# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G18LosAngeles1::Game do
  describe 19_984 do
    it 'Dewey, Cheatham, & Howe places a cheater token from the charter at normal price' do
      game = fixture_at_action(145)

      dch = game.company_by_id('DC&H')
      corp = dch.corporation
      city = game.hex_by_id('C6').tile.cities.first

      # slots before
      expect(city.tokens.size).to eq(2)

      # corporation cash and tokens before
      expect(corp.id).to eq('LAIR')
      expect(corp.cash).to eq(137)
      expect(corp.tokens.partition(&:used).map(&:size)).to eq([3, 3])

      game.process_to_action(146)

      # cheater token added a slot
      expect(city.tokens.size).to eq(3)

      token = city.tokens[2]
      expect(token.type).to eq(:normal)

      # corporation had to pay and use a token from the charter
      expect(token.corporation).to eq(corp)
      expect(corp.cash).to eq(57)
      expect(corp.tokens.partition(&:used).map(&:size)).to eq([4, 2])
    end

    it 'LA Title places a neutral token' do
      game = fixture_at_action(167)

      la_title = game.company_by_id('LAT')
      corp = la_title.corporation

      expect(corp.id).to eq('LA')
      expect(corp.cash).to eq(37)
      expect(corp.tokens.partition(&:used).map(&:size)).to eq([3, 2])

      game.process_to_action(168)
      token = game.hex_by_id('C8').tile.cities.first.tokens[1]

      expect(token.type).to eq(:neutral)

      # free token, not from the charter
      expect(corp.cash).to eq(37)
      expect(corp.tokens.partition(&:used).map(&:size)).to eq([3, 2])
    end
  end
end
