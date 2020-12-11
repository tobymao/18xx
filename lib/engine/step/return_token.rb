# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class ReturnToken < Base
      ACTIONS = %w[remove_token].freeze

      def actions(entity)
        return [] unless ability(entity)

        ACTIONS
      end

      def blocks?
        false
      end

      def process_remove_token(action)
        company = action.entity
        corporation = action.entity.owner

        @game.game_error("#{company.name} must be owned by a corporation") unless corporation.corporation?

        last_used_token = available_tokens(corporation).first

        @game.game_error("#{corporation.name} cannot return its only placed token") unless last_used_token

        selected_city = action.city
        hex = selected_city.hex

        city_string = hex.tile.cities.size > 1 ? " city #{selected_city.index}" : ''
        unless available_city(corporation, selected_city)
          @game.game_error("Cannot return token from #{hex.name}#{city_string} to #{corporation.name}")
        end

        last_city = last_used_token.city
        return_ability = ability(company)
        selected_token = selected_city.tokens[action.slot]

        selected_token.remove!
        selected_city&.remove_reservation!(corporation)
        if selected_token != last_used_token
          last_used_token.remove!
          last_city.place_token(corporation, selected_token)
        end

        @game.bank.spend(last_used_token.price, corporation) if return_ability.reimburse

        return_ability.use!

        @log <<
          "#{corporation.name} returns the token from #{hex.name}#{city_string} using #{company.name}"\
          "#{(return_ability.reimburse ? " and is reimbursed #{@game.format_currency(last_used_token.price)}" : '')}"
      end

      def can_replace_token?(company, token)
        corporation = company.owner
        return unless corporation.corporation?

        available_tokens(corporation).any? && corporation.tokens.find { |t| t.city == token.city }
      end

      def available_hex(company, hex)
        corporation = company.owner
        return unless corporation.corporation?

        corporation.tokens.map { |t| t.city&.hex }.include?(hex)
      end

      def available_city(corporation, city)
        return unless corporation.corporation?

        corporation.tokens.map(&:city).include?(city)
      end

      def available_tokens(corporation)
        return [] unless corporation.corporation?

        used_tokens = corporation.tokens.select(&:used)

        # You cannot return your last token
        return [] unless used_tokens.size > 1

        [used_tokens.last]
      end

      def ability(entity)
        return unless entity&.company?

        entity.abilities(:return_token)
      end
    end
  end
end
