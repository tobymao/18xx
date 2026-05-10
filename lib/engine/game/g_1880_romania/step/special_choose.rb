# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G1880Romania
      module Step
        class SpecialChoose < Engine::Step::SpecialChoose
          def actions(entity)
            return [] if entity != @game.banater && entity != @game.malaxa
            return [] unless @game.abilities(entity, :choose_ability)
            return [] if choices_ability(entity).empty?

            ACTIONS
          end

          def description
            'Use Private Company Ability'
          end

          def choices_ability(entity)
            return banater_choices(entity) if entity == @game.banater
            return malaxa_choices(entity) if entity == @game.malaxa

            {}
          end

          def process_choose_ability(action)
            return process_banater(action) if action.entity == @game.banater
            return process_malaxa(action) if action.entity == @game.malaxa

            raise GameError, "Unknown entity: #{action.entity.name}"
          end

          private

          def banater_choices(entity)
            owner = entity.owner
            choices = { 'player' => "#{@game.format_currency(20)} to #{owner.name}" }
            @game.corporations.select { |c| c.owner == owner && c.floated? }.each do |corp|
              choices[corp.id] = "#{@game.format_currency(40)} to #{corp.full_name} (#{corp.id})"
            end
            choices
          end

          def process_banater(action)
            entity = action.entity
            owner = entity.owner

            if action.choice == 'player'
              @game.bank.spend(20, owner)
              @game.log << "#{owner.name} receives #{@game.format_currency(20)} from closing #{entity.name}"
            else
              corp = @game.corporation_by_id(action.choice)
              raise GameError, "Invalid corporation: #{action.choice}" unless corp

              @game.bank.spend(40, corp)
              @game.log << "#{corp.full_name} receives #{@game.format_currency(40)} from closing #{entity.name}"
            end

            @game.abilities(entity, :choose_ability)&.use!
            entity.close!
          end

          def malaxa_choices(entity)
            owner = entity.owner
            corps = @game.corporations.select { |c| c.owner == owner && c.floated? }
            choices = {}
            corps.each do |corp|
              %w[AB BC CD].each do |permit|
                choices["#{corp.id}|#{permit}"] = "#{corp.full_name} (#{corp.id}): #{permit} building permit"
              end
            end
            choices
          end

          def process_malaxa(action)
            entity = action.entity
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
