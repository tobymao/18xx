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

          def round_state
            super.merge({ train_in_route: [] })
          end

          def available_hex(entity, hex)
            return true if entity.corporation? && entity.assigned?(@game.wings.id)

            super
          end

          def process_run_routes(action)
            super

            track_running_trains(action.entity)

            return if @game.two_barrels.closed? || !@game.two_barrels.all_abilities.empty?

            # Close 'Two Barrels' if used and no more usage
            @game.two_barrels.close!
            @log << "'#{@game.two_barrels.name}' is closed"
          end

          def process_pass(action)
            super

            track_running_trains(action.entity)
          end

          def log_skip(entity)
            super

            track_running_trains(entity)
          end

          def chart(entity)
            threshold = @game.threshold(entity)
            bonus_hold = @game.chart_price(entity.share_price)
            bonus_pay = @game.chart_price(@game.share_price_updated(entity, threshold))
            [
              ["Threshold#{nbsp(4)}Move", 'Dividend'],
              ["withhold#{nbsp(6)}1 ←", ''],
              ["< #{@game.format_revenue_currency(threshold)}#{nbsp(13)}", bonus_hold.to_s],
              ["≥ #{@game.format_revenue_currency(threshold)}#{nbsp(6)}1 →", bonus_pay.to_s],
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

          def track_running_trains(entity)
            # Track running train (to handle obsolete train with patch)
            @round.train_in_route = entity.trains.map(&:id)
          end
        end
      end
    end
  end
end
