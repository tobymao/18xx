# frozen_string_literal: true

module Lib
  module RowAnimation
    # Create a global cache to store row coordinates before the DOM patches
    %x(
      window.RowAnimCache = window.RowAnimCache || {};
    )

    def self.hook(id)
      {
        prepatch: %x{
          function(oldVnode, vnode) {
            var elm = oldVnode.elm;
            if (elm) {
              window.RowAnimCache[#{id}] = elm.getBoundingClientRect();
            }
          }
        },
        postpatch: %x{
          function(oldVnode, vnode) {
            var elm = vnode.elm;
            var oldRect = window.RowAnimCache[#{id}];

            if (!elm || !oldRect) return;

            delete window.RowAnimCache[#{id}];

            // Snabbdom's postpatch fires *before* the parent tbody physically
            // moves the row with insertBefore. We use a microtask to wait for
            // the DOM move to finish, but execute before the browser paints.
            Promise.resolve().then(function() {
              var newRect = elm.getBoundingClientRect();
              var deltaY = newRect.top - oldRect.top;

              // Only animate if it actually moved vertically
              if (Math.abs(deltaY) > 1.0) {

                // 1. Freeze widths of the original cells
                var cells = elm.children;
                var widths = [];
                for(var i = 0; i < cells.length; i++) {
                  widths.push(cells[i].getBoundingClientRect().width);
                }

                // 2. Create the "GlassPane" floating overlay table
                var overlay = window.document.createElement('table');
                overlay.style.position = 'fixed';
                overlay.style.top = oldRect.top + 'px';
                overlay.style.left = oldRect.left + 'px';
                overlay.style.zIndex = '9999';
                overlay.style.borderCollapse = 'collapse';
                overlay.style.pointerEvents = 'none';

                // 3. Clone the row into the overlay
                var tbody = window.document.createElement('tbody');
                var clone = elm.cloneNode(true);

                var cloneCells = clone.children;
                for(var i = 0; i < cloneCells.length; i++) {
                  cloneCells[i].style.width = widths[i] + 'px';
                  cloneCells[i].style.boxSizing = 'border-box';
                }

                clone.style.backgroundColor = window.getComputedStyle(elm).backgroundColor || '#ffffff';
                clone.style.boxShadow = '0 8px 16px rgba(0,0,0,0.3)';
                clone.style.outline = '2px solid #2563eb';

                tbody.appendChild(clone);
                overlay.appendChild(tbody);
                window.document.body.appendChild(overlay);

                // 4. Hide the real row while the clone flies
                elm.style.opacity = '0';

                // 5. Double rAF ensures the browser paints the starting position before transitioning
                window.requestAnimationFrame(function() {
                  window.requestAnimationFrame(function() {
                    overlay.style.transition = 'transform 0.5s cubic-bezier(0.25, 0.8, 0.25, 1)';
                    overlay.style.transform = 'translateY(' + deltaY + 'px)';
                  });
                });

                // 6. Cleanup
                setTimeout(function() {
                  if (overlay.parentNode) overlay.parentNode.removeChild(overlay);
                  elm.style.transition = 'opacity 0.1s ease-in';
                  elm.style.opacity = '1';

                  setTimeout(function() { elm.style.transition = ''; }, 100);
                }, 500);
              }
            });
          }
        },
      }
    end
  end
end
