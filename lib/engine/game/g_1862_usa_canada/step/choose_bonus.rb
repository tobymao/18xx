# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1862UsaCanada
      module Step
        class ChooseBonus < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def description
            'Connection Bonus Choice'
          end

          def actions(entity)
            return [] unless entity.corporation?
            return [] if pending_for(entity).empty?

            ACTIONS
          end

          def choice_name
            bonus, _idx, hex_id = pending_for(current_entity).first
            hex_label = hex_id ? " (#{@game.hex_by_id(hex_id)&.tile&.location_name || hex_id})" : ''
            "#{current_entity.name} reached #{bonus[:name]}#{hex_label}: " \
              "#{@game.format_currency(bonus[:cash])} cash or " \
              "+#{@game.format_currency(bonus[:route_bonus])}/OR permanent?"
          end

          def choices
            bonus, = pending_for(current_entity).first
            {
              'cash'      => "Cash — #{@game.format_currency(bonus[:cash])} to corporation treasury",
              'permanent' => "Permanent — +#{@game.format_currency(bonus[:route_bonus])} route bonus per OR",
            }
          end

          def process_choose(action)
            entity          = action.entity
            bonus, idx, hex = pending_for(entity).first

            case action.choice
            when 'cash'
              @game.bank.spend(bonus[:cash], entity)
              @game.bonus_state[[entity.id, idx]] = :cash
              @game.update_bonus_icon!(entity.id, idx, :cash)
              @log << "#{entity.name} takes #{@game.format_currency(bonus[:cash])} cash " \
                      "for #{bonus[:name]} connection bonus (treasury)"
            when 'permanent'
              @game.bonus_state[[entity.id, idx]] = :permanent
              @game.bonus_hex[[entity.id, idx]]   = hex if hex
              @game.update_bonus_icon!(entity.id, idx, :permanent, hex)
              hex_label = hex ? " at #{@game.hex_by_id(hex)&.tile&.location_name || hex}" : ''
              @log << "#{entity.name} keeps #{bonus[:name]} connection bonus " \
                      "as permanent +#{@game.format_currency(bonus[:route_bonus])}/OR#{hex_label}"
            end

            pass! if pending_for(entity).empty?
          end

          def skip!
            pass!
          end

          private

          def pending_for(entity)
            @game.pending_bonus_activations(entity, @round.routes || [])
          end
        end
      end
    end
  end
end
