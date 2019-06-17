#!/usr/local/bin/fontforge

Print("Opening "+$1);
Open($1);
Print("Saving "+$1:r+".ttf");
SetFontNames($1:r,$1:r,$1:r);
Generate($1:r + ".ttf");
Quit(0);