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

        # UP reserves a slot in Omaha from setup and in Cheyenne on the green upgrade.
        NATIONAL_RESERVATIONS = %w[F27 F19].freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'up_operates' => ['Union Pacific operates',
                            'The Union Pacific runs the trains on its consist card and pays a full dividend'],
          'export_train' => ['Train Export',
                             'At the end of each OR the next available train is exported and removed from the game'],
        ).freeze

        PHASES = [
          { name: '2', train_limit: { minor: 2 }, tiles: [:yellow], operating_rounds: 2 },
          {
            name: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            on: '3',
            operating_rounds: 2,
          },
          {
            name: '4',
            train_limit: { minor: 1, major: 3, national: 99 },
            tiles: %i[yellow green],
            status: %w[export_train up_operates],
            on: '4',
            operating_rounds: 2,
          },
          {
            name: '5',
            train_limit: { minor: 1, major: 3, national: 99 },
            tiles: %i[yellow green brown],
            status: %w[export_train up_operates],
            on: '5',
            operating_rounds: 2,
          },
          {
            name: '6',
            train_limit: { minor: 1, major: 2, national: 99 },
            tiles: %i[yellow green brown],
            status: %w[export_train up_operates],
            on: '6',
            operating_rounds: 2,
          },
          {
            name: '7',
            train_limit: { minor: 1, major: 2, national: 99 },
            tiles: %i[yellow green brown gray],
            status: %w[export_train up_operates],
            on: '7',
            operating_rounds: 2,
          },
          {
            name: '8',
            train_limit: { major: 2, national: 99 },
            tiles: %i[yellow green brown gray],
            status: ['up_operates'],
            on: '8',
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 10,
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 225,
            rusts_on: '6',
            num: 7,
            events: [{ 'type' => 'green_minors_available' }],
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 350,
            rusts_on: '8',
            num: 4,
            events: [{ 'type' => 'majors_can_ipo' },
                     { 'type' => 'trainless_nationalization' },
                     { 'type' => 'up_operates' },
                     { 'type' => 'close_credit_mobilier' }],
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 550,
            num: 4,
            events: [{ 'type' => 'minors_cannot_start' },
                     { 'type' => 'open_tunnels' }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 650,
            num: 2,
            events: [{ 'type' => 'trainless_nationalization' },
                     { 'type' => 'remove_minor_abilities' },
                     { 'type' => 'up_ipo_purchasable' },
                     { 'type' => 'enforce_ownership_limit' }],
          },
          {
            name: '7',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 7, 'visit' => 7 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 800,
            num: 2,
          },
          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 1000,
            num: 'unlimited',
            events: [{ 'type' => 'minors_nationalized' },
                     { 'type' => 'trainless_nationalization' },
                     { 'type' => 'train_trade_allowed' }],
            discount: {
              '5' => 275,
              '6' => 325,
              '7' => 400,
              '8' => 500,
              '2+2' => 300,
              '5+5E' => 750,
            },
          },
          {
            name: '2+2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            multiplier: 2,
            price: 600,
            num: 'unlimited',
            available_on: '8',
            discount: {
              '5' => 275,
              '6' => 325,
              '7' => 400,
              '8' => 500,
              '2+2' => 300,
              '5+5E' => 750,
            },
          },
          {
            name: '5+5E',
            distance: [{ 'nodes' => ['offboard'], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => %w[city town], 'pay' => 0, 'visit' => 99 }],
            multiplier: 2,
            price: 1500,
            num: 'unlimited',
            available_on: '8',
            discount: {
              '5' => 275,
              '6' => 325,
              '7' => 400,
              '8' => 500,
              '2+2' => 300,
              '5+5E' => 750,
            },
          },
        ].freeze

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
          # Local Contract: corporation => hex id of the station carrying the
          # +$10 marker.
          @local_contracts = {}
          @pullman_bonus_used = false

          @union_pacific = @national = @corporations.find { |c| c.type == :national }
          @corporations.delete(@national)
          @national.ipoed = true
          share_price = stock_market.market.flatten.compact.find { |sp| sp.price == 80 }
          stock_market.set_par(@national, share_price)

          @corporations, @future_corporations = @corporations.partition do |corporation|
            corporation.type == :minor && !self.class::GREEN_CORPORATIONS.include?(corporation.id)
          end

          deal_ability_cards!
          grant_additional_station_tokens!

          # Deal one consist card per phase, each from that phase's deck.
          decks = UnionPacific::CONSIST_DECKS.values
          @up_consist = UnionPacific::PHASES_WITH_CONSISTS.to_h do |phase|
            [phase, decks[rand % decks.size][phase]]
          end
        end

        # Early Adopter is set aside, the other fifteen shuffled, then Early
        # Adopter is placed within the top ten so it reaches one of the ten
        # minors available from the start rather than a green minor that
        # might never be started - a free-ish 2-train is useless on a minor
        # that never floats.
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

        # `additional_token` (see `Engine::Ability::AdditionalToken`) is an inert
        # marker in this engine: nothing in `Operator#init_operator` or
        # `Step::Tokener` ever mutates `@tokens`, which is built once at
        # construction from `opts[:tokens]`. 1817 and 18Hiawatha are the only
        # other titles that grant a token from an ability, and both do it by
        # explicitly pushing a real `Token` when the ability fires
        # (`corporation.tokens << Engine::Token.new(corporation)`). Union
        # Station and Central Station are dealt, not bought, so there is no
        # player action to hang this on - grant the token here, once, at
        # setup, priced at the $10-per-hexagon rate the card promises.
        def grant_additional_station_tokens!
          (@corporations + @future_corporations).each do |corporation|
            abilities(corporation, :additional_token) do |ability|
              corporation.tokens << Engine::Token.new(corporation, price: extra_token_price(corporation))
              ability.use!
              @log << "#{corporation.name} receives an additional station token from #{ability.owner.name}"
            end
          end
        end

        # The base rate consumed by `hex_distance_from_token` in
        # `G1867::Step::Token#adjust_token_price_ability!`: the final price is
        # this multiplied by the hex distance from the corporation's nearest
        # placed token, exactly as 1867 prices its normal tokens off the
        # `tokens:` tiers in `Entities::CORPORATIONS` - only the rate differs.
        def extra_token_price(corporation)
          corporation.companies.any? { |c| ['Union Station', 'Central Station'].include?(c.name) } ? 10 : 0
        end

        def double_tracks?(corporation)
          corporation.respond_to?(:companies) &&
            corporation.companies.any? { |c| c.name == 'Double Tracks' }
        end

        def pullman_car?(corporation)
          corporation.respond_to?(:companies) &&
            corporation.companies.any? { |c| c.name == 'Pullman Car' }
        end

        # Two trains of the same corporation may not normally reuse the same
        # piece of track (`Route#check_overlap!` -> here). Double Tracks lifts
        # that restriction for its holder. Minors never run more than two
        # trains at once (`PHASES`' `train_limit`), so waiving the check
        # entirely for a holder is equivalent to "two trains may share track".
        def check_overlap(routes)
          return if double_tracks?(routes.first&.corporation)

          super
        end

        def reset_pullman_bonus!
          @pullman_bonus_used = false
        end

        # Pullman Car: one train may treat up to two additional towns as real
        # (revenue-earning) stops without them counting against the train's
        # distance. `G1867::Game#compute_stops` already gives us the stops a
        # plain train would earn; here, for a Pullman Car holder that hasn't
        # used its bonus yet this route-running action (see
        # `Step::Route#process_run_routes`), add up to two visited-but-unused
        # towns on top of that base result.
        def compute_stops(route)
          stops = super
          return stops if stops.empty? || @pullman_bonus_used || !pullman_car?(route.corporation)

          extra_towns = (route.visited_stops - stops).select(&:town?).first(2)
          return stops if extra_towns.empty?

          @pullman_bonus_used = true
          stops + extra_towns
        end

        # Local Contract: a +$10 marker placed on one city where the holding
        # corporation has a station (`Step::Assign` handles the placement
        # action). Hooked into `revenue_for` here so the ability is testable
        # now; Task 11 should NOT add a second call to this from its own
        # route-bonus work in `revenue_for`.
        def local_contract_bonus(corporation, stop)
          return 0 unless @local_contracts[corporation] == stop.hex.id

          10
        end

        # The four $80 city-pair bonuses (any route touching both cities in a
        # pair earns the bonus; a route touching cities from two different
        # pairs earns both).
        BONUS_PAIRS = [
          ['Great Lakes', 'Seattle'],
          ['New Orleans', 'Los Angeles'],
          ['St. Louis', 'San Francisco'],
          ['Chicago', 'San Francisco'],
        ].freeze
        PAIR_BONUS = 80

        # The $120 Forty-Niner Route bonus: a single route through all five
        # named cities.
        FORTY_NINER_ROUTE = ['Chicago', 'Omaha', 'Cheyenne', 'Salt Lake', 'San Francisco'].freeze
        FORTY_NINER_BONUS = 120

        # The $80 bonus for a route reaching both a north ("N") marker hex and
        # a south ("S") marker hex. A16 (Canada) and B27 (Great Lakes) carry
        # the printed "N"; L11 (Mexico) and K28 (New Orleans) carry the
        # printed "S" - confirmed exhaustive by Task 2's read of all 148 hexes.
        NORTH_HEXES = %w[A16 B27].freeze
        SOUTH_HEXES = %w[L11 K28].freeze
        NORTH_SOUTH_BONUS = 80

        # The rulebook is explicit that none of 1864's route bonuses are ever
        # multiplied by the 2+2 or 5+5E trains' multiplier, unlike 1867's own
        # capitals-and-Timmins bonus (`BONUS_CAPITALS`/`BONUS_REVENUE`, still
        # inherited from `G1867::Game` but never consulted below - see
        # `revenue_for`). This helper documents that rule for anything that
        # cares to ask; `revenue_for` itself simply never multiplies.
        def bonus_multiplier
          1
        end

        # Fully replaces `G1867::Game#revenue_for` rather than calling `super`
        # into it: 1867's version adds `hex_bonus` ability revenue (1864 has
        # no abilities of that kind - Local Contract is handled below via
        # `local_contract_bonus`) and a capitals+Timmins bonus that it
        # multiplies by the train multiplier (1864 has no such bonus, and
        # none of its own bonuses are ever multiplied). The first line below
        # reproduces `Base#revenue_for` in full; everything after it is 1864.
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

        # The stations eligible to receive Local Contract's marker: every hex
        # where the holding corporation currently has a placed (used) token.
        def local_contract_hexes(company)
          corporation = company.owner
          return [] unless corporation.respond_to?(:tokens)

          # Matches `G1867::Step::Token#adjust_token_price_ability!`'s
          # `token.city.tile.hex`, rather than `token.hex` directly.
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
            when 'Angel Investors'
              @bank.spend(60, corporation)
              @log << "#{corporation.name} receives #{format_currency(60)} from Angel Investors"
            when 'Early Adopter'
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

        # 1864 has no private companies, so there is no initial auction.
        # `new_stock_round` can't be used directly: it builds its log line via
        # `round_description`, which defaults to `@round.round_num`, and `@round`
        # is not yet set the first time `init_round` runs.
        def init_round
          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter += 1
          stock_round
        end

        # 1867 gives the exported train to the CN. 1864 removes it from the game.
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

        # Because `event_up_operates!` fires when the 4-train is bought — mid
        # Operating Round — the UP does not begin operating until the *next*
        # OR, per the rulebook's timing.
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

        def event_open_tunnels!; end

        def event_remove_minor_abilities!; end

        def event_up_ipo_purchasable!
          @up_ipo_open = true
          @log << 'Union Pacific shares may now be purchased from the IPO'
        end

        def event_enforce_ownership_limit!; end

        # Shares of the Union Pacific reach players by four routes: (1) a
        # regionalized minor's owner may buy one 10% share, (2) a regionalized
        # major's shareholders may each buy one share per 10% they held,
        # starting with the President and proceeding clockwise, (3) the Open
        # Market during a Stock Round, and (4) the IPO during a Stock Round,
        # but only from phase 6 on. `nationalize!` (1861/1867) cannot itself
        # run an interactive purchase - it's called mid-step from four
        # different places - so it enqueues eligible buyers here, and
        # `G1864::Step::UPShares` drains the queue.
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

        def add_neutral_tokens
          @green_tokens = []
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

        # 1861's rule: one space left per loan, not 1867's two.
        def nationalization_loan_movement(corporation)
          corporation.loans.each { stock_market.move_left(corporation) }
        end

        # 1864 explicitly removes ability cards from the game on
        # regionalization, overriding 1861's transfer-to-the-national rule. The
        # same treatment is applied to trains and cash: the UP runs only what
        # its consist card shows, so transferred trains would be unusable.
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

        # 1867's `nationalize!` pays out shareholders and cannot itself run an
        # interactive purchase - see `queue_up_share_purchase` above. Enqueue
        # the eligible buyers once the payout is complete.
        def nationalize!(corporation)
          return if !corporation.floated? || !@corporations.include?(corporation)

          super
          queue_up_share_purchase(corporation)
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
            # The blocking buy company needs to be before loan operations
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
