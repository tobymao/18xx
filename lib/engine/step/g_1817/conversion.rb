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
          actions << 'take_loan' if @tokens_needed && @game.can_take_loan?(entity)
          actions << 'pass' if actions.any?
          actions
        end

        def pass_description
          if needs_money?(current_entity)
            'Liquidate Corporation'
          elsif current_actions.include?('take_loan')
            'Pass (Loans)'
          else
            super
          end
        end

        def description
          'Convert or Merge Corporation'
        end

        def process_take_loan(action)
          corporation = action.entity
          @game.take_loan(corporation, action.loan)
          purchase_tokens(corporation) unless @game.can_take_loan?(corporation)
        end

        def process_pass(action)
          corporation = action.entity

          liquidate!(corporation) if needs_money?(corporation)
          purchase_tokens(corporation) if @tokens_needed

          super
        end

        def process_convert(action)
          corporation = action.entity
          before = corporation.total_shares
          @game.convert(corporation)
          after = corporation.total_shares
          @log << "#{corporation.name} converts from #{before} to #{after} shares"

          tokens = corporation.tokens.size

          @tokens_needed =
            if after == 5
              tokens < 8 ? 1 : 0
            elsif after == 10
              [[8 - tokens, 0].max, 2].min
            else
              0
            end

          liquidate!(corporation) if needs_money?(corporation) && !@game.can_take_loan?(corporation)
          purchase_tokens(corporation) unless @game.can_take_loan?(corporation)
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

          share_price = @game.find_share_price(corporation.share_price.price + target.share_price.price)
          price = share_price.price
          @game.stock_market.move(corporation, *share_price.coordinates)

          @log << "#{corporation.name} merges with #{target.name} "\
            "at share price #{@game.format_currency(price)} receiving #{receiving.join(', ')}"

          @game.convert(corporation)

          owner = corporation.owner
          target_owner = target.owner

          if owner != target_owner
            owner.spend(price, corporation)
            share = corporation.shares[0]
            @log << "#{owner.name} buys a #{share.percent}% share for #{@game.format_currency(price)} "\
              "and receives the president's share"
            @game.share_pool.buy_shares(target_owner, share.to_bundle, exchange: :free)
          end

          @game.reset_corporation(target)
          @round.entities.delete(target)
          @round.converted = corporation
        end

        def log_pass(entity)
          super unless entity.share_price.liquidation?
        end

        def liquidate!(corporation)
          @game.liquidate!(corporation)
          @log << "#{corporation.name} cannot purchase required tokens and liquidates"
          @tokens_needed = nil
        end

        def purchase_tokens(corporation)
          return unless token_cost.positive?
          return if needs_money?(corporation)

          corporation.spend(token_cost, @game.bank)
          @tokens_needed.times { corporation.tokens << Engine::Token.new(corporation, price: 0) }
          @log << "#{corporation.name} pays #{@game.format_currency(token_cost)}"\
            " for #{@tokens_needed} token#{@tokens_needed > 1 ? 's' : ''}"
          @tokens_needed = nil
          pass!
        end

        def mergeable(corporation)
          return [] if !corporation.floated? || !corporation.share_price.normal_movement?

          @game.corporations.select do |target|
            target.floated? &&
              target.share_price.normal_movement? &&
              target != corporation &&
              target.total_shares == corporation.total_shares
          end
        end

        private

        def setup
          @tokens_needed = nil
        end

        def round_state
          {
            converted: nil,
          }
        end

        def needs_money?(corporation)
          @tokens_needed && token_cost > corporation.cash
        end

        def token_cost
          (@tokens_needed || 0) * 50
        end
      end
    end
  end
end
