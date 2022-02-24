# frozen_string_literal: true

module Engine
  module Game
    module G18Dixie
      module Corporations
        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'ACL',
            name: 'Atlantic Coast Line',
            logo: '18_ga/ACL',
            simple_logo: '18_ga/ACL.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'M25',
            color: 'black',
          },
          {
            float_percent: 50,
            sym: 'CoG',
            name: 'Central of Georgia Railroad',
            logo: '18_ga/CoG',
            simple_logo: '18_ga/CoG.alt',
            tokens: [0, 40, 100],
            coordinates: 'I19',
            color: 'red',
          },
          {
            float_percent: 50,
            sym: 'Fr',
            name: 'Frisco',
            logo: '18_ms/Fr',
            simple_logo: '18_ms/Fr.alt',
            tokens: [0, 40, 100],
            coordinates: 'J2',
            color: '#ed1c24',
          },
          {
            float_percent: 50,
            sym: 'IC',
            name: 'Illinois Central Railroad',
            logo: '18_ms/IC',
            simple_logo: '18_ms/IC.alt',
            tokens: [0, 40],
            coordinates: 'D6',
            color: '#397641',
          },
          {
            float_percent: 50,
            sym: 'L&N',
            name: 'Louisville and Nashville Railroad',
            logo: '18_ms/LN',
            simple_logo: '18_ms/LN.alt',
            tokens: [0, 40],
            coordinates: 'A13',
            color: '#0d5ba5',
          },
          {
            float_percent: 50,
            sym: 'SAL',
            name: 'Seaboard Air Line',
            logo: '18_ga/SAL',
            simple_logo: '18_ga/SAL.alt',
            tokens: [0, 40, 100],
            coordinates: 'J26',
            color: 'gold',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'SR',
            name: 'Southern Railway',
            logo: '18_fl/SR',
            simple_logo: '18_fl/SR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'C17',
            city: 1,
            color: '#76a042',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'WRA',
            name: 'Western Railway of Alabama',
            logo: '18_ms/WRA',
            simple_logo: '18_ms/WRA.alt',
            tokens: [0, 40, 100],
            coordinates: 'J12',
            color: '#c7c4e2',
            text_color: 'black',
          },
          # Minors

        ].freeze
      end
    end
  end
end
