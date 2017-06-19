# (c) 2017 Ribose Inc.
#

require 'thor'
require 'pry'

module Awsclean
end

require 'aws-sdk'
require 'awsclean/aws_extensions'

require 'awsclean/commands'
require 'awsclean/aws_command'
require 'awsclean/ami_clean'
require 'awsclean/ecr_clean'
