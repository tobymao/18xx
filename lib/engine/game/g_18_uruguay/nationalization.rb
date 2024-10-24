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
            @log << "#{holder.name} receives  #{number}% in FCE in exchange to the nationalized shares"
            odd_share = aquired * 2 != total_percent
            next unless odd_share

            price = corp_fce.share_price.price / 2
            @bank.spend(price, holder)
            @log << "#{holder.name} receives  #{price} from half share"
          end
          @log << "#{new_president.name} becomes new president of #{corp_fce.name}"
        end

        def compute_merger_share_price(corps)
          price = 0
          price = corps.sum { |corp| corp.share_price.price } / corps.size if corps.size.positive?
          max_share_price = nil
          @stock_market.market.reverse_each do |row|
            next if row.first.coordinates[0] == self.class::RPTLA_STOCK_ROW

            share_price = row.max_by { |p| p.price <= price ? p.price : 0 }
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
          @round.entities.select do |entity|
            entity.loans.size.positive? && entity.loans.size <= maximum_loans(entity) && entity != @rptla
          end
        end

        def start_merge(originatior)
          candidates = corps_to_nationalize
          corps = candidates.take(2)
          @merge_data = {
            holders: share_holder_list(originatior, corps),
            corps: corps,
            secondary_corps: [],
            home_tokens: [],
            tokens: [],
            candidates: candidates,
          }

          if corps.empty?
            @fce.close!
            @corporations.delete(@fce)
            return
          end

          @fce.ipoed = true
          fce_share_price = compute_merger_share_price(corps)
          @fce.floatable = true
          @stock_market.set_par(@fce, fce_share_price)
          after_par(@fce)

          acquire_shares_in_fce(@fce, @merge_data)
        end

        def nationalization_final_export!
          return if number_of_goods_at_harbor.zero?

          nr_goods = [number_of_goods_at_harbor, @rptla.trains.sum { |train| ship_capacity(train) }].min
          @log << "Nationalization: Final Export #{nr_goods} good for #{format_currency(50)}" if nr_goods == 1
          @log << "Nationalization: Final Export #{nr_goods} goods for #{format_currency(50)} each" if nr_goods > 1
          amount_per_share = 5 * nr_goods
          players.each do |holder|
            amount = holder.num_shares_of(@rptla) * amount_per_share
            next unless amount.positive?

            @log << "Nationalization: Final Export #{holder.name} receives #{format_currency(amount)}"
            @bank.spend(amount, holder)
          end
          if @rptla.share_price.price <= amount_per_share * 10 && @rptla.trains.size.positive?
            return @stock_market.move_right(@rptla)
          end

          @stock_market.move_left(@rptla)
        end

        def nationalization_close_rptla!
          @log << '  Nationalization: RPTLA closes'
          corporation = @rptla
          corporation.share_holders.keys.each do |share_holder|
            next if share_holder == share_pool

            shares = share_holder.shares_of(corporation)
            next if shares.empty?

            bundle = ShareBundle.new(shares)
            sell_shares_and_change_price(bundle, movement: :none) unless corporation == share_holder
          end
          @rptla.close!
          @corporations.delete(@rptla)
        end

        def close_rptla_private!
          company = company_by_id('JOHN')
          return if company.closed?

          @log << ('RPTLA buys its first non-yellow ship: ' + company&.name + ' closes')
          company&.close!
        end

        def nationalization_close_private!
          company = company_by_id('AP')
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
          @log << '-- Event: Nationalization! --'
          @nationalization_triggered = true
          nationalization_final_export!
          nationalization_close_rptla!
          nationalization_close_private!
          @nationalized = true
          train = train_by_id('7-0')
          buy_train(@fce, train, :free)
          phase.buying_train!(@fce, train, train.owner)
          minors.each(&:close!)
        end

        # Move stock price one step left for each loan more than limit
        def decrease_stock_value
          @corporations.each do |corporation|
            over_committed = loans_due_interest(corporation) - maximum_loans(corporation)
            if over_committed.positive?
              @log << "#{corporation.name} stock prices drops #{over_committed} steps due to over commitment"
              over_committed.times { @stock_market.move_left(corporation) }
            end
          end
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
            @fce.tokens.delete(@fce.next_token) if new_token.nil?
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

        def share_holder_list(originator, corps)
          @players.rotate(@players.index(originator.owner)).select do |p|
            corps.any? do |c|
              !p.shares_of(c).empty?
            end
          end
        end
      end
    end
  end
end
