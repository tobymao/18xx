# frozen_string_literal: true

require_relative '../../../step/home_token'
require_relative 'minor_exchange'

module Engine
  module Game
    module G18EU
      module Step
        class HomeToken < Engine::Step::HomeToken
          include MinorExchange

          def process_place_token(action)
            minor_to_merge = find_minor(action.city, action.entity.owner)
            exchange_share(minor_to_merge, action.entity, action.entity) if minor_to_merge
            merge_minor!(minor_to_merge, action.entity, action.entity) if minor_to_merge

            super
          end

          def can_replace_token?(entity, replace_token)
            @game.home_token_locations(entity).include?(replace_token.city.hex)
          end

          def find_minor(city, player)
            @game.minors.find do |minor|
              next unless minor.owner == player
              next unless minor.tokens.first.city == city

              minor
            end
          end

          def can_buy?(entity, bundle)
            return unless bundle&.buyable

            can_gain?(entity, bundle)
          end
        end
      end
    end
  end
end
