# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module GFrost1831
      describe Game do
        def new_game(num_players, id: 1)
          Engine::Game::GFrost1831::Game.new((1..num_players).map { |i| "Player #{i}" }, id: id)
        end

        it 'has the expected title and aliases' do
          expect(Meta::GAME_TITLE).to eq('Frost 1831')
          expect(Meta::GAME_ALIASES).to eq(['1831'])
        end

        it 'plays with 2 to 5 players' do
          expect(Meta::PLAYER_RANGE).to eq([2, 5])
        end

        {
          2 => { cert_limit: 31, cash: 1200 },
          3 => { cert_limit: 25, cash: 800 },
          4 => { cert_limit: 22, cash: 600 },
          5 => { cert_limit: 19, cash: 480 },
        }.each do |num_players, expected|
          it "initializes with #{num_players} players without error" do
            game = new_game(num_players)
            expect(game.cert_limit).to eq(expected[:cert_limit])
            expect(game.players.map(&:cash).uniq).to eq([expected[:cash]])
          end
        end

        it 'loads the eight corporations' do
          game = new_game(3)
          expect(game.corporations.map(&:id).sort).to eq(%w[CM DL EC GJ HF OE SP TV])
        end

        describe 'first-to-arrive market cells' do
          let(:game) { new_game(3) }
          let(:market) { game.stock_market }
          let(:first_to_arrive_messages) { game.log.map(&:message).grep(/is first to reach/) }

          def place(corporation, coordinates)
            price = market.share_price(coordinates)
            corporation.share_price = price
            price.corporations << corporation
          end

          def move_right(corporation)
            from = corporation.share_price
            market.move_right(corporation)
            game.log_share_price(corporation, from)
          end

          it 'marks seven cells' do
            expect(market.share_prices_with_types([:pays_bonus_1]).map(&:price)).to eq([300, 240, 200, 160, 120, 80, 60])
          end

          it 'turns the cell into a normal one when the first corporation arrives' do
            corporation = game.corporation_by_id('CM')
            place(corporation, [1, 11])

            move_right(corporation)

            expect(corporation.share_price.price).to eq(300)
            expect(corporation.share_price.types).to be_empty
            expect(market.share_prices_with_types([:pays_bonus_1]).size).to eq(6)
            expect(first_to_arrive_messages.size).to eq(1)
            expect(first_to_arrive_messages.first).to include('CM')
          end

          it 'does not claim the cell again for the next corporation' do
            first = game.corporation_by_id('CM')
            second = game.corporation_by_id('DL')
            place(first, [1, 11])
            place(second, [1, 11])

            move_right(first)
            move_right(second)

            expect(second.share_price).to eq(first.share_price)
            expect(first_to_arrive_messages.size).to eq(1)
          end
        end
      end
    end
  end
end
