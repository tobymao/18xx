# frozen_string_literal: true

require_relative '../config/game/g_1856'
require_relative 'base'

module Engine
  module Game
    class G1856 < Base
      register_colors(black: '#37383a',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      tgbOrange: '#fa460f',
                      gtGreen: '#78c292',
                      lpsBlue: '#c3deeb',
                      wgbBlue: '#21234a',
                      cprPink: '#91498b',
                      thbYellow: '#979e5d',
                      gwGray: '#6e6966',
                      wrBrown: '#664c3a',
                      red: '#d81e3e',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G1856::JSON)

      DEV_STAGE = :prealpha

      GAME_LOCATION = 'Ontario, Canada'
      GAME_RULES_URL = 'http://google.com'
      GAME_DESIGNER = 'Bill Dixon'
      GAME_INFO_URL = 'https://google.com'

      HOME_TOKEN_TIMING = :operating_round

      # Trying to do {static literal}.merge(super.static_literal) so that the capitalization shows up first.
      STATUS_TEXT = {
        'escrow' => ['Escrow Cap', "New corporations will be capitalized for the first 5 shares sold. The money for the last 5 shares is held in escrow until the corporation has destinated"],
        'incremental' => ['Incremental Cap', 'New corporations will be capitalized for all 10 shares as they are sold regardless of if a corporation has destinated'],
        'fullcap' => ['Full Cap', 'New corporations will be capitalized for 10 x par price when 60% of the IPO is sold'],
        'facing_2' => ["20% to start", "An unstarted corporation needs 20% sold from the IPO to start for the first time"],
        'facing_3' => ["30% to start", "An unstarted corporation needs 30% sold from the IPO to start for the first time"],
        'facing_4' => ["40% to start", "An unstarted corporation needs 40% sold from the IPO to start for the first time"],
        'facing_5' => ["50% to start", "An unstarted corporation needs 50% sold from the IPO to start for the first time"],
        'facing_6' => ["60% to start", "An unstarted corporation needs 60% sold from the IPO to start for the first time"] 
      }.merge(Base::STATUS_TEXT)
      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          Step::DiscardTrain,
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end
    end
  end
end
