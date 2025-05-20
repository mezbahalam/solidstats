
namespace :solidstats do
  desc "Install Solidstats into your Rails application"
  task :install do
    if system "rails g solidstats:install"
      puts "\n✅ Solidstats installation completed successfully!"
      puts "   Start your Rails server and visit http://localhost:3000/solidstats\n\n"
    else
      puts "\n❌ Solidstats installation failed. Please try running manually:"
      puts "   bundle exec rails generate solidstats:install\n\n"
    end
  end
end
