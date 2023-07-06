# frozen_string_literal: true

module Engine
  module TestTiles
    # each entry is a Hash containing:
    # - tile / hex id
    # - game title (optional)
    # - fixture (optional, requires game title; if not given, the starting state
    #   of the hex/tile is used)
    # - action id (optional, requires fixture; if not given, the fixture is
    #   processed to its conclusion)
    # - other kwargs for View::Tiles#render_tile_blocks
    TEST_TILES_HUMAN_READABLE = [
      { tile: '45' },

      { tile: 'H11', title: '1822PNW' },
      { tile: 'O8', title: '1822PNW' },
      { tile: 'I12', title: '1822PNW' },

      # open: https://github.com/tobymao/18xx/issues/5981
      { tile: 'H22', title: '1828.Games' },

      # open: https://github.com/tobymao/18xx/issues/8178
      { tile: 'H18', title: '1830', fixture: '26855', action: 385 },

      { tile: 'C15', title: '1846' },

      # open: https://github.com/tobymao/18xx/issues/5167
      { tile: 'N11', title: '1856', fixture: 'hotseat005', action: 113 },

      { tile: 'L0', title: '1868 Wyoming' },
      { tile: 'WRC', title: '1868 Wyoming' },
      { tile: 'F12', title: '1868 Wyoming', fixture: '1868WY_5', action: 835 },
      { tile: 'L0', title: '1868 Wyoming', fixture: '1868WY_5', action: 835 },
      { tile: 'J12', title: '1868 Wyoming', fixture: '1868WY_5', action: 835 },
      { tile: 'J12', title: '1868 Wyoming', fixture: '1868WY_5' },

      # open: https://github.com/tobymao/18xx/issues/4992
      { tile: 'I11', title: '1882', fixture: '5236', action: 303 },

      # open: https://github.com/tobymao/18xx/issues/6604
      { tile: 'L41', title: '1888' },

      # open: https://github.com/tobymao/18xx/issues/5153
      { tile: 'IR7', title: '18Ireland' },
      { tile: 'IR8', title: '18Ireland' },

      # open: https://github.com/tobymao/18xx/issues/5673
      { tile: 'D19', title: '18Mag', fixture: 'hs_tfagolvf_76622' },
      { tile: 'I14', title: '18Mag', fixture: 'hs_tfagolvf_76622' },

      # open: https://github.com/tobymao/18xx/issues/7765
      { tile: '470', title: '18MEX' },
      { tile: '475', title: '18MEX' },
      { tile: '479P', title: '18MEX' },
      { tile: '485P', title: '18MEX' },
      { tile: '486P', title: '18MEX' },
    ].freeze

    # rearrange the above to a structure that can be more efficiently iterated
    # over--each fixture only needs to be fetched once, and only needs to be
    # processed to each unique action once
    #
    # defining with this structure directly would confusing to read; for generic
    # tiles, all of the keys in the nested Hash would end up as `nil`
    TEST_TILES =
      TEST_TILES_HUMAN_READABLE.each_with_object({}) do |opts, test_tiles|
        tile = opts.delete(:tile)
        title = opts.delete(:title)
        fixture = opts.delete(:fixture)
        action = opts.delete(:action)

        test_tiles[title] ||= {}
        test_tiles[title][fixture] ||= {}
        test_tiles[title][fixture][action] ||= []

        test_tiles[title][fixture][action] << [tile, opts]
      end.freeze
  end
end
