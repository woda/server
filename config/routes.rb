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

  match 'users/:login/login' => 'users#login'
  match 'users/logout' => 'users#logout'
  match 'users/files' => 'users#files', via: :get
  match 'users/files/:folder' => 'users#files', via: :get, constraints: {folder: /.*/}
  match 'users/public_files' => 'users#public_files', via: :get
  match 'users/downloaded_public_files' => 'users#downloaded_public_files', via: :get
  match 'users/share/:id/:share' => 'users#share', via: :post
  match 'users/download_sf/:id' => 'users#download_sf', via: :post
  match 'users/shared_files' => 'users#shared_files', via: :get
  match 'users/recents' => 'users#recents', via: :get
  match 'users/favorites' => 'users#favorites', via: :get
  match 'users/favorites/:id' => 'users#set_favorite', via: :post
  match 'users' => 'users#index', via: :get
  match 'users' => 'users#update', via: :post
  match 'users' => 'users#delete', via: :delete
  match 'users/:login' => 'users#create', via: :put

  match 'users/folder/:directory(/:public)' => 'users#create_directory', via: :put

  match 'admin/cleanup' => 'admin#cleanup'

  match 'sync/public/:filename' => 'sync#set_public_status', via: :post, constraints: {filename: /.*/}
  match 'sync/public/:filename' => 'sync#public_status', via: :get, constraints: {filename: /.*/}
  match 'sync/foreign_public/:filename' => 'sync#sync_public', via: :put, constraints: {filename: /.*/}
  match 'sync/:filename' => 'sync#put', via: :put, constraints: {filename: /.*/}
  match 'partsync/:part/:filename' => 'sync#upload_part', via: :put, constraints: {filename: /.*/}
  match 'sync/:filename' => 'sync#change', via: :post, constraints: {filename: /.*/}
  match 'successsync/:filename' => 'sync#upload_success', via: :post, constraints: {filename: /.*/}
  match 'sync/:filename' => 'sync#delete', via: :delete, constraints: {filename: /.*/}
  match 'partsync/:part/:filename' => 'sync#get2', via: :get, constraints: {filename: /.*/}
end
