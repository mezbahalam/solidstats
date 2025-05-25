require "net/http"

module Solidstats
  module GemMetadata
    class FetcherService
      GemMeta = Struct.new(:name, :version, :current_version, :released, :info, :runtime, keyword_init: true)

      def self.call(gem_names = nil, force_refresh = false)
        new.call(gem_names, force_refresh)
      end

      def call(gem_names = nil, force_refresh = false)
        gem_names = get_gem_names(gem_names)
        fetch_metadata(gem_names, force_refresh)
      end

      private

      def get_gem_names(gem_names)
        return gem_names if gem_names.present?

        gemfile_lock = Rails.root.join("Gemfile.lock")
        return [] unless File.exist?(gemfile_lock)

        lockfile = File.read(gemfile_lock)
        parser = Bundler::LockfileParser.new(lockfile)
        parser.specs.map(&:name)
      end

      def get_current_versions
        gemfile_lock = Rails.root.join("Gemfile.lock")
        return {} unless File.exist?(gemfile_lock)

        lockfile = File.read(gemfile_lock)
        parser = Bundler::LockfileParser.new(lockfile)

        parser.specs.each_with_object({}) do |spec, versions|
          versions[spec.name] = spec.version.to_s
        end
      end

      def fetch_metadata(gem_names, force_refresh)
        current_versions = get_current_versions

        gem_names.map do |name|
          fetch_gem_data(name, current_versions[name], force_refresh)
        end
      end

      def fetch_gem_data(name, current_version, force_refresh)
        cached_data = fetch_from_cache(name) unless force_refresh

        if cached_data
          # Update current version if it changed since caching
          if current_version && cached_data.current_version != current_version
            cached_data.current_version = current_version
            cache_data(name, cached_data)
          end
          return cached_data
        end

        begin
          data = fetch_from_api(name)
          meta = GemMeta.new(
            name: data["name"],
            version: data["version"],
            current_version: current_version,
            released: data["version_created_at"] ? Time.parse(data["version_created_at"]) : nil,
            info: data["info"],
            runtime: data["dependencies"] && data["dependencies"]["runtime"] || []
          )
          cache_data(name, meta)
          meta
        rescue => e
          Rails.logger.error("Failed to fetch gem metadata for #{name}: #{e.message}")
          GemMeta.new(name: name, current_version: current_version, info: "(API unavailable)")
        end
      end

      def fetch_from_api(name)
        uri = URI.parse("https://rubygems.org/api/v1/gems/#{name}.json")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = 5
        http.read_timeout = 5

        response = http.get(uri.request_uri)

        if response.code == "200"
          JSON.parse(response.body)
        else
          raise "API request failed with status #{response.code}"
        end
      end

      def fetch_from_cache(name)
        cache_file = cache_path(name)
        return nil unless File.exist?(cache_file)

        data = JSON.parse(File.read(cache_file))
        cache_time = File.mtime(cache_file)

        # Return nil if cache is older than 24 hours
        return nil if Time.now - cache_time > 24.hours

        GemMeta.new(
          name: data["name"],
          version: data["version"],
          current_version: data["current_version"],
          released: data["released"] ? Time.parse(data["released"]) : nil,
          info: data["info"],
          runtime: data["runtime"] || []
        )
      end

      def cache_data(name, meta)
        FileUtils.mkdir_p(File.dirname(cache_path(name)))

        data = {
          "name" => meta.name,
          "version" => meta.version,
          "current_version" => meta.current_version,
          "released" => meta.released&.iso8601,
          "info" => meta.info,
          "runtime" => meta.runtime
        }

        File.write(cache_path(name), data.to_json)
      end

      def cache_path(name)
        Rails.root.join("tmp", "cache", "gem_metadata", "#{name}.json")
      end
    end
  end
end
