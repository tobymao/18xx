# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module G18Junta
      describe Game do
        let(:players) { %w[a b c] }
        let(:optional_rules) { [] }
        let(:game) { Engine::Game::G18Junta::Game.new(players, id: 1, optional_rules: optional_rules) }

        def auction_step
          game.round.active_step
        end

        def current_player
          game.round.active_entities.first
        end

        def bid(company, price)
          game.process_action(Engine::Action::Bid.new(current_player, company: company, price: price)).maybe_raise!
        end

        def pass
          game.process_action(Engine::Action::Pass.new(current_player)).maybe_raise!
        end

        describe 'private company auction (rules summary 2.1)' do
          it 'opens at face value and needs a raise of at least $5' do
            company = game.companies.first
            expect(auction_step.min_bid(company)).to eq(company.value)

            bid(company, company.value)
            expect(auction_step.min_bid(company)).to eq(company.value + 5)
          end

          context 'with the faster auction option' do
            let(:optional_rules) { [:bid_increment_10] }

            it 'needs a raise of at least $10' do
              company = game.companies.first
              bid(company, company.value)
              expect(auction_step.min_bid(company)).to eq(company.value + 10)
            end
          end

          it 'rejects bids that are not a multiple of $5' do
            company = game.companies.first
            expect { bid(company, company.value + 1) }.to raise_error(GameError, /multiple of \$5/)
          end

          it 'gives the company to the highest bidder, and the next player chooses' do
            company = game.companies.first
            opener = current_player
            bid(company, company.value)
            pass
            pass

            expect(company.owner).to eq(opener)
            expect(opener.cash).to eq(game.class::STARTING_CASH[players.size] - company.value)
            expect(current_player).to eq(game.players[(game.players.index(opener) + 1) % players.size])
          end

          it 'offers a discount round at half value after everyone passes the choice' do
            company = game.companies.max_by(&:value)
            players.size.times { pass }

            expect(auction_step.min_bid(company)).to eq((company.value / 10.0).ceil * 5)
          end

          it 'removes the remaining companies when the discount round is declined too' do
            companies = game.companies.dup
            (players.size * 2).times { pass }

            expect(companies).to all(be_closed)
            expect(game.round).to be_a(Engine::Round::Stock)
          end
        end

        describe 'priority after the auction (rules summary 2.1)' do
          it 'goes to the player with the most cash, ties broken by seating order' do
            seating = game.players.dup
            company = game.companies.max_by(&:value)
            buyer = current_player
            bid(company, company.value)
            pass
            pass
            pass while game.round.is_a?(Engine::Round::Auction)

            expected = (seating - [buyer]).first
            expect(game.round.active_entities.first).to eq(expected)
            expect(game.log.map(&:message)).to include(a_string_including("#{expected.name} has priority"))
          end
        end

        describe 'stock market (rules summary 3.5)' do
          let(:corporation) { game.corporations.first }

          def place_at(row, column)
            price = game.stock_market.market[row][column]
            corporation.share_price = price
            price.corporations << corporation
          end

          it 'moves right instead of up on the top row' do
            place_at(0, 3)
            game.stock_market.move_up(corporation)
            expect(corporation.share_price.coordinates).to eq([0, 4])
          end

          it 'stays on the last space of the top row' do
            last = game.stock_market.market[0].size - 1
            place_at(0, last)
            game.stock_market.move_up(corporation)
            expect(corporation.share_price.coordinates).to eq([0, last])
          end

          it 'moves up as usual below the top row' do
            place_at(2, 4)
            game.stock_market.move_up(corporation)
            expect(corporation.share_price.coordinates).to eq([1, 4])
          end
        end

        describe 'dividend movement (rules summary 3.5)' do
          let(:corporation) { game.corporations.first }
          let(:step) { G18Junta::Step::Dividend.new(game, game.round) }

          before { corporation.share_price = game.stock_market.market[2][4] } # $100

          it 'moves left when withholding' do
            expect(step.share_price_change(corporation, 0)).to eq(share_direction: :left, share_times: 1)
          end

          it 'moves right for a normal payout' do
            expect(step.share_price_change(corporation, 199)).to eq(share_direction: :right, share_times: 1)
          end

          it 'moves right and up for a high dividend (at least twice the share price)' do
            expect(step.share_price_change(corporation, 200))
              .to eq(share_direction: %i[right up], share_times: [1, 1])
          end
        end

        describe 'upgrade license (rules summary 4.2)' do
          let(:corporation) { game.corporations.first }

          def start_operating_round
            game.instance_variable_set(:@or_round_number, game.instance_variable_get(:@or_round_number) + 1)
            game.expire_stale_upgrade_licenses!
          end

          it 'is only valid in the next Operating Round' do
            game.grant_upgrade_license!(corporation)
            expect(game.upgrade_license_granted?(corporation)).to be(true)
            expect(game.upgrade_license?(corporation)).to be(false)

            start_operating_round
            expect(game.upgrade_license?(corporation)).to be(true)

            start_operating_round
            expect(game.upgrade_license_granted?(corporation)).to be(false)
          end

          it 'is returned once used' do
            game.grant_upgrade_license!(corporation)
            start_operating_round

            expect(game.consume_upgrade_license!(corporation)).to be(true)
            expect(game.consume_upgrade_license!(corporation)).to be(false)
          end

          it 'expires when the Track step ends without using it' do
            game.grant_upgrade_license!(corporation)
            start_operating_round
            step = G18Junta::Step::Track.new(game, game.round)
            allow(step).to receive(:current_entity).and_return(corporation)

            step.pass!
            expect(game.upgrade_license_granted?(corporation)).to be(false)
          end

          it 'expires when unused' do
            game.grant_upgrade_license!(corporation)
            start_operating_round

            game.expire_upgrade_license_if_unused!(corporation)
            expect(game.upgrade_license_granted?(corporation)).to be(false)
            expect(game.log.map(&:message)).to include(a_string_including('Upgrade License, which has expired'))
          end
        end

        describe 'buying from other companies (rules summary 2.2 and 4.3)' do
          let(:president) { game.players[0] }
          let(:other) { game.players[1] }
          let(:buyer) { game.corporations[0] }
          let(:sibling) { game.corporations[1] }
          let(:rival) { game.corporations[2] }

          before do
            buyer.owner = president
            sibling.owner = president
            rival.owner = other
          end

          it 'only offers trains of companies with the same president' do
            own_train, rival_train = game.depot.upcoming.first(2)
            own_train.owner = sibling
            rival_train.owner = rival

            expect(game.depot.other_trains(buyer)).to eq([own_train])
          end

          it "only offers private companies owned by the company's president" do
            own, others = game.companies.reject { |c| game.abilities(c, :no_buy) }.first(2)
            own.owner = president
            others.owner = other

            expect(game.purchasable_companies(buyer)).to include(own)
            expect(game.purchasable_companies(buyer)).not_to include(others)
          end
        end

        describe 'farms (rules summary 7.1)' do
          def stop(label)
            instance_double(Engine::Part::City, tile: instance_double(Engine::Tile, label: label))
          end

          it 'recognizes farm tiles by their blank label' do
            expect(game.farm_stop?(stop(' '))).to be(true)
            expect(game.farm_stop?(stop(nil))).to be(false)
          end

          it 'rejects a route that starts or ends at a farm' do
            route = instance_double(Engine::Route, visited_stops: [stop(' '), stop(nil)])
            expect { game.check_other(route) }.to raise_error(GameError, /farm cannot be the start or the end/)
          end
        end

        describe 'Laguna (rules summary 7.3)' do
          let(:yellow) { game.tiles.find { |t| t.name == 'J16' } }
          let(:gray) { game.tiles.find { |t| t.name == 'J17' } }

          it 'cannot skip to gray before gray tiles are available' do
            expect(game.upgrades_to_correct_color?(yellow, gray)).to be(false)
          end

          it 'upgrades the yellow Laguna tile straight to gray once gray tiles are available' do
            allow(game.phase).to receive(:tiles).and_return(%i[yellow green brown gray])
            expect(game.upgrades_to_correct_color?(yellow, gray)).to be(true)
          end
        end

        describe 'corruption bag (rules summary 1.4 and 5.1)' do
          let(:player) { game.players.first }

          def bag
            game.instance_variable_get(:@corruption_bag).tally
          end

          it 'starts with 28 white and 7 black tokens' do
            expect(bag).to eq(white: 28, black: 7)
          end

          it 'gives the drawn token to the player' do
            color = game.draw_corruption_token!(player, 'a test')

            expect(player.corruption_tokens[color]).to eq(1)
            expect(bag.values.sum).to eq(34)
          end

          it 'gives a black token from the stock when the bag is empty' do
            game.instance_variable_set(:@corruption_bag, [])

            expect(game.draw_corruption_token!(player, 'a test')).to eq(:black)
            expect(game.log.map(&:message).last).to include('from the stock')
          end

          it 'adds three black tokens when the last 2-train is bought' do
            corporation = game.corporations.first
            game.depot.upcoming.select { |t| t.name == '2' }.each { |t| game.buy_train(corporation, t, :free) }

            expect(bag).to eq(white: 28, black: 10)
          end
        end

        describe 'upgrade without a license (rules summary 4.1 and 4.2)' do
          let(:corporation) { game.corporations.first }
          let(:president) { game.players.first }
          let(:step) { G18Junta::Step::Track.new(game, game.round) }

          before { corporation.owner = president }

          it 'makes the president draw a corruption token' do
            step.use_license_or_draw_corruption!(corporation)

            tokens = president.corruption_tokens
            expect(tokens[:white] + tokens[:black]).to eq(1)
          end

          it 'draws nothing when the company holds a license' do
            game.grant_upgrade_license!(corporation)
            game.instance_variable_set(:@or_round_number, 1)

            step.use_license_or_draw_corruption!(corporation)

            expect(president.corruption_tokens).to eq(white: 0, black: 0)
            expect(game.upgrade_license_granted?(corporation)).to be(false)
          end
        end

        describe 'corruption penalty (rules summary 9.2 and 9.3)' do
          let(:a) { game.players[0] }
          let(:b) { game.players[1] }

          def hold(player, white, black)
            player.corruption_tokens.merge!(white: white, black: black)
          end

          it 'uses the rate for the total tokens held' do
            hold(a, 5, 3)
            hold(b, 7, 5)
            expect(game.total_corruption_tokens).to eq(20)
            expect(game.corruption_penalty_rate).to eq(25)
          end

          it 'charges every black token, even below zero cash' do
            hold(a, 0, 3)
            a.spend(a.cash - 10, game.bank)

            game.pay_corruption_penalty!
            expect(a.cash).to eq(10 - (3 * 20))
          end

          it 'breaks ties by fewer black tokens, then fewer white tokens' do
            allow(game).to receive(:player_value).and_return(100)
            hold(a, 0, 2)
            hold(b, 3, 1)

            expect(game.result.keys).to eq([game.players[2].id, b.id, a.id]) # c holds no tokens
          end
        end

        describe 'political track (rules summary 1.3 and 6.1)' do
          def place_marker(position)
            game.instance_variable_set(:@political_track, position)
          end

          it 'gives starting tokens to four different companies, two on each side' do
            alignments = game.corporations.map { |c| game.corporation_alignment(c) }
            expect(alignments.sum { |a| a[:military] }).to eq(2)
            expect(alignments.sum { |a| a[:civilian] }).to eq(2)
            expect(alignments.count { |a| (a[:military] + a[:civilian]).positive? }).to eq(4)
          end

          it 'moves the marker toward the starting token when the company floats' do
            corporation = game.corporations.find { |c| game.corporation_alignment(c)[:military].positive? }
            game.par_corporation(corporation, game.stock_market.par_prices.first)
            game.float_corporation(corporation)
            expect(game.political_track).to eq(-1)
          end

          it 'skips Neutral' do
            place_marker(-1)
            game.move_political_track!(:civilian)
            expect(game.political_track).to eq(1)
          end

          it 'moves two spaces from space 3 toward the other side' do
            place_marker(-3)
            game.move_political_track!(:civilian)
            expect(game.political_track).to eq(-1)
          end

          it 'never goes beyond either end' do
            place_marker(5)
            game.move_political_track!(:civilian)
            expect(game.political_track).to eq(5)
          end

          it 'picks the Dictatorship column of the corruption table on the Military side' do
            place_marker(-2)
            expect(game.corruption_penalty_regime).to eq(:dictatorship)
            place_marker(0)
            expect(game.corruption_penalty_regime).to eq(:democracy)
          end
        end

        describe 'paramilitary hexes (rules summary 6.2)' do
          let(:corporation) { game.corporations.first }
          let(:president) { game.players.first }
          let(:hex) { game.hex_by_id('C11') }

          before do
            corporation.owner = president
            game.claim_paramilitary_hex!(hex, corporation)
          end

          def bag(*colors)
            game.instance_variable_set(:@corruption_bag, colors)
          end

          it 'asks the president to choose a side, once per hex' do
            expect(game.paramilitary_hex_unclaimed?(hex)).to be(false)
            expect(game.pending_paramilitary_choice_for?(corporation)).to be(true)
            step = G18Junta::Step::ParamilitaryChoice.new(game, game.round)
            allow(step).to receive(:current_entity).and_return(corporation)
            expect(step.actions(corporation)).to eq(%w[choose])
          end

          it 'adds the token to the company and moves the marker' do
            bag(:black)
            game.resolve_paramilitary_choice!(corporation, 'military')

            expect(game.corporation_alignment(corporation)[:military]).to be >= 1
            expect(game.political_track).to eq(-1)
            expect(game.pending_paramilitary_choice_for?(corporation)).to be(false)
          end

          it 'draws one corruption token when it is black' do
            bag(:white, :black)
            game.resolve_paramilitary_choice!(corporation, 'civilian')
            expect(game.corruption_tokens(president)).to eq(white: 0, black: 1)
          end

          it 'draws a second corruption token when the first is white' do
            bag(:black, :white)
            game.resolve_paramilitary_choice!(corporation, 'civilian')
            expect(game.corruption_tokens(president)).to eq(white: 1, black: 1)
          end
        end
      end
    end
  end
end
