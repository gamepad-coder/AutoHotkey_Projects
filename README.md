```
           /******************************************************/
          /*                                                    */
         /*       Gamepad.Coder's [AutoHotkey_Projects]        */
        /*                                                    */
       /******************************************************/
      /*  last update:   [2021_03_01]  @  [06-31-26 PM]     */
     /******************************************************/
       
```

<br />

# About this Repository

## Personal Projects in AutoHotkey (a.k.a. "AHK" or "ahk")<br>
- Framework for building GUI applications in AutoHotkey
- Utilities (mainly productivity apps)
- How-To Tutorials & Example Scripts

## License 

Feel free to explore and reuse any of my code in this repository, all open source, all free.

GitHub doesn't allow Community Commons as a license when configuring a repository.<br>
So this repo displays the MIT license, but my scripts will display either "[Community Commons Zero](https://creativecommons.org/share-your-work/public-domain/cc0/)" or "cc0".

For simplicity, just assume all of the AutoHotkey code in this repo (where I am the sole author) is "cc0" and therefore in the Public Domain. (Any code not written by me will explicity state the author and the source at the top of the file's contents). 

All of my personally written AutoHotkey code, to date, is exclusively licensed under cc0.

No cost. No attribution necessary. No worries.

https://creativecommons.org/share-your-work/public-domain/cc0/


## Code contained in this repository written by other authors:

**Authorship:**

I've written the vast majority of code here, but some experiments and tutorial scripts have been adapted from online posts. I have listed the author at beginning of every file, and for scripts I adapted or copied you will also find a URL in the script's top comment.

**Largest chunk of code by other authors:**

My large framework contains two helper libraries, `XML.ahk` and `AutoXYWH.ahk`.

`XML.ahk` is by user Coco and can be found here: https://autohotkey.com/board/topic/89197-xml-build-parse-xml/ <br>
`AutoXYWH.ahk` is by by user tmplinshi and can be found here: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=1079

If eithor author would prefer I remove their code from this repo and link to the online board post instead, feel free to message me.


<br />


# About my Object-Oriented Graphical User Interface Framework.


## About:

The bulk of the code here is for a framework I wrote for AutoHotkey v1 to encapsulate its GUI (Graphical User Interface) commands inside classes and objects. It's far from complete in covering every GUI command and use case, but for my purposes it's proven to be time-saving and fairly robust. 

I've tried to avoid using external libraries and low-level .dll calls to windows when possible, to make the framework easy to understand and easy to extend for those with a minor to modest background in programming (or for those coming from other languages).


## Documentation:

This page is a draft, [~] note to self to add a bit more to this blurb.

A manual for this framework can be found here:<br>
https://gamepad-coder.github.io/Documentation.html


## Future for this framework:

I've since moved to Godot for building hobby applications, but I'm uploading this project in case anyone wants to use or extend it for their own applications.

Further, AutoHotkey v2 (still in it's alpha stage) will contain built-in object-oriented design for its GUI functionality. So if v2 becomes the primarily used AHK distribution, this framework will be halfway obsolete (however my TreeView extension within the framework is still novel and would remain useful). Conversely, AutoHotkey v1 and AutoHotkey v2 have several syntax differences, so this framework will still be useful to anyone who wants to use object-oriented design on top of their existing code without rewriting all of it into AutoHotkey v2's syntax.

If I ever do return to this project there are a lot of quality-of-life functions I'd like to include for automatic Control positioning and allowing fast re-arrangement (presently it's a bit of a chore to change a GUI interface built using AHK once the window has been created).

All in all, I've had a lot of fun building this. It's been enormously useful for prototyping larger applications in pure AHK, and I'm planning on porting large chunks of it into Godot.


<br />

<br />

<br />

<br />

<br />

<br />

<br />


Have a great day.
