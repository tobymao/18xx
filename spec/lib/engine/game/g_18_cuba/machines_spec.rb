# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

module Engine
  module Game
    module G18Cuba
      describe Game do
        include G18CubaSpecHelpers

        let(:players) { %w[a b c] }
        let(:game) { Engine::Game::G18Cuba::Game.new(players) }
        let(:player) { game.players.first }
        let(:ju) { game.corporation_by_id('JU') }

        def operate_until_buy_train
          act(Action::Pass) until game.round.operating? && game.round.active_step.is_a?(G18Cuba::Step::BuyTrain)
        end

        def buy_cheapest_train(corporation)
          step = game.round.active_step
          train, variant = step.buyable_trains(corporation).reject { |t| game.wagon?(t) }
                               .flat_map { |t| step.buyable_train_variants(t, corporation).map { |v| [t, v] } }
                               .min_by { |_, v| v[:price] }
          act(Action::BuyTrain, corporation, train: train, price: variant[:price], variant: variant[:name])
        end

        def minor_in_buy_machine
          float_minor!(ju, player)
          operate_until_buy_train
          buy_cheapest_train(ju)
          act(Action::Pass, ju) if game.round.active_step.is_a?(G18Cuba::Step::BuyTrain)
        end

        def buy_machine(generation)
          act(Action::Choose, ju, choice: generation)
        end

        describe G18Cuba::Step::BuyMachine do
          it 'offers machine generations by phase' do
            minor_in_buy_machine
            step = game.round.active_step

            expect(step).to be_a(described_class)
            expect(step.choices.keys).to eq(['yellow'])
            expect(step.choices['yellow']).to include('$25')
            expect { buy_machine('green') }.to raise_error(GameError)

            game.phase.next! until game.phase.name == '3'
            expect(step.choices.keys).to eq(%w[yellow green])

            game.phase.next! until game.phase.name == '5'
            expect(step.choices.keys).to eq(%w[yellow green brown])
          end

          it 'buys up to three machines from the cheapest space' do
            minor_in_buy_machine
            step = game.round.active_step
            minor_cash = ju.cash
            bank_cash = game.bank.cash

            [25, 30, 35].each do |price|
              buy_machine('yellow')
              minor_cash -= price
              bank_cash += price
              expect([ju.cash, game.bank.cash]).to eq([minor_cash, bank_cash])
            end

            expect(step.actions(ju)).to eq([])
            expect(game.machine_price(:yellow)).to eq(40)
            expect(game.status_str(ju)).to eq('Machines: yellow, yellow, yellow')
          end

          it 'gives a major no action and no skip line' do
            major = game.corporation_by_id('MS')
            float_major!(major)
            operate_until_buy_train
            step = game.round.steps.find { |s| s.is_a?(described_class) }
            expect(step.actions(major)).to eq([])

            buy_cheapest_train(major)
            act(Action::Pass, major) if game.round.active_step.is_a?(G18Cuba::Step::BuyTrain)

            expect(game.log.map(&:message).grep(/skips buy machines/)).to be_empty
          end

          it 'does not offer a generation the minor cannot afford' do
            float_minor!(ju, player)
            operate_until_buy_train
            2.times { buy_cheapest_train(ju) }
            step = game.round.active_step
            expect(step).to be_a(described_class)

            buy_machine('yellow')

            expect(game.machine_price(:yellow)).to be > ju.cash
            expect(step.actions(ju)).to eq([])
          end

          context 'with four minors' do
            let(:players) { %w[a b c d] }
            let(:minors) { %w[JU HG HY DQ].map { |id| game.corporation_by_id(id) } }

            it 'stops offering yellow once all ten are sold' do
              float_minors!(minors.zip(game.players, %w[M1 M2 M4 M5]).to_h { |m, pl, c| [m, [pl, c]] })

              minor = nil
              minors.size.times do
                operate_until_buy_train
                minor = game.current_entity
                buy_cheapest_train(minor)
                act(Action::Pass, minor) if game.round.active_step.is_a?(G18Cuba::Step::BuyTrain)
                while game.round.active_step.is_a?(described_class) && game.round.active_step.choices.key?('yellow')
                  act(Action::Choose, minor, choice: 'yellow')
                end
              end

              expect(minors.sum { |m| game.machines(m).count(:yellow) }).to eq(10)
              expect(game.machines(minor).size).to be < Machines::MACHINE_LIMIT
              expect(minor.cash).to be >= Machines::MACHINES[:yellow][:prices].max
              expect(game.buyable_machine_generations(minor)).to be_empty
              act(Action::Pass) until game.round.is_a?(Engine::Round::Stock)
              expect(game.exception).to be_nil
            end
          end
        end
      end
    end
  end
end
