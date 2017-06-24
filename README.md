# Awsclean

[![Build Status](https://travis-ci.org/riboseinc/awsclean.svg?branch=master)](https://travis-ci.org/riboseinc/awsclean)

CLI to clean up AWS AMIs and ECR images.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'awsclean'
```

And then execute:

```ruby
bundle
```

Or install it yourself as:

```ruby
gem install awsclean
```

## Usage

### clean_ecr_images

Locates and deletes stale docker images stored in Amazon ECR.

An ECR image is considered stale when:

1. It was created over `--e` days ago (default: 60).
2. It's not being used by any ECS active task definition.

#### Listing images eligible for cleanup:

```
$ awsclean clean_ecr_images
```

```
[clean_ecr_images] Checking region: us-east-2
REGION          IN USE?     REPOSITORY URI                                            TAGS            IMAGE ID                CREATED                                   SIZE        ELEGIBLE FOR CLEANUP?
us-east-2       true        3333344444.dkr.ecr.us-east-2.amazonaws.com/foobar         baz             sha256:464ea4713d51     2017-04-05T21:00:45+00:00 (100 days ago)  184.0 MB    false
us-east-2       true        3333344444.dkr.ecr.us-east-2.amazonaws.com/foobar         latest          sha256:464ea4713d51     2017-04-05T21:00:45+00:00 (100 days ago)  184.0 MB    false
us-east-2       false       3333344444.dkr.ecr.us-east-2.amazonaws.com/foobar_v2      (!TAG)          sha256:f47d0c6acbe9     2017-06-22T22:55:44+00:00 (21 days ago)   136.0 MB    false
us-east-2       false       3333344444.dkr.ecr.us-east-2.amazonaws.com/foobar_v2      latest          sha256:58e584fd7654     2017-06-23T16:13:22+00:00 (21 days ago)   15.0 MB     false
```

### clean_amis

Locates and deletes stale Amazon Machine Images (AMI).

An AMI is considered stale when:

1. It was created over `--e` days ago (default: 60).
2. It's not being used by any EC2 instance.

#### Listing images eligible for cleanup:

```
$ awsclean clean_amis
```

The following flags are available to use in both commands:

* `--c`: delete images marked as eligible for cleanup. (default: false)
* `--e`: images older than `--e` days are considered old. (default: 60)
* `--r`: select which AWS regions to perform on. (default: all)

The `--r` flag accepts a space separated list of region names.

```
$ awsclean clean_amis -r us-east-2 ca-central-1
```

## Development
After checking out the repo, run `bin/setup` to install dependencies.

Then, run `rake spec` to run the tests. You can also run `bin/console`
for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release`, which will create
a git tag for the version, push git commits and tags, and push the
`.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome. This project is intended to
be a safe, welcoming space for collaboration, and contributors are
expected to adhere to the [Contributor
Covenant](http://contributor-covenant.org) code of conduct.

