# frozen_string_literal: true

require_relative 'companies'
require_relative 'corporations'
require_relative 'map'
require_relative 'market'
require_relative 'meta'
require_relative 'phases'
require_relative 'tiles'
require_relative 'trains'

require_relative '../base'
require_relative '../tranches'

module Engine
  module Game
    module G1871
      class Game < Game::Base
        # Include our game metadata
        include_meta(G1871::Meta)

        # Include most of our game data
        include(G1871::Companies)
        include(G1871::Corporations)
        include(G1871::Map)
        include(G1871::Market)
        include(G1871::Phases)
        include(G1871::Tiles)
        include(G1871::Trains)

        # Include tranch support
        include(Engine::Game::Tranches)

        # We create one player that represents the union bank and the PEIR
        # corporation
        attr_reader :union_bank, :peir, :peir_shares, :peir_company_shares, :peir_corporation_shares, :random_corporation

        # Standard config
        ALLOW_TRAIN_BUY_FROM_OTHER_PLAYERS = true
        BANK_CASH = 99_999
        CAPITALIZATION = :full
        CERT_LIMIT = { 3 => 20, 4 => 16 }.freeze
        CURRENCY_FORMAT_STR = '$%s'
        DISCARDED_TRAINS = :remove
        EBUY_OTHER_VALUE = false
        EBUY_PRES_SWAP = true
        EBUY_OWNER_MUST_HELP = true
        GAME_END_CHECK = { bankrupt: :immediate, final_phase: :one_more_full_or_set }.freeze
        HOME_TOKEN_TIMING = :float
        MARKET_SHARE_LIMIT = 80
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        MUST_SELL_IN_BLOCKS = true
        NEXT_SR_PLAYER_ORDER = :first_to_pass
        SELL_AFTER = :operate
        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :down_block
        STARTING_CASH = { 3 => 580, 4 => 480 }.freeze
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, cost: 20, upgrade: false }].freeze

        # This allows us to add in privates to the cert count ourselves, without
        # the PEIR shares later on
        CERT_LIMIT_INCLUDES_PRIVATES = false

        # This game only allows you to sell 30 percent of a company at a time.
        # This is a feature we added to 18xx.games controlled by this variable.
        TURN_SELL_LIMIT = 30

        STATUS_TEXT = {
          'can_buy_companies' =>
          ['Can Buy Hunslet', 'A corporation may purchase the Hunslet from its owning player'],
        }.freeze

        # The numbers needed to assign proper private numbers to the PEIR
        # shares/privates to match the IRL game.
        NUMBERS = {
          'So' => 1,
          'A' => 2,
          'MS' => 3,
          'MR' => 4,
          'S' => 5,
          'Gt' => 6,
          'C' => 7,
        }.freeze

        # In this game most shares start in the market, but if you split a
        # corporation shares end up in the treasury. We have no IPO.
        def ipo_verb(_entity = nil)
          'starts'
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        # We use the reserved share type to represent the 3 shortline exchange
        # shares.
        def ipo_reserved_name(_entity = nil)
          'Exchange'
        end

        def setup_preround
          # Pick a random company to be the mainline and the shortline
          @corporations = @corporations[0..6].sort_by { rand } + @corporations[7..-1]
          @random_corporation = @corporations[2]

          # Unsort corporations 2-6
          @corporations = @corporations[0..1] + @corporations[2..6].sort_by { |c| NUMBERS[c.id] } + @corporations[7..-1]

          # Setup the ML / SL names on their privates
          @companies.each do |company|
            company.desc = company.desc.gsub('Mainline', mainline.full_name[0..-5])
            company.desc = company.desc.gsub('Shortline', shortline.full_name[0..-5])

            company.desc = company.desc.gsub('Random', @random_corporation.full_name[0..-5]) if company.id == 'UB'
          end

          # Setup the ML and SL names, float values and pars
          mainline.full_name = mainline.full_name[0..-2] + 'ML'
          mainline.float_percent = 50
          shortline.full_name = shortline.full_name[0..-2] + 'SL'
          stock_market.set_par(mainline, stock_market.share_price(1, 1))
          stock_market.set_par(shortline, stock_market.share_price(2, 1))

          # Mainline and Shortline tokens start on the board
          @hexes.each do |hex|
            if hex.id == mainline.coordinates
              hex.tile.cities.first.exchange_token(mainline.tokens.first)
            elsif hex.id == shortline.coordinates
              hex.tile.cities.first.exchange_token(shortline.tokens.first)
            end
          end

          # Setup bank
          @union_bank = Player.new(-1, 'Union Bank')
          add_union_bank_to_players

          # Setup peir variable
          @peir = @corporations[7]

          # Setup tranches
          init_tranches([[mainline, shortline], [nil], [nil, nil], [nil, nil, nil]])

          # Setup hash to map each non-ml/sl corp to its PEIR share
          @peir_corporation_shares = {}
          @peir_company_shares = {}
          @corporations[2, 5].sort_by { |c| NUMBERS[c.id] }.each_with_index do |c, i|
            @peir_corporation_shares[c.id] = "PEIR_#{i}"
            @peir_company_shares["P#{NUMBERS[c.id]}"] = "PEIR_#{i}"
          end

          # Setup neutral token in G11 to block tokens but allow runs
          neutral_logo = '1871/neutral'
          neutral_corp = Corporation.new(sym: 'N', name: 'Neutral', logo: neutral_logo, simple_logo: neutral_logo, tokens: [0])
          neutral_corp.owner = @bank
          neutral_city = @hexes.find { |hex| hex.id == 'G11' }.tile.cities.first
          token = neutral_corp.tokens[0]
          token.type = :neutral
          neutral_city.exchange_token(token)

          # For each non-ml/sl corporation, replace its token with a PEIR token
          # and create the company that represents a PEIR share
          @peir_companies = []
          @corporations[2, 5].each_with_index do |c, i|
            @log << "Setting up PEIR token for #{c.full_name} on #{c.coordinates}"
            city = @hexes.find { |hex| hex.id == c.coordinates }.tile.cities.first
            city.remove_reservation!(c)
            city.exchange_token(peir.tokens[i])

            company = Company.new(sym: "P#{NUMBERS[c.name]}",
                                  name: "PEIR - #{c.full_name}",
                                  desc: "Exchanges for a #{c.name} share from the bank if and when #{c.name} floats.",
                                  abilities: [{ type: 'close', on_phase: 'never' }, { type: 'no_buy' }],
                                  value: 80)

            @peir_companies << company
            @companies << company
          end

          @log << "Mainline: #{mainline.full_name} (#{mainline.name})"
          @log << "Shortline: #{shortline.full_name} (#{shortline.name})"
          @log << "Union Bank Share: #{random_corporation.full_name} (#{random_corporation.name})"
        end

        def setup
          # Set concession action names
          abilities(company_by_id('ML'), :close, time: 'operated') do |ability|
            ability.corporation = mainline.name
          end
          abilities(company_by_id('SL'), :close, time: 'operated') do |ability|
            ability.corporation = shortline.name
          end

          # Reserve the shortline shares
          shortline.shares.last(3).each do |share|
            share.buyable = false
          end

          # Assign King's Mail
          kings_mail = company_by_id('KM')
          kings_mail.owner = peir
          peir.companies << kings_mail

          # Give PEIR their initial cash and setup their shares to not count
          # towards the limit
          peir.cash = 200
          @peir_shares = peir.shares

          # If Ice Boat shipping is in the game, set its corporations
          if @players.size == 5 # due to Union Bank already being added
            ice_boat_shipping = company_by_id('IB')
            ice_boat_ability = Engine::Ability::Exchange.new(type: :exchange,
                                                             corporations: 'ipoed',
                                                             owner_type: 'player',
                                                             when: 'owning_player_sr_turn',
                                                             from: %w[market])
            ice_boat_shipping.add_ability(ice_boat_ability)
          end

          # Move all shares to the market for the initial corporations.
          @corporations.each do |corporation|
            buyable_shares = corporation.shares.select(&:buyable)
            bundle = ShareBundle.new(buyable_shares)
            share_pool.transfer_shares(bundle, share_pool, price: 0, allow_president_change: true)
          end

          # Setup bank shares
          share_pool.buy_shares(@union_bank, share_by_id('mainline_8'), exchange: :free)
          share_pool.buy_shares(@union_bank, share_by_id("#{random_corporation.id}_8"), exchange: :free)
        end

        # Override num_certs to remove PEIR privates from the cert count
        def num_certs(entity)
          super + entity.companies.count { |c| !@peir_companies.include?(c) }
        end

        # Our stock round is edited (to remove the bank player) and also removes
        # the not-needed special track step.
        def stock_round
          G1871::Round::Stock.new(self, [G1871::Step::Exchange,
                                         G1871::Step::SplitCorporation,
                                         G1871::Step::BuySellParSplitShares])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
                                         G1871::Step::HunsletPurchaseTrain,
                                         Engine::Step::Bankrupt,
                                         Engine::Step::Exchange,
                                         Engine::Step::SpecialTrack,
                                         Engine::Step::BuyCompany,
                                         Engine::Step::Track,
                                         Engine::Step::Token,
                                         Engine::Step::Route,
                                         G1871::Step::Dividend,
                                         Engine::Step::DiscardTrain,
                                         G1871::Step::BuyTrain,
                                         [Engine::Step::BuyCompany, { blocks: true }],
                                       ], round_num: round_num)
        end

        # Our initial round is our own custom version of an Auction round with
        # our custom Auction step.
        def init_round
          @init_round ||= G1871::Round::Auction.new(self, [G1871::Step::Auction])
        end

        # Make sure privates and unsold companies show their values on the
        # player card.
        def show_value_of_companies?(_owner)
          true
        end

        # Our operating order is just floated companies sorted in the normal way
        # with PEIR last
        def operating_order
          @corporations.reject(&:closed?).select(&:floated?).sort do |a, b|
            if a == peir
              1
            elsif b == peir
              -1
            else
              a <=> b
            end
          end
        end

        # A helper function to return the mainline corportaion.
        def mainline
          @corporations[0]
        end

        # A helper function to return the shortline corportaion.
        def shortline
          @corporations[1]
        end

        # The base game pulls all active entities and removes bankrupted
        # players. We take this but also remove the bank as an active player.
        def active_players
          super.reject { |player| player == @union_bank }
        end

        # Adds the union bank to the end of the player list
        def add_union_bank_to_players
          @players << @union_bank unless @players.include?(@union_bank)
        end

        # This copies the standard code from base for the :shares ability on
        # companies.
        #
        # After it checks for some special 1871 logic:
        #
        # - Union Bank: Create the bank player and give it the starting shares
        #
        # - PEIR Shares: Create the PEIR shares when someone buys a PEIR private
        def after_buy_company(player, company, _price)
          abilities(company, :shares) do |ability|
            ability.shares.each do |share|
              if share.percent >= 20
                # Don't let two 10% shares of the Mainline confer presidency;
                # give it to the Mainline Concession winner by hand
                share.corporation.owner = player
                @log << "#{player.name} becomes the president of #{share.corporation.name}"
              end
              share_pool.buy_shares(player, share, exchange: :free, allow_president_change: false)
            end
          end

          company.value = 0 if company.sym == 'UB'

          return unless company.id.start_with?('P')

          # Convert PEIR companies to shares
          share_name = @peir_company_shares[company.id]
          share = share_by_id(share_name)
          bundle = Engine::ShareBundle.new(share)
          share_pool.transfer_shares(bundle, player, price: 0, allow_president_change: false)
          peir.owner = peir_owner
        end

        # Returns the player's lowest number PEIR share
        def lowest_peir_share(player)
          player.shares_of(peir).min_by(&:index)
        end

        # Let the Union Bank owner act for the bank in an operating round
        def acting_for_entity(entity)
          acting_for_player(entity&.owner)
        end

        def acting_for_player(player)
          return player unless player == @union_bank

          bank_company = company_by_id('UB')
          bank_company.owner
        end

        # Returns the player that should be the current peir owner
        def peir_owner
          # Get all of the share holders
          share_holders = peir.player_share_holders

          # Get max ownership
          max_ownership = share_holders.map(&:last).max

          # Get the owners that own the max (tied players)
          max_owners = share_holders.select do |_p, o|
            o == max_ownership
          end.keys

          # Find the one with the lowest pier share by name
          max_owners.map { |p| lowest_peir_share(p) }.min_by(&:index).owner
        end

        # After default caches are made, override the share_by_id and
        # corporation_by_id method to recognize mainline and shortline
        def cache_objects
          super

          self.class.define_method(:share_by_id) do |id|
            if id&.start_with?('mainline')
              id = id.sub('mainline', mainline.id)
            elsif id&.start_with?('shortline')
              id = id.sub('shortline', shortline.id)
            end

            instance_variable_get(:@_shares)[id]
          end

          self.class.define_method(:corporation_by_id) do |id|
            case id
            when 'mainline'
              id = mainline.id
            when 'shortline'
              id = shortline.id
            end

            instance_variable_get(:@_corporations)[id]
          end
        end

        # Override default rust behavior for 4+ trains so that we only rust them
        # if they've run once.
        def rust(train)
          if train.name == '4+' && !train.ever_operated
            train.obsolete = true
            return
          end

          super
        end

        # Players are allowed to hold above 60 if they are able to buy it
        def can_hold_above_corp_limit?(_entity)
          true
        end

        # Events to remove pars on certain trains
        def event_remove_smv_80!
          stock_market.remove_par!(stock_market.share_price(3, 1))
        end

        def event_remove_smv_74!
          stock_market.remove_par!(stock_market.share_price(4, 1))
        end

        def event_remove_smv_65!
          stock_market.remove_par!(stock_market.share_price(5, 1))
        end

        # Handle tile upgrades. Differences from base include:
        # - Removing the 'special' tile lay exception since 1871 doesn't include one
        # - Removing weird OO and double dit handling
        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # Normal color progression and pre-existing track copied from base
          return false unless Engine::Tile::COLORS.index(to.color) == (Engine::Tile::COLORS.index(from.color) + 1)
          return false unless from.paths_are_subset_of?(to.paths)
          return false unless upgrades_to_correct_label?(from, to)

          # This is simplified from the base game since we don't have OO tiles
          # and double dits work in a standard way.
          return false if from.towns.size != to.towns.size
          return false if from.cities.size != to.cities.size

          # Only allow a 9 tile to be placed if the current players owns the
          # proper private.
          if to.name == '9'
            player = @round.current_entity.owner
            return false unless player.companies.find { |c| c.sym == 'SBC' }
          end

          true
        end

        # Standard hex edge cost method copied from multiple other games
        def hex_edge_cost(conn)
          conn[:paths].each_cons(2).sum do |a, b|
            a.hex == b.hex ? 0 : 1
          end
        end

        def plus_route_distance(route)
          route.visited_stops.sum do |stop|
            next 1 if stop.city? || stop.offboard?

            0
          end
        end

        # The base route_distance just counts the visited stops on a route. This
        # is valid but only for non-hex trains.
        def hex_route_distance(route)
          route.chains.sum { |conn| hex_edge_cost(conn, route.train) }
        end

        def route_distance(route)
          return hex_route_distance(route) if route.train.name.include?('H')
          return plus_route_distance(route) if route.train.name.include?('+')

          super
        end

        # Right now this is a simplified version of check_distance from base
        # that only compares distance using our route distance method above.
        def check_distance(route, _visits)
          return super unless route.train.name.include?('H')

          limit = route.train.distance
          distance = hex_route_distance(route)
          raise GameError, "#{distance} is too much for #{route.train.name} train" if distance > limit
        end

        # PEIR doesn't have to buy a train
        def must_buy_train?(entity)
          return false if entity.id == 'PEIR'

          super
        end

        def can_go_bankrupt?(player, corporation)
          return false if player == @union_bank

          if corporation.owner == @union_bank && company_by_id('UB').owner == player
            total_emr_buying_power(player, corporation) +
              total_emr_buying_power(@union_bank, corporation) < @depot.min_depot_price
          else
            super
          end
        end

        def purchasable_companies(entity = nil)
          # PEIR isn't allowed to buy the hunslet
          return [] if entity == @peir

          super
        end

        # We added the ability to exchange for any ipoed company, however this
        # game has 2 types of exchange. It's either for shortline or any ipoed
        # NON-mainline/shortline. So we override here for that.
        def exchange_corporations(exchange_ability)
          candidates = case exchange_ability.corporations
                       when 'shortline'
                         [shortline]
                       when 'ipoed'
                         corporations.select(&:ipoed).reject do |corporation|
                           corporation == mainline || corporation == shortline || corporation == peir
                         end
                       end
          candidates.reject(&:closed?)
        end

        # Normally this only calls value on the player, but we want to add the
        # bank to the proper player. Update the bank's private value in place so
        # it will display correctly on the player card.
        def player_value(player)
          bank = company_by_id('UB')
          bank.value = @union_bank&.value || 0 if bank.owner == player
          player.value
        end

        # Need to redefine this in order to add in union bank to the mix after
        # each round. The base function removes the bank since it's not active
        # during the stock round.
        def reorder_players(_order = nil, log_player_order: false)
          @players.delete(union_bank)

          case @round
          when init_round.class
            current_order = @players.dup
            @players.sort_by! { |p| [p.cash, current_order.index(p)] }
          else
            @players = @round.pass_order unless @round.pass_order.empty?
          end

          @log << if log_player_order
                    "Priority order: #{@players.reject(&:bankrupt).map(&:name).join(', ')}"
                  else
                    "#{@players.first.name} has priority deal"
                  end

          add_union_bank_to_players
        end

        # Don't show cert limit for the Union Bank
        def show_game_cert_limit?(player)
          return super unless player

          player != @union_bank
        end

        # Branches can not be pared,
        def can_par?(corporation, _parrer)
          return false unless tranch_available?
          return false if corporation.full_name.include?('Branch')
          return false if corporation.name == 'PEIR'

          !corporation.ipoed
        end

        # Allow a company to split, if the owner has >= 40 percent, at least two
        # tokens out and there is a tranch available
        def can_split?(corporation, spliter)
          return false unless tranch_available?
          return false if corporation.name == 'PEIR'
          return false unless corporation.ipoed

          # Have to own the company in question
          return false unless corporation.owner == spliter

          # Have to own at least 40 percent
          return false unless spliter.percent_of(corporation) >= 40

          # Have to have two tokens of this corporation out on the map
          corporation.placed_tokens.size >= 2
        end

        def available_splits
          corporations.select do |c|
            !c.ipoed && c.full_name.include?('Branch')
          end
        end

        # Set the PEIR share price and owner based on current shares. Delete the
        # company if no shares remain
        def readjust_peir
          if @peir_shares.empty?
            @log << "Closing the King's Mail"
            company_by_id('KM')&.close!
            @log << 'Closing the PEIR'
            peir.close!
            return
          end

          new_share_percent = (100 / @peir_shares.size).to_i
          @peir.forced_share_percent = new_share_percent
          peir.share_holders.clear
          @peir_shares.each do |share|
            share.percent = new_share_percent
            peir.share_holders[share.owner] ||= 0
            peir.share_holders[share.owner] += new_share_percent
          end
          peir.share_holders.each do |owner, amount|
            @log << "#{owner.name} now owns #{(100 * amount / (@peir_shares.size * new_share_percent)).round}% of the PEIR"
          end

          if (new_peir_owner = peir_owner) == peir.owner
            @log << "PEIR is still operated by #{peir.owner.name}"
          else
            peir.owner = new_peir_owner
            @log << "PEIR is now operated by #{peir.owner.name}"
          end
        end

        # Once a corporation pars, add it to the tranches
        def after_par(corporation)
          super

          add_corporation_to_tranches(corporation)
        end

        # Override in order to auto exchange the shortline shares
        def event_close_companies!
          %w[MC VR SB].map { |id| company_by_id(id) }.reject(&:closed?).each do |company|
            share = shortline.reserved_shares.first
            share_pool.buy_shares(company.owner,
                                  share.to_bundle,
                                  exchange: company)
            share.buyable = true
            company.close!
          end

          super
        end

        # When companies float, we need to find their PEIR company and close it,
        # give the owner a share and adjust PEIR share values
        def float_corporation(corporation)
          super

          company = company_by_id("P#{NUMBERS[corporation.id]}")

          return unless company

          # Remove PEIR token and place corporation token
          hex = @hexes.find { |h| h.id == corporation.coordinates }
          city = hex.tile.cities.first
          city.tokens.find { |token| token.corporation == peir }.destroy!
          city.exchange_token(corporation.tokens.first)

          # Mark the owner of the private
          owner = company.owner

          # Close the private
          @log << "Closing #{company.name}"
          company.close!

          # Remove the share, and transfer a market share of the company to the
          # owner
          @log << "Exchanging #{owner.name}'s PEIR share for #{corporation.full_name}"
          peir_share = share_by_id(@peir_corporation_shares[corporation.id])
          owner.shares_by_corporation[peir].delete(peir_share)
          @peir_shares.delete(peir_share)

          # Give this player the first market share of this company
          share = share_pool.shares_by_corporation[corporation].first
          bundle = Engine::ShareBundle.new(share)
          share_pool.transfer_shares(bundle, owner, price: 0, allow_president_change: true)

          # Adjust PEIR shares and set owner
          readjust_peir
        end

        def split_token_choices(corporation)
          # If a corporation no longer has at least 2 tokens there is no choice
          return [] if corporation.placed_tokens.size < 2

          home_hex_id = corporation.coordinates

          # Return choices of all tokens that aren't the home
          corporation.placed_tokens.reject do |token|
            token.city.hex&.id == home_hex_id
          end
        end

        # Don't include the bank in the results
        def result_players
          @players.reject { |p| p == @union_bank }
        end

        # Find all shares that need to be exchanged and do so. Also places
        # remaining corporation shares in its treasury and gives the branch
        # company its partial cap.
        def exchange_split_shares(corporation, branch)
          # Setup the corporation to be incremental capitalization now
          corporation.capitalization = :incremental

          # Handle the players presidency
          owner_non_presidents_shares = corporation.owner.shares_by_corporation[corporation].reject(&:president)

          @log << "#{corporation.owner.name} exchanges 2 shares of #{corporation.name} for the president cert of #{branch.name}"
          owner_non_presidents_shares.take(2).each do |share|
            share.transfer(corporation)
          end
          branch_pres_share = share_pool.shares_by_corporation[branch].find(&:president)
          branch_pres_share.transfer(corporation.owner)
          branch.owner = corporation.owner

          # Go through all players and exchange, putting exchanged shares onto
          # corporation_treasury_shares
          @players.each do |player|
            shares = player.shares_by_corporation[corporation].reject(&:president)
            num_of_branch_shares = (shares.sum(&:percent) / 10 / 2).to_i

            next unless num_of_branch_shares.positive?

            shares_str = num_of_branch_shares == 1 ? 'share' : 'shares'
            @log << "#{player.name} exchanges #{num_of_branch_shares} #{shares_str} of #{corporation.name} for #{branch.name}"

            shares.take(num_of_branch_shares).each do |share|
              share.transfer(corporation)
            end
            share_pool.shares_by_corporation[branch].take(num_of_branch_shares).each do |share|
              share.transfer(player)
            end
          end

          # Now exchange in the bank pool
          shares = share_pool.shares_by_corporation[corporation]
          num_of_branch_shares = (shares.sum(&:percent) / 10 / 2).to_i

          if num_of_branch_shares.positive?
            shares_str = num_of_branch_shares == 1 ? 'share' : 'shares'
            @log << "The market exchanges #{num_of_branch_shares} #{shares_str} of #{corporation.name} for #{branch.name}"

            shares.take(num_of_branch_shares).each do |share|
              share.transfer(corporation)
            end
            share_pool.shares_by_corporation[branch].take(num_of_branch_shares).each do |share|
              share.transfer(share_pool)
            end
          end

          branch_shares_left = share_pool.shares_by_corporation[branch].size
          treasury_shares = corporation.shares_by_corporation[corporation].count(&:buyable)

          # Assign the partial capital to the branch
          @bank.spend(branch.par_price.price * branch_shares_left, branch)

          @log << "#{corporation.name} places #{treasury_shares} shares into its treasury"
          @log << "#{branch.name} receives #{format_currency(branch.cash)} from #{branch_shares_left} market shares"
        end

        # Have to sell treasury shares in a split company when emergency fund
        # raising.
        def emergency_issuable_bundles(corp)
          return [] if corp.trains.any?
          return [] unless (train = @depot.min_depot_train)
          return [] if corp.cash >= train.price

          shares = corp.shares_of(corp).select(&:buyable)
          bundles = bundles_for_corporation(corp, corp, shares: shares)

          # If a train cannot be afforded, issue all possible shares
          biggest_bundle = bundles.max_by(&:num_shares)
          return [biggest_bundle] if biggest_bundle

          []
        end

        # Never include UB as priority deal player
        def priority_deal_player
          players = @players.reject(&:bankrupt).reject { |p| p == @union_bank }

          if @round.current_entity&.player?
            # We're in a round that iterates over players, so the
            # priority deal card goes to the player who will go first if
            # everyone passes starting now.  last_to_act is nil before
            # anyone has gone, in which case the first player has PD.
            last_to_act = @round.last_to_act
            priority_idx = last_to_act ? (players.index(last_to_act) + 1) % players.size : 0
            players[priority_idx]
          else
            # We're in a round that iterates over something else, like
            # corporations.  The player list was already rotated when we
            # left a player-focused round to put the PD player first.
            players.first
          end
        end

        # Override to allow union bank to always lose ties when choosing a new
        # president after a sale
        def player_distance_for_president(player_a, player_b)
          return 0 if !player_a || !player_b

          return players.size + 1 if (player_a == @union_bank) || (player_b == @union_bank)

          entities = players.reject(&:bankrupt)
          a = entities.find_index(player_a)
          b = entities.find_index(player_b)
          a < b ? b - a : b - (a - entities.size)
        end
      end
    end
  end
end
