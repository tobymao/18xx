# frozen_string_literal: true

require_relative '../g_1849/game'
require_relative 'meta'
require_relative 'entities'

module Engine
  module Game
    module G18Ireland
      class Game < G1849::Game
        include_meta(G18Ireland::Meta)
        include G18Ireland::Entities

        CURRENCY_FORMAT_STR = '£%d'

        BANK_CASH = 4000

        CERT_LIMIT = { 3 => 16, 4 => 12, 5 => 10, 6 => 8 }.freeze

        STARTING_CASH = { 3 => 330, 4 => 250, 5 => 200, 6 => 160 }.freeze

        MARKET = [
          ['', '62', '68', '76', '84', '92', '100p', '110', '122', '134', '148', '170', '196', '225', '260e'],
          ['', '58', '64', '70', '78', '85p', '94', '102', '112', '124', '136', '150', '172', '198'],
          ['', '55', '60', '65', '70p', '78', '86', '95', '104', '114', '125', '138'],
          ['', '50', '55', '60p', '66', '72', '80', '88', '96', '106'],
          ['', '38y', '50p', '55', '60', '66', '72', '80'],
          ['', '30y', '38y', '50', '55', '60'],
          ['', '24y', '30y', '38y', '50'],
          %w[0c 20y 24y 30y 38y],
        ].freeze

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
