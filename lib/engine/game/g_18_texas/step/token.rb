# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18Texas
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return super unless can_lay_special_token?(entity)

            %w[pass]
          end

          def process_place_token(action)
            super

            check_remove_token_ability!(action)
          end

          def check_remove_token_ability!(action)
            hex_id = action.city.hex.id
            return unless (reserved_corp_id = @game.class::RESERVED_TOKEN_CORP_BY_HEX[hex_id])
            return if action.entity.id == reserved_corp_id
            return unless (company = @game.company_by_id(@game.class::TELEPORT_COMPANY_BY_HEX[hex_id]))
            return unless (ability = company.all_abilities.find { |a| a.type == :token })

            company.remove_ability(ability)
            @log << "#{company.name} loses its token ability, as all unreserved slots in #{action.hex.name} are filled"
          end

          private

          def can_lay_special_token?(entity)
            return false unless entity.corporation?

            entity.owner.companies.any? do |company|
              @game.abilities(company, :token)&.hexes&.any? do |hex_id|
                hex = @game.hex_by_id(hex_id)
                hex.tile.cities.none? { |c| c.tokened_by?(entity) }
              end
            end
          end
        end
      end
    end
  end
end
