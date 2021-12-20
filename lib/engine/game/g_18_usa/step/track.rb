# frozen_string_literal: true

require_relative 'tracker'
require_relative '../../../step/track'
require_relative '../../../step/upgrade_track_max_exits'
require_relative '../../../game_error'

module Engine
  module Game
    module G18USA
      module Step
        class Track < Engine::Step::Track
          include Tracker

          def actions(entity)
            actions = super
            return actions unless entity.corporation?

            actions << 'choose' if choice_available?(entity)
            actions << 'pass' if actions.size == 1
            actions
          end

          def can_lay_tile?(entity)
            super || can_place_token_with_p20?(entity) || can_assign_p6?(entity)
          end

          def can_place_token_with_p20?(entity)
            entity.companies.include?(@game.company_by_id('P20')) &&
            !entity.tokens.all?(&:used) &&
            @game.graph.connected_nodes(entity).keys.any? do |node|
              node.city? && node.available_slots.zero? && !node.tokened_by?(entity)
            end
          end

          def can_assign_p6?(entity)
            entity.companies.include?(@game.company_by_id('P6')) &&
            @game.graph.connected_hexes(entity).keys.any? { |hex| hex.tile.color == :red }
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            tile = action.tile

            check_company_town(tile, action.hex) if tile.name.include?('CTown')

            super

            @game.company_by_id('P16').close! if tile.name.include?('RHQ')
            process_company_town(tile) if tile.name.include?('CTown')
            if @game.metro_denver && @game.hex_by_id('E11').tile.color == :white &&
                action.hex.neighbors.any? { |exit, hex| action.hex.tile.exits.include?(exit) && hex.name == 'E11' }
              @round.pending_tracks << { entity: action.entity, hexes: [@game.hex_by_id('E11')] }
            end
            @game.jump_graph.clear
          end

          def check_company_town(_tile, hex)
            raise GameError, 'Cannot use Company Town in a tokened hex' if hex.tile.cities&.first&.tokens&.first
            return if (hex.neighbors.values & @game.active_metropolitan_hexes).empty?

            raise GameError, 'Cannot use Company Town next to a metropolis'
          end

          def process_company_town(tile)
            corporation = @game.company_by_id('P27').owner
            if corporation.tokens.size < 8
              @game.log << "#{corporation.name} gets a free token to place on the Company Town"
              bonus_token = Engine::Token.new(corporation)
              corporation.tokens << bonus_token
              tile.cities.first.place_token(corporation, bonus_token, free: true, check_tokenable: false, extra_slot: true)
            else
              @game.log << "#{corporation.name} forfeits the Company Town token as they are at token limit of 8"
            end
            @game.graph.clear
            @game.company_by_id('P27').close!
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            old_tile.name.include?('iron') && new_tile.name.include?('iron') ? true : super
          end

          def available_hex(entity, hex)
            custom_tracker_available_hex(entity, hex)
          end
        end
      end
    end
  end
end
