# frozen_string_literal: true

require_relative 'credit_mobilier'
require_relative 'entities'
require_relative 'golden_spike'
require_relative 'map'
require_relative 'meta'
require_relative 'oil_companies'
require_relative 'share_pool'
require_relative 'trains'
require_relative 'round/bust'
require_relative 'round/development'
require_relative 'round/operating'
require_relative 'step/assign'
require_relative 'step/buy_company'
require_relative 'step/buy_train'
require_relative 'step/choose'
require_relative 'step/company_pending_par'
require_relative 'step/development_token'
require_relative 'step/discard_train'
require_relative 'step/dividend'
require_relative 'step/double_share_protection'
require_relative 'step/home_token'
require_relative 'step/issue_shares'
require_relative 'step/manual_close_company'
require_relative 'step/route'
require_relative 'step/special_track'
require_relative 'step/stock_round_action'
require_relative 'step/token'
require_relative 'step/track'
require_relative 'step/waterfall_auction'
require_relative '../base'
require_relative '../company_price_up_to_face'
require_relative '../double_sided_tiles'
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
        include OilCompanies

        # Engine::Game includes
        include CompanyPriceUpToFace
        include DoubleSidedTiles
        include StubsAreRestricted
        include SwapColorAndStripes

        attr_accessor :big_boy_first_chance, :double_headed_trains, :dpr_first_home_status,
                      :placed_oil_dt_count, :up_double_share_protection
        attr_reader :big_boy_train, :big_boy_train_original, :tile_groups, :unused_tiles,
                    :busters

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
        GAME_END_CHECK = { bankrupt: :immediate, custom: :one_more_full_or_set }.freeze
        GAME_END_REASONS_TEXT = {
          bankrupt: 'player is bankrupt',
          custom: '7-train is bought/exported',
        }.freeze
        GAME_END_REASONS_TIMING_TEXT = {
          immediate: "Immediately, bankrupt player's score is $0",
          one_more_full_or_set: 'see the "Endgame Sequence" timeline',
        }.freeze
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
          remove_forts: ['Remove Forts', 'Remove forts whose color matches the previous phase'],
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

        # rounds
        DEVELOPMENT_ROUND_NAME = 'Development'
        PRIVATES_ROUND_NAME = 'Privates Pay'

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
        BOOMCITY_REVENUES = {
          yellow: [10, 20, 30],
          green: [10, 30, 40],
          brown: [20, 40, 50],
          gray: [20, 50, 60],
        }.freeze
        BOOMCITY_DEFAULT_REVENUES_TO_RENDER = {
          yellow: [[['#FFFFFF', 10], [:yellow, 20], [:black, 30]]],
          green: [[['#FFFFFF', 10], [:green, 30], [:black, 40]]],
          brown: [[['#FFFFFF', 20], [:brown, 40], [:black, 50]]],
          gray: [[['#FFFFFF', 20], [:gray, 50], [:black, 60]]],
        }.freeze
        BOOMTOWN_REVENUES = {
          yellow: 10,
          green: 10,
          brown: 20,
          gray: 20,
        }.freeze
        COAL_TOKENS = {
          '2' => 4,
          '3' => 3,
          '4' => 3,
          '5' => 3,
          '6' => 2,
          '7' => 2,
        }.freeze
        COAL_COMPANY_NAMES = [
          'Wyoming Coal and Mining Company',
          'Carbon County Coal Company',
          'Dietz Fuel Company',
          'Powder River Coal Company',
          'Owl Creek Coal Company',
        ].freeze
        LETTERS = ('A'..'E').to_a
        URANIUM_HEXES = {
          '5' => %w[J12 J20],
          '6' => %w[J12],
          '7' => %w[J12 J20],
        }.freeze

        # special hexes
        BILLINGS_HEXES = %w[A9 A11].freeze
        CASPER_HEX = 'H18'
        FEMV_HEX = 'G27'
        CM_BORDER_HEXES = %w[L2 M3 M7 M9 J16 J18].freeze
        JEFFREY_CITY_HEX = 'J12'
        RCL_HEX = 'C27'
        SHIRLEY_BASIN_HEX = 'J20'
        WALDEN_HEX = 'N18'
        WIND_RIVER_CANYON_HEX = 'F12'
        YELLOWSTONE_HEXES = %w[C5 D4].freeze
        FORT_HEXES = %w[
          A23
          C17
          E19
          G21
          G5
          H18
          J26
          K17
          L4
        ].freeze
        FT_KEOGH_HEX = FORT_HEXES.first

        # special shares
        UP_PRESIDENTS_SHARE = 'UP_0'
        UP_DOUBLE_SHARE = 'UP_7'

        # privates
        ASSIGNMENT_TOKENS = {
          'P6c' => '/icons/1868_wy/no_bust.svg',
          'P8' => '/icons/1868_wy/pure_oil.svg',
        }.freeze
        PURE_OIL_CAMP_TILES = {
          '7' => '5b',
          '8' => '6b',
          '9' => '57b',
          '14' => '14b',
          '17' => '14b',
          '20' => '14b',
          '626' => '14b',
          '15' => '15b',
          '16' => '15b',
          '18' => '15b',
          '625' => '15b',
          '19' => '619b',
          '21' => '619b',
          '22' => '619b',
          '619' => '619b',
        }.freeze

        TOKEN_PRICES_AFTER_BUST = [80, 60, 40].freeze

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def setup
          init_track_points
          @companies.each do |company|
            company.min_price = 0
            company.max_price = 0
          end

          @development_token_count = init_development_hexes
          @placed_development_tokens = Hash.new { |h, k| h[k] = [] }
          @placed_oil_dt_count = Hash.new(0)
          @busters = {}
          @teapot_dome_hex_bonus = nil

          setup_credit_mobilier

          @coal_companies = init_coal_companies
          @coal_companies << init_union_pacific_coal
          @minors.concat(@coal_companies)
          @oil_companies = init_oil_companies
          @oil_companies << init_bonanza
          @minors.concat(@oil_companies)
          update_cache(:minors)

          @p3_dt_hex = nil

          @all_corps_available = false
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

          @pure_oil_hex = nil

          @lhp_train = find_and_remove_train_by_id('2+1-0', buyable: false)
          @lhp_train_pending = false

          setup_spikes

          @endgame_triggered = false
          @final_stock_round_started = false

          @big_boy_first_chance = false

          @tile_groups = self.class::TILE_GROUPS
          initialize_tile_opposites!
          @unused_tiles = []

          unless @optional_rules.include?(:p2_p6_choice)
            removals = COMPANY_CHOICES.keys
            COMPANY_CHOICES.each do |_, companies|
              removals.concat(companies.sort_by { rand }.take(2))
            end

            @companies.reject! do |c|
              next unless removals.include?(c.id)

              @round.active_step.companies.delete(c)
              c.close!
              true
            end

            @log << 'Available P2-P6 companies:'
            @companies.slice(1, 5).map(&:name).each do |company|
              @log << "- #{company}"
            end
          end

          @forts = setup_forts!
        end

        def setup_forts!
          colors = %i[yellow yellow green green green green green brown brown].sort_by { rand }
          FORT_HEXES.zip(colors).each.with_object({}) do |(hex_id, color), forts|
            hex_by_id(hex_id).tile.icons <<
              Part::Icon.new("1868_wy/fort_#{color}", 'fort', true, false,
                             large: hex_id != FT_KEOGH_HEX)
            forts[hex_id] = color
          end
        end

        def event_remove_forts!
          color = @phase.tiles[-2]

          removed = FORT_HEXES.each.with_object([]) do |hex_id, rm|
            next unless color == @forts[hex_id]

            # remove "Ft. ___" from the location name for cities with another
            # name, and otherwise blank tiles; keep it for towns
            hex = hex_by_id(hex_id)
            tile = hex.tile
            new_name =
              if tile.city_towns.empty? && tile.offboards.empty?
                nil
              elsif (name = tile.location_name).include?(' / ')
                name.split(' / ').last
              end
            if new_name
              hex.location_name = new_name
              tile.location_name = new_name
            end

            tile.icons.reject! { |icon| icon.name == 'fort' }
            @forts.delete(hex_id)
            rm <<
              if new_name
                "#{hex_id} (#{new_name})"
              else
                hex_id
              end
          end

          @log << "-- Event: #{color} forts are removed from #{removed.join(', ')} --"
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
            G1868WY::Step::DiscardTrain,
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

        def payout_companies(payout = false, ignore: [])
          super(ignore: ignore) if payout
        end

        def new_privates_round(round_num)
          return if @phase.name == '8'

          @log << "-- #{round_description('Privates Pay', round_num)} --"
          payout_companies(true)
        end

        def new_development_round(round_num = 1)
          new_privates_round(round_num)

          @log << "-- #{round_description(self.class::DEVELOPMENT_ROUND_NAME, round_num)} --"
          @round_counter += 1
          development_round(round_num)
        end

        def development_round(round_num)
          G1868WY::Round::Development.new(self, [
            G1868WY::Step::Assign,
            G1868WY::Step::DevelopmentToken,
          ], round_num: round_num)
        end

        def new_operating_round(round_num = 1)
          @log << "-- #{round_description(self.class::OPERATING_ROUND_NAME, round_num)} --"
          operating_round(round_num)
        end

        def operating_round(round_num)
          G1868WY::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G1868WY::Step::SpecialTrack,
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
            G1868WY::Step::DiscardTrain,
            G1868WY::Step::BuyTrain,
            [G1868WY::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def new_bust_round(round_num)
          @log << "-- #{round_description('BUST', round_num)} --"
          bust_round(round_num)
        end

        def bust_round(round_num)
          G1868WY::Round::Bust.new(self, [
            G1868WY::Step::Assign,
          ], round_num: round_num)
        end

        def resolve_busters!
          @busters.dup.each do |hex, _original_dtc|
            handle_bust_hex!(hex) unless hex.tile.preprinted
          end
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1868WY::Step::CompanyPendingPar,
            G1868WY::Step::WaterfallAuction,
          ])
        end

        def init_round_finished
          if (player = upc_private.player)
            minor = union_pacific_coal
            minor.owner = player
            minor.float!
          else
            close_corporation(union_pacific_coal)
          end
          if (player = bonanza_private.player)
            minor = bonanza
            minor.owner = player
          else
            close_corporation(bonanza)
          end
          up_double_share.buyable = true unless ames_bros.player

          durant.close!
          @log << "#{durant.name} closes"
        end

        def event_all_corps_available!
          @log << '-- All Railroad Companies now available --'
          @all_corps_available = true
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

        def event_close_upc!
          if (token = union_pacific_coal.tokens.find(&:used))
            @log << "-- Event: UP Development Token is removed from #{token.hex.name} --"
            destroy_development_token!(token)
          end
          @minors.delete(union_pacific_coal)
          union_pacific_coal.close!
        end

        def event_close_bonanza!
          if (token = bonanza.tokens.find(&:used))
            @log << "-- Event: BZ Oil Development Token is removed from #{token.hex.name} --"
            destroy_development_token!(token)
          end
          @minors.delete(bonanza)
          bonanza.close!
        end

        def par_prices
          @stock_market.share_prices_with_types(@available_par_groups)
        end

        def event_remove_placed_coal_dt!
          coal_phase_name = "coal-#{@phase.name.to_i - 2}"
          @log << "-- Event: Phase #{coal_phase_name} Coal Development Tokens are removed from the map --"
          @coal_companies.each do |company|
            company.tokens.dup.each do |token|
              destroy_development_token!(token, handle_bust: false) if token.used && token.logo.include?(coal_phase_name)
            end
          end

          handle_bust!
        end

        def event_remove_unplaced_coal_dt!
          coal_phase_name = "coal-#{@phase.name.to_i - 1}"
          @coal_companies.each do |company|
            company.tokens.dup.each do |token|
              token.destroy! if token && !token.used && token.logo.include?(coal_phase_name)
            end
          end
        end

        def event_uranium_boom!
          hex_ids = URANIUM_HEXES[@phase.name]
          case @phase.name
          when '5'
            @log << '-- Event: Uranium is Booming! J12 Jeffrey City and J20 Shirley Basin '\
                    'receive a Uranium Development Token and +$20 revenue --'
          when '6'
            @log << '-- Event: Uranium is Booming! J12 Jeffrey City receives a '\
                    'Uranium Development Token and +$20 revenue --'
          end

          hex_ids.each do |hex_id|
            hex = hex_by_id(hex_id)
            hex.tile.icons.find.with_index do |icon, index|
              hex.tile.icons[index] = Part::Icon.new('1868_wy/uranium', nil, true, false, false) if icon.name == 'uranium_early'
            end
            increment_development_token_count(hex)
          end
        end

        def event_uranium_bust!
          @log << '-- Event: Uranium BUSTS! --'
          hex_ids = URANIUM_HEXES[@phase.name]

          hex_ids.each do |hex_id|
            hex = hex_by_id(hex_id)

            is_uranium = ->(icon) { icon.name == 'uranium' }
            count = hex.tile.icons.count(&is_uranium)
            hex.tile.icons.reject!(&is_uranium)

            to_ghost_town!(hex)

            count.times { decrement_development_token_count(hex) }
          end
        end

        def event_trigger_endgame!
          @log << '-- Event: Endgame triggered --'
          @log << 'Finish this OR; the endgame round sequence is described in the Timeline section of the Info tab'
          @endgame_triggered = true
          @operating_rounds = @round.round_num
          @final_turn = @turn + 1
        end

        def event_close_pure_oil!
          @log << "Company #{pure_oil.name} closes"
          pure_oil.close!
          @pure_oil_hex&.remove_assignment!(pure_oil.id)
          to_ghost_town!(@pure_oil_hex)
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

          upgrade_home(corporation)

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

        def custom_end_game_reached?
          @endgame_triggered
        end

        def init_track_points
          @track_points_used = Hash.new(0)
        end

        def status_array(corporation)
          statuses = []

          if corporation.floated?
            if corporation.minor? && corporation != union_pacific_coal && corporation != bonanza
              player = corporation.owner
              statuses << strikebreakers_status if corporation.type == :coal && player == strikebreakers_private.owner
              statuses << 'P3c Frémont discount: $20' if player == fremont.owner
              statuses << 'P5c RR Act discount: 50%' if player == pac_rr_a.owner
            elsif @round.is_a?(G1868WY::Round::Operating) && corporation.corporation?
              statuses << "Track Points: #{track_points_available(corporation)}"
            end
          elsif !@all_corps_available && (stack = @corp_stacks.find { |s| s.last == corporation }) && stack.size > 1
            statuses << "Next: #{stack.map(&:name).reverse.slice(1, 4).join(', ')}"
          end

          if corporation == dpr
            if dpr_first_home_status == :placed && dpr.tokens.count(&:used).zero? && !home_token_locations(corporation).empty?
              statuses << 'Choose new home as an SR action'
            elsif !dpr_first_home_status && home_token_locations(corporation).empty?
              statuses << 'Cannot par: no home token location available'
            end
          end

          statuses.empty? ? nil : statuses
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

          TRACK_POINTS - @track_points_used[corporation]
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
          return if !action.entity.corporation? && action.entity != lander

          corporation = action.entity.corporation
          points_used = action.tile.color == :yellow ? YELLOW_POINT_COST : UPGRADE_POINT_COST
          @track_points_used[corporation] += points_used
        end

        def preprocess_action(action)
          case action
          when Action::LayTile
            @border_before = action.hex.tile.borders.first if CM_BORDER_HEXES.include?(action.hex.name)
          end
        end

        def action_processed(action)
          case action
          when Action::LayTile
            if action.hex.name == WIND_RIVER_CANYON_HEX
              swap_color_and_stripes(action.hex.tile)
            else
              @border_after = action.hex.tile.borders.first if @border_before
              credit_mobilier_check_tile_lay_action(action)
              foncier_check_tile_lay_action(action)

              if @forts.include?(action.hex.id) && action.tile.color == :yellow
                icon = action.tile.icons.find { |i| i.name == 'fort' }
                icon.large = false
              end
            end
            update_boomcity_revenue!(action.hex.tile)
          when Action::HexToken
            if @forts.include?(action.hex.id) && action.hex.tile.color == :white
              icon = action.hex.tile.icons.find { |i| i.name == 'fort' }
              icon.large = false
            end
          end
        end

        def update_boomcity_revenues!(new_tile, old_tile)
          reset_boomcity_revenue!(old_tile)
          update_boomcity_revenue!(new_tile)
        end

        def reset_boomtown_revenue!(tile, town)
          town.revenue.each do |color, _rev|
            town.revenue[color] = BOOMTOWN_REVENUES[tile.color]
          end

          tile.revenue_to_render = [BOOMTOWN_REVENUES[tile.color]]
        end

        def update_boomtown_revenue!(tile, town)
          return unless (u_bonus = uranium_bonus(@phase.name, tile.hex)).positive?

          town.revenue.each do |color, _rev|
            town.revenue[color] = BOOMTOWN_REVENUES[tile.color] + u_bonus
          end
        end

        def reset_boomcity_revenue!(tile)
          return if tile.color == :white
          if (town = tile.towns.first)&.boom
            return reset_boomtown_revenue!(tile, town)
          end
          return unless tile.cities.first&.boom

          tile.revenue_to_render = BOOMCITY_DEFAULT_REVENUES_TO_RENDER[tile.color]
        end

        def update_boomcity_revenue!(tile)
          return if tile.color == :white
          if (town = tile.towns.first)&.boom
            return update_boomtown_revenue!(tile, town)
          end
          return unless (city = tile.cities.first)&.boom

          rev_colors =
            if (u_bonus = uranium_bonus(@phase.name, tile.hex)).positive?
              %i[yellow yellow yellow]
            else
              %i[gray gray gray]
            end

          boom_index =
            case @development_token_count[city.hex]
            when (0..2)
              0
            when 3
              1
            else
              2
            end
          rev_colors[boom_index] = '#FFFFFF'

          rev_values = BOOMCITY_REVENUES[tile.color].map { |rev| rev + u_bonus }

          city.revenue = city.parse_revenue(rev_values[boom_index].to_s)
          tile.revenue_to_render = [rev_colors.zip(rev_values)]
        end

        def isr_company_choices
          @isr_company_choices ||= COMPANY_CHOICES.transform_values do |company_ids|
            company_ids.map { |id| company_by_id(id) }
          end
        end

        def init_corporations(stock_market)
          corporations = game_corporations.map do |corporation|
            Corporation.new(
              min_price: stock_market.par_prices.map(&:price).min,
              capitalization: self.class::CAPITALIZATION,
              **corporation.merge(corporation_opts),
            )
          end

          @corp_stacks = init_stacks(corporations.slice(1, 9))

          @log << 'The Railroad Companies (other than UP) have been split it into two stacks. '\
                  'Before phase 5, only the first Railroad Company in a stack may be started. DPR is '\
                  'guaranteed to be at the bottom of a stack.'
          corp_stacks_str_arr(@log)

          corporations.sort
        end

        # setup process:
        #
        # 1) set aside DPR
        # 2) shuffle the other 8 corporations, place them on top of DPR
        # 3) take the top 4 or 5 corporations into a second stack
        #
        # during play only the top (end of array) corporation from either stack
        # may be started
        def init_stacks(corporations)
          dpr, *shuffled = corporations
          shuffled.sort_by! { rand }
          corps = [dpr, *shuffled]

          stacks = [4, 5]
          stacks.sort_by! { rand }
          size1, size2 = stacks

          [
            corps.slice(0, size1),
            corps.slice(size1, size2),
          ]
        end

        # extends the given array with the string representation of the
        # corporation stacks
        def corp_stacks_str_arr(arr = [])
          @corp_stacks.each.with_index do |stack, index|
            arr << "- Railroad Company stack #{index + 1}: #{stack.map(&:name).reverse.join(', ')}" unless stack.empty?
          end
          arr
        end

        def sr_visible_corporations
          return sorted_corporations if @all_corps_available

          [*corporations.select(&:ipoed).sort, *@corp_stacks.flat_map(&:last).compact]
        end

        def timeline
          timeline = []
          unless @all_corps_available
            timeline << 'Before phase 5, only the first Railroad Company in a stack may be started:'
            corp_stacks_str_arr(timeline)
          end

          timeline << round_timeline unless @endgame_triggered
          timeline << endgame_timeline

          timeline
        end

        def init_coal_companies
          @players.map.with_index do |player, index|
            coal_company = Engine::Minor.new(
              type: :coal,
              sym: "Coal-#{self.class::LETTERS[index]}",
              name: self.class::COAL_COMPANY_NAMES[index],
              logo: '1868_wy/coal',
              tokens: [],
              color: :black,
              abilities: [{ type: 'no_buy', owner_type: 'player' }],
            )
            add_coal_development_tokens(coal_company)
            coal_company.owner = player
            coal_company.float!

            def coal_company.cash
              player.cash
            end

            coal_company
          end
        end

        def round_timeline
          @round_timeline ||=
            begin
              rounds = %w[
                SR
                Privates
                DEV
                OR
                Privates
                DEV
                OR
                Export
                BUST
              ]
              "Round Sequence: #{rounds.join(' - ')}"
            end
        end

        def endgame_timeline
          @endgame_timeline ||=
            begin
              endgame = [
                '7-train purchase*/export',
                'BUST',
                'SR',
                'Privates',
                'DEV',
                'OR',
                'Export',
                'BUST',
                'Privates',
                'DEV',
                'OR',
                'Export',
                'BUST',
                'DEV',
                'OR',
                'Game End',
              ]

              "Endgame Sequence: #{endgame.join(' - ')} (*if 7-train is purchased in OR 1 of 2, skip OR 2)"
            end
        end

        def init_union_pacific_coal
          @union_pacific_coal = Engine::Minor.new(
            type: :coal,
            sym: 'UPC',
            name: 'Union Pacific Coal',
            logo: '1868_wy/coal-up',
            tokens: [],
            color: :black,
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          )

          logo = '/icons/1868_wy/coal-up.svg'
          token = Token.new(
            @union_pacific_coal,
            price: 0,
            logo: logo,
            simple_logo: logo,
            type: :development,
          )
          @union_pacific_coal.tokens << token

          @union_pacific_coal
        end

        def init_bonanza
          @bonanza = Engine::Minor.new(
            type: :oil,
            sym: 'BZ',
            name: '"Buffalo Bill" Cody\'s Bonanza Oil District',
            logo: '1868_wy/Oil-BZ',
            tokens: [],
            color: :black,
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          )

          logo = '/icons/1868_wy/Oil-BZ.svg'
          token = Token.new(
            @bonanza,
            price: 0,
            logo: logo,
            simple_logo: logo,
            type: :development,
          )
          @bonanza.tokens << token

          @bonanza
        end

        def init_development_hexes
          @hexes.each_with_object({}) do |hex, development_hexes|
            development_hexes[hex] = 0 unless %i[red gray purple].include?(hex.tile.color)
          end
        end

        def developing_order
          minors = @coal_companies.select { |c| c.floated? && !c.closed? }.sort_by { |m| @players.index(m.owner) }
          oil = @oil_companies.select { |c| c.floated? && !c.closed? }.sort_by { |m| @players.index(m.owner) }
          minors.concat(oil)
          minors.sort_by! { |m| @players.index(m.owner) } if @optional_rules.include?(:async)
          minors
        end

        def operating_order
          @corporations.select(&:floated?).sort
        end

        def add_coal_development_tokens(coal_company, count: nil, sort: false)
          self.class::COAL_TOKENS.each do |phase_name, token_count|
            logo = "/icons/1868_wy/coal-#{phase_name}.svg"

            (count || token_count).times do
              coal_company.tokens << Token.new(
                coal_company,
                price: 0,
                logo: logo,
                simple_logo: logo,
                type: :development,
              )
            end
          end
          coal_company.tokens.sort_by!(&:logo) if sort
        end

        def available_development_hex?(entity, hex)
          return false unless @development_token_count.include?(hex)
          return @p3_dt_hex != hex if entity == union_pacific_coal || entity == bonanza

          case entity.type
          when :coal
            hex.tile.icons.none? { |i| i.image.include?(coal_phase.to_s) }
          when :oil
            hex.tokens.each do |token|
              return true if token.corporation == entity
              return false if token.corporation.type == :oil && token.corporation != bonanza
            end
            true
          end
        end

        def place_development_token(action)
          entity = action.entity
          player = entity.player
          hex = action.hex
          token = action.token
          cost = action.cost
          cost_str = cost.positive? ? " for #{format_currency(cost)}" : ''

          if entity == union_pacific_coal || entity == bonanza
            @p3_dt_hex = hex
            dt_id = entity == union_pacific_coal ? 'UP' : 'BZ'
            if (placed_token = entity.tokens.find(&:used))
              from_hex = placed_token.hex.name
              destroy_development_token!(placed_token)
              @log << "#{player.name} (#{entity.id}) moves the #{dt_id} "\
                      "Development Token from #{from_hex} to #{hex.name}#{cost_str}"
            else
              @log << "#{player.name} (#{entity.id}) places the #{dt_id} Development Token on #{hex.name}#{cost_str}"
            end
          elsif entity.type == :coal
            @log << "#{player.name} places a Coal Development Token (#{@phase.name}) on #{hex.name}#{cost_str}"
          elsif entity.type == :oil
            @log << "#{player.name} places an Oil Development Token on #{hex.name}#{cost_str}"
          else
            raise GameError, "Unexpected development token placement caused by action: #{action.to_h}"
          end

          player.spend(cost, @bank) if cost.positive?
          hex.place_token(token, logo: token.logo, preprinted: false)

          increment_development_token_count(hex)
          @placed_development_tokens[@phase.name] << hex
          @teapot_dome_hex_bonus = nil if entity == teapot_dome_oil
        end

        def destroy_development_token!(token, handle_bust: true)
          hex = token.hex
          company = token.corporation

          company.tokens.delete(token)
          hex.tokens.delete(token)
          hex.tile.icons.reject! { |i| i.image == token.logo }

          decrement_development_token_count(hex)
          handle_bust! if handle_bust
        end

        def coal_phase
          "coal-#{@phase.name}"
        end

        def boomer?(tile)
          tile.city_towns.any?(&:boom)
        end

        def boomcity?(tile)
          tile.cities.any?(&:boom)
        end

        def increment_development_token_count(tokened_hex)
          hexes = [tokened_hex].concat((0..5).map { |edge| hex_neighbor(tokened_hex, edge) })

          hexes.each do |hex|
            next unless @development_token_count.include?(hex)

            @development_token_count[hex] += 1
            handle_boom!(hex) if boomer?(hex.tile)
          end
        end

        def handle_boom!(hex)
          case @development_token_count[hex]
          when DTC_BOOMCITY
            if hex.tile.cities.none?
              boomtown_to_boomcity!(hex)
            else
              busting_boomcity_saved!(hex)
            end
          when DTC_REVENUE
            boomcity_increase_revenue!(hex)
          end
          update_boomcity_revenue!(hex.tile)
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
            new_tile = hex.tile.opposite
            boom_bust_autoreplace_tile!(new_tile, tile)
          end

          return unless hex.assigned?(pure_oil.id)

          token = hex.tokens.first
          hex.remove_token(token)
          hex.tile.add_reservation!(pure_oil.owner, 0, 0)
          @graph.clear
        end

        def boomcity_increase_revenue!(hex)
          @log << "#{hex.name} #{location_name(hex.name)} is Booming! Its revenue "\
                  "increases by #{format_currency(BOOMING_REVENUE_BONUS)}."
        end

        def busting_boomcity_saved!(hex)
          @log << "#{hex.name} #{location_name(hex.name)} is no longer BUSTing. Its revenue "\
                  "increases to #{format_currency(BOOMCITY_REVENUES[hex.tile.color][1])}."
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
          update_boomcity_revenues!(new_tile, tile)
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return false unless boomer?(from) == boomer?(to)

          case from.name
          when 'YG'
            to.name == 'GG'
          when 'YL'
            to.name == 'GL'
          else
            super
          end
        end

        # green crossing track with "$20" label
        def upgrades_to_correct_label?(from, to)
          (%w[8 9].include?(from.name) && to.label&.to_s == '$20') || super
        end

        def upgrade_cost(tile, hex, entity, spender)
          super + (%w[16 19 20].include?(tile.name) ? 20 : 0)
        end

        def tile_cost_with_discount(_tile, _hex, _entity, spender, _cost)
          cost = super
          cost /= 2 if spender.corporation == pac_rr_a.owner
          cost
        end

        def uranium_bonus(phase_name, hex)
          return 0 unless %w[5 6].include?(phase_name)

          case hex.id
          when JEFFREY_CITY_HEX
            phase_name == '5' ? 20 : 40
          when SHIRLEY_BASIN_HEX
            20
          else
            0
          end
        end

        def revenue_for(route, stops)
          revenue = super

          includes_yellowstone = stops.any? { |s| YELLOWSTONE_HEXES.include?(s.hex.id) }
          revenue += 10 if includes_yellowstone && route.train.owner.companies.include?(wylie)

          revenue += east_west_bonus(stops)[:revenue]

          revenue += spike_route_bonuses(route, stops)[:revenue]

          revenue += fort_bonuses(route)[:revenue]

          revenue += teapot_dome_bonuses(route, stops)[:revenue]

          revenue
        end

        def revenue_str(route)
          str = super
          str += '+ Wylie Yellowstone bonus' if route.train.owner.companies.include?(wylie) &&
                                                route.stops.any? { |s| YELLOWSTONE_HEXES.include?(s.hex.id) }

          ew_bonus = east_west_bonus(route.stops)[:description]
          str += " + #{ew_bonus}" if ew_bonus

          spike_bonus = spike_route_bonuses(route, route.stops)[:description]
          str += " + #{spike_bonus}" if spike_bonus

          str += ' + Uranium' if route.stops.any? { |s| uranium_bonus(@phase.name, s.hex).positive? }
          str += fort_bonuses(route)[:description]
          str += teapot_dome_bonuses(route, route.stops)[:description]
          str
        end

        def east_west_bonus(stops)
          bonus = { revenue: 0 }

          east = stops.find { |stop| stop.groups.include?('E') && stop.tile.label&.to_s == 'E' }
          west = stops.find { |stop| stop.groups.include?('W') && stop.tile.label&.to_s == 'W' }

          if east && west
            east_rev = east.tile.icons.sum { |icon| icon.name.to_i }
            west_rev = west.tile.icons.sum { |icon| icon.name.to_i }

            if !east_rev.zero? && !west_rev.zero?
              bonus[:revenue] += east_rev + west_rev
              bonus[:description] = 'E/W'
            end
          end

          bonus
        end

        def decrement_development_token_count(tokened_hex)
          hexes = [tokened_hex].concat((0..5).map { |edge| hex_neighbor(tokened_hex, edge) })

          hexes.each do |hex|
            next unless @development_token_count.include?(hex)
            next unless @development_token_count[hex].positive?

            if boomer?(hex.tile) && (dtc = @development_token_count[hex]) >= DTC_BOOMCITY
              @busters[hex] ||= dtc
            end
            @development_token_count[hex] -= 1
          end
        end

        def handle_bust!
          @busters.dup.each do |hex, original_dtc|
            next unless boomer?(hex.tile)
            next handle_bust_hex!(hex) if hex.tile.preprinted

            new_dtc = @development_token_count[hex]
            if (new_dtc == DTC_BOOMCITY) && (original_dtc > DTC_BOOMCITY)
              @log << "#{hex.name} #{hex.location_name} is BUSTing! Its revenue "\
                      "decreases by #{format_currency(BOOMING_REVENUE_BONUS)}."
            elsif new_dtc < DTC_BOOMCITY
              @log << "#{hex.name} #{hex.location_name} is BUSTing! Its revenue "\
                      "drops to #{format_currency(BOOMCITY_REVENUES[hex.tile.color][0])}."
            end
            update_boomcity_revenue!(hex.tile)
          end
        end

        def handle_bust_hex!(hex)
          @busters.delete(hex)
          return unless boomer?(hex.tile)

          new_dtc = @development_token_count[hex]

          if hex.assigned?(no_bust&.id) && new_dtc < DTC_BOOMCITY
            @log << "#{hex.name} #{location_name(hex.name)} remains a Boom City thanks to the NO BUST token."
          elsif !hex.tile.preprinted && new_dtc == DTC_GHOST_TOWN
            to_ghost_town!(hex)
          elsif new_dtc < DTC_BOOMCITY
            boomcity_to_boomtown!(hex)
          end
        end

        def busting_return_tokens!(hex, all_tokens: true)
          return unless hex.tile.cities.first

          tokens =
            if all_tokens
              hex.tile.cities.first.tokens.compact
            else
              [hex.tile.cities.first.tokens[1]].compact
            end

          corporations = tokens.map do |token|
            token.remove!
            reprice_tokens!(token.corporation)
          end

          if corporations.empty?
            ''
          else
            @graph.clear
            dpr.coordinates = '' if corporations.include?(dpr) && dpr.tokens.count(&:used).zero?
            " Tokens are returned: #{corporations.map(&:name).join(' and ')}" unless corporations.empty?
          end
        end

        def reprice_tokens!(corporation)
          corporation.tokens.reject(&:used).reverse.each_with_index do |token, index|
            token.price = TOKEN_PRICES_AFTER_BUST[index]
          end
          corporation
        end

        def to_ghost_town!(hex)
          return unless hex

          log_str = "#{hex.name} #{location_name(hex.name)} BUSTs to a Ghost Town."
          log_str += busting_return_tokens!(hex) || ''
          @log << log_str

          hex.location_name = GHOST_TOWN_NAME
          hex.tile.location_name = GHOST_TOWN_NAME

          if hex.tile.preprinted
            hex.tile.cities.reject! { true }
            hex.tile.towns.reject! { true }
            hex.remove_assignment!(pure_oil.id) if hex.assigned?(pure_oil.id)
            return
          end

          gt_tile_name = GHOST_TOWN_TILE[hex.tile.name] || 'GT'
          gt_tile = @tiles.find { |t| t.name == gt_tile_name.to_s && !t.hex }

          boom_bust_autoreplace_tile!(gt_tile, hex.tile)

          hex.remove_assignment!(pure_oil.id) if hex.assigned?(pure_oil.id)
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
            log_str = "#{hex.name} #{location_name(hex.name)} BUSTs to a Boomtown."
            log_str += busting_return_tokens!(hex)
            @log << log_str

            tile = hex.tile.opposite
            boom_bust_autoreplace_tile!(tile, hex.tile)
          end

          return unless hex.assigned?(pure_oil.id)

          corp = pure_oil.corporation
          token = Token.new(
            corp,
            price: 0,
            logo: corp.logo,
            simple_logo: corp.simple_logo,
            type: :boomcity_reservation,
          )
          hex.place_token(token, logo: token.simple_logo, preprinted: false)
        end

        def final_or_in_set?(round)
          round.is_a?(G1868WY::Round::Operating) && round.round_num == @operating_rounds
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Auction
              init_round_finished
              reorder_players(:most_cash, log_player_order: true)
              new_stock_round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players(:first_to_pass, log_player_order: true)
              @phase.name == '8' ? new_operating_round(@round.round_num) : new_development_round
            when G1868WY::Round::Development
              new_operating_round(@round.round_num)
            when G1868WY::Round::Operating
              init_track_points

              last_or_in_set = @round.round_num == @operating_rounds
              in_endgame = @endgame_triggered && @final_stock_round_started

              depot.export! if (last_or_in_set && !@endgame_triggered) ||
                               (in_endgame && @phase.name != '8')

              if last_or_in_set || @endgame_triggered
                new_bust_round(@round.round_num)
              else
                round_num = @round.round_num + 1
                @phase.name == '8' ? new_operating_round(round_num) : new_development_round(round_num)
              end
            when G1868WY::Round::Bust
              resolve_busters!
              if @endgame_triggered && @final_stock_round_started
                round_num = @round.round_num + 1
                @phase.name == '8' ? new_operating_round(round_num) : new_development_round(round_num)
              else
                @final_stock_round_started = @endgame_triggered
                @turn += 1
                new_stock_round
              end
            end
        end

        def player_value(player)
          player.bankrupt ? 0 : player.value
        end

        def distance(train)
          if train.distance.is_a?(Numeric)
            [train.distance, 0]
          else
            cities = train.distance[1]['pay']
            towns = train.distance[0]['pay']
            [cities, towns]
          end
        end

        def trains_str(corporation)
          return '' if corporation.minor?
          return 'None' if corporation.trains.empty?

          corporation.trains.each_with_object([]) do |train, named_trains|
            (named_trains << train.name) unless @double_headed_trains.include?(train)
          end.join(' ')
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

        def route_distance_str(route)
          return route.stops.size.to_s if route.train.distance.is_a?(Integer)

          towns = route.stops.count(&:town?)
          cities = route_distance(route) - towns
          towns_as_cities = [0, towns - route.train.distance[0]['pay']].max

          c = cities + towns_as_cities
          t = towns - towns_as_cities

          towns.positive? ? "#{c}+#{t}" : cities.to_s
        end

        def after_par(corporation)
          super

          return if @all_corps_available

          @corp_stacks.each { |s| s.pop if s.last == corporation }
        end

        def upgrade_home(corporation)
          return if corporation.id != 'LNP' && corporation.id != 'OSL'

          hex = hex_by_id(corporation.coordinates)
          old_tile = hex.tile
          return if old_tile.color == :green || old_tile.color == :brown || old_tile.color == :gray

          green_tile = tile_by_id("G#{old_tile.label}-0")
          update_tile_lists(green_tile, old_tile)
          hex.lay(green_tile)
          update_boomcity_revenues!(green_tile, old_tile)
          @log << "#{corporation.name} lays tile #{green_tile.name} on #{hex.id} (#{green_tile.location_name})"
        end

        def can_par?(corporation, _parrer)
          return false unless super
          return true if corporation.id == 'UP'
          return false if !@all_corps_available && @corp_stacks.none? { |s| s.last == corporation }

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

        def place_pure_oil(hex)
          type = @development_token_count[hex] < DTC_BOOMCITY ? :boomtown : :boomcity

          @pure_oil_hex = hex

          if hex.tile.color == :white
            revenue = '0'
            opts = { boom: true }

            if type == :boomtown
              town = Part::Town.new(revenue, **opts)
              town.tile = hex.tile
              hex.tile.towns << town
            else
              city = Part::City.new(revenue, **opts)
              city.tile = hex.tile
              hex.tile.cities << city
            end
          else
            tile_name = PURE_OIL_CAMP_TILES[hex.tile.name]
            tile_name = tile_name.upcase if type == :boomcity
            tile = tiles.find { |t| t.name == tile_name }

            rotation = -1
            tile.rotate!(rotation += 1) until (hex.tile.exits - tile.exits).empty? || rotation > 5

            update_tile_lists(tile, hex.tile)
            hex.lay(tile)
            update_boomcity_revenues!(tile, hex.tile)

            case type
            when :boomtown
              corp = pure_oil.corporation
              token = Token.new(
                corp,
                price: 0,
                logo: corp.logo,
                simple_logo: corp.simple_logo,
                type: :boomcity_reservation,
              )
              hex.place_token(token, logo: token.simple_logo, preprinted: false)

            when :boomcity
              tile.add_reservation!(pure_oil.owner, 0, 0)
              @log << "#{hex.name} reserved for #{pure_oil.owner.name}"
            end
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

        def total_rounds(name)
          case name
          when self.class::PRIVATES_ROUND_NAME, self.class::DEVELOPMENT_ROUND_NAME
            2
          when self.class::OPERATING_ROUND_NAME
            @operating_rounds
          when 'BUST'
            @endgame_triggered && @final_stock_round_started ? 2 : nil
          end
        end

        def place_no_bust(hex)
          @no_bust_hex = hex
        end

        def event_close_no_bust!
          @log << "-- Event: #{no_bust.name} closes, removing the NO BUST token --"
          hex = @no_bust_hex
          hex.remove_assignment!(no_bust.id)

          return unless (dtc = @development_token_count[hex]) < DTC_BOOMCITY

          @busters[hex] = dtc
          handle_bust!
        end

        def private_earns(amount, company, reason)
          @bank.spend(amount, company.owner)
          @log << "#{company.owner.name} collects #{format_currency(amount)} from #{company.name}; #{reason}"
        end

        def teapot_dome_bonuses(route, stops)
          return { revenue: 0, description: '' } unless teapot_dome_railroad?(route.corporation)

          revenue = stops.sum do |stop|
            (boomcity?(stop.tile) && teapot_dome_hex_bonus[stop.hex]) || 0
          end

          if revenue.positive?
            { revenue: revenue, description: " + #{teapot_dome_private.sym}" }
          else
            { revenue: 0, description: '' }
          end
        end

        def teapot_dome_railroad?(corporation)
          !teapot_dome_private.closed? && corporation.player == teapot_dome_private.player
        end

        # Returns Hash:
        #   - keys: Hex
        #   - values: Int
        # Int value is the total revenue bonus P6c Teapot Dome Oil Leases
        # provides to the key Hex. The caller is responsible for ensuring the
        # bonus only applies to Boom Cities, on routes for RRs with the same
        # owner as the Teapot Dome private.
        #
        # This function is only called when running routes, and is cached so
        # that the bonuses are not be recomputed with every click on a
        # route. The cache is busted when the Teapot Dome's owner adds or
        # removes a token with their oil company.
        def teapot_dome_hex_bonus
          @teapot_dome_hex_bonus ||=
            begin
              bonus = Hash.new(0)
              teapot_dome_oil.tokens.each do |token|
                token.hex.neighbors.each { |_, h| bonus[h] += 5 } if token.used
              end
              bonus
            end
        end

        def check_midwest_oil!(routes)
          return if !midwest_oil || midwest_oil.closed?
          return if !midwest_oil.owned_by_player? && !midwest_oil.owned_by_corporation?

          casper_trains = routes.count do |route|
            route.visited_stops.any? { |stop| stop.hex&.id == CASPER_HEX }
          end
          return if casper_trains.zero?

          private_earns(
            10 * casper_trains,
            midwest_oil,
            "#{casper_trains} train#{casper_trains == 1 ? '' : 's'} visited Casper (#{CASPER_HEX})"
          )
        end

        def foncier_check_tile_lay_action(action)
          return if !foncier || action.entity != foncier.corporation

          tile = action.tile
          return unless tile.color == :yellow

          amount, tile_type =
            if boomer?(tile)
              [30, (tile.cities.empty? ? 'Boomtown' : 'Boom City')]
            elsif !tile.cities.empty? && tile.label&.to_s != 'G' && tile.label&.to_s != 'L'
              [40, 'city']
            elsif !tile.towns.empty?
              [10, 'town']
            else
              [0, nil]
            end

          return unless amount.positive?

          private_earns(amount, foncier, "laid a #{tile_type} tile")
        end

        def event_close_coal_companies!
          @log << '-- Event: Coal Companies close (gray Coal DTs remain on the board) --'
          @minors.reject! do |company|
            next if company.type == :oil

            company.close!
            true
          end
        end

        def setup_strikebreakers!
          add_coal_development_tokens(strikebreakers_coal, count: 1, sort: true)
          @log << "#{strikebreakers_private.name} adds 1 Coal DT for each phase to #{strikebreakers_coal.name}'s DTs"

          @strikebreakers_used = (2..7).to_h { |n| [n.to_s, false] }
        end

        def max_development_tokens(entity)
          max = @phase.name == '2' ? 2 : 1
          max += 1 if entity == strikebreakers_coal && !@strikebreakers_used[@phase.name]
          max
        end

        def after_strikebreakers
          @strikebreakers_used[@phase.name] = true
        end

        def strikebreakers_unused
          @strikebreakers_used.select { |phase, used| !used && phase.to_i >= @phase.name.to_i }.keys
        end

        def strikebreakers_status
          "P6a extra placements: #{strikebreakers_unused.join(',')}"
        end

        def fort_bonuses(route)
          forts = route.connection_hexes.flatten.uniq.count { |id| @forts[id] }

          if forts.positive?
            revenue = forts * (route.corporation == trabing_bros.owner ? 20 : 10)
            { revenue: revenue, description: " + #{forts} Fort#{forts == 1 ? '' : 's'}" }
          else
            { revenue: 0, description: '' }
          end
        end

        def event_close_privates!
          case @phase.name
          when '5'
            event_close_ames_brothers! unless ames_bros.closed?
            event_close_upc! unless union_pacific_coal.closed?
            event_convert_lhp! unless lhp_private.closed?
          when '7'
            event_close_pure_oil! unless pure_oil.closed?
          when '8'
            event_close_big_boy! unless big_boy_private.closed?
            event_close_bonanza! unless bonanza.closed?
            event_close_no_bust! unless no_bust.closed?
          end
        end

        def event_setup_company_price_up_to_face!
          setup_company_price_up_to_face
        end
      end
    end
  end
end
