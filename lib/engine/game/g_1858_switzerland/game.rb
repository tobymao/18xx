# frozen_string_literal: true

require_relative 'entities'
require_relative 'graph'
require_relative 'map'
require_relative 'meta'
require_relative 'tiles'
require_relative '../g_1858/game'

module Engine
  module Game
    module G1858Switzerland
      class Game < G1858::Game
        include_meta(G1858Switzerland::Meta)
        include Entities
        include Map
        include Tiles

        attr_reader :robot

        GRAPH_CLASS = G1858Switzerland::Graph
        CURRENCY_FORMAT_STR = '%ssfr'

        BANK_CASH = 8_000
        STARTING_CASH = { 2 => 500, 3 => 335, 4 => 250 }.freeze
        CERT_LIMIT = { 2 => 20, 3 => 13, 4 => 10 }.freeze

        PHASES = G1858::Trains::PHASES.reject { |phase| phase[:name] == '7' }
        STATUS_TEXT = G1858::Trains::STATUS_TEXT.merge(
          'green_privates' => [
            'Yellow and green privates available',
            'The first and second batches of private companies can be auctioned',
          ],
          'all_privates' => [
            'All privates available',
            'The first, second and third batches of private companies can be auctioned',
          ],
          'blue_privates' => [
            'Blue privates available',
            'The third batch of private companies can be auctioned',
          ],
        ).freeze
        EVENTS_TEXT = G1858::Trains::EVENTS_TEXT.merge(
          'sbb_starts' => [
            'SBB starts',
            'The SBB starts operating',
          ],
          'blue_privates_available' => [
            'Blue privates can start',
            'The third set of private companies becomes available',
          ],
          'privates_close' => [
            'Yellow/green private companies close',
            'The first private closure round takes place at the end of the ' \
            'operating round in which the first 5E/4M train is bought',
          ],
          'privates_close2' => [
            'Blue private companies close',
            'The second private closure round takes place at the end of the ' \
            'operating round in which the first 6E/5M train is bought',
          ],
        ).freeze

        ROBOT_MINOR_TILE_LAYS = [{ lay: true, upgrade: false }].freeze
        ROBOT_MAJOR_TILE_LAYS = [{ lay: true, upgrade: true }].freeze

        def game_phases
          unless @game_phases
            @game_phases = super.map(&:dup)
            _phase2, _phase3, phase4, phase5, phase6 = @game_phases
            phase4[:status] = %w[all_privates narrow_gauge]
            phase5[:status] = %w[blue_privates public_companies dual_gauge]
            phase6[:tiles] = %i[yellow green brown gray]
          end
          @game_phases
        end

        def timeline
          @timeline = ['5D trains are available after the first 6E/5M train has been bought.',
                       '4H/2M trains rust when the second 6E/5M/5D train is bought.',
                       '6H/3M trains are wounded when the second 6E/5M/5D train is bought.',
                       '6H/3M trains rust when the fourth 6E/5M/5D train is bought.']
        end

        def event_sbb_starts!
          @log << '-- The SBB starts operating --'
          sbb.owner = @robot
          sbb.floatable = true
          sbb.floated = true
          @round.entities << sbb
        end

        def event_blue_privates_available!
          @log << '-- Event: Blue private companies can be started --'
          # Don't need to change anything, the check in buyable_bank_owned_companies
          # will let these companies be auctioned in future stock rounds.
        end

        def event_privates_close!
          @log << '-- Event: Yellow and green private companies will close ' \
                  'at the end of this operating round --'
          @private_closure_round = :next
        end

        def event_privates_close2!
          @log << '-- Event: Blue private companies will close at the end ' \
                  'of this operating round --'
          @private_closure_round = :next
        end

        TRAINS = G1858::Trains::TRAINS.reject { |train| train[:name] == '7E' }
        TRAIN_COUNTS = {
          '2H' => 4,
          '4H' => 3,
          '6H' => 3,
          '5E' => 2,
          '6E' => 10,
          '5D' => 5,
        }.freeze
        GREY_TRAINS = %w[6E 5M 5D].freeze

        def game_trains
          unless @game_trains
            # Need to make a deep copy of 1858's train definitions.
            # https://github.com/tobymao/18xx/issues/11372 was caused by
            # modifying the definitions without a deep copy. If a game of 1858
            # is loaded on the server after a game of 1858 Switzerland then it
            # is was seeing the version of the definitions after these
            # modifications, causing errors as 1858 does not have a method for
            # handling the `blue_privates_available` event.
            @game_trains = super.map(&:dup)
            train_2h, _train_4h, train_6h, _train_5e, train_6e, train_5d = @game_trains
            train_2h[:events] = [{ 'type' => 'sbb_starts' }] if robot?
            train_6h.delete(:obsolete_on) # Wounded on second grey train, handled in code
            train_6h[:events] = [{ 'type' => 'blue_privates_available' }]
            train_6e[:events] = [{ 'type' => 'privates_close2' }]
            train_6e[:price] = 700
            train_6e[:variants][0][:price] = 600
            train_5d[:available_on] = '6'
          end
          @game_trains
        end

        def num_trains(train)
          TRAIN_COUNTS[train[:name]]
        end

        PHASE4_TRAINS_OBSOLETE = 2 # 6H/3M trains wounded after second grey train is bought.
        PHASE3_TRAINS_RUST = 2 # 4H/2M trains rust after second grey train is bought.
        PHASE4_TRAINS_RUST = 4 # 6H/3M trains rust after fourth grey train is bought.

        def setup
          super
          @phase4_train_trigger = PHASE4_TRAINS_RUST
        end

        def init_starting_cash(players, bank)
          return super unless robot?

          # This method is called before the robot player is added to `players`.
          # The robot does not receive any cash, but the amount received by the
          # human players is reduced to the starting cash for a three-player
          # game.
          cash = self.class::STARTING_CASH[players.size + 1]
          players.each do |player|
            bank.spend(cash, player)
          end
        end

        def game_cert_limit
          return super unless robot?

          # This method is called before the robot player is added to `players`.
          # The certificate limit is reduced to account for the extra player.
          self.class::CERT_LIMIT.transform_keys { |player_count| player_count - 1 }
        end

        def game_corporations
          excluded = robot? ? 'RhB' : 'SBB'
          super.reject { |corp| corp[:sym] == excluded }
        end

        def maybe_rust_wounded_trains!(grey_trains_bought, purchased_train)
          obsolete_trains!(%w[6H 3M], purchased_train) if grey_trains_bought == PHASE4_TRAINS_OBSOLETE
          rust_wounded_trains!(%w[4H 2M], purchased_train) if grey_trains_bought == PHASE3_TRAINS_RUST
          rust_wounded_trains!(%w[6H 3M], purchased_train) if grey_trains_bought == PHASE4_TRAINS_RUST
        end

        def obsolete_trains!(train_names, purchased_train)
          trains.select { |train| train_names.include?(train.name) }
                .each { |train| train.obsolete_on = purchased_train.sym }
          rust_trains!(purchased_train, purchased_train.owner)
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G1858::Step::Exchange,
            G1858::Step::ExchangeApproval,
            G1858::Step::HomeToken,
            G1858Switzerland::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num = 1)
          @round_num = round_num
          Engine::Round::Operating.new(self, [
            G1858Switzerland::Step::Track,
            G1858Switzerland::Step::Token,
            G1858Switzerland::Step::Route,
            G1858Switzerland::Step::Dividend,
            G1858Switzerland::Step::DiscardTrain,
            G1858Switzerland::Step::BuyTrain,
            G1858Switzerland::Step::IssueShares,
          ], round_num: round_num)
        end

        def closure_round(round_num)
          G1858Switzerland::Round::Closure.new(self, [
            G1858::Step::ExchangeApproval,
            G1858::Step::HomeToken,
            G1858::Step::PrivateClosure,
          ], round_num: round_num)
        end

        def reorder_players(order = nil, log_player_order: false, silent: false)
          super
          return unless robot?

          # The robot player is always last in priority order.
          @players.delete(@robot)
          @players << @robot
        end

        def operating_order
          return super unless robot?

          super.sort_by { |entity| entity == sbb ? 1 : 0 }
        end

        def companies_to_payout(ignore: [])
          @companies.select do |company|
            company.owner &&
              company.owner != @robot &&
              !ignore.include?(company.id)
          end
        end

        BONUS_HEXES = {
          north: %w[C4 D3 E2 H1 I2],
          south: %w[H15 I16],
          east: %w[L5 L7],
          west: %w[A14 B7],
          revenue_ns: 'B16',
          revenue_ew: 'L16',
        }.freeze

        def revenue_for(route, stops)
          super + north_south_bonus(route, stops) + east_west_bonus(route, stops)
        end

        def private_colors_available(phase)
          if phase.status.include?('yellow_privates')
            %i[yellow]
          elsif phase.status.include?('green_privates')
            %i[yellow green]
          elsif phase.status.include?('all_privates')
            %i[yellow green lightblue]
          elsif phase.status.include?('blue_privates')
            %i[lightblue]
          else
            []
          end
        end

        MOUNTAIN_RAILWAY_TILE = 'X28'
        MOUNTAIN_RAILWAY_ASSIGNMENT = '+40'
        MOUNTAIN_RAILWAY_BONUS = 40
        ASSIGNMENT_TOKENS = {
          MOUNTAIN_RAILWAY_ASSIGNMENT => '/icons/1858_switzerland/mountain.svg',
        }.freeze

        def submit_revenue_str(routes, _show_subsidy)
          mountain_revenue = mountain_bonus(current_entity, routes)
          return super if mountain_revenue.zero?

          train_revenue = routes_revenue(routes)
          "#{format_revenue_currency(train_revenue)} + " \
            "#{format_revenue_currency(mountain_revenue)} mountain railway bonus"
        end

        def extra_revenue(entity, routes)
          mountain_bonus(entity, routes)
        end

        def mountain_bonus(entity, routes)
          return 0 if routes.empty?

          mountain_railway_built?(entity) ? MOUNTAIN_RAILWAY_BONUS : 0
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          return super unless mountain_hex?(tile)

          super + Array(@tiles.find { |t| t.name == MOUNTAIN_RAILWAY_TILE })
        end

        def upgrades_to?(from, to, special, selected_company: nil)
          valid = super
          return valid unless current_entity.corporation?
          return valid if mountain_railway_built?(current_entity)
          return valid unless mountain_hex?(from)

          valid || to.name == MOUNTAIN_RAILWAY_TILE
        end

        def after_lay_tile(_hex, tile, entity)
          if tile.name == MOUNTAIN_RAILWAY_TILE
            entity.assign!(MOUNTAIN_RAILWAY_ASSIGNMENT)
          elsif robot_owner?(entity) && home_route_complete?(entity)
            private_nationalised(entity)
          end
        end

        def setup_preround
          super
          return unless robot?

          @robot = Player.new(-1, 'Robot')
          @players << @robot
        end

        # This method is called to remove some private railways from 1858 when
        # there are two players. This does not happen in 1858 Switzerland.
        def setup_unbuyable_privates; end

        def gotthard
          @gotthard ||= hex_by_id('H11')
        end

        def fob_minor
          @fob_minor ||= minor_by_id('FOB')
        end

        def gb_minor
          @gb_minor ||= minor_by_id('GB')
        end

        def home_hex?(operator, hex, gauge = nil)
          home_hex = super
          return home_hex if !home_hex || hex != gotthard

          # Gotthard (H11) is different from other hexes. A public company
          # doesn't just to have to have a connection to anywhere on the hex to
          # be able to absorb a private railway. To absorb the GB private it
          # needs to have a connection to the broad gauge track, to absorb the
          # FOB it needs to have a connection to the metre (narrow) gauge track.
          (operator == fob_minor && gauge == :narrow) ||
            (operator == gb_minor && gauge == :broad)
        end

        def corporation_private_connected?(corporation, minor)
          # Private railway companies cannot be exchanged for shares of SBB.
          return false if corporation.type == :national

          super
        end

        def robot_owner?(entity)
          return false unless robot?
          return false if !entity.corporation? && !entity.minor?

          entity.owner == @robot
        end

        def acting_for_player(player)
          return player unless player == @robot

          acting_for_robot(current_entity)
        end

        # Finds the player who should take track actions for robot-owned
        # private railways and public companies.
        def acting_for_robot(operator)
          player_index =
            if operator.corporation?
              # SBB is operated by the priority holder in the first round of an
              # OR set, and the other player in the second.
              @round.round_num - 1
            else
              # The players take turns operate the robot's private railway
              # companies, starting with the priority deal holder.
              minor_index = @round.entities
                                  .select { |e| e.minor? && e.owner == @robot }
                                  .index(operator)
              minor_index % human_players.size
            end
          human_players[player_index]
        end

        def tile_lays(entity)
          return super unless robot_owner?(entity)

          entity.corporation? ? ROBOT_MAJOR_TILE_LAYS : ROBOT_MINOR_TILE_LAYS
        end

        def can_par?(corporation, parrer)
          return false if corporation == sbb

          super
        end

        def close_company(company)
          # Bit of a hack to avoid rewriting the method in G1858::Game.
          # This avoids the SBB being paid for any of their companies.
          company.owner = @bank if company.owner == sbb

          super
        end

        def buy_train(entity, train, price)
          super(entity, train, price.zero? ? :free : price)
        end

        # Checks whether tiles have been laid in all the hexes of a private
        # railway company.
        def home_route_complete?(entity)
          return false unless entity.minor?

          entity.coordinates.none? { |coord| hex_by_id(coord).tile.color == :white }
        end

        private

        def sbb
          @sbb ||= corporation_by_id('SBB')
        end

        # Is this game using the rules for the two-player robot variant?
        def robot?
          @optional_rules.include?(:robot)
        end

        def human_players
          @players.reject { |player| player == @robot }
        end

        def hexes_by_id(coordinates)
          coordinates.map { |coord| hex_by_id(coord) }
        end

        def r2r_bonus(route, stops, zone1, zone2, bonus)
          @bonus_nodes ||= {
            north: hexes_by_id(BONUS_HEXES[:north]).map(&:tile).flat_map(&:offboards),
            south: hexes_by_id(BONUS_HEXES[:south]).map(&:tile).flat_map(&:offboards),
            east: hexes_by_id(BONUS_HEXES[:east]).map(&:tile).flat_map(&:offboards),
            west: hexes_by_id(BONUS_HEXES[:west]).map(&:tile).flat_map(&:offboards),
          }
          @bonus_revenue ||= {
            north_south: hex_by_id(BONUS_HEXES[:revenue_ns]).tile.offboards.first,
            east_west: hex_by_id(BONUS_HEXES[:revenue_ew]).tile.offboards.first,
          }
          return 0 unless stops.intersect?(@bonus_nodes[zone1])
          return 0 unless stops.intersect?(@bonus_nodes[zone2])

          @bonus_revenue[bonus].route_revenue(@phase, route.train)
        end

        def north_south_bonus(route, stops)
          r2r_bonus(route, stops, :north, :south, :north_south)
        end

        def east_west_bonus(route, stops)
          r2r_bonus(route, stops, :east, :west, :east_west)
        end

        def mountain_hex?(tile)
          tile.color == :white && tile.upgrades.any? { |u| u.cost == 120 }
        end

        def mountain_railway_built?(entity)
          return false unless entity.corporation?

          entity.assignments.key?(MOUNTAIN_RAILWAY_ASSIGNMENT)
        end

        # Called when a private railway company owned by the robot has finished
        # laying track in all its home hexes. This closes the private railway
        # and, if possible, places a SBB token in one of its home cities.
        def private_nationalised(minor)
          @log << "#{minor.id} has built all its reserved hexes and is " \
                  "acquired by #{sbb.id}."
          company = private_company(minor)
          @robot.companies.delete(company)
          company.owner = sbb
          city = @cities.find { |c| c.reserved_by?(company) }
          if city&.tokenable?(sbb, free: true)
            @log << "#{sbb.id} places a token in #{city.tile.hex.location_name}."
            city.place_token(sbb, sbb.next_token, free: true)
          end
          close_private(minor)
        end
      end
    end
  end
end
