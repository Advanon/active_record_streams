# frozen_string_literal: true

module ActiveRecordStreams
  class Credentials
    def build_credentials
      region_config
        .merge(access_key_id_config)
        .merge(secret_access_key_config)
    end

    private

    def region_config
      return {} unless ActiveRecordStreams.config.aws_region

      { region: ActiveRecordStreams.config.aws_region }
    end

    def access_key_id_config
      return {} unless ActiveRecordStreams.config.aws_access_key_id

      { access_key_id: ActiveRecordStreams.config.aws_access_key_id }
    end

    def secret_access_key_config
      return {} unless ActiveRecordStreams.config.aws_secret_access_key

      { secret_access_key: ActiveRecordStreams.config.aws_secret_access_key }
    end
  end
end
