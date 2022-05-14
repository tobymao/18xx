# frozen_string_literal: true

require_relative '../../../step/buy_company'
require_relative '../../../game_error'

module Engine
  module Game
    module G18SJ
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def actions(entity)
            return [] if @game.bot_corporation?(entity)

            super
          end

          def process_buy_company(action)
            return super unless action.company == @game.company_khj

            minor = @game.minor_khj
            buyer = action.entity
            train_count = minor.trains.size + buyer.trains.size

            if train_count > @game.train_limit(buyer)
              raise GameError, "Cannot merge minor #{minor.name} as it exceeds train limit"
            end

            super

            @log << "#{minor.name} merges into #{buyer.name}"

            duplicate_count = @game.remove_duplicate_tokens(buyer, minor)

            @game.remove_reservation(minor)

            # If owner don't have token in KHJ home, transfer it to owner
            @game.transfer_home_token(buyer, minor) unless duplicate_count.positive?

            if minor.trains.size.zero?
              transfer_trains(buyer, minor)
            else
              khj_train = minor.trains.first
              transfer_trains(buyer, minor)
              @log << 'The former KHJ train cannot be operated more this OR (see rule 7.3)'
              khj_train.operated = true
            end

            transfer_money(buyer, minor)

            minor.close!

            @game.graph.clear_graph_for(minor)

            # Close company as it no longer has any effect
            action.company.close!
          end

          private

          # Any trains in minor are transfered, and made buyable
          # Rule 7.3 allows train to be reused during the OR.
          def transfer_trains(buyer, minor)
            return if minor.trains.empty?

            minor.trains.each do |t|
              t.operated = false
              t.buyable = true
            end

            transferred = @game.transfer(:trains, minor, buyer)
            @log << "#{buyer.name} receives the trains: #{transferred.map(&:name).join(', ')}"
          end

          def transfer_money(buyer, minor)
            return unless minor.cash.positive?

            @log << "#{buyer.name} receives treasury: #{@game.format_currency(minor.cash)}"
            minor.spend(minor.cash, buyer)
          end
        end
      end
    end
  end
end
