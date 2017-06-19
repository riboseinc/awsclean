# (c) 2017 Ribose Inc.
#

module Awsclean
  class AwsCommand

    class << self

      def supported_regions
        Aws.partition('aws').regions
          .select { |region| region.services.include?(self.const_get(:SERVICE_IDENTIFIER)) }
          .map(&:name)
      end

      def filter_regions(regions)
        supported = supported_regions

        if regions.first == "all"
          supported_regions
        else
          # TODO: throw something if region not available
          regions.select { |r| supported.include? r }
        end
      end

    end

  end
end

