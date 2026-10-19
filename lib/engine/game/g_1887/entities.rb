# frozen_string_literal: true

module Engine
  module Game
    module G1887
      module Entities
        PRIVATES = [
          ['P1', '4DP', 'Phase 4. Gain a permanent 4D train. The owning company must then discard trains held in '\
                        'excess of the train limit.'],
          ['P2', '2DP', 'Phase 2. Gain a permanent 2D train. It is unsellable, doesn’t count towards train limit or '\
                        'train ownership. Pays, half-pays, and withholds with the owning corporation.'],
          ['P3', 'E Train Reserve', 'Phase 6. Apply a $300 discount on a single E train. This may be used to '\
                                    'purchase an E train during emergency fundraising.'],
          ['P4', 'Logging Railcar', 'Phase 1. Gain a logging railcar. If the company contains a lumber mill, its '\
                                    'revenue increases by $20. May be purchased by another company for any amount '\
                                    'between $0 and $100 during train buying.'],
          ['P5', 'Penitentiary', 'Phase 3. Adds a $30 bonus to either Aberdeen or Tri-Cities for all corporations.'],
          ['P6', 'Grand Coulee', 'Phase 2. Place a free token on the reserved space at Grand Coulee.'],
          ['P7', 'Puget Sound Navigation', 'Phase 2. Place a free token in a ferry hex, even if it is full.'],
          ['P8', 'State Park', 'Phase 1. Replace a minor industry with a State Park industry tile. Bank pays the '\
                               'president the minor’s current share value. The president must pay off any '\
                               'orchard/winery loans immediately.'],
          ['P9', 'Lobbyists', 'Phase 2. Reserve one treasury share (or up to two shares if the owning company has '\
                              'a token in Olympia). Reserved shares may not leave the company’s treasury without '\
                              'the president’s permission.'],
          ['P10', 'Capital Infusion', 'Phase 2. Move any amount of money from your hand to the owning company’s '\
                                      'treasury.'],
          ['P11', 'Advanced Tile Lay', 'Phase 1. Upgrade one plain track tile as an additional track lay. The new '\
                                       'track may be of a color that is not yet available.'],
          ['P12', 'Puget Sound Dredging Company', 'Phase 1. Lay or upgrade two tiles to form a connection across a '\
                                                  'water border, paying no terrain costs and as free track lays.'],
          ['P13', 'Coal Mine', 'Phase 1. Upgrade one neighboring city with a coal symbol up to one phase past the '\
                               'current phase, paying no terrain costs and as a free track lay. Ignore tile costs.'],
          ['P14', 'Twin Cities', 'Phase 1. Lay or upgrade one OO tile as a free track lay. New track may be of a '\
                                 'color beyond the current phase. Does not allow you to upgrade a tile twice in one '\
                                 'turn.'],
          ['P15', 'Ecotourism Company', 'Phase 2. Major gets a free token in a national park and places a $20 '\
                                        'marker on it. One train in major may run state and national parks as free '\
                                        'stops.'],
          ['P16', 'Late Industry', 'Phase 1. An owning major may acquire an unopened industry. A player owner may '\
                                   'par an unopened industry with as much cash from the president’s hand as they '\
                                   'wish at the end of an SR.'],
          ['P17', 'Tourism Grant', 'Phase 1. Get a $150 discount on a winery or resort. Does not allow force '\
                                   'purchasing a winery or resort.'],
        ].freeze

        # [id, name, home hex, home city index]
        RAILROAD_MINORS = [
          ['2', 'Puget Sound and Grays Harbor', 'C1', 0],
          ['3', 'Olympia and Chehalis Valley', 'C5', 0],
          ['4', 'Meeker and Southern', 'C11', 0],
          ['7', 'Satsop', 'D2', 0],
          ['9', 'Tacoma, Orting, and Southeastern', 'D10', 0],
          ['11', 'Issaquah Valley Trolley', 'F16', 0],
          ['12', 'Seattle and Walla Walla', 'G13', 0],
          ['13', 'Discovery and Quilcene', 'H8', 0],
          ['14', 'Everett and Cherry Valley', 'H16', 0],
          ['18', 'Seattle and Montana', 'I15', 0],
          ['19', 'Seattle and North Coast', 'K7', 0],
          ['21', 'Bellingham Bay and Eastern', 'M15', 0],
        ].freeze

        # [sym, name, color, text color, home hex, home city index, destination hex]
        MAJORS = [
          ['CPS', 'Columbia and Puget Sound', '#e05297', 'white', 'G13', 0, 'E21'],
          ['NP', 'Northern Pacific', '#7b4a2a', 'white', 'A5', 0, 'D10'],
          ['SLSE', 'Seattle, Lake Shore and Eastern', '#5b2c83', 'white', 'G13', 1, 'K15'],
          ['PTS', 'Port Townsend Southern', '#f0791f', 'white', 'J10', 0, 'D10'],
          ['GNR', 'Great Northern', '#f6d70d', 'black', 'I19', 0, 'I15'],
          ['UP', 'Union Pacific', '#1f5fbf', 'white', 'E3', 0, 'A5'],
          ['SWWR', 'Spokane and Walla Walla', '#0a8a3a', 'white', 'J22', 0, 'K21'],
        ].freeze

        COMPANIES = [
          *PRIVATES.map do |sym, name, desc|
            { name: "#{sym} #{name}", sym: sym, value: 0, revenue: 10, desc: desc, abilities: [], color: '#89CFF0' }
          end,
          *RAILROAD_MINORS.map do |id, name, hex, _city|
            {
              name: "MINOR: #{id}. #{name}",
              sym: "M#{id}",
              value: 100,
              revenue: 0,
              desc: "A 50% director’s certificate in the associated minor company. Starting location is #{hex}.",
              abilities: [],
              color: '#ffffff',
              text_color: 'black',
            }
          end,
          *MAJORS.each_with_index.map do |(sym, name, color, text_color, hex, _city, dest), index|
            {
              name: "CONCESSION: #{sym} #{name}",
              sym: "C#{index + 1}",
              value: 100,
              revenue: 10,
              desc: "Converts into the #{sym}’s 20% director certificate. Home #{hex}, destination #{dest}.",
              abilities: [{ type: 'exchange', corporations: [sym], owner_type: 'player', from: 'par' }],
              color: color,
              text_color: text_color,
            }
          end,
        ].freeze

        CORPORATIONS = [
          *RAILROAD_MINORS.map do |id, name, hex, city|
            {
              sym: id,
              name: name,
              logo: "1887/#{id}",
              tokens: [0],
              type: 'minor',
              always_market_price: true,
              float_percent: 100,
              hide_shares: true,
              shares: [100],
              max_ownership_percent: 100,
              coordinates: hex,
              city: city,
              color: '#ffffff',
              text_color: 'black',
            }
          end,
          *MAJORS.map do |sym, name, color, text_color, hex, city, dest|
            {
              sym: sym,
              name: name,
              logo: "1887/#{sym}",
              tokens: [0, 100, 100, 100, 100, 100, 100],
              type: 'major',
              float_percent: 20,
              always_market_price: true,
              coordinates: hex,
              city: city,
              color: color,
              text_color: text_color,
              destination_coordinates: dest,
              destination_icon: "1887/#{sym}_DEST",
            }
          end,
        ].freeze
      end
    end
  end
end
