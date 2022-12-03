# frozen_string_literal: true

module Engine
  module Game
    module G1858
      module Step
        # Code shared by both the Exchange and PrivateClosure steps.
        module CompanyExchange
          def acquire_company(corporation, company)
            player = company.owner
            player.companies.delete(company)
            @game.minors.delete(company)
            company.owner = corporation
            corporation.companies << company
            company.release_stubs
            @log << "#{corporation.name} acquires #{company.name} from #{player.name}"
          end

          def exchange_for_share(bundle, corporation, company, player)
            unless @game.company_corporation_connected?(company, corporation)
              raise GameError, "#{company.name} is not connected to #{corporation.full_name}"
            end

            @game.share_pool.buy_shares(player, bundle, exchange: :free)
          end

          def claim_token(corporation, company)
            return if corporation.unplaced_tokens.empty?

            cities = @game.reserved_cities(corporation, company)
            return if cities.empty?

            @round.pending_tokens << {
              entity: corporation,
              hexes: cities.map(&:hex),
              token: corporation.next_token,
            }
          end
        end
      end
    end
  end
end
