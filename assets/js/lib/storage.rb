# frozen_string_literal: true

require 'json'

module Lib
  module Storage
    def self.[](key)
      value = `localStorage.getItem(#{key})`
      JSON.parse(value) if value
    end

    def self.[]=(key, value)
      `localStorage.setItem(#{key}, #{JSON.dump(value)})`
    end
  end
end
