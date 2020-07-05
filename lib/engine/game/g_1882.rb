# frozen_string_literal: true

require_relative '../config/game/g_1882'
require_relative 'base'

module Engine
  module Game
    class G1882 < Base
      register_colors(green: '#237333',
                      gray: '#9a9a9d',
                      red: '#d81e3e',
                      blue: '#0189d1',
                      yellow: '#FFF500',
                      brown: '#7b352a')

      AXES = { x: :number, y: :letter }.freeze
      CORPORATIONS_WITHOUT_NEUTRAL = %w[CPR CN].freeze

      load_from_json(Config::Game::G1882::JSON)

      GAME_LOCATION = 'Assiniboia, Canada'
      GAME_RULES_URL = 'https://www.boardgamegeek.com/filepage/189409/1882-rules'
      GAME_DESIGNER = 'Marc Voyer'
      GAME_PUBLISHER = Publisher::INFO[:all_aboard_games]

      SELL_BUY_ORDER = :sell_buy_sell
      TRACK_RESTRICTION = :permissive
      DISCARDED_TRAINS = :remove
      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'nwr' => ['North West Rebellion',
                  'Remove all yellow tiles from NWR-marked hexes. Station markers remain']
      ).freeze

      def operating_round(round_num)
        Round::G1882::Operating.new(@corporations, game: self, round_num: round_num)
      end

      def init_phase
        phases = self.class::PHASES
        nwr_phases = %w[3 4 5 6]
        nwr_phase = nwr_phases[rand % nwr_phases.size]
        @log << "NWR Rebellion occurs at start of phase #{nwr_phase}"
        phases.each do |phase|
          phase[:events] = { nwr: true }.merge(phase[:events] || {}) if phase[:name] == nwr_phase
        end

        Phase.new(phases, self)
      end

      def init_corporations(stock_market)
        min_price = stock_market.par_prices.map(&:price).min

        corporations = self.class::CORPORATIONS.map do |corporation|
          corporation[:needs_token_to_par] = true if corporation[:sym] == 'CN'
          Corporation.new(
            min_price: min_price,
            capitalization: self.class::CAPITALIZATION,
            **corporation,
          )
        end

        # CN's tokens use a neutral logo, but as layed become owned by cn but don't block other players
        cn_corp = corporations.find { |x| x.name == 'CN' }
        corporations.each do |x|
          unless CORPORATIONS_WITHOUT_NEUTRAL.include?(x.name)
            x.tokens << Token.new(cn_corp, price: 0, logo: '/logos/1882/neutral.svg', type: :neutral)
          end
        end
        corporations
      end

      def event_nwr!
        @log << '-- Event: North West Rebellion! --'
        name = 'NWR'
        @hexes.each do |hex|
          next unless hex.tile.icons.any? { |icon| icon.name == name }

          next unless hex.tile.color == :yellow
          next unless hex.tile != hex.original_tile

          @log << "Rebellion destroys tile #{hex.name}"
          old_tile = hex.tile
          hex.lay(hex.original_tile)
          tiles << old_tile
        end
      end

      def revenue_for(route)
        revenue = super

        stops = route.stops
        # East offboards I1, B2
        east = stops.find { |stop| %w[I1 B2].include?(stop.hex.name) }
        # Hudson B12
        west = stops.find { |stop| stop.hex.name == 'B12' }
        revenue += 100 if east && west

        revenue
      end
    end
  end
end
