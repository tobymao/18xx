# frozen_string_literal: true

module Engine
  module Transfer
    def transfer(ownable_type, to)
      ownables = send(ownable_type)
      to_ownables = to.send(ownable_type)

      ownables.each do |ownable|
        ownable.owner = to
        to_ownables << ownable
      end

      transferred = ownables.dup
      ownables.clear
      transferred
    end
  end
end
