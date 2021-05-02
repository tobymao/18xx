# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
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

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f')

        CURRENCY_FORMAT_STR = '$%d'

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
              { 'type' => 'remove_markers' },
              { 'type' => 'remove_reservations' },
            ],
          },
        ].freeze

        POOL_SHARE_DROP = :one
        SELL_AFTER = :p_any_operate
        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :left_block_pres
        EBUY_OTHER_VALUE = false
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        HOME_TOKEN_TIMING = :float
        MUST_BUY_TRAIN = :always
        CERT_LIMIT_COUNTS_BANKRUPTED = true
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        ORANGE_GROUP = [
          'Lake Shore Line',
          'Michigan Central',
          'Ohio & Indiana',
        ].freeze

        BLUE_GROUP = [
          'Steamboat Company',
          'Meat Packing Company',
          'Tunnel Blasting Company',
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
        LSL_ICON = 'lsl'

        MEAT_HEXES = %w[D6 I1].freeze
        STEAMBOAT_HEXES = %w[B8 C5 D14 I1 G19].freeze

        MEAT_REVENUE_DESC = 'Meat-Packing'

        TILE_COST = 20
        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_markers' => ['Remove Markers', 'Remove Steamboat and Meat Packing markers'],
          'remove_reservations' => ['Remove Reservations', 'Remove reserved token slots for corporations']
        ).freeze

        ASSIGNMENT_TOKENS = {
          'MPC' => '/icons/1846/mpc_token.svg',
          'SC' => '/icons/1846/sc_token.svg',
        }.freeze

        # Two tiles can be laid, only one upgrade
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded }].freeze

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def corporation_opts
          two_player? ? { max_ownership_percent: 70 } : {}
        end

        def init_companies(players)
          super + Array.new(num_pass_companies(players)) do |i|
            name = "Pass (#{i + 1})"

            Company.new(
              sym: name,
              name: name,
              value: 0,
              desc: "Choose this card if you don't want to purchase any of the offered companies this turn.",
            )
          end
        end

        def num_pass_companies(players)
          two_player? ? 0 : players.size
        end

        def setup
          @turn = setup_turn

          # When creating a game the game will not have enough to start
          return unless @players.size.between?(*self.class::PLAYER_RANGE)

          remove_from_group!(self.class::ORANGE_GROUP, @companies) do |company|
            remove_lsl_icons if company == lake_shore_line
            company.close!
            @round.active_step.companies.delete(company)
          end
          remove_from_group!(self.class::BLUE_GROUP, @companies) do |company|
            company.close!
            @round.active_step.companies.delete(company)
          end

          corporation_removal_groups.each do |group|
            remove_from_group!(group, @corporations) do |corporation|
              place_home_token(corporation)
              abilities(corporation, :reservation) do |ability|
                corporation.remove_ability(ability)
              end
              place_second_token(corporation)
            end
          end

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

        def setup_turn
          two_player? ? 0 : 1
        end

        def remove_from_group!(group, entities)
          removals = group.sort_by { rand }.take(num_removals(group))
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

        def num_removals(_group)
          two_player? ? 1 : 5 - @players.size
        end

        def corporation_removal_groups
          two_player? ? [NORTH_GROUP, SOUTH_GROUP] : [GREEN_GROUP]
        end

        def place_second_token(corporation, two_player_only: true, cheater: 1)
          return if two_player_only && !two_player?

          hex_id = self.class::REMOVED_CORP_SECOND_TOKEN[corporation.id]
          token = corporation.find_token_by_type
          hex_by_id(hex_id).tile.cities.first.place_token(corporation, token, check_tokenable: false, cheater: cheater)
          @log << "#{corporation.id} places a token on #{hex_id}"
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

          meat = meat_packing.id
          revenue += 30 if route.corporation.assigned?(meat) && stops.any? { |stop| stop.hex.assigned?(meat) }

          steam = steamboat.id
          if route.corporation.assigned?(steam) && (port = stops.map(&:hex).find { |hex| hex.assigned?(steam) })
            revenue += 20 * port.tile.icons.count { |icon| icon.name == 'port' }
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

          meat = meat_packing.id
          str += " + #{self.class::MEAT_REVENUE_DESC}" if route.corporation.assigned?(meat) && stops.any? do |stop|
                                                            stop.hex.assigned?(meat)
                                                          end

          steam = steamboat.id
          str += ' + Port' if route.corporation.assigned?(steam) && (stops.map(&:hex).find do |hex|
                                                                       hex.assigned?(steam)
                                                                     end)

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

        def illinois_central
          @illinois_central ||= corporation_by_id('IC')
        end

        def preprocess_action(action)
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

          super

          @last_action = action
        end

        def special_tile_lay?(action)
          (action.is_a?(Action::LayTile) &&
           (action.entity == michigan_central || action.entity == ohio_indiana))
        end

        def psuedo_special_tile_lay?(action)
          (action.is_a?(Action::LayTile) &&
           (action.entity == michigan_central&.owner || action.entity == ohio_indiana&.owner))
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
          [TILE_COST, super].max
        end

        def event_close_companies!
          @minors.dup.each { |minor| close_corporation(minor) }
          remove_lsl_icons
          remove_steamboat_markers! unless steamboat.owned_by_corporation?
          super
        end

        def remove_steamboat_markers!
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
        end

        def event_remove_markers!
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

          (self.class::MEAT_HEXES + self.class::STEAMBOAT_HEXES).uniq.each do |hex|
            hex_by_id(hex).tile.icons.reject! do |icon|
              %w[meat port].include?(icon.name)
            end
          end

          removals.each do |company, removal|
            hex = removal[:hex]
            corp = removal[:corporation]
            @log << "-- Event: #{corp}'s #{company_by_id(company).name} token removed from #{hex} --"
          end
        end

        def remove_lsl_icons
          self.class::LSL_HEXES.each do |hex|
            hex_by_id(hex).tile.icons.reject! { |icon| icon.name == self.class::LSL_ICON }
          end
        end

        def sellable_bundles(player, corporation)
          return [] if corporation.receivership?

          super
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
            begin
              values = super.dup # get copy of GAME_END_CHECK that is not frozen
              values[:final_train] = :one_more_full_or_set if two_player?
              values
            end
        end

        def east_west_desc
          'E/W'
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
      end
    end
  end
end
