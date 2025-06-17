Solidstats::Engine.routes.draw do
  root to: "dashboard#dashboard"
  get "dashboard", to: "dashboard#dashboard", as: :solidstats_dashboard
  get "refresh", to: "dashboard#refresh", as: :refresh

  # Log-related routes
  get "logs/size", to: "logs#logs_size", as: :logs_size
  post "logs/truncate/:filename", to: "logs#truncate", as: :truncate_log, constraints: { filename: /.+/ }
  post "logs/refresh", to: "logs#refresh", as: :refresh_logs
  
  # Security-related routes
  get "securities/bundler_audit", to: "securities#bundler_audit", as: :securities_bundler_audit
  post "securities/refresh_bundler_audit", to: "securities#refresh_bundler_audit", as: :refresh_securities_bundler_audit
  
  # Quality-related routes
  get "quality/style_patrol", to: "quality#style_patrol", as: :quality_style_patrol
  post "quality/refresh_style_patrol", to: "quality#refresh_style_patrol", as: :refresh_quality_style_patrol
  get "quality/coverage_compass", to: "quality#coverage_compass", as: :quality_coverage_compass
  post "quality/refresh_coverage_compass", to: "quality#refresh_coverage_compass", as: :refresh_quality_coverage_compass
  
  # Productivity-related routes
  resources :productivity, only: [] do
    collection do
      get :my_todos
      post :refresh_todos
    end
  end
  
  # Performance-related routes
  resources :performance, only: [] do
    collection do
      get :load_lens
      post :refresh
    end
  end
end
