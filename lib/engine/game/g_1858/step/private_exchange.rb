# frozen_string_literal: true

module Engine
  module Game
    module G1858
      module Step
        # Code shared by both the Exchange and PrivateClosure steps.
        module PrivateExchange
          def acquire_private(corporation, entity)
            player = entity.owner

            company = @game.private_company(entity)
            minor = @game.private_minor(entity)

            @game.release_stubs(minor)
            transfer_abilities(minor, company)
            minor.close!
            player.companies.delete(company)
            company.owner = corporation
            corporation.companies << company
            @log << "#{corporation.name} acquires #{company.name} from #{player.name}"
          end

          def transfer_abilities(minor, company)
            # The ability blocking other entities laying track in the private's
            # home hexes needs to survive until the private railway closes, so
            # move it from the minor to the company.
            blocker = @game.abilities(minor, :blocks_hexes)
            return unless blocker

            company.add_ability(blocker)
          end

          def exchange_for_share(bundle, corporation, minor, player, treasury_share)
            if !@game.loading && !@game.corporation_private_connected?(corporation, minor)
              raise GameError, "#{minor.name} is not connected to #{corporation.full_name}"
            end

            @game.share_pool.buy_shares(player, bundle, exchange: :free)
            return unless treasury_share

            acquire_private(corporation, minor)
            claim_token(corporation, minor)
          end

          def claim_token(corporation, minor)
            return if corporation.unplaced_tokens.empty?

            company = @game.private_company(minor)
            cities = @game.reserved_cities(corporation, company)
            return unless cities.any? { |city| city.tokens.compact.size < city.slots }

            @round.pending_tokens << {
              entity: corporation,
              cities: cities,
              hexes: cities.map(&:hex),
              token: corporation.next_token,
            }
            return unless @game.private_closure_round == :in_progress

            # We are in the private closure round and the private company will
            # close before the player gets asked whether they want to take the
            # token. When the private closes it loses its reserved token slot,
            # and this means that there might no longer be an available slot in
            # Sevilla, Córdoba or Zaragoza if the tile is still yellow and the
            # other private company with a reservation has not yet closed. To
            # avoid this, change the reservation to belong to the corporation.
            reservations = Array(@game.abilities(company, :reservation))
            reservations.each do |reservation|
              city = reservation.tile.cities[reservation.city]
              city.reservations[city.find_reservation(company)] = corporation
              company.remove_ability(reservation)
              corporation.add_ability(reservation)
            end
          end

          def log_request(corporation, minor)
            requester = minor.owner
            approver = corporation.owner
            msg = "• requested #{approver.name}’s permission to " \
                  "exchange #{minor.name} for a #{corporation.id} " \
                  'treasury share.'
            @round.process_action(Engine::Action::Log.new(requester, message: msg))
          end

          def log_response(corporation, minor, approved)
            requester = minor.owner
            approver = corporation.owner
            verb = approved ? 'approved' : 'denied'
            msg = "• #{verb} #{requester.name}’s request to exchange " \
                  "#{minor.name} for a #{corporation.id} treasury share."
            @round.process_action(Engine::Action::Log.new(approver, message: msg))
          end
        end
      end
    end
  end
end
