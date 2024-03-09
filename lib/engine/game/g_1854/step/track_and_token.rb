# frozen_string_literal: true

require_relative '../../../step/track_and_token'

module Engine
  module Game
    module G1854
      module Step
        class TrackAndToken < Engine::Step::TrackAndToken
          def actions(entity)
            return [] unless entity == pending_entity

            actions = []
            actions << 'assign' unless @selected_hex
            actions << 'lay_tile' if can_lay_tile?(entity)
            actions << 'place_token' if can_place_token?(entity)
            actions
          end

          def round_state
            super.merge(
              {
                pending_tokens: [],
              }
            )
          end

          def setup
            super
            @selected_hex = nil
          end

          def pass_description
            'TESTING'
          end

          def active?
            pending_entity
          end

          def current_entity
            pending_entity
          end

          def pending_entity
            pending_token[:entity]
          end

          def token
            pending_token[:token]
          end

          def pending_token
            @round.pending_tokens&.first || {}
          end

          def available_hex(_entity, hex)
            pending_token[:hexes].include?(hex)
          end

          def available_tokens(_entity)
            [token]
          end

          def can_lay_tile?(_entity)
            !@laid_tile
          end

          def can_place_token?(_entity)
            !@tokened
          end

          def process_place_token(action)
            # the action is faked and doesn't represent the actual token laid
            hex = action.city.hex
            raise GameError, "Cannot place token on #{hex.name} as the hex is not available" unless available_hex(action.entity,
                                                                                                                  hex)

            place_token(
              token.corporation,
              action.city,
              token,
              connected: false,
              extra_action: true,
            )
            @round.pending_tokens.shift
            @tokened = true
            pass!
          end

          def potential_tiles(_entity, _hex)
            @game.tiles.select { |t| @game.lokal_tile_names.include?(t.name) }.uniq(&:name)
          end

          def hex_neighbors(_entity, hex)
            @game.hex_by_id(hex.id).neighbors.keys
          end

          def process_assign(action)
            company = action.entity
            target = action.target

            case target
            when Hex
              @log << "#{company.name} selects #{target.name}"
              @selected_hex = target
              pending_token[:hexes] = [@selected_hex]
            else
              raise GameError, "Invalid target #{target} for company #{company.name}"
            end
          end
        end
      end
    end
  end
end
