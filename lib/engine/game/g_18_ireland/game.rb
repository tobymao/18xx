# frozen_string_literal: true

require_relative '../g_1849/game'
require_relative 'meta'
require_relative 'misc_config'
require_relative 'entity_config'

module Engine
  module Game
    module G18Ireland
      class Game < G1849::Game
        include_meta(G18Ireland::Meta)
        include G18Ireland::MiscConfig
        include G18Ireland::EntityConfig

        CURRENCY_FORMAT_STR = '£%d'

        BANK_CASH = 4000

        CERT_LIMIT = { 3 => 16, 4 => 12, 5 => 10, 6 => 8 }.freeze

        STARTING_CASH = { 3 => 330, 4 => 250, 5 => 200, 6 => 160 }.freeze

        # @todo: all the following code will disappear after removing dependency on 1849
        def setup
          @corporations[0].next_to_par = true

          @available_par_groups = %i[par]

          @player_debts = Hash.new { |h, k| h[k] = 0 }
          @moved_this_turn = []
        end

        def float_str(entity)
          "#{entity.percent_to_float}% to float" if entity.corporation? && entity.floatable
        end
      end
    end
  end
end
