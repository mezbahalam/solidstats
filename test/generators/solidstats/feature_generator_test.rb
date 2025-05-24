require "test_helper"
require "generators/solidstats/feature/feature_generator"

class Solidstats::Generators::FeatureGeneratorTest < Rails::Generators::TestCase
  tests Solidstats::Generators::FeatureGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  test "generator runs without errors" do
    run_generator ["memory_usage"]
    
    # Check that files were created
    assert_file "app/services/solidstats/memory_usage_service.rb" do |content|
      assert_match(/class MemoryUsageService/, content)
      assert_match(/CACHE_KEY/, content)
    end
    
    assert_file "app/helpers/solidstats/memory_usage_helper.rb" do |content|
      assert_match(/module MemoryUsageHelper/, content)
    end
    
    assert_file "app/views/solidstats/dashboard/_memory_usage_summary.html.erb" do |content|
      assert_match(/memory-usage-component/, content)
    end
    
    assert_file "app/views/solidstats/memory_usage/index.html.erb"
    assert_file "app/controllers/solidstats/memory_usage_controller.rb"
    assert_file "app/assets/stylesheets/solidstats/memory_usage_component.scss"
  end
  
  test "generator with options" do
    run_generator ["cpu_metrics", "--icon=processor", "--section=performance"]
    
    assert_file "app/services/solidstats/cpu_metrics_service.rb"
    assert_file "app/helpers/solidstats/cpu_metrics_helper.rb"
  end
  
  test "generator creates test files" do
    run_generator ["disk_usage"]
    
    assert_file "test/services/solidstats/disk_usage_service_test.rb" do |content|
      assert_match(/class DiskUsageServiceTest/, content)
    end
    
    assert_file "test/helpers/solidstats/disk_usage_helper_test.rb"
    assert_file "test/controllers/solidstats/disk_usage_controller_test.rb"
  end
end
