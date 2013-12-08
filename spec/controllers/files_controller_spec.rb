require 'spec_helper'

describe FilesController do
	render_views
	DataMapper::Model.raise_on_save_failure = true

	before :all do
		db_clear
		put_description
	end

	before :each do
		User.each do | user |
			if user.login != "Testeur"
				user.x_files.destroy!
				user.destroy!
			end
		end

		u = User.first login: "Testeur"

		if !u
			@user = create_user({login: "Testeur", password: "Testing42", email: "testeur@woda-serveur.com"})
			generate_files @user
		else
			session[:user] = u.id
		end
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

	describe "listing all files" do
		
		##
		# => HUGE CONTEXT !!!
		##
		it "should list all the file without params" do

			get :list, format: :json
			json = get_json
			json["success"].should be_true

			# => Checking the root folder
			json["folder"]["name"].should match /\//
			# => Root folder have to contain only one file, RootInFolder
			json["folder"]["files"].size.should == 1
			json["folder"]["files"][0]["name"].should match /FileInRoot.txt/

			# => Root folder should have one folder named Movies
			json["folder"]["folders"].size.should == 1
			movies = json["folder"]["folders"][0]
			movies["name"].should match /Movies/

			# => Movies should contain 2 folders and 4 files in it
			movies["folders"].size.should == 2
			movies["files"].size.should == 4

			# => Checking files
			movies["files"][0]["name"].should match /Youtube_Funny_Jokes.flv/
			movies["files"][1]["name"].should match /Clip_Video_Teletubies.mpeg/
			movies["files"][2]["name"].should match /Power_Rangers.flv/
			movies["files"][3]["name"].should match /Pokemon.flv/

			# => Checking folders

			# => MKV
			movies["folders"][0]["name"].should match /MKV/
			mkv = movies["folders"][0]
			# => It should contains 2 other folders
			mkv["folders"].size.should == 2
			mkv["folders"][0]["name"].should match /English/
			english = mkv["folders"][0]

			# => English folder should contain 4 files and 0 folders
			english["folders"].size.should == 0
			english["files"].size.should == 4

			english["files"][0]["name"].should match /Avatar_\(2010\).mkv/
			english["files"][1]["name"].should match /The_Lord_Of_The_Ring.mkv/
			english["files"][2]["name"].should match /Inception.mkv/
			english["files"][3]["name"].should match /Gravity.mkv/

			mkv["folders"][1]["name"].should match /French/
			french = mkv["folders"][1]

			# => French Should contain 4 files and 0 folders
			french["folders"].size.should == 0
			french["files"].size.should == 4

			french["files"][0]["name"].should match /Asterix_Mission_Cleopatre.mkv/
			french["files"][1]["name"].should match /Brice_De_Nice.mkv/
			french["files"][2]["name"].should match /Jeux_Enfant.mkv/
			french["files"][3]["name"].should match /Asterix_Chez_Les_Bretons.mkv/

			# => AVI
			movies["folders"][1]["name"].should match /AVI/
			avi = movies["folders"][1]
			# => It should contains 2 other folders
			avi["folders"].size.should == 2
			avi["folders"][0]["name"].should match /English/
			english = avi["folders"][0]

			# => English folder should contain 4 files and 0 folders
			english["folders"].size.should == 0
			english["files"].size.should == 4

			english["files"][0]["name"].should match /Harry_Potter_The_Chamber_Of_Secret.avi/
			english["files"][1]["name"].should match /Xmen_Origins.avi/
			english["files"][2]["name"].should match /Gravity.avi/
			english["files"][3]["name"].should match /Batman_Begins.avi/

			avi["folders"][1]["name"].should match /French/
			french = avi["folders"][1]

			# => French Should contain 4 files and 0 folders
			french["folders"].size.should == 0
			french["files"].size.should == 4

			french["files"][0]["name"].should match /Asterix_Le_Gaulois.avi/
			french["files"][1]["name"].should match /Qui_A_Tue_Pamela_Rose.avi/
			french["files"][2]["name"].should match /OSS_117_Le_Caire_Nid_Despion.avi/
			french["files"][3]["name"].should match /OSS_117_A_Rio.avi/
		end

		it "should return folder description with :id == folder" do
			folder = Folder.first name: "MKV"
			get :list, id: folder.id, format: :json
			json = get_json
			json["success"].should be_true
			json["file"].should be_nil
			json["folder"].should_not be_nil
			json["folder"]["name"].should match /MKV/ 
			json["folder"]["folders"].size.should == 2
			json["folder"]["folders"][0]["files"].size.should == 4
			json["folder"]["folders"][1]["files"].size.should == 4

		end

		it "should return file description with :id == file" do
			file = XFile.first name: "Gravity.mkv"
			get :list, id: file.id, format: :json
			json = get_json
			json["success"].should be_true
			json["folder"].should be_nil
			json["file"].should_not be_nil
			json["file"]["name"].should match /Gravity.mkv/
		end

		it "should fail with bad id format" do
			get :list, id: "aksjdk", format: :json
			json = get_json
			json["success"].should be_false
			json["error"].should_not be_nil
		end

		it "should fail with an non-existing id" do
			get :list, id: 4242, format: :json
			json = get_json
			json["success"].should be_false
			json["error"].should match /folder_not_found/
		end

		it "should only root file" do
			u = create_user({login: "OnlyRoot", password: "424242", email: "onlyroot@woda-serveur.com"})

			get :list, format: :json
			json = get_json
			json["success"].should be_true
			json["folder"].should_not be_nil
			json["folder"]["name"].should match /\//
			json["folders"].should be_nil
			json["files"].should be_nil
		end

		it "should not list files when not logged" do
			session[:user] = nil
			get :list, format: :json
			json = get_json
			json["success"].should be_false
			json["error"].should match /not_logged_in/
		end
	end

	describe "favorites files" do

		it "should set/unset file in favorite" do
			file = XFile.first name: "Gravity.mkv"

			post :set_favorite, id: file.id, favorite: true, format: :json
			json = get_json
			json["success"].should be_true
			json["file"].should_not be_nil
			json["folder"].should be_nil
			json["file"]["name"].should match /Gravity.mkv/
			json["file"]["favorite"].should be_true

			post :set_favorite, id: file.id, favorite: false, format: :json
			json = get_json
			json["success"].should be_true
			json["file"].should_not be_nil
			json["folder"].should be_nil
			json["file"]["name"].should match /Gravity.mkv/
			json["file"]["favorite"].should be_false
		end

		it "should set/unset folder in favorite" do
			folder = Folder.first name: "MKV"

			post :set_favorite, id: folder.id, favorite: true, format: :json
			json = get_json
			json["success"].should be_true
			json["folder"].should be_nil
			json["file"].should_not be_nil
			json["file"]["name"].should match /MKV/
			json["file"]["favorite"].should be_true


			post :set_favorite, id: folder.id, favorite: false, format: :json
			json = get_json
			json["success"].should be_true
			json["folder"].should be_nil
			json["file"].should_not be_nil
			json["file"]["name"].should match /MKV/
			json["file"]["favorite"].should be_false
		end

		it "should fail if the user does not own the file/folder" do
			back = session[:user]
			u = create_user({login: "Owner", password: "424242", email: "owner@woda-serveur.com"})
			u.create_folder "MKV"
			u.create_file "Gravity.mkv"
			session[:user] = back

			folder = Folder.first name: "MKV", user: u
			post :set_favorite, id: folder.id, favorite: true, format: :json
			json = get_json
			json["success"].should be_false
			json["error"].should match /file_not_found/
			
			file = XFile.first name: "Gravity.mkv", user: u
			post :set_favorite, id: file.id, favorite: true, format: :json
			json = get_json
			json["success"].should be_false
			json["error"].should match /file_not_found/
		end

		it "should not set favorite if the id does not exist or is invalid" do
			post :set_favorite, id: "424242", favorite: true, format: :json
			json = get_json
			json["error"].should match /file_not_found/

			post :set_favorite, id: "aksjds", favorite: true, format: :json
			json = get_json
			json["success"].should be_false
		end

		it "should fail if params is missing" do
			# => Both
			lambda {post :set_favorite, format: :json}.should raise_error

			# => id
			lambda {post :set_favorite, favorite: true, format: :json}.should raise_error

			# => favorite
			post :set_favorite, id: 13, format: :json
			json = get_json
			json["error"].should match /missing_params/
		end

		it "should fail setting favorite if not logged" do
			back = session[:user]
			session[:user] = nil
			post :set_favorite, id: 13, favorite: true, format: :json
			json = get_json
			json["error"].should match /not_logged_in/
		end

		it "should return favorite list" do
			folder = Folder.first name: "AVI"
			post :set_favorite, id: folder.id, favorite: true

			file = XFile.first name: "Gravity.avi"
			post :set_favorite, id: file.id, favorite: true

			get :favorites, format: :json
			json = get_json
			json["success"].should be_true
			json["files"].size.should == 2
			json["files"][0]["name"].should match /AVI/
			json["files"][1]["name"].should match /Gravity.avi/

			post :set_favorite, id: folder.id, favorite: false
			post :set_favorite, id: file.id, favorite: false
		end

		it "should return an empty list" do
			get :favorites, format: :json
			json = get_json
			json["success"].should be_true
			json["files"].size.should == 0
		end

		it "should not return favorite list when not logged" do
			back = session[:user]
			session[:user] = nil
			get :favorites, format: :json
			json = get_json
			json["error"].should match /not_logged_in/
		end
	end

	describe "public files" do
		
		it "should set/unset folder to public" do
			folder = Folder.first name: "Movies"
			post :set_public, id: folder.id, public: true, format: :json
			json = get_json
			json["success"].should be_true
			json["file"].should be_true
			json["file"]["name"].should match /Movies/
			json["file"]["public"].should be_true

			post :set_public, id: folder.id, public: false, format: :json
			json = get_json
			json["success"].should be_true
			json["file"].should be_true
			json["file"]["name"].should match /Movies/
			json["file"]["public"].should be_false
		end

		it "should set/unset file to public" do
			file = XFile.first name: "Gravity.mkv"
			post :set_public, id: file.id, public: true, format: :json
			json = get_json
			json["success"].should be_true
			json["file"].should be_true
			json["file"]["name"].should match /Gravity.mkv/
			json["file"]["public"].should be_true

			post :set_public, id: file.id, public: false, format: :json
			json = get_json
			json["success"].should be_true
			json["file"].should be_true
			json["file"]["name"].should match /Gravity.mkv/
			json["file"]["public"].should be_false	
		end

		it "should fail if the user does not own the file/folder" do
			back = session[:user]
			u = create_user({login: "Owner", password: "424242", email: "owner@woda-serveur.com"})
			u.create_folder "MKV"
			u.create_file "Gravity.mkv"
			session[:user] = back

			folder = Folder.first name: "MKV", user: u
			post :set_public, id: folder.id, public: true, format: :json
			json = get_json
			json["success"].should be_false
			json["error"].should match /file_not_found/
			
			file = XFile.first name: "Gravity.mkv", user: u
			post :set_public, id: file.id, public: true, format: :json
			json = get_json
			json["success"].should be_false
			json["error"].should match /file_not_found/
		end

		it "should not set public if the id does not exist or is invalid" do
			post :set_public, id: "424242", public: true, format: :json
			json = get_json
			json["error"].should match /file_not_found/

			post :set_public, id: "aksjds", public: true, format: :json
			json = get_json
			json["success"].should be_false
		end	

		it "should fail if params is missing" do
			# => Both
			lambda {post :set_public, format: :json}.should raise_error

			# => id
			lambda {post :set_public, favorite: true, format: :json}.should raise_error

			# => favorite
			post :set_favorite, id: 13, format: :json
			json = get_json
			json["error"].should match /missing_params/
		end

		it "should fail setting favorite if not logged" do
			back = session[:user]
			session[:user] = nil
			post :set_public, id: 13, public: true, format: :json
			json = get_json
			json["error"].should match /not_logged_in/
		end		

		it "should return public list" do
			folder = Folder.first name: "AVI"
			post :set_public, id: folder.id, public: true

			file = XFile.first name: "Gravity.avi"
			post :set_public, id: file.id, public: true

			get :public, format: :json
			json = get_json
			json["success"].should be_true
			json["files"].size.should == 2
			json["files"][0]["name"].should match /AVI/
			json["files"][1]["name"].should match /Gravity.avi/

			post :set_public, id: folder.id, public: false
			post :set_public, id: file.id, public: false
		end

		it "should return an empty list" do
			get :public, format: :json
			json = get_json
			json["success"].should be_true
			json["files"].size.should == 0
		end

		it "should not return public list when not logged" do
			back = session[:user]
			session[:user] = nil
			get :public, format: :json
			json = get_json
			json["error"].should match /not_logged_in/
		end	

	end

	describe "link and sharing" do

		it "should generate link for folder" do
			folder = Folder.first name: "Movies"
			post :link, id: folder.id, format: :json
			json = get_json
			json["success"].should be_true
			json["file"].should_not be_nil
			json["file"]["name"].should match /Movies/
			json["file"]["folder"].should be_true
			json["file"]["shared"].should be_true
			json["link"].should_not be_nil
		end


		it "should generate link for file" do
			file = XFile.first name: "Gravity.avi"
			post :link, id: file.id, format: :json
			json = get_json
			json["success"].should be_true
			json["file"].should_not be_nil
			json["file"]["name"].should match /Gravity.avi/
			json["file"]["folder"].should be_false
			json["file"]["shared"].should be_true
			json["link"].should_not be_nil
		end

		it "should faild without param" do
			lambda {get :link, format: :json}.should raise_error
		end

		it "should fail with bad id or invalid id" do
			post :link, id: "asdjawdwa", format: :json
			json = get_json
			json["success"].should be_nil

			post :link, id: 4599, format: :json
			json = get_json
			json["success"].should be_false
			json["error"].should match /file_not_found/
		end

		it "should fail generating link when not logged in" do
			session[:user] = nil
			post :link, id: 23, format: :json
			json = get_json
			json["success"].should be_false
			json["error"].should match /not_logged_in/
		end

		it "should return all shared files" do
			u = create_user({login: "SharedFile", password: "password", email: "SharedFile@woda-serveur.com"})
			generate_files u
			folder = Folder.first name: "AVI", user: u
			file = XFile.first name: "Gravity.mkv", user: u
			post :link, id: folder.id, format: :json
			post :link, id: file.id, format: :json

			get :shared, format: :json
			json = get_json
			json["success"].should be_true
			json["files"].should_not be_nil
			json["files"].size.should == 2
			json["files"][0]["name"].should match /AVI/
			json["files"][0]["shared"].should be_true
			json["files"][0]["folder"].should be_true
			json["files"][1]["name"].should match /Gravity.mkv/
			json["files"][1]["shared"].should be_true
			json["files"][1]["folder"].should be_false
		end

		it "should return an empty array" do
			create_user({login: "NoSharedFile", password: "password", email: "NoSharedFile@woda-serveur.com"})

			get :shared, format: :json
			json = get_json
			json["success"].should be_true
			json["files"].should_not be_nil
			json["files"].size.should == 0
		end

		it "should not return all shared files when not logged in" do
			session[:user] = nil
			get :shared, format: :json
			json = get_json
			json["success"].should be_false
			json["error"].should match /not_logged_in/
		end

	end

	describe "downloaded files" do
		# doit retourner success: true + files: array of files
		# doit retourner les fichiers et PAS de dossiers
		# doit retourner les fichiers dans un tableau
		# doit retourner les fichiers qui ont été téléchargés au moins 1 fois ou plus.
		# doit retourner un array vide + success:true si pas de fichiers

		it "should return all files downloaded" do
			folder = Folder.first name: "MKV"
			folder.downloads = 2
			folder.save

			file = XFile.first name: "Gravity.mkv"
			file.downloads = 42
			file.save

			file = XFile.first name: "Batman_Begins.avi"
			file.downloads = 1
			file.save

			get :downloaded, format: :json
			json = get_json
			json["success"].should be_true
			json["files"].should_not be_nil
			json["files"].size.should == 2
			json["files"][0]["folder"].should be_false
			json["files"][0]["downloads"].should >= 1
			json["files"][1]["folder"].should be_false
			json["files"][1]["downloads"].should >= 1
		end

		it "should return an empty array" do
			folder = Folder.first name: "MKV"
			folder.downloads = 0
			folder.save

			file = XFile.first name: "Gravity.mkv"
			file.downloads = 0
			file.save

			file = XFile.first name: "Batman_Begins.avi"
			file.downloads = 0
			file.save

			get :downloaded, format: :json
			json = get_json
			json["success"].should be_true
			json["files"].should_not be_nil
			json["files"].size.should == 0	
		end

		it "should not return all downloaded files when not logged in" do
			session[:user] = nil
			get :downloaded, format: :json
			json = get_json
			json["success"].should be_false
			json["error"].should match /not_logged_in/
		end

	end

end
