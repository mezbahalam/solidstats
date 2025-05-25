Solidstats::Engine.routes.draw do
  root to: "dashboard#index"
  get "refresh", to: "dashboard#refresh", as: :refresh

  # Route for truncating logs - accepts filename without extension
  post "truncate-log(/:filename)", to: "dashboard#truncate_log", as: :truncate_log,
                                   constraints: { filename: /[^\.]+/ }

  post "gem_metadata/refresh", to: "gem_metadata#refresh", as: :refresh_gem_metadata
end
