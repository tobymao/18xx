# frozen_string_literal: true

require './spec/spec_helper'

require 'find'
require 'json'
require 'zlib'

# The fixture suite is split across the shard_NN_spec.rb files in
# spec/lib/engine/game/fixtures/ so parallel_tests can spread it over every
# worker instead of running all fixtures in one process. Each fixture is
# assigned to a shard by a stable hash of its path relative to FIXTURES_DIR, so
# adding a fixture never moves the others. describe/context names are
# unchanged, so `rspec spec/lib/engine/game/fixtures -e '1860 19354'` still
# selects a single fixture.
module FixtureSpecs
  SHARDS = 12

  def self.shard_for(fixture)
    relative = fixture.delete_prefix(FIXTURES_DIR).delete_prefix('/')
    Zlib.crc32(relative) % SHARDS
  end

  def self.fixtures(shard)
    Find.find(FIXTURES_DIR).select { |f| File.basename(f) =~ /.json/ }.sort.select { |f| shard_for(f) == shard }
  end

  def self.run(shard:)
    # Attribute the example groups to the shard_NN_spec.rb file rather than to
    # this one; parallel_tests records runtimes per file_path, and without this
    # every shard's runtime would be logged against spec/support/.
    location = caller(1..1)
    fixtures(shard).each { |fixture| define(fixture, location) }
  end

  def self.define(fixture, location)
    Engine.module_eval do
      game_fixture_dir_name = File.basename(File.dirname(fixture))
      meta = Engine.meta_by_title(game_fixture_dir_name)
      game_title = meta.title
      filename = File.basename(fixture)
      game_id = filename.split('.json').first
      describe game_title, caller: location do
        context game_id do
          before(:all) do
            @text = File.read(fixture)
            @data = JSON.parse(@text)
          end

          it 'has the correct title field in the file' do
            expect(@data['title']).to eq(game_title)
          end

          it "#{fixture} has the right directory name" do
            expect(game_fixture_dir_name).to eq(meta.fixture_dir_name)
          end

          describe 'formatted with `make fixture_format`' do
            it 'text is compressed' do
              expect(@text.lines.size).to eq(1)
            end

            it 'game descriptions and player names are removed' do
              @data['players'].each do |player|
                expect(player['name']).to match(/^(Player )?(\d+|[A-Z])$/)
              end

              if @data.dig('fixture_format', 'keep_user')
                expect(@data['players']).to include(@data['user'])
              else
                expect(@data['user']).to eq({ 'id' => 0, 'name' => 'You' })
              end

              if @data.dig('fixture_format', 'keep_description')
                expect(@data['description'].size).to be > 1
              else
                expect(@data['description']).to eq('')
              end
            end

            it 'has chat messages matching `fixture_format["chat"]`' do
              message_actions = @data['actions'].select { |a| a['type'] == 'message' }

              case @data.dig('fixture_format', 'chat')
              when 'scrub'
                expect(message_actions.all? { |a| a['message'] == 'chat' }).to eq(true)
              when 'keep'
                expect(message_actions.any? { |a| a['message'] != 'chat' && a['message'].size.positive? }).to eq(true)
              else
                expect(message_actions.size).to eq(0)
              end

              expect(@data['actions'].count { |a| a['type'] == 'message' && a['message'] != 'chat' }).to eq(0)
            end

            it 'is loaded and finished' do
              # this is required for opening fixtures in the browser at /fixture/<title>/<id>
              expect(@data['loaded']).to eq(true)
              expect(@data['status']).to eq('finished')
            end

            it 'all actions have an Integer id' do
              @data['actions'].each.with_index do |action, index|
                expect(action['id']).to(
                  be_kind_of(Integer),
                  "Expected action at index #{index} to be an Integer instead of #{action['id']}."
                )
              end
            end

            it 'player scores are Integers' do
              @data['result'].each do |player, score|
                expect(score).to(
                  be_kind_of(Integer),
                  "Expected stored JSON score #{score} for player '#{player}' to be an Integer",
                )
              end
            end

            it 'has a non-null game_end_reason' do
              expect(@data['game_end_reason']).not_to eq(nil)
            end
          end

          [false, true].each do |strict|
            describe "with strict: #{strict}" do
              describe 'running full game' do
                before(:all) do
                  @game = Engine::Game.load(@data, strict: strict).maybe_raise!
                end

                it 'is finished and matches result exactly' do
                  result = @data['result']

                  game_result = JSON.parse(JSON.generate(@game.result))
                  expect(game_result).to eq(result)
                  expect(@game.finished).to eq(true)
                end

                it 'game_end_reason matches' do
                  game_end_reason = @data['game_end_reason']&.to_sym

                  expect(@game.game_end_reason).to eq(game_end_reason)
                end

                it "last N actions in game match fixture's test_last_actions" do
                  test_last_actions = @data['test_last_actions']
                  next unless test_last_actions

                  actions = @data['actions']
                  (1..(test_last_actions.to_i)).each do |index|
                    run_action = @game.actions[@game.actions.size - index].to_h
                    expect(run_action).to eq(actions[actions.size - index])
                  end
                end

                it 'all expected cash is accounted for' do
                  starting_cash = @game.bank_starting_cash
                  ending_cash = @game.spenders.sum(&:cash)

                  expect(ending_cash).to be_kind_of(Integer)
                  expect(ending_cash).to eq(starting_cash)
                end

                it "all player debt came from the Bank's @debt and is accounted for" do
                  total_debt = [@game.bank, *@game.players].sum(&:debt)
                  expect(total_debt).to eq(0)
                end
              end
            end
          end
        end
      end
    end
  end
end
