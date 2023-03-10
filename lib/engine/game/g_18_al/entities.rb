# frozen_string_literal: true

module Engine
  module Game
    module G18AL
      module Entities
        COMPANIES = [
          {
            sym: 'TR',
            name: 'Tuscumbia Railway',
            value: 20,
            revenue: 5,
            desc: 'No special abilities.',
          },
          {
            sym: 'SNAR',
            name: 'South & North Alabama Railroad',
            value: 40,
            revenue: 10,
            desc: 'Owning corporation may place the Warrior Coal Field token in one of the city '\
                  'hexes with a mining symbol (Gadsden, Anniston, Oxmoor, Birmingham, or Tuscaloosa) '\
                  'provided that the corporation can reach the city with a route that is in the range '\
                  'of a train owned by the corporation (i.e. not an infinite route). Placing the '\
                  'token does not close the company. The owning corporation adds 10 to revenue for '\
                  'all trains whose route includes the city with the token. The token is removed from '\
                  'the game at the beginning of phase 6.',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[H3 G4 H5 G6 E6],
                count: 1,
                owner_type: 'corporation',
              },
            ],
          },
          {
            sym: 'BLC',
            name: 'Brown & Sons Lumber Co.',
            value: 70,
            revenue: 15,
            desc: 'Owning corporation may during the track laying step lay the Lumber Terminal '\
                  'track tile (# 445) in an empty swamp hex, which need not be connected to the '\
                  'corporation\'s station(s). The tile is free and does not count as the '\
                  'corporation\'s one tile lay per turn. Laying the tile does not close the '\
                  'company. The tile is permanent and cannot be upgraded.',
            abilities: [
              {
                type: 'tile_lay',
                free: true,
                owner_type: 'corporation',
                tiles: ['445'],
                hexes: %w[G2 M2 O4 N5 P5],
                count: 1,
                when: 'track',
              },
            ],
          },
          {
            sym: 'M&C',
            name: 'Memphis & Charleston Railroad',
            value: 100,
            revenue: 20,
            desc: 'Owning corporation receives the Robert E. Lee marker which adds +20 to revenue '\
                  'if a route includes Atlanta and Birmingham and the Pan American marker which adds '\
                  '+40 to revenue if a route includes Nashville and Mobile. Each marker may be assigned '\
                  'to one train each operating round and both markers may be assigned to a single '\
                  'train. The bonuses are permanent unless a new player becomes president of the '\
                  'corporation, in which case they are removed from the game.',
          },
          {
            sym: 'NDY',
            name: 'New Decatur Yards',
            value: 120,
            revenue: 20,
            desc: 'Owning corporation may purchase one new train from the bank with a discount of 50%, '\
                  'which closes the company.',
            abilities: [
              {
                type: 'train_discount',
                discount: 0.5,
                owner_type: 'corporation',
                trains: %w[3 4 5],
                count: 1,
                closed_when_used_up: true,
                when: 'buying_train',
              },
            ],
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'L&N',
            name: 'Louisville & Nashville Railroad',
            logo: '18_al/LN',
            simple_logo: '18_al/LN.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'A4',
            color: 'blue',
            abilities: [{ type: 'assign_hexes', hexes: ['G4'], count: 1 }],
          },
          {
            sym: 'M&O',
            name: 'Mobile & Ohio Railroad',
            logo: '18_al/MO',
            simple_logo: '18_al/MO.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'Q2',
            color: 'orange',
            abilities: [{ type: 'assign_hexes', hexes: ['K2'], count: 1 }],
          },
          {
            sym: 'WRA',
            name: 'Western Railway of Alabama',
            logo: '18_al/WRA',
            simple_logo: '18_al/WRA.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'L5',
            color: 'red',
            abilities: [{ type: 'assign_hexes', hexes: ['J7'], count: 1 }],
          },
          {
            sym: 'ATN',
            name: 'Alabama, Tennessee & Northern Railroad',
            logo: '18_al/ATN',
            simple_logo: '18_al/ATN.alt',
            tokens: [0, 40, 100],
            coordinates: 'F1',
            color: 'black',
            abilities: [{ type: 'assign_hexes', hexes: ['L1'], count: 1 }],
          },
          {
            sym: 'ABC',
            name: 'Atlanta, Birmingham & Coast Railroad',
            logo: '18_al/ABC',
            simple_logo: '18_al/ABC.alt',
            tokens: [0, 40],
            coordinates: 'G6',
            color: 'green',
            abilities: [{ type: 'assign_hexes', hexes: ['G4'], count: 1 }],
          },
          {
            sym: 'TAG',
            name: 'Tennessee, Alabama & Georgia Railway',
            logo: '18_al/TAG',
            simple_logo: '18_al/TAG.alt',
            tokens: [0, 40],
            coordinates: 'E6',
            color: 'yellow',
            text_color: 'black',
            abilities: [{ type: 'assign_hexes', hexes: ['G4'], count: 1 }],
          },
        ].freeze
      end
    end
  end
end
