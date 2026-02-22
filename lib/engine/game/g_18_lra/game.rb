# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'phases'
require_relative 'trains'
require_relative '../g_18_rhl/game'

module Engine
  module Game
    module G18Lra
      class Game < G18Rhl::Game
        include_meta(G18Lra::Meta)
        include Entities
        include Map
        include Phases
        include Trains

        BANK_CASH = { 2 => 6000, 3 => 6000, 4 => 8000 }.freeze

        CERT_LIMIT = { 2 => 14, 3 => 14, 4 => 15 }.freeze

        STARTING_CASH = { 2 => 600, 3 => 600, 4 => 450 }.freeze
        LOWER_STARTING_CASH = { 2 => 500, 3 => 500, 4 => 375 }.freeze

        EVENTS_TEXT = G18Rhl::Game::EVENTS_TEXT.merge(
          'remove_tile_block' => ['Remove tile block', 'Hexes B4 and C11 can now be upgraded to yellow'],
          'gbk_floats' => ['GBK floats', 'GBK (Private no. 6) floats'],
        ).freeze

        STATUS_TEXT = {
          'harbour_unreserved' => [
            'Harbours unreserved',
            'No reservation of the harbour station locations',
          ],
        }.merge(G18Rhl::Game::STATUS_TEXT).freeze

        def setup
          # Create 4 neutral harbour tokens and put them in the 4 hardbour slots on the map
          # Create virtual SJ corporation
          @harbours = Corporation.new(
            sym: 'HH',
            name: 'Harbours',
            tokens: [],
          )
          @harbours.owner = @bank

          @harbour_tokens = []
          harbour_logo = '/icons/port.svg'
          [{ 'hex' => 'B12', 'city_id' => 0 },
           { 'hex' => 'B14', 'city_id' => 0 },
           { 'hex' => 'E13', 'city_id' => 1 },
           { 'hex' => 'H14', 'city_id' => 1 }].each do |harbour|
            token = Token.new(@harbours, price: 0, logo: harbour_logo, simple_logo: harbour_logo, type: :neutral)
            hex = hex_by_id(harbour['hex'])
            hex.tile.cities[harbour['city_id']].place_token(@harbours, token, free: true)
            @harbours.tokens << token
          end

          # Add harbour tokens to all corporations except GVE
          @corporations.each do |c|
            next if c.id == 'GVE'

            price = c.tokens.last.price + 20
            logo = c.tokens.last.logo.gsub(/\.svg/, '_harbour\\0')
            c.tokens << Engine::Token.new(c, price: price, logo: logo, simple_logo: logo, type: :harbour)

            c.add_ability(Ability::Base.new(
                          type: 'description',
                          description: 'Harbour token',
                          desc_detail: 'Last token is a Harbour token which can be used to token a harbour. '\
                                       "cost #{price / 2}M before harbour reservation ceases in phase 5 (TO BE DONE)"))
          end
        end

        def event_remove_tile_block!
          @log << "Hex B4 (#{location_name(B4)}) and C11 (#{location_name(C11)}) are now possible to upgrade to yellow"
          yellow_block_hex.tile.icons.reject! { |i| i.name == 'green_hex' }
        end

        def event_gbk_floats!
          @log << 'GBK (Private no. 6) floats - NOT YET IMPLEMENTED'
        end
      end
    end
  end
end
