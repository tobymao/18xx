# frozen_string_literal: true

module Engine
  module Step
    module MinorWithold
      def actions(entity)
        return [] if entity.minor?
        return [] if entity.corporation? && entity.type == :minor

        super
      end

      def skip!
        return super if current_entity.corporation? && !current_entity.minor?

        process_dividend(Action::Dividend.new(
          current_entity,
          kind: 'withhold',
        ))
      end
    end
  end
end
