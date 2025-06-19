module Solidstats
  module ApplicationHelper
    def time_ago_in_words(from_time)
      return "just now" if from_time.nil?

      distance_in_seconds = (Time.current - from_time).to_i

      case distance_in_seconds
      when 0..29
        "just now"
      when 30..59
        "#{distance_in_seconds} seconds"
      when 60..3599
        minutes = distance_in_seconds / 60
        "#{minutes} minute#{'s' if minutes != 1}"
      when 3600..86399
        hours = distance_in_seconds / 3600
        "#{hours} hour#{'s' if hours != 1}"
      else
        days = distance_in_seconds / 86400
        "#{days} day#{'s' if days != 1}"
      end
    end

    def quick_actions
      [
        { icon: "refresh-ccw", label: "Refresh All", color: "blue" },
        { icon: "download", label: "Export Data", color: "green" },
        { icon: "bar-chart-2", label: "View Reports", color: "purple" },
        { icon: "tool", label: "Settings", color: "orange" }
      ]
    end

    # Inline CSS helper - reads all CSS files and returns them as a style tag
    def solidstats_styles
      return @solidstats_styles_cache if defined?(@solidstats_styles_cache)

      begin
        engine_root = Solidstats::Engine.root
        css_files = Dir.glob("#{engine_root}/app/assets/stylesheets/solidstats/*.css")

        combined_css = css_files.map do |file_path|
          relative_path = file_path.gsub("#{engine_root}/app/assets/stylesheets/solidstats/", "")

          # Skip manifest files (application.css with require statements)
          next if relative_path == "application.css"

          "/* === #{relative_path} === */\n#{File.read(file_path)}"
        end.compact.join("\n\n")

        @solidstats_styles_cache = content_tag(:style, combined_css.html_safe, type: "text/css")
      rescue => e
        Rails.logger.error "Solidstats CSS loading error: #{e.message}"
        content_tag(:style, "/* Solidstats CSS loading failed: #{e.message} */", type: "text/css")
      end
    end

    # Inline JavaScript helper - reads all JS files and returns them as a script tag
    def solidstats_scripts
      return @solidstats_scripts_cache if defined?(@solidstats_scripts_cache)

      begin
        engine_root = Solidstats::Engine.root
        js_files = Dir.glob("#{engine_root}/app/assets/javascripts/solidstats/**/*.js")

        if js_files.any?
          combined_js = js_files.map do |file_path|
            relative_path = file_path.gsub("#{engine_root}/app/assets/javascripts/solidstats/", "")
            javascript_content = File.read(file_path)
            # Remove Sprockets directives since we're inlining
            cleaned_js = javascript_content.gsub(/^\/\/=.*$/, "").strip

            "/* === #{relative_path} === */\n#{cleaned_js}"
          end.join("\n\n")

          dashboard_js = <<~JS
            /* === Dashboard Core Scripts === */
            document.addEventListener('DOMContentLoaded', function() {
              // Initialize Feather icons if available
              if (typeof feather !== 'undefined') {
                feather.replace();
              }
            #{'  '}
              // Auto-refresh functionality with animations
              setInterval(function() {
                document.querySelectorAll('.card').forEach(function(card) {
                  card.style.transform = 'scale(1.02)';
                  setTimeout(function() {
                    card.style.transform = '';
                  }, 200);
                });
              }, 30000);

              // Add loading states to forms
              document.querySelectorAll('form[data-turbo-submits-with]').forEach(function(form) {
                form.addEventListener('submit', function() {
                  var submitBtn = form.querySelector('button[type="submit"]');
                  if (submitBtn) {
                    submitBtn.classList.add('loading');
                    submitBtn.disabled = true;
                  }
                });
              });
            });
          JS

          final_js = combined_js + "\n\n" + dashboard_js
        else
          # No JS files found, just include dashboard scripts
          final_js = <<~JS
            /* === Dashboard Core Scripts === */
            document.addEventListener('DOMContentLoaded', function() {
              // Initialize Feather icons if available
              if (typeof feather !== 'undefined') {
                feather.replace();
              }
            #{'  '}
              // Auto-refresh functionality with animations
              setInterval(function() {
                document.querySelectorAll('.card').forEach(function(card) {
                  card.style.transform = 'scale(1.02)';
                  setTimeout(function() {
                    card.style.transform = '';
                  }, 200);
                });
              }, 30000);

              // Add loading states to forms
              document.querySelectorAll('form[data-turbo-submits-with]').forEach(function(form) {
                form.addEventListener('submit', function() {
                  var submitBtn = form.querySelector('button[type="submit"]');
                  if (submitBtn) {
                    submitBtn.classList.add('loading');
                    submitBtn.disabled = true;
                  }
                });
              });
            });
          JS
        end

        @solidstats_scripts_cache = content_tag(:script, final_js.html_safe, type: "text/javascript")
      rescue => e
        Rails.logger.error "Solidstats JavaScript loading error: #{e.message}"
        content_tag(:script, "console.error('Solidstats JavaScript loading failed: #{e.message}');", type: "text/javascript")
      end
    end

    # CDN dependencies helper
    def solidstats_cdn_dependencies
      [
        tag(:meta, name: "viewport", content: "width=device-width,initial-scale=1"),
        stylesheet_link_tag("https://cdn.jsdelivr.net/npm/daisyui@4.12.10/dist/full.min.css", media: "all"),
        javascript_include_tag("https://cdn.tailwindcss.com"),
        javascript_include_tag("https://unpkg.com/feather-icons")
      ].join.html_safe
    end
  end
end
