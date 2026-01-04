# frozen_string_literal: true

require_relative '../../g_1846/step/assign'

module Engine
  module Game
    module G18BB
      module Step
        class Assign < G1846::Step::Assign
          def actions(entity)
            actions = entity.company? && entity.sym == 'GMC' ? gmc_actions(entity) : super

            return actions unless blocking?

            ACTIONS_WITH_PASS
          end

          def gmc_actions(entity)
            has_assign = @game.abilities(entity, :assign_hexes) || @game.abilities(entity, :assign_corporation)
            return ACTIONS if has_assign && @game.tiles.none? { |t| t.name == 'M1' }

            []
          end

          def setup
            @steamboat = @game.steamboat
            @sw_steamboat = @game.sw_steamboat
            @oil_and_gas = @game.oil_and_gas
          end

          def assignable_corporations(company = nil)
            assignable_corporations = @game.minors.select { |m| m.floated? && !m.assigned?(company&.id) } + super
            assignable_corporations.uniq
          end

          def blocking_for_steamboat?
            return false unless @round.operating?
            return false unless @steamboat.owned_by_player?
            return true if steamboat_assignable_to_corp?
            return true if steamboat_assignable_to_hex?

            false
          end

          def blocking_for_sw_steamboat?
            return false unless @round.operating?
            return false unless @sw_steamboat.owned_by_player?
            return true if sw_steamboat_assignable_to_corp?
            return true if sw_steamboat_assignable_to_hex?

            false
          end

          def blocking_for_oil_and_gas?
            return false unless @round.operating?
            return false unless @oil_and_gas.owned_by_player?
            return true if oil_and_gas_assignable_to_corp?
            return true if oil_and_gas_assignable_to_hex?

            false
          end

          def blocking?
            blocking_for_steamboat? || blocking_for_sw_steamboat? || blocking_for_oil_and_gas?
          end

          def description
            return super unless blocking?

            case active_entities.first&.id
            when 'SC'
              'Assign Steamboat Company'
            when 'SSC'
              'Assign Southwest Steamboat Company'
            when 'O&G'
              'Assign Oil and Gas Company'
            end
          end

          def assigned_hex(company)
            return unless company

            @game.hexes.find { |h| h.assigned?(company.id) }
          end

          def assigned_corp(company)
            return unless company

            assignable_corporations.find { |c| c.assigned?(company.id) }
          end

          def oil_and_gas_assignable_to_corp?
            return false unless @game.abilities(@oil_and_gas, :assign_corporation, time: 'or_start', strict_time: false)

            !assignable_corporations(@oil_and_gas).empty?
          end

          def oil_and_gas_assignable_to_hex?
            return false unless @game.abilities(@oil_and_gas, :assign_hexes, time: 'or_start', strict_time: false)
            return true if assigned_corp(@oil_and_gas)

            oil_and_gas_assignable_to_corp?
          end

          def sw_steamboat_assignable_to_corp?
            return false unless @game.abilities(@sw_steamboat, :assign_corporation, time: 'or_start', strict_time: false)

            !assignable_corporations(@sw_steamboat).empty?
          end

          def sw_steamboat_assignable_to_hex?
            return false unless @game.abilities(@sw_steamboat, :assign_hexes, time: 'or_start', strict_time: false)
            return true if sw_steamboat_assigned_corp(@sw_steamboat)
          end

          def steamboat_assignable_to_corp?
            return false unless @game.abilities(@steamboat, :assign_corporation, time: 'or_start', strict_time: false)

            !assignable_corporations(@steamboat).empty?
          end

          def steamboat_assignable_to_hex?
            return false unless @game.abilities(@steamboat, :assign_hexes, time: 'or_start', strict_time: false)
            return true if assigned_corp(@steamboat)

            steamboat_assignable_to_corp?
          end

          def help
            return super unless blocking_for_steamboat?

            assignments = [assigned_hex(@steamboat), assigned_corp(@steamboat)].compact.map(&:name)

            targets = []
            targets << 'hex' if steamboat_assignable_to_hex?
            targets << 'corporation or minor' if steamboat_assignable_to_corp?

            help_text = ["#{@steamboat.owner.name} may assign Steamboat Company to a new #{targets.join(' and/or ')}."]
            help_text << " Currently assigned to #{assignments.join(' and ')}." if assignments.any?

            help_text
          end

          def active_entities
            if blocking_for_steamboat?
              [@steamboat]
            elsif blocking_for_sw_steamboat?
              [@sw_steamboat]
            elsif blocking_for_oil_and_gas?
              [@oil_and_gas]
            else
              super
            end
          end

          def active?
            blocking? || super
          end

          def blocks?
            blocking?
          end

          def process_pass(action)
            if (ability = @game.abilities(action.entity, :assign_hexes, time: 'or_start', strict_time: false))
              ability.use!
              @log <<
                if (hex = assigned_hex(action.entity))
                  "#{action.entity.name} is assigned to #{hex.name}"
                else
                  "#{action.entity.name} is not assigned to any hex"
                end
            end

            if (ability = @game.abilities(action.entity, :assign_corporation, time: 'or_start', strict_time: false))
              ability.use!
              @log <<
                if (corp = assigned_corp(action.entity))
                  "#{action.entity.name} is assigned to #{corp.name}"
                else
                  "#{action.entity.name} is not assigned to any corporation or minor"
                end
            end

            pass!
          end
        end
      end
    end
  end
end
