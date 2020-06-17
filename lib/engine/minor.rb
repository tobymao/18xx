# frozen_string_literal: true

require_relative 'ownable'
require_relative 'passer'
require_relative 'spender'
require_relative 'operator'

module Engine
  class Minor
    include Operator
    include Ownable
    include Passer
    include Spender

    attr_reader :name, :full_name

    def initialize(sym:, name:, **opts)
      @name = sym
      @full_name = name
      init_operator(opts)
    end

    def abilities(_type); end

    def companies
      @companies ||= []
    end

    def id
      @name
    end

    def player?
      false
    end

    def company?
      false
    end

    def corporation?
      false
    end

    def minor?
      true
    end
  end
end
