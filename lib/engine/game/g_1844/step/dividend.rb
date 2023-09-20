# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1844
      module Step
        class Dividend < Engine::Step::Dividend
          def dividends_for_entity(entity, holder, per_share)
            dividends = (holder.num_shares_of(entity, ceil: false) * per_share)
            holder == @game.share_pool ? dividends.floor : dividends.ceil
          end
        end
      end
    end
  end
end
