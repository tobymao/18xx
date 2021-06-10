# frozen_string_literal: true

require_relative 'choose_ability_on_or'

module Engine
  module Game
    module G18ZOO
      module Step
        class Route < Engine::Step::Route
          include Engine::Game::G18ZOO::ChooseAbilityOnOr

          def actions(entity)
            return ['choose_ability'] if entity.company? && can_choose_ability?(entity)

            super
          end

          def available_hex(entity, hex)
            return true if entity.corporation? && entity.assigned?(@game.wings.id)

            super
          end

          def process_run_routes(action)
            super

            return unless @game.two_barrels.all_abilities.empty?

            # Close 'Two Barrels' if used and no more usage
            @game.two_barrels.close!
            @log << "'#{@game.two_barrels.name}' is closed"
          end

          def chart(entity)
            threshold = @game.threshold(entity)
            bonus_hold = @game.chart_price(entity.share_price)
            bonus_pay = @game.chart_price(@game.share_price_updated(entity, threshold))
            [
              ["Threshold#{nbsp(4)}Move", 'Dividend'],
              ["withhold#{nbsp(6)}1 ←", ''],
              ["< #{threshold} nuts#{nbsp(13)}", bonus_hold.to_s],
              ["≥ #{threshold} nuts#{nbsp(6)}1 →", bonus_pay.to_s],
            ]
          end

          private

          def nbsp(time)
            ' ' * time
          end

          def can_choose_ability?(company)
            entity = @game.current_entity
            return false unless entity.corporation?

            return true if @game.can_choose_two_barrels?(entity, company)

            false
          end
        end
      end
    end
  end
end
