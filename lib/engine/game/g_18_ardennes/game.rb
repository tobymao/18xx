# frozen_string_literal: true

require_relative '../base'
require_relative 'entities'
require_relative 'map'
require_relative 'market'
require_relative 'meta'
require_relative 'tiles'
require_relative 'trains'

module Engine
  module Game
    module G18Ardennes
      class Game < Game::Base
        include_meta(G18Ardennes::Meta)
        include Entities
        include Map
        include Market
        include Tiles
        include Trains

        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :par

        def setup_preround
          @minors, @corporations = @corporations.partition { |c| c.type == :minor }
        end

        def cache_objects
          super

          # Override the default @game.corporation_by_id method to include both
          # major and minor railways.
          self.class.define_method(:corporation_by_id) do |id|
            instance_variable_get(:@_corporations)[id] ||
              instance_variable_get(:@_minors)[id]
          end
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G18Ardennes::Step::MinorAuction,
          ])
        end
      end
    end
  end
end
