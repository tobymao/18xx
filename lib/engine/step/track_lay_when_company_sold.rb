# frozen_string_literal: true

require_relative 'special_track'

module Engine
  module Step
    module TrackLayWhenCompanySold
      ACTIONS = %w[lay_tile].freeze
      ACTIONS_WITH_PASS = %w[lay_tile pass].freeze

      def actions(entity)
        return super unless blocking_for_sold_company?

        @game.abilities(@company, :tile_lay, time: 'sold').blocks ? ACTIONS : ACTIONS_WITH_PASS
      end

      def blocking?
        blocking_for_sold_company? || super
      end

      def process_lay_tile(action)
        return super unless action.entity == @company

        entity = action.entity
        ability = @game.abilities(@company, :tile_lay, time: 'sold')
        raise GameError, "Not #{entity.name}'s turn: #{action.to_h}" unless entity == @company

        lay_tile(action, spender: entity.owner)
        @round.laid_hexes << action.hex
        check_connect(action, ability)
        ability.use!(upgrade: %i[green brown gray].include?(action.tile.color))

        @company = nil
      end

      def process_pass(action)
        entity = action.entity
        ability = @game.abilities(@company, :tile_lay, time: 'sold')
        raise GameError, "Not #{entity.name}'s turn: #{action.to_h}" unless entity == @company

        @company.remove_ability(ability)
        @log << "#{entity.name} passes lay track"
        pass!

        @company = nil
      end

      def blocking_for_sold_company?
        @company = nil
        just_sold_company = @round.respond_to?(:just_sold_company) && @round.just_sold_company

        if @game.abilities(just_sold_company, :tile_lay, time: 'sold')
          @company = just_sold_company
          return true
        end

        false
      end
    end
  end
end
