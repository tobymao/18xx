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
        include G1822PNW::BuilderCubes

        CERT_LIMIT = { 3 => 21, 4 => 15, 5 => 12 }.freeze

        STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300 }.freeze

        BIDDING_TOKENS = {
          '3': 5,
          '4': 4,
          '5': 4,
        }.freeze

        EXCHANGE_TOKENS = {
          'CPR' => 3,
          'GNR' => 3,
          'CMPS' => 3,
          'SWW' => 3,
          'SPS' => 3,
          'ORNC' => 3,
          'NP' => 3,
        }.freeze

        STARTING_COMPANIES = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P17 P18 P19 P20 P21
                                M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15 M16 M17 M18 M19 M20 M21 MA MB MC].freeze

        STARTING_CORPORATIONS = %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 A B C
                                   NP CPR GNR ORNC SPS CMPS SWW].freeze

        CURRENCY_FORMAT_STR = '$%s'

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par_1: :red,
          par: :peach,
        ).freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(
          par_1: 'Par (Majors and Minors, Phases 2-7)',
          par: 'Par (Minors only. Phases 1-7)',
        )

        MARKET = [
          %w[40 50p 55x 60x 65x 70x 75x 80x 90x 100x
             110 120 135 150 165 180 200 220 245 270 300 330 360
             400 450 500 550 600e],
        ].freeze

        LOCAL_TRAIN_CAN_CARRY_MAIL = true

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
            ['Dividend ≥ 3x share price, share price <= 150', '3 →'],
            ['Minor company dividend > 0', '1 →'],
            ['Each share sold (if sold by director)', '1 ←'],
            ['One or more shares sold (if sold by non-director)', '1 ←'],
            ['Corporation sold out at end of SR', '1 →'],
          ]
        end

        SELL_MOVEMENT = :left_per_10_if_pres_else_left_one
        PRIVATE_TRAINS = %w[P1 P2 P3 P4 P5 P6].freeze
        EXTRA_TRAIN_PERMANENTS = %w[2P LP].freeze
        PRIVATE_MAIL_CONTRACTS = %w[P9].freeze
        PRIVATE_CLOSE_AFTER_PASS = %w[P11].freeze
        PRIVATE_PHASE_REVENUE = %w[].freeze # Stub for 1822 specific code

        IMPASSABLE_HEX_COLORS = %i[gray red blue].freeze

        ASSIGNMENT_TOKENS = {
          'forest' => '/icons/1822_pnw/tree_plus_10.svg',
          'P17' => '/icons/ski.svg',
          'P15' => '/icons/factory.svg',
        }.freeze

        DOUBLE_HEX = %w[H19 M4].freeze

        # Don't run 1822 specific code for the LCDR
        COMPANY_LCDR = nil

        PRIVATE_COMPANIES_ACQUISITION = {
          'P1' => { acquire: %i[major], phase: 5 },
          'P2' => { acquire: %i[major], phase: 2 },
          'P3' => { acquire: %i[major minor], phase: 1 },
          'P4' => { acquire: %i[major minor], phase: 1 },
          'P5' => { acquire: %i[major minor], phase: 3 },
          'P6' => { acquire: %i[major minor], phase: 3 },
          'P7' => { acquire: %i[major minor], phase: 1 },
          'P8' => { acquire: %i[major minor], phase: 1 },
          'P9' => { acquire: %i[major], phase: 3 },
          'P10' => { acquire: %i[major minor], phase: 1 },
          'P11' => { acquire: %i[major minor], phase: 3 },
          'P12' => { acquire: %i[major minor], phase: 2 },
          'P13' => { acquire: %i[major], phase: 3 },
          'P14' => { acquire: %i[major minor], phase: 3 },
          'P15' => { acquire: %i[major minor], phase: 3 },
          'P16' => { acquire: %i[major minor], phase: 2 },
          'P17' => { acquire: %i[major minor], phase: 5 },
          'P18' => { acquire: %i[major minor], phase: 3 },
          'P19' => { acquire: %i[major minor], phase: 3 },
          'P20' => { acquire: %i[major minor], phase: 1 },
          'P21' => { acquire: %i[major minor], phase: 2 },
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
          'P9' => 'P9 (Mail Service)',
          'P10' => 'P10 (Builder Cubes)',
          'P11' => 'P11 (Extra Tile Lay)',
          'P12' => 'P12 (Small Port)',
          'P13' => 'P13 (Large Port)',
          'P14' => 'P14 (2x Timber Value)',
          'P15' => 'P15 ($10/$30 City Revenue)',
          'P16' => 'P16 (Special Tile Placement)',
          'P17' => 'P17 ($30 Route Enhancement)',
          'P18' => 'P18 (Special Tile Upgrade)',
          'P19' => 'P19 (Rockport Coal Mine)',
          'P20' => 'P20 (Backroom Negotiations)',
          'P21' => 'P21 (Credit Mobiier)',
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

        def setup_associated_minors
          @minor_associations = {
            '1' => 'CPR',
            '5' => 'GNR',
            '7' => 'CMPS',
            '8' => 'SWW',
            '17' => 'SPS',
            '18' => 'ORNC',
            '20' => 'NP',
          }
        end

        def major_name_for_associated_minor(id)
          @minor_associations[id]
        end

        def replace_associated_minor(old_minor_id, new_minor_id)
          @minor_associations[new_minor_id] = @minor_associations.delete(old_minor_id)
        end

        def second_icon(corporation)
          return unless (major_id = major_name_for_associated_minor(corporation.id))

          corporation_by_id(major_id)
        end

        def timeline
          timeline = super
          pairs = @minor_associations.keys.map { |a| "#{a} → #{@minor_associations[a]}" }
          timeline << "Minor Associations: #{pairs.join(', ')}" unless pairs.empty?
          timeline
        end

        def reservation_corporations
          corporations.reject { |c| c.type == :major }
        end

        def home_token_counts_as_tile_lay?(_entity)
          false
        end

        def port_company?(entity)
          %w[P12 P13].include?(entity.id)
        end

        def cube_company?(entity)
          entity.id == 'P10'
        end

        def mill_company?(entity)
          entity.id == 'P15'
        end

        def portage_company?(entity)
          entity.id == 'P16'
        end

        def boomtown_company?(entity)
          entity&.id == 'P18'
        end

        def coal_company?(entity)
          entity&.id == 'P19'
        end

        def owns_coal_company?(entity)
          entity.companies.any? { |c| coal_company?(c) }
        end

        def coal_company_used
          company_by_id('P19').revenue = 0
        end

        def coal_token
          @coal_token ||= Engine::Token.new(nil, logo: '/icons/18_usa/mine.svg')
        end

        def backroom_company?(entity)
          entity.id == 'P20'
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          return super unless coal_company?(selected_company)

          tiles.select { |t| abilities(selected_company).tiles.include?(t.name) }.uniq
        end

        PHASES = [
          {
            name: '1',
            on: '',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            status: ['minor_float_phase1'],
            operating_rounds: 1,
          },
          {
            name: '2',
            on: %w[2 3],
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            status: %w[minor_float_phase2],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains
                       can_acquire_minor_bidbox
                       can_par
                       minors_green_upgrade
                       minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains
                       can_acquire_minor_bidbox
                       can_par
                       full_capitalisation
                       minors_green_upgrade
                       minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '7',
            on: '7',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown gray],
            status: %w[can_buy_trains
                       can_acquire_minor_bidbox
                       can_par
                       full_capitalisation
                       minors_green_upgrade
                       minor_float_phase3on],
            operating_rounds: 2,
          },
        ].freeze

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
            num: 2,
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
        ].freeze

        UPGRADE_COST_L_TO_2_PHASE_2 = 80

        def operating_round(round_num)
          Engine::Game::G1822PNW::Round::Operating.new(self, [
            G1822::Step::PendingToken,
            G1822::Step::FirstTurnHousekeeping,
            G1822PNW::Step::AcquireCompany,
            G1822::Step::DiscardTrain,
            G1822PNW::Step::Assign,
            Engine::Step::SpecialChoose,
            G1822PNW::Step::SpecialTrack,
            G1822::Step::SpecialToken,
            G1822PNW::Step::Track,
            G1822::Step::DestinationToken,
            G1822::Step::Token,
            G1822PNW::Step::Route,
            G1822PNW::Step::Dividend,
            G1822::Step::BuyTrain,
            G1822PNW::Step::MinorAcquisition,
            G1822::Step::PendingToken,
            G1822::Step::DiscardTrain,
            G1822PNW::Step::IssueShares,
          ], round_num: round_num)
        end

        def choose_step
          [G1822::Step::Choose]
        end

        def next_round!
          @round =
            case @round
            when G1822::Round::Choices
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Stock
              G1822::Round::Choices.new(self, choose_step, round_num: @round.round_num)
            when Engine::Round::Operating
              if @phase.name.to_i >= 2
                @log << "-- #{round_description('Merger', @round.round_num)} --"
                G1822PNW::Round::Merger.new(self, [
                  G1822PNW::Step::Merge,
                ], round_num: @round.round_num)
              elsif @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when G1822PNW::Round::Merger
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        MERGER_ROUND_NAME = 'Merger'

        def total_rounds(name)
          # Return the total number of rounds for those with more than one.
          @operating_rounds if [self.class::OPERATING_ROUND_NAME, self.class::MERGER_ROUND_NAME].include?(name)
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

        def stock_round
          G1822PNW::Round::Stock.new(self, [
            G1822::Step::DiscardTrain,
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

        def setup_game_specific
          setup_regional_payout_count
          setup_tokencity_tiles
        end

        def remove_l_trains(num_trains)
          @log << "#{num_trains} L/2 train(s) have been discarded"
          num_trains.times { @depot.remove_train(@depot.upcoming.first) }
        end

        def major_formation_status(major, player: nil)
          return :formed if major.floated?

          minor_id = @minor_associations.keys.find { |m| @minor_associations[m] == major.id }
          minor_corp = corporation_by_id(minor_id)

          if minor_corp&.owner && player
            return minor_corp.owner == player ? :convertable : :none
          end

          company_id = company_id_from_corp_id(minor_id)
          company = @companies.find { |c| c.id == company_id }

          return :parable if !company || !@round.respond_to?(:bids) || @round.bids[company].empty?

          :none
        end

        def corporation_available?(corporation)
          major_formation_status(corporation) != :none
        end

        def form_button_text(_corporation)
          'Convert from minor'
        end

        def after_par(corporation)
          if corporation.type == :major
            minor_id = @minor_associations.keys.find { |m| @minor_associations[m] == corporation.id }
            minor_company = company_by_id(company_id_from_corp_id(minor_id))
            unless minor_company.closed?
              @log << "Associated minor #{minor_id} closes"
              minor_corporation = corporation_by_id(minor_id)
              minor_city = hex_by_id(minor_corporation.coordinates).tile.cities.find { |c| c.reserved_by?(minor_corporation) }
              minor_city.reservations.delete(minor_corporation)
              minor_company.close!
            end
          end
          super
        end

        def float_corporation(corporation)
          remove_home_icon(corporation, corporation.coordinates) if corporation.type == :major
          super
        end

        def add_home_icon(corporation, coordinates)
          hex = hex_by_id(coordinates)
          # Logo and Icon each add '.svg' to the end - so chop one of them off
          hex.tile.icons << Part::Icon.new("../#{corporation.logo.chop.chop.chop.chop}", "#{corporation.id}_home")
        end

        def remove_home_icon(corporation, coordinates)
          hex = hex_by_id(coordinates)
          hex.tile.icons.reject! { |icon| icon.name == "#{corporation.id}_home" }
        end

        def corp_id_from_company_id(id)
          id[1..-1]
        end

        def company_id_from_corp_id(id)
          "M#{id}"
        end

        # setup_companies from 1822 has too much 1822-specific stuff that doesn't apply to this game
        def setup_companies
          setup_associated_minors
          @companies.sort_by! { rand }

          minors = @companies.select { |c| c.id[0] == self.class::COMPANY_MINOR_PREFIX }
          minor_6, minors = minors.partition { |c| c.id == 'M6' }
          minors_assoc, minors = minors.partition { |c| @minor_associations.key?(corp_id_from_company_id(c.id)) }

          privates = @companies.select { |c| c.id[0] == self.class::COMPANY_PRIVATE_PREFIX }
          private_1 = privates.find { |c| c.id == 'P1' }
          privates.delete(private_1)
          privates.unshift(private_1)

          # Clear and add the companies in the correct randomize order sorted by type
          @companies.clear
          @companies.concat(minor_6)
          stack_1 = (minors_assoc[0..2] + minors[0..5]).sort_by! { rand }
          @companies.concat(stack_1)
          stack_2 = (minors_assoc[3..4] + minors[6..10]).sort_by! { rand }
          @companies.concat(stack_2)
          stack_3 = (minors_assoc[5..6] + minors[11..15]).sort_by! { rand }
          @companies.concat(stack_3)
          @companies.concat(privates)

          # Setup company abilities
          @company_trains = {}
          @company_trains['P1'] = find_and_remove_train_by_id('5P-0')
          @company_trains['P2'] = find_and_remove_train_by_id('2P-0', buyable: false)
          @company_trains['P3'] = find_and_remove_train_by_id('LP-0', buyable: false)
          @company_trains['P4'] = find_and_remove_train_by_id('LP-1', buyable: false)
          @company_trains['P5'] = find_and_remove_train_by_id('P+-0', buyable: false)
          @company_trains['P6'] = find_and_remove_train_by_id('P+-1', buyable: false)
        end

        # Stubbed out because this game doesn't it, but base 22 does
        def company_tax_haven_bundle(choice); end

        # Stubbed out because this game doesn't it, but base 22 does
        def company_tax_haven_payout(entity, per_share); end

        def finalize_end_game_values; end

        def set_private_revenues; end

        def setup_regional_payout_count
          @regional_payout_count = {
            'A' => 0,
            'B' => 0,
            'C' => 0,
          }
        end

        def payout_companies
          super
          regionals.each { |r| @regional_payout_count[r.id] += 1 if r.owner }
        end

        def regional_payout_count(regional)
          @regional_payout_count[regional.id]
        end

        def float_str(entity)
          regional_railway?(entity) ? '' : super
        end

        def company_choices(company, time)
          return company_choices_p21(company, time) if company.id == 'P21'

          {}
        end

        def sorted_corporations
          ipoed, others = @corporations.select { |c| c.type == :major }.partition(&:ipoed)
          corporations = ipoed.sort
          corporations += others if @phase.status.include?('can_convert_concessions') || @phase.status.include?('can_par')
          corporations
        end

        def company_choices_p21(company, time)
          return {} unless company.owner&.corporation?
          return {} if time != :token && time != :track && time != :issue

          exclude_minors = bidbox_minors
          exclude_privates = bidbox_privates

          minors_choices = company_choices_p21_companies(self.class::COMPANY_MINOR_PREFIX, exclude_minors)
          privates_choices = company_choices_p21_companies(self.class::COMPANY_PRIVATE_PREFIX, exclude_privates)

          choices = {}
          choices.merge!(minors_choices)
          choices.merge!(privates_choices)
          if company.owner.type == :major && exchange_tokens(company.owner).positive?
            exchange_choice = {}
            exchange_choice['exchange'] = "#{company.owner.name} moves a token from exchange to available"
            choices.merge!(exchange_choice)
          end
          choices.compact
        end

        def company_choices_p21_companies(prefix, exclude_companies)
          choices = {}
          companies = bank_companies(prefix).reject do |company|
            exclude_companies.any? { |c| c == company }
          end
          companies.each do |company|
            choices["#{company.id}_top"] = "#{self.class::COMPANY_SHORT_NAMES[company.id]}-Top"
            choices["#{company.id}_bottom"] = "#{self.class::COMPANY_SHORT_NAMES[company.id]}-Bottom"
          end
          choices
        end

        def company_made_choice(company, choice, _time)
          return company_made_choice_p21(company, choice) if company.id == 'P21'
        end

        def company_made_choice_p21(company, choice)
          if choice == 'exchange'
            @log << "#{company.owner.name} moves one token from exchange to available"
            move_exchange_token(company.owner)
            @log << "#{company.name} closes"
            company.close!
            return
          else
            choice_array = choice.split('_')
            selected_company = company_by_id(choice_array[0])
            top = choice_array[1] == 'top'

            @companies.delete(selected_company)
            if top
              last_bid_box_company = case selected_company.id[0]
                                     when self.class::COMPANY_MINOR_PREFIX
                                       bidbox_minors&.last
                                     else
                                       bidbox_privates&.last
                                     end
              index = @companies.index { |c| c == last_bid_box_company }
              @companies.insert(index + 1, selected_company)
            else
              @companies << selected_company
            end

            @log << "#{company.owner.name} moves #{selected_company.name} to the #{top ? 'top' : 'bottom'}"
          end

          @log << "#{company.name} closes"
          company.close!
        end

        def operating_order
          minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
          minors + majors
        end

        def company_bought(company, entity)
          on_acquired_train(company, entity) if self.class::PRIVATE_TRAINS.include?(company.id)
          company.revenue = 0 if cube_company?(company) || company.id == 'P14' || company.id == 'P9'
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

        def check_other(route)
          raise NoToken, 'Route must contain token' unless route.visited_stops.any? do |stop|
                                                             city_tokened_by?(stop, route.corporation) &&
                                                               !stop.tokens.include?(coal_token)
                                                           end
        end

        def must_be_on_terrain?(_entity)
          false
        end

        def can_only_lay_plain_or_towns?(_entity)
          false
        end

        def can_upgrade_one_phase_ahead?(_entity)
          false
        end

        def company_ability_extra_track?(entity)
          %w[P11 P12 P13].include?(entity.id)
        end

        def choices_entities
          []
        end

        def must_remove_town?(entity)
          %w[P7 P8].include?(entity.id)
        end

        def mill_bonus_amount
          @phase.name.to_i < 5 ? 10 : 30
        end

        def mill_bonus(routes)
          return nil if routes.empty?

          # If multiple routes gets mill bonus, get the biggest one.
          mill_bonus = routes.map { |r| calculate_mill_bonus(r) }.compact
          mill_bonus.sort_by { |v| v[:revenue] }.reverse&.first
        end

        def calculate_mill_bonus(route)
          mill_hex = route.hexes.find { |hex| hex.assigned?('P15') }
          revenue = mill_hex ? mill_bonus_amount : 0
          if mill_hex && (train_type(route.train) == :etrain)
            revenue = mill_hex.tile.cities[0].tokened_by?(route.train.owner) ? mill_bonus_amount * 2 : 0
          end
          { route: route, revenue: revenue }
        end

        def lumber_baron_bonus(routes)
          return nil if routes.empty?

          # If multiple routes gets lumber baron bonus, get the biggest one.
          lumber_baron_bonus = routes.map { |r| calculate_lumber_baron_bonus(r) }.compact
          lumber_baron_bonus.sort_by { |v| v[:revenue] }.reverse&.first
        end

        def calculate_lumber_baron_bonus(route)
          return nil unless route.train.owner.companies.any? { |c| c.id == 'P14' }

          { route: route, revenue: forest_revenue(route) }
        end

        def forest_revenue(route)
          return 0 if train_type(route.train) == :etrain

          10 * route.all_hexes.count { |hex| hex.assigned?('forest') }
        end

        def ski_haus_revenue(route)
          route.all_hexes.any? { |hex| hex.assigned?('P17') } ? 30 : 0
        end

        def portage_penalty(route)
          @portage_tiles ||= %w[PNW1 PNW2].freeze
          return 0 if route.train.owner.companies.any? { |c| portage_company?(c) }

          10 * route.all_hexes.count { |hex| @portage_tiles.include?(hex.tile.name) }
        end

        def revenue_for(route, stops)
          revenue = super
          revenue += forest_revenue(route)
          revenue += ski_haus_revenue(route)
          lumber_baron_bonus = lumber_baron_bonus(route.routes)
          revenue += lumber_baron_bonus[:revenue] if lumber_baron_bonus && lumber_baron_bonus[:route] == route
          mill_bonus = mill_bonus(route.routes)
          revenue += mill_bonus[:revenue] if mill_bonus && mill_bonus[:route] == route
          revenue -= portage_penalty(route)
          revenue
        end

        def revenue_str(route)
          str = super

          mill_bonus = mill_bonus(route.routes)
          if mill_bonus && mill_bonus[:route] == route && (mill_bonus[:revenue]).positive?
            str += " (+#{format_currency(mill_bonus[:revenue])} Mill) "
          end

          lumber_baron_bonus = lumber_baron_bonus(route.routes)
          if lumber_baron_bonus && lumber_baron_bonus[:route] == route
            str += " (+#{format_currency(lumber_baron_bonus[:revenue])} LB) "
          end

          str += ' (+30 Ski Haus) ' if ski_haus_revenue(route).positive?
          str += " (-#{format_currency(portage_penalty(route))} Portage) " if portage_penalty(route).positive?

          str
        end

        def legal_city_and_town_tile(hex, tile)
          @city_and_town_yellow_tiles ||= %w[5 6 57]
          @city_and_town_hex_names ||= %w[H19]
          @city_and_town_hex_names.include?(hex.name) && @city_and_town_yellow_tiles.include?(tile.name)
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return true if legal_city_and_town_tile(from.hex, to) && from.color == :white
          return true if from.color == :blue && to.color == :blue
          return to.name == 'PNW3' if boomtown_company?(selected_company)
          return from.color == :brown if to.name == 'PNW4'
          return to.name == 'PNW5' if from.name == 'PNW4'
          return tokencity_upgrades_to?(from, to) if tokencity?(from.hex)

          super
        end

        def upgrade_ignore_num_cities(from)
          from.hex.id == 'O14' && from.color == :yellow
        end

        def tile_valid_for_phase?(tile, hex: nil, phase_color_cache: nil)
          return true if tile.name == 'PNW5'

          super
        end

        def close_corporation(corporation, quiet: false)
          super
          if associated_minor?(corporation)
            major = associated_major(corporation)
            hex_by_id(corporation.coordinates).tile.cities[0].add_reservation!(major)
            @log << "#{major.name} reservation takes the place of #{corporation.name}"
          elsif regional_railway?(corporation)
            company = company_by_id(company_id_from_corp_id(corporation.id))
            company.owner&.companies&.delete(company)
            company.close!
          end
        end

        def company_status_str(company)
          index = bidbox_minors.index(company) || bidbox_privates.index(company)
          return "Bid box #{index + 1}" if index

          nil
        end

        def status_str(corporation)
          return super unless regional_railway?(corporation)

          "Acquisition value #{format_currency(200)}"
        end

        def total_terrain_cost(tile)
          tile.upgrades.sum { |u| u.terrains.empty? ? 0 : u.cost }
        end

        def can_place_river(tile)
          @river_directions ||= { 'M4' => 5, 'N5' => 2, 'H13' => 1 }
          return false unless @river_directions.include?(tile.hex.id)

          tile.paths.find { |p| !p.edges.empty? && p.edges[0].num == @river_directions[tile.hex.id] }.nil?
        end

        def upgrade_cost(tile, hex, entity, spender)
          return tokencity_upgrade_cost(tile, hex) if tokencity?(hex)

          super
        end

        def tile_cost_with_discount(tile, _hex, _entity, _spender, base_cost)
          return 0 if tile.name == 'PNW3'

          [base_cost - (40 * current_builder_cubes(tile)), 0].max
        end

        def regional_railway?(entity)
          @regional_railways ||= %w[A B C].freeze
          @regional_railways.include?(entity.id)
        end

        def regional_railway_company?(entity)
          @regional_railway_companies ||= %w[MA MB MC].freeze
          @regional_railway_companies.include?(entity.id)
        end

        def associated_minor?(entity)
          @minor_associations.include?(entity.id)
        end

        def associated_minors
          @corporations.select { |c| c.floated? && @minor_associations.include?(c.id) }
        end

        def unassociated_minors
          @corporations.select { |c| c.floated? && c.type == :minor && !@minor_associations.include?(c.id) }
        end

        def regionals
          # Not cached because @corporations can change
          @corporations.select { |c| regional_railway?(c) }
        end

        def company_header(company)
          regional_railway_company?(company) ? 'REGIONAL RAILWAY' : super
        end

        def associated_major(minor)
          corporation_by_id(@minor_associations[minor.id])
        end

        def associated_minor(major)
          corporation_by_id(@minor_associations.keys.find { |m| @minor_associations[m] == major.id })
        end

        def forest?(tile)
          tile.terrain.include?(:forest)
        end

        def transfer_posessions(from, to)
          receiving = []

          if from.cash.positive?
            receiving << format_currency(from.cash)
            from.spend(from.cash, to)
          end

          companies = transfer(:companies, from, to).map(&:name)
          receiving << "companies (#{companies.join(', ')})" unless companies.empty?

          trains = transfer(:trains, from, to).map(&:name)
          receiving << "trains (#{trains})" unless trains.empty?

          from.tokens.each do |token|
            next unless token == coal_token

            token.corporation = to
            to.tokens << token
            receiving << 'Mine token'
          end

          log << "#{to.name} receives #{receiving.join(', ')} from #{from.name}" unless receiving.empty?
        end

        def close_minor(minor)
          minor.owner.shares_by_corporation.delete(minor)
          minor.close!
          corporations.delete(minor)
        end

        def check_destination_duplicate(entity, hex)
          city = hex.tile.cities.first
          return unless city.tokened_by?(entity)

          @log << "#{entity.name} has an existing token on its destination #{hex.name} and will pick it up as an available token"
          entity.tokens.find { |t| t.city == city }.remove!
        end

        def after_lay_tile(hex, old_tile, tile)
          hex.neighbors[1].tile.borders.shift if hex.id == 'H13' && tile.exits.include?(1)
          super
        end

        def home_token_can_be_cheater
          true
        end

        def buyable_bank_owned_companies
          @round.active_step.respond_to?(:hide_bank_companies?) && @round.active_step.hide_bank_companies? ? [] : super
        end
      end
    end
  end
end
