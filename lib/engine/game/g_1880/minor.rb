# frozen_string_literal: true

require_relative '../../minor'
require_relative '../../share_holder'

module Engine
  module Game
    module G1880
      class Minor < Engine::Minor
        include ShareHolder
        def num_shares_of(corporation, ceil: true)
          num = percent_of(corporation).to_f / corporation.share_percent
          ceil ? num.ceil : num
        end

        def hide_shares?
          false
        end
      end
    end
  end
end
