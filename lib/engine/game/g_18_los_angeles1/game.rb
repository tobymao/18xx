# frozen_string_literal: true

require_relative '../g_18_los_angeles/game'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'

module Engine
  module Game
    module G18LosAngeles1
      class Game < G18LosAngeles::Game
        include_meta(G18LosAngeles1::Meta)
        include Entities
        include Map

        ORANGE_GROUP = [
          'Beverly Hills Carriage',
          'South Bay Line',
        ].freeze

        BLUE_GROUP = [
          'Chino Hills Excavation',
          'Los Angeles Citrus',
          'Los Angeles Steamship',
        ].freeze

        GREEN_GROUP = %w[LA SF SP].freeze

        REMOVED_CORP_SECOND_TOKEN = {
          'LA' => 'B9',
          'SF' => 'C8',
          'SP' => 'C6',
        }.freeze

        ABILITY_ICONS = {
          SBL: 'sbl',
          LAC: 'meat',
          LAS: 'port',
        }.freeze

        LSL_HEXES = %w[E4 E6].freeze
        LSL_ICON = 'sbl'
        LSL_ID = 'SBL'

        EVENTS_TEXT = G1846::Game::EVENTS_TEXT.merge(
          'remove_markers' => ['Remove Markers', 'Remove LA Steamship and LA Citrus markers']
        ).freeze

        def post_setup; end

        def game_companies
          @game_companies ||=
            self.class::COMPANIES + (G18LosAngeles::Game::COMPANIES.slice(0, 11).map do |company|
                                       self.class::COMPANIES_1E[company[:sym]] || company
                                     end)
        end

        def lake_shore_line
          @lake_shore_line ||= company_by_id('SBL')
        end

        def game_corporations
          @game_corporations ||=
            G18LosAngeles::Game::CORPORATIONS.map do |company|
              self.class::CORPORATIONS_1E[company[:sym]] || company
            end
        end

        def num_removals(group)
          return 0 if @players.size == 5
          return 1 if @players.size == 4

          case group
          when ORANGE_GROUP, BLUE_GROUP
            1
          when GREEN_GROUP
            2
          end
        end

        def corporation_removal_groups
          [GREEN_GROUP]
        end

        def place_second_token_kwargs
          { two_player_only: false, deferred: false }
        end

        def after_par_check_limit!; end

        def after_bid; end

        def draft_finished?; end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1846::Step::Assign,
            G1846::Step::BuySellParShares,
          ])
        end

        def home_token_locations(corporation)
          raise NotImplementedError
        end
      end
    end
  end
end
