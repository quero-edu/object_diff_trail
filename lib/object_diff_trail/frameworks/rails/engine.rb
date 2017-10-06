module ObjectDiffTrail
  module Rails
    # See http://guides.rubyonrails.org/engines.html
    class Engine < ::Rails::Engine
      paths["app/models"] << "lib/object_diff_trail/frameworks/active_record/models"
      config.object_diff_trail = ActiveSupport::OrderedOptions.new
      initializer "object_diff_trail.initialisation" do |app|
        ObjectDiffTrail.enabled = app.config.object_diff_trail.fetch(:enabled, true)
      end
    end
  end
end
