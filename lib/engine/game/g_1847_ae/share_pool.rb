# frozen_string_literal: true

module Engine
  module Game
    module G1847AE
      class SharePool < Engine::SharePool
        def change_president(presidents_share, swap_to, president, _previous_president)
          corporation = presidents_share.corporation
          incoming_pres_shares = president.shares_of(corporation)

          single_shares = incoming_pres_shares.reject(&:double_cert)
          shares_to_transfer = if single_shares.size >= 2
                                 single_shares.take(2)
                               else
                                 [incoming_pres_shares.find(&:double_cert)]
                               end
          shares_to_transfer.each { |s| move_share(s, swap_to) }

          move_share(presidents_share, president)
        end
      end
    end
  end
end
