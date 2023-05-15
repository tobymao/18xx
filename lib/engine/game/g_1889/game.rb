# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'step/special_track'
require_relative '../base'

module Engine
  module Game
    module G1889
      class Game < Game::Base
        include_meta(G1889::Meta)
        include Entities
        include Map

        register_colors(black: '#37383a',
                        orange: '#f48221',
                        brightGreen: '#76a042',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '¥%s'

        BANK_CASH = 7000

        CERT_LIMIT = { 2 => 25, 3 => 19, 4 => 14, 5 => 12, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 420, 3 => 420, 4 => 420, 5 => 390, 6 => 390 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = true

        MARKET = [
          %w[75 80 90 100p 110 125 140 155 175 200 225 255 285 315 350],
          %w[70 75 80 90p 100 110 125 140 155 175 200 225 255 285 315],
          %w[65 70 75 80p 90 100 110 125 140 155 175 200],
          %w[60 65 70 75p 80 90 100 110 125 140],
          %w[55 60 65 70p 75 80 90 100],
          %w[50y 55 60 65p 70 75 80],
          %w[45y 50y 55 60 65 70],
          %w[40y 45y 50y 55 60],
          %w[30o 40y 45y 50y],
          %w[20o 30o 40y 45y],
          %w[10o 20o 30o 40y],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 6,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 5,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'D',
            num: 4,
          },
          {
            name: '5',
            distance: 5,
            price: 450,
            num: 3,
            events: [{ 'type' => 'close_companies' }],
          },
          { name: '6', distance: 6, price: 630, num: 2 },
          {
            name: 'D',
            distance: 999,
            price: 1100,
            num: 20,
            available_on: '6',
            discount: { '4' => 300, '5' => 300, '6' => 300 },
          },
].freeze

        EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
        EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
        HOME_TOKEN_TIMING = :operating_round

        BEGINNER_GAME_PRIVATES = {
          2 => %w[DR SIR],
          3 => %w[DR SIR ER],
          4 => %w[DR SIR ER SMR],
          5 => %w[DR SIR ER SMR TR],
          6 => %w[DR SIR ER SMR TR MF],
        }.freeze

        BEGINNER_GAME_PRIVATE_REVENUES = {
          'TR' => 5,
          'MF' => 15,
          'ER' => 15,
          'SMR' => 20,
          'DR' => 20,
          'SIR' => 25,
        }.freeze

        BEGINNER_GAME_PRIVATE_VALUES = {
          'TR' => 20,
          'MF' => 40,
          'ER' => 40,
          'SMR' => 60,
          'DR' => 60,
          'SIR' => 90,
        }.freeze

        def setup
          remove_company(company_by_id('SIR')) if two_player? && !beginner_game?
          return unless beginner_game?

          neuter_private_companies
          close_unused_privates
          remove_blockers_and_icons

          # companies are randomly distributed to players and they buy their company
          @companies.sort_by! { rand }
          @players.zip(@companies).each { |p, c| buy_company(p, c) }
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            G1889::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def init_round
          return super unless beginner_game?

          stock_round
        end

        def optional_tiles
          remove_beginner_tiles unless beginner_game?
        end

        def active_players
          return super if @finished

          company = company_by_id('ER')
          current_entity == company ? [@round.company_sellers[company]] : super
        end

        def beginner_game?
          @optional_rules.include?(:beginner_game)
        end

        def remove_beginner_tiles
          @tiles.reject! { |tile| tile.id.start_with?('Beg') }
          @all_tiles.reject! { |tile| tile.id.start_with?('Beg') }
        end

        def remove_blockers_and_icons
          %w[C4 K4 B11 G10 I12 J9].each do |coords|
            hex = hex_by_id(coords)
            hex.tile.blockers.reject! { true }
            hex.tile.icons.reject! { true }
          end
        end

        def neuter_private_companies
          @companies.each { |c| neuter_company(c) }
        end

        def neuter_company(company)
          company_abilities = company.abilities.dup
          company_abilities.each { |ability| company.remove_ability(ability) }
          company.desc = 'Closes when the first 5 train is bought. Cannot be purchased by a corporation'
          company.value = BEGINNER_GAME_PRIVATE_VALUES[company.sym]
          company.revenue = BEGINNER_GAME_PRIVATE_REVENUES[company.sym]
          company.add_ability(Ability::NoBuy.new(type: 'no_buy'))
        end

        def close_unused_privates
          companies_dup = @companies.dup
          companies_dup.each { |c| remove_company(c) unless BEGINNER_GAME_PRIVATES[@players.size].include?(c.sym) }
        end

        def remove_company(company)
          company.close!
          @round.active_step.companies.delete(company) unless beginner_game?
          @companies.delete(company)
        end

        def buy_company(player, company)
          price = company.value
          company.owner = player
          player.companies << company
          player.spend(price, @bank)
          @log << "#{player.name} buys #{company.name} for #{format_currency(price)}"
        end
      end
    end
  end
end
