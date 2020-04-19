# frozen_string_literal: true

module View
  class About < Snabberb::Component
    def render
      h(:div,
        [h(:p, <<END
18xx.games is created and maintained by Toby Mao. It is an open source project, and you can find the
code at https://github.com/tobymao/18xx
END
        ),
        h(:p, "The 1889 game is used with kind permission from Josh Starr at Grand Trunk Games.")
      ])
    end
  end
end
