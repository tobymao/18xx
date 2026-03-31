# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G1880Romania
      module Step
        class SpecialChoose < Engine::Step::SpecialChoose
          def actions(entity)
            return [] unless entity.company?
            return [] unless entity == @game.p6
            return [] unless @game.abilities(entity, :choose_ability)
            return [] if choices_ability(entity).empty?

            ACTIONS
          end

          def description
            'Exchange P6 for Building Permit'
          end

          def choices_ability(entity)
            return {} unless entity == @game.p6

            owner = @game.p6.owner
            corps = @game.corporations.select { |c| c.owner == owner && c.floated? }
            choices = {}
            corps.each do |corp|
              %w[AB BC CD].each do |permit|
                choices["#{corp.id}|#{permit}"] = "#{corp.full_name} (#{corp.id}): #{permit} building permit"
              end
            end
            choices
          end

          def process_choose_ability(action)
            entity = action.entity
            raise GameError, "#{entity.name} is not P6" unless entity == @game.p6

            corp_sym, permit = action.choice.split('|')
            corporation = @game.corporation_by_id(corp_sym)

            raise GameError, "Invalid corporation: #{corp_sym}" unless corporation
            raise GameError, "Invalid permit: #{permit}" unless %w[AB BC CD].include?(permit)

            new_permits = if corporation.building_permits
                            (corporation.building_permits.chars | permit.chars).sort.join
                          else
                            permit
                          end

            @game.log << "#{entity.owner.name} exchanges #{entity.name} for #{permit} building permit" \
                         " assigned to #{corporation.full_name} (#{new_permits})"
            corporation.building_permits = new_permits
            @game.abilities(entity, :choose_ability)&.use!
            entity.close!
          end
        end
      end
    end
  end
end
