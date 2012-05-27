Perfo::Application.routes.draw do
  match '', to: 'institutions#show', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' }, :as => 'institution_root'
  match '/edit', to: 'institutions#edit', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' }, :as => 'institution_edit'
  match '/new', to: 'institutions#new', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' }, :as => 'institution_new'
  
  match '/signup', 						to: 'user_profiles#new', 					:as => 'signup'
  match '/login', 							to: 'sessions#new', 							:as => 'login'
  get 'logout'			 						=> 'sessions#destroy', 						:as => 'logout'
  
  match '/dashboard', 				to: 'sessions#dashboard' , 				:as => 'dashboard'    
  get 'invalid_tenant'					=> 'tenants#invalid',							:as => 'invalid_tenant'
  
  resources :tenants do
    member do
      get 'activate_options'
      post 'activate'
    end
  end
  resources :institutions
  resources :semesters
  resources :departments do
    collection do
      get 'hods'
      #We are having update_hods in the collection unlike the update_* methods in section controller
      #Here we are updating the hods of all the departments
  	  post 'update_hods'      
    end
  end
  resources :subjects
  resources :exams
  resources :batches
  resources :faculties
  resources :sections do
  	member do
  	  #To update a particular subject (or other items), we need to send a section id along with it. We can also
  	  #send a hidden field to achieve this, but I figured this method will be neat.
      post 'update_subjects'
      post 'update_faculties'
      post 'update_exams'      
  	end
    collection do
      #For these items the section ids are received via the select boxes. So we are considering them as collection.
      #The url will be sections/subjects
      get 'subjects'
      get 'faculties'
      get 'exams'
    end
  end
  resources :school_types
  resources :students
  resources :blood_groups
  resources :selectors
  resources :user_profiles
  resources :sessions
  resources :password_resets
  resources :resources
  resources :roles
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
