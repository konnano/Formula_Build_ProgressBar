use scripting additions
use framework "Foundation"
set progress total steps to 100
script scr
	property pth : ""
	property fom : ""
	property str : ""
	property con : 0
	property num : {}
	property rep : "$1"
	property pat : ".*\\[ *([0-9]+)%].*"
end script
set {ho, k} to {(path to home folder) as text, true}
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
			read po from eof to -200
			if result contains "nettirw neeb evah selif dliuB" then
				if f is false and d is false then display notification " configure...." with title "Success"
				set k to false
				exit repeat
			end if
			set g to get eof po
			delay 0.5
			if (get eof po) = g then
				do shell script "ps x|grep [c]make || :"
				if result is "" then
					display dialog m & " : configure : Error..."
					return
				end if
			end if
		end repeat
	else
		display dialog "File not exist : $HOME/Library/Logs/Homebrew/" & m & "/01.cmake"
	end if
	if k is false then exit repeat
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

do shell script "perl -ne  'print 1 if /^make: \\*/' " & e & " 2>/dev/null"
if result is "1" then return

do shell script "perl -ne 'next if $_!~/^\\[ *\\d+%]/;s/\\[ *([\\d]+)%].+/$1/;next if $i&&$i==$_;
                 $h||=0;$h=1 if $i&&$_==0;if($h&&$_<=100){$h=0 if $_==100;next}$i=$_;
                 END{print $i,$h}' " & e & " 2>/dev/null"
if result is "" then
	set {y, c} to {0, 0}
else
	set p to words of result
	set y to item 1 of p as number
	set c to item 2 of p as number
end if
set {pth of scr, fom of scr, b} to {po, m, 0}
repeat
	if c = 1 then set progress completed steps to y
	set g to get eof po
	delay 0.1
	if (get eof po) > g then
		set con of scr to g
		set scr to reader_1(scr)
	end if
	repeat with a in num of scr
		set a to a as number
		repeat 1 times
			if not y = 0 and a = 0 then
				set b to 1
				exit repeat
			end if
			if b = 1 or c = 1 then
				if 100 > a then
					exit repeat
				else
					set {b, c} to {0, 0}
					exit repeat
				end if
			end if
			if a > y then set y to a
		end repeat
	end repeat
	error_1(scr)
	if result is true then return
	if y = 100 then
		repeat
			set g to get eof po
			delay 0.1
			tell application "System Events" to exists file (d)
			if result is true then
				exit repeat
			else
				set con of scr to g
				set scr to reader_1(scr)
				repeat with s in num of scr
					set s to s as number
					if y > s then
						set y to s
						exit repeat
					end if
				end repeat
			end if
			error_1(scr)
			if result is true then return
		end repeat
	end if
	set progress completed steps to y
	if y = 100 then
		delay 1
		exit repeat
	end if
end repeat

on reader_1(scr)
	set num of scr to {}
	read pth of scr from con of scr using delimiter "
	"
	repeat with se in result
		if se contains "%] " then
			set str of scr to se
			regex_1(scr)
			set end of num of scr to result
		end if
	end repeat
	return scr
end reader_1

on error_1(scr)
	read pth of scr from eof to -200
	if result contains "* :ekam" then
		display dialog fom of scr & " : make : Error..."
		return true
	end if
	return false
end error_1

on regex_1(scr)
	set regularExpression to current application's NSRegularExpression's regularExpressionWithPattern:(pat of scr) options:0 |error|:(missing value)
	return (regularExpression's stringByReplacingMatchesInString:(str of scr) options:0 range:{location:0, |length|:length of (str of scr)} withTemplate:(rep of scr)) as text
end regex_1
