# frozen_string_literal: true

if RUBY_ENGINE == 'opal'
  require_tree 'automation'
else
  require 'require_all'
  require_rel 'automation'
end

module Engine
  module Automation
    AUTOMATIONS = Automation.constants.map do |c|
      klass = Automation.const_get(c)
      next if !klass.is_a?(Class) || klass == Automation::Base

      klass
    end.compact

    def self.available(game)
      AUTOMATIONS.select do |auto|
        auto.available(game)
      end
    end
  end
end
