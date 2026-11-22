# frozen_string_literal: true

require './spec/spec_helper'
require_relative '../../../../lib/engine/game/g_18_oe/route_helpers'
require 'view/game/tile'
require 'view/game/part/assignments'
require 'view/game/part/icons'
require 'view/game/part/large_item'
require 'view/game/part/large_icons'
require 'view/game/part/future_label'
require 'view/game/part/partitions'
require 'view/game/part/reservation'

module View
  module Game
    describe Tile do
      include_context 'with 18OE route helpers'

      let(:hex) { game.hex_by_id('J23') }

      def rendered_parts(tile)
        calls = []
        component = described_class.new(nil, game: game, tile: tile)
        allow(component).to receive(:h) do |klass, **opts|
          calls << [klass, opts]
          klass
        end
        component.render
        calls
      end

      def upgrades_cost(calls)
        calls.select { |klass, _| klass == Part::Upgrades }.map { |_, opts| opts[:upgrades].sum(&:cost) }
      end

      it 'renders the printed terrain cost on a Brandt & Brandau tile (§14.9)' do
        hex.assign!('BBE')
        hex.lay(game.tile_by_id('7-0'))

        expect(upgrades_cost(rendered_parts(hex.tile))).to eq([45])
      end

      it 'renders no terrain on a laid tile without a Brandt & Brandau token' do
        hex.lay(game.tile_by_id('7-0'))

        expect(upgrades_cost(rendered_parts(hex.tile))).to be_empty
      end
    end
  end
end
