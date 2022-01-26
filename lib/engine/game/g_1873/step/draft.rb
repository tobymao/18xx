# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/programmer'

module Engine
  module Game
    module G1873
      module Step
        class Draft < Engine::Step::Base
          include Engine::Step::Programmer

          attr_reader :companies, :choices

          ACTIONS = %w[bid pass].freeze
          PREMIUM_REDUCTION = 10

          def setup
            @companies = @game.start_companies.sort
            @round.players_history[current_entity] = nil
          end

          def round_state
            {
              # What the players did last turn
              players_history: {},
            }
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

          def name
            'Draft'
          end

          def description
            'Draft Private Mines and Concessions'
          end

          def finished?
            @companies.empty? || (entities.all?(&:passed?) && @game.premium.zero?)
          end

          def actions(entity)
            return [] if finished?
            return [] if entity != current_entity
            return %w[bid] if @game.premium_winner

            ACTIONS
          end

          def process_bid(action)
            @game.premium_winner = nil
            company = action.company
            player = action.entity
            price = action.price

            company.owner = player
            player.spend(price + @game.premium, @game.bank)

            @companies.delete(company)
            if (minor = @game.get_mine(company))
              minor.owner = player
              minor.float!
              @game.open_mine!(minor)
              company.close!
              @game.companies.delete(company)
            else
              player.companies << company
            end

            @log << if @game.premium.positive?
                      "#{player.name} buys #{company.name} for #{@game.format_currency(price + @game.premium)}"\
                        " (premium: #{@game.format_currency(@game.premium)})"
                    else
                      "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"
                    end
            @round.players_history[action.entity.player] = action

            action.entity.unpass!
            @round.next_entity_index!
            action_finalized
          end

          def process_pass(action)
            @log << "#{action.entity.name} passes"
            action.entity.pass!
            @round.next_entity_index!
            action_finalized

            return if finished? || !entities.all?(&:passed?)

            @game.premium -= PREMIUM_REDUCTION
            @log << "All have passed. Premium reduced to #{@game.premium}"
            @game.players.each(&:unpass!)
          end

          def auto_actions(entity)
            programmed_auto_actions(entity)
          end

          def activate_program_harzbahn_draft_pass(entity, program)
            if program.until_premium && program.until_premium >= @game.premium
              return [Action::ProgramDisable.new(entity, reason: "Reached target premium #{program.until_premium}")]
            end

            unless program.unconditional
              @round.players_history.each do |other_entity, action|
                next if other_entity == entity
                next unless action
                next if action < program

                return [Action::ProgramDisable.new(entity, reason: "#{action.entity.player.name} bought #{action.company.name}")]
              end
            end

            [Action::Pass.new(entity)]
          end

          def action_finalized
            return unless finished?

            @companies.each do |c|
              if (minor = @game.get_mine(c))
                @game.close_mine!(minor)
                @game.companies.delete(c)
              end
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

          def buy_str(company)
            "Buy (#{@game.format_currency(company.value + @game.premium)})"
          end

          def show_map
            true
          end
        end
      end
    end
  end
end
