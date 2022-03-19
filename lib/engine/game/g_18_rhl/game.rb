# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'
require_relative '../stubs_are_restricted'
module Engine
  module Game
    module G18Rhl
      # Used for cities that is the destination for Trajekt ferries
      class VisitedWithoutCost
        def initialize(visit)
          @visit = visit
        end

        def visit_cost
          0
        end

        def type
          @visit.type
        end
      end

      class Game < Game::Base
        include_meta(G18Rhl::Meta)
        include Entities
        include Map

        attr_reader :osterath_tile

        CURRENCY_FORMAT_STR = '%dM'

        BANK_CASH = 9000

        CERT_LIMIT = { 3 => 20, 4 => 15, 5 => 12, 6 => 10 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze
        LOWER_STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300, 6 => 250 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        GAME_END_CHECK = { bank: :full_or }.freeze

        # Move down one step for a whole block, not per share
        SELL_MOVEMENT = :down_block

        # Cannot sell until operated
        SELL_AFTER = :operate

        # Sell zero or more, then Buy zero or one
        SELL_BUY_ORDER = :sell_buy

        # New track must be usable, or upgrade city value
        TRACK_RESTRICTION = :semi_restrictive

        # Cannot buy other corp trains during emergency buy (rule 13.2)
        EBUY_OTHER_VALUE = false

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_tile_block' => ['Remove tile block', 'Hex E12 can now be upgraded to yellow'],
        ).freeze

        MARKET = [%w[75
                     80
                     90
                     100p
                     110
                     120
                     135
                     150
                     165
                     180
                     200
                     220
                     240
                     265
                     290
                     320
                     350],
                  %w[70
                     75
                     80p
                     90p
                     100
                     110
                     120
                     135
                     150
                     165
                     180
                     200
                     220
                     240],
                  %w[65
                     70p
                     75p
                     80
                     90
                     100
                     110
                     120
                     135
                     150
                     165],
                  %w[60p 65p 70 75 80 90 100],
                  %w[55 60 65 70],
                  %w[50 55 60]].freeze

        STATUS_TEXT = {
          'incremental' => [
            'Incremental Cap',
            'Newly floated corporations used incremental capitalization for all shares sold during the whole game. '\
            'These corporation also get a one time stock price bump up one step if parring at less than 100. Unsold '\
            'shares moved to Treasury.',
          ],
          'fullcap' => [
            'Full Cap',
            'Newly floated corporations use 100% capitalization when floated, and no one time stock price bump. '\
            'Not yet sold shares moved to Market.',
          ],
        }.merge(Base::STATUS_TEXT).freeze

        PHASES = [
          {
            name: '2',
            on: '2',
            train_limit: 4,
            tiles: [:yellow],
            status: %w[incremental],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            status: %w[incremental],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            status: %w[incremental],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[fullcap],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[fullcap],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: %w[fullcap],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 5,
            price: 200,
            rusts_on: '6',
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 3,
            price: 300,
            rusts_on: '8',
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 3,
            price: 500,
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 6,
            price: 600,
            available_on: '5',
          },
          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 99 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            num: 4,
            price: 800,
            available_on: '6',
          },
        ].freeze

        def game_trains
          trains = self.class::TRAINS
          return trains unless optional_ratingen_variant

          # Inject remove_tile_block event
          trains.each do |t|
            next unless t[:name] == '3'

            t[:events] = [{ 'type' => 'remove_tile_block' }]
          end
          trains
        end

        def num_trains(train)
          return train[:num] unless train[:name] == '2'

          optional_2_train ? 7 : 6
        end

        def optional_2_train
          @optional_rules&.include?(:optional_2_train)
        end

        def optional_lower_starting_capital
          @optional_rules&.include?(:lower_starting_capital)
        end

        def optional_promotion_tiles
          @optional_rules&.include?(:promotion_tiles)
        end

        def optional_ratingen_variant
          @optional_rules&.include?(:ratingen_variant)
        end

        def init_starting_cash(players, bank)
          cash = optional_lower_starting_capital ? self.class::LOWER_STARTING_CASH : self.class::STARTING_CASH
          cash = cash[players.size]

          players.each do |player|
            bank.spend(cash, player)
          end
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G18Rhl::Step::CompanyPendingPar,
            Engine::Step::WaterfallAuction,
          ])
        end

        def stock_round
          @newly_floated = []
          G18Rhl::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18Rhl::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G18Rhl::Round::Operating.new(self, [
            G18Rhl::Step::Bankrupt,
            Engine::Step::HomeToken,
            G18Rhl::Step::SpecialTrack,
            G18Rhl::Step::SpecialToken, # Must be before regular track lay (due to private No. 4)
            G18Rhl::Step::Track,
            G18Rhl::Step::RheBonusCheck,
            G18Rhl::Step::Token,
            Engine::Step::Route,
            G18Rhl::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18Rhl::Step::BuyTrain,
          ], round_num: round_num)
        end

        def or_round_finished
          reset_all_token_blocking
          super
        end

        def priority_deal_player
          return players_with_max_cash.first if @round.is_a?(Engine::Round::Stock) && players_with_max_cash.one?

          super
        end

        def players_with_max_cash
          max_cash = @players.max_by(&:cash).cash
          @players.select { |p| p.cash == max_cash }
        end

        def show_priority_deal_player?(_order)
          true
        end

        def reorder_players(_order = nil, log_player_order: false)
          # Player order is the player with most cash (followed by seating order)
          # and if multiple players have most cast, left of last to act (followed
          # by seating order).

          max_cash_players = players_with_max_cash
          if max_cash_players.one?
            @players.rotate!(@players.index(max_cash_players.first))
            @log << "#{@players.first.name} has priority deal as having the most cash"
          else
            player = @players.reject(&:bankrupt)[@round.entity_index]
            @players.rotate!(@players.index(player))
            @log << "#{@players.first.name} has priority deal as being left of last to act, as several had the most cash"
          end
        end

        def cce
          @cce_corporation ||= corporation_by_id('CCE')
        end

        def keg
          @keg_corporation ||= corporation_by_id('KEG')
        end

        def rhe
          @rhe_corporation ||= corporation_by_id('RhE')
        end

        def prinz_wilhelm_bahn
          return if optional_ratingen_variant

          @prinz_wilhelm_bahn ||= company_by_id('PWB')
        end

        def angertalbahn
          return unless optional_ratingen_variant

          @angertalbahn ||= company_by_id('ATB')
        end

        def konzession_essen_osterath
          @konzession_essen_osterath ||= company_by_id('KEO')
        end

        def seilzuganlage
          @seilzuganlage ||= company_by_id('Szl')
        end

        def trajektanstalt
          @trajektanstalt ||= company_by_id('Tjt')
        end

        def rhe_company
          @rhe_company ||= company_by_id('RhE')
        end

        def setup
          keg.shares[2].double_cert = true
          keg.shares[3].double_cert = true

          @aachen_duren_cologne_link_bonus = 0
          @eastern_ruhr_connections = []
          @newly_floated = []

          @essen_tile ||= @tiles.find { |t| t.name == 'Essen' } if optional_promotion_tiles
          @moers_tile_brown ||= @tiles.find { |t| t.name == '947' }
          @moers_tile_gray ||= @tiles.find { |t| t.name == '950' } if optional_promotion_tiles
          @d_k_tile ||= @tiles.find { |t| t.name == '932V' } if optional_promotion_tiles
          @d_du_k_tile ||= @tiles.find { |t| t.name == '932' } unless optional_promotion_tiles
          @d_tile_brown ||= @tiles.find { |t| t.name == '927' }
          @k_tile_brown ||= @tiles.find { |t| t.name == '928' }
          @du_tile_brown ||= @tiles.find { |t| t.name == '929' }
          @du_tile_gray ||= @tiles.find { |t| t.name == '949' } if optional_promotion_tiles
          @osterath_tile ||= @tiles.find { |t| t.name == '935' }

          @variable_placement = (rand % 9) + 1

          # Add Koal to Moers upgrade tile - will be sticky
          @moers_tile_brown.icons << Part::Icon.new('../logos/18_rhl/K')

          # Put out K tokens
          @k = Corporation.new(
            sym: 'K',
            name: 'Coal',
            logo: '18_rhl/K',
            simple_logo: '18_rhl/K.alt',
            tokens: [0, 0, 0, 0],
          )
          @k.owner = @bank
          place_free_token(@k, 'C14', 1)
          place_free_token(@k, 'D15', 0)
          extra_coal_mine = hex_by_id(variable_coal_mine)
          extra_coal_mine.tile.icons << Part::Icon.new('../logos/18_rhl/K')
          @log << "Variable coal mine added to #{extra_coal_mine.name}"

          @s = Corporation.new(
            sym: 'S',
            name: 'Steel',
            logo: '18_rhl/S',
            simple_logo: '18_rhl/S.alt',
            tokens: [0, 0, 0, 0],
          )
          @s.owner = @bank
          place_free_token(@s, 'C14', 0)
          place_free_token(@s, 'D15', 1)
          extra_steel_mill = hex_by_id(variable_steel_mill).tile
          extra_steel_mill.icons << Part::Icon.new('../logos/18_rhl/S')
          @log << "Variable steel mill added to #{extra_steel_mill.name}"
        end

        include StubsAreRestricted

        def after_buy_company(player, company, price)
          super

          return unless company.id == 'RhE'

          @rhe_winning_bid = price
          @log << "Move 3 #{rhe.name} 10% shares to market"
          rhe.shares[1..3].each do |s|
            @share_pool.transfer_shares(s.to_bundle, @share_pool, price: 0, allow_president_change: false)
          end
        end

        def after_par(corporation)
          return unless corporation == rhe

          @bank.spend(@rhe_winning_bid, rhe)
          @log << "#{rhe.name} receives the winning bid of #{format_currency(@rhe_winning_bid)}
                  from #{rhe_company.name}"

          rhe_company.close!
          @log << "#{rhe_company.name} closes"
        end

        def float_corporation(corporation)
          if brown_phase?
            # When floated in phase 5 or later, do a "normal" float (ie 100% cap, be fullcap)
            # and move unsold shares to market.
            super

            @log << 'Move remaining IPO shares to market'
            corporation.shares.each do |s|
              @share_pool.transfer_shares(s.to_bundle, @share_pool, price: 0, allow_president_change: false)
            end
            return
          end

          @log << "#{corporation.name} floats"

          # For floats before phase 5, corporation receives par price for all shares sold from IPO to players.
          # The remaining shares end up in Treasury, and corporation becomes incremental.
          paid_to_treasury = corporation == keg ? 6 : 5

          if corporation == rhe
            @aachen_duren_cologne_link_bonus = rhe.par_price.price * 3
            delayed = format_currency(@aachen_duren_cologne_link_bonus)
            @log << "#{rhe.name} will receive #{delayed} when there is a link from Köln to Aachen via Düren (KDA link)"
            ability = abilities(rhe, :base)
            ability.description = "When KDA link created: treasury +#{format_currency(@aachen_duren_cologne_link_bonus)}"
            ability.desc_detail = 'The first time it is possible to go from Köln to Aachen via Düren the 3 times PAR '\
                                  "value of RhE (#{format_currency(@aachen_duren_cologne_link_bonus)}) will be added "\
                                  '̈́to the treasury of RhE. '\
                                  'Note: The link check ignores blocking tokens, available trains and length of route.'
          else
            @bank.spend(corporation.par_price.price * paid_to_treasury, corporation)
            @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
          end

          corporation.capitalization = :incremental

          # Corporations floated before phase 5 will increase one step at end of current SR
          @newly_floated << corporation
        end

        def handle_share_price_increase_for_newly_floated_corporations
          @newly_floated.each do |corp|
            prev = corp.share_price.price

            stock_market.move_up(corp)
            @log << "The share price of the newly floated #{corp.name} increases" if prev != corp.share_price.price
            log_share_price(corp, prev)
          end
          @newly_floated = []
        end

        def ipo_name(corporation)
          return 'I/T' unless corporation

          corporation.capitalization == :incremental ? 'Treasury' : 'IPO'
        end

        class WithNameAdapter
          def name
            'Receivership'
          end
        end

        def acting_for_entity(entity)
          return super if entity.owned_by_player?

          WithNameAdapter.new
        end

        def place_home_token(corporation)
          return super unless corporation == cce
          return if corporation.tokens.first&.used == true

          cce.coordinates.each_with_index do |coordinate, index|
            place_free_token(cce, coordinate, index, silent: false)
          end
          cce.coordinates = [cce.coordinates.first]
        end

        UPGRADES_TO_88 = %w[1 55].freeze
        UPGRADES_TO_87 = %w[2 56].freeze
        UPGRADE_TO_204 = '69'
        UPGRADES_FROM_3 = %w[141 142 143].freeze
        UPGRADES_FROM_4 = %w[141 142].freeze
        UPGRADES_FROM_58 = %w[141 142 143 144].freeze

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # Osterath cannot be upgraded at all, and cannot be upgraded to in phase 5 or later
          return false if from.name == @osterath_tile&.name ||
          (to.name == @osterath_tile&.name && @phase.name.to_i >= 5)

          # Private No. 2 allows Osterath tile to be put on E8 regardless
          return true if from.hex.name == 'E8' &&
          to.name == @osterath_tile&.name &&
          selected_company == konzession_essen_osterath

          # Handle Rhine Metropolis upgrade from green
          return to.name == '927' if from.color == :green && from.hex.name == 'F9'
          return to.name == '928' if from.color == :green && from.hex.name == 'I10'
          return to.name == '929' if from.color == :green && from.hex.name == 'D9'

          # Handle Moers upgrades
          return to.name == '947' if from.color == :green && from.hex.name == 'D7'
          return to.name == '950' if from.color == :brown && from.hex.name == 'D7'

          # Handle 3-spokers
          return UPGRADES_FROM_3.include?(to.name) if from.name == '3'
          return UPGRADES_FROM_4.include?(to.name) if from.name == '4'
          return UPGRADES_FROM_58.include?(to.name) if from.name == '58'
          return false if UPGRADES_FROM_58.include?(from.name)

          # Handle 4-spokers
          return to.name == '87' if UPGRADES_TO_87.include?(from.name)
          return to.name == '88' if UPGRADES_TO_88.include?(from.name)
          return to.name == '204' if from.name == UPGRADE_TO_204

          if optional_promotion_tiles
            # Essen can be upgraded to gray
            return to.name == 'Essen' if from.color == :brown && from.hex.name == 'D13'

            # Dusseldorf and Cologne can be upgraded to gray 932V
            return to.name == '932V' if from.color == :brown && %w[F9 I10].include?(from.hex.name)

            # Moers can be upgraded to gray 950
            return to.name == '950' if from.color == :brown && from.hex.name == 'D7'

            # Duisburg can be upgraded to gray 929
            return to.name == '949' if from.color == :brown && from.hex.name == 'D9'
          elsif from.color == :brown && %w[D9 F9 I10].include?(from.hex.name)
            return to.name == '932'
          end
          # Duisburg, Dusseldorf and Cologne can be upgraded to gray 932

          return super unless optional_ratingen_variant

          # Hex E10 have special tile for upgrade to yellow, and green, and no brown
          if from.hex.name == 'E10'
            case from.color
            when :white
              return to.name == '1910'
            when :yellow
              return to.name == '1911'
            else
              return false
            end
          end

          # Hex E12 is blocked for upgrade in yellow phase
          return super if from.hex.name != RATINGEN_HEX || phase.name != '2'

          raise GameError, "Cannot place a tile in #{from.hex.name} until green phase"
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          # Osterath cannot be upgraded
          return [] if tile.name == @osteroth_tile&.name

          upgrades = super

          return upgrades unless tile_manifest

          # Handle potential upgrades to Osterath tile
          upgrades |= [@osterath_tile] if OSTERATH_POTENTIAL_TILE_UPGRADES_FROM.include?(tile.name)

          # Tile manifest for 947 should show Moers tile if Moers tile used
          upgrades |= [@moers_tile_gray] if @moers_tile_gray && tile.name == '947'

          # Tile manifest for 216 should show Essen tile if Essen tile used
          upgrades |= [@essen_tile] if @essen_tile && tile.name == '216'

          # Show correct potential upgrades for Rhine Metropolis hexes
          upgrades |= [@d_k_tile] if @d_k_tile && %w[927 928].include?(tile.name)
          upgrades |= [@d_du_k_tile] if @d_du_k_tile && %w[927 928 929].include?(tile.name)
          upgrades |= [@du_tile_gray] if @du_tile_gray && tile.name == '929'

          # Show brown upgrades from Rhine Metropolis green tiles
          upgrades |= [@d_tile_brown] if %w[921X 922X].include?(tile.name)
          upgrades |= [@k_tile_brown] if %w[923X 924X].include?(tile.name)
          upgrades |= [@du_tile_brown] if %w[925X 926X].include?(tile.name)

          upgrades
        end

        def legal_tile_rotation?(_entity, hex, tile)
          return legal_if_stubbed?(hex, tile) unless tile.name == '1910'

          # Need special handling - tile 1910 must match both stubs of base hex
          hex.tile.stubs.map(&:edge) == tile.exits
        end

        def hex_blocked_by_ability?(entity, ability, hex)
          return false if entity.player == ability.owner.player && (hex.name == 'E14' || hex == yellow_block_hex)

          super
        end

        def event_remove_tile_block!
          @log << "Hex #{RATINGEN_HEX} is now possible to upgrade to yellow"
          yellow_block_hex.tile.icons.reject! { |i| i.name == 'green_hex' }
        end

        def rhine_metropolis_visits(visits)
          metropolis_visits = []

          visits.each_with_index do |v, idx|
            next unless RHINE_METROPOLIS_HEXES.include?(v.hex.name)

            metropolis_visits << { name: v.hex.name, index: idx, color: v.hex.tile.color, loc: v.loc }
          end

          metropolis_visits.group_by { |v| v[:name] }.reject { |_, e| e.size < 2 }
        end

        def illegal_revisit_of_rhine_metropolis_hex?(visits)
          visits.each do |_hex_name, v|
            next if v.size < 2 || v.first[:color] != :green

            0.upto(v.size - 2).each do |idx|
              (idx + 1).upto(v.size - 1).each do |idx2|
                # In green a visit of both cities can only be if using a trajekt
                return true if v[idx][:loc] != v[idx2][:loc] && v[idx][:index] + 1 < v[idx2][:index]
              end
            end
          end
          false
        end

        def check_distance(route, visits)
          first = visits.first
          last = visits.last
          corp = route.train.owner
          raise GameError, 'Route cannot begin/end in a town' if first.town? || last.town?
          raise GameError, 'Route to out-tokened off-board hex not allowed' if out_tokened_hex?(first.hex, corp) ||
                                                                               out_tokened_hex?(last.hex, corp)

          if visits.count { |v| EASTERN_RUHR_HEXES.include?(v.hex.name) } > 1
            raise GameError, 'A route cannot both begin and end at Eastern Ruhr off-board hexes'
          end

          if visits.count { |v| NIMWEGEN_ARNHEIM_OFFBOARD_HEXES.include?(v.hex.name) } > 1
            raise GameError, 'A route cannot both begin and end at the Nimwegen and Arnheim off-board hexes'
          end

          if visits.count { |v| BASEL_FRANKFURT_OFFBOARD_HEXES.include?(v.hex.name) } > 1
            raise GameError, 'A route cannot both begin and end at the Basel and Frankfurt off-board hexes'
          end

          if route.train.name == '8'
            if !rge_terminus?(visits.first) && !rge_terminus?(visits.last)
              raise GameError, 'Route for 8 trains must begin and/or end in an RGE hex'
            end
            if visits.find { |v| !RGE_HEXES.include?(v.hex.name) && v.hex.tile.color == :red }
              raise GameError, 'Route for 8 trains cannot include any off-board hexes besides the RGE ones'
            end
          end

          metropolis_visits = rhine_metropolis_visits(visits)
          return super if metropolis_visits.empty?

          if illegal_revisit_of_rhine_metropolis_hex?(metropolis_visits)
            raise GameError, 'Must use Trajekt for a revisiting route'
          end

          trajekts = trajekts_used(metropolis_visits)
          return super if trajekts.empty?

          # Create a clone so that we can set visit cost to zero for any Trajekts used
          updated_visits = visits.clone
          trajekts.each do |trajekt|
            idx = trajekt[:index]
            updated_visits[idx] = VisitedWithoutCost.new(visits[idx])
          end

          super(route, updated_visits)
        end

        def revenue_for(route, _stops)
          # # Need to use visited_stops as the supplied stops might have some visited stops removed due to trajekt usage
          stops = route.visited_stops

          revenue = super(route, stops)
          revenue_info(route, stops).each { |b| revenue += b[:revenue] }

          revenue
        end

        def revenue_str(route)
          stops = route.stops

          count = {}
          route_hexes = route.hexes.map do |h|
            # Auto-routing seems to give tripple hex in case of trajekt, so skip third
            previous = count[h&.name] || 0
            new_count = previous + 1
            count[h&.name] = new_count
            new_count > 2 ? nil : h
          end.compact

          stop_hexes = stops.map(&:hex)
          str = route_hexes.map do |h|
            stop_hexes.include?(h) ? h&.name : "(#{h&.name})"
          end.join('-')

          revenue_info(route, stops).map { |b| b[:description] }.compact.each { |d| str += " + #{d}" }

          str
        end

        def route_distance(route)
          metropolis_visits = rhine_metropolis_visits(route.visited_stops)
          super - trajekts_used(metropolis_visits).size
        end

        def route_distance_str(route)
          towns = route.stops.count(&:town?)
          cities = route_distance(route) - towns
          return towns.zero? ? cities.to_s : "#{cities}+#{towns}" unless route.train.name == '8'

          cities > 8 ? "8(+#{cities - 8})" : cities.to_s
        end

        def revenue_info(route, stops)
          # # Need to use visited_stops as the supplied stops might have some visited stops removed due to trajekt usage
          # stops = route.visited_stops

          [montan_bonus(route, stops),
           eastern_ruhr_area_bonus(stops),
           iron_rhine_bonus(stops),
           trajekt_usage_penalty(route),
           rheingold_express_bonus(route, stops),
           ratingen_bonus(route, stops)]
        end

        def aachen_duren_cologne_link_checkable?
          @aachen_duren_cologne_link_bonus.positive?
        end

        def aachen_duren_cologne_link_established?
          return unless aachen_duren_cologne_link_checkable?
          return if loading

          duren_aachen = false
          duren_cologne = false

          @corporations.select(&:operated?).each do |corp|
            duren_aachen ||= check_connections(corp, aachen_hex)
            duren_cologne ||= check_connections(corp, cologne_hex)
          end
          duren_aachen && duren_cologne
        end

        def aachen_duren_cologne_link_established!
          @log << 'A link between Aachen and Köln, via Düren, has been established!'
          @log << "#{rhe.name} adds #{format_currency(@aachen_duren_cologne_link_bonus)} to its treasury"
          @bank.spend(@aachen_duren_cologne_link_bonus, rhe)
          @aachen_duren_cologne_link_bonus = 0
          rhe.remove_ability(abilities(rhe, :base))
        end

        def eastern_ruhr_connection_check(hex)
          return if !EASTERN_RUHR_CONNECTION_CHECK.include?(hex.name) || @eastern_ruhr_connections.size == 4

          [['C12', 4], ['D13', 3], ['D13', 4], ['E14', 3]].each do |check_hex, edge|
            next unless check_hex == hex.name
            next if @eastern_ruhr_connections.include?([check_hex, edge])
            next unless hex.tile.exits.include?(edge)

            @log << 'New link to Eastern Ruhr established'
            @eastern_ruhr_connections << [check_hex, edge]
          end
        end

        def potential_icon_cleanup(tile)
          # FIXME: Sticky:0 does not seem to work so remove trajekt icon manually
          remove_trajekt_icon(tile) if RHINE_METROPOLIS_HEXES.include?(tile.hex.id) && tile.color == :brown
        end

        def shares_for_presidency_swap(shares, num_shares)
          # The shares to exchange might contain a double share.
          # If so, return that unless more than 2 certificates.
          twenty_percent = shares.find(&:double_cert)
          return super unless twenty_percent
          return [twenty_percent] if shares.size <= num_shares && twenty_percent

          super(shares - [twenty_percent], num_shares)
        end

        def player_value(player)
          # Do not include companies in valuation, as they cannot be sold
          super - player.companies.sum(&:value)
        end

        def reset_all_token_blocking
          @corporations.each { |c| c.tokens.each { |t| t.type = :normal } }
        end

        def update_token_blocking_in_rhine_metropolies(entity)
          reset_all_token_blocking
          [duisburg_hex, dusseldorf_hex, cologne_hex].each do |hex|
            next unless hex.tile.color == :green

            tokens = get_all_tokens_in_hex(hex)
            if tokens.size < 3
              # If not fully tokened, make all tokens passable
              type = :neutral
            else
              # If current operator has a token, make all passable in hex
              entity_tokens = tokens.count { |t| t.corporation == entity }
              type = entity_tokens.positive? ? :neutral : :normal
            end

            tokens.each { |t| t.type = type }
          end
        end

        def get_token(entity, token)
          return token unless token.nil?

          # Due to changing the token type, this can cause problems when doing undo.
          # As a fall back assume first available token of type normal/neutral is OK
          token_owner = entity.company? ? entity.owner : entity
          token_owner.find_token_by_type(:normal) || token_owner.find_token_by_type(:neutral)
        end

        private

        def get_all_tokens_in_hex(hex)
          tokens = []
          hex.tile.cities.each do |c|
            c.tokens.each do |t|
              tokens << t if t
            end
          end
          tokens
        end

        def variable_coal_mine
          case @variable_placement
          when 1, 7
            'J3'
          when 2
            'K4'
          when 3, 4
            'D9'
          when 5, 6
            'C12'
          when 8, 9
            'D11'
          end
        end

        def variable_steel_mill
          case @variable_placement
          when 1, 3, 5, 8
            'E6'
          when 2, 6, 9
            'D9'
          when 4, 7
            'D13'
          end
        end

        def brown_phase?
          @phase.name.to_i >= 5
        end

        def place_free_token(corporation, hex_name, city_number, silent: true)
          hex = hex_by_id(hex_name).tile

          # If tile has been upgraded to green - then it is just one city with slots
          city_number = 0 if hex.cities.one?
          hex.cities[city_number].place_token(corporation, corporation.next_token, free: true)
          @log << "#{corporation.name} places a token on #{hex_name}" unless silent
        end

        def get_location_name(hex_name)
          @hexes.find { |h| h.name == hex_name }.location_name
        end

        def metropolis_name(metropolis_hex_name, is_west)
          west_name, east_name = get_location_name(metropolis_hex_name).split
          is_west || !east_name ? west_name : east_name
        end

        def out_tokened_hex?(hex, corporation)
          return false unless OUT_TOKENED_HEXES.include?(hex.name)

          tile_cities = hex.tile.cities
          return false if tile_cities.empty? || tile_cities.first.tokens.empty?

          tile_cities.first.tokens.find { |t| t&.corporation != corporation }
        end

        def montan_bonus(route, stops)
          bonus = { revenue: 0 }
          return bonus if route.train.name == '8'

          coal = count_coal(route, stops)
          return bonus if coal.zero?

          steel = count_steel(route, stops)
          return bonus if steel.zero?

          if coal > 1 && steel > 1
            bonus[:revenue] = brown_phase? ? 80 : 40
            bonus[:description] = 'Double Montan'
          else
            bonus[:revenue] = brown_phase? ? 40 : 20
            bonus[:description] = 'Montan'
          end
          bonus
        end

        def count_coal(route, stops)
          coal = visited_icons(stops, 'K')
          coal += 1 if stops.find { |s| EASTERN_RUHR_HEXES.include?(s.hex.id) && coal_edge_used?(route, s.hex.id) }
          coal
        end

        def count_steel(route, stops)
          steel = visited_icons(stops, 'S')
          steel += 1 if stops.find { |s| EASTERN_RUHR_HEXES.include?(s.hex.id) && steel_edge_used?(route, s.hex.id) }
          steel += 1 if stops.find { |s| s.hex.id == 'J15' }
          steel
        end

        def eastern_ruhr_area_bonus(stops)
          bonus = { revenue: 0 }
          return bonus if stops.none? { |s| EASTERN_RUHR_HEXES.include?(s.hex.id) }

          links = @eastern_ruhr_connections.size
          bonus[:revenue] = 10 * links
          bonus[:description] = "#{links} link#{links > 1 ? 's' : ''}"
          bonus
        end

        def iron_rhine_bonus(stops)
          bonus = { revenue: 0 }
          return bonus if stops.none? { |s| s.hex.id == roermund_hex.id } ||
                          stops.none? { |s| EASTERN_RUHR_HEXES.include?(s.hex.id) }

          bonus[:revenue] = 80
          bonus[:description] = 'Iron Rhine'
          bonus
        end

        def trajekt_usage_penalty(route)
          metropolis_visits = rhine_metropolis_visits(route.visited_stops)

          # For any green Rhine Metropolis hex, we need to check if ferry is used
          bonus = { revenue: 0 }
          trajekts_count = trajekts_used(metropolis_visits).size
          return bonus unless trajekts_count.positive?

          bonus[:revenue] = -50 * trajekts_count
          bonus[:description] = "#{trajekts_count} trajekt#{trajekts_count > 1 ? 's' : ''}"
          bonus
        end

        def trajekts_used(metropolis_visits)
          green_visits = metropolis_visits.select { |_k, v| v.first[:color] == :green && v.size > 1 }
          return [] if green_visits.empty?

          trajekts = []
          green_visits.each do |_hex_name, visits|
            visits.each_cons(2) do |v|
              v1 = v.first
              v2 = v.last
              trajekts << v2 if v1[:index] + 1 == v2[:index] && v1[:loc] != v2[:loc]
            end
          end

          trajekts
        end

        def rheingold_express_bonus(route, stops)
          bonus = { revenue: 0 }
          return bonus if route.train.name != '8' ||
                          !stops.first || !rge_terminus?(stops.first) ||
                          !stops.last || !rge_terminus?(stops.last)

          # Double any Rhine Metropolis cities visited
          doubles = 0
          stops.each do |s|
            next unless RHINE_METROPOLIS_HEXES.include?(s.hex.name)

            doubles += 1
            bonus[:revenue] += s.route_revenue(route.phase, route.train)
          end
          return bonus unless doubles.positive?

          bonus[:description] = 'RGE' + (doubles > 1 ? "x#{doubles}" : '')
          bonus
        end

        def ratingen_bonus(route, stops)
          bonus = { revenue: 0 }
          return bonus if !optional_ratingen_variant ||
                          route.train.name == '8' ||
                          stops.none? { |s| s.hex.id == RATINGEN_HEX } ||
                          count_steel(route, stops).zero?

          bonus[:revenue] = 30
          bonus[:description] = 'Ratingen'
          bonus
        end

        def check_connections(corp, destination)
          duren_node = duren_hex.tile.cities.first # Each tile with a city has exactly one node

          destination.tile.nodes.first&.walk(corporation: corp) do |path, _, _|
            return true if path.nodes.include?(duren_node)
          end

          false
        end

        def visited_icons(stops, icon_name)
          stops.select { |s| s.hex.tile.icons.any? { |i| i.name == icon_name } }
               .map { |s| s.hex.name }
               .uniq
               .size
        end

        def rge_terminus?(visited_node)
          return false unless visited_node

          RGE_HEXES.include?(visited_node.hex.name)
        end

        def western_edge_used?(hex_name, chain)
          edge_used?(chain, hex_name, [0, 1, 2])
        end

        def eastern_edge_used?(hex_name, chain)
          edge_used?(chain, hex_name, [3, 4, 5])
        end

        def coal_edge_used?(route, hex_name)
          edge_of_interest = hex_name == 'C14' ? 1 : 0
          route.chains.any? { |c| edge_used?(c, hex_name, [edge_of_interest]) }
        end

        def steel_edge_used?(route, hex_name)
          edge_of_interest = hex_name == 'C14' ? 0 : 1
          route.chains.any? { |c| edge_used?(c, hex_name, [edge_of_interest]) }
        end

        def edge_used?(chain, hex_name, edges_of_interest)
          chain[:paths].any? { |p| p.hex.name == hex_name && !(p.exits & edges_of_interest).empty? }
        end

        def tile_has_specified_exits?(hex, specified_exits)
          !(hex.tile.exits & specified_exits).empty?
        end

        def remove_trajekt_icon(tile)
          tile.icons.reject! { |i| i.name == 'trajekt' }
        end
      end
    end
  end
end
