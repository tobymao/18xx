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

        PHASES = [
          { name: 'red', train_limit: 1, tiles: [:yellow], operating_rounds: 1 },
          { name: 'orange', train_limit: 1, tiles: [:yellow], operating_rounds: 1 },
          { name: 'yellow', train_limit: 1, tiles: [:yellow], operating_rounds: 1 },
          { name: 'green', train_limit: 1, tiles: [:yellow], operating_rounds: 1 },
          { name: 'blue', train_limit: 1, tiles: [:yellow], operating_rounds: 1 },
        ].freeze

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

        def reorder_by_cash
          # this should break ties in favor of the closest to previous PD
          pd_player = @players.max_by(&:cash)
          @players.rotate!(@players.index(pd_player))
          @log << "Player order: #{@players.map(&:name).join(', ')}"
        end

        # wrap-up
        def phase2
          reorder_by_cash
          @on_deck.delete
        end

        # income
        def phase5; end

        # end card
        def phase7; end

        def next_round!
          @round =
            case @round
            when GRollingStock::Round::Investment
              phase2
              @turn += 1 # FIXME: after Round::IPO
              new_investment_round # FIXME: new_acquistion_round
            end
        end

        def issuable_shares(entity)
          return [] unless entity.corporation?

          bundles_for_corporation(@bank, entity)
        end

        def buyable_bank_owned_companies
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
      end
    end
  end
end
