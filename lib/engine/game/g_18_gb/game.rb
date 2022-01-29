# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative 'scenarios'
require_relative 'trainphases'
require_relative '../base'

module Engine
  module Game
    module G18GB
      class Game < Game::Base
        include_meta(G18GB::Meta)
        include Entities
        include Map
        include Scenarios
        include TrainPhases

        GAME_END_CHECK = { final_train: :current_or, stock_market: :current_or }.freeze

        BANKRUPTCY_ALLOWED = false

        BANK_CASH = 99_999

        CURRENCY_FORMAT_STR = '£%d'

        PRESIDENT_SALES_TO_MARKET = true

        CAPITALIZATION = :full

        SELL_BUY_ORDER = :sell_buy

        SOLD_OUT_INCREASE = true

        NEXT_SR_PLAYER_ORDER = :first_to_pass

        MUST_SELL_IN_BLOCKS = true

        TRACK_RESTRICTION = :restrictive

        HOME_TOKEN_TIMING = :float

        DISCARDED_TRAINS = :remove

        IMPASSABLE_HEX_COLORS = %i[gray red].freeze

        MARKET_SHARE_LIMIT = 100

        MARKET = [
          %w[50o 55o 60o 65o 70p 75p 80p 90p 100p 115 130 160 180 200 220 240 265 290 320 350e 380e],
        ].freeze

        def init_scenario(optional_rules)
          num_players = @players.size
          two_east_west = optional_rules.include?(:two_player_ew)
          four_alternate = optional_rules.include?(:four_player_alt)

          case num_players
          when 2
            SCENARIOS[two_east_west ? '2EW' : '2NS']
          when 3
            SCENARIOS['3']
          when 4
            SCENARIOS[four_alternate ? '4Alt' : '4Std']
          when 5
            SCENARIOS['5']
          else
            SCENARIOS['6']
          end
        end

        def init_optional_rules(optional_rules)
          optional_rules = super(optional_rules)
          @scenario = init_scenario(optional_rules)
          optional_rules
        end

        def optional_hexes
          case @scenario['map']
          when '2NS'
            self.class::HEXES_2P_NW
          when '2EW'
            self.class::HEXES_2P_EW
          else
            self.class::HEXES
          end
        end

        def num_trains(train)
          @scenario['train_counts'][train[:name]]
        end

        def game_cert_limit
          @scenario['cert-limit']
        end

        def game_companies
          scenario_comps = @scenario['companies']
          self.class::COMPANIES.select { |comp| scenario_comps.include? comp['sym'] }
        end

        def game_corporations
          scenario_corps = @scenario['corporations'] + @scenario['corporation-extra'].sort_by { rand }.take(1)
          self.class::CORPORATIONS.select { |corp| scenario_corps.include? corp['sym'] }
        end

        def game_tiles
          if @scenario['gray-tiles']
            self.class::TILES.merge(self.class::GRAY_TILES)
          else
            self.class::TILES
          end
        end

        def init_starting_cash(players, bank)
          cash = @scenario['starting-cash']
          players.each do |player|
            bank.spend(cash, player)
          end
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::BuyCompany,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def active_players
          return super if @finished

          company = company_by_id('ER')
          current_entity == company ? [@round.company_sellers[company]] : super
        end
      end
    end
  end
end
