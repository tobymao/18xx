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
        CORPORATION_CLASS = G1854::Corporation
        DEPOT_CLASS = G1854::Depot

        CURRENCY_FORMAT_STR = '%s G'

        BANK_CASH = 10_000

        # TODO: cert limit changes with share split companies
        CERT_LIMIT = {
          3 => 24,
          4 => 18,
          5 => 15,
          6 => 13,
          7 => 11,
        }.freeze

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

        MERGERS_BEGIN_PHASE = 5
        MERGERS_MANDATORY_PHASE = 6

        MARKET = [
          %w[86 89 93p 97S 101S 106S 112S 119S 127S 136S 146S 158S 170S 185S 210S 230S 50S 275S 300e],
          %w[81 84 87p 91 95S 99S 104S 110S 117S 125S 134S 143S 153S 165S 180S 200S],
          %w[76 79 82p 85 89 93S 97S 102S 108S 115S 123S],
          %w[71 74 77p 80 83 87 91S 95S 100S],
          %w[66 69 72p 75 78 81 85 89S],
          %w[61y 64 67p 70 73 76y 79y],
          %w[56y 59y 62 65 68y 71y],
          [''] + %w[54y 57y 60y 63y],
].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(share_split: 'Share split when first entered').freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(share_split: :green).freeze

        DOUBLE_TOWN_TILES = %w[1 2 55 56 69].freeze
        DOUBLE_TOWN_UPGRADES = %w[14 15 619].freeze

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
            G1854::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            G1854::Step::MergeMinors,
            G1854::Step::TrackAndToken,
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            G1854::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1854::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1854::Step::BuyTrain,
            G1854::Step::BuyMailContract,
            G1854::Step::MergeMinors,
          ], round_num: round_num)
        end

        def must_buy_train?(entity)
          return false if entity.minor?

          super
        end

        def event_can_buy_trains!
          @log << "-- Event: #{EVENTS_TEXT['can_buy_trains'][1]} --"
          @can_cross_buy = true
        end

        def can_cross_buy?
          @can_cross_buy
        end

        def event_minor_mergers_allowed!
          @log << "-- Event: #{EVENTS_TEXT['minor_mergers_allowed'][1]} --"
          @minor_mergers_allowed = true
        end

        def minor_mergers_allowed?
          @minor_mergers_allowed
        end

        def event_minor_mergers_required!
          @log << "-- Event: #{EVENTS_TEXT['minor_mergers_required'][1]} --"
          @minor_mergers_required = true
        end

        def minor_mergers_required?
          @minor_mergers_required
        end

        def buy_train(operator, train, price = nil)
          # adjust share prices on sold, only move companies with a stock
          # price token, not minors
          seller = train.owner
          if seller != @depot
            if seller.corporation? && !seller.minor?
              old_price = seller.share_price
              @stock_market.move_down_right_hex(seller)
              log_share_price(seller, old_price)
            end

            if operator.corporation? && !operator.minor?
              old_price = operator.share_price
              @stock_market.move_up_left_hex(operator)
              log_share_price(operator, old_price)
            end
          end

          super
        end

        def route_trains(entity)
          # local railways are not allowed to run normal trains
          # they may only run + trains
          if entity.minor?
            # TODO: better method to filter, not based on name?
            return super.filter { |t| t.name.include? '+' }
          end

          super
        end

        def trigger_auction_or
          @need_auction_or = true
        end

        def clear_auction_or
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
          (1..NUM_SMALL_MAIL_CONTRACTS).each do |_|
            @available_mail_contracts << MailContract.new(sym: 'MC', name: 'Mail Contract', value: 100)
          end

          (1..NUM_LARGE_MAIL_CONTRACTS).each do |_|
            @available_mail_contracts << MailContract.new(sym: 'MC', name: 'Mail Contract', value: 200)
          end
        end

        def open_minors
          @minors.reject(&:closed?)
        end

        def mergeable?(entity)
          @minors.include?(entity) && !entity.closed?
        end

        def merge_target?(entity)
          !entity.floated? && entity.type == :lokalbahn
        end

        def merge_minors_into_lokalbahn(minor_a, minor_b, corp)
          # name is effectively sorting because they're all single digit numbers as strings
          lower_minor, upper_minor = [minor_a, minor_b].sort_by(&:name)

          @log << "#{formatted_minor_name(lower_minor)} gives #{format_currency(lower_minor.cash)} to #{corp.name}"
          lower_minor.spend(lower_minor.cash, corp, check_positive: false)

          @log << "#{formatted_minor_name(upper_minor)} gives #{format_currency(upper_minor.cash)} to #{corp.name}"
          upper_minor.spend(upper_minor.cash, corp, check_positive: false)

          corp.owner = lower_minor.owner
          share_pool.move_share(corp.ipo_shares.first, lower_minor.owner)
          share_pool.move_share(corp.ipo_shares.first, upper_minor.owner)
          float_corporation(corp) if corp.floated?
          # TODO: currently relies on the ordering in the market for last
          @stock_market.set_par(corp, @stock_market.par_prices.last)
          close_corporation(lower_minor)
          close_corporation(upper_minor)
        end

        def lokal_tile_names
          DOUBLE_TOWN_UPGRADES
        end

        def lokalbahn_homes
          [hex_by_id('D18'), hex_by_id('D20')]
        end

        def double_dit_upgrade?(from, to)
          DOUBLE_TOWN_TILES.include?(from.name) && DOUBLE_TOWN_UPGRADES.include?(to.name)
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          case active_step
          when G1854::Step::TrackAndToken
            return true if DOUBLE_TOWN_UPGRADES.include?(to.name)
          end

          return true if double_dit_upgrade?(from, to)

          super
        end

        def home_token_locations(corp)
          return lokalbahn_homes if corp.corporation? && corp.type == :lokalbahn

          []
        end

        def float_corporation(corporation)
          super unless corporation.type == :lokalbahn

          # TODO: double printing floats for majors
          # @log << "#{corporation.name} floats"
        end

        def formatted_minor_name(minor)
          "#{minor.full_name} (#{minor.name})"
        end

        def first_company
          @companies.first
        end

        def initial_auction_companies
          super.select { |company| !company.owned_by_player? && !company.closed? }
        end

        def reservation_corporations
          # populate reserved spaces on starting map
          # so locals starting spaces can be seen more easily
          @corporations + @minors
        end

        def player_card_minors(player)
          @minors.select { |m| m.owner == player }
        end

        def num_certs(entity)
          # local railroads count towards cert limit
          super + player_card_minors(entity).size
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

        def possibly_convert(entity)
          return unless entity&.corporation?
          return if entity&.shares_split?
          return unless entity.share_price.type == :share_split

          convert!(entity)
        end

        def convert!(corporation, quiet: false)
          corporation.shares_split = true

          @log << "#{corporation.name} converts to a 10-share company" unless quiet

          shares = @_shares.values.select { |share| share.corporation == corporation }
          shares.each { |share| share.percent /= 2 }
          corporation.share_holders.transform_values! { |percent| percent / 2 }
          corporation.share_holders.each do |shareholder, percent|
            next unless shareholder.player?

            amount = (percent / 10) * corporation.share_price.price
            @log << "#{shareholder.name} receives #{format_currency(amount)}" unless quiet
            @bank.spend(amount, shareholder)
          end

          new_shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 4) }
          new_shares.each do |share|
            add_new_share(share)
          end
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end
      end
    end
  end
end
