# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../base'
module Engine
  module Game
    module G18Scan
      class Game < Game::Base
        include_meta(G18Scan::Meta)
        include Entities
        include Map

        CURRENCY_FORMAT_STR = 'K%d'

        BANK_CASH = 6000

        CERT_LIMIT = { 2 => 18, 3 => 12, 4 => 9 }.freeze

        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 450 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = true

        MARKET = [
          %w[82 90 100 110 122 135 150 165 180 200 220 245 270 300 330 360 400],
          %w[75 85 90 100 110 122 135 150 165 180 200 220 245 270],
          %w[70 75 82 90 100p 110 122 135 150 165 180],
          %w[65 70 75 82p 90p 100 110 122],
          %w[60 65 70p 75p 82 90],
          %w[50 60 65 70 75],
          %w[40 50 60 65],
          ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2, major: 4, national: 0 },
            tiles: [:yellow],
            status: %w[float_2 incremental],
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, major: 4, national: 0 },
            tiles: %i[yellow green],
            status: %w[float_3 incremental],
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 1, major: 3, national: 0 },
            tiles: %i[yellow green],
            status: %w[float_4 incremental],
          },
          {
            name: '5',
            on: '5',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown],
            status: %w[float_5 fullcap],
          },
          {
            name: '5E',
            on: '5E',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown],
            status: %w[float_5 fullcap],
          },
          {
            name: '4D',
            on: '4D',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown],
            status: %w[float_5 fullcap],
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            obsolete_on: '4',
            variants: [
              {
                name: '1+1',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 1, 'visit' => 1 },
                           { 'nodes' => %w[town], 'pay' => 1, 'visit' => 1 }],
                price: 80,
              },
            ],
            num: 6,
          },
          {
            name: '3',
            distance: 3,
            price: 200,
            obsolete_on: '5',
            variants: [
              {
                name: '2+2',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => %w[town], 'pay' => 2, 'visit' => 2 }],
                price: 180,
              },
            ],
            num: 4,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            obsolete_on: '4D',
            variants: [
              {
                name: '3+3',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => %w[town], 'pay' => 3, 'visit' => 3 }],
                price: 280,
              },
            ],
            num: 3,
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            variants: [
              {
                name: '4+4',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => %w[town], 'pay' => 4, 'visit' => 4 }],
                price: 480,
              },
            ],
            num: 2,
          },
          {
            name: '5E',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 600,
            available_on: '5',
            num: 2,
          },
          {
            name: '4D',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4, 'multiplier' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 800,
            num: 6,
          },
        ].freeze

        LAYOUT = :pointy

        AXES = { x: :letter, y: :number }.freeze

        GAME_END_CHECK = { bank: :current_set }.freeze

        TRACK_RESTRICTION = :semirestrictive

        COPENHAGEN_HEX = 'C6'

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'minors_closed' => ['Minors closed'],
        ).freeze

        def company_1
          @company_1 ||= company_by_id('1')
        end

        def company_2
          @company_2 ||= company_by_id('2')
        end

        def company_3
          @company_3 ||= company_by_id('3')
        end

        def sj
          @sj_corporation ||= corporation_by_id('SJ')
        end

        def company_1_reserved_share
          @company_1_reserved_share ||= sj.shares[6]
        end

        def company_2_reserved_share
          @company_2_reserved_share ||= sj.shares[7]
        end

        def company_3_reserved_share
          @company_3_reserved_share ||= sj.shares[8]
        end

        def dsb
          @dsb_corporation ||= corporation_by_id('DSB')
        end

        def nsb
          @nsb_corporation ||= corporation_by_id('NSB')
        end

        def vr
          @vr_corporation ||= corporation_by_id('VR')
        end

        def nsj
          @nsj_corporation ||= corporation_by_id('NSJ')
        end

        def minor_1
          @minor_a ||= minor_by_id('1')
        end

        def minor_2
          @minor_2 ||= minor_by_id('2')
        end

        def minor_3
          @minor_3 ||= minor_by_id('3')
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G18Scan::Step::Assign,
            G18Scan::Step::BuyCompany,
            Engine::Step::HomeToken,
            G18Scan::Step::Merge,
            G18Scan::Step::SpecialTrack,
            G18Scan::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18Scan::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18Scan::Step::SingleDepotTrainBuy,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end
      end
    end
  end
end
