# frozen_string_literal: true

require_relative '../company'

module Engine
  module G18ZOO
    class Company < Engine::Company
      attr_accessor :phase
    end
  end
end
