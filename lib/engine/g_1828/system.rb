# frozen_string_literal: true

require_relative '../corporation'
require_relative 'shell'

module Engine
  module G1828
    class System < Engine::Corporation
      attr_reader :shells, :corporations

      def initialize(sym:, name:, **opts)
        opts[:always_market_price] = true
        opts[:float_percent] = 50
        super(sym: sym, name: name, **opts)

        @game = opts[:game]
        @corporations = opts[:corporations]
        @name = @corporations.first.name
        @shells = []

        @corporations.each do |corporation|
          corporation.spend(corporation.cash, self) if corporation.cash.positive?
          create_tokens(corporation)
          transfer_companies(corporation)
          transfer_abilities(corporation)

          shell = Engine::G1828::Shell.new(corporation.name, self)
          @shells << shell
          transfer_trains(corporation, shell)
        end

        max_price = tokens.max(&:price).price + 1
        tokens.sort_by! { |t| (t.used ? -max_price : max_price) + t.price }
      end

      def system?
        true
      end

      def remove_train(train)
        super
        @shells.each { |shell| shell.trains.delete(train) }
      end

      private

      def create_tokens(corporation)
        used, unused = corporation.tokens.partition(&:used)
        used.each { |t| replace_token(t) }
        unused.sort_by(&:price).each { |t| tokens << Engine::Token.new(self, price: t.price) }

        corporation.tokens.clear
      end

      def replace_token(token)
        new_token = Engine::Token.new(self, price: token.price)
        tokens << new_token
        token.swap!(new_token, check_tokenable: false)
      end

      def transfer_trains(corporation, shell)
        corporation.trains.dup.each do |train|
          @game.buy_train(self, train, :free)
          shell.trains << train
        end
      end

      def transfer_companies(corporation)
        corporation.companies.each do |company|
          company.owner = self
          companies << company
        end
        corporation.companies.clear
      end

      def transfer_abilities(corporation)
        corporation.all_abilities.dup.each do |ability|
          add_ability(ability)
          corporation.remove_ability(ability)
        end
      end
    end
  end
end
