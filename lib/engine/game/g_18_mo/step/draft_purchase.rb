# frozen_string_literal: true

require_relative '../../g_1846/step/draft_distribution'

module Engine
  module Game
    module G18MO
      module Step
        class DraftPurchase < G1846::Step::DraftDistribution
          PASS_COST = 10
          SKIPPING_COST = 5
          def setup
            @companies = @game.companies.reject(&:owned_by_player?).sort_by { @game.rand }
            entities.each(&:unpass!)
          end

          def available
            @companies
          end

          def visible?
            true
          end

          def players_visible?
            true
          end

          def finished?
            @companies.empty? || entities.all?(&:passed?)
          end

          def actions(entity)
            return [] if finished?
            return [] unless entity == current_entity

            ACTIONS_WITH_PASS
          end

          def pass_description
            return 'Pass (for free)' if current_entity.cash < PASS_COST

            "Pass (Pay #{@game.format_currency(PASS_COST)} to discount #{@companies.first.name})"
          end

          def process_pass(action)
            company = @companies.first
            if action.entity.cash >= PASS_COST
              action.entity.spend(PASS_COST, @game.bank)
              company.discount += PASS_COST
              @log << "#{action.entity.name} passes and pays #{@game.format_currency(PASS_COST)} to discount "\
                      "#{company.name} to #{@game.format_currency(company.min_bid)}"
            else
              company.discount += PASS_COST
              @log << "#{action.entity.name} passes and #{company.name} is discounted "\
                      "to #{@game.format_currency(company.min_bid)}"
            end
            @round.next_entity_index!
            action.entity.unpass! # passing doesn't end round
          end

          def process_bid(action)
            action.entity.unpass!
            super
          end

          def extra_cost(company)
            @companies.index(company) * SKIPPING_COST
          end

          def choose_company(player, company)
            raise GameError, "Cannot buy #{company.name}" unless @companies.include?(company)

            total_cost = company.min_bid + extra_cost(company)
            raise GameError, "Cannot afford #{@game.format_currency(total_cost)} for #{company.name}" if player.cash < total_cost

            @log << if total_cost.positive?
                      "#{player.name} buys #{company.name} for #{@game.format_currency(total_cost)}"
                    elsif total_cost.zero?
                      "#{player.name} receives #{company.name} for free"
                    else
                      "#{player.name} receives #{company.name} and #{@game.format_currency(-total_cost)}"
                    end
            @companies.each do |c|
              break if c == company

              c.discount += SKIPPING_COST
              @log << "#{c.name} is discounted to #{@game.format_currency(c.min_bid)}"
            end

            @companies.delete(company)
            company.owner = player
            player.companies << company
            player.spend(total_cost, @game.bank) if total_cost.positive?
            @game.bank.spend(-total_cost, player) if total_cost.negative?

            float_minor(company)
          end

          def action_finalized; end

          def committed_cash
            0
          end

          def may_purchase?(_company)
            true
          end

          def may_choose?(_company)
            false
          end

          def buy_str(company)
            extra = extra_cost(company)
            total = company.min_bid + extra
            return "Select and receive #{@game.format_currency(-total)}" if total.negative?
            return 'Select for free' if total.zero?

            extra_str = extra.positive? ? " + #{@game.format_currency(extra)}" : ''
            "Buy for #{@game.format_currency(company.min_bid)}#{extra_str}"
          end

          def min_bid(company)
            company.min_bid
          end
        end
      end
    end
  end
end
