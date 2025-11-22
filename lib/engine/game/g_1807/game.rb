# frozen_string_literal: true

require_relative '../g_1867/game'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative 'market'
require_relative 'tiles'
require_relative 'trains'

module Engine
  module Game
    module G1807
      class Game < G1867::Game
        include Entities
        include Map
        include Market
        include Tiles
        include Trains

        include_meta(G1807::Meta)

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          train: 'The first 4+4 or 6G train is purchased.',
        )
        GAME_END_CHECK = { train: :one_more_full_or_set }.freeze

        def setup
          # TODO: check which bits of this are needed, just cut-n-pasted from 1867.
          @interest = {}
          setup_company_price_up_to_face

          @show_majors = false
          setup_london_hexes
          setup_bonuses
        end

        def setup_preround
          # Randomise the privates available and the minor company order.
          setup_companies
          setup_minors

          # Remove companies and corporations that cannot yet be started.
          @companies, @future_companies = @companies.partition do |company|
            company.type == :railway
          end
          @corporations, @future_corporations = @corporations.partition do |corporation|
            corporation.type == :minor && corporation.reservation_color == MINORS_COLOR_BATCH1
          end
        end

        def add_neutral_tokens(_hexes)
          # No green placeholder tokens in 1807.
          @green_tokens = []
        end

        def init_loans
          @loan_value = 50
          # 24 minors × 2, 11 majors × 5, 5 systems × 10.
          Array.new(153) { |id| Loan.new(id, @loan_value) }
        end

        def new_stock_round
          case @turn
          when 1
            # Ferry companies are now available.
            new_companies_available! { |company| company.type == :ferry }
          when 2
            # Second batch of private companies are available.
            new_minors_available! do |corporation|
              corporation.type == :minor && corporation.reservation_color == MINORS_COLOR_BATCH2
            end
          end

          super
        end

        def stock_round
          G1867::Round::Stock.new(self, [
            G1867::Step::MajorTrainless,
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G1807::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          calculate_interest
          G1867::Round::Operating.new(self, [
            G1867::Step::MajorTrainless,
            Engine::Step::BuyCompany,
            G1867::Step::RedeemShares,
            G1807::Step::SpecialTrack,
            G1867::Step::Track,
            G1867::Step::Token,
            Engine::Step::Route,
            G1867::Step::Dividend,
            # The blocking buy company needs to be before loan operations
            [G1867::Step::BuyCompanyPreloan, { blocks: true }],
            G1867::Step::LoanOperations,
            Engine::Step::DiscardTrain,
            G1867::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def event_minors_batch3!
          new_minors_available! do |corporation|
            corporation.type == :minor && corporation.reservation_color == MINORS_COLOR_BATCH3
          end
        end

        def event_u1_available!
          new_companies_available! { |company| company.sym == 'U1' }
        end

        def event_u2_available!
          new_companies_available! { |company| company.sym == 'U2' }
        end

        def event_privates_close!
          # TODO: implement this.
        end

        def buyable_bank_owned_companies
          @companies.select { |company| !company.closed? && !company.owner }
        end

        def unowned_purchasable_companies(_entity)
          (@companies + @future_companies).select do |company|
            !company.closed? && !company.owner
          end
        end

        def calculate_interest
          # Number of loans interest is due on is set before taking loans in that OR
          @interest.clear
          @corporations.each { |c| calculate_corporation_interest(c) }
        end

        def revenue_for(route, stops)
          train = route.train
          bonuses =
            if goods_train?(train)
              bonus_mine(train, stops)
            else
              bonus_scottish_border(train, stops) +
              bonus_welsh_border(train, stops) +
              bonus_london_offboard(train, stops)
            end
          super + bonuses
        end

        private

        def new_companies_available!(&block)
          available, @future_companies = @future_companies.partition(&block)
          @log << 'New private companies available for auction: ' \
                  "#{available.map(&:id).join(', ')}."
          @companies += available
          update_cache(:companies)
        end

        def new_minors_available!(&block)
          available, @future_corporations = @future_corporations.partition(&block)
          @log << 'New minor companies available for auction: ' \
                  "#{available.map(&:id).join(', ')}."
          @corporations += available
          update_cache(:corporations)
        end
      end
    end
  end
end
