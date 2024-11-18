# frozen_string_literal: true

module Engine
  module Game
    module G18Ardennes
      module Step
        module MinorExchange
          private

          # Exchanges a minor company for a share in a public company.
          # @param minor [Corporation] The minor company being exchanged.
          # @param bundle [ShareBundle] The share bundle being received in
          #        exchange for the minor company.
          # @param transfer [label] The assets to be transferred.
          #        :all => All cash, tokens, trains and forts are transferred
          #        from the minor company to the public company.
          #        :choose => Cash is transferred, and the president of the
          #        public company gets to choose whether tokens, trains and
          #        forts are transferred.
          #        :none => Nothing is transferred.
          def exchange_minor(minor, bundle, transfer = :all)
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
            if transfer == :none
              discard_assets(minor)
            else
              transfer_assets(minor, major, transfer == :choose)
            end
            # If there are tokens that may optionally be rejected the minor
            # needs to be left open for the DeclineTokens step.
            @game.close_corporation(minor) unless @round.corporations_removing_tokens

            # The game graph might be invalid after station tokens have been
            # exchanged or removed.
            @game.clear_graph_for_entity(major)
          end

          # Discards a minor company's assets.
          # @param minor [Corporation] The minor company being closed.
          def discard_assets(minor)
            if minor.cash.positive?
              @game.log << "#{@game.format_currency(minor.cash)} is returned " \
                           "to the bank from minor #{minor.name}’s treasury."
              minor.spend(minor.cash, @game.bank)
            end

            minor.trains.each do |train|
              @game.log << "Minor #{minor.name}’s #{train.name} train is " \
                           'discarded to the open market.'
              @game.depot.reclaim_train(train)
            end

            minor.placed_tokens.each { |token| remove_minor_token!(token) }

            forts = minor.assignments.keys.intersection(Map::FORT_HEXES.keys)
            return if forts.empty?

            @game.log << "Minor #{minor.name}’s #{forts.size} fort " \
                         "#{forts.one? ? 'token' : 'tokens'} are discarded."
            forts.each { |fort| minor.remove_assignment!(fort) }
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
            assets << transfer_forts(minor, major, may_decline)
            @game.log << "#{major.name} receives #{minor.name}’s assets: " \
                         "#{assets.compact.join(', ')}."
          end

          # Transfers treasury cash.
          # @param minor [Corporation] The minor corporation being exchanged.
          # @param major [Corporation] The major corporation receiving the assets.
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
          #         no tokens are transferred.
          def transfer_tokens(minor, major, may_decline)
            if may_decline
              remove_unswappable_tokens!(minor, major)
              return if minor.placed_tokens.empty?

              @round.corporations_removing_tokens = [major, minor]
            end

            cities = []
            minor.placed_tokens.each do |token|
              cities << token_location(token)
              transfer_minor_token!(token, major) unless may_decline
            end
            "#{cities.one? ? 'a token' : 'tokens'} (#{cities.join(' and ')})"
          end

          # Removes tokens that cannot legally be transferred from the minor
          # company to the major. This can be for one of two reasons:
          # 1. The major already has a token in the same city. Having tokens in
          #    the same hex is allowed, if they are in different cities.
          # 2. The major alreay has all of its tokens on the board.
          # @param minor [Corporation] The minor corporation being exchanged.
          # @param major [Corporation] The major corporation receiving the assets.
          def remove_unswappable_tokens!(minor, major)
            unswappable =
              if major.unplaced_tokens.empty?
                minor.placed_tokens
              else
                minor.placed_tokens.select do |token|
                  major.placed_tokens.map(&:city).include?(token.city)
                end
              end
            unswappable.each { |token| remove_minor_token!(token) }
          end

          # Removes a minor company's token from the map. If the token was in
          # a port or mine city then a port or mine token is returned to the
          # empty token slot.
          # @param token [Token] The token to be removed.
          def remove_minor_token!(token)
            minor = token.corporation
            city = token.city
            coord = city.hex.coordinates
            location = token_location(token)
            @game.log << "Minor #{minor.id}’s token in " \
                         "#{location} is removed."
            token.remove!
            return unless minor.assigned?(coord)

            dummy_corp =
              if Map::MINE_HEXES.include?(coord)
                @game.mine_corp
              elsif Map::PORT_HEXES.include?(coord)
                @game.port_corp
              end
            minor.remove_assignment!(coord)
            city.place_token(dummy_corp, dummy_corp.next_token, check_tokenable: false)
            @game.log << "A #{dummy_corp.name.downcase} token is " \
                         "returned to #{location}."
          end

          # Transfers a station token from a minor company to a major. Also
          # copies across assignments for mine and port tokens.
          # @param token [Token] The token to be removed.
          # @param major [Corporation] The major receiving the token.
          def transfer_minor_token!(token, major)
            minor = token.corporation
            city = token.city
            coord = city.hex.coordinates
            token.remove!
            city.place_token(major, major.next_token, check_tokenable: false)
            return unless minor.assigned?(coord)

            minor.remove_assignment!(coord)
            major.assign!(coord)
          end

          # Transfers fort tokens.
          # @param minor [Corporation] The minor corporation being exchanged.
          # @param major [Corporation] The major corporation receiving the assets.
          # @param may_decline [Boolean] If true, the major's owner will have
          #        the option to decline any fort tokens.
          # @return [String, nil] A description of the transfer, or nil if
          #         there were no forts to transfer.
          def transfer_forts(minor, major, may_decline)
            forts = minor.assignments.keys.intersection(Map::FORT_HEXES.keys)
            return if forts.empty?

            @round.optional_forts = forts if may_decline
            forts.each do |fort|
              minor.remove_assignment!(fort)
              major.assign!(fort)
            end
            "#{forts.size} #{forts.one? ? 'fort' : 'forts'}"
          end

          # Returns a description of the location of a token, city name and hex
          # coordinates.
          def token_location(token)
            "#{token.city.hex.location_name} [#{token.city.hex.coordinates}]"
          end
        end
      end
    end
  end
end
