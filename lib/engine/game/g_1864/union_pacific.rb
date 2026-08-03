# frozen_string_literal: true

module Engine
  module Game
    module G1864
      module UnionPacific
        # Eight consist decks, one card per phase. At setup one card is dealt
        # from each phase's deck; it is revealed at the start of that phase and
        # replaces the UP's previous consist.
        #
        # Transcribed from cards/StdEd-SheetE-1.pdf and StdEd-SheetF-1.pdf. The
        # printed cards are drawn as fanned, overlapping images, so a two-train
        # consist shows one full card plus a partly hidden one behind it.
        CONSIST_DECKS = {
          'E1' => { '4' => %w[4],   '5' => %w[4 5],   '6' => %w[5 6], '7' => %w[6 7], '8' => %w[7 8] },
          'E2' => { '4' => %w[3 3], '5' => %w[3 3 4], '6' => %w[4],   '7' => %w[4 6], '8' => %w[6 8] },
          'E3' => { '4' => %w[4 4], '5' => %w[5],     '6' => %w[4 4], '7' => %w[6 6], '8' => %w[8 2+2] },
          'E4' => { '4' => %w[3],   '5' => %w[3 3],   '6' => %w[5],   '7' => %w[6],   '8' => %w[7] },
          'F1' => { '4' => %w[3 4], '5' => %w[4 4],   '6' => %w[4 5], '7' => %w[4 6], '8' => %w[7 2+2] },
          'F2' => { '4' => %w[3 4], '5' => %w[3 4],   '6' => %w[4 6], '7' => %w[5 7], '8' => %w[5+5E] },
          'F3' => { '4' => %w[3 4], '5' => %w[4],     '6' => %w[5 5], '7' => %w[7],   '8' => %w[5 7] },
          'F4' => { '4' => %w[3],   '5' => %w[3 5],   '6' => %w[6],   '7' => %w[5 6], '8' => %w[8] },
        }.freeze

        PHASES_WITH_CONSISTS = %w[4 5 6 7 8].freeze
      end
    end
  end
end
