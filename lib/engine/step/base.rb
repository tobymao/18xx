# frozen_string_literal: true

require_relative '../helper/type'
require_relative '../passer'

module Engine
  module Step
    class Base
      include Helper::Type
      include Passer
      attr_accessor :acted

      ACTIONS = [].freeze

      def initialize(game, round, **opts)
        @game = game
        @log = game.log
        @round = round
        @opts = opts
        @acted = false
      end

      def description
        raise NotImplementedError
      end

      def pass_description
        'Pass'
      end

      def actions(_entity)
        []
      end

      def auto_actions(_entity); end

      def available_hex(entity, hex); end

      def did_sell?(_corporation, _entity)
        false
      end

      def last_acted_upon?(_corporation, _entity)
        false
      end

      def log_pass(entity)
        @log << "#{entity.name} passes #{description.downcase}"
      end

      def log_skip(entity)
        @log << "#{entity.name} skips #{description.downcase}"
      end

      def process_pass(action)
        log_pass(action.entity)
        pass!
      end

      def skip!
        log_skip(current_entity) if !@acted && current_entity
        pass!
      end

      def current_actions
        entity = current_entity
        return [] if !entity || entity.closed?

        actions(entity)
      end

      def current_entity
        active_entities[0]
      end

      def active_entities
        [entities[entity_index]]
      end

      def round_state
        {}
      end

      def blocking?
        blocks? && !current_actions.empty?
      end

      def blocks?
        true
      end

      def setup; end

      def unpass!
        super
        @acted = false
      end

      # see assets/app/view/game/help.rb
      def help
        ''
      end

      def auctioneer?
        false
      end

      private

      def entities
        @round.entities
      end

      def entity_index
        @round.entity_index
      end

      def buying_power(entity)
        @game.buying_power(entity)
      end

      def try_take_loan(entity, price); end

      def inspect
        "<#{self.class.name}>"
      end
    end
  end
end
