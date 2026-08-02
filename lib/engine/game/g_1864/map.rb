# frozen_string_literal: true

module Engine
  module Game
    module G1864
      module Map
        LAYOUT = :flat

        TILES = {
          '8' => 'unlimited',
          '9' => 'unlimited',
        }.freeze

        LOCATION_NAMES = {
          'B2' => 'Omaha',
        }.freeze

        HEXES = {
          white: {
            %w[B4] => '',
            %w[B2] => 'city=revenue:0',
          },
          gray: {
            %w[B6] => 'path=a:0,b:1',
          },
        }.freeze
      end
    end
  end
end
