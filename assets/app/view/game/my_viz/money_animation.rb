# frozen_string_literal: true

module Lib
  module MoneyAnimation
    # Snabbdom update hook to trigger counting and bubble animations on text change
    def self.hook
      {
        update: lambda do |old_vnode, vnode|
          %x{
            var oldV = #{old_vnode};
            var newV = #{vnode};

            // Safely extract text whether it is a direct property or nested child
            var getText = function(vn) {
              if (vn.text) return String(vn.text);
              if (vn.children && vn.children.length > 0) {
                if (typeof vn.children[0] === 'string') return vn.children[0];
                if (vn.children[0].text) return String(vn.children[0].text);
              }
              return '';
            };

            var oldText = getText(oldV);
            var newText = getText(newV);

            if (oldText && newText && oldText !== newText) {
              var oldVal = parseInt(oldText.replace(/[^0-9-]/g, ''), 10);
              var newVal = parseInt(newText.replace(/[^0-9-]/g, ''), 10);

              if (!isNaN(oldVal) && !isNaN(newVal) && oldVal !== newVal) {
                var target = newV.elm;
                var delta = newVal - oldVal;
                var color = delta > 0 ? '#228B22' : '#DC143C'; // Forest Green : Crimson
                var duration = 500;
                var start = performance.now();

                // 1. Spawn floating bubble
                var rect = target.getBoundingClientRect();
                var bubble = document.createElement('div');
                bubble.innerText = (delta > 0 ? '+' : '') + delta;
                bubble.style.position = 'fixed';
                bubble.style.left = (rect.left + rect.width / 2) + 'px';
                bubble.style.top = rect.top + 'px';
                bubble.style.transform = 'translate(-50%, -50%)';
                bubble.style.backgroundColor = color;
                bubble.style.color = 'white';
                bubble.style.padding = '4px 8px';
                bubble.style.borderRadius = '6px';
                bubble.style.fontWeight = 'bold';
                bubble.style.zIndex = '10000';
                bubble.style.pointerEvents = 'none';
                bubble.style.transition = 'transform ' + duration + 'ms ease-out, opacity ' + duration + 'ms ease-out';

                document.body.appendChild(bubble);

                window.requestAnimationFrame(function() {
                  bubble.style.transform = 'translate(-50%, -200%)';
                  bubble.style.opacity = '0';
                });

                setTimeout(function() {
                  if (bubble.parentNode) bubble.parentNode.removeChild(bubble);
                }, duration);

                // 2. Count animation
                var origColor = target.style.color || '';
                target.style.color = color;

                function animateCount(time) {
                  var elapsed = time - start;
                  var progress = Math.min(elapsed / duration, 1);
                  var current = Math.round(oldVal + (delta * progress));

                  // Restore visual styling that Snabberb stripped during parsing
                  target.innerText = current;

                  if (progress < 1) {
                    window.requestAnimationFrame(animateCount);
                  } else {
                    target.style.color = origColor;
                    target.innerText = newText;
                  }
                }
                window.requestAnimationFrame(animateCount);
              }
            }
          }
        end,
      }
    end
  end
end
