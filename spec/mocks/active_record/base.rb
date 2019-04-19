# frozen_string_literal: true

module ActiveRecord
  class Base
    class << self
      attr_reader :before_save_callback, :after_commit_callback

      def before_save(symbol)
        @before_save_callback = symbol
      end

      def after_commit(symbol)
        @after_commit_callback = symbol
      end

      def table_name
        'lovely_records'
      end
    end

    def attributes
      {
        'hello' => 'world',
        'world' => 'hello'
      }
    end

    def attribute_was(attribute)
      "old #{attributes[attribute]}"
    end

    def transaction_include_any_action?(actions)
      return true if actions.include?(:create)
    end

    ##
    # Test method to invoke callbacks in a specific order

    def _invoke_persistent_callbacks
      method(self.class.before_save_callback).call
      method(self.class.after_commit_callback).call
    end
  end
end
