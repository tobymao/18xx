# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1832
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return super unless miami_token_ability(entity)

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
            ability = miami_token_ability(corporation)
            return unless ability
            return unless corporation.cash >= ability.cost

            miami_hex_id = @game.class::MIAMI_HEX
            hex = @game.hex_by_id(miami_hex_id)
            hex.tile.icons.reject! { |icon| icon.name == 'FECR_key_west' }
            hex.assign!(corporation)

            ability.use!
            corporation.spend(ability.cost, @game.bank)
            @log << "#{corporation.name} places the Key West token on #{hex.name} for #{@game.format_currency(ability.cost)}"
          end

          def miami_token_ability(entity)
            return nil if @game.miami_token_placed?
            return nil unless entity.corporation?
            return nil unless @game.phase.status.include?('can_place_miami_token')

            miami_hex_id = @game.class::MIAMI_HEX
            entity.all_abilities.find { |a| a.type == :assign_hexes && a.hexes == [miami_hex_id] }
          end
        end
      end
    end
  end
end
