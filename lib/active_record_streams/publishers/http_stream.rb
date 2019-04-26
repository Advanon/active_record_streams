# frozen_string_literal: true

require 'net/http'

module ActiveRecordStreams
  module Publishers
    class HttpStream
      ANY_TABLE = '*'
      SUCCESSFUL_CODE_REGEX = /\A2\d{2}\z/.freeze
      DEFAULT_CONTENT_TYPE = 'application/json'

      ##
      # @param [String] url
      # @param [Hash] headers
      # @param [String] table_name
      # @param [Enumerable<String>] ignored_tables
      # @param [Proc] error_handler

      def initialize(
        url:,
        headers: {},
        table_name: ANY_TABLE,
        ignored_tables: [],
        error_handler: nil
      )
        @url = url
        @headers = headers
        @table_name = table_name
        @ignored_tables = ignored_tables
        @error_handler = error_handler
      end

      def publish(table_name, message)
        return unless (any_table? && allowed_table?(table_name)) ||
                      table_name == @table_name

        request.body = message.json
        response = http.request(request)
        assert_response_code(response)
      rescue StandardError => e
        raise e unless @error_handler.is_a?(Proc)

        @error_handler.call(self, table_name, message, e)
      end

      private

      def any_table?
        @table_name == ANY_TABLE
      end

      def allowed_table?(table_name)
        !@ignored_tables.include?(table_name)
      end

      def request
        @request ||= Net::HTTP::Post.new(uri.request_uri, headers)
      end

      def http
        @http ||= Net::HTTP.new(uri.host, uri.port)
      end

      def uri
        @uri ||= URI.parse(@url)
      end

      def headers
        { 'Content-Type': DEFAULT_CONTENT_TYPE }.merge(@headers)
      end

      def assert_response_code(response)
        return if response.code.to_s.match(SUCCESSFUL_CODE_REGEX)

        raise StandardError, response.body
      end
    end
  end
end
