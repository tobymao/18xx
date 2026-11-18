# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module GFrost1831
      describe Game do
        let(:game) { Engine::Game::GFrost1831::Game.new(%w[P1 P2 P3], id: 1) }
        let(:corporation) { game.corporation_by_id('CM') }
        let(:messages) { game.log.map(&:message) }

        def place_government(row, col)
          game.instance_variable_set(:@government_marker, [row, col])
        end

        def in_operating_round(laid:)
          game.instance_variable_set(:@round, double(num_laid_track: laid))
        end

        def tile_on(hex_id, tile_name)
          hex = game.hex_by_id(hex_id)
          tile = game.tiles.find { |t| t.name == tile_name }
          hex.lay(tile)
          [hex, tile]
        end

        describe 'events' do
          it 'handles the parliament_opens and turmoil events of the trains' do
            types = game.class::TRAINS.flat_map { |train| train[:events] || [] }.map { |event| event['type'] }.uniq

            %w[parliament_opens turmoil].each do |type|
              expect(types).to include(type)
              expect(game).to respond_to("event_#{type}!")
            end
          end

          it 'runs the events when the first 3 and 4 trains are bought' do
            %w[3 4].each do |name|
              train = game.depot.upcoming.find { |t| t.name == name }
              game.phase.buying_train!(corporation, train, game.depot)
            end

            expect(game.parliament_open?).to be(true)
            expect(messages).to include('-- Event: Turmoil! --')
          end

          it 'opens Parliament' do
            expect(game.parliament_open?).to be(false)

            game.event_parliament_opens!

            expect(game.parliament_open?).to be(true)
            expect(messages).to include("-- Event: New London's Parliament opens! --")
          end
        end

        describe 'government marker' do
          it 'starts neutral at the centre' do
            expect(game.government_marker).to eq([3, 4])
            expect(game.government_neutral?).to be(true)
            expect(game.governing_faction_sym).to be_nil
          end

          it 'moves toward a faction and gives it the government' do
            game.move_government('TEC')

            expect(game.government_marker).to eq([2, 3])
            expect(game.governing_faction_sym).to eq('TEC')
            expect(ParliamentMovement.polarization_level(*game.government_marker)).to eq(1)
          end

          it 'reads the governing faction from the quadrant' do
            { [0, 1] => 'TEC', [0, 6] => 'LOR', [7, 1] => 'EXP', [7, 6] => 'GUA' }.each do |position, faction|
              place_government(*position)
              expect(game.governing_faction_sym).to eq(faction)
            end
          end

          it 'stays put at the maximum for a faction' do
            place_government(0, 1)
            game.move_government('TEC')

            expect(game.government_marker).to eq([0, 1])
            expect(messages).to include('Government marker already at maximum for Technicians')
          end

          it 'only moves to valid positions' do
            ParliamentMovement.all_positions.each do |row, col|
              Game::FACTION_NAMES.each_key do |faction|
                expect(ParliamentMovement.valid_position?(*ParliamentMovement.move(row, col, faction))).to be(true)
              end
            end
          end
        end

        describe 'faction influence' do
          it 'is capped by the phase limit' do
            6.times { expect(game.faction_influence_gain('LOR')).to be(true) }

            expect(game.faction_influence_gain('LOR')).to be(false)
            expect(game.faction_influence('LOR')).to eq(6)
            expect(messages).to include('Lords has reached the limit of 6 Influence in Parliament (cube discarded)')
          end

          it 'never goes below zero' do
            expect(game.faction_influence_lose('GUA')).to be(false)
            expect(game.faction_influence('GUA')).to eq(0)
          end
        end

        describe 'turmoil' do
          it 'has no consequences while the government is neutral' do
            game.event_turmoil!

            expect(messages).to include('Government is neutral — no consequences')
          end

          it 'changes no influence at level 1' do
            game.faction_influence_gain('GUA')
            place_government(2, 3)
            game.event_turmoil!

            expect(game.faction_influence('TEC')).to eq(0)
            expect(game.faction_influence('GUA')).to eq(1)
          end

          it 'moves influence from the opposition to the government from level 2' do
            game.faction_influence_gain('GUA')
            place_government(1, 2)
            game.event_turmoil!

            expect(game.faction_influence('TEC')).to eq(1)
            expect(game.faction_influence('GUA')).to eq(0)
            expect(messages).to include('Government: Technicians (Level 2)', 'Opposition: Guardians',
                                        'Technicians gains 1 Influence in Parliament',
                                        'Guardians loses 1 Influence in Parliament')
          end
        end

        describe 'regulations' do
          it 'start at Normal' do
            expect(game.regulations.keys).to eq(%w[R1 R2 R3 R4])
            expect(game.regulations.values.map { |r| r[:position] }.uniq).to eq([Game::NORMAL])
          end

          it 'move one step at a time and stay between Loose and Tight' do
            game.move_regulation('R1', :up)
            game.move_regulation('R1', :up)
            expect(game.regulation_value('R1')).to eq(Game::TIGHT)

            3.times { game.move_regulation('R1', :down) }
            expect(game.regulation_value('R1')).to eq(Game::LOOSE)
          end

          describe 'R1 track laying' do
            let(:yellow) { game.tiles.find { |t| t.name == '7' } }
            let(:hex) { game.hex_by_id('E10') }

            def r1_cost(position, laid)
              game.regulations['R1'][:position] = position
              in_operating_round(laid: laid)
              game.tile_cost_with_discount(yellow, hex, corporation, corporation, 0)
            end

            it 'charges the second yellow tile at Normal' do
              expect(r1_cost(Game::NORMAL, 0)).to eq(0)
              expect(r1_cost(Game::NORMAL, 1)).to eq(20)
            end

            it 'charges no yellow tile at Loose and every yellow tile at Tight' do
              expect(r1_cost(Game::LOOSE, 1)).to eq(0)
              expect(r1_cost(Game::TIGHT, 0)).to eq(20)
            end
          end

          describe 'R2 track upgrade' do
            def upgrade_cost_at(position, tile)
              game.regulations['R2'][:position] = position
              game.upgrade_cost(tile, tile.hex, corporation, corporation)
            end

            def r2_extra(position, tile)
              upgrade_cost_at(position, tile) - upgrade_cost_at(Game::LOOSE, tile)
            end

            it 'charges plain track upgrades at Normal and every upgrade at Tight' do
              _hex, track = tile_on('E10', '7')
              _city_hex, city = tile_on('E8', '57')

              expect(r2_extra(Game::NORMAL, track)).to eq(20)
              expect(r2_extra(Game::NORMAL, city)).to eq(0)
              expect(r2_extra(Game::TIGHT, city)).to eq(20)
            end

            it 'leaves yellow tile lays on empty hexes to R1' do
              hex = game.hex_by_id('E10')

              expect(r2_extra(Game::TIGHT, hex.tile)).to eq(0)
            end
          end

          describe 'R3 corporation limit' do
            it 'sets the ownership limit from the regulation' do
              expect(corporation.max_ownership_percent).to eq(60)

              game.move_regulation('R3', :down)
              expect(corporation.max_ownership_percent).to eq(70)

              2.times { game.move_regulation('R3', :up) }
              expect(corporation.max_ownership_percent).to eq(50)
            end

            it 'lifts the limit while the corporation is in a no cert limit cell' do
              cell = game.stock_market.market.flatten.compact.find { |p| p.type == :no_cert_limit }
              corporation.share_price = cell
              game.apply_r3_limits

              expect(corporation.max_ownership_percent).to eq(100)
            end
          end
        end
      end
    end
  end
end
