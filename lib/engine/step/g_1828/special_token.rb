# frozen_string_literal: true

require_relative '../special_token'
require_relative 'token_tracker'

module Engine
  module Step
    module G1828
      class SpecialToken < SpecialToken
        include TokenTracker

        ACTIONS = %w[place_token pass].freeze

        def actions(entity)
          blocking_for_sold_company? ? ACTIONS : super
        end

        def description
          "Place token for #{@company.owner.name}"
        end

        def blocking?
          blocking_for_sold_company? || super
        end

        def pass_description
          'Pass (Token)'
        end

        def active_entities
          @company ? [@company] : super
        end

        def process_place_token(entity)
          @company = nil
          super
        end

        def process_pass(action)
          entity = action.entity
          ability = @company.abilities(:token, time: 'sold')
          @game.game_error("Not #{entity.name}'s turn: #{action.to_h}") unless entity == @company

          hex = @game.hex_by_id(ability.hexes.first)
          @log << "#{entity.owner.name} passes placing a token on #{hex.name} (#{hex.location_name})"

          @game.place_blocking_token(@game.hex_by_id(ability.hexes.first))
          @company.remove_ability(ability)
          @company = nil

          pass!
        end

        def blocking_for_sold_company?
          return false unless (company = @round.just_sold_company)

#          company = @round.respond_to?(:just_sold_company) && @round.just_sold_company

          if (ability = company.abilities(:token, time: 'sold'))
            if available_tokens(company.owner) && !already_tokened_this_round?(company.owner)
              @company = company
              return true
            else
              @log << "#{company.owner.name} does not have the option to replace #{company.name}'s token"
              @game.place_blocking_token(@game.hex_by_id(ability.hexes.first))
              company.remove_ability(ability)
              return false
            end
          end

          false
        end
      end
    end
  end
end
