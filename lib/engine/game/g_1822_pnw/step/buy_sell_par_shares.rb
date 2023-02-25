# frozen_string_literal: true

require_relative '../../g_1822/step/buy_sell_par_shares'
require_relative 'conversion'

module Engine
  module Game
    module G1822PNW
      module Step
        class BuySellParShares < Engine::Game::G1822::Step::BuySellParShares
          include Conversion
          PURCHASE_ACTIONS = Engine::Step::BuySellParShares::PURCHASE_ACTIONS + [Action::Par]

          def actions(entity)
            @converting_major && entity == current_entity ? ['choose'] : super
          end

          def ipo_type(corporation)
            case @game.major_formation_status(corporation, player: current_entity)
            when :parable, :convertable then :par
            else 'Only the owner of the associated minor can convert'
            end
          end

          def convertable_by?(corp, player)
            player.player? && @game.major_formation_status(corp, player: player) == :convertable
          end

          def get_par_prices(current_entity, corporation)
            minor = @game.associated_minor(corporation)
            return super if !minor || !minor.floated

            minor_value = minor.share_price.price * 2
            @game.stock_market.par_prices.select do |par|
              # 50 is valid for par for minors, but cannot be used here
              par.price != 50 && can_par_at?(par.price, minor.cash, minor_value, minor.owner.cash)
            end
          end

          def par_price_only(corporation, _share_price)
            minor = @game.associated_minor(corporation)
            minor&.floated
          end

          def sellable_companies(entity)
            @converting_major ? nil : super
          end

          def process_par(action)
            return super unless @game.major_formation_status(action.corporation, player: current_entity) == :convertable

            @par_price = action.share_price
            @converting_major = action.corporation
            minor = @game.associated_minor(@converting_major)
            @game.log << "#{current_entity.name} converts associate minor #{minor.name} to #{@converting_major.name} at  " \
                         "a par price of #{@game.format_currency(@par_price.price)}"
          end

          def choice_available?(entity)
            @converting_major == entity && convertable_by?(entity, current_entity)
          end

          def visible_corporations
            @converting_major ? [@converting_major] : @game.sorted_corporations.reject(&:closed?)
          end

          def hide_bank_companies?
            @converting_major
          end

          def choices
            choices = {}
            minor = @game.associated_minor(@converting_major)
            minor_value = minor.share_price.price * 2
            possible_exchanged_shares(@par_price.price, minor.cash, minor_value, minor.owner.cash).each do |shares|
              money_difference = minor_value - (@par_price.price * shares)
              choices[shares.to_s] = if money_difference.zero?
                                       "#{minor.owner.name} receives #{shares} shares"
                                     elsif money_difference.positive?
                                       "#{minor.owner.name} receives #{shares} shares and " \
                                         "#{@game.format_currency(money_difference)}"
                                     else
                                       "#{minor.owner.name} receives #{shares} shares and pays " \
                                         "#{@game.format_currency(-1 * money_difference)}"
                                     end
            end
            choices
          end

          def choice_name
            'Exchange options'
          end

          def process_choose(action)
            num_shares = action.choice.to_i
            minor = @game.associated_minor(@converting_major)

            @game.transfer_posessions(minor, @converting_major)
            @converting_major.ipoed = true
            @converting_major.floated = true
            @converting_major.capitalization = :incremental
            @game.remove_home_icon(@converting_major, minor.coordinates)

            @game.stock_market.set_par(@converting_major, @par_price)

            shares_value = (num_shares * @par_price.price)
            minor_value = minor.share_price.price * 2

            if shares_value > minor_value
              @game.log << "#{current_entity.name} pays #{@game.format_currency(shares_value - minor_value)} " \
                           "to get #{num_shares} shares of #{@converting_major.name}"
              current_entity.spend(shares_value - minor_value, @converting_major)
            elsif shares_value < minor_value
              @game.log << "#{current_entity.name} gets #{num_shares} shares of #{@converting_major.name} " \
                           "and #{@game.format_currency(minor_value - shares_value)}"
              @converting_major.spend(minor_value - shares_value, current_entity)
            else
              @game.log << "#{current_entity.name} gets #{@num_shares} shares of #{@converting_major.name}"
            end

            @game.share_pool.transfer_shares(Engine::ShareBundle.new(@converting_major.shares.first(num_shares - 1)),
                                             current_entity)

            city = minor.tokens[0].city
            city.delete_token!(minor.tokens[0])
            city.place_token(@converting_major, @converting_major.find_token_by_type, check_tokenable: false)
            @game.log << "#{@converting_major.name} replaces the #{minor.name} token in #{city.hex.name}"

            @game.close_minor(minor)
            track_action(action, @converting_major)
            @converting_major = nil
            pass!
          end

          def selected_corporation
            @converting_major
          end
        end
      end
    end
  end
end
