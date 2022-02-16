# frozen_string_literal: true

module Engine
  module Game
    module G18MT
      module Train
        def must_issue_before_ebuy?(corporation)
          corporation.trains.none? && !@game.emergency_issuable_bundles(corporation).empty?
        end

        def buyable_train_variants(train, entity)
          return [] unless buyable_trains(entity).any? { |bt| bt.variants[bt.name] }

          train.variants.values
        end

        def president_may_contribute?(entity, _shell = nil)
          return false if must_issue_before_ebuy?(entity)

          super
        end

        def buyable_trains(entity)
          trains = super

          return trains.reject(&:owned_by_corporation?) if @last_share_issued_price

          trains
        end
      end
    end
  end
end
