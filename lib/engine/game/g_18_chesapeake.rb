# frozen_string_literal: true

require_relative '../config/game/g_18_chesapeake'
require_relative '../g_18_chesapeake/share_pool'
require_relative '../round/g_18_chesapeake/stock'
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

      DEV_STAGE = :production

      GAME_LOCATION = nil
      GAME_RULES_URL = 'https://www.dropbox.com/s/x0dsehrxqr1tl6w/18Chesapeake_Rules.pdf'
      GAME_DESIGNER = 'Scott Petersen'
      GAME_PUBLISHER = Publisher::INFO[:all_aboard_games]
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Chesapeake'

      MUST_BID_INCREMENT_MULTIPLE = true
      SELL_BUY_ORDER = :sell_buy

      def init_share_pool
        Engine::G18Chesapeake::SharePool.new(self)
      end

      def action_processed(action)
        case action
        when Action::LayTile
          check_special_tile_lay(action, columbia)
          check_special_tile_lay(action, baltimore)
        end
      end

      def stock_round
        Round::G18Chesapeake::Stock.new(self, [
          Step::DiscardTrain,
          Step::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::SpecialTrack,
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def setup
        cornelius.add_ability(Ability::Close.new(
          type: :close,
          when: :train,
          corporation: cornelius.abilities(:shares).shares.first.corporation.name,
        ))

        return unless two_player?

        cv_corporation = cornelius.abilities(:shares).shares.first.corporation

        @corporations.each do |corporation|
          next if corporation == cv_corporation

          presidents_share = corporation.shares_by_corporation[corporation].first
          presidents_share.percent = 30

          final_share = corporation.shares_by_corporation[corporation].last
          @share_pool.transfer_shares(final_share.to_bundle, @bank)
        end
      end

      def check_special_tile_lay(action, company)
        company.abilities(:tile_lay) do |ability|
          hexes = ability.hexes
          next unless hexes.include?(action.hex.id)
          next if company.closed? || action.entity == company

          company.remove_ability(ability)
          @log << "#{company.name} loses the ability to lay #{hexes}"
        end
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

      def float_corporation(corporation)
        super

        return unless two_player?

        @log << "#{corporation.name}'s remaining shares are transferred to the Market"
        bundle = ShareBundle.new(corporation.shares_of(corporation))
        @share_pool.transfer_shares(bundle, @share_pool)
      end
    end
  end
end
