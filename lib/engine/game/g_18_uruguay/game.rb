# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'map'
require_relative 'corporations'
require_relative 'companies'
require_relative 'trains'
require_relative 'phases'
require_relative 'step/ability_ship'
require_relative '../../loan'
require_relative 'step/corn_farm'
require_relative 'step/payoff_loans'

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

        GAME_END_CHECK = { custom: :one_more_full_or_set }.freeze

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
        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          nationalization: ['Nationalization',
                            'Time for nationalization']
        ).freeze

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['Dividend 0 or withheld', '1 ←'],
            ['Dividend paid', '1 →'],
            ['One or more shares sold (Except RLTP)', '1 ↓'],
            ['Corporation sold out at end of SR', '1 ↑'],
          ]
        end

        def init_optional_rules(optional_rules)
          super
        end

        def find_and_remove_train_by_id(train_id)
          train = train_by_id(train_id)
          return unless train

          @depot.remove_train(train)
          train.buyable = true
          train.reserved = true
          train
        end

        def setup
          super
          @rptla = @corporations.find { |c| c.id == 'RPTLA' }
          @fce = @corporations.find { |c| c.id == 'FCE' }

          @rptla.add_ability(Engine::G18Uruguay::Ability::Ship.new(
            type: 'Ship',
            description: 'Ship goods'
          ))
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

        def init_train_handler
          depot = super

          # Due to that the nationalization happens on second 6 purchase an not on a phase change,
          # the event needs to be tied to a train.
          train = depot.upcoming.reverse.find { |t| t.name == '6' }
          train.events << { 'type' => 'nationalization' }

          depot
        end

        def lookup_rptla_price(price)
          @stock_market.market[RPTLA_STOCK_ROW].each do |sp|
            return sp if sp.price == price
          end
        end

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

        def corn_farm
          @corn_farm ||= company_by_id('LA_CORN')
        end

        def sheep_farm
          @sheep_farm ||= company_by_id('LO_SHEEP')
        end

        def cattle_farm
          @cattle_farm ||= company_by_id('LO_CATTLE')
        end

        def train_with_goods?(train)
          return unless train

          train.name.include?(self.class::GOODS_TRAIN)
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G18Uruguay::Step::BuySellParShares,
          ])
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
            G18Uruguay::Step::Track,
            G18Uruguay::Step::Token,
            G18Uruguay::Step::Route,
            G18Uruguay::Step::Dividend,
            G18Uruguay::Step::DiscardTrain,
            G18Uruguay::Step::BuyTrain,
            [G18Uruguay::Step::TakeLoanBuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def new_nationalization_round(round_num)
          G18Uruguay::Round::Nationalization.new(self, [
              G18Uruguay::Step::DiscardTrain,
              G18Uruguay::Step::PayoffLoans,
              G18Uruguay::Step::NationalizeCorporation,
              G18Uruguay::Step::RemoveTokens,
              ], round_num: round_num)
        end

        def multiple_buy_only_from_market?
          !optional_rules&.include?(:multiple_brown_from_ipo)
        end

        def home_token_locations(corporation)
          raise NotImplementedError unless corporation.name == 'FCE'

          hexes = @hexes.dup
          hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
          end
        end

        def reset_adjustable_trains!(_entity, routes)
          routes.each do |route|
            p 'Find a way to clear train from good' if train_with_goods?(route.train)
          end
        end

        def visits_include_port?(visits)
          visits.each do |visit|
            return true if PORTS.include?(visit.hex.id)
          end
          false
        end

        def route_include_port?(route)
          route.hexes.each do |hex|
            return true if PORTS.include?(hex.id)
          end
          false
        end

        def reset_train!(_train)
          p 'Reset train!'
          # train.name = train.name.partition('+')[0] unless train.nil?
        end

        def check_for_goods_if_run_to_port(route, visits)
          true if route.corporation == @rptla
          visits_include_port?(visits) || !train_with_goods?(route.train)
        end

        def check_for_port_if_goods_attached(route, visits)
          true if route.corporation == @rptla
          !visits_include_port?(visits) || train_with_goods?(route.train)
        end

        def check_distance(route, visits, train = nil)
          @round.current_routes |= [route]
          if route.corporation != @rptla && !nationalized?
            raise RouteTooLong, 'Need to have goods to run to port' unless check_for_port_if_goods_attached(route,
                                                                                                            visits)
            raise RouteTooLong, 'Goods needs to be shipped to port' unless check_for_goods_if_run_to_port(route,
                                                                                                          visits)
          end
          raise RouteTooLong, '4D trains cannot deliver goods' if route.train.name == '4D' && visits_include_port?(visits)

          super
        end

        def operating_order
          super.sort.partition { |c| c.type != :bank }.flatten
        end

        def float_corporation(corporation)
          return if corporation == @rptla
          return unless @loans

          amount = corporation.par_price.price * 5
          @bank.spend(amount, corporation)
          @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
          take_loan(corporation, @loans[0]) if @loans.size.positive? && !nationalized?
        end

        def second_capitilization!(corporation)
          amount = corporation.par_price.price * 5
          @bank.spend(amount, corporation)
          @log << "Connected to destination #{corporation.name} receives #{format_currency(amount)}"
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

        def after_par(corporation)
          super
          return unless corporation == @rptla

          train = find_and_remove_train_by_id('Ship 1-0')
          buy_train(@rptla, train)
        end

        # LOANS
        def init_loans
          @loan_value = 100
          Array.new(NUMBER_OF_LOANS) { |id| Loan.new(id, @loan_value) }
        end

        def maximum_loans(entity)
          entity == @rptla ? NUMBER_OF_LOANS : entity.num_player_shares
        end

        def loans_due_interest(entity)
          entity.loans.size
        end

        def interest_owed(entity)
          return 0 if entity == @rptla

          10 * loans_due_interest(entity)
        end

        def interest_owed_for_loans(count)
          10 * count
        end

        def can_take_loan?(entity, ebuy: nil)
          # return false if nationalized?
          return false if entity == @rlpta
          return true if ebuy

          entity.corporation? &&
            entity.loans.size < maximum_loans(entity) &&
            !@loans.empty?
        end

        def take_loan(entity, loan, ebuy: nil)
          raise GameError, "Cannot take more than #{maximum_loans(entity)} loans" unless can_take_loan?(entity, ebuy: ebuy)

          # raise GameError, "Not allowed to take loans after nationalization" if @game.nationalized?

          @bank.spend(loan.amount, entity)
          entity.loans << loan
          rptla.loans << loan.dup
          @loans.delete(loan)
          @log << "#{entity.name} takes a loan and receives #{format_currency(loan.amount)}"
        end

        def payoff_loan(entity, number_of_loans, spender)
          total_amount = 0
          number_of_loans.times do |_i|
            paid_loan = entity.loans.pop
            amount = paid_loan.amount
            total_amount += amount
            spender.spend(amount, @bank)
          end
          @log << "#{spender.name} payoff #{number_of_loans} loan(s) for #{entity.name} and pays #{total_amount}"
        end

        def adjust_stock_market_loan_penalty(entity)
          delta = entity.loans.size - maximum_loans(entity)
          return unless delta.positive?

          delta.times do |_i|
            @stock_market.move_left(entity)
          end
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

        def share_holder_list(originator, corps)
          @players.rotate(@players.index(originator.owner)).select do |p|
            corps.any? do |c|
              !p.shares_of(c).empty?
            end
          end
        end

        def affected_shares(entity, corps)
          affected = entity.shares.select { |s| s.corporation == corps.first }.sort_by(&:percent).reverse
          affected.concat(entity.shares.select { |s| s.corporation == corps.last }.sort_by(&:percent).reverse) unless corps.one?
          affected
        end

        def find_president(holders, corps)
          president_candidate = nil
          candidate_sum = 0
          holders.each do |holder|
            entity_shares = affected_shares(holder, corps)
            sum = entity_shares.sum(&:percent)
            if sum > candidate_sum
              president_candidate = holder
              candidate_sum = sum
            end
          end
          president_candidate
        end

        def transfer_share(share, new_owner)
          corp = share.corporation
          corp.share_holders[share.owner] -= share.percent
          corp.share_holders[new_owner] += share.percent
          share.owner.shares_by_corporation[corp].delete(share)
          new_owner.shares_by_corporation[corp] << share
          share.owner = new_owner
        end

        def transfer_pres_share(corporation, owner)
          pres_share = corporation.presidents_share
          transfer_share(pres_share, owner)
          corporation.owner = owner
        end

        def acquire_shares_in_fce(corp_fce, merge_data)
          new_president = find_president(merge_data[:holders], merge_data[:corps])
          transfer_pres_share(corp_fce, new_president)
          # @share_pool.change_president(corp_fce.presidents_share, corp_fce, new_president)
          merge_data[:holders].each do |holder|
            aquired = 0
            aquired = 20 if holder == new_president
            entity_shares = affected_shares(holder, merge_data[:corps])
            total_percent = entity_shares.sum(&:percent)
            aquire_percent = (total_percent / 20).to_i * 10
            while aquired < aquire_percent
              share = corp_fce.shares.first
              aquired += share.percent
              transfer_share(share, holder)
            end
            number = aquire_percent
            @log << "#{holder.name} recives #{number}% in FCE in exchange to the nationalized shares"
            odd_share = aquired * 2 != total_percent
            next unless odd_share

            price = corp_fce.share_price.price / 2
            @bank.spend(price, holder)
            @log << "#{holder.name} recives #{price} from halv share"
          end
          @log << "#{new_president.name} becomes new president of #{corp_fce.name}"
        end

        def compute_merger_share_price(corp_a, corp_b)
          price = corp_a.share_price.price
          price = (corp_a.share_price.price + corp_b.share_price.price) / 2 unless corp_b.nil?
          max_share_price = nil
          @stock_market.market.reverse_each do |row|
            next if row.first.coordinates[0] == RPTLA_STOCK_ROW

            share_price = row.max_by { |p| p.price <= price ? p.price : nil }
            next if share_price.nil?

            max_share_price = share_price if max_share_price.nil?
            max_share_price = share_price if max_share_price.price < share_price.price
            if max_share_price.price == share_price.price && max_share_price.coordinates[1] == share_price.coordinates[1]
              max_share_price = share_price
            end
          end
          max_share_price
        end

        def move_assets(corp_fce, corp)
          # cash
          corp.spend(corp.cash, corp_fce) if corp.cash.positive?
          # train
          corp.trains.each { |train| train.owner = corp_fce }
          corp_fce.trains.concat(corp.trains)
          corp.trains.clear
          corp_fce.trains.each { |t| t.operated = false }
        end

        def swap_token(survivor, nonsurvivor, old_token)
          city = old_token.city
          exist = city.tokens.find { |token| token&.corporation == survivor }
          nonsurvivor.tokens.delete(old_token)
          if exist
            @log << "Token removed in #{city.hex.id} since FCE already have one token in that location"
            city.tokens[city.tokens.find_index(old_token)] = nil
            return nil
          end
          new_token = survivor.next_token
          @log << "Replaced #{nonsurvivor.name} token in #{city.hex.id} with #{survivor.name} token"
          new_token.place(city)
          city.tokens[city.tokens.find_index(old_token)] = new_token
          new_token
        end

        def place_home_token(corporation)
          return if corporation == @fce

          super
        end

        def corps_to_nationalize
          @round.entities.select { |entity| entity.loans.size.positive? && entity != @rptla }
        end

        def start_merge(originatior, _entity_a, _entity_b)
          candidates = corps_to_nationalize
          corp_a = nil
          corp_b = nil
          corps = []
          if candidates.size.positive?
            corp_a = candidates.shift
            corps.append(corp_a)
          end
          if candidates.size.positive?
            corp_b = candidates.shift
            corps.append(corp_b)
          end
          @merge_data = {
            holders: share_holder_list(originatior, corps),
            corps: corps,
            secondary_corps: [],
            home_tokens: [],
            tokens: [],
            candidates: candidates,
          }

          if corp_a.nil?
            @fce.close!
            @corporations.delete(@fce)
            return
          end

          @fce.ipoed = true
          fce_share_price = compute_merger_share_price(corp_a, corp_b)
          @fce.floatable = true
          @stock_market.set_par(@fce, fce_share_price)
          after_par(@fce)

          acquire_shares_in_fce(@fce, @merge_data)
        end

        def routes_revenue(route, corporation)
          revenue = super
          return revenue if @rptla != corporation

          revenue += (corporation.loans.size.to_f / 2).floor * 10
          revenue
        end

        def routes_subsidy(route, corporation)
          return super if @rptla != corporation

          (corporation.loans.size.to_f / 2).ceil * 10
        end

        def goods_on_train(train)
          m = train.name.match(/.*\+.*(?<count>\d+).*/)
          return 0 if m.nil?

          m[:count]&.to_i
        end

        def revenue_for(route, stops)
          revenue = super
          revenue *= 2 if route.train.name == '4D'
          revenue *= 2 if final_operating_round?
          return revenue unless route&.corporation == @rptla

          train = route.train
          revenue * goods_on_train(train)
        end

        def revenue_str(route)
          return super unless route&.corporation == @rptla

          'Ship'
        end

        def nationalization_final_export!
          number_of_goods_at_harbor
          @log << '  Nationalization: Final Export'
        end

        def nationalization_close_rptla!
          @log << '  Nationalization: RPTLA closes'
          corporation = @rptla
          corporation.share_holders.keys.each do |share_holder|
            shares = share_holder.shares_of(corporation)
            bundle = ShareBundle.new(shares)
            sell_shares_and_change_price(bundle) unless corporation == share_holder
          end
          @rptla.close!
          @corporations.delete(@rptla)
        end

        def close_rptla_private!
          sym = 'JOHN'
          company = @companies.find { |comp| comp.sym == sym }
          return if company.closed?

          @log << ('RPTLA buys its first non-yellow ship: ' + company&.name + ' closes')
          company&.close!
        end

        def nationalization_close_private!
          sym = 'AP'
          company = @companies.find { |comp| comp.sym == sym }
          @log << ('  Nationalization: ' + company&.name + ' closes')
          company&.close!
        end

        def nationalized?
          @nationalized
        end

        def custom_end_game_reached?
          @nationalized
        end

        def event_nationalization!
          print('-- Event: Nationalization! --')
          @log << '-- Event: Nationalization! --'
          @nationalization_triggered = true
          nationalization_final_export!
          nationalization_close_rptla!
          nationalization_close_private!
          @nationalized = true
          train = train_by_id('7-0')
          buy_train(@fce, train, :free)
        end

        def retreive_home_tokens
          home_tokens = []
          tokens = []
          @merge_data[:corps].each do |corp|
            home_tokens.append(corp.tokens[0])
            tokens += corp.tokens
          end
          @merge_data[:secondary_corps].each do |corp|
            home_tokens.append(corp.tokens[0])
            tokens += corp.tokens
          end
          tokens = tokens.select { |token| !home_tokens.include?(token) && !token.hex.nil? }
          if home_tokens.size >= @fce.tokens.size
            tokens.each do |token|
              @log << "Remove #{token.corporation.name} token from hex #{token.hex.id}"
              token.destroy!
            end
            tokens = []
          end

          (home_tokens.size + tokens.size - @fce.tokens.size).times { @fce.tokens << Token.new(@fce, price: 0) }
          home_tokens.each do |token|
            new_token = swap_token(@fce, token.corporation, token)
            @merge_data[:home_tokens].append(new_token) unless new_token.nil?
          end
          tokens.each do |token|
            new_token = swap_token(@fce, token.corporation, token)
            @merge_data[:tokens].append(new_token) unless new_token.nil?
          end
        end

        def remove_corporation!(corporation)
          @log << "#{corporation.name} is merge into FCE and removed from the game"

          # remove_marker(corporation)

          corporation.share_holders.keys.each do |share_holder|
            share_holder.shares_by_corporation.delete(corporation)
          end

          @share_pool.shares_by_corporation.delete(corporation)
          corporation.share_price&.corporations&.delete(corporation)
          corporation.close!
          @corporations.delete(corporation)
        end

        def close_companies
          @merge_data[:corps].each do |corp|
            move_assets(@fce, corp)
            remove_corporation!(corp)
          end
          @merge_data[:secondary_corps].each do |corp|
            move_assets(@fce, corp)
            remove_corporation!(corp)
          end
          @corporations.delete(@rlpta)
        end

        def take_loan_if_needed_for_interest!(entity)
          owed = interest_owed(entity)
          return if owed.zero?

          remaining = owed - entity.cash
          perform_ebuy_loans(entity, remaining + 10) if remaining.positive?
        end

        def corps_pay_interest
          corps = @round.entities.select { |entity| entity.loans.size.positive? && entity != @rptla }
          corps.each do |corp|
            next if corp.closed?

            take_loan_if_needed_for_interest!(corp)
            pay_interest!(corp)
          end
        end

        def or_round_finished
          corps_pay_interest unless nationalized?
        end

        def next_round!
          @round =
            case @round
            when G18Uruguay::Round::Nationalization
              case @round.round_num
              when 1
                start_merge(current_entity.owner)
              when 2
                retreive_home_tokens
                close_companies
                @crowded_corps = nil
                @cert_limit = CERT_LIMIT_NATIONALIZATION[@players.size][@corporations.size]
                @log << "New certification limit is #{@cert_limit}"
              end

              if @round.round_num < 3
                new_nationalization_round(@round.round_num + 1)
              elsif @saved_or_round
                # reorder_players
                @log << '--Return to Operating Round--'
                @saved_or_round
              else
                new_operating_round
              end
            when Engine::Round::Operating
              if @nationalization_triggered
                @nationalization_triggered = false
                @saved_or_round = @round
                new_nationalization_round(1)
              else
                super
              end
            else
              super
            end
        end

        def float_str(entity)
          return super if !entity.corporation || entity.floatable

          'Nationalization'
        end

        def final_operating_round?
          @final_turn == @turn
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

        def can_hold_above_corp_limit?(_entity)
          true
        end
      end
    end
  end
end
