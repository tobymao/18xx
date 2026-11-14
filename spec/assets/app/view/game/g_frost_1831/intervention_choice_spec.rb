# frozen_string_literal: true

require './spec/spec_helper'
require 'view/game/g_frost_1831/intervention_choice'

module View
  module Game
    module GFrost1831
      describe InterventionChoice do
        let(:game) { Engine::Game::GFrost1831::Game.new(%w[a b c], id: 1) }
        let(:hex) { game.hex_by_id('G14') }
        let(:gua) { game.corporation_by_id('GUA') }
        let(:exp) { game.corporation_by_id('EXP') }
        let(:nodes) { [] }

        def render(tile_selector)
          component = described_class.new(nil, game: game, tile_selector: tile_selector)
          allow(component).to receive(:h) do |tag, props = {}, children = nil|
            unless props.is_a?(Hash)
              children = props
              props = {}
            end
            nodes << [tag, props, children]
            [tag, props, children]
          end
          allow(component).to receive(:store)
          allow(component).to receive(:process_action)
          component.render
          component
        end

        it 'asks for a hex while none is selected' do
          render(nil)

          expect(nodes.map(&:last)).to include('Click a highlighted hex on the map.')
          expect(nodes.map(&:first)).not_to include(:button)
        end

        it 'offers the Factions of the selected hex and submits the hex with the Faction' do
          selector = Lib::HexChoiceSelector.new(hex, [0, 0], 'G14:GUA' => gua, 'G14:EXP' => exp)
          component = render(selector)
          buttons = nodes.select { |tag, _, _| tag == :button }

          expect(nodes.map(&:last)).to include('Base in G14:')
          expect(buttons.map(&:last)).to eq(%w[Guardians Expansionists])

          buttons.last[1][:on][:click].call

          expect(component).to have_received(:store).with(:tile_selector, nil, skip: true)
          expect(component).to have_received(:process_action) do |action|
            expect(action.choice).to eq('G14:EXP')
          end
        end
      end
    end
  end
end
