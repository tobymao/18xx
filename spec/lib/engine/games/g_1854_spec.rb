# frozen_string_literal: true

require './spec/spec_helper'

require 'json'
require 'pry-byebug'

module Engine
  describe Game::G1854 do

    let(:players) { %w[alice ben chuck] }

    context 'testing 1854' do
      it 'should conduct initial auction' do
        game = Game::G1854::Game.new(players)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('P2'), price: 55),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('P2'), price: 60),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('P2'), price: 65),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('L3'), price: 160), add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('P2'), price: 70),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('P1'), price: 20),  add_auto_actions: true)
        game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
        game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('P3'), price: 70),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('L2'), price: 155),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('L2'), price: 160),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('L1'), price: 150),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('L2'), price: 165),  add_auto_actions: true)
        game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('L5'), price: 155),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('L5'), price: 160),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('L5'), price: 165),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('L5'), price: 170),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('L4'), price: 150),  add_auto_actions: true)
        game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('L5'), price: 175),  add_auto_actions: true)
        game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('L6'), price: 150),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('P4'), price: 170),  add_auto_actions: true)
        game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
        game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
        game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('P5'), price: 190),  add_auto_actions: true)
        # binding.pry
        game.process_action(Action::Par.new(game.current_entity, corporation: game.corporation_by_id('KE'), share_price: game.share_price_by_id("67,5,6")),  add_auto_actions: true)
        game.process_action(Action::BuyShares.new(game.current_entity, shares: game.share_by_id('KE_2')),  add_auto_actions: true)

        puts game.log.map {|m| m.message }
        puts "==="
        puts game.exception
        puts "==="
        puts game.current_entity.name

        puts game.players.map {|p| "#{p.name}:#{p.cash}" }.join(', ')

        expect(game.players.sort_by{|p| p.name }.map {|p| p.cash }).to eq([155, 265, 690])
        expect(game.current_entity).to be game.player_by_id("chuck")
      end

      # it 'should reduce price of first company until bought' do
      #   game = Game::G1854::Game.new(players)
      #   game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('L3'), price: 160), add_auto_actions: true)
      #   game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('L5'), price: 170),  add_auto_actions: true)
      #   game.process_action(Action::Bid.new(game.current_entity, company: game.company_by_id('L4'), price: 155),  add_auto_actions: true)
      #   game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
      #   game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
      #   game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
      #   game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
      #   game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
      #   game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
      #   game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
      #   game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
      #   game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
      #   game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
      #   game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)
      #   game.process_action(Action::Pass.new(game.current_entity),  add_auto_actions: true)

      #   puts game.log.map {|m| m.message }
      #   puts "==="
      #   puts game.exception
      #   puts "==="
      #   puts game.current_entity.name

      #   puts game.players.map {|p| "#{p.name}:#{p.cash}" }.join(', ')

      #   expect(game.players.sort_by{|p| p.name }.map {|p| p.cash }).to eq([860, 860, 860])
      #   expect(game.player_by_id("alice").companies).to eq([game.company_by_id('P1')])
      #   expect(game.current_entity).to be game.player_by_id("ben")
      # end
    end
  end
end
