require "rails/generators/named_base"

module Solidstats
  module Generators
    class FeatureGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      desc "Generate a new Solidstats feature with service, component, and views"

      class_option :icon, type: :string, default: "📊", desc: "Icon for the feature"
      class_option :section, type: :string, default: "metrics", desc: "Dashboard section (overview, security, code-quality, metrics)"
      class_option :status_colors, type: :boolean, default: true, desc: "Include status-based coloring"
      class_option :cache_hours, type: :numeric, default: 1, desc: "Cache duration in hours"

      def create_service
        template "service.rb.erb", "app/services/solidstats/#{file_name}_service.rb"
      end

      def create_component_helper
        template "component.rb.erb", "app/helpers/solidstats/#{file_name}_helper.rb"
      end

      def create_component_partial
        template "component.html.erb", "app/views/solidstats/dashboard/_#{file_name}_summary.html.erb"
      end

      def create_component_styles
        template "component.scss", "app/assets/stylesheets/solidstats/#{file_name}_component.scss"
      end

      def create_preview
        template "preview.rb.erb", "app/views/solidstats/#{file_name}/preview.html.erb"
      end

      def create_detail_view
        template "detail_view.html.erb", "app/views/solidstats/#{file_name}/index.html.erb"
      end

      def create_controller
        template "controller.rb.erb", "app/controllers/solidstats/#{file_name}_controller.rb"
      end

      def create_service_test
        template "service_test.rb.erb", "test/services/solidstats/#{file_name}_service_test.rb"
      end

      def create_component_test
        template "component_test.rb.erb", "test/helpers/solidstats/#{file_name}_helper_test.rb"
      end

      def create_controller_test
        template "controller_test.rb.erb", "test/controllers/solidstats/#{file_name}_controller_test.rb"
      end

      def add_route
        route_content = "  get \"#{file_name}\", to: \"#{file_name}#index\", as: :#{file_name}"
        inject_into_file "config/routes.rb", after: "Solidstats::Engine.routes.draw do\n" do
          "#{route_content}\n"
        end
      end

      def integrate_with_dashboard
        # Add instance variable to dashboard controller
        inject_into_file "app/controllers/solidstats/dashboard_controller.rb",
          after: "def index\n" do
          "      @#{file_name}_data = #{class_name}Service.new.summary\n"
        end

        # Add to refresh method
        inject_into_file "app/controllers/solidstats/dashboard_controller.rb",
          after: "def refresh\n" do
          "      #{file_name}_data = #{class_name}Service.new.fetch(true)\n"
        end

        # Add to refresh JSON response
        inject_into_file "app/controllers/solidstats/dashboard_controller.rb",
          after: "render json: {\n" do
          "        #{file_name}_data: #{file_name}_data,\n"
        end
      end

      def update_dashboard_view
        # Add summary card to overview section
        card_partial = <<~ERB

            <div class="summary-card <%= @#{file_name}_data&.dig(:status) || 'status-ok' %>" data-section="#{options[:section]}" data-tab="#{file_name.dasherize}">
              <div class="summary-icon">#{options[:icon]}</div>
              <div class="summary-data">
                <div class="summary-value"><%= @#{file_name}_data&.dig(:value) || 0 %></div>
                <div class="summary-label">#{human_name}</div>
              </div>
            </div>
        ERB

        inject_into_file "app/views/solidstats/dashboard/index.html.erb",
          after: '<div class="stats-summary">' do
          card_partial
        end

        # Add section if it doesn't exist for metrics
        if options[:section] == "metrics"
          section_content = <<~ERB

            <!-- #{human_name} Section -->
            <section id="#{file_name.dasherize}" class="dashboard-section">
              <h2 class="section-title">#{human_name}</h2>
              <%= render Solidstats::#{class_name}Component.new(data: @#{file_name}_data) %>
            </section>
          ERB

          inject_into_file "app/views/solidstats/dashboard/index.html.erb",
            before: "  <!-- Floating quick navigation -->" do
            section_content
          end

          # Add to navigation
          nav_item = <<~ERB

                  <li><a href="##{file_name.dasherize}" class="nav-item" data-section="#{file_name.dasherize}">#{human_name}</a></li>
          ERB

          inject_into_file "app/views/solidstats/dashboard/index.html.erb",
            after: '<nav class="dashboard-nav">' do
            "      <ul>#{nav_item}"
          end

          # Add to quick nav
          quick_nav_item = <<~ERB

              <a href="##{file_name.dasherize}" class="quick-nav-item">#{human_name}</a>
          ERB

          inject_into_file "app/views/solidstats/dashboard/index.html.erb",
            after: '<div class="quick-nav-menu">' do
            quick_nav_item
          end
        end
      end

      def create_directory_structure
        empty_directory "app/views/solidstats/#{file_name}"
      end

      def show_next_steps
        say "\n" + set_color("#{human_name} feature generated successfully!", :green, :bold)
        say "\nNext steps:"
        say "  1. Implement data collection logic in #{set_color("app/services/solidstats/#{file_name}_service.rb", :yellow)}"
        say "  2. Customize the component template in #{set_color("app/components/solidstats/#{file_name}_component.html.erb", :yellow)}"
        say "  3. Add any required styling in #{set_color("app/components/solidstats/#{file_name}_component.scss", :yellow)}"
        say "  4. Run tests: #{set_color("rails test test/services/solidstats/#{file_name}_service_test.rb", :cyan)}"
        say "  5. Visit #{set_color("http://localhost:3000/rails/view_components", :cyan)} to preview the component"
        say "\nThe feature will appear in the #{set_color(options[:section], :blue)} section of the dashboard."
      end

      private

      def human_name
        file_name.humanize
      end

      def class_name
        file_name.camelize
      end

      def section_human_name
        options[:section].humanize
      end
    end
  end
end
