require 'aws-sdk'

module Aws
  module EC2
    module Types
      class Image

        attr_accessor :in_use, :elegible_for_cleanup

        def days_since_creation
          (DateTime.now - DateTime.parse(creation_date)).to_i
        end

        def stale?(max_age)
          days_since_creation >= max_age
        end
      end
    end
  end

  module ECR
    module Types
      class ImageDetail

        attr_accessor :region, :in_use, :elegible_for_cleanup

        def days_since_creation
          (DateTime.now - image_pushed_at.to_datetime).to_i
        end

        def stale?(max_age)
          days_since_creation >= max_age
        end

        def image_uris
          (image_tags || []).map { |tag| repository_uri << ':' << tag }
        end

        def repository_uri
          sprintf('%i.dkr.ecr.%s.amazonaws.com/%s',
            registry_id, region, repository_name,
          )
        end
      end
    end
  end
end
