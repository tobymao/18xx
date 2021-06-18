# frozen_string_literal: true

module Engine
  module Game
    module G1840
      module Step
        class InterruptingBuyTrain < BuyTrain
          def active_entities
            [buying_entity]
          end

          def round_state
            {
              corporation_bought_minor: [],
            }
          end

          def active?
            buying_entity
          end

          def current_entity
            buying_entity
          end

          def buying_entity
            corporation[:entity]
          end

          def corporation
            @round.corporation_bought_minor&.first || {}
          end

          def pass!
            @round.corporation_needs_reassign << {
              entity: buying_entity,
            }
            @round.corporation_bought_minor.shift
            super
          end
        end
      end
    end
  end
end
