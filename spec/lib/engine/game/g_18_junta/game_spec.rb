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
          it 'only offers the private companies in play (rules summary 1.2)' do
            expect(auction_step.companies).to match_array(game.companies)
            expect(auction_step.companies.size).to eq(6)
          end

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

          it 'defaults to the current entity, as the buy companies view calls it without an argument' do
            own, others = game.companies.reject { |c| game.abilities(c, :no_buy) }.first(2)
            own.owner = president
            others.owner = other
            allow(game).to receive(:current_entity).and_return(buyer)

            expect(game.purchasable_companies).to eq(game.purchasable_companies(buyer))
            expect(game.purchasable_companies).not_to include(others)
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
            expect(president.corruption_tokens).to eq(white: 0, black: 1)
          end

          it 'draws a second corruption token when the first is white' do
            bag(:black, :white)
            game.resolve_paramilitary_choice!(corporation, 'civilian')
            expect(president.corruption_tokens).to eq(white: 1, black: 1)
          end
        end

        describe 'coup (rules summary 1.5 and 6.3 to 6.5)' do
          let(:civilian_corp) { game.corporations[0] }
          let(:military_corp) { game.corporations[1] }
          let(:neutral_corp) { game.corporations[2] }
          let(:president) { game.players.first }

          def setup_companies(track)
            game.instance_variable_set(:@political_track, track)
            alignment = Hash.new { |h, k| h[k] = { civilian: 0, military: 0 } }
            alignment[civilian_corp] = { civilian: 2, military: 1 }
            alignment[military_corp] = { civilian: 0, military: 2 }
            game.instance_variable_set(:@corporation_alignment, alignment)
            [civilian_corp, military_corp, neutral_corp].each_with_index do |corporation, index|
              corporation.owner = president
              price = game.stock_market.market[2][index + 2] # $80, $90, $100
              game.par_corporation(corporation, price)
              corporation.share_price = price
              price.corporations << corporation
              corporation.floated = true
            end
          end

          it 'has two Calm cards and one Coup Attempt card' do
            expect(game.instance_variable_get(:@political_situation_deck).tally).to eq(calm: 2, coup: 1)
          end

          it 'only resolves the coup on the Coup Attempt card' do
            game.instance_variable_set(:@political_situation_deck, %i[calm coup])
            game.reveal_political_situation_card!
            expect(game.coup_resolved?).to be(false)
          end

          it 'drops the share price to the lowest value that is at least half (rules examples)' do
            expect(game.half_share_price(125).price).to eq(65)
            expect(game.half_share_price(75).price).to eq(45)
          end

          context 'when the marker is on the Military side' do
            before do
              setup_companies(-2)
              game.resolve_coup!
            end

            it 'ends in Dictatorship and locks the track' do
              expect(game.coup_outcome).to eq(:dictatorship)
              game.move_political_track!(:civilian)
              expect(game.political_track).to eq(-2)
              expect(game.corruption_penalty_regime).to eq(:dictatorship)
            end

            it 'cancels Civilian and Military tokens one for one' do
              expect(game.corporation_alignment(civilian_corp)).to eq(civilian: 1, military: 0)
            end

            it 'removes the D-trains and fixes the border cities' do
              expect(game.depot.upcoming.map(&:name)).not_to include('D')
              expect(game.hex_by_id('A13').tile.offboards.first.revenue.values.uniq).to eq([80])
            end

            it 'pays $80 per Military token and punishes the least aligned president' do
              expect(military_corp.cash).to eq(2 * 80)
              expect(president.corruption_tokens[:black]).to eq(10)
            end

            it 'closes every private company' do
              expect(game.companies).to be_empty
            end

            it 'removes the remaining paramilitary tokens and their icons from the board' do
              icons = game.class::PARAMILITARY_HEXES.flat_map { |id| game.hex_by_id(id).tile.icons.map(&:name) }
              expect(icons).not_to include('militia')
            end
          end

          context 'when the marker is on the Civilian side' do
            before { setup_companies(2) }

            it 'ends in Democracy and removes the 8-trains and the 8 phase' do
              game.resolve_coup!
              expect(game.coup_outcome).to eq(:democracy)
              expect(game.depot.upcoming.map(&:name)).not_to include('8')
              expect(game.phase.phases.map { |phase| phase[:name] }).not_to include('8')
            end

            it 'moves Civilian companies right once per remaining token' do
              game.resolve_coup!
              expect(civilian_corp.share_price.coordinates).to eq([2, 3])
            end

            it 'halves the share price of the least aligned company' do
              game.resolve_coup!
              expect(military_corp.share_price.price).to eq(45)
            end
          end
        end

        describe 'private companies A, E, G, H and M (rules summary 11)' do
          let(:players) { %w[a b c d] }
          let(:game) { Engine::Game::G18Junta::Game.new(players, id: 222) } # A, E, G, H and M in play
          let(:owner) { game.players.first }
          let(:corporation) { game.corporations.first }

          def give(sym, entity)
            company = game.companies.find { |c| c.sym == sym }
            company.owner = entity
            entity.companies << company
            company
          end

          before { corporation.owner = owner }

          it 'A: fixes the par price of a company once per game' do
            give('(A)', owner)
            price = game.stock_market.par_prices.last
            expect(game.private_a_owner).to eq(owner)

            game.use_private_a!(corporation, price)
            expect(game.private_a_usable_this_stock_round?).to be(false)
            step = G18Junta::Step::BuySellParShares.new(game, game.round)
            expect(step.get_par_prices(owner, corporation)).to eq([price])
          end

          it 'E: can be donated only from the first 3-train' do
            give('(E)', owner)
            expect(game.private_e_donatable?(corporation)).to be(false)

            allow(game.phase).to receive(:status).and_return(['can_buy_companies'])
            expect(game.private_e_donatable?(corporation)).to be(true)
          end

          it 'E: the company gets the private and $150 from the bank, the owner gets nothing' do
            company = give('(E)', owner)
            cash = owner.cash

            game.donate_private_e!(corporation)
            expect(corporation.companies).to include(company)
            expect(corporation.cash).to eq(150)
            expect(owner.cash).to eq(cash)
          end

          it 'G: towns do not count toward the train range' do
            train = game.depot.upcoming.first # a 2-train
            city = instance_double(Engine::Part::City, town?: false, visit_cost: 1)
            town = instance_double(Engine::Part::Town, town?: true, visit_cost: 1)
            route = instance_double(Engine::Route, corporation: corporation, train: train)

            expect { game.check_distance(route, [city, town, city]) }.to raise_error(GameError)
            give('(G)', corporation)
            expect { game.check_distance(route, [city, town, city]) }.not_to raise_error
          end

          it 'H: adds 10% of a high dividend to the treasury' do
            game.pay_private_h_bonus!(corporation, 250)
            expect(corporation.cash).to eq(0)

            give('(H)', corporation)
            game.pay_private_h_bonus!(corporation, 250)
            expect(corporation.cash).to eq(25)
          end

          it 'M: draws a token for $5 per phase number, once per Stock Round' do
            give('(M)', owner)
            expect(game.private_m_usable?(owner)).to be(false) # still in the auction

            game.instance_variable_set(:@round, game.stock_round)
            cash = owner.cash
            game.use_private_m!(owner)

            expect(owner.cash).to eq(cash + 10) # phase 2
            expect(owner.corruption_tokens.values.sum).to eq(1)
            expect { game.use_private_m!(owner) }.to raise_error(GameError)
          end
        end

        describe 'private companies C, D, F, I, K and N (rules summary 11)' do
          let(:players) { %w[a b c d] }
          let(:game) { Engine::Game::G18Junta::Game.new(players, id: 162) } # C, D, I, K and N in play
          let(:owner) { game.players.first }
          let(:corporation) { game.corporations.first }

          def give(sym, entity)
            company = game.companies.find { |c| c.sym == sym }
            company.owner = entity
            entity.companies << company
            company
          end

          before { corporation.owner = owner }

          it 'C: may discard a paramilitary token without moving the marker or drawing' do
            give('(C)', corporation)
            game.claim_paramilitary_hex!(game.hex_by_id('C11'), corporation)
            step = G18Junta::Step::ParamilitaryChoice.new(game, game.round)
            allow(step).to receive(:current_entity).and_return(corporation)
            expect(step.choices).to include('discard')

            game.resolve_paramilitary_choice!(corporation, 'discard')
            expect(game.political_track).to eq(0)
            expect(owner.corruption_tokens.values.sum).to eq(0)
          end

          it 'D: discards a 2-train and pays only the difference for the cheapest train in the supply' do
            company = give('(D)', corporation)
            old_train, *other_twos = game.depot.upcoming.select { |t| t.name == '2' }
            game.buy_train(corporation, old_train, :free)
            other_twos.each { |t| game.buy_train(game.corporations.last, t, :free) } # the new train must cost more
            game.bank.spend(500, corporation)
            step = G18Junta::Step::SpecialChoose.new(game, game.round)
            target = game.private_d_target_train
            expect(step.choices_ability(company).keys).to eq([old_train.id])

            game.exchange_train_for_private_d!(corporation, old_train)
            expect(corporation.trains).to eq([target])
            expect(corporation.cash).to eq(500 - (target.price - old_train.price))
          end

          it 'I: lets the owning company discard an alignment token before the tokens cancel out' do
            give('(I)', corporation)
            price = game.stock_market.par_prices.first
            game.par_corporation(corporation, price)
            corporation.share_price = price
            price.corporations << corporation
            corporation.floated = true
            game.corporation_alignment(corporation).merge!(civilian: 1, military: 1)
            game.resolve_coup!
            expect(game.pending_coup_i_choice).to eq(corporation)

            game.resolve_private_i_choice!('military')
            expect(game.pending_coup_i_choice).to be_nil
            expect(game.corporation_alignment(corporation)).to eq(civilian: 1, military: 0)
            expect(game.companies).to be_empty
          end

          it 'K: a black token from the bag goes back and is drawn again, once per Operating Round' do
            give('(K)', corporation)
            game.instance_variable_set(:@corruption_bag, %i[black black])
            game.draw_corruption_token!(owner, 'a test', corporation: corporation)
            game.draw_corruption_token!(owner, 'a test', corporation: corporation)

            expect(game.log.map(&:message).count { |m| m.include?('draws again (Hernandez Abogados)') }).to eq(1)
            expect(owner.corruption_tokens[:black]).to eq(2)
          end

          it 'N: removes a paramilitary token and gives the president 2 black tokens' do
            give('(N)', corporation)
            game.use_private_n!(corporation, 'C11')

            expect(game.paramilitary_hex_unclaimed?(game.hex_by_id('C11'))).to be(false)
            expect(game.hex_by_id('C11').tile.icons.map(&:name)).not_to include('militia')
            expect(owner.corruption_tokens[:black]).to eq(2)
          end

          it 'F: only offers yellow tiles on empty hexes' do
            game_f = Engine::Game::G18Junta::Game.new(players, id: 1) # F in play
            company = game_f.companies.find { |c| c.sym == '(F)' }
            step = G18Junta::Step::SpecialTrack.new(game_f, game_f.round)
            expect(step.potential_tiles(company, game_f.hex_by_id('G7'))).to be_empty # preprinted green city
          end
        end

        describe '2-player game (rules summary 1.1 and 1.2)' do
          let(:players) { %w[a b] }

          it 'removes Hijos Muñoz and one more company' do
            expect(game.corporations.size).to eq(6)
            expect(game.corporations.map(&:name)).not_to include('H')
          end

          it 'uses the smaller map, with Campesina at home in F4' do
            expect(game.hex_by_id('H2')).to be_nil
            campesina = game.corporations.find { |c| c.name == 'C' }
            expect(campesina.coordinates).to eq('F4') if campesina
          end

          it 'has one 2-, one 3- and one 4-train fewer' do
            counts = game.depot.upcoming.group_by(&:name).transform_values(&:size)
            expect(counts.values_at('2', '3', '4')).to eq([5, 4, 3])
          end

          it 'keeps five private companies' do
            expect(game.companies.size).to eq(5)
          end
        end

        describe 'bankruptcy (rules summary 9.1)' do
          it 'does not count private companies in a bankrupt player\'s score' do
            player = game.players.first
            company = game.companies.first
            company.owner = player
            player.companies << company
            value = game.player_value(player)

            player.bankrupt = true
            expect(game.player_value(player)).to eq(value - company.value)
          end
        end

        describe 'info, cards and log' do
          it 'shows the political track scale, the corruption bag and the penalty table on the Info page' do
            lines = game.timeline
            expect(lines[0]).to end_with(': NEUTRAL')
            expect(lines[1]).to include("MIL 5 >> | MIL 4 >> | MIL 3 >> | MIL 2 | MIL 1 | \u25B6")
            expect(lines[1]).to end_with('CIV 2 | << CIV 3 | << CIV 4 | << CIV 5')
            expect(lines).to include("BAG:  28x\u26AA  7x\u26AB")
            expect(lines.last).to start_with('<=').and end_with('+: $44/$60')
          end

          it 'drops Neutral from the scale once the marker has left it' do
            game.move_political_track!(:military)
            expect(game.timeline[1]).not_to include('NEUTRAL')
          end

          it 'shows the marker on the A2 status tile' do
            tile = game.hex_by_id('A2').tile
            expect(tile.location_name).to eq('NEUTRAL')

            game.move_political_track!(:military)
            expect(tile.location_name).to eq("STATUS: \nMIL 1")
            expect(tile.color).to eq(:green)
          end

          it 'never upgrades the A2 status tile' do
            from = game.hex_by_id('A2').tile
            expect(game.tiles.none? { |tile| game.upgrades_to?(from, tile) }).to be(true)
          end

          it 'explains the coup in the phase table' do
            expect(game.phase.phases.find { |ph| ph[:name] == '5' }[:status]).to include('coup_attempt')
            expect(game.class::STATUS_TEXT).to have_key('coup_attempt')
          end

          it 'shows corruption tokens on player cards and alignment tokens on company cards' do
            player = game.players.first
            corporation = game.corporations.find { |c| game.corporation_alignment(c)[:civilian].positive? }
            expect(game.player_card_rows(player)).to eq(['Corruption:', "0x\u26AA  0x\u26AB"])
            expect(game.status_array(corporation)).to include(['Civilian x1', 'civilian_support'])
          end

          it 'writes the setup draws as one block' do
            log = game.log.map(&:message)
            start = log.index { |m| m.include?(' SETUP ') }
            expect(log[start + 1..start + 3].join).to include('Corporation removed in this game')
            expect(log[start + 3]).to start_with('Private companies available in this game')
          end
        end
      end
    end
  end
end
