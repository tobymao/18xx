# frozen_string_literal: true

module Title
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def title
      parts = name.split('::')
      last = parts.last
      second_last = parts[-2]
      (last == 'Game' || last == 'Meta' ? second_last : last).slice(1..-1)
    end
  end
end
