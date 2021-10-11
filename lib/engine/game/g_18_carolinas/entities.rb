# frozen_string_literal: true

module Engine
  module Game
    module G18Carolinas
      module Entities
        COMPANIES = [
          {
            name: 'South Carolina Canal and Rail Road Company',
            value: 30,
            revenue: 5,
            desc: 'Sell to the bank for $30 less than face value.',
            sym: 'SCCRR',
            abilities: [],
          },
          {
            name: 'Halifax & Weldon Railroad',
            value: 75,
            revenue: 12,
            desc: 'Sell to the bank for $30 less than face value.',
            sym: 'HWR',
            abilities: [],
          },
          {
            name: 'Louisville, Cincinnati, and Charleston Railroad',
            value: 130,
            revenue: 20,
            desc: 'Sell to the bank for $30 less than face value.',
            sym: 'LCCR',
            abilities: [],
          },
          {
            name: 'Wilmington and Raleigh Railroad',
            value: 210,
            revenue: 30,
            desc: 'Sell to the bank for $30 less than face value.',
            sym: 'WRR',
            abilities: [],
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            max_ownership_percent: 100,
            sym: 'NCR',
            name: 'North Carolina Railroad',
            logo: '18_carolinas/NCR',
            tokens: [
              0,
              40,
            ],
            coordinates: 'C13',
            color: 'red',
          },
          {
            float_percent: 60,
            max_ownership_percent: 100,
            sym: 'WM',
            name: 'Wilmington and Manchester Railroad',
            logo: '18_carolinas/WM',
            tokens: [
              0,
              40,
            ],
            coordinates: 'G19',
            city: 0,
            color: 'deepPink',
          },
          {
            float_percent: 60,
            max_ownership_percent: 100,
            sym: 'WNC',
            name: 'Western North Carolina Railroad',
            logo: '18_carolinas/WNC',
            tokens: [
              0,
              40,
            ],
            coordinates: 'D10',
            city: 1,
            color: 'orange',
          },
          {
            float_percent: 60,
            max_ownership_percent: 100,
            sym: 'SR',
            name: 'Southern Railway',
            logo: '18_carolinas/SR',
            tokens: [
              0,
              40,
            ],
            coordinates: 'J12',
            color: 'green',
          },
          {
            float_percent: 60,
            max_ownership_percent: 100,
            sym: 'WW',
            name: 'Wilmington and Weldon Railroad',
            logo: '18_carolinas/WW',
            tokens: [
              0,
              40,
            ],
            coordinates: 'G19',
            city: 1,
            color: 'yellow',
            text_color: 'black',
          },
          {
            float_percent: 60,
            max_ownership_percent: 100,
            sym: 'CSC',
            name: 'Charlotte and South Carolina Railroad',
            logo: '18_carolinas/CSC',
            tokens: [
              0,
              40,
            ],
            coordinates: 'D10',
            city: 0,
            color: 'black',
          },
          {
            float_percent: 60,
            max_ownership_percent: 100,
            sym: 'SEA',
            name: 'Seaboard and Roanoke Railroad',
            logo: '18_carolinas/SEA',
            tokens: [
              0,
              40,
            ],
            coordinates: 'B20',
            color: 'DeepSkyBlue',
            text_color: 'black',
          },
          {
            float_percent: 60,
            max_ownership_percent: 100,
            sym: 'CAR',
            name: 'Columbia and Augusta Railroad',
            logo: '18_carolinas/CAR',
            tokens: [
              0,
              40,
            ],
            coordinates: 'G9',
            color: 'DarkBlue',
          },
        ].freeze
      end
    end
  end
end
