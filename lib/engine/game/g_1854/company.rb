# frozen_string_literal: true

require_relative '../../company'

module Engine
  module Game
    module G1854
      class Company < Engine::Company
        attr_reader :corp_sym, :local_railway

        def initialize(**opts)
          @corp_sym = opts.fetch(:corp_sym, nil)
          @local_railway = opts.fetch(:local_railway, false)
          super
        end

        def local_railway?
          @local_railway
        end
      end
    end
  end
end
