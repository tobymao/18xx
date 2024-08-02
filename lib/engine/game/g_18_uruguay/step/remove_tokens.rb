# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Uruguay
      module Step
        class RemoveTokens < Engine::Step::Base
          MAX_NUMBER_OF_TOKENS = 5

          def description
            'Choose token to remove'
          end

          def actions(entity)
            return [] unless @game.round.round_num == 3
            return [] unless entity == @game.fce

            num_tokens = @game.merge_data[:home_tokens].size + @game.merge_data[:tokens].size
            return [] unless num_tokens > self.class::MAX_NUMBER_OF_TOKENS

            %w[remove_token].freeze
          end

          def log_skip(entity); end

          def active?
            true
          end

          def can_replace_token?(entity, token)
            return false unless token.corporation == current_entity

            available_hex(entity, token.hex)
          end

          def process_remove_token(action)
            entity = action.entity
            city = action.city
            token = city.tokens[action.slot]
            hex = city.hex
            raise GameError, "Cannot remove #{token.corporation.name} token" unless can_replace_token?(entity, token)

            @log << "Remove #{token.corporation.name} token from hex #{hex.id} slot #{action.slot}"
            @game.merge_data[:home_tokens] = @game.merge_data[:home_tokens].reject { |t| t == token }
            @game.merge_data[:tokens] = @game.merge_data[:tokens].reject { |t| t == token }
            token.destroy!
          end

          def available_hex(_entity, hex)
            if @game.merge_data[:home_tokens].size > self.class::MAX_NUMBER_OF_TOKENS
              @game.merge_data[:home_tokens].each do |token|
                return true if token.hex == hex
              end
            end
            if @game.merge_data[:home_tokens].size + @game.merge_data[:tokens].size > self.class::MAX_NUMBER_OF_TOKENS
              @game.merge_data[:tokens].each do |token|
                return true if token.hex == hex
              end
            end
            false
          end
        end
      end
    end
  end
end
