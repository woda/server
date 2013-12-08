require 'spec_helper'

# doit être testé:
#
# # # # all # # # #
# login required
# 
# # # #  complete_upload # # # #
# doit supprimer toutes les parties de fichiers correspondant aux paramètres (id fichier + id part)
# doit setter le booleen uploaded à true pour TOUS les fichiers qui référence ce content
# doit mettre à jour le last_update de TOUS les dossiers parents de TOUS les fichiers jusqu'au dossier racine
# retourne true if upload finished
# retourner false if upload not finished
#
# # # # update_and_save # # # #
# doit prendre en parametre un xfile
# doit fail si pas de parametre
# doit fail si parametre == nil
# doit mettre a jour le last_update du fichier courant
# doit mettre a jour le last_update du dosser parent et de tous les autres sur-dossiers-sur-parents
# ne doit PAS mettre a jour le last_update des fichiers présents dans le même dossier
# ne doit PAS mettre a jour le last_update des fichiers présents dans les sous-dossier
# ne doit PAS fail si un fichier n'a pas de parent
#
# # # # update_and_delete # # # #
# doit prendre en parametre un xfile
# doit fail si pas de parametre
# doit fail si parametre == nil
# doit mettre a jour le last_update du dosser parent et de tous les autres sur-dossiers-sur-parents
# doit supprimer le dossier courant
# doit supprimer TOUT les sous fichiers/dossiers du dossier courant (testé de faire un list/id d'un fichier délété pour vérifier)
# ne doit PAS mettre a jour le last_update des fichiers présents dans le même dossier
# ne doit PAS fail si un fichier n'a pas de parent
#
# # # # create_folder # # # #
# doit fail si pas de param(filename)
# doit fail si filename incorrect
# doit fail si le folder n'a pas été créé (je sais pas trop comment tester ça)
# doit créer un dossier
# doit retourner un dossier déjà créé si demandé. pas de modification des sous-fichiers/dossiers
# doit mettre à jour le last_update du dosser parent et de tous les autres sur-dossiers-sur-parents
# doit retourner  { folder: folder.description, success: true }
#
# # # # put # # # #
# doit fail si le param filename est manquant
# doit fail si le param filename est invalide
# doit fail si le param content_hash est manquant
# doit fail si le param content_hash est invalide
# doit fail si le param size est manquant
# doit fail si le param size est invalide
# doit fail si le fichier existe deja
#
# si new file + new content then
### => return { success: true, uploaded: true, file: file.description, needed_parts: [0,1,...], part_size: XFile.part_size (5mb) }
# si new file + existing content + first_file.uploaded:true then
### => return { success: true, uploaded: false, file: file.description }
# si new file + existing content + first_file.uploaded:false then
### => { success: true, uploaded: true, file: file.description, needed_parts: [0,1,...], part_size: XFile.part_size (5mb) }
#
#
# # # # upload_part # # # #
# doit fail si le param id est manquant
# doit fail si le param id est invalide (id: hegfruyegf)
# doit fail si le param id est invalide (file not found)
# doit fail si le param id est invalide (file is a folder)
# doit fail si le param part est manquant
# doit fail si le param part est invalide 
# doit fail si le content du fichier est invalide (je sais pas comment le tester)
# doit fail si la partie envoyé est trop grande pour le fichier (part > (f.content.size/XFile.part_size) )
# doit fail si la partie envoyé est trop longue
# doit fail si la partie envoyé est trop courte
# doit stocker la partie du fichier dans le serveur (je sais pas comment le tester)
# doit stocker la partie du fichier encryptée (je sais pas comment le tester)
# doit faire tout ce que fait la methode complete_upload
# doit retourner { success: true }
#
# # # # needed_parts # # # #
# doit fail si le param id est manquant
# doit fail si le param id est invalide (id: hegfruyegf)
# doit fail si le param id est invalide (file not found)
# doit fail si le param id est invalide (file is a folder)
# doit fail si le fichier n'a pas de content (File content found)
# SI et seulement SI toutes las parties du fichier ont été uploader la methode doit:
### doit retourner { success: true, uploaded: true, needed_parts: [] }
# SINON 
## doit retourner la liste des parties manquantes / qui restent à uploaded
## doit retourner { success: true, uploaded: false, needed_parts: [0, 1, 2, ...] }
#
# # # # change # # # # 
# doit faire ce que fais delete ET put
# doit fail si l'un des params est invalide ou manquant.
#
# # # # delete # # # #
# doit fail si le param id est manquant
# doit fail si le param id est invalide (id: hegfruyegf)
# doit fail si le param id est invalide (file not found)
# doit fail si le param id est invalide (file is the root folder)
# doit delete des dossiers
# doit delete des fichiers
# doit delete des dossiers et tous les sous-dossiers/fichiers
# doit retourner { success: true }
#
# # # # get # # # #
# doit fail si le param id est manquant
# doit fail si le param id est invalide (id: hegfruyegf)
# doit fail si le param id est invalide (file not found)
# doit fail si le param id est invalide (file is a folder)
# doit fail si le param part est manquant
# doit fail si le param part est invalide (part: hegfruyegf)
# doit fail si le param part est invalide (key path not found)
# doit fail si le content du fichier est invalide (je sais pas comment le tester)
# doit fail le file.uploaded == false
# if part == 0 then file.downloads += 1
# doit retourner UNIQUEMENT la data du fichier décrypté : "bonjour"
#
# # # # last_update # # # #
# ne doit PAS fail si le param id est manquant
# doit fail si le param id existe et est invalide (id: hegfruyegf)
# doit fail si le param id existe et est invalide (file not found)
# doit retourner { last_update: file/folder.last_update, success: true }

describe SyncController do
end

