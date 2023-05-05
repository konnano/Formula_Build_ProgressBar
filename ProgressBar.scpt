set k to 0
set ho to (path to home folder) as text
set progress total steps to 100
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
			delay 0.1
			read po from eof to -200
			if result contains "nettirw neeb evah selif dliuB" then
				if f is false and d is false then display notification " configure...." with title "Success"
				set k to 1
				exit repeat
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
	if (get eof po) > g then
		read po from g using delimiter "
		"
		repeat with se in result
			if se contains "%] " then
				my regex(se, ".*\\[ *([0-9]+)%].*", "$1")
				set end of num to result
			end if
		end repeat
	end if
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
	read po from eof to -200
	if result contains "* :ekam" then
		display dialog m & " : make: Error..."
		return
	end if
	if y = 100 then
		repeat
			tell application "System Events" to exists file (d)
			if result is true then exit repeat
			do shell script "tail " & e & " 2>/dev/null >$HOME/Library/Logs/Homebrew/" & m & "/diff1.txt"
			delay 10
			do shell script "tail " & e & " 2>/dev/null >$HOME/Library/Logs/Homebrew/" & m & "/diff2.txt"
			do shell script "diff $HOME/Library/Logs/Homebrew/" & m & "/diff1.txt \\
                                              $HOME/Library/Logs/Homebrew/" & m & "/diff2.txt >/dev/null 2>&1 || echo 1"
			if result is "" then
				exit repeat
			else
				do shell script "tail -2 " & e & " 2>/dev/null |sed -E '/^\\[.+]/!d;s/\\[ *([0-9]+)%].+/\\1/'"
				set s to result as number
				if not s = 0 and y > s then
					set y to s
					exit repeat
				end if
			end if
		end repeat
	end if
	set progress completed steps to y
	if y = 100 then
		delay 1
		exit repeat
	end if
end repeat

try
	tell application "System Events"
		delete file ("~/Library/Logs/Homebrew/" & m & "/diff1.txt")
		delete file ("~/Library/Logs/Homebrew/" & m & "/diff2.txt")
	end tell
end try

use scripting additions
use framework "Foundation"
on regex(aText as text, pattern as text, replace as text)
	set regularExpression to current application's NSRegularExpression's regularExpressionWithPattern:pattern options:0 |error|:(missing value)
	return (regularExpression's stringByReplacingMatchesInString:aText options:0 range:{location:0, |length|:count aText} withTemplate:replace) as text
end regex
