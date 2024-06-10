# frozen_string_literal: true

module Engine
  module Game
    module G1888
      module Entities
        # rubocop:disable Layout/LineLength
        COMPANIES = [
          {
            name: 'Kaiping Tramway',
            value: 25,
            revenue: 5,
            desc: 'No special ability',
            sym: 'KT',
          },
        ].freeze
        # rubocop:enable Layout/LineLength

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'JHR',
            name: 'Jingha Railway',
            logo: '1888/JHR',
            simple_logo: '1888/JHR.alt',
            tokens: [0, 40, 60],
            city: 1,
            color: '#C93A1E',
            text_color: 'white',
          },
        ].freeze
      end
    end
  end
end
