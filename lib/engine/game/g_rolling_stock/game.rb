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
        CERT_LIMIT = 99

        SELL_MOVEMENT = :left_share_pres
        SELL_BUY_ORDER = :sell_buy
        GAME_END_CHECK = { stock_market: :current_or, bank: :full_or }.freeze
        SOLD_OUT_INCREASE = false
        EBUY_OTHER_VALUE = false
        PRESIDENT_SALES_TO_MARKET = true

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

        def init_round
          new_investment_round
        end

        def new_investment_round
          @turn += 1
          @log << "-- Turn #{@turn}, Phase 1 - Investment --"
          @round_counter += 1
          investment_round
        end

        def investment_round
          Round::Investment.new(self, [
            Step::BuySellSharesBidCompanies,
          ])
        end

        def new_ipo_round
          @log << "-- Turn #{@turn}, Phase 9 - IPO --"
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
          pd_player = @players.max_by(&:cash)
          @players.rotate!(@players.index(pd_player))
          @log << "Player order: #{@players.map(&:name).join(', ')}"
        end

        # wrap-up
        def phase2
          @log << "-- Turn #{@turn}, Phase 2 - Wrap-Up --"
          reorder_by_cash
          # FIXME: implement foriegn investor purchase
          @on_deck.clear
        end

        # income
        def phase5
          @log << "-- Turn #{@turn}, Phase 5 - Income --"
          (@players + [@foreign_investor] + @corporations).each do |entity|
            next if entity.corporation? && !entity.ipoed

            income = entity.companies.sum(&:revenue)
            income += calculate_synergies(entity) if entity.corporation?
            income += FOREIGN_EXTRA_INCOME if entity == @foreign_investor
            next unless income.positive?

            @log << "#{entity.name} receives #{format_currency(income)}"
            @bank.spend(income, entity)
          end
        end

        # end card
        def phase7
          @log << "-- Turn #{@turn}, Phase 7 - End Card --"
        end

        def next_round!
          @round =
            case @round
            when Round::Investment
              phase2
              phase5 # FIXME: move to after closing_round
              phase7 # FIXME: move to after dividends_round
              new_ipo_round # FIXME: new_acquistion_round
            when Round::IPO
              new_investment_round
            end
        end

        # FIXME
        def calculate_synergies(_corporation)
          0
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
          while price.price != 75 && !price.corporations.empty?
            r, c = price.coordinates
            price = @stock_market.share_price(r, c + 1)
          end
          price
        end

        def move_to_left(corporation)
          r, c = next_price_to_left(corporation.share_price).coordinates
          @stock_market.move(corporation, r, c)
          new_price = corporation.share_price.price
          @log << "#{corporation.name} share price decreases to #{format_currency(new_price)}"
          close_corporation(corporation) if new_price.zero?
        end

        def next_price_to_left(price)
          while price.price != 0 && !price.corporations.empty?
            r, c = price.coordinates
            price = @stock_market.share_price(r, c - 1)
          end
          price
        end
      end
    end
  end
end
