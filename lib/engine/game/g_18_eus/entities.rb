# frozen_string_literal: true

module Engine
  module Game
    module G18EUS
      module Entities
        COMPANIES = [].freeze

        CORPORATIONS = [].freeze

        SUBSIDIES = [
          {
            icon: 'subsidy_plus_ten',
            abilities: [],
            sym: 'S1',
            name: '+10 starting city',
            desc: 'Increases starting city value by $10',
            value: 0,
          },
          {
            icon: 'subsidy_twenty',
            abilities: [],
            sym: 'S2',
            name: 'Extra $20',
            desc: 'Company receives an extra $20 into its treasury',
            value: 20,
          },
          {
            icon: 'subsidy_thirty',
            abilities: [],
            sym: 'S3',
            name: 'Extra $30',
            desc: 'Company receives an extra $30 into its treasury',
            value: 30,
          },
          {
            icon: 'subsidy_forty',
            abilities: [],
            sym: 'S4',
            name: 'Extra $40',
            desc: 'Company receives an extra $40 into its treasury',
            value: 40,
          },
          {
            icon: 'subsidy_fifty',
            abilities: [],
            sym: 'S5',
            name: 'Extra $50',
            desc: 'Company receives an extra $50 into its treasury',
            value: 50,
          },
          {
            icon: 'subsidy_free_token',
            abilities: [
              {
                type: 'token',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                price: 0,
                count: 1,
                extra_action: true,
                from_owner: false,
                cheater: true,
                special_only: true,
                hexes: [], # Determined in special_token step
              },
            ],
            sym: 'S6',
            name: 'Free Token',
            desc: 'Company receives extra token that may be placed for free',
            value: 0,
          },
          {
            icon: 'subsidy_rural_junction',
            abilities: [
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                reachable: true,
                consume_tile_lay: false,
                hexes: [],
                tiles: %w[1], # TODO: find tile number
              },
            ],
            sym: 'S7',
            name: 'Rural Junction Tile',
            desc: 'Company receives "K" rural junction tile. Placing junction tile does not count as tile lay.',
            value: 0,
          },
          {
            icon: 'subsidy_free_tile_lays',
            abilities: [
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                reachable: true,
                consume_tile_lay: false,
                count: 2,
                hexes: [],
                tiles: %w[7 8 9],
              },
            ],
            sym: 'S8',
            name: 'Free Tile Lays',
            desc: 'Company may lay two extra free yellow tiles',
            value: 0,
          },
          {
            icon: 'subsidy_green_starting_city',
            abilities: [
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                closed_when_used_up: true,
                count: 1,
                hexes: [], # assigned when claimed
                tiles: %w[14 15 619],
              },
              {
                type: 'close',
                when: 'operated',
                corporation: nil, # assigned when claimed
              },
            ],
            sym: 'S9',
            name: 'Green Starting City',
            desc: 'On its first operating turn, company may place green city tile on its home location instead of yellow.',
            value: 0,
          },
        ].freeze
      end
    end
  end
end
