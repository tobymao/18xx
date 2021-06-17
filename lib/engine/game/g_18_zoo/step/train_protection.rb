# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18ZOO
      module Step
        class TrainProtection < Engine::Step::Base
          def actions(_entity)
            actions = []
            actions << 'choose' if @round.entity_with_bandage
            actions << 'pass' unless actions.empty?
            actions
          end

          def description
            'Train protect'
          end

          def round_state
            super.merge(entity_with_bandage: nil, trains_for_bandage: [])
          end

          def active_entities
            return [] unless @round.entity_with_bandage

            [@round.entity_with_bandage]
          end

          def blocks?
            @round.entity_with_bandage
          end

          def choice_available?(entity)
            entity == @round.entity_with_bandage
          end

          def choice_name
            'Assign the patch to a train before rusting'
          end

          def choices
            @round.trains_for_bandage
                  .map { |train| [train.id, "#{train.name} (#{train.owner.name})"] }
                  .uniq { |_, name| name }
                  .to_h
          end

          def process_choose(action)
            train = @game.train_by_id(action.choice)
            owner = train.owner.name
            rusts_on = "#{train.rusts_on}-0" if train.rusts_on
            @game.assign_bandage(train)

            @log << "#{train.name} owned by #{owner} gets a patch and is not rusted"

            @round.trains_for_bandage.delete(train)
            @game.rust_trains!(@game.train_by_id(rusts_on), nil) if rusts_on

            @round.entity_with_bandage = nil
            @round.trains_for_bandage = []
          end

          def process_pass(action)
            train = @round.trains_for_bandage.first
            @game.rust_trains!(@game.train_by_id("#{train.rusts_on}-0"), nil) if train.rusts_on
            @round.entity_with_bandage = nil
            @round.trains_for_bandage = []

            super
          end

          def ipo_type(_entity) end
        end
      end
    end
  end
end
