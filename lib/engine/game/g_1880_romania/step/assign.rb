# frozen_string_literal: true

require_relative '../../g_1880/step/assign'

module Engine
  module Game
    module G1880Romania
      module Step
        class Assign < G1880::Step::Assign
          def actions(entity)
            return super unless entity == @game.danube_port
            return [] if current_entity.minor?
            return [] unless @game.abilities(entity, :assign_hexes)

            ACTIONS
          end

          def p5_block?
            false
          end

          def assignable_corporations(company = nil)
            return super unless company == @game.remar

            owner = @game.remar.owner
            @game.corporations.select { |c| c.owner == owner && c.floated? }
          end

          def process_assign(action)
            company = action.entity
            target = action.target

            return process_assign_remar(action) if company == @game.remar
            return super unless company == @game.danube_port

            ability = @game.abilities(company, :assign_hexes)
            ability.use!

            target.assign!(company.id)
            @log << "#{company.name} builds port on #{target.name}"
          end

          private

          def process_assign_remar(action)
            company = action.entity
            target = action.target

            ability = @game.abilities(company, :assign_corporation)
            target.assign!(company.id)
            ability.use!
            @game.log << "#{company.name} tender assigned to #{target.name}"
          end
        end
      end
    end
  end
end
