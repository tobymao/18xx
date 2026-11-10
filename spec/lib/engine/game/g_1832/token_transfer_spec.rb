# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1832::Game do
    let(:game) { Game::G1832::Game.new(%w[a b c]) }

    describe 'token transfer' do
      let(:acl) { game.corporation_by_id('ACL') }
      let(:awp) { game.corporation_by_id('A&WP') }
      let(:salr) { game.corporation_by_id('SALR') }
      let(:system) { game.corporation_by_id('AMTK') }

      # D16 gets a two-slot tile so two corporations can have a token in the same city.
      let(:shared_city) do
        hex = game.hex_by_id('D16')
        tile = game.tiles.find { |t| t.color == :green && t.cities.any? { |c| c.slots == 2 } }
        hex.lay(tile)
        hex.tile.cities.first
      end

      def place(corp, index, city)
        city.place_token(corp, corp.tokens[index], free: true, check_tokenable: false)
      end

      def city_at(hex_id)
        game.hex_by_id(hex_id).tile.cities.first
      end

      def on_map(corp)
        corp.tokens.select(&:city).map { |t| t.city.hex.id }.sort
      end

      def in_supply(corp)
        corp.tokens.count { |t| !t.city }
      end

      def map_tokens_of(*corps)
        game.hexes.flat_map { |h| h.tile.cities.flat_map(&:tokens) }.compact.select { |t| corps.include?(t.corporation) }
      end

      it 'gives a system every token of both components, with duplicates and unplaced tokens in supply' do
        place(acl, 0, city_at('F6'))
        place(acl, 1, shared_city)
        place(salr, 0, city_at('I3'))
        place(salr, 1, shared_city)

        system.tokens.clear
        game.send(:transfer_tokens, acl, system)
        game.send(:transfer_tokens, salr, system)

        expect(system.tokens.size).to eq(acl.tokens.size + salr.tokens.size)
        expect(on_map(system)).to eq(%w[D16 F6 I3])
        expect(in_supply(system)).to eq(3) # one duplicate, one unplaced token from each component
        expect(map_tokens_of(acl, salr)).to be_empty
      end

      it 'gives a buyer every token of the target, replacing the target\'s tokens from its own supply' do
        place(acl, 0, city_at('F6'))
        place(acl, 1, shared_city)
        place(awp, 0, city_at('I3'))
        place(awp, 1, shared_city)

        game.send(:transfer_tokens, awp, acl)

        expect(acl.tokens.size).to eq(3 + 2)
        expect(on_map(acl)).to eq(%w[D16 F6 I3])
        expect(in_supply(acl)).to eq(2)
        expect(map_tokens_of(awp)).to be_empty
      end

      it 'gives the buyer the target\'s markers even when its own supply runs out' do
        place(awp, 0, city_at('F6'))
        place(awp, 1, city_at('J10'))
        expect(in_supply(awp)).to eq(0)
        place(salr, 0, city_at('I3'))
        place(salr, 1, city_at('M13'))

        game.send(:transfer_tokens, salr, awp)

        expect(awp.tokens.size).to eq(2 + 3)
        expect(on_map(awp)).to eq(%w[F6 I3 J10 M13])
        expect(in_supply(awp)).to eq(1)
      end
    end
  end
end
