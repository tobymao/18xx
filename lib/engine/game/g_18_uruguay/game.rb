# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'map'
require_relative 'corporations'
require_relative 'companies'
require_relative 'trains'
require_relative 'phases'
require_relative 'loans'
require_relative '../../loan'

module Engine
  module Game
    module G18Uruguay
      class Game < Game::Base
        attr_accessor :merge_data
        attr_reader :rptla, :fce, :nationalization_triggered, :nationalization

        include_meta(G18Uruguay::Meta)
        include Map
        include Corporations
        include Companies
        include Trains
        include Phases
        include InterestOnLoans
        include Loans

        EBUY_SELL_MORE_THAN_NEEDED = true
        GOODS_TRAIN = 'Goods'

        register_colors(darkred: '#ff131a',
                        red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')

        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy
        TILE_RESERVATION_BLOCKS_OTHERS = true
        CURRENCY_FORMAT_STR = '$U%d'
        GOODS_DESCRIPTION_STR = 'Number of goods: '

        MUST_BUY_TRAIN = :always

        BANK_CASH = 12_000

        CERT_LIMIT = { 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 3 => 630, 4 => 475, 5 => 380, 6 => 320 }.freeze

        RPTLA_STARTING_CASH = 50
        RPTLA_STARTING_PRICE = 50
        RPTLA_STOCK_ROW = 11
        NUMBER_OF_LOANS = 99
        LOAN_VALUE = 100

        GAME_END_CHECK = { bankrupt: :immediate, custom: :one_more_full_or_set }.freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'Nationalized'
        )

        ASSIGNMENT_TOKENS = {
          'GOODS_CORN' => '/icons/18_zoo/wheat.svg',
          'GOODS_CORN0' => '/icons/18_zoo/wheat.svg',
          'GOODS_CORN1' => '/icons/18_zoo/wheat.svg',
          'GOODS_CORN2' => '/icons/18_zoo/wheat.svg',
          'GOODS_CORN3' => '/icons/18_zoo/wheat.svg',
          'GOODS_CORN4' => '/icons/18_zoo/wheat.svg',
          'GOODS_CORN5' => '/icons/18_zoo/wheat.svg',
          'GOODS_CORN6' => '/icons/18_zoo/wheat.svg',
          'GOODS_CORN7' => '/icons/18_zoo/wheat.svg',
          'GOODS_CORN8' => '/icons/18_zoo/wheat.svg',
          'GOODS_CORN9' => '/icons/18_zoo/wheat.svg',
          'GOODS_CORN10' => '/icons/18_zoo/wheat.svg',
          'GOODS_SHEEP' => '/icons/1846/meat.svg',
          'GOODS_SHEEP0' => '/icons/1846/meat.svg',
          'GOODS_SHEEP1' => '/icons/1846/meat.svg',
          'GOODS_SHEEP2' => '/icons/1846/meat.svg',
          'GOODS_SHEEP3' => '/icons/1846/meat.svg',
          'GOODS_SHEEP4' => '/icons/1846/meat.svg',
          'GOODS_SHEEP5' => '/icons/1846/meat.svg',
          'GOODS_SHEEP6' => '/icons/1846/meat.svg',
          'GOODS_SHEEP7' => '/icons/1846/meat.svg',
          'GOODS_SHEEP8' => '/icons/1846/meat.svg',
          'GOODS_SHEEP9' => '/icons/1846/meat.svg',
          'GOODS_SHEEP10' => '/icons/1846/meat.svg',
          'GOODS_CATTLE' => '/icons/1846/meat.svg',
          'GOODS_CATTLE0' => '/icons/1846/meat.svg',
          'GOODS_CATTLE1' => '/icons/1846/meat.svg',
          'GOODS_CATTLE2' => '/icons/1846/meat.svg',
          'GOODS_CATTLE3' => '/icons/1846/meat.svg',
          'GOODS_CATTLE4' => '/icons/1846/meat.svg',
          'GOODS_CATTLE5' => '/icons/1846/meat.svg',
          'GOODS_CATTLE6' => '/icons/1846/meat.svg',
          'GOODS_CATTLE7' => '/icons/1846/meat.svg',
          'GOODS_CATTLE8' => '/icons/1846/meat.svg',
          'GOODS_CATTLE9' => '/icons/1846/meat.svg',
          'GOODS_CATTLE10' => '/icons/1846/meat.svg',
        }.freeze

        PORTS = %w[E1 G1 I1 J4 K5 K7 K13].freeze
        MARKET = [
          %w[70 75 80 90 100p 110 125 150 175 200 225 250 275 300 325 350 375 400 425 450],
          %w[65 70 75 80 90p 100 110 125 150 175 200 225 250 275 300 325 350 375 400 425],
          %w[60 65 70 75 80p 90 100 110 125 150 175 200 225 250 275],
          %w[55 60 65 70 75p 80 90 100 110 125 150 175 200],
          %w[50y 55 60 65 70p 75 80 90 100 110 125],
          %w[45y 50y 55 60 65p 70 75 80 90],
          %w[40o 45y 50y 55 60 65 70],
          %w[35o 40o 45y 50y 55 60],
          %w[30o 35o 40o 45y 50y],
          %w[0c 30o 35o 40o 45y],
          %w[0c 0c 30o 35o 40o],
          %w[50r 60r 70r 80r 90r 100r 110r 120r 130r 140r 150r 160r 180r 200r],
        ].freeze

        CERT_LIMIT_NATIONALIZATION = {
          3 => { 3 => 20, 4 => 10, 5 => 13, 6 => 15, 7 => 18, 8 => 20, 9 => 22 },
          4 => { 3 => 7, 4 => 8, 5 => 10, 6 => 12, 7 => 14, 8 => 16, 9 => 18 },
          5 => { 3 => 6, 4 => 7, 5 => 8, 6 => 10, 7 => 11, 8 => 13, 9 => 15 },
          6 => { 3 => 5, 4 => 6, 5 => 7, 6 => 8, 7 => 10, 8 => 11, 9 => 12 },
        }.freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          par: 'Par value',
          repar: 'RLTP stock price',
          close: 'Close',
          endgame: 'End game trigger',
        )

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          liquidation: :darkred
        )

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['Dividend 0 or withheld', '1 ←'],
            ['Dividend paid', '1 →'],
            ['One or more shares sold (Except RLTP)', '1 ↓'],
            ['Corporation sold out at end of SR', '1 ↑'],
          ]
        end

        def find_and_remove_train_by_id(train_id)
          train = train_by_id(train_id)
          return unless train

          @depot.remove_train(train)
          train.buyable = true
          train.reserved = true
          train
        end

        def corn_farm
          @corn_farm ||= company_by_id('LA_CORN')
        end

        def sheep_farm
          @sheep_farm ||= company_by_id('LO_SHEEP')
        end

        def cattle_farm
          @cattle_farm ||= company_by_id('LO_CATTLE')
        end

        def setup
          super
          @rptla = @corporations.find { |c| c.id == 'RPTLA' }
          @fce = @corporations.find { |c| c.id == 'FCE' }

          @rptla.add_ability(Engine::Ability::Base.new(
            type: 'Goods',
            description: GOODS_DESCRIPTION_STR + '0',
            count: 0
          ))

          @rptla.add_ability(Engine::Ability::Base.new(
            type: 'Incremental',
            description: 'Incremental capatilization',
            count: 0
          ))

          @stock_market.set_par(@rptla, lookup_rptla_price(RPTLA_STARTING_PRICE))

          ability = abilities(corn_farm, :assign_hexes, time: 'or_start', strict_time: false)
          ability.hexes.each do |farm_id|
            hex_by_id(farm_id).assign!('GOODS_CORN')
          end

          ability = abilities(sheep_farm, :assign_hexes, time: 'or_start', strict_time: false)
          ability.hexes.each do |farm_id|
            hex_by_id(farm_id).assign!('GOODS_SHEEP')
          end

          ability = abilities(cattle_farm, :assign_hexes, time: 'or_start', strict_time: false)
          ability.hexes.each do |farm_id|
            hex_by_id(farm_id).assign!('GOODS_CATTLE')
          end

          setup_destinations
        end

        def lookup_rptla_price(price)
          @stock_market.market[RPTLA_STOCK_ROW].each do |sp|
            return sp if sp.price == price
          end
        end

        def setup_destinations
          @corporations.each do |c|
            next unless c.destination_coordinates

            dest_hex = hex_by_id(c.destination_coordinates)
            ability = Ability::Base.new(
              type: :destination_bonus,
              description: destination_description(c),
              count: 1
            )
            c.add_ability(ability)

            dest_hex.tile.icons << Part::Icon.new("../#{c.destination_icon}", "#{c.id}_destination")
          end
        end

        def destination_description(corporation)
          dest_hex = hex_by_id(corporation.destination_coordinates)

          "Destination bonus: #{dest_hex.location_name} (#{dest_hex.name})"
        end

        def after_par(corporation)
          super
          return unless corporation == @rptla

          train = find_and_remove_train_by_id('Ship 1-0')
          buy_train(@rptla, train)
        end

        def after_buy_company(player, company, _price)
          abilities(company, :shares) do |ability|
            ability&.shares&.each do |share|
              return super unless share.corporation == @rptla

              share_pool.buy_shares(player, share, exchange: :free)
              after_par(share.corporation) if share.president
              ability.use!
            end
          end
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            G18Uruguay::Step::CornFarm,
            G18Uruguay::Step::SheepFarm,
            G18Uruguay::Step::CattleFarm,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            G18Uruguay::Step::TakeLoanBuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            G18Uruguay::Step::Token,
            Engine::Step::Route,
            G18Uruguay::Step::Dividend,
            G18Uruguay::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [G18Uruguay::Step::TakeLoanBuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def abilities_ignore_owner(entity, type = nil, time: nil, on_phase: nil, passive_ok: nil, strict_time: nil)
          return nil unless entity

          active_abilities = entity.all_abilities.select do |ability|
            ability_right_type?(ability, type) &&
              ability_usable_this_or?(ability) &&
              ability_right_time?(ability,
                                  time,
                                  on_phase,
                                  passive_ok.nil? ? true : passive_ok,
                                  strict_time.nil? ? true : strict_time) &&
              ability_usable?(ability)
          end

          active_abilities.each { |a| yield a, a.owner } if block_given?

          return nil if active_abilities.empty?
          return active_abilities.first if active_abilities.one?

          active_abilities
        end

        # Nationalized
        def nationalized?
          @nationalized
        end

        def operating_order
          super.sort.partition { |c| c.type != :bank }.flatten
        end

        # Loans
        def float_corporation(corporation)
          return if corporation == @rptla
          return unless @loans

          amount = corporation.par_price.price * 5
          @bank.spend(amount, corporation)
          @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
          take_loan(corporation, @loans[0]) if @loans.size.positive? && !nationalized?
        end

        def perform_ebuy_loans(entity, remaining)
          ebuy = true
          while remaining.positive? && entity.share_price.price != 0
            # if at max loans, company goes directly into receiverhsip
            if @loans.empty?
              @log << "There are no more loans available to force buy a train, #{entity.name} goes into receivership"
              break
            end
            loan = @loans.first
            take_loan(entity, loan, ebuy: ebuy)
            remaining -= loan.amount
          end
        end

        # Goods
        def number_of_goods_at_harbor
          ability = @rptla.abilities.find { |a| a.type == 'Goods' }
          ability.description[/\d+/].to_i
        end

        def add_good_to_rptla
          ability = @rptla.abilities.find { |a| a.type == 'Goods' }
          count = number_of_goods_at_harbor + 1
          ability.description = GOODS_DESCRIPTION_STR + count.to_s
        end

        def remove_goods_from_rptla(goods_count)
          return if number_of_goods_at_harbor < goods_count

          ability = @rptla.abilities.find { |a| a.type == 'Goods' }
          count = number_of_goods_at_harbor - goods_count
          ability.description = GOODS_DESCRIPTION_STR + count.to_s
        end

        def check_distance(route, visits, train = nil)
          @round.current_routes[route.train] = route
          if route.corporation != @rptla && !nationalized?
            raise RouteTooLong, 'Need to have goods to run to port' unless check_for_port_if_goods_attached(route,
                                                                                                            visits)
            raise RouteTooLong, 'Goods needs to be shipped to port' unless check_for_goods_if_run_to_port(route,
                                                                                                          visits)
          end
          raise RouteTooLong, '4D trains cannot deliver goods' if route.train.name == '4D' && visits_include_port?(visits)

          super
        end

        # Revenue
        def revenue_str(route)
          return super unless route&.corporation == @rptla

          'Ship'
        end

        def rptla_revenue(corporation)
          return 0 if @rptla != corporation

          (corporation.loans.size.to_f / 2).floor * 10
        end

        def rptla_subsidy(corporation)
          return 0 if @rptla != corporation

          (corporation.loans.size.to_f / 2).ceil * 10
        end

        def revenue_for(route, stops)
          revenue = super
          revenue *= 2 if route.train.name == '4D'
          revenue *= 2 if final_operating_round?
          return revenue unless route&.corporation == @rptla

          train = route.train
          revenue * goods_on_train(train)
        end

        def or_round_finished
          corps_pay_interest unless nationalized?
        end

        def final_operating_round?
          @final_turn == @turn
        end
      end
    end
  end
end
