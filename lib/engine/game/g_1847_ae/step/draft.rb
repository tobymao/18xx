# frozen_string_literal: true

require_relative '../../../step/simple_draft'

module Engine
  module Game
    module G1847AE
      module Step
        class Draft < Engine::Step::SimpleDraft
          attr_reader :grouped_companies

          ACTIONS = %w[bid pass].freeze

          def setup
            @companies = @game.companies.select { |c| c.owner.nil? && !c.closed? }
            @companies = @companies.sort_by { |item| [item.revenue, item.value] }
          end

          def actions(entity)
            return [] if finished?

            entity == current_entity ? ACTIONS : []
          end

          def active?
            true
          end

          def tiered_auction_companies
            @companies.group_by(&:revenue).values
          end

          def description
            'Draft Private Companies'
          end

          def finished?
            @game.draft_finished = @companies.empty?

            @companies.empty? || entities.all?(&:passed?)
          end

          def process_bid(action, _suppress_log = false)
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
            next_player! unless finished?
          end

          def process_pass(action, suppress_log = false)
            @log << "#{action.entity.name} passes" unless suppress_log
            action.entity.pass!
            action_finalized
            next_player! unless finished?
          end

          def pass_if_no_valid_action!
            return if @companies.any? { |c| current_entity.cash >= min_bid(c) }

            @log << "#{current_entity.name} has no valid actions and passes"
            @round.process_action(Engine::Action::Pass.new(current_entity), suppress_log: true)
          end

          def next_player!
            @round.next_entity_index!

            pass_if_no_valid_action!
          end

          def action_finalized
            return unless finished?

            @round.reset_entity_index!
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
