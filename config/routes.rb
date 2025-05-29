Solidstats::Engine.routes.draw do
  root to: "dashboard#dashboard"
  get "dashboard", to: "dashboard#dashboard", as: :dashboard
  get "refresh", to: "dashboard#refresh", as: :refresh

  # Route for truncating logs - accepts filename without extension
  post "truncate-log(/:filename)", to: "dashboard#truncate_log", as: :truncate_log,
                                   constraints: { filename: /[^\.]+/ }
end
