# frozen_string_literal: true

module Lib
  module CardAnimation
    def self.fly(event, dest_selector)
      # FIRST: Handle DOM capture and cloning natively to avoid Opal bridge errors
      %x{
        var nativeEvent = #{event}.$to_n ? #{event}.$to_n() : #{event};
        var target = nativeEvent.target || nativeEvent;
        var card = target.closest('.card') || target;

        var rect = card.getBoundingClientRect();
        var startX = rect.left;
        var startY = rect.top;
        var width = rect.width;
        var height = rect.height;

        var clone = card.cloneNode(true);
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

      # Execute the game action to update state and trigger Snabberb VDOM patch
      yield

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
