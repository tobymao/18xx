# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/tokener'
require_relative '../../../step/tracker'
require_relative 'nwr_track_bonus'

module Engine
  module Game
    module G1882
      module Step
        class SpecialNWR < Engine::Step::Base
          include Engine::Step::Tokener
          include Engine::Step::Tracker
          include NwrTrackBonus

          REMOVE_TOKEN_ACTIONS = %w[remove_token].freeze
          PLACE_TOKEN_ACTIONS = %w[place_token].freeze
          TRACK_ACTIONS = %w[lay_tile pass].freeze

          def actions(entity)
            return [] unless ability(entity)
            # Disable using NWR private on the dividend screen
            return [] if @round.routes&.any?

            case @state
            when nil
              REMOVE_TOKEN_ACTIONS
            when :place_token
              PLACE_TOKEN_ACTIONS
            when :lay_tile
              TRACK_ACTIONS
            end
          end

          def pass!
            super
            @state = nil
          end

          def can_replace_token?(entity, token)
            return true unless token

            token.corporation == entity.owner
          end

          def description
            case @state
            when :place_token
              'NWR: Place Token'
            when :lay_tile
              'NWR: Lay Track'
            end
          end

          def pass_description
            'NWR: Skip (Track)'
          end

          def active_entities
            [@entity]
          end

          def blocks?
            @state
          end

          def process_remove_token(action)
            @entity = action.entity
            owner = @entity.owner
            token = action.city.tokens[action.slot]
            raise GameError, "Cannot remove #{token.corporation.name} token" unless token.corporation == @entity.owner

            home_token = owner.tokens.first == token
            token.remove!
            if home_token
              @log << "Remove token from #{action.city.hex.name} and replace with neutral token"

              # Add a new neutral/CN token
              cn_corp = @game.corporation_by_id('CN')
              logo = '/logos/1882/neutral.svg'
              token = Engine::Token.new(cn_corp, price: 0, logo: logo, simple_logo: logo, type: :neutral)
              cn_corp.tokens << token

              action.city.reservations.delete(owner)
              token.place(action.city)
              action.city.tokens[action.slot] = token
            else
              @log << "Remove token from #{action.city.hex.name}"
            end

            @state = :place_token
          end

          def process_place_token(action)
            @entity = action.entity

            place_token(
              @entity.owner,
              action.city,
              available_tokens(@entity)[0],
              connected: false,
              extra_action: true,
              special_ability: @game.abilities(@entity, :token),
            )
            @destination = action.city.hex

            # Owner may no longer have a valid route.
            @game.graph.clear_graph_for(@entity.owner)

            @state = :lay_tile
          end

          def process_lay_tile(action)
            owner = action.entity.owner
            lay_tile(action, entity: owner)
            @round.laid_hexes << action.hex

            # Record any track laid after the dividend step
            if owner&.corporation? && (operating_info = owner.operating_history[[@game.turn, @round.round_num]])
              operating_info.laid_hexes = @round.laid_hexes
            end

            gain_nwr_bonus(action.tile, action.entity.owner)
            ability(action.entity).use!
            @state = nil
          end

          # Can't lay neutral tokens, so just provide the next one.
          def available_tokens(entity)
            [entity.owner.next_token]
          end

          def upgradeable_tiles(entity, hex)
            super(entity.owner, hex)
          end

          def available_hex(entity, hex)
            case @state
            when nil
              # Token cannot be in NWR
              return false if tile_nwr?(hex.tile)

              token = entity.owner.tokens.find { |t| t.used && t.city.hex == hex }

              if token == entity.owner.tokens.first
                # Home token cannot contain a neutral token
                cn_corp = @game.corporation_by_id('CN')
                hex.tile.cities.none? { |city| city.tokened_by?(cn_corp) }
              elsif token
                true
              end

            when :place_token
              ability(entity).hexes.include?(hex.id) &&
              hex.tile.cities.any? { |c| c.tokenable?(entity.owner, free: true) }
            when :lay_tile
              @game.hex_by_id(hex.id).neighbors.keys if hex == @destination
            end
          end

          def ability(entity)
            return unless entity.company?

            case @state
            when nil, :place_token
              @game.abilities(entity, :token)
            when :lay_tile
              @game.abilities(entity, :tile_lay)
            end
          end
        end
      end
    end
  end
end
