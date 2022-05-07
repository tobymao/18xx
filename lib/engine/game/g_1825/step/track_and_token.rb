# frozen_string_literal: true

require_relative 'lease_train'
require_relative '../../../step/track_and_token'

module Engine
  module Game
    module G1825
      module Step
        class TrackAndToken < Engine::Step::TrackAndToken
          include LeaseTrain

          def actions(entity)
            return [] if @game.silent_receivership?(entity)
            return [] if entity != current_entity

            actions = []
            if can_lay_tile?(entity)
              actions << 'lay_tile'
              actions << 'special_buy' if entity.receivership? && !@round.leased_train && !@game.leaseable_trains.empty?
            end
            actions << 'place_token' if can_place_token?(entity)
            actions << 'pass' unless actions.empty?
            actions
          end

          def description
            return 'Lay Home Track' if @game.minor_deferred_token?(current_entity)

            'Place a Token or Lay Track'
          end

          def setup
            @round.receivership_loan = 0
            super
          end

          def round_state
            super.merge(
              {
                receivership_loan: 0,
              }
            )
          end

          # handle updating tile reservation if there is now only one tokenable city on tile
          def update_tile_reservation(tile)
            return unless tile.reservations.one?
            return if tile.cities.empty?

            corp = tile.reservations[0]
            return unless tile.cities.count { |c| c.tokenable?(corp) } == 1

            city = tile.cities.find { |c| c.tokenable?(corp) }
            return unless (slot = city.get_slot(corp))

            city.add_reservation!(corp, slot)
            tile.reservations.delete(corp)
          end

          def track_upgrade?(from, _to, _hex)
            from.color != :white && !(from.color == :yellow && from.preprinted)
          end

          def protect_ns?(tile, hex, entity)
            (tile.name == '888' || tile.name == '887') &&
              (hex.id == 'Q13') && (entity.name != 'NS')
          end

          # 1825: pre-printed yellows are not "upgraded"
          def lay_tile_action(action, entity: nil, spender: nil)
            tile = action.tile
            entity ||= action.entity
            old_tile = action.hex.tile
            tile_lay = get_tile_lay(action.entity)
            upgrade = track_upgrade?(old_tile, tile, action.hex)
            raise GameError, 'Cannot upgrade now' if upgrade && !(tile_lay && tile_lay[:upgrade])
            raise GameError, 'Cannot lay a tile now' if !upgrade && !(tile_lay && tile_lay[:lay])
            if tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(action.hex)
              raise GameError, "#{action.hex.id} cannot be layed as this hex was already layed on this turn"
            end

            raise GameError, 'Only the NS can place tiles 887/888 on Q13' if protect_ns?(tile, action.hex, entity)

            check_adjacent(old_tile.hex) if @round.num_laid_track.positive?

            extra_cost = tile.color == :yellow ? tile_lay[:cost] : tile_lay[:upgrade_cost]

            lay_tile(action, extra_cost: extra_cost, entity: entity, spender: spender)
            @round.upgraded_track = true if upgrade
            @round.num_laid_track += 1
            @round.laid_hexes << action.hex

            update_tile_reservation(tile)

            # handle deferred tile lay
            @game.place_home_token(entity) if @game.minor_deferred_token?(entity) && @game.can_place_home_token?(entity)

            return unless (abilities = @game.abilities(entity, :blocks_hexes))

            # if this corp laid a hex on its reserved hex, remove the ability
            abilities = Array(abilities)
            abilities.each do |ability|
              entity.abilities.delete(ability) if @game.hex_blocked_by_ability?(entity, ability, action.hex)
            end
          end

          def pay_tile_cost!(entity, tile, rotation, hex, spender, cost, _extra_cost)
            return super unless entity.receivership?

            if spender.cash >= cost
              spender.spend(cost, @game.bank) if cost.positive?
            else
              diff = cost - spender.cash
              spender.spend(spender.cash, @game.bank) if spender.cash.positive?
              @round.receivership_loan += diff
            end

            @log << "#{spender.name}"\
                    "#{spender == entity || !entity.company? ? '' : " (#{entity.sym})"}"\
                    "#{cost.zero? ? '' : " spends #{@game.format_currency(cost)} and"}"\
                    " lays tile ##{tile.name}"\
                    " with rotation #{rotation} on #{hex.name}"\
                    "#{tile.location_name.to_s.empty? ? '' : " (#{tile.location_name})"}"
          end

          def buying_power(entity, **)
            entity.cash + (entity.receivership? ? 200 : 0)
          end

          def place_token(entity, city, token, connected: true, extra_action: false,
                          special_ability: nil, check_tokenable: true, spender: nil)

            return super unless entity.receivership?

            hex = city.hex
            check_connected(entity, city, hex) if connected

            raise GameError, 'Token already placed this turn' if !extra_action && @round.tokened

            tokener = entity.name
            raise GameError, 'Token is already used' if token.used

            city.place_token(entity, token, free: true, check_tokenable: check_tokenable,
                                            cheater: false, extra_slot: false, spender: spender)

            spender ||= entity
            if spender.cash >= token.price
              pay_token_cost(spender, token.price) if token.price.positive?
            else
              diff = token.price - spender.cash
              pay_token_cost(spender, spender.cash) if spender.cash.positive?
              @round.receivership_loan += diff
            end

            @log << "#{tokener} places a token on #{hex.name} (#{hex.location_name}) for #{@game.format_currency(token.price)}"

            @round.tokened = true unless extra_action
            @game.graph.clear
          end

          def check_adjacent(new_hex)
            coordinates = @round.laid_hexes.to_h { |h| [[h.x, h.y], h] }
            Engine::Hex::DIRECTIONS[new_hex.layout].each do |xy, _direction|
              x, y = xy
              raise GameError, 'Cannot lay tiles in adjacent hexes' if coordinates[[new_hex.x + x, new_hex.y + y]]
            end
          end

          def end_subset?(this, other)
            return true if (this.city? || this.town?) && (other.city? || other.town?)

            this <= other
          end

          # this is basically the path '<=' method except towns and cities match
          # both this and other are paths
          def path_subset?(this, other)
            other_ends = other.ends
            this.ends.all? do |t|
              other_ends.any? do |o|
                end_subset?(t, o)
              end
            end && (this.ignore_gauge_compare || this.tracks_match?(other))
          end

          def legal_tile_rotation?(entity, hex, tile)
            return super unless @game.force_upgrade?(hex.tile, tile)

            # basically a simplified version of the super except with a modified path check to allow dits to upgrade to cities
            return false unless @game.legal_tile_rotation?(entity, hex, tile)

            old_paths = hex.tile.paths
            old_ctedges = hex.tile.city_town_edges

            new_paths = tile.paths
            new_exits = tile.exits
            new_ctedges = tile.city_town_edges
            multi_city_upgrade = new_ctedges.size > 1 && old_ctedges.size > 1

            new_exits.all? { |edge| hex.neighbors[edge] } &&
              !(new_exits & hex_neighbors(entity, hex)).empty? &&
              # substituted path check:
              old_paths.all? { |path| new_paths.any? { |p| path_subset?(p, path) } } &&
              (!multi_city_upgrade || old_ctedges.all? { |oldct| new_ctedges.one? { |newct| (oldct & newct) == oldct } })
          end

          def reachable_node?(entity, node, max_node_distance, max_city_distance)
            if max_node_distance.positive?
              node_distances = @game.node_distance_graph.node_distances(entity)
              return false unless node_distances[node]
              return true if node_distances[node][:node] < max_node_distance
            end

            if max_city_distance.positive?
              city_distances = @game.city_distance_graph.node_distances(entity)
              return false unless city_distances[node]
              return true if city_distances[node][:city] < max_city_distance
            end

            false
          end

          # 1825 rule: any upgraded station must be reachable with a train
          def check_track_restrictions!(entity, old_tile, new_tile)
            return if @game.loading || !entity.operator?

            # allow a placement on home hex if minor home token hasn't been laid
            # This should only apply to three of the minors (Cambrian, Taff Vale, North Staffordshire)
            return if @game.minor_deferred_token?(entity) && new_tile.hex.id == entity.coordinates

            super

            return if old_tile.preprinted || new_tile.nodes.empty?

            raise GameError, 'Cannot upgrade a city/town without a train' if entity.trains.empty? && !@round.leased_train

            # a 4+4E train can reach any tile on the network
            return if (max_node_distance = @game.biggest_node_distance(entity, @round.leased_train)) == 99

            max_city_distance = @game.biggest_city_distance(entity, @round.leased_train)

            @game.node_distance_graph.clear
            @game.city_distance_graph.clear
            return if new_tile.nodes.any? { |node| reachable_node?(entity, node, max_node_distance, max_city_distance) }

            raise GameError, 'Unable to reach a city/town on upgraded tile with any train'
          end

          def tokenable_hex?(entity, hex)
            return false if @round.tokened || (tokens = available_tokens(entity)).empty?
            return false unless min_token_price(tokens) <= buying_power(entity)
            return false if hex.tile.cities.empty?

            @game.graph.reachable_hexes(entity)[hex]
          end

          def available_hex(entity, hex)
            return true if @game.minor_deferred_token?(entity) && hex.id == entity.coordinates
            return true if can_lay_tile?(entity) && super

            tokenable_hex?(entity, hex)
          end

          def tracker_available_hex(entity, hex)
            connected = hex_neighbors(entity, hex)
            return nil unless connected

            tile_lay = get_tile_lay(entity)
            return nil unless tile_lay

            preprinted = hex.tile.preprinted
            return nil if preprinted && !tile_lay[:lay]
            return nil if !preprinted && !tile_lay[:upgrade]
            return nil if !preprinted && tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(hex)

            connected
          end

          def hex_neighbors(entity, hex)
            return super if !@game.minor_deferred_token?(entity) || hex.id != entity.coordinates

            neighbors = {}
            hex.neighbors.each { |e, _| neighbors[e] = true }
            neighbors.keys
          end
        end
      end
    end
  end
end
