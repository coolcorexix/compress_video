on run {input}
	-- Get the input file
	set inputFile to POSIX path of (item 1 of input)
	
	-- Get directory and filename
	set inputDir to do shell script "dirname " & quoted form of inputFile
	set inputFilename to do shell script "basename " & quoted form of inputFile
	
	-- Create output filename
	set outputFile to inputDir & "/compressed_" & inputFilename
	
	-- Create and show progress dialog
	set progress total steps to 100
	set progress description to "Compressing video..."
	set progress additional description to "This may take several minutes"
	
	
	-- Create a temporary file for progress
	set progressFile to do shell script "mktemp"
	
	-- Create the ffmpeg command with progress monitoring
	set ffmpegCmd to "/opt/homebrew/bin/ffmpeg -i " & quoted form of inputFile & " -progress " & quoted form of progressFile & " -vcodec libx264 -crf 28 " & quoted form of outputFile & " &>/dev/null"
	display dialog "ffmpeg command: " & ffmpegCmd buttons {"OK"} default button "OK"
	-- Create a handler for duration extraction
	set durationCmd to "/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 " & quoted form of inputFile & " | sed 's/\\./,/'"
	
	try
		-- Get video duration
		set videoDuration to do shell script durationCmd
		set totalDuration to videoDuration as number
		-- Create a temporary file for storing the PID
		set tempPIDFile to do shell script "mktemp"
		
		-- Start compression with progress monitoring
		do shell script ffmpegCmd & " & echo $! > " & quoted form of tempPIDFile & " & "
		set pid to do shell script "cat " & quoted form of tempPIDFile
		display dialog "Compression started with PID: " & pid buttons {"OK"} default button "OK"
		repeat
			set currentTimeCmd to "grep 'out_time_ms' " & quoted form of progressFile & " | tail -n 1 | cut -d '=' -f 2"
			-- Get current time from ffmpeg progress
			set currentTime to do shell script "grep 'out_time_ms' " & quoted form of progressFile & " | tail -n 1 | cut -d '=' -f 2"
			if currentTime is not "" then
				-- won't be visible if Do not disturb is enabled
			-- can not change icon consider use terminal-notifier
			display notification with title "Compression in Progress: " & ((round ((currentTime as number) / 10000 / totalDuration) rounding down) as string) & "%" subtitle "Please wait..."
			end if
			
			-- Check if process is still running
			try
				do shell script "ps -p " & pid
			on error
				
				exit repeat
			end try
			
			delay 1
		end repeat

		-- Calculate original and new file sizes
		set originalSize to do shell script "stat -f%z " & quoted form of inputFile & " 2>/dev/null || stat --format=%s " & quoted form of inputFile
		set newSize to do shell script "stat -f%z " & quoted form of outputFile & " 2>/dev/null || stat --format=%s " & quoted form of outputFile
		set sizeReduction to 100 - ((newSize as number) * 100 / (originalSize as number))
		
		-- Display size reduction
		display dialog "New Size: " & newSize as string &  " Size reduction: " & (sizeReduction as string) & "%" buttons {"OK"} default button "OK"

		-- Create a dictionary with the JSON object
		set appUploadFileSizeDict to {slack:1024, zalo:1024, telegram:2048, messenger:80}
		-- Create a list with the JSON object
		set appUploadFileSizeList to {{"slack", 1024}, {"zalo", 1024}, {"telegram", 2048}, {"messenger", 80}}
		-- Get all installed application names
		set installedApps to do shell script "ls /Applications"
		set installedApps to paragraphs of installedApps
		-- Initialize an empty list for apps that can upload the file
		set appList to {}
		-- Iterate through the list and check if the app is installed and can upload the file
		repeat with appInfo in appUploadFileSizeList
			set {appName, maxSize} to appInfo
			if (installedApps as string) contains (appName) then
				if newSize as number <= maxSize then
					set end of appList to appName
				end if
			end if
		end repeat
		display dialog "Apps that can be used to share compressed file: " & appList buttons {"OK"} default button "OK"		
	on error errMsg
		
		display dialog "Error compressing video: " & errMsg buttons {"OK"} default button "OK" with icon stop
	end try
end run