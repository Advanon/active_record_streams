# frozen_string_literal: true

require 'net/http'

module ActiveRecordStreams
  module Publishers
    class HttpStream
      ANY_TABLE = '*'
      DEFAULT_CONTENT_TYPE = 'application/json'

      def initialize(
        url:,
        headers: {},
        table_name: ANY_TABLE,
        ignored_tables: []
      )
        @url = url
        @headers = headers
        @table_name = table_name
        @ignored_tables = ignored_tables
      end

      def publish(table_name, message)
        return unless (any_table? && allowed_table?(table_name)) ||
                      table_name == @table_name

        request.body = message.json
        http.request(request)
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
    end
  end
end
