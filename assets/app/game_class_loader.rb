# frozen_string_literal: true

module GameClassLoader
  def self.included(base)
    base.needs :game_classes_loaded, default: {}, store: true if base.respond_to?(:needs)
  end

  # Ensures the game class for the given title is loaded. If it is not present,
  # the bundled js for that game is requested by adding a <script> tag to the
  # page; this happens asynchronously, and when the script is loaded, the given
  # callback is executed, so the passed callback can be used to rerun the
  # function that called load_game_class.
  #
  # Returns the Game class if it is already loaded, otherwise returns nil
  def load_game_class(title, callback = nil)
    return unless title
    return @game_classes_loaded[title] if @game_classes_loaded[title]

    game_meta = Engine.meta_by_title(title)
    require_tree "engine/game/#{game_meta.fs_name}"

    if (dep_title = game_meta::DEPENDS_ON)
      load_game_class(dep_title, -> { load_game_class(title, callback) })
      return unless @game_classes_loaded[dep_title]
    end

    if (game_class = Engine.game_by_title(title))
      @game_classes_loaded[title] = game_class
      store(:game_classes_loaded, @game_classes_loaded, skip: true)
      return game_class
    end

    onload = lambda do
      require_tree "engine/game/#{game_meta.fs_name}"

      if Engine.game_by_title(title)
        @game_classes_loaded[title] = game_class
        store(:game_classes_loaded, @game_classes_loaded, skip: false)
        callback&.call
      end
    end

    src = "/assets/#{game_meta.fs_name}.js"

    %x{var script = document.createElement('script')
     script.type = 'text/javascript'
     script.src = #{src}
     script.onload = #{onload}
     document.body.appendChild(script)}

    nil
  end
end
