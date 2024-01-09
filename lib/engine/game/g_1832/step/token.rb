# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1832
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            actions = super
            actions += %w[choose pass] if can_place_miami_token?(entity)

            actions.uniq
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
            ability = @game.abilities(corporation, :assign_hexes)
            hex = @game.hex_by_id(ability.hexes.first)

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
            (abilities = @game.abilities(entity, :assign_hexes)) &&
            abilities.any? { |ability| ability.cost == 100 } &&
            entity.cash >= 100 &&
            (3..6).cover?(@game.phase.name.to_i)
          end
        end
      end
    end
  end
end
