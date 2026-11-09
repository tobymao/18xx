# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18OE
      module Step
        class OrientExpressBonus < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless @round.orient_express_revenue
            return [] if @game.orient_express_marker?(entity)

            ACTIONS
          end

          def description
            'Orient Express Bonus'
          end

          def choice_name
            'Orient Express first-time bonus'
          end

          def choices
            {
              'cash' => "Bank pays #{@game.format_currency(@round.orient_express_revenue)} "\
                        '(Orient Express train revenue)',
              'right' => 'Share value RIGHT 3 times',
            }
          end

          def process_choose(action)
            entity = action.entity
            raise GameError, "Invalid Orient Express bonus: #{action.choice}" unless choices.key?(action.choice)

            @game.place_orient_express_marker!(entity)
            @log << "#{entity.name} receives an Orient Express marker"

            if action.choice == 'cash'
              amount = @round.orient_express_revenue
              @game.bank.spend(amount, entity)
              @log << "#{entity.name} receives #{@game.format_currency(amount)} Orient Express bonus"
            else
              old_price = entity.share_price
              3.times { @game.stock_market.move_right(entity) }
              @game.log_share_price(entity, old_price, 3)
            end

            pass!
          end
        end
      end
    end
  end
end
