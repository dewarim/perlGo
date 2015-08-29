# Short Introduction to PerlGo
# For more information visit the projects HP at http://dewarim.de/de/programme/go.html

1. Installation
Unzip into a new folder. The current direcotry structure is:

README
go.pl
Go/Board.pm
Go/Node.pm
Go/Pov.pm

If you want to generate images with POV-Ray, install it from http://www.povray.org.
On Linux machines, the script expects POV-Ray to run with "povray".
On Windows machines, the expected path to pvengine is "D:\bin\POV-Ra~1.5\bin\pvengine.exe", change it in Go/Board.pm (Line 470) to match your preferences.

2. Starting
perl -w go.pl starts the script.

2.1 Options:
os=win (Default: =linux)
pov=0 (Default: =1), use (=1) or do not use (=0) POV-Ray.
x=number and y=number:  Board dimensions. Default: 9x9
autoplay=1 (Default: 0): plays automatically, uses game.dat
filename=name:	      use this instead of game.dat
print=0 (Default: 1): display Board with ASCII-chars.
fpt=number: number of frames to generate per turn (with pov=1).
ask=1 (Default: 0): Ask for move if encountering illegal moves during autoplay.

eg, start it with "perl -w go.pl x=19 y=19 pov=0"

2.2 Playing:
When prompted for a Move, you can use
'Redo' or +1 or + to go forwards one move
'Undo' or -1 or - to go back one move
'Goto Number' or 'number' to go to a specific move
'+number' or '-number' to move along by that amount of moves
'x y' to choose a place a stone. X and y can be alphanumeric values.

eg, 'a 4' will place a stone at the first column from the left & the
fourth row from the bottom. This is the same as '1 4' or 'a d' etc.

Note that it's safer to add a space between X and Y, because '44' will result
in 'Goto 44', not '4 4'.

3. License
Distributed under the terms of the Perl Artistic License.

4. Bugs
?

5. Contact
Sourceforge Project Site: http://sourceforge.net/projects/perlgo
Homepage: http://dewarim.de/de/programme/go.html
Email: ingo_wiarda@web.de


---
(C) Ingo Wiarda 2003