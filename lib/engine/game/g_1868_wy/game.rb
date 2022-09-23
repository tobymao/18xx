# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'trains'
require_relative 'step/buy_company'
require_relative 'step/buy_sell_par_shares'
require_relative 'step/buy_train'
require_relative 'step/company_pending_par'
require_relative 'step/development_token'
require_relative 'step/dividend'
require_relative 'step/route'
require_relative 'step/token'
require_relative 'step/track'
require_relative 'step/waterfall_auction'
require_relative '../base'
require_relative '../company_price_up_to_face'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G1868WY
      class Game < Game::Base
        include_meta(G1868WY::Meta)
        include Entities
        include Map
        include Trains

        include CompanyPriceUpToFace
        include StubsAreRestricted

        BANK_CASH = 99_999
        STARTING_CASH = { 3 => 734, 4 => 550, 5 => 440 }.freeze
        CERT_LIMIT = { 3 => 20, 4 => 15, 5 => 12 }.freeze

        SELL_AFTER = :any_time
        POOL_SHARE_DROP = :each
        CAPITALIZATION = :incremental
        SELL_BUY_ORDER = :sell_buy
        HOME_TOKEN_TIMING = :par
        NEXT_SR_PLAYER_ORDER = :first_to_pass

        TRACK_POINTS = 6
        YELLOW_POINT_COST = 2
        UPGRADE_POINT_COST = 3

        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        MUST_BUY_TRAIN = :always

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

        MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'company starting values',
                                              par_1: 'additional starting values in phase 3+',
                                              par_2: 'additional starting values in phase 5+').freeze

        LATE_CORPORATIONS = %w[C&N DPR LNP OSL].freeze
        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'all_corps_available' => ['All Corporations Available',
                                    'C&N, DPR, LNP, OSL are now available to start'],
          'full_capitalization' => ['Full Capitalization',
                                    'Railroads now float at 60% and receive full capitalization'],
          'rust_coal_dt_2' => ['Remove Phase 2 Coal DTs', 'Remove Phase 2 Coal Development Tokens'],
          'rust_coal_dt_3' => ['Remove Phase 3 Coal DTs', 'Remove Phase 3 Coal Development Tokens'],
          'rust_coal_dt_4' => ['Remove Phase 4 Coal DTs', 'Remove Phase 4 Coal Development Tokens'],
          'rust_coal_dt_5' => ['Remove Phase 5 Coal DTs', 'Remove Phase 5 Coal Development Tokens'],
          'rust_coal_dt_6' => ['Remove Phase 6 Coal DTs', 'Remove Phase 6 Coal Development Tokens'],
          'green_par' => ['Green Par Available', 'Railroads may now par at 90 or 100.'],
          'brown_par' => ['Brown Par Available', 'Railroads may now par at 110 or 120.'],
        ).freeze
        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'all_corps_available' => ['All Corporations Available',
                                    'C&N, DPR, LNP, OSL are available to start'],
          'full_capitalization' =>
            ['Full Capitalization', 'Railroads float at 60% and receive full capitalization'],
        ).freeze

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

          setup_event_methods

          @development_hexes = init_development_hexes
          @development_token_count = Hash.new(0)
          @placed_development_tokens = Hash.new { |h, k| h[k] = [] }
          @busters = {}

          @late_corps, @corporations = @corporations.partition { |c| LATE_CORPORATIONS.include?(c.id) }
          @late_corps.each { |corp| corp.reservation_color = nil }

          @coal_companies = init_coal_companies
          @minors.concat(@coal_companies)
          update_cache(:minors)

          @available_par_groups = %i[par]
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G1868WY::Step::BuySellParShares,
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
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G1868WY::Step::BuyCompany,
            G1868WY::Step::Track,
            G1868WY::Step::Token,
            G1868WY::Step::Route,
            G1868WY::Step::Dividend,
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
          p9_company.close!
          @log << "#{p9_company.name} closes"
        end

        def event_all_corps_available!
          @late_corps.each { |corp| corp.reservation_color = CORPORATION_RESERVATION_COLOR }
          @corporations.concat(@late_corps)
          @log << '-- All corporations now available --'
        end

        def event_full_capitalization!
          @log << '-- Event: Railroads now float at 60% and receive full capitalization --'
          @corporations.each do |corporation|
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

        def setup_event_methods
          (2..6).each do |phase|
            self.class.define_method("event_remove_coal_dt_#{phase}!") do
              event_remove_coal_dt!(phase.to_s)
            end
          end
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

        def float_corporation(corporation)
          if @phase.status.include?('full_capitalization')
            bundle = ShareBundle.new(corporation.shares_of(corporation))
            @share_pool.transfer_shares(bundle, @share_pool)
            @log << "#{corporation.name}'s remaining shares are transferred to the Market"
          end

          super

          corporation.capitalization = :incremental
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

        def p1_company
          @p1_company ||= company_by_id('P1')
        end

        def p5_company
          @p5_company ||= company_by_id('P5')
        end

        def p8_company
          @p8_company ||= company_by_id('P8')
        end

        def p9_company
          @p9_company ||= company_by_id('P9')
        end

        def p10_company
          @p10_company ||= company_by_id('P10')
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
            if action.hex.name == 'G15'
              action.hex.tile.color = :gray
              @log << 'Wind River Canyon turns gray; it can never be upgraded'
            end
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
            " Tokens are returned: #{corporations.join(' and ')}" unless corporations.empty?
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
          return unless corporation.id == 'LNP' || corporation.id == 'OSL'

          hex = hex_by_id(corporation.coordinates)
          old_tile = hex.tile
          return if old_tile.color == :green || old_tile.color == :brown

          green_tile = tile_by_id("G#{old_tile.label}-0")
          update_tile_lists(green_tile, old_tile)
          hex.lay(green_tile)
          @log << "#{corporation.name} lays tile #{green_tile.name} on #{hex.id} (#{old_tile.location_name})"
        end
      end
    end
  end
end
