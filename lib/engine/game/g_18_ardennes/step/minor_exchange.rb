# frozen_string_literal: true

module Engine
  module Game
    module G18Ardennes
      module Step
        # Code shared between Step::BuySellParSharesCompanies and Step::Convert.
        module MinorExchange
          private

          def exchange_minor(minor, bundle)
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
            transfer_assets(minor, major)
            @game.close_corporation(minor)
          end

          # Moves all assets from a minor to a major and logs what was transferred.
          def transfer_assets(minor, major)
            assets = []
            assets << transfer_cash(minor, major)
            assets << transfer_trains(minor, major)
            assets << transfer_tokens(minor, major)
            assets << transfer_forts(minor, major, :fort)
            @game.log << "#{major.name} receives #{minor.name}’s assets: " \
                         "#{assets.compact.join(', ')}."
          end

          # Transfers treasury cash.
          # Returns a string describing the transfer, or nil if there was no cash
          # to transfer.
          def transfer_cash(minor, major)
            return if minor.cash.zero?

            cash = minor.cash
            minor.spend(minor.cash, major)
            "cash (#{@game.format_currency(cash)})"
          end

          # Transfers trains.
          # Returns a string describing the transfer, or nil if there was no
          # train to transfer.
          def transfer_trains(minor, major)
            return if minor.trains.empty?

            trains = @game.transfer(:trains, minor, major).map(&:name)
            "#{trains.one? ? 'a train' : 'trains'} (#{trains.join(' and ')})"
          end

          # Transfers station tokens. Also copies across assignments for mine
          # and port tokens.
          # Returns a string describing the station tokens transferred.
          def transfer_tokens(minor, major)
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
          # Returns a string describing the transfer, or nil if there was
          # nothing to transfer.
          def transfer_forts(minor, major)
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
