# frozen_string_literal: true

module Engine
  module Game
    module G1822MRS
      module Entities
        CONCESSIONS = %w[C1 C2 C3 C4 C6 C7 C9].freeze

        MINORS_CORPORATIONS = %w[7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 24].freeze
        MINORS_COMPANIES = MINORS_CORPORATIONS.map { |m| "M#{m}" }.freeze

        STARTING_COMPANIES = [
          # P1, P2, P5-P16, P17
          'P1', 'P2', 'P5', 'P6', 'P7', 'P8', 'P9', 'P10', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P18',
          *CONCESSIONS,
          *MINORS_COMPANIES
        ].freeze

        STARTING_COMPANIES_STARTER = [
          # P1, P2, P5-P14
          'P1', 'P2', 'P5', 'P6', 'P7', 'P8', 'P9', 'P10', 'P11', 'P12', 'P13', 'P14',
          *CONCESSIONS,
          *MINORS_COMPANIES
        ].freeze

        STARTING_COMPANIES_ADVANCED = [
          # P1-P12
          'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'P9', 'P10', 'P11', 'P12',
          *CONCESSIONS,
          *MINORS_COMPANIES
        ].freeze

        STARTING_COMPANIES_TWOPLAYER = [
          # P1-P12
          'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'P9', 'P10', 'P11', 'P12',
          *CONCESSIONS,
          *MINORS_COMPANIES
        ].freeze

        STARTING_CORPORATIONS = (MINORS_CORPORATIONS + %w[LNWR GWR LBSCR SECR MR LYR SWR]).freeze
      end
    end
  end
end
