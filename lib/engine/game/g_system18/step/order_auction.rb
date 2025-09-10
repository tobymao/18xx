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

          def all_pass_next_entity
            # skip over players with companies
            @round.next_entity_index!
            @round.next_entity_index! until @round.current_entity.companies.empty?
          end

          def post_win_order(winning_player)
            # winner cannot compete in future auctions
            entities.each do |entity|
              if entity.companies.empty?
                entity.unpass!
              else
                entity.pass!
              end
            end

            # no need to move PD
            @round.goto_entity!(winning_player)
            next_entity!
          end
        end
      end
    end
  end
end
