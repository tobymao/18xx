# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'step/draft_2p_distribution'
require_relative 'step/draft_distribution'
require_relative '../company_price_up_to_face'
require_relative '../base'

module Engine
  module Game
    module G1846
      class Game < Game::Base
        include_meta(G1846::Meta)
        include Entities
        include Map
        include CompanyPriceUpToFace

        attr_accessor :second_tokens_in_green

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f')

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = { 2 => 7000, 3 => 6500, 4 => 7500, 5 => 9000 }.freeze

        CERT_LIMIT = {
          2 => { 5 => 19, 4 => 16 },
          3 => { 5 => 14, 4 => 11 },
          4 => { 6 => 12, 5 => 10, 4 => 8 },
          5 => { 7 => 11, 6 => 10, 5 => 8, 4 => 6 },
        }.freeze

        STARTING_CASH = { 2 => 600, 3 => 400, 4 => 400, 5 => 400 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = true

        MARKET = [
          %w[0c 10 20 30
             40p 50p 60p 70p 80p 90p 100p 112p 124p 137p 150p
             165 180 195 212 230 250 270 295 320 345 375 405 440 475 510 550],
           ].freeze

        PHASES = [
          {
            name: 'I',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: 'II',
            train_limit: 4,
            on: '4',
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: 'III',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: 'IV',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            obsolete_on: '5',
            rusts_on: '6',
          },
          {
            name: '4',
            distance: 4,
            price: 180,
            obsolete_on: '6',
            variants: [
              {
                name: '3/5',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 5 }],
                price: 160,
              },
            ],
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            variants: [
              {
                name: '4/6',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 6 }],
                price: 450,
              },
            ],
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: 6,
            price: 800,
            variants: [
              {
                name: '7/8',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 7, 'visit' => 8 }],
                price: 900,
              },
            ],
            events: [
              { 'type' => 'remove_bonuses' },
              { 'type' => 'remove_reservations' },
            ],
          },
        ].freeze

        POOL_SHARE_DROP = :down_block
        SELL_AFTER = :p_any_operate
        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :left_block_pres
        EBUY_FROM_OTHERS = :never
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        HOME_TOKEN_TIMING = :float
        MUST_BUY_TRAIN = :always
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        GAME_END_CHECK = {
          bankrupt: :immediate,
          bank: :full_or,
          all_closed: :immediate,
          final_train: :one_more_full_or_set,
        }.freeze

        ORANGE_GROUP = [
          'Lake Shore Line',
          'Michigan Central',
          'Ohio & Indiana',
          'Little Miami',
        ].freeze

        BLUE_GROUP = [
          'Steamboat Company',
          'Meat Packing Company',
          'Tunnel Blasting Company',
          'Boomtown',
        ].freeze

        GREEN_GROUP = %w[C&O ERIE PRR].freeze
        NORTH_GROUP = %w[ERIE GT NYC PRR].freeze
        SOUTH_GROUP = %w[B&O C&O IC].freeze

        REMOVED_CORP_SECOND_TOKEN = {
          'B&O' => 'H12',
          'C&O' => 'H12',
          'ERIE' => 'D20',
          'GT' => 'D14',
          'IC' => 'G7',
          'NYC' => 'E17',
          'PRR' => 'E11',
        }.freeze

        LSL_HEXES = %w[D14 E17].freeze

        # we must define these since it's redefined by 18LA
        LSL_ICON = 'lsl'
        LSL_ID = 'LSL'
        MEAT_REVENUE_DESC = 'Meat-Packing'
        BOOMTOWN_REVENUE_DESC = 'Boomtown'

        LITTLE_MIAMI_HEXES = %w[H12 G13].freeze

        ABILITY_ICONS = {
          SC: 'port',
          MPC: 'meat',
          LSL: 'lsl',
          BT: 'boom',
          LM: 'lm',
          IC: 'ic',
        }.freeze

        MEAT_HEXES = %w[D6 I1].freeze

        STEAMBOAT_HEXES = %w[B8 C5 D14 I1 G19].freeze

        BOOMTOWN_HEXES = %w[H12].freeze

        TILE_COST = 20
        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_bonuses' => ['Remove Bonuses', 'Remove Steamboat, Meat Packing, and Boomtown bonuses'],
          'remove_reservations' => ['Remove Reservations', 'Remove reserved token slots for corporations']
        ).freeze

        ASSIGNMENT_TOKENS = {
          'MPC' => '/icons/1846/mpc_token.svg',
          'SC' => '/icons/1846/sc_token.svg',
          'BT' => '/icons/1846/bt_token.svg',
        }.freeze

        # Two tiles can be laid, only one upgrade
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded }].freeze

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['Dividend < 1/2 stock price', '1 ←'],
            ['Dividend ≥ 1/2 stock price but < stock price', 'none'],
            ['Dividend ≥ stock price', '1 →'],
            ['Dividend ≥ 2X stock price', '2 →'],
            ['Dividend ≥ 3X stock price and stock price ≥ 165', '3 →'],
            ['Corporation director sells any number of shares', '1 ←'],
            ['Corporation has any shares in the Market at end of an SR', '1 ←'],
            ['Corporation is sold out at end of an SR', '1 →'],
          ]
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def corporation_opts
          two_player? ? { max_ownership_percent: 70 } : {}
        end

        def init_companies(players)
          companies = super

          passes = Array.new(num_pass_companies(players)) do |i|
            name = "Pass (#{i + 1})"
            Company.new(
              sym: name,
              name: name,
              value: 0,
              desc: "Choose this card if you don't want to purchase any of the offered companies this turn.",
            )
          end

          if first_edition?
            second_ed_companies, companies = companies.partition { |c| %w[BT LM].include?(c.id) }
            second_ed_companies.each(&:close!)
            @blue_group = BLUE_GROUP.take(3)
            @orange_group = ORANGE_GROUP.take(3)
          end

          companies + passes
        end

        def num_pass_companies(players)
          two_player? ? 0 : players.size
        end

        def setup
          @turn = setup_turn
          @second_tokens_in_green = {}

          if first_edition?
            remove_icons(self.class::BOOMTOWN_HEXES, self.class::ABILITY_ICONS['BT'])
            remove_icons(self.class::LITTLE_MIAMI_HEXES, self.class::ABILITY_ICONS['LM'])
          end

          remove_from_group!(orange_group, @companies) do |company|
            ability_with_icons = company.abilities.find { |ability| ability.type == 'tile_lay' }
            remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[company.id]) if ability_with_icons
            company.close!
            @round.active_step.companies.delete(company)
          end
          remove_from_group!(blue_group, @companies) do |company|
            ability_with_icons = company.abilities.find { |ability| ability.type == 'assign_hexes' }
            remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[company.id]) if ability_with_icons
            company.close!
            @round.active_step.companies.delete(company)
          end

          corporation_removal_groups.each do |group|
            remove_from_group!(group, @corporations) do |corporation|
              place_home_token(corporation)
              ability_with_icons = corporation.abilities.find { |ability| ability.type == 'tile_lay' }
              remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[corporation.id]) if ability_with_icons
              abilities(corporation, :reservation) do |ability|
                corporation.remove_ability(ability)
              end
              place_second_token(corporation, **place_second_token_kwargs(corporation))
            end
          end
          @log << "Privates in the game: #{@companies.reject { |c| c.name.include?('Pass') }.map(&:name).sort.join(', ')}"
          @log << "Corporations in the game: #{@corporations.map(&:name).sort.join(', ')}"

          @cert_limit = init_cert_limit

          setup_company_price_up_to_face

          @draft_finished = false

          @minors.each do |minor|
            train = @depot.upcoming[0]
            train.buyable = false
            buy_train(minor, train, :free)
            hex = hex_by_id(minor.coordinates)
            hex.tile.cities[0].place_token(minor, minor.next_token, free: true)
          end

          @last_action = nil
        end

        def orange_group
          @orange_group ||= self.class::ORANGE_GROUP
        end

        def blue_group
          @blue_group ||= self.class::BLUE_GROUP
        end

        def first_edition?
          @first_edition ||= @optional_rules.include?(:first_ed)
        end

        def setup_turn
          two_player? ? 0 : 1
        end

        def remove_from_group!(group, entities)
          removals_group = group.dup
          removals_group -= ['Boomtown', 'Little Miami', 'C&O'] if @optional_rules.include?(:second_ed_co)
          removals = removals_group.sort_by { rand }.take(num_removals(group))

          # This looks verbose, but it works around the fact that we can't
          # modify code which includes rand() w/o breaking existing games
          return if removals.empty?

          @log << "Removing #{removals.join(', ')}"
          entities.reject! do |entity|
            if removals.include?(entity.name)
              yield entity if block_given?
              @removals << entity
              true
            else
              false
            end
          end
        end

        def operating_order
          corporations = @corporations.select(&:floated?)
          if @turn == 1 && (@round_num || 1) == 1
            corporations.sort_by! do |c|
              sp = c.share_price
              [sp.price, sp.corporations.find_index(c)]
            end
          else
            corporations.sort!
          end
          @minors.select(&:floated?) + corporations
        end

        def num_removals(group)
          additional =
            case group
            when BLUE_GROUP, ORANGE_GROUP
              (first_edition? ? 0 : 1)
            else
              0
            end

          (two_player? ? 1 : 5 - @players.size) + additional
        end

        def corporation_removal_groups
          two_player? ? [NORTH_GROUP, SOUTH_GROUP] : [GREEN_GROUP]
        end

        def place_second_token_kwargs(corporation = nil)
          { deferred: corporation != erie }
        end

        def place_second_token(corporation, two_player_only: true, deferred: true)
          return if two_player_only && !two_player?

          hex_id = self.class::REMOVED_CORP_SECOND_TOKEN[corporation.id]
          hex = hex_by_id(hex_id)

          if deferred
            # defer second token placement until green city upgrade.
            @second_tokens_in_green[hex_id] = corporation

            # Unfortunately Icon always reapplies the ".svg"
            logo_filename = corporation.logo[0...-4]
            hex.tile.icons << Part::Icon.new("../#{logo_filename}", corporation.id.to_s)
            @log << "#{corporation.id} will place a token on #{hex_id} when it is upgraded to green"
          else
            token = corporation.find_token_by_type
            hex.tile.cities.first.place_token(corporation, token, check_tokenable: false)
            @log << "#{corporation.id} places a second token on #{hex_id} (#{hex.location_name})"
          end
        end

        def place_token_on_upgrade(action)
          hex_id = action.tile.hex.id
          return if action.tile.color != :green || !@second_tokens_in_green.include?(hex_id)

          corporation = @second_tokens_in_green[hex_id]
          token = corporation.find_token_by_type
          hex = hex_by_id(hex_id)
          hex.tile.cities.first.place_token(corporation, token, check_tokenable: false)
          icon = hex.tile.icons.find { |i| i.name == corporation.id }
          hex.tile.icons.delete(icon) if icon

          @log << "#{corporation.id} places a token on #{hex_id} (#{hex.location_name}) as the city is green"
          @second_tokens_in_green.delete(hex_id)
          @graph.clear
        end

        def num_trains(train)
          num_players = @players.size

          case train[:name]
          when '2'
            two_player? ? 7 : num_players + 4
          when '4'
            two_player? ? 5 : num_players + 1
          when '5'
            two_player? ? 3 : num_players
          when '6'
            two_player? ? 4 : 9
          end
        end

        def revenue_for(route, stops)
          revenue = super

          [
            [boomtown, 20],
            [meat_packing, 30],
            [steamboat, 20, 'port'],
          ].each do |company, bonus_revenue, icon|
            id = company&.id
            if id && route.corporation.assigned?(id) && (assigned_stop = stops.find { |s| s.hex.assigned?(id) })
              revenue += bonus_revenue * (icon ? assigned_stop.hex.tile.icons.count { |i| i.name == icon } : 1)
            end
          end

          revenue += east_west_bonus(stops)[:revenue]

          if route.train.owner.companies.include?(mail_contract)
            longest = route.routes.max_by { |r| [r.visited_stops.size, r.train.id] }
            revenue += route.visited_stops.size * 10 if route == longest
          end

          revenue
        end

        def east_west_bonus(stops)
          bonus = { revenue: 0 }

          east = stops.find { |stop| stop.groups.include?('E') }
          west = stops.find { |stop| stop.tile.label&.to_s == 'W' }

          if east && west
            bonus[:revenue] += east.tile.icons.sum { |icon| icon.name.to_i }
            bonus[:revenue] += west.tile.icons.sum { |icon| icon.name.to_i }
            bonus[:description] = 'E/W'
          end

          bonus
        end

        def revenue_str(route)
          stops = route.stops
          stop_hexes = stops.map(&:hex)
          str = route.hexes.map do |h|
            stop_hexes.include?(h) ? h&.name : "(#{h&.name})"
          end.join('-')

          [
            [boomtown, self.class::BOOMTOWN_REVENUE_DESC],
            [meat_packing, self.class::MEAT_REVENUE_DESC],
            [steamboat, 'Port'],
          ].each do |company, desc|
            id = company&.id
            str += " + #{desc}" if id && route.corporation.assigned?(id) && stops.any? { |s| s.hex.assigned?(id) }
          end

          bonus = east_west_bonus(stops)[:description]
          str += " + #{bonus}" if bonus

          if route.train.owner.companies.include?(mail_contract)
            longest = route.routes.max_by { |r| [r.visited_stops.size, r.train.id] }
            str += ' + Mail Contract' if route == longest
          end

          str
        end

        def meat_packing
          @meat_packing ||= company_by_id('MPC')
        end

        def steamboat
          @steamboat ||= company_by_id('SC')
        end

        def boomtown
          @boomtown ||= company_by_id('BT')
        end

        def block_for_steamboat?
          steamboat.owned_by_player?
        end

        def michigan_central
          @michigan_central ||= company_by_id('MC')
        end

        def ohio_indiana
          @ohio_indiana ||= company_by_id('O&I')
        end

        def mail_contract
          @mail_contract ||= company_by_id('MAIL')
        end

        def lake_shore_line
          @lake_shore_line ||= company_by_id('LSL')
        end

        def erie
          @erie ||= corporation_by_id('ERIE')
        end

        def illinois_central
          @illinois_central ||= corporation_by_id('IC')
        end

        def preprocess_action(action)
          preprocess_little_miami(action)
          check_special_tile_lay(action) unless psuedo_special_tile_lay?(action)
        end

        def action_processed(action)
          case action
          when Action::Par
            if action.corporation == illinois_central
              illinois_central.remove_ability_when(:par)
              bonus = action.share_price.price
              @bank.spend(bonus, illinois_central)
              @log << "#{illinois_central.name} receives a #{format_currency(bonus)} subsidy"
            end
          end

          check_special_tile_lay(action)
          postprocess_little_miami(action)

          super

          @last_action = action
        end

        def special_tile_lay?(action)
          action.is_a?(Action::LayTile) &&
            [michigan_central, ohio_indiana, little_miami].include?(action.entity)
        end

        def psuedo_special_tile_lay?(action)
          action.is_a?(Action::LayTile) &&
            [michigan_central, ohio_indiana, little_miami].any? { |c| c&.owner == action.entity }
        end

        def check_special_tile_lay(action)
          return if action.is_a?(Engine::Action::Message)

          company = @last_action&.entity
          return unless special_tile_lay?(@last_action)
          return unless (ability = abilities(company, :tile_lay))
          return if action.entity == company

          company.remove_ability(ability)
          @log << "#{company.name} forfeits second tile lay."
        end

        def init_round
          draft_step = two_player? ? G1846::Step::Draft2pDistribution : G1846::Step::DraftDistribution
          Engine::Round::Draft.new(self, [draft_step], reverse_order: true)
        end

        def new_draft_round
          @log << "-- #{round_description('Draft')} --"
          init_round
        end

        def priority_deal_player
          return @players.first if @round.is_a?(Engine::Round::Draft)

          super
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1846::Step::Assign,
            G1846::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          @round_num = round_num
          G1846::Round::Operating.new(self, [
            G1846::Step::Bankrupt,
            G1846::Step::Assign,
            Engine::Step::SpecialToken,
            G1846::Step::SpecialTrack,
            G1846::Step::BuyCompany,
            G1846::Step::IssueShares,
            G1846::Step::TrackAndToken,
            Engine::Step::Route,
            G1846::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1846::Step::BuyTrain,
            [G1846::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def upgrade_cost(tile, hex, entity, spender)
          [self.class::TILE_COST, super].max
        end

        def event_close_companies!
          @minors.dup.each { |minor| close_corporation(minor) }
          remove_icons(self.class::LSL_HEXES, self.class::ABILITY_ICONS[lake_shore_line.id]) if lake_shore_line
          remove_icons(self.class::LITTLE_MIAMI_HEXES, self.class::ABILITY_ICONS[little_miami.id]) if little_miami
          remove_steamboat_bonuses! if steamboat && !steamboat.owned_by_corporation?
          super
        end

        def remove_steamboat_bonuses!
          self.class::STEAMBOAT_HEXES.each do |hex_id|
            hex = hex_by_id(hex_id)
            if hex.assigned?(steamboat.id)
              hex.remove_assignment!(steamboat.id)
              @log << "-- Event: Player-owned #{steamboat.name} token removed from #{hex.name} --"
            end
          end

          @corporations.each do |corp|
            corp.remove_assignment!(steamboat.id) if corp.assigned?(steamboat.id)
          end

          self.class::STEAMBOAT_HEXES.uniq.each do |hex|
            hex_by_id(hex).tile.icons.reject! do |icon|
              %w[port].include?(icon.name)
            end
          end
        end

        def event_remove_reservations!
          @log << '-- Event: Reserved token slots removed --'
          @corporations.each do |corp|
            abilities(corp, :token) do |ability|
              ability.description = ability.description.sub('Reserved ', '')
            end
          end
        end

        def event_remove_bonuses!
          removals = Hash.new { |h, k| h[k] = {} }

          @corporations.each do |corp|
            corp.assignments.dup.each do |company, _|
              removals[company][:corporation] = corp.name
              corp.remove_assignment!(company)
            end
          end

          @hexes.each do |hex|
            hex.assignments.dup.each do |company, _|
              removals[company][:hex] = hex.name
              hex.remove_assignment!(company)
            end
          end

          remove_icons(self.class::BOOMTOWN_HEXES, self.class::ABILITY_ICONS['BT'])
          remove_icons(self.class::STEAMBOAT_HEXES, self.class::ABILITY_ICONS['SC'])
          remove_icons(self.class::MEAT_HEXES, self.class::ABILITY_ICONS['MPC'])

          removals.each do |company, removal|
            hex = removal[:hex]
            corp = removal[:corporation]
            @log << "-- Event: #{corp}'s #{company_by_id(company).name} bonus removed from #{hex} --"
          end
        end

        def remove_icons(hex_list, icon_name)
          hex_list.each do |hex|
            hex_by_id(hex).tile.icons.reject! { |icon| icon.name == icon_name }
          end
        end

        def sellable_bundles(player, corporation)
          return [] if corporation.receivership?

          super
        end

        def buying_power(entity, **)
          entity.cash + (issuable_shares(entity).map(&:price).max || 0)
        end

        def total_emr_buying_power(player, corporation)
          emergency = (issuable = emergency_issuable_cash(corporation)).zero?
          corporation.cash + issuable + liquidity(player, emergency: emergency)
        end

        def issuable_shares(entity)
          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.instance_of?(G1846::Step::IssueShares) }.active?

          num_shares = entity.num_player_shares - entity.num_market_shares
          bundles = bundles_for_corporation(entity, entity)
          share_price = stock_market.find_share_price(entity, :left).price

          bundles
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| bundle.num_shares > num_shares }
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.instance_of?(G1846::Step::IssueShares) }.active?

          share_price = stock_market.find_share_price(entity, :right).price

          bundles_for_corporation(share_pool, entity)
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| entity.cash < bundle.price }
        end

        def emergency_issuable_bundles(corp)
          return [] if corp.trains.any?
          return [] if @round.emergency_issued
          return [] unless (train = @depot.min_depot_train)

          min_train_price, max_train_price = train.variants.map { |_, v| v[:price] }.minmax
          return [] if corp.cash >= max_train_price

          bundles = bundles_for_corporation(corp, corp)

          num_issuable_shares = corp.num_player_shares - corp.num_market_shares
          bundles.reject! { |bundle| bundle.num_shares > num_issuable_shares }

          bundles.each do |bundle|
            directions = [:left] * (1 + bundle.num_shares)
            bundle.share_price = stock_market.find_share_price(corp, directions).price
          end

          # cannot issue shares that generate no money; this is errata from BGG
          # and differs from the GMT rulebook
          # https://boardgamegeek.com/thread/2094996/article/30495755#30495755
          bundles.reject! { |b| b.price.zero? }

          bundles.sort_by!(&:price)

          # Cannot issue more shares than needed to buy the train from the bank
          # (but may buy either variant)
          # https://boardgamegeek.com/thread/1849992/article/26952925#26952925
          train_buying_bundles = bundles.select { |b| (corp.cash + b.price) >= min_train_price }
          if train_buying_bundles.any?
            bundles = train_buying_bundles

            index = bundles.find_index { |b| (corp.cash + b.price) >= max_train_price }
            return bundles.take(index + 1) if index

            return bundles
          end

          # if a train cannot be afforded, issue all possible shares
          # https://boardgamegeek.com/thread/1849992/article/26939192#26939192
          biggest_bundle = bundles.max_by(&:num_shares)
          return [biggest_bundle] if biggest_bundle

          []
        end

        def next_round!
          return super if !two_player? || @draft_finished

          @round =
            case @round
            when Engine::Round::Draft
              if (@draft_finished = companies.all?(&:owned_by_player?))
                @turn = 1
                new_stock_round
              else
                @operating_rounds = @phase.operating_rounds
                new_operating_round
              end
            when Engine::Round::Operating
              or_round_finished
              if @round.round_num < @operating_rounds
                new_operating_round(@round.round_num + 1)
              else
                or_set_finished
                new_draft_round
              end
            else
              raise GameError "unexpected current round type #{@round.class.name}, don't know how to pick next round"
            end

          @round
        end

        def game_end_check_values
          @game_end_check_values ||=
            if two_player?
              self.class::GAME_END_CHECK
            else
              self.class::GAME_END_CHECK.except(:final_train)
            end
        end

        def east_west_desc
          'East to West'
        end

        def train_help(_entity, runnable_trains, _routes)
          help = []

          nm_trains = runnable_trains.select { |t| t.name.include?('/') }

          if nm_trains.any?
            corporation = nm_trains.first.owner
            trains = nm_trains.map(&:name).uniq.sort.join(', ')
            help << "N/M trains (#{trains}) may visit M locations, but only "\
                    'earn revenue from the best combination of N locations.'
            help << "One of the N locations must include a #{corporation.name} "\
                    'token.'
            help << 'In order for an N/M train to earn bonuses for an '\
                    "#{east_west_desc} route, both of the #{east_west_desc} "\
                    'locations must be counted among the N locations.'
          end

          help
        end

        def potential_minor_cash(entity, allowed_trains: (0..3))
          if entity.corporation? && entity.cash.positive? && allowed_trains.include?(entity.trains.size)
            @minors.reduce(0) do |memo, minor|
              minor.owned_by_player? && minor.cash.positive? ? memo + minor.cash - 1 : memo
            end
          else
            0
          end
        end

        def track_buying_power(entity)
          buying_power(entity) + potential_minor_cash(entity)
        end

        def train_buying_power(entity)
          buying_power(entity) + potential_minor_cash(entity, allowed_trains: (1..2))
        end

        def ability_time_is_or_start?
          active_step.is_a?(G1846::Step::Assign) || super
        end

        def little_miami
          @little_miami ||= company_by_id('LM')
        end

        def little_miami_router
          @little_miami_router ||=
            Engine::Corporation.new(name: 'LM Corp', sym: 'LM Corp', tokens: [], coordinates: LITTLE_MIAMI_HEXES.first)
        end

        def compute_little_miami_graph
          graph = Graph.new(self, no_blocking: true, home_as_token: true)
          graph.compute(little_miami_router)
          graph
        end

        def little_miami_action?(action)
          action.entity == little_miami &&
            (action.is_a?(Action::LayTile) || action.is_a?(Action::Pass))
        end

        def preprocess_little_miami(action)
          return unless little_miami_action?(action)

          @little_miami_hexes_laid ||= []
          check_little_miami_graph_before! if @little_miami_hexes_laid.empty?

          return unless action.is_a?(Action::LayTile)

          hex = action.hex
          @little_miami_before_exits ||= {}
          @little_miami_before_exits[hex.id] = hex.tile.exits.dup
        end

        def postprocess_little_miami(action)
          return unless little_miami_action?(action)

          if action.is_a?(Action::LayTile)
            hex = action.hex
            @little_miami_new_exits ||= {}
            @little_miami_new_exits[hex.id] = hex.tile.exits.dup - @little_miami_before_exits[hex.id]

            if @little_miami_hexes_laid == [hex]
              raise GameError, 'Cannot lay and upgrade a tile in the same hex with Little Miami'
            end

            @little_miami_hexes_laid << hex
          end

          return if abilities(little_miami, :tile_lay)

          check_little_miami_graph_after!
          remove_icons(self.class::LITTLE_MIAMI_HEXES, self.class::ABILITY_ICONS[little_miami.id])
        end

        def check_little_miami_graph_before!
          return if loading

          graph = compute_little_miami_graph
          reached_hexes = graph.connected_nodes(little_miami_router).select { |_k, v| v }.keys.map { |n| n.hex.id }

          return unless (LITTLE_MIAMI_HEXES & reached_hexes) == LITTLE_MIAMI_HEXES

          raise GameError, "#{LITTLE_MIAMI_HEXES.join(' and ')} are already connected, cannot use Little Miami"
        end

        def check_little_miami_graph_after!
          return if loading

          graph = compute_little_miami_graph
          reached_hexes = graph.connected_nodes(little_miami_router).select { |_k, v| v }.keys.map { |n| n.hex.id }
          if (LITTLE_MIAMI_HEXES & reached_hexes) != LITTLE_MIAMI_HEXES
            raise GameError, "#{LITTLE_MIAMI_HEXES.join(' and ')} must be connected after using Little Miami"
          end

          new_paths_by_hex = @little_miami_new_exits.map do |hex_id, exits|
            paths = exits.flat_map do |exit|
              graph.connected_paths(little_miami_router).keys.select do |path|
                path.hex.id == hex_id && path.exits.include?(exit)
              end
            end
            [hex_id, paths]
          end

          return if new_paths_by_hex.all? do |hex_id, new_paths_on_hex|
            little_miami_a_new_path_used_for_connection?(hex_id, new_paths_on_hex)
          end

          raise GameError, 'Some new track on each tile laid by Little Miami must '\
                           "be used to connect #{LITTLE_MIAMI_HEXES.join(' and ')}"
        end

        def little_miami_a_new_path_used_for_connection?(hex_id, new_paths)
          node = hex_by_id(hex_id).tile.cities.first

          other_hex_id = LITTLE_MIAMI_HEXES.find { |h| h != hex_id }
          other_node = hex_by_id(other_hex_id).tile.cities.first

          node.walk do |_path, visited_paths, visited_nodes|
            return true if visited_nodes[other_node] && new_paths.any? { |p| visited_paths[p] }
          end

          false
        end

        def purchasable_companies(entity = nil)
          return [] if entity&.minor?

          super
        end

        def unowned_purchasable_companies
          @round.is_a?(Engine::Round::Draft) ? @companies.reject { |c| c.name.start_with?('Pass') }.sort_by(&:name) : []
        end

        def show_company_owners?
          !@round.is_a?(Engine::Round::Draft)
        end
      end
    end
  end
end
