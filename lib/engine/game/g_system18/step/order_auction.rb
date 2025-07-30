# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'upwards_auction'

module Engine
  module Game
    module GSystem18
      module Step
        class OrderAuction < GSystem18::Step::UpwardsAuction
          def actions(entity)
            acts = super.dup

            acts.delete('pass') unless auctioning
            acts
          end

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
        end
      end
    end
  end
end
