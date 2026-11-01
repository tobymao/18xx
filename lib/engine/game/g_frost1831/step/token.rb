# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module GFrost1831
      module Step
        class Token < Engine::Step::Token
          BASE_INFLUENCE_COST = 5

          def actions(entity)
            return %w[choose] if entity&.company? && entity.sym == 'FAV'
            return [] unless entity == current_entity
            return [] if entity.type == :faction

            super
          end

          def description
            return 'Faction Action: Place Base' if current_entity&.type == :faction

            super
          end

          def process_choose(action)
            return unless action.entity&.sym == 'FAV'

            special_choose = @round.steps.find { |s| s.is_a?(GFrost1831::Step::SpecialChoose) }
            special_choose&.process_choose_ability(action)
          end

          def available_hex(entity, hex)
            if entity.type == :faction
              # Factions can only place in connected cities with available slots
              return nil unless @game.available_faction_cities(entity).include?(hex.id)

              return true
            end

            return nil unless super

            # Faction-reserved cities: non-faction corps blocked if only 1 slot + icon
            if entity.type != :faction && faction_reserved?(hex)
              city = hex.tile.cities.first
              return nil unless city
              return nil unless city.available_slots > 1
            end

            true
          end

          def place_token(entity, city, token, **kwargs)
            if entity.type == :faction
              hex = city.hex

              # Validate: faction can't have 2 bases in same hex. Check ALL
              # cities on the hex (multi-city OO/NL tiles), not just this one.
              if hex.tile.cities.any? { |c| c.tokens.any? { |t| t&.corporation == entity } }
                raise GameError, "#{entity.name} already has a base in #{hex.id}"
              end

              # Validate: must be connected to existing base (unless first base)
              existing_bases = entity.tokens.select(&:used).map(&:hex)
              if existing_bases.any? && !@game.connected_to_faction_base?(entity, hex, existing_bases)
                raise GameError, "#{hex.id} is not connected to #{entity.name}'s existing bases"
              end

              cubes = @game.faction_influence(entity.id)
              if cubes < BASE_INFLUENCE_COST
                raise GameError, "#{entity.name} needs #{BASE_INFLUENCE_COST} Influence but has #{cubes}"
              end

              super(entity, city, token, **kwargs.merge(check_tokenable: false))

              BASE_INFLUENCE_COST.times { @game.faction_influence_lose(entity.id) }
              @log << "#{entity.name} spends #{BASE_INFLUENCE_COST} Influence for base"

              @round.faction_acted = true if @round.respond_to?(:faction_acted=)
              return
            end

            super
          end

          def log_skip(entity)
            return if entity.type == :faction

            super
          end

          private

          def faction_reserved?(hex)
            hex.tile.icons.any? { |icon| icon.name == 'faction_base' }
          end
        end
      end
    end
  end
end
