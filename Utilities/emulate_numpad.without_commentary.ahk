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


	Menu, Tray, Icon, Shell32.dll, 174

	_emulate_numpad_on := false


	_settings__show_persistent_tooltip_when_enabled := true
	_settings__show_legend_in_persistent_tooltip    := true
	_tooltip_hwnd := ""


	;-----------------------------------------------------------------------------------------------
	  

	;================================================;
	;                                                ;
	;                   Hotkeys                      ;
	;                                                ;
	;================================================;


	>^F12::
		gosub, Toggle_Emulated_Numpad
	return


	~Escape::
	{
		if( true == _emulate_numpad_on ){
			gosub, Toggle_Emulated_Numpad
		}
		return
	}


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
	

	;==================================;
	; </>  end of Hotkey definitions   ;
	;==================================;


	;-----------------------------------------------------------------------------------------------


	;================================================;
	;                                                ;
	;                    Labels                      ;
	;                                                ;
	;================================================;


	Toggle_Emulated_Numpad:
	{
		
		_emulate_numpad_on := !_emulate_numpad_on
		gosub, Show_User_Tooltip_About_Emulation_State
		
		return
	}

	Show_User_Tooltip_About_Emulation_State:
	{
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
		else if( false == _emulate_numpad_on ){
			
			toast_message :=  "EMULATED NUMBER PAD"
			toast_message  .= "`n`n`t`t"
			toast_message  .= "[-]   disabled.`n"
			
			ToolTip, %toast_message%
			
			SetTimer, Timer_turn_tooltip_off, -1500
			
		}
			
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
	
	Timer_refresh_tooltip_location_while_enabled:
	{
		if( true == _emulate_numpad_on ){
		
			if( "" == _tooltip_hwnd ){
			
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
