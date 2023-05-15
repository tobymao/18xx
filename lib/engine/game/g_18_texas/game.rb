# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'map'
require_relative 'entities'

module Engine
  module Game
    module G18Texas
      class Game < Game::Base
        include_meta(G18Texas::Meta)
        include Entities
        include Map

        CURRENCY_FORMAT_STR = '$%s'
        BANK_CASH = 8_000
        CERT_LIMIT = { 2 => 21, 3 => 15, 4 => 12, 5 => 10 }.freeze
        STARTING_CASH = { 2 => 670, 3 => 500, 4 => 430, 5 => 400 }.freeze
        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :float
        TRACK_RESTRICTION = :semi_restrictive
        AXES = { x: :number, y: :letter }.freeze
        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :operate
        TREASURY_SHARE_LIMIT = 50
        EBUY_OTHER_VALUE = false

        TOKEN_FEE = {
          'T&P' => 140,
          'SP' => 140,
          'MP' => 100,
          'MKT' => 100,
          'SSW' => 60,
          'SAA' => 60,
        }.freeze

        MARKET = [
          %w[82 90 100 110 122 135 150 165 180 200 220 245 270 300 330 360 400],
          %w[75 82 90 100 110 122 135 150 165 180 200 220 245 270],
          %w[70 75 82 90 100p 110 122 135 150 165 180],
          %w[65 70 75 82p 90p 100 110 122],
          %w[60 65 70p 75p 82 90],
          %w[50 60 65 70 75],
          %w[40 50 60 65],
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
        },
        {
          name: '4',
          on: '4',
          train_limit: 3,
          tiles: %i[yellow green],
          operating_rounds: 2,
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
          name: '8',
          on: '8',
          train_limit: 2,
          tiles: %i[yellow green brown gray],
          operating_rounds: 3,
        },
      ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 5,
          },
          {
            name: '3',
            distance: 3,
            price: 200,
            rusts_on: '6',
            num: 4,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '8',
            num: 3,
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 2,
            events: [{ 'type' => 'close_companies' }],
          },
          { name: '6', distance: 6, price: 600, num: 2 },
          { name: '8', distance: 8, price: 800, num: 4 },
        ].freeze

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G18Texas::Step::CompanyPendingPar,
            G18Texas::Step::SimultaneousAuction,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G18Texas::Step::CompanyPendingPar,
            Engine::Step::BuySellParShares,
          ])
        end

        def init_company_abilities
          random_corporation = @corporations[rand % @corporations.size]
          random_shares = []
          @companies.each do |company|
            next unless (ability = abilities(company, :shares))

            real_shares = []
            ability.shares.each do |share|
              case share
              when 'random_president'
                new_share = random_corporation.shares[0]
                real_shares << new_share
                random_shares << new_share
                company.desc = "Purchasing player takes a president's share (20%) of #{random_corporation.name} \
              and immediately sets its par value. #{company.desc}"
                @log << "#{company.name} comes with the president's share of #{random_corporation.name}"
              when 'match_share'
                new_share = random_corporation.shares.find { |s| !random_shares.include?(s) }
                real_shares << new_share
                random_shares << new_share
                company.desc = "#{company.desc} This private company comes with a #{new_share.percent}% share of \
                #{random_corporation.name}."
                @log << "#{company.name} comes with a #{new_share.percent}% share of #{random_corporation.name}"
              else
                real_shares << share_by_id(share)
              end
            end

            ability.shares = real_shares
          end
        end

        def status_array(corp)
          return if corp.floated?

          [["Token Fee: #{format_currency(TOKEN_FEE[corp.id])}"]]
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G18Texas::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18Texas::Step::Dividend,
            G18Texas::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            G18Texas::Step::IssueShares,
          ], round_num: round_num)
        end

        def float_corporation(corporation)
          @log << "#{corporation.name} floats"
          stock_market.move_up(corporation)
          @log << "#{corporation.name} share value moves up one space to #{corporation.share_price.price}"
          fee = TOKEN_FEE[corporation.id]
          corporation.spend(fee, @bank)
          @log << "#{corporation.name} spends #{format_currency(fee)} for tokens"
        end

        def issuable_shares(entity)
          return [] unless entity.operating_history.size > 1
          return [] unless entity.corporation?

          bundles_for_corporation(entity, entity)
            .select { |bundle| @share_pool.fit_in_bank?(bundle) }
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?

          bundles_for_corporation(share_pool, entity)
            .select { |bundle| fit_in_treasury?(entity, bundle) }
            .reject { |bundle| entity.cash < bundle.price }
        end

        def fit_in_treasury?(entity, bundle)
          (bundle.percent + entity.percent_of(bundle.corporation)) <= TREASURY_SHARE_LIMIT
        end

        def tile_lays(_entity)
          [{ lay: true, upgrade: true, cost: 0 }, { lay: :not_if_upgraded, upgrade: false }]
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return true if selected_company&.sym == 'NOPR' && from.color == :white && to.name == '511' && from.hex.name == 'J5'

          super
        end

        def ability_right_time?(ability, time, on_phase, passive_ok, strict_time)
          return false if %i[teleport tile_lay].include?(ability.type) && !%w[3 4].include?(@phase.name)

          super
        end

        def token_owner(entity)
          if entity.company? && entity.owner&.player?
            @round.teleport_tokener
          elsif entity.company?
            entity.owner
          else
            entity
          end
        end
      end
    end
  end
end
