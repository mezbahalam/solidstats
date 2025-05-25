# frozen_string_literal: true

module Solidstats
  module Ui
    # Stats overview component displaying key dashboard metrics
    class StatsOverviewComponent < Solidstats::BaseComponent
      def initialize(metrics: [], **options)
        @metrics = metrics
        @options = options
      end

      private

      attr_reader :metrics, :options

      def overview_classes
        css_classes("stats-summary", options[:class])
      end

      def overview_attributes
        { class: overview_classes }.merge(options.except(:class))
      end

      def metric_status(metric)
        return metric[:status] if metric[:status]
        
        # Auto-determine status based on value and thresholds
        if metric[:value].to_i == 0 && metric[:zero_is_good]
          :ok
        elsif metric[:thresholds]
          determine_threshold_status(metric[:value], metric[:thresholds])
        else
          :info
        end
      end

      def determine_threshold_status(value, thresholds)
        numeric_value = extract_numeric_value(value)
        
        if numeric_value >= thresholds[:excellent]
          :ok
        elsif numeric_value >= thresholds[:good]
          :ok
        elsif numeric_value >= thresholds[:warning]
          :warning
        else
          :error
        end
      end

      def extract_numeric_value(value)
        case value
        when Numeric
          value
        when String
          value.to_f
        else
          0
        end
      end

      def metric_href(metric)
        if metric[:section] && metric[:tab]
          "##{metric[:section]}"
        elsif metric[:href]
          metric[:href]
        end
      end

      def metric_data_attributes(metric)
        attrs = {}
        attrs["data-section"] = metric[:section] if metric[:section]
        attrs["data-tab"] = metric[:tab] if metric[:tab]
        attrs
      end
    end
  end
end
