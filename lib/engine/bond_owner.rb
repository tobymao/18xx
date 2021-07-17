# frozen_string_literal: true

module Engine
  module BondOwner
    def bonds
      bonds_by_issuer.values.flatten
    end

    def bonds_by_issuer(sorted: false)
      @bonds_by_issuer ||= Hash.new { |h, k| h[k] = [] }
      @bonds_by_issuer = @bonds_by_issuer.to_a.sort.to_h if sorted
      @bonds_by_issuer
    end

    def bonds_of(issuer)
      return [] unless issuer

      bonds_by_issuer[issuer]
    end
  end
end
