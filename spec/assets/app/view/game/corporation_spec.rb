# frozen_string_literal: true

require 'spec_helper'
require 'view/game/corporation'

describe View::Game::Corporation do
  let(:game) { Engine::Game::G1846::Game.new(%w[Alice Bob Carol], seed: 6) }
  let(:corporation) { game.corporations.first }
  let(:company) { game.companies.find { |c| c.id == 'SC' } }
  let(:component) { described_class.new(nil, corporation: corporation, game: game) }

  def strings(node, found = [])
    case node
    when String
      found << node
    when Array
      node.each { |part| strings(part, found) }
    end
    found
  end

  before do
    corporation.assign!(company.id)
    game.hex_by_id('I1').assign!(company.id)

    allow(component).to receive(:h) { |tag, props = {}, children = nil| [tag, props, children] }
  end

  it 'shows the assigned hex rather than the private abbreviation' do
    rendered = strings(component.render_tokens)

    expect(rendered).to include('I1')
    expect(rendered).not_to include('SC')
  end
end
