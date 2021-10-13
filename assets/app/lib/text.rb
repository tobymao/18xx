# frozen_string_literal: true

module Lib
  module Text
    def ordinal(number)
      case number % 10
      when 1 then "#{number}st"
      when 2 then "#{number}nd"
      when 3 then "#{number}rd"
      else "#{number}th"
      end
    end
  end
end
