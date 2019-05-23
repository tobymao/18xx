# frozen_string_literal: true

class Component
  attr_accessor :node, :root

  def render; end

  def h(tag, props = {}, children = nil)
    props_is_hash = props.is_a?(Hash)
    children = props if !children && !props_is_hash
    props = {} unless props_is_hash
    `snabbdom.h(#{tag}, #{Native.convert(props)}, #{children})`
  end

  def c(component, props = {})
    component = component.new(**props) if component.is_a?(Class)
    component.root = @root
    component.render
  end

  def attach(container)
    @root = self
    @node = `document.getElementById(#{container})`
    update
  end

  def update
    `window.requestAnimationFrame(function(timestamp) {#{update!}})`
  end

  def root?
    self == @root
  end

  def state_key
    raise NotImplementedError unless root?
  end

  def set_state(key, value, scope = nil)
    @root._state[scope || state_key][key] = value
    update
  end

  def state(key, scope = nil)
    @root._state[scope || state_key][key]
  end

  def update!
    @@patcher ||= %x{snabbdom.init([
      snabbdom_style.default,
      snabbdom_props.default,
      snabbdom_eventlisteners.default,
    ])}
    node = @root.render
    @@patcher.call(@root.node, node)
    @root.node = node
  end

  def _state
    raise 'Must be root' unless root?

    @state ||= Hash.new { |h, k| h[k] = {} }
  end
end
