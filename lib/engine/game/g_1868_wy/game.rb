# frozen_string_literal: true

require_relative 'credit_mobilier'
require_relative 'entities'
require_relative 'golden_spike'
require_relative 'map'
require_relative 'meta'
require_relative 'share_pool'
require_relative 'trains'
require_relative 'step/assign'
require_relative 'step/buy_company'
require_relative 'step/buy_train'
require_relative 'step/choose'
require_relative 'step/company_pending_par'
require_relative 'step/development_token'
require_relative 'step/dividend'
require_relative 'step/double_share_protection'
require_relative 'step/home_token'
require_relative 'step/issue_shares'
require_relative 'step/manual_close_company'
require_relative 'step/route'
require_relative 'step/stock_round_action'
require_relative 'step/token'
require_relative 'step/track'
require_relative 'step/waterfall_auction'
require_relative '../base'
require_relative '../company_price_up_to_face'
require_relative '../swap_color_and_stripes'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G1868WY
      class Game < Game::Base
        # Engine::Game::G1868WY includes
        include_meta(G1868WY::Meta)
        include Entities
        include Map
        include Trains
        include CreditMobilier
        include GoldenSpike

        # Engine::Game includes
        include CompanyPriceUpToFace
        include StubsAreRestricted
        include SwapColorAndStripes

        attr_accessor :big_boy_first_chance, :double_headed_trains, :dpr_first_home_status,
                      :up_double_share_protection
        attr_reader :big_boy_train, :big_boy_train_original

        # overrides
        BANK_CASH = 99_999
        STARTING_CASH = { 3 => 734, 4 => 550, 5 => 440 }.freeze
        CERT_LIMIT = { 3 => 20, 4 => 15, 5 => 12 }.freeze
        SELL_AFTER = :any_time
        CAPITALIZATION = :incremental
        SELL_BUY_ORDER = :sell_buy
        HOME_TOKEN_TIMING = :par
        NEXT_SR_PLAYER_ORDER = :first_to_pass
        MUST_SELL_IN_BLOCKS = true
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        MUST_BUY_TRAIN = :always
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        EBUY_OTHER_VALUE = true
        MARKET = [
          [''] + %w[82 90 100 110z 120z 140 160 180 200 225 250 275 300 325 350 375 400 430 460 490 525 560],
          %w[72 76 82 90x 100x 110 120 140 160 180 200 225 250 275 300 325 350 375 400 430 460 490],
          %w[68 72 76 82p 90 100 110 120 140 160 180 200 225 250 275 300 325 350],
          %w[64 68 72 76p 82 90 100 110 120 140 160 180 200 225],
          %w[60 64 68 72p 76 82 90 100 110 120 140],
          %w[55 60 64 68p 72 76 82 90 100],
          %w[50 55 60 64 68 72 76],
          %w[40 50 55 60 64 68],
        ].freeze
        STOCKMARKET_COLORS = {
          par: :yellow,
          par_1: :green,
          par_2: :brown,
        }.freeze
        LATE_CORPORATIONS = %w[C&N DPR LNP OSL].freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'Railroad Company par values',
                                              par_1: 'additional par values in Phase 3+',
                                              par_2: 'additional par values in Phase 5+').freeze
        # rubocop:disable Layout/LineLength
        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          green_par: ['Green Par Available', 'Phase 3: Railroad Companies may now additionally start at $90 or $100'],
          brown_par: ['Brown Par Available', 'Phase 5: Railroad Companies may now additionally start at $110 or $120'],
          all_corps_available: ['All Railroad Companies Available',
                                'Phase 5: All Railroad Companies are now available to start'],
          full_capitalization: ['Full Capitalization',
                                'Phase 5: Railroad Companies now float at 60% and receive full capitalization'],
          oil_companies_available: ['Oil Companies Available', 'Phase 5: Oil Companies begin to Develop after Coal Companies'],
          uranium_boom: ['Uranium Boom',
                         'Phase 5-6: Uranium Boom token added to appropriate Uranium location(s); counts as a DT and adds +$20 revenue'],
          trigger_endgame: ['Trigger Endgame',
                            'Phase 7: Begin final SR after current OR (even if this skips OR 2 of 2); see see the "Endgame Sequence" timeline for more details'],
          uranium_bust: ['Uranium BUST', 'Phase 7: Uranium locations BUST into Ghost Towns'],
          close_privates: ['Close Privates',
                           'Phase 5-8: various private companies close at each of these phases'],
          close_coal_companies: ['Close Coal Companies', 'Phase 8: Coal Companies stop Developing; gray Coal DTs remain on the board'],
          remove_placed_coal_dt: ['"Rust" Coal DTs', 'Phase 4-8: Coal DTs placed 2 phases ago are removed from the board'],
          remove_unplaced_coal_dt: ['Remove Unplaced Coal DTs', 'Phase 3-7: Coal DTs still on a Coal Company\'s charter from the previous phase are discarded'],
        ).freeze
        # rubocop:enable Layout/LineLength
        STATUS_TEXT = {
          'can_buy_companies' => ['Can Buy Privates',
                                  'All Railroad Companies can buy private companies from players'],
          'all_corps_available' => ['All Railroad Companies Available',
                                    'All Railroad Companies are now available to start'],
          'full_capitalization' =>
            ['Full Capitalization', 'Railroad Companies float at 60% and receive full capitalization'],
        }.freeze

        # track points
        TRACK_POINTS = 6
        YELLOW_POINT_COST = 2
        UPGRADE_POINT_COST = 3

        # boomtowns, coal/oil/uranium
        DTC_GHOST_TOWN = 0
        DTC_BOOMCITY = 3
        DTC_REVENUE = 4
        BOOMING_REVENUE_BONUS = 10
        BUSTED_REVENUE = {
          yellow: 10,
          green: 10,
          brown: 20,
          gray: 20,
        }.freeze

        GHOST_TOWN_NAME = 'ghost town'

        BILLINGS_HEXES = %w[A9 A11].freeze
        FEMV_HEX = 'G27'
        RCL_HEX = 'C27'
        WALDEN_HEX = 'N18'
        WIND_RIVER_CANYON_HEX = 'F12'

        # special shares
        UP_PRESIDENTS_SHARE = 'UP_0'
        UP_DOUBLE_SHARE = 'UP_7'

        def dotify(tile)
          tile.towns.each { |town| town.style = :dot }
          tile
        end

        def init_tiles
          super.each { |tile| dotify(tile) }
        end

        def init_hexes(companies, corporations)
          super.each { |hex| dotify(hex.tile) }
        end

        def add_extra_tile(tile)
          dotify(super)
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def setup
          init_track_points
          setup_company_price_up_to_face

          @development_hexes = init_development_hexes
          @development_token_count = Hash.new(0)
          @placed_development_tokens = Hash.new { |h, k| h[k] = [] }
          @busters = {}

          @late_corps, @corporations = @corporations.partition { |c| LATE_CORPORATIONS.include?(c.id) }
          @late_corps.each { |corp| corp.reservation_color = nil }
          setup_credit_mobilier

          @coal_companies = init_coal_companies
          @minors.concat(@coal_companies)
          update_cache(:minors)

          @available_par_groups = %i[par]

          @double_headed_trains = []

          # place neutral token in Walden
          neutral = Corporation.new(
            sym: 'N',
            name: 'Neutral',
            logo: 'open_city',
            simple_logo: 'open_city',
            tokens: [0],
          )
          neutral.owner = @bank
          neutral.tokens.first.type = :neutral
          city_by_id("#{self.class::WALDEN_HEX}-0-0").place_token(neutral, neutral.next_token)

          # reserve the double share for Ames Bros exchange
          union_pacific.shares.last.buyable = false
          up_double_share.double_cert = true
          @up_double_share_protection = {}

          @lhp_train = find_and_remove_train_by_id('2+1-0', buyable: false)
          @lhp_train_pending = false

          setup_spikes

          @big_boy_first_chance = false
        end

        def init_share_pool
          G1868WY::SharePool.new(self)
        end

        def dpr
          @dpr ||= corporation_by_id('DPR')
        end

        def femv
          @femv ||= corporation_by_id('FE&MV')
        end

        def rcl
          @rcl ||= corporation_by_id('RCL')
        end

        def femv_hex?(hex)
          hex.id == self.class::FEMV_HEX
        end

        def rcl_hex?(hex)
          hex.id == self.class::RCL_HEX
        end

        def union_pacific
          @union_pacific ||= corporation_by_id('UP')
        end

        def up_presidency
          @up_presidency ||= share_by_id(self.class::UP_PRESIDENTS_SHARE)
        end

        def up_double_share
          @up_double_share ||= share_by_id(self.class::UP_DOUBLE_SHARE)
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::SpecialTrack,
            G1868WY::Step::Assign,
            G1868WY::Step::ManualCloseCompany,
            G1868WY::Step::HomeToken,
            G1868WY::Step::DoubleShareProtection,
            G1868WY::Step::StockRoundAction,
          ])
        end

        def init_stock_market
          G1868WY::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                   multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def operating_round(round_num)
          G1868WY::Round::Operating.new(self, [
            G1868WY::Step::DevelopmentToken,
            Engine::Step::Bankrupt,
            Engine::Step::SpecialTrack,
            G1868WY::Step::Assign,
            G1868WY::Step::BuyCompany,
            G1868WY::Step::ManualCloseCompany,
            G1868WY::Step::Choose,
            G1868WY::Step::IssueShares,
            G1868WY::Step::Track,
            G1868WY::Step::Token,
            G1868WY::Step::DoubleHeadTrains,
            G1868WY::Step::Route,
            G1868WY::Step::Dividend,
            G1868WY::Step::DoubleShareProtection,
            Engine::Step::DiscardTrain,
            G1868WY::Step::BuyTrain,
            [G1868WY::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1868WY::Step::CompanyPendingPar,
            G1868WY::Step::WaterfallAuction,
          ])
        end

        def init_round_finished
          up_double_share.buyable = true unless ames_bros.player

          durant.close!
          @log << "#{durant.name} closes"
        end

        def event_all_corps_available!
          @late_corps.each { |corp| corp.reservation_color = CORPORATION_RESERVATION_COLOR }
          @corporations.concat(@late_corps)
          @log << '-- All corporations now available --'
        end

        def event_full_capitalization!
          @log << '-- Event: Railroad Companies now float at 60% and receive full capitalization --'
          @corporations.each do |corporation|
            next if corporation.floated?

            corporation.capitalization = :full
            corporation.float_percent = 60
          end
        end

        def event_green_par!
          @log << "-- Event: #{EVENTS_TEXT[:green_par][1]} --"
          @available_par_groups << :par_1
          update_cache(:share_prices)
        end

        def event_brown_par!
          @log << "-- Event: #{EVENTS_TEXT[:brown_par][1]} --"
          @available_par_groups << :par_2
          update_cache(:share_prices)
        end

        def par_prices
          @stock_market.share_prices_with_types(@available_par_groups)
        end

        def event_remove_coal_dt!(phase_name)
          @log << "-- Event: Phase #{phase_name} Coal Development Tokens are removed --"

          @placed_development_tokens[phase_name].each do |hex|
            tokens = hex.tile.icons.select { |i| i.name == "coal-#{phase_name}" }

            tokens.each do |token|
              hex.tile.icons.delete(token)
              decrement_development_token_count(hex)
            end
          end

          handle_bust_preprinted_and_revenue!
        end

        def event_close_big_boy!
          detach_big_boy(log: true)
        end

        def float_corporation(corporation)
          if @phase.status.include?('full_capitalization')
            bundle = ShareBundle.new(corporation.shares_of(corporation))
            @share_pool.transfer_shares(bundle, @share_pool)
            @log << "#{corporation.name}'s remaining shares are transferred to the Market"
          end

          super

          corporation.capitalization = :incremental
        end

        def event_convert_lhp!
          if (corporation = lhp_private.corporation)
            convert_lhp_train!(corporation)
          else
            @lhp_train_pending = true unless lhp_private.closed?
          end
        end

        def convert_lhp_train!(corporation)
          train = @lhp_train
          buy_train(corporation, train, :free)
          @log << "#{lhp_private.name} converts to a #{train.name} train for #{corporation.id}"
          lhp_private.close!
          @lhp_train_pending = false
        end

        def pass_converting_lhp_train!
          train = @lhp_train
          @log << "#{lhp_private.name} closes without converting to a #{train.name} train"
          lhp_private.close!
          @lhp_train_pending = false
        end

        def extra_train?(train)
          train == @lhp_train
        end

        def crowded_corps
          @crowded_corps ||= corporations.select do |c|
            c.trains.count { |t| !extra_train?(t) } > train_limit(c)
          end
        end

        def must_buy_train?(entity)
          entity.trains.none? { |t| !extra_train?(t) }
        end

        def lhp_train_pending?
          @lhp_train_pending
        end

        def init_track_points
          @track_points_used = Hash.new(0)
        end

        def status_str(corporation)
          return unless corporation.floated?

          if corporation.minor?
            player = corporation.owner
            "#{player.name} Cash: #{format_currency(player.cash)}"
          else
            "Track Points: #{track_points_available(corporation)}"
          end
        end

        def hell_on_wheels
          @hell_on_wheels ||= company_by_id('P1')
        end

        def wylie
          @wylie ||= company_by_id('P2a')
        end

        def trabing_bros
          @trabing_bros ||= company_by_id('P2b')
        end

        def midwest_oil
          @midwest_oil ||= company_by_id('P2c')
        end

        def upc_private
          @upc_private ||= company_by_id('P3a')
        end

        def bonanza_private
          @bonanza_private ||= company_by_id('P3b')
        end

        def fremont
          @fremont ||= company_by_id('P3c')
        end

        def dodge
          @dodge ||= company_by_id('P4a')
        end

        def lander
          @lander ||= company_by_id('P4c')
        end

        def casement
          @casement ||= company_by_id('P5a')
        end

        def foncier
          @foncier ||= company_by_id('P5b')
        end

        def pac_rr_a
          @pac_rr_a ||= company_by_id('P5c')
        end

        def strikebreakers_private
          @strikebreakers_private ||= company_by_id('P6a')
        end

        def strikebreakers_coal
          @strikebreakers_coal ||= @minors.find { |m| m.type == :coal && m.player == strikebreakers_private.player }
        end

        def teapot_dome_private
          @teapot_dome_private ||= company_by_id('P6b')
        end

        def teapot_dome_oil
          @teapot_dome_oil ||= @minors.find { |m| m.type == :oil && m.player == teapot_dome_private.player }
        end

        def no_bust
          @no_bust ||= company_by_id('P6c')
        end

        def big_boy_private
          @big_boy_private ||= company_by_id('P7')
        end

        def pure_oil
          @pure_oil ||= company_by_id('P8')
        end

        def lhp_private
          @lhp_private ||= company_by_id('P9')
        end

        def durant
          @durant ||= company_by_id('P10')
        end

        def ames_bros
          @ames_bros ||= company_by_id('P11')
        end

        def union_pacific_coal
          @union_pacific_coal ||= minor_by_id('UPC')
        end

        def bonanza
          @bonanza ||= minor_by_id('BZ')
        end

        def track_points_available(entity)
          return 0 unless (corporation = entity).corporation?

          p5_point = p5_company.owner == corporation ? 1 : 0
          TRACK_POINTS + p5_point - @track_points_used[corporation]
        end

        def tile_lays(entity)
          if (points = track_points_available(entity)) >= UPGRADE_POINT_COST
            { @round.num_laid_track => { lay: true, upgrade: true, cost: 0 } }
          elsif points == YELLOW_POINT_COST
            { @round.num_laid_track => { lay: true, upgrade: false, cost: 0 } }
          else
            []
          end
        end

        def spend_tile_lay_points(action)
          return unless (corporation = action.entity).corporation?

          points_used = action.tile.color == :yellow ? YELLOW_POINT_COST : UPGRADE_POINT_COST
          @track_points_used[corporation] += points_used
        end

        def action_processed(action)
          case action
          when Action::LayTile
            swap_color_and_stripes(action.hex.tile) if action.hex.name == WIND_RIVER_CANYON_HEX
          end
        end

        def isr_company_choices
          @isr_company_choices ||= COMPANY_CHOICES.transform_values do |company_ids|
            company_ids.map { |id| company_by_id(id) }
          end
        end

        def init_coal_companies
          @players.map.with_index do |player, index|
            coal_company = Engine::Minor.new(
              type: :coal,
              sym: "Coal-#{index + 1}",
              name: "#{player.name} Coal",
              logo: '1868_wy/coal',
              tokens: [],
              color: :black,
              abilities: [{ type: 'no_buy', owner_type: 'player' }],
            )
            coal_company.owner = player
            coal_company.float!
            coal_company
          end
        end

        def init_development_hexes
          @hexes.select do |hex|
            hex.tile.city_towns.empty? && hex.tile.offboards.empty?
          end
        end

        def operating_order
          coal = @coal_companies.sort_by { |m| @players.index(m.owner) }
          railroads = @corporations.select(&:floated?).sort
          coal + railroads
        end

        def setup_development_tokens
          logo = "/icons/1868_wy/coal-#{@phase.name}.svg"
          @coal_companies.each do |coal|
            coal.unplaced_tokens.each { |t| coal.tokens.delete(t) }
            (@phase.name == '2' ? 2 : 1).times do
              coal.tokens << Token.new(
                coal,
                price: 0,
                logo: logo,
                simple_logo: logo,
                type: :development,
              )
            end
          end
        end

        def available_coal_hex?(hex)
          (hex.tile.icons.count { |i| i.name.include?('coal') } < 2) && @development_hexes.include?(hex)
        end

        def place_development_token(action)
          entity = action.entity
          player = entity.player
          hex = action.hex
          token = action.token
          cost = action.cost

          player.spend(cost, @bank) if cost.positive?
          hex.place_token(token, logo: "1868_wy/coal-#{@phase.name}")

          cost_str = cost.positive? ? " for #{format_currency(cost)}" : ''
          @log << "#{player.name} places a Development Token on #{hex.name}#{cost_str}"

          increment_development_token_count(hex)
          @placed_development_tokens[@phase.name] << hex
        end

        def boomer?(tile)
          tile.city_towns.any?(&:boom)
        end

        def increment_development_token_count(tokened_hex)
          hexes = [tokened_hex].concat((0..5).map { |edge| hex_neighbor(tokened_hex, edge) })

          hexes.each do |hex|
            next unless hex
            next unless boomer?(hex.tile)

            @development_token_count[hex] += 1
            handle_boom!(hex)
          end
        end

        def handle_boom!(hex)
          case @development_token_count[hex]
          when DTC_BOOMCITY
            boomtown_to_boomcity!(hex)
          when DTC_REVENUE
            boomcity_increase_revenue!(hex)
          end
        end

        def boomtown_to_boomcity!(hex, gray_checked: false)
          tile = hex.tile

          unless tile.preprinted
            @log << "#{hex.name} #{location_name(hex.name)} is Booming! A Boomtown is replaced by a Boom City."
          end

          # auto-upgrade the preprinted tile
          if tile.preprinted
            boomtown = tile.towns.pop
            tile.city_towns.delete(boomtown)
            city = Engine::Part::City.new('0', boom: true, loc: boomtown.loc)
            city.tile = tile
            tile.cities << city
            tile.city_towns << city
            tile.rotate!(0) # reset tile rendering

          # auto-upgrade the tile
          else
            new_tile = boomcity_tile(tile.name)
            boom_bust_autoreplace_tile!(new_tile, tile)
          end
        end

        def boomcity_increase_revenue!(hex)
          # actual logic for increased revenue is handled in `revenue_for()`
          @log << "#{hex.name} #{location_name(hex.name)} is Booming! Its revenue "\
                  "increases by #{format_currency(BOOMING_REVENUE_BONUS)}."
        end

        def boom_bust_autoreplace_tile!(new_tile, tile)
          hex = tile.hex

          sorted_exits = tile.exits.sort
          (0..5).find do |rotation|
            new_tile.rotate!((tile.rotation + rotation) % 6)
            new_tile.exits.sort == sorted_exits
          end

          update_tile_lists(new_tile, tile)
          hex.lay(new_tile)
        end

        def boomcity_tile(tile_name)
          @tiles.find { |t| t.name == BOOMTOWN_TO_BOOMCITY_TILES[tile_name] && !t.hex }
        end

        def boomtown_tile(tile_name)
          @tiles.find { |t| t.name == BOOMCITY_TO_BOOMTOWN_TILES[tile_name] && !t.hex }
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return false unless boomer?(from) == boomer?(to)

          if (upgrades = TILE_UPGRADES[from.name])
            upgrades.include?(to.name)
          else
            super
          end
        end

        def revenue_for(route, stops)
          stops.sum do |stop|
            if stop.city? && stop.boom
              dtc = @development_token_count[stop.hex]
              next BUSTED_REVENUE[stop.hex.tile.color] if dtc < DTC_BOOMCITY

              gets_bonus = dtc >= DTC_REVENUE
            end

            stop.route_revenue(route.phase, route.train) + (gets_bonus ? BOOMING_REVENUE_BONUS : 0)
          end
        end

        def decrement_development_token_count(tokened_hex)
          hexes = [tokened_hex].concat((0..5).map { |edge| hex_neighbor(tokened_hex, edge) })

          hexes.each do |hex|
            next unless hex
            next unless @development_token_count[hex].positive?

            if (dtc = @development_token_count[hex]) >= DTC_BOOMCITY
              @busters[hex] ||= dtc
            end
            @development_token_count[hex] -= 1
          end
        end

        def handle_bust_preprinted_and_revenue!
          @busters.dup.each do |hex, original_dtc|
            next handle_bust_hex!(hex) if hex.tile.preprinted

            new_dtc = @development_token_count[hex]
            if (original_dtc >= DTC_REVENUE) && (new_dtc >= DTC_BOOMCITY)
              @log << "#{hex.name}) is Busting! Its revenue "\
                      "decreases by #{format_currency(BOOMING_REVENUE_BONUS)}."
            elsif new_dtc < DTC_BOOMCITY
              @log << "#{hex.name} #{location_name(hex.name)} is Busting! Its revenue "\
                      "drops to #{format_currency(BUSTED_REVENUE[hex.tile.color])}."
            end
          end
        end

        def bust_round!
          @log << "-- BUST Round #{@turn}.#{@round.round_num} (of 2) -- "

          @busters.dup.each do |hex, _original_dtc|
            next if hex.tile.preprinted

            handle_bust_hex!(hex)
          end
        end

        def handle_bust_hex!(hex)
          new_dtc = @development_token_count[hex]

          if !hex.tile.preprinted && new_dtc == DTC_GHOST_TOWN
            to_ghost_town!(hex)
          elsif new_dtc < DTC_BOOMCITY
            boomcity_to_boomtown!(hex)
          end

          @busters.delete(hex)
        end

        def busting_return_tokens!(hex, all_tokens: true)
          tokens =
            if all_tokens
              hex.tile.cities.first.tokens.compact
            else
              [hex.tile.cities.first.tokens[1]].compact
            end

          corporations = tokens.map do |token|
            token.remove!
            token.corporation.name
          end

          if corporations.empty?
            ''
          else
            @graph.clear
            dpr.coordinates = '' if corporations.include?(dpr) && dpr.tokens.count(&:used).zero?
            " Tokens are returned: #{corporations.map(&:name).join(' and ')}" unless corporations.empty?
          end
        end

        def to_ghost_town!(hex)
          log_str = "#{hex.name} #{location_name(hex.name)} Busts to a Ghost Town."
          log_str += busting_return_tokens!(hex)
          @log << log_str

          hex.location_name = GHOST_TOWN_NAME
          hex.tile.location_name = GHOST_TOWN_NAME

          gt_tile_name = GHOST_TOWN_TILE[hex.tile.name]
          gt_tile = @tiles.find { |t| t.name == gt_tile_name.to_s && !t.hex }

          boom_bust_autoreplace_tile!(gt_tile, hex.tile)

          @development_hexes << hex
        end

        def boomcity_to_boomtown!(hex)
          return unless hex.tile.cities.first&.boom

          if (tile = hex.tile).preprinted
            boomcity = tile.cities.pop
            tile.city_towns.delete(boomcity)
            boomtown = Engine::Part::Town.new('0', boom: true, loc: boomcity.loc)
            boomtown.tile = tile
            tile.towns << boomtown
            tile.city_towns << boomtown
            tile.rotate!(0) # reset tile rendering

          else
            log_str = "#{hex.name} #{location_name(hex.name)} Busts to a Boomtown."
            log_str += busting_return_tokens!(hex)
            @log << log_str

            tile = boomtown_tile(hex.tile.name)
            boom_bust_autoreplace_tile!(tile, hex.tile)
          end
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players(:first_to_pass, log_player_order: true)
              new_operating_round
            when G1868WY::Round::Operating
              if @round.round_num < @operating_rounds
                init_track_points
                bust_round!
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                init_track_points
                depot.export!
                bust_round!
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players(:most_cash, log_player_order: true)
              new_stock_round
            end
        end

        def player_value(player)
          player.value - player.companies.sum(&:value)
        end

        def issuable_shares(entity, previously_issued = 0)
          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.instance_of?(G1868WY::Step::IssueShares) }.active?

          max_size = @phase.name.to_i - (previously_issued || @round.issued)

          bundles_for_corporation(entity, entity).select do |bundle|
            @share_pool&.fit_in_bank?(bundle) && bundle.num_shares <= max_size && bundle.shares.all?(&:buyable)
          end
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.instance_of?(G1868WY::Step::IssueShares) }.active?

          bundles = bundles_for_corporation(share_pool, entity)

          if entity == union_pacific
            bundles.reject! { |bundle| (entity.cash < bundle.price) || bundle.shares.find { |s| s.id == UP_DOUBLE_SHARE } }
          else
            bundles.reject! { |bundle| entity.cash < bundle.price }
          end

          bundles
        end

        def total_emr_buying_power(player, corporation)
          emergency = (issuable = emergency_issuable_cash(corporation)).zero?
          corporation.cash + issuable + liquidity(player, emergency: emergency)
        end

        def emergency_issuable_bundles(corp)
          return [] if corp.trains.any?

          train = @depot.min_depot_train
          _min_train_price, max_train_price = train.variants.map { |_, v| v[:price] }.minmax
          return [] if corp.cash >= max_train_price

          issuable_shares(corp)
        end

        def sellable_bundles(player, corporation)
          bundles = super

          unless corporation.operated?
            bundles.each do |bundle|
              directions = [:down] * bundle.num_shares
              bundle.share_price = stock_market.find_share_price(corporation, directions).price
            end
          end

          bundles
        end

        def after_par(corporation)
          return if corporation.id != 'LNP' && corporation.id != 'OSL'

          hex = hex_by_id(corporation.coordinates)
          old_tile = hex.tile
          return if old_tile.color == :green || old_tile.color == :brown

          green_tile = tile_by_id("G#{old_tile.label}-0")
          update_tile_lists(green_tile, old_tile)
          hex.lay(green_tile)
          @log << "#{corporation.name} lays tile #{green_tile.name} on #{hex.id} (#{old_tile.location_name})"
        end

        def can_par?(corporation, _parrer)
          return false unless super

          corporation == dpr ? !home_token_locations(corporation).empty? : true
        end

        def home_token_locations(corporation)
          if corporation == dpr
            hexes.select do |hex|
              hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
            end
          else
            [hex_by_id(corporation.coordinates)]
          end
        end

        def skip_homeless_dpr?(entity)
          entity == dpr && entity.tokens.count(&:used).zero?
        end

        def token_owner(entity)
          if entity == dpr.player && dpr.floated? && dpr.tokens.count(&:used).zero? && !home_token_locations(dpr).empty?
            dpr
          else
            super
          end
        end

        def double_head_candidates(corporation)
          corporation.trains.reject do |train|
            train.operated || train.obsolete
          end
        end

        def find_and_remove_train_by_id(train_id, buyable: true)
          train = train_by_id(train_id)
          @depot.remove_train(train)
          train.buyable = buyable
          train.reserved = true
          train
        end

        def update_trains_cache
          update_cache(:trains)
        end

        def attach_big_boy(train, entity)
          detached = detach_big_boy(log: false)

          @big_boy_train_original = train.dup
          cities, towns = distance(train).map(&:succ)
          train.name = "[#{cities}+#{towns}]"
          train.distance = [
            {
              'nodes' => ['town'],
              'pay' => towns,
              'visit' => towns,
            },
            {
              'nodes' => %w[city offboard town],
              'pay' => cities,
              'visit' => cities,
            },
          ]
          @big_boy_train = train

          @log <<
            if detached
              "#{entity.name} moves the [+1+1] token from a #{detached.name} "\
                "train to a #{@big_boy_train_original.name} train, forming a #{train.name} train"
            else
              "#{entity.name} attaches the [+1+1] token to a #{@big_boy_train_original.name} "\
                "train, forming a #{train.name} train"
            end

          @big_boy_train
        end

        def detach_big_boy(log: false)
          return unless @big_boy_train

          train = @big_boy_train_original

          @log << "The [+1+1] token is detached from the #{train.name} train" if log

          @big_boy_train.name = train.name
          @big_boy_train.distance = train.distance

          cleanup_big_boy

          train
        end

        def rust_trains!(train, _entity)
          detach_big_boy if train.sym == @big_boy_train&.rusts_on
          super
        end

        def cleanup_big_boy
          @big_boy_train_original = nil
          @big_boy_train = nil
        end

        def buy_train(operator, train, price = nil)
          detach_big_boy(log: true) if train == big_boy_train
          super
        end

        def abilities(entity, type = nil, **kwargs)
          if type == :exchange
            return unless entity == ames_bros
            return unless active_step.is_a?(G1868WY::Step::StockRoundAction)
            return if active_step.sold? || active_step.bought? || active_step.tokened?
          end

          super
        end

        def bundles_for_corporation(share_holder, corporation, shares: nil)
          return [] unless corporation.ipoed

          shares = (shares || share_holder.shares_of(corporation)).sort_by { |h| [h.president ? 1 : 0, h.percent] }

          bundles = shares.flat_map.with_index do |share, index|
            bundle = shares.take(index + 1)
            percent = bundle.sum(&:percent)
            bundles = [Engine::ShareBundle.new(bundle, percent)]
            bundles.concat(partial_bundles_for_presidents_share(corporation, bundle, percent)) if share.president
            bundles
          end

          # handle the UP double share
          if corporation == union_pacific && shares.include?(up_double_share)
            # player may swap with a normal share in the market to sell only 10%
            # of the double share
            if share_holder.player? && (10..40).cover?(@share_pool.percent_of(union_pacific))
              bundles << up_double_share.to_bundle(10)
            end

            # double share may be sold by player or bought directly from UP
            # treasury while other shares are present (but may not be bought
            # from the market if other shares are there)
            bundles << up_double_share.to_bundle if shares.size > 1 && share_holder != @share_pool
          end

          bundles.sort_by(&:percent)
        end

        def event_close_ames_brothers!
          return if ames_bros.closed?

          player = ames_bros.owner
          cash = union_pacific.share_price.price * 2
          @log << "Company #{ames_bros.name} closes."
          @log << "#{player.name} exchanges the #{ames_bros.id} certificate for the Ames Brothers "\
                  "20% share of UP, and UP receives #{format_currency(cash)} from the bank"

          up_double_share.buyable = true
          @share_pool.buy_shares(player, up_double_share, exchange: :free, allow_president_change: true, silent: true)
          @bank.spend(cash, union_pacific)
          ames_bros.close!
        end

        def before_sell_up(bundle)
          return unless (corporation = bundle.corporation) == union_pacific
          return unless corporation.president?(president = bundle.owner)
          return unless (double_holder = up_double_share.owner).player?
          return if president == double_holder

          {
            president: president,
            double_holder: double_holder,
            share_price: corporation.share_price,
            num_shares: bundle.num_shares,
            bundle_share_price: bundle.share_price,
          }
        end

        def after_sell_up(bundle, before)
          return unless before
          return unless (president = union_pacific.owner) == before[:double_holder]
          return unless up_double_share.owner == @share_pool

          singles = {
            president: president.shares_of(union_pacific).reject(&:president),
            share_pool: @share_pool.shares_of(union_pacific).reject(&:double_cert),
          }
          return if singles.values.sum(&:size) < 2

          # if the player who held the double share chooses to protect, they buy
          # `num_buyable` shares and the price becomes `share_price`; if the UP
          # dump happened on/near a ledge, protection might not increase the
          # price
          num_buyable = [2 - singles[:president].size, 0].max
          return if president.cash < (before[:share_price].price * num_buyable)

          net_sold = before[:num_shares] - num_buyable
          share_price = @stock_market.find_relative_share_price(before[:share_price], [:up] * net_sold)

          after = {
            president: president,
            num_buyable: num_buyable,
            share_price: share_price,
          }

          # if shares will be bought from the pool to protect the double share,
          # the price will increase and the net drop from selling shares will be
          # lessened; therefore, if the president sold the shares before UP
          # operated, they will be owed additional cash since pre-operational shares
          # are sold at their final share price, and the true final price will
          # not be reached until after the double share is protected
          if before[:bundle_share_price] == union_pacific.share_price.price
            price_delta = share_price.price - before[:bundle_share_price]
            cash = price_delta * bundle.num_shares
            after[:cash] = cash if cash.positive?
          end

          after
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
          before = before_sell_up(bundle)
          super
          return unless (after = after_sell_up(bundle, before))

          @up_double_share_protection = {
            prev_president: before[:president],
            player: after[:president],
            num_buyable: after[:num_buyable],
            buy_at_price: before[:share_price],
            new_price: after[:share_price],
            cash: after[:cash],
          }

          swap_up_double_share_and_presidency!
        end

        def swap_up_double_share_and_presidency!
          old_pres = up_presidency.owner
          old_double = up_double_share.owner

          share_pool.move_share(up_presidency, old_double)
          share_pool.move_share(up_double_share, old_pres)
          union_pacific.owner = old_double
        end

        def up_protection_player_bundle
          return unless @up_double_share_protection[:num_buyable] < 2

          player = @up_double_share_protection[:player]
          shares = player.shares_of(union_pacific).reject(&:double_cert)
          Engine::ShareBundle.new(shares)
        end

        def billings_hex?(hex)
          self.class::BILLINGS_HEXES.include?(hex.id)
        end

        def other_billings(hex)
          return unless (index = self.class::BILLINGS_HEXES.index(hex.id))

          hex_by_id(self.class::BILLINGS_HEXES[(index + 1) % 2])
        end

        def event_close_privates!
          case @phase.name
          when '5'
            event_close_ames_brothers!
          when '8'
            event_close_big_boy!
          end
        end
      end
    end
  end
end
