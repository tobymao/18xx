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

    def self.notify(message, send_focused)
      %x{
        let is_hidden = document.hidden;
        let in_focus = document.hasFocus();

        let send_notification = (msg) => {
          if ("Notification" in window) {
            if (Notification.permission === "granted") {
              new Notification(msg);
            }
            else if (Notification.permission !== "denied") {
              Notification.requestPermission().then(function (permission) {
                if (permission === "granted") {
                  new Notification(msg);
                }
              });
            }
          }
        }
        // Dont send the notification unless the window is active and 
        // user has the notification setting on
        if (!#{send_focused} && !is_hidden && !in_focus) {

        } else {
          send_notification(#{message})
        }
      }
    end
  end
end
