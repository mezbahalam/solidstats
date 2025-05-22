Solidstats::Engine.routes.draw do
  root to: "dashboard#index"
  get "refresh", to: "dashboard#refresh", as: :refresh
end
