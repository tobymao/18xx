# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/token_merger'

module Engine
  module Game
    module G1822
      module Step
        class MinorAcquisition < Engine::Step::Base
          include Engine::Step::TokenMerger

          ACQUIRE_ACTIONS = %w[merge pass].freeze
          CHOOSE_ACTIONS = %w[choose].freeze
          CHOOSE_PAY_SHARES = { 'money' => 0, 'one_share' => 1, 'two_shares' => 2 }.freeze

          def actions(entity)
            return [] unless entity == current_entity

            # Init the state to :select_minor if this is the first time here
            @acquire_state ||= :select_minor

            # We either on the choose pay or choose token step
            return CHOOSE_ACTIONS if @acquire_state == :choose_pay || @acquire_state == :choose_token

            # Do we have any minors to acquire
            return [] unless can_acquire?(entity)

            ACQUIRE_ACTIONS
          end

          def auto_actions(entity)
            return nil if @acquire_state == :choose_pay || @acquire_state == :choose_token
            return [Engine::Action::Pass.new(entity)] if mergeable(entity).empty?
          end

          def can_acquire?(entity)
            return false if !entity.corporation? || (entity.corporation? && entity.type != :major)
            return false unless entity.operating_history.size > 1

            !potentially_mergeable(entity).empty?
          end

          def choice_name
            return 'How to pay' if @acquire_state == :choose_pay

            'What to do with the token'
          end

          def choices
            return @pay_choices if @acquire_state == :choose_pay

            @token_choices
          end

          def description
            'Acquire a minor'
          end

          def merge_name(_entity = nil)
            'Acquire a minor'
          end

          def mergeable(entity)
            potentially_mergeable(entity).select { |minor| entity_connects?(entity, minor) }
          end

          def potentially_mergeable(entity)
            # Mergable ignoring connections
            corporations = @game.corporations.select do |minor|
              minor.type == :minor && minor.floated? && minor.operating_history.size > 1 &&
                !pay_choices(entity, minor).empty?
            end
            if @game.phase.status.include?('can_acquire_minor_bidbox')
              bidbox_minors = @game.bidbox_minors.map { |c| @game.find_corporation(c) }.reject do |minor|
                pay_choices(entity, minor).empty?
              end
              corporations.concat(bidbox_minors) if bidbox_minors
            end

            corporations
          end

          def mergeable_type(corporation)
            "Minors that can merge with #{corporation.name}"
          end

          def pass_description
            'Skip (Minor acquisition)'
          end

          def token_replace_requires_choice?(entity)
            entity.id == @game.class::MINOR_14_ID
          end

          def acquire_bank_minor(entity, token_choice)
            # Transfer money from corporation to the bank
            entity.spend(@game.class::MINOR_BIDBOX_PRICE, @game.bank)

            receiving = []
            case token_choice
            when 'replace'
              if token_replace_requires_choice?(@selected_minor)
                @game.remove_exchange_token(entity)
                token = Engine::Token.new(entity)
                entity.tokens << token
                entity.add_ability(@game.minor_14_token_ability)

                @round.pending_tokens << {
                  entity: entity,
                  hexes: [@game.hex_by_id(@game.class::MINOR_14_HOME_HEX)],
                  token: token,
                }
                receiving << "a token on hex #{@game.class::MINOR_14_HOME_HEX}"
              else
                minor_city = @game.hex_by_id(@selected_minor.coordinates).tile.cities.find { |c| c.reserved_by?(@selected_minor) }
                minor_city.reservations.delete(@selected_minor)

                if minor_city.tokened_by?(entity)
                  @game.move_exchange_token(entity)
                  receiving << "one token from exchange to available since #{entity.id} cant have 2 tokens "\
                               'in the same city'
                else
                  @game.remove_exchange_token(entity)
                  token = Engine::Token.new(entity)
                  entity.tokens << token
                  minor_city.place_token(entity, token, check_tokenable: false)
                  @game.graph.clear
                  receiving << "a token on hex #{@selected_minor.coordinates}"
                end
              end
            when 'exchange'
              @game.move_exchange_token(entity)
              receiving << 'one token from exchange to available'
            end

            @log << pay_choice_str(entity, @selected_minor, @selected_share_num, show_owner_name: true)
            @log << "#{entity.id} acquired #{@selected_minor.id} receiving #{receiving.join(', ')}"

            # Remove the proxy company for the minor
            company = @game.companies.find { |c| c.id == "M#{@selected_minor.id}" }
            @game.companies.delete(company)

            # Close the minor, this also removes the minor token if the token choice of 'remove' is selected
            @game.close_corporation(@selected_minor)
          end

          def extra_transfers(minor, entity); end

          def acquire_entity_minor(entity, token_choice)
            share_difference = pay_choice_difference(entity, @selected_minor, @selected_share_num)
            log_choice = pay_choice_str(entity, @selected_minor, @selected_share_num, show_owner_name: true)

            # Transfer money from/to corporation and minor owner
            @selected_minor.owner.spend(share_difference.abs, entity) if share_difference.negative?
            entity.spend(share_difference, @selected_minor.owner) if share_difference.positive?

            # Transfer IPO shares from corporation to minor owner
            @selected_share_num.times.each do |_i|
              entity.ipo_shares.first.transfer(@selected_minor.owner)
            end

            # Transfer assets from minor to major
            receiving = []
            if @selected_minor.cash.positive?
              receiving << @game.format_currency(@selected_minor.cash)
              @selected_minor.spend(@selected_minor.cash, entity)
            end

            companies = @game.transfer(:companies, @selected_minor, entity).map(&:name)
            receiving << "companies (#{companies.join(', ')})" if companies.any?

            trains = @game.transfer(:trains, @selected_minor, entity).map(&:name)
            receiving << "trains (#{trains})" if trains.any?

            extra = extra_transfers(@selected_minor, entity)
            receiving << extra if extra

            case token_choice
            when 'replace'
              minor_city = @selected_minor.tokens.first.city
              if minor_city.tokened_by?(entity)
                @game.move_exchange_token(entity)
                remove_minor_token
                receiving << "one token from exchange to available since #{entity.id} cant have 2 tokens "\
                             'in the same city'
              else
                @game.remove_exchange_token(entity)
                tokens = move_tokens_to_surviving(entity, @selected_minor, check_tokenable: false)
                receiving << "a token on hex #{tokens.compact}"
              end
            when 'exchange'
              @game.move_exchange_token(entity)
              remove_minor_token
              receiving << 'one token from exchange to available'
            end

            @log << log_choice
            @log << "#{entity.id} acquired #{@selected_minor.id} receiving #{receiving.join(', ')}"

            # Close the minor, this also removes the minor token if the token choice of 'remove' is selected
            @game.close_corporation(@selected_minor)
          end

          def remove_minor_token
            minor_city = @game.hex_by_id(@selected_minor.coordinates).tile.cities.find { |c| c.tokened_by?(@selected_minor) }
            minor_city.delete_token!(@selected_minor.tokens.first,
                                     remove_slot: minor_city.slots > @game.min_city_slots(minor_city))
          end

          def process_choose(action)
            if @acquire_state == :choose_pay
              @selected_share_num = CHOOSE_PAY_SHARES[action.choice]
              @acquire_state = :choose_token
            else
              if !@selected_minor.owner || @selected_minor.owner == @bank
                acquire_bank_minor(action.entity, action.choice)
              else
                acquire_entity_minor(action.entity, action.choice)
              end
              @acquire_state = :select_minor
              pass!
            end
          end

          def entity_connects?(entity, minor)
            if (!minor.owner || minor.owner == @bank) && minor.id == @game.class::MINOR_14_ID
              # Trying to acquire minor 14 from the bank. You still have to have connection to london.
              # You have a option to place a "cheater" token in one of the cities you have connection to.
              # A small note, if a corporation already have a token in london and no clear path to another node.
              # They can still choose to acquire and still gets both options of place or exchange. We dont want
              # to an extra check of connected_nodes. This is very costly.
              # Try all 6 cities in london to see if there is atleast one connection
              connected_nodes = @game.graph.connected_nodes(entity)
              found_connected_city = @game.hex_by_id(@game.class::MINOR_14_HOME_HEX).tile.cities.any? do |c|
                connected_nodes[c]
              end
            else
              minor_city = if !minor.owner || minor.owner == @bank
                             # Trying to acquire a bidbox minor. Trace route to its hometokenplace
                             @game.hex_by_id(minor.coordinates).tile.cities.find { |c| c.reserved_by?(minor) }
                           else
                             # Minors only have one token, check if its connected
                             minor.tokens.first.city
                           end
              found_connected_city = @game.graph.connected_nodes(entity)[minor_city]
            end
            found_connected_city
          end

          def process_merge(action)
            entity = action.entity
            minor = action.corporation

            if !@game.loading && !entity_connects?(entity, minor)
              raise GameError, "Can't acquire minor #{minor.id} "\
                               "because it is not connected to #{entity.id}"
            end

            @selected_minor = minor
            @pay_choices = pay_choices(entity, minor)
            @token_choices = token_choices(entity)
            @acquire_state = :choose_pay
          end

          def pay_choices(entity, minor)
            choices = Hash.new { |h, k| h[k] = [] }

            # Minor is a bidbox minor
            if !minor.owner || minor.owner == @bank
              if entity.cash >= @game.class::MINOR_BIDBOX_PRICE
                choice = pay_choice_str(entity, minor, 0)
                choices['money'] = choice if choice
              end
              return choices
            end

            # Pay only with corporation money
            if entity.cash >= (minor.share_price.price * 2)
              choice = pay_choice_str(entity, minor, 0)
              choices['money'] = choice if choice
            end

            # The corporation have atleast one share, calculate if corp or player should receive/pay difference
            ipo_shares = entity.num_ipo_shares
            if ipo_shares.positive?
              choice = pay_choice_str(entity, minor, 1)
              choices['one_share'] = choice if choice
            end

            # The corporation have atleast two share, calculate if corp or player should receive/pay difference
            if ipo_shares > 1 && @game.num_certs(minor.owner) < @game.cert_limit
              choice = pay_choice_str(entity, minor, 2)
              choices['two_shares'] = choice if choice
            end
            choices
          end

          def pay_choice_difference(entity, minor, share_num)
            (minor.share_price.price * 2) - (entity.share_price.price * share_num)
          end

          def pay_choice_str(entity, minor, share_num, show_owner_name: false)
            if !minor.owner || minor.owner == @bank
              return "#{entity.id} pays #{@game.format_currency(@game.class::MINOR_BIDBOX_PRICE)} to the bank"
            end

            owner_name = show_owner_name ? "#{minor.owner.name} receives" : 'Receive'
            return "#{owner_name} #{@game.format_currency(minor.share_price.price * 2)} from #{entity.id}" if share_num.zero?

            share_difference = pay_choice_difference(entity, minor, share_num)
            share_str = share_num == 1 ? '1 share' : '2 shares'
            if share_difference.negative? && share_difference.abs <= minor.owner.cash
              "#{owner_name} #{share_str} and pay #{@game.format_currency(share_difference.abs)} to #{entity.id}"
            elsif share_difference.zero?
              "#{owner_name} #{share_str} from #{entity.id}"
            elsif share_difference.positive? && share_difference <= entity.cash
              "#{owner_name} #{share_str} and #{@game.format_currency(share_difference)} from #{entity.id}"
            end
          end

          def token_choices(entity)
            choices = Hash.new { |h, k| h[k] = [] }

            if @game.exchange_tokens(entity).positive?
              choices['replace'] = 'Replace token on the map with an exchange token'
              choices['exchange'] = 'Move an exchange token to available token area on the corporation chart'
            else
              choices['remove'] = 'Remove the minors token since no exchange tokens is available'
            end
            choices
          end

          def show_other_players
            false
          end

          def skip!
            log_skip(current_entity) if !@acted && current_entity && current_entity.corporation? && current_entity.type == :major
            pass!
          end
        end
      end
    end
  end
end
