require 'spec_helper'

# doit être testé
#
# # # # all # # # #
# require_login sauf pour create et login
#
# # # # create # # # #
# doit fail si login taken
# doit fail si email taken
# doit retourner une erreur si login || password || email is missing
# doit retourner une erreur si email invalid
# doit créer le dossier racine de l'utilisateur
# doit login l'utilisateur
# doit retourner { user: user.description, success: true }
#
# # # # delete # # # #
# doit supprimer l'utilisateur courant
# doit logout l'utilisateur courant
# doit supprimer l'utilisateur courant et pas un autre 
# doit logout l'utilisateur courant et pas un autre
# doit être impossible de se reconnecter après 
# doit etre possible de recreer un user avec les même id
# doit retourner success: true
#
# # # # update # # # #
# n'a pas besoin d'avoir TOUT les parametres 
# update que les parametres passés en dans la requete
# a faire : login / update / login / relogin 
# doit retourner { user: user.description, success: true }
# doit retourner l'utilisateur modifié
#
# # # # index # # # #
# doit retourner user.description de l'utilisateur courant (vérifier les valeurs correctement)
# SSI un id est spécifié en param : doit retourner la description de l'user concerné
# si un mauvais ID est envoyé : doit retournée une erreur
#
# # # # login # # # # 
# doit fail si user pas créé (user not found)
# doit fail si bad password
# doit fail si login incorrect (user not found)
# doit fail si pas de params login || password
# doit login l'utilisateur (possibilité de faire d'autre appel comme index après)
# doit retourner { user: user.description, success: true }
#
# # # # logout # # # #
# doit logout l'utilisateur courant
# doit retourner  { success: true }
# doit empêcher l'user de faire d'autre appel comme index apres

describe UsersController do
  render_views
  DataMapper::Model.raise_on_save_failure = true

  before do
    db_clear
    session[:user] = User.new({login: 'lol', last_name: 'Ecoffet', first_name: 'Adrien', email: 'aec@gmail.com'})
    session[:user].set_password 'hello'
    session[:user].save
  end

  def login_user
    user = session[:user]
    resp = post :login, login: user.login, password: "hello", format: :json
    j = JSON.parse resp.body
    j["login"].should match /lol/
    user
  end

  it "should create a user" do
    session[:user] = nil    
    session[:user].should be_nil
    put :create, login: 'lool', last_name: 'Ecoffet', first_name: 'Adrien', email: 'aec@gmal.com', password: 'omg'
    session[:user].should_not be_nil
    User.first(login: 'lool').should_not be_nil
  end

  it "should be able to get user" do
    user = login_user
    resp = get :index, format: :json
    j = JSON.parse(resp.body)
    j["login"].should match /lol/
  end

  it "should allow user login" do
    login_user
  end

  it "should destroy ther user" do 
    user = login_user
    resp = post :delete
    User.first(login: "lol").should be_nil
  end

  it "should update user" do
    user = login_user
    post :update, login: "plop"
    User.first(login: "plop").should_not be_nil
  end

  it "should not allow user login" do    
    user = session[:user]
    resp = post :login, login: user.login, password: "FAIL_PASSWORD"
    j = JSON.parse resp.body
    j["error"].should match /bad_password/
  end

  it "should logout user" do

    # LOGIN
    user = login_user
    
    # NOW LOGOUT
    resp = get :logout, format: :json
    j = JSON.parse resp.body
    j["success"].should be_true
  end

end
