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
            return unless can_place_miami_token?(corporation)

            hex = @game.hex_by_id(MIAMI_HEX)
            abilities = Array(@game.abilities(corporation, :assign_hexes))
            ability = abilities.find { |a| a.hexes.includes?(MIAMI_HEX) }

            hex.tile.icons.reject! { |icon| icon.name == 'FECR_key_west' }
            hex.assign!(corporation)
            ability.use!
            corporation.spend(ability.cost, @game.bank)
            @log << "#{corporation.name} places the Key West token on #{hex.name} for #{@game.format_currency(ability.cost)}"
          end

          def skip!
            pass!
          end

          def can_place_miami_token?(entity)
            return false if entity.cash < 100
            return false unless (3..6).cover?(@game.phase.name.to_i)

            abilities = Array(@game.abilities(entity, :assign_hexes))
            abilities.any? { |ability| ability.hexes.includes?(MIAMI_HEX) }
          end
        end
      end
    end
  end
end
