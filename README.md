# PrComet

[![CI](https://github.com/ryz310/pr_comet/actions/workflows/ci.yml/badge.svg)](https://github.com/ryz310/pr_comet/actions/workflows/ci.yml) [![Gem Version](https://badge.fury.io/rb/pr_comet.svg)](https://badge.fury.io/rb/pr_comet)

A helper library that makes it easy to create pull requests.

## Supported Ruby versions

Ruby 3.3, 3.4, and 4.0.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pr_comet'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pr_comet

## Usage

```ruby
# Initialize.
pr_comet = PrComet.new(base: 'master', branch: '{branch name}')

# Modify arbitrary files and commit into the block.
pr_comet.commit '{commit message}' do
  file = File.read('path/to/file')
  file.sub!('hoge', 'fuga')
  File.write('path/to/file', file)
end

# You can also change files outer the block.
`bundle update`
pr_comet.commit '$ bundle update'

# Create a new pull request.
pr_comet.create!(
  title: 'New pull request',
  body: '{New pull request body}',
  labels: ['label 1', 'label 2'] # optional
)
```

## Rspec

### Testing

You can stub `PrComet` class for testing.
Add the following code to `spec/spec_helper`:

```ruby
require 'pr_comet/rspec'
```

Then you can use `#stub_pr_comet!`.
It makes `PrComet` class to stubbing and `PrComet.new` will return stubbed `PrComet` instance.
The stubbed `PrComet#commit` does not execute `$ git commit`, but it executes given block code.

```ruby
def create_pr
  pr_comet = PrComet.new(base: 'master', branch: 'any-branch') # stubbed.
  pr_comet.commit 'Hello world.' do # stubbed.
    File.write('path/to/file.txt', 'Hello world.') # not stubbed.
  end
  pr_comet.create!(title: 'New pull request') # stubbed.
end

stub_pr_comet!
allow(File).to receive(:write)
create_pr
expect(File).to have_received(:write).with('path/to/file.txt', 'Hello world.')
```

If you want to test about `PrComet`, you can use `#stub_pr_comet!` return value.
It returns any instance of `PrComet`.

```ruby
def create_pr
  pr_comet = PrComet.new(base: 'master', branch: 'any-branch')
  pr_comet.commit 'commit message' do
    # ...
  end
  pr_comet.create!(title: 'New pull request')
end

pr_comet = stub_pr_comet!
create_pr
expect(PrComet).to have_received(:new).with(base: 'master', branch: 'any-branch')
expect(pr_comet).to have_received(:commit).with('commit message')
expect(pr_comet).to have_received(:create!).with(title: 'New pull request')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pr_comet. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PrComet project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/pr_comet/blob/master/CODE_OF_CONDUCT.md).

## CI and publishing

GitHub Actions dependencies are tracked in `.github/workflows/actions.lock`. After changing a workflow's `uses:` references, run `gh actions-lock` and commit the generated lockfile with the workflow. Dependabot updates locked Actions dependencies together with their references.

GitHub Actions runs RSpec and builds the gem on the supported Ruby versions. It also runs RuboCop, generates YARD docs, and saves merged coverage as a workflow artifact. To publish the report and view maintainability in Qlty, import the repository into Qlty Cloud and set `QLTY_COVERAGE_TOKEN` as an Actions secret. Fork PRs and runs without the secret retain the artifact without publishing.

Automatic publishing is opt-in via `GHA_RELEASE_ENABLED=true` and uses RubyGems Trusted Publishing for `release.yml`. Configure the GitHub `release` environment to allow deployments from the `production` branch only, and associate the RubyGems Trusted Publisher with that environment.

The daily RuboCop Challenge is opt-in via `GHA_CHALLENGE_ENABLED=true`. Before enabling it, install a GitHub App on this repository with Contents and Pull requests write permissions. Set `CHALLENGE_APP_CLIENT_ID` as a repository variable and `CHALLENGE_APP_PRIVATE_KEY` as an Actions secret. The App token lets the challenge PR trigger CI without relying on approval of a PR created by the built-in token.
