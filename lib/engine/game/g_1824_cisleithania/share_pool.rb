# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G1824Cisleithania
      class SharePool < Engine::SharePool
        def bank_at_limit?(corporation)
          return super unless @game.bond_railway?(corporation)

          false
        end

        def transfer_shares(bundle,
                            to_entity,
                            spender: nil,
                            receiver: nil,
                            price: nil,
                            allow_president_change: true,
                            swap: nil,
                            borrow_from: nil,
                            swap_to_entity: nil,
                            corporate_transfer: nil)
          return super unless transfer_of_bond_railway_shares?(bundle)

          # Rule X.4: The construction regional does not have any president
          super(
            bundle,
            to_entity,
            spender: spender,
            receiver: receiver,
            price: price,
            allow_president_change: false,
            swap: swap,
            borrow_from: borrow_from,
            swap_to_entity: swap_to_entity,
            corporate_transfer: corporate_transfer
          )
        end

        private

        def transfer_of_bond_railway_shares?(bundle)
          bundle && @game.two_player? && @game.bond_railway?(bundle.corporation)
        end
      end
    end
  end
end
