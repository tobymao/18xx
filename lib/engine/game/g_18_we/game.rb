# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_1862/game'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18WE
      class Game < G1862::Game
        include_meta(G18WE::Meta)
        include Entities
        include Map

        CURRENCY_FORMAT_STR = '%sf'

        BANK_CASH = 99_999

        CERT_LIMIT = {
          2 => 25,
          3 => 18,
          4 => 14,
          5 => 12,
          6 => 11,
          7 => 10,
          8 => 9,
        }.freeze

        STARTING_CASH = {
          2 => 1200,
          3 => 800,
          4 => 640,
          5 => 520,
          6 => 440,
          7 => 385,
          8 => 360,
        }.freeze

        GAME_END_CHECK = {
          custom: :one_more_full_or_set,
          stock_market: :current_or,
        }.freeze
        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
            custom: 'A corporation reaches a share price of 700+',
          ).freeze
        GAME_END_REASONS_TIMING_TEXT = Base::GAME_END_REASONS_TIMING_TEXT.merge(
            one_more_full_or_set:
                'If triggered in the first OR of a set then a final set ' \
                'of 2 ORs will be  played after the final SR, otherwise ' \
                'a final set of 3 ORs will be played after the final SR'
          ).freeze

        def setup
          @cached_freight_sets = nil
          @global_stops = nil
          @deferred_rust = []
          @merging = nil
        end
      end
    end
  end
end
