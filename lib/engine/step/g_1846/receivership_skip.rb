# frozen_string_literal: true

module Engine
  module Step
    module G1846
      module ReceivershipSkip
        def actions(entity)
          entity.receivership? ? [] : super
        end
      end
    end
  end
end
