# frozen_string_literal: true

require_relative '../../../round/auction'

module Engine
  module Game
    module G1871
      module Round
        class Stock < Engine::Round::Stock
          attr_reader :split_corporation, :split_branch
          attr_accessor :bank_bought

          SPLIT_NONE = 0
          SPLIT_PICK_BRANCH = 1
          SPLIT_PICK_TOKENS = 2
          SPLIT_PICK_PAR = 3
          SPLIT_PICK_TRAINS = 4
          SPLIT_PICK_MONEY = 5
          SPLIT_PICK_HUNSLET = 6

          def setup
            @bank_bought = false
            super
          end

          def select_entities
            super.reject { |p| p == @game.union_bank }
          end

          def split_active?
            (@split || 0).positive?
          end

          def split_corporations
            [@split_corporation, @split_branch].compact
          end

          def split_start(corporation)
            @split_corporation = corporation
            @split_branch = nil
            split_next
            @log << "#{current_entity.name} splits #{@split_corporation.full_name}"
          end

          def split_active_entities
            [@split_corporation&.owner].compact
          end

          def split_choice_entity
            case @split
            when SPLIT_PICK_BRANCH
              current_entity
            when SPLIT_PICK_TOKENS, SPLIT_PICK_PAR, SPLIT_PICK_TRAINS, SPLIT_PICK_MONEY, SPLIT_PICK_HUNSLET
              @split_branch
            end
          end

          def split_choices
            case @split
            when SPLIT_PICK_BRANCH
              @game.available_splits.to_h { |c| [c.id, c.full_name] }
            when SPLIT_PICK_TOKENS
              tokens = @game.split_token_choices(@split_corporation)
              token_choices = tokens.to_h { |t| [@split_corporation.tokens.find_index(t), t.city.hex.id] }
              token_choices['done'] = 'Done' if @split_corporation.tokens.size < 4
              token_choices
            when SPLIT_PICK_PAR
              @game.stock_market.par_prices.to_h do |p|
                price_str = @game.par_price_str(p)
                available_cash = current_entity.cash
                purchasable_shares = (available_cash / p.price).to_i

                [p.id, "#{price_str} (#{purchasable_shares})"]
              end
            when SPLIT_PICK_TRAINS
              trains = @split_corporation.trains.to_h { |t| [t.id, t.name] }
              trains['done'] = 'Done'
              trains
            when SPLIT_PICK_MONEY
              [0, @split_corporation.cash]
            when SPLIT_PICK_HUNSLET
              { yes: 'Yes', no: 'No' }
            end
          end

          def show_map
            @split == SPLIT_PICK_TOKENS
          end

          def split_description
            case @split
            when SPLIT_PICK_BRANCH
              "Splitting #{@split_corporation.full_name} - Choosing Branch"
            when SPLIT_PICK_TOKENS
              "Splitting #{@split_corporation.full_name} - Choosing Tokens"
            when SPLIT_PICK_PAR
              "Splitting #{@split_corporation.full_name} - Choosing Par"
            when SPLIT_PICK_TRAINS
              "Splitting #{@split_corporation.full_name} - Choosing Train Split"
            when SPLIT_PICK_MONEY
              "Splitting #{@split_corporation.full_name} - Choosing Cash Split"
            when SPLIT_PICK_HUNSLET
              "Splitting #{@split_corporation.full_name} - Choosing Hunslet Owner"
            end
          end

          def split_prompt
            case @split
            when SPLIT_PICK_BRANCH
              'Start'
            when SPLIT_PICK_TOKENS
              'Choose Tokens'
            when SPLIT_PICK_PAR
              'Choose Par'
            when SPLIT_PICK_TRAINS
              'Choose Trains'
            when SPLIT_PICK_MONEY
              'Choose Cash'
            when SPLIT_PICK_HUNSLET
              'Transferring Hunslet?'
            end
          end

          def split_pick_branch(branch)
            @split_branch = branch
            @log << "#{current_entity.name} picks #{@split_branch.full_name} as the new company"
            split_next

            # Now check if there is only one token choice, and just pick it if so
            tokens = @game.split_token_choices(@split_corporation)
            return unless tokens.size == 1

            index = @split_corporation.tokens.find_index(tokens[0])
            process_action(Engine::Action::Choose.new(current_entity, choice: index))
          end

          def split_pick_par(share_price)
            @log << "Setting par of #{@split_branch.full_name} to #{@game.format_currency(share_price.price)}"
            @game.stock_market.set_par(@split_branch, share_price)
            @game.after_par(@split_branch)
            @game.exchange_split_shares(@split_corporation, @split_branch)
            @split_branch.ipoed = true
            split_next
          end

          def split_pick_tokens(token)
            city = token.city
            @log << "#{@split_corporation.full_name} token in #{city.hex.id} is replaced with #{@split_branch.full_name} token"
            new_token = @split_branch.next_token
            token.swap!(new_token)
            token.destroy!

            return unless @game.split_token_choices(@split_corporation).empty?

            @log << "#{@split_corporation.full_name} is out of tokens to swap"
            split_next

            # if there is only one par choice, pick it
            pars = @game.stock_market.par_prices
            process_action(Engine::Action::Choose.new(current_entity, choice: pars[0].id)) if pars.size == 1
          end

          def split_pick_trains(train)
            @split_corporation.trains.delete(train)
            train.owner = @split_branch
            @split_branch.trains << train
            @log << "#{current_entity.name} transfers #{train.name} to #{@split_branch.full_name}"

            return unless @split_corporation.trains.empty?

            @log << "#{@split_corporation.full_name} is out of trains to transfer"
            split_next
          end

          def split_pick_money(amount)
            @split_corporation.spend(amount, @split_branch) unless amount.zero?
            @log << "#{@split_corporation.full_name} transfers #{@game.format_currency(amount)} to #{@split_branch.full_name}"

            # Skip the next step if we aren't dealing with the hunslet
            split_next if @game.company_by_id('HSE').owner != @split_corporation

            split_next
          end

          def split_pick_hunslet(do_transfer)
            if do_transfer
              @log << "#{current_entity.name} is transferring the Hunslet to #{@split_branch.full_name}"
              hunslet = @game.company_by_id('HSE')
              hunslet.owner = @split_branch
              @split_corporation.companies.delete(hunslet)
              @split_branch.companies << hunslet
            end
            split_next
          end

          def split_process_choose(choose)
            case @split
            when SPLIT_PICK_BRANCH
              branch = @game.corporation_by_id(choose.choice)
              split_pick_branch(branch)
            when SPLIT_PICK_TOKENS
              if choose.choice == 'done'
                @log << "#{current_entity.name} is done swapping tokens"
                split_next
              else
                token = @split_corporation.tokens[choose.choice.to_i]
                split_pick_tokens(token)
              end
            when SPLIT_PICK_PAR
              share_price = @game.share_price_by_id(choose.choice)
              split_pick_par(share_price)
            when SPLIT_PICK_TRAINS
              if choose.choice == 'done'
                @log << "#{current_entity.name} is done transferring trains"
                split_next
              else
                train = @game.train_by_id(choose.choice)
                split_pick_trains(train)
              end
            when SPLIT_PICK_MONEY
              amount = choose.choice.to_i

              if amount.negative? || (amount > @split_corporation.cash)
                raise GameError, "#{@split_corporation.full_name} does not have #{@game.format_currency(amount)} in cash"
              end

              split_pick_money(amount)
            when SPLIT_PICK_HUNSLET
              split_pick_hunslet(choose.choice == 'yes')
            end
          end

          def split_next
            @split = (@split || 0) + 1

            return unless @split > SPLIT_PICK_HUNSLET

            @log << 'Split completed'
            @split = SPLIT_NONE
            next_entity!
          end

          def choice_is_amount?
            @split == SPLIT_PICK_MONEY
          end

          # Overriding to make sure reserved shares count towards selling out
          def sold_out?(corporation)
            (corporation.player_share_holders.values.sum +
             corporation.reserved_shares.sum(&:percent)) == 100
          end
        end
      end
    end
  end
end
