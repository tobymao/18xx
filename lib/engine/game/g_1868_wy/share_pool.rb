# frozen_string_literal: true

module Engine
  module Game
    module G1868WY
      class SharePool < Engine::SharePool
        def change_president(presidents_share, swap_to, president, _previous_president)
          corporation = presidents_share.corporation

          incoming_pres_shares = president.shares_of(corporation)

          double = incoming_pres_shares.find(&:double_cert)
          shares =
            if double && incoming_pres_shares.size < 4
              [double]
            else
              incoming_pres_shares.reject(&:double_cert).take(2)
            end
          shares.each do |s|
            move_share(s, swap_to)
          end
          move_share(presidents_share, president)
        end

        def handle_partial(bundle, from, to)
          move_share(from.shares_of(bundle.corporation).find { |s| !s.double_cert }, to)
        end

        def swap_double_cert(from, to, corporation)
          double = from.shares_of(corporation).find(&:double_cert)
          move_share(double, to)
          shares = to.shares_of(corporation).select { |s| s.percent == 10 }.take(2)
          shares.each { |s| move_share(s, from) }
        end
      end
    end
  end
end
