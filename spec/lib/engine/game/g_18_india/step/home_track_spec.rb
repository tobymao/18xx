# frozen_string_literal: true

require 'spec_helper'

# fixture_at_action derives the game title from the outermost describe class (.title),
# so this spec must be rooted at the Game class rather than the Step class.
describe Engine::Game::G18India::Game do
  describe 'OO-Fix' do
    describe Engine::Game::G18India::Step::HomeTrack do
      # HomeTrack is registered ahead of the generic Engine::Step::HomeToken for every
      # corporation (not just GIPR), and Round::Base#actions_for stops at the first
      # active + blocking step regardless of whether it returned any actions. So
      # HomeTrack#actions must offer 'place_token' for a normal fixed-home corporation
      # whenever its own home hex has room, even if no OTHER open city/town exists
      # anywhere else on the board. Before the fix, HomeTrack gated 'place_token' on
      # board-wide open_city_hexes/town_to_green_city_hexes (a check only meaningful
      # for GIPR's "pick any open city" home rule), so a corp like KGF or WR would be
      # left with zero legal actions late in the game once the rest of the board
      # filled up -- see GH #11461.
      let(:game) { fixture_at_action(37, clear_cache: true) }
      let(:kgf) { game.corporation_by_id('KGF') }
      let(:home_hex) { game.hex_by_id(kgf.coordinates) }
      let(:step) { described_class.new(game, game.round) }

      before do
        game.round.pending_tokens << { entity: kgf, hexes: [home_hex], token: kgf.find_token_by_type }
        game.round.clear_cache!
      end

      def stub_empty_board
        allow(game).to receive(:open_city_hexes).and_return([])
        allow(game).to receive(:town_to_green_city_hexes).and_return([])
      end

      describe '#actions' do
        it 'offers place_token for a fixed-home corp even when no other city/town is open' do
          stub_empty_board

          expect(step.actions(kgf)).to eq(%w[place_token])
        end

        it 'still offers place_token for a fixed-home corp when the board has open cities' do
          expect(step.actions(kgf)).to eq(%w[place_token])
        end

        it 'returns [] for an entity that is not the pending entity' do
          other = game.corporations.find { |c| c != kgf }
          expect(step.actions(other)).to eq([])
        end

        it "still gates GIPR's flexible placement on board-wide availability" do
          gipr = game.gipr
          game.round.pending_tokens.clear
          game.round.pending_tokens << { entity: gipr, hexes: [], token: gipr.find_token_by_type }
          game.round.clear_cache!
          stub_empty_board

          expect(step.actions(gipr)).to eq([])
        end
      end

      describe '#process_place_token' do
        it "places the corporation's token on its home hex and clears the pending queue" do
          stub_empty_board
          city = home_hex.tile.cities.first
          action = Engine::Action::PlaceToken.new(kgf, city: city)

          step.process_place_token(action)

          expect(city.tokened_by?(kgf)).to eq(true)
          expect(game.round.pending_tokens).to eq([])
        end
      end
    end
  end
end
