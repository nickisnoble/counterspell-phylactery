source "https://rubygems.org"
gem "rails", "~> 8.0.2", ">= 8.0.2.1"
gem "propshaft"
gem "sqlite3", ">= 2.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"

gem "bcrypt", "~> 3.1.7"
gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem "image_processing", "~> 1.14"

gem "lexxy", "~> 0.1.4.beta"
gem "phlex-rails"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
  gem "letter_opener", "~> 1.10"
  gem "hotwire-spark", "~> 0.1.13"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "simplecov", "~> 0.22.0"
  gem "rails-controller-testing", "~> 1.0"
  gem "minitest-reporters", "~> 1.7"
end

group :production do
  gem "resend", "~> 0.27.0"
end

gem "rotp", "~> 6.3"
gem "rack-attack", "~> 6.7"
gem "nondisposable", "~> 0.1.0"

gem "dockerfile-rails", ">= 1.7", group: :development

gem "litestream", "~> 0.14.0"

gem "aws-sdk-s3", "~> 1.203", require: false

gem "active_hashcash", "~> 0.4.0"
