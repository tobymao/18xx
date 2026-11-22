# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/tile'
require 'view/game/part/upgrades'

module View
  module Game
    module Part
      describe Upgrades do
        let(:tile) { Engine::Tile.for('1') }
        let(:given) { [Engine::Part::Upgrade.new(60, %w[mountain])] }

        def render_with(**kwargs)
          component = described_class.new(nil, tile: tile, region_use: {}, **kwargs)
          allow(component).to receive(:h) { |_klass, **opts| opts[:cost] }
          component.render
        end

        it 'renders the upgrades it is given' do
          expect(render_with(upgrades: given)).to eq([60])
        end

        it "renders the tile's own upgrades when none are given" do
          allow(tile).to receive(:upgrades).and_return(given)

          expect(render_with).to eq([60])
        end
      end
    end
  end
end
