# frozen_string_literal: true

module ActiveRecord
  module Persistence
    def destroy!
      destroy
    end

    def destroy
      destroy_row
    end

    private

    def relation_for_destroy
      # Left blank
    end

    def destroy_row
      # Left blank
    end
  end
end
