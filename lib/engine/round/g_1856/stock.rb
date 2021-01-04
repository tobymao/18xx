# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G1856
      class Stock < Stock
        def players_unvested_holdings
          # Player -> Corp if player has an unvested share in it.
          # This doesn't distinguish the number of shares bought. This is fine for 1856
          #  because the only way to buy more than 1 share is to IPO a corporation and
          #  if you IPO a corporation you cannot in the same action get rid of the presidency
          #  so this works. If 1862EA wanted to borrow from this they would have to rework it
          @players_unvested_holdings ||= {}
        end

        def start_entity
          players_unvested_holdings[@entities[@entity_index]] = nil
          super
        end
      end
    end
  end
end
