# frozen_string_literal: true

class Components::Base < Phlex::HTML
  # Include any helpers you want to be available across all components
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::AssetPath
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::Pluralize
  include Phlex::Rails::Helpers::URLFor
  include Phlex::Rails::Helpers::NumberToHumanSize

  if respond_to?(:register_value_helper)
    register_value_helper :content_for
    register_value_helper :Current
    register_value_helper :authenticated?
    register_value_helper :alert
    register_value_helper :notice
  end

  if respond_to?(:register_output_helper)
    register_output_helper :hashcash_hidden_field_tag
  end

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end

  # Configure cache store for fragment caching
  # Uses Rails.cache by default, which is compatible with Phlex
  def cache_store
    Rails.cache
  end
end
