# frozen_string_literal: true

require_relative '../config/game/g_18_zoo'
require_relative '../g_18_zoo/corporation'
require_relative '../g_18_zoo/company'
require_relative 'base'

module Engine
  module Game
    module Internal
      class G18ZOO < Base
        DEV_STAGE = :alpha

        GAME_DESIGNER = 'Paolo Russo'

        BANKRUPTCY_ALLOWED = false

        HOME_TOKEN_TIMING = :float

        SELL_BUY_ORDER = :sell_buy
        GAME_END_CHECK = { bankrupt: :immediate, bank: :full_or }.freeze

        # Two lays or one upgrade
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

        def init_round
          Round::Draft.new(self, [Step::G18ZOO::SimpleDraft], reverse_order: true)
        end

        def init_companies(_players)
          @companies = self.class::COMPANIES.map do |company|
            Engine::G18ZOO::Company.new(**company)
          end
          @companies = @companies.sort_by { rand }
          @companies.map.with_index do |company, index|
            company.phase = if index < 4
                              'ISR'
                            elsif index < 8
                              'MONDAY'
                            elsif index < 12
                              'TUESDAY'
                            elsif index < 16
                              'WEDNESDAY'
                            end
            company
          end.compact
        end

        def init_corporations(stock_market)
          min_price = stock_market.par_prices.map(&:price).min

          self.class::CORPORATIONS.map do |corporation|
            Engine::G18ZOO::Corporation.new(min_price: min_price, capitalization: self.class::CAPITALIZATION,
                                            **corporation.merge(corporation_opts))
          end
        end

        def priority_deal_player
          return @players.first if @round.is_a?(Round::Draft)

          super
        end

        # Only buy and sell par shares is possible action during SR
        def stock_round
          Round::Stock.new(self, [
              Step::BuySellParShares,
          ])
        end

        def game_end_check
          triggers = {
              custom: custom_end_game_reached?,
          }.select { |_, t| t }

          %i[immediate current_round current_or full_or one_more_full_or_set].each do |after|
            triggers.keys.each do |reason|
              if game_end_check_values[reason] == after
                (@turn == (@final_turn ||= @turn + 1)) if after == :one_more_full_or_set
                return [reason, after]
              end
            end
          end

          nil
        end
      end
    end

    class G18ZOOMapA < Internal::G18ZOO
      load_from_json(Config::Game::G18ZOO::JSON, Config::Game::G18ZOOMapA::JSON)

      def self.title
        '18ZOO - Map A'
      end
    end

    class G18ZOOMapB < G18ZOOMapA
      load_from_json(Config::Game::G18ZOO::JSON, Config::Game::G18ZOOMapB::JSON)

      def self.title
        '18ZOO - Map B'
      end
    end

    class G18ZOOMapC < G18ZOOMapA
      load_from_json(Config::Game::G18ZOO::JSON, Config::Game::G18ZOOMapC::JSON)

      def self.title
        '18ZOO - Map C'
      end
    end

    class G18ZOOMapD < Internal::G18ZOO
      load_from_json(Config::Game::G18ZOO::JSON, Config::Game::G18ZOOMapD::JSON)

      def self.title
        '18ZOO - Map D'
      end
    end

    class G18ZOOMapE < G18ZOOMapD
      load_from_json(Config::Game::G18ZOO::JSON, Config::Game::G18ZOOMapE::JSON)

      def self.title
        '18ZOO - Map E'
      end
    end

    class G18ZOOMapF < G18ZOOMapD
      load_from_json(Config::Game::G18ZOO::JSON, Config::Game::G18ZOOMapF::JSON)

      def self.title
        '18ZOO - Map F'
      end
    end
  end
end
