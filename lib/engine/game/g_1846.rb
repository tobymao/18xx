# File original exported from 18xx-maker: https://www.18xx-maker.com/
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# frozen_string_literal: true

require_relative '../config/game/g_1846'
require_relative 'base'

module Engine
  module Game
    class G1846 < Base
      register_colors(red: '#d1232a',
                      orange: '#f58121',
                      black: '#110a0c',
                      blue: '#025aaa',
                      lightBlue: '#8dd7f6',
                      yellow: '#ffe600',
                      green: '#32763f')

      load_from_json(Config::Game::G1846::JSON)

      DEV_STAGE = :alpha

      GAME_LOCATION = 'Midwest, USA'
      GAME_RULES_URL = 'https://s3-us-west-2.amazonaws.com/gmtwebsiteassets/1846/1846-RULES-GMT.pdf'
      GAME_DESIGNER = 'Thomas Lehmann'
      GAME_PUBLISHER = Publisher::INFO[:gmt_games]

      POOL_SHARE_DROP = :one
      SELL_AFTER = :p_any_operate
      SELL_BUY_ORDER = :sell_buy
      SELL_MOVEMENT = :left_block_pres
      HOME_TOKEN_TIMING = :float

      ORANGE_GROUP = [
        'Lake Shore Line',
        'Michigan Central',
        'Ohio & Indiana',
      ].freeze

      BLUE_GROUP = [
        'Steamboat Company',
        'Meat Packing Company',
        'Tunnel Blasting Company',
      ].freeze

      GREEN_GROUP = %w[C&O ERIE PRR].freeze

      TILE_COST = 20
      EVENTS_TEXT = Base::EVENTS_TEXT.merge('remove_tokens' => ['Remove Tokens', 'Remove private company tokens']).freeze

      def init_companies(players)
        super + @players.size.times.map do |i|
          name = "Pass (#{i + 1})"

          Company.new(
            sym: name,
            name: name,
            value: 0,
            desc: "Choose this card if you don't want to purchase any of the offered companies this round",
          )
        end
      end

      def michigan_southern
        @michigan_southern ||= minor_by_id('MS')
      end

      def big4
        @big4 ||= minor_by_id('BIG4')
      end

      def setup
        remove_from_group!(ORANGE_GROUP, @companies) do |company|
          @round.companies.delete(company)
        end
        remove_from_group!(BLUE_GROUP, @companies) do |company|
          @round.companies.delete(company)
        end
        remove_from_group!(GREEN_GROUP, @corporations) do |corporation|
          @round.place_home_token(corporation)
        end

        @companies.each do |company|
          company.min_price = 1
          company.max_price = company.value
        end

        @minors.each do |minor|
          train = @depot.upcoming[0]
          train.buyable = false
          minor.buy_train(train, :free)
          hex = hex_by_id(minor.coordinates)
          hex.tile.cities[0].place_token(minor, minor.next_token, free: true)
        end
      end

      def remove_from_group!(group, entities)
        remove = group.sort_by { rand }.take([5 - @players.size, 2].min)
        @log << "Removing #{remove.join(', ')}"
        entities.reject! do |entity|
          if remove.include?(entity.name)
            yield entity if block_given?
            true
          else
            false
          end
        end
      end

      def num_trains(train)
        num_players = @players.size

        case train[:name]
        when '2'
          num_players + 4
        when '4'
          num_players + 1
        when '5'
          num_players
        end
      end

      def illinois_central
        @illinois_central ||= corporation_by_id('IC')
      end

      def action_processed(action)
        case action
        when Action::Par
          if action.corporation == illinois_central
            bonus = action.share_price.price
            @bank.spend(bonus, illinois_central)
            @log << "#{illinois_central.name} receives a #{format_currency(bonus)} subsidy"
          end
        end

        @corporations.dup.each do |corporation|
          close_corporation(corporation) if corporation.share_price&.price&.zero?
        end
      end

      def close_corporation(corporation)
        corporation.share_holders.keys.each do |player|
          player.shares_by_corporation.delete(corporation)
        end

        @share_pool.shares_by_corporation.delete(corporation)

        hexes.each do |hex|
          hex.tile.cities.each do |city|
            next unless city.tokened_by?(corporation)

            city.tokens.map! { |token| token&.corporation == corporation ? nil : token }
            city.reservations.delete(corporation.name)
          end
        end

        corporation.spend(corporation.cash, @bank)
        @log << "#{corporation.name} closes"
        @round.skip_current_entity if @round.current_entity == corporation
        @corporations.delete(corporation)
      end

      def init_round
        Round::G1846::Draft.new(@players.reverse, game: self)
      end

      def operating_round(round_num)
        Round::G1846::Operating.new(@minors + @corporations, game: self, round_num: round_num)
      end

      def event_remove_tokens!
        # to be implemented
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
