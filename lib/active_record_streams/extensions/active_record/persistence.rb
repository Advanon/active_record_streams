# frozen_string_literal: true

module ActiveRecord
  Persistence.prepend(
    Module.new do
      private

      ##
      # destroy/destroy! methods should still call `delete_all` without
      # callbacks, since they already serve their own callbacks

      def destroy_row
        relation_for_destroy.delete_all_without_callbacks
      end
    end
  )
end
