# frozen_string_literal: true

module Engine
  module Game
    module G1849
      class SharePool < Engine::SharePool
        def change_president(presidents_share, swap_to, president, previous_president)
          corporation = presidents_share.corporation

          incoming_pres_shares = president.shares_of(corporation)

          double = incoming_pres_shares.find(&:last_cert)
          shares =
            if double
              if incoming_pres_shares.sum(&:percent) >= 40
                @game.swap_choice_player = previous_president
                @game.swap_location = swap_to
                @game.swap_other_player = president
                @game.swap_corporation = corporation
                @game.log << "Presidency swapped for last cert by default.
                          #{swap_to.name} may choose to swap for two 10% shares instead."
              end
              [double]
            else
              incoming_pres_shares.reject(&:last_cert).take(2)
            end
          shares.each do |s|
            move_share(s, swap_to)
          end
          move_share(presidents_share, president)
        end

        def handle_partial(bundle, from, to)
          move_share(from.shares_of(bundle.corporation).find { |s| !s.last_cert }, to)
        end

        def swap_double_cert(from, to, corporation)
          double = from.shares_of(corporation).find(&:last_cert)
          move_share(double, to)
          shares = to.shares_of(corporation).select { |s| s.percent == 10 }.take(2)
          shares.each { |s| move_share(s, from) }
        end
      end
    end
  end
end
