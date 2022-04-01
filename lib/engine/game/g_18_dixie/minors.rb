# frozen_string_literal: true

module Engine
  module Game
    module G18Dixie
      module Minors
        M1_SYM = ' 1'
        M2_SYM = ' 2'
        M3_SYM = ' 3'
        M4_SYM = ' 4'
        M5_SYM = ' 5'
        M6_SYM = ' 6'
        M7_SYM = ' 7'
        M8_SYM = ' 8'
        M9_SYM = ' 9'
        M10_SYM = '10'
        M11_SYM = '11'
        M12_SYM = '12'
        M13_SYM = '13'

        MINOR_EXCHANGE_OPTIONS = {
          M1_SYM => %w[SR],
          M2_SYM => %w[L&N SR],
          M3_SYM => %w[Fr],
          M4_SYM => %w[WRA],
          M5_SYM => %w[SAL],
          M6_SYM => %w[ACL],
          M7_SYM => %w[L&N],
          M8_SYM => %w[CoG],
          M9_SYM => %w[L&N],
          M10_SYM => %w[IC],
          M11_SYM => %w[IC],
          M12_SYM => %w[Fr CoG WRA],
          M13_SYM => %w[ACL CoG Fr IC L&N SAL SR WRA],
        }.freeze

        def minor_exchange_options(minor)
          MINOR_EXCHANGE_OPTIONS[minor.id]&.map { |c_id| corporation_by_id(c_id) }
        end

        MINORS = [
          {
            sym: ' 1',
            coordinates: 'K17',
            logo: '18_mag/1',
            simple_logo: '18_mag/1.alt',
            tokens: [0],
            shares: [100],
            name: 'Georgia & Florida Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR2.1* ▼',
                desc_detail: 'Is exchanged for a preferred share of SR, which gets the minor\'s token and treasury',
              },
            ],
            text_color: 'white',
          },
          {
            sym: ' 2',
            coordinates: 'C11',
            logo: '18_mag/2',
            simple_logo: '18_mag/2.alt',
            tokens: [0],
            shares: [100],
            name: 'Tennessee Central Railway',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR2.1* ▼',
                desc_detail: 'Is exchanged for a preferred share of L&N or SR, which gets the minor\'s token and treasury',
              },
            ],
            text_color: 'white',
          },
          {
            sym: ' 3',
            coordinates: 'J6',
            logo: '18_mag/3',
            simple_logo: '18_mag/3.alt',
            tokens: [0],
            shares: [100],
            name: 'Missisippi Central Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR2.1* ▼',
                desc_detail: 'Is exchanged for a preferred share of Frisco, which gets the minor\'s token and treasury',
              },
            ],
            text_color: 'white',
          },
          {
            sym: ' 4',
            coordinates: 'J10',
            logo: '18_mag/4',
            simple_logo: '18_mag/4.alt',
            tokens: [0],
            shares: [100],
            name: 'Alabama & Tenessee River Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR2.1* ▼',
                desc_detail: 'Is exchanged for a preferred share of WRA, which gets the minor\'s token and treasury',
              },
            ],
            text_color: 'white',
          },
          {
            sym: ' 5',
            coordinates: 'M17',
            logo: '18_mag/5',
            simple_logo: '18_mag/5.alt',
            tokens: [0],
            shares: [100],
            name: 'Tallahassee Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR2.2* ▼',
                desc_detail: 'Is exchanged for a preferred share of SAL, which gets the minor\'s token and treasury',
              },
            ],
            text_color: 'white',
          },
          {
            sym: ' 6',
            coordinates: 'H10',
            logo: '18_mag/6',
            simple_logo: '18_mag/6.alt',
            tokens: [0],
            shares: [100],
            name: 'Atlanta, Birmingham & Coast Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR2.2* ▼',
                desc_detail: 'Is exchanged for a preferred share of ACL, which gets the minor\'s token and treasury',
              },
            ],
            text_color: 'white',
          },
          {
            sym: ' 7',
            coordinates: 'G17',
            logo: '18_mag/7',
            simple_logo: '18_mag/7.alt',
            tokens: [0],
            shares: [100],
            name: 'Western & Atlantic Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR2.2* ▼',
                desc_detail: 'Is exchanged for a preferred share of L&B, which gets the minor\'s token and treasury',
              },
            ],
            text_color: 'white',
          },
          {
            sym: ' 8',
            coordinates: 'G23',
            logo: '18_mag/8',
            simple_logo: '18_mag/8.alt',
            tokens: [0],
            shares: [100],
            name: 'Georgia Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR2.2* ▼',
                desc_detail: 'Is exchanged for a preferred share of CoG, which gets the minor\'s token and treasury',
              },
            ],
            text_color: 'white',
          },
          {
            sym: ' 9',
            coordinates: %w[D12 E15],
            logo: '18_mag/9',
            simple_logo: '18_mag/9.alt',
            tokens: [0, 40],
            shares: [100],
            name: 'Nashville, Chattanooga & St. Louis Railway',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR3.1* ▼',
                desc_detail: 'Is exchanged for a preferred share of L&N, which gets the minor\'s token and treasury',
              },
              {
                type: 'description',
                description: 'Has a choice of starting location',
              },
            ],
            text_color: 'white',
          },
          {
            sym: '10',
            coordinates: 'E3',
            logo: '18_mag/10',
            simple_logo: '18_mag/10.alt',
            tokens: [0, 40],
            shares: [100],
            name: 'Gulf, Mobile & Ohio Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR3.1* ▼',
                desc_detail: 'Is exchanged for a preferred share of IC, which gets the minor\'s token and treasury',
              },
            ],
            text_color: 'white',
          },
          {
            sym: '11',
            coordinates: 'M7',
            logo: '18_mag/11',
            simple_logo: '18_mag/11.alt',
            tokens: [0, 40],
            shares: [100],
            name: 'Mobile & Ohio Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR3.1* ▼',
                desc_detail: 'Is exchanged for a preferred share of IC, which gets the minor\'s token and treasury',
              },
            ],
            text_color: 'white',
          },
          {
            sym: '12',
            coordinates: %w[F6 F14],
            logo: '18_mag/12',
            simple_logo: '18_mag/12.alt',
            tokens: [0, 40],
            shares: [100],
            name: 'Memphis & Charleston RR',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR3.1* ▼',
                desc_detail: 'Is exchanged for a preferred share of CoG, Frisco, or WRA, '\
                             'which gets the minor\'s token and treasury',
              },
              {
                type: 'description',
                description: 'Has a choice of starting location',
              },
            ],
            text_color: 'white',
          },
          {
            sym: '13',
            coordinates: 'N2',
            logo: '18_mag/13',
            simple_logo: '18_mag/13.alt',
            tokens: [0],
            shares: [100],
            name: 'New Orleans and Texas RR',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR3.1* ▼',
                desc_detail: 'Is exchanged for any any remaining preferred share, '\
                             'the corresponding corporation gets the minor\'s token and treasury',
              },
            ],
            text_color: 'white',
          },
        ].freeze
      end
    end
  end
end
