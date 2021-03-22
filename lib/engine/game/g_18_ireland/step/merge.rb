# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../token'
require_relative '../../../step/token_merger'

module Engine
  module Game
    module G18Ireland
      module Step
        class Merge < Engine::Step::Base
          include Engine::Step::TokenMerger
          LIMIT_MERGE = 3

          def actions(entity)
            return [] unless entity.player?
            return ['merge'] if @round.merging&.one? || finalize_merger?
            return [] if @round.vote_outcome == :against

            %w[pass merge]
          end

          # @todo: Auto actions including non-possible merger skip

          def finalize_merger?
            @round.vote_outcome == :for
          end

          def merge_name
            return 'Choose new corporation' if finalize_merger?
            return 'Add to proposed merge' if @round.merging

            'Propose Merge'
          end

          def pass_description
            return 'Start Voting on Proposal' if @round.merging

            super
          end

          def can_merge?(entity)
            mergeable_candidates(entity).any?
          end

          def description
            'Propose Minor Corporation Merge'
          end

          def move_assets(from, to)
            receiving = []

            if from.cash.positive?
              receiving << @game.format_currency(from.cash)
              from.spend(from.cash, to)
            end

            companies = @game.transfer(:companies, from, to).map(&:name)
            receiving << "companies (#{companies.join(', ')})" if companies.any?

            loans = @game.transfer(:loans, from, to).size
            receiving << "loans (#{loans})" if loans.positive?

            trains = @game.transfer(:trains, from, to).map(&:name)
            receiving << "trains (#{trains})" if trains.any?

            receiving
          end

          def move_tokens(from, to)
            from.tokens.each do |token|
              new_token = to.next_token
              unless new_token
                new_token = Engine::Token.new(to)
                to.tokens << new_token
              end

              city = token.city
              token.remove!
              city.place_token(to, new_token, check_tokenable: false)
            end
          end

          def finish_merge
            # @todo: Calculate votes for stock market shares
            players = @game.players.rotate(@game.players.index(current_entity))
            @round.to_vote = players.map do |player|
              shares = @round.merging.sum { |corp| player.num_shares_of(corp,) }
              [player, shares] unless shares.zero?
            end.compact

            @round.votes_needed = (@round.to_vote.sum { |_player, shares| shares } / 2.0).ceil
            voters = @round.to_vote.map { |p, _s| p.name }.join(',')
            @game.log << "Shareholders (#{voters}) will now vote for proposed merge of "\
            "#{@round.merging.map(&:name).join(',')}, #{@round.votes_needed} votes needed"

            @round.votes_for = 0
            @round.votes_against = 0
          end

          def finish_merge_to_major(action)
            target = action.corporation
            initiator = action.entity
            # @todo: New price is complex...
            merged_share_price = @round.merging.first.share_price

            @game.stock_market.set_par(target, merged_share_price)

            target.ipoed = true

            # 'Buy' shares in player order, which will result in the presidency ended up in the right place.
            players = @game.players.rotate(@game.players.index(initiator))
            player_shares = players.map do |player|
              shares = @round.merging.sum { |corp| player.num_shares_of(corp,) }
              [player, shares] unless shares.zero?
            end.compact

            # Transfer assets
            @round.merging.each do |corporation|
              remove_duplicate_tokens(target, @round.merging)
              move_tokens(corporation, target)

              receiving = move_assets(corporation, target)
              @game.close_corporation(corporation)
              @log << "#{corporation.name} merges into #{target.name} receiving #{receiving.join(', ')}"
              @round.entities.delete(corporation)
            end

            player_shares.each do |player, shares|
              # @todo: this could be cleaner
              shares.times do
                share = target.shares.last

                if target.shares.first.president && player.percent_of(target) == 10
                  # give the 10% back
                  presidency = target.shares.first
                  player.shares_of(target).first.transfer(presidency.owner)
                  # grab the presidency
                  @game.share_pool.buy_shares(player, presidency.to_bundle, exchange: :free)
                else
                  @game.share_pool.buy_shares(player, share.to_bundle, exchange: :free)
                end
              end
            end
            # @todo: market shares

            move_tokens_to_surviving(target, @round.merging)

            # Add the $50 token back
            if target.tokens.size < 3
              new_token = Engine::Token.new(target, price: 50)
              target.tokens << new_token
            end

            tokens = target.tokens.map { |t| t.city&.hex&.id }
            charter_tokens = tokens.size - tokens.compact.size
            @log << "#{target.name} has tokens (#{tokens.size}: #{tokens.compact.size} on hexes #{tokens.compact}"\
            "#{charter_tokens.positive? ? " & #{charter_tokens} on the charter" : ''})"

            @round.merging = nil
            @round.vote_outcome = nil
            pass!
          end

          def process_merge(action)
            return finish_merge_to_major(action) if finalize_merger?
            if !@game.loading && !mergeable(action.entity).include?(action.corporation)
              raise GameError, "Cannot merge with #{action.corporation.name}"
            end

            @round.merging ||= []
            @game.log <<
              if @round.merging.empty?
                "Proposing merge of #{action.corporation.name}"
              else
                "Adding #{action.corporation.name} to proposed merge of #{@round.merging.map(&:name).join(',')}"
              end
            @round.merging << action.corporation

            return unless mergeable_candidates(action.entity).none?

            # No more potential merges, finish merge
            finish_merge
          end

          def process_pass(action)
            if @round.merging
              finish_merge
            else
              super
            end
          end

          def new_share_price(corporation, target)
            new_price =
              if corporation.total_shares == 2
                corporation.share_price.price + target.share_price.price
              else
                (corporation.share_price.price + target.share_price.price) / 2
              end
            @game.find_share_price(new_price)
          end

          def mergeable_type(entity)
            if finalize_merger?
              'New Corporation for merger'
            elsif @round.merging
              'Corporations to add to proposed merger'
            else
              "Corporations that can be proposed for merger by #{entity.name}"
            end
          end

          def mergeable_candidates(entity)
            merging = @round.merging || []

            # Can't merge at 3 corporations
            return [] if merging.size == LIMIT_MERGE

            # Can propose merging any corporations they have at least one share of
            # @todo: filter corporations that would exceed shares, majors and ensure connectivity
            # there's a bunch of other rules as well
            @game.corporations.select do |c|
              c.floated? && c.type == :minor && !merging.include?(c) && !entity.shares_of(c).empty?
            end
          end

          def mergeable(entity)
            if finalize_merger?
              @game.corporations.select do |target|
                target.type == :major &&
                !target.floated?
              end
            else
              mergeable_candidates(entity)
            end
          end

          def show_other_players
            true # Could say this being true is actually the game...
          end

          def round_state
            {
              votes_for: 0,
              votes_against: 0,
              votes_needed: nil,
              vote_outcome: nil,
              to_vote: [],
              merging: nil,
            }
          end
        end
      end
    end
  end
end
