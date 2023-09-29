use scripting additions
use framework "Foundation"
set progress total steps to 100
script scr
	property pth : ""
	property fom : ""
	property str : ""
	property con : 0
	property stp : 0
	property cou : 0
	property num : {}
	property mes : "cmake"
	property hom : (path to home folder) as text
	property pat1 : "^\\[ *([0-9]+)%].*"
	property pat2 : "^\\[([0-9]+/[0-9]+)].*"
end script
set k to true
repeat
	display dialog "Formula" default answer ""
	set m to text returned of result
	tell application "System Events"
		set e to exists file ("~/Library/Logs/Homebrew/" & m & "/01." & mes of scr)
		set f to exists file ("~/Library/Logs/Homebrew/" & m & "/02." & mes of scr)
		set d to exists file ("~/Library/Logs/Homebrew/" & m & "/02.make")
		if exists file ("~/Library/Logs/Homebrew/" & m & "/01.meson") then
			set e to true
			set mes of scr to "meson"
			set f to exists file ("~/Library/Logs/Homebrew/" & m & "/02." & mes of scr)
		end if
	end tell
	if e is true then
		if f is false and d is false then display notification " configure...." with title "Wait"
		set po to POSIX path of (hom of scr & "Library:Logs:Homebrew:" & m & ":01." & mes of scr)
		delay 0.1
		repeat
			read po from eof to -150
			if result contains "nettirw neeb" or result contains "ajnin dnuoF" then
				if f is false and d is false then display notification " configure...." with title "Success"
				set k to false
				exit repeat
			end if
			set g to get eof po
			delay 0.5
			if (get eof po) = g then
				if mes of scr = "cmake" then
					do shell script "killall -INFO cmake 2>/dev/null||echo 1"
				else
					do shell script "killall -INFO Python 2>/dev/null||echo 1"
				end if
				if result is "1" then
					display dialog m & " : configure : Error..."
					return
				end if
			end if
		end repeat
	else
		display dialog "File not exist : $HOME/Library/Logs/Homebrew/" & m & "/....."
	end if
	if k is false then exit repeat
end repeat

delay 2
tell application "System Events"
	set f to exists file ("~/Library/Logs/Homebrew/" & m & "/02." & mes of scr)
	set d to exists file ("~/Library/Logs/Homebrew/" & m & "/02.make")
end tell
if f is false and d is false then return

if f is true then
	set e to "$HOME/Library/Logs/Homebrew/" & m & "/02." & mes of scr
	set po to POSIX path of (hom of scr & "Library:Logs:Homebrew:" & m & ":02." & mes of scr)
else
	set mes of scr to "make"
	set e to "$HOME/Library/Logs/Homebrew/" & m & "/02." & mes of scr
	set po to POSIX path of (hom of scr & "Library:Logs:Homebrew:" & m & ":02." & mes of scr)
end if

set {Shell, loop} to {"", 0}
repeat 10 times
	delay 1
	set loop to loop + 1
	set Shell to do shell script "
          perl -ne '$i=$h=$e=2,last if /^make: \\*/||/^ninja: build stopped:/||/^KeyboardInterrupt/;
	  next if $_!~m|^\\[\\d+/\\d+]|&&$_!~/^\\[ *\\d+%]/;
          m|^\\[\\d+/(\\d+)]|,$e=$1||'t' unless $e;
	  s|^\\[([\\d]+)/(\\d+)].+|eval int $1/$2*100|e;s/^\\[ *([\\d]+)%].+/$1/;
	  next if $i&&$i==$_;$h||=0;$h=1 if $i&&$i>$_;
          if($h&&$_<=100){$h=0 if $_==100;next}$i=$_;END{print qq{$i$h
$e}}' " & e & " 2>/dev/null"
	if not Shell is "" then exit repeat
end repeat
if loop = 10 and Shell is "" then return

if Shell is "22" & return & "2" then
	return
else
	set p to words of Shell
	set y to item 1 of p as number
	set b to item 2 of p as number
	set stp of scr to item 3 of p
end if
if y = 100 and b = 0 then return

set tmp to text item delimiters of AppleScript
set text item delimiters of AppleScript to "/"
set {pth of scr, fom of scr} to {po, m}
repeat
	set {g, num of scr} to {get eof po, {}}
	error_1(scr, true)
	if result is true then return
	if (get eof po) > g then
		set con of scr to g
		set scr to reader_1(scr)
	end if
	repeat with a in num of scr
		try
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
		end try
	end repeat
	if y ≥ 100 then
		repeat
			set {g, k, num of scr} to {get eof po, false, {}}
			error_1(scr, false)
			if result is true then
				return
			else if result = 1 then
				set y to 100
				exit repeat
			end if
			if (get eof po) > g then
				set con of scr to g
				set scr to reader_1(scr)
			end if
			repeat with s in num of scr
				try
					set s to s as number
					if y > s then
						set {y, k} to {s, true}
						exit repeat
					end if
				end try
			end repeat
			if k is true then exit repeat
		end repeat
	end if
	set progress completed steps to y
	if y = 100 then
		delay 1
		exit repeat
	end if
end repeat
set text item delimiters of AppleScript to tmp

on reader_1(scr)
	read pth of scr from con of scr using delimiter linefeed
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

on error_1(scr, y)
	set cou of scr to (cou of scr) + 1
	if not cou of scr = 31 then delay 0.1
	if (cou of scr) mod 10 = 0 then
		try
			(hom of scr & "Library:Logs:Homebrew:" & fom of scr & ":03." & mes of scr) as alias
			return 1
		end try
	else if cou of scr = 31 then
		set cou of scr to 0
		if mes of scr is "cmake" or mes of scr is "make" then
			do shell script "killall -INFO cmake 2>/dev/null||echo 1"
		else
			do shell script "killall -INFO Python 2>/dev/null||echo 1"
		end if
		if result is "1" then
			if y is true then
				display dialog fom of scr & " : make : Error..."
				return true
			else
				return 1
			end if
		end if
	end if
	read pth of scr from eof to -200
	if result contains "* :ekam" or result contains ":deppots dliub" or result contains "tpurretnIdraobyeK" then
		display dialog fom of scr & " : make : Error..."
		return true
	end if
	false
end error_1

on regex_1(scr)
	set regex to current application's NSRegularExpression's regularExpressionWithPattern:(pat1 of scr) options:0 |error|:(missing value)
	(regex's stringByReplacingMatchesInString:(str of scr) options:0 range:{location:0, |length|:length of (str of scr)} withTemplate:"$1") as text
end regex_1

on regex_2(scr)
	set regex to current application's NSRegularExpression's regularExpressionWithPattern:(pat2 of scr) options:0 |error|:(missing value)
	(regex's stringByReplacingMatchesInString:(str of scr) options:0 range:{location:0, |length|:length of (str of scr)} withTemplate:"$1") as text
	try
		(text item 1 of result) / (text item 2 of result) * 100 div 1
	on error
		100
	end try
end regex_2
