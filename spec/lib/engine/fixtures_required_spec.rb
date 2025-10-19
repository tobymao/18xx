# frozen_string_literal: true

require 'spec_helper'

require 'json'

SKIP_ALPHA = Set.new(['18Norway', '1824 Cisleithania'])

SKIP_BETA_PROD = {

  # :final_train is only in 2p; '1846 2p Variant' is treated as a separate title
  '1846' => [:final_train],

  # this is a very contrived game end state and is covered in an 1846 test
  '1846 2p Variant' => [:all_closed],

  # breaking the $15K bank without reaching the final train rank is very rare
  '1861' => [:bank],
  '1867' => [:bank],

  # no examples of these game end reasons were found in the live database
  '1848' => [:closed_five],
  '1849' => [:bankrupt],
  '1849: Kingdom of the Two Sicilies' => [:bankrupt],
  '1866' => [:stock_market],
  '1893' => [:bankrupt],
  '18Ardennes' => [:bankrupt],
  '18Carolinas' => %i[stock_market bankrupt],
  '18EU' => [:bankrupt],
  '18 Los Angeles 2' => %i[bankrupt all_closed],
  '18 Los Angeles' => %i[bankrupt all_closed final_train],
  '18NY 1st Edition' => %i[bankrupt closed],
  '18NY' => %i[bankrupt closed],
  '18Neb' => [:bankrupt],
  '18NewEngland 2: Northern States' => %i[stock_market bankrupt],
  '18NewEngland' => [:bankrupt],
  '18TN' => [:bankrupt],
  '18Texas' => [:bankrupt],
  '18Tokaido' => [:bank],
  '18VA' => [:bankrupt],
  '18ZOO - Map A' => [:stock_market],
  '18ZOO - Map B' => [:stock_market],
  '18ZOO - Map C' => [:stock_market],
  '18ZOO - Map D' => %i[stock_market fixed_round],
  '18ZOO - Map E' => %i[stock_market fixed_round],
  '18ZOO - Map F' => %i[stock_market fixed_round],
  '18ZOO' => %i[stock_market fixed_round],
}.freeze

def fixtures(meta)
  dir = "#{FIXTURES_DIR}/#{meta.fixture_dir_name}"
  return [] unless File.directory?(dir)

  Dir.glob("#{dir}/*.json")
end

module Engine
  describe 'fixtures' do
    metas = Engine::GAME_METAS.group_by { |m| m::DEV_STAGE }

    describe 'alpha games have at least one completed game' do
      metas[:alpha].each do |meta|
        next if SKIP_ALPHA.include?(meta.title)

        it meta.title do
          completed = fixtures(meta).count do |fixture|
            data = JSON.parse(File.read(fixture))
            data['game_end_reason'] != 'manually_ended'
          end
          expect(completed).to be >= 1
        end
      end
    end

    describe 'beta/production games have at least one completed game for each game_end_reason' do
      (metas[:beta] + metas[:production]).each do |meta|
        describe meta.title do
          game_end_counts = fixtures(meta).each_with_object(Hash.new(0)) do |fixture, counts|
            data = JSON.parse(File.read(fixture))
            counts[data['game_end_reason']&.to_sym] += 1
          end

          Engine.game_by_title(meta.title)::GAME_END_CHECK.each do |reason, _timing|
            next if (SKIP_BETA_PROD[meta.title] || []).include?(reason)

            it "has a fixture for :#{reason}" do
              expect(game_end_counts[reason]).to be >= 1
            end
          end
        end
      end
    end
  end
end
