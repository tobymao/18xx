# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1822
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            actions = super.dup
            if (!choices_ability(entity).empty? || (actions.empty? && ability_chpr_lcdr?(entity))) &&
              !actions.include?('choose_ability')
              actions << 'choose_ability'
            end
            actions << 'pass' if !actions.empty? && !actions.include?('pass')
            actions
          end

          def choices_ability(entity)
            return {} unless entity.company?

            @game.company_choices(entity, :token)
          end

          def available_tokens(entity)
            entity.tokens_by_type.reject { |t| t.type == :destination }
          end

          def ability_chpr_lcdr?(entity)
            return unless entity.corporation?

            # Special case if corporation has no tokens available, but does have
            # CHPR or LCDR and an exchange token
            entity.companies.any? { |c| c.id == @game.class::COMPANY_CHPR || c.id == @game.class::COMPANY_LCDR } &&
              @game.exchange_tokens(entity).positive?
          end

          def can_place_token?(entity)
            return true if @game.abilities(entity, :token) && !@round.tokened && !available_tokens(entity).empty?

            super
          end

          def process_choose_ability(action)
            @game.company_made_choice(action.entity, action.choice, :token)
          end

          def process_place_token(action)
            entity = action.entity
            city = action.city

            if entity.corporation? && entity.type == :major && city.tokened_by?(entity)
              hex = city.hex
              city_string = city.hex.tile.cities.size > 1 ? " city #{city.index}" : ''
              raise GameError, "Can't place token on #{hex.name}#{city_string} because #{entity.id} cant have 2 "\
                               'tokens in the same city'
            end

            check_tokenable = city.hex.name != @game.class::LONDON_HEX
            place_token(entity, action.city, action.token, check_tokenable: check_tokenable)
            pass!
          end
        end
      end
    end
  end
end
