# frozen_string_literal: true

require_relative '../config/game/g_18_fl'
require_relative 'base'

module Engine
  module Game
    class G18FL < Base
      register_colors(black: '#37383a',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#d81e3e',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G18FL::JSON)

      DEV_STAGE = :prealpha

      GAME_LOCATION = 'Florida, US'
      GAME_RULES_URL = 'http://google.com'
      GAME_DESIGNER = 'David Hecht'
      GAME_PUBLISHER = nil
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18FL'

      EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
      EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
      HOME_TOKEN_TIMING = :operating_round
      SELL_BUY_ORDER = :sell_buy

      def event_close_port!
        @log << "Port closes"
      end

      # 5 => 10 share conversion logic
      def event_forced_conversions!
        @log << "All 5 share corporations must convert to 10 share corporations immediately"
        @corporations.select { |c| c.total_shares == 5 }.each { |c| convert(c) }
      end

      def process_convert(action)
        @game.convert(action.entity)
      end

      def convert(corporation)
        before = corporation.total_shares
        shares = @_shares.values.select { |share| share.corporation == corporation }

        corporation.share_holders.clear

        case corporation.total_shares
        when 5
          shares.each { |share| share.percent = 10 }
          shares[0].percent = 20
          new_shares = 5.times.map { |i| Share.new(corporation, percent: 10, index: i + 4) }
        else
          raise GameError, 'Cannot convert 10 share corporation'
        end

        corporation.max_ownership_percent = 60
        shares.each { |share| corporation.share_holders[share.owner] += share.percent }

        new_shares.each do |share|
          add_new_share(share)
        end

        after = corporation.total_shares
        @log << "#{corporation.name} converts from #{before} to #{after} shares"

        converted_price = corporation.share_price
        conversion_funding = 5 * converted_price
        @log << "#{corporation.name} gets #{format_currency(conversion_funding)} from the conversion"
        @bank.spend(conversion_funding, corporation)

        new_shares
      end
    end
  end
end
