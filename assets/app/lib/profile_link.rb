# frozen_string_literal: true

module Lib
  module ProfileLink
    def profile_link(id, name)
      # Negative ID values are used for dummy players, these do not have
      # profile pages.
      return h(:span, name) if id.to_i.negative?

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
