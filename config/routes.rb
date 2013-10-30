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

# Folders Controller
  match 'folders' => 'folders#list', via: :get, constraints: {filename: /.*/}
  match 'folders/:path' => 'folders#create', via: :put, constraints: {filename: /.*/}
  match 'folders/favorite' => 'folders#favorite', via: :post
  match 'folders/public' => 'folders#public', via: :post
  match 'folders/:path' => 'folders#delete', via: :delete, constraints: {filename: /.*/}

# Files Controller
  match 'files/recents' => 'files#recents', via: :get
  match 'files/favorites' => 'files#favorites', via: :get
  match 'files/public' => 'files#public', via: :get
  match 'files/shared' => 'files#shared', via: :get
  match 'files/share/:id' => 'files#set_shared', via: :post
  match 'files/favorite/:id' => 'files#set_favorite', via: :post
  match 'files/public/:id' => 'files#set_public', via: :post
  
# Useless methods
  match 'files/downloaded' => 'files#downloaded', via: :get
  match 'files/downloaded_public' => 'files#downloaded_public', via: :get
  match 'sync/foreign_public/:filename' => 'sync#sync_public', via: :put, constraints: {filename: /.*/}

# sync controller
  match 'sync/:filename' => 'sync#put', via: :put, constraints: {filename: /.*/}
  match 'sync/:filename' => 'sync#delete', via: :delete, constraints: {filename: /.*/}
  match 'sync/:filename' => 'sync#change', via: :post, constraints: {filename: /.*/}
  match 'sync_part/:part/:filename' => 'sync#get', via: :get, constraints: {filename: /.*/}
  match 'sync_part/:part/:filename' => 'sync#upload_part', via: :put, constraints: {filename: /.*/}
  match 'sync_success/:filename' => 'sync#upload_success', via: :post, constraints: {filename: /.*/}
  match 'sync_link/:filename' => 'sync#link', via: :get, constraints: {filename: /.*/}
  match 'last_update' => 'sync#last_update', via: :get, constraints: {filename: /.*/}

# admin controller
  match 'admin/cleanup' => 'admin#cleanup'
  match '*path' => 'admin#wrong_route'
  
end
