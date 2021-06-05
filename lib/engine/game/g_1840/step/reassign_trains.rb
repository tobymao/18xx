# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1840
      module Step
        class ReassignTrains < Engine::Step::Base
          BUY_ACTIONS = %w[reassign_trains pass].freeze

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

          def process_reassign_trains(action)
            assignments = action.assignments
            entity = action.entity
            reassignments = []
            assignments.each do |assignment|
              train = assignment[:train]
              new_corporation = assignment[:corporation]
              next if new_corporation == train.owner

              old_owner = train.owner
              old_owner.trains.delete(train)

              train.owner = new_corporation
              new_corporation.trains << train

              reassignments << "#{train.name} ➝ #{new_corporation.name}"
            end

            invalid_tram_corp = @game.tram_owned_by_corporation[entity].find { |item| item.trains.size > 1 }
            if invalid_tram_corp
              raise GameError,
                    "#{invalid_tram_corp.full_name} cannot be assigned more than one train"
            end

            @log << "#{entity.owner.name} reassignes trains: #{reassignments.join(', ')}" unless reassignments.empty?
          end

          def trains(entity)
            @game.tram_owned_by_corporation[entity].flat_map(&:trains).concat(entity.trains)
          end

          def target_corporations(entity)
            [entity].concat(@game.tram_owned_by_corporation[entity])
          end
        end
      end
    end
  end
end
