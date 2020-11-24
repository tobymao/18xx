# frozen_string_literal: true

module Lib
  module Params
    def self.[](key)
      return nil if `typeof URLSearchParams === 'undefined'` # rubocop:disable Lint/LiteralAsCondition

      Native(`(new URLSearchParams(window.location.search)).get(#{key})`)
    end

    def self.add(route, k, v)
      route = route.split('#')[0]
      route = route.split('?')[0]
      return route unless v

      "#{route}?#{k}=#{v}"
    end
  end
end
