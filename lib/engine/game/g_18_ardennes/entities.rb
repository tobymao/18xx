# frozen_string_literal: true

module Engine
  module Game
    module G18Ardennes
      module Entities
        COMPANIES = [
          {
            sym: 'GL',
            name: 'Guillaume-Luxembourg',
            type: :minor,
            value: 100,
            discount: 0,
            revenue: 25,
            color: :yellow,
            text_color: :black,
            abilities: [{ type: 'no_buy' }],
            desc: 'The player who owns the Guillaume-Luxembourg receives F25 ' \
                  'income at the beginning of each operating round. The ' \
                  'Guillaume-Luxembourg is treated as a single share worth ' \
                  'F100. The player who owns it may sell it to the open ' \
                  'market during a stock round. If the Guillaume-Luxembourg ' \
                  'is in the open market then it may be bought by any ' \
                  'player, unless they sold it earlier in the same stock round.',
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: '1',
            name: 'Hollandsche IJzeren Spoorweg Maatschappij',
            tokens: [0, 40],
            color: :white,
            text_color: :black,
            logo: '18_ardennes/1',
            float_percent: 100,
            type: :minor,
            shares: [100],
            max_ownership_percent: 100,
            capitalization: :none,
            coordinates: 'B8',
            city: 0,
            abilities: [{ type: 'exchange', corporations: 'ipoed', from: %w[ipo market] }],
          },
          {
            sym: '2',
            name: 'Nederlandsche Rhijnspoorweg-Maatschappij',
            tokens: [0, 40],
            color: :white,
            text_color: :black,
            logo: '18_ardennes/2',
            float_percent: 100,
            type: :minor,
            shares: [100],
            max_ownership_percent: 100,
            capitalization: :none,
            coordinates: 'B8',
            city: 1,
            abilities: [{ type: 'exchange', corporations: 'ipoed', from: %w[ipo market] }],
          },
          {
            sym: '3',
            name: 'Rheinische Eisenbahngesellschaft',
            tokens: [0, 40],
            color: :white,
            text_color: :black,
            logo: '18_ardennes/3',
            float_percent: 100,
            type: :minor,
            shares: [100],
            max_ownership_percent: 100,
            capitalization: :none,
            coordinates: 'E15',
            abilities: [{ type: 'exchange', corporations: 'ipoed', from: %w[ipo market] }],
          },
          {
            sym: '4',
            name: 'Großherzoglich Badische Staatseisenbahnen',
            tokens: [0, 40],
            color: :white,
            text_color: :black,
            logo: '18_ardennes/4',
            float_percent: 100,
            type: :minor,
            shares: [100],
            max_ownership_percent: 100,
            capitalization: :none,
            coordinates: 'G25',
            abilities: [{ type: 'exchange', corporations: 'ipoed', from: %w[ipo market] }],
          },
          {
            sym: '5',
            name: 'Compagnie de Strasbourg à Bâle',
            tokens: [0, 40],
            color: :white,
            text_color: :black,
            logo: '18_ardennes/5',
            float_percent: 100,
            type: :minor,
            shares: [100],
            max_ownership_percent: 100,
            capitalization: :none,
            coordinates: 'J24',
            abilities: [{ type: 'exchange', corporations: 'ipoed', from: %w[ipo market] }],
          },
          {
            sym: '6',
            name: 'Compagnie du Nord-est',
            tokens: [0, 40],
            color: :white,
            text_color: :black,
            logo: '18_ardennes/6',
            float_percent: 100,
            type: :minor,
            shares: [100],
            max_ownership_percent: 100,
            capitalization: :none,
            coordinates: 'H6',
            abilities: [{ type: 'exchange', corporations: 'ipoed', from: %w[ipo market] }],
          },
          {
            sym: '7',
            name: 'Pfalzbahn',
            tokens: [0, 40],
            color: :white,
            text_color: :black,
            logo: '18_ardennes/7',
            float_percent: 100,
            type: :minor,
            shares: [100],
            max_ownership_percent: 100,
            capitalization: :none,
            coordinates: 'I21',
            abilities: [{ type: 'exchange', corporations: 'ipoed', from: %w[ipo market] }],
          },
          {
            sym: '8',
            name: 'Ligne de Paris à Douai et Lille',
            tokens: [0, 40],
            color: :white,
            text_color: :black,
            logo: '18_ardennes/8',
            float_percent: 100,
            type: :minor,
            shares: [100],
            max_ownership_percent: 100,
            capitalization: :none,
            coordinates: 'M7',
            city: 0,
            abilities: [{ type: 'exchange', corporations: 'ipoed', from: %w[ipo market] }],
          },
          {
            sym: '9',
            name: 'Compagnie de Paris à Strasbourg',
            tokens: [0, 40],
            color: :white,
            text_color: :black,
            logo: '18_ardennes/9',
            float_percent: 100,
            type: :minor,
            shares: [100],
            max_ownership_percent: 100,
            capitalization: :none,
            coordinates: 'M7',
            city: 1,
            abilities: [{ type: 'exchange', corporations: 'ipoed', from: %w[ipo market] }],
          },
          {
            sym: '10',
            name: 'Cöln-Mindener Eisenbahn-Gesellschaft',
            tokens: [0, 40],
            color: :white,
            text_color: :black,
            logo: '18_ardennes/10',
            float_percent: 100,
            type: :minor,
            shares: [100],
            max_ownership_percent: 100,
            capitalization: :none,
            coordinates: 'D18',
            abilities: [{ type: 'exchange', corporations: 'ipoed', from: %w[ipo market] }],
          },
          {
            sym: '11',
            name: 'Bergisch-Märkische Eisenbahn-Gesellschaft',
            tokens: [0, 40],
            color: :white,
            text_color: :black,
            logo: '18_ardennes/11',
            float_percent: 100,
            type: :minor,
            shares: [100],
            max_ownership_percent: 100,
            capitalization: :none,
            coordinates: 'B16',
            abilities: [{ type: 'exchange', corporations: 'ipoed', from: %w[ipo market] }],
          },
          {
            sym: '12',
            name: 'Compagnie du chemin de fer des Ardennes et de l\'Oise',
            tokens: [0, 40],
            color: :white,
            text_color: :black,
            logo: '18_ardennes/12',
            float_percent: 100,
            type: :minor,
            shares: [100],
            max_ownership_percent: 100,
            capitalization: :none,
            coordinates: 'K11',
            abilities: [{ type: 'exchange', corporations: 'ipoed', from: %w[ipo market] }],
          },
          {
            sym: '13',
            name: 'Société Anonyme des chemins de fer d\'Anvers à Rotterdam',
            tokens: [0, 40],
            color: :white,
            text_color: :black,
            logo: '18_ardennes/13',
            float_percent: 100,
            type: :minor,
            shares: [100],
            max_ownership_percent: 100,
            capitalization: :none,
            coordinates: 'E9',
            abilities: [{ type: 'exchange', corporations: 'ipoed', from: %w[ipo market] }],
          },
          {
            sym: '14',
            name: 'Grand Central Belge',
            tokens: [0, 40],
            color: :white,
            text_color: :black,
            logo: '18_ardennes/14',
            float_percent: 100,
            type: :minor,
            shares: [100],
            max_ownership_percent: 100,
            capitalization: :none,
            coordinates: 'F10',
            abilities: [{ type: 'exchange', corporations: 'ipoed', from: %w[ipo market] }],
          },
          {
            sym: '15',
            name: 'Großherzoglich Hessische Staatseisenbahnen',
            tokens: [0, 40],
            color: :white,
            text_color: :black,
            logo: '18_ardennes/15',
            float_percent: 100,
            type: :minor,
            shares: [100],
            max_ownership_percent: 100,
            capitalization: :none,
            coordinates: 'E25',
            city: 1,
            abilities: [{ type: 'exchange', corporations: 'ipoed', from: %w[ipo market] }],
          },
          {
            sym: 'BY',
            name: 'Königlich Bayerische Staats-Eisenbahn',
            color: :lightblue,
            text_color: :black,
            logo: '18_ardennes/BY',
            float_percent: 60,
            type: '5-share',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 100, 100, 100, 100, 100],
          },
          {
            sym: 'N',
            name: 'Compagnie des chemins de fer du Nord',
            color: :saddlebrown,
            text_color: :white,
            logo: '18_ardennes/N',
            float_percent: 60,
            type: '5-share',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 100, 100, 100, 100, 100],
          },
          {
            sym: 'E',
            name: 'Compagnie des chemins de fer de l\'Est',
            color: :orange,
            text_color: :black,
            logo: '18_ardennes/E',
            float_percent: 60,
            type: '5-share',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 100, 100, 100, 100, 100],
          },
          {
            sym: 'NL',
            name: 'Maatschappij tot Exploitatie van Staatsspoorwegen',
            color: :yellow,
            text_color: :black,
            logo: '18_ardennes/NL',
            float_percent: 60,
            type: '5-share',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 100, 100, 100, 100, 100],
          },
          {
            sym: 'BE',
            name: 'État Belge',
            color: :darkgreen,
            text_color: :white,
            logo: '18_ardennes/BE',
            float_percent: 60,
            type: '5-share',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 100, 100, 100, 100, 100],
          },
          {
            sym: 'P',
            name: 'Preußische Staatseisenbahnen',
            color: :darkblue,
            text_color: :white,
            logo: '18_ardennes/P',
            float_percent: 60,
            type: '5-share',
            shares: [40, 20, 20, 20],
            always_market_price: true,
            capitalization: :incremental,
            tokens: [0, 100, 100, 100, 100, 100],
          },
        ].freeze

        # Defines where a minor needs to have a token to be used to start a
        # public company. Paris (hex M7) is a special case, E can only start in
        # the western city, N only in the eastern.
        PUBLIC_COMPANY_HEXES = {
          'BE' => %w[E9 E15 F4 F10 H6 H10],
          'BY' => %w[E25 G25 H26 I21 J24],
          'E' => %w[I21 J18 J24 K11 M7],
          'N' => %w[G3 H6 K5 M7],
          'NL' => %w[B8 B12 C7 E5 E9 E15],
          'P' => %w[B16 D18 E15 E25],
        }.freeze
        PARIS_HEX = 'M7'
        PARIS_CITIES = { 'N' => 0, 'E' => 1 }.freeze

        def company_header(company)
          case company.type
          when :minor then 'MINOR COMPANY'
          when :concession then 'PUBLIC COMPANY'
          else raise GameError, 'Unknown type of private company'
          end
        end

        def game_companies
          return super if @players.size == 4

          # The Guillaume-Luxembourg is only used in four-player games.
          super.reject { |c| c[:type] == :minor }
        end

        def setup_preround
          @companies.concat(init_concessions)
        end

        def setup_icons
          @hexes.map(&:tile).flat_map(&:cities).each { |c| add_slot_icons(c) }
        end

        def concession_companies
          companies.select { |company| company.type == :concession }
        end

        def minor_companies
          companies.select { |company| company.type == :minor }
        end

        def major_corporations
          corporations.reject { |corporations| corporations.type == :minor }
        end

        def minor_corporations
          corporations.select { |corporations| corporations.type == :minor }
        end

        def reservation_corporations
          minor_corporations
        end

        def sorted_corporations
          major_corporations.sort
        end

        # 18Ardennes doesn't have multiple layers of private companies.
        def check_new_layer; end

        def can_par?(corporation, parrer)
          return true if corporation.type == :minor

          super
        end

        # Is the player unable to raise enough cash to start one of the
        # corporations that they are under obligation for?
        def bankrupt?(player)
          return false if player.companies.none? { |c| c.type == :concession }

          cash_needed(player) > liquidity(player)
        end

        # How much a minor is worth, when exchanged for a share.
        # A minor's value is twice its market price, but anything in excess
        # of the value of the major's share is lost.
        def minor_sale_value(minor, share_price)
          [share_price.price, minor.share_price.price * 2].min
        end

        # The minimum amount of cash needed to start a major company.
        def min_concession_cost(concession)
          major = major_corporations.find do |corp|
            corp.par_via_exchange == concession
          end
          minor = pledged_minors[major]
          min_par = lowest_major_par
          (min_par.price * 3) - minor_sale_value(minor, min_par)
        end

        # Entities that can own an exchange ability.
        def exchange_entities
          minor_corporations
        end

        def exchange_corporations(exchange_ability)
          minor = exchange_ability.owner
          return [] if minor.receivership?
          return [] if minor.share_price.price.zero?
          return [] if under_obligation?(minor.owner)

          super.select do |major|
            max_price = (minor.share_price.price * 2) + liquidity(minor.owner)

            major.share_price.price <= max_price &&
              major_minor_connected?(major, minor)
          end
        end

        def unowned_purchasable_companies
          minor_companies.select { |company| company.owner == bank }
        end

        def buyable_bank_owned_companies
          # Do not show the GL after a corporation grows up.
          @round.operating? ? [] : super
        end

        def company_sale_price(company)
          company.value
        end

        # Has the player won any auctions for public companies in the
        # preceding auction round? If they have then they must start these
        # majors before they can buy any other shares or pass.
        def under_obligation?(entity)
          return false unless entity.player?

          entity.companies.any? { |company| company.type == :concession }
        end

        def place_home_token(corporation)
          city = cities.find { |c| c.reserved_by?(corporation) }
          token = corporation.find_token_by_type
          super
          change_token_icon(city, token, corporation)
        end

        # If no public companies have yet been started then there are
        # geographical restrictions on which minor companies can be used to
        # start a public company.
        def restricted?
          major_corporations.none?(&:floated?) && concession_companies.none?(&:owner)
        end

        # Set a minor company's token logo to show which public companies can be
        # started from the city it is in.
        def change_token_icon(city, token, minor)
          return unless restricted?
          return if minor.type != :minor && minor.type != :dummy

          majors = associated_majors(city)
          return if majors.empty? # Basel

          token.logo = logo_path(majors, minor.id)
          token.simple_logo = logo_path(majors, minor.id)
        end

        # Set a minor company's token logo back to its default logo.
        def reset_token_icon(token)
          return unless token

          token.logo = token.corporation.logo
          token.simple_logo = token.corporation.simple_logo
        end

        private

        # Creates a concession company for each major corporations
        def init_concessions
          major_corporations.map do |corporation|
            concession = Company.new(
              sym: corporation.id,
              name: corporation.full_name,
              type: :concession,
              value: 0,
              color: corporation.color,
              text_color: corporation.text_color,
              desc: 'The player who wins the auction for this item has the ' \
                    "right to form the #{corporation.full_name} " \
                    "[#{corporation.id}] public company. Public companies " \
                    'must be started as the player’s first actions in the ' \
                    'stock round.',
            )
            corporation.par_via_exchange = concession
            concession
          end
        end

        def status_array(corporation)
          return if corporation.floated?
          return unless (minor = @pledged_minors[corporation])

          player = minor.presidents_share.owner
          verb = @round.auction? ? 'bid' : 'won the right'
          [
            "#{player.name} has #{verb} to start this company using " \
            "minor #{minor.id}.",
          ]
        end

        # The minimum amount of cash needed to start one of the corporations
        # that the player is under obligation for.
        def cash_needed(player)
          player.companies
                .select { |company| company.type == :concession }
                .map { |concession| min_concession_cost(concession) }
                .min
        end

        # The lowest par price for starting a major corporation.
        def lowest_major_par
          @lowest_major_par ||= stock_market.par_prices.reverse.find do |pp|
            pp.types.include?(:par_2)
          end
        end

        # Adds slot icons to empty city slots, showing which public companies
        # can be started using a token in this city.
        def add_slot_icons(city)
          return unless restricted?

          city.tokens.each_with_index do |token, ix|
            next if token || city.reservations[ix]

            majors = associated_majors(city)
            next if majors.empty? # Basel does not have an associated public companies

            path = "18_ardennes/#{majors.join('+')}"
            city.slot_icons[ix] = Engine::Part::Icon.new(path)
          end
        end

        # Finds which public companies can be started from a minor company
        # that has a token in this city.
        # @param city [City] The city with a minor company's token.
        # @return [Array<String>] IDs of the public companies that could be
        # started by a minor company with a token in this city.
        def associated_majors(city)
          coords = city.hex.coordinates
          if coords == PARIS_HEX
            Array(PARIS_CITIES.key(city.tile.cities.index(city)))
          else
            PUBLIC_COMPANY_HEXES.select { |_, hexes| hexes.include?(coords) }.keys
          end
        end

        # Returns the path to a token logo indicating which public companies
        # can be started in a city. If minor is not nil, then this logo also
        # has the minor company number on it.
        # @param majors [Array<String>] The IDs of the major companies.
        # @param minor [String] The ID of the minor company (optional).
        # @return [String] Path to the logo file.
        def logo_path(majors, minor = nil)
          minor += '-' if minor
          "/logos/18_ardennes/#{minor}#{majors.join('+')}.svg"
        end
      end
    end
  end
end
