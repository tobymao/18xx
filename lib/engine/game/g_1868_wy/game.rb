# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'trains'
require_relative 'step/track'
require_relative 'step/waterfall_auction'
require_relative '../base'
require_relative '../company_price_up_to_face'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G1868WY
      class Game < Game::Base
        include_meta(G1868WY::Meta)
        include Entities
        include Map
        include Trains

        include CompanyPriceUpToFace
        include StubsAreRestricted

        BANK_CASH = 99_999
        STARTING_CASH = { 3 => 734, 4 => 550, 5 => 440, 6 => 367 }.freeze
        CERT_LIMIT = { 3 => 20, 4 => 15, 5 => 12, 6 => 10 }.freeze

        POOL_SHARE_DROP = :each
        CAPITALIZATION = :incremental
        SELL_BUY_ORDER = :sell_buy
        HOME_TOKEN_TIMING = :par

        TRACK_POINTS = 6
        YELLOW_POINT_COST = 2
        UPGRADE_POINT_COST = 3

        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        MUST_BUY_TRAIN = :always

        MARKET = [
          %w[64 68 72 76 82 90 100p 110 120 140 160 180 200 225 250 275 300 325 350 375 400 430 460 490 525 560],
          %w[60y 64 68 72 76 82 90p 100 110 120 140 160 180 200 225 250 275 300 325 350 375 400 430 460 490 525],
          %w[55y 60y 64 68 72 76 82p 90 100 110 120 140 160 180 200 225 250 275 300 325],
          %w[50o 55y 60y 64 68 72 76p 82 90 100 110 120 140 160 180 200],
          %w[40o 50o 55y 60y 64 68 72p 76 82 90 100 110 120],
          %w[30b 40o 50o 55y 60y 64 68p 72 76 82 90],
          %w[20b 30b 40o 50o 55y 60y 64 68 72],
          ['', '20b', '30b', '40o', '50o', '55y', '60y'],
        ].freeze

        LATE_CORPORATIONS = %w[C&N DPR FEMV LNP OSL].freeze
        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'all_corps_available' => ['All Corporations Available',
                                    'C&N, DPR, FEMV, LNP, OSL are now available to start'],
          'full_capitalization' =>
            ['Full Capitalization', 'Railroads now float at 60% and receive full capitalization'],
        ).freeze
        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'all_corps_available' => ['All Corporations Available',
                                    'C&N, DPR, FEMV, LNP, OSL are available to start'],
          'full_capitalization' =>
            ['Full Capitalization', 'Railroads float at 60% and receive full capitalization'],
        ).freeze

        def dotify(tile)
          tile.towns.each { |town| town.style = :dot }
          tile
        end

        def init_tiles
          super.each { |tile| dotify(tile) }
        end

        def init_hexes(companies, corporations)
          super.each { |hex| dotify(hex.tile) }
        end

        def add_extra_tile(tile)
          dotify(super)
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def setup
          init_track_points
          setup_company_price_up_to_face

          @late_corps, @corporations = @corporations.partition { |c| LATE_CORPORATIONS.include?(c.id) }
          @late_corps.each { |corp| corp.reservation_color = nil }
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            G1868WY::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def new_auction_round
          Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G1868WY::Step::WaterfallAuction,
          ])
        end

        def init_round_finished
          p10_company.revenue = 0
          p10_company.desc = 'Pays $40 revenue ONLY in green phases. Closes, '\
                             'becomes LHP train at phase 5.'

          p11_company.close!
          @log << "#{p11_company.name} closes"
        end

        def event_all_corps_available!
          @late_corps.each { |corp| corp.reservation_color = CORPORATION_RESERVATION_COLOR }
          @corporations.concat(@late_corps)
          @log << '-- All corporations now available --'
        end

        def event_full_capitalization!
          @log << '-- Event: Railroads now float at 60% and receive full capitalization --'
          @corporations.each do |corporation|
            corporation.capitalization = :full
            corporation.float_percent = 60
          end
        end

        def float_corporation(corporation)
          if @phase.status.include?('full_capitalization')
            bundle = ShareBundle.new(corporation.shares_of(corporation))
            @share_pool.transfer_shares(bundle, @share_pool)
            @log << "#{corporation.name}'s remaining shares are transferred to the Market"
          end

          super

          corporation.capitalization = :incremental
        end

        def init_track_points
          @track_points_used = Hash.new(0)
        end

        def status_str(corporation)
          "Track Points: #{track_points_available(corporation)}" if corporation.floated?
        end

        def p1_company
          @p1_company ||= company_by_id('P1')
        end

        def p7_company
          @p7_company ||= company_by_id('P7')
        end

        def p10_company
          @p10_company ||= company_by_id('P10')
        end

        def p11_company
          @p11_company ||= company_by_id('P11')
        end

        def p12_company
          @p12_company ||= company_by_id('P12')
        end

        def track_points_available(entity)
          return 0 unless (corporation = entity).corporation?

          p7_point = p7_company.owner == corporation ? 1 : 0
          TRACK_POINTS + p7_point - @track_points_used[corporation]
        end

        def tile_lays(entity)
          if (points = track_points_available(entity)) >= UPGRADE_POINT_COST
            { @round.num_laid_track => { lay: true, upgrade: true, cost: 0 } }
          elsif points == YELLOW_POINT_COST
            { @round.num_laid_track => { lay: true, upgrade: false, cost: 0 } }
          else
            []
          end
        end

        def spend_tile_lay_points(action)
          return unless (corporation = action.entity).corporation?

          points_used = action.tile.color == :yellow ? YELLOW_POINT_COST : UPGRADE_POINT_COST
          @track_points_used[corporation] += points_used
        end

        def or_round_finished
          init_track_points
        end

        def action_processed(action)
          case action
          when Action::LayTile
            if action.hex.name == 'G15'
              action.hex.tile.color = :gray
              @log << 'Wind River Canyon turns gray; it can never be upgraded'
            end
          end
        end

        def or_set_finished
          depot.export!
        end

        def isr_payout_companies(p12_bidders)
          payout_companies
          bidders = p12_bidders.map(&:name).sort
          @log << "#{bidders.join(', ')} collect#{bidders.one? ? 's' : ''} $5 "\
                  "for their bid#{bidders.one? ? '' : 's'} on #{p12_company.name}"
          p12_bidders.each { |p| @bank.spend(5, p) }
        end

        def isr_company_choices
          @isr_company_choices ||= COMPANY_CHOICES.transform_values do |company_ids|
            company_ids.map { |id| company_by_id(id) }
          end
        end
      end
    end
  end
end
