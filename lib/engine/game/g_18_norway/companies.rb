# frozen_string_literal: true

module Engine
  module Game
    module G18Norway
      module Companies
        COMPANIES = [
          {
            name: 'P1 Rørosbanen',
            sym: 'P1',
            value: 20,
            revenue: 5,
            desc: 'Blocks hex (J23) until bought by a public company, or when the first 5 train is bought, ' \
                  'which also closes the P1.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['J23'] }],
            color: nil,
          },
          {
            name: 'P2A Thunes mekaniske verksted',
            sym: 'P2A',
            value: 30,
            revenue: 10,
            desc: 'Public company owning P2A does not need to pay for snow on tracks. '\
                  'Closes when first 5 train is bought.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P2B Mjøsas hvite svane',
            sym: 'P2B',
            value: 30,
            revenue: 10,
            desc: 'Public company owning P2B does not need to pay for trafficing Mjøsa. '\
                  'Closes when first 5 train is bought.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P3A Sørumstand mekaniske verksted',
            sym: 'P3A',
            value: 40,
            revenue: 10,
            desc: 'Owner of P3A receive 10kr as additional payment from the bank each time '\
                  'a tunnel is built. Closes when first 5 train is bought.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P3B Ofotbanen',
            sym: 'P3B',
            value: 40,
            revenue: 10,
            desc: 'Owner of P3B only receive 10kr if first 3 train has been bought '\
                  'P3B never closes.',
            abilities: [
              { type: 'close', on_phase: 'never' },
            ],
            color: nil,
          },
          {
            name: 'P4A Mellemværftet',
            sym: 'P4A',
            value: 50,
            revenue: 10,
            desc: 'Owner of P4A receive 10kr as additional payment from the bank each time '\
                  'a ship is bought. Closes when first 5 train is bought.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P4B Bodø stasjon',
            sym: 'P4B',
            value: 50,
            revenue: 0,
            desc: 'Public company owning P4B gets an extra station in Bodø (L1) '\
                  'when P4B closes. Closes when first 5 train is bought.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P5 Carl Abraham Pihl',
            sym: 'P5',
            value: 70,
            revenue: 15,
            desc: 'Public company owning P5 may nationalize out of turn, i.e. ‘skipping the line’. '\
                  'Closes when first 5 train is bought.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P6 Peter Jebsen',
            sym: 'P6',
            value: 90,
            revenue: 15,
            desc: 'Accompanied by a 20 percent share in Bergensbanen (B). '\
                  'Par value is set when its president’s certificate is purchased, '\
                  'and B then floats immediately. Its company treasury receives funds for all three '\
                  'stocks when it floats. Closes when the first 5 train is bought.',
            abilities: [{ type: 'shares', shares: 'B_1' }],
            color: nil,
          },
          {
            name: 'P7 Robert Stephenson',
            sym: 'P7',
            value: 140,
            revenue: 20,
            desc: 'Accompanied by the 40 percent Hovedbanen’s (H) President Certificate. '\
                  'Set market value. The maximum value is equal to the winning bid divided by two rounded down. '\
                  'Gets selected value times two from bank. Closes when the first 3-train is bought',
            abilities: [{ type: 'shares', shares: 'H_0' },
                        { type: 'close', on_phase: '3' }],
            color: nil,
          },
        ].freeze
      end
    end
  end
end
