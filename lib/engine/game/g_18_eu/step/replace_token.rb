# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../token'

module Engine
  module Game
    module G18EU
      module Step
        class ReplaceToken < Engine::Step::Base
          include Engine::Step::Tokener
          ACTIONS = %w[place_token pass].freeze

          def actions(entity)
            return [] unless entity == current_entity

            ACTIONS
          end

          def auto_actions(entity)
            return [] unless all_cities_have_corp_token?

            [Engine::Action::Pass.new(entity)]
          end

          def all_cities_have_corp_token?
            # return true if all possible cities already have a token from the
            # exchanging corporation.  This is used to auto-pass when there is
            # not an actual decision to make, and pass is the only valid option.
            available_cities.all? { |city| city&.tokened_by?(pending_corporation) }
          end

          def description
            'Replace Token'
          end

          def pass_description
            'Discard Token'
          end

          def active?
            pending_acquisition
          end

          def active_entities
            return [] unless pending_acquisition

            [pending_corporation]
          end

          def pending_acquisition
            @round.pending_acquisition
          end

          def pending_minor
            pending_acquisition[:minor]
          end

          def pending_corporation
            pending_acquisition[:corporation]
          end

          def pending_token
            pending_minor.tokens.first
          end

          def available_cities
            [pending_token.city]
          end

          def available_hex(_entity, hex)
            available_cities.map(&:hex).include?(hex)
          end

          def available_city?(_entity, city)
            available_cities.include?(city)
          end

          def can_replace_token?(entity, token)
            available_city?(entity, token.city)
          end

          def process_pass(_action)
            @game.log << if all_cities_have_corp_token?
                           "#{pending_corporation.name} already has a token on #{pending_token.city.hex.name}"
                         else
                           "#{pending_corporation.name} passes replacing #{pending_minor.name} token"
                         end

            close!(pending_minor)
          end

          def process_place_token(action)
            entity = action.entity

            raise GameError, "Cannot place a token on #{action.city.hex.name}" unless available_hex(entity,
                                                                                                    action.city.hex)

            new_token = entity.unplaced_tokens.first
            pending_token.remove!
            action.city.exchange_token(new_token)

            @game.log << "#{pending_corporation.name} replaces #{pending_minor.name} token on #{action.city.hex.name}"
            @game.maybe_remove_duplicate_token!(action.city.tile)

            close!(pending_minor)
          end

          def close!(entity)
            @game.close_corporation(entity)
            @round.pending_acquisition = nil
          end
        end
      end
    end
  end
end
