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

        PENDING_HOME_TOKENERS = ['GNWR'].freeze

        def after_lay_tile(hex, _old_tile, _tile)
          super
          update_home(gnwr, tile_trigger: true) if hex.id == gnwr.coordinates
        end

        def after_place_token(_entity, city)
          super
          update_home(gnwr) if city.hex.id == gnwr.coordinates
        end

        # the pending home tokeners are all in the east
        def pending_home_tokeners
          []
        end

        # GNWR and minor 18 both live in Thunder Bay (R16), and they might both
        # be there before there are actually 2 token slots available
        def home_token_can_be_cheater
          true
        end

        def place_home_token(corporation)
          # placing the "cheater" token while GNWR also has a reservation
          # creates a third slot in green/brown
          hex_by_id(gnwr.coordinates).tile.remove_reservation!(gnwr) if corporation == gnwr
          super
        end
      end
    end
  end
end
