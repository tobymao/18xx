# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1841
      module Step
        module CorpStart
          def post_share_pass_step!
            return unless @round.corp_started

            corp = @round.corp_started
            if @game.historical?(corp) && corp.name != 'SFMA'
              @game.place_home_token(corp)
              post_token_lay_step!
            else
              @log << "#{corp.name} must choose city for home token"
              @round.pending_tokens << {
                entity: corp,
                hexes: @game.home_token_locations(corp),
                token: corp.tokens[0],
              }
              if @game.major?(corp)
                # major corps may lay two tokens
                @round.pending_tokens << {
                  entity: corp,
                  hexes: [],
                  token: corp.tokens[1],
                }
              end
              @round.clear_cache!
            end
          end

          def post_token_lay_step!
            return unless @round.corp_started

            corp = @round.corp_started
            if @game.major?(corp)
              min = 2
              max = 5
            else
              min = 1
              max = 2
            end
            @log << "#{corp.name} must buy between #{min} and #{max} tokens"
            price = @game.token_price(corp)
            @log << if @game.historical?(corp)
                      "Each token costs #{@game.format_currency(price)}"
                    else
                      "Based on token placement, each token costs #{@game.format_currency(price)}"
                    end
            @round.buy_tokens << {
              entity: corp,
              price: price,
              min: min,
              max: max,
            }
          end
        end
      end
    end
  end
end
