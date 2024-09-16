# frozen_string_literal: true

module Engine
  module Game
    module G1826
      module Entities
        COMPANIES = [
          {
            name: 'Ponts et Chaussées',
            sym: 'P1',
            value: 20,
            revenue: 5,
            desc: 'Allows a corporation to lay a tile on a river hex free of charge as part of its normal tile placement.'\
                  " The river hex must be connected to the corporation's track. The tile laid is the corporation's one"\
                  ' tile placement for the turn. This closes the private company.',
            abilities: [
              {
                type: 'tile_discount',
                discount: 40,
                count: 1,
                terrain: 'water',
                owner_type: 'player',
              },
            ],
          },
          {
            name: 'Régie des Postes',
            sym: 'P2',
            value: 40,
            revenue: 10,
            desc: 'This company allows a Corporation to increase the value of a City by F10 for all its runs. Once chosen,'\
                  ' the corp and city cannot be changed. This closes the private company. Bonus is removed when the first E'\
                  ' train is purchased.',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_player_track',
                hexes: %w[B12 C11 C13 C15 E5 E15 F12 G9 G19 I1 I7 I13 K17 L14 M3 M13],
                count: 1,
                owner_type: 'player',
              },
              {
                type: 'assign_corporation',
                when: 'owning_player_track',
                count: 1,
                owner_type: 'player',
              },
            ],
            color: nil,
          },
          {
            name: "Chemin de Fer d'Algérie",
            sym: 'P3',
            value: 70,
            revenue: 15,
            desc: "May increase a corporation's train limit by 1. This closes the private company. This ability is removed "\
                  'when the first E train is purchased.',
            abilities: [{
              type: 'train_limit',
              increase: 1,
              count: 1,
              owner_type: 'player',
            }],
          },
          {
            name: 'Grand Central Belge',
            sym: 'P4',
            value: 110,
            revenue: 20,
            desc: 'The initial purchaser of the GCB immediately receives a 10% share of Belge stock without further'\
                  ' payment. This action does not close the GCB. The Belge corporation will not be running at this point,'\
                  ' but the stock may be retained or sold subject to the ordinary rules of the game.',
            abilities: [{ type: 'shares', shares: 'B_1' }],
            color: 'green',
          },
          {
            name: 'Compagnie Paris-Rouen',
            sym: 'P5',
            value: 160,
            revenue: 25,
            desc: "The owner of this private company immediately receives the President's certificate of the"\
                  ' CdF de Paris without further payment. Does not exchange hands if the owning player loses the presidency of'\
                  ' the CdF de Paris. Closes when the CdF de Paris purchases its first train.',
            abilities: [{ type: 'close', when: 'bought_train', corporation: 'Paris' },
                        { type: 'shares', shares: 'Paris_0' }],
            color: 'sand',
          },
          {
            name: 'Compagnie Paris-Rouen',
            sym: 'P5',
            value: 220,
            revenue: 30,
            desc: "The owner of this private company immediately receives the President's certificate of the CdF d'Alsace"\
                  ' without further payment. Does not exchange hands if the owning player loses the presidency of the'\
                  " CdF d'Alsace. Closes when the CdF d'Alsace purchases its first train.",
            abilities: [{ type: 'close', when: 'bought_train', corporation: 'Al' },
                        { type: 'shares', shares: 'Al_0' }],
            color: 'blue',
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'Paris',
            name: 'Chemin de Fer de Paris',
            logo: '1826/Paris',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20],
            coordinates: 'G9',
            city: 2,
            abilities: [{ type: 'blocks_hexes_consent', owner_type: 'player', hexes: ['F8'], hidden: true }],
            type: 'five_share',
            color: 'sand',
          },
          {
            float_percent: 50,
            sym: 'PO',
            name: 'Chemin de Fer de Paris-Orléans',
            logo: '1826/PO',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20],
            coordinates: 'G9',
            city: 0,
            type: 'five_share',
            abilities: [{ type: 'blocks_hexes_consent', owner_type: 'player', hexes: ['H8'], hidden: true }],
            color: '#lightishBlue',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'N',
            name: 'Chemin de Fer du Nord',
            logo: '1826/N',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20],
            coordinates: 'G9',
            city: 3,
            type: 'five_share',
            abilities: [{ type: 'blocks_hexes_consent', owner_type: 'player', hexes: ['F10'], hidden: true }],
            color: 'red',
          },
          {
            float_percent: 50,
            sym: 'Est',
            name: "Chemin de Fer de l'Est",
            logo: '1826/Est',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20],
            coordinates: 'G9',
            city: 4,
            type: 'five_share',
            abilities: [{ type: 'blocks_hexes_consent', owner_type: 'player', hexes: ['G11'], hidden: true }],
            color: 'orange',
          },
          {
            float_percent: 50,
            sym: 'O',
            name: "Chemin de Fer de l'Ouest",
            logo: '1846/O',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20],
            coordinates: 'G9',
            city: 1,
            type: 'five_share',
            abilities: [{ type: 'blocks_hexes_consent', owner_type: 'player', hexes: ['G7'], hidden: true }],
            color: 'pink',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'Midi',
            name: 'Chemin de Fer du Midi',
            logo: '1826/Midi',
            shares: [40, 20, 20, 20],
            tokens: [0, 20],
            coordinates: 'M3',
            city: 0,
            type: 'five_share',
            color: 'brightGreen',
          },
          {
            float_percent: 50,
            sym: 'GC',
            name: 'Grand Central de France',
            logo: '1826/GC',
            shares: [40, 20, 20, 20],
            tokens: [0, 20],
            coordinates: 'L14',
            type: 'five_share',
            color: 'lightBlue',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'PLM',
            name: 'Chemin de Fer Paris-Lyon-Méditerranée',
            logo: '1826/PLM',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20],
            coordinates: 'G9',
            city: 5,
            type: 'five_share',
            abilities: [{ type: 'blocks_hexes_consent', owner_type: 'player', hexes: ['H10'], hidden: true }],
            color: 'violet',
            text_color: 'black',
          },
          {
            float_percent: 50,
            sym: 'Al',
            name: "Chemin de Fer d'Alsace",
            logo: '1826/Al',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20],
            coordinates: 'G19',
            type: 'five_share',
            color: 'blue',
          },
          {
            float_percent: 50,
            sym: 'B',
            name: "Chemins de Fer de l'Etat Belge",
            logo: '1826/B',
            shares: [40, 20, 20, 20],
            tokens: [0, 20, 20],
            coordinates: 'C13',
            type: 'ten_share',
            color: 'green',
            abilities: [
              {
                type: 'blocks_hexes',
                owner_type: nil,
                hexes: %w[B10 B12 B14 C15 D12 D14 D16],
                remove: 'lay_tile',
              },
            ],
          },
          {
            float_percent: 50,
            sym: 'Etat',
            name: "Chemins de Fer de l'Etat",
            logo: '1826/Etat',
            tokens: [0, 20, 20, 20],
            type: 'ten_share',
            shares: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'black',
            abilities: [
              {
                type: 'train_buy',
                description: 'Inter-corporation train buy/sell at face value only',
                face_value: true,
              },
              {
                type: 'train_limit',
                increase: 1,
                description: '3 train limit',
              },
            ],
          },
          {
            float_percent: 60,
            sym: 'SNCF',
            name: 'Société Nationale des Chemins de Fer Français',
            logo: '1826/SNCF',
            tokens: [0, 20, 20, 20],
            type: 'ten_share',
            shares: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'gray',
          },
        ].freeze
      end
    end
  end
end
