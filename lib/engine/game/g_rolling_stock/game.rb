# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'entities'

module Engine
  module Game
    module GRollingStock
      class Game < Game::Base
        include_meta(GRollingStock::Meta)
        include Entities

        attr_reader :foreign_investor, :company_deck, :company_highlight, :company_level, :company_synergies,
                    :cost_level, :cost_table, :offering

        register_colors(black: '#16190e',
                        blue: '#0189d1',
                        brown: '#7b352a',
                        gray: '#7c7b8c',
                        green: '#3c7b5c',
                        olive: '#808000',
                        lightGreen: '#009a54ff',
                        lightBlue: '#4cb5d2',
                        lightishBlue: '#0097df',
                        teal: '#009595',
                        orange: '#d75500',
                        magenta: '#d30869',
                        purple: '#772282',
                        red: '#ef4223',
                        rose: '#b7274c',
                        coral: '#f3716d',
                        white: '#fff36b',
                        navy: '#000080',
                        cream: '#fffdd0',
                        yellow: '#ffdea8')

        CURRENCY_FORMAT_STR = '$%s'
        BANK_CASH = 10_000
        STARTING_CASH = { 2 => 30, 3 => 30, 4 => 30, 5 => 30, 6 => 25 }.freeze

        MARKET = [
          %w[0c
             5
             6
             7
             8
             9
             10
             11
             12
             13
             14
             15
             16
             18
             20
             22
             24
             26
             28
             31
             34
             37
             41
             45
             50
             55
             60
             66
             73
             81
             90
             100e],
        ].freeze

        MARKET_TEXT = {
          par: 'Par value',
          no_cert_limit: 'Corporation shares do not count towards cert limit',
          unlimited: 'Corporation shares can be held above 60%',
          multiple_buy: 'Can buy more than one share in the corporation per turn',
          close: 'Corporation closes',
          endgame: 'End game trigger',
          liquidation: 'Liquidation',
          repar: 'Minor company value',
          ignore_one_sale: 'Ignore first share sold when moving price',
        }.freeze

        TILES = [].freeze
        LAYOUT = :none
        CERT_LIMIT = 99

        SELL_MOVEMENT = :left_share_pres
        SELL_BUY_ORDER = :sell_buy
        GAME_END_CHECK = { custom: :immediate }.freeze
        SOLD_OUT_INCREASE = false
        EBUY_OTHER_VALUE = false
        PRESIDENT_SALES_TO_MARKET = false
        CAPITALIZATION = :incremental

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'Max stock price in phase 3 or 10 or end card flipped in phase 10',
        )

        ALLOW_MULTIPLE_PROGRAMS = true

        STAR_COLORS = {
          #     main color text     card color standard color highlight text
          1 => ['#cd5c5c', 'white', '#f8ecec', :red,          'yellow'],
          2 => ['#ffa500', 'black', '#fff7e5', :orange,       'red'],
          3 => ['#ffff33', 'black', '#ffffe5', :yellow,       'red'],
          4 => ['#90ee90', 'black', '#e8fce8', :green,        'red'],
          5 => ['#add8e6', 'black', '#ecf7f8', :blue,         'red'],
          6 => ['#9370db', 'white', '#efecf9', :purple,       'red'],
        }.freeze

        LEVEL_SYMBOLS = {
          1 => '⬤',
          2 => '▲',
          3 => '■',
          4 => '⬟',
          5 => '⬢',
          6 => '★',
        }.freeze

        FOREIGN_START_CASH = 4
        FOREIGN_EXTRA_INCOME = 5

        PAR_PRICES = {
          1 => [10, 11, 12, 13, 14],
          2 => [10, 11, 12, 13, 14, 15, 16, 18, 20],
          3 => [10, 11, 12, 13, 14, 15, 16, 18, 20, 22, 24, 26],
          4 => [15, 16, 18, 20, 22, 24, 26, 28, 31, 34],
          5 => [22, 24, 26, 28, 31, 34, 37, 41, 45],
          6 => [28, 31, 34, 37, 41, 45],
        }.freeze

        END_CARD_FRONT = 7
        END_CARD_BACK = 8

        COST_OF_OWNERSHIP = {
          1 => [0, 0, 0, 0, 0, 0],
          2 => [0, 0, 0, 0, 0, 0],
          3 => [0, 0, 0, 0, 0, 0],
          4 => [1, 0, 0, 0, 0, 0],
          5 => [3, 3, 0, 0, 0, 0],
          6 => [6, 6, 6, 0, 0, 0],
          7 => [10, 10, 10, 10, 0, 0],
          8 => [16, 16, 16, 16, 0, 0],
        }.freeze

        COST_OF_OWNERSHIP_SHORT = {
          1 => [0, 0, 0, 0, 0, 0],
          2 => [0, 0, 0, 0, 0, 0],
          3 => [0, 0, 0, 0, 0, 0],
          4 => [1, 0, 0, 0, 0, 0],
          5 => [3, 3, 0, 0, 0, 0],
          7 => [6, 6, 6, 0, 0, 0],
          8 => [15, 15, 15, 15, 0, 0],
        }.freeze

        SEPARATE_WRAP_UP = true

        def init_phase; end

        def num_phases
          self.class::SEPARATE_WRAP_UP ? 10 : 9
        end

        def rs_version
          1
        end

        def setup
          @company_highlight = {} # only used in RS Stars
          @company_level = self.class::COMPANIES.to_h { |c| [company_by_id(c[:sym]), c[:level]] }
          @company_synergies = self.class::COMPANIES.to_h do |c|
            [company_by_id(c[:sym]), c[:synergies].to_h { |oc| [company_by_id(oc), true] }]
          end

          @company_deck = setup_company_deck
          @offering = @company_deck.shift(@players.size)
          @on_deck = []

          @foreign_investor = Player.new(-1, 'Foreign Investor')
          @bank.spend(self.class::FOREIGN_START_CASH, @foreign_investor)
          @cost_level = @company_level[@company_deck[0]]
          @log << 'No cost of ownership'
          @cost_table = init_cost_table
          @synergy_income = {}

          add_default_autopass
        end

        # enable conditiional auto-pass for everyone at the start
        def add_default_autopass
          @players.each do |player|
            @programmed_actions[player] << Engine::Action::ProgramClosePass.new(
              player,
              unconditional: false,
            )
          end
        end

        def setup_preround
          @phase_counter = 2
        end

        def init_cost_table
          @optional_rules&.include?(:short) ? self.class::COST_OF_OWNERSHIP_SHORT : self.class::COST_OF_OWNERSHIP
        end

        def num_to_draw(players, level)
          if players.size == 6
            8
          elsif level != 2 || players.size < 4
            players.size
          elsif players.size == 4
            5
          else
            7
          end
        end

        def num_levels
          @optional_rules&.include?(:short) ? 5 : 6
        end

        def setup_company_deck
          deck = []
          num = num_levels
          num.times do |stars|
            matching = @companies.select { |c| @company_level[c] == (stars + 1) }
            highest = matching.max_by(&:value)
            @company_highlight[highest] = true
            drawn = matching.reject { |c| c == highest }.sort_by { rand }.take(num_to_draw(players, stars + 1))
            drawn << highest
            deck.concat(drawn.sort_by { rand })
          end
          deck
        end

        def can_acquire_any_company?(corporation)
          if abilities(corporation, :overseas) && @companies.any? do |c|
               c.owner == @foreign_investor && corporation.cash >= c.value
             end
            return true
          end

          @companies.any? { |c| c.owner && c.owner != corporation && corporation.cash >= c.min_price }
        end

        # any player with a company, or any player owning a corporation
        #
        def acquisition_players
          owners = @players.select { |p| p != @foreign_investor && !p.companies.empty? }
          @corporations.each { |c| owners << c.owner if c.owner && !c.receivership? }
          owners.uniq
        end

        def closing_players
          acquisition_players
        end

        def init_round
          new_investment_round
        end

        def next_phase
          @phase_counter += 1
          return unless @phase_counter > num_phases

          @phase_counter = 1
          @turn += 1
        end

        def new_investment_round
          next_phase
          @log << "-- #{round_phase_string} - Investment --"
          @round_counter += 1
          investment_round
        end

        def investment_round
          Round::Investment.new(self, [
            Step::BuySellSharesBidCompanies,
          ])
        end

        def wrap_up
          next_phase
          @log << "-- #{round_phase_string} - Wrap-Up --"
          reorder_by_cash

          if self.class::SEPARATE_WRAP_UP
            next_phase
            @log << "-- #{round_phase_string} - Foreign Investor --"
          end

          # foreign_investor buys
          while (cheapest = (@offering - @on_deck).min_by(&:value)) && (@foreign_investor.cash >= cheapest.value)
            @log << "#{@foreign_investor.name} buys #{cheapest.sym} for #{format_currency(cheapest.value)}"
            cheapest.owner = @foreign_investor
            @foreign_investor.companies << cheapest
            @foreign_investor.spend(cheapest.value, @bank)

            update_offering(cheapest)
          end

          @on_deck.clear
        end

        def new_acquisition_round
          next_phase
          @log << "-- #{round_phase_string} - Acquisition --"
          @round_counter += 1
          if @corporations.any? { |corp| can_acquire_any_company?(corp) }
            acquisition_round
          else
            @log << 'No corporations can acquire a company'
            new_closing_round
          end
        end

        def acquisition_round
          Round::Acquisition.new(self, [
            Step::ReceiverProposeAndPurchase,
            Step::ProposeAndPurchase,
          ])
        end

        def new_closing_round
          next_phase
          @log << "-- #{round_phase_string} - Closing --"
          @round_counter += 1
          auto_close_companies
          if @players.any? { |p| !p.companies.empty? } || @corporations.any? { |corp| corp.companies.size > 1 }
            closing_round
          else
            @log << 'No companies can close'
            income_phase
            new_dividends_round
          end
        end

        def closing_round
          Round::Closing.new(self, [
            Step::CloseCompanies,
          ])
        end

        def auto_close_companies
          @foreign_investor.companies.dup.each do |company|
            if company_income(company).negative?
              @log << "#{company.sym} (#{company.owner.name}) has negative income"
              close_company(company)
            end
          end

          @corporations.select(&:receivership?).each do |corp|
            corp.companies.sort_by(&:value).each do |company|
              if company_income(company).negative? && receivership_close?(company) && corp.companies.size > 1
                @log << "#{company.sym} (#{company.owner.name} - Receivership) exceeds maximum cost of ownership"
                close_company(company)
              end
            end
          end
        end

        def receivership_close?(company)
          (@company_level[company] == 1 && operating_cost(company) >= 4) ||
            (@company_level[company] == 2 && operating_cost(company) >= 7)
        end

        # income
        def income_phase
          next_phase
          @log << "-- #{round_phase_string} - Income --"
          (@players + [@foreign_investor] + @corporations).each do |entity|
            next if entity.corporation? && !entity.ipoed

            income = total_income(entity)

            if income.positive?
              @log << "#{entity.name} receives #{format_currency(income)}"
              @bank.spend(income, entity)
            elsif income.negative?

              if entity.cash < -income
                raise GameError, "Game Bug: #{entity.name} cannot pay net loss" unless entity.corporation?

                @log << "#{entity.name} cannot pay net loss of #{format_currency(-income)}"
                close_corporation(entity)
              else
                @log << "#{entity.name} pays #{format_currency(-income)} due to net loss"
                entity.spend(-income, @bank)
              end
            end
          end
        end

        def new_dividends_round
          next_phase
          @log << "-- #{round_phase_string} - Dividends --"
          @round_counter += 1
          if @corporations.any?(&:floated?)
            dividends_round
          else
            @log << 'No corporations can pay dividends'
            end_card
            new_issue_round
          end
        end

        def dividends_round
          Round::Dividends.new(self, [
            Step::Dividend,
          ])
        end

        def end_card
          next_phase
          @log << "-- #{round_phase_string} - End Card --"

          if @cost_level == self.class::END_CARD_BACK || @stock_market.max_reached?
            @log << 'Game ends: Max Stock price has been reached' if @stock_market.max_reached?
            @log << 'Game ends: Game end card reached' if @cost_level == self.class::END_CARD_BACK
            return end_game!
          end

          return if @cost_level != self.class::END_CARD_FRONT || !@offering.empty?

          @cost_level = self.class::END_CARD_BACK
          @log << "New cost of ownership: #{cost_level_str}"
          @log << 'Game will end on next turn'
        end

        def custom_end_game_reached?
          @stock_market.max_reached? && @round.is_a?(Round::Investment)
        end

        def game_ending_description
          return if !@finished && @cost_level != self.class::END_CARD_BACK

          after_text = @finished ? '' : ' : Game Ends on next phase 7'

          if @stock_market.max_reached?
            'Corporation hit max stock value'
          else
            "End card flipped#{after_text}"
          end
        end

        def new_issue_round
          next_phase
          return Round::Issue.new(self, []) if @finished

          @log << "-- #{round_phase_string} - Issue Shares --"
          @round_counter += 1

          if issuable_corporations.empty?
            @log << 'No corporations can issue'
            new_ipo_round
          else
            issue_round
          end
        end

        def issue_round
          Round::Issue.new(self, [
            Step::IssueShares,
          ])
        end

        def new_ipo_round
          next_phase
          @log << "-- #{round_phase_string} - IPO --"
          @round_counter += 1
          if ipo_companies.empty?
            @log << 'No companies eligible to convert'
            new_investment_round
          else
            ipo_round
          end
        end

        def ipo_round
          Round::IPO.new(self, [
            Step::IPOCompany,
          ])
        end

        def reorder_by_cash
          # this should break ties in favor of the closest to previous PD
          old_order = @players.dup
          @players.sort_by! { |p| [-p.cash, old_order.index(p)] }
          @log << "Player order: #{@players.map(&:name).join(', ')}"
        end

        def next_round!
          @round =
            case @round
            when Round::Investment
              wrap_up
              new_acquisition_round
            when Round::Acquisition
              new_closing_round
            when Round::Closing
              income_phase
              new_dividends_round
            when Round::Dividends
              end_card
              new_issue_round
            when Round::Issue
              new_ipo_round
            when Round::IPO
              new_investment_round
            end
        end

        def total_income(entity)
          income = 0
          income += self.class::FOREIGN_EXTRA_INCOME if entity == @foreign_investor
          return income if entity.companies.empty?

          income += entity.companies.sum { |c| company_income(c) }
          return income unless entity.corporation?

          income += synergy_income(entity)
          income += ability_income(entity)
          income
        end

        def ability_income(entity)
          return 0 unless entity.corporation?
          return 0 if entity.companies.empty?

          extra = 0
          extra += entity.companies.size if abilities(entity, :prussian)
          extra += entity.companies.max_by(&:revenue).revenue if abilities(entity, :doppler)
          extra += [entity.companies.sum { |c| operating_cost(c) }, 10].min if abilities(entity, :vintage_machinery)
          extra
        end

        def company_income(company)
          company.revenue - operating_cost(company)
        end

        def operating_cost(company)
          @cost_table[@cost_level][@company_level[company] - 1]
        end

        def synergy_income(corporation)
          @synergy_income[corporation] ||= calculate_synergy_income(corporation)
        end

        def clear_synergy_income(corporation)
          @synergy_income.delete(corporation)
        end

        def calculate_synergy_income(corporation)
          comps = corporation.companies
          total = 0
          count = 0
          comps.each do |c|
            pairs = calculate_synergy_pairs(c, comps)
            total += pairs[0]
            count += pairs[1]
          end
          total += (count / 2).to_i if abilities(corporation, :synergistic)
          total
        end

        def calculate_synergy_pairs(company, other_companies)
          total = 0
          count = 0
          other_companies.each do |oc|
            if @company_synergies[company][oc] && company.value > oc.value
              total += synergy_value_by_level(company, oc)
              count += 1
            end
          end
          [total, count]
        end

        def synergy_value_by_level(company_a, company_b)
          level = @company_level[company_a]
          other_level = @company_level[company_b]
          case level
          when 1
            1
          when 2
            other_level == 1 ? 1 : 2
          when 3
            other_level == 2 ? 2 : 4
          when 4
            4
          when 5
            [3, 4].include?(other_level) ? 4 : 8
          else
            other_level == 5 ? 8 : 16
          end
        end

        def num_issued(corporation)
          return 0 unless corporation.floated?

          corporation.num_player_shares + corporation.num_market_shares
        end

        def max_dividend_per_share(corporation)
          return 0 unless corporation.floated?

          [(corporation.share_price.price / 3), (corporation.cash / num_issued(corporation))].min.to_i
        end

        def book_value(corporation, cash = nil)
          (cash || corporation.cash) + corporation.companies.sum(&:value)
        end

        def market_cap(corporation, price)
          num_issued(corporation) * price.price
        end

        def issuable_shares(entity)
          return [] unless entity.corporation?

          bundle = bundles_for_corporation(entity, entity).first
          return [] unless bundle

          bundle.share_price = next_price_to_left(bundle.corporation.share_price).price unless abilities(entity, :stock_masters)

          [bundle]
        end

        def redeemable_shares(_entity)
          []
        end

        def buyable_bank_owned_companies
          return [@round.current_entity] if @round.is_a?(Round::IPO)

          @offering
        end

        def biddable_companies
          @offering - @on_deck
        end

        def responder_order(buyer)
          eligible = @corporations.select do |corp|
            corp.floated? && (!corp.receivership? || corp == buyer)
          end
          oversea_corp, others = eligible.partition { |corp| abilities(corp, :overseas) }
          (oversea_corp + others.sort).compact
        end

        def update_offering(company)
          @offering.delete(company)
          if @company_deck.empty?
            @log << 'Company Deck is empty'
          else
            next_to_offer = @company_deck.shift
            @offering << next_to_offer
            @on_deck << next_to_offer
            @log << "#{next_to_offer.sym} revealed from deck"
          end

          new_cost = if @company_deck.empty?
                       self.class::END_CARD_FRONT
                     else
                       @company_level[@company_deck[0]]
                     end

          return unless @cost_level < new_cost

          @cost_level = new_cost
          @log << "New cost of ownership: #{cost_level_str}"

          @log << 'Some companies have negative income' if @players.any? { |p| any_negative_companies?(p) }
          disable_auto_close_pass
        end

        def disable_auto_close_pass
          @programmed_actions.each do |entity, action_list|
            action_list.reject! do |action|
              next false if !action.is_a?(Engine::Action::ProgramClosePass) ||
                action.unconditional ||
                !any_negative_companies?(entity)

              player_log(entity, "Programmed action '#{action}' removed due to negative company income")
              true
            end
          end
        end

        def any_negative_companies?(player)
          return false unless player.player?
          return true if player.companies.any? { |c| company_income(c).negative? }

          @corporations.any? do |corp|
            corp.owner == player &&
              corp.companies.any? { |c| company_income(c).negative? }
          end
        end

        def cost_level_str
          level = @cost_table[@cost_level]
          colors = %w[Red Orange Yellow Green Blue Purple]
          non_zero_colors = level.each_with_index.map do |l, i|
            l.positive? ? colors[i] : nil
          end.compact
          return 'None' unless level[0].positive?

          "#{non_zero_colors.join(', ')} = $#{level[0]}"
        end

        def issuable_corporations
          @corporations.select { |c| c.ipoed && !issuable_shares(c).empty? }
        end

        def share_prices
          self.class::PAR_PRICES.values.flatten.uniq.map { |p| prices[p] }
        end

        def ipo_companies
          @companies.select { |c| c.owner&.player? && c.owner != @foreign_investor }.sort_by(&:value).reverse
        end

        def available_par_prices(company)
          self.class::PAR_PRICES[@company_level[company]].map { |p| prices[p] }.select { |p| p.corporations.empty? }
        end

        def prices
          @prices ||= @stock_market.market[0].to_h { |p| [p.price, p] }
        end

        def find_new_price(current, target, diff)
          if diff.zero?
            current
          elsif target.corporations.empty? || target.end_game_trigger? || target.price.zero?
            target
          elsif diff.positive?
            next_price_to_right(target)
          else
            next_price_to_left(target)
          end
        end

        def book_to_cap_change(corporation, cash = nil)
          book = book_value(corporation, cash)
          current = corporation.share_price
          r, c = current.coordinates

          # assumes that current is not at either limit of market
          right = @stock_market.share_price([r, c + 1])
          left = @stock_market.share_price([r, c - 1])

          if book >= market_cap(corporation, current) && book < market_cap(corporation, right)
            diff = 1
            target = right
          elsif book >= market_cap(corporation, right)
            diff = 2
            target = right.end_game_trigger? ? right : @stock_market.share_price([r, c + 2])
          elsif book < market_cap(corporation, current) && book >= market_cap(corporation, left)
            diff = -1
            target = left
          else
            diff = -2
            target = left.price.zero? ? left : @stock_market.share_price([r, c - 2])
          end

          actual = find_new_price(current, target, diff)

          [actual, target, diff]
        end

        def dividend_price_movement(corporation)
          new_price = book_to_cap_change(corporation)[0]
          move_to_price(corporation, new_price)
        end

        def move_to_right(corporation)
          old_price = corporation.share_price.price
          @stock_market.move(corporation, next_price_to_right(corporation.share_price).coordinates)
          new_price = corporation.share_price.price
          @log << "#{corporation.name} share price increases to #{format_currency(new_price)}" unless old_price == new_price
        end

        def next_price_to_right(price)
          new_price = price
          while !new_price.end_game_trigger? && (!new_price.corporations.empty? || new_price == price)
            r, c = new_price.coordinates
            new_price = @stock_market.share_price([r, c + 1])
          end
          new_price
        end

        def move_to_left(corporation)
          @stock_market.move(corporation, next_price_to_left(corporation.share_price).coordinates)
          new_price = corporation.share_price.price
          @log << "#{corporation.name} share price decreases to #{format_currency(new_price)}"
          close_corporation(corporation) if new_price.zero?
        end

        def next_price_to_left(price)
          new_price = price
          while new_price.price != 0 && (!new_price.corporations.empty? || new_price == price)
            r, c = new_price.coordinates
            new_price = @stock_market.share_price([r, c - 1])
          end
          new_price
        end

        def one_price_to_left(price)
          r, c = price.coordinates
          return nil if (c - 1).negative?

          @stock_market.share_price([r, c - 1])
        end

        def two_prices_to_left(price)
          r, c = price.coordinates
          return nil if (c - 2).negative?

          @stock_market.share_price([r, c - 2])
        end

        def one_price_to_right(price)
          r, c = price.coordinates
          return nil if c + 1 >= @stock_market.market[r].size

          @stock_market.share_price([r, c + 1])
        end

        def two_prices_to_right(price)
          r, c = price.coordinates
          return nil if c + 2 >= @stock_market.market[r].size

          @stock_market.share_price([r, c + 2])
        end

        def move_to_price(corporation, new_price)
          current_price = corporation.share_price
          return if current_price.price == new_price.price

          @stock_market.move(corporation, new_price.coordinates)
          dir = new_price.price > current_price.price ? 'increases' : 'decreases'
          @log << "#{corporation.name} share price #{dir} to #{format_currency(new_price.price)}"
          close_corporation(corporation) if new_price.price.zero?
        end

        def close_company(company)
          owner = company.owner
          owner.companies.delete(company)
          company.owner = nil
          @companies.delete(company)
          @log << "#{company.sym} (#{owner.name}) closes"
          clear_synergy_income(owner) if owner.corporation?
          return if !owner.corporation? || !abilities(owner, :junkyard_scrappers)

          bonus = company.revenue * 2
          @bank.spend(bonus, owner)
          @log << "#{owner.name} receives #{format_currency(bonus)} as a scrapping bonus"
        end

        def close_corporation(corporation, quiet: false)
          @log << "#{corporation.name} bankrupts"
          corporation.spend(corporation.cash, @bank) if corporation.cash.positive?

          corporation.share_holders.keys.each do |share_holder|
            share_holder.shares_by_corporation.delete(corporation)
          end
          @share_pool.shares_by_corporation.delete(corporation)

          reset_corporation(corporation)
        end

        def pass_entity(user)
          return super unless @round.unordered?
          return super unless user

          player_by_id(user['id']) || super
        end

        def company_header(company)
          company.sym
        end

        def player_entities
          @players + [@foreign_investor]
        end

        def dividend_help_str(entity, max)
          "Dividend per share. Range: From #{format_currency(0)}"\
            " to #{format_currency(max)}. Issued shares: #{num_issued(entity)}."\
            " Market Cap: #{format_currency(market_cap(entity, entity.share_price))}"
        end

        def dividend_arrows(diff)
          if diff == -1
            '⬅'
          elsif diff < -1
            '⬅⬅'
          elsif diff == 1
            '➡'
          elsif diff > 1
            '➡➡'
          else
            ''
          end
        end

        def dividend_chart(corporation)
          rows = (0..max_dividend_per_share(corporation)).map do |div|
            cash_left = corporation.cash - (div * num_issued(corporation))
            book = book_value(corporation, cash_left)
            price, target, diff = book_to_cap_change(corporation, cash_left)
            arrows = dividend_arrows(diff)
            target = "#{arrows} #{format_currency(target.price)}"
            price = format_currency(price.price)
            [format_currency(div), format_currency(cash_left), format_currency(book), target, price]
          end
          [
            ['Div', 'Cash', 'Book', 'Target Price', 'New Price'],
            *rows,
          ]
        end

        def corporation_view(_corp)
          'rs_corporation'
        end

        def company_view(_company)
          'rs_company'
        end

        def company_card_only?
          true
        end

        def company_available?(company)
          !@on_deck.include?(company)
        end

        def company_colors(company)
          self.class::STAR_COLORS[@company_level[company]]
        end

        def nav_bar_color
          if @cost_level < 6
            self.class::STAR_COLORS[@cost_level][3]
          else
            'gray'
          end
        end

        def round_phase_string
          "Turn #{@turn}, Phase #{@phase_counter}"
        end

        def phase_valid?
          false
        end

        def round_description(name, _round_number)
          "#{name} Round"
        end

        def market_par_bars(price)
          colors = []
          self.class::PAR_PRICES.each do |k, v|
            colors << self.class::STAR_COLORS[k][0] if v.include?(price.price)
          end
          colors
        end

        def level_symbol(level)
          self.class::LEVEL_SYMBOLS[level]
        end

        def show_game_cert_limit?
          false
        end

        def sellable_bundles(player, corporation)
          return [] unless @round.active_step.respond_to?(:can_sell?)

          bundles = bundles_for_corporation(player, corporation).map do |bundle|
            bundle.share_price = next_price_to_left(bundle.corporation.share_price).price
            bundle
          end
          bundles.select { |bundle| @round.active_step.can_sell?(player, bundle) }
        end

        def available_programmed_actions
          [Action::ProgramSharePass, Action::ProgramClosePass]
        end

        def ipo_name(_corp)
          'Unissued'
        end

        def show_player_percent?(_player)
          false
        end

        def share_card_description
          'Target Book Value by Share Price'
        end

        def share_card_array(price)
          return [] if price.price.zero? || price.end_game_trigger?

          (2..10).map do |idx|
            [idx.to_s, format_currency(idx * price.price)]
          end
        end

        def result
          result_players
            .sort_by { |p| [player_value(p), -@players.index(p)] }
            .reverse
            .to_h { |p| [p.id, player_value(p)] }
        end

        def companies_sort(companies)
          companies.sort_by(&:value).reverse
        end

        def stock_round_name
          'Investment Phase'
        end

        def force_unconditional_stock_pass?
          true
        end

        def movement_chart(corporation)
          num = num_issued(corporation)
          price = corporation.share_price
          two_right = two_prices_to_right(price)&.price
          one_right = one_price_to_right(price)&.price
          one_left = one_price_to_left(price)&.price
          two_left = two_prices_to_left(price)&.price

          chart = [%w[Value Price]]
          chart <<  ["$#{num * one_right} - ∞", "$#{two_right}"] if two_right
          chart <<  ["$#{num * price.price} - $#{(num * one_right) - 1}", "$#{one_right}"] if one_right
          chart <<  ["$#{num * one_left} - $#{(num * price.price) - 1}", "$#{one_left}"] if one_left
          chart <<  ["$0 - $#{(num * one_left) - 1}", "$#{two_left}"] if two_left
          chart << ['', ''] while chart.size < 5
          chart
        end

        def liquidity(player, emergency: false)
          total = player.cash
          player.shares_by_corporation.reject { |_, s| s.empty? }.each do |corporation, shares|
            total += dump_cash(corporation, shares.size)
          end
          total
        end

        def dump_cash(corporation, num)
          value = 0
          price = corporation.share_price
          num.times do
            price = next_price_to_left(price)
            value += price.price
          end
          value
        end
      end
    end
  end
end
