# frozen_string_literal: true

module Lib
  module CardAnimation
    def self.fly(event_or_source, dest_selector, &block)
      # FIRST: Handle DOM capture and cloning natively to avoid Opal bridge errors
      %x{
        var card = null, startX, startY, width, height, clone;
        try {

        if (typeof #{event_or_source} === 'string') {
            card = window.document.querySelector(#{event_or_source});
            if (!card) {
              var parts = #{event_or_source}.split(' ');
              var id = parts[0].replace('#', '');
              var parent = window.document.getElementById(id);
              if (parent) {
                card = parent.querySelector('.game-card') || parent.querySelector('.card') || parent;
              }
            }
          } else if (#{event_or_source}) {
            var nativeEvent = #{event_or_source}.$to_n ? #{event_or_source}.$to_n() : #{event_or_source};
            var target = nativeEvent.target || nativeEvent;
            card = target.closest('.game-card') || target.closest('.card') || target;
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

          // Strip out absolute choice dropdown containers from the moving clone
          var nestedDivs = clone.getElementsByTagName('div');
          for (var i = 0; i < nestedDivs.length; i++) {
            if (nestedDivs[i].style.position === 'absolute') {
              nestedDivs[i].parentNode.removeChild(nestedDivs[i]);
            }
          }


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
          // Hide the original element template while the flight clone is active
          card.style.visibility = 'hidden';
        }
      }

      unless capture_successful
        yield if block
        return
      end
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
                if (card) {
                card.style.visibility = 'visible';
              }
              if (js_block) {
                js_block.$call();
              }
            }, 500);
          });
        });
      }
    end
  end
end
