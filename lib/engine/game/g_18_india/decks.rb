# frozen_string_literal: true

module Engine
  module Game
    module G18India
      module Decks
=begin
        def convert_shares_to_cards(shares)
          new_deck = []
          shares.each do |share|
            card = Company.new(
              sym: share.id,
              name: share.corporation.name,
              value: share.price,
              desc: "Certificate for 10\% of #{share.corporation.full_name}",
              type: :share,
              color: share.corporation.color,
              text_color: share.corporation.text_color
            )
            new_deck << card
          end
          new_deck
        end
=end
      end
    end
  end
end