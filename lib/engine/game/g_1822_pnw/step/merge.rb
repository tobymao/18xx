# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../token'
require_relative '../../../step/token_merger'
require_relative '../../../step/programmer_merger_pass'

module Engine
  module Game
    module G1822PNW
      module Step
        class Merge < Engine::Step::Base
          include Engine::Step::TokenMerger
          include Engine::Step::ProgrammerMergerPass
          include Engine::Game::G1822PNW::Connections
          include Conversion

          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity
            return %w[choose] if @merge_state != :none
            return %w[merge pass] if mergeable(entity).any?

            []
          end

          def setup
            @merge_state = :none
          end

          def merge_name(_entity = nil)
            'Merge'
          end

          def description
            'Merge Corporation'
          end

          def log_skip(entity)
            @log << "#{entity.name} has no valid companies to merge with and is skipped"
          end

          def buyer
            @merge_state == :none ? nil : @new_corporation
          end

          def mergeable(corporation)
            return [] unless @merge_state == :none

            @game.unassociated_minors.select do |m|
              (entity_connects?(corporation, m) || entity_connects?(m, corporation)) &&
                !valid_par_prices(corporation, m).empty? &&
                corporation.owner == m.owner
            end
          end

          def choice_name
            case @merge_state
            when :selecting_par
              'Choose par value for new company'
            when :selecting_shares
              'Choose number of shares to make up minors value of '\
              "#{@game.format_currency((@associated_minor.share_price.price + @unassociated_minor.share_price.price) * 2)}"
            when :selecting_token
              'What to do with the token'
            end
          end

          def valid_par_prices(minor_one, minor_two)
            minors_value = (minor_one.share_price.price + minor_two.share_price.price) * 2
            minors_cash = (@merge_state == :none ? (minor_one.cash + minor_two.cash) : @new_corporation.cash)
            @game.stock_market.par_prices.map(&:price).sort.select do |par|
              # 50 is valid for par for minors, but cannot be used here
              par != 50 && can_par_at?(par, minors_cash, minors_value, minor_one.owner.cash)
            end
          end

          def choices
            choices = {}
            case @merge_state
            when :selecting_par
              valid_par_prices(@associated_minor, @unassociated_minor).each do |par|
                choices[par.to_s] = @game.format_currency(par)
              end
            when :selecting_shares
              minors_value = (@associated_minor.share_price.price + @unassociated_minor.share_price.price) * 2
              minors_cash = @new_corporation.cash
              player_cash = @associated_minor.owner.cash
              possible_exchanged_shares(@selected_par, minors_cash, minors_value, player_cash).each do |shares|
                money_difference = minors_value - (@selected_par * shares)
                choices[shares.to_s] = if money_difference.zero?
                                         "#{@associated_minor.owner.name} receives #{shares} shares"
                                       elsif money_difference.positive?
                                         "#{@associated_minor.owner.name} receives #{shares} shares and " \
                                           "#{@game.format_currency(money_difference)}"
                                       else
                                         "#{@associated_minor.owner.name} receives #{shares} shares and pays " \
                                           "#{@game.format_currency(-1 * money_difference)}"
                                       end
              end
            when :selecting_token
              choices['replace'] = 'Replace token on the map with an exchange token'
              choices['exchange'] = 'Move an exchange token to available token area on the corporation chart'
            end
            choices
          end

          def process_merge(action)
            @associated_minor = action.entity
            @unassociated_minor = action.corporation

            if !@game.loading && (!@unassociated_minor || !mergeable(@associated_minor).include?(@unassociated_minor))
              raise GameError, "Choose a corporation to merge with #{@associated_minor.name}"
            end

            @new_corporation = @game.associated_major(@associated_minor)
            @player = @associated_minor.owner

            @game.log << "#{@associated_minor.name} and #{@unassociated_minor.name} merge into #{@new_corporation.name}"

            @game.transfer_posessions(@associated_minor, @new_corporation)
            @game.transfer_posessions(@unassociated_minor, @new_corporation)
            @new_corporation.ipoed = true
            @new_corporation.floated = true
            @new_corporation.capitalization = :incremental
            @game.remove_home_icon(@new_corporation, @associated_minor.coordinates)

            @merge_state = :selecting_par
          end

          def process_select_par(action)
            @selected_par = action.choice.to_i
            @game.log << "#{@new_corporation.name} is parred at #{@game.format_currency(@selected_par)}"
            @game.stock_market.set_par(@new_corporation, @game.stock_market.par_prices.find { |pp| pp.price == @selected_par })
            @merge_state = :selecting_shares
          end

          def process_select_shares(action)
            @selected_shares = action.choice.to_i
            shares = @new_corporation.shares.first(@selected_shares - 1)
            bundle = Engine::ShareBundle.new(shares)
            @game.share_pool.transfer_shares(bundle, @player)

            minors_value = (@associated_minor.share_price.price + @unassociated_minor.share_price.price) * 2
            shares_value = (@selected_shares * @selected_par)

            if shares_value > minors_value
              @game.log << "#{@player.name} pays #{@game.format_currency(shares_value - minors_value)} " \
                           "to get #{@selected_shares} shares of #{@new_corporation.name}"
              @player.spend(shares_value - minors_value, @new_corporation)
            elsif (@selected_shares * @selected_par) < minors_value
              @game.log << "#{@player.name} gets #{@selected_shares} shares of #{@new_corporation.name} " \
                           "and #{@game.format_currency(minors_value - shares_value)}"
              @new_corporation.spend(minors_value - shares_value, @player)
            else
              @game.log << "#{@player.name} gets #{@selected_shares} shares of #{@new_corporation.name}"
            end

            @merge_state = :selecting_token
            process_minor_on_destination if @new_corporation.destination_coordinates == @associated_minor.coordinates
          end

          def process_select_token(action)
            @selected_token = action.choice
            city = @associated_minor.tokens[0].city
            city.delete_token!(@associated_minor.tokens[0])
            city.place_token(@new_corporation, @new_corporation.find_token_by_type, check_tokenable: false)
            @game.log << "#{@new_corporation.name} replaces the #{@associated_minor.name} token in #{city.hex.name}"

            city = @unassociated_minor.tokens[0].city
            city.delete_token!(@unassociated_minor.tokens[0])
            @game.move_exchange_token(@new_corporation)
            if @selected_token == 'replace'
              city.place_token(@new_corporation, @new_corporation.find_token_by_type, check_tokenable: false)
              @game.log << "#{@new_corporation.name} replaces the #{@unassociated_minor.name} token in #{city.hex.name}"
            else
              @game.log << "#{@new_corporation.name} moves one token from exchange to available"
            end

            finish_merge
          end

          def process_minor_on_destination
            city = @unassociated_minor.tokens[0].city
            city.delete_token!(@unassociated_minor.tokens[0])
            city.place_token(@new_corporation, @new_corporation.find_token_by_type, check_tokenable: false)
            @game.log << "#{@new_corporation.name} token replaces the #{@unassociated_minor.name} token in #{city.hex.name}"

            city = @associated_minor.tokens[0].city
            city.delete_token!(@associated_minor.tokens[0])
            token = @new_corporation.find_token_by_type(:destination)
            city.place_token(@new_corporation, token, free: true, check_tokenable: false, cheater: true)
            city.hex.tile.icons.reject! { |icon| icon.name == "#{@new_corporation.id}_destination" }
            ability = @new_corporation.all_abilities.find { |a| a.type == :destination }
            @new_corporation.remove_ability(ability)
            @game.log << "#{@new_corporation.name} destination token replaces the #{@associated_minor.name} " \
                         "token in #{city.hex.name}"

            finish_merge
          end

          def finish_merge
            @game.graph.clear
            @game.close_minor(@associated_minor)
            @game.close_minor(@unassociated_minor)
            @merge_state = :none
            pass!
          end

          def process_choose(action)
            case @merge_state
            when :selecting_par
              process_select_par(action)
            when :selecting_shares
              process_select_shares(action)
            when :selecting_token
              process_select_token(action)
            end
          end

          def mergeable_type(corporation)
            "Corporations that can merge with #{corporation.name}"
          end

          def show_other_players
            false
          end
        end
      end
    end
  end
end
