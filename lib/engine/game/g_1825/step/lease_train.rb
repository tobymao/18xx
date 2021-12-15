# frozen_string_literal: true

module Engine
  module Game
    module G1825
      module Step
        module LeaseTrain
          LEASE_COST = 10

          def buyable_items(entity)
            return [] unless entity.receivership?
            return [] if @round.leased_train

            @game.leaseable_trains.map do |t|
              Item.new(description: t.name, cost: LEASE_COST)
            end
          end

          def item_str(item)
            "Lease #{item.description} train from the bank (#{@game.format_currency(item.cost)})"
          end

          def process_special_buy(action)
            item = action.item
            train = @game.leaseable_trains.find { |t| t.name == item.description } || @game.depot.upcoming.first
            entity = action.entity
            @round.leased_train = train

            if entity.cash >= LEASE_COST
              entity.spend(LEASE_COST, @game.bank)
            else
              diff = LEASE_COST - entity.cash
              entity.spend(entity.cash, @game.bank) if entity.cash.positive?
              @round.receivership_loan += diff
            end
            @log << "#{entity.name} leases #{train.name} for #{@game.format_currency(LEASE_COST)}"
          end
        end
      end
    end
  end
end
