require 'spec_helper'

#
# TODO vérifier ce qui a déjà été fait
#
# # # # description # # # #
# doit retourner { id: self.id, login: self.login, email: self.email, active: self.active, locked: self.locked }
#
# # # # has_password? # # # #
# doit fail si l'utilisateur n'a pas de password
#
# # # # set_password # # # #
# doit stocker le password encrypté
#
# # # # create_root_folder # # # #
# doit créer le dossier racine de l'utilisateur et le stocker
# ce dossier doit être le premier des x_files
# doit retourner le dossier root
#
# # # # create_folder # # # #
# doit fail si pas de param path 
# doit fail si param path invalid (testé avec pleins de valeurs incohérentes pour voir le résultat: special character, multple slash, etc.)
# doit créer un dossier
# doit retourner un dossier
# doit créer un dossier et si besoin ses dossiers parents (params = /folder1/folder2/folder3) (retourne le dernier dossier)
#
# # # # create_file # # # #
# doit fail si pas de param path 
# doit fail si le fichier existe deja
# doit fail si param path invalid (testé avec pleins de valeurs incohérentes pour voir le résultat: special character, multple slash, etc.)
# doit créer le(s) dossier(s) parents si besoin (params = /folder1/folder2/folder3/file1) (retourne le fichier)
# doit retourner un fichier
# doit fail si path = '/'

describe User do
  before do
    db_clear
    DataMapper::Model.raise_on_save_failure = true
  end

  it "should have proper updatable properties" do
    User.updatable_properties.should eq(Set.new([:login, :email]))
  end

  def build_user
    @user = User.new login: "hello", email: 'a@b.com'
    @user.set_password "world"
    @user.save
  end

  it "should handle passwords" do
    @user = User.new login: "hello"
    @user.set_password "world"
    @user.has_password?("world").should be
    @user.has_password?("wrld").should_not be
  end

  it "should be insertable" do
    @user = User.new login: "hello", email: 'a@b.com'
    @user.set_password "world"
    @user.id.should be_nil
    @user.save
    @user.id.should_not be_nil
  end

  it "should have a unique login" do
    build_user
    lambda { build_user }.should raise_error
  end

  it "should force presence of login, pass_hash, email but with first and last name as optional" do
    u = User.new
    u.set_password "pass"
    hash = u.pass_hash
    # missing login
    u2 = User.new pass_hash: hash, email: 'a@b.com'
    lambda { u2.save }.should raise_error
    # missing hash/password
    u2 = User.new login: "lol", email: 'a@b.com'
    lambda { u2.save }.should raise_error
    # missing email
    u2 = User.new login: "lol"
    u2.set_password "pass"
    lambda { u2.save }.should raise_error
    # ok - first_name not required
    u2 = User.new login: "lol", email: 'a@b.com'
    u2.set_password "pass"
    lambda { u2.save }.should be
    # ok - last_name not required
    u2 = User.new login: "lol2", email: 'a2@b.com'
    u2.set_password "pass"
    lambda { u2.save }.should be
    # ok without name and first name
    u2 = User.new login: "lol3", email: 'a3@b.com'
    u2.set_password "pass"
    lambda { u2.save }.should be
    # ok with name and first name
    u2 = User.new login: "lol4", email: 'a4@b.com'
    u2.set_password "pass"
    lambda { u2.save }.should be
  end

  it "should not allow to create an account with a login or email already used" do
    build_user #login: "hello", email: 'a@b.com'

    # same login
    new_user = User.new login: "hello", email: 'a4@b.com'
    new_user.set_password "pass"
    lambda { u2.save }.should raise_error

    # same email
    new_user = User.new login: "aloa", email: 'a@b.com'
    new_user.set_password "pass"
    lambda { u2.save }.should raise_error

    # same first/last name -> should be ok
    new_user = User.new login: "aloa", email: 'sac@main.fr'
    new_user.set_password "pass"
    lambda { u2.save }.should be

  end

  it "should support queries" do
    build_user
    User.first(login: 'hello').has_password?("world").should be
    User.first(login: 'a').should be_nil
  end

  it "should force having a password hash" do
    u = User.new login: "hello", pass_hash: "world", email: 'a@b.com'
    lambda { u.save }.should raise_error
    u = User.new login: "hello", email: 'a@b.com'
    u.set_password "world"
    u.save
  end

  it "should support updates" do
    build_user
    u = User.first(login: 'hello')
    u.set_password "ok"
    u.save
  end
end
