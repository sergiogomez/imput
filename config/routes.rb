Rails.application.routes.draw do

  scope "/:locale", locale: /#{I18n.available_locales.join("|")}/ do


    devise_for :people, :controllers => {registrations: "registrations"}, path_prefix: "a"

    resources :clients, except: [:show]
    resources :companies, only: [:update]
    resources :people, except: [:show]
    resources :projects, except: [:show]
    resources :rows, only: [:create, :destroy]
    resources :tasks, except: [:show]
    resources :time_entries, except: [:index, :show, :new]

    get '/dashboard', to: 'dashboard#index', as: :dashboard

    get '/reports(/:time_frame_from/:time_frame_to/:clients/:projects/:tasks/:people)', to: 'dashboard#reports', as: :reports
    post '/reports', to: 'dashboard#run_reports', as: :run_reports

    get '/time/week(/:year/:month/:day)', to: 'time#week', as: :time_week
    post '/time/week(/:year/:month/:day)', to: 'time#update', as: :time_update
    get '/time/week/new(/:year/:month/:day)', to: 'rows#new', as: :new_row
    get '/time/day(/:year/:month/:day)', to: 'time#day', as: :time_day
    get '/time/new(/:year/:month/:day)', to: 'time_entries#new', as: :new_time_entry
    patch '/time/day/duplicate(/:year/:month/:day)', to: 'time#duplicate_day', as: :duplicate_day
    patch '/time/week/duplicate(/:year/:month/:day)', to: 'time#duplicate_row', as: :duplicate_row

    patch '/time_entries/:id/start', to: 'time_entries#start', as: :start_timer
    patch '/time_entries/:id/stop', to: 'time_entries#stop', as: :stop_timer
    patch '/time_entries/:id/duplicate', to: 'time_entries#duplicate', as: :duplicate_time_entry

    get '/imports', to: redirect('/imports/time_entries', status: 302), as: :imports
    get '/imports/clients', to: 'clients#import', as: :import_clients
    post '/imports/clients', to: 'clients#import_file', as: :import_clients_file
    get '/imports/projects', to: 'projects#import', as: :import_projects
    post '/imports/projects', to: 'projects#import_file', as: :import_projects_file
    get '/imports/tasks', to: 'tasks#import', as: :import_tasks
    post '/imports/tasks', to: 'tasks#import_file', as: :import_tasks_file
    get '/imports/people', to: 'people#import', as: :import_people
    post '/imports/people', to: 'people#import_file', as: :import_people_file
    get '/imports/time_entries', to: 'time_entries#import', as: :import_time_entries
    post '/imports/time_entries', to: 'time_entries#import_file', as: :import_time_entries_file

    get '/profile', to: 'people#profile', as: :edit_profile
    patch '/switch_time_format', to: 'people#switch_time_format', as: :switch_time_format
    patch '/people/:id/disable', to: 'people#disable', as: :disable_person
    patch '/people/:id/enable', to: 'people#enable', as: :enable_person

    patch '/clients/:id/disable', to: 'clients#disable', as: :disable_client
    patch '/clients/:id/enable', to: 'clients#enable', as: :enable_client

    get '/account', to: 'companies#show', as: :show_account

    get '/projects/:id/project_managers', to: 'projects#edit_project_managers', as: :edit_project_managers
    patch '/projects/:id/disable', to: 'projects#disable', as: :disable_project
    patch '/projects/:id/enable', to: 'projects#enable', as: :enable_project

    delete '/delete_account', to: 'companies#destroy', as: :delete_account


    root to: redirect("/%{locale}/dashboard", status: 302)
  end
  root to: redirect("/#{I18n.default_locale}", status: 302), as: :redirected_root
  #get "/*path", to: redirect("/#{I18n.default_locale}/%{path}", status: 302), constraints: {path: /(?!(#{I18n.available_locales.join("|")})\/).*/}, format: false






  namespace :dynamic_select do
    get ':project_id/tasks', to: 'tasks#index', as: 'tasks'
    get ':project_id/:stored_at/tasks_row', to: 'tasks#row', as: 'row_tasks'
  end

  require 'sidekiq/web'
  require 'sidetiq/web'
  authenticate :admin_user do
    mount Sidekiq::Web => '/sidekiq'
  end

  %w( 404 422 500 ).each do |code|
    match code, to: "errors#show", code: code, via: :all
  end

  namespace :api, defaults: { format: "json" } do
    namespace :v1 do
      devise_for :people
      resources :projects do
        resources :tasks
      end
      resources :time_entries
      patch 'time_entries/:id/start', to: 'time_entries#start', as: :api_v1_start_timer
      patch 'time_entries/:id/stop', to: 'time_entries#stop', as: :api_v1_stop_timer
    end
  end

end
