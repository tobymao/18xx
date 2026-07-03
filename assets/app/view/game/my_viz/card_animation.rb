# frozen_string_literal: true

module Lib
  module CardAnimation
    def self.fly(_event, dest_selector)
      # FIRST: Handle DOM capture and cloning natively to avoid Opal bridge errors
      capture_successful = false
      %x{
        var card = null, startX, startY, width, height, clone;
        try {
          if (typeof #{event_or_source} === 'string') {
            var parts = #{event_or_source}.split(' ');
            var id = parts[0].replace('#', '');
            var parent = window.document.getElementById(id);
            if (parent) {
              card = parent.querySelector(parts[1] || '.card');
            }
          } else {
            var nativeEvent = #{event_or_source}.$to_n ? #{event_or_source}.$to_n() : #{event_or_source};
            var target = nativeEvent.target || nativeEvent;
            card = target.closest('.card') || target;
          }
        } catch(e) {
          console.warn("Animation failed to locate source", e);
        }

        if (card) {
          #{capture_successful = true};
          var rect = card.getBoundingClientRect();
          startX = rect.left;
          startY = rect.top;
          width = rect.width;
          height = rect.height;

          clone = card.cloneNode(true);
          clone.style.position = 'fixed';
          clone.style.left = startX + 'px';
          clone.style.top = startY + 'px';
          clone.style.width = width + 'px';
          clone.style.height = height + 'px';
          clone.style.zIndex = '9999';
          clone.style.margin = '0';
          clone.style.transition = 'transform 0.5s ease-in-out, opacity 0.5s ease-in-out';
          clone.style.pointerEvents = 'none';

          window.document.body.appendChild(clone);
        }
      }

      # Execute the game action to update state and trigger Snabberb VDOM patch unconditionally
      yield if block_given?

      return unless capture_successful

      # LAST & PLAY: Handle the FLIP destination logic natively
      %x{
        window.requestAnimationFrame(function() {
          window.requestAnimationFrame(function() {
            var dest = window.document.querySelector(#{dest_selector});
            if (dest) {
              var destRect = dest.getBoundingClientRect();
              var destX = destRect.left + (destRect.width / 2) - (width / 2);
              var destY = destRect.top + (destRect.height / 2) - (height / 2);

              var deltaX = destX - startX;
              var deltaY = destY - startY;

              clone.style.transform = 'translate(' + deltaX + 'px, ' + deltaY + 'px)';
            } else {
              clone.style.transform = 'translate(0px, -50px) scale(1.1)';
              clone.style.opacity = '0';
            }

            setTimeout(function() {
              if (clone.parentNode) {
                clone.parentNode.removeChild(clone);
              }
            }, 550);
          });
        });
      }
    end
  end
end
