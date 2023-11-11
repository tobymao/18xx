# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G1880
      module Step
        class Assign < Engine::Step::Assign
          ACTIONS_WITH_PASS = %w[assign pass].freeze
          def actions(entity)
            return [] if entity.player? || current_entity.minor?
            return [] unless @game.abilities(entity, :assign_corporation)

            return ACTIONS if @game.forced_exchange_rocket? && entity == @game.rocket
            return ACTIONS_WITH_PASS if p5_block?

            super
          end

          def assignable_corporations(_company = nil)
            @game.forced_exchange_rocket? ? assignable_corporations_rocket : super
          end

          def assignable_corporations_rocket
            return rocket_corps_with_slots unless rocket_corps_with_slots.empty?

            # no corps with slots, show all corps.
            @game.corporations.select { |c| c.owner == @game.rocket.owner }
          end

          def rocket_corps_with_slots
            @game.corporations.select { |c| c.owner == @game.rocket.owner && c.trains.length < @game.train_limit(c) }
          end

          def active_entities
            @game.forced_exchange_rocket? ? [@game.rocket] : super
          end

          def description
            @game.forced_exchange_rocket? ? 'Forced Exchange for Rocket of China' : 'Assign Jeme Tien Yow Engineer Office'
          end

          def help
            return super unless @game.forced_exchange_rocket?

            'Owner of Rocket of China must choose one of their corporations to receive the next 4 train from the depot at no cost'
          end

          def blocks?
            @game.forced_exchange_rocket? || p5_block?
          end

          def p5_block?
            @game.phase.name[0] == 'D' && !@game.p5.all_abilities.empty? && current_entity.corporation? \
            && current_entity.owner == @game.p5.owner && !current_entity.building_permits&.include?('D')
          end

          def process_assign(action)
            return process_assign_rocket(action) if @game.forced_exchange_rocket?
            raise GameError, "#{current_entity.id} already has a D permit" if current_entity.building_permits&.include?('D')

            super
            corporation = action.target
            @game.log << "#{corporation.name} receives a D building permit"
            corporation.building_permits += 'D'
          end

          def process_assign_rocket(action)
            buying_corp = action.target
            train = @game.rocket_train || @game.depot.upcoming.first
            @log << "#{buying_corp.name} exchanges #{@game.rocket.name} for a free #{train.name} train"

            @game.rocket.close!
            @game.buy_train(buying_corp, train, :free)
            @game.phase.buying_train!(buying_corp, train, @game.depot)
          end
        end
      end
    end
  end
end
