# frozen_string_literal: true

require_relative '../base'
require_relative '../../token'

module Engine
  module Step
    module G1817
      class Conversion < Base
        def actions(entity)
          return [] if !entity.corporation? || entity != current_entity

          actions = []
          actions << 'convert' if !@tokens_needed && [2, 5].include?(entity.total_shares)
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
          'Convert Corporation'
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

        def log_pass(entity)
          super unless entity.share_price.liquidation?
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

        def setup
          @tokens_needed = nil
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
