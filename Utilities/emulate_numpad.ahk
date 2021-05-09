					  ;-------------------------------------;
					  ;                                     ;
					  ;           PUBLIC DOMAIN             ;
					  ;                                     ;
					  ;       This file is released         ;
					  ;       under the cc0 license.        ;
					  ;                                     ;
					  ;-------------------------------------;
					  ;                                     ;
					  ;   Written by:                       ;
					  ;                    Gamepad-Coder    ;
					  ;                                     ;
					  ;-------------------------------------;
	   
	   
	   ;-----------------------------------------------------------------------;
	   ;  emulate_numpad.ahk                                                   ;
	   ;-----------------------------------------------------------------------;
	   ;                                                                       ;
	   ;                                                     version 2         ;
	   ;                                                                       ;
	   ;                                        [2021_05_03]  @  [06-02-35 PM] ;
	   ;-----------------------------------------------------------------------;
	   
	   
	   ;------------------------------------------------------------------;
	   ;                                                                  ;
	   ; Credits for a solution:                                          ;
	   ;                                                                  ;
	   ;------------------------------------------------------------------;
	   ; To create a moving ToolTip which doesn't flicker,                ;
	   ; I adapted the implementation of:                                 ;
	   ;                                                                  ;
	   ;   Function: FFToolTip()                                          ;
	   ;   Author:   iPhilip                                              ;
	   ;                                                                  ;
	   ;   URL: https://www.autohotkey.com/boards/viewtopic.php?t=62607   ;
	   ;                                                                  ;
	   ; Other sources of information I used for the adaptation           ;
	   ; can be found in the label:                                       ;
	   ;    Timer_refresh_tooltip_location_while_enabled                  ;
	   ;------------------------------------------------------------------;
   

	/* ABOUT

	  *************************************************************************
	  
		======================
		   What does it do?
		======================
		
		This script allows keyboards without a Number Pad (a.k.a. "numpad") 
		(for example, 87 key and other "tenkeyless" keyboards)
		
		to send the same keycodes normally only sendable with the Number Pad.

		When this script is run, 
		the keyboard will function normally until a hotkey is pressed 
		which toggles keyboard functionality.

		When the default hotkey is pressed <RightControl + F12> 
		the script calls a label named Toggle_Emulated_Numpad, 
		which changes what the following keys do:

			 *   -+
			789
			uio
			jkl     Enter
			m .  /

			Note: This chart is an approximation of 
				  the keys located in the main rows of the keyboard.
				  
				  *   represents <shift+8>, 
				  -+  are the minus and plus next to the backspace key.
				  ./  are the keys close to the space bar.
		
		
		
		
		============================================
		   The following keys are remapped when
		   _emulate_numpad_on is set to true:
		============================================
		
		- - - - - - - - - - - - - - - - - - - - - - - -
		
			The keys:
			
				789
				uio
				jkl    Enter
				m
			
			will send the NumberPad keycodes for:
			
				Numpad7 Numpad8 Numpad9
				Numpad4 Numpad5 Numpad6
				Numpad1 Numpad2 Numpad3   NumpadEnter
				Numpad0
				
		- - - - - - - - - - - - - - - - - - - - - - - -
		
			The symbol keys:
			
				*-+
				./
			
			will send the NumberPad keycodes for:
			
				NumpadMult NumpadSub NumpadAdd
				NumpadDot NumpadDiv
			
			For ease of use, 
			the = key will also send NumpadAdd.
			
		- - - - - - - - - - - - - - - - - - - - - - - -
		
			The ? key will be remapped 
			
			to show a help message.
			
		- - - - - - - - - - - - - - - - - - - - - - - -
		
			
		
		============================================================
					Turning off NumberPad Emulation 
		============================================================

			There are two ways to exit NumberPad mode:
			
			(1) When _emulate_numpad_on is enabled, 
				pressing the toggle hotkey again 
				will turn off NumberPad emulation.
			
			(2) Alternatively, you can press the Escape key 
				to disable the NumberPad emulation.
				
				This <Esc> toggle-off feature is a failsafe to help:
				
				(A) users who forget the hotkey, or
				(B) users who are using a PC running this script
					(who don't know about the script) 
					and are wondering why the keyboard 
					isn't functioning normally.


			When _emulate_numpad_on is set to false 
			the keyboard will function normally 
			except for the hotkey which toggles the script on.
			
	  *************************************************************************
	  
	*/




	;-----------------------------------------------------------------------------------------------


	;================================================;
	;                                                ;
	;             begin autorun section              ;
	;                                                ;
	;================================================;
	   
	   ;---------;`
	   ;    ?    ;
	   ;---------------------------------------------------------;``
	   ; For more information about the "auto-execute section"   ;
	   ; at the beginning of an AutoHotkey script, see:          ;
	   ;     https://www.autohotkey.com/docs/Scripts.htm#auto    ;
	   ;---------------------------------------------------------;```


	;---------------------------------------------------------;
	;                                                         ;
	; Just for fun.                                           ;
	;                                                         ;
	; Menu, Tray, Icon, ...                                   ;
	;                                                         ;
	; Changes the default AHK icon in the notification tray   ;
	; to a picture of a keybaord + monitor.                   ;
	;                                                         ;
	; see AHK DOCS -> Menu -> Sub-commands -> Icon            ;
	;                                                         ;
	;---------------------------------------------------------;

	Menu, Tray, Icon, Shell32.dll, 174



	;------------------------------------------------;
	;    Initialize our toggle boolean variable.     ;
	;    Start with NumberPad emulation disabled.    ;
	;------------------------------------------------;

	_emulate_numpad_on := false



	;----------------------------------------------------------------;`
	;                                                                ;
	;                     HELPER TOOLTIP                             ;
	;                                                                ;
	;----------------------------------------------------------------;``
	;                                                                ;
	; This script features a tooltip which follows the mouse         ;
	; whenever NumberPad emulation is turned on.                     ;
	;                                                                ;
	; It will disappear when Number Pad emulation is toggled off.    ;
	;                                                                ;
	;----------------------------------------------------------------;
	;                                                                ;
	;  To disable the tooltip which follows the mouse,               ;
	;  use this line instead:                                        ;
	;                                                                ;
	;      _settings__show_persistent_tooltip_when_enabled := false  ;
	;                                                                ;
	;----------------------------------------------------------------;
	;                                                                ;
	;  If the persistent tooltip is enabled,                         ;
	;  whenever NumberPad emulation is turned on:                    ;
	;                                                                ;
	;   (1)   The tooltip will display a key legend                  ;
	;         to remind you which keys are remapped.                 ;
	;                                                                ;
	;   (2)   F1 will toggle this legend on or off                   ;
	;                                                                ;
	;  To hide the key legend by default:                            ;
	;  use this line instead:                                        ;
	;                                                                ;
	;      _settings__show_legend_in_persistent_tooltip := false     ;
	;                                                                ;
	;----------------------------------------------------------------;```

	_settings__show_persistent_tooltip_when_enabled := true
	_settings__show_legend_in_persistent_tooltip    := true


	;--------------------------------------------------;
	; _tooltip_hwnd       Stores the window "handle"   ;
	;                     for the persistent tooltip.  ;
	;--------------------------------------------------;

	_tooltip_hwnd := ""



	;================================;
	; </>  end of autorun section    ;
	;================================;
		

	;-----------------------------------------------------------------------------------------------
	  

	;================================================;
	;                                                ;
	;                   Hotkeys                      ;
	;                                                ;
	;================================================;



	;----------------------------------------------------------------;`
	;           Enable or Disable : Numberpad Emulation              ;
	;----------------------------------------------------------------;``
	; >^F12::                                                        ;
	;          will toggle our numpad emulation hotkeys              ;
	;          on or off when we press <RCtrl+F12>                   ;
	;                                                                ;
	; ^   means "the Control modifier key"                           ;
	; >   means "use the modifier on the right side of the keyboard" ;
	; >^  means "use the right Control modifier"                     ;
	;----------------------------------------------------------------;```

	>^F12::
		gosub, Toggle_Emulated_Numpad
	return

			;--------------------------------;`
			;                                ;
			;  Alternative "Toggle" Hotkey   ;
			;                                ;
			;--------------------------------------------------------;``
			;                                                        ;
			;  Comment the above three lines                         ;
			;     (by adding a ';' to the beginning of the line      ;
			;      to prevent the code from being run).              ;
			;                                                        ;
			;  Then uncomment one of the below blocks of three lines ;
			;  to use a different hotkey.                            ;
			;                                                        ;
			;                                                        ;
			;  Or, if you want to make your own                      ;
			;  but you're new to AutoHotkey                          ;
			;                                                        ;
			;      check out the official                            ;
			;      AutoHotkey Beginner Tutorial here:                ;
			;      https://www.autohotkey.com/docs/Tutorial.htm#s2   ;
			;                                                        ;
			;--------------------------------------------------------;
			

			;-----------------------------------------------;
			; To use                                        ;
			;          Win key                              ;
			;          + F12                                ;
			;                                               ;
			; to toggle our emulated numpad mode            ;
			; use these three lines:                        ;
			;-----------------------------------------------;
			
			; #F12::  
			;   gosub, Toggle_Emulated_Numpad
			; return



			;---------------------------------------------------------;
			; If your PC only has one Control key (i.e. some laptops) ;
			; but you sill wish to use the Control key and F12        ;
			;                                                         ;
			; you can use                                             ;
			;                                                         ;
			;         any Control key                                 ;
			;         + F12                                           ;
			;                                                         ;
			; by using the following three lines:                     ;
			;---------------------------------------------------------;
			
			; ^F12::
			; 	gosub, Toggle_Emulated_Numpad
			; return


			;-------------------------------;
			; </> Alternative Hotkey Blocks ;
			;-------------------------------;```


	;-------------------------------------------------------------;`
	;               Disable : Numberpad Emulation                 ;
	;-------------------------------------------------------------;``
	; <Esc> is another way to turn off our emulation hotkeys.     ;
	;-------------------------------------------------------------;
	; Escape will only turn it off.                               ;
	; Escape will not turn on NumberPad emulation.                ;
	;                                                             ;
	; When the emulator is off, Escape will function like normal. ;
	; When the emulator is on,  Escape will function like normal, ;
	;    but our emulator will turn off.                          ;
	;-------------------------------------------------------------;```

	~Escape::
	{
		if( true == _emulate_numpad_on ){
			gosub, Toggle_Emulated_Numpad
		}
		return
	}

		;---------;`
		;    ?    ;
		;-----------------------------------------------------;
		;    What does putting a ~ before a hotkey do?        ;
		;-----------------------------------------------------;``
		; DOCS -> "Hotkeys" page -> "Modifier Symbols" -> "~" ;
		;                                                     ;
		;   "When the hotkey fires, its key's                 ;
		;    native function will not be blocked"             ;
		;                                                     ;
		; https://www.autohotkey.com/docs/Hotkeys.htm#Symbols ;
		;-----------------------------------------------------;```




	;-------------------------------------------;
	;                                           ;
	;           EMULATE  NUMBER PAD             ;
	;                                           ;
	;-------------------------------------------;
	;                                           ;
	; The following hotkeys are only active     ;
	; when  _emulate_numpad_on  is set to true. ;
	;                                           ;
	;-------------------------------------------;

	#If (_emulate_numpad_on == true)
	{
		
		j::Numpad1
		
		k::Numpad2
		
		l::Numpad3
		
		u::Numpad4
		
		i::Numpad5
		
		o::Numpad6
		
		7::Numpad7
		
		8::Numpad8
		
		9::Numpad9
		
		m::Numpad0
		
		;------------------------------------------------;
		;  Full Support                                  ;
		;------------------------------------------------;
		; If you're using Blender or another app         ;
		; which uses the numpad for hotkeys              ;
		; then our script will send the following as if  ;
		; they were pressed on the NumberPad:            ;
		;------------------------------------------------;
		
		*::NumpadMult
		
		/::NumpadDiv
		
		-::NumpadSub
		
		+::NumpadAdd
		=::NumpadAdd			; for ease of use
		
		Enter::NumpadEnter
		
		.::NumpadDot
		
		?::gosub Show_Help
		F1::gosub Toggle_Key_Legend
		
	}
	#If
			;--------;`
			;   ?    ;
			;------------------------------------------------------;
			;     How are these hotkeys conditionally active?      ;
			;------------------------------------------------------;``
			; DOCS -> "Mouse and Keyboard"                         ;
			;      -> "Hotkeys and Hotstrings"                     ;
			;      -> "#If"                                        ;
			;                                                      ;
			;   The #If directive:                                 ;
			;                                                      ;
			;   "Creates context-sensitive hotkeys and hotstrings. ;
			;    Such hotkeys perform a different action           ;
			;    (or none at all) depending on                     ;
			;    the result of an expression."                     ;
			;                                                      ;
			; https://www.autohotkey.com/docs/commands/_If.htm     ;
			;------------------------------------------------------;```
		
		

	;==================================;
	; </>  end of Hotkey definitions   ;
	;==================================;


	;-----------------------------------------------------------------------------------------------


	;================================================;
	;                                                ;
	;                    Labels                      ;
	;                                                ;
	;================================================;


	;----------------------------------------------------------------;`
	; Toggle_Emulated_Numpad                                         ;
	;----------------------------------------------------------------;``
	;                                                                ;
	; Turn on  Numpad Emulation when it's off.                       ;
	; Turn off Numpad Emulation when it's on.                        ;
	;                                                                ;
	; The hotkeys nested above inside the #If directive              ;
	; will only be triggered when _emulate_numpad_on is set to true. ;
	;                                                                ;
	;----------------------------------------------------------------;```

	Toggle_Emulated_Numpad:
	{
		;---------------------------------------------------------;`
		; Flip the boolean's state each time we goto this label   ;
		;---------------------------------------------------------;``
		;                                                         ;
		; If it is currently false, it will be set to true.       ;
		; If it is currently true,  it will be set to false.      ;
		;                                                         ;
		;---------------------------------------------------------;
		;                                                         ;
		; This var is used in the directive expression above:     ;
		;                                                         ;
		;      #If (_emulate_numpad_on == true)                   ;
		;                                                         ;
		;---------------------------------------------------------;```
		
		_emulate_numpad_on := !_emulate_numpad_on
		
		;-----------------------------;
		;  just for fun, tooltip nfo  ;
		;-----------------------------;
		
		gosub, Show_User_Tooltip_About_Emulation_State
		
		return
	}



	;------------------------------------------------------------------;`
	; Show_User_Tooltip_About_Emulation_State                          ;
	;------------------------------------------------------------------;``
	;                                                                  ;
	; Display info tooltip when NumPad Emulation is turned on or off.  ;
	;                                                                  ;
	;------------------------------------------------------------------;
	;                                                                  ;
	; If _settings__show_persistent_tooltip_when_enabled == false:     ;
	;                                                                  ;
	;    Display a tooltip for 1 second                                ;
	;    telling the user whether it's on or off.                      ;
	;                                                                  ;
	;    A timer is set to automatically turn the tooltip off          ;
	;    after 1 second, then the timer itself turns off.              ;
	;                                                                  ;
	; If _settings__show_persistent_tooltip_when_enabled == true:      ;
	;                                                                  ;
	;    Display a helper tooltip which follows the mouse              ;
	;    until Numpad Emulation is turned off.                         ;
	;                                                                  ;
	;    A timer is set to periodically refresh the location           ;
	;    of the tooltip window. This tooltip will follow the mouse     ;
	;    until NumberPad Emulation is toggled off.                     ;
	;                                                                  ;
	;------------------------------------------------------------------;
	;                                                                  ;
	; Note:                                                            ;
	;         Timers run in their own threads.                         ;
	;                                                                  ;
	;         By using a timer, future hotkeys will not be blocked     ;
	;                                                                  ;
	;         and the script can proceed normally without delay.       ;
	;                                                                  ;
	;------------------------------------------------------------------;```

	Show_User_Tooltip_About_Emulation_State:
	{
		;---------------------------------------------------------------;`
		; If the NumberPad Emulation was just turned on:                ;
		;---------------------------------------------------------------;``
		; Then display either:                                          ;
		;                                                               ;
		; (1)  A persistent ToolTip                                     ;
		;      until the NumberPad Emulation is disabled.               ;
		;                                                               ;
		;      Handled by Timer_refresh_tooltip_location_while_enabled. ;
		;                                                               ;
		;  or                                                           ;
		;                                                               ;
		; (2)  A short ToolTip which disappears, notifying the user     ;
		;      that the mode has been turned on.                        ;
		;---------------------------------------------------------------;```
		if( true == _emulate_numpad_on ){
		
			if( _settings__show_persistent_tooltip_when_enabled ){
			
				SetTimer, Timer_refresh_tooltip_location_while_enabled, 100
				
			}
			else{
				toast_message :=  "EMULATED NUMBER PAD"
				toast_message  .= "`n`n`t`t"
				toast_message  .= "[+]   ENABLED!`n"
			
				ToolTip, %toast_message%
				
				SetTimer, Timer_turn_tooltip_off, -1500
			}
			
		}
		;-------------------------------------------------------------;`
		; Else, if the NumberPad Emulation was just turned off:       ;
		;-------------------------------------------------------------;``
		; Then display:                                               ;
		;                                                             ;
		;      A short ToolTip which disappears, notifying the user   ;
		;      that the mode has been turned off.                     ;
		;                                                             ;
		; Whether or not                                              ;
		;                                                             ;
		;     _settings__show_persistent_tooltip_when_enabled         ;
		;                                                             ;
		; is true or false, this off message will be the same.        ;
		;-------------------------------------------------------------;```
		else if( false == _emulate_numpad_on ){
			
			toast_message :=  "EMULATED NUMBER PAD"
			toast_message  .= "`n`n`t`t"
			toast_message  .= "[-]   disabled.`n"
			
			ToolTip, %toast_message%
			
			SetTimer, Timer_turn_tooltip_off, -1500
			
		}

		;----------------;`
		;  About Timers  ;
		;-------------------------------------------------------------------;``
		; SetTimer command expects its first parameter                      ;
		;                          to be an unquoted string.                ;
		;                                                                   ;
		; Timer_turn_tooltip_off is the name of a label below               ;
		; which will hide the tooltip.                                      ;
		;                                                                   ;
		; The timer will run this label when the timer reaches 0.           ;
		;                                                                   ;
		; To make the timer wait 1 second (1000ms)                          ;
		;  before turning the label off,                                    ;
		;  set the second parameter (for the timer period) to -1000.        ;
		;                                                                   ;
		; Making the period negative does two things:                       ;
		; (1) Run the timer only once, then disable the timer               ;
		; (2) Wait that number of milliseconds before jumping to the label  ;
		;                                                                   ;
		; When a timer's period is positive,                                ;
		; it will repeat infinitely until turned off.                       ;
		;-------------------------------------------------------------------;```
		
		
			;--------;`
			;   ?    ;
			;-------------------------------------------------------------------;
			;  Why use a timer here?                                            ;
			;-------------------------------------------------------------------;``
			; Timers are MUCH better than using                                 ;
			;                                                                   ;
			;    ToolTip, Some literal tooltip text without quotes              ;
			;    Sleep, 1000                                                    ;
			;    ToolTip                                                        ;
			;                                                                   ;
			; Because if you use sleep here,                                    ;
			; the entire current thread will be stuck for 1 second here         ;
			; (or for the number of miliseconds in the Sleep, %param%)          ;
			;                                                                   ;
			; and you would't be able to do anything with this script           ;
			; til it's done.                                                    ;
			;                                                                   ;
			; Hotkeys would be blocked,                                         ;
			; including the ability to restore the keyboard                     ;
			; to its normal state.                                              ;
			;                                                                   ;
			; Whenever you use SetTimer, AutoHotkey                             ;
			; creates a new thread for the timer,                               ;
			;                                                                   ;
			; This allows the script's main thread to continue on immediately.  ;
			;-------------------------------------------------------------------;```
			
		
		return
	}


	Toggle_Key_Legend:
	{
		_settings__show_legend_in_persistent_tooltip := !_settings__show_legend_in_persistent_tooltip
		_tooltip_hwnd := ""
		return
	}

				
	;========================================================================;
	;                                                                        ;
	;                                                                        ;
	;   The following ToolTip code was adapted from the following post:      ;
	;                                                                        ;
	;      https://www.autohotkey.com/boards/viewtopic.php?t=62607           ;
	;                                                                        ;
	;                                                                        ;
	;========================================================================;

				
	;-------------------------------------------------------------------------------------------;`
	;                                                                                           ;
	; URLS : Additional Information                                                             ;
	;                                                                                           ;
	;-------------------------------------------------------------------------------------------;``
	;                                                                                           ;
	; Getting a Script's own Process ID :                                                       ;
	;   https://autohotkey.com/board/topic/3770-how-does-a-script-gets-its-own-pid/#entry23653  ;
	;                                                                                           ;
	; DetectHiddenWindows (Why it's necessity here) :                                           ;
	;   https://autohotkey.com/board/topic/3770-how-does-a-script-gets-its-own-pid/#entry23655  ;
	;                                                                                           ;
	; WinGet :                                                                                  ;
	;   https://www.autohotkey.com/docs/commands/WinGet.htm#PID                                 ;
	;                                                                                           ;
	; WinExist :                                                                                ;
	;   https://www.autohotkey.com/docs/commands/WinExist.htm                                   ;
	;                                                                                           ;
	; CoordMode :                                                                               ;
	;   https://www.autohotkey.com/docs/commands/CoordMode.htm                                  ;
	;                                                                                           ;
	; MouseGetPos :                                                                             ;
	;   https://www.autohotkey.com/docs/commands/MouseGetPos.htm                                ;
	;                                                                                           ;
	; SetWinDelay :                                                                             ;
	;   https://www.autohotkey.com/docs/commands/SetWinDelay.htm                                ;
	;                                                                                           ;
	; WinMove :                                                                                 ;
	;    https://www.autohotkey.com/docs/commands/WinMove.htm                                   ;
	;                                                                                           ;
	;                                                                                           ;
	;-------------------------------------------------------------------------------------------;```
	
	Timer_refresh_tooltip_location_while_enabled:
	{
		if( true == _emulate_numpad_on ){
		
			if( "" == _tooltip_hwnd ){
			
				;----------------------------------------------------------------;
				;                                                                ;
				;  :=  means assign                                              ;
				;  .=  means append right hand side to end of toast_message      ;
				;                                                                ;
				;  `n  inserts a new line                                        ;
				;  `t  inserts a tab character                                   ;
				;                                                                ;
				;----------------------------------------------------------------;
				
				toast_message :=   "EMULATED NUMBER PAD"
				toast_message  .=  "`n`n`t`t"
				toast_message  .=  "[+]   ENABLED!`n"
				toast_message  .=  "`n"
				toast_message  .=  "---------------------------------------------------`n"
				toast_message  .=  "Press ?      `t for help.                          `n"
				toast_message  .=  "Press F1     `t to toggle legend.                  `n"
				toast_message  .=  "Press Escape `t to turn off.                       `n"
				toast_message  .=  "---------------------------------------------------"
				
				if( _settings__show_legend_in_persistent_tooltip ){
					toast_message  .=  "                                                `n"
					toast_message  .=  "                                                `n"
					toast_message  .=  "The following keys are remapped right now:      `n"
					toast_message  .=  "                                                `n"
					toast_message  .=  "      *-+       `t->`t Numpad(Mult,Sub,Add)     `n"
					toast_message  .=  "                                                `n"
					toast_message  .=  "     789        `t->`t Numpad(789)              `n"
					toast_message  .=  "     uio        `t->`t Numpad(456)              `n"
					toast_message  .=  "     jkl        Enter"
					toast_message  .=                  "`t->`t Numpad(123) Numpad(Enter)`n"
					toast_message  .=  "     m          `t->`t Numpad(0)                `n"
					toast_message  .=  "                                                `n"
					toast_message  .=  "      ./        `t->`t Numpad(Dot,Div)          `n"
					toast_message  .=  " "
				}
				
				ToolTip, %toast_message%
				
					;--------;`
					;   ?    ;
					;------------------------------------------------------------------------------;
					;  Why not rapidly recreate the ToolTip here, using a timer and less code?     ;
					;------------------------------------------------------------------------------;``
					;                                                                              ;
					;     Rapidly calling ToolTip with a timer                                     ;
					;     will result in the ToolTip intensely flickering.                         ;
					;                                                                              ;
					;     When a ToolTip is repositioned with WinMove, it doesn't flicker.         ;
					;                                                                              ;
					;------------------------------------------------------------------------------;```
				
				
				DetectHiddenWindows on
				WinGet, scriptPID, PID, %A_ScriptFullPath%
				_tooltip_hwnd := WinExist("ahk_class tooltips_class32 ahk_pid " scriptPID)
				
			}
			else{
			
				CoordMode, Mouse, Screen
				CoordMode, ToolTip, Screen
				MouseGetPos, Output_X, Output_Y
				
				x_for_tooltip := Output_X + 10 
				y_for_tooltip := Output_Y + 10
				
				SetWinDelay, -1
				WinMove, ahk_id %_tooltip_hwnd%,, %x_for_tooltip%, %y_for_tooltip%
				
			}
			
		}
		else{
		
			gosub Timer_turn_tooltip_off
			
		}
		
		return
	}


	Timer_turn_tooltip_off: 
	{
		;------------;`
		;    Docs    ;
		;-----------------------------------------------;
		;               Tooltip[, Text]                 ;
		;-----------------------------------------------;``
		;                                               ;
		; [Text] parameter :                            ;
		;                                               ;
		;   "If blank or omitted, the existing tooltip  ;
		;     (if any) will be hidden."                 ;
		;-----------------------------------------------;```

		ToolTip
		_tooltip_hwnd := ""

		return
	}


	Show_Help:
	{
		Help_Msg :=  ""
		Help_Msg  .= "-----------------------------------`n"
		Help_Msg  .= "emulate_numpad.ahk   v2            `n"
		Help_Msg  .= "-----------------------------------`n"
		Help_Msg  .= "                                                `n"
		Help_Msg  .= "NumberPad emulation is currently enabled.       `n"
		Help_Msg  .= "                                                `n"
		Help_Msg  .= "Some keyboard keys have been remapped           `n"
		Help_Msg  .= "to send NumberPad keystrokes                    `n"
		Help_Msg  .= "instead of their normal functionality.          `n"
		Help_Msg  .= "                                                `n"
		Help_Msg  .= "The following keys are remapped right now:      `n"
		Help_Msg  .= "                                                `n"
		Help_Msg  .= "      *-+       `t->`t Numpad(Mult,Sub,Add)     `n"
		Help_Msg  .= "                                                `n"
		Help_Msg  .= "     789        `t->`t Numpad(789)              `n"
		Help_Msg  .= "     uio        `t->`t Numpad(456)              `n"
		Help_Msg  .= "     jkl        Enter"
		Help_Msg  .=                 "`t->`t Numpad(123) Numpad(Enter)`n"
		Help_Msg  .= "     m          `t->`t Numpad(0)                `n"
		Help_Msg  .= "                                                `n"
		Help_Msg  .= "      ./        `t->`t Numpad(Dot,Div)          `n"
		Help_Msg  .= "                                                `n"
		Help_Msg  .= "     (?)        `t->`t shows this help box      `n"
		Help_Msg  .= "                                                `n"
		Help_Msg  .= "Press the <Escape> key                          `n"
		Help_Msg  .= "to exit this mode                               `n"
		Help_Msg  .= "and return the Keyboard to normal               `n"
		Help_Msg  .= "                                                `n"
		
		Option_QuestionMark := 32
		op := Option_QuestionMark
		title := "( HELP )  emulate_numpad.ahk"
		
		MsgBox, % op, %title%, %Help_Msg%
		
		return 
	}


	;===============================;
	;   end of Label section        ;
	;===============================;


	;-----------------------------------------------------------------------------------------------


	;------------------------------------------;---------------;
	;  end of file,   emulate_numpad.ahk       ;      cc0      ;
	;------------------------------------------;---------------;
   

	/* Fun Tweak:

		===============================================================
		Just for fun.
		===============================================================

			If you have a Scroll Lock key on your laptop 
			AND if you have an LED that lights up when you press it:
			
			you can configure this script to turn on the ScrollLock LED 
			whenever the NumberPad Emulation mode is enabled.
		
			
			=========================================================
			Change the toggle Label to this :
			=========================================================


				Toggle_Emulated_Numpad:
					
					_emulate_numpad_on := !_emulate_numpad_on
					
					;---------------------------------;
					;  Just for fun, scroll lock LED  ;
					;---------------------------------;
					
					gosub, Toggle_ScrollLock_LED
					
					gosub, Show_User_Tooltip_About_Emulation_State
					
				return 
					
					
			=========================================================
			And add the following label : 
			=========================================================
			
				Toggle_ScrollLock_LED:
						
					if( _emulate_numpad_on ){
						
						SetScrollLockState, On
						
					}
					else if( false == _emulate_numpad_on ){
						
						SetScrollLockState, Off
						
					}
					
				return

	*/