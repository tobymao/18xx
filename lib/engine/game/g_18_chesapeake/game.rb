# frozen_string_literal: true

require_relative 'meta'
require_relative 'share_pool'
require_relative 'round/stock'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18Chesapeake
      class Game < Game::Base
        include_meta(G18Chesapeake::Meta)
        include Entities
        include Map

        register_colors(green: '#237333',
                        red: '#d81e3e',
                        blue: '#0189d1',
                        lightBlue: '#a2dced',
                        yellow: '#FFF500',
                        orange: '#f48221',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 8000

        CERT_LIMIT = { 2 => 20, 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 1200, 3 => 800, 4 => 600, 5 => 480, 6 => 400 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[80 85 90 100 110 125 140 160 180 200 225 250 275 300 325 350 375],
          %w[75 80 85 90 100 110 125 140 160 180 200 225 250 275 300 325 350],
          %w[70 75 80 85 95p 105 115 130 145 160 180 200],
          %w[65 70 75 80p 85 95 105 115 130 145],
          %w[60 65 70p 75 80 85 95 105],
          %w[55y 60 65 70 75 80],
          %w[50y 55y 60 65],
          %w[40y 45y 50y],
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
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 7,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 6,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'D',
            num: 5,
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 3,
            events: [{ 'type' => 'close_companies' }],
          },
          { name: '6', distance: 6, price: 630, num: 2 },
          {
            name: 'D',
            distance: 999,
            price: 900,
            num: 20,
            available_on: '6',
            discount: { '4' => 200, '5' => 200, '6' => 200 },
          },
        ].freeze

        MUST_BID_INCREMENT_MULTIPLE = true
        ONLY_HIGHEST_BID_COMMITTED = true
        SELL_BUY_ORDER = :sell_buy

        def init_share_pool
          G18Chesapeake::SharePool.new(self)
        end

        def preprocess_action(action)
          case action
          when Action::LayTile
            queue_log! do
              check_special_tile_lay(action, baltimore)
              check_special_tile_lay(action, columbia)
            end
          end
        end

        def action_processed(action)
          case action
          when Action::LayTile
            flush_log!
          end
        end

        def stock_round
          G18Chesapeake::Round::Stock.new(self, [
            Step::DiscardTrain,
            Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Step::Bankrupt,
            Step::SpecialTrack,
            Step::SpecialToken,
            Step::BuyCompany,
            Step::Track,
            Step::Token,
            Step::Route,
            Step::Dividend,
            Step::DiscardTrain,
            Step::BuyTrain,
            [Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def setup
          cornelius.add_ability(Ability::Close.new(
            type: :close,
            when: 'bought_train',
            corporation: abilities(cornelius, :shares).shares.first.corporation.name,
          ))

          return unless two_player?

          cv_corporation = abilities(cornelius, :shares).shares.first.corporation

          @corporations.each do |corporation|
            next if corporation == cv_corporation

            presidents_share = corporation.shares_by_corporation[corporation].first
            presidents_share.percent = 30

            final_share = corporation.shares_by_corporation[corporation].last
            @share_pool.transfer_shares(final_share.to_bundle, @bank)
          end
        end

        def status_str(corp)
          return unless two_player?

          "#{corp.presidents_percent}% President's Share"
        end

        def timeline
          @timeline = [
            'At the end of each set of ORs the next available non-permanent (2, 3 or 4) train will be exported
           (removed, triggering phase change as if purchased)',
          ]
        end

        def check_special_tile_lay(action, company)
          abilities(company, :tile_lay, time: 'any') do |ability|
            hexes = ability.hexes
            next unless hexes.include?(action.hex.id)
            next if company.closed? || action.entity == company

            company.remove_ability(ability)
            @log << "#{company.name} loses the ability to lay #{hexes}"
          end
        end

        def columbia
          @companies.find { |company| company.name == 'Columbia - Philadelphia Railroad' }
        end

        def baltimore
          @companies.find { |company| company.name == 'Baltimore and Susquehanna Railroad' }
        end

        def cornelius
          @cornelius ||= @companies.find { |company| company.name == 'Cornelius Vanderbilt' }
        end

        def or_set_finished
          depot.export! if %w[2 3 4].include?(@depot.upcoming.first.name)
        end

        def float_corporation(corporation)
          super

          return unless two_player?

          @log << "#{corporation.name}'s remaining shares are transferred to the Market"
          bundle = ShareBundle.new(corporation.shares_of(corporation))
          @share_pool.transfer_shares(bundle, @share_pool)
        end
      end
    end
  end
end
