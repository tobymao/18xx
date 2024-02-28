# frozen_string_literal: true

require_relative '../../corporation'
# require 'pry-byebug'
module Engine
  module Game
    module G1854
      class Corporation < Engine::Corporation
        attr_accessor :shares_split

        def initialize(**opts)
          @shares_split = false
          @forced_share_percent = opts[:forced_share_percent]
          super
        end

        def shares_split?
          @shares_split
        end
      end
    end
  end
end
