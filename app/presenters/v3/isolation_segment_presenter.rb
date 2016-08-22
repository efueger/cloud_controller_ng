require 'presenters/v3/base_presenter'

module VCAP::CloudController
  module Presenters
    module V3
      class IsolationSegmentPresenter < BasePresenter
        def to_hash
          {
            guid:       isolation_segment.guid,
            name:       isolation_segment.name,
            created_at: isolation_segment.created_at,
            updated_at: isolation_segment.updated_at,
            links:      build_links
          }
        end

        private

        def isolation_segment
          @resource
        end

        def build_links
          links = {
            self:      { href: "/v3/isolation_segments/#{isolation_segment.guid}" },
          }
        end
      end
    end
  end
end
