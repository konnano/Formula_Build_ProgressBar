use scripting additions
use framework "Foundation"
set progress total steps to 100
script scr
	property pth : ""
	property fom : ""
	property str : ""
	property con : 0
	property stp : 0
	property num : {}
	property rep : "$1"
	property pat1 : ".*\\[ *([0-9]+)%].*"
	property pat2 : ".*\\[([0-9]+/[0-9]+)].*"
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
				do shell script "killall -INFO cmake||echo 1"
				if result is "1" then
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

delay 2
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

set {Shell, loop} to {"", 0}
repeat 10 times
	delay 1
	set loop to loop + 1
	set Shell to do shell script "
          perl -ne '$i=$h=$e=2,last if /^make: \\*/;next if $_!~m|^\\[\\d+/\\d+]|&&$_!~/^\\[ *\\d+%]/;
          m|^\\[\\d+/(\\d+)]|,$e=$1||'t' unless $e;
	   s|\\[([\\d]+)/(\\d+)].+|eval int $1/$2*100|e;s/\\[ *([\\d]+)%].+/$1/;
	   next if $i&&$i==$_;$h||=0;$h=1 if $i&&$i>$_;
          if($h&&$_<=100){$h=0 if $_==100;next}$i=$_;END{print qq{$i$h
$e}}' " & e & " 2>/dev/null"
	if not Shell is "" then exit repeat
end repeat
if loop = 10 then return

if Shell is "22" & return & "2" then
	return
else
	set p to words of Shell
	set y to item 1 of p as number
	set b to item 2 of p as number
	set stp of scr to item 3 of p
end if
set {pth of scr, fom of scr} to {po, m}
repeat
	set {g, num of scr} to {get eof po, {}}
	if not stp of scr is "t" then
		delay 0.5
	else
		delay 0.1
	end if
	if (get eof po) > g then
		set con of scr to g
		set scr to reader_1(scr)
	end if
	error_1(scr)
	if result is true then return
	repeat with a in num of scr
		set a to a as number
		repeat 1 times
			if a < y then
				set b to 1
				exit repeat
			end if
			if b = 1 then
				if 100 > a then
					exit repeat
				else
					set b to 0
					exit repeat
				end if
			end if
			if a > y then set y to a
		end repeat
	end repeat
	if y = 100 then
		repeat
			set {g, k, num of scr} to {get eof po, false, {}}
			delay 0.1
			tell application "System Events" to exists file (d)
			if result is true then
				exit repeat
			else
				if (get eof po) > g then
					set con of scr to g
					set scr to reader_1(scr)
				end if
				error_1(scr)
				if result is true then return
				repeat with s in num of scr
					set s to s as number
					if y > s then
						set {y, k} to {s, true}
						exit repeat
					end if
				end repeat
			end if
			if k is true then exit repeat
			do shell script "killall -INFO cmake||echo 1"
			if result is "1" then exit repeat
		end repeat
	end if
	set progress completed steps to y
	if y = 100 then
		delay 1
		exit repeat
	end if
end repeat

on reader_1(scr)
	read pth of scr from con of scr using delimiter "
	"
	repeat with se in result
		if se contains "] " then
			set str of scr to se
			if stp of scr is "t" then
				regex_1(scr)
			else
				regex_2(scr)
			end if
			set end of num of scr to result
		end if
	end repeat
	scr
end reader_1

on error_1(scr)
	read pth of scr from eof to -200
	if result contains "* :ekam" or result contains ":deppots dliub :ajnin" then
		display dialog fom of scr & " : make : Error..."
		return true
	end if
	false
end error_1

on regex_1(scr)
	set regularExpression to current application's NSRegularExpression's regularExpressionWithPattern:(pat1 of scr) options:0 |error|:(missing value)
	(regularExpression's stringByReplacingMatchesInString:(str of scr) options:0 range:{location:0, |length|:length of (str of scr)} withTemplate:(rep of scr)) as text
end regex_1

on regex_2(scr)
	set regularExpression to current application's NSRegularExpression's regularExpressionWithPattern:(pat2 of scr) options:0 |error|:(missing value)
	set r to (regularExpression's stringByReplacingMatchesInString:(str of scr) options:0 range:{location:0, |length|:length of (str of scr)} withTemplate:(rep of scr)) as text
	set text item delimiters of AppleScript to "/"
	try
		(text item 1 of r) / (text item 2 of r) * 100 as integer
	on error
		100
	end try
end regex_2
