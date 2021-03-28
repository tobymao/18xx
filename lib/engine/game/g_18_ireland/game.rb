# frozen_string_literal: true

require_relative '../g_1849/map'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18Ireland
      class Game < Game::Base
        include_meta(G18Ireland::Meta)
        include G18Ireland::Entities
        include G1849::Map
        include G18Ireland::Map

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :par
        SELL_BUY_ORDER = :sell_buy

        # Two lays with one being an upgrade, second tile costs 20
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: :not_if_upgraded, upgrade: false, cost: 20 },
        ].freeze
        CURRENCY_FORMAT_STR = '£%d'

        BANK_CASH = 4000

        CERT_LIMIT = { 3 => 16, 4 => 12, 5 => 10, 6 => 8 }.freeze

        STARTING_CASH = { 3 => 330, 4 => 250, 5 => 200, 6 => 160 }.freeze

        LIMIT_TOKENS_AFTER_MERGER = 3

        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_round, bank: :full_or }.freeze

        MARKET = [
          ['', '62', '68', '76', '84', '92', '100p', '110', '122', '134', '148', '170', '196', '225', '260e'],
          ['', '58', '64', '70', '78', '85p', '94', '102', '112', '124', '136', '150', '172', '198'],
          ['', '55', '60', '65', '70p', '78', '86', '95', '104', '114', '125', '138'],
          ['', '50', '55', '60p', '66', '72', '80', '88', '96', '106'],
          ['', '38y', '50p', '55', '60', '66', '72', '80'],
          ['', '30y', '38y', '50', '55', '60'],
          ['', '24y', '30y', '38y', '50'],
          %w[0c 20y 24y 30y 38y],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 2,
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4H',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '6',
            on: '6H',
            train_limit: { minor: 2, major: 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '8',
            on: '8H',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '10',
            on: '10H',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        # @todo: how to do the opposite side
        # rusts turns them to the other side, go into the bankpool obsolete then removes completely
        TRAINS = [
          {
            name: '2H',
            num: 6,
            distance: 2,
            price: 80,
            obsolete_on: '8H',
            rusts_on: '6H',
          }, # 1H price:40
          {
            name: '4H',
            num: 5,
            distance: 4,
            price: 180,
            obsolete_on: '10H',
            rusts_on: '8H',
            events: [{ 'type' => 'corporations_can_merge' }],
          }, # 2H price:90
          {
            name: '6H',
            num: 4,
            distance: 6,
            price: 300,
            rusts_on: '10H',
          }, # 3H price:150
          {
            name: '8H',
            num: 3,
            distance: 8,
            price: 440,
            events: [{ 'type' => 'minors_cannot_start' }, { 'type' => 'close_companies' }],
          },
          {
            name: '10H',
            num: 2,
            distance: 10,
            price: 550,
            events: [{ 'type' => 'train_trade_allowed' }],
          },
          {
            name: 'D',
            num: 1,
            distance: 99,
            price: 770,
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge('corporations_can_merge' => ['Corporations can merge',
                                                                           'Players can vote to merge corporations'],
                                              'minors_cannot_start' => ['Minors cannot start'],
                                              'train_trade_allowed' =>
                                              ['Train trade in allowed',
                                               'Trains can be traded in for face value for more powerful trains'],)
        # Companies guaranteed to be in the game
        PROTECTED_COMPANIES = %w[DAR DK].freeze
        PROTECTED_CORPORATION = 'DKR'
        KEEP_COMPANIES = 5

        def bankruptcy_limit_reached?
          @players.reject(&:bankrupt).one?
        end

        def setup_preround
          # Only keep 3 private companies
          remove_companies = @companies.size - self.class::KEEP_COMPANIES

          companies = @companies.reject do |c|
            self.class::PROTECTED_COMPANIES.include?(c.id)
          end

          removed_companies = companies.sort_by! { rand }.take(remove_companies)
          removed = removed_companies.map do |comp|
            @companies.delete(comp)
            comp.close!
            comp.id
          end
          @log << "Removed #{removed.join(',')} companies"
        end

        def setup
          corporations, @future_corporations = @corporations.partition do |corporation|
            corporation.type == :minor
          end

          protect = corporations.find { |c| c.id == PROTECTED_CORPORATION }
          corporations.delete(protect)
          corporations.sort_by! { rand }
          removed_corporation = corporations.first
          @log << "Removed #{removed_corporation.id} corporation"
          corporations.delete(removed_corporation)
          corporations.unshift(protect)
          @corporations = corporations
        end

        def get_par_prices(entity, _corp)
          @game
            .stock_market
            .par_prices
            .select { |p| p.price * 2 <= entity.cash }
        end

        def after_buy_company(player, company, price)
          abilities(company, :shares) do |ability|
            ability.shares.each do |share|
              if share.president
                # DKR is pared at the highest par price below
                corporation = share.corporation
                par_price = price / 2
                share_price = @stock_market.par_prices.find { |sp| sp.price <= par_price }

                @stock_market.set_par(corporation, share_price)
                @share_pool.buy_shares(player, share, exchange: :free)
                # Receives the bid money
                @bank.spend(price, corporation)
                after_par(corporation)
                # And buys a 2 train
                train = @depot.upcoming.first
                buy_train(corporation, train, train.price)
              else
                share_pool.buy_shares(player, share, exchange: :free)
              end
            end
          end
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          # The Irish Mail
          return true if special && from.color == :blue && to.color == :red

          # Specials must observe existing rules otherwise
          super(from, to, false, selected_company: selected_company)
        end

        def home_token_locations(corporation)
          hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
          end
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::HomeToken,
            G18Ireland::Step::BuySellParShares,
          ])
        end

        def merger_round
          G18Ireland::Round::Merger.new(self, [
            Engine::Step::DiscardTrain,
            G18Ireland::Step::MergerVote,
            G18Ireland::Step::Merge,
          ], round_num: @round.round_num)
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::HomeToken,
            G18Ireland::Step::SpecialTrack,
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

        def new_or!
          if @round.round_num < @operating_rounds
            new_operating_round(@round.round_num + 1)
          else
            @turn += 1
            or_set_finished
            new_stock_round
          end
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @final_operating_rounds || @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              or_round_finished
              if @round.round_num < @operating_rounds || phase.name.to_i == 2
                new_or!
              else
                @log << "-- #{round_description('Merger', @round.round_num)} --"
                merger_round
              end
            when G18Ireland::Round::Merger
              new_or!
            when init_round.class
              reorder_players
              new_stock_round
            end
        end

        def event_corporations_can_merge!
          # All the corporations become available, as minors can now merge/convert to corporations
          @corporations.concat(@future_corporations)
          @future_corporations = []
        end

        def event_minors_cannot_start!
          @corporations, removed = @corporations.partition do |corporation|
            corporation.owned_by_player? || corporation.type != :minor
          end

          hexes.each do |hex|
            hex.tile.cities.each do |city|
              city.reservations.reject! { |reservation| removed.include?(reservation) }
            end
          end

          @log << 'Minors can no longer be started' if removed.any?
        end

        def event_train_trade_allowed!; end
      end
    end
  end
end
