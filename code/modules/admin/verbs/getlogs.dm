//This proc allows download of past server logs saved within the data/logs/ folder.
/client/proc/getserverlogs()
	set name = "Get Server Logs"
	set desc = "View/retrieve logfiles."
	set category = "Admin"
	if(!check_rights(R_SERVER))
		return

	browseserverlogs()

/client/proc/getcurrentlogs()
	set name = "Get Current Logs"
	set desc = "View/retrieve logfiles for the current round."
	set category = "Admin"

	browseserverlogs("[GLOB.log_directory]/")

/client/proc/browseserverlogs(path = "data/logs/")
	if(IsAdminAdvancedProcCall())
		log_admin_private("BROWSEFILES: Admin proc call blocked")
		message_admins("BROWSEFILES: Admin proc call blocked")
		return null

	path = browse_files(path)
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	switch(alert("View (in game), Open (in your system's text editor), or Download?", path, "View", "Open", "Download"))
		if ("View")
			src << browse(HTML_SKELETON("<pre style='word-wrap: break-word;'>[html_encode(rustg_file_read(path))]</pre>"), list2params(list("window" = "viewfile.[path]")))
		if ("Open")
			src << run(file(path))
		if ("Download")
			src << ftp(file(path))
		else
			return
	to_chat(src, "Attempting to send [path], this may take a fair few minutes if the file is very large.")
	return
