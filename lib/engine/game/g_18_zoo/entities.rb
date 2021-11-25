# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module SharedEntities
        COMPANIES = [
          {
            sym: 'DAYS_OFF',
            name: 'Days off',
            value: 3,
            desc: 'During the SR you can choose a family (company), and its reputation mark (share value) increases!'\
                  ' It goes one space to the right',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: 'MIDAS',
            name: 'Midas',
            value: 2,
            desc: 'During the SR you can take the priority: when priority is assigned by “more money” criteria,'\
                  ' you are assigned 1st spot',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: 'TOO_MUCH_RESPONSIBILITY',
            name: 'Too much responsibility',
            value: 1,
            desc: 'Player immediately gets 3$N',
            abilities: [{ type: 'no_buy', owner_type: 'player' },
                        { type: 'description', description: 'Get 3$N', when: 'any' }],
          },
          {
            sym: 'LEPRECHAUN_POT_OF_GOLD',
            name: 'Leprechaun pot of gold',
            value: 2,
            desc: 'Player earns 2$N now, and 2$N at the start of each SR',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: 'IT_S_ALL_GREEK_TO_ME',
            name: 'It’s all greek to me',
            value: 2,
            desc: 'After your turn in an SR, you get another turn - it means you can play twice in a row in a SR:'\
                  ' “who said you can steal a company?”',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: 'WHATSUP',
            name: 'Whatsup',
            value: 3,
            desc: 'During the SR, a family (company) can buy the first available squirrel (train), deactivated.'\
                  ' Reputation (share value) moves one space to the right',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
          },
          {
            sym: 'RABBITS',
            name: 'Rabbits',
            value: 3,
            desc: 'The family (company) gets two bonus upgrades, that can be placed even illegally'\
                  ' (mountains and water pool) or before the correct phase',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                closed_when_used_up: true,
                connect: false,
                count: 2,
                special: true,
                reachable: true,
                must_lay_together: false,
                when: 'owning_corp_or_turn',
                tiles: [],
                hexes: [],
              },
            ],
          },
          {
            sym: 'MOLES',
            name: 'Moles',
            value: 2,
            desc: 'The family (company) gets 4 special tiles, that can be used to upgrade any plain tiles,'\
                  ' even illegally (mountains and water pool)',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                closed_when_used_up: true,
                connect: false,
                count: 4,
                special: true,
                reachable: true,
                must_lay_together: false,
                when: 'owning_corp_or_turn',
                tiles: %w[80 X80 81 X81 82 X82 83 X83],
                hexes: [],
              },
            ],
          },
          {
            sym: 'ANCIENT_MAPS',
            name: 'Ancient maps',
            value: 2,
            desc: 'The family (company) can build two additional yellow tiles',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                closed_when_used_up: true,
                connect: false,
                count: 2,
                special: false,
                reachable: true,
                must_lay_together: true,
                when: 'owning_corp_or_turn',
                tiles: %w[7 X7 8 X8 9 X9 5 6 57 201 202 621],
                hexes: [],
              },
            ],
          },
          {
            sym: 'HOLE',
            name: 'Hole',
            value: 2,
            desc: 'Mark two offmap R areas anywhere on the map, and from now on they are connected to run through',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                count: 2,
                hexes: [],
                owner_type: 'corporation',
              },
            ],
          },
          {
            sym: 'ON_A_DIET',
            name: 'On a diet',
            value: 1,
            desc: 'The family (company) can place a station in addition to the allowed spaces'\
                  ' - no one can block you out',
            abilities: [
              {
                type: 'token',
                owner_type: 'corporation',
                price: 0,
                extra_slot: true,
                from_owner: true,
                when: 'owning_corp_or_turn',
                special_only: true,
                hexes: [],
              },
            ],
          },
          {
            sym: 'SHINING_GOLD',
            name: 'Shining gold',
            value: 1,
            desc: 'The family (company) gets 2$N / 1$N when it builds on a M / MM tile',
            abilities: [
              {
                type: 'tile_discount',
                discount: 2,
                owner_type: 'corporation',
              },
              {
                type: 'tile_income',
                income: 1,
                terrain: 'mountain',
                owner_type: 'corporation',
                owner_only: true,
              },
              {
                type: 'tile_income',
                income: 2,
                terrain: 'hill',
                owner_type: 'corporation',
                owner_only: true,
              },
            ],
          },
          {
            sym: 'THAT_S_MINE',
            name: "That's mine!",
            value: 2,
            desc: 'The family (company) reserves an open place on a station tile anywhere'\
                  ' (irrespective of connectivity) - it is reserved and open for all to run through,'\
                  ' until the family puts a token there',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: [],
                owner_type: 'corporation',
              },
            ],
          },
          {
            sym: 'WORK_IN_PROGRESS',
            name: 'Work in progress',
            value: 2,
            desc: 'The family (company) blocks a free place on a station tile anywhere'\
                  ' (irrespective of connectivity)',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: [],
                owner_type: 'corporation',
              },
            ],
          },
          {
            sym: 'WHEAT',
            name: 'Wheat',
            value: 2,
            desc: 'The family (company) chooses a tile with its own station; the station is worth +30',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: [],
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                owner_type: 'corporation',
              },
            ],
          },
          {
            sym: 'TWO_BARRELS',
            name: 'Two barrels',
            value: 2,
            desc: 'The family (company) can use this power on two separate occasions to double the value of all'\
                  ' O tiles – but the downside is that family doesn\'t collect in treasury the usual 1$N for each O',
            abilities: [
              {
                type: 'description',
                description: 'Double O tiles',
                owner_type: 'corporation',
                count: 2,
                when: 'route',
                count_per_or: 1,
              },
            ],
          },
          {
            sym: 'A_SQUEEZE',
            name: 'A squeeze',
            value: 3,
            desc: 'The family (company) gets an additional 3$N if at least one of its squirrels (train)'\
                  ' runs through or to a O',
          },
          {
            sym: 'PATCH',
            name: 'Patch',
            value: 2,
            desc: 'Save from rust: at the phase change the player or the family can choose to mark a squirrel'\
                  ' (train) so that it won\'t rust; it becomes, and run as, a 1S. The 1S cannot be sold.'\
                  ' The PATCH on 1S can be discarded anytime. If the PATCH stays on, the family (company)'\
                  ' cannot purchase new squirrels (trains)',
          },
          {
            sym: 'WINGS',
            name: 'Wings',
            value: 2,
            desc: 'During the run, a squirrel (train) can skip one tokened-out station',
            abilities: [
              {
                type: 'assign_corporation',
                when: 'sold',
                owner_type: 'corporation',
              },
            ],
          },
          {
            sym: 'A_TIP_OF_SUGAR',
            name: 'A tip of sugar',
            value: 2,
            desc: 'A squirrel (train) will run one more stop - it doesn\'t work with 4J or 2J',
          },
        ].freeze

        ALL_CORPORATIONS = [
          {
            sym: 'CR',
            float_percent: 20,
            name: '(H1) CROCODILES',
            logo: '18_zoo/crocodile',
            shares: [40, 20, 20, 20, 20],
            max_ownership_percent: 120,
            always_market_price: true,
            tokens: [0, 2, 4, 4],
            color: '#00af14',
          },
          {
            sym: 'GI',
            float_percent: 20,
            name: '(H2) GIRAFFES',
            logo: '18_zoo/giraffe',
            shares: [40, 20, 20, 20, 20],
            max_ownership_percent: 120,
            always_market_price: true,
            tokens: [0, 2],
            color: '#fff793',
            text_color: 'black',
          },
          {
            sym: 'PB',
            float_percent: 20,
            name: '(H3) POLAR BEARS',
            logo: '18_zoo/polar-bear',
            shares: [40, 20, 20, 20, 20],
            max_ownership_percent: 120,
            always_market_price: true,
            tokens: [0, 2, 4, 4],
            color: '#efebeb',
            text_color: 'black',
          },
          {
            sym: 'PE',
            float_percent: 20,
            name: '(H4) PENGUINS',
            logo: '18_zoo/penguin',
            shares: [40, 20, 20, 20, 20],
            max_ownership_percent: 120,
            always_market_price: true,
            tokens: [0, 2, 4, 4],
            color: '#55b7b7',
            text_color: 'black',
          },
          {
            sym: 'LI',
            float_percent: 20,
            name: '(H5) LIONS',
            logo: '18_zoo/lion',
            shares: [40, 20, 20, 20, 20],
            max_ownership_percent: 120,
            always_market_price: true,
            tokens: [0, 2, 4],
            color: '#df251a',
          },
          {
            sym: 'TI',
            float_percent: 20,
            name: '(H6) TIGERS',
            logo: '18_zoo/tiger',
            shares: [40, 20, 20, 20, 20],
            max_ownership_percent: 120,
            always_market_price: true,
            tokens: [0, 2],
            color: '#ffa023',
            text_color: 'black',
          },
          {
            sym: 'BB',
            float_percent: 20,
            name: '(H7) BROWN BEAR',
            logo: '18_zoo/brown-bear',
            shares: [40, 20, 20, 20, 20],
            max_ownership_percent: 120,
            always_market_price: true,
            tokens: [0, 2, 4],
            color: '#ae6d1d',
          },
          {
            sym: 'EL',
            float_percent: 20,
            name: '(H8) ELEPHANT',
            logo: '18_zoo/elephant',
            shares: [40, 20, 20, 20, 20],
            max_ownership_percent: 120,
            always_market_price: true,
            tokens: [0, 2, 4],
            color: '#858585',
          },
        ].freeze

        def game_corporation_coordinates
          self.class::CORPORATION_COORDINATES
        end
      end

      module Entities
        include G18ZOO::SharedEntities
      end
    end

    module G18ZOOMapA
      module Entities
        include G18ZOO::SharedEntities
        CORPORATIONS = ALL_CORPORATIONS.select { |corporation| %w[GI PB PE LI TI].include?(corporation[:sym]) }.freeze

        CORPORATION_COORDINATES = { 'GI' => 'K9', 'PB' => 'N10', 'PE' => 'K17', 'LI' => 'E15', 'TI' => 'H14' }.freeze
      end
    end

    module G18ZOOMapB
      module Entities
        include G18ZOO::SharedEntities
        CORPORATIONS = ALL_CORPORATIONS.select { |corporation| %w[CR GI PB PE BB].include?(corporation[:sym]) }.freeze

        CORPORATION_COORDINATES = { 'CR' => 'H3', 'GI' => 'K10', 'PB' => 'N11', 'PE' => 'K18', 'BB' => 'I6' }.freeze
      end
    end

    module G18ZOOMapC
      module Entities
        include G18ZOO::SharedEntities
        CORPORATIONS = ALL_CORPORATIONS.select { |corporation| %w[CR LI TI BB EL].include?(corporation[:sym]) }.freeze

        CORPORATION_COORDINATES = { 'CR' => 'I3', 'LI' => 'F16', 'TI' => 'I15', 'BB' => 'J6', 'EL' => 'E5' }.freeze
      end
    end

    module G18ZOOMapD
      module Entities
        include G18ZOO::SharedEntities
        CORPORATIONS = ALL_CORPORATIONS.select do |corporation|
          %w[CR GI PB PE LI TI BB].include?(corporation[:sym])
        end.freeze

        CORPORATION_COORDINATES = {
          'CR' => 'H3',
          'GI' => 'K10',
          'PB' => 'N11',
          'PE' => 'K18',
          'LI' => 'E16',
          'TI' => 'H15',
          'BB' => 'I6',
        }.freeze
      end
    end

    module G18ZOOMapE
      module Entities
        include G18ZOO::SharedEntities
        CORPORATIONS = ALL_CORPORATIONS.select do |corporation|
          %w[CR GI PB PE TI BB EL].include?(corporation[:sym])
        end.freeze

        CORPORATION_COORDINATES = {
          'CR' => 'H3',
          'GI' => 'K10',
          'PB' => 'N11',
          'PE' => 'K18',
          'TI' => 'H15',
          'BB' => 'I6',
          'EL' => 'D5',
        }.freeze
      end
    end

    module G18ZOOMapF
      module Entities
        include G18ZOO::SharedEntities
        CORPORATIONS = ALL_CORPORATIONS.select do |corporation|
          %w[CR GI PE LI TI BB EL].include?(corporation[:sym])
        end.freeze

        CORPORATION_COORDINATES = {
          'CR' => 'I3',
          'GI' => 'L10',
          'PE' => 'L18',
          'LI' => 'F16',
          'TI' => 'I15',
          'BB' => 'J6',
          'EL' => 'E5',
        }.freeze
      end
    end
  end
end
