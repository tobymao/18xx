# frozen_string_literal: true

module Engine
  module Game
    module G1868WY
      module OilCompanies
        OIL_COMPANY_NAMES = [
          'Standard Oil',
          'Empire State Oil',
          'Consolidated Royalty Oil Company',
          'Argo Oil Corporation',
          'Petroleum Maatschappij Salt Creek',
        ].freeze

        def event_oil_companies_available!
          @log << '-- Event: Oil Companies now available --'
          @oil_companies.each(&:float!)
        end

        def init_oil_companies
          @players.map.with_index do |player, index|
            sym = "Oil-#{self.class::LETTERS[index]}"
            oil_company = Engine::Minor.new(
              type: :oil,
              sym: sym,
              name: self.class::OIL_COMPANY_NAMES[index],
              logo: "1868_wy/#{sym}",
              tokens: [],
              color: :black,
              abilities: [{ type: 'no_buy', owner_type: 'player' }],
            )
            3.times { new_oil_token!(oil_company) }
            oil_company.owner = player

            def oil_company.cash
              player.cash
            end

            oil_company
          end
        end

        def new_oil_token!(oil_company)
          oil_company.tokens << Token.new(
            oil_company,
            price: 0,
            type: :development,
          )
        end

        def remove_oil_development_token!(token)
          entity = token.corporation
          player = entity.player
          hex = token.hex
          token.destroy!
          decrement_development_token_count(hex)
          handle_bust!
          new_oil_token!(entity)
          @log << "#{player.name} removes a Development Token from #{hex.id}"
          @teapot_dome_hex_bonus = nil if entity == teapot_dome_oil
        end
      end
    end
  end
end
