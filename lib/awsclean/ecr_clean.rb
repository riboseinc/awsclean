# (c) 2017 Ribose Inc.
#

module Awsclean
  class EcrClean < AwsCommand

    SERVICE_IDENTIFIER = "ECR"

    IMAGE_LIST_HEADER = [
      'REGION', 'IN USE?', 'REPOSITORY URI', 'TAGS',
      'IMAGE ID', 'CREATED', 'SIZE', 'ELEGIBLE FOR CLEANUP?'
    ]
    IMAGE_LIST_FORMAT = '%-16s%-12s%-64s%-24s%-24s%-42s%-12s%-24s'

    def self.run options
      regions = filter_regions(options[:r])

      if regions.empty?
        puts "Please specify region with -r [regions, e.g., 'all' or 'us-west-1 us-east-1']"
        exit 1
      end

      regions.each do |region|
        puts "[clean_ecr_images] Checking region: #{region}"

        ecr = Aws::ECR::Client.new(region: region)

        # List all image repositories
        #
        res    = ecr.describe_all_repositories
        images = res.repositories.flat_map do |repo|
          ecr.describe_images(repository_name: repo.repository_name)
            .image_details
        end

        images.each do |image|
          image.region = region
          image.in_use = !image.image_uris.empty?
          image.elegible_for_cleanup = (image.stale?(options[:e]) && !image.in_use)
        end

        # We always show a list of images
        #
        print_image_list_header
        images.each { |image| print_image_list_entry(image) }

        if options[:c]
          images_to_delete =
            images.select(&:elegible_for_cleanup).group_by(&:repository_name)

          images_to_delete.each do |repository_name, pack|
            ecr.batch_delete_image(
              repository_name: repository_name,
              image_ids: pack.map { |i| { image_digest: i.image_digest } }
            )
          end
        end
      end
    end

    private

    def self.print_image_list_header
      puts sprintf(IMAGE_LIST_FORMAT, *IMAGE_LIST_HEADER)
    end

    def self.print_image_list_entry(image)
      created  = image.image_pushed_at.iso8601
      created << " (#{image.days_since_creation} days ago)"

      size  = (image.image_size_in_bytes / 1024 / 1024).round(2).to_s
      size << ' MB'

      unless image.image_tags
        puts sprintf(IMAGE_LIST_FORMAT,
          image.region, image.in_use,              image.repository_uri,
          "(!TAG)",     image.image_digest[0,19],  created,
          size,         image.elegible_for_cleanup
        )
      else
        image.image_tags.each do |tag|
          puts sprintf(IMAGE_LIST_FORMAT,
            image.region, image.in_use,              image.repository_uri,
            tag,          image.image_digest[0,19],  created,
            size,         image.elegible_for_cleanup
          )
        end
      end
    end
  end
end
