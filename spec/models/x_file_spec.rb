require 'spec_helper'

#
# Doit etre testé
#
# # # # children # # # #
# doit retourner la liste des sous-dossiers uniquement
# ne doit pas retourner de sous fichiers
#
# # # # files # # # #
# doit retourner la liste des sous-fichiers uniquement
# ne doit pas retourner de sous-dossiers
#
# # # # delete # # # #
# doit delete le fichier/dossier courant
# doit delete tous les sous-dossiers/fichiers si self est un folder et donc a plusieurs x_files
# doit delete tous les content qui ont besoin de l'être (== content plus référencé dans aucun autre fichier)
#
# # # # description # # # #
# si folder doit retourner = { id: self.id, name: self.name, public: self.public, favorite: self.favorite, last_update: self.last_update }
# si fichier doit retourner = 
#        { 
#          id: self.id, name: self.name, last_update: self.last_update, type: File.extname(self.name),
#          size: self.size, part_size: XFile.part_size, uploaded: self.uploaded, public: self.public, 
#          shared: self.uuid != nil, downloads: self.downloads, favorite: self.favorite
#        }
#
# # # # self.part_size # # # #
# ne doit pas etre testé
#
# # # # size # # # #
# si folder doit retourner la taille du content du premier fichier dans la liste
# si fichier doit retourner la taille du content
#
# # # # to_json # # # #
# doit retourner les params 'size' et 'part_size' dans un JSON
#
# # # # content # # # #
# doit retourner nil si pas de content_hash
# doit retourner un content correspondant au content_hash
#
# # # # content= arg # # # #
# doit setter le self.content_hash avec l'argument.content_hash
# si pas d'argument alors selt.content_hash = nil


describe XFile do
end
