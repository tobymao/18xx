# frozen_string_literal: true

require_relative '../special_track'

module Engine
  module Step
    module G1889
      class SpecialTrack < SpecialTrack
        ACTIONS = %w[lay_tile pass].freeze

        def actions(entity)
          blocking_for_sold_company? ? ACTIONS : super
        end

        def blocking?
          blocking_for_sold_company? || super
        end

        def process_pass(action)
          @game.game_error("Not #{action.entity.name}'s turn: #{action.to_h}") unless action.entity == @company

          ability = @company.abilities(:tile_lay, 'sold')
          @company.remove_ability(ability)
          @log << "#{action.entity.name} passes lay track"
          pass!
        end

        def blocking_for_sold_company?
          just_sold_company = @round.respond_to?(:just_sold_company) && @round.just_sold_company

          if just_sold_company&.abilities(:tile_lay, 'sold')
            @company = just_sold_company
            return true
          end

          false
        end
      end
    end
  end
end
