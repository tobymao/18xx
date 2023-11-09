# frozen_string_literal: true

require_relative '../g_1822_ca/game'
require_relative '../g_1822_ca/scenario'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'

module Engine
  module Game
    module G1822CaWrs
      class Game < G1822CA::Game
        include_meta(G1822CaWrs::Meta)
        include Entities
        include Map
        include G1822CA::Scenario

        EXCHANGE_TOKENS = {
          'CNoR' => 3,
          'CPR' => 4,
          'GNWR' => 3,
          'GTP' => 3,
          'NTR' => 3,
          'PGE' => 3,
        }.freeze

        TRAINS = (G1822CA::Scenario::TRAINS + [
          {
            name: 'G',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 99,
                'visit' => 99,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 2,
            price: 0,
          },
        ]).freeze

        PENDING_HOME_TOKENERS = [MINOR_14_ID, 'GNWR'].freeze

        def init_companies(players)
          game_companies.map do |company|
            next if players.size < (company[:min_players] || 0)
            next unless starting_companies.include?(company[:sym])

            opts = self.class::STARTING_COMPANIES_OVERRIDE[company[:sym]] || {}
            Company.new(**company.merge(opts))
          end.compact
        end
      end
    end
  end
end
