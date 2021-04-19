# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1840
      module Step
        class ReassignTrains < Engine::Step::Base
          BUY_ACTIONS = %w[switch_trains pass].freeze

          def actions(_entity)
            BUY_ACTIONS
          end

          def pass_description
            @acted ? 'Done (Reassign)' : 'Skip (Reassign)'
          end

          def description
            'Reassign Trains'
          end

          def help_text
            'Select new corporations for each train'
          end

          def slot_view(_entity)
            'trains'
          end

          def process_switch_trains(action)
            entity = action.entity
            slots = action.slots

            slots.each do |slot|
              puts slot
              train_id, corp_id = slot.split('-')
              puts train_id
              puts corp_id
              puts @game.train_by_id(train_id)
              p @game.corporation_by_id(corp_id)


            end
          end

          def trains(entity)
            entity.trains + @game.tram_owned_by_corporation[entity].flat_map(&:trains)
          end

          def target_corporations(entity)
            [entity] + @game.tram_owned_by_corporation[entity]
          end
        end
      end
    end
  end
end
