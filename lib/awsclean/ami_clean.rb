# (c) 2017 Ribose Inc.
#

module Awsclean
  class AmiClean < AwsCommand

    SERVICE_IDENTIFIER = "EC2"

    IMAGE_LIST_HEADER = ['REGION', 'IN USE?', 'NAME', 'AMI ID', 'CREATED', 'ELEGIBLE FOR CLEANUP?']
    IMAGE_LIST_FORMAT = '%-10s%-10s%-24s%-24s%-42s%-6s'

    def self.run options
      regions = filter_regions(options[:r])

      if regions.empty?
        puts "Please specify region with -r [regions, e.g., 'all' or 'us-west-1,us-east-1']"
        exit 1
      end

      regions.each do |region|
        puts "[clean_amis] checking region: #{region}"

        ec2 = Aws::EC2::Client.new(region: region)

        # Get a list of all AMIs in use.
        #
        res = ec2.describe_instances(
          filters: [{ name: 'instance-state-name', values: %w(running) }],
          max_results: 1000
        )
        instances   = res.reservations.flat_map(&:instances)
        amis_in_use = instances.map(&:image_id).uniq

        # Allow user to define a list of locked AMIs
        if !options[:a].empty?
          options[:a].each do |ami|
            puts "Locked AMI: #{ami}"
            amis_in_use << ami
          end
        end

        # Get a list of all of AMI's owned by the account.
        #
        res = ec2.describe_images(owners: %w(self))
        images = res.images

        images.each do |image|
          image.in_use = amis_in_use.include?(image.image_id)
          image.elegible_for_cleanup = (image.stale?(options[:e]) && !image.in_use)
        end

        # We always show a list of images
        #
        puts build_image_list_header
        images.each { |image| puts build_image_list_entry(region, image) }

        if options[:c]
          images.select(&:elegible_for_cleanup).each do |image|
            puts "[#{region}] Deregistering image: #{image.image_id} #{image.creation_date}"
            ec2.deregister_image(image_id: image.image_id)

            image.block_device_mappings.each { |bdm|
              puts "[#{region}] Deregistering image #{image.image_id}: deleting snapshot #{bdm.ebs.snapshot_id}..."
              ec2.delete_snapshot(snapshot_id: bdm.ebs.snapshot_id)
            }
            puts "[#{region}] Deregister image complete: #{image.image_id}"
          end
        end
      end
    end

    private

    def self.build_image_list_header
      sprintf(IMAGE_LIST_FORMAT, *IMAGE_LIST_HEADER)
    end

    def self.build_image_list_entry(region, image)
      created  = DateTime.parse(image.creation_date).iso8601
      created << " (#{image.days_since_creation} days ago)"

      sprintf(IMAGE_LIST_FORMAT,
              region, image.in_use, image.name, image.image_id,
              created, image.elegible_for_cleanup)
    end
  end
end
