import os


def remove_pack_from_filesyst(pack_file_path):
	check_file = os.path.isfile(pack_file_path)

	if check_file == True:
		try:
			os.remove(pack_file_path) 
			filesyst_pack_removal_status = True
			filesyst_pack_removal_msg = "Pack removed from filesystem."				
		except:
			filesyst_pack_removal_status = False
			filesyst_pack_removal_msg = "Pack could not be removed from filesystem. See logs."	
	else:
		filesyst_pack_removal_status = True
		filesyst_pack_removal_msg = "Pack removed from filesystem."	
	return filesyst_pack_removal_status, filesyst_pack_removal_msg
