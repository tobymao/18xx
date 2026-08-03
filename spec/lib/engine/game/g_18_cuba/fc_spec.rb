# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module G18Cuba
      describe Game do
        let(:players) { %w[a b c] }
        let(:game) { Engine::Game::G18Cuba::Game.new(players) }

        # The topmost regular (broad, non-wagon) train in the bank — what an export pulls.
        def top_broad_train
          game.depot.upcoming.find { |t| !game.wagon?(t) && t.track_type == :broad }
        end

        describe '#export_train_to_fc!' do
          it 'moves the top broad train to the FC, non-rusting and unbuyable' do
            train = top_broad_train
            expect(train.name).to eq('2') # cheapest broad train, first in the bank

            game.export_train_to_fc!

            expect(game.fc.trains).to include(train)          # now on the FC stack
            expect(game.depot.upcoming).not_to include(train) # gone from the bank
            expect(train.rusts_on).to be_nil                  # never scrapped (VII.15/16)
            expect(train.buyable).to be(false)                # cannot be bought back
            expect(game.phase.name).to eq('2')                # exporting a 2 does not advance the phase
          end

          it 'advances the phase when it exports the first 3, like a purchase (VII.17)' do
            game.export_train_to_fc! while top_broad_train&.name == '2' # drain the 2s
            expect(top_broad_train.name).to eq('3')

            game.export_train_to_fc!

            expect(game.phase.name).to eq('3')
          end
        end
      end
    end
  end
end
