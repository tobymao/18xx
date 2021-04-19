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
            slots = action.slots
            entity = action.entity
            reassignments = []
            slots.each do |slot|
              train_id, corp_id = slot.split(';')
              train = @game.train_by_id(train_id)
              new_corporation = @game.corporation_by_id(corp_id)

              next if new_corporation == train.owner

              old_owner = train.owner
              old_owner.trains.delete(train)

              train.owner = new_corporation
              new_corporation.trains << train

              reassignments << "#{train.name} ➝ #{new_corporation.name}"
            end

            @log << "#{entity.owner.name} reassignes trains: #{reassignments.join(', ')}"
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
