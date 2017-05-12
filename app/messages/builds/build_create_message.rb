require 'messages/base_message'
require 'messages/validators'
require 'messages/lifecycles/buildpack_lifecycle_data_message'

module VCAP::CloudController
  class BuildCreateMessage < BaseMessage
    ALLOWED_KEYS = [:memory_in_mb, :disk_in_mb, :lifecycle, :package].freeze

    attr_accessor(*ALLOWED_KEYS)
    def self.create_from_http_request(body)
      BuildCreateMessage.new(body.deep_symbolize_keys)
    end

    def self.lifecycle_requested?
      @lifecycle_requested ||= proc { |a| a.requested?(:lifecycle) }
    end

    validates_with NoAdditionalKeysValidator
    validates_with LifecycleValidator, if: lifecycle_requested?

    validates :package_guid,
      presence: true,
      allow_nil: false,
      guid: true

    validates :memory_in_mb, numericality: { only_integer: true }, allow_nil: true
    validates :disk_in_mb, numericality: { only_integer: true }, allow_nil: true

    validates :lifecycle_type,
      string: true,
      allow_nil: false,
      if: lifecycle_requested?

    validates :lifecycle_data,
      hash: true,
      allow_nil: false,
      if: lifecycle_requested?

    def package_guid
      HashUtils.dig(package, :guid)
    end

    def buildpack_data
      @buildpack_data ||= VCAP::CloudController::BuildpackLifecycleDataMessage.create_from_http_request(lifecycle_data)
    end

    def lifecycle_data
      HashUtils.dig(lifecycle, :data)
    end

    def lifecycle_type
      HashUtils.dig(lifecycle, :type)
    end

    def environment_variables
      nil
    end

    private

    def allowed_keys
      ALLOWED_KEYS
    end
  end
end
