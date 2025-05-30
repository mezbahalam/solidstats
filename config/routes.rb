Solidstats::Engine.routes.draw do
  root to: "dashboard#dashboard"
  get "dashboard", to: "dashboard#dashboard", as: :dashboard
  get "refresh", to: "dashboard#refresh", as: :refresh

  # Log-related routes
  get "logs/size", to: "logs#logs_size", as: :logs_size
  post "logs/truncate/:filename", to: "logs#truncate", as: :truncate_log, constraints: { filename: /.+/ }
  post "logs/refresh", to: "logs#refresh", as: :refresh_logs
  
  # Security-related routes
  get "securities/bundler_audit", to: "securities#bundler_audit", as: :securities_bundler_audit
  post "securities/refresh_bundler_audit", to: "securities#refresh_bundler_audit", as: :refresh_securities_bundler_audit
end
