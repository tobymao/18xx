# frozen_string_literal: true

require_relative '../../../step/reduce_tokens'

module Engine
  module Game
    module G1807
      module Step
        class DeclineTokens < Engine::Step::ReduceTokens
          ACTIONS = %w[remove_token pass].freeze

          def actions(_entity)
            return [] unless taking_over_minor?
            return [] if minor.placed_tokens.empty?

            ACTIONS
          end

          def description
            "Transfer or remove tokens from #{minor.name}"
          end

          def pass_description
            'Transfer token'
          end

          def active?
            taking_over_minor?
          end

          def blocking?
            taking_over_minor?
          end

          def active_entities
            [minor]
          end

          def available_hex(_entity, hex)
            minor.tokens.any? { |token| token.used && token.hex == hex }
          end

          def can_replace_token?(_entity, token)
            return false unless token

            minor.tokens.include?(token)
          end

          def process_pass(_action)
            minor.placed_tokens.each do |minor_token|
              major_token = major.next_token
              city = minor_token.city
              minor_token.remove!
              city.place_token(major, major_token, check_tokenable: false)
            end
            @game.close_corporation(minor)
            @round.corporations_acquiring_minors = nil
          end

          def process_remove_token(action)
            entity = action.entity
            city = action.city
            slot = action.slot
            token = city.tokens[slot]
            raise GameError, "Cannot remove #{entity.id}’s token" unless entity == minor
            raise GameError, 'Cannot remove token' unless can_replace_token?(entity, token)

            @log << "#{major.name} removes #{minor.name}’s token from #{@game.token_location(token)}"
            token.remove!
            return unless minor.placed_tokens.empty?

            @game.close_corporation(minor)
            @round.corporations_acquiring_minors = nil
          end

          private

          def taking_over_minor?
            !!@round.corporations_acquiring_minors
          end

          def major
            @round.corporations_acquiring_minors[:major]
          end

          def minor
            @round.corporations_acquiring_minors[:minor]
          end

          def surviving
            major
          end

          def acquired_corps
            [minor]
          end
        end
      end
    end
  end
end
