# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module GRollingStock
      module Step
        class Dividend < Engine::Step::Base
          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity
            return [] if entity.receivership?

            %w[dividend]
          end

          def description
            'Select Dividends'
          end

          def dividend_types
            [:variable]
          end

          def skip!
            return super if !current_entity.corporation? || !current_entity.receivership?

            process_dividend(Action::Dividend.new(current_entity, kind: 'variable', amount: 0))
          end

          def process_dividend(action)
            entity = action.entity
            amount = action.amount

            raise GameError, "Illegal dividend amount #{amount}" unless amount <= @game.max_dividend_per_share(entity)

            receiver = entity.receivership? ? ' (in receivership)' : ''
            @log << "#{entity.name}#{receiver} pays #{@game.format_currency(amount)} per share"
            @game.players.each { |p| payout_player(entity, p, amount) }
            payout_market(entity, amount)
            @game.dividend_price_movement(entity)

            pass!
          end

          def payout_player(corporation, player, amount)
            return unless amount.positive?

            num_shares = player.num_shares_of(corporation, ceil: false)
            return unless num_shares.positive?

            total = num_shares * amount

            corporation.spend(total, player)
            @log << "#{player.name} has #{num_shares} share#{num_shares > 1 ? 's' : ''} of #{corporation.name}"\
                    " and receives #{@game.format_currency(total)}"
          end

          def payout_market(corporation, amount)
            return unless amount.positive?

            num_shares = corporation.num_market_shares
            return unless num_shares.positive?

            total = num_shares * amount
            corporation.spend(total, @game.bank)
            @log << "The Market has #{num_shares} share#{num_shares > 1 ? 's' : ''} of #{corporation.name}"\
                    " and receives #{@game.format_currency(total)}"
          end

          def help_str(max)
            @game.dividend_help_str(current_entity, max)
          end

          def variable_max
            @game.max_dividend_per_share(current_entity)
          end

          def variable_share_multiplier(_corporation)
            1
          end

          def variable_input_step
            1
          end

          def chart
            @game.dividend_chart(current_entity)
          end
        end
      end
    end
  end
end
