# frozen_string_literal: true

require_relative '../g_1870/game'
require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../base'

module Engine
  module Game
    module G1850
      class Game < Game::Base
        include_meta(G1850::Meta)
        include G1850::Entities
        include G1850::Map

        CERT_LIMIT = {
          2 => { 9 => 24, 8 => 21 },
          3 => { 9 => 17, 8 => 15 },
          4 => { 9 => 14, 8 => 12 },
          5 => { 9 => 11, 8 => 9 },
          6 => { 9 => 9, 8 => 8 },
        }.freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
            status: ['can_buy_companies_from_other_players'],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies can_buy_companies_from_other_players],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies can_buy_companies_from_other_players],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '10',
            on: '10',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '12',
            on: '12',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          { name: '2', distance: 2, price: 80, rusts_on: '4', num: 6 },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 6,
            events: [{ 'type' => 'companies_buyable' }],
          },
          { name: '4', distance: 4, price: 300, rusts_on: '8', num: 4 },
          {
            name: '5',
            distance: 5,
            price: 450,
            rusts_on: '12',
            num: 3,
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: 6,
            price: 630,
            num: 3,
            events: [{ 'type' => 'remove_tokens' }],
          },
          { name: '8', distance: 8, price: 800, num: 3 },
          { name: '10', distance: 10, price: 950, num: 2 },
          { name: '12', distance: 12, price: 1100, num: 12 },
        ].freeze

        def setup
          # Place neutral token in Sault St. Marie
          neutral = Corporation.new(
            sym: 'N',
            name: 'Neutral',
            logo: 'open_city',
            simple_logo: 'open_city.alt',
            tokens: [0, 0],
          )
          neutral.owner = @bank

          neutral.tokens.each { |token| token.type = :neutral }

          city_by_id('C20-0-0').place_token(neutral, neutral.next_token)
        end
      end
    end
  end
end
