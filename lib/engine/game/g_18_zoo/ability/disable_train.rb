# frozen_string_literal: true

module Engine
  module G18ZOO
    module Ability
      class DisableTrain < Engine::Ability::Base
        attr_reader :train

        def setup(train:)
          @train = train
        end
      end
    end
  end
end
