# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18Neb
      class Game < Game::Base
        include_meta(G18Neb::Meta)
        include Entities
        include Map

        attr_reader :cattle_token_hex

        DEPOT_CLASS = G18Neb::Depot

        BANK_CASH = 6000

        CERT_LIMIT = { 2 => 26, 3 => 17, 4 => 13 }.freeze

        STARTING_CASH = { 2 => 650, 3 => 450, 4 => 350 }.freeze

        MIN_BID_INCREMENT = 5
        ONLY_HIGHEST_BID_COMMITTED = true

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :par

        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :operate
        MUST_SELL_IN_BLOCKS = true

        SOLD_OUT_TOP_ROW_MOVEMENT = :down_right

        NEXT_SR_PLAYER_ORDER = :first_to_pass

        ALLOW_TRAIN_BUY_FROM_OTHER_PLAYERS = false
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        EBUY_SELL_MORE_THAN_NEEDED_SETS_PURCHASE_MIN = true

        CERT_LIMIT_CHANGE_ON_BANKRUPTCY = true
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        CLOSED_CORP_RESERVATIONS_REMOVED = false
        CLOSED_CORP_TRAINS_REMOVED = false

        MARKET = [
          %w[82 90 100 110 122 135 150 165 180 200 220 245 270 300 330 360 400],
          %w[75 82 90 100p 110 122 135 150 165 180 200 220 245 270 300 330 360],
          %w[70 75 82 90p 100 110 122 135 150 165 180 200 220],
          %w[65 70 75 82p 90 100 110 122 135 150 165],
          %w[60 65 70 75p 82 90 100 110],
          %w[50 60 65 70p 75 82],
          %w[40 50 60 65 70],
          %w[30 40 50 60],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: %i[yellow],
            operating_rounds: 2,
            status: ['can_buy_morison_bridging'],
          },
          {
            name: '3',
            on: '3+3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '4',
            on: '4+4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '5',
            on: '5/7',
            train_limit: { 'ten-share': 3, local: 1 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6/8',
            train_limit: { 'ten-share': 2, local: 1 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '4D',
            on: '4D',
            train_limit: { 'ten-share': 2, local: 1 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2+2',
            distance: [{ 'nodes' => %w[town], 'pay' => 2 },
                       { 'nodes' => %w[town city offboard], 'pay' => 2 }],
            price: 100,
            rusts_on: '4+4',
            num: 5,
          },
          {
            name: '3+3',
            distance: [{ 'nodes' => %w[town], 'pay' => 3 },
                       { 'nodes' => %w[town city offboard], 'pay' => 3 }],
            price: 200,
            rusts_on: '6/8',
            num: 4,
          },
          {
            name: '4+4',
            distance: [{ 'nodes' => %w[town], 'pay' => 4 },
                       { 'nodes' => %w[town city offboard], 'pay' => 4 }],
            price: 300,
            rusts_on: '4D',
            num: 3,
          },
          {
            name: '5/7',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 7 }],
            price: 450,
            num: 2,
            events: [{ 'type' => 'close_companies' },
                     { 'type' => 'full_capitalization' },
                     { 'type' => 'local_railways_available' }],
          },
          {
            name: '6/8',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 8 }],
            price: 600,
            num: 2,
            events: [{ 'type' => 'remove_tokens' }],
          },
          {
            name: '4D',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 99, 'multiplier' => 2 },
                       { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 }],
            price: 900,
            num: 20,
            available_on: '6',
          },
        ].freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_morison_bridging' => ['Can Buy Morison Bridging Company'],
        )

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'full_capitalization' => ['Full Capitalization',
                                    'Newly started 10-share corporations receive remaining capitalization once 5 shares sold'],
          'local_railways_available' => ['Local Railways Available', 'Local Railways can now be started'],
          'remove_tokens' => ['Remove Tokens', 'All private company tokens are removed from the game'],
        )

        CATTLE_OPEN_ICON = 'cattle_open'
        CATTLE_CLOSED_ICON = 'cattle_closed'

        ASSIGNMENT_TOKENS = {
          CATTLE_OPEN_ICON => '/icons/18_neb/cattle_open.svg',
          CATTLE_CLOSED_ICON => '/icons/18_neb/cattle_closed.svg',
        }.freeze

        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded }].freeze

        def bridge_company
          @bridge_company ||= @companies.find { |company| company.id == 'P2' }
        end

        def cattle_company
          @cattle_company ||= company_by_id('P3')
        end

        def tile_income_company
          @tile_income_company ||= @companies.find { |company| company.id == 'P5' }
        end

        def setup_preround
          setup_company_purchase_prices
        end

        def setup_company_purchase_prices
          @companies.each do |company|
            range = case company
                    when bridge_company
                      [1.0, 1.0]
                    when tile_income_company
                      [0.5, 1.0]
                    else
                      [0.5, 1.5]
                    end
            set_company_purchase_price(company, *range)
          end
        end

        def set_company_purchase_price(company, min_multiplier, max_multiplier)
          company.min_price = (company.value * min_multiplier).ceil
          company.max_price = (company.value * max_multiplier).floor
        end

        def setup
          @corporations_to_fully_capitalize = []
          @locals = @corporations.select { |c| c.type == :local }
          move_local_reservations_to_city
          place_neutral_token(valentine_hex)
        end

        def move_local_reservations_to_city
          @locals.each do |local|
            hex = hex_by_id(local.coordinates)
            hex.tile.remove_reservation!(local)
            [@tiles, @all_tiles].each do |tiles|
              brown_tile = tiles.find { |t| local_home_track_brown_upgrade?(hex.tile, t) }
              brown_tile.cities.first.add_reservation!(local)
            end
          end
        end

        def valentine_hex
          @valentine_hex ||= hex_by_id('G1')
        end

        def place_neutral_token(hex)
          @neutral_corp ||= Corporation.new(sym: 'N', name: 'Neutral', logo: '18_neb/neutral', tokens: [])
          hex.tile.cities.first.place_token(@neutral_corp,
                                            Token.new(@neutral_corp, price: 0, type: :neutral),
                                            check_tokenable: false)
        end

        def event_close_companies!
          super
          # Bridge tokens remain in the game until phase 6
          company_by_id('P2')&.revenue = 0
          cattle_company&.revenue = 0
        end

        def event_full_capitalization!
          @log << "-- Event: #{EVENTS_TEXT['full_capitalization'][1]} --"
          @corporations_fully_capitalize = true
        end

        def event_local_railways_available!
          @log << "-- Event: #{EVENTS_TEXT['local_railways_available'][1]} --"
          @locals_available = true
        end

        def event_remove_tokens!
          @log << "-- Event: #{EVENTS_TEXT['remove_tokens'][1]} --"
          return unless @cattle_token_hex

          remove_cattle_token
        end

        def remove_cattle_token
          @cattle_token_hex.remove_assignment!(self.class::CATTLE_OPEN_ICON)
          @cattle_token_hex.remove_assignment!(self.class::CATTLE_CLOSED_ICON)
          @corporations.each do |corporation|
            corporation.remove_assignment!(self.class::CATTLE_OPEN_ICON)
            corporation.remove_assignment!(self.class::CATTLE_CLOSED_ICON)
          end
        end

        def reorder_players(order = nil, log_player_order: false)
          @round.is_a?(Round::Auction) ? super(:most_cash, log_player_order: true) : super
        end

        def init_round
          Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G18Neb::Step::BidAuction,
          ])
        end

        def stock_round
          Round::Stock.new(self, [
            G18Neb::Step::LocalHomeTrack,
            G18Neb::Step::Exchange,
            G18Neb::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          @round_num = round_num
          Round::Operating.new(self, [
            G18Neb::Step::Bankrupt,
            G18Neb::Step::Assign,
            G18Neb::Step::SpecialChoose,
            G18Neb::Step::BuyCompany,
            G18Neb::Step::SpecialTrack,
            G18Neb::Step::Track,
            G18Neb::Step::Token,
            Engine::Step::Route,
            G18Neb::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18Neb::Step::BuyTrain,
            [G18Neb::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return local_home_track_brown_upgrade?(from, to) if @round.is_a?(Round::Stock)
          return true if town_to_city_upgrade?(from, to)
          return true if omaha_green_upgrade?(from, to)

          super
        end

        def omaha_green_upgrade?(from, to)
          from.color == :yellow && from.label&.to_s == 'O' && to.name == 'X04'
        end

        def town_to_city_upgrade?(from, to)
          %w[3 4 58].include?(from.name) && %w[X01 X02 X03].include?(to.name)
        end

        def local_home_track_brown_upgrade?(from, to)
          to.color == :brown && @locals.map(&:coordinates).include?(from.hex.id) && upgrades_to_correct_label?(from, to)
        end

        def upgrade_cost(tile, _hex, entity, spender)
          terrain_cost = tile.upgrades.sum(&:cost)
          discounts = 0

          # Tile discounts must be activated
          if entity.company? && (ability = entity.all_abilities.find { |a| a.type == :tile_discount })
            discounts = tile.upgrades.sum do |upgrade|
              next unless upgrade.terrains.include?(ability.terrain)

              discount = [upgrade.cost, ability.discount].min
              log_cost_discount(spender, ability, discount) if discount.positive?
              discount
            end
          end

          terrain_cost -= TILE_COST if terrain_cost.positive?
          terrain_cost - discounts
        end

        def purchasable_companies(entity = nil)
          if @phase.status.include?('can_buy_morison_bridging') &&
              bridge_company&.owner&.player? &&
              entity != bridge_company.owner
            [bridge_company]
          elsif @phase.status.include?('can_buy_companies')
            super
          else
            []
          end
        end

        def after_phase_change(name)
          set_company_purchase_price(bridge_company, 0.5, 1.5) if name == '3' && bridge_company
        end

        def after_par(corporation)
          super
          return if corporation.type == :local || !corporations_fully_capitalize?

          @corporations_to_fully_capitalize << corporation
        end

        def place_home_token(corporation)
          unless can_place_home_token?(corporation)
            @round.pending_home_track << corporation unless @round.pending_home_track.include?(corporation)
            return
          end

          super
        end

        def can_place_home_token?(corporation)
          return true unless corporation.type == :local

          %i[brown gray].include?(hex_by_id(corporation.coordinates).tile.color)
        end

        def corporations_fully_capitalize?
          @corporations_fully_capitalize
        end

        def locals_available?
          @locals_available
        end

        def can_par?(corporation, _parrer)
          return false if corporation.type == :local && !locals_available?

          super
        end

        def can_gain_from_player?(entity, bundle)
          bundle.corporation == entity && !causes_president_swap?(entity, bundle)
        end

        def causes_president_swap?(corporation, bundle)
          return false unless corporation.president?(bundle.owner)

          seller = bundle.owner
          share_holders = corporation.player_share_holders(corporate: true)
          remaining = share_holders[seller] - bundle.percent
          next_highest = share_holders.reject { |k, _| k == seller }.values.max || 0
          remaining < next_highest
        end

        def check_for_full_capitalization(corporation)
          return if !@corporations_to_fully_capitalize.include?(corporation) || corporation.num_ipo_shares != 5

          cash = corporation.num_ipo_shares * corporation.par_price.price
          @bank.spend(cash, corporation)
          @share_pool.transfer_shares(ShareBundle.new(corporation.shares_of(corporation)), @share_pool)
          @corporations_to_fully_capitalize.delete(corporation)
          @log << "#{corporation.name} becomes fully capitalized, receiving #{format_currency(cash)} in its treasury. " \
                  "#{corporation.name}'s remaining shares are placed in the market."
        end

        def issuable_shares(entity)
          max_issuable = (entity.total_shares * 0.5).floor - entity.num_market_shares
          return [] unless max_issuable.positive?

          bundles_for_corporation(entity, entity, shares: entity.shares_of(entity).first(max_issuable))
        end

        def redeemable_shares(entity)
          ([@share_pool] + @players).flat_map do |sh|
            sh.shares_of(entity).reject(&:president).find { |s| s.price <= entity.cash }&.to_bundle
          end.compact
        end

        def operating_order
          corporations = @corporations.select(&:floated?)
          if @turn == 1 && (@round_num || 1) == 1
            corporations.sort_by do |c|
              sp = c.share_price
              [sp.price, sp.corporations.find_index(c)]
            end
          else
            corporations.sort
          end
        end

        def check_other(route)
          double_chicago = (self.class::CHICAGO_HEXES & route.stops.map { |s| s.hex.id }) == self.class::CHICAGO_HEXES
          raise GameError, 'Cannot include both North and South Chicago' if double_chicago
        end

        def revenue_for(route, stops)
          super + east_west_bonus(route, stops) + cattle_bonus(route, stops)
        end

        def revenue_str(route)
          stops = route.stops
          stop_hexes = stops.map(&:hex)
          str = route.hexes.map { |h| stop_hexes.include?(h) ? h&.name : "(#{h&.name})" }.join('-')
          str += ' + EW' if east_west_route?(route.stops)
          str
        end

        def east_west_route?(stops)
          (stops.map { |s| s.tile.label&.to_s }.uniq & %w[E W]).size == 2
        end

        def east_west_bonus(route, stops)
          return 0 unless east_west_route?(stops)

          stops.map { |stop| stop.route_revenue(route.phase, route.train) }.max
        end

        def cattle_bonus(route, stops)
          closed_cattle = stops.any? { |stop| stop.hex.assigned?(self.class::CATTLE_CLOSED_ICON) }
          open_cattle = !closed_cattle && stops.any? { |stop| stop.hex.assigned?(self.class::CATTLE_OPEN_ICON) }

          if (open_cattle && route.train.owner.assigned?(self.class::CATTLE_OPEN_ICON)) ||
              (closed_cattle && route.train.owner.assigned?(self.class::CATTLE_CLOSED_ICON))
            20
          elsif open_cattle
            10
          else
            0
          end
        end

        def cattle_token_assigned!(hex)
          cattle_company.add_ability(Engine::Ability::ChooseAbility.new(type: :choose_ability, choices: ['Close Token'],
                                                                        when: 'token'))
          @cattle_token_hex = hex
        end

        def rust(train)
          train.rusted = true
          @depot.reclaim_train(train)
        end

        def close_corporation(corporation, quiet: false)
          if corporation.assigned?(self.class::CATTLE_OPEN_ICON) || corporation.assigned?(self.class::CATTLE_CLOSED_ICON)
            remove_cattle_token
          end
          super
          corporation = reset_corporation(corporation)
          hex_by_id(corporation.coordinates).tile.add_reservation!(corporation, 0)
          @corporations << corporation
        end
      end
    end
  end
end
