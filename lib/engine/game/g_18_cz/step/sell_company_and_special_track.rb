# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18CZ
      module Step
        class SellCompanyAndSpecialTrack < Engine::Step::SpecialTrack
          def actions(entity)
            actions = []
            abilities = abilities(entity)
            actions << 'lay_tile' if abilities
            actions << 'sell_company' if (entity.company? && entity.owner == current_entity) || entity == current_entity

            actions
          end

          def process_sell_company(action)
            corporation = action.entity
            company = action.company
            price = action.price

            @game.bank.spend(price, corporation)

            @log << "#{corporation.name} sells #{company.name} for #{@game.format_currency(price)} to the bank"

            company.close!

            @log << "#{company.name} closes"
          end

          def process_lay_tile(action)
            owner = if !action.entity.owner
                      nil
                    elsif action.entity.owner.corporation?
                      action.entity.owner
                    else
                      @game.current_entity
                    end

            unless @game.purple_tile?(action.tile)
              discount = action.hex.tile.upgrades.sum(&:cost)
              @log << "#{action.entity.owner.name} receives a discount of "\
                      "#{@game.format_currency(discount)} from "\
                      "#{action.entity.name}"
            end

            lay_tile(action, spender: owner)
            @round.laid_hexes << action.hex

            # Record any track laid after the dividend step
            if owner&.corporation? && (operating_info = owner.operating_history[[@game.turn, @round.round_num]])
              operating_info.laid_hexes = @round.laid_hexes
            end

            @round.num_laid_track += 1 unless @game.purple_tile?(action.tile)

            abilities = @game.abilities(action.entity, :tile_lay, time: 'any')
            abilities.each(&:use!)
          end

          def hex_neighbors(entity, hex)
            return unless (abilities = abilities(entity))
            return if abilities.all? { |ability| !ability.hexes&.none? && !ability.hexes&.include?(hex.id) }

            operator = entity.owner.corporation? ? entity.owner : @game.current_entity
            return if abilities.all? do |ability|
                        ability.reachable && !@game.graph.connected_hexes(operator)[hex]
                      end

            @game.graph.connected_hexes(operator)[hex]
          end

          def potential_tiles(entity, hex)
            return [] unless (abilities = abilities(entity))

            abilities_for_hex = abilities.select do |ability|
              ability.hexes&.empty? || ability.hexes&.include?(hex.coordinates)
            end

            all_possible_tiles = abilities_for_hex.flat_map(&:tiles)

            all_possible_tiles.map { |name| @game.tiles.find { |t| t.name == name } }
              .compact
              .select { |t| @game.phase.tiles.include?(t.color) && @game.upgrades_to?(hex.tile, t, false) }
          end

          def available_hex(entity, hex)
            hex_neighbors(entity, hex)
          end

          def abilities(entity, **kwargs, &block)
            return unless entity&.company?

            time = %w[special_track owning_corp_or_turn]
            time << '%current_step%' if @game.tile_lays(entity.corporation)[@round.num_laid_track]

            abilities = @game.abilities(
              entity,
              :tile_lay,
              time: time,
              **kwargs,
              &block
            )

            return nil if abilities.nil?
            return abilities if abilities.is_a?(Array)

            [abilities]
          end
        end
      end
    end
  end
end
