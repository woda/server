Server::Application.routes.draw do
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
  # match ':controller(/:action(/:id))(.:format)'

# Users Controller
  match 'users/:login/login' => 'users#login'
  match 'users/logout' => 'users#logout'
  match 'users' => 'users#index', via: :get
  match 'users' => 'users#update', via: :post
  match 'users' => 'users#delete', via: :delete
  match 'users/:login' => 'users#create', via: :put

# Files Controller
  match 'files/recents' => 'files#recents', via: :get
  match 'files/favorites' => 'files#favorites', via: :get
  match 'files/favorites/:id' => 'files#set_favorite', via: :post
  match 'files/public' => 'files#public', via: :get
  match 'files/public/:id' => 'files#set_public', via: :post
  match 'files/shared' => 'files#shared', via: :get
  match 'files/link/:id' => 'files#link', via: :get
  match 'files/downloaded' => 'files#downloaded', via: :get  
  match 'files(/:id)' => 'files#list', via: :get

# Files Controller::folder methods
  match 'folders' => 'files#create_folder', via: :post
  match 'folders/:id' => 'files#delete_folder', via: :delete

# sync controller
  match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
  match 'sync/:id' => 'sync#delete', via: :delete
  match 'sync/:id' => 'sync#change', via: :post
  match 'sync/:id/:part' => 'sync#upload_part', via: :put
  match 'sync/:id/:part' => 'sync#get', via: :get
  match 'sync_success/:id' => 'sync#upload_success', via: :post
  match 'last_update(/:id)' => 'sync#last_update', via: :get

# admin controller
  match 'admin/cleanup' => 'admin#cleanup'
  match '*path' => 'admin#wrong_route'
  
end
