# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18NY
      module Step
        class ReplaceTokens < Engine::Step::Base
          REMOVE_TOKEN_ACTIONS = %w[remove_token pass].freeze

          def description
            'Replace Tokens'
          end

          def actions(entity)
            return [] unless current_entity == entity

            REMOVE_TOKEN_ACTIONS
          end

          def active?
            corporation && acquired_corporation && remaining_tokens?
          end

          def active_entities
            [corporation]
          end

          def round_state
            {
              acquisition_corporations: [],
            }
          end

          def corporation
            @round.acquisition_corporations[0]
          end

          def acquired_corporation
            @round.acquisition_corporations[-1]
          end

          def remaining_tokens?
            !corporation.tokens.reject(&:used).empty? && !acquired_corporation.tokens.select(&:used).empty?
          end

          def available_hex(entity, hex)
            return false unless entity == corporation

            hexes.include?(hex)
          end

          def hexes
            acquired_corporation.tokens.select(&:used).map(&:hex)
          end

          def can_replace_token?(entity, token)
            entity == current_entity && token.corporation == acquired_corporation
          end

          def process_remove_token(action)
            entity = action.entity
            city = action.city
            token = city.tokens[action.slot]
            hex = city.hex

            raise GameError, "Cannot replace token in #{hex.name} (#{hex.location_name})" unless available_hex(entity, hex)

            @log << "#{entity.name} replaces token in #{hex.name} (#{hex.location_name})"
            token.swap!(entity.tokens.reject(&:used).first, check_tokenable: false)
            @game.complete_acquisition(corporation, acquired_corporation) unless remaining_tokens?
          end

          def process_pass(action)
            @game.complete_acquisition(corporation, acquired_corporation)
            super
          end
        end
      end
    end
  end
end
