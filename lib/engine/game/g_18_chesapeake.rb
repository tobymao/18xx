# frozen_string_literal: true

require_relative '../config/game/g_18_chesapeake'
require_relative 'base'

module Engine
  module Game
    class G18Chesapeake < Base
      register_colors(green: '#237333',
                      red: '#d81e3e',
                      blue: '#0189d1',
                      lightBlue: '#a2dced',
                      yellow: '#FFF500',
                      orange: '#f48221',
                      brown: '#7b352a')

      load_from_json(Config::Game::G18Chesapeake::JSON)

      DEV_STAGE = :beta

      GAME_LOCATION = nil
      GAME_RULES_URL = 'https://www.dropbox.com/s/e38xzaf14meb2tw/18Chesapeake_Rules.pdf'
      GAME_DESIGNER = 'Scott Petersen'
      GAME_PUBLISHER = :aag

      def action_processed(action)
        case action
        when Action::BuyTrain
          if !cornelius.closed? && action.entity == cornelius.abilities(:share)[:share].corporation
            cornelius.close!
            @log << "#{cornelius.name} closes"
          end
        when Action::LayTile
          check_special_tile_lay(action, columbia)
          check_special_tile_lay(action, baltimore)
        end
      end

      def check_special_tile_lay(action, company)
        return if company.closed? || action.entity == company
        return unless (ability = company.abilities(:tile_lay))

        hexes = ability[:hexes]
        return unless hexes.include?(action.hex.id)

        company.remove_ability(:tile_lay)
        @log << "#{company.name} loses the ability to lay #{hexes}"
      end

      def columbia
        @companies.find { |company| company.name == 'Columbia - Philadelphia Railroad' }
      end

      def baltimore
        @companies.find { |company| company.name == 'Baltimore and Susquehanna Railroad' }
      end

      def cornelius
        @cornelius ||= @companies.find { |company| company.name == 'Cornelius Vanderbilt' }
      end

      def or_set_finished
        depot.export! if %w[2 3 4].include?(@depot.upcoming.first.name)
      end

      def stock_round
        Round::Stock.new(@players, game: self, sell_buy_order: :sell_buy)
      end
    end
  end
end
