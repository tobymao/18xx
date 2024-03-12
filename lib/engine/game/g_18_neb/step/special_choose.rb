# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G18Neb
      module Step
        class SpecialChoose < Engine::Step::SpecialChoose
          def process_choose_ability(action)
            company = action.entity
            raise GameError, "#{company.name} does not have a choice ability" if company != @game.cattle_company

            @log << "#{company.owner.name} (#{company.name}) closes cattle token"
            @log << "#{company.name} closes"
            @game.cattle_token_hex.remove_assignment!(@game.class::CATTLE_OPEN_ICON)
            company.owner.remove_assignment!(@game.class::CATTLE_OPEN_ICON)
            @game.cattle_token_hex.assign!(@game.class::CATTLE_CLOSED_ICON)
            company.owner.assign!(@game.class::CATTLE_CLOSED_ICON)
            company.close!
          end
        end
      end
    end
  end
end
