# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'phases'
require_relative 'trains'
require_relative 'tiles'
require_relative 'mail_contract'
require_relative '../base'

module Engine
  module Game
    module G1854
      class Game < Game::Base
        include_meta(G1854::Meta)
        include Entities
        include Map
        include Phases
        include Trains
        include Tiles

        attr_reader :need_auction_or, :auction_finished, :available_mail_contracts

        COMPANY_CLASS = G1854::Company
        DEPOT_CLASS = G1854::Depot

        CURRENCY_FORMAT_STR = '%s G'

        BANK_CASH = 10_000

        # TODO: cert limit changes with share split companies
        CERT_LIMIT = {
          3 => 24,
          4 => 18,
          5 => 15,
          6 => 13,
          7 => 11
        }.freeze
        CERT_LIMIT_INCLUDES_PRIVATES = false

        STARTING_CASH = { 3 => 860, 4 => 650, 5 => 525, 6 => 450 }.freeze

        SELL_BUY_ORDER = :sell_buy

        # TODO: this is different for hex market
        SELL_MOVEMENT = :down_left_hex_share
        POOL_SHARE_DROP = :left_block

        EBUY_PRES_SWAP = false

        # TODO: unsure
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false

        TRACK_RESTRICTION = :permissive
        TILE_RESERVATION_BLOCKS_OTHERS = :always

        NUM_SMALL_MAIL_CONTRACTS = 6
        NUM_LARGE_MAIL_CONTRACTS = 6

        MARKET = [
          ['',    '',    '',    '86',  '89',  '93p', '97',  '101', '106', '112', '119', '127', '136', '146', '158', '170', '185', '210', '230', '250', '275', '300e'],
          ['',    '',    '',    '81',  '84',  '87p', '91',  '95', '99', '104', '110', '117', '125', '134', '143', '153', '165', '180', '200'],
          ['',    '',    '76',  '79',  '82p'  '85', '89',  '93', '97', '102', '108', '115', '123'],
          ['',    '',    '71',  '74',  '77p'  '80', '83',  '87', '91', '95', '100'],
          ['',    '66',  '69',  '72p',  '75',  '78', '81',  '85', '89'],
          ['',    '61y', '64',  '67p', '70',  '73', '76y', '79y'],
          ['56y', '59y', '62',  '65',  '68y', '71y'],
          ['',    '54y', '57y', '60y', '63y']].freeze


        MARKET_TEXT = Base::MARKET_TEXT.merge(par_1: 'SBB starting price', type_limited: 'Regionals cannot enter').freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par_1: :blue, type_limited: :peach).freeze

        @need_auction_or = true
        @auction_finished = false
        @available_mail_contracts = []

        def new_auction_round
          Engine::Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G1854::Step::WaterfallAuction,
          ])
        end

        def stock_round
          G1854::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1854::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1854::Step::BuyTrain,
            G1854::Step::BuyMailContract,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def must_buy_train?(entity)
          return false if entity.minor?
          super
        end

        def route_trains(entity)
          # local railways are not allowed to run normal trains
          # they may only run + trains
          if entity.minor?
            # TODO: better method to filter, not based on name?
            return super.filter {|t| t.name.include? "+"}
          end
          super
        end

        def trigger_auction_or
          puts "trigger_auction_or"
          @need_auction_or = true
        end

        def clear_auction_or
          puts "clear_auction_or"
          @need_auction_or = false
        end

        def set_auction_finished
          @auction_finished = true
        end

        def auction_finished?
          @auction_finished
        end

        def close_minor_companies
          @companies.each do |company|
            next if company.corp_sym.nil?
            company.close!
          end
        end

        def init_stock_market
          Engine::StockMarket.new(self.class::MARKET,
                                 self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES,
                                 hex_market: true)
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
                @operating_rounds = @phase.operating_rounds
                reorder_players
                new_operating_round
            when Engine::Round::Operating
              clear_auction_or
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                if auction_finished?
                  new_stock_round
                else
                  new_auction_round
                end
              end
            when init_round.class
              if @need_auction_or
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                puts "finally done"
                close_minor_companies
                set_auction_finished
                init_round_finished
                reorder_players
                new_stock_round
              end
            end
        end

        def setup
          # each minor starts with 150G, regardless of price paid in
          # initial auction.
          @minors.each do |minor|
            @bank.spend(150, minor)
          end

          @companies.each do |company|
            next if company.corp_sym.nil?
            company.add_ability(G1854::Ability::AssignMinor.new(type: :assign_minor, corp_sym: company.corp_sym))
          end

          @available_mail_contracts = []
          for _ in 1..NUM_SMALL_MAIL_CONTRACTS do
            @available_mail_contracts << MailContract.new(sym:"MC", name:"Mail Contract", value:100)
          end

          for _ in 1..NUM_LARGE_MAIL_CONTRACTS do
            @available_mail_contracts << MailContract.new(sym:"MC", name:"Mail Contract", value:200)
          end
        end

        def reservation_corporations
          # populate reserved spaces on starting map
          # so locals starting spaces can be seen more easily
          @corporations + @minors
        end

        def player_card_minors(player)
          @minors.select { |m| m.owner == player }
        end

        def company_header(company)
          company.local_railway? ? 'LOCAL RAILWAY' : super
        end

        def after_buy_company(player, company, _price)
          minor_assigned = false
          abilities(company, :assign_minor) do |ability|
            target_corp = minor_by_id(ability.corp_sym)
            target_corp.owner = player
            target_corp.float!
            minor_assigned = true
          end
          super
          company.close! if minor_assigned
        end
      end
    end
  end
end
