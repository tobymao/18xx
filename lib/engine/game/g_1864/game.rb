# frozen_string_literal: true

require_relative 'credit_mobilier'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'union_pacific'
require_relative 'round/operating'
require_relative 'step/assign'
require_relative 'step/buy_sell_par_shares'
require_relative 'step/buy_train'
require_relative 'step/dividend'
require_relative 'step/route'
require_relative 'step/token'
require_relative 'step/track'
require_relative 'step/up_shares'
require_relative '../g_1867/game'

module Engine
  module Game
    module G1864
      class Game < G1867::Game
        include_meta(G1864::Meta)
        include Entities
        include Map
        include UnionPacific

        GREEN_CORPORATIONS = %w[MB Y V TR SV E].freeze

        CERT_LIMIT = { 2 => 31, 3 => 21, 4 => 16, 5 => 13, 6 => 11 }.freeze
        STARTING_CASH = { 2 => 530, 3 => 353, 4 => 265, 5 => 212, 6 => 176 }.freeze

        OMAHA_HEX = 'F27'
        CHEYENNE_HEX = 'F19'
        NATIONAL_RESERVATIONS = [OMAHA_HEX, CHEYENNE_HEX].freeze

        UP_OPERATES_PHASE = 4

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'national_operates' => ['Union Pacific operates',
                                  'The Union Pacific runs the trains on its consist card and pays a full dividend'],
          'export_train' => ['Train Export',
                             'At the end of each OR the next available train is exported and removed from the game'],
        ).freeze

        PHASES = G1861::Game::PHASES.map do |phase|
          status = (phase[:status] || []) - ['can_buy_companies']
          status |= %w[national_operates export_train] if phase[:name].to_i >= UP_OPERATES_PHASE
          status.empty? ? phase.except(:status) : phase.merge(status: status)
        end.freeze

        TRAIN_EVENTS = {
          '4' => %w[majors_can_ipo trainless_nationalization up_operates close_credit_mobilier],
          '5' => %w[minors_cannot_start open_tunnels],
          '6' => %w[trainless_nationalization remove_minor_abilities up_ipo_purchasable enforce_ownership_limit],
        }.freeze

        TRAINS = G1867::Game::TRAINS.map do |train|
          events = TRAIN_EVENTS[train[:name]]
          events ? train.merge(events: events.map { |type| { 'type' => type } }) : train
        end.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'up_operates' => ['Union Pacific operates',
                            'The Union Pacific begins running trains from its consist card'],
          'close_credit_mobilier' => ['Credit Mobilier closes',
                                      'The Credit Mobilier private company closes'],
          'open_tunnels' => ['Tunnels open',
                             'The Moffat Tunnel and Lucin Cutoff through-routes become available'],
          'remove_minor_abilities' => ['Minor abilities removed',
                                       'Minor corporations lose their special abilities'],
          'up_ipo_purchasable' => ['Union Pacific shares purchasable',
                                   'Union Pacific treasury shares become available for purchase'],
          'enforce_ownership_limit' => ['Ownership limit enforced',
                                        'The certificate ownership limit is now enforced'],
        ).freeze

        attr_reader :union_pacific, :future_corporations, :credit_mobilier, :up_consist, :pending_up_share_buyers

        def setup
          @interest = {}
          @show_majors = false
          @national_reservations = self.class::NATIONAL_RESERVATIONS.dup
          @credit_mobilier = CreditMobilier.new
          @pending_up_share_buyers = []
          @up_ipo_open = false
          @local_contracts = {}
          @pullman_bonus_used = false
          @additional_station_tokens = []

          @union_pacific = @national = @corporations.find { |c| c.type == :national }
          @corporations.delete(@national)
          @national.ipoed = true
          share_price = stock_market.market.flatten.compact.find { |sp| sp.price == 80 }
          stock_market.set_par(@national, share_price)

          @corporations, @future_corporations = @corporations.partition do |corporation|
            corporation.type == :minor && !self.class::GREEN_CORPORATIONS.include?(corporation.id)
          end

          (@corporations + @future_corporations).each do |corporation|
            corporation.max_ownership_percent = 100 if corporation.type == :major
          end
          @union_pacific.max_ownership_percent = 60
          @ownership_limited = false

          deal_ability_cards!
          grant_additional_station_tokens!
          place_up_home_token!
          setup_up_tile_reservations!
          place_tunnel_phase_icons!

          decks = UnionPacific::CONSIST_DECKS.values
          @up_consist = UnionPacific::PHASES_WITH_CONSISTS.to_h do |phase|
            [phase, decks[rand % decks.size][phase]]
          end
        end

        UP_TILE_RESERVATIONS = { 'X4' => 1, '639' => 3, '641' => 2 }.freeze

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
          early = @companies.find { |c| c.sym == 'EA1' }
          rest = @companies.reject { |c| c.sym == 'EA1' }.sort_by { rand }
          deck = rest.dup
          deck.insert(rand % 10, early)

          minors = (@corporations + @future_corporations).select { |c| c.type == :minor }
          minors.zip(deck).each do |minor, company|
            company.owner = minor
            minor.companies << company
          end
        end

        def place_up_home_token!
          hex = hex_by_id(OMAHA_HEX)
          return unless hex
          return unless (token = @union_pacific.next_token)

          @national_reservations.delete(hex.id)
          hex.tile.cities.last.place_token(@union_pacific, token, check_tokenable: false)
          @log << "#{@union_pacific.name} places a station in #{location_name(hex.id)}"
        end

        def grant_additional_station_tokens!
          (@corporations + @future_corporations).each do |corporation|
            abilities(corporation, :additional_token) do |ability|
              token = Engine::Token.new(corporation, price: extra_token_price(corporation))
              corporation.tokens << token
              @additional_station_tokens << token
              ability.use!
              @log << "#{corporation.name} receives an additional station token from #{ability.owner.name}"
            end
          end
        end

        def remove_additional_station_tokens!
          @additional_station_tokens.each(&:destroy!)
          @additional_station_tokens.clear
        end

        def extra_token_price(corporation)
          corporation.companies.any? { |c| EXTRA_STATION_CARDS.include?(c.name) } ? 10 : 0
        end

        def double_tracks?(corporation)
          corporation.respond_to?(:companies) &&
            corporation.companies.any? { |c| c.name == DOUBLE_TRACKS }
        end

        def pullman_car?(corporation)
          corporation.respond_to?(:companies) &&
            corporation.companies.any? { |c| c.name == PULLMAN_CAR }
        end

        def check_overlap(routes)
          return if double_tracks?(routes.first&.corporation)

          super
        end

        def reset_pullman_bonus!
          @pullman_bonus_used = false
        end

        def compute_stops(route)
          stops = super
          return stops if stops.empty? || @pullman_bonus_used || !pullman_car?(route.corporation)

          extra_towns = (route.visited_stops - stops).select(&:town?).first(2)
          return stops if extra_towns.empty?

          @pullman_bonus_used = true
          stops + extra_towns
        end

        def local_contract_bonus(corporation, stop)
          return 0 unless @local_contracts[corporation] == stop.hex.id

          10
        end

        BONUS_PAIRS = [
          ['Great Lakes', 'Seattle'],
          ['New Orleans', 'Los Angeles'],
          ['St. Louis', 'San Francisco'],
          ['Chicago', 'San Francisco'],
        ].freeze
        PAIR_BONUS = 80

        FORTY_NINER_ROUTE = ['Chicago', 'Omaha', 'Cheyenne', 'Salt Lake', 'San Francisco'].freeze
        FORTY_NINER_BONUS = 120

        NORTH_HEXES = %w[A16 B27].freeze
        SOUTH_HEXES = %w[L11 K28].freeze
        NORTH_SOUTH_BONUS = 80

        def bonus_multiplier
          1
        end

        def revenue_for(route, stops)
          revenue = stops.sum { |stop| stop.route_revenue(route.phase, route.train) }

          raise GameError, 'Route visits same hex twice' if route.hexes.size != route.hexes.uniq.size

          names = stops.map { |stop| location_name(stop.hex.id) }.compact
          hex_ids = stops.map { |stop| stop.hex.id }

          revenue += BONUS_PAIRS.count { |a, b| names.include?(a) && names.include?(b) } * PAIR_BONUS
          revenue += NORTH_SOUTH_BONUS if hex_ids.any? { |id| NORTH_HEXES.include?(id) } &&
                                          hex_ids.any? { |id| SOUTH_HEXES.include?(id) }
          revenue += FORTY_NINER_BONUS if FORTY_NINER_ROUTE.all? { |city| names.include?(city) }

          revenue + stops.sum { |stop| local_contract_bonus(route.corporation, stop) }
        end

        def local_contract_placed?(company)
          @local_contracts.key?(company.owner)
        end

        def local_contract_hexes(company)
          corporation = company.owner
          return [] unless corporation.respond_to?(:tokens)

          corporation.tokens.select(&:used).map { |token| token.city.tile.hex }.compact.uniq
        end

        def place_local_contract!(company, hex)
          corporation = company.owner
          @local_contracts[corporation] = hex.id
          location = hex.location_name.to_s.empty? ? '' : " (#{hex.location_name})"
          @log << "#{company.name} places its +$10 marker on #{hex.id}#{location}"
        end

        def ability_card_for(corporation)
          corporation.companies.first
        end

        def all_corporations
          @corporations + [@national]
        end

        def operating_order
          minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
          majors << @national if up_operating?
          minors + majors.sort
        end

        def operated_operators
          (@corporations + [@national]).select(&:operated?)
        end

        def float_corporation(corporation)
          super

          corporation.companies.each do |company|
            case company.name
            when ANGEL_INVESTORS
              @bank.spend(60, corporation)
              @log << "#{corporation.name} receives #{format_currency(60)} from Angel Investors"
            when EARLY_ADOPTER
              train = @depot.upcoming.find { |t| t.name == '2' }
              next unless train

              buy_train(corporation, train, 100)
              @log << "#{corporation.name} buys a 2-train for #{format_currency(100)} as an Early Adopter"
            end
          end
        end

        def game_market
          self.class::COLUMN_MARKET
        end

        def init_round
          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter += 1
          stock_round
        end

        def or_round_finished
          return unless @phase.status.include?('export_train')

          train = @depot.upcoming.first
          @depot.export!
          @depot.forget_train(train) if train
          @log << "#{train.name} train is exported and removed from the game" if train
          post_train_buy
          game_end_check
        end

        def reveal_up_consist!(phase_name)
          names = @up_consist[phase_name]
          return unless names

          @union_pacific.trains.clear
          names.each do |name|
            prototype = self.class::TRAINS.find { |t| t[:name] == name }
            train = Train.new(**prototype.except(:events), index: -1)
            train.owner = @union_pacific
            train.buyable = false
            @union_pacific.trains << train
          end
          @log << "#{@union_pacific.name} reveals its Phase #{phase_name} consist: #{names.join(', ')}"
        end

        def event_up_operates!
          @up_pending = true
        end

        def up_operating?
          !!@up_started
        end

        def or_set_finished
          @up_started = true if @up_pending
          super
        end

        def event_close_credit_mobilier!
          return if @credit_mobilier.closed?

          if @credit_mobilier.cash.positive?
            @log << "Crédit Mobilier closes, returning #{format_currency(@credit_mobilier.cash)} to the bank"
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
          remove_additional_station_tokens!
          @companies.each do |company|
            next if company.closed?

            company.close!
          end
          @local_contracts.clear
        end

        def event_up_ipo_purchasable!
          @up_ipo_open = true
          @log << 'Union Pacific shares may now be purchased from the IPO'
        end

        def event_enforce_ownership_limit!
          @log << 'Players may no longer purchase shares beyond 60% of a company'
          (@corporations + @future_corporations).each do |corporation|
            next if corporation.type == :minor

            corporation.max_ownership_percent = 60
          end
          @ownership_limited = true
        end

        def reset_corporation(corporation)
          corp = super
          corp.max_ownership_percent = @ownership_limited ? 60 : 100
          corp
        end

        def setup_for_2_players
          self.class::TRAINS_REMOVE_2_PLAYER.each do |train_name, count|
            trains = depot.upcoming.select { |t| t.name == train_name }.reverse.take(count)
            trains.each { |t| depot.forget_train(t) }
          end
        end

        def queue_up_share_purchase(corporation)
          case corporation.type
          when :minor
            player = corporation.owner
            return unless player&.player?

            @pending_up_share_buyers << { player: player, shares: 1 }
          when :major
            ordered_players_from(corporation.owner).each do |buyer|
              held = buyer.num_shares_of(corporation)
              next unless held.positive?

              @pending_up_share_buyers << { player: buyer, shares: held }
            end
          end
        end

        def ordered_players_from(first)
          return @players.dup unless first

          index = @players.index(first) || 0
          @players.rotate(index)
        end

        def up_shares_purchasable_from_ipo?
          !!@up_ipo_open
        end

        def event_green_minors_available!
          @log << 'Green minors are now available'
          @corporations += @future_corporations
          @future_corporations = []
        end

        def init_loans
          @loan_value = 50
          Array.new(72) { |id| Loan.new(id, @loan_value) }
        end

        def pay_credit_mobilier(amount, from:)
          return if @credit_mobilier.closed? || !amount.positive?

          from.spend(amount, @credit_mobilier)
        end

        def distribute_credit_mobilier!
          return if @credit_mobilier.closed?

          per_player = @credit_mobilier.cash / @players.size
          return unless per_player.positive?

          @players.each { |player| @credit_mobilier.spend(per_player, player) }
          @log << "Crédit Mobilier pays #{format_currency(per_player)} to each player"\
                  " (#{format_currency(@credit_mobilier.cash)} remains)"
        end

        def spending_entities
          super + [@credit_mobilier]
        end

        def new_merger_round
          distribute_credit_mobilier!
          super
        end

        def nationalization_loan_movement(corporation)
          corporation.loans.each { stock_market.move_left(corporation) }
        end

        def nationalization_transfer_assets(corporation)
          corporation.companies.dup.each do |company|
            @log << "#{company.name} is removed from the game"
            company.close!
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

          super
          queue_up_share_purchase(corporation)
        end

        def train_limit(entity)
          return 99 if deregulated?

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
            Engine::Step::DiscardTrain,
            G1867::Step::HomeToken,
            G1864::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          calculate_interest
          G1864::Round::Operating.new(self, [
            G1864::Step::UPShares,
            G1867::Step::MajorTrainless,
            Engine::Step::BuyCompany,
            G1867::Step::RedeemShares,
            G1864::Step::Track,
            G1864::Step::Token,
            G1864::Step::Assign,
            G1864::Step::Route,
            G1864::Step::Dividend,
            [G1867::Step::BuyCompanyPreloan, { blocks: true }],
            G1867::Step::LoanOperations,
            Engine::Step::DiscardTrain,
            G1864::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end
      end
    end
  end
end
