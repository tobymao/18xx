# frozen_string_literal: true

require_relative '../g_1822/game'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1822Africa
      class Game < G1822::Game
        include_meta(G1822Africa::Meta)
        include G1822Africa::Entities
        include G1822Africa::Map

        CERT_LIMIT = { 3 => 16, 4 => 13, 5 => 10 }.freeze

        BIDDING_TOKENS = {
          '3': 6,
          '4': 5,
          '5': 4,
        }.freeze

        EXCHANGE_TOKENS = {}.freeze

        STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300 }.freeze

        STARTING_COMPANIES = %w[].freeze

        STARTING_CORPORATIONS = %w[].freeze

        CURRENCY_FORMAT_STR = '$%s'

        MARKET = [
          %w[40 50p 60xp 70xp 80xp 90 100 110 120 135 150 165e],
        ].freeze

        STARTING_COMPANIES = %w[].freeze

        STARTING_CORPORATIONS = %w[1 2 3 4 5 6 7 8 9 10 11 12
          NAR WAR EAR CAR SAR].freeze

        MUST_SELL_IN_BLOCKS = true
        SELL_MOVEMENT = :left_per_10_if_pres_else_left_one
        PRIVATE_TRAINS = %w[].freeze
        EXTRA_TRAINS = %w[].freeze
        EXTRA_TRAIN_PERMANENTS = %w[].freeze
        PRIVATE_MAIL_CONTRACTS = %w[].freeze
        PRIVATE_PHASE_REVENUE = %w[].freeze # Stub for 1822 specific code

        LOCAL_TRAIN_CAN_CARRY_MAIL = true

        # Don't run 1822 specific code for the LCDR
        COMPANY_LCDR = nil

        TRAINS = [].freeze

        # setup_companies from 1822 has too much 1822-specific stuff that doesn't apply to this game
        def setup_companies; end
        # Temporary stub
        def setup_exchange_tokens; end

        # Stubbed out because this game doesn't it, but base 22 does
        def company_tax_haven_bundle(choice); end
        def company_tax_haven_payout(entity, per_share); end
        def num_certs_modification(_entity) = 0
      end
    end
  end
end
