Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'timetables#show'

  resources :groups, only: [:index]
  resources :lessons, only: [:show], param: :group_name
  resource :bug_report, only: [:create]
end
