# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../token'
require_relative '../../../step/token_merger'
require_relative '../../../step/programmer_merger_pass'

module Engine
  module Game
    module G1817
      module Step
        class Conversion < Engine::Step::Base
          include Engine::Step::TokenMerger
          include Engine::Step::ProgrammerMergerPass

          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity

            actions = []
            actions << 'convert' if [2, 5].include?(entity.total_shares)
            actions << 'merge' if mergeable(entity).any?
            actions << 'pass' if actions.any?
            actions
          end

          def merge_name(_entity = nil)
            'Merge'
          end

          def description
            'Convert or Merge Corporation'
          end

          def merger_auto_pass_entity
            # Buying and selling shares are done by other steps
            current_entity
          end

          def others_acted?
            !@round.converts.empty?
          end

          def process_convert(action)
            corporation = action.entity
            before = corporation.total_shares
            @game.convert(corporation)
            after = corporation.total_shares
            @log << "#{corporation.name} converts from #{before} to #{after} shares"

            tokens = corporation.tokens.size

            @round.tokens_needed =
              case after
              when 5
                tokens < 8 ? 1 : 0
              when 10
                [[8 - tokens, 0].max, 2].min
              else
                0
              end

            @round.converts << corporation
            @round.converted_price = corporation.share_price
            @round.converted = corporation
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

          def process_merge(action)
            corporation = action.entity
            target = action.corporation

            if !target || !mergeable(corporation).include?(target)
              raise GameError, "Choose a corporation to merge with #{corporation.name}"
            end

            receiving = []

            if target.cash.positive?
              receiving << @game.format_currency(target.cash)
              target.spend(target.cash, corporation)
            end

            companies = @game.transfer(:companies, target, corporation).map(&:name)
            receiving << "companies (#{companies.join(', ')})" if companies.any?

            loans = @game.transfer(:loans, target, corporation).size
            receiving << "loans (#{loans})" if loans.positive?

            trains = @game.transfer(:trains, target, corporation).map(&:name)
            receiving << "trains (#{trains})" if trains.any?

            remove_duplicate_tokens(corporation, target)
            if tokens_above_limits?(corporation, target)
              @game.log << "#{corporation.name} will be above token limit and must decide which tokens to remove"
              @round.corporations_removing_tokens = [corporation, target]
            else
              tokens = move_tokens_to_surviving(corporation, target)
              receiving << "and tokens (#{tokens.size}: hexes #{tokens.compact})"
            end

            initial_size = corporation.total_shares
            share_price = new_share_price(corporation, target)
            price = share_price.price
            @game.stock_market.move(corporation, share_price.coordinates)

            @log << "#{corporation.name} merges with #{target.name} "\
                    "at share price #{@game.format_currency(price)} receiving #{receiving.join(', ')}"

            owner = corporation.owner
            target_owner = target.owner

            if initial_size == 2
              @game.convert(corporation)
              if owner != target_owner
                owner.spend(price, corporation)
                share = corporation.shares[0]
                @log << "#{owner.name} buys a #{share.percent}% share for #{@game.format_currency(price)} "\
                        "and receives the president's share"
                @game.share_pool.buy_shares(target_owner, share.to_bundle, exchange: :free)
              end
            else
              @game.migrate_shares(corporation, target)
            end

            @game.reset_corporation(target)

            @round.entities.delete(target)

            # Deleting the entity changes turn order, restore it.
            @round.goto_entity!(corporation) unless @round.entities.empty?

            @round.converted = corporation
            @round.converted_price = corporation.share_price
            @round.converts << corporation
          end

          def log_pass(entity)
            super unless entity.share_price.liquidation?
          end

          def mergeable_type(corporation)
            "Corporations that can merge with #{corporation.name}"
          end

          def show_other_players
            false
          end

          def mergeable(corporation)
            return [] if !corporation.floated? || !corporation.share_price.normal_movement?

            @game.corporations.select do |target|
              target.floated? &&
              !@round.converts.include?(target) &&
                target.share_price.normal_movement? &&
                !target.share_price.acquisition? &&
                target != corporation &&
                target.total_shares != 10 &&
                target.total_shares == corporation.total_shares &&
              # on 5 share merges ensure one player will have at least enough shares to take the presidency
              (target.total_shares != 5 || merged_max_share_holder(corporation, target) >= 40) &&
              owner_can_afford_extra_share(corporation, target)
            end
          end

          def merged_max_share_holder(corporation, target)
            corporation.player_share_holders
            .merge(target.player_share_holders) { |_key, corp, other| (corp + other) }
            .values.max
          end

          def owner_can_afford_extra_share(corporation, target)
            target.total_shares != 2 ||
            corporation.owner == target.owner ||
            (corporation.owner.cash >= new_share_price(corporation, target).price)
          end

          def round_state
            {
              converted: nil,
              converted_price: nil,
              tokens_needed: nil,
              converts: [],
            }
          end
        end
      end
    end
  end
end
