# frozen_string_literal: true

module Engine
  module Game
    module G18MS
      class PlayerInfo < Engine::PlayerInfo
        def round
          case round_name
          when 'OR'
            "#{round_name} #{((turn - 1) * 2) + round_no}"
          when 'DR'
            'ISR'
          else
            "#{round_name} #{turn}"
          end
        end
      end
    end
  end
end
