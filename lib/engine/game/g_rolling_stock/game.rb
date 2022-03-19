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

        attr_reader :foreign_investor

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
        GAME_END_CHECK = { stock_market: :current_or, bank: :full_or }.freeze
        SOLD_OUT_INCREASE = false
        EBUY_OTHER_VALUE = false
        PRESIDENT_SALES_TO_MARKET = true
        CAPITALIZATION = :incremental

        PHASES = [
          { name: 'red', train_limit: 1, tiles: [:yellow], operating_rounds: 1 },
          { name: 'orange', train_limit: 1, tiles: [:yellow], operating_rounds: 1 },
          { name: 'yellow', train_limit: 1, tiles: [:yellow], operating_rounds: 1 },
          { name: 'green', train_limit: 1, tiles: [:yellow], operating_rounds: 1 },
          { name: 'blue', train_limit: 1, tiles: [:yellow], operating_rounds: 1 },
        ].freeze

        FOREIGN_START_CASH = 4
        FOREIGN_EXTRA_INCOME = 5

        PAR_PRICES = {
          1 => [10, 11, 12, 13, 14],
          2 => [10, 11, 12, 13, 14, 16, 18, 20],
          3 => [16, 18, 20, 22, 24, 27],
          4 => [22, 24, 27, 30, 33, 37],
          5 => [30, 33, 37],
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
          @company_stars = self.class::COMPANIES.to_h { |c| [c[:sym], c[:stars]] }
          @company_synergies = self.class::COMPANIES.to_h { |c| [c[:sym], c[:synergies]] }

          @company_deck = []
          5.times do |stars|
            matching = @companies.select { |c| @company_stars[c.sym] == (stars + 1) }
            highest = matching.max_by(&:value)
            drawn = matching.reject { |c| c == highest }.sort_by { rand }.take(num_to_draw(players, stars + 1))
            drawn << highest
            @company_deck.concat(drawn.sort_by { rand })
          end
          @offering = @company_deck.shift(@players.size)
          @on_deck = []

          @foreign_investor = Player.new(-1, 'Foreign Investor')
          @bank.spend(FOREIGN_START_CASH, @foreign_investor)
        end

        # FIXME: Overseas Trading
        def can_acquire_any_company?(corporation)
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
          @log << "-- Turn #{@turn}, Phase 1 - Investment --"
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
          @log << "-- Turn #{@turn}, Phase 2 - Wrap-Up --"
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
          @log << "-- Turn #{@turn}, Phase 3 - Acquisition --"
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
          @log << "-- Turn #{@turn}, Phase 4 - Closing --"
          @round_counter += 1
          auto_close_companies
          if @players.any? { |p| !p.companies.empty? } || @corporations.any? { |corp| corp.companies.size > 1 }
            closing_round
          else
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
          @foreign_investor.companies.each do |company|
            if calculate_income(company).negative?
              close_company(company)
              @log << "#{company.sym} (#{company.owner.name}) has negative income"
            end
          end
        end

        # income
        def phase5
          @log << "-- Turn #{@turn}, Phase 5 - Income --"
          (@players + [@foreign_investor] + @corporations).each do |entity|
            next if entity.corporation? && !entity.ipoed

            income = calculate_total_income(entity)

            if income.positive?
              @log << "#{entity.name} receives #{format_currency(income)}"
              @bank.spend(income, entity)
            elsif income.negative?
              @log << "#{entity.name} pays #{format_currency(income)} due to negative income"
              entity.spend(-income, @bank)
            end
          end
        end

        def new_dividends_round
          @log << "-- Turn #{@turn}, Phase 6 - Dividends --"
          @round_counter += 1
          if @corporations.any?(&:floated?)
            dividends_round
          else
            phase7
            new_ipo_round # FIXME: new_issue_round
          end
        end

        def dividends_round
          Round::Dividends.new(self, [
            Step::Dividend,
          ])
        end

        # end card
        def phase7
          @log << "-- Turn #{@turn}, Phase 7 - End Card --"
        end

        def new_ipo_round
          @log << "-- Turn #{@turn}, Phase 9 - IPO --"
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
              new_ipo_round # FIXME: new_issue_round
            when Round::IPO
              @turn += 1
              new_investment_round
            end
        end

        # FIXME: Prussian Railway
        # FIXME: Doppler AG
        # FIXME: Vintage Machinery
        def calculate_total_income(entity)
          income = entity.companies.sum { |c| calculate_income(c) }
          income += calculate_synergies(entity) if entity.corporation?
          income += FOREIGN_EXTRA_INCOME if entity == @foreign_investor
          income
        end

        def calculate_income(company)
          company.revenue - operating_cost(company)
        end

        # FIXME: TBD
        def operating_cost(_company)
          0
        end

        # FIXME: TBD
        # FIXME: Synergistic
        def calculate_synergies(_corporation)
          0
        end

        def num_issued(corporation)
          return 0 unless corporation.floated?

          corporation.num_player_shares + corporation.num_market_shares
        end

        def max_dividend_per_share(corporation)
          return 0 unless corporation.floated?

          [(corporation.share_price.price / 3), (corporation.cash / num_issued(corporation))].min.to_i
        end

        # FIXME: TBD
        # FIXME: Stars, Inc.
        def corporation_stars(corporation, cash)
          (cash / 10).to_i + corporation.companies.sum { |c| @company_stars[c.sym] }
        end

        def target_stars(corporation)
          return 0 unless corporation.floated?

          (num_issued(corporation) * corporation.share_price.price / 10.0).round
        end

        def issuable_shares(entity)
          return [] unless entity.corporation?

          bundles_for_corporation(@bank, entity)
        end

        def buyable_bank_owned_companies
          return [@round.current_entity] if @round.is_a?(Round::IPO)

          @offering
        end

        def biddable_companies
          @offering - @on_deck
        end

        def update_offering(company)
          @offering.delete(company)
          next_to_offer = @company_deck.shift
          @offering << next_to_offer
          @on_deck << next_to_offer
          @log << "#{next_to_offer.sym} revealed from deck"
        end

        def share_prices
          PAR_PRICES.values.flatten.uniq.map { |p| prices[p] }
        end

        def ipo_companies
          @companies.select { |c| c.owner&.player? && c.owner != @foreign_investor }.sort_by(&:value)
        end

        def available_par_prices(company)
          PAR_PRICES[@company_stars[company.sym]].map { |p| prices[p] }.select { |p| p.corporations.empty? }
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

        # FIXME: Junkyard Scrappers
        def close_company(company)
          owner = company.owner
          owner.companies.delete(company)
          company.owner = nil
          @companies.delete(company)
          @log << "#{company.sym} (#{owner.name}) closes"
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
      end
    end
  end
end
