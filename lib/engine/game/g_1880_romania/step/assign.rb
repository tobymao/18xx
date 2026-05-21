# frozen_string_literal: true

require_relative '../../g_1880/step/assign'

module Engine
  module Game
    module G1880Romania
      module Step
        class Assign < G1880::Step::Assign
          def p5_block?
            false
          end

          def assignable_corporations(company = nil)
            return super unless company == @game.remar

            owner = @game.remar.owner
            @game.corporations.select { |c| c.owner == owner && c.floated? }
          end

          def process_assign(action)
            return process_assign_remar(action) if action.entity == @game.remar

            super
          end

          private

          def process_assign_remar(action)
            company = action.entity
            target = action.target

            ability = @game.abilities(company, :assign_corporation)
            ability.use!
            target.add_ability(Engine::Ability::Base.new(type: :tender, description: 'REMAR tender'))
            @game.log << "#{company.name} tender assigned to #{target.name}"
          end
        end
      end
    end
  end
end
