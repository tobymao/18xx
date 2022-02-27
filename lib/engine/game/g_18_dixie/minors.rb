# frozen_string_literal: true

module Engine
  module Game
    module G18Dixie
      module Minors
        MINORS = [
          {
            sym: ' 1',
            coordinates: 'K17',
            logo: '18_mag/1',
            simple_logo: '18_mag/1.alt',
            tokens: [0],
            name: 'Georgia & Florida Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR3',
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
            name: 'Tennessee Central Railway',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR3',
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
            name: 'Missisippi Central Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR3',
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
            name: 'Alabama & Tenessee River Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR3',
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
            name: 'Tallahassee Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR4',
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
            name: 'Atlanta, Birmingham & Coast Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR4',
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
            name: 'Western & Atlantic Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR4',
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
            name: 'Georgia Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR4',
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
            tokens: [0],
            name: 'Nashville, Chattanooga & St. Louis Railway',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR5',
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
            tokens: [0],
            name: 'Gulf, Mobile & Ohio Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR5',
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
            tokens: [0],
            name: 'Mobile & Ohio Railroad',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR5',
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
            tokens: [0],
            name: 'Memphis & Charleston RR',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR5',
                desc_detail: 'Is exchanged for a preferred share of Cog, Frisco, or WRA, '\
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
            name: 'New Orleans and Texas RR',
            color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Closes at the end of OR5',
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
