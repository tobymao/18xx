# frozen_string_literal: true

module Lib
  module Params
    def self.[](key)
      URLSearchParams.new[key]
    end

    def self.add(route, k, v)
      route = (route || '').split(/[?\#]/)[0]
      return route unless v

      "#{route}?#{k}=#{v}"
    end

    class URLSearchParams
      attr_reader :unsupported

      def initialize
        @unsupported = `typeof URLSearchParams === 'undefined'`
        @native = Native(`new URLSearchParams(window.location.search)`) unless @unsupported
      end

      def [](key)
        @native&.get(key)
      end

      def []=(key, value)
        if !value || value.to_s.empty?
          @native&.delete(key)
        else
          @native&.set(key, value)
        end
      end

      def to_query_string
        # TODO: after https://github.com/opal/opal/pull/2584 is included in a
        # release, upgrade Opal to that release and revert this function to:
        #
        # @native&.toString() || ''

        # https://github.com/opal/opal/issues/2583#issuecomment-1718381113
        `Opal.truthy(self.native) ? self.native.native.toString() : nil` || ''
      end
    end
  end
end
