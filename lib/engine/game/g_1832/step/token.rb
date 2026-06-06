# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1832
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return super unless can_place_miami_token?(entity)

            super | %w[choose pass]
          end

          def choice_name
            'Additional Token Actions'
          end

          def choices
            choices = {}
            choices['keywest'] = 'Place Key West Token' if can_place_miami_token?(current_entity)

            choices
          end

          def process_choose(action)
            raise GameError, 'Illegal choice' unless action.choice == 'keywest'

            place_miami_token(action.entity)
            pass!
          end

          def place_miami_token(corporation)
            raise GameError, 'Cannot place Miami token' unless can_place_miami_token?(corporation)

            @game.place_miami_token

            ability = miami_token_ability(corporation)
            ability.use!

            corporation.spend(ability.cost, @game.bank)
            @log << "#{corporation.name} places the Key West token on #{hex.name} for #{@game.format_currency(ability.cost)}"
          end

          def miami_token_ability(entity)
            entity.all_abilities.find { |a| a.type == :assign_hexes && a.hexes == [@game.MIAMI_HEX_ID] }
          end

          def can_place_miami_token?(entity)
            return false if @game.miami_token_placed?
            return false unless entity == @game.fecr_corp
            return false unless @game.phase.status.include?('can_place_miami_token')

            ability = miami_token_ability(entity)
            return false unless ability

            return false unless corporation.cash >= ability.cost

            true
          end
        end
      end
    end
  end
end
