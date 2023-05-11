use scripting additions
use framework "Foundation"
set progress total steps to 100
script scr
	property str : ""
	property pat : ".*\\[ *([0-9]+)%].*"
	property rep : "$1"
end script
set k to 0
global po, m
set ho to (path to home folder) as text
repeat
	display dialog "Formula" default answer ""
	set m to text returned of result
	tell application "System Events"
		set e to exists file ("~/Library/Logs/Homebrew/" & m & "/01.cmake")
		set f to exists file ("~/Library/Logs/Homebrew/" & m & "/02.cmake")
		set d to exists file ("~/Library/Logs/Homebrew/" & m & "/02.make")
	end tell
	if e is true then
		if f is false and d is false then display notification " configure...." with title "Wait"
		set po to POSIX path of (ho & "Library:Logs:Homebrew:" & m & ":01.cmake")
		repeat
			set g to get eof po
			delay 0.5
			read po from eof to -200
			if result contains "nettirw neeb evah selif dliuB" then
				if f is false and d is false then display notification " configure...." with title "Success"
				set k to 1
				exit repeat
			end if
			if (get eof po) = g then
				do shell script "ps aux|grep [c]make || :"
				if result is "" then
					display dialog m & " : configure : Error..."
					return
				end if
			end if
		end repeat
	else
		display dialog "File not exist : $HOME/Library/Logs/Homebrew/" & m & "/01.cmake"
	end if
	if k = 1 then exit repeat
end repeat
delay 1
tell application "System Events"
	set f to exists file ("~/Library/Logs/Homebrew/" & m & "/02.cmake")
	set d to exists file ("~/Library/Logs/Homebrew/" & m & "/02.make")
end tell
if f is false and d is false then return

if f is true then
	set e to "$HOME/Library/Logs/Homebrew/" & m & "/02.cmake"
	set d to "~/Library/Logs/Homebrew/" & m & "/03.cmake"
	set po to POSIX path of (ho & "Library:Logs:Homebrew:" & m & ":02.cmake")
else
	set e to "$HOME/Library/Logs/Homebrew/" & m & "/02.make"
	set d to "~/Library/Logs/Homebrew/" & m & "/03.make"
	set po to POSIX path of (ho & "Library:Logs:Homebrew:" & m & ":02.make")
end if

read po from eof to -200
if result contains "]%001[" then return

do shell script "sed '/.*make: \\*/!d' " & e & " 2>/dev/null"
if not result is "" then return

do shell script "sed -E '/^\\[.+]/!d;s/\\[ *([0-9]+)%].+/\\1/' " & e & " 2>/dev/null | uniq |
perl -ne '$h||=0;$h=1 if $i&&$_==0;if($h&&$_<=100){$h=0 if $_==100;next}$i=$_;END{print $i,$h}'"
if result is "" then
	return
else
	set p to words of result
	set y to item 1 of p as number
	set c to item 2 of p as number
end if
set b to 0
set num to {}
repeat
	if c = 1 then set progress completed steps to y
	set g to get eof po
	delay 0.1
	if (get eof po) > g then set num to reader_1(g)
	repeat with a in num
		set a to a as number
		if not y = 0 and a = 0 then
			set b to 1
			exit repeat
		end if
		if b = 1 or c = 1 then
			if 100 > a then
				exit repeat
			else
				set b to 0
				set c to 0
				exit repeat
			end if
		end if
		if a > y then set y to a
	end repeat
	set num to {}
	error_1()
	if result = 1 then return
	if y = 100 then
		repeat
			set g to get eof po
			delay 0.1
			tell application "System Events" to exists file (d)
			if result is true then
				exit repeat
			else
				set num to reader_1(g)
				repeat with s in num
					set s to s as number
					if y > s then
						set y to s
						set k to 0
						exit repeat
					end if
				end repeat
			end if
			if k = 0 then exit repeat
			error_1()
			if result = 1 then return
		end repeat
	end if
	set progress completed steps to y
	if y = 100 then
		delay 1
		exit repeat
	end if
end repeat

on reader_1(g)
	set num to {}
	read po from g using delimiter "
	"
	repeat with se in result
		if se contains "%] " then
			set str of scr to se
			my regex_1(scr)
			set end of num to result
		end if
	end repeat
	return num
end reader_1

on error_1()
	read po from eof to -200
	if result contains "* :ekam" then
		display dialog m & " : make : Error..."
		return 1
	end if
	return 0
end error_1

on regex_1(scr)
	set regularExpression to current application's NSRegularExpression's regularExpressionWithPattern:(pat of scr) options:0 |error|:(missing value)
	return (regularExpression's stringByReplacingMatchesInString:(str of scr) options:0 range:{location:0, |length|:count (str of scr) as text} withTemplate:(rep of scr)) as text
end regex_1
