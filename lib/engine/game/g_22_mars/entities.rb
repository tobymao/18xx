# frozen_string_literal: true

module Engine
  module Game
    module G22Mars
      module Entities
        COMPANIES = [
          {
            name: 'VIP Evacuation Plan',
            sym: 'VEP',
            is_revolt: true,
            value: 0,
            revenue: 5,
            desc: 'Use once to increase the value of every tourist colony token (T) on the board by +10c.'\
                  ' This increase applies to all trains stopping at T colonies.',
            abilities: [
              { type: 'close', on_phase: 'never' },
              {
                type: 'description',
                description: 'Cannot be used until Revolt! happens.',
              },
            ],
            color: :red,
          },
          {
            name: 'Stopped Riot',
            sym: 'SR',
            is_revolt: true,
            value: 0,
            revenue: 5,
            desc: 'Use once to flip back or remove one Revolt! token completely from the game board.',
            abilities: [
              { type: 'close', on_phase: 'never' },
              {
                type: 'description',
                description: 'Cannot be used until Revolt! happens.',
              },
            ],
            color: :red,
          },
          {
            name: 'Tourist Evacuation',
            sym: 'TE',
            is_revolt: true,
            value: 0,
            revenue: 5,
            desc: 'Use once to remove up to three tourist colony tokens (T) from the board'\
                  ' regardless what corporations they belong to.',
            abilities: [
              { type: 'close', on_phase: 'never' },
              {
                type: 'description',
                description: 'Cannot be used until Revolt! happens.',
              },
            ],
            color: :red,
          },
          {
            name: 'Special Force Operation',
            sym: 'SFO',
            is_revolt: true,
            value: 0,
            revenue: 5,
            desc: 'Use once to remove all Revolt! tokens in one colony cluster free of choice.',
            abilities: [
              { type: 'close', on_phase: 'never' },
              {
                type: 'description',
                description: 'Cannot be used until Revolt! happens.',
              },
            ],
            color: :red,
          },
          {
            name: 'Labour Transports',
            sym: 'LT',
            value: 10,
            revenue: 10,
            desc: 'Assign to a corporation which gets to transport convicts as labor and get +10c'\
                  'bonus for each train stop made at the Robot Factory, Android Amusement Park and/or Paradise City.'\
                  ' This permit starts generating +5c per OR after the first train stop at one of the three locations.',
            abilities: [
              {
                type: 'assign_corporation',
                when: 'owning_player_or_turn',
                count: 1,
              },
            ],
            color: :orange,
          },
          {
            name: 'Government Decision',
            sym: 'GD',
            value: 30,
            revenue: 10,
            desc: 'Use once to relocate any colony token on the board (except a "T" token) which'\
                  'belongs to a corporation the player owns at least a 20% certificate in, to any other'\
                  'free colony space on the board. This action is performed during the OR colony phase.',
            abilities: [],
            color: nil,
          },
          {
            name: 'Infrastructure Push',
            sym: 'IP',
            value: 30,
            revenue: 10,
            desc: 'The owner can, as the CEO of a corporation, choose to upgrade a tile one level'\
                  ' above current phase. (This cannot upgrade a tile to the black tile)',
            abilities: [],
            color: nil,
          },
          {
            name: 'Robot Factory',
            sym: 'RF',
            value: 20,
            revenue: 10,
            used_revenue: 5,
            desc: 'The owner can place the white RF token in any hex with a M or C colony token on it.'\
                  ' This extra token can be placed under an existing colony token or in a free slot and'\
                  ' increases the income by +10c for all trains stopping in this hex.'\
                  ' If placed in a free slot, it will block train passage according to normal colony rules.'\
                  ' After being used, this permit still generates +5c per OR',
            abilities: [],
            color: :orange,
          },
          {
            name: 'Paradise City',
            sym: 'PC',
            value: 20,
            revenue: 10,
            used_revenue: 5,
            desc: 'The owner can place a white "T" token in a colony hex that does not contain a M or C colony.'\
                  ' This extra income token does not claim a colony space and increases the income by +10c'\
                  ' for all trains stopping in this hex.'\
                  ' After being used, this permit still generates +5c per OR',
            abilities: [],
            color: :orange,
          },
          {
            name: 'Android Amusement Park',
            sym: 'AAP',
            value: 30,
            revenue: 10,
            used_revenue: 5,
            desc: 'The player can, as the CEO of a corporation, place the Android Amusement Park tile'\
                  ' in an outpost hex either as a new tile or as a replacement of a yellow tile.'\
                  ' This counts as a free action during tile laying step in OR.'\
                  ' After being used, this permit still generates +5c per OR',
            abilities: [],
            color: :orange,
          },
          {
            name: 'Prototype Hyperdrive',
            sym: 'PH',
            value: 20,
            revenue: 10,
            desc: 'Use once to choose a train that gets extended distance by a free outpost stop during each run.'\
                  ' If only colonies are passed along the route, no free stop can be made.'\
                  ' The permit is removed if the train rusts.',
            abilities: [],
            color: nil,
          },
          {
            name: 'Mining Area Gamma',
            sym: 'MAG',
            value: 10,
            revenue: 10,
            desc: 'Assign to a corporation to give it exclusive rights to build track and run trains'\
                  ' through the Mining Area Gamma.  This permit stops generating revenue after the tile is laid'\
                  ' in Mining Area Gamma hex.',
            abilities: [
              {
                type: 'blocks_hexes',
                hexes: ['D13'], # TODO: Maintain hexes when map is randomly generated
              },
              {
                type: 'assign_corporation',
                when: 'owning_player_or_turn',
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Mining Area Alpha',
            sym: 'MAA',
            value: 10,
            revenue: 10,
            desc: 'Assign to a corporation to give it exclusive rights to build track and run trains'\
                  ' through the Mining Area Alpha.  This permit stops generating revenue after the tile is laid'\
                  ' in Mining Area Alpha hex.',
            abilities: [
              {
                type: 'blocks_hexes',
                hexes: ['H15'], # TODO: Maintain hexes when map is randomly generated
              },
              {
                type: 'assign_corporation',
                when: 'owning_player_or_turn',
                count: 1,
              },
            ],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'TRE',
            name: 'The Redline Express',
            logo: '22Mars/TRE',
            coordinates: 'D9', # TODO: Maintain start city when map is randomly generated
            color: '#FB0007',
            text_color: 'white',
            tokens: [0, 0, 0, 0], # TODO: Add M/T/C tokens via code
            shares: [20, 20, 20, 20, 20],
            float_percent: 20,
            max_ownership_percent: 100,
            always_market_price: true,
          },
          {
            sym: 'SMC',
            name: 'Space Minerals Corporation',
            logo: '22Mars/SMC',
            coordinates: 'C14', # TODO: Maintain start city when map is randomly generated
            color: '#0B5453',
            text_color: 'white',
            tokens: [0, 0, 0, 0],
            shares: [20, 20, 20, 20, 20],
            float_percent: 20,
            max_ownership_percent: 100,
            always_market_price: true,
          },
          {
            sym: 'NWC',
            name: 'The New World Corporation',
            logo: '22Mars/NWC',
            coordinates: 'D11', # TODO: Maintain start city when map is randomly generated
            color: '#D0D0D0',
            text_color: 'black',
            tokens: [0, 0, 0, 0],
            shares: [20, 20, 20, 20, 20],
            float_percent: 20,
            max_ownership_percent: 100,
            always_market_price: true,
          },
          {
            sym: 'PL',
            name: 'The Paradise Line',
            logo: '22Mars/PL',
            coordinates: 'G14', # TODO: Maintain start city when map is randomly generated
            color: '#BF5206',
            text_color: 'black',
            tokens: [0, 0, 0, 0],
            shares: [20, 20, 20, 20, 20],
            float_percent: 20,
            max_ownership_percent: 100,
            always_market_price: true,
          },
          {
            sym: 'MS',
            name: 'The Mars Shuttle',
            logo: '22Mars/MS',
            coordinates: 'I14', # TODO: Maintain start city when map is randomly generated
            color: '#18C0FF',
            text_color: 'black',
            tokens: [0, 0, 0, 0],
            shares: [20, 20, 20, 20, 20],
            float_percent: 20,
            max_ownership_percent: 100,
            always_market_price: true,
          },
          {
            sym: 'SRC',
            name: 'The Star Rail Corporation',
            logo: '22Mars/SRC',
            type: '5-share',
            coordinates: 'H7', # TODO: Maintain start city when map is randomly generated
            city: 0,
            color: 'black',
            text_color: 'white',
            tokens: [0, 0, 0, 0],
            shares: [20, 20, 20, 20, 20],
            float_percent: 20,
            max_ownership_percent: 100,
            always_market_price: true,
          },
          {
            sym: 'IG',
            name: 'Intergalactic',
            logo: '22Mars/IG',
            type: '5-share',
            coordinates: 'C6', # TODO: Maintain start city when map is randomly generated
            city: 0,
            color: '#6B006D',
            text_color: 'white',
            tokens: [0, 0, 0, 0],
            shares: [20, 20, 20, 20, 20],
            float_percent: 20,
            max_ownership_percent: 100,
            always_market_price: true,
          },
          {
            sym: 'REX',
            name: 'The Robot Express',
            logo: '22Mars/REX',
            type: '5-share',
            coordinates: 'H7', # TODO: Maintain start city when map is randomly generated
            city: 1,
            color: '#FFFF0B',
            text_color: 'black',
            tokens: [0, 0, 0, 0],
            shares: [20, 20, 20, 20, 20],
            float_percent: 20,
            max_ownership_percent: 100,
            always_market_price: true,
          },
        ].freeze
      end
    end
  end
end
