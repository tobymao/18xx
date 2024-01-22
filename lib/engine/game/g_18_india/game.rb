# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative 'corporation'
require_relative 'player'
require_relative 'decks'
require_relative '../base'

module Engine
  module Game
    module G18India
      class Game < Game::Base
        include_meta(G18India::Meta)
        include Entities
        include Map

        attr_accessor :draft_deck

        register_colors(brown: '#a05a2c',
                        white: '#000000',
                        purple: '#5a2ca0')

        BANKRUPTCY_ALLOWED = false
        BANK_CASH = 9_000
        CURRENCY_FORMAT_STR = '₹%s'
        CAPITALIZATION = :incremental

        TRACK_RESTRICTION = :permissive
        TILE_TYPE = :lawson

        MARKET_SHARE_LIMIT = 200 # up to 200% of GIPR may be in market
        PRESIDENT_SALES_TO_MARKET = true # need to set to false and allow GIPR to sell PS

        SELL_BUY_ORDER = :sell_buy
        MUST_SELL_IN_BLOCKS = false
        SELL_MOVEMENT = :none
        POOL_SHARE_DROP = :none
        SOLD_OUT_INCREASE = false
        NEXT_SR_PLAYER_ORDER = :first_to_pass

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
          [EAST_GROUP, WEST_GROUP, SOUTH_GROUP]
        end

        CERT_DEALT = { 2 => 15, 3 => 13, 4 => 11, 5 => 10 }.freeze
        CERT_KEPT = { 2 => 8, 3 => 7, 4 => 6, 5 => 5 }.freeze
        IPO_CERTS_PER_ROW = { 2 => 18, 3 => 15, 4 => 13, 5 => 12 }.freeze

        # Use overridden clases
        PLAYER_CLASS = Player
        CORPORATION_CLASS = Corporation

        def certs_per_row
          IPO_CERTS_PER_ROW[@players.size]
        end

        def deal_to_player
          CERT_DEALT[@players.size]
        end

        def certs_to_keep
          CERT_KEPT[@players.size]
        end

        def ipo_name(_entity = nil)
          'IPO Pool'
        end

        def ipo_reserved_name(_entity = nil)
          'Player Hands'
        end

        def setup_preround
          @log << 'setup_preround method in game called'
        end

        def setup
          # remove random corporations based on regions, One from each group is Guaranty Company
          setup_corporations_by_region!(@corporations)

          # Set IPO prices for companies in game
          assign_initial_ipo_price(@corporations)

          # Build draw and draft decks for inital hand and IPO rows
          @ipo_rows = [[], [], []]
          create_decks(@corporations)

          @selection_finished = false
          @draft_finished = false
          @last_action = nil

          # @log << "removals contain #{@removals.to_s}"
          # @log << "Player Hand Count #{@player_decks.flatten.size}"
          @log << 'End of Setup in Game'
        end

        def setup_corporations_by_region!(corporations)
          corps_to_remove = []
          guaranty_corps = []

          @log << 'Setup: Select 3 corporations per region, remove others. One Guaranty company per region.'
          corporation_removal_groups.each do |group|
            randomized_group = group.dup.sort_by { rand }
            corps_to_remove += randomized_group.take(group.count - 3) # remove all but 3 items from each region group
            guaranty_corps += [randomized_group.last] # Set the last randomized company as Guaranty Company
          end

          corporations.reject! do |corporation|
            if corps_to_remove.include?(corporation.name)
              # @log << "Removing #{corporation.name}"
              remove_corporation_reservations(corporation)
              corporation.close!
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
          @log << "Corporations in the game: #{@corporations.map(&:name).sort.join(', ')}"
          @log << "Guaranty Companies are #{guaranty_corps.join(', ')}"
        end

        def remove_corporation_reservations(corporation)
          # remove reservations for corporation at intial coordinates
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
          name = 'Guaranty Warrant'
          warrant = Company.new(
            sym: name,
            name: name,
            value: 0,
            desc: "Warrant pays 5\% of share value when company doesn't pay dividend.",
            type: :warrent
          )
          corporation.companies << warrant
        end

        def assign_initial_ipo_price(corporations)
          corporations.each do |corporation|
            ipo_price = @stock_market.par_prices.select { |p| p.price == corporation.min_price }.first
            # ipo_price = @stock_market.par_prices.select { |p| p.price == IPO_PAR_PRICES[corporation.name] }.first
            @stock_market.set_par(corporation, ipo_price)
            corporation.ipoed = true
            # @log << "Set IPO for #{corporation.name} at #{corporation.par_price.price.to_s}"
          end
        end

        def create_decks(corporations)
          draw_deck = []
          @draft_deck = []

          corporations.each do |corporation|
            corporation.shares.each do |share|
              if share.percent == 20
                share.buyable = false # set the share as reserved / in player hands
                @draft_deck << convert_share_to_company(share)
              else
                draw_deck << share
              end
            end
          end
          draw_deck += @companies
          draw_deck.sort_by! { rand }

          # draw deck dealt to IPO rows
          deal_deck_to_ipo(draw_deck)
          # remaining deck dealt to player hands
          deal_deck_to_players(draw_deck)
          # deal leftovers to market and add funds to corps
          deal_deck_to_market(draw_deck)
        end

        def hand_as_companies(deck, set_buyable = false)
          new_deck = []
          deck.each do |card|
            if card.is_a? Engine::Share
              card.buyable = set_buyable # set buyable to false if in player hands
              new_deck << convert_share_to_company(card)
            elsif card.is_a? Engine::Company
              new_deck << card
            else
              @log << 'Error in converting deck'
            end
          end
          # @log << "Deck Count #{new_deck.flatten.size}"
          new_deck
        end

        def share_type(share)
          return :share unless share.percent == 20

          :president
        end

        def convert_share_to_company(share)
          Company.new(
            sym: share.id,
            name: share.corporation.name,
            value: share.price,
            desc: "Certificate for #{share.percent}\% of #{share.corporation.full_name}. Type is #{share_type(share)}",
            type: share_type(share),
            color: share.corporation.color,
            text_color: share.corporation.text_color,
            treasury: share
          )
        end

        def deal_deck_to_ipo(deck)
          rows = [0, 1, 2]
          rows.each do |row|
            new_row = deck.pop(certs_per_row)
            @ipo_rows[row] = hand_as_companies(new_row, true)
            # @log << "Row size #{row.size} contains #{row.to_s}"
          end
        end

        def deal_deck_to_players(deck)
          players.each do |player|
            cards = deck.pop(deal_to_player)
            player.hand = hand_as_companies(cards, false)
          end
          deck
        end

        def sell_card(_entity, card)
          return if card.nil? || enity.nil?

          share_pool.buy_shares(share_pool, card.treasury)
        end

        def deal_deck_to_market(deck)
          deck.each do |card|
            # @log << "Card is #{card}"
            if card.is_a? Engine::Share
              # @log << "Share"
              share_pool.buy_shares(share_pool, card)
            elsif card.is_a? Engine::Company
              @log << "Private #{card.name} is availabe in the Market"
              card.owner = @bank
              @bank.companies.push(card)
            else
              @log << 'Deck Dealing Error'
            end
          end
        end

        def prepare_draft_deck
          # @log << "At start Draft Deck contains: #{@draft_deck.join(', ')}"
          draft = []
          @players.each do |player|
            cards = player.hand.dup
            cards.each do |card|
              next unless card.owner.nil?

              draft << card
              @draft_deck << card
              player.hand.delete(card)
            end
            # @log << "#{player.name.to_s} hand is size #{player.hand.size} contains #{player.hand.to_s}"
          end
          # @log << "Added to Draft is #{draft.size} cards: #{draft.join(', ')}"
          # @log << "Final Draft Deck of #{@draft_deck.size} has: #{@draft_deck.to_s}"
        end

        def railroad_bond_convert_cost
          return 12 unless gpir_share_price

          if gpir_share_price <= 100
            0
          else
            gpir_share_price - 100
          end
        end

        def gpir_share_price
          return 112 unless @corporations

          gipr = @corporations.select { |corp| corp.name == 'GIPR' }.first
          return 112 unless gipr.share_price

          gipr.share_price
        end

        def init_round
          selection_round
        end

        def selection_round
          selection_step = G18India::Step::CertificateSelection
          Engine::Round::Draft.new(self, [selection_step], reverse_order: false)
        end

        def draft_round
          draft_step = G18India::Step::Draft
          Engine::Round::Draft.new(self, [draft_step], reverse_order: false)
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::Assign,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            # Engine::Step::Bankrupt,  # should not need as there is no bankruptcy in game
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

        def next_round!
          @round =
            case @round
            when Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when init_round.class
              if @selection_finished == false
                @selection_finished = true
                draft_round
              else
                # init_round_finished
                reorder_players
                new_stock_round
              end
            end
        end

        def in_ipo?(company)
          @ipo_rows.flatten.include?(company)
        end

        def ipo_row_and_index(company)
          [0, 1, 2].each do |row|
            index = @ipo_rows[row].index(company)
            return [row + 1, index + 1] if index
          end
          nil
        end

        def company_status_str(company)
          # used to add status of cert card e.g. IPO ROW
          if in_ipo?(company)
            row, index = ipo_row_and_index(company)
            return "IPO Row:#{row} Index:#{index}"
          end
          'status'
        end

        def status_str(_corporation)
          # Use to track Corp status, e.g. managed vs directed companies
          'Managed Company'
        end

        def timeline
          timeline = []

          ipo_row_1 = ipo_timeline(0)
          timeline << "IPO ROW 1: #{ipo_row_1.join(', ')}" unless ipo_row_1.empty?

          ipo_row_2 = ipo_timeline(1)
          timeline << "IPO ROW 2: #{ipo_row_2.join(', ')}" unless ipo_row_2.empty?

          ipo_row_3 = ipo_timeline(2)
          timeline << "IPO ROW 3: #{ipo_row_3.join(', ')}" unless ipo_row_3.empty?

          timeline << "Market: #{bank.companies.join(', ')}" unless ipo_row_1.empty?

          @players.each do |p|
            timeline << "#{p.name}: #{p.hand.map { |c| c.name }.sort.join(', ')}" unless p.hand.empty?
          end

          timeline
        end

        def ipo_timeline(index)
          row = @ipo_rows[index]
          row.map do |company|
            "#{company.name}#{'*' if row.index(company) < 2}"
          end
        end

        def unowned_purchasable_companies(_entity)
          bank.companies + @ipo_rows[0] + @ipo_rows[1]
        end

        def purchasable_companies(entity = nil)
          return [] unless entity.player?

          entity.hand
        end

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['End OR without train', '1 ←'],
            ['Dividend 0 or withheld', '1 ←'],
            ['Dividend < share price', 'none'],
            ['Dividend ≥ share price', '1 →'],
            ['Dividend ≥ 2x share price', '2 →'],
            ['Dividend ≥ 3x share price', '3 →'],
            ['Dividend ≥ 4x share price', '4 →'],
          ]
        end
      end
    end
  end
end
