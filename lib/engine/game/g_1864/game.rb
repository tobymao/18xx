# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'union_pacific'
require_relative 'round/merger'
require_relative 'round/operating'
require_relative 'step/assign'
require_relative 'step/buy_sell_par_shares'
require_relative 'step/buy_train'
require_relative 'step/dividend'
require_relative 'step/discard_train'
require_relative 'step/merge'
require_relative 'step/reduce_tokens'
require_relative 'step/route'
require_relative 'step/special_token'
require_relative 'step/track'
require_relative 'step/up_shares'
require_relative '../g_1861/game'
require_relative '../g_1861/step/token'
require_relative '../g_1867/game'

module Engine
  module Game
    module G1864
      class Game < G1867::Game
        include_meta(G1864::Meta)
        include Entities
        include Map
        include UnionPacific

        GREEN_CORPORATIONS = G1861::Game::GREEN_CORPORATIONS

        CERT_LIMIT = { 2 => 31, 3 => 21, 4 => 16, 5 => 13, 6 => 11 }.freeze
        STARTING_CASH = { 2 => 530, 3 => 353, 4 => 265, 5 => 212, 6 => 176 }.freeze

        BONUS_CAPITALS = [].freeze
        BONUS_REVENUE = nil

        UP_OPERATES_PHASE = 4
        LAST_EXPORT_PHASE = 7
        OWNERSHIP_LIMIT_PHASE = 6
        REMOVE_ABILITIES_PHASE = 6
        OWNERSHIP_LIMIT = { 2 => 70, 3 => 60, 4 => 60, 5 => 60, 6 => 60 }.freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'national_operates' => ['Union Pacific operates',
                                  'The Union Pacific runs the trains on its consist card and pays a full dividend'],
          'export_train' => ['Train Export',
                             'At the end of each OR the next available train is exported and removed from the game'],
          'no_ownership_limit' => ['No ownership limit',
                                   'Players may buy shares beyond 60% (70% with 2 players) of a major company'],
        )

        PHASES = G1861::Game::PHASES.map do |phase|
          number = phase[:name].to_i
          status = (phase[:status] || []) - ['can_buy_companies']
          status |= ['national_operates'] if number >= UP_OPERATES_PHASE
          status |= ['export_train'] if number.between?(UP_OPERATES_PHASE, LAST_EXPORT_PHASE)
          status << (number >= OWNERSHIP_LIMIT_PHASE ? 'ownership_limit' : 'no_ownership_limit')
          phase.merge(status: status)
        end.freeze

        TRAIN_EVENTS = {
          '4' => %w[majors_can_ipo trainless_regionalization up_operates close_credit_mobilier],
          '5' => %w[minors_cannot_start open_tunnels],
          '6' => %w[trainless_regionalization remove_minor_abilities up_ipo_purchasable ownership_limit],
          '8' => %w[minors_regionalized trainless_regionalization train_trade_allowed],
        }.freeze

        PULLMAN = 'Pullman'

        TRAINS = (G1867::Game::TRAINS.map do |train|
          events = TRAIN_EVENTS[train[:name]]
          events ? train.merge(events: events.map { |type| { 'type' => type } }) : train
        end + [{ name: PULLMAN, distance: 0, price: 0, num: 1, rusts_on: '6', reserved: true }]).freeze

        EVENTS_TEXT = G1867::Game::EVENTS_TEXT.except(
          'minors_nationalized', 'nationalize_companies', 'trainless_nationalization'
        ).merge(
          'minors_regionalized' => ['Minors are regionalized'],
          'trainless_regionalization' => ['Trainless Regionalization',
                                          'Operating trainless minors are regionalized, '\
                                          'operating trainless majors may regionalize'],
          'up_operates' => ['Union Pacific operates',
                            'The Union Pacific begins running trains from its consist card in the next Operating Round'],
          'close_credit_mobilier' => ['Crédit Mobilier closes',
                                      'The Crédit Mobilier Company ceases operations and returns its money to the Bank'],
          'open_tunnels' => ['Tunnels open',
                             'The Moffat Tunnel and Lucin Cutoff through-routes become available'],
          'remove_minor_abilities' => ['Minor abilities removed',
                                       'Minor Company Ability cards, and any Union/Central Station tokens, are removed'],
          'up_ipo_purchasable' => ['Union Pacific shares purchasable',
                                   'Union Pacific IPO shares may be bought in Stock Rounds'],
        )

        UP_TILE_RESERVATIONS = { 'X4' => 1, '639' => 3, '641' => 2 }.freeze
        BAILEY_YARD_TILES = { yellow: 'X6', brown: 'X7', gray: 'X8' }.freeze
        BAILEY_YARD_GRAY_PHASE = 7

        EAST_WEST_BONUSES = [
          [['Great Lakes'], ['Seattle']],
          [['New Orleans'], ['Los Angeles']],
          [['St. Louis', 'Chicago'], ['San Francisco']],
        ].freeze
        EAST_WEST_BONUS = 80

        FORTY_NINER_ROUTE = ['Chicago', 'Omaha', 'Cheyenne', 'Salt Lake', 'San Francisco'].freeze
        FORTY_NINER_BONUS = 120

        NORTH_GROUPS = %w[Canada GreatLakes].freeze
        SOUTH_GROUPS = %w[Mexico NewOrleans].freeze
        NORTH_SOUTH_BONUS = 80

        LOCAL_CONTRACT_BONUS = 10
        ASSIGNMENT_TOKENS = {
          'LC1' => '/icons/1864/local_contract.svg',
          'LC2' => '/icons/1864/local_contract.svg',
        }.freeze
        TRACK_BUILDERS = %w[TB1 TB2].freeze
        PULLMAN_TOWNS = 2
        EARLY_ADOPTER_PRICE = 100
        ANGEL_INVESTMENT = 60

        attr_reader :union_pacific, :future_corporations, :credit_mobilier, :up_consist, :pending_up_share_buyers

        def setup
          @interest = {}
          @pending_up_share_buyers = []
          @pending_regionalizations = []
          @extra_station_tokens = {}
          @local_contract_tokens = {}
          @credit_mobilier = minor_by_id('CM')

          setup_future_corporations!
          setup_union_pacific!
          update_ownership_limits!
          setup_ownership_limit_text!
          deal_ability_cards!
          reserve_ability_train!('EA1', '2')
          reserve_ability_train!('PC1', PULLMAN)
          place_tunnel_phase_icons!
          deal_up_consists!
        end

        def game_corporations
          corporations = super
          return corporations unless @optional_rules.include?(:no_starting_locations)

          corporations.map { |corporation| corporation[:type] == 'minor' ? corporation.except(:coordinates, :city) : corporation }
        end

        def game_trains
          trains = super
          return trains if @optional_rules.include?(:train_trade_in)

          trains.map do |train|
            events = train[:events]&.reject { |event| event['type'] == 'train_trade_allowed' }
            train.except(:discount).merge(events: events)
          end
        end

        def ownership_limit
          @phase.status.include?('ownership_limit') ? OWNERSHIP_LIMIT[@players.size] : 100
        end

        def setup_ownership_limit_text!
          limit = OWNERSHIP_LIMIT[@players.size]
          STATUS_TEXT['ownership_limit'] = ["#{limit}% ownership limit",
                                            "Players may not buy shares that take them above #{limit}% of a major company; "\
                                            'holdings already above the limit need not be sold']
          EVENTS_TEXT['ownership_limit'] = ["#{limit}% ownership limit",
                                            "Players may no longer buy shares that take them above #{limit}% of a major company"]
        end

        def update_ownership_limits!
          (@corporations + @future_corporations).each do |corporation|
            corporation.max_ownership_percent = ownership_limit if corporation.type == :major
          end
        end

        def setup_up_tile_reservations!
          UP_TILE_RESERVATIONS.each do |tile_name, slot|
            [@tiles, @all_tiles].each do |tile_set|
              tile = tile_set.find { |t| t.name == tile_name }
              tile.add_reservation!(@union_pacific, 0, slot)
            end
          end
        end

        def place_tunnel_phase_icons!
          TUNNEL_TILES.each_key do |hex_id|
            hex_by_id(hex_id).tile.icons << Engine::Part::Icon.new('1864/phase_5_plus', 'phase_5_plus', true, nil, true,
                                                                   large: true)
          end
        end

        def decorate_marker(icon)
          return { shape: :none } if icon.name == 'phase_5_plus'

          super
        end

        def deal_ability_cards!
          early_adopter, rest = @companies.partition { |c| c.id == 'EA1' }
          rest = rest.sort_by { rand }
          deck = (rest.shift(9) + early_adopter).sort_by { rand } + rest

          minors = (@corporations + @future_corporations).select { |c| c.type == :minor }
          @ability_card_deal = minors.zip(deck)
          @ability_card_deal.each do |minor, company|
            company.owner = minor
            minor.companies << company
          end
        end

        def show_map_legend?
          @phase.name.to_i < REMOVE_ABILITIES_PHASE
        end

        def map_legends
          [:minor_ability_legend]
        end

        def minor_ability_legend(font_color, *_extra_colors)
          cell = { border: "1px solid #{font_color}", padding: '0 0.3rem' }
          [
            { style: { margin: '0.5rem 0', border: '1px solid', borderCollapse: 'collapse' } },
            %w[Minor Home Ability Effect].map { |text| { text: text, props: { style: cell } } },
            *@ability_card_deal.map do |minor, company|
              next if minor.closed?

              [
                { text: minor.id, props: { style: cell.merge(backgroundColor: minor.color, color: minor.text_color) } },
                { text: minor_home_name(minor), props: { style: cell } },
                { text: company.name, props: { style: cell } },
                { text: company.desc, props: { style: cell } },
              ]
            end.compact,
          ]
        end

        def minor_home_name(minor)
          hex_id = minor.coordinates || minor.tokens.first&.hex&.id
          hex_id ? location_name(hex_id) : ''
        end

        def reserve_ability_train!(company_id, train_name)
          company = company_by_id(company_id)
          minor = company.owner
          train = @depot.upcoming.find { |t| t.name == train_name }
          @depot.remove_train(train)
          train.owner = minor
          train.buyable = false
          minor.trains << train
          @log << "#{minor.name} receives a #{train_name} train from #{company.name}"
        end

        def activate_minor_power!(corporation)
          corporation.trains.each { |train| train.buyable = true }
          corporation.companies.dup.each do |company|
            case company.id
            when 'AI1', 'AI2'
              @bank.spend(ANGEL_INVESTMENT, corporation)
              @log << "#{corporation.name} receives #{format_currency(ANGEL_INVESTMENT)} from #{company.name}"
              company.close!
            when 'EA1'
              corporation.spend(EARLY_ADOPTER_PRICE, @bank)
              @log << "#{corporation.name} pays #{format_currency(EARLY_ADOPTER_PRICE)} for its #{company.name} 2-train"
              company.close!
            when 'PC1'
              company.close!
            end
          end
        end

        def place_up_reserved_token!(tile)
          return if tile.cities.any? { |city| city.tokened_by?(@union_pacific) }

          city = tile.cities.find { |c| c.reserved_by?(@union_pacific) }
          return unless city
          return unless (token = @union_pacific.next_token)

          city.place_token(@union_pacific, token, check_tokenable: false)
          @log << "#{@union_pacific.name} places a station in #{tile.hex.location_name}"
        end

        def upgrades_to_correct_color?(from, to, selected_company: nil)
          return true if from.name == BAILEY_YARD_TILES[:yellow] && to.name == BAILEY_YARD_TILES[:brown]

          super
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return false if to.name == BAILEY_YARD_TILES[:gray] && @phase.name.to_i < BAILEY_YARD_GRAY_PHASE

          super
        end

        def ability_card?(entity, *ids)
          entity.respond_to?(:companies) && entity.companies.any? { |c| ids.include?(c.id) }
        end

        def track_builder?(entity)
          ability_card?(entity, *TRACK_BUILDERS)
        end

        def pullman?(train)
          train.name == PULLMAN
        end

        def num_pullman_towns
          PULLMAN_TOWNS
        end

        def compute_stops(route)
          stops = super
          town_pay = route.train.distance.sum { |h| h['nodes'] == ['town'] ? h['pay'] : 0 }
          return stops if !stops || town_pay.zero?

          towns = (route.visited_stops - stops).select(&:town?)
          towns.combination([town_pay, towns.size].min).map { |combo| stops + combo }.max_by { |s| revenue_for(route, s) }
        end

        def route_trains(entity)
          super.reject { |train| pullman?(train) }
        end

        def num_corp_trains(entity)
          super - entity.trains.count { |train| pullman?(train) }
        end

        def trainless?(corporation)
          corporation.trains.all? { |train| pullman?(train) }
        end

        def must_buy_train?(entity)
          trainless?(entity) && !depot.depot_trains.empty?
        end

        def can_hold_above_corp_limit?(_entity)
          true
        end

        def check_overlap(routes)
          return super unless ability_card?(routes.first&.corporation, 'DT1')
          return if routes.size <= 2

          shared = routes.combination(2).any? do |pair|
            pair.all? do |route|
              super(routes - [route])
              true
            rescue GameError
              false
            end
          end
          raise GameError, 'Only two trains may share track' unless shared
        end

        def compute_other_paths(routes, route)
          return [] if ability_card?(route.corporation, 'DT1')

          super
        end

        def revenue_for(route, stops)
          super + route_bonus(stops) + (local_contract_bonus(stops) * (route.train.multiplier || 1))
        end

        def route_bonus(stops)
          names = stops.map { |stop| location_name(stop.hex.id) }.compact
          groups = stops.flat_map(&:groups)

          bonus = EAST_WEST_BONUSES.count { |east, west| (names & east).any? && (names & west).any? } * EAST_WEST_BONUS
          bonus += NORTH_SOUTH_BONUS if (groups & NORTH_GROUPS).any? && (groups & SOUTH_GROUPS).any?
          bonus += FORTY_NINER_BONUS if (FORTY_NINER_ROUTE - names).empty?
          bonus
        end

        def local_contract_bonus(stops)
          contract_cities = @local_contract_tokens.values.map(&:city)
          stops.count { |stop| contract_cities.include?(stop) } * LOCAL_CONTRACT_BONUS
        end

        def place_local_contract!(company, city)
          token = Token.new(nil, logo: assignment_tokens(company.id))
          city.exchange_token(token, extra_slot: true)
          @local_contract_tokens[company.id] = token
        end

        def record_extra_station!(company, token)
          @extra_station_tokens[company.id] = token
        end

        def forget_extra_station!(company)
          @extra_station_tokens.delete(company.id)
        end

        def extra_station?(token)
          @extra_station_tokens.value?(token)
        end

        def attach_extra_stations!(corporation)
          extra_stations(corporation).each do |_company, token|
            corporation.tokens << token unless corporation.tokens.include?(token)
          end
        end

        def extra_stations(corporation)
          @extra_station_tokens.filter_map do |id, token|
            [company_by_id(id), token] if token.used && token.corporation == corporation
          end
        end

        def close_ability_card!(company)
          remove_extra_station!(company)
          @local_contract_tokens.delete(company.id)&.remove!
          company.close!
        end

        def remove_extra_station!(company)
          return unless (token = @extra_station_tokens.delete(company.id))&.used

          owner = token.corporation
          location = token.city.hex.location_name
          token.destroy!
          clear_graph_for_entity(owner)
          @log << "#{owner.name}'s #{company.name} in #{location} is removed"
        end

        def operating_order
          super.reject { |corporation| corporation == @union_pacific && !up_operating? }
        end

        def unstarted_corporation_summary
          summary, (union_pacific, *corporations) = super
          bank_held = [(union_pacific unless union_pacific.owner), (@credit_mobilier unless @credit_mobilier.closed?)]
          [summary, bank_held.compact + corporations]
        end

        def init_round
          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter += 1
          stock_round
        end

        def or_round_finished
          super
          start_up_operations!
        end

        def event_close_credit_mobilier!
          return if @credit_mobilier.closed?

          if @credit_mobilier.cash.positive?
            @log << "Crédit Mobilier closes, returning #{format_currency(@credit_mobilier.cash)} to the Bank"
            @credit_mobilier.spend(@credit_mobilier.cash, @bank)
          else
            @log << 'Crédit Mobilier closes'
          end
          @credit_mobilier.close!
        end

        def event_open_tunnels!
          @log << '-- Event: the Moffat Tunnel and Lucin Cutoff are now open --'
          self.class::TUNNEL_TILES.each do |hex_id, tile_name|
            tile = @tiles.find { |t| t.name == tile_name }
            next unless tile

            @tiles.delete(tile)
            hex_by_id(hex_id).lay(tile)
          end
          @graph.clear_graph_for_all
        end

        def event_remove_minor_abilities!
          @log << '-- Event: Minor Company Abilities are removed from the game --'
          @companies.each { |company| close_ability_card!(company) unless company.closed? }
        end

        def event_ownership_limit!
          @log << "-- Event: Players may no longer buy shares beyond #{ownership_limit}% of a major company --"
          update_ownership_limits!
        end

        def reset_corporation(corporation)
          corp = super
          corp.max_ownership_percent = ownership_limit
          corp
        end

        def setup_for_2_players
          self.class::TRAINS_REMOVE_2_PLAYER.each do |train_name, count|
            trains = depot.upcoming.select { |t| t.name == train_name }.reverse.take(count)
            trains.each { |t| depot.forget_train(t) }
          end
        end

        def event_green_minors_available!
          @log << 'Green minors are now available'
          @corporations += @future_corporations
          @future_corporations = []
        end

        def pay_credit_mobilier(amount, from:)
          return if @credit_mobilier.closed? || !amount.positive?

          from.spend(amount, @credit_mobilier)
        end

        def distribute_credit_mobilier!
          return if @credit_mobilier.closed?

          per_player = (@credit_mobilier.cash.to_f / @players.size).floor
          return unless per_player.positive?

          @players.each { |player| @credit_mobilier.spend(per_player, player) }
          @log << "Crédit Mobilier pays #{format_currency(per_player)} to each player"\
                  " (#{format_currency(@credit_mobilier.cash)} remains)"
        end

        def new_merger_round
          distribute_credit_mobilier!
          super
        end

        def companies_to_payout(ignore: [])
          super.select { |company| company.owner.floated? }
        end

        def nationalization_loan_movement(corporation)
          corporation.loans.each { stock_market.move_left(corporation) }
        end

        def nationalization_transfer_assets(corporation)
          corporation.companies.dup.each do |company|
            @log << "#{company.name} is removed from the game"
            forget_extra_station!(company)
            close_ability_card!(company)
          end

          corporation.trains.dup.each do |train|
            @log << "#{corporation.name}'s #{train.name} train is removed from the game"
            @depot.forget_train(train)
          end
          corporation.trains.clear

          corporation.spend(corporation.cash, @bank, check_positive: false) if corporation.cash.positive?
        end

        def nationalize!(corporation)
          return if !corporation.floated? || !@corporations.include?(corporation)
          return @pending_regionalizations << corporation unless @pending_up_share_buyers.empty?

          buyers = up_share_buyers(corporation)
          super
          @pending_up_share_buyers.concat(buyers)
          return if corporation.type != :major || !@round.is_a?(Engine::Round::Operating)

          @round.force_next_entity! if @round.current_operator == corporation
        end

        def regionalize_pending!
          nationalize!(@pending_regionalizations.shift) while @pending_up_share_buyers.empty? && @pending_regionalizations.any?
        end

        def nationalize_verb
          'regionalize'
        end

        def event_minors_regionalized!
          minors = @corporations.select { |c| c.type == :minor }
          return if minors.empty?

          @log << "Minors #{nationalize_verb}d"
          @corporations -= minors.reject(&:floated?)
          minors.select(&:floated?).sort.each { |c| nationalize!(c) }
        end

        def event_trainless_regionalization!
          event_trainless_nationalization!
        end

        def corporation_show_individual_reserved_shares?
          false
        end

        def train_limit(entity)
          return entity.trains.size + 1 if deregulated?

          super
        end

        def deregulated?
          return false unless @optional_rules&.include?(:deregulation)

          !@final_turn.nil? && @turn >= @final_turn
        end

        def stock_round
          G1867::Round::Stock.new(self, [
            G1864::Step::UPShares,
            G1867::Step::MajorTrainless,
            G1864::Step::DiscardTrain,
            G1867::Step::HomeToken,
            G1864::Step::BuySellParShares,
          ])
        end

        def merger_round
          G1864::Round::Merger.new(self, [
            G1864::Step::UPShares,
            G1867::Step::MajorTrainless,
            G1864::Step::ReduceTokens,
            G1867::Step::PostMergerShares,
            G1864::Step::DiscardTrain,
            G1864::Step::Merge,
          ], round_num: @round.round_num)
        end

        def operating_round(round_num)
          calculate_interest
          G1864::Round::Operating.new(self, [
            G1864::Step::UPShares,
            G1867::Step::MajorTrainless,
            G1867::Step::RedeemShares,
            G1864::Step::SpecialToken,
            G1864::Step::Track,
            G1861::Step::Token,
            G1864::Step::Assign,
            G1864::Step::Route,
            G1864::Step::Dividend,
            G1867::Step::LoanOperations,
            G1864::Step::DiscardTrain,
            G1864::Step::BuyTrain,
          ], round_num: round_num)
        end
      end
    end
  end
end
