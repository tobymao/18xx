# frozen_string_literal: true

require_relative '../base'
require_relative '../../token'
require_relative '../token_merger'

module Engine
  module Step
    module G18EU
      class Merge < Base
        include TokenMerger

        # TODO: Implement Mergers
      end
    end
  end
end
