# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G18Dixie
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout withhold].freeze
          include Engine::Step::HalfPay
          include Engine::Step::MinorHalfPay
          def rust_obsolete_trains!(entity)
            rusted_trains = entity.trains.select(&:obsolete).each do |train|
              @game.remove_spare_part(train)
              @game.rust(train)
            end

            @log << '-- Event: Obsolete trains rust --' if rusted_trains.any?
          end
        end
      end
    end
  end
end
