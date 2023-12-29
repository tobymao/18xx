# frozen_string_literal: true

module Engine
  module Game
    module G18Ardennes
      module Step
        # Code shared between Step::BuySellParSharesCompanies and Step::Convert.
        module MinorExchange
          private

          # Exchanges a minor corporation for a share in a major corporation.
          # @param minor [Corporation] The minor corporation being exchanged.
          # @param bundle [ShareBundle] The share bundle being received in
          #        exchange for the minor corporation.
          # @param may_decline [Boolean] If true, the major's owner will have
          #        the option to decline any trains, tokens or forts. If false
          #        then these will all be transferred. Cash cannot be declined.
          #        This should be false if the minor is being used to start a
          #        new major company, and true otherwise.
          def exchange_minor(minor, bundle, may_decline)
            player = minor.owner
            major = bundle.corporation
            extra_cost = [0, major.share_price.price - (minor.share_price.price * 2)].max

            msg = "#{player.name} exchanges minor #{minor.name} "
            msg += "and #{@game.format_currency(extra_cost)} " if extra_cost.positive?
            msg += "for a #{bundle.percent}% share of #{major.name}"
            @game.log << msg

            @game.share_pool.buy_shares(player,
                                        bundle,
                                        exchange: minor,
                                        exchange_price: extra_cost,
                                        silent: true)
            transfer_assets(minor, major, may_decline)
            @game.close_corporation(minor)
          end

          # Moves assets from a minor to a major and logs what was transferred.
          # @param minor [Corporation] The minor corporation being exchanged.
          # @param major [Corporation] The major corporation receiving the assets.
          # @param may_decline [Boolean] If true, the major's owner will have
          #        the option to decline any trains, tokens or forts. If false
          #        then these will all be transferred. Cash cannot be declined.
          def transfer_assets(minor, major, may_decline)
            assets = []
            assets << transfer_cash(minor, major)
            assets << transfer_trains(minor, major, may_decline)
            assets << transfer_tokens(minor, major, may_decline)
            assets << transfer_forts(minor, major, :fort, may_decline)
            @game.log << "#{major.name} receives #{minor.name}’s assets: " \
                         "#{assets.compact.join(', ')}."
          end

          # Transfers treasury cash.
          # @param minor [Corporation] The minor corporation being exchanged.
          # @param major [Corporation] The major corporation receiving the assets.
          # @param may_decline [Boolean] If true, the major's owner will have
          #        the option to decline any trains, tokens or forts. If false
          #        then these will all be transferred. Cash cannot be declined.
          # @return [String, nil] A description of the transfer, or nil if there
          #         was no cash to transfer.
          def transfer_cash(minor, major)
            return if minor.cash.zero?

            cash = minor.cash
            minor.spend(minor.cash, major)
            "cash (#{@game.format_currency(cash)})"
          end

          # Transfers trains.
          # @param minor [Corporation] The minor corporation being exchanged.
          # @param major [Corporation] The major corporation receiving the assets.
          # @param may_decline [Boolean] If true, the major's owner will have
          #        the option to decline any trains.
          # @return [String, nil] A description of the transfer, or nil if there
          #         were no trains to transfer.
          def transfer_trains(minor, major, may_decline)
            return if minor.trains.empty?

            trains = @game.transfer(:trains, minor, major)
            @round.optional_trains = trains if may_decline
            "#{trains.one? ? 'a train' : 'trains'} " \
              "(#{trains.map(&:name).join(' and ')})"
          end

          # Transfers station tokens. Also copies across assignments for mine
          # and port tokens.
          # @param minor [Corporation] The minor corporation being exchanged.
          # @param major [Corporation] The major corporation receiving the assets.
          # @param may_decline [Boolean] If true, the major's owner will have
          #        the option to decline any tokens.
          # @return [String, nil] A description of the transfer, or nil if
          #         may_decline is true.
          def transfer_tokens(minor, major, may_decline)
            cities = []
            minor.placed_tokens.each do |token|
              city = token.city
              token.remove!
              city.place_token(major, major.next_token, check_tokenable: false)
              hex = city.hex.coordinates
              prefix = ''
              if minor.assigned?(hex)
                if Map::MINE_HEXES.include?(hex)
                  prefix = '⚒ '
                  minor.remove_assignment!(hex)
                  major.assign!(hex)
                elsif Map::PORT_HEXES.include?(hex)
                  prefix = '⚓ '
                  minor.remove_assignment!(hex)
                  major.assign!(hex)
                end
              end
              cities << (prefix + city.hex.location_name)
            end
            "#{cities.one? ? 'a token' : 'tokens'} (#{cities.join(' and ')})"
          end

          # Transfers fort tokens.
          # @param minor [Corporation] The minor corporation being exchanged.
          # @param major [Corporation] The major corporation receiving the assets.
          # @param may_decline [Boolean] If true, the major's owner will have
          #        the option to decline any fort tokens.
          # @return [String, nil] A description of the transfer, or nil if either
          #         there were no forts to transfer, or if may_decline is true.
          def transfer_forts(minor, major, may_decline)
            forts = minor.assignments.keys.intersection(Map::FORT_HEXES.keys)
            return if forts.empty?

            forts.each do |fort|
              minor.remove_assignment!(fort)
              major.assign!(fort)
            end
            "#{forts.count} fort token#{forts.count == 1 ? '' : 's'}"
          end
        end
      end
    end
  end
end
