# (c) 2017 Ribose Inc.
#

module Awsclean
  class Commands < Thor

=begin
-- -l only list out "unused" images with name, AMI ID, size, region, date created (and how many days it has been) and who created
-- -c to clean up all "unused" containers
-- -e [days] the number of days considered "unused", default is 60
-- -l and -c can be used with -e but -l and -c cannot be used together. Default mode is -l.
-- -r [regions] to specify regions to check, in the form of "us-west-1,us-east-1,..." separated by comma
-- -a [amis] to specify amis to skip for deletion, in the form of "ami-xxxxxx,ami-yyyyyy,..." separated by comma
=end

    option :l, type: :boolean, default: true #list
    option :c, type: :boolean
    option :e, type: :numeric, default: 60
    option :r, type: :array, default: %w(all)
    option :a, type: :array, default: %w()

    # TODO: dynamically generate these based on listing out subclasses of AwsCommand?

    desc 'clean_amis', "Cleanup unused AMI's"
    def clean_amis
      puts "[clean_amis] Running AmiClean"
      AmiClean.run options
    end

    option :l, type: :boolean, default: true #list
    option :c, type: :boolean
    option :e, type: :numeric, default: 60
    option :r, type: :array, default: %w(all)

    desc 'clean_ecr_images', "Cleanup unused ECR container images"
    def clean_ecr_images
      puts "[clean_ecr_images] Running EcrClean"
      EcrClean.run options
    end

  end
end

