# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'tiles'
require_relative '../g_1858/game'

module Engine
  module Game
    module G1858India
      class Game < G1858::Game
        include_meta(G1858India::Meta)
        include Entities
        include Map
        include Tiles

        attr_accessor :mine_corp, :port_corp

        CURRENCY_FORMAT_STR = '£%s'
        BANK_CASH = 16_000
        STARTING_CASH = { 3 => 665, 4 => 500, 5 => 400, 6 => 335 }.freeze
        CERT_LIMIT = { 3 => 27, 4 => 20, 5 => 16, 6 => 13 }.freeze

        TRAIN_COUNTS = {
          '2H' => 8,
          '4H' => 7,
          '6H' => 5,
          '5E' => 4,
          '6E' => 3,
          '7E' => 20,
          '5D' => 10,
          'Mail' => 4,
        }.freeze

        PHASE4_TRAINS_RUST = 7 # 6H/3M trains rust after the seventh grey train is bought.

        STATUS_TEXT = G1858::Trains::STATUS_TEXT.merge(
          'loco_works' => [
            'Loco works available',
            'The locomotive works private companies are available for purchase',
          ],
          'oil_tokens' => [
            'Oil tokens',
            'Oil tokens can be collected',
          ],
          'port_tokens' => [
            'Port tokens',
            'Port tokens can be collected',
          ]
        ).freeze

        def setup
          super
          setup_hex_tokens
        end

        def operating_round(round_num = 1)
          @round_num = round_num
          Engine::Round::Operating.new(self, [
            G1858India::Step::Track,
            G1858India::Step::CollectTokens,
            G1858::Step::Token,
            G1858India::Step::Route,
            G1858::Step::Dividend,
            G1858::Step::DiscardTrain,
            G1858India::Step::BuyTrain,
            G1858::Step::IssueShares,
          ], round_num: round_num)
        end

        def game_trains
          unless @game_trains
            @game_trains = super.map(&:dup)
            # Add the 1M variant to the 2H train.
            @game_trains.first['variants'] =
              [
                {
                  name: '1M',
                  no_local: true,
                  distance: [{ 'nodes' => %w[city offboard], 'pay' => 1, 'visit' => 1 },
                             { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
                  track_type: :narrow,
                  price: 70,
                },
              ]
            @game_trains <<
              {
                name: 'Mail',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 7, 'visit' => 7 },
                           { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 }],
                track_type: :broad,
                price: 100,
                available_on: '3',
              }
          end
          @game_trains
        end

        def num_trains(train)
          TRAIN_COUNTS[train[:name]]
        end

        def mail_train?(train)
          train.name == 'Mail'
        end

        def owns_mail_train?(corporation)
          corporation.trains.any? { |train| mail_train?(train) }
        end

        def trainless?(corporation)
          # For emergency money raising, a mail train on its own doesn't stop
          # a public company from issuing shares.
          corporation.trains.none? { |train| !mail_train?(train) }
        end

        def num_corp_trains(corporation)
          # Mail trains don't count towards train limit.
          corporation.trains.count { |train| !mail_train?(train) }
        end

        def route_trains(entity)
          # Don't show mail trains in the route selector.
          entity.runnable_trains.reject { |train| mail_train?(train) }
        end

        def revenue_for(route, stops)
          super + mail_bonus(route, stops)
        end

        def game_phases
          unless @game_phases
            @game_phases = super.map(&:dup)
            @game_phases.first[:status] = %w[yellow_privates narrow_gauge]
            @game_phases[3][:status] << 'loco_works'
            @game_phases[3][:status] << 'oil_tokens'
            @game_phases[4][:status] << 'loco_works'
            @game_phases[4][:status] << 'oil_tokens'
            @game_phases[5][:status] << 'loco_works'
            @game_phases[5][:status] << 'oil_tokens'
            @game_phases[5][:status] << 'port_tokens'
          end
          @game_phases
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          super || gauge_conversion?(from, to)
        end

        # Checks whether a tile can replace another as a gauge conversion.
        # To do this it must:
        #   - Be the same colour as the previous one (yellow or green).
        #   - Have the same cities and towns as the previous one.
        #   - Have the same number of exits as the previous one.
        #   - Have the same arrangement of track as the previous one.
        #   - Have either:
        #     - one section of track connecting two edges changed from broad
        #       gauge to narrow gauge or vice versa, or
        #     - two sections of track connecting a town or city to edges changed
        #       from broad gauge to narrow gauge.
        # The check for the number of track sections changes is done in
        # G1858India::Step::Track.old_paths_maintained?
        def gauge_conversion?(from, to)
          return false unless from.color == to.color
          return false unless upgrades_to_correct_label?(from, to)
          return false unless from.cities.size == to.cities.size
          return false unless from.towns.size == to.towns.size
          return false unless from.paths.size == to.paths.size

          Engine::Tile::ALL_EDGES.any? do |ticks|
            from.paths.all? do |p|
              path = p.rotate(ticks)
              to.paths.any? do |other|
                path.ends.all? { |pe| other.ends.any? { |oe| pe <= oe } }
              end
            end
          end
        end

        def private_railway?(company)
          company.type != :locoworks
        end

        def purchasable_companies(_entity)
          @companies.select do |company|
            !private_railway?(company) && !company.owner
          end
        end

        def company_sellable(company)
          !private_railway?(company) && super
        end

        def unowned_purchasable_companies(_entity)
          @companies.select do |company|
            !company.closed? && (!company.owner || company.owner == @bank)
          end
        end

        def mine_hexes
          @mine_hexes ||= MINE_HEXES.map { |coord| hex_by_id(coord) }
        end

        def oil_hexes
          @oil_hexes ||= OIL_HEXES.map { |coord| hex_by_id(coord) }
        end

        def port_hexes
          @port_hexes ||= PORT_HEXES.map { |coord| hex_by_id(coord) }
        end

        def extra_revenue(_entity, routes)
          mines_ports_bonus(routes)
        end

        def submit_revenue_str(routes, _show_subsidy)
          bonus_revenue = extra_revenue(current_entity, routes)
          return super if bonus_revenue.zero?

          train_revenue = routes_revenue(routes)
          "#{format_revenue_currency(train_revenue)} + " \
            "#{format_revenue_currency(bonus_revenue)} mine/port bonus"
        end

        private

        def setup_hex_tokens
          @mine_corp = dummy_corp('mine', '1858_india/mine', mine_hexes)
          @oil_corp = dummy_corp('oil', '1858_india/oil', oil_hexes)
          @port_corp = dummy_corp('port', '1858_india/port', port_hexes)
        end

        def dummy_corp(sym, logo, hexes)
          corp = Corporation.new(
            sym: sym,
            name: sym,
            logo: logo,
            simple_logo: logo,
            tokens: Array.new(hexes.size, 0),
            type: :dummy
          )
          corp.owner = @bank
          hexes.each { |hex| hex.place_token(corp.next_token) }
          corp
        end

        def mail_bonus(route, stops)
          train = route.train
          return 0 unless @round.mail_trains[train.owner] == train

          stop_bonus = (train.multiplier || 1) * (train.obsolete ? 5 : 10)
          stop_bonus * stops.count { |stop| stop.city? || stop.offboard? }
        end

        def mines_ports_bonus(routes)
          return 0 if routes.empty?

          train = routes.first.train
          corp = train.owner
          mines = corp.tokens.count { |t| MINE_HEXES.include?(t.hex&.id) }
          oil = corp.tokens.count { |t| OIL_HEXES.include?(t.hex&.id) }
          ports = corp.tokens.count { |t| PORT_HEXES.include?(t.hex&.id) }
          return 0 if mines.zero? && ports.zero?

          @mine_bonus ||= hex_by_id(MINE_BONUS_HEX).tile.offboards.first
          @oil_bonus ||= hex_by_id(OIL_BONUS_HEX).tile.offboards.first
          @port_bonus ||= hex_by_id(PORT_BONUS_HEX).tile.offboards.first

          # Use #route_base_revenue here instead of #route_revenue as we
          # don't want the bonus doubled for 5D trains.
          (mines * @mine_bonus.route_base_revenue(@phase, train)) +
            (oil * @oil_bonus.route_base_revenue(@phase, train)) +
            (ports * @port_bonus.route_base_revenue(@phase, train))
        end
      end
    end
  end
end
