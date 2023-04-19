set k to 0
set progress total steps to 100
repeat
	display dialog "Formula" default answer ""
	set m to text returned of result
	
	set e to do shell script "[ -f $HOME/Library/Logs/Homebrew/" & m & "/01.cmake ] || echo 1"
	if e is "1" then display dialog "File not exist : $HOME/Library/Logs/Homebrew/" & m & "/01.cmake"
	
	set f to do shell script "[ -f $HOME/Library/Logs/Homebrew/" & m & "/02.cmake ] || echo 1"
	if e is "" then
		if f is "1" then display notification " configure...." with title "Wait"
		repeat
			do shell script "tail -1 $HOME/Library/Logs/Homebrew/" & m & "/01.cmake 2>/dev/null |
                                         sed 's/.*Build files have been written.*/1/'"
			if result is "1" then
				if f is "1" then display notification " configure...." with title "Success"
				set k to 1
				exit repeat
			end if
		end repeat
	end if
	if k = 1 then exit repeat
end repeat
delay 1
do shell script "[ -f $HOME/Library/Logs/Homebrew/" & m & "/02.cmake ] || echo 1"
if result is "1" then
	display dialog "File not exist : $HOME/Library/Logs/Homebrew/" & m & "/02.cmake"
	return
end if

do shell script "tail -2 $HOME/Library/Logs/Homebrew/" & m & "/02.cmake 2>/dev/null | head -c 6"
if result is "[100%]" then return

do shell script "sed  -E '/.*make: \\*+/!d' \\
                 $HOME/Library/Logs/Homebrew/" & m & "/02.cmake 2>/dev/null"
if not result is "" then return

do shell script "sed -E '/^\\[.+]/!d;s/\\[ *([0-9]+)%].+/\\1/' \\
                 $HOME/Library/Logs/Homebrew/" & m & "/02.cmake 2>/dev/null | uniq |
perl -ne '$h||=0;$h=1 if $i&&$_==0;if($h&&$_<=100){$h=0 if $_==100;next};$i=$_;END{print $i,$h}'"
if result is "" then
	set y to 0
	set c to 0
else
	set p to words of result
	set y to item 1 of p as number
	set c to item 2 of p as number
end if
set b to 0
repeat
	if c = 1 then set progress completed steps to y
	do shell script "tail -2 $HOME/Library/Logs/Homebrew/" & m & "/02.cmake 2>/dev/null |
                         sed -E '/^\\[.+]/!d;s/\\[ *([0-9]+)%].+/\\1/'"
	set str to words of result
	repeat with a in str
		set i to a as number
		if not y = 0 and i = 0 then
			set b to 1
			exit repeat
		end if
		if b = 1 or c = 1 then
			if 100 > i then
				exit repeat
			else
				set b to 0
				set c to 0
				exit repeat
			end if
		end if
		if i > y then set y to i
	end repeat
	do shell script "tail $HOME/Library/Logs/Homebrew/" & m & "/02.cmake 2>/dev/null |
	                 sed  -E '/.*make: \\*+/!d'"
	if not result is "" then
		display dialog m & " : make: Error..."
		exit repeat
	end if
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
	do shell script "rm $HOME/Library/Logs/Homebrew/" & m & "/diff1.txt 2>/dev/null \\
                            $HOME/Library/Logs/Homebrew/" & m & "/diff2.txt 2>/dev/null"
end try
