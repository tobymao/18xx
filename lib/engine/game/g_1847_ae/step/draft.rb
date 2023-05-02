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
            @companies = @game.companies.select { |c| c.owner.nil? && !c.closed? }
            @companies = @companies.sort_by { |item| [item.revenue, item.value] }
          end

          def available
            @companies
          end

          def active?
            true
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
            @game.draft_finished = @companies.empty?

            @companies.empty? || entities.all?(&:passed?)
          end

          def actions(entity)
            return [] if finished?

            entity == current_entity ? ACTIONS : []
          end
          
          def process_bid(action, suppress_log = false)
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

              # Give related share to the player and give money for the share to the corporation
              ability.shares.each do |share|
                @game.share_pool.buy_shares(player, share, exchange: :free)
                share.corporation.cash += share.corporation.par_price.price * share.percent / 10
              end
            end

            # PLP company is only a temporary holder for the L presidency
            company.close! if company.id == 'PLP'

            entities.each(&:unpass!)
            action_finalized
            next_player unless finished?
          end

          def process_pass(action, suppress_log = false)
            @log << "#{action.entity.name} passes" unless suppress_log
            action.entity.pass!
            action_finalized
            next_player unless finished?
          end

          def pass_if_no_valid_action
            unless @companies.any? { |c| current_entity.cash >= min_bid(c) }
              @log << "#{current_entity.name} has no valid actions and passes"
              @round.process_action(Engine::Action::Pass.new(current_entity), suppress_log: true)
            end
          end

          def next_player
            @round.next_entity_index!

            pass_if_no_valid_action
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
