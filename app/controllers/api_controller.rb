class ApiController < ApplicationController
  
  def list
    # Folder 1
    file_01 = {name: "Rapport", type: ".doc", last_updated: "03/03/2013 22:42:42"}
    file_02 = {name: "Rapport", type: ".doc", last_updated: "03/04/2013 18:21:21"}
    file_03 = {name: "Liste_films", type: ".txt", last_updated: "02/12/2013 22:42:34"}
    file_04 = {name: "Winrar_Install", type: ".exe", last_updated: "03/21/2013 15:05:12"}
    
    files_list_01 = [file_01, file_02, file_03, file_04]
    
    folder_01 = {name: "", full_path: "/", last_updated: "03/21/2013 15:05:12", files: files_list_01}
    
    # Folder 2
    file_01 = {name: "TBBT_S06E13_VOSTFR", type: ".avi", last_updated: "03/03/2013 22:42:42"}
    file_02 = {name: "TBBT_S06E13_VOSTFR", type: ".avi", last_updated: "03/04/2013 18:21:21"}
    file_03 = {name: "TBBT_S06E14_VOSTFR", type: ".avi", last_updated: "02/12/2013 22:42:34"}
    
    files_list_02 = [file_01, file_02, file_03]
    
    folder_02 = {name: "TBBT", full_path: "/Series/TBBT", last_updated: "03/21/2013 15:05:12", files: files_list_02}
    
    # Folder 3
    file_01 = {name: "Spartacus_S03E06_VOSTFR", type: ".avi", last_updated: "03/03/2013 22:42:42"}
    file_02 = {name: "Spartacus_S03E07_VOSTFR", type: ".avi", last_updated: "03/04/2013 18:21:21"}
    file_03 = {name: "Spartacus_S03E08_VOSTFR", type: ".avi", last_updated: "02/12/2013 22:42:34"}
    
    files_list_03 = [file_01, file_02, file_03]
    
    folder_03 = {name: "Spartacus", full_path: "/Series/Spartacus", last_updated: "03/21/2013 15:05:12", files: files_list_02}
    
    # Folder 4
    file_01 = {name: "List_series", type: ".txt", last_updated: "03/03/2013 22:42:42"}
    
    files_list_04 = [file_01]
    
    folder_04 = {name: "Series", full_path: "/Series", last_updated: "03/21/2013 15:05:12", files: files_list_02}
    
    folder_list = [folder_01, folder_02, folder_03, folder_04]
    @result = folder_list
  end
  
end
