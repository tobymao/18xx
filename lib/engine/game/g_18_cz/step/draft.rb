# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18CZ
      module Step
        class Draft < Engine::Step::Base
          attr_reader :companies, :choices, :grouped_companies

          ACTIONS = %w[bid pass].freeze

          def setup
            @companies = @game.companies.sort_by { |item| [item.revenue, item.value] }
          end

          def available
            @companies
          end

          def may_purchase?(_company)
            true
          end

          def auctioning; end

          def bids
            {}
          end

          def visible?
            true
          end

          def players_visible?
            true
          end

          def override_entities
            @game.exclude_vaclav(@round.entities)
          end

          def tiered_auction_companies
            @companies.group_by(&:revenue).values
          end

          def name
            'Draft'
          end

          def description
            'Draft Private Companies'
          end

          def finished?
            @companies.empty? || entities.all?(&:passed?)
          end

          def actions(entity)
            return [] if finished?

            unless @companies.any? { |c| current_entity.cash >= min_bid(c) }
              @log << "#{current_entity.name} has no valid actions and passes"
              return []
            end

            entity == current_entity ? ACTIONS : []
          end

          def process_bid(action)
            company = action.company
            player = action.entity
            price = action.price

            company.owner = player
            player.companies << company
            player.spend(price, @game.bank)

            @companies.delete(company)

            @log << "#{player.name} buys [#{@game.company_size(company)}] #{company.name} for #{@game.format_currency(price)}"

            entities.each(&:unpass!)
            @round.next_entity_index!
            action_finalized
          end

          def process_pass(action)
            @log << "#{action.entity.name} passes"
            action.entity.pass!
            @round.next_entity_index!
            action_finalized
          end

          def action_finalized
            return unless finished?

            @companies.each do |c|
              @log << "#{c.name} is removed from the game"
              @game.companies.delete(c)
            end

            @round.reset_entity_index!
          end

          def committed_cash(_player, _show_hidden = false)
            0
          end

          def min_bid(company)
            return unless company

            company.value
          end

          def skip!
            current_entity.pass!
            @round.next_entity_index!
            action_finalized
          end
        end
      end
    end
  end
end
