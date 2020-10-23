# frozen_string_literal: true

require_relative '../base'
require_relative '../../token'
require_relative 'token_merger'

module Engine
  module Step
    module G1817
      class Conversion < Base
        include TokenMerger

        def actions(entity)
          return [] if !entity.corporation? || entity != current_entity

          actions = []
          actions << 'convert' if [2, 5].include?(entity.total_shares)
          actions << 'merge' if mergeable(entity).any?
          actions << 'pass' if actions.any?
          actions
        end

        def description
          'Convert or Merge Corporation'
        end

        def process_convert(action)
          corporation = action.entity
          before = corporation.total_shares
          @game.convert(corporation)
          after = corporation.total_shares
          @log << "#{corporation.name} converts from #{before} to #{after} shares"

          tokens = corporation.tokens.size

          @round.tokens_needed =
            if after == 5
              tokens < 8 ? 1 : 0
            elsif after == 10
              [[8 - tokens, 0].max, 2].min
            else
              0
            end

          @round.converted = corporation
        end

        def process_merge(action)
          corporation = action.entity
          target = action.corporation

          if !target || !mergeable(corporation).include?(target)
            @game.game_error("Choose a corporation to merge with #{corporation.name}")
          end

          receiving = []

          if target.cash.positive?
            receiving << @game.format_currency(target.cash)
            target.spend(target.cash, corporation)
          end

          companies = target.transfer(:companies, corporation).map(&:name)
          receiving << "companies (#{companies.join(', ')})" if companies.any?

          loans = target.transfer(:loans, corporation).size
          receiving << "loans (#{loans})" if loans.positive?

          trains = target.transfer(:trains, corporation).map(&:name)
          receiving << "trains (#{trains})" if trains.any?

          remove_duplicate_tokens(corporation, target)
          if tokens_above_limits?(corporation, target)
            @game.log << "#{corporation.name} will be above token limit and must decide which tokens to keep"
            @round.corporations_removing_tokens = [corporation, target]
          else
            tokens = move_tokens_to_surviving(corporation, target)
            receiving << "and tokens (#{tokens.size}: hexes #{tokens.compact})"
          end

          initial_size = corporation.total_shares
          new_price =
            if initial_size == 2
              corporation.share_price.price + target.share_price.price
            else
              (corporation.share_price.price + target.share_price.price) / 2
            end
          share_price = @game.find_share_price(new_price)
          price = share_price.price
          @game.stock_market.move(corporation, *share_price.coordinates)

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
        end

        def log_pass(entity)
          super unless entity.share_price.liquidation?
        end

        def mergeable(corporation)
          return [] if !corporation.floated? || !corporation.share_price.normal_movement?

          @game.corporations.select do |target|
            target.floated? &&
              target.share_price.normal_movement? &&
              target != corporation &&
              target.total_shares != 10 &&
              target.total_shares == corporation.total_shares &&
            # on 5 share merges ensure one player will have at least enough shares to take the presidency
            (target.total_shares != 5 || merged_max_share_holder(corporation, target) > 40)
          end
        end

        def merged_max_share_holder(corporation, target)
          corporation.player_share_holders
          .merge(target.player_share_holders) { |_key, corp, other| (corp + other) }
          .values.max
        end

        def round_state
          {
            converted: nil,
            tokens_needed: nil,
          }
        end
      end
    end
  end
end
