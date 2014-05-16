R2::Application.routes.draw do

  resources :places

  get 'repairs/new/:engine_id' => 'repairs#new'

  get 'repairs/engineArrived/:engine_id' => 'repairs#engineArrived'

  get 'repairs/repairOrder/:id'    => 'repairs#repairOrder'

  get 'repairs/repairStarted/:id'  => 'repairs#repairStarted'

  get 'repairs/repairFinished/:id' => 'repairs#repairFinished'

  get 'repairs/download_requestpaper/:id' => 'repairs#download_requestpaper' , :as => :requestpaper

  get 'repairs/download_checkpaper/:id' => 'repairs#download_checkpaper', :as => :checkpaper

  get 'repairs/index' => 'repairs#index'

  get 'engines/index' => 'engines#index'

  get 'engines/serialno_list' => 'engines#list_serialno', :as => :list_serialno

  get 'engineorders/engineInquiry' => 'engineorders#inquiry'

  get 'engineorders/engineInquiry/:id' => 'engineorders#inquiry', :as => :edit_inquery

  get 'engineorders/newInquiry/:engine_id' => 'engineorders#inquiry', :as => :new_inquiry

  get 'engineorders/engineOrdered/:id' => 'engineorders#ordered', :as => :ordered

  get 'engineorders/engineAllocated/:id' => 'engineorders#allocated', :as => :allocated

  get 'engineorders/engineShipped/:id' => 'engineorders#shipped', :as => :shipped

  get 'engineorders/engineReturning/:id' => 'engineorders#returning', :as => :returning

  get 'engineorders/undo_allocation/:id' => 'engineorders#undo_allocation', :as => :undo_allocation

  #post 'companies' =>  'companies#show'

  resources :engineorders

  resources :arrivals

  resources :repairs

  root to: 'menu#show'

  devise_for :users
  
  #resources :enginemodels

  resources :engines do
    get :autocomplete_engine_engine_model_name, :on => :collection
    collection { post :import }
  end

  resources :businessstatuses

  resources :enginestatuses

  resources :locations

  resources :companies do
    collection { post :import }
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
