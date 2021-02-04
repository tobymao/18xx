# frozen_string_literal: true

require './spec/spec_helper'

require 'engine'

module Engine
  describe Hex do
    let(:game) { Engine.game_by_title('1889').new(%w[a b]) }
    subject { game.hex_by_id('H7') }

    describe '#neighbor_direction' do
      it 'is a neighbor' do
        expect(subject.neighbor_direction(game.hex_by_id('I8'))).to eq(5)
      end

      it 'is not a neighbor' do
        expect(subject.neighbor_direction(game.hex_by_id('I4'))).to be_falsey
      end
    end

    describe '#lay' do
      let(:green_tile) { game.tile_by_id('15-0') }
      let(:brown_tile) { game.tile_by_id('611-0') }
      let(:corp_1) { game.corporation_by_id('AR') }
      let(:corp_2) { game.corporation_by_id('IR') }

      context 'laying green' do
        it 'sets @tile to the given tile' do
          subject.lay(green_tile)
          expect(subject.tile).to have_attributes(name: '15')
        end

        it 'preserves a placed token' do
          subject.tile.cities[0].place_token(corp_1, corp_1.next_token)

          subject.lay(green_tile)
          expect(subject.tile.cities[0].tokens[0]).to have_attributes(corporation: corp_1)
          expect(subject.tile.cities[0].tokens[1]).to be_nil
        end

        it 'preserves a token reservation' do
          subject.tile.cities[0].reservations = [corp_1]

          subject.lay(green_tile)
          expect(subject.tile.cities[0].reservations).to eq([corp_1])
        end
      end

      context 'laying brown' do
        before(:each) { subject.lay(green_tile) }

        it 'sets @tile to the given tile' do
          subject.lay(brown_tile)

          expect(subject.tile).to have_attributes(name: '611')
        end

        it 'preserves a placed token' do
          subject.tile.cities[0].place_token(corp_1, corp_1.next_token)

          subject.lay(brown_tile)
          expect(subject.tile.cities[0].tokens[0]).to have_attributes(corporation: corp_1)
          expect(subject.tile.cities[0].tokens[1]).to be_nil
        end

        it 'preserves 2 placed tokens' do
          subject.tile.cities[0].place_token(corp_1, corp_1.next_token)
          subject.tile.cities[0].place_token(corp_2, corp_2.next_token)

          subject.lay(brown_tile)

          expect(subject.tile.cities[0].tokens[0]).to have_attributes(
            corporation: corp_1,
            used: true,
          )

          expect(subject.tile.cities[0].tokens[1]).to have_attributes(
            corporation: corp_2,
            used: true,
          )
        end

        it 'preserves a placed token and a reservation' do
          subject.tile.cities[0].reservations = [corp_1]
          subject.tile.cities[0].place_token(corp_2, corp_2.next_token)

          subject.lay(brown_tile)

          expect(subject.tile.cities[0].tokens[0]).to be_nil
          expect(subject.tile.cities[0].tokens[1]).to have_attributes(corporation: corp_2)
          expect(subject.tile.cities[0].reservations).to eq([corp_1])
        end
      end

      context 'OO tiles' do
        [
          {
            game: '18Chesapeake',
            desc: 'Philadelphia yellow to green w/ C&A token in bottom city',
            setup: {
              hex: 'J4',
              corporations: [
                {
                  name: 'C&A',
                  token: 0,
                },
              ],
              tile: ['preprinted', 0],
            },
            tiles_with_rotations_to_lay: {
              'X3' => [0, 1, 3, 4],
              'X4' => [0, 3],
              'X5' => [0, 3],
            },
          },
          {
            game: '18Chesapeake',
            desc: 'Baltimore green to brown w/ B&O and PRR tokens',
            setup: {
              hex: 'H6',
              corporations: [
                {
                  name: 'B&O',
                  token: 1,
                },
                {
                  name: 'PRR',
                  token: 0,
                },
              ],
              tile: ['X3', 2],
            },
            tiles_with_rotations_to_lay: {
              'X7' => [3],
            },
          },
          {
            game: '18Chesapeake',
            desc: 'Baltimore brown to gray w/ B&O and PRR tokens',
            setup: {
              hex: 'H6',
              corporations: [
                {
                  name: 'B&O',
                  token: 0,
                },
                {
                  name: 'PRR',
                  token: 0,
                },
              ],
              tile: ['X7', 3],
            },
            tiles_with_rotations_to_lay: {
              'X9' => [3],
            },
          },
          {
            game: '18Chesapeake',
            desc: 'Baltimore green to brown w/ PRR token and B&O reservation',
            setup: {
              hex: 'H6',
              corporations: [
                {
                  name: 'B&O',
                  token: nil,
                },
                {
                  name: 'PRR',
                  token: 0,
                },
              ],
              tile: ['X3', 2],
            },
            tiles_with_rotations_to_lay: {
              'X7' => [3],
            },
          },
        ].each do |spec|
          context "#{spec[:game]} #{spec[:desc]}" do
            let(:game) { Engine.game_by_title(spec[:game]).new(%w[a b c]) }
            let(:hex) { game.hex_by_id(spec[:setup][:hex]) }
            let(:initial_tile) do
              tile_name, rotation = spec[:setup][:tile]
              if tile_name == 'preprinted'
                hex.tile
              else
                tile = game.tile_by_id("#{tile_name}-0")
                tile.rotate!(rotation)
                tile
              end
            end

            # setup
            before(:each) do
              # lay initial tile
              hex.lay(initial_tile) unless hex.tile == initial_tile

              # add initial corporation tokens
              spec[:setup][:corporations].each do |corp|
                corporation = game.corporation_by_id(corp[:name])

                initial_tile.cities[corp[:token]].place_token(corporation, corporation.next_token) if corp[:token]
              end
            end

            spec[:tiles_with_rotations_to_lay].each do |tile_name, rotations|
              rotations.each do |rotation|
                it "correctly lays #{tile_name} with rotation #{rotation}" do
                  # get the tile and rotate it
                  tile = game.tile_by_id("#{tile_name}-0")
                  tile.rotate!(rotation)

                  # lay it
                  hex.lay(tile)

                  spec[:setup][:corporations].each do |corp|
                    corporation = game.corporation_by_id(corp[:name])

                    next unless corp[:token]

                    # check corp still has a token, grab the new city with
                    # their token
                    cities = tile.cities.select { |c| c.tokened_by?(corporation) }
                    expect(cities.size).to eq(1)
                    city = cities.first

                    # expect the connection between the edge and the bottom
                    # city from the preprinted OO tile to still be present
                    old_city = initial_tile.cities[corp[:token]]
                    old_edges = old_city.exits

                    # make sure all old edges are in the new city
                    edges = city.exits
                    expect(edges).to include(*old_edges)
                  end
                end
              end
            end
          end
        end
      end

      context 'icon preservation' do
        {
          '1846' => [
            {
              hex: 'D6',
              initial_icons: %w[meat],
              lays: [{ tile: '298', rotation: 0, icons: %w[meat] },
                     { tile: '299', rotation: 0, icons: %w[meat] },
                     { tile: '300', rotation: 0, icons: %w[meat] }],
            },
            {
              hex: 'D14',
              initial_icons: %w[port lsl],
              lays: [{ tile: '5', rotation: 1, icons: %w[port lsl] },
                     { tile: '14', rotation: 1, icons: %w[port lsl] },
                     { tile: '611', rotation: 5, icons: %w[port lsl] },
                     { tile: '51', rotation: 5, icons: %w[port lsl] }],
            },
            {
              hex: 'G19',
              initial_icons: %w[port port],
              lays: [{ tile: '14', rotation: 1, icons: %w[port port] }],
            },
            {
              hex: 'J4',
              initial_icons: %w[ic],
              lays: [{ tile: '9', rotation: 0, icons: [] }],
            },
          ],
          '1882' => [
            {
              hex: 'B4',
              initial_icons: %w[NWR],
              lays: [{ tile: '8', rotation: 5, icons: %w[NWR] },
                     { tile: 'original', rotation: 0, icons: %w[NWR] }],
            },
          ],
          '1889' => [
            {
              hex: 'G10',
              initial_icons: %w[port],
              lays: [{ tile: '437', rotation: 0, icons: %w[port] }],
            },
            {
              hex: 'I12',
              initial_icons: %w[port],
              lays: [{ tile: '58', rotation: 1, icons: [] }],
            },
          ],
        }.each do |game_title, specs|
          game_class = Engine.game_by_title(game_title)
          players = Engine.player_range(game_class).max.times.map { |n| "Player #{n + 1}" }
          game = game_class.new(players)
          specs.each do |spec|
            context "hex #{spec[:hex]} in #{game_title}" do
              hex = game.hex_by_id(spec[:hex])

              it 'has the correct initial icons' do
                expect(hex.tile.icons.map(&:name)).to eq(spec[:initial_icons])
              end

              spec[:lays].each do |lay|
                it "has #{lay[:icons]} after laying tile \"#{lay[:tile]}\"" do
                  tile = lay[:tile] == 'original' ? hex.original_tile : Tile.for(lay[:tile])
                  tile.rotate!(lay[:rotation])

                  hex.lay(tile)

                  expect(hex.tile.icons.map(&:name)).to eq(lay[:icons])
                end
              end
            end
          end
        end
      end
    end
  end
end
