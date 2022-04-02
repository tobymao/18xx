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

        attr_reader :foreign_investor, :company_deck, :company_stars, :company_synergies, :cost_level,
                    :cost_table, :offering

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

        CURRENCY_FORMAT_STR = '$%d'
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
             16
             18
             20
             22
             24
             27
             30
             33
             37
             41
             45
             50
             55
             61
             68
             75e],
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
        PRESIDENT_SALES_TO_MARKET = true
        CAPITALIZATION = :incremental

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'Max stock price in phase 1 or 7 or end card flipped in phase 7',
        )

        PHASES = [
          { name: 'unused', train_limit: 1, tiles: [:yellow], operating_rounds: 1 },
        ].freeze

        STAR_COLORS = {
          #     main color text     card color standard color
          1 => ['#cd5c5c', 'white', '#f8ecec', :red],
          2 => ['#ffa500', 'black', '#fff7e5', :orange],
          3 => ['#ffff33', 'black', '#ffffe5', :yellow],
          4 => ['#90ee90', 'black', '#e8fce8', :green],
          5 => ['#add8e6', 'black', '#ecf7f8', :blue],
          6 => ['#9370db', 'white', '#efecf9', :purple],
        }.freeze

        FOREIGN_START_CASH = 4
        FOREIGN_EXTRA_INCOME = 5

        PAR_PRICES = {
          1 => [10, 11, 12, 13, 14],
          2 => [10, 11, 12, 13, 14, 16, 18, 20],
          3 => [16, 18, 20, 22, 24, 27],
          4 => [22, 24, 27, 30, 33, 37],
          5 => [30, 33, 37],
        }.freeze

        END_CARD_FRONT = 7
        END_CARD_BACK = 8

        COST_OF_OWNERSHIP_RSS = {
          1 => [0, 0, 0, 0, 0],
          2 => [0, 0, 0, 0, 0],
          3 => [0, 0, 0, 0, 0],
          4 => [2, 0, 0, 0, 0],
          5 => [4, 4, 0, 0, 0],
          7 => [7, 7, 7, 0, 0],
          8 => [10, 10, 10, 10, 0],
        }.freeze

        def num_to_draw(players, stars)
          if players.size == 6
            8
          elsif stars != 2 || players.size < 4
            players.size
          elsif players.size == 4
            5
          else
            7
          end
        end

        def setup
          @company_stars = self.class::COMPANIES.to_h { |c| [company_by_id(c[:sym]), c[:stars]] }
          @company_synergies = self.class::COMPANIES.to_h do |c|
            [company_by_id(c[:sym]), c[:synergies].to_h { |oc| [company_by_id(oc), true] }]
          end

          @company_deck = []
          5.times do |stars|
            matching = @companies.select { |c| @company_stars[c] == (stars + 1) }
            highest = matching.max_by(&:value)
            drawn = matching.reject { |c| c == highest }.sort_by { rand }.take(num_to_draw(players, stars + 1))
            drawn << highest
            @company_deck.concat(drawn.sort_by { rand })
          end
          @offering = @company_deck.shift(@players.size)
          @on_deck = []

          @foreign_investor = Player.new(-1, 'Foreign Investor')
          @bank.spend(FOREIGN_START_CASH, @foreign_investor)
          @cost_level = @company_stars[@company_deck[0]]
          @log << 'No cost of ownership'
          @cost_table = COST_OF_OWNERSHIP_RSS
          @synergy_income = {}
          @phase_counter = 0
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

        def new_investment_round
          @phase_counter = 1
          @log << "-- #{round_phase_string} - Investment --"
          @round_counter += 1
          investment_round
        end

        def investment_round
          Round::Investment.new(self, [
            Step::BuySellSharesBidCompanies,
          ])
        end

        # wrap-up
        def phase2
          @phase_counter += 1
          @log << "-- #{round_phase_string} - Wrap-Up --"
          reorder_by_cash

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
          @phase_counter += 1
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
          @phase_counter += 1
          @log << "-- #{round_phase_string} - Closing --"
          @round_counter += 1
          auto_close_companies
          if @players.any? { |p| !p.companies.empty? } || @corporations.any? { |corp| corp.companies.size > 1 }
            closing_round
          else
            @log << 'No companies can close'
            phase5
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
            corp.companies.sort_by(&:value).reverse_each do |company|
              if company_income(company).negative? && receivership_close?(company) && corp.companies.size > 1
                @log << "#{company.sym} (#{company.owner.name} - Receivership) has negative income"
                close_company(company)
              end
            end
          end
        end

        def receivership_close?(company)
          (@company_stars[company] == 1 && operating_cost(company) >= 4) ||
            (@company_stars[company] == 2 && operating_cost(company) >= 7)
        end

        # income
        def phase5
          @phase_counter += 1
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
          @phase_counter += 1
          @log << "-- #{round_phase_string} - Dividends --"
          @round_counter += 1
          if @corporations.any?(&:floated?)
            dividends_round
          else
            @log << 'No corporations can pay dividends'
            phase7
            new_issue_round
          end
        end

        def dividends_round
          Round::Dividends.new(self, [
            Step::Dividend,
          ])
        end

        # end card
        def phase7
          @phase_counter += 1
          @log << "-- #{round_phase_string} - End Card --"

          if @cost_level == END_CARD_BACK || @stock_market.max_reached?
            @log << 'Game ends: Max Stock price has been reached' if @stock_market.max_reached?
            @log << 'Game ends: Game end card reached' if @cost_level == END_CARD_BACK
            return end_game!
          end

          return if @cost_level != END_CARD_FRONT || !@offering.empty?

          @cost_level = END_CARD_BACK
          @log << "New cost of ownership: #{cost_level_str}"
          @log << 'Game will end on next turn'
        end

        def custom_end_game_reached?
          @stock_market.max_reached? && @round.is_a?(Round::Investment)
        end

        def game_ending_description
          return if !@finished && @cost_level != END_CARD_BACK

          after_text = @finished ? '' : ' : Game Ends on next phase 7'

          if @stock_market.max_reached?
            'Corporation hit max stock value'
          else
            "End card flipped#{after_text}"
          end
        end

        def new_issue_round
          @phase_counter += 1
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
          @phase_counter += 1
          @log << "-- #{round_phase_string} - IPO --"
          @round_counter += 1
          if ipo_companies.empty?
            @log << 'No companies eligible to convert'
            @turn += 1
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
          pd_player = @players.max_by(&:cash)
          @players.rotate!(@players.index(pd_player))
          @log << "Player order: #{@players.map(&:name).join(', ')}"
        end

        def next_round!
          @round =
            case @round
            when Round::Investment
              phase2
              new_acquisition_round
            when Round::Acquisition
              new_closing_round
            when Round::Closing
              phase5
              new_dividends_round
            when Round::Dividends
              phase7
              new_issue_round
            when Round::Issue
              new_ipo_round
            when Round::IPO
              @turn += 1
              new_investment_round
            end
        end

        def total_income(entity)
          income = 0
          income += FOREIGN_EXTRA_INCOME if entity == @foreign_investor
          return income if entity.companies.empty?

          income = entity.companies.sum { |c| company_income(c) }
          return income unless entity.corporation?

          income += synergy_income(entity)
          income += ability_income(entity)
          income
        end

        def ability_income(entity)
          return 0 unless entity.corporation?

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
          @cost_table[@cost_level][@company_stars[company] - 1]
        end

        def synergy_income(corporation)
          @synergy_income[corporation] ||= calculate_synergy_income(corporation)
        end

        def clear_synergy_income(corporation)
          @synergy_income.delete(corporation)
        end

        # FIXME: Synergistic
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
              total += synergy_value_by_star(company, oc)
              count += 1
            end
          end
          [total, count]
        end

        def synergy_value_by_star(company_a, company_b)
          stars = @company_stars[company_a]
          other_stars = @company_stars[company_b]
          case stars
          when 1
            1
          when 2
            other_stars < stars ? 1 : 2
          when 3
            other_stars < stars ? 2 : 4
          when 4
            other_stars < stars ? 4 : 8
          else
            case other_stars
            when 3
              4
            when 4
              8
            else
              16
            end
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

        def corporation_stars(corporation, cash)
          total = (cash / 10).to_i + corporation.companies.sum { |c| @company_stars[c] }
          total += 2 if abilities(corporation, :stars)
          total
        end

        def target_stars(corporation)
          return 0 unless corporation.floated?

          (num_issued(corporation) * corporation.share_price.price / 10.0).round
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

        def responder_order
          eligible = @corporations.select { |corp| corp.floated? && !corp.receivership? }
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
                       END_CARD_FRONT
                     else
                       @company_stars[@company_deck[0]]
                     end

          return unless @cost_level < new_cost

          @cost_level = new_cost
          @log << "New cost of ownership: #{cost_level_str}"
        end

        def cost_level_str
          case @cost_level
          when 1, 2, 3
            'None'
          when 4
            'Red = $2'
          when 5
            'Red, Orange = $4'
          when 6
            'Red, Orange, Yellow = $7'
          else
            'Red, Orange, Yellow, Green = $10'
          end
        end

        def issuable_corporations
          @corporations.select { |c| c.ipoed && !issuable_shares(c).empty? }
        end

        def share_prices
          PAR_PRICES.values.flatten.uniq.map { |p| prices[p] }
        end

        def ipo_companies
          @companies.select { |c| c.owner&.player? && c.owner != @foreign_investor }.sort_by(&:value)
        end

        def available_par_prices(company)
          PAR_PRICES[@company_stars[company]].map { |p| prices[p] }.select { |p| p.corporations.empty? }
        end

        def prices
          @prices ||= @stock_market.market[0].to_h { |p| [p.price, p] }
        end

        def move_to_right(corporation)
          old_price = corporation.share_price.price
          r, c = next_price_to_right(corporation.share_price).coordinates
          @stock_market.move(corporation, r, c)
          new_price = corporation.share_price.price
          @log << "#{corporation.name} share price increases to #{format_currency(new_price)}" unless old_price == new_price
        end

        def next_price_to_right(price)
          new_price = price
          while new_price.price != 75 && (!new_price.corporations.empty? || new_price == price)
            r, c = new_price.coordinates
            new_price = @stock_market.share_price(r, c + 1)
          end
          new_price
        end

        def move_to_left(corporation)
          r, c = next_price_to_left(corporation.share_price).coordinates
          @stock_market.move(corporation, r, c)
          new_price = corporation.share_price.price
          @log << "#{corporation.name} share price decreases to #{format_currency(new_price)}"
          close_corporation(corporation) if new_price.zero?
        end

        def next_price_to_left(price)
          new_price = price
          while new_price.price != 0 && (!new_price.corporations.empty? || new_price == price)
            r, c = new_price.coordinates
            new_price = @stock_market.share_price(r, c - 1)
          end
          new_price
        end

        def move_to_price(corporation, new_price)
          current_price = corporation.share_price
          return if current_price.price == new_price.price

          r, c = new_price.coordinates
          @stock_market.move(corporation, r, c)
          dir = new_price.price > current_price.price ? 'increases' : 'decreases'
          @log << "#{corporation.name} share price #{dir} to #{format_currency(new_price.price)}"
          close_corporation(corporation) if new_price.price.zero?
        end

        def star_diff_price(corporation, diff)
          return unless corporation.floated?

          if diff.zero?
            corporation.share_price
          elsif diff == 1
            next_price_to_right(corporation.share_price)
          elsif diff > 1
            next_price_to_right(next_price_to_right(corporation.share_price))
          elsif diff == -1
            next_price_to_left(corporation.share_price)
          else
            next_price_to_left(next_price_to_left(corporation.share_price))
          end
        end

        def close_company(company)
          owner = company.owner
          owner.companies.delete(company)
          company.owner = nil
          @companies.delete(company)
          @log << "#{company.sym} (#{owner.name}) closes"
          clear_synergy_income(owner) if owner.corporation?
          return if !owner.corporation? || !abilities(owner, :junkyard_scrappers)

          @bank.spend(owner, company.revenue)
          @log << "#{owner.name} receives #{format_currency(company.revenue)} as a scrapping bonus"
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
          return @round.entities.find { |e| !e.passed? } unless user

          player_by_id(user['id']) || super
        end

        def company_header(company)
          company.sym
        end

        def player_entities
          @players + [@foreign_investor]
        end

        def dividend_chart(corporation)
          rows = (0..max_dividend_per_share(corporation)).map do |div|
            cash_left = corporation.cash - (div * num_issued(corporation))
            stars = corporation_stars(corporation, cash_left)
            diff = stars - target_stars(corporation)
            arrows = if diff == -1
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
            new_price = "#{arrows} #{format_currency(star_diff_price(corporation, diff).price)}"
            [format_currency(div), format_currency(cash_left), "#{stars}★", new_price]
          end
          [
            ['Div/Share', 'New Cash', 'Stars', 'New Price'],
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
          STAR_COLORS[company_stars[company]]
        end

        def nav_bar_color
          if @cost_level < 6
            STAR_COLORS[@cost_level][3]
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
      end
    end
  end
end
