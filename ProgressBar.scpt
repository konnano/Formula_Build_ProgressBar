set f to ""
repeat
	display dialog "Formula" default answer "llvm"
	set llvm to text returned of result
	
	try
		set f to do shell script "ls $HOME/Library/Logs/Homebrew/" & llvm & "/02.cmake 2>/dev/null"
	on error
		display dialog "File not exist : $HOME/Library/Logs/Homebrew/" & llvm & "/02.cmake"
	end try
	
	if not f is "" then
		exit repeat
	end if
end repeat

do shell script "tail -2 $HOME/Library/Logs/Homebrew/" & llvm & "/02.cmake 2>/dev/null|head -c 6"
if result is "[100%]" then
	return
end if

set progress total steps to 100
set y to 0
repeat
	do shell script "sed  -E '/.*make: \\*+/!d' \\
                               $HOME/Library/Logs/Homebrew/" & llvm & "/02.cmake 2>/dev/null"
	if not result is "" then
		display dialog llvm & " : make: Error..."
		exit repeat
	end if
	do shell script "tail $HOME/Library/Logs/Homebrew/" & llvm & "/02.cmake 2>/dev/null|
                               sed -E '/^\\[.+]/!d;s/\\[ *([0-9]+)%].+/\\1/'"
	set str to words of result
	repeat with a in str
		set int to a as number
		if int > y then
			set y to int
		end if
	end repeat
	set progress completed steps to y
	if y = 100 then
		exit repeat
	end if
	delay 1
end repeat
