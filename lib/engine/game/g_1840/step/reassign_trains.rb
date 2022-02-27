# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1840
      module Step
        class ReassignTrains < Engine::Step::Base
          ACTIONS = %w[reassign_trains].freeze

          def actions(entity)
            return [] unless entity == current_entity

            minor_corps = @game.corporate_card_minors(entity)
            if minor_corps.size.zero? ||
              (minor_corps.size == 1 && !minor_corps.first.trains.empty? && entity.trains.empty?)
              return []
            end

            ACTIONS
          end

          def description
            'Reassign Trains'
          end

          def auto_actions(entity)
            minor_corps = @game.corporate_card_minors(entity)
            train_count = minor_corps.sum { |item| item.trains.size } + entity.trains.size
            return if minor_corps.size != 1 || train_count != 1

            [
              Engine::Action::ReassignTrains.new(
                entity,
                assignments: [{
                  train: entity.trains.first,
                  corporation: @game.corporate_card_minors(entity).first,
                }]
              ),
            ]
          end

          def help_text
            'Select a line for each tram'
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

            if !entity.trains.empty? && @game.tram_owned_by_corporation[entity].any? { |item| item.trains.empty? }
              raise GameError,
                    'All tram lines need to have one train'
            end
            @log << if reassignments.empty?
                      "#{entity.owner.name} does not reassign any trains"
                    else
                      "#{entity.owner.name} reassignes trains: #{reassignments.join(', ')}"
                    end
            pass!
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
