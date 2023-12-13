# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative 'corporation'
require_relative '../base'

module Engine
  module Game
    module G18India
      class Game < Game::Base
        include_meta(G18India::Meta)
        include Entities
        include Map

        register_colors(brown: '#a05a2c',
                        white: '#000000',
                        purple: '#5a2ca0')

        BANKRUPTCY_ALLOWED = false
        BANK_CASH = 9_000
        CURRENCY_FORMAT_STR = '₹%s'
        CAPITALIZATION = :incremental

        TRACK_RESTRICTION = :permissive
        TILE_TYPE = :lawson

        MARKET_SHARE_LIMIT = 100
        PRESIDENT_SALES_TO_MARKET = true

        SELL_BUY_ORDER = :sell_buy
        MUST_SELL_IN_BLOCKS = false
        SELL_MOVEMENT = :none
        POOL_SHARE_DROP = :none
        SOLD_OUT_INCREASE = false

        HOME_TOKEN_TIMING = :float
        MUST_BUY_TRAIN = :never

        CERT_LIMIT = { 2 => 37, 3 => 23, 4 => 18, 5 => 15 }.freeze
        CERT_LIMIT_CLOSE1 = { 2 => 33, 3 => 22, 4 => 17, 5 => 13 }.freeze
        CERT_LIMIT_CLOSE2 = { 2 => 29, 3 => 19, 4 => 15, 5 => 12 }.freeze

        STARTING_CASH = { 2 => 1100, 3 => 733, 4 => 550, 5 => 440 }.freeze

        GAME_END_CHECK = { bank: :current_or, stock_market: :current_or }.freeze

        MARKET = [
          %w[0c 56 58 61 64p 67p 71p 76p 82p 90p 100p 112p 126 142 160
             180 205 230 255 280 300 320 340 360 380 400e 420e 440e 460e],
        ].freeze

        PHASES = [
          { name: 'I', train_limit: 2, tiles: %i[yellow green brown gray], operating_rounds: 2 },
          { name: 'II', on: '3', train_limit: 2, tiles: %i[yellow green brown gray], operating_rounds: 2 },
          { name: 'III', on: '4', train_limit: 2, tiles: %i[yellow green brown gray], operating_rounds: 2 },
          { name: 'IV', on: '5', train_limit: 2, tiles: %i[yellow green brown gray], operating_rounds: 2 },
        ].freeze

        TRAINS = [
          { name: '2', distance: 2, price: 180, num: 6 },
          { name: '3', distance: 3, price: 300, num: 4 },
          { name: '4', distance: 4, price: 450, num: 3 },
          { name: '5', distance: 999, price: 1100, num: 3 },
        ].freeze

        EAST_GROUP = %w[BNR DHR EIR EBR NCR TR].freeze
        WEST_GROUP = %w[BR NWR PNS SPD WR].freeze
        SOUTH_GROUP = %w[CGR KGF MR NSR SIR WIP].freeze

        def corporation_removal_groups
          [EAST_GROUP , WEST_GROUP, SOUTH_GROUP]
        end

        CERT_DEALT = { 2 => 15, 3 => 13, 4 => 11, 5 => 10 }.freeze
        CERT_KEPT = { 2 => 8, 3 => 7, 4 => 6, 5 => 5 }.freeze
        IPO_CERTS_PER_ROW = { 2 => 18, 3 => 15, 4 => 13, 5 => 12 }.freeze
        
        def certs_per_row
          IPO_CERTS_PER_ROW[@players.size]
        end

        def deal_to_player
          CERT_DEALT[@players.size]
        end

        def certs_to_keep
          CERT_KEPT[@players.size]
        end

        def setup
          # remove random corporations based on regions, One from each group is Guaranty Company
          @log << "Setup: Select 3 corporations per region, remove others. One Guaranty company per region."
          remove_by_group!(@corporations)
          @log << "Corporations in the game: #{@corporations.map(&:name).sort.join(', ')}"

          # Set IPO prices for companies in game
          assign_initial_ipo_price()

          # Build draw decks for inital hand and IPO rows
          create_draw_deck()

        end

        def remove_by_group!(corporations)       
          removals = []
          guaranty_corps = []

          corporation_removal_groups.each do |group|
            # randomized_group = group.dup.sort_by { rand }
            randomized_group = group.dup.shuffle!(rand)
            removals += randomized_group.take(group.count - 3) # remove all but 3 items from each region group
            guaranty_corps += [randomized_group.last] # Set the last randomized company as Guaranty Company
          end
          @log << "Removing #{removals.join(', ')}"
          @log << "Guaranty Companies are #{guaranty_corps.join(', ')}"

          corporations.reject! do |corporation|
            if removals.include?(corporation.name)
              # @log << "Removing #{corporation.name}"
              remove_corporation_reservations(corporation)
              yield corporation if block_given?
              @removals << corporation
              true
            elsif guaranty_corps.include?(corporation.name)
              # @log << "#{corporation.name} is a Guaranty Company"
              assign_guaranty_warrant(corporation)
              false
            else
              false
            end
          end          
        end      

        def remove_corporation_reservations(corporation)
          # remove reservations for corporation
          hex = hex_by_id(corporation.coordinates)
          hex.tile.cities.each do |city|
            city.tokens.select { |t| t&.corporation == corporation }.each(&:remove!) if self.class::CLOSED_CORP_TOKENS_REMOVED
            if self.class::CLOSED_CORP_RESERVATIONS_REMOVED && city.reserved_by?(corporation)
              city.reservations.delete(corporation)
            end
          end
          if self.class::CLOSED_CORP_RESERVATIONS_REMOVED && hex.tile.reserved_by?(corporation)
            hex.tile.reservations.delete(corporation)
          end
        end

        def assign_guaranty_warrant(corporation)
            name = "Guaranty Warrant"
            warrant = Company.new(
              sym: name,
              name: name,
              value: 0,
              desc: "Warrant pays 5\% of share value when company doesn't pay dividend.",
              type: :warrent
            )
            corporation.companies << warrant
        end
        
        def assign_initial_ipo_price()
          @corporations.each do |corporation|
            ipo_price = @stock_market.par_prices.select { |p| p.price == IPO_PAR_PRICES[corporation.name] }.first
            @stock_market.set_par(corporation, ipo_price)
            # @log << "Set IPO for #{corporation.name} at #{corporation.par_price.price.to_s}"
          end
        end

        IPO_PAR_PRICES = { 
          'GIPR' => 112,
          'NWR' => 100,
          'EIR' => 100,
          'NCR' => 90,
          'MR' => 90,
          'SIR' => 82,
          'BNR' => 82,
          'CGR' => 76,
          'PNS' => 76,
          'WIP' => 76,
          'EBR' => 76,
          'BR' => 71,
          'NSR' => 71,
          'TR' => 71,
          'SPD' => 67,
          'DHR' => 67,
          'WR' => 64,
          'KGF' => 64,
        }

        def create_draw_deck()
          # stuff
          draw_deck = []
          draft_deck = []

          @corporations.each do |corporation|
            corporation.shares.each do |share|
              if share.percent == 20 
                draft_deck << share
              else
                draw_deck << share
              end
            end
          end
          draw_deck += @companies
          draw_deck.shuffle!(rand)

          @log << "Draw deck size #{draw_deck.size} contains #{draw_deck.join(', ')}"
          @log << "Draft deck contains #{draft_deck.join(', ')}"

          @log << "certs to deal #{certs_per_row}"
          deal_deck_to_ipo(draw_deck)
          @log << "Draw deck size #{draw_deck.size} contains #{draw_deck.join(', ')}"

          # deal leftovers to market and add funds to corps
          # deal_deck_to_market(draw_deck)
          # @log << "Bank Pool #{bank.to_s}"
          deal_deck_to_market(draw_deck)

          @log << "Bank Pool #{bank.companies.to_s}"

        end

        def deal_deck_to_ipo(deck)
          ipo_rows = [ [], [], [] ]
          player_hands = []

          ipo_rows.each do |row|
            row.concat( deck.pop(certs_per_row) )
            @log << "Row size #{row.size} contains #{row.to_s}"
          end
          
          players.each do |player|
            player_hands << deck.pop(deal_to_player)
          end
          @log << "Player Hand size #{player_hands.size} contains #{player_hands.to_s}"

        end

        def deal_deck_to_market(deck)
          deck.each do |card|
            @log << "Card is #{card}"
            if card.is_a? Engine::Share
              @log << "Share"
              share_pool.buy_shares(share_pool, card)
            elsif card.is_a? Engine::Company
              @log << "Company"
              bank.companies.push(card)
            else
              @log << "None"
            end
          end
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: false }],
          ], round_num: round_num)
        end
      end
    end
  end
end
