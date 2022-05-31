# frozen_string_literal: true

require_relative '../../g_1822/step/special_track'
require_relative 'tracker'

module Engine
  module Game
    module G1822MX
      module Step
        class SpecialTrack < Engine::Game::G1822::Step::SpecialTrack
          include Engine::Game::G1822MX::Tracker

          def abilities(entity, **kwargs, &block)
            return unless entity&.company?

            %i[tile_lay teleport].each do |type|
              ability = @game.abilities(
                entity,
                type,
                time: %w[special_track %current_step% owning_corp_or_turn],
                **kwargs,
                &block
              )
              return ability if ability && (ability.type != :teleport || !ability.used?)
            end

            nil
          end

          def available_hex(entity, hex)
            return hex.tile.color == :blue ? [hex.tile.exits] : nil if @game.port_company?(entity)
            if @game.cube_company?(entity)
              return @game.can_hold_builder_cubes?(hex.tile) && @game.graph.connected_hexes(entity.owner)[hex]
            end

            super
          end

          def process_lay_tile(action)
            if @game.cube_company?(action.entity)
              @log << "#{action.entity.name} places builder cube on #{action.hex.name}"
              action.hex.tile.icons << Part::Icon.new('../icons/1822_mx/red_cube', 'block')
              ability = abilities(action.entity)
              ability.use!
              if ability.count.zero? && ability.closed_when_used_up
                company = ability.owner
                @log << "#{company.name} closes"
                company.close!
              end
            elsif @game.company_ability_extra_track?(action.entity) && action.tile.id == 'BC-0'
              @log << "#{action.entity.name} places builder cube on #{action.hex.name}"
              action.hex.tile.icons << Part::Icon.new('../icons/1822_mx/red_cube', 'block')
              ability = abilities(action.entity)
              ability.use!
              # Minors can only do this once...
              if action.entity.owner.type == :minor
                ability.use!
              else
                @extra_laided_track = true
              end

              if ability.type == :tile_lay && ability.count <= 0 && ability.closed_when_used_up
                @log << "#{ability.owner.name} closes"
                ability.owner.close!
              end
            else
              super
              action.hex.tile.icons.reject! { |i| i.name == 'block' }
            end
          end
        end
      end
    end
  end
end
