# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module GFrost1831
      module Step
        class Dividend < Engine::Step::Dividend
          def actions(entity)
            return %w[choose] if entity&.company? && entity.sym == 'FAV'
            return [] if entity&.type == :faction

            super
          end

          # Frost 1831: share price moves right only if TOTAL revenue >= market value
          # If positive but below market value: no movement
          # If zero (withhold): move left
          def share_price_change(entity, revenue)
            return {} if entity.type == :faction

            if revenue.zero?
              { share_direction: :left, share_times: 1 }
            else
              if revenue >= entity.share_price.price
                { share_direction: :right, share_times: 1 }
              else
                {}
              end
            end
          end

          def process_choose(action)
            return unless action.entity&.sym == 'FAV'

            special_choose = @round.steps.find { |s| s.is_a?(GFrost1831::Step::SpecialChoose) }
            special_choose&.process_choose_ability(action)
          end

          def skip!
            return if current_entity&.type == :faction

            super
          end

          def log_skip(entity)
            return if entity.type == :faction

            super
          end
        end
      end
    end
  end
end
