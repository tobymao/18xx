# frozen_string_literal: true

require_relative '../g_1822/game'
require_relative '../../part/upgrade'
require_relative 'entities'
require_relative 'meta'
require_relative 'map'

module Engine
  module Game
    module G1822PNW
      class Game < G1822::Game
        include_meta(G1822PNW::Meta)
        include G1822PNW::Entities
        include G1822PNW::Map

        CERT_LIMIT = { 3 => 21, 4 => 15, 5 => 12 }.freeze

        STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300 }.freeze

        BIDDING_TOKENS = {
          '3': 5,
          '4': 4,
          '5': 3,
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

        STARTING_COMPANIES = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P17 P18
                                M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                M16 M17 M18 M19 M20 M21 MA MB MC].freeze

        STARTING_CORPORATIONS = %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 A B C
                                   FCM MC CHP FNM MIR FCP IRM NDEM].freeze

        CURRENCY_FORMAT_STR = '$%d'

        MARKET = [
          %w[40 50px 55px 60px 65px 70px 75px 80px 90px 100px
             110 120 135 150 165 180 200 220 245 270 300 330 360
             400 450 500 550 600e],
        ].freeze

        SELL_MOVEMENT = :left_per_10_if_pres_else_left_one
        PRIVATE_TRAINS = %w[P1 P2 P3 P4 P5 P6].freeze
        EXTRA_TRAIN_PERMANENTS = %w[2P LP 3/2P].freeze
        PRIVATE_CLOSE_AFTER_PASS = %w[P9].freeze
        PRIVATE_MAIL_CONTRACTS = %w[P14 P15].freeze
        PRIVATE_PHASE_REVENUE = %w[].freeze # Stub for 1822 specific code
        P7_REVENUE = [0, 0, 0, 20, 20, 40, 40, 60].freeze

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
          'P3' => 'P3 (Permanent LT)',
          'P4' => 'P4 (Permanent LT)',
          'P5' => 'P5 (Pullman)',
          'P6' => 'P6 (Pullman)',
          'P7' => 'P7 (Remove Town)',
          'P8' => 'P8 (Remove Town)',
          'P9' => 'P9 (Mail Contract)',
          'P10' => 'P10 (Builder Cubes)',
          'P11' => 'P11 (Extra Tile Lay)',
          'P12' => 'P12 (Small Port)',
          'P13' => 'P13 (Large Port)',
          'P14' => 'P14 (2x Timber Value)',
          'P15' => 'P15 ($10/$30 City Revenue)',
          'P16' => 'P16 (Special Tile Placement)',
          'P17' => 'P17 ($30 Route Enhancement)',
          'P18' => 'P18 (Special Tile Upgrade)',
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
          'MA' => 'A',
          'MB' => 'B',
          'MC' => 'C',
        }.freeze

        def port_company?(entity)
          entity.id == 'P17' || entity.id == 'P18'
        end

        def cube_company?(entity)
          entity.id == 'P10' || entity.id == 'P11'
        end

        BIDDING_BOX_START_PRIVATE = 'P1'
        BIDDING_BOX_START_MINOR = nil

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
                'type' => 'phase_revenue',
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

        UPGRADE_COST_L_TO_2_PHASE_2 = 80

        def operating_round(round_num)
          G1822::Round::Operating.new(self, [
            G1822::Step::PendingToken,
            G1822::Step::FirstTurnHousekeeping,
            Engine::Step::AcquireCompany,
            G1822::Step::DiscardTrain,
            G1822PNW::Step::SpecialChoose,
            G1822PNW::Step::SpecialTrack,
            G1822::Step::SpecialToken,
            G1822PNW::Step::Track,
            G1822::Step::DestinationToken,
            G1822::Step::Token,
            G1822::Step::Route,
            G1822PNW::Step::Dividend,
            G1822::Step::BuyTrain,
            G1822PNW::Step::MinorAcquisition,
            G1822::Step::PendingToken,
            G1822::Step::DiscardTrain,
            G1822::Step::IssueShares,
          ], round_num: round_num)
        end

        def choose_step
          [G1822PNW::Step::Choose]
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

        def upgrades_to_correct_label?(from, to)
          # If the previous hex is white with a 'T', allow upgrades to 5 or 6
          if from.hex.tile.label.to_s == 'T' && from.hex.tile.color == :white
            return true if to.name == '5'
            return true if to.name == '6'
          end
          super
        end

        def stock_round
          G1822PNW::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1822PNW::Step::BuySellParShares,
          ])
        end

        def must_buy_train?(entity)
          entity.trains.none? { |t| !extra_train?(t) } &&
          !depot.depot_trains.empty?
        end

        def corporation_from_company(company)
          corporation_by_id(company.id[1..-1])
        end

        def setup
          # Setup the bidding token per player
          @bidding_token_per_player = init_bidding_token

          # Initialize the player depts, if player have to take an emergency loan
          @player_debts = Hash.new { |h, k| h[k] = 0 }

          # Randomize and setup the companies
          # setup_companies

          # Initialize the stock round choice for P7
          @p7_choice = nil

          # Actual bidbox setup happens in the stock round.
          @bidbox_minors_cache = []

          # Setup exchange token abilities for all corporations
          # setup_exchange_tokens

          # Setup all the destination tokens, icons and abilities
          # setup_destinations

          # Setup the NdeM
          # setup_ndem
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

        # Stubbed out because this game doesn't it, but base 22 does
        def company_tax_haven_payout(entity, per_share); end

        def operating_order
          minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
          minors + majors
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
          company.revenue = 0 if cube_company?(company)
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

        def company_ability_extra_track?(company)
          company.id == 'P9' || company.id == 'P17' || company.id == 'P18'
        end

        def must_remove_town?(entity)
          entity.id == 'P12' || entity.id == 'P13'
        end

        def revenue_for(route, stops)
          revenue = super
          route.train.name == '3/2P' ? (revenue / 2).round(-1) : revenue
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return true if from.color == 'blue' && to.color == 'blue'

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
          from = company.owner.share_price.price
          stock_market.move_left(company.owner)
          log_share_price(company.owner, from)
          company.close!
        end

        def company_status_str(company)
          index = bidbox_minors.index(company) || bidbox_concessions.index(company)
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
          max += 2 if terrain?(tile, 'mountain')
          max += 1 if terrain?(tile, 'hill')
          max += 1 if terrain?(tile, 'river')
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
          if num_cubes >= 2 && terrain?(tile, 'mountain')
            num_cubes -= 2
            cost -= 80
          end
          if num_cubes >= 1 && terrain?(tile, 'hill')
            num_cubes -= 1
            cost -= 40
          end
          cost -= 20 if num_cubes >= 1 && terrain?(tile, 'river')
          cost
        end
      end
    end
  end
end
