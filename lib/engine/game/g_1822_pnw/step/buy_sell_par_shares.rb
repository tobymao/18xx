# frozen_string_literal: true

require_relative '../../g_1822/step/buy_sell_par_shares'

module Engine
  module Game
    module G1822PNW
      module Step
        class BuySellParShares < Engine::Game::G1822::Step::BuySellParShares
          PURCHASE_ACTIONS = Engine::Step::BuySellParShares::PURCHASE_ACTIONS + [Action::Par]
          def ipo_type(corporation)
            case @game.major_formation_status(corporation, player: current_entity)
            when :parable then :par
            when :convertable then :form
            else 'Only the owner of the associated minor can convert'
            end
          end

          def process_par(action)
            return super unless @game.major_formation_status(action.corporation, player: current_entity) == :convertable

            major = action.corporation
            minor = @game.associated_minor(major)

            @game.log << "#{current_entity.name} converts #{minor.name} to #{major.name}"
            @game.transfer_posessions(minor, major)
            major.ipoed = true
            major.floated = true
            @game.remove_home_icon(major, minor.coordinates)

            @game.log << "#{major.name} share price set to #{@game.format_currency(minor.share_price.price)}"
            @game.stock_market.set_par(major, minor.share_price)

            @game.share_pool.transfer_shares(Engine::ShareBundle.new(major.shares.first(1)), current_entity)

            city = minor.tokens[0].city
            city.delete_token!(minor.tokens[0])
            city.place_token(major, major.find_token_by_type, check_tokenable: false)
            @game.log << "#{major.name} replaces the #{minor.name} token in #{city.hex.name}"

            @game.close_minor(minor)
            track_action(action, major)
          end
        end
      end
    end
  end
end
