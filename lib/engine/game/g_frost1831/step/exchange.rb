# frozen_string_literal: true

require_relative '../../../step/exchange'
require_relative 'faction_certificates'

module Engine
  module Game
    module GFrost1831
      module Step
        # Affiliate: exchanged in a Stock Round for a Faction certificate
        class Exchange < Engine::Step::Exchange
          include FactionCertificates

          def process_buy_shares(action)
            company = action.entity
            faction = action.bundle.corporation
            return super unless faction.type == :faction
            raise GameError, "Cannot exchange #{company.name} for #{faction.name}" unless can_exchange?(company, action.bundle)

            @log << "#{company.owner.name} exchanges #{company.name} for a share of #{faction.name}"
            gain_faction_certificate(company.owner, faction, bundle: action.bundle)
            company.close!
          end
        end
      end
    end
  end
end
