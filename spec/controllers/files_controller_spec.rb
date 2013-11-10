require 'spec_helper'

# doit être testé:
#
# # # all # # # #
# login required
# 
# # # # set_favorite # # # #
# doit fail si pas de param(id) || param(favorite)
# doit fail si le param id est invalide (id: hegfruyegf)
# doit fail si l'id n'existe pas
# doit fail si le fichier n'appartient pas à l'utilisateur
# doit fail si le param favorite n'est pas valide
# ne doit pas mettre à jour le last_update du dossier racine
# doit retourner success:true + file: file.description
#
# # # # favorites # # # #
# doit retourner success: true + array of files
# doit retourner les fichiers ET dossiers favoris
# doit retourner les fichiers ET dossiers dans un tableau
# doit retourner un array vide + success:true si pas de fichiers
# 
# # # # set_public # # # #
# doit fail si pas de param(id) || param(public)
# doit fail si le param id est invalide (id: hegfruyegf)
# doit fail si l'id n'existe pas
# doit fail si le fichier n'appartient pas à l'utilisateur
# doit fail si le param public n'est pas valide
# ne doit pas mettre à jour le last_update du dossier racine
# doit retourner success:true + file: file.description
# 
# # # # public # # # #
# doit retourner success: true + array of files
# doit retourner les fichiers ET dossiers public
# doit retourner les fichiers ET dossiers dans un tableau
# doit retourner un array vide + success:true si pas de fichiers
# 
# # # # shared # # # #
# doit retourner success: true + array of files
# doit retourner les fichiers ET dossiers dont le UUID/DDL link a été généré
# doit retourner les fichiers ET dossiers dans un tableau
# doit retourner un array vide + success:true si pas de fichiers
#
# # # # link # # # #
# doit fail si pas de param(id)
# doit fail si le param id est invalide (id: hegfruyegf)
# doit fail si l'id n'existe pas, ou que le fichier n'appartient pas à l'utilisateur
# ne doit pas mettre à jour le last_update du dossier racine
# doit retourner success:true + file: file.description + link: URL
#
# # # # downloaded # # # #
# doit retourner success: true + files: array of files
# doit retourner les fichiers et PAS de dossiers
# doit retourner les fichiers dans un tableau
# doit retourner les fichiers qui ont été téléchargés au moins 1 fois ou plus.
# doit retourner un array vide + success:true si pas de fichiers

describe FilesController do
	render_views
	DataMapper::Model.raise_on_save_failure = true

	before :all do
		db_clear
		put_description
	end

	before :each do
		db_clear
		@user = create_user({login: "Testeur", password: "Testing42", email: "testeur@woda-serveur.com"})
		generate_files @user
		require_login
	end

	describe "listing recent file" do

		it "should list recents file for the generic user" do
			get :recents, format: :json

			json = get_json
			json["success"].should be_true
			json["files"].size.should == 20
			# => On vérifie que les dates de chaque fichier sont exclusivement entre aujourd'hui et il y a 20 jours
			json["files"].each do | file |
				now = Time.now
				back_in_twenty_days = 20.days.ago
				time = Time.parse(file["last_update"])
				time.should <= now
				time.should >= back_in_twenty_days
			end
		end

		it "should return an empty array" do
			create_user({login: "NoRootFolder", password: "NoRoot", email: "noRoot@woda-serveur.com"})

			get :recents, format: :json
			json = get_json
			json["success"].should be_true
			json["files"].size.should == 0
		end

		it "should not list recents file when logged out" do
			session[:user] = nil
			get :recents, format: :json
			json = get_json
			json["success"].should be_false
			json["error"].should match /not_logged_in/
		end

	end

	# # # # list # # # #
	# list de fichier correctement retourné
	# liste de fichiers sans param = tous les fichiers
	# liste de fichiers avec des sous dossiers/sous fichiers
	# doit fail si le param id est invalide (id: hegfruyegf)
	# si param(id) == file.id retourn la description d'un fichier
	# si param(id) == folder.id retourn la liste de fichier depuis un dossier
	# si mauvais id retourne file not found
	# doit retourner success = true
	# doit retourner la liste de fichiers ou la description d'un dossier dans { folder: ici, success: true }
	# doit retourner la description d'un ficheir dans { file: ici, success: true }
	# si pas de fichiers doit juste retourner le dossier racine et rien d'autre du coup


	describe "listing all files" do
		
	end

end
