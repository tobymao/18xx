# frozen_string_literal: true

require_relative '../../../step/special_token'
require_relative 'token_tracker'

module Engine
  module Game
    module G1828
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          include TokenTracker

          ACTIONS = %w[place_token pass].freeze

          def actions(entity)
            blocking_for_sold_company? ? ACTIONS : super
          end

          def description
            blocking_for_sold_company? ? "Place token for #{@company.owner.name}" : super
          end

          def blocking?
            blocking_for_sold_company? || super
          end

          def pass_description
            blocking_for_sold_company? ? 'Pass (Token)' : super
          end

          def active_entities
            blocking_for_sold_company? ? [@company] : super
          end

          def process_place_token(entity)
            @company = nil if blocking_for_sold_company?
            super
          end

          def process_pass(action)
            return super unless blocking_for_sold_company?

            entity = action.entity
            ability = @game.abilities(@company, :token, time: 'sold')
            raise GameError, "Not #{entity.name}'s turn: #{action.to_h}" unless entity == @company

            hex = @game.hex_by_id(ability.hexes.first)
            @log << "#{entity.owner.name} passes placing a token on #{hex.name} (#{hex.location_name})"

            @game.place_blocking_token(@game.hex_by_id(ability.hexes.first))
            @company.remove_ability(ability)
            @company = nil

            pass!
          end

          def blocking_for_sold_company?
            return true if @company
            return false unless (company = @round.just_sold_company)

            if (ability = @game.abilities(company, :token, time: 'sold'))
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
end
