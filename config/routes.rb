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

# CORS
  match "*all" => "application#cors", via: :options

# Users Controller
  match 'users/:login/login' => 'users#login', via: :post
  match 'users/logout' => 'users#logout', via: :get
  match 'users(/:id)' => 'users#index', via: :get
  match 'users' => 'users#update', via: :post
  match 'users' => 'users#delete', via: :delete
  match 'users/:login' => 'users#create', via: :put

# Files Controller
  match 'files/recents' => 'files#recents', via: :get
  match 'files/favorites' => 'files#favorites', via: :get
  match 'files/favorites/:id' => 'files#set_favorite', via: :post
  match 'files/public' => 'files#public', via: :get
  match 'files/public/:id' => 'files#set_public', via: :post
  match 'files/share/:id' => 'files#share', via: :post
  match 'files/unshare/:id' => 'files#unshare', via: :post
  match 'files/shared_by_me(/:id)' => 'files#shared_by_me', via: :get
  match 'files/shared_to_me' => 'files#shared_to_me', via: :get
  match 'files/link/:id' => 'files#link', via: :get
  match 'files/downloaded' => 'files#downloaded', via: :get
  match 'files/breadcrumb/:id' => 'files#breadcrumb', via: :get
  match 'files/last_update(/:id)' => 'files#last_update', via: :get
  match 'files(/:id)' => 'files#list', via: :get
  match 'usersfiles/:user(/:id)' => 'files#list', via: :get
  match 'move/:id/from/:source/into/:destination' => 'files#move', via: :post

# sync controller
  match 'sync' => 'sync#put', via: :put, constraints: {filename: /.*/}
  match 'sync/:id' => 'sync#delete', via: :delete
  match 'sync/:id' => 'sync#change', via: :post
  match 'sync/:id' => 'sync#needed_parts', via: :get
  match 'sync/:id/:part' => 'sync#upload_part', via: :put
  match 'sync_public/:id' => 'sync#synchronize', via: :post
  
# download
  match 'sync/:id/:part' => 'download#get', via: :get
  match 'dl/:uuid' => 'download#ddl', via: :get

# folder management
  match 'sync_folder' => 'sync#create_folder', via: :post
  match 'create_folder' => 'sync#create_folder', via: :post

# friend management
  match 'friends/:id' => 'friends#create', via: :put
  match 'friends/:id' => 'friends#delete', via: :delete
  match 'friends' => 'friends#list', via: :get
  match 'friendships' => 'friends#list_friendships', via: :get

# search
  match 'search' => 'search#search', via: :get

# admin controller
  match 'admin/users' => 'admin#users', via: :get
  match 'admin/users/:id' => 'admin#delete_user', via: :delete
  match 'admin/users/:id/update_space/:space' => 'admin#update_user_space', via: :post
  match 'admin/files(/:id)' => 'admin#files', via: :get
  match 'admin/files/:id' => 'admin#delete_file', via: :delete
  match '*path' => 'admin#wrong_route'

end
