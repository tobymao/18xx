# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1812::Step::HomeToken do
  let(:game) { Engine::Game::G1812::Game.new(%w[a b c d]) }
  let(:corporation) { game.corporations.find { |c| c.type == :major } }
  let(:hex) { game.hex_by_id('F5') }

  before do
    game.phase.next! until game.phase.name == '4'
    game.instance_variable_set(:@round, game.send(:stock_round))
  end

  def start_public
    share_price = game.stock_market.par_prices.find { |sp| sp.price == 65 }
    action = Engine::Action::Par.new(game.current_entity, corporation: corporation, share_price: share_price)
    game.process_action(action).maybe_raise!
  end

  def place_home_token
    game.process_action(Engine::Action::PlaceToken.new(corporation, city: hex.tile.cities.first, slot: 0)).maybe_raise!
  end

  it 'charges nothing for a city without a tile' do
    start_public

    expect { place_home_token }.not_to change(corporation, :cash)
  end

  it 'charges twice the value of the city' do
    hex.lay(game.tiles.find { |t| t.name == '5' })
    start_public

    expect { place_home_token }.to change(corporation, :cash).by(-40)
    expect(game.log.last.message).to eq("#{corporation.name} pays £40 for its home station in #{hex.full_name}")
  end
end
