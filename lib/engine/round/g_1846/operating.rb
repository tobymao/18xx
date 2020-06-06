# frozen_string_literal: true

require_relative '../operating'

module Engine
  module Round
    module G1846
      class Operating < Operating
        STEPS = %i[
          issue
          token_or_track
          route
          dividend
          train
          company
        ].freeze

        STEP_DESCRIPTION = {
          issue: 'Issue or Redeem Shares',
          token_or_track: 'Place a Token or Lay Track',
          route: 'Run Routes',
          dividend: 'Pay or Withold Dividends',
          train: 'Buy Trains',
          company: 'Purchase Companies',
        }.freeze
      end
    end
  end
end
