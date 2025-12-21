# frozen_string_literal: true

require './spec/spec_helper'

# set this value for the fixture you want to investigate
fixture = '18Uruguay/18Uruguay_game_end_bankrupt.json'

# This block can be quite slow and expensive even for a single fixture, so its
# best use is to identify exactly at which action something breaks in a
# particular fixture.
#
# It sould be run with:
#     `rspec spec/lib/engine/game/fixture_every_action.rb --fail-fast`
#
# This file is excluded from the default test suite since its name intentionally
# does not end in `_spec.rb
describe 'validated at every action' do
  text = File.read("#{FIXTURES_DIR}/#{fixture}")
  data = JSON.parse(text)

  game = Engine::Game.load(data, at_action: 1, strict: true).maybe_raise!
  starting_cash = game.bank_starting_cash

  data['actions'].each do |action|
    # use a URL here to easily open up the game in the browser for
    # inspection when a test fails
    it "http://localhost:9292/fixture/#{fixture.gsub('.json', '')}?action=#{action['id']}" do
      game.process_to_action(action['id'])

      # integer money
      [game.bank, *game.players, *game.corporations].each do |entity|
        expect(entity.cash).to be_kind_of(Integer)
      end

      # total cash is consistent
      cash = game.spenders.sum(&:cash)
      expect(cash).to eq(starting_cash)

      # total debt is consistent
      total_debt = [game.bank, *game.players].sum(&:debt)
      expect(total_debt).to eq(0)
    end
  end
end
