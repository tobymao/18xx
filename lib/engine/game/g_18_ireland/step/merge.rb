# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../token'
require_relative '../../../step/token_merger'
require_relative 'merger_common'

module Engine
  module Game
    module G18Ireland
      module Step
        class Merge < Engine::Step::Base
          include Engine::Step::TokenMerger
          include MergerCommon
          LIMIT_MERGE = 3

          def actions(entity)
            return [] unless entity.player?
            return ['merge'] if @round.merging&.one? || finalize_merger?
            return [] if @round.vote_outcome == :against
            # Must be an unstarted 10 share corporation to be able to do a merge.
            return ['pass'] if merge_targets.empty?

            %w[pass merge]
          end

          def auto_actions(entity)
            # @todo: Sort of programmed actions for 18ireland
            return super if @round.merging&.one? || finalize_merger?

            return [Engine::Action::Pass.new(entity)] if mergeable_candidates(entity).empty?

            super
          end

          def finalize_merger?
            @round.vote_outcome == :for
          end

          def merge_name(_entity = nil)
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
            receiving << "companies (#{companies.join(', ')})" unless companies.empty?

            loans = @game.transfer(:loans, from, to).size
            receiving << "loans (#{loans})" if loans.positive?

            trains = @game.transfer(:trains, from, to).map(&:name)
            receiving << "trains (#{trains})" unless trains.empty?

            to.assignments.merge!(from.assignments)
            receiving << "assignments (#{from.assignments.keys})" unless from.assignments.empty?

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

          def new_share_price
            # Find the left most price
            new_column = @round.merging.map { |p| p.share_price.coordinates.last }.min
            # Find the top most price
            new_row = @round.merging.map { |p| p.share_price.coordinates.first }.min
            @game.stock_market.share_price([new_row, new_column])
          end

          def finish_merge(entity)
            # Sort to ensure uniqueness
            merging_sorted = @round.merging.sort
            if (previous_proposer = @round.proposed_mergers[merging_sorted])
              # Filtering proposals would be quite complex as it can be 2 long or 3 long, this is easy.
              @game.log << "#{previous_proposer.name} already proposed the same exact merger of"\
                           " #{@round.merging.map(&:name).join(', ')}."\
                           ' This is against the rules, clearing proposal.'
              @round.merging = nil
              return
            end

            players = @game.players.rotate(@game.players.index(current_entity))
            players.each(&:unpass!)
            @round.to_vote = players.map do |player|
              shares = @round.merging.sum { |corp| player.num_shares_of(corp,) }
              [player, shares] unless shares.zero?
            end.compact

            new_price = new_share_price
            @round.votes_for = 0
            @round.votes_against = 0

            @round.merging.each do |corp|
              shares = @game.share_pool.num_shares_of(corp)
              unless shares.zero?

                if new_price.price > corp.share_price.price
                  @round.votes_for += shares
                  @game.log << "#{shares} market shares of #{corp.name} vote for merger #{vote_summary}"
                elsif new_price.price < corp.share_price.price
                  @round.votes_against += shares
                  @game.log << "#{shares} market shares of #{corp.name} vote against merger #{vote_summary}"
                else
                  @game.log << "#{shares} market shares of #{corp.name} abstain"
                end
              end
            end

            @round.votes_available = @round.votes_for + @round.votes_against + @round.to_vote.sum do |_player, shares|
              shares
            end
            @round.votes_needed = (@round.votes_available / 2.0).floor + 1
            voters = @round.to_vote.map { |p, _s| p.name }.join(', ')
            @game.log << "Shareholders (#{voters}) will now vote for proposed merge of "\
                         "#{@round.merging.map(&:name).join(', ')}; "\
                         "#{@round.votes_needed}/#{@round.votes_available} votes needed for success"

            @round.proposed_mergers[merging_sorted] = entity

            # just in case the market shares carry the vote

            check_result
          end

          def finish_merge_to_major(action)
            target = action.corporation
            initiator = action.entity
            merged_share_price = new_share_price

            @game.stock_market.set_par(target, merged_share_price)

            target.ipoed = true

            # 'Buy' shares in player order, which will result in the presidency ended up in the right place.
            players = @game.players.rotate(@game.players.index(initiator))
            player_shares = players.map do |player|
              shares = @round.merging.sum { |corp| player.num_shares_of(corp,) }
              [player, shares] unless shares.zero?
            end.compact

            market_shares = @round.merging.sum { |corp| @game.share_pool.num_shares_of(corp) }

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
              bundle =
                if shares > 1 && target.shares.first.president
                  target.shares.take(shares - 1)
                elsif target.shares.first.president
                  target.shares.drop(1).take(shares)
                else
                  target.shares.take(shares)
                end
              @game.share_pool.buy_shares(player, ShareBundle.new(bundle), exchange: :free)
            end
            # market shares, presidency will be with a player, so can just buy
            unless market_shares.zero?
              @game.share_pool.buy_shares(@game.share_pool, ShareBundle.new(target.shares.take(market_shares)),
                                          exchange: :free)
            end

            tokens = target.tokens.map { |t| t.city&.hex&.id }
            charter_tokens = tokens.size - tokens.compact.size
            @log << "#{target.name} has tokens (#{tokens.size}: #{tokens.compact.size} on hexes #{tokens.compact}"\
                    "#{charter_tokens.positive? ? " & #{charter_tokens} on the charter" : ''})"

            @round.merging = nil
            @round.vote_outcome = nil
            @corp_connectivity.clear
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
                "#{action.entity.name} proposing merge of #{action.corporation.name}"
              else
                "#{action.entity.name} adds #{action.corporation.name}"\
                  " to proposed merge of #{@round.merging.map(&:name).join(', ')}"
              end
            @round.merging << action.corporation

            return unless mergeable_candidates(action.entity).none?

            # No more potential merges, finish merge
            finish_merge(action.entity)
          end

          def process_pass(action)
            if @round.merging
              finish_merge(action.entity)
            else
              current_entity.pass!
              super
            end
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

          def corporation_connected?(c1, c2)
            # Are corporations connected (blocking by tokens doesn't matter)
            unless @corp_connectivity[c1]
              new_home = c1.tokens.first.city
              connected = [c1]
              visited = {}
              new_home.walk(skip_track: :narrow) do |path, _, _|
                next if visited[path]

                visited[path] = true

                path.nodes.each do |p_node|
                  next unless p_node.city?
                  next if visited[p_node]

                  visited[p_node] = true

                  a = p_node.tokens.select { |t| t&.corporation&.type == :minor }.map(&:corporation)
                  connected.concat(a)
                end
              end
              connected.each { |c| @corp_connectivity[c] = connected }
            end
            @corp_connectivity[c1].include?(c2)
          end

          def merge_possible?(corporations, new_corporation)
            return false if corporations.include?(new_corporation)

            # Minors only have one token
            new_home = new_corporation.tokens.first.city

            return false unless corporations.any? { |c| corporation_connected?(c, new_corporation) }

            # Don't share tokens (minors only have one token)
            return false if corporations.any? { |c| c.tokens.first.city.tile == new_home.tile }

            all_corporations = corporations + [new_corporation]
            # No more than 10 shares issued between players and the market (5 share corporation...)
            return false if all_corporations.sum { |corp| 5 - corp.shares.size } > 10
            # no player will end up over 70%
            return false if @game.players.any? do |player|
              all_corporations.sum { |corp| player.num_shares_of(corp,) } > 7
            end
            # Market wouldn't have more than 50%
            return false if all_corporations.sum { |corp| @game.share_pool.num_shares_of(corp) } > 5

            true
          end

          def merge_targets
            @game.corporations.select do |target|
              target.type == :major && !target.floated?
            end
          end

          def mergeable_candidates(entity)
            merging = @round.merging || []

            return [] if merge_targets.empty?

            # Can't merge at 3 corporations
            return [] if merging.size == LIMIT_MERGE

            # Can propose merging any corporations they have at least one share of
            potential_corporations = @game.corporations.select do |c|
              c.floated? && c.type == :minor && !merging.include?(c)
            end
            if merging.empty?
              # first corporation must have shares owned by player
              start_corporations = potential_corporations.reject { |c| entity.shares_of(c).empty? }
              start_corporations.select { |c| potential_corporations.any? { |c2| merge_possible?([c], c2) } }
            else
              potential_corporations.select { |c| merge_possible?(merging, c) }
            end
          end

          def mergeable(entity)
            if finalize_merger?
              merge_targets
            else
              mergeable_candidates(entity)
            end
          end

          def show_other_players
            true # Could say this being true is actually the game...
          end

          def setup
            @corp_connectivity = {}
            @round.vote_outcome = nil
            @round.merging = nil
          end

          def round_state
            {
              votes_for: 0,
              votes_against: 0,
              votes_needed: nil,
              votes_available: nil,
              vote_outcome: nil,
              to_vote: [],
              merging: nil,
              proposed_mergers: {},
            }
          end
        end
      end
    end
  end
end
