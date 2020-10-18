# frozen_string_literal: true

module Lib
  module Notification
    def self.ask_permission
      %x{
        if ("Notification" in window) {
          if (Notification.permission === "default") {
            Notification.requestPermission().then(function(permission) {
            })
          }
        }
      }
    end
  end
end
