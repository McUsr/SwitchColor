README for SwitchColor.vim ver: 0.0.7

SwitchColor loops you though color schemes by hotkey,
and makes Vim remember your choice.

Enables organizing your colorschemes into themes if you make
symbolic links to color schemes files in dedicated folders,
and edit a ready boilerplate function in the plugin.

Author: Tommy Bollman  (tommy.bollman AT gmaail DOT com)
For Vim version 7.0 and above Last change: May 3, 2022

Vim License.  

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the
Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall
be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

Copyright (c) 2022 Tommy Bollman/McUsr 

|Installation:|
========================================================================

* Drop/copy the plugin SwitchColor.vim into your  plugins
	folder in your ~/.vim or $HOME/vimfiles folder. 

* Drop/copy the help file SwitchColor.txt into you doc
	folder  in your ~/.vim or $HOME/vimfiles folder. 

* Fire up vim and run the command		:helptags ~/.vim/doc or
	:helptags c:\Vimfiles\doc You should now be able to see
	the help document by writing |:help SwitchColor| 

* Having seen you can get up the help, with the
	configuration information, its
* time to play with the  hotkeys. You may want to change
	them. 

|Basics:|

	(The short story: h SwitchColor.txt for the full story).

*  opt/alt 5/6 goes back/forward in your colorschemes, loopwise.

*	 opt/alt c runs: |:colorschemes <Tab>| to let you easily cherrypick.

*  opt/alt g prints the name of the current colorscheme.

* Try exiting and starting vim again, and control that your
  last choosen colorscheme is active. On the rare occassion
  that it isn`t, read about |g:SC_dotfilename| in
  SwitchColor.txt (:h SwitchColor)

