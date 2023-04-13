set f to ""
repeat
	display dialog "Formula" default answer ""
	set m to text returned of result
	
	try
		set f to do shell script "ls $HOME/Library/Logs/Homebrew/" & m & "/02.cmake 2>/dev/null"
	on error
		display dialog "File not exist : $HOME/Library/Logs/Homebrew/" & m & "/02.cmake"
	end try
	
	if not f is "" then exit repeat
end repeat

do shell script "tail -2 $HOME/Library/Logs/Homebrew/" & m & "/02.cmake 2>/dev/null | head -c 6"
if result is "[100%]" then return

set progress total steps to 100
set y to 0
repeat
	do shell script "sed  -E '/.*make: \\*+/!d' \\
                               $HOME/Library/Logs/Homebrew/" & m & "/02.cmake 2>/dev/null"
	if not result is "" then
		display dialog m & " : make: Error..."
		exit repeat
	end if
	do shell script "tail $HOME/Library/Logs/Homebrew/" & m & "/02.cmake 2>/dev/null |
                               sed -E '/^\\[.+]/!d;s/\\[ *([0-9]+)%].+/\\1/'"
	set str to words of result
	repeat with a in str
		set int to a as number
		if int > y then set y to int
	end repeat
	set progress completed steps to y
	if y = 100 then
		repeat
			do shell script "tail $HOME/Library/Logs/Homebrew/" & m & "/02.cmake 2>/dev/null \\
                                             >$HOME/Library/Logs/Homebrew/" & m & "/diff1.txt"
			delay 5
			do shell script "tail $HOME/Library/Logs/Homebrew/" & m & "/02.cmake 2>/dev/null \\
                                             >$HOME/Library/Logs/Homebrew/" & m & "/diff2.txt"
			do shell script "diff $HOME/Library/Logs/Homebrew/" & m & "/diff1.txt \\
                                             $HOME/Library/Logs/Homebrew/" & m & "/diff2.txt >/dev/null 2>&1 || echo 1"
			if result is "" then
				exit repeat
			else
				do shell script "tail -2 $HOME/Library/Logs/Homebrew/" & m & "/02.cmake 2>/dev/null |
                                                    sed -E '/^\\[.+]/!d;s/\\[ *([0-9]+)%].+/\\1/'"
				set s to result as number
				if y > s then
					set y to s
					exit repeat
				end if
			end if
		end repeat
	end if
	if y = 100 then exit repeat
	delay 1
end repeat

try
	do shell script "rm $HOME/Library/Logs/Homebrew/" & m & "/diff1.txt 2>/dev/null \\
                               $HOME/Library/Logs/Homebrew/" & m & "/diff2.txt 2>/dev/null"
end try
