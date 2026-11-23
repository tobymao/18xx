# frozen_string_literal: true

require 'spec_helper'
require 'view/game/entities'
require 'view/game/company'
require 'view/game/corporation'
require 'view/game/game_info'

describe View::Game::Entities do
  let(:corporation) { double(:corporation, closed?: false, owner: nil) }
  let(:game) do
    double(:game).tap do |game|
      allow(game).to receive(:player_entities).and_return([])
      allow(game).to receive(:corporations).and_return([corporation])
      allow(game).to receive(:minors).and_return([])
      allow(game).to receive(:player_sort).and_return([])
      allow(game).to receive(:bank_sort) { |corporations| corporations }
      allow(game).to receive(:show_ipo_rows?).and_return(false)
      allow(game).to receive(:respond_to?).with(:unstarted_corporation_summary).and_return(false)
      allow(game).to receive(:unowned_purchasable_companies).and_return([])
      allow(game).to receive(:receivership_corporations).and_return([corporation])
    end
  end
  let(:component) { described_class.new(nil, game: game, user: nil) }
  let(:nodes) { [] }

  before do
    allow(component).to receive(:h) do |tag, props = {}, children = nil|
      node = [tag, props, children]
      nodes << node
      node
    end
  end

  it 'renders a receivership corporation once, in the Bank column' do
    component.render

    rendered = nodes.select { |tag, _props, _children| tag == View::Game::Corporation }
    expect(rendered.size).to eq(1)
    expect(rendered.first[1][:corporation]).to eq(corporation)
  end
end
