# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1873
      module Step
        class Convert < Engine::Step::Base
          def actions(entity)
            return [] if entity.minor? && !entity.owner
            return %w[convert pass] if can_convert?(entity)

            []
          end

          def description
            return 'Close Mine' if current_entity.minor?
            return 'Convert to 5 Share' if current_entity.total_shares == 2

            'Convert to 10 Share'
          end

          def pass_description
            return 'Stay Open' if current_entity.minor?

            'Do not convert'
          end

          def log_skip(entity)
            super if !entity.minor? || entity.owner
          end

          def skip!
            if !@acted && current_entity && current_entity != @game.mhe &&
                (current_entity.minor? || current_entity.total_shares < 10)
              log_skip(current_entity)
            end
            pass!
          end

          def can_convert?(entity)
            return true if entity.minor?
            return false unless entity.corporation?
            return false if entity.receivership?
            return false unless entity.total_shares < 10
            return false unless entity.num_market_shares.zero? && entity.num_ipo_shares.zero?

            entity.total_shares < 5 || entity.owner.num_shares_of(entity) >= 2
          end

          def process_convert(action)
            entity = action.entity
            if entity.minor?
              @game.close_mine!(entity)
            else
              @game.convert!(entity)
            end

            pass!
          end
        end
      end
    end
  end
end
