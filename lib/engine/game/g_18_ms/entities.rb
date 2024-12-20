# frozen_string_literal: true

module Engine
  module Game
    module G18MS
      module Entities
        COMPANIES = [
          {
            name: 'Alabama Great Southern Railroad',
            value: 30,
            revenue: 15,
            desc: 'The owning Major Corporation may lay an extra yellow tile for free. '\
                  'This extra tile must extend existing track and could be used to extend from a yellow or green tile '\
                  "played as a Major Corporation's normal tile lay. This ability can only be used once, and using it "\
                  'does not close the Private Company. Alabama Great Southern Railroad can be bought for exactly face '\
                  'value during OR 1 by an operating Major Corporation if the president owns the Private Company.',
            sym: 'AGS',
            abilities: [
            {
              type: 'tile_lay',
              owner_type: 'corporation',
              count: 1,
              free: true,
              special: false,
              reachable: true,
              hexes: [],
              tiles: [],
              when: %w[track owning_corp_or_turn],
            },
          ],
          },
          {
            name: 'Birmingham Southern Railroad',
            value: 40,
            revenue: 10,
            desc: 'The owning Major Corporation may lay one or two extra yellow tiles for free. This extra tile lay '\
                  'must extend existing track and could be used to extend from a yellow or green tile played as a '\
                  "corporation's normal tile lay. This ability can only be used once during a single operating round, and"\
                  ' using it does not close the Private Company. Birmingham Southern Railroad can be bought for exactly '\
                  'face value during OR 1 by an operating Major Corporation if the president owns the Private Company.',
            sym: 'BS',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                count: 2,
                use_across_ors: false,
                free: true,
                special: false,
                reachable: true,
                must_lay_together: false,
                hexes: [],
                tiles: [],
                when: 'track',
              },
            ],
          },
          {
            name: 'Meridian and Memphis Railway',
            value: 50,
            revenue: 15,
            desc: 'The owning Major Corporation may lay their cheapest available token for half price. '\
                  'This is not an extra token placement. This ability can only be used once, '\
                  'and using it does not close the Private Company.',
            sym: 'M&M',
            abilities: [
              {
                type: 'token',
                owner_type: 'corporation',
                when: 'token',
                hexes: [],
                discount: 0.5,
                count: 1,
                from_owner: true,
              },
            ],
          },
          {
            name: 'Mississippi Central Railway',
            value: 60,
            revenue: 5,
            desc: 'The owning Major Corporation exchanges this private for a special 2+ train when purchased. '\
                  '(This 2+ train may not be sold.) This exchange occurs immediately when purchased. '\
                  'If this exchange would place the Major Corporation over the train limit of 3, '\
                  'the purchase is not allowed. If this Private Company is not purchased by the end of OR 4, '\
                  "it may not be sold to a Major Corporation and counts against the owner's certificate limit until "\
                  'it closes upon the start of Phase 6.',
            sym: 'MC',
          },
          {
            name: 'Mobile & Ohio Railway',
            value: 70,
            revenue: 5,
            desc: 'The owning Major Corporation may purchase an available 3+ Train or 4+ Train from the bank for a '\
                  'discount of $100. Using this discount closes this Private Company. The discounted purchase is subject '\
                  'to the normal rules governing train purchases - only during the train-buying step and train limits '\
                  'apply.',
            sym: 'M&O',
            abilities: [
              {
                type: 'train_discount',
                discount: 100,
                owner_type: 'corporation',
                trains: ['3+', '4+'],
                count: 1,
                closed_when_used_up: true,
                when: 'buy_train',
              },
            ],
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            max_ownership_percent: 70,
            sym: 'GMO',
            name: 'Gulf, Mobile and Ohio Railroad',
            logo: '18_ms/GMO',
            simple_logo: '18_ms/GMO.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'H6',
            color: 'black',
          },
          {
            float_percent: 60,
            max_ownership_percent: 70,
            sym: 'IC',
            name: 'Illinois Central Railroad',
            logo: '18_ms/IC',
            simple_logo: '18_ms/IC.alt',
            tokens: [0, 40, 100],
            coordinates: 'A1',
            color: '#397641',
          },
          {
            float_percent: 60,
            max_ownership_percent: 70,
            sym: 'L&N',
            name: 'Louisville and Nashville Railroad',
            logo: '18_ms/LN',
            simple_logo: '18_ms/LN.alt',
            tokens: [0, 40, 100],
            coordinates: 'C9',
            color: '#0d5ba5',
          },
          {
            float_percent: 60,
            max_ownership_percent: 70,
            sym: 'Fr',
            name: 'Frisco',
            logo: '18_ms/Fr',
            simple_logo: '18_ms/Fr.alt',
            tokens: [0, 40, 100],
            coordinates: 'E1',
            color: '#ed1c24',
          },
          {
            float_percent: 60,
            max_ownership_percent: 70,
            sym: 'WRA',
            name: 'Western Railway of Alabama',
            logo: '18_ms/WRA',
            simple_logo: '18_ms/WRA.alt',
            tokens: [0, 40, 100],
            coordinates: 'E11',
            color: '#c7c4e2',
            text_color: 'black',
          },
        ].freeze
      end
    end
  end
end
