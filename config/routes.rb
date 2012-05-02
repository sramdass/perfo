Perfo::Application.routes.draw do
  match '', to: 'institutions#show', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' }, :as => 'institution_root'
  match '/edit', to: 'institutions#edit', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' }, :as => 'institution_edit'
  match '/new', to: 'institutions#new', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' }, :as => 'institution_new'  
  get 'invalid_tenant'			=> 'tenants#invalid',					 :as => 'invalid_tenant'
  resources :tenants
  resources :institutions
  resources :semesters
  resources :departments  
  resources :subjects
  resources :exams
  resources :batches
  resources :faculties
  resources :sections do
    collection do
      get 'subjects'
      put 'update_subjects'
      get 'faculties'
      put 'update_faculties'
      get 'exams'
      put 'update_exams'      
    end
  end
  resources :school_types
  resources :students
  resources :blood_groups
  resources :selectors
  root :to => 'tenants#new'
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
