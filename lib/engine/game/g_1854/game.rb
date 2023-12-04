# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'phases'
require_relative 'trains'
require_relative 'tiles'
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

        attr_reader :need_auction_or, :auction_finished

        COMPANY_CLASS = G1854::Company

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
        SELL_MOVEMENT = :down_block
        POOL_SHARE_DROP = :left_block

        EBUY_PRES_SWAP = false

        # TODO: unsure
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false

        TRACK_RESTRICTION = :permissive
        TILE_RESERVATION_BLOCKS_OTHERS = :always

        MARKET = [
        ['',
         '',
         '90',
         '100',
         '110',
         '120',
         '130',
         '140',
         '155',
         '170',
         '185',
         '200',
         '220t',
         '240t',
         '260t',
         '290t',
         '320t',
         '350t'],
        ['',
         '70',
         '80',
         '90',
         '100p',
         '110',
         '120',
         '130',
         '145',
         '160',
         '175',
         '190',
         '210t',
         '230t',
         '250t',
         '280t',
         '310t',
         '340t'],
        %w[55 60 70 80 90p 100 110 120 135 150 165 180 200t 220t 240t 270t 300t 330t],
        %w[50 56 60 70 80p 90 100 110 125 140 155 170 190t 210t 230t],
        %w[45 52 57 60 70p 80 90 100 115 130 145 160],
        %w[40 50 54 58 60p 70 80 90 100x 120],
        %w[35 45 52 56 59 64 70 80],
        %w[30 40 48 54 58 60],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(par_1: 'SBB starting price', type_limited: 'Regionals cannot enter').freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par_1: :blue, type_limited: :peach).freeze

        @need_auction_or = true
        @auction_finished = false

        def new_auction_round
          Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G1854::Step::WaterfallAuction,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1854::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def must_buy_train?(entity)
          return false if entity.minor?
          super
        end

        def route_trains(entity)
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
        end

        def reservation_corporations
          # populate reserved spaces on starting map
          # so locals starting spaces can be seen more easily
          @corporations + @minors
        end

        def player_card_minors(player)
          @minors.select { |m| m.owner == player }
        end

        def after_buy_company(player, company, _price)
          abilities(company, :assign_minor) do |ability|
            target_corp = minor_by_id(ability.corp_sym)
            target_corp.owner = player
            target_corp.float!
          end
          super
        end
      end
    end
  end
end
