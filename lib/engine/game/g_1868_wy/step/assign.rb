# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G1868WY
      module Step
        class Assign < Engine::Step::Assign
          def description
            case current_entity
            when @game.lhp_private
              'Assign the LHP 2+1 train to a Railroad Company'
            when @game.no_bust
              'Place NO BUST token'
            end
          end

          def help
            case current_entity
            when @game.lhp_private
              "#{@game.lhp_private.name} is closing. You may assign the 2+1 train to a Railroad Company for no compensation."
            end
          end

          def actions(entity)
            actions =
              case entity
              when @game.no_bust
                if @game.no_bust.player.nil? || !@game.abilities(entity, :assign_hexes)
                  []
                elsif bust_round?
                  @game.busters.empty? ? [] : %w[assign pass]
                else
                  %w[assign]
                end
              when @game.pure_oil
                %w[assign] if @game.abilities(entity, :assign_hexes)
              when @game.lhp_private
                %w[assign pass] if @game.lhp_train_pending?
              end
            actions || []
          end

          def process_assign(action)
            case action.entity
            when @game.no_bust
              super
              @game.place_no_bust(action.target)
            when @game.pure_oil
              super
              @game.place_pure_oil(action.target)
            when @game.lhp_private
              @game.convert_lhp_train!(action.target)
            end
          end

          def process_pass(action)
            return super unless action.entity == @game.lhp_private

            @game.pass_converting_lhp_train!
          end

          def active_entities
            if @game.lhp_train_pending?
              [@game.lhp_private]
            elsif bust_round? && !@game.no_bust.closed?
              [@game.no_bust]
            else
              super
            end
          end

          def blocks?
            @game.lhp_train_pending? || bust_round?
          end

          def assignable_corporations(company)
            return [] unless company == @game.lhp_private
            return [] unless @game.lhp_train_pending?

            super
          end

          def bust_round?
            @round.is_a?(G1868WY::Round::Bust)
          end

          def log_skip(_entity); end

          def available_hex(entity, hex)
            available = super

            if entity == @game.pure_oil
              available && %i[white yellow].include?(hex.tile.color)
            else
              available
            end
          end
        end
      end
    end
  end
end
