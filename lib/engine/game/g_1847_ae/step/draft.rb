# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1847AE
      module Step
        class Draft < Engine::Step::Base
          attr_reader :companies, :choices, :grouped_companies

          ACTIONS = %w[bid pass].freeze

          def setup
            @companies = @game.companies.select { |c| c.owner.nil? }
            @companies = @companies.sort_by { |item| [item.revenue, item.value] }
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
            finished = @companies.empty? || entities.all?(&:passed?)

            if finished && @game.draft_last_acting_index.nil?
              # If not all companies are purchased, the draft will be coninuted after a "short OR".
              # We have to store the index of the last player to have acted, so we can continue with next in order.
              @game.draft_finished = @companies.empty?
              @game.draft_last_acting_index = @round.entity_index
            end

            finished
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

            @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"

            company.abilities.each do |ability|
                next unless ability.type == :shares

                ability.shares.each do |share|
                    @game.share_pool.buy_shares(player, share, exchange: :free)
                end
            end
            
            # PLP company is only a temporary holder for the L presidency
            company.close! if company.id == 'PLP'

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
