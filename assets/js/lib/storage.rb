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
      self[key]
    end

    def self.delete(key)
      `localStorage.removeItem(#{key})`
    end

    def self.all_keys
      `Object.keys(localStorage)`
    end
  end
end
