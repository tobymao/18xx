# frozen_string_literal: true

module Engine
  module Game
    module G18Uruguay
      module Nationalization
        def new_nationalization_round(round_num)
          G18Uruguay::Round::Nationalization.new(self, [
              G18Uruguay::Step::DiscardTrain,
              G18Uruguay::Step::PayoffLoans,
              G18Uruguay::Step::NationalizeCorporation,
              G18Uruguay::Step::RemoveTokens,
              ], round_num: round_num)
        end
      end

      def affected_shares(entity, corps)
        affected = entity.shares.select { |s| s.corporation == corps.first }.sort_by(&:percent).reverse
        unless corps.one?
          affected.concat(entity.shares.select do |s|
                            s.corporation == corps.last
                          end.sort_by(&:percent).reverse)
        end
        affected
      end

      def find_president(holders, corps)
        president_candidate = nil
        candidate_sum = 0
        holders.each do |holder|
          entity_shares = affected_shares(holder, corps)
          sum = entity_shares.sum(&:percent)
          if sum > candidate_sum
            president_candidate = holder
            candidate_sum = sum
          end
        end
        president_candidate
      end

      def transfer_share(share, new_owner)
        corp = share.corporation
        corp.share_holders[share.owner] -= share.percent
        corp.share_holders[new_owner] += share.percent
        share.owner.shares_by_corporation[corp].delete(share)
        new_owner.shares_by_corporation[corp] << share
        share.owner = new_owner
      end

      def transfer_pres_share(corporation, owner)
        pres_share = corporation.presidents_share
        transfer_share(pres_share, owner)
        corporation.owner = owner
      end

      def acquire_shares_in_fce(corp_fce, merge_data)
        new_president = find_president(merge_data[:holders], merge_data[:corps])
        transfer_pres_share(corp_fce, new_president)

        merge_data[:holders].each do |holder|
          aquired = 0
          aquired = 20 if holder == new_president
          entity_shares = affected_shares(holder, merge_data[:corps])
          total_percent = entity_shares.sum(&:percent)
          aquire_percent = (total_percent / 20).to_i * 10
          while aquired < aquire_percent
            share = corp_fce.shares.first
            aquired += share.percent
            transfer_share(share, holder)
          end
          number = aquire_percent
          @log << "#{holder.name} recives #{number}% in FCE in exchange to the nationalized shares"
          odd_share = aquired * 2 != total_percent
          next unless odd_share

          price = corp_fce.share_price.price / 2
          @bank.spend(price, holder)
          @log << "#{holder.name} recives #{price} from halv share"
        end
        @log << "#{new_president.name} becomes new president of #{corp_fce.name}"
      end

      def compute_merger_share_price(corp_a, corp_b)
        price = corp_a.share_price.price
        price = (corp_a.share_price.price + corp_b.share_price.price) / 2 unless corp_b.nil?
        max_share_price = nil
        @stock_market.market.reverse_each do |row|
          next if row.first.coordinates[0] == RPTLA_STOCK_ROW

          share_price = row.max_by { |p| p.price <= price ? p.price : nil }
          next if share_price.nil?

          max_share_price = share_price if max_share_price.nil?
          max_share_price = share_price if max_share_price.price < share_price.price
          if max_share_price.price == share_price.price && max_share_price.coordinates[1] == share_price.coordinates[1]
            max_share_price = share_price
          end
        end
        max_share_price
      end

      def move_assets(corp_fce, corp)
        # cash
        corp.spend(corp.cash, corp_fce) if corp.cash.positive?
        # train
        corp.trains.each { |train| train.owner = corp_fce }
        corp_fce.trains.concat(corp.trains)
        corp.trains.clear
        corp_fce.trains.each { |t| t.operated = false }
      end

      def swap_token(survivor, nonsurvivor, old_token)
        city = old_token.city
        exist = city.tokens.find { |token| token&.corporation == survivor }
        nonsurvivor.tokens.delete(old_token)
        if exist
          @log << "Token removed in #{city.hex.id} since FCE already have one token in that location"
          city.tokens[city.tokens.find_index(old_token)] = nil
          return nil
        end
        new_token = survivor.next_token
        @log << "Replaced #{nonsurvivor.name} token in #{city.hex.id} with #{survivor.name} token"
        new_token.place(city)
        city.tokens[city.tokens.find_index(old_token)] = new_token
        new_token
      end

      def corps_to_nationalize
        @round.entities.select { |entity| entity.loans.size.positive? && entity != @rptla }
      end

      def start_merge(originatior, _entity_a, _entity_b)
        candidates = corps_to_nationalize
        corp_a = nil
        corp_b = nil
        corps = []
        if candidates.size.positive?
          corp_a = candidates.shift
          corps.append(corp_a)
        end
        if candidates.size.positive?
          corp_b = candidates.shift
          corps.append(corp_b)
        end
        @merge_data = {
          holders: share_holder_list(originatior, corps),
          corps: corps,
          secondary_corps: [],
          home_tokens: [],
          tokens: [],
          candidates: candidates,
        }

        if corp_a.nil?
          @fce.close!
          @corporations.delete(@fce)
          return
        end

        @fce.ipoed = true
        fce_share_price = compute_merger_share_price(corp_a, corp_b)
        @fce.floatable = true
        @stock_market.set_par(@fce, fce_share_price)
        after_par(@fce)

        acquire_shares_in_fce(@fce, @merge_data)
      end

      def nationalization_final_export!
        @log << '  Nationalization: Final Export to be implemented'
      end

      def nationalization_close_rptla!
        @log << '  Nationalization: RPTLA closes'
        corporation = @rptla
        corporation.share_holders.keys.each do |share_holder|
          shares = share_holder.shares_of(corporation)
          bundle = ShareBundle.new(shares)
          sell_shares_and_change_price(bundle) unless corporation == share_holder
        end
        @rptla.close!
        @corporations.delete(@rptla)
      end

      def close_rptla_private!
        sym = 'JOHN'
        company = @companies.find { |comp| comp.sym == sym }
        return if company.closed?

        @log << ('RPTLA buys its first non-yellow ship: ' + company&.name + ' closes')
        company&.close!
      end

      def nationalization_close_private!
        sym = 'AP'
        company = @companies.find { |comp| comp.sym == sym }
        @log << ('  Nationalization: ' + company&.name + ' closes')
        company&.close!
      end

      def nationalized?
        @nationalized
      end

      def custom_end_game_reached?
        @nationalized
      end

      def event_nationalization!
        print('-- Event: Nationalization! --')
        @log << '-- Event: Nationalization! --'
        @nationalization_triggered = true
        nationalization_final_export!
        nationalization_close_rptla!
        nationalization_close_private!
        @nationalized = true
        train = train_by_id('7-0')
        buy_train(@fce, train, :free)
      end

      def retreive_home_tokens
        home_tokens = []
        tokens = []
        @merge_data[:corps].each do |corp|
          home_tokens.append(corp.tokens[0])
          tokens += corp.tokens
        end
        @merge_data[:secondary_corps].each do |corp|
          home_tokens.append(corp.tokens[0])
          tokens += corp.tokens
        end
        tokens = tokens.select { |token| !home_tokens.include?(token) && !token.hex.nil? }
        if home_tokens.size >= @fce.tokens.size
          tokens.each do |token|
            @log << "Remove #{token.corporation.name} token from hex #{token.hex.id}"
            token.destroy!
          end
          tokens = []
        end

        (home_tokens.size + tokens.size - @fce.tokens.size).times { @fce.tokens << Token.new(@fce, price: 0) }
        home_tokens.each do |token|
          new_token = swap_token(@fce, token.corporation, token)
          @merge_data[:home_tokens].append(new_token) unless new_token.nil?
        end
        tokens.each do |token|
          new_token = swap_token(@fce, token.corporation, token)
          @merge_data[:tokens].append(new_token) unless new_token.nil?
        end
      end

      def remove_corporation!(corporation)
        @log << "#{corporation.name} is merge into FCE and removed from the game"

        corporation.share_holders.keys.each do |share_holder|
          share_holder.shares_by_corporation.delete(corporation)
        end

        @share_pool.shares_by_corporation.delete(corporation)
        corporation.share_price&.corporations&.delete(corporation)
        corporation.close!
        @corporations.delete(corporation)
      end

      def close_companies
        @merge_data[:corps].each do |corp|
          move_assets(@fce, corp)
          remove_corporation!(corp)
        end
        @merge_data[:secondary_corps].each do |corp|
          move_assets(@fce, corp)
          remove_corporation!(corp)
        end
        @corporations.delete(@rlpta)
      end
    end
  end
end
