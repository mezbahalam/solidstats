module Solidstats
  module ApplicationHelper
    # Inline CSS helper - reads all CSS files and returns them as a style tag
    def solidstats_styles
      return @solidstats_styles_cache if defined?(@solidstats_styles_cache)

      begin
        engine_root = Solidstats::Engine.root
        css_files = Dir.glob("#{engine_root}/app/assets/stylesheets/solidstats/components/*.css")

        combined_css = css_files.map do |file_path|
          "/* === #{File.basename(file_path)} === */\n#{File.read(file_path)}"
        end.join("\n\n")

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
        js_file = "#{engine_root}/app/assets/javascripts/solidstats/application.js"

        if File.exist?(js_file)
          javascript_content = File.read(js_file)
          # Remove Sprockets directives since we're inlining
          cleaned_js = javascript_content.gsub(/^\/\/=.*$/, "").strip

          @solidstats_scripts_cache = content_tag(:script, cleaned_js.html_safe, type: "text/javascript")
        else
          Rails.logger.warn "Solidstats JavaScript file not found: #{js_file}"
          content_tag(:script, "console.log('Solidstats JavaScript not found');", type: "text/javascript")
        end
      rescue => e
        Rails.logger.error "Solidstats JavaScript loading error: #{e.message}"
        content_tag(:script, "console.error('Solidstats JavaScript loading failed: #{e.message}');", type: "text/javascript")
      end
    end
  end
end
