# frozen_string_literal: true

module ActiveRecord
  Relation.prepend(
    Module.new do
      def self.prepended(object)
        object.class_eval do
          alias_method :delete_all_without_callbacks, :delete_all
          alias_method :delete_all, :delete_all_with_callbacks
        end
      end

      def update_all(updates)
        find_each.inject(0) do |counter, record|
          record.assign_attributes(updates)
          counter += 1 if record.save(validate: false)

          counter
        end
      end

      ##
      # Override `delete_all` method to serve callbacks.
      # Change to this method also affects `delete` method.

      # rubocop:disable Metrics/MethodLength
      def delete_all_with_callbacks(conditions = nil)
        return where(conditions).delete_all if conditions

        find_each.inject(0) do |count, record|
          wrap_delete_with_callbacks(record) do
            deleted_count = where(
              primary_key => record.attributes[primary_key]
            ).delete_all_without_callbacks

            if deleted_count == 1
              record.instance_variable_set('@destroyed', true)
              count += 1
            end

            count
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      def wrap_delete_with_callbacks(record)
        record.run_callbacks(:commit) do
          record.run_callbacks(:destroy) do
            ActiveRecord::Base.transaction do
              yield
            end
          end
        end
      end
    end
  )
end
