# frozen_string_literal: true

module Lib
  module ProfileLink
    def profile_link(id, name)
      props = {
        attrs: {
          href: "/profile/#{id}",
        },
        style: {
          'text-decoration' => 'none',
        },
      }

      h(:a, props, name)
    end
  end
end
