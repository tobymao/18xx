# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1850
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def actions(entity)
            return [] unless can_use_special_track?(entity)

            acts = super
            acts += ['choose_ability'] if can_buy_mesabi_token_with_wlg?(entity)
            acts
          end

          def choices_ability(entity)
            return [] unless can_buy_mesabi_token_with_wlg?(entity)

            [['Buy Mesabi Token', 'Buy Mesabi Token']]
          end

          def process_choose_ability(action)
            return unless action.choice == 'Buy Mesabi Token'

            ability = @game.abilities(@game.wlg_company, :tile_lay, time: 'track')
            track_step.buy_mesabi_token(@game.wlg_company.owner)
            ability.use!
          end

          def can_use_special_track?(entity)
            @round.steps.find { |step| step.is_a?(Track) }.acted || entity == @game.river_company
          end

          def process_lay_tile(action)
            ability = abilities(action.entity)
            super
            fix_ability_only_western(ability) if action.entity == @game.wlg_company && !@game.western_hex?(action.hex)
          end

          def fix_ability_only_western(ability)
            ability.hexes = @game.class::WEST_RIVER_HEXES
          end

          private

          def can_buy_mesabi_token_with_wlg?(entity)
            corp = if entity == @game.wlg_company
                     entity.owner
                   elsif entity.corporation?
                     entity
                   end
            return false unless corp&.corporation?
            return false unless corp.companies.include?(@game.wlg_company)

            track_step.can_buy_mesabi_token_without_lay?(corp)
          end

          def track_step
            @round.steps.find { |step| step.is_a?(Track) }
          end
        end
      end
    end
  end
end
