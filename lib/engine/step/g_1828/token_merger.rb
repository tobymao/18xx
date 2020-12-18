# frozen_string_literal: true

module Engine
  module Step
    module G1817
      class TokenMerger
        attr_reader :hexes_to_resolve

        def initialize(blocking_corporation)
          @blocking_corporation = blocking_corporation
          @hexes_to_resolve = []
        end

        def merge(first, second)
          used, unused = second.tokens.partition(&:used)

          used.concat(first.select(&used)).group_by { |t| t.city.hex }.each do |hex, tokens|
            if tokens.one?
              next if tokens.first.corporation == first

              replace_token(first, tokens.first)
            elsif tokens[0].city == tokens[1].city
              replace_token(@blocking_corporation, tokens.find { |t| t.corporation == second })
            else
              replace_token(first, tokens.find { |t| t.corporation == second })
              @hexes_to_resolve << hex
            end
          end

          unused.each { |t| first.tokens << Token.new(first, price: t.price) }

          first.tokens
        end

        def replace_token(corporation, token)
          new_token = Token.new(corporation, price: token.price)
          corporation.tokens << new_token
          token.swap!(new_token)
        end
      end
    end
  end
end
