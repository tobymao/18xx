# frozen_string_literal: true

require_relative '../../g_1817/step/acquire'

module Engine
  module Game
    module G18USA
      module Step
        class Acquire < G1817::Step::Acquire
          def actions(entity)
            actions = super
            if entity.corporation? && entity == @buyer && entity.trains.any? { |t| @game.pullman_train?(t) }
              actions = %w[pass] if actions.empty?
              actions << 'scrap_train'
            end
            actions
          end

          def pass_description
            if @offer
              'Pass (Offer for Sale)'
            elsif @auctioning
              'Pass (Bid)'
            elsif @buyer && can_take_loan?(@buyer)
              'Pass (Take Loan)'
            elsif @buyer && can_payoff?(@buyer)
              'Pass (On payoff Loan)'
            elsif @buyer
              'Pass (Scrap Train)'
            end
          end

          def process_pass(action)
            if @offer
              @game.log << "#{@offer.owner.name} declines to put #{@offer.name} up for sale"
              @round.offering.delete(@offer)
              @offer = nil
              setup_auction
            elsif @buyer && can_take_loan?(@buyer)
              @passed_take_loans = true
              @game.log << "#{@buyer.name} passes taking additional loans"
              acquire_post_loan
            elsif @buyer && can_payoff?(@buyer)
              @passed_payoff_loans = true
              @game.log << "#{@buyer.name} passes paying off additional loans"
              acquire_post_loan
            elsif @buyer
              @passed_scrap_trains = true
              @game.log << "#{@buyer.name} passes scrapping trains"
              acquire_post_loan
            else
              pass_auction(action.entity)
            end
          end

          def acquire_post_loan
            return if can_scrap_train?(@buyer)

            super
          end

          def can_scrap_train?(entity)
            return true if entity.corporation? && !@passed_scrap_trains && entity.trains.find { |t| @game.pullman_train?(t) }
          end

          def scrappable_trains(entity)
            entity.trains.select { |t| t.name == 'P' }
          end

          def scrap_info(_)
            @game.scrap_info
          end

          def scrap_button_text(_)
            @game.scrap_button_text
          end

          def process_scrap_train(action)
            @corporate_action = action
            @game.scrap_train_by_corporation(action, current_entity)
          end
        end
      end
    end
  end
end
