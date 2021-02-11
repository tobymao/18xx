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

      HOME_TOKEN_TIMING = :operating_round
      SELL_BUY_ORDER = :sell_buy
      SELL_MOVEMENT = :left_block
      SELL_AFTER = :operate
      EBUY_OTHER_VALUE = true
      EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze
      STEAMBOAT_HEXES = %w[B5 B23 G20 K28].freeze
      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'hurricane' => ['Florida Keys Hurricane', 'Track and hotels in the Florida Keys (M24, M26) is removed'],
        'close_port' => ['Port Token Removed'],
        'forced_conversions' => ['Forced Conversions',
                                 'All remaining 5 share corporations immediately convert to 10 share corporations']
      ).freeze
      MARKET_TEXT = Base::MARKET_TEXT.merge(max_price: 'Maximum price for a 5-share corporation').freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'hotels_doubled' => ['Hotel Bonus Doubled', 'Hotel bonus increases from $10 to $20'],
        'may_convert' => ['Corporations May Convert',
                          'At the start of a corporations Operating turn it
                           may choose to convert to a 10 share corporation'],
      ).freeze

      ASSIGNMENT_TOKENS = {
        'POSC' => '/icons/1846/sc_token.svg',
      }.freeze
      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::HomeToken,
          Step::G18FL::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        Round::G18FL::Operating.new(self, [
          Step::Bankrupt,
          Step::G18FL::Assign,
          Step::Exchange,
          Step::G18FL::Convert,
          Step::SpecialTrack,
          Step::BuyCompany,
          Step::G18FL::Track,
          Step::G18FL::SpecialToken,
          Step::G18FL::Token,
          Step::Route,
          Step::G18FL::Dividend,
          Step::DiscardTrain,
          Step::G18FL::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def steamboat
        @steamboat ||= company_by_id('POSC')
      end

      def tile_company
        @tile_company ||= company_by_id('TR')
      end

      def token_company
        @token_company ||= company_by_id('POSC')
      end

      def revenue_for(route, stops)
        revenue = super

        raise GameError, 'Route visits same hex twice' if route.hexes.size != route.hexes.uniq.size

        raise GameError, '3E must visit at least two paying revenue centers' if route.train.variant['name'] == '3E' &&
           stops.count { |h| !h.town? } <= 1

        steam = steamboat.id
        if route.corporation.assigned?(steam) && (port = stops.map(&:hex).find { |hex| hex.assigned?(steam) })
          revenue += 20 * port.tile.icons.select { |icon| icon.name == 'port' }.size
        end
        hotels = stops.count { |h| h.tile.icons.any? { |i| i.name == route.corporation.id } }

        revenue + hotels * hotel_value
      end

      def hotel_value
        @phase.status.include?('hotels_doubled') ? 20 : 10
      end

      # Event logic goes here
      def event_close_port!
        @log << 'Port closes'
        removals = Hash.new { |h, k| h[k] = {} }

        @corporations.each do |corp|
          corp.assignments.dup.each do |company, _|
            removals[company][:corporation] = corp.name
            corp.remove_assignment!(company)
          end
        end

        @hexes.each do |hex|
          hex.assignments.dup.each do |company, _|
            removals[company][:hex] = hex.name
            hex.remove_assignment!(company)
          end
        end

        self.class::STEAMBOAT_HEXES.each do |hex|
          hex_by_id(hex).tile.icons.reject! { |icon| icon.name == 'port' }
        end

        removals.each do |company, removal|
          hex = removal[:hex]
          corp = removal[:corporation]
          @log << "-- Event: #{corp}'s #{company_by_id(company).name} token removed from #{hex} --"
        end
      end

      def event_hurricane!
        @log << '-- Event: Florida Keys Hurricane --'
        key_west = @hexes.find { |h| h.id == 'M24' }
        key_island = @hexes.find { |h| h.id == 'M26' }

        @log << 'A hurricane destroys track in the Florida Keys (M24, M26)'
        key_island.lay_downgrade(key_island.original_tile)

        @log << 'The hurricane also destroys the hotels in Key West'
        # TODO: Destroy Key West hotels
        key_west.lay_downgrade(key_west.original_tile)
      end

      # 5 => 10 share conversion logic
      def event_forced_conversions!
        @log << '-- Event: All 5 share corporations must convert to 10 share corporations immediately --'
        @corporations.select { |c| c.type == :medium }.each { |c| convert(c, funding: c.share_price) }
      end

      def process_convert(action)
        @game.convert(action.entity)
      end

      def convert(corporation, funding: true)
        before = corporation.total_shares
        shares = @_shares.values.select { |share| share.corporation == corporation }

        corporation.share_holders.clear

        case corporation.type
        when :medium
          shares.each { |share| share.percent = 10 }
          shares[0].percent = 20
          new_shares = 5.times.map { |i| Share.new(corporation, percent: 10, index: i + 4) }
          corporation.type = :large
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
        if funding
          conversion_funding = 5 * corporation.share_price.price
          @log << "#{corporation.name} gets #{format_currency(conversion_funding)} from the conversion"
          @bank.spend(conversion_funding, corporation)
        end

        new_shares
      end

      def add_new_share(share)
        owner = share.owner
        corporation = share.corporation
        corporation.share_holders[owner] += share.percent if owner
        owner.shares_by_corporation[corporation] << share
        @_shares[share.id] = share
      end
    end
  end
end
