# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'trains'
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

        def init_tiles
          super.each do |tile|
            tile.towns.each { |town| town.style = :dot }
          end
        end

        def init_hexes(companies, corporations)
          super.each do |hex|
            hex.tile.towns.each { |town| town.style = :dot }
          end
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def setup
          @late_corps, @corporations = @corporations.partition { |c| LATE_CORPORATIONS.include?(c.id) }
          @late_corps.each { |corp| corp.reservation_color = nil }
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
      end
    end
  end
end
