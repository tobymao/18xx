# frozen_string_literal: true

module Engine
  module Game
    module G18Rhl
      module Entities
        CORPORATIONS = [
          {
            float_percent: 50,
            name: 'Aachen-Düsseldorf-Ruhrorter E.',
            sym: 'ADR',
            tokens: [0, 60, 80],
            logo: '18_rhl/ADR',
            simple_logo: '18_rhl/ADR.alt',
            color: :green,
            coordinates: 'K2',
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Bergisch-Märkische Eisenbahngesell.',
            sym: 'BME',
            float_percent: 50,
            tokens: [0, 60, 80, 100],
            logo: '18_rhl/BME',
            simple_logo: '18_rhl/BME.alt',
            color: :brown,
            coordinates: 'F13',
            city: 1,
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Cöln-Mindener Eisenbahngesellschaft',
            sym: 'CME',
            float_percent: 50,
            tokens: [0, 60, 80, 100],
            color: '#CD5C5C',
            logo: '18_rhl/CME',
            simple_logo: '18_rhl/CME.alt',
            coordinates: 'I10',
            city: 2,
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Düsseldorf Elberfelder Eisenbahn',
            sym: 'DEE',
            float_percent: 50,
            tokens: [0, 60],
            logo: '18_rhl/DEE',
            simple_logo: '18_rhl/DEE.alt',
            color: :yellow,
            text_color: :black,
            coordinates: 'F9',
            city: 1,
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Krefelder Eisenbahngesellschaft',
            sym: 'KEG',
            float_percent: 60,
            tokens: [0, 60],
            # The 2nd share decided share percentage for shares
            shares: [20, 10, 20, 20, 10, 10, 10],
            logo: '18_rhl/KEG',
            simple_logo: '18_rhl/KEG.alt',
            color: :orange,
            text_color: :black,
            coordinates: 'D7',
            abilities: [
              {
                type: 'base',
                description: 'Two double (20%) certificates',
                desc_detail: 'The first two (non-president) shares sold from IPO are double (20%) certificates',
              },
            ],
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Gladbach-Venloer Eisenbahn',
            sym: 'GVE',
            float_percent: 50,
            tokens: [0, 60],
            logo: '18_rhl/GVE',
            simple_logo: '18_rhl/GVE.alt',
            color: :gray,
            coordinates: 'G6',
            city: 1,
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Cöln-Crefelder Eisenbahn',
            sym: 'CCE',
            float_percent: 50,
            tokens: [0, 0, 80],
            color: :blue,
            logo: '18_rhl/CCE',
            simple_logo: '18_rhl/CCE.alt',
            coordinates: %w[E6 I10],
            city: 1,
            abilities: [
              {
                type: 'base',
                description: 'Two home stations (Köln & Krefeld)',
              },
            ],
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Rheinische Eisenbahngesellschaft',
            sym: 'RhE',
            float_percent: 50,
            tokens: [0, 60, 80, 100],
            color: :purple,
            logo: '18_rhl/RhE',
            simple_logo: '18_rhl/RhE.alt',
            coordinates: 'I10',
            city: 0,
            abilities: [
              {
                type: 'base',
                description: 'Special par/float rules',
                desc_detail: "When the president's share is acquired (via private No. 6) three 10% shares are moved "\
                             'from IPO to the Market, and the initial par value of the 3 shares will be paid to '\
                             "RhE's treasury as soon as there is a track link from Köln to Aachen via Düren. RhE "\
                             'floats directly, and the starting treasury is the winning bid for private 6. Note! '\
                             'RhE can only be parred at 70, 75, or 80.',
              },
            ],
            always_market_price: true,
            max_ownership_percent: 100,
          },
        ].freeze

        COMPANIES = [
          {
            sym: 'PWB',
            name: 'No. 1 Prinz Wilhelm-Bahn',
            value: 20,
            revenue: 5,
            desc: 'Blocks Hex E14. As director of a corporation the owner may place the first tile on this hex. '\
                  'An upgrade follows the normal track building rules. If there is still no tile on hex E14 after the '\
                  'purchase of the first 5 train, the blocking by the PWB ends.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[E14] }],
          },
          {
            sym: 'ATB',
            name: 'No. 1 Angertalbahn',
            value: 20,
            revenue: 5,
            desc: 'When acting as a director of a corporation the owner may place a tile on hex E12 for free during '\
                  'the green phase. The placement of this tile is in addition to the normal tile placement of the '\
                  'corporation. However the corporation needs an unblocked track link from one of its stations to '\
                  'the hex E12. This action closes the "Angertalbahn".',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[E12] },
                        {
                          type: 'tile_lay',
                          owner_type: 'player',
                          hexes: %w[E12],
                          tiles: %w[1 2 55 56 69],
                          free: true,
                          reachable: true,
                          special: true,
                          count: 1,
                          when: %w[owning_player_or_turn],
                          consume_tile_lay: false,
                          closed_when_used_up: true,
                        }],
          },
          {
            sym: 'KEO',
            name: 'No. 2 Konzession Essen-Osterath',
            value: 30,
            revenue: 0,
            desc: 'With the beginning of the green phase this special function can be used. As director of a '\
                  'corporation the owner may lay the orange tile #935 on hex E8 regardless whether there is a tile '\
                  'on that hex or not. Directly after this tile placement the operating corporation may directly '\
                  'place a station token for free on that hex (the cheapest available token will be used. '\
                  "This tile placement of is in addition to corporation's normal tile lay. There need not be a link "\
                  "to the corporation's network. If the token is placed as part of this ability no further tile "\
                  'lays or upgrades are allowed in this turn. After the purchase of the first 5-train the #935 tile '\
                  'may no longer be laid.',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                tiles: %w[935],
                hexes: %w[E8],
                count: 1,
                when: %w[owning_player_or_turn],
                free_tile_lay: true,
              },
            ],
          },
          {
            sym: 'Szl',
            name: 'No. 3 Seilzuganlage',
            value: 50,
            revenue: 15,
            desc: 'As director of a corporation the owner may place a tile on a mountain hex for free during the '\
                  "corporation's track building phase. This tile placement is in addition to the corporation's normal "\
                  "tile lay and there need not be a link to the corporation's network. This function can only be used "\
                  'once during the game.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'player',
                hexes: %w[D13 E12 E14 F11 F13 G12 G14 H13 I12 I14 J13 K2 K12],
                tiles: %w[1 2 3 4 5 6 7 8 9 23 24 25 30 55 56 57 58 69 930 934 937],
                free: true,
                reachable: false,
                count: 1,
                when: %w[owning_player_or_turn],
                consume_tile_lay: false,
              },
            ],
          },
          {
            sym: 'Tjt',
            name: 'No. 4 Trajektanstalt',
            value: 80,
            revenue: 20,
            desc: 'As director of a corporation the owner may upgrade *one* of the yellow hexes of '\
                  'Köln / Düsseldorf / Duisburg for free. This tile placement is in addition to the '\
                  "corporation's normal tile lay. The corporation may place a station token there in the same OR "\
                  "by paying the appropriate costs. There need not be a link to the corporation's network. "\
                  'If the token is placed as part of this ability no further tile lays or upgrades are '\
                  'allowed in this turn. Note! Token can only be used together with the upgrade to green '\
                  'and not as a token-only action. If no applicable hexes are yellow the special ability '\
                  'is no longer usable.',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                tiles: %w[X921 X922 X923 X924 X925 X926],
                hexes: %w[D9 F9 I10],
                count: 1,
                when: %w[owning_player_or_turn],
                free_tile_lay: true,
              },
            ],
          },
          {
            sym: 'NLK',
            name: 'No. 5 Niederrheinische Licht- und Kraftwerke',
            value: 120,
            revenue: 25,
            abilities: [{ type: 'shares', shares: 'GVE_1' },
                        # block_partition has no effect, except it makes it possible to show Rhine in hex D9, F9 and I10
                        # (the three Rhine Metropolis hexes). When upgrading these hexes to green the partition is removed.
                        {
                          type: 'blocks_partition',
                          partition_type: 'water',
                        }],
            desc: 'The player who purchased the Niederrheinische Licht- und Kraftwerke immediately receives a 10% '\
                  'share of the GVE for free. In order to float the GVE only 40% of the GVE needs to be sold from the '\
                  'Initial Offering.',
          },
          {
            sym: 'RhE',
            name: "No. 6 Director's Certificate of Rheinischen Eisenbahngesellschaft",
            value: 140,
            revenue: 0,
            abilities: [
              { type: 'shares', shares: 'RhE_0' },
              { type: 'close', when: 'par', corporation: 'RhE' },
            ],
            desc: 'The player who purchased this must immediately set the par value for the RhE. The par '\
                  'can only be 70M, 75M or 80M. The money RhE receives for the presidency will be the winning '\
                  'bid. Three 10% shares of the RhE will be placed in the Bank Pool. The Bank will delay paying '\
                  'the par value of these three 10% shares to the RhE treasury until there is a track link from '\
                  'Köln to Aachen via Düren (cannot be blocked by non-RhE station tokens).',
          },
        ].freeze

        def cce
          @cce_corporation ||= corporation_by_id('CCE')
        end

        def keg
          @keg_corporation ||= corporation_by_id('KEG')
        end

        def rhe
          @rhe_corporation ||= corporation_by_id('RhE')
        end

        def prinz_wilhelm_bahn
          return if optional_ratingen_variant

          @prinz_wilhelm_bahn ||= company_by_id('PWB')
        end

        def angertalbahn
          return unless optional_ratingen_variant

          @angertalbahn ||= company_by_id('ATB')
        end

        def konzession_essen_osterath
          @konzession_essen_osterath ||= company_by_id('KEO')
        end

        def seilzuganlage
          @seilzuganlage ||= company_by_id('Szl')
        end

        def trajektanstalt
          @trajektanstalt ||= company_by_id('Tjt')
        end

        def rhe_company
          @rhe_company ||= company_by_id('RhE')
        end

        def game_companies
          # Private 1 is different in base game and in Ratingen Variant
          all = self.class::COMPANIES
          return all.reject { |c| c[:sym] == 'ATB' } unless optional_ratingen_variant

          all.reject { |c| c[:sym] == 'PWB' }
        end
      end
    end
  end
end
