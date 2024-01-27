# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'trains'

module Engine
  module Game
    module G18RoyalGorge
      class Game < Game::Base
        include_meta(G18RoyalGorge::Meta)
        include Entities
        include Map
        include Trains

        CURRENCY_FORMAT_STR = '$%s'
        BANK_CASH = 99_999
        CERT_LIMIT = { 2 => 20, 3 => 14, 4 => 10 }.freeze
        STARTING_CASH = { 2 => 800, 3 => 550, 4 => 400 }.freeze

        STOCKMARKET_COLORS = {
          par: :yellow,
          par_1: :green,
          par_2: :brown,
          endgame: :red,
        }.freeze
        MARKET = [
          %w[30 35 40 45 50 55 60p 65p 70p 80p 90x 100x 110x 120x 130z 145z 160z 180z 200 220 240 260 280 310e 340e 380e 420e
             460e],
        ].freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'Par values in Yellow Phase',
                                              par_1: 'Additional par values in Green Phase',
                                              par_2: 'Additional par values in Brown Phase').freeze
        MUST_SELL_IN_BLOCKS = true
        SELL_BUY_ORDER = :sell_buy

        TILE_LAYS = ([{ lay: true, upgrade: true, cost: 0 }] * 6).freeze
        MUST_BUY_TRAIN = :always
        CAPITALIZATION = :incremental
        ESTABLISHED = {
          'KP' => 1869,
          'RG' => 1870,
          'SPP' => 1872,
          'PAV' => 1875,
          'SF' => 1876,
          'NO' => 1881,
          'CM' => 1883,
          'S' => 1887,
          'FCC' => 1893,
          'CSCC' => 1897,
          'CS' => 1898,
        }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          green_par: ['Green Par Available'],
          brown_par: ['Brown Par Available'],
        )

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def game_companies
          YELLOW_COMPANIES.sort_by { rand }.take(2).sort_by { |c| c[:sym] } +
            GREEN_COMPANIES.sort_by { rand }.take(2).sort_by { |c| c[:sym] } +
            BROWN_COMPANIES.sort_by { rand }.take(1)
        end

        def game_corporations
          # SF, RG, and three random corporations
          corporations = INCLUDED_CORPORATIONS + MAYBE_CORPORATIONS.sort_by { rand }.take(3)

          # sort by established year, to create yellow/green/brown tranches
          corporations = corporations.sort_by { |c| ESTABLISHED[c[:sym]] }

          # put established year on charter
          corporations.map do |corporation|
            corp = corporation.dup
            corp[:abilities] = [{ type: 'base', description: "Est. #{ESTABLISHED[corp[:sym]]}" }]
            corp
          end

          @log << "Railroads in the game: #{corporations.map { |c| c[:sym] }.join(', ')}"

          corporations
        end

        def setup
          @corporation_phase_color = {}
          @corporations[0..1].each { |c| @corporation_phase_color[c.name] = 'Yellow' }
          @corporations[2..3].each { |c| @corporation_phase_color[c.name] = 'Green' }
          @corporations[4..4].each { |c| @corporation_phase_color[c.name] = 'Brown' }

          @available_par_groups = %i[par]
        end

        def status_array(corporation)
          if can_start?(corporation) || corporation.type == :metal
            nil
          else
            ["Available in #{@corporation_phase_color[corporation.name]} Phase"]
          end
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G18RoyalGorge::Step::BuySellParShares,
          ])
        end

        def can_start?(corporation)
          case @phase.name
          when 'Yellow'
            @corporation_phase_color[corporation.name] == @phase.name
          when 'Green'
            @corporation_phase_color[corporation.name] != 'Brown'
          else
            true
          end
        end

        def can_par?(corporation, parrer)
          can_start?(corporation) && super
        end

        def event_green_par!
          @log << "-- Event: #{EVENTS_TEXT[:green_par]} --"
          @available_par_groups << :par_1
          update_cache(:share_prices)
        end

        def event_brown_par!
          @log << "-- Event: #{EVENTS_TEXT[:brown_par]} --"
          @available_par_groups << :par_2
          update_cache(:share_prices)
        end

        def par_prices
          @stock_market.share_prices_with_types(@available_par_groups)
        end

        def corporation_opts
          @players.size == 2 ? { max_ownership_percent: 70 } : {}
        end
      end
    end
  end
end
