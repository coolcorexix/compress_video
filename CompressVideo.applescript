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
			
			-- Get current time from ffmpeg progress
			set currentTime to do shell script "grep 'out_time_ms' " & quoted form of progressFile & " | tail -n 1 | cut -d '=' -f 2"
			-- won't be visible if Do not disturb is enabled
			-- can not change icon consider use terminal-notifier
			display notification with title "Compression in Progress: " & ((round ((currentTime as number) / 10000 / totalDuration) rounding down) as string) & "%" subtitle "Please wait..." sound name "Glass"
			-- Check if process is still running
			try
				do shell script "ps -p " & pid
			on error
				
				exit repeat
			end try
			
			delay 1
		end repeat
		
		display dialog "Video compression complete!" buttons {"OK"} default button "OK"
		
	on error errMsg
		display dialog "Error compressing video: " & errMsg buttons {"OK"} default button "OK" with icon stop
	end try
end run