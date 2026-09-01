-- Ficus for macOS. Blocks social media sites device-wide via /etc/hosts.
--
-- To run it: open this file in Script Editor (double-click it) and hit Run.
-- To get something double-clickable instead, open Terminal in this folder and run:
--   osacompile -o Ficus.app Ficus.applescript
-- Keep Ficus.app in this same folder afterward, since it needs the .sh files next to it.

on scriptDir()
	return do shell script "dirname " & quoted form of (POSIX path of (path to me))
end scriptDir

on run
	my mainMenu()
end run

on mainMenu()
	set dir to my scriptDir()
	set statusText to do shell script "/bin/bash " & quoted form of (dir & "/ficus-status.sh")

	if statusText is "blocked" then
		set statusLabel to "Ficus — currently BLOCKED"
		set toggleLabel to "Unblock Now"
	else
		set statusLabel to "Ficus — currently NOT BLOCKED"
		set toggleLabel to "Block Now"
	end if

	set dialogResult to display dialog statusLabel & return & return & "Turning this on or off will ask for your Mac password, since it edits /etc/hosts." buttons {"Edit Sites", "Quit", toggleLabel} default button toggleLabel cancel button "Quit"
	set choice to button returned of dialogResult

	if choice is "Quit" then
		return
	else if choice is "Edit Sites" then
		my editSites()
		my mainMenu()
	else
		if statusText is "blocked" then
			try
				do shell script "/bin/bash " & quoted form of (dir & "/ficus-apply.sh") & " disable" with administrator privileges
			on error errText number errNum
				if errNum is not -128 then display alert "Ficus" message errText
			end try
		else
			set checkedText to do shell script "/bin/bash " & quoted form of (dir & "/ficus-domains.sh") & " checked"
			set checkedList to paragraphs of checkedText
			if (count of checkedList) is 0 then
				display alert "Ficus" message "Check at least one site under Edit Sites first."
				my mainMenu()
				return
			end if
			set domainArgs to ""
			repeat with d in checkedList
				set domainArgs to domainArgs & " " & quoted form of d
			end repeat
			try
				do shell script "/bin/bash " & quoted form of (dir & "/ficus-apply.sh") & " enable" & domainArgs with administrator privileges
			on error errText number errNum
				if errNum is not -128 then display alert "Ficus" message errText
			end try
		end if
		my mainMenu()
	end if
end mainMenu

on editSites()
	set dir to my scriptDir()
	set allText to do shell script "/bin/bash " & quoted form of (dir & "/ficus-domains.sh") & " list"
	set allList to paragraphs of allText
	set checkedText to do shell script "/bin/bash " & quoted form of (dir & "/ficus-domains.sh") & " checked"
	set checkedList to paragraphs of checkedText

	set pickResult to choose from list allList with prompt "Choose which sites to block:" default items checkedList with multiple selections allowed

	if pickResult is not false then
		set selArgs to ""
		repeat with d in pickResult
			set selArgs to selArgs & " " & quoted form of (d as text)
		end repeat
		do shell script "/bin/bash " & quoted form of (dir & "/ficus-domains.sh") & " set-checked" & selArgs
	end if

	set addResult to display dialog "Add another site (leave blank to skip):" default answer "" buttons {"Skip", "Add"} default button "Add" cancel button "Skip"
	if button returned of addResult is "Add" then
		set addAnswer to text returned of addResult
		if addAnswer is not "" then
			do shell script "/bin/bash " & quoted form of (dir & "/ficus-domains.sh") & " add " & quoted form of addAnswer
		end if
	end if
end editSites
