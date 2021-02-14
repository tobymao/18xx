# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1873
      class Draft < Base
        attr_reader :companies, :choices

        ACTIONS = %w[bid pass].freeze
        PREMIUM_REDUCTION = 10

        def setup
          @companies = @game.start_companies.sort
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

          entity == current_entity ? ACTIONS : []
        end

        def process_bid(action)
          company = action.company
          player = action.entity
          price = action.price

          company.owner = player
          player.spend(price + @game.premium, @game.bank)

          @companies.delete(company)
          if (minor = @game.get_mine(company))
            minor.owner = player
            minor.float!
            company.close!
          else
            player.companies << company
          end

          @log << if @game.premium.positive?
                    "#{player.name} buys #{company.name} for #{@game.format_currency(price + @game.premium)}"\
                      " (premium: #{@game.format_currency(@game.premium)})"
                  else
                    "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"
                  end

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

        def action_finalized
          return unless finished?

          @companies.each do |c|
            if (minor = @game.get_mine(c))
              @game.companies.delete(c)
              @game.close_mine(minor)
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
      end
    end
  end
end
