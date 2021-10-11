# frozen_string_literal: true

module Engine
  module Game
    module G1868WY
      module Entities
        CORPORATION_RESERVATION_COLOR = '#c6e9af'

        COMPANY_CHOICES = {
          'P3' => %w[P3a P3b P3c],
          'P5' => %w[P5a P5b P5c],
          'P6' => %w[P6a P6b P6c],
        }.freeze

        def self.def_corporation(**kwargs)
          {
            float_percent: 20,
            tokens: [0, 40, 60, 80],
            always_market_price: true,
            logo: "1868_wy/#{kwargs[:sym]}",
            simple_logo: "1868_wy/#{kwargs[:sym]}.alt",
            reservation_color: CORPORATION_RESERVATION_COLOR,
          }.merge(kwargs).freeze
        end

        CORPORATIONS = [
          def_corporation(
            sym: 'BH',
            name: 'Bighorn Railroad Company',
            coordinates: 'C11',
            color: '#000000',
          ),
          def_corporation(
            sym: 'C&N',
            name: 'Cheyenne & Northern Railway',
            coordinates: 'D22',
            color: '#c00000',
          ),
          def_corporation(
            sym: 'CC',
            name: 'Carbon Cutoff Railway',
            coordinates: 'N2',
            color: '#9A9A9D',
            text_color: 'black',
          ),
          def_corporation(
            sym: 'DPR',
            name: 'Denver Pacific Railway and Telegraph Company',
            coordinates: '',
            color: '#4D2674',
          ),
          def_corporation(
            sym: 'FEMV',
            name: 'Fremont, Elkhorn & Missouri Valley Railroad',
            coordinates: 'I33',
            color: '#5E0000',
          ),
          def_corporation(
            sym: 'LNP',
            name: 'Laramie, North Park and Pacific Railroad and Telegraph Company',
            coordinates: 'O25',
            color: '#FFC425',
            text_color: 'black',
          ),
          def_corporation(
            sym: 'OSL',
            name: 'Oregon Short Line Railroad',
            coordinates: 'L8',
            color: '#492F24',
          ),
          def_corporation(
            sym: 'RCL',
            name: 'Rapid City, Black Hills & Western Railroad Company',
            coordinates: 'D34',
            color: '#FFFFFF',
            text_color: 'black',
          ),
          def_corporation(
            sym: 'UP',
            name: 'Union Pacific Railroad',
            coordinates: 'O29',
            color: '#006D9C',
          ),
          def_corporation(
            sym: 'WNW',
            name: 'Wyoming & North Western Railway',
            coordinates: 'I11',
            color: '#004D95',
          ),
          def_corporation(
            sym: 'WYC',
            name: 'Wyoming Central Railway',
            coordinates: 'I23',
            color: '#f58121',
          ),
        ].freeze

        COMPANIES = [
          {
            name: 'P1 Hell on Wheels',
            sym: 'P1',
            value: 40,
            revenue: 10,
            abilities: [{ type: 'close', on_phase: '5' }],
            desc: 'Closes at phase 5.',
          },
          {
            name: 'P2 Wylie Permanent Camping Company',
            sym: 'P2',
            value: 45,
            revenue: 10,
            abilities: [{ type: 'close', on_phase: '5' },
                        { type: 'revenue_change', revenue: 0, when: 'sold' }],
            desc: 'Provides its owning Railroad Company a +$10 revenue bonus for routes '\
                  'starting or ending at either of the accessible Yellowstone entrances. '\
                  'Closes at phase 5.',
          },
          {
            name: 'P3 Surveyor A',
            sym: 'P3',
            value: 60,
            revenue: 10,
            desc: 'Buyer or auction winner chooses one of Henry Gannett, James Evans, or '\
                  'John A. Rawlins',
          },
          {
            name: 'P3a Henry Gannett',
            sym: 'P3a',
            value: 60,
            revenue: 10,
            abilities: [{ type: 'close', on_phase: '5' },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          must_lay_together: true,
                          hexes: [],
                          tiles: [],
                          when: 'track',
                          count: 2,
                          closed_when_used_up: true,
                        }],
            desc: 'Allows placement of up to two yellow tiles ignoring terrain costs as '\
                  "a free action during the owning Railroad Company's tile laying phase. "\
                  'Closes on tile placement or at phase 5.',
          },
          {
            name: 'P3b James Evans',
            sym: 'P3b',
            value: 60,
            revenue: 10,
            abilities: [{ type: 'close', on_phase: '6' }],
            desc: 'Gives owning Railroad Company a $10 discount to terrain costs for each '\
                  'tile lay. Closes at phase 6.',
          },
          {
            name: 'P3c John A. Rawlins',
            sym: 'P3c',
            value: 60,
            revenue: 10,
            abilities: [{ type: 'close', on_phase: '6' }],
            desc: 'Gives owning Railroad Company a $40 discount to terrain costs for one '\
                  'tile lay per OR. Closes at phase 6.',
          },
          {
            name: 'P4 John C. Fiere',
            sym: 'P4',
            value: 60,
            revenue: 10,
            abilities: [{ type: 'close', on_phase: '4' }, { type: 'no_buy' }],
            desc: 'At the start of phase 4, the player owner of this private company '\
                  'immediately takes ownership of one Oil Company of their choice.  It '\
                  'may place its first Development Token in the following OR. No RR '\
                  'buy-in. Closes at phase 4.',
          },
          {
            name: 'P5 Developer',
            sym: 'P5',
            value: 70,
            revenue: 10,
            desc: 'Buyer or auction winner chooses one of Union Pacific Coal Company, '\
                  '"Buffalo Bill" Cody\'s Bonanza Oil District, or Frémont Expedition',
          },
          {
            name: 'P5a Union Pacific Coal Company',
            sym: 'P5a',
            value: 70,
            revenue: 10,
            abilities: [{ type: 'close', on_phase: '5' }, { type: 'no_buy' }],
            desc: 'The owner this private receives a black coal Development Token that '\
                  'it may place or move at any time in phases 2-4. Placement or movement '\
                  'only pays terrain costs. Closes at phase 5, removing DT from the game.',
          },
          {
            name: 'P5b "Buffalo Bill" Cody\'s Bonanza Oil District',
            sym: 'P5b',
            value: 70,
            revenue: 10,
            abilities: [{ type: 'close', on_phase: '8' }, { type: 'no_buy' }],
            desc: 'Comes with Oil DT usable in phase 4. Costs $0 to place and $0 '\
                  'maintenance. No RR buy-in. Closes at phase 8, removing DT from the game.',
          },
          {
            name: 'P5c Frémont Expedition',
            sym: 'P5c',
            value: 70,
            revenue: 10,
            abilities: [{ type: 'close', on_phase: '6' }, { type: 'no_buy' }],
            desc: 'Gives a $20 discount to terrain costs for each Development Token '\
                  'placement. No RR buy-in. Closes at phase 6.',
          },
          {
            name: 'P6 Surveyor B',
            sym: 'P6',
            value: 90,
            revenue: 15,
            desc: 'Buyer or auction winner chooses one of Grenville M. Dodge, Edward '\
                  'Gillette, or Frederick W. Lander',
          },
          {
            name: 'P6a Grenville M. Dodge',
            sym: 'P6a',
            value: 90,
            revenue: 15,
            abilities: [{ type: 'close', on_phase: '5' },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          must_lay_together: true,
                          hexes: [],
                          tiles: [],
                          when: 'track',
                          count: 3,
                          free: true,
                          closed_when_used_up: true,
                        }],
            desc: 'Allows placement of up to three yellow tiles ignoring terrain costs '\
                  "as a free action during the owning Railroad Company's tile laying "\
                  'phase. Closes on tile placement or at phase 5.',
          },
          {
            name: 'P6b Edward Gillette',
            sym: 'P6b',
            value: 90,
            revenue: 15,
            abilities: [{ type: 'close', on_phase: '6' },
                        {
                          type: 'tile_discount',
                          discount: 15,
                          terrain: 'mountain',
                          owner_type: 'corporation',
                        },
                        {
                          type: 'tile_discount',
                          discount: 15,
                          terrain: 'water',
                          owner_type: 'corporation',
                        },
                        {
                          type: 'tile_discount',
                          discount: 15,
                          terrain: 'cow_skull',
                          owner_type: 'corporation',
                        }],
            desc: 'Gives owning Railroad Company a $15 discount to terrain costs for '\
                  'each tile lay. Closes at phase 6.',
          },
          {
            name: 'P6c Frederick W. Lander',
            sym: 'P6c',
            value: 90,
            revenue: 15,
            abilities: [{ type: 'close', on_phase: '6' }],
            desc: 'Gives owning Railroad Company a $60 discount to terrain costs for one '\
                  'tile lay per OR. Closes at phase 6.',
          },
          {
            name: 'P7 John S. "General Jack" Casement',
            sym: 'P7',
            value: 90,
            revenue: 20,
            abilities: [{ type: 'close', on_phase: '6' }],
            desc: 'Grants owning Railroad Company one extra point for tile laying. This '\
                  'allows the additional option of laying two tiles plus one upgrade. '\
                  'Closes at phase 6.',
          },
          {
            name: 'P8 American Locomotive Corporation 4-8-8-4 "Big Boy" Wasatch Class Locomotive',
            sym: 'P8',
            value: 100,
            revenue: 20,
            abilities: [{ type: 'close', on_phase: '8' }],
            desc: 'Trains of the owning Railroad Company add $40 to any East-West route '\
                  'bonus collected. Closes at phase 8.',
          },
          {
            name: 'P9 The Pure Oil Camp',
            sym: 'P9',
            value: 120,
            revenue: 20,
            abilities: [{ type: 'close', on_phase: '7' }],
            desc: 'Comes with a Boomtown token that may be placed in an OR. Once it '\
                  'becomes a Boom City, it may be tokened, but only by the owning '\
                  'Railroad Company. Closes at phase 7, removing Boomtown or City, '\
                  'station token, and reverts tile.',
          },
          {
            name: "P10 Laramie, Hahn's Peak & Pacific Railway",
            sym: 'P10',
            value: 180,
            revenue: 20,
            abilities: [{ type: 'close', on_phase: '5' },
                        { type: 'revenue_change', revenue: 40, on_phase: '3' },
                        { type: 'revenue_change', revenue: 0, on_phase: '5' }],
            desc: 'Pays $20 revenue if all players consecutively pass on buying P11 '\
                  'during the ISR. Pays $40 revenue ONLY in green phases. Closes, becomes '\
                  'LHP train at phase 5.',
          },
          {
            name: 'P11 Thomas C. Durant',
            sym: 'P11',
            value: 220,
            revenue: 0,
            abilities: [{ type: 'shares', shares: 'UP_0' }],
            desc: "Owner receives the President's certificate of the Union Pacific "\
                  'Railroad, chooses its par value, and it receives 2× that amount. '\
                  'Closes at end of ISR.',
          },
          {
            name: 'P12 Oakes Ames and Oliver Ames, Jr.',
            sym: 'P12',
            value: 240,
            revenue: 30,
            abilities: [{ type: 'close', on_phase: '5' },
                        { type: 'no_buy' },
                        {
                          type: 'exchange',
                          corporations: ['UP'],
                          owner_type: 'player',
                          when: 'stock_round',
                          from: 'ipo',
                        }],
            desc: 'This private company may be exchanged for two shares of the Union '\
                  'Pacific Railroad as an action in a stock round. No RR Buy-in. Closes '\
                  'on share exchange or at phase 5.',
          },
        ].freeze
      end
    end
  end
end
