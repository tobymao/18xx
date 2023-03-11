# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1850
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            actions = super.dup
            actions += %w[choose pass] if can_place_edge_token?(entity)

            actions.uniq
          end

          def choice_name
            'Additional Token Actions'
          end

          def choices
            choices = []
            choices << ['Place Edge Token'] if can_place_edge_token?(current_entity)
            choices
          end

          def process_choose(action)
            place_edge_token(action.entity) if action.choice == 'Place Edge Token'
            pass!
          end

          def place_edge_token(corporation)
            ability = @game.abilities(corporation, :assign_hexes)
            hex = @game.hex_by_id(ability.hexes.first)

            hex.tile.icons.reject! { |icon| icon.name == "#{corporation.name}_edge" }
            hex.assign!(corporation)
            ability.use!
            corporation.spend(ability.cost, @game.bank)
            @log << "#{corporation.name} places an edge token on #{hex.name} for #{@game.format_currency(ability.cost)}"
          end

          def skip!
            pass!
          end

          def can_place_edge_token?(entity)
            (ability = @game.abilities(entity, :assign_hexes)) &&
            entity.cash >= ability.cost &&
            available_hex(entity, @game.hex_by_id(ability.hexes.first))
          end
        end
      end
    end
  end
end
