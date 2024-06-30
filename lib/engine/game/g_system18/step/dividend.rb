# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module GSystem18
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          SIMPLE_DIVIDEND_TYPES = %i[payout withhold].freeze
          include Engine::Step::HalfPay

          def share_price_change(entity, revenue = 0)
            return super unless @game.game_capitalization == :incremental

            price = entity.share_price.price
            LOGGER.debug { "price: #{price}, revenue: #{revenue}" }

            if revenue.zero?
              { share_direction: :left, share_times: 1 }
            elsif revenue >= 2 * price
              { share_direction: :right, share_times: 2 }
            elsif revenue >= price
              { share_direction: :right, share_times: 1 }
            else
              {}
            end
          end

          def pass!
            super
          end

          def dividend_types
            if @game.half_dividend_by_map?
              DIVIDEND_TYPES
            else
              SIMPLE_DIVIDEND_TYPES
            end
          end
        end
      end
    end
  end
end
