# frozen_string_literal: true

module Engine
  module Game
    module G18Uruguay
      module Step
        class NationalizeCorporation < Engine::Step::Base
          def description
            'Nationalization offer'
          end

          def actions(entity)
            return [] unless @game.round.round_num == 2
            return [] if !entity.corporation? || entity != current_entity
            return [] if entity == @game.rptla
            return [] if entity == @game.fce
            return [] if @game.merge_data[:corps].include?(entity)
            return [] unless entity.loans.size.positive?
            return [] if @game.maximum_loans(entity) < entity.loans.size
            return [] if @game.merge_data[:corp_share_sum] + (10 * @game.merge_data[:secondary_corps].size) >= 100

            actions = []
            actions << 'choose'
            actions
          end

          def log_skip(entity)
            return unless @game.round.round_num == 2
            return if entity == @game.rptla
            return if entity == @game.fce
            return @log << "#{entity.name} is nationalized" if @game.merge_data[:corps].include?(entity)

            super
          end

          def choice_name
            'Nationalize Croporation'
          end

          def choices
            {
              'handover' => 'Hand over company to FCE',
              'decline' => 'Decline nationalization offer',
            }
          end

          def process_choose(action)
            @game.merge_data[:secondary_corps] << action.entity if action.choice == 'handover'
            pass!
          end
        end
      end
    end
  end
end
