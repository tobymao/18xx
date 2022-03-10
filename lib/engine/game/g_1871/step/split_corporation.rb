# frozen_string_literal: true

module Engine
  module Game
    module G1871
      module Step
        class SplitCorporation < Engine::Step::Base
          def description
            @round.split_description
          end

          def actions(entity)
            return [] unless entity == current_entity

            ['choose']
          end

          def choices
            @round.split_choices
          end

          def choice_available?(entity)
            @round.split_choice_entity == entity
          end

          def selected_corporation
            @round.split_corporations.last
          end

          def visible_corporations
            @round.split_corporations
          end

          def choice_name
            @round.split_prompt
          end

          def process_choose(choose)
            @round.split_process_choose(choose)
          end

          def ipo_type(_entity)
            :par
          end

          def active?
            @round.split_active?
          end

          def choice_is_amount?
            @round.choice_is_amount?
          end

          def active_entities
            @round.split_active_entities
          end
        end
      end
    end
  end
end
