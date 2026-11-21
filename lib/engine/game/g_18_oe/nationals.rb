# frozen_string_literal: true

require_relative 'national_revenue'

module Engine
  module Game
    module G18OE
      module Nationals
        def setup_nationals
          @rusted_at_phase_change = Hash.new { |hash, owner| hash[owner] = [] }
          @national_formation_queue = []
        end

        def national?(corporation)
          corporation&.corporation? && corporation.type == :national
        end

        def national_region_by_coordinates
          @national_region_by_coordinates ||= begin
            regions = {}
            self.class::NATIONAL_REGION_HEXES.each do |region, coordinates|
              coordinates.each { |coordinate| regions[coordinate] ||= region }
            end
            regions.merge(self.class::CITY_TOWN_NATIONAL_ZONE)
          end
        end

        def city_tokened_by?(city, entity)
          return true if national?(entity) && region_for_hex(city.hex) == entity_track_rights_zone(entity)

          super
        end

        def national_candidates(player)
          corporations.select { |corporation| corporation.floated? && corporation.type == :major && corporation.owner == player }
        end

        def national_formation_phase?(name)
          self.class::NATIONAL_FORMATION_PHASES.include?(name)
        end

        def start_national_formation!(buyer)
          clear_rusted_at_phase_change!
          order = @players.include?(buyer) ? @players.rotate(@players.index(buyer)) : @players
          @national_formation_queue = order.reject { |player| national_candidates(player).empty? }
        end

        def national_formation_player
          @national_formation_queue.first
        end

        def national_formation_done!(player)
          @national_formation_queue.delete(player)
          clear_rusted_at_phase_change! if @national_formation_queue.empty?
        end

        def forced_national_choice
          self.class::FORCED_NATIONAL_CHOICE
        end

        def forced_national_conversion?(major)
          return false if major.type != :major || !major.floated? || !trainless?(major)

          price = forced_train_price(major)
          !price.nil? && major.cash + major.owner.cash < price
        end

        def force_national!(major)
          president = major.owner
          cash = president.cash
          @log << "#{president.name} cannot fund a train for #{major.name} and surrenders #{format_currency(cash)} to the bank"
          president.spend(cash, @bank) if cash.positive?
          form_national!(major)
        end

        def form_national!(major)
          @log << "#{major.name} forms a national (#{entity_track_rights_zone(major)})"
          major.spend(major.cash, @bank) if major.cash.positive?
          move_corporation_treasury_shares_to_open_market!(major)
          discard_pullman!(major) if pullman(major)
          remove_corporation_tokens!(major)
          remove_corporation_port_authorities!(major)
          remove_corporation_orient_express_marker!(major)
          remove_corporation_pass_through_tokens!(major)
          abandon_corporation_merged_minors!(major)
          major.type = :national
          return_corporation_rusted_trains!(major)
          clear_graph
        end

        def move_corporation_treasury_shares_to_open_market!(corporation)
          shares = corporation.treasury_shares.dup
          return if shares.empty?

          bundle = Engine::ShareBundle.new(shares)
          @share_pool.transfer_shares(bundle, @share_pool, allow_president_change: false)
          @log << "#{corporation.name} moves #{shares.sum(&:percent)}% of its treasury shares to the Open Market"
        end

        def remove_corporation_tokens!(corporation)
          wcf_position = wcf_position_token?(corporation)
          corporation.tokens.each(&:remove!)
          corporation.tokens.clear
          return unless wcf_position

          place_wcf_placeholder!
          @log << "Lille's White Cliffs Ferry position is open again (§11.2.2)"
        end

        def remove_corporation_port_authorities!(corporation)
          @port_authorities.delete(corporation)&.each { |sea| @removed_port_authorities[sea] += 1 }
        end

        def remove_corporation_orient_express_marker!(corporation)
          @orient_express_markers.delete(corporation)
        end

        def remove_corporation_pass_through_tokens!(corporation)
          @pass_through_tokens.select { |_company, token| token.corporation == corporation }.each do |company, token|
            token.remove!
            @pass_through_tokens.delete(company)
          end
        end

        def abandon_corporation_merged_minors!(corporation)
          minors = @merged_minors.delete(corporation) || []
          minors.each { |minor| abandon_merged_minor!(minor, corporation) }
          return if minors.empty?

          order = game_corporations.map { |definition| definition[:sym] }
          @corporations.sort_by! { |corp| order.index(corp.id) || order.size }
        end

        def abandon_merged_minor!(minor, corporation)
          assets = @minor_charter_assets.delete(minor)
          assets[:abilities].each do |ability|
            corporation.remove_ability(ability)
            minor.add_ability(ability)
          end
          assets[:companies].each do |company|
            corporation.companies.delete(company)
            company.owner = minor
            minor.companies << company
          end
          minor.reopen!
          @corporations << minor
          share = minor.presidents_share
          share.owner.shares_by_corporation[minor] << share
          minor.ipoed = true
          minor.floated = true
          abandon_minor!(minor)
        end

        def rusted_trains
          @depot.rusted_trains
        end

        def rusted_at_phase_change(owner)
          @rusted_at_phase_change.fetch(owner, [])
        end

        def clear_rusted_at_phase_change!
          @rusted_at_phase_change.clear
        end

        def return_corporation_rusted_trains!(corporation)
          @rusted_at_phase_change.delete(corporation)&.each do |train|
            @depot.remove_train(train)
            train.owner = corporation
            corporation.trains << train
          end
          @crowded_corps = nil
        end

        def national_revenue(corporation)
          NationalRevenue.new(self, corporation)
        end

        def national_filler_city_revenue
          self.class::NATIONAL_FILLER_CITY_REVENUE
        end

        def national_filler_town_revenue
          self.class::NATIONAL_FILLER_TOWN_REVENUE
        end

        def national_claimable_trains
          rusted_trains.uniq(&:sym)
        end

        def national_upgrade_trains(national)
          national_candidates(national.owner)
            .flat_map(&:trains)
            .reject { |train| train.rusted || extra_train?(train) }
        end

        def national_swaps_open?
          !(@round.respond_to?(:national_upgraded) && @round.national_upgraded)
        end

        def national_train_exchanges(national)
          owned = national.trains.select(&:rusted).uniq(&:name)
          swaps = national_swaps_open? ? national_claimable_trains : []
          upgrades = national_upgrade_trains(national).uniq { |t| [t.owner, t.name] }
          owned.flat_map do |rusted|
            swap_entries = swaps.select { |train| train.level > rusted.level }.flat_map do |train|
              train.variants.keys.map { |variant_name| [rusted, train, variant_name, 0] }
            end
            upgrade_entries = upgrades.map { |train| [rusted, train, train.name, 0] }
            swap_entries + upgrade_entries
          end
        end

        def national_claim_train!(national, train, variant)
          train.variant = variant
          buy_train(national, train, :free)
          @log << "#{national.name} claims a rusted #{train.name} from the Locomotive Works"
        end

        def national_swap_train!(national, rusted, train, variant)
          @depot.reclaim_train(rusted)
          train.variant = variant
          buy_train(national, train, :free)
          @log << "#{national.name} exchanges a rusted #{rusted.name} for a rusted #{train.name}"
        end

        def national_upgrade_train!(national, rusted, train)
          seller = train.owner
          amount = (train.price.to_f / 2).floor
          @depot.reclaim_train(rusted)
          buy_train(national, train, :free)
          @bank.spend(amount, seller)
          @log << "#{national.name} upgrades a rusted #{rusted.name} to #{seller.name}'s #{train.name}; " \
                  "#{seller.name} receives #{format_currency(amount)} from the bank"
        end
      end
    end
  end
end
