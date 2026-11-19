# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe '18OE Minor C operating position (§15.3)' do
  include G18OESpecHelpers

  [Engine::Game::G18OE::Game, Engine::Game::G18OEUKFR::Game].each do |klass|
    context klass.title do
      let(:game) { new_game(%w[a b c], klass: klass) }
      let(:player) { game.players.first }
      let(:minor) { start_minor!(game, 'C', player, 'UK') }

      def operating_round!(number = 1)
        enter_round!(game, game.operating_round(number)).tap(&:setup)
      end

      def choose!(round, entity, position)
        act!(round, Engine::Action::Choose.new(entity, choice: position))
      end

      def merge_c!(major)
        game.add_minor_charter!(minor, major)
        game.minor_regional_order.delete(minor)
        game.close_corporation(minor)
        major
      end

      def group_with_minor
        first = start_regional!(game, 'PLM', player)
        holder = minor
        last = start_regional!(game, 'LNWR', player)
        major = start_major!(game, 'GWR', player)
        [first, holder, last, major]
      end

      it 'blocks operating actions until C chooses with the normal operator already initialized' do
        first = start_regional!(game, 'PLM', game.players.last)
        minor
        round = operating_round!

        expect(round.current_operator).to eq(first)
        expect(round.operating_position_entity).to be_nil
        expect(round.operating_position).to be_nil
        expect(round.current_entity).to eq(minor)
        expect(round.actions_for(first)).not_to include('lay_tile', 'place_token', 'choose')
        expect(round.active_step.actions(minor)).to eq(['choose'])
        operation_logs = game.log.map(&:message).select { |message| message.include?(' operates ') }
        expect(operation_logs).to eq(["#{first.owner.name} operates #{first.name}"])
        expect { act!(round, Engine::Action::Pass.new(first)) }.to raise_error(Engine::GameError)

        choose!(round, minor, 'first')
        expect(round.operating_position_entity).to eq(minor)
        expect(round.operating_position).to eq('first')
        expect(round.current_operator).to eq(minor)
        expect(game.log.map(&:message).select { |message| message.include?(' operates ') }).to eq(operation_logs)
      end

      {
        'first' => [1, 2, 0, 3],
        'normal' => [2, 1, 0, 3],
        'last' => [2, 0, 1, 3],
      }.each do |position, indices|
        it "moves C #{position} within the round's existing minor/regional order" do
          ordinary = group_with_minor
          permanent = game.minor_regional_order.dup
          round = operating_round!
          round.entities = [ordinary[2], ordinary[1], ordinary[0], ordinary[3]]
          choose!(round, minor, position)

          expect(round.entities).to eq(indices.map { |index| ordinary[index] })
          expect(round.current_operator).to eq(round.entities.first)
          expect(game.minor_regional_order).to eq(permanent)
        end
      end

      {
        'first' => [0, 2, 1, 3],
        'normal' => [0, 1, 2, 3],
        'last' => [0, 1, 3, 2],
      }.each do |position, indices|
        it "runs an acquiring major #{position} within the major/national group" do
          regional = start_regional!(game, 'PLM', player)
          high = start_major!(game, 'LNWR', player)
          holder = merge_c!(start_major!(game, 'GWR', player))
          low = start_major!(game, 'MIDI', player)
          low.type = :national
          ordinary = [regional, high, holder, low]
          price = holder.share_price
          stack = price.corporations.dup
          round = operating_round!

          expect(round.current_entity).to eq(holder)
          expect(round.current_operator).to eq(regional)
          choose!(round, holder, position)

          expect(round.entities).to eq(indices.map { |index| ordinary[index] })
          expect(round.current_operator).to eq(regional)
          expect(holder.share_price).to eq(price)
          expect(price.corporations).to eq(stack)
        end
      end

      it 'prompts anew each OR and restores normal order when selected' do
        ordinary = group_with_minor
        round = operating_round!
        choose!(round, minor, 'first')
        following = operating_round!(2)

        expect(following.current_operator).to eq(ordinary.first)
        expect(following.active_step.actions(minor)).to eq(['choose'])
        choose!(following, minor, 'normal')
        expect(following.entities).to eq(ordinary)
      end

      it 'preserves the chosen position when the unoperated railroads are reordered' do
        ordinary = group_with_minor
        round = operating_round!
        choose!(round, minor, 'last')
        round.recalculate_order

        expect(round.entities).to eq([ordinary[0], ordinary[2], minor, ordinary[3]])
      end

      it 'keeps the chosen railroad and position for the OR when the charter ability moves' do
        ordinary = group_with_minor
        round = operating_round!
        choose!(round, minor, 'last')
        ability = minor.abilities.first
        minor.remove_ability(ability)
        ordinary[3].add_ability(ability)
        round.recalculate_order

        expect(round.entities).to eq([ordinary[0], ordinary[2], minor, ordinary[3]])
      end

      it 'does not move a completed C or the current railroad when the remaining order is recalculated' do
        ordinary = group_with_minor
        round = operating_round!
        choose!(round, minor, 'first')
        round.force_next_entity!
        round.recalculate_order

        expect(round.entities).to eq([minor, ordinary[0], ordinary[2], ordinary[3]])
        expect(round.current_operator).to eq(ordinary[0])
        expect(round.entity_index).to eq(1)
      end

      it 'never repeats the opening choice when the next railroad begins' do
        group_with_minor
        round = operating_round!
        choose!(round, minor, 'first')
        round.force_next_entity!

        expect(round.current_operator.id).to eq('PLM')
        expect(round.active_step).not_to be_a(Engine::Game::G18OE::Step::ChooseOperatingPosition)
        expect(round.actions_for(minor)).not_to include('choose')
      end

      it 'rejects another railroad choosing before changing the operating order' do
        first, = group_with_minor
        round = operating_round!
        order = round.entities.dup

        expect { choose!(round, first, 'first') }.to raise_error(Engine::GameError)
        expect(round.entities).to eq(order)
        expect(round.current_operator).to eq(first)
      end

      it 'rejects an invalid position without changing the current operator' do
        first, = group_with_minor
        round = operating_round!
        order = round.entities.dup

        expect { choose!(round, minor, 'anywhere') }.to raise_error(Engine::GameError)
        expect(round.entities).to eq(order)
        expect(round.current_operator).to eq(first)
      end

      it 'rejects a second choice without changing order' do
        group_with_minor
        round = operating_round!
        choose!(round, minor, 'first')
        order = round.entities.dup

        expect { choose!(round, minor, 'last') }.to raise_error(Engine::GameError)
        expect(round.entities).to eq(order)
      end

      it 'does not prompt before C floats' do
        first = start_regional!(game, 'PLM', player)
        round = operating_round!

        expect(round.current_operator).to eq(first)
        expect(round.actions_for(game.corporation_by_id('C'))).not_to include('choose')
      end

      it 'does not prompt while C is abandoned' do
        first = start_regional!(game, 'PLM', player)
        game.abandon_minor!(minor)
        round = operating_round!

        expect(round.current_operator).to eq(first)
        expect(round.current_entity).to eq(first)
      end

      it 'gives the power to a major buying abandoned C' do
        major = start_major!(game, 'PLM', player)
        ability = minor.abilities.first
        game.abandon_minor!(minor)
        game.add_minor_charter!(minor, major)
        round = operating_round!

        expect(major.abilities).to include(ability)
        expect(round.current_operator).to eq(major)
        expect(round.active_step.actions(major)).to eq(['choose'])
      end

      it 'waits until the next OR when a major acquires abandoned C after operations start' do
        first = start_major!(game, 'PLM', player)
        second = start_major!(game, 'GWR', player)
        game.abandon_minor!(minor)
        round = operating_round!
        expect(round.current_operator).to eq(first)

        game.add_minor_charter!(minor, second)
        round.force_next_entity!
        expect(round.current_operator).to eq(second)
        expect(round.actions_for(second)).not_to include('choose')

        following = operating_round!(2)
        expect(following.current_operator).to eq(first)
        expect(following.current_entity).to eq(second)
      end

      it 'does not grant the power to a national' do
        major = merge_c!(start_major!(game, 'PLM', player))
        major.type = :national
        round = operating_round!

        expect(round.current_operator).to eq(major)
        expect(round.actions_for(major)).not_to include('choose')
      end

      it 'follows the original ability when it moves or is removed' do
        first = start_major!(game, 'PLM', player)
        second = start_major!(game, 'GWR', player)
        ability = minor.abilities.first
        merge_c!(first)
        first.remove_ability(ability)
        second.add_ability(ability)
        round = operating_round!

        expect(round.current_entity).to eq(second)
        second.remove_ability(ability)
        following = operating_round!(2)
        expect(following.current_operator).to eq(first)
      end

      [[], [:long_endgame]].each do |rules|
        context "with final-round options #{rules}" do
          let(:game) { new_game(%w[a b c], klass: klass, optional_rules: rules) }

          it 'offers the opening choice in the final OR and preserves the appropriate operating steps' do
            group_with_minor
            game.buy_train(minor, game.depot.upcoming.first, :free)
            allow(game).to receive(:can_run_route?).with(minor).and_return(true)
            game.instance_variable_set(:@final_turn, game.turn)
            game.instance_variable_set(:@operating_rounds, 2)
            round = operating_round!(2)

            expect(round.active_step.actions(minor)).to eq(['choose'])
            choose!(round, minor, 'first')
            expect(round.current_operator).to eq(minor)
            expect(round.actions_for(minor).include?('lay_tile')).to eq(rules.include?(:long_endgame))
          end
        end
      end

      it 'operates each railroad once when the abbreviated final OR automatically skips every turn' do
        ordinary = group_with_minor
        game.instance_variable_set(:@final_turn, game.turn)
        game.instance_variable_set(:@operating_rounds, 2)
        round = operating_round!(2)
        ordinary.each do |corporation|
          expect(game).to receive(:after_end_of_operating_turn).with(corporation).once.and_call_original
        end
        choose!(round, minor, 'first')

        expect(round).to be_finished
        expect(round.current_operator).to be_nil
      end

      it 'pays private revenue once before the choice and does not pay it again on selection' do
        group_with_minor
        company = game.company_by_id('PeC')
        give_company!(player, company)
        cash = player.cash
        round = operating_round!

        expect(player.cash).to eq(cash + company.revenue)
        choose!(round, minor, 'last')
        expect(player.cash).to eq(cash + company.revenue)
      end

      [true, false].each do |strict|
        it "rebuilds a recorded choice with strict=#{strict} into the same order and log" do
          group_with_minor
          round = operating_round!
          action = Engine::Action::Choose.new(minor, choice: 'last')
          recorded = action.to_h
          choose!(round, minor, 'last')
          expected_order = round.entities.map(&:id)
          expected_log = game.log.map(&:message)
          rebuilt = klass.new(%w[a b c], seed: 1, strict: strict)
          replay_player = rebuilt.players.first
          start_regional!(rebuilt, 'PLM', replay_player)
          start_minor!(rebuilt, 'C', replay_player, 'UK')
          start_regional!(rebuilt, 'LNWR', replay_player)
          start_major!(rebuilt, 'GWR', replay_player)
          rebuilt.instance_variable_set(:@loading, !strict)
          replay = enter_round!(rebuilt, rebuilt.operating_round(1)).tap(&:setup)
          act!(replay, Engine::Action::Choose.from_h(recorded, rebuilt))

          expect(rebuilt.loading).to eq(!strict)
          expect(replay.entities.map(&:id)).to eq(expected_order)
          expect(rebuilt.log.map(&:message)).to eq(expected_log)
        end
      end
    end
  end
end
