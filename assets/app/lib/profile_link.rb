# frozen_string_literal: true

module Lib
  module ProfileLink
    def profile_link(name, display_name: nil)
      props = {
        attrs: {
          href: "/profile/#{name}",
        },
        style: {
          'text-decoration' => 'none',
        },
      }

      display_name ||= name
      h(:a, props, display_name)
    end
  end
end
