# frozen_string_literal: true

require_relative '../g_1822/game'
require_relative '../../part/upgrade'
require_relative 'meta'
require_relative 'map'

module Engine
  module Game
    module G1822MX
      class Game < G1822::Game
        include_meta(G1822MX::Meta)
        include G1822MX::Entities
        include G1822MX::Map

        attr_accessor :ndem_acting_player, :number_ndem_shares, :ndem_state

        CERT_LIMIT = { 3 => 16, 4 => 13, 5 => 10 }.freeze

        BIDDING_TOKENS = {
          '3': 6,
          '4': 5,
          '5': 4,
        }.freeze

        EXCHANGE_TOKENS = {
          'FCM' => 3,
          'MC' => 3,
          'CHP' => 3,
          'FNM' => 3,
          'MIR' => 3,
          'FCP' => 3,
          'IRM' => 3,
        }.freeze

        STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300 }.freeze

        STARTING_COMPANIES = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P17 P18
                                C1 C2 C3 C4 C5 C6 C7 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                M16 M17 M18 M19 M20 M21 M22 M23 M24].freeze

        STARTING_CORPORATIONS = %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
                                   FCM MC CHP FNM MIR FCP IRM NDEM].freeze

        CURRENCY_FORMAT_STR = '$%s'

        MARKET = [
          %w[5y 10y 15y 20y 25y 30y 35y 40y 45y 50p 60xp 70xp 80xp 90xp 100xp 110 120 135 150 165 180 200 220 245 270 300 330
             360 400 450 500 550 600e],
        ].freeze

        SELL_MOVEMENT = :left_per_10_if_pres_else_left_one
        PRIVATE_TRAINS = %w[P1 P2 P3 P4 P5 P6].freeze
        EXTRA_TRAINS = %w[2P P+ LP 3/2P].freeze
        EXTRA_TRAIN_PERMANENTS = %w[2P LP 3/2P].freeze
        PRIVATE_CLOSE_AFTER_PASS = %w[P9].freeze
        PRIVATE_MAIL_CONTRACTS = %w[P14 P15].freeze
        PRIVATE_PHASE_REVENUE = %w[].freeze # Stub for 1822 specific code
        P7_REVENUE = [0, 0, 0, 20, 20, 40, 40, 60].freeze

        LOCAL_TRAIN_CAN_CARRY_MAIL = true

        # Don't run 1822 specific code for the LCDR
        COMPANY_LCDR = nil

        PRIVATE_COMPANIES_ACQUISITION = {
          'P1' => { acquire: %i[major], phase: 5 },
          'P2' => { acquire: %i[major], phase: 2 },
          'P3' => { acquire: %i[major minor], phase: 1 },
          'P4' => { acquire: %i[major minor], phase: 1 },
          'P5' => { acquire: %i[major minor], phase: 3 },
          'P6' => { acquire: %i[major minor], phase: 3 },
          'P7' => { acquire: %i[major], phase: 3 },
          'P8' => { acquire: %i[major minor], phase: 1 },
          'P9' => { acquire: %i[major minor], phase: 3 },
          'P10' => { acquire: %i[major minor], phase: 1 },
          'P11' => { acquire: %i[major minor], phase: 1 },
          'P12' => { acquire: %i[major minor], phase: 1 },
          'P13' => { acquire: %i[major minor], phase: 1 },
          'P14' => { acquire: %i[major], phase: 3 },
          'P15' => { acquire: %i[major], phase: 3 },
          'P16' => { acquire: %i[major], phase: 2 },
          'P17' => { acquire: %i[major minor], phase: 2 },
          'P18' => { acquire: %i[major], phase: 3 },
        }.freeze

        COMPANY_SHORT_NAMES = {
          'P1' => 'P1 (5-Train)',
          'P2' => 'P2 (Permanent 2T)',
          'P3' => 'P3 (Permanent 3/2T)',
          'P4' => 'P4 (Permanent LT)',
          'P5' => 'P5 (Pullman)',
          'P6' => 'P6 (Pullman)',
          'P7' => 'P7 (Double Cash)',
          'P8' => 'P8 (Adv. Tile Lay)',
          'P9' => 'P9 (Extra Tile Lay)',
          'P10' => 'P10 (Builder Cubes)',
          'P11' => 'P11 (Builder Cubes)',
          'P12' => 'P12 (Remove Town)',
          'P13' => 'P13 (Remove Town)',
          'P14' => 'P14 (Mail Contract)',
          'P15' => 'P15 (Mail Contract)',
          'P16' => 'P16 (Stock Drop)',
          'P17' => 'P17 (Small Port)',
          'P18' => 'P18 (Large Port)',
          'C1' => 'FCM',
          'C2' => 'MC',
          'C3' => 'CHP',
          'C4' => 'FNM',
          'C5' => 'MIR',
          'C6' => 'FCP',
          'C7' => 'IRM',
          'M1' => '1',
          'M2' => '2',
          'M3' => '3',
          'M4' => '4',
          'M5' => '5',
          'M6' => '6',
          'M7' => '7',
          'M8' => '8',
          'M9' => '9',
          'M10' => '10',
          'M11' => '11',
          'M12' => '12',
          'M13' => '13',
          'M14' => '14',
          'M15' => '15',
          'M16' => '16',
          'M17' => '17',
          'M18' => '18',
          'M19' => '19',
          'M20' => '20',
          'M21' => '21',
          'M22' => '22',
          'M23' => '23',
          'M24' => '24',
        }.freeze

        def port_company?(entity)
          entity.id == 'P17' || entity.id == 'P18'
        end

        def cube_company?(entity)
          entity.id == 'P10' || entity.id == 'P11'
        end

        BIDDING_BOX_START_PRIVATE = 'P1'
        BIDDING_BOX_START_MINOR = nil

        DOUBLE_HEX = %w[L19 M22 M26].freeze

        def init_graph
          Graph.new(self, home_as_token: true)
        end

        TRAINS = [
          {
            name: 'L',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 22,
            price: 60,
            rusts_on: '3',
            variants: [
              {
                name: '2',
                distance: 2,
                price: 120,
                rusts_on: '4',
                available_on: '1',
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            num: 7,
            price: 200,
            rusts_on: '6',
          },
          {
            name: '4',
            distance: 4,
            num: 4,
            price: 300,
            rusts_on: '7',
          },
          {
            name: '5',
            distance: 5,
            num: 2,
            price: 500,
            events: [
              {
                'type' => 'close_concessions',
              },
            ],
          },
          {
            name: '6',
            distance: 6,
            num: 3,
            price: 600,
            events: [
              {
                'type' => 'full_capitalisation',
              },
            ],
          },
          {
            name: '7',
            distance: 7,
            num: 20,
            price: 750,
            variants: [
              {
                name: 'E',
                distance: 99,
                multiplier: 2,
                price: 1000,
              },
            ],
            events: [
              {
                'type' => 'close_ndem',
              },
            ],
          },
          {
            name: '2P',
            distance: 2,
            num: 1,
            price: 0,
          },
          {
            name: 'LP',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 1,
            price: 0,
          },
          {
            name: '5P',
            distance: 5,
            num: 1,
            price: 500,
          },
          {
            name: 'P+',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 99,
                'visit' => 99,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 2,
            price: 0,
          },
          {
            name: '3/2P',
            distance: 3,
            num: 1,
            price: 0,
            # Dividing by two takes place in revenue_for
          },
        ].freeze

        EVENTS_TEXT = {
          'close_concessions' =>
            ['Concessions close', 'All concessions close without compensation, major companies float at 50%'],
          'full_capitalisation' =>
            ['Full capitalisation', 'Major companies receive full capitalisation when floated'],
          'close_ndem' =>
            ['NdeM privatization', 'NdeM privatized, runs one last time, auctions token'],
        }.freeze

        UPGRADE_COST_L_TO_2_PHASE_2 = 80

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            G1822::Step::PendingToken,
            G1822::Step::FirstTurnHousekeeping,
            Engine::Step::AcquireCompany,
            G1822MX::Step::DiscardTrain,
            G1822MX::Step::SpecialChoose,
            G1822MX::Step::SpecialTrack,
            G1822::Step::SpecialToken,
            G1822MX::Step::Track,
            G1822::Step::DestinationToken,
            G1822MX::Step::Token,
            G1822MX::Step::Route,
            G1822MX::Step::Dividend,
            G1822::Step::BuyTrain,
            G1822MX::Step::MinorAcquisition,
            G1822::Step::PendingToken,
            G1822MX::Step::DiscardTrain,
            G1822MX::Step::IssueShares,
            G1822MX::Step::CashOutNdem,
            G1822MX::Step::AuctionNdemTokens,
          ], round_num: round_num)
        end

        def choose_step
          [G1822MX::Step::Choose]
        end

        def discountable_trains_for(corporation)
          discount_info = []

          upgrade_cost = if @phase.name.to_i < 2
                           self.class::UPGRADE_COST_L_TO_2
                         else
                           self.class::UPGRADE_COST_L_TO_2_PHASE_2
                         end
          corporation.trains.select { |t| t.name == 'L' }.each do |train|
            discount_info << [train, train, '2', upgrade_cost]
          end
          discount_info
        end

        def starting_companies
          self.class::STARTING_COMPANIES
        end

        def init_share_pool
          G1822MX::SharePool.new(self)
        end

        def stock_round
          G1822MX::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1822MX::Step::BuySellParShares,
          ])
        end

        def must_buy_train?(entity)
          entity.id != 'NDEM' && super
        end

        def sorted_corporations
          available_corporations = super
          available_corporations << ndem unless available_corporations.include?(ndem)
          available_corporations
        end

        def corporation_from_company(company)
          corporation_by_id(company.id[1..-1])
        end

        def replace_minor_with_ndem(company)
          # Remove minor
          @companies.delete(company)
          @log << "-- #{company.sym} is removed from the game and replaced with NdeM"

          corporation = corporation_from_company(company)

          # Replace token
          city = hex_by_id(corporation.coordinates).tile.cities.find { |c| c.reserved_by?(corporation) }
          city.remove_reservation!(corporation)
          city.place_token(ndem, ndem.find_token_by_type, check_tokenable: false)
          graph.clear

          # Add a stock certificate
          new_share = Share.new(ndem, percent: 10, index: @number_ndem_shares)
          new_share.counts_for_limit = false
          @share_pool.transfer_shares(new_share.to_bundle, @share_pool, allow_president_change: false)
          @_shares[new_share.id] = new_share
          @number_ndem_shares += 1
        end

        def setup_ndem
          @number_ndem_shares = 3

          # Make the NDEM shares not count against the cert limit and move them to the bank pool
          ndem.shares_by_corporation[ndem].each { |share| share.counts_for_limit = false }
          @share_pool.transfer_shares(Engine::ShareBundle.new(ndem.shares_by_corporation[ndem]), @share_pool)

          # Find the first of (M14, M15, and M17) to remove for the NdeM.  The rules say to randomize
          # the entire stack, and then find the earliest one of the three.  This will result in a
          # slightly different order than just pulling one out to start...

          ndem_minor_index = [@companies.index { |c| c.id == 'M14' },
                              @companies.index { |c| c.id == 'M15' },
                              @companies.index { |c| c.id == 'M17' }].min
          replace_minor_with_ndem(@companies[ndem_minor_index])

          # bidboxes need to be re-setup if this minor was in the top 4
          setup_bidboxes

          stock_market.set_par(ndem, stock_market.par_prices.find { |pp| pp.price == 100 })
          ndem.ipoed = true
          ndem.owner = @share_pool # Not clear this is needed
          after_par(ndem) # Not clear this is needed

          @ndem_state = :open

          n = ndem
          def n.counts_for_limit
            false
          end
        end

        def send_train_to_ndem(train)
          if train.name == 'L' && phase.name == '2'
            train.variant = '2'
            @log << 'L Train given to NDEM is flipped to a 2 Train'
          end
          source = train.owner
          buy_train(ndem, train, :free)
          phase.buying_train!(ndem, train, source)
          while ndem.trains.length > phase.train_limit(ndem)
            t = ndem.trains.shift
            rust(t)
          end
        end

        def setup_game_specific
          @p7_choice = nil
          setup_ndem
        end

        # setup_companies from 1822 has too much 1822-specific stuff that doesn't apply to this game
        def setup_companies
          # Randomize from preset seed to get same order
          @companies.sort_by! { rand }

          minors = @companies.select { |c| c.id[0] == self.class::COMPANY_MINOR_PREFIX }
          concessions = @companies.select { |c| c.id[0] == self.class::COMPANY_CONCESSION_PREFIX }
          privates = @companies.select { |c| c.id[0] == self.class::COMPANY_PRIVATE_PREFIX }

          c1 = concessions.find { |c| c.id == bidbox_start_concession }
          concessions.delete(c1)
          concessions.unshift(c1)

          p1 = privates.find { |c| c.id == bidbox_start_private }
          privates.delete(p1)
          privates.unshift(p1)

          # Move Minor 18 to the end so that it's not in the initial auction
          m18 = minors.find { |c| c.id == 'M18' }
          minors.delete(m18)
          minors.push(m18)

          # Clear and add the companies in the correct randomize order sorted by type
          @companies.clear
          @companies.concat(minors)
          @companies.concat(concessions)
          @companies.concat(privates)

          # Set the min bid on the Concessions and Minors
          @companies.each do |c|
            c.min_price = case c.id[0]
                          when self.class::COMPANY_CONCESSION_PREFIX, self.class::COMPANY_MINOR_PREFIX
                            c.value
                          else
                            0
                          end
            c.max_price = 10_000
          end

          # Setup company abilities
          @company_trains = {}
          @company_trains['P1'] = find_and_remove_train_by_id('5P-0')
          @company_trains['P2'] = find_and_remove_train_by_id('2P-0', buyable: false)
          @company_trains['P3'] = find_and_remove_train_by_id('3/2P-0', buyable: false)
          @company_trains['P4'] = find_and_remove_train_by_id('LP-0', buyable: false)
          @company_trains['P5'] = find_and_remove_train_by_id('P+-0', buyable: false)
          @company_trains['P6'] = find_and_remove_train_by_id('P+-1', buyable: false)
        end

        # Stubbed out because this game doesn't it, but base 22 does
        def company_tax_haven_bundle(choice); end
        def company_tax_haven_payout(entity, per_share); end
        def num_certs_modification(_entity) = 0

        def event_close_ndem!
          @log << '-- Event: Ndem privatizing --'
          @ndem_state = :closing
          return unless @round.is_a?(Engine::Round::Operating)

          ndem = @round.entities.pop
          @round.entities.insert(@round.entity_index + 1, ndem)
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
          return super unless bundle.corporation == corporation_by_id('NDEM')

          @share_pool.sell_shares(bundle, allow_president_change: false, swap: swap)
        end

        def operating_order
          ndem, others = @corporations.select(&:floated?).sort.partition { |c| c.id == 'NDEM' }
          minors, majors = others.sort.partition { |c| c.type == :minor }
          case @ndem_state
          when :closing
            ndem + minors + majors
          when :closed
            minors + majors
          else
            minors + majors + ndem
          end
        end

        def active_players
          if current_entity == ndem && @round.active_step.respond_to?(:ndem_acting_player)
            return [@round.active_step.ndem_acting_player]
          end

          super
        end

        def set_private_revenues
          @companies.each do |c|
            next unless c.owner

            adjust_p7_revenue(c) if c.id == 'P7' && c.owner.corporation?
          end
        end

        def adjust_p7_revenue(company)
          company.revenue = self.class::P7_REVENUE[@phase.name.to_i]
        end

        def choices_entities
          company = company_by_id('P7')
          return [] unless company&.owner&.player?

          [company.owner]
        end

        def company_choices_p7(company, time)
          return {} if @p7_choice || !company.owner&.player? || time != :choose

          choices = {}
          choices['double'] = 'Double your actual cash holding when determining player turn order.'
          choices
        end

        def company_made_choice_p7(company)
          @p7_choice = company.owner
          @log << "#{company.owner.name} chooses to double actual cash holding when determining player turn order."
        end

        def company_choices(company, time)
          case company.id
          when 'P7'
            company_choices_p7(company, time)
          else
            {}
          end
        end

        def company_made_choice(company, _choice, _time)
          case company.id
          when 'P7'
            company_made_choice_p7(company)
          end
        end

        def company_bought(company, entity)
          on_acquired_train(company, entity) if self.class::PRIVATE_TRAINS.include?(company.id)
          adjust_p7_revenue(company) if company.id == 'P7'
          company.revenue = -10 if company.id == 'P16'
          company.revenue = 0 if cube_company?(company) || self.class::PRIVATE_MAIL_CONTRACTS.include?(company.id)
        end

        def reorder_players(_order = nil)
          current_order = @players.dup.reverse
          @players.sort_by! do |p|
            cash = p.cash
            cash *= 2 if @p7_choice == p
            [cash, current_order.index(p)]
          end.reverse!

          player_order = @players.map do |p|
            double = ' doubled' if @p7_choice == p
            "#{p.name} (#{format_currency(p.cash)}#{double})"
          end.join(', ')

          @log << "-- New player order: #{player_order}"

          @p7_choice = nil
        end

        def can_only_lay_plain_or_towns?(entity)
          entity.id == 'P8'
        end

        def can_upgrade_one_phase_ahead?(entity)
          entity.id == 'P8'
        end

        def must_be_on_terrain?(_entity)
          false
        end

        def home_token_counts_as_tile_lay?(_entity)
          false
        end

        def company_ability_extra_track?(company)
          company.id == 'P9' || company.id == 'P17' || company.id == 'P18'
        end

        def must_remove_town?(entity)
          entity.id == 'P12' || entity.id == 'P13'
        end

        def revenue_for(route, stops)
          revenue = super
          route.train.name.start_with?('3/2P') ? (revenue / 2).round(-1) : revenue
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return true if from.color == :blue && to.color == :blue

          super
        end

        def payout_companies
          super
          # Check on stock drop private
          company = company_by_id('P16')
          return unless company.owner.is_a?(Corporation)

          payment = 10
          if company.owner.cash >= payment
            @log << "#{company.owner.name} spends #{format_currency(payment)} because of #{company.name}"
            company.owner.spend(payment, bank)
          else
            @log << "#{company.owner.name} cannot afford #{format_currency(payment)} for #{company.name}"
            close_p16
          end
        end

        def close_p16
          company = company_by_id('P16')
          @log << "#{company.name} closes"
          old_price = company.owner.share_price
          stock_market.move_left(company.owner)
          log_share_price(company.owner, old_price)
          company.close!
        end

        def company_status_str(company)
          index = bidbox_minors.index(company) || bidbox_concessions.index(company) || bidbox_privates.index(company)
          return "Bid box #{index + 1}" if index

          nil
        end

        def terrain?(tile, terrain)
          tile.parts.each do |part|
            return true if part.is_a?(Engine::Part::Upgrade) && (part.terrains[0] == terrain)
          end
          false
        end

        def max_builder_cubes(tile)
          max = 0
          max += 2 if terrain?(tile, :mountain)
          max += 1 if terrain?(tile, :hill)
          max += 1 if terrain?(tile, :river)
          max
        end

        def current_builder_cubes(tile)
          tile.icons.count { |i| i.name.start_with?('block') }
        end

        def can_hold_builder_cubes?(tile)
          current_builder_cubes(tile) < max_builder_cubes(tile)
        end

        # Assume the company optimizes cost reduction from cubes
        def upgrade_cost(tile, hex, entity, spender)
          cost = super
          num_cubes = current_builder_cubes(tile)
          if num_cubes >= 2 && terrain?(tile, :mountain)
            num_cubes -= 2
            cost -= 80
          elsif num_cubes >= 1 && terrain?(tile, :hill)
            num_cubes -= 1
            cost -= 40
          end
          cost -= 20 if num_cubes >= 1 && terrain?(tile, :river)
          cost
        end

        def purchasable_companies(entity = nil)
          return [] if entity && entity.id == 'NDEM'

          super
        end

        def ndem
          @ndem ||= corporation_by_id('NDEM')
        end

        def extra_train_pullman_count(corporation)
          corporation.trains.count { |train| extra_train_pullman?(train) }
        end

        def extra_train_pullman?(train)
          train.name == self.class::EXTRA_TRAIN_PULLMAN
        end

        def crowded_corps
          @crowded_corps ||= corporations.select do |c|
            trains = c.trains.count { |t| !extra_train?(t) }
            crowded = trains > train_limit(c)
            crowded |= extra_train_permanent_count(c) > 1
            crowded |= extra_train_pullman_count(c) > 1
            crowded
          end
        end

        def finalize_end_game_values; end

        def reduced_bundle_price_for_market_drop(bundle)
          bundle.share_price = @stock_market.find_share_price(bundle.corporation, [:left] * bundle.num_shares).price
          bundle
        end

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['Dividend 0 or withheld', '1 ←'],
            ['Dividend < share price', 'none'],
            ['Dividend ≥ share price, < 2x share price ', '1 →'],
            ['Dividend ≥ 2x share price', '2 →'],
            ['Minor company dividend > 0', '1 →'],
            ['Each share sold (if sold by director)', '1 ←'],
            ['One or more shares sold (if sold by non-director)', '1 ←'],
            ['Corporation (except NdeM) sold out at end of SR', '1 →'],
          ]
        end
      end
    end
  end
end
