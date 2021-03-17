```
           /******************************************************/
          /*                                                    */
         /*       Gamepad.Coder's [AutoHotkey_Projects]        */
        /*                                                    */
       /******************************************************/
      /*  last update:   [2021_03_16]  @  [08-20-48 PM]     */
     /******************************************************/
       
```

<br />

# About this Repository

### Personal Projects in AutoHotkey (a.k.a. "AHK" or "ahk")<br>
- Framework for building GUI applications in AutoHotkey
- Utilities (mainly productivity apps)
- How-To Tutorials & Example Scripts

# License 

### Community Commons Zero 1.0 Universal License:

Feel free to explore and reuse any of my code in this repository, all open source, all free.

You don't need to ask for permission (and you don't even need to give me credit) if you use excerpts or even entire scripts I've written and uploaded to this repository. Public Domain. Go wild.

My scripts in this repository will display my user name and a reference to [the Community Commons Zero License](https://creativecommons.org/share-your-work/public-domain/cc0/) (also known as the "CC0 License" or simply "cc0") at the top of the file. Typically something like: `by Gamepad.Coder, cc0`.

The "CC0 1.0 Universal License" is a simple legal tool which allows an owner to officially release a work -> into the Public Domain. 

For simplicity, just assume all of the AutoHotkey code in this repo (unless someone else is explicitly cited as the author) is "cc0" and therefore in the Public Domain. Though I intend to explicitly state this license in each file, if I miss one then I'd like to avoid ambiguity: if a file in this repo says "by Gamepad.Coder" it is definitely licensed under cc0.

No cost. No attribution necessary. No worries.

https://creativecommons.org/share-your-work/public-domain/cc0/

### Code by other authors:

I've written the vast majority of code here, but some experiments and tutorial scripts have been adapted from online posts or from the AutoHotkey manual itself. I have listed myself as the author at the beginning of every file I wrote. For scripts I adapted or copied you will find a reference to that file's original author and a source URL in the script's top comment. 

When I incorporate small excerpts written by others, I always place a comment block (containing a URL and author) directly above any portion of code I didn't design (with the sole exception being simple syntax or commands which can be found in the AutoHotkey manual). 

Example:

```AutoHotkey
31|  GamepadCoder_Function( string_param ){
32|  
33|    ;---------------
34|    ; String before.
35|    MsgBox, Your string was %string_param%
36|    
37|    ;---------------------------------------------------;
38|    ; function:      example()                          ;
39|    ; written by:    usr xyz                            ;
40|    ; found at url:  www.somewebsite.org/123/post.html  ;
41|    ;---------------------------------------------------;
42|    string_param := example( string_param )
43|    
44|    ;---------------
45|    ; String after.
46|    MsgBox, Your string is now %string_param%
47|  }
```

I will do my best to additionally make a note about this at the beginning of the file, just after the license and author. 

Example: 

```AutoHotkey
1|  ;-------------------------------------------------;
2|  ; By Gamepad.Coder, licensed under cc0.           ;
3|  ;-------------------------------------------------;
4|  ; Note:                                           ;
5|  ; This script includes a function I didn't write. ;
6|  ; The example() function is by user xyz           ;
7|  ; URL:  www.somewebsite.org/123/post.html.        ;
8|  ;-------------------------------------------------;
```

All such exceprts came from one of the following websites:
- the AutoHotkey boards (public and awesome community),
- the AutoHotkey manual
- or from the Q/A site Stackoverflow.com.

### Largest chunk of code by other authors:

My large framework contains two third-party helper libraries, `XML.ahk` and `AutoXYWH.ahk`.

`XML.ahk` is by user Coco and can be found here: https://autohotkey.com/board/topic/89197-xml-build-parse-xml/ <br>
`AutoXYWH.ahk` is by by user tmplinshi and can be found here: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=1079

Neither of the original files contain a license, though I presume they were posted (like many AutoHotkey scripts) to be used freely by the community. However, if either author happens upon this repo and would prefer I remove their code (and link to the online board post instead), please feel free to message me.


<br />


# About my Object-Oriented Graphical User Interface Framework.


### About:

The bulk of the code here is for a framework I wrote for AutoHotkey v1 to encapsulate its GUI (Graphical User Interface) commands inside classes and objects. It's far from complete in covering every GUI command and use case, but for my purposes it's proven to be time-saving and fairly robust. 

I've tried to avoid using external libraries and low-level .dll calls to the Windows Operating System wherever possible:
1. To make the Framework easier to understand (i.e. you can study it almost entirely offline if you have a copy of the AutoHotkey manual).
2. To make the Framework easier to extend for those with a minor to modest background in programming (or for those coming from other languages).

Again, as mentioned above, the biggest third party addition is `XML.ahk`, which I used to replace my initial XML parser for the added security and error-checking it provides via instantiation of a MSXML object (Microsoft XML Core Services). Other than this, I've tried to make this Framework as un-arcane and self-documented as possible.

### Future for this framework:

I've since moved to Godot for building hobby applications, but I'm uploading this project in case anyone wants to use or extend it for their own applications.

Further, AutoHotkey v2 (still in its alpha stage) will contain built-in object-oriented design for its GUI functionality. So if v2 becomes the primarily used AHK distribution, this framework will be halfway obsolete (however my TreeView extension within the framework is still novel and would remain useful). Conversely, AutoHotkey v1 and AutoHotkey v2 have several syntax differences, so this framework will still be useful to anyone who wants to use object-oriented design on top of their existing code without rewriting all of it into AutoHotkey v2's syntax.

If I ever do return to this project there are a lot of quality-of-life functions I'd like to include for automatic Control positioning and allowing fast re-arrangement (presently it's a bit of a chore to change a GUI interface built using AHK once the window has been created).

All in all, I've had a lot of fun building this. It's been enormously useful for prototyping larger applications in pure AHK, and I'm planning on porting large chunks of it into Godot.

# Documentation:

This page is a draft, [~] note to self to add a bit more to this blurb.

A manual for my AutoHotkey Object-Oriented GUI Framework can be found here:<br>
https://gamepad-coder.github.io/Documentation.html.

<br />

<br />

<br />

<br />

<br />

<br />

<br />


Have a great day.
