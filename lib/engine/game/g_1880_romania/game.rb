# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_1880/game'
require_relative 'map'
require_relative 'entities'
require_relative 'phases'
require_relative 'trains'

module Engine
  module Game
    module G1880Romania
      class Game < G1880::Game
        include_meta(G1880Romania::Meta)
        include G1880Romania::Map
        include G1880Romania::Entities
        include G1880Romania::Phases
        include G1880Romania::Trains

        CURRENCY_FORMAT_STR = 'L%s'

        CERT_LIMIT = { 3 => 20, 4 => 16, 5 => 14, 6 => 12 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 480, 5 => 400, 6 => 340 }.freeze

        EVENTS_TEXT = G1880::Game::EVENTS_TEXT.merge(
          'signal_end_game' => ['Signal End Game', 'Game ends 3 ORs after purchase of last 6E train']
        ).freeze

        def stock_round
          G1880Romania::Round::Stock.new(self, [
            Engine::Step::Exchange,
            G1880::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G1880::Round::Operating.new(self, [
            Engine::Step::HomeToken,
            Engine::Step::Exchange,
            Engine::Step::DiscardTrain,
            G1880::Step::Assign,
            G1880Romania::Step::Track,
            G1880::Step::Token,
            G1880::Step::Route,
            G1880::Step::Dividend,
            G1880Romania::Step::BuyTrain,
            G1880::Step::CheckFIConnection,
          ], round_num: round_num)
        end

        def event_open_borders!
          @log << "-- Event: Borders opened, owner of #{p2.name} still receives payment for built crossings --"

          self.class::BORDERS.each do |coord, edges|
            hex = hex_by_id(coord)
            next unless hex

            hex.tile.modify_borders(edges, type: :province)
          end

          clear_graph
        end

        def event_remove_borders!
          @log << '-- Event: Borders removed --'

          self.class::BORDERS.each do |coord, edges|
            hex = hex_by_id(coord)
            next unless hex

            hex.tile.modify_borders(edges, type: nil)
          end
        end

        def handle_province_crossing_income(hex, entity_or_entities)
          entity = Array(entity_or_entities).first
          return unless entity&.corporation?

          crossings = hex.tile.borders.select { |b| %i[province impassable].include?(b.type) }
          return if crossings.empty?

          income = 20 * crossings.size
          bank.spend(income, p2.owner)

          @log << "#{p2.owner.name} receives #{format_currency(income)} for province crossing"
        end

        def remove_border_calculate_cost!(tile, entity_or_entities, spender)
          total_cost, border_types = super

          @province_crossings ||= {}
          @province_crossings[tile.hex] = border_types.count { |t| %i[province impassable].include?(t) }

          [total_cost, border_types]
        end

        def p2
          @p2 ||= company_by_id('P2')
        end

        # This game's Electroputere S.A. private company's forced train exchange is identical to the forced exchange for the
        # Rocket of China in 1880, so we can reuse that logic here rather than recoding the whole thing.
        def forced_exchange_rocket?
          phase.name == 'B2' && !rocket.closed?
        end

        # Used for disabled 1880 methods
        def dummy_company
          @dummy ||= Company.new(
            name: 'Dummy Company',
            sym: 'DUMMY',
            value: 0,
          )
          @dummy.close!
          @dummy
        end

        # 1880 China method. Not used in this variant.
        def ferry_hexes
          []
        end

        # 1880 China method. Not used in this variant.
        def ferry_company
          dummy_company
        end

        # 1880 China method. Not used in this variant.
        def taiwan_company
          dummy_company
        end

        # 1880 China method. Not used in this variant.
        def taiwan_hex; end

        # 1880 China method. Not used in this variant.
        def trans_siberian_bonus?(_stops); end
      end
    end
  end
end
