# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module G18Cuba
      describe Game do
        let(:players) { %w[a b c] }
        let(:game) { Engine::Game::G18Cuba::Game.new(players) }

        # ── Helpers ──────────────────────────────────────────────────────────

        # Finds a train by name in the depot (includes upcoming trains).
        def depot_train(name)
          game.depot.depot_trains.find { |t| t.name == name } ||
            game.depot.upcoming.find { |t| t.name == name }
        end

        # Injects a train directly into a corporation, bypassing cash / buy-step
        # validation. Tests here exercise state queries, not the purchase path.
        def give_train(corp, name)
          train = depot_train(name)
          return nil unless train

          game.depot.remove_train(train)
          train.owner = corp
          corp.trains << train
          train
        end

        # Advances the phase by calling Phase#next! until the target name is reached.
        # Does NOT trigger train rusting — phase-limit changes are enough for these tests.
        def advance_to_phase(target)
          game.phase.next! until game.phase.name == target
        end

        let(:major) { game.corporations.find { |c| c.type == :major } }
        let(:minor) { game.corporations.find { |c| c.type == :minor } }

        # ─────────────────────────────────────────────────────────────────────
        # Wagon classification — everything else depends on this
        # ─────────────────────────────────────────────────────────────────────

        describe '#wagon?' do
          it 'recognises 1w / 2w / 3w as wagons' do
            %w[1w 2w 3w].each do |name|
              expect(game.wagon?(depot_train(name))).to be(true), "#{name} should be a wagon"
            end
          end

          it 'does not classify regular trains as wagons' do
            %w[2 3 4 2n 3n 4n].each do |name|
              train = depot_train(name)
              next unless train

              expect(game.wagon?(train)).to be(false), "#{name} should not be a wagon"
            end
          end
        end

        describe '#num_wagons / #num_corp_trains' do
          it 'counts wagons and regular trains independently' do
            give_train(major, '2')
            give_train(major, '1w')

            expect(game.num_corp_trains(major)).to eq(1)
            expect(game.num_wagons(major)).to eq(1)
          end

          it 'does not count a wagon as a regular train' do
            give_train(major, '1w')

            expect(game.num_corp_trains(major)).to eq(0)
          end
        end

        # ─────────────────────────────────────────────────────────────────────
        # train_limit_overflow / crowded_corps — correct discard axes on phase change
        # ─────────────────────────────────────────────────────────────────────

        describe '#train_limit_overflow' do
          it 'flags trains axis when regular trains exceed the limit' do
            4.times { give_train(major, '2') }
            advance_to_phase('4') # limit drops 4 → 3
            expect(game.train_limit_overflow(major)).to eq(trains: true, wagons: false)
          end

          it 'flags wagons axis when wagons exceed the limit' do
            give_train(major, '2')
            4.times { give_train(major, '1w') }
            advance_to_phase('4') # limit drops 4 → 3
            expect(game.train_limit_overflow(major)).to eq(trains: false, wagons: true)
          end

          it 'flags both axes when both exceed the limit' do
            4.times { give_train(major, '2') }
            4.times { give_train(major, '1w') }
            advance_to_phase('5') # limit drops to 2
            expect(game.train_limit_overflow(major)).to eq(trains: true, wagons: true)
          end

          it 'returns all-false when within limits' do
            give_train(major, '2')
            give_train(major, '1w')
            expect(game.train_limit_overflow(major)).to eq(trains: false, wagons: false)
          end
        end

        describe '#crowded_corps' do
          it 'is empty when no corporation exceeds its limit' do
            give_train(major, '2')
            expect(game.crowded_corps).not_to include(major)
          end

          it 'includes a corporation once its train axis is over the limit' do
            3.times { give_train(major, '2') }
            advance_to_phase('5') # limit 2 → 3 trains crowded
            expect(game.crowded_corps).to include(major)
          end
        end

        # ─────────────────────────────────────────────────────────────────────
        # must_buy_train? is track-type aware (pragmatic bankruptcy rule)
        # ─────────────────────────────────────────────────────────────────────

        describe '#must_buy_train?' do
          it 'is false when the corporation owns a regular train' do
            give_train(major, '2')
            expect(game.must_buy_train?(major)).to be(false)
          end

          it 'is true when the corporation has no trains and depot has matching trains' do
            expect(game.must_buy_train?(major)).to be(true)
          end

          it 'is false for a major when only narrow trains remain in the depot' do
            # depot.trains holds all copies; depot_trains returns one representative per type
            game.depot.trains.select { |t| t.track_type == :broad && !game.wagon?(t) }.each do |t|
              game.depot.remove_train(t)
            end
            expect(game.must_buy_train?(major)).to be(false)
          end

          it 'is false for a minor when only broad trains remain in the depot' do
            game.depot.trains.select { |t| t.track_type == :narrow }.each do |t|
              game.depot.remove_train(t)
            end
            expect(game.must_buy_train?(minor)).to be(false)
          end

          it 'is true when the corporation owns only wagons (wagons do not satisfy the obligation)' do
            give_train(major, '1w')
            expect(game.must_buy_train?(major)).to be(true)
          end
        end

        # ─────────────────────────────────────────────────────────────────────
        # names_of_cheapest_variants — plus-train and aged-train filter
        # ─────────────────────────────────────────────────────────────────────

        describe Engine::Game::G18Cuba::Step::BuyTrain do
          # Step only needs @game for these queries; round context is irrelevant.
          let(:step) { described_class.new(game, game.round) }

          it 'excludes the plus variant from the cheapest name (3 not 3+)' do
            three = depot_train('3')
            expect(step.names_of_cheapest_variants(three)).to eq(['3'])
          end

          it 'returns the base name for an unaged 4n' do
            four_n = depot_train('4n')
            expect(step.names_of_cheapest_variants(four_n)).to eq(['4n'])
          end

          it 'returns [train.name] for an aged 4n (variant = 4-1n)' do
            four_n = depot_train('4n')
            four_n.variant = '4-1n'
            expect(step.names_of_cheapest_variants(four_n)).to eq(['4-1n'])
          end

          describe '#must_buy_at_face_value?' do
            it 'is true for wagons (rule VII.12)' do
              wagon = depot_train('1w')
              expect(step.must_buy_at_face_value?(wagon, major)).to be(true)
            end

            it 'is false for standard trains' do
              # Owned by another corp: depot trains never reach this check (from_depot? guards it).
              train2 = give_train(minor, '2')
              expect(step.must_buy_at_face_value?(train2, major)).to be(false)
            end
          end
        end

        # ─────────────────────────────────────────────────────────────────────
        # can_buy_train_from_others? — cross-company buys unlock in phase 3 (Rule VII.12)
        # ─────────────────────────────────────────────────────────────────────

        describe '#can_buy_train_from_others?' do
          it 'is false while the cross_company_trains status is absent (phase 2)' do
            expect(game.phase.status).not_to include('cross_company_trains')
            expect(game.can_buy_train_from_others?).to be(false)
          end

          it 'is true once the cross_company_trains status is active (phase 3+)' do
            advance_to_phase('3')
            expect(game.phase.status).to include('cross_company_trains')
            expect(game.can_buy_train_from_others?).to be(true)
          end
        end

        # ─────────────────────────────────────────────────────────────────────
        # DiscardTrain separates wagon and train crowding axes (Rule VII.12)
        # ─────────────────────────────────────────────────────────────────────

        describe Engine::Game::G18Cuba::Step::DiscardTrain do
          let(:step) { described_class.new(game, game.round) }

          it 'offers only regular trains when only the train axis is crowded' do
            4.times { give_train(major, '2') }
            give_train(major, '1w')
            advance_to_phase('4') # limit 3: 4 trains crowded, 1 wagon within limit

            offered = step.trains(major)
            expect(offered.none? { |t| game.wagon?(t) }).to be(true)
            expect(offered.size).to eq(4)
          end

          it 'offers only wagons when only the wagon axis is crowded' do
            give_train(major, '2')
            4.times { give_train(major, '1w') }
            advance_to_phase('4') # limit 3: 4 wagons crowded, 1 train within limit

            offered = step.trains(major)
            expect(offered.all? { |t| game.wagon?(t) }).to be(true)
            expect(offered.size).to eq(4)
          end

          it 'offers both wagons and trains when both axes are crowded' do
            4.times { give_train(major, '2') }
            4.times { give_train(major, '1w') }
            advance_to_phase('5') # limit 2: both axes crowded

            offered = step.trains(major)
            expect(offered.any? { |t| game.wagon?(t) }).to be(true)
            expect(offered.any? { |t| !game.wagon?(t) }).to be(true)
          end
        end
      end
    end
  end
end
