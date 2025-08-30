# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'upwards_auction'

module Engine
  module Game
    module GSystem18
      module Step
        class OrderAuction < GSystem18::Step::UpwardsAuction
          def description
            'Bid on Initial Player Order'
          end

          def available
            [@companies.first]
          end

          def initial_auction_entities
            entities.select { |ent| ent.companies.empty? }
          end

          def resolve_bids
            super
            entities.each do |entity|
              if entity.companies.empty?
                entity.unpass!
              else
                entity.pass!
              end
            end

            start_player = @auction_triggerer
            @round.goto_entity!(start_player)
            next_entity!
          end

          def post_price_reduction(company)
            super
            return unless company.min_bid <= 0

            @round.goto_entity!(company.owner)
            company.owner.pass!
            next_entity!
          end
        end
      end
    end
  end
end
