# frozen_string_literal: true

module Engine
  module Game
    module G18Lra
      module Entities
        CORPORATIONS = [
          {
            float_percent: 50,
            name: 'Aachen-Düsseldorf-Ruhrorter Eisenbahn',
            sym: 'ADR',
            tokens: [0, 60, 80],
            logo: '18_rhl/ADR',
            simple_logo: '18_rhl/ADR.alt',
            color: :green,
            coordinates: 'K3',
            abilities: [
              {
                type: 'base',
                description: 'Double yellow tiles first OR',
                desc_detail: 'The ADR may lay two yellow tracks instead of one, during its first operating round (TO BE DONE)',
              },
            ],
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Bergisch-Märkische Eisenbahngesell.',
            sym: 'BME',
            float_percent: 50,
            tokens: [0, 60, 80],
            logo: '18_rhl/BME',
            simple_logo: '18_rhl/BME.alt',
            color: :brown,
            coordinates: 'G15',
            abilities: [],
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Cöln-Mindener Eisenbahngesellschaft',
            sym: 'CME',
            float_percent: 50,
            tokens: [0, 60, 80],
            color: '#CD5C5C',
            logo: '18_rhl/CME',
            simple_logo: '18_rhl/CME.alt',
            coordinates: 'A5',
            abilities: [
              {
                type: 'base',
                description: 'Double yellow tiles first OR',
                desc_detail: 'The CME may lay two yellow tracks instead of one, during its first operating round (TO BE DONE)',
              },
            ],
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Krefelder Eisenbahngesellschaft',
            sym: 'KEG',
            float_percent: 50,
            shares: [30, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 60],
            logo: '18_rhl/KEG',
            simple_logo: '18_rhl/KEG.alt',
            color: :orange,
            text_color: :black,
            coordinates: 'F10',
            city: 0,
            abilities: [
              {
                type: 'base',
                description: 'Double yellow tiles first OR',
                desc_detail: 'The KEG may lay two yellow tracks instead of one, during its first operating round (TO BE DONE)',
              },
              {
                type: 'base',
                description: 'Presidency share 30%',
              },
            ],
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Gladbach-Venloer Eisenbahn',
            sym: 'GVE',
            float_percent: 50,
            tokens: [0, 60, 80],
            logo: '18_rhl/GVE',
            simple_logo: '18_rhl/GVE.alt',
            color: :gray,
            coordinates: 'G7',
            city: 1,
            abilities: [
            {
              type: 'base',
              description: 'Bonus when link exists Mönchengladbach - Venlo',
              desc_detail: 'The GVE receives 100 Marks into its treasury, when a track link has been established '\
                           'from Mönchengladbach and Venlo (TO BE DONE)',
            },
           ],
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Cöln-Crefelder Eisenbahn',
            sym: 'CCE',
            float_percent: 50,
            tokens: [0, 60],
            color: :blue,
            logo: '18_rhl/CCE',
            simple_logo: '18_rhl/CCE.alt',
            coordinates: 'K15',
            city: 1,
            abilities: [
              {
                type: 'base',
                description: 'Free teleport to Krefeld (F10)',
                desc_detail: 'The CCE may place a station token during its normal tokening on Hex F10 (Krefeld) '\
                             'without an available route',
              },
            ],
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Rheinische Eisenbahngesellschaft',
            sym: 'RhE',
            float_percent: 50,
            tokens: [0, 60, 80],
            color: :purple,
            logo: '18_rhl/RhE',
            simple_logo: '18_rhl/RhE.alt',
            coordinates: 'I10',
            city: 0,
            abilities: [
              {
                type: 'base',
                description: 'Double yellow tiles first OR',
                desc_detail: 'The RhE may lay two yellow tracks instead of one, during its first operating round (TO BE DONE)',
              },
            ],
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Moerser Kreisbahn',
            sym: 'MKB',
            float_percent: 50,
            tokens: [0, 60],
            # The 2nd share decided share percentage for shares (TO BE DONE - Check if 18Rhl code work for this)
            shares: [20, 10, 20, 20, 10, 10, 10],
            color: :black,
            text_color: :white,
            logo: '18_rhl/MKB',
            simple_logo: '18_rhl/MKB.alt',
            coordinates: 'C11',
            abilities: [
              {
                type: 'base',
                description: 'Cheaper harbour token in Orsoy',
                desc_detail: 'The MKB may place a harbour token in Orsoy (B12) for 20 Marks (TO BE DONE)',
              },
              {
                type: 'base',
                description: 'Two double (20%) certificates',
                desc_detail: 'The first two (non-president) shares sold from IPO are double (20%) certificates (TO BE DONE)',
              },
            ],
            always_market_price: true,
            max_ownership_percent: 100,
          },
        ].freeze

        def game_corporations
          self.class::CORPORATIONS
        end

        COMPANIES = [
          {
            sym: 'DEC',
            name: 'No. 1 Dalheim Emigrant Camp',
            value: 20,
            revenue: 5,
            desc: 'DEC becomes active, either when the Dalheim hex I3 being liked to a city on the right (east) banks '\
                  'of Rhine, or after the purchase of the first 5-train. The owning player must immediately turn the '\
                  "token 'Dec under construction' to 'Dec active'. Then places the token with DEC and the value '20' "\
                  'on the charter of a railway corporation they hold the director certificate of. That railway '\
                  "corporation now increases any route from Rhine's right (east) bank to Dalheim by 20 Marks. "\
                  'Both DEC tokens remain in place until the end of the game.',
          },
          {
            sym: 'UH',
            name: 'No. 2 Uerdingen Harbour',
            value: 40,
            revenue: 15,
            desc: 'Private no. 2 reserves a harbour station location on hex E13 (Uerdingen). THe owner may '\
                  'place the harbour token on this reserved station location providing the hex is already '\
                  'upgraded with green tile #L31 and the acting railway corporation has an available route '\
                  'to that location. Use the lower cost for the station token.',
          },
          {
            sym: 'NH',
            name: 'No. 3 Neuss Harbour',
            value: 50,
            revenue: 15,
            desc: 'Private no. 3 reserves a harbour station location on hex H14 (Neuss). THe owner may '\
                  'place the harbour token on this reserved station location providing the hex is already '\
                  'upgraded with green tile #L27 and the acting railway corporation has an available route '\
                  'to that location. Use the lower cost for the station token.',
          },
          {
            sym: 'RH',
            name: 'No. 4 Rihrort Harbour',
            value: 60,
            revenue: 15,
            desc: 'Private no. 4 reserves a harbour station location on hex B14 (Ruhrort). THe owner may '\
                  'place the harbour token on this reserved station location providing the hex is already '\
                  'upgraded with green tile #L30 and the acting railway corporation has an available route '\
                  'to that location. Use the lower cost for the station token.',
          },
          {
            sym: 'RM',
            name: "No. 5 Rhineland's Manchester",
            value: 80,
            revenue: 20,
            desc: 'Private no. 5 comes together with a 10% certificate of the ADR. After the start of the '\
                  'green phase, the owning player may place a tile on one of the MG hexes (H8 or I7). The '\
                  'acting railway corporation does not need an available route to the hex. It may also build '\
                  'a station on the tile just laid at the normal costs. A later station placement requires '\
                  'an available route.',
          },
          {
            sym: 'GKB',
            name: 'No. 6 Geldernsche Kreisbahn',
            value: 100,
            revenue: 10,
            desc: "Private no. 6 comes with the GKB's home station token. GKB floats instantely after the "\
                  "purchase of the first 5-train. Place the GKB's home station token onto field A2. The "\
                  'owning player must immediately flip the private certificate no. 6 to convert it into a '\
                  "2+4 train and place the train card onto a railway corporation's charter of which they "\
                  'hold the directorturn the token certificate.',
          },
        ].freeze
      end
    end
  end
end
