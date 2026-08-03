# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1835
      module Step
        class Draft < Engine::Step::Base
          ACTIONS = %w[bid pass].freeze

          def setup
            @companies = @game.companies.select { |c| c.owner.nil? && !c.closed? }

            @tiered_companies = Array.new(4) { [] }
            @companies.each do |company|
              @tiered_companies[company.auction_row] << company
            end
          end

          def available
            @companies
          end

          def main_description
            'Draft items'
          end

          def description
            'Drafting items'
          end

          def may_purchase?(company)
            return false unless company

            top_row = @tiered_companies.find { |row| !row.empty? }
            return false unless top_row

            if top_row.size == 1 && top_row.first.sym == 'BY_D'
              second_row = @tiered_companies[@tiered_companies.index(top_row) + 1]
              return true if company == top_row.first || (second_row && company == second_row.first)
            end

            company == top_row.first
          end

          def min_bid(company)
            company.value
          end

          def finished?
            @companies.empty?
          end

          def auctioning
            nil
          end

          def visible?(_company)
            true
          end

          def players_visible?
            true
          end

          def bids(_company)
            []
          end

          def bids(_company = nil)
            {}
          end
          
          def min_increment
            1
          end

          def can_bid?(_company)
            false
          end

          def max_bid(entity, _company)
            entity.cash
          end

          def actions(entity)
            return [] if finished?

            entity == current_entity ? ACTIONS : []
          end

          def auto_actions(entity)
            return [Engine::Action::Pass.new(entity)] if entity.player? && @companies.none? do |c|
                                                           entity.cash >= c.value
                                                         end

            []
          end

          def skip!
            current_entity.pass!
            @round.next_entity_index!
          end

          def process_bid(action)
            company = action.company
            player = action.entity
            price = company.value

            unless may_purchase?(company)
              raise GameError, "Cannot purchase #{company.name} as it is not the top-most item"
            end

            player.spend(price, @game.bank)
            company.owner = player
            player.companies << company
            @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"

            if company.sym == 'BY_D'
              share = @game.corporation_by_id('BY').shares.first
              buy_share(player, share)
            elsif company.sym == 'LD'
              share = @game.corporation_by_id('SX').shares.first
              buy_share(player, share)
            end

            @companies.delete(company)
            @tiered_companies.each { |row| row.delete(company) }

            @round.last_to_act = player
            @round.next_entity_index!
            action_finalized
          end

          def process_pass(action)
            @log << "#{action.entity.name} passes"
            action.entity.pass!
            @round.last_to_act = action.entity
            @round.next_entity_index!
            action_finalized
          end

          def action_finalized
          end

          def may_choose?(_company)
            false
          end

          def buy_share(player, share)
            allow_president_change = share.president || !share.corporation.shares.first.president
            @game.share_pool.transfer_shares(ShareBundle.new(share), player,
                                             allow_president_change: allow_president_change)

            @game.place_home_token(share.corporation) if share.corporation.floated?
          end

          def committed_cash(_player, _show_everything = false)
            0
          end
        end
      end
    end
  end
end