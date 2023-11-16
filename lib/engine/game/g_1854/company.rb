# frozen_string_literal: true

require_relative '../../company'

module Engine
  module Game
    module G1854
      class Company < Engine::Company
        attr_reader :corp_sym

        def initialize(**opts)
          @corp_sym = opts.fetch(:corp_sym,nil)
          super
        end
      end
    end
  end
end
