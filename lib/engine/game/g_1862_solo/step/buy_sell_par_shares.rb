# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1862Solo
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          ACTIONS = %w[buy_company choose pass].freeze

          def actions(entity)
            return [] unless entity == current_entity

            actions = ACTIONS.dup
            actions << 'sell_shares' if can_sell_any?(entity)
            actions
          end

          def round_state
            super.merge(
              {
                bought_shares: [],
              }
            )
          end

          def visible_corporations
            @game.corporations.reject(&:closed?)
          end

          def can_buy_company?(player, company)
            return false if company.value.zero?

            @game.ipo_rows.flatten.include?(company) && available_cash(player) >= company.value
          end

          # Cannot sell shares you have bought this SR
          def can_sell?(_entity, bundle)
            bundle.shares.none? { |s| @round.bought_shares.include?(s) }
          end

          def choice_available?(_entity)
            true
          end

          def choices
            []
          end

          def choice_name
            nil
          end

          def get_par_prices(entity, _corp)
            @game.repar_prices.select { |p| p.price * 3 <= entity.cash }
          end

          def general_input_renderings_ipo_row(_entity, company, index)
            renderings = []
            return renderings if @game.ipo_rows[index].empty?

            share = company.treasury

            @game.all_rows_indexes.each do |i|
              next if i == index || @game.ipo_rows[i].empty?
              next unless company.treasury.corporation == @game.ipo_rows[i].first.treasury.corporation

              renderings << ["move##{company.id}##{i}", "Move to IPO Row #{i + 1}"]
            end

            renderings << ["remove##{company.id}", "Remove #{company.name} from IPO Row #{index + 1}"]

            if share.corporation.share_price
              renderings << ["buy##{company.id}", "Buy #{company.name} for #{@game.company_value(company)}"]
            elsif @game.can_par_corporations?
              # TODO: Need to get all possible par prices - separate view?
              # TODO: Is it possible to use interval?
              price1 = @game.repar_prices.first.price
              renderings << ["par_unchartered##{price1}##{company.id}", "Par at #{price1} (unchartered)"]
              price2 = @game.par_prices.first.price
              renderings << ["par_chartered##{price2}##{company.id}", "Par at #{price2} (chartered)"]
            end

            renderings
          end

          # Need to have false here as we are solo player
          def bought?
            false
          end

          def process_choose(action)
            choice = action.choice
            if choice.start_with?('buy')
              action_buy(choice)
            elsif choice.start_with?('deal')
              action_deal(choice)
            elsif choice.start_with?('move')
              action_move(choice)
            elsif choice.start_with?('par_chartered')
              action_par_chartered(choice)
            elsif choice.start_with?('par_unchartered')
              action_par_unchartered(choice)
            elsif choice.start_with?('remove')
              action_remove(choice)
            else
              raise GameError, "Unknown choice #{choice}"
            end

            track_action(action, @game.players.first)
          end

          def process_pass(action)
            action.entity.pass!
          end

          private

          def action_buy(choice)
            company = get_company_from_choice(choice)
            price = @game.company_value(company)
            share = company.treasury
            corporation = share.corporation
            owner = @game.bank
            player = @game.players.first

            @game.ipo_rows[company.ipo_row_index].delete(company)
            buy_shares(player, ShareBundle.new([share]), allow_president_change: false)

            player.spend(price, owner)

            if !corporation.floated? && player.shares_by_corporation[corporation].size >= 3
              @game.chartered[corporation] ? float_chartered_corporation(corporation) : float_unchartered_corporation(corporation)
            end

            cleanup_company(company)
          end

          def action_deal(choice)
            @game.remove_corporation(random_corporation)
            index = choice.split('#').last.to_i
            @game.deal_to_ipo_row(index)
            card_text = @game.cards_to_deal == 1 ? 'card is' : 'cards are'
            @log << "#{@game.cards_to_deal} #{card_text} added to IPO Row #{index + 1}"
          end

          def action_move(choice)
            parts = choice.split('#')
            raise GameError, "Incorrect choice format #{choice}" unless parts.size == 3

            id = parts[1]
            index = parts[2].to_i
            company = get_company(id)
            @game.ipo_rows[company.ipo_row_index].delete(company)
            @game.ipo_rows[index].prepend(company)
            company.ipo_row_index = index
            @log << "#{company.name} moves to top of IPO Row #{index + 1}"
          end

          def action_par_chartered(choice)
            parts = choice.split('#')
            raise GameError, "Incorrect choice format #{choice}" unless parts.size == 3

            price = parts[1].to_i
            id = parts[2].to_sym
            company = get_company(id)
            share = company.treasury
            corporation = share.corporation
            @game.chartered[corporation] = true

            par_corporation(share, corporation, price, true)
            cleanup_company(company)
          end

          def action_par_unchartered(choice)
            parts = choice.split('#')
            raise GameError, "Incorrect choice format #{choice}" unless parts.size == 3

            price = parts[1].to_i
            id = parts[2].to_sym
            company = get_company(id)
            share = company.treasury
            corporation = share.corporation

            @game.convert_to_incremental!(corporation)
            corporation.tokens.pop # 3 -> 2
            raise GameError, 'Wrong number of tokens for Unchartered Company' if corporation.tokens.size != 2

            # Unchartered starts shares in treasury
            corporation.shares.each { |s| s.owner = corporation }

            par_corporation(share, corporation, price, false)
            cleanup_company(company)

            @game.remove_corporation(random_corporation)
          end

          def par_corporation(share, corporation, price, chartered)
            @log << "#{corporation.name} pars at #{price}"
            corporation.ipoed = true
            shares_prices = chartered ? @game.par_prices : @game.repar_prices
            # owner = chartered ? @game.bank : corporation
            player = @game.players.first
            share_price = shares_prices.find { |p| p.price == price }
            @game.stock_market.set_par(corporation, share_price)
            buy_shares(player, ShareBundle.new([share]), allow_president_change: true)
          end

          def action_remove(choice)
            company = get_company_from_choice(choice)
            @log << "#{company.name} drops from IPO Row #{company.ipo_row_index + 1}"
            cleanup_company(company)
            share = company.treasury
            corporation = share.corporation
            @game.remove_corporation(corporation)
          end

          def get_company_from_choice(choice)
            id = choice.split('#').last
            get_company(id)
          end

          def get_company(id)
            company = @game.company_by_id(id)
            raise GameError, "Company with ID #{id} not found in IPO rows" unless company

            company
          end

          def random_corporation
            # Get a random corporatiion, which player does not own any shares of. TODO: Is this correct?
            @game.corporations.reject { |c| c.closed? || c.ipoed || player_owns_any_shares_of?(c) }.min_by { rand }
          end

          def player_owns_any_shares_of?(corp)
            @game.players.first.shares_by_corporation[corp].any?
          end

          def cleanup_company(company)
            @round.bought_shares << company.treasury
            @game.ipo_rows[company.ipo_row_index].delete(company)
            company.close!
          end

          def float_chartered_corporation(corporation)
            corporation.floated = true

            cash = corporation.par_price.price * 10
            @log << "Chartered #{corporation.name} floats and receives #{cash}"
            @game.bank.spend(cash, corporation)

            token_cost = 60 * 3
            @log << "#{corporation.name} buys 3 tokens and pays #{token_cost}"

            corporation.spend(token_cost, @game.bank)
            @game.assign_first_permit(corporation)
          end

          def float_unchartered_corporation(corporation)
            corporation.floated = true

            cash = corporation.par_price.price * 5
            @log << "Non-chartered #{corporation.name} floats and receives #{cash}"
            @game.bank.spend(cash, corporation)

            # TODO, unchartered should buy 2 to 7 tokens, not always 3
            token_cost = 40 * 3
            @log << "#{corporation.name} buys 3 tokens and pays #{token_cost}"
            corporation.spend(token_cost, @game.bank)

            @game.assign_first_permit(corporation)
            @game.remove_corporation(random_corporation)
          end
        end
      end
    end
  end
end
