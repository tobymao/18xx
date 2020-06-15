# frozen_string_literal: true

module Engine
  module Helper
    module Type
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def type(type)
          type.split('_').map(&:capitalize).join
        end
      end

      def type
        type_s(self)
      end

      def type_s(obj)
        obj.class.name.split('::').last.gsub(/(.)([A-Z])/, '\1_\2').downcase
      end
    end
  end
end
