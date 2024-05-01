# frozen_string_literal: true

module Engine
  module Game
    module G1847AE
      class SharePool < Engine::SharePool
        def change_president(presidents_share, _swap_to, president, _previous_president)
          corporation = presidents_share.corporation
          incoming_president_shares = president.shares_of(corporation)

          single_shares = incoming_president_shares.reject(&:double_cert)
          shares_to_transfer = if single_shares.size >= 2
                                 single_shares.take(2)
                               else
                                 [incoming_president_shares.find(&:double_cert)].compact
                               end
          # If president's share is sold to Market, the Market is temporarily the owner
          # and it is where the shares should be transferred. In other cases the owner is
          # the previous president
          shares_to_transfer.each { |s| move_share(s, presidents_share.owner) }

          move_share(presidents_share, president)
        end
      end
    end
  end
end
