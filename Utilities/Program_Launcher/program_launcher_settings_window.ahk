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
	;  program_launcher_settings_window.ahk                                 ;
	;-----------------------------------------------------------------------;
	;                                                                       ;
	;                                                     version 2         ;
	;                                                                       ;
	;  This file contains the GUI interface for program_launcher.ahk.       ;
	;                                                                       ;
	;  To open this GUI config window:                                      ;
	;                                                                       ;
	;     (1) Run program_launcher.ahk,                                     ;
	;     (2) Use the command to open the settings,                         ;
	;         (by default, the command is "config", no quotes).             ;
	;                                                                       ;
	;         This script's code will be used to show the user              ;
	;         a settings window which facilitates modifying                 ;
	;         the settings.ini file.                                        ;
	;                                                                       ;
	;   This file cannot be run in isolation.                               ;
	;   It's really just the second half of program_launcher.ahk,           ;
	;   but separated into a second file to improve readability.            ;
	;-----------------------------------------------------------------------;
	
	
	class GuiConfigMain {
	
		;----------------------------------------------------------------------
		; These text strings are specific to the checkbox at the bottom 
		; of Tab1 of this window. These vars won't be altered, only accessed.
		;
		static CheckboxShowAll_TextForChecked  := "SHOW ALL   (Uncheck to hide disabled commands)   "
		static CheckboxShowAll_TextForUnchecked := "SHOW ALL   (Check to also show disabled commands)"
		
		
		static _plucked_command := ""
		static _plucked_action  := ""
		
		static _is_gui_baked := false


		__New() {
		; global 
			
			;------------------------------;
			; Global vars to use elsewhere
			;
			
		
			GuiConfigMain.Initialize_Gui_gVariables()
			
			GuiConfigMain.Init_Config_Gui_and_TabControl()
			GuiConfigMain.Init_Config_1st_Tab()
			GuiConfigMain.Init_Config_2nd_Tab()
			GuiConfigMain.Init_Config_3rd_Tab()
			GuiConfigMain.Init_Config_4th_Tab()
			
			GuiConfigMain.Fn_Action_Buttons_Disable()
			
			;==================================;
			; Render + Display main GUI window ;
			;==================================;
			
			Gui, ConfigMain:Show
		
			; _is_MainGui_baked := true 
			GuiConfigMain.GUI_EVENT_OnSize( "Gui up and running" )
			
			GuiConfigMain.Init_ReadProgramArraysIntoGui()
			
			GuiConfigMain._is_gui_baked := true 
			
			return this
		}
		
		__Delete() {
		; global 
		
			; Clear static class members between Config Window instances.
					
			GuiConfigMain._plucked_command := ""
			GuiConfigMain._plucked_action  := ""
			
			; Clear static function variables in OnSize() function
			
			GuiConfigMain.GUI_EVENT_OnSize( "RESET" )
			GuiConfigMain._is_gui_baked := false
			
			Gui ConfigMain: Destroy
			
			return
		}
		
		;============================================================
		;         GuiConfigMain (Main Window)  
		;============================================================

		
		Initialize_Gui_gVariables() {
		global
		
			;-------------------------------------------------------------------------
			; 
			; It's a good practice to clear global variables 
			; for GUIs which are created multiple times over the lifespan of a script.
			; 
			;-------------------------------------------------------------------------		
			
			GuiConfigMain_Tabs                              := ""
			
			GuiConfigMain_ListViewCmds                      := ""
			GuiConfigMain_ButtonNewCmd                      := ""
			GuiConfigMain_ButtonEditCmd                     := ""
			GuiConfigMain_ButtonDeleteCmd                   := ""
			GuiConfigMain_CheckboxShowAll                   := ""
			
			GuiConfigMain_ListViewActions                   := ""
			GuiConfigMain_ButtonNewAction                   := ""
			GuiConfigMain_ButtonEditAction                  := ""
			GuiConfigMain_ButtonDeleteAction                := ""
			
			GuiConfigMain_Settings_ABOUT                    := ""
			GuiConfigMain_Settings_ButtonExport             := ""
			GuiConfigMain_Settings_ButtonImportAsDisabled   := ""  
			GuiConfigMain_Settings_ButtonImportAsEnabled    := ""
			GuiConfigMain_Settings_Info                     := ""
			 
			
			return
		}
		
		
		Init_Config_Gui_and_TabControl() {
		global
		
			;========================;
			; Create main GUI window ;
			;========================;
			
			  title_for_GuiConfigMain_Window := "_program_launcher.ahk - Configuration"
			options_for_GuiConfigMain_Window := A_Space "+Label" "GuiConfigMain.GUI_EVENT_On"
			options_for_GuiConfigMain_Window .= A_Space "+Resize +MinSize420x375"

			Gui, ConfigMain:New
				, %options_for_GuiConfigMain_Window%
				, %title_for_GuiConfigMain_Window%


			;--------------------------------;
			; Ensures future "Gui," commands 
			; add specifically to the Gui 
			; using the name "ConfigMain:". 
			;
			Gui, ConfigMain:Default
				
				
			;=========================================================;
			; Hidden Button to allow detection of <Enter> key events  ;
			;=========================================================;
		  
			options :=  A_Space "g" "GuiConfigMain.GUI_EVENT_ButtonHiddenDefault"
			options  .= A_Space "+Hidden +Default w0 h0"
			Gui, ConfigMain:Add, Button
				, %options%
				, ""


			;================================
			; Add Tab Container with 3 tabs
			; - Commands
			; - Actions
			; - Settings
			;================================

			   text := "Commands|Actions|Settings|   ?   "
			options :=  A_Space "g" "GuiConfigMain.GUI_EVENT_Tabs"
			options  .= A_Space "v" "GuiConfigMain_Tabs"
			   
			   
			Gui, ConfigMain:Add, Tab3
				, %options%
				, %text%
				
			return
		}
		
		Init_Config_1st_Tab() {
		global
		
		  ;[1][1][1][1][1][1][1][1][1][1][1][1][1]~
		  ;---------------TAB SWITCH---------------
		  ;
		  ; 1st Tab will receive 
		  ; Gui Controls added after this line
		  ;
		  ;---------------TAB SWITCH---------------
		  ;[1][1][1][1][1][1][1][1][1][1][1][1][1]~
			
			Gui, Tab, 1		

			
			;=======================;
			; ListView for Commands ;
			;=======================;

			  ;------------------------------------------------------------
			  ; Note:
			  ;   The style "LV0x10000" is LVS_EX_DOUBLEBUFFER, 
			  ;   and (in some cases) helps reduce flikering upon redrawing
			  ;------------------------------------------------------------
			  ; Read More Here:
			  ;   https://autohotkey.com/board/topic/89323-listview-and-flashing-on-redrawing-or-editing/
			  ;   https://www.autohotkey.com/docs/misc/Styles.htm#ListView
			  ;------------------------------------------------------------
			
			text_column1 := "Command     "
			text_column2 := "|->"
			text_column3 := "|Action ID"
			text_column4 := "|Action Type"
			text_column5 := "|Action Path"
			text_column6 := "|Action Arg for Programs"
			text := text_column1
				  .  text_column2
				  .  text_column3
				  .  text_column4
				  .  text_column5
				  .  text_column6
				  
			options :=  A_Space "g" "GuiConfigMain.GUI_EVENT_ListViewCommands" 
			options  .= A_Space "v"           "GuiConfigMain_ListViewCmds" 
			options  .= A_Space "+checked +ReadOnly +AltSubmit -Multi" 
			options  .= A_Space "r20 w700" 
			options  .= A_Space "+LV0x10000" 
			
			Gui, ConfigMain:Add, ListView
				, %options%
				,    %text%
			

			;================================;
			; Button to create a new Command ;
			;================================;
			
			   text := "[ + ] New Command"
			options :=  A_Space "g" "GuiConfigMain.GUI_EVENT_ButtonNewCmd"
			options  .= A_Space "v"           "GuiConfigMain_ButtonNewCmd"
			options  .= A_Space "section"
			
			Gui, ConfigMain:Add, Button
				, %options%
				,    %text%
			
			;================================;
			; Button to Edit a Command ;
			;================================;
			
			   text := "[ : ] Edit Selected`nCommand"
			options :=  A_Space "g" "GuiConfigMain.GUI_EVENT_ButtonEditCmd"
			options  .= A_Space "v"           "GuiConfigMain_ButtonEditCmd"
			options  .= A_Space "ys"
			
			Gui, ConfigMain:Add, Button
				, %options%
				,    %text%
				
			;================================;
			; Button to Delete a Command ;
			;================================;
			
			   text := "[ x ] Delete Selected`nCommand"
			options :=  A_Space "g" "GuiConfigMain.GUI_EVENT_ButtonDeleteCmd"
			options  .= A_Space "v"           "GuiConfigMain_ButtonDeleteCmd"
			options  .= A_Space "ys"
			
			Gui, ConfigMain:Add, Button
				, %options%
				,    %text%
			
			
			;===========================;
			; CheckBox to toggle        ;
			; - display all             ;
			; - or just display enabled ;
			;===========================;

			   text := GuiConfigMain.CheckboxShowAll_TextForChecked
			options :=  A_Space "g" "GuiConfigMain.GUI_EVENT_CheckboxShowAll" 
			options  .= A_Space "v"           "GuiConfigMain_CheckboxShowAll"
			options  .= A_Space "xs y+10"
			options  .= A_Space "Checked" "1"
			
			Gui, ConfigMain:Add, CheckBox
				, %options%
				,    %text%
			
			
			return 
		}

		Init_Config_2nd_Tab() {
		global
		
		  ;[2][2][2][2][2][2][2][2][2][2][2][2][2]~
		  ;---------------TAB SWITCH---------------
		  ;
		  ; 2nd Tab will receive 
		  ; Gui Controls added after this line
		  ;
		  ;---------------TAB SWITCH---------------
		  ;[2][2][2][2][2][2][2][2][2][2][2][2][2]~
			
			Gui, Tab, 2	


			;=======================;
			; ListView for Actions ;
			;=======================;

			gui_name     := "ConfigMain"
			goto_name    := "GuiConfigMain.GUI_EVENT_ListViewActions"
			control_name := "GuiConfigMain_ListViewActions"
			REUSABLE_GUI_CONTROLS.create_listview_of_actions( gui_name
				, goto_name
				, control_name )
			

			
			;================================;
			; Button to create a new Action  ;
			;================================;
			
			   text := "[ + ] New Action "
			options :=  A_Space "g" "GuiConfigMain.GUI_EVENT_ButtonNewAction"
			options  .= A_Space "v"           "GuiConfigMain_ButtonNewAction"
			options  .= A_Space "section"
			
			Gui, ConfigMain:Add, Button
				, %options%
				,    %text%


			;================================;
			; Button to Edit an Action       ;
			;================================;
			
			   text := "[ : ] Edit Selected`nAction"
			options :=  A_Space "g" "GuiConfigMain.GUI_EVENT_ButtonEditAction"
			options  .= A_Space "v"           "GuiConfigMain_ButtonEditAction"
			options  .= A_Space "ys x137"
			
			Gui, ConfigMain:Add, Button
				, %options%
				,    %text%
				
			;================================;
			; Button to Delete an Action     ;
			;================================;
			
			   text := "[ x ] Delete Selected`nAction"
			options :=  A_Space "g" "GuiConfigMain.GUI_EVENT_ButtonDeleteAction"
			options  .= A_Space "v"           "GuiConfigMain_ButtonDeleteAction"
			options  .= A_Space "ys"
			
			Gui, ConfigMain:Add, Button
				, %options%
				,    %text%
			
				
			;================================;
			; Button to Run an Action        ;
			;================================;
			
			Gui, Tab, 
			
			   text := "Run selected Action now."
			options :=  A_Space "g" "GuiConfigMain.GUI_EVENT_ButtonRunAction"
			options  .= A_Space "v"           "GuiConfigMain_ButtonRunAction"
			options  .= A_Space "ym x600"
			options  .= A_Space "+Hidden"
			
			Gui, ConfigMain:Add, Button
				, %options%
				,    %text%
			
			
			return 
		}
		
		Init_Config_3rd_Tab() {
		global 
		
		  ;[3][3][3][3][3][3][3][3][3][3][3][3][3]~
		  ;---------------TAB SWITCH---------------
		  ;
		  ; 3rd Tab will receive 
		  ; Gui Controls added after this line
		  ;
		  ;---------------TAB SWITCH---------------
		  ;[3][3][3][3][3][3][3][3][3][3][3][3][3]~
			
			Gui, Tab, 3	
			


			;========================================;
			; Button to change Application icon      ;
			;========================================;
			
			   text :=  "Change Window Icon."
			options :=  A_Space "g" "GuiConfigMain.GUI_EVENT_Settings_ButtonIcon"
			options  .= A_Space "v" "GuiConfigMain_Settings_ButtonIcon"
			options  .= A_Space "y+30 x+35"
			
			Gui, ConfigMain:Add, Button
				, %options%
				,    %text%
				

			;========================================;
			; Button to create a backup of settings  ;
			;========================================;
			
			   text :=  "Export a backup file."
			options :=  A_Space "g" "GuiConfigMain.GUI_EVENT_Settings_ButtonExport"
			options  .= A_Space "v" "GuiConfigMain_Settings_ButtonExport"
			; options  .= A_Space "y+12"
			options  .= A_Space "y+30"
			
			Gui, ConfigMain:Add, Button
				, %options%
				,    %text%
				
			
			;==========================================;
			; Button to import settings (disable cmds) ;
			;==========================================;
			
			   text := "Import a backup file (but disable all imported commands)."
			options :=  A_Space "g" "GuiConfigMain.GUI_EVENT_Settings_ButtonImportAsDisabled"
			options  .= A_Space "v" "GuiConfigMain_Settings_ButtonImportAsDisabled"
			options  .= A_Space " y+12"
			
			Gui, ConfigMain:Add, Button
				, %options%
				,    %text%
			
			
			;==========================================;
			; Button to import settings (enable cmds)  ;
			;==========================================;
			
			   text := "Import a backup file (and enable all imported commands)."
			options :=  A_Space "g" "GuiConfigMain.GUI_EVENT_Settings_ButtonImportAsEnabled"
			options  .= A_Space "v" "GuiConfigMain_Settings_ButtonImportAsEnabled"
			options  .= A_Space " y+12"
			
			Gui, ConfigMain:Add, Button
				, %options%
				,    %text%


			;=========================================
			; Add `Text` Label:
			;-----------------------------------------
			; Inform User Drag-n-Drop is possible here
			;=========================================

			   text :=  ""
			   text  .= "  Auto-Save:`n`n"
			   text  .= "     Actions, Commands, and Settings are automatically saved `n"
			   text  .= "     the moment you change them (add, edit, enable/disable, delete).`n`n"
			   text  .= "     Actions, Commands, and Settings are saved to`n"
			   text  .= "     _program_launcher_settings.ini.`n`n"
			   text  .= "  On this tab :`n`n"
			   text  .= "     You can make a backup of this settings file,`n"
			   text  .= "     or add settings into your current save file`n"
			   text  .= "     by importing data from a backup."
			   ; text  .= "`n`n`n"
			   
			options :=  A_Space "v" "GuiConfigMain_Settings_Info"
			options  .= A_Space "Border "
			options  .= A_Space "y+30 w700 r10"
			options  .= A_Space "x20"
			options  .= A_Space "+ReadOnly"
			
			Gui, Font,s12
			
			Gui, ConfigMain:Add, Edit
				, %options%
				, %text% 
			
			Gui, Font
				

			return
		}

		Init_Config_4th_Tab() {
		global 
		
		  ;[3][3][3][3][3][3][3][3][3][3][3][3][3]~
		  ;---------------TAB SWITCH---------------
		  ;
		  ; 3rd Tab will receive 
		  ; Gui Controls added after this line
		  ;
		  ;---------------TAB SWITCH---------------
		  ;[3][3][3][3][3][3][3][3][3][3][3][3][3]~
			
			Gui, Tab, 4
			
			
			;=========================================
			; Add `Edit` readonly Label: about 
			;=========================================
			
			   text := GuiConfigMain.Fn_AboutTab_Get_Text()
			options :=  A_Space "v" "GuiConfigMain_Settings_ABOUT"
			options  .= A_Space "Border "
			options  .= A_Space "y+30"
			options  .= A_Space "+Readonly"
			   
			Gui, Font,s12, Courier New
			
			Gui, ConfigMain:Add, Edit
				, %options%
				, %text% 
				
			Gui, Font

			return
		}
		
		Init_ReadProgramArraysIntoGui() {
		global

			; Tells future ListView operations to operate on this specific ListView control
			GuiConfigMain.ListViewCommands_Activate()
			
			;------------------;
			; syntax reference ; 
			;-----------------------------------------------------------------;
			;   _COMMANDS := { "godot" : {"action_id":1, "enabled":true} }    ;
			;-----------------------------------------------------------------;
			for cmd, cmd_info in _COMMANDS {

				action      := ""
				action_type := ""
				action_path := ""
				action_arg  := ""
				
				cmd_action_id  := cmd_info["action_id"]
				cmd_is_enabled := cmd_info["enabled"]
				
				
				;------------------------------------------------------
				; AutoHotkey Docs, Ternary Operator: 
				; https://www.autohotkey.com/docs/Variables.htm#ternary
				;
				lv_cmd_options := (true==cmd_is_enabled) ? "+Check" : "-Check"
				
					
				;==================================
				; Get the Command's Action Data
				;==================================
				
				if( _ACTIONS.HasKey(cmd_action_id) ){
					action := _ACTIONS[cmd_action_id]
					action_type := action["type"]
					action_path := action["path"]
					action_arg  := action["arg"]
					; msgbox does have action id
				}
				
				;======================================================
				; Add the Command to GuiConfigMain's Command ListView 
				;======================================================
				
				if( cmd_action_id!="" and action_type!="" and action_path!="" ){
					
					LV_Add(lv_cmd_options   ; Check row if Command is enabled
						, cmd                 ; row 1
						, ""                  ; row 2
						, cmd_action_id       ; row 3
						, action_type         ; row 4
						, action_path         ; row 5
						, action_arg )        ; row 6
					
				}
				else if( "SETTINGS" = cmd_action_id
				or       "QUIT"     = cmd_action_id ){
					
					LV_Add(lv_cmd_options   ; Check row if Command is enabled
						, cmd                 ; row 1
						, ""                  ; row 2
						, cmd_action_id       ; row 3
						, ""                  ; row 4
						, ""                  ; row 5
						, "" )                ; row 6
						
				}
				else{ ;error;
					error_msg :=  "Error in Initialization of Main.LV.Cmds `n "
					error_msg  .= "cmd_action_id [" cmd_action_id "] `n "
					error_msg  .= "action_type   ["  action_type  "] `n "
					error_msg  .= "action_path   ["  action_path  "] `n "
					MSGBOX, , Error, %error_msg%
				}
			}
			
			LV_ModifyCol(3, "Sort")
			GuiConfigMain.ListViewCommands_ReadjustAllCols()
			GuiConfigMain.ListViewActions_ReadjustAllCols()
			
			return
		}

		
		;-----------------------------------------------
		; <Enter> key pressed.
		;-----------------------------------------------
		; Crude workaround recommended by the AHK Docs.
		;
		GUI_EVENT_ButtonHiddenDefault() {
		global

			;------------------------------------------
			; Refreshes the variable GuiConfigMain_Tabs
			; which stores the current tab name
			;------------------------------------------

			Gui, ConfigMain:Submit, NoHide 

			if( GuiConfigMain_Tabs == "Commands" ){

				;-----------------------------------------------------
				; Edit the currently selected Command (if selection)
				;-----------------------------------------------------
				
				; GuiConfigMain.Create_Popup_Command()
				GuiConfigMain.Create_Popup("command")
			}
			else if( GuiConfigMain_Tabs == "Actions" ){

				;-----------------------------------------------------
				; Edit the currently selected Action (if selection)
				;-----------------------------------------------------
			
				; GuiConfigMain.Create_Popup_Action()
				GuiConfigMain.Create_Popup("action")
			}
		return
		}

		GUI_EVENT_OnSize( FLAG:="" ) {
		global
			
			;=====================================================
			;         Upon resizing the GUI window, 
			;        
			;         readjust Control :
			;           - placement 
			;           - width  (where applicable) 
			;           - height (where applicable) 
			;        
			;         to maintain a consistent layout.
			;=====================================================
			
			;-------------------------------------------------
			; Static variables in a function 
			; will retain their value between function calls.
			;-------------------------------------------------
			
			static is_MainGui_baked := false 
			static GuiHeight 
			static GuiWidth
			
			static offset_y_from_tabcontainer := "" 
			static ar_offset_from_bottom := []
			static ar_offset_from_right  := []
			static ar_reposition_ctrls := [ ""
					.     "GuiConfigMain_CheckboxShowAll"
						, "GuiConfigMain_ButtonNewCmd" 
						, "GuiConfigMain_ButtonEditCmd" 
						, "GuiConfigMain_ButtonDeleteCmd" 
						, "GuiConfigMain_ButtonNewAction" 
						, "GuiConfigMain_ButtonEditAction" 
						, "GuiConfigMain_ButtonDeleteAction" ]		
			static ar_resize_ctrls := [ ""
					.     "GuiConfigMain_Tabs" 
						, "GuiConfigMain_ListViewCmds"
						, "GuiConfigMain_ListViewActions"
						, "GuiConfigMain_Settings_Info"
						, "GuiConfigMain_Settings_ABOUT" ]		
				
			/*
			
			GuiConfigMain_Tabs                              := ""
			GuiConfigMain_ListViewCmds                      := ""
			GuiConfigMain_ButtonNewCmd                      := ""
			GuiConfigMain_ButtonEditCmd                     := ""
			GuiConfigMain_ButtonDeleteCmd                   := ""
			GuiConfigMain_CheckboxShowAll                   := ""
			GuiConfigMain_ButtonNewAction                   := ""
			GuiConfigMain_ButtonEditAction                  := ""
			GuiConfigMain_ButtonDeleteAction                := ""
			GuiConfigMain_Settings_ABOUT                    := ""
			GuiConfigMain_Settings_ButtonExport             := ""
			GuiConfigMain_Settings_ButtonImportAsDisabled   := ""  
			GuiConfigMain_Settings_ButtonImportAsEnabled    := ""
			GuiConfigMain_Settings_Info                     := ""
			
			*/
			
			;---------------------------------------------------------------------
			; NOTE:
			;---------------------------------------------------------------------
			;
			; The Gui Event "OnSize" is called when a window is first rendered
			; but A_GuiHeight and A_GuiWidth aren't present 
			; when we call this function manually with 
			;    
			;    GuiConfigMain.GUI_EVENT_OnSize("Some Flag")
			; 
			; As soon as these are initialized, we'll store a copy 
			; in these function static vars.
			; 
			; This will allow us to reference these dimensions 
			; when we call this "OnSize" event function manually
			;---------------------------------------------------------------------
			;
			if( "" != A_GuiHeight 
			and "" != A_GuiWidth ){
				GuiHeight := A_GuiHeight
				GuiWidth := A_GuiWidth
			}
			
			
		  ;******************************************************************************
		  ;
		  ;                     Manual Function Calls with Flags
		  ;
		  ;******************************************************************************
			
			;==========================================
			; Initialize static vars & control offsets
			;==========================================
			
			if( "Gui up and running" == FLAG){
				is_MainGui_baked  := true 
				
				;----------------------------------------------
				; Controls in Tab Containers 
				; have a hidden additional offset 
				;
				; Hacky offset found through trial-and-error 
				;
				c := "GuiConfigMain_ListViewCmds"
				GuiControlGet, TabContainer, Pos, %c%
				offset_y_from_tabcontainer := TabContainerY - 6
				
				;-----------------------------------------------------------------
				; For each Control where we only need to adjust its y-coordinate
				;-----------------------------------------------------------------
				; (1) Find how far away from the bottom it is initially.
				; (2) Upon window resize, 
				;     reposition the y-coordinate to maintain this offset consistently.
				;
				for i, c in ar_reposition_ctrls
				{
					GuiControlGet, ctrl_, Pos, %c%
					
					offset_from_bottom := GuiHeight - (ctrl_y  - offset_y_from_tabcontainer)
					ar_offset_from_bottom[c] := offset_from_bottom					
				}
				
				;-----------------------------------------------------------------
				; For each Control where we only need to stretch the height
				;-----------------------------------------------------------------
				; (1) Find the amount of space between the bottom of the control 
				;     and the bottom of the window (all these Controls are 
				;     positioned at the top of the window, so keep that in mind
				;     if altering or reusing this code).
				; (2) Upon window resize, stretch Control's height 
				;     to maintain this bottom offset consistently.
				;
				for i, c in ar_resize_ctrls
				{
					GuiControlGet, ctrl_, Pos, %c%
				
					offset_from_bottom := GuiHeight - ctrl_h
					ar_offset_from_bottom[c] := offset_from_bottom		
				}		
				
				c := "GuiConfigMain_ButtonRunAction"
				GuiControlGet, ctrl_, Pos, %c%
				ar_offset_from_right[c] := GuiWidth - ctrl_x
				
				;----------------------------------------------------
				; When called manually, 
				; A_GuiHeight and A_GuiWidth 
				; will not be populated by AutoHotkey Event handling
				;
				return 

			}
			else if( "RESET" == FLAG ){
				is_MainGui_baked  := false
				GuiHeight := ""
				GuiWidth := ""
				return
			}
			
			
		  ;******************************************************************************
		  ;
		  ;                    AutoHotkey Event calls to OnSize()
		  ;
		  ;******************************************************************************

			;==========================================
			; Adjust size and positioning of Controls
			; when Gui Window is resized.
			;==========================================
				
			if( true == is_MainGui_baked) ; ensures this is only called after our static vars are initialized
			{
				
				;---------------------------------
				; Adjust y-position of 
				;
				; GuiConfigMain_CheckboxShowAll
				; GuiConfigMain_ButtonNewCmd 
				; GuiConfigMain_ButtonNewAction
				;---------------------------------
				
				for j, c in ar_reposition_ctrls
				{
					offset :=  ar_offset_from_bottom[c]
					destination_y := A_GuiHeight - offset
					
					; GuiControl, ConfigMain: MoveDraw, %c%, % "y" destination_y
					GuiControl, ConfigMain: Move,     %c%, % "y" destination_y					
				}
				
				c := "GuiConfigMain_ButtonRunAction"
				offset :=  ar_offset_from_right[c]
				destination_x := A_GuiWidth - offset
				GuiControl, ConfigMain: Move,     %c%, % "x" destination_x		
				
				
				;---------------------------------
				; Adjust Size of 
				;
				; Tab box 
				; ListView: Commands 
				; ListView: Actions
				;---------------------------------
				
				c := "GuiConfigMain_ListViewCmds"
				GuiControlGet, ctrl_LV_, Pos, %c%
				offset_LV :=  ar_offset_from_bottom[c]
				
				c := "GuiConfigMain_Tabs"
				GuiControlGet, ctrl_tab_, Pos, %c%
				offset_tab :=  ar_offset_from_bottom[c]
				
				c := "GuiConfigMain_Settings_Info"
				offset_info :=  ar_offset_from_bottom[c]
				
				options_LV := ""
				options_tab := ""
				
					options_tab .= " h" A_GuiHeight - offset_tab				
					options_LV  .= " h" A_GuiHeight - offset_LV
					options_info .= " h" A_GuiHeight - offset_info
					
					options_LV  .= " w" A_GuiWidth - (ctrl_LV_X * 2)				
					options_tab .= " w" A_GuiWidth - (ctrl_tab_X * 2)
					
					options_info  .= " w" A_GuiWidth - (ctrl_LV_X * 2)
					options_about .= " w" A_GuiWidth - (ctrl_LV_X * 2)
					
				
				c := "GuiConfigMain_ListViewCmds"
				; GuiControl, ConfigMain: MoveDraw,     %c%, %options_LV%
				GuiControl, ConfigMain: Move,     %c%, %options_LV%
				
				
				c := "GuiConfigMain_ListViewActions"
				; GuiControl, ConfigMain: MoveDraw,     %c%, %options_LV%
				GuiControl, ConfigMain: Move,     %c%, %options_LV%
			
				c := "GuiConfigMain_Settings_Info"
				; GuiControl, ConfigMain: MoveDraw,     %c%, %options_info%
				GuiControl, ConfigMain: Move,     %c%, %options_info%
				
				c := "GuiConfigMain_Settings_ABOUT"
				about_text := GuiConfigMain.Fn_AboutTab_Get_Text(A_GuiWidth)
				; GuiControl, ConfigMain: , %c%, ""
				GuiControl, ConfigMain: , %c%, %about_text%
				; msgbox %about_text%
				if( A_GuiWidth < 585){
					; GuiControl, ConfigMain: MoveDraw,     %c%, %options_info%
					GuiControl, ConfigMain: Move,     %c%, %options_about%
				}
				else{
					GuiControl, ConfigMain: Move,     %c%, w527
				}
				
				
				
				c := "GuiConfigMain_Tabs"
				GuiControl, ConfigMain: MoveDraw,     %c%, %options_tab%
				; GuiControl, ConfigMain: Move,     %c%, %options_tab%
				
				
				;---------------------------------------------------------------------------------
				; Calling these readjust functions here 
				; will prevent a horizontal scroll bar from appearing when unnecessary.
				;
				; However, adding these lines causes the ListView headers for the columns 
				; to frequently fail to repaint (due to rapid MoveDraw calls).
				;
				;      GuiConfigMain.ListViewActions_ReadjustAllCols()
				;      GuiConfigMain.ListViewCommands_ReadjustAllCols()
				;---------------------------------------------------------------------------------
				
			}
			
			return
		}
		
		GUI_EVENT_OnEscape() {
		global
			return
		}
		
		GUI_EVENT_OnClose() {
		global
		
				_o_Gui_Config_Main := ""
				
			return
		}

		GUI_EVENT_OnDropFiles() {
		global
		
			;---------------------------------------------------------------------
			; AutoHotkey Docs for GuiDropFiles
			;---------------------------------------------------------------------
			; A_EventInfo and ErrorLevel:
			;   Both contain the number of files dropped.
			;---------------------------------------------------------------------
			; A_GuiEvent:
			;   Contains the names of the files that were dropped, 
			;   with each filename except the last terminated by a linefeed (`n).
			;---------------------------------------------------------------------
			; https://www.autohotkey.com/docs/commands/Gui.htm#GuiDropFiles
			;---------------------------------------------------------------------
			
			Gui, ConfigMain:Submit, NoHide 
			
			if( GuiConfigMain_Tabs == "Actions" ){
			
				;--------------------------------------------
				; Populate GUI data with drag-n-dropped file.
				;--------------------------------------------
				; User dropped 1 file onto GuiConfigPopup GUI 
				;--------------------------------------------
				if( A_EventInfo == 1 ){
					
					is_dragNdrop_valid := FileExist(A_GuiEvent)
			
					if( "" !=  is_dragNdrop_valid ){
					
						if( _o_Gui_Config_Popup == "" ){
							_o_Gui_Config_Popup := new GuiConfigPopup("action"
																	, "add"
																	, NA_lv_row:=""
																	, silent:=true)
							
							if( InStr(is_dragNdrop_valid, "D") ){
								; populate as dir 
								
								GuiControl,, GuiConfigPopup_ActionConfig_RadioFolder, 1
								GuiControl,, GuiConfigPopup_ActionConfig_RadioApp   , 0
								
								GuiControl,, GuiConfigPopup_ActionConfig_InputPath, %A_GuiEvent%
							}
							else {
								; populate as file 
								
								GuiControl,, GuiConfigPopup_ActionConfig_RadioFolder, 0
								GuiControl,, GuiConfigPopup_ActionConfig_RadioApp   , 1
								
								GuiControl,, GuiConfigPopup_ActionConfig_InputPath, %A_GuiEvent%
							}
							_o_Gui_Config_Popup.Submit_Changes()
							_o_Gui_Config_Popup := ""
						}
					}
				}
				;----------------------------------------------------
				; Unsupported.
				;----------------------------------------------------
				; User dropped more than 1 file onto GuiConfigPopup GUI 
				;----------------------------------------------------
				else if( A_EventInfo > 1 ){
					str_for_usr_output := "_program_launcher.ahk`n`n"
					str_for_usr_output .= "--------------`nOops`n--------------`n"
					str_for_usr_output .= """Edit a Command"" can't process more than one file.`n`n"
					str_for_usr_output .= "Ensure you only have one file selected `n"
					str_for_usr_output .= "in Windows Explorer.`n`n"
					str_for_usr_output .= "Then try to drag-and-drop it onto this window again.`n"
					
					MsgBox,, % "[X] Can't process more than one file for a path.", %str_for_usr_output%
				}
			}
			
			return
		}


		GUI_EVENT_Tabs() {
		global 
			
			;------------------------------------------
			; Refreshes the variable GuiConfigMain_Tabs
			; which stores the current tab name
			;------------------------------------------

			Gui, ConfigMain:Submit, NoHide 
			
			if( GuiConfigMain_Tabs == "Actions" ){
				GuiControl, ConfigMain: -Hidden, GuiConfigMain_ButtonRunAction
			}
			else{
				GuiControl, ConfigMain: +Hidden, GuiConfigMain_ButtonRunAction
			}
			return
		}

		GUI_EVENT_ListViewActions() {
		global
			
			;-----------------------------------------------------
			; If events are being triggered
			; while the popup is altering or inserting new entries
			; ignore event.
			;
			if("" != _o_Gui_Config_Popup ){
				return
			}
			
			; msgbox A_EventInfo %A_EventInfo%
			if (A_GuiEvent = "DoubleClick")
			{
				; GuiConfigMain.Create_Popup_Action()
				GuiConfigMain.Create_Popup("action")
			}

			;--------------------------------------
			; user has edited first field of a row 
			if (A_GuiEvent = "e")
			{
				GuiConfigMain.ListViewActions_ReadjustAllCols()
			}
			
			;--------------------------
			; An Item Changed
			;
			if ( "I" = A_GuiEvent ){
				
				;===================================================
				; ENABLE / DISABLE state changed for a Command
				;===================================================
				
				;-------------------------------------------
				; Event was either Select (S) or Deselect (s)
				;
				if( InStr(ErrorLevel, "S") ){
					
					; Tells future ListView operations to operate on this specific ListView control
					GuiConfigMain.ListViewActions_Activate()
				
					;-------------------------------------------
					; Get Action ID for that row in the ListView 
					;
					sel_act_id := ""
					LV_GetText(sel_act_id, A_EventInfo, 1)
					
					;---------------------------------------------------
					; If a row is selected, 
					; ErrorLevel will contain a "S" in its string.
					;
					; If a row is deselected, 
					; ErrorLevel will contain a "s" in its string.
					;---------------------------------------------------
					
					was_item_selected   := InStr(ErrorLevel, "S", CaseSensitive:=true)
					;~ was_item_deselected := InStr(ErrorLevel, "s", CaseSensitive:=true)
					
					
					;=====================================================================
					;                             WARNING
					;=====================================================================
					;
					;    Additionally using else if(was_item_deselected)... branches:
					;  
					;       will sometimes (randomly) incorrectly break 
					;       the "Edit Action" / "Delete Action" buttons 
					;       when the user has selected a valid, editable Action entry. 
					;  
					;    This is due to rapid calling of ListView 
					;    event functions, and the lag in response time
					;    will sometimes result in the program glitching into a 
					;    state desynchronized with the logic here.
					;  
					;    The following if logic was therefore carefully chosen:
					;    
					;    (A)  It always enables the buttons when a valid entry is selected
					;         (without the same event triggering any other code branches)
					;  
					;    (B)  It only calls disable when either:
					;         - all entries are deselected or
					;         - an entry for QUIT or SETTINGS is selected
					;         (without the same event triggering any other code branches)
					;  
					;  
					;  As great as AutoHotkey is for simple User Interfaces, 
					;  this is perhaps its biggest shortcoming.
					;
					;  When you've debugged your code, but you're still 
					;  encountering unexpected behavior, look to your Event functions.
					;=====================================================================
					
					
					;--------------------------------------------------------------
					; If QUIT or SETTINGS selected, disable edit + delete buttons.
					; If anything else selected, enable edit + delete buttons.
					;
					if( was_item_selected ){
						if( "QUIT"     != sel_act_id 
						and "SETTINGS" != sel_act_id ){
							GuiConfigMain.Fn_Action_Buttons_Enable()
						}
						else{
							allow_run := false 
							if( "QUIT" == sel_act_id ){
								allow_run := true
							}
							GuiConfigMain.Fn_Action_Buttons_Disable( allow_run )
						}
					}
					
					;---------------------------------
					; If nothing is selected
					; disable edit + delete buttons.
					;
					if( 0 == LV_GetNext(0) ){
						GuiConfigMain.Fn_Action_Buttons_Disable()					
					}
					
					
				}
				
			}
			
			return
		}

		GUI_EVENT_ListViewCommands() {
		global
			
			;-----------------------------------------------------
			; If events are being triggered
			; while the popup is altering or inserting new entries
			; ignore event.
			;
			if("" != _o_Gui_Config_Popup ){
				return
			}
			
			;------------------------------------------
			; If Gui not initialized yet, 
			; don't respond to checkmark events.
			;
			if(false == GuiConfigMain._is_gui_baked){
				return
			}
			
			;-----------------------------------
			; User Double-Clicked 
			; either a row or a blank space.
			;
			if ( "DoubleClick" = A_GuiEvent )
			{
				GuiConfigMain.Create_Popup("command")
			}

			;--------------------------------------
			; user has edited first field of a row 
			;
			if ( "e" = A_GuiEvent )
			{
				GuiConfigMain.ListViewCommands_ReadjustAllCols()
			}

			;--------------------------
			; An Item Changed
			;
			if ( "I" = A_GuiEvent ){
				
				;===================================================
				; ENABLE / DISABLE state changed for a Command
				;===================================================
				
				;-------------------------------------------
				; Event was either Checkmark (C) or Uncheckmark (c)
				;
				if( InStr(ErrorLevel, "c") ){				
					
					; Tells future ListView operations to operate on this specific ListView control
					GuiConfigMain.ListViewCommands_Activate()
				
					;-------------------------------------------
					; Get command for that row in the ListView 
					;
					cmd := ""
					LV_GetText(cmd, A_EventInfo,1)
					
					;---------------------------------------------------
					; If a row is selected, 
					; ErrorLevel will contain a "S" in its string.
					;
					; If a row is deselected, 
					; ErrorLevel will contain a "s" in its string.
					;---------------------------------------------------
					
					was_item_checked := InStr(ErrorLevel, "C", CaseSensitive:=true)
					was_item_unchecked := InStr(ErrorLevel, "c", CaseSensitive:=true)
					
					if( was_item_checked ){
						GuiConfigMain.Fn_EnableCommand( cmd )
					}
					if( was_item_unchecked ){
						GuiConfigMain.Fn_DisableCommand( cmd )
					}					
					
				}
				
			}
			
			return
		}


		GUI_EVENT_ButtonRunAction() {
		global run_action_id
		
			GuiConfigMain.ListViewActions_Activate()
			
			which_row := LV_GetNext(0)		
			
			if( 0 != which_row ){
				LV_GetText(action_id_is, which_row, 1)
				run_action_id := action_id_is 
				gosub RunActionID
			}
			
			return
		}
		
		GUI_EVENT_ButtonNewAction() {
		global

			; GuiConfigMain.Create_Popup_Action_Add()
			GuiConfigMain.Create_Popup("action", "add")

			return
		}
		
		GUI_EVENT_ButtonEditAction() {
		global
		
			GuiConfigMain.Create_Popup("action", "edit")
			
			return
		}
		
		GUI_EVENT_ButtonDeleteAction() {
		global
		
			GuiConfigMain.ListViewActions_Activate()
			
			;===============================================
			; Get the row# of the selected ListView item.
			;===============================================
			
			which_row := LV_GetNext(0)
			
			if( 0 == which_row ){
				; User pressed Delete Action button with no selection.
				return
			}
			
			action_id := ""
			LV_GetText(action_id, which_row, 1)
			
			
			aID   := action_id
			aType := _ACTIONS[aID]["type"]
			aPath := _ACTIONS[aID]["path"]
			aArg  := _ACTIONS[aID]["arg"]
			
			;~ ar_cmds_which_use_this_action     := []
			string_cmds_which_use_this_action := ""
			
			for cmd, cmd_dat in _COMMANDS{
				
				if( aID == cmd_dat["action_id"] ){
					; msgbox command has aid [%aID%]
					;~ ar_cmds_which_use_this_action.Push(cmd)
					string_cmds_which_use_this_action .= cmd "`n`n"
				}
				
			}
			
			
			msgbox_type_ok_cancel := 1
			msgbox_icon_question  := 32
			msgbox_default_button := 256
			
			msgbox_options := msgbox_type_ok_cancel
							+ msgbox_icon_question
							+ msgbox_default_button
			
			
			
			msgbox_prompt :=  ""
			msgbox_prompt  .= "Delete Action[" aID "] ?`n`n"
			msgbox_prompt  .= "    Type:`t" aType "`n"
			msgbox_prompt  .= "    Path:`t" aPath "`n"
			msgbox_prompt  .= ("" != aArg) 
								? "    Arg:`t" aArg 
								: ""
			
			msgbox_prompt  .= "`n`n"
			
			msgbox_prompt  .= "(This Action and any Commands which use it`n"
			msgbox_prompt  .= "  will all be erased from your savefile.)`n`n"
						   
			;~ if( ar_cmds_which_use_this_action.Count() > 0 )
			if( StrLen(string_cmds_which_use_this_action) > 0 ){
				msgbox_prompt  .= "`n"
				msgbox_prompt  .= "------------------------------------------------------`n"
				msgbox_prompt  .= "WARNING    `n`n"
				msgbox_prompt  .= "The following Commands use Action[" aID "]`n"
				msgbox_prompt  .= "and will also be deleted: `n"
				msgbox_prompt  .= "------------------------------------------------------`n`n"
				msgbox_prompt  .= string_cmds_which_use_this_action
				
			}
								
			
			msgbox_title := "DELETE"
			
			MsgBox, % msgbox_options, % msgbox_title, %msgbox_prompt%
			
			IfMsgBox, Cancel
				return 
			IfMsgBox, OK
			{
				; delete all cmds in string_cmds_which_use_this_action
				; delete action
				
				if( StrLen(string_cmds_which_use_this_action) > 0 ){
					Loop, Parse, string_cmds_which_use_this_action, `n`n
					{
						GuiConfigMain.Fn_DeleteCommand( A_LoopField )
					}
				}
				
				GuiConfigMain.Fn_DeleteAction( aID )
			
			}
			
			return
		}

		Fn_Action_Buttons_Enable() {
		
			GuiConfigMain.ListViewActions_Activate()
			GuiControl, ConfigMain: Enable, GuiConfigMain_ButtonEditAction
			GuiControl, ConfigMain: Enable, GuiConfigMain_ButtonDeleteAction
			GuiControl, ConfigMain: Enable, GuiConfigMain_ButtonRunAction
			
			return
		}
		
		Fn_Action_Buttons_Disable( flag_allow_run:=false ) {
		
			GuiConfigMain.ListViewActions_Activate()
			GuiControl, ConfigMain: Disable, GuiConfigMain_ButtonEditAction
			GuiControl, ConfigMain: Disable, GuiConfigMain_ButtonDeleteAction
			
			if(false == flag_allow_run){
				GuiControl, ConfigMain: Disable, GuiConfigMain_ButtonRunAction
			}
			else{
				GuiControl, ConfigMain: Enable, GuiConfigMain_ButtonRunAction			
			}
			
			return
		}


		GUI_EVENT_ButtonNewCmd() {
		global

			; GuiConfigMain.Create_Popup_Command_Add()
			GuiConfigMain.Create_Popup("command", "add")
			
		return 
		}

		GUI_EVENT_ButtonEditCmd() {
		global
		
			GuiConfigMain.Create_Popup("command", "edit")
			
			return
		}

	; [~] TODO: new option checkbox: Show confirmation warning before deleting an Action or Command.
	
		GUI_EVENT_ButtonDeleteCmd() {
		global
		
			GuiConfigMain.ListViewCommands_Activate()
			
			;===============================================
			; Get the row# of the selected ListView item.
			;===============================================
			
			which_row := LV_GetNext(0)
			
			if( 0 == which_row ){
				; User pressed Delete Command button with no selection.
				return
			}
			
			cmd_txt := ""
			LV_GetText(cmd_txt, which_row, 1)
			
			msgbox_type_ok_cancel := 1
			msgbox_icon_question  := 32
			msgbox_default_button := 256
			
			msgbox_options := msgbox_type_ok_cancel
							+ msgbox_icon_question
							+ msgbox_default_button
			
			msgbox_prompt :=  ""
			msgbox_prompt  .= "Delete the following Command?`n`n"
			msgbox_prompt  .= "`t" cmd_txt "`n`n`n"
			msgbox_prompt  .= "( This Command will be erased from your savefile,`n"
			msgbox_prompt  .= "  but its Action will not be removed. )`n`n"
			
			msgbox_title := "DELETE"
			MsgBox, % msgbox_options, % msgbox_title, %msgbox_prompt%
			
			IfMsgBox, Cancel
				return 
				
			IfMsgBox, OK
				GuiConfigMain.Fn_DeleteCommand( cmd_txt )
			
			return
		}
		
		Fn_Command_Buttons_Enable() {
		
			GuiConfigMain.ListViewCommands_Activate()
			GuiControl, ConfigMain: Enable, GuiConfigMain_ButtonEditCommand
			GuiControl, ConfigMain: Enable, GuiConfigMain_ButtonDeleteCommand
			
			return
		}
		
		Fn_Command_Buttons_Disable() {
		
			GuiConfigMain.ListViewCommands_Activate()
			GuiControl, ConfigMain: Disable, GuiConfigMain_ButtonEditCommand
			GuiControl, ConfigMain: Disable, GuiConfigMain_ButtonDeleteCommand
			
			return
		}
		
		
		GUI_EVENT_CheckboxShowAll() {
		global

			;----------------------------------------------------
			; Change label depending on state.
			;----------------------------------------------------
			;
			; When Checkbox is on, 
			;
			; - ListView will display: 
			;   all Commands
			;
			; - GuiConfigMain_CheckboxShowAll will display text:
			;   SHOW ALL   (Uncheck to hide disabled commands)
			;
			; When Checkbox is off 
			;
			; - ListView will display: 
			;   only enabled Commands
			;
			; - GuiConfigMain_CheckboxShowAll will display text:
			;   SHOW ALL   (Check to also show disabled commands)
			;
			;----------------------------------------------------
			
			GuiControlGet,show_all_state,, GuiConfigMain_CheckboxShowAll
			
			if( show_all_state ){
				txt := GuiConfigMain.CheckboxShowAll_TextForChecked
				
				GuiConfigMain.ListViewCommands_ShowAll()
			}
			else{
				txt := GuiConfigMain.CheckboxShowAll_TextForUnchecked
				
				GuiConfigMain.ListViewCommands_ShowOnlyEnabled()
			}
			
			GuiControl,, GuiConfigMain_CheckboxShowAll, %txt%
			
			return
		}

		
		GUI_EVENT_Settings_ButtonIcon() {
		global 
		
			if( "" == _o_Gui_Config_IconPicker ){
				_o_Gui_Config_IconPicker := new GuiConfigIconPicker()
			}
			
			return
		}
		
		GUI_EVENT_Settings_ButtonExport() {
		global
		
			return
		}
		
		GUI_EVENT_Settings_ButtonImportAsDisabled() {
		global
		
			return
		}
		
		GUI_EVENT_Settings_ButtonImportAsEnabled() {
		global
		
			return
		}
		
		


		ListViewActions_Activate() {
		global
			;
			; Word of warning:
			; In this current implementation, OnSize() 
			; will readjust the columns on a resize 
			; (to prevent horizontal scrollbar when not needed).
			;
			; Be sure to call ListViewActions_Activate() 
			;  or             ListViewCommands_Activate
			; before any AutoHotkey ListView function.
			;--------------------------------------------
			
			
			;--------------------------------------------------------------------;
			; This line ensures "Gui, " commands operate on the main GUI window  ;
			;--------------------------------------------------------------------;
			Gui, ConfigMain:Default

			;---------------------------------------------------;
			; This line ensures ListView commands "LV_..()"     ;
			; operate on this specific ListView                 ;
			;---------------------------------------------------;
			Gui, ConfigMain:ListView, GuiConfigMain_ListViewActions
			
			return
		}

		ListViewActions_ReadjustAllCols() {
		global
		
			; see notes above in GuiConfigMain.ListViewCommands_ReadjustAllCols()
			
			; Tells future ListView operations to operate on this specific ListView control
			GuiConfigMain.ListViewActions_Activate()
			
			; Adjust all column widths to fit all contents without trailing "..."
			LV_ModifyCol(1,"AutoHdr")
			LV_ModifyCol(2,"AutoHdr")
			LV_ModifyCol(3,"AutoHdr")
			LV_ModifyCol(4,"AutoHdr")
			
			return
		}


		ListViewActions_AddNewAction( p_actionID, p_actionType, p_actionPath, p_actionArg ) {
		global 
			
			; msgBOX id[%p_actionID%] type[%p_actionType%] path[%p_actionPath%] ar[%p_actionArg%]
			
			; Tells future ListView operations to operate on this specific ListView control
			GuiConfigMain.ListViewActions_Activate()
			
			options := "" 
			
			; msgBOX %success%
			
			LV_Add( options
				, p_actionID
				, p_actionType
				, p_actionPath
				, p_actionArg )
			
			
			return
		}


		ListViewCommands_Activate() {
		global
			;
			; Word of warning:
			; In this current implementation, OnSize() 
			; will readjust the columns on a resize 
			; (to prevent horizontal scrollbar when not needed).
			;
			; Be sure to call ListViewActions_Activate() 
			;  or             ListViewCommands_Activate
			; before any AutoHotkey ListView function.
			;--------------------------------------------
			
			;--------------------------------------------------------------------;
			; This line ensures "Gui, " commands operate on the main GUI window  ;
			;--------------------------------------------------------------------;
			
			Gui, ConfigMain:Default

			;---------------------------------------------------;
			; This line ensures ListView commands "LV_..()"     ;
			; operate on this specific ListView                 ;
			;---------------------------------------------------;
			
			Gui, ConfigMain:ListView, GuiConfigMain_ListViewCmds
			
			
			;----------------------------------------------------------------
			; see:                                                          
			; https://www.autohotkey.com/docs/commands/Gui.htm#MultiWin     
			; https://www.autohotkey.com/docs/commands/Gui.htm#Default      
			; https://www.autohotkey.com/docs/commands/ListView.htm#BuiltIn 
			;----------------------------------------------------------------

			return
		}

		ListViewCommands_ReadjustAllCols() {
		global

			;-----------------------------------------------------------
			; These lines ensure the next ListView function ("LV_...()")
			; will specifically use GuiConfigMain's ListView for Commands
			;-----------------------------------------------------------
			
			GuiConfigMain.ListViewCommands_Activate()
			
			;-------------------------------------------------------------------
			; AutoHotkey Docs for ListView, ModifyCol, AutoHdr
			;-------------------------------------------------------------------
			; AutoHdr: 
			;   Adjusts the column's width to fit 
			;   its contents and the column's header text, 
			;   whichever is wider. 
			;-------------------------------------------------------------------
			; https://www.autohotkey.com/docs/commands/ListView.htm#LV_ModifyCol
			;-------------------------------------------------------------------
			
			LV_ModifyCol(1,"AutoHdr")
			LV_ModifyCol(2,"AutoHdr")
			LV_ModifyCol(3,"AutoHdr")
			LV_ModifyCol(4,"AutoHdr")
			LV_ModifyCol(5,"AutoHdr")
			LV_ModifyCol(6,"AutoHdr")
			
			return
		}


		ListViewCommands_ShowOnlyEnabled() {
		global	
		
			;------------------------------------------------------------------------------
			; Tells future ListView operations to operate on this specific ListView control
			GuiConfigMain.ListViewCommands_Activate()
			
			i_lv_rows := LV_GetCount()
			;-----------------------
			; iterate ListView items
			while(i_lv_rows > 0)
			{
				;----------------------------------
				; get the cmd in each ListView row
				LV_GetText(cmd, i_lv_rows)
				
				;-----------------------------------------
				; ensure cmd is present in _COMMANDS array 
				if( _COMMANDS.HasKey(cmd) ){
					; msgbox has key [%cmd%]
					; if the Command is disabled,  
					; then remove that Command's ListView entry
					if( false == _COMMANDS[cmd]["enabled"] ){
						LV_Delete( i_lv_rows )
					}
					
				}
				
				i_lv_rows := i_lv_rows - 1
			}
			
			return
		}
		
		ListViewCommands_ShowAll() {
		global
		
			;------------------------------------------------------------------------------
			; Tells future ListView operations to operate on this specific ListView control
			GuiConfigMain.ListViewCommands_Activate()
			
			ar_enabled := {}
			
			;-----------------------
			; iterate ListView items
			Loop % LV_GetCount()
			{
				;----------------------------------
				; get the cmd in each ListView row
				LV_GetText(cmd, A_Index)
				
				ar_enabled[cmd] := true
			}
			
			for cmd, cmd_data in _COMMANDS {
				if ar_enabled.HasKey(cmd){
					continue
				}
				
				lv_cmd_options := (true==cmd_data["enabled"]) ? "+Check" : "-Check"
				
				cmd_action_id  := cmd_data["action_id"]
				action_type    := _ACTIONS[cmd_action_id]["type"]
				action_path    := _ACTIONS[cmd_action_id]["path"]
				action_arg     := _ACTIONS[cmd_action_id]["arg"]
				
				LV_Add(lv_cmd_options   ; Check row if Command is enabled
					, cmd                 ; row 1
					, ""                  ; row 2
					, cmd_action_id       ; row 3
					, action_type         ; row 4
					, action_path         ; row 5
					, action_arg )        ; row 6
							
			}
			
			return
		}
		
		ListViewCommands_UpdateAllWhichUseAction( p_actionID ) {
		global	
		
			aID   := p_actionID
			aType := _ACTIONS[aID]["type"]
			aPath := _ACTIONS[aID]["path"]
			aArg  := _ACTIONS[aID]["arg"]
			
			msgBOX id[%aID%] type[%aType%] path[%aPath%]
			
			; Tells future ListView operations to operate on this specific ListView control
			GuiConfigMain.ListViewCommands_Activate()
			
			; iterate ListView items
			Loop % LV_GetCount()
			{
				; get the cmd in each ListView row
				LV_GetText(cmd, A_Index)
				
				; ensure cmd is present in _COMMANDS array 
				if( _COMMANDS.HasKey(cmd) ){
				
					; if the Command uses this updated Action 
					; then update that Command's ListView entry with updated Action config
					if( aID == _COMMANDS[cmd]["action_id"] ){
						
						;------------------------------------------------------
						; AutoHotkey Docs, Ternary Operator: 
						; https://www.autohotkey.com/docs/Variables.htm#ternary
						;
						lv_cmd_options := (true==_COMMANDS[cmd]["enabled"]) ? "+Check" : "-Check"
						
						LV_Modify(A_Index
							, lv_cmd_options     ; no options
							, cmd                 ; row 1
							,                     ; row 2 is always empty
							, aID                 ; row 3
							, aType               ; row 4
							, aPath               ; row 5
							, aArg        )       ; row 6        
							
					}
					
				}
				
			}
			
			return 
		}



		
		Create_Popup(mode, purpose:="") {
		global		
		
			; Parameters
			;----------------------------------------------------
			; mode    is either:    "command"  or  "action"
			; purpose is either:        "add"  or  "edit"
			;----------------------------------------------------
			
			plural := ("command"=mode) ? "Commands"   : "Actions"
			caps   := ("command"=mode) ? "Command"    : "Action"
			AR     := ("command"=mode) ? "_COMMANDS"  : "_ACTIONS"
			
			
			
			;-----------------------------------------------------------------
			; Here, ensure the next ListView function ("LV_...()")
			; will specifically use the appropriate ListView in GuiConfigMain
			;-----------------------------------------------------------------
			
			
					;====================================================================`
					;
					; Note:
					;
					; AutoHotkey Info : Dynamically Calling + Function References
					;
					;====================================================================``
					;
					; The line `GuiConfigMain[fn]()` will call one of these two functions
					;
					;    GuiConfigMain.ListViewCommands_Activate()
					;    GuiConfigMain.ListViewActions_Activate()
					;====================================================================
					;
					; Read more about how this works: 
					;
					;    https://www.autohotkey.com/boards/viewtopic.php?t=6354
					;    https://www.autohotkey.com/docs/Objects.htm#Function_References
					;    https://www.autohotkey.com/docs/Objects.htm#Usage_Objects 
					;      -> end of first section begins with `x.y[z]()` example.
					;====================================================================```
					;
			fn := "ListView" plural "_Activate"
			GuiConfigMain[fn]()
				
			
			if("" == purpose){
			
				;-----------------------------------------------------------`
				; If LV_GetNext(0) succeeds, then a row is selected. 
				;-----------------------------------------------------------``
				; The user either hit <Enter> or double-clicked that row.
				; An "Edit Action/Command" popup will appear for this item.
				;
				;-----------------------------------------------------------
				; If LV_GetNext(0) fails, then there is no selection.
				;-----------------------------------------------------------
				; The user either hit <Enter> w/o a selection or 
				; double-clicked a blank area, not a row.
				; A "New Action/Command" popup will appear.
				;-----------------------------------------------------------```
				
				if( 0 != LV_GetNext(0) ){
					purpose := "edit"
				}
				else{
					purpose := "add"				
				}
				
			}
			
			if( "command" == mode
			or  "action"  == mode)
			{
			
				;=============================================
				;   Create Popup to Add a (Command or Action)
				;=============================================
				if( "add" == purpose ){
				
					;------------------------------------------
					; Create Popup, 
					; if this global var is empty.
					;------------------------------------------
					;
					if( _o_Gui_Config_Popup == "" ){
						_o_Gui_Config_Popup := new GuiConfigPopup(mode, "add")
					}
					else{ ;error;
						MsgBox, 16,  [ PROGRAM ERROR ], % "Whoops, big bug, a Popup is already open!`n"
					}
					
				}
				;=============================================
				;   Create Popup to Edit a (Command or Action)
				;=============================================
				else 
				if( "edit" == purpose ){
					
					
					;===============================================
					; Get the row# of the selected ListView item.
					;===============================================
					
					which_row := LV_GetNext(0)
					
					
					;================================
					; Exit if no selection to edit.
					;================================
					
					if( 0 == which_row ){
						
						return   ; User pressed "Edit Selected..." Button
								 ; with no selection. 
								 ; Ignore. 
					}
					
					
					;===============================================
					; Get the selected row's 1st column, either: 
					;   - the Action's  ID
					;   - the Command's text
					;===============================================
					
					LV_GetText(aID_or_cmd, which_row, 1)
					
					
					;--------------------------------------------------------------`
					; AutoHotkey Info, using a %variable_name% stored in a string
					;--------------------------------------------------------------``
					; Here, I'd like to showcase a language feature of AutoHotkey, 
					; 
					; where you can %resolve% a variable stored in a string 
					; in order to dynamically change the variable a line uses.
					;
					; 
					; The following logic :
					; 
					;    AR := ("command" == mode) ? "_COMMANDS" : "_ACTIONS"
					;
					;    if( %AR%.HasKey(aID_or_cmd) ){ .. }
					;    
					; serves to dynamically turn this if branch 
					; into the following:
					;    
					;    if(  _ACTIONS.HasKey(row_cmd) ){ .. }
					;    if( _COMMANDS.HasKey(row_cmd) ){ .. }
					;    
					;--------------------------------------------------------------
					;    
					; However, the following if branch 
					; can alternatively be replaced with this instead :
					; 
					;    if("command" == mode){
					;       valid_key := _COMMANDS.HasKey(row_cmd)
					;    }
					;    if("action" == mode){
					;       valid_key := _ACTIONS.HasKey(row_cmd)
					;    }
					;    if( valid_key ){ ... }
					;
					;--------------------------------------------------------------
					; AutoHotkey docs:
					;
					; https://www.autohotkey.com/docs/Functions.htm#DynCall
					; https://www.autohotkey.com/docs/Variables.htm#operators
					;               (see %Var% in the operators table ^)
					;--------------------------------------------------------------```
					
					;===============================================
					; Ensure the row is still valid in main array
					;===============================================
					
					AR := ("command" == mode) ? "_COMMANDS" : "_ACTIONS"
					
					if( %AR%.HasKey( aID_or_cmd ) ){
						
						
						;===============================================
						; Store the (Action or Command)'s ListView data 
						; for the Popup to access.
						;===============================================
						
						row_dat := GuiConfigMain.Get_Associative_Array_Of_Selected_LV_Row_Data(which_row)
						
						
						;==============================================================
						; Pluck command for editing 
						;   ( more details in Pluck_Selected_Command_From_COMMANDS() )
						;==============================================================					
						
						;-------------------------------------------------------------
						; Call either 
						;
						;       GuiConfigMain.Pluck_Selected_Command_From_COMMANDS() 
						;    or GuiConfigMain.Pluck_Selected_Action_From_ACTIONS()
						;
						;-------------------------------------------------------------
						; See above note on Dynamically Calling Function References 
						;-------------------------------------------------------------
						
						fn := "Pluck_Selected_" caps "_From" AR 
						GuiConfigMain[fn]( aID_or_cmd )
						
						
						;=======================================;
						;     Create Popup  :  Command Edit     ;
						;=======================================;
						
						if( _o_Gui_Config_Popup == "" ){
							_o_Gui_Config_Popup := new GuiConfigPopup(mode, "edit", row_dat)
						}
						else{ ;then bug;
							MsgBox, 16,  [ PROGRAM ERROR ], % "Whoops, a Popup is already open.`n"
						}
						
					}
					else{ ;then bug;
						debug_out := "mode[" mode "] purpose[" purpose "] `n"
						debug_out .= "Trying to open config Popup window, `n"
						debug_out .= "but array " AR " does not have key[" aID_or_cmd "], `n"
						msgbox %debug_out%
					}
					
				}				
			
			}
			
			return
		}
		
		
		
		 
		Pluck_Selected_Command_From_COMMANDS(p_row_cmd) {
		global 
		
		;-------------------------------------------------------------------------`
		; Note
		;-------------------------------------------------------------------------
		;
		; _COMMANDS and _ACTIONS, keys + values, and edit Popups : 
		;
		;   On creating a Popup with purpose "edit", 
		;   for either popup mode "action" or popup mode "command"
		;   remove the entry from _ACTIONS or _COMMANDS.
		;
		;   Later after either (user cancels or user submits) the popup,
		;   add the key + value back into _ACTIONS or _COMMANDS 
		;   (which is potentially the same, or potentially entirely modified).
		;
		;-------------------------------------------------------------------------``
		; Why this implementation?
		;-------------------------------------------------------------------------
		;
		; Short answer:
		;
		;   As with all algorithms, there's many ways to accomplish the same thing.
		;   I liked the simplicity of implementation of this direction most.
		;
		;-------------------------------------------------------------------------
		;
		; Explanation:
		;
		;   When a preexisting Action or Command is edited, 
		;   this implementation removes it from the main internal array 
		;   which holds all the _ACTIONS{} or _COMMANDS{} at runtime.
		;
		;   Later, when a popup submits the user's edited changes, 
		;   first the app checks the _COMMANDS or _ACTIONS array for conflicts
		;   (depending on whether the _popup_mode is "command" or "action").
		;   
		;   Since no two Commands will ever have the same text, and 
		;   since no two Actions will ever have exactly the same path data, and
		;   since the app always removes the edited key value pair from 
		;   _COMMANDS or _ARRAYS before editing, 
		;   this not-a-duplicate verification can use the same logic 
		;   as the logic for adding a new Command or Action.
		;
		; Benefit:
		;
		;   For instance, if the user edits a Command, and renames the Command, 
		;   there's no need for additional logic which checks _COMMANDS 
		;   for the old command key, compares it to what is potentially a new key 
		;   then additionally checks for preexisting other Commands with the same key.
		;
		;   In this current implementation, since we remove the key upfront,
		;   if the key doesn't exist, 
		;      then we can immediately add it in, 
		;      regardless of whether it's edited or brand new.
		;
		;   If the Command keeps the same name and only changes the Action configuration
		;   then the key which was plucked from _COMMANDS can be added back in 
		;   with a slightly different value for the corresponding Action data to trigger.
		;   And no other logic is needed other than `if(!_COMMANDS.HasKey(cmd))`.
		;
		; Tradeoff:
		;
		;   This current design choice potentially has the drawback 
		;   of being unintuitive at a glance, 
		;   but the benefit of the simplicity of verification logic 
		;   was appealing enough to me to go this route. 
		;
		;-------------------------------------------------------------------------```
		
			;=================================================================`
			; Pluck and save current row's command data                       
			; from _COMMANDS array                                            
			; into _plucked_command variable.                                 
			;=================================================================``
			; How _plucked_command will be used:                              
			;                                                                 
			;   If user cancels,                                              
			;     when GuiConfigPopup is closed                               
			;     GUI_EVENT_GuiConfigPopup_OnClose will use _plucked_command  
			;     to restore the command to the _COMMANDS array.              
			;                                                                 
			;   If user submits an edited command,                          
			;     we'll assign new command data to the _COMMANDS array,       
			;     and make _plucked_command empty to prevent                  
			;  	  GUI_EVENT_GuiConfigPopup_OnClose from restoring it.         
			;=================================================================```
			
			
			GuiConfigMain._plucked_command := { "" 
				.   "command":   p_row_cmd
				  , "enabled":   _COMMANDS[p_row_cmd]["enabled"]
				  , "action_id": _COMMANDS[p_row_cmd]["action_id"] }	
			
			;-----------------------------------------------------------
			; Deletes from the array storing all our Commands. 
			;-----------------------------------------------------------
			; Doing this allows both Popup->EditCmd + Popup->AddCmd 
			; to use the same logic (_COMMANDS.HasKey()) to ensure
			; the user's input won't become a duplicate entry.
			;		
			_COMMANDS.Delete(p_row_cmd)
			
			return
		}	
		
		Discard_Plucked_Command() {
		global 
		
			;----------------------------------------
			; Remove backup of (now) edited command
			;----------------------------------------
			; Making this variable empty will prevent 
			;
			;   GUI_EVENT_GuiConfigPopup_OnClose and
			;   GUI_EVENT_GuiConfigPopup_OnEscape
			;
			; from automatically restoring 
			; the old version of this Command
			;
			; when the GuiConfigPopup GUI is closed.
			;----------------------------------------
			
			GuiConfigMain._plucked_command := ""
			
			return
		}
		
		Restore_Plucked_Command_If_User_Cancelled() {
		global 
		
			;-----------------------------------------------------------
			; If user cancelled out of the GuiConfigPopup GUI
			; then restore the original Command to the _COMMANDS array.
			;-----------------------------------------------------------
			
			if( "" != GuiConfigMain._plucked_command )
			{
				cmd        := GuiConfigMain._plucked_command["command"]
				is_enabled := GuiConfigMain._plucked_command["enabled"]
				aID        := GuiConfigMain._plucked_command["action_id"]
				
				_COMMANDS[cmd] := { "action_id":aID, "enabled":is_enabled }
				
				GuiConfigMain._plucked_command := ""
			}
			
			return
		}

		
		Pluck_Selected_Action_From_ACTIONS(p_action_id) {
		global 
		
			;------------------------------------------------------------
			; same as GuiConfigMain.Pluck_Selected_Command_From_COMMANDS
			;------------------------------------------------------------
			
			GuiConfigMain._plucked_action := { ""
				.   "action_id"  : p_action_id
				  , "action_type": _ACTIONS[p_action_id]["type"]
				  , "action_path": _ACTIONS[p_action_id]["path"]
				  , "action_arg" : _ACTIONS[p_action_id]["arg"]   }
				  
			_ACTIONS.Delete(p_action_id)
			
			return
		}	
		
		Discard_Plucked_Action() {
		global 
			GuiConfigMain._plucked_action := ""
			return
		}	
		
		Restore_Plucked_Action_If_User_Cancelled() {
		global 
			;-----------------------------------------------------------
			; If user cancelled out of the GuiConfigPopup GUI
			; then restore the original Command to the _COMMANDS array.
			;-----------------------------------------------------------
			
			if( "" != GuiConfigMain._plucked_action )
			{
				aID   := GuiConfigMain._plucked_action["action_id"]
				aType := GuiConfigMain._plucked_action["action_type"]
				aPath := GuiConfigMain._plucked_action["action_path"]
				aArg  := GuiConfigMain._plucked_action["action_arg"]
				
				_ACTIONS[aID] := {"type":aType, "path":aPath, "arg":aArg}
				
				GuiConfigMain._plucked_action := ""
			}
			
			return
		}


		;-------------------------------------------------------------------
		; Only called for "edit" Popups, either mode ("action" or "command")
		;
		Get_Associative_Array_Of_Selected_LV_Row_Data( selected_row ) {
		global 
		local  got_cmd, got_cmd_is_enabled 
		local  got_actionId, got_actionType, got_actionType, got_actionArg
		
			;-----------------------------------------------------`
			; Parameter: selected_row
			;-----------------------------------------------------``	
			;
			; - ListView row ID (integer)
			;   for the active ListView in GuiConfigMain
			;   (either a row in GuiConfigMain_ListViewActions
			;                 or GuiConfigMain_ListViewCmds).
			;
			; - This function will copy that row's data,
			;   for the "edit" Popup to read.
			;
			; - When the "edit" Popup "Submits" its data 
			;   it modifies the ListView row with this ID
			;   to reflect the edited action or command.
			; 
			;-----------------------------------------------------```
			
			
			;========================================================
			; Create the associative array to hold the row's data in
			; for Popup to reference
			;========================================================
			
			row_dat := {}
			
			
			;========================================
			; Refresh the variable GuiConfigMain_Tabs
			; which stores the current tab name
			;========================================
			
			Gui, ConfigMain:Submit, NoHide 
			
			
			;========================================
			; Copy selected ListView Row's data 
			;========================================
			
			if( "Actions" == GuiConfigMain_Tabs ){
				
				GuiConfigMain.ListViewActions_Activate()
				
				got_cmd            := "" ; not used for this type of config popup 
				got_cmd_is_enabled := "" ; not used for this type of config popup 
				
				LV_GetText(got_actionID,   selected_row,1)
				LV_GetText(got_actionType, selected_row,2)
				LV_GetText(got_actionPath, selected_row,3)
				LV_GetText(got_actionArg,  selected_row,4)
				
			}
			else if( "Commands" == GuiConfigMain_Tabs ){
				
				GuiConfigMain.ListViewCommands_Activate()
				
				;-----------------------------------------------------------------`
				; AutoHotkey Docs:
				;-----------------------------------------------------------------``
				; LV_GetNext(StartingRowNumber, RowType)
				;
				;    "... the search begins at the row after StartingRowNumber"
				;
				;    "If RowType is omitted, 
				;     the function searches for the next selected/highlighted row. 
				;     Otherwise, specify "C" or "Checked" to find the next checked row; 
				;     or "F" or "Focused" to find the focused row ..."
				;
				; https://www.autohotkey.com/docs/commands/ListView.htm#LV_GetNext
				;-----------------------------------------------------------------```
				got_cmd_is_enabled := LV_GetNext(selected_row-1, "C")
				
				LV_GetText(got_cmd,        selected_row,1)
				; column 2 is just an arrow "->" to visually separate cmd cols from action cols
				LV_GetText(got_actionID,   selected_row,3)
				LV_GetText(got_actionType, selected_row,4)
				LV_GetText(got_actionPath, selected_row,5)
				LV_GetText(got_actionArg,  selected_row,6)
					
			
			}
		
			
			;==========================================================
			; Initialize the row_dat array with the ListView Row data 
			;==========================================================
		
			row_dat["LV_id"]               := selected_row
			row_dat["row_cmd"]             := got_cmd
			row_dat["row_cmd_is_enabled"]  := got_cmd_is_enabled
			row_dat["row_actionID"]        := got_actionId
			row_dat["row_actionType"]      := got_actionType
			row_dat["row_actionPath"]      := got_actionPath
			row_dat["row_actionArg"]       := got_actionArg
			
			return row_dat
		}
		
		
		
		
		Fn_EnableCommand( cmd ) {
		global 
		
			if( _COMMANDS.HasKey(cmd) ){
					
				_COMMANDS[cmd]["enabled"] := true
				
				FILE_HELPER.Change_Savefile__Enable_Command( cmd )
			}
			
			return
		}
		
		Fn_DisableCommand( cmd ) {
		global 
			
			if( _COMMANDS.HasKey(cmd) ){
					
				_COMMANDS[cmd]["enabled"] := false
				
				FILE_HELPER.Change_Savefile__Disable_Command( cmd )
				
				;----------------------------------------------
				; If user has chosen to hide disabled commands
				; (in GuiConfigMain's Commands ListView), 
				;
				; then hide this Command too.
				;----------------------------------------------
				
				GuiControlGet,show_all_state,, GuiConfigMain_CheckboxShowAll
				if( false == show_all_state ){
					GuiConfigMain.ListViewCommands_ShowOnlyEnabled()
				}
							
			}
			
			return
		}

		Fn_DeleteCommand( cmd_to_delete ) {
		global 
			
			GuiConfigMain.ListViewCommands_Activate()
			
			; iterate ListView items
			Loop % LV_GetCount()
			{
				; get the cmd in each ListView row
				LV_GetText(cmd, A_Index, 1)
				
				; ensure cmd is present in _COMMANDS array 
				if( _COMMANDS.HasKey(cmd) ){
					
					if( cmd_to_delete == cmd ){
						LV_Delete( A_Index )
						
						p1 := "command"
						p2 := "delete"
						p3 := cmd
						FILE_HELPER.Change_Savefile( p1, p2, p3 )
						break
					}
				}
			}
			
			return
		}

		Fn_DeleteAction( action_id_to_delete ) {
		global 
		
			GuiConfigMain.ListViewActions_Activate()
			
			; iterate ListView items
			Loop % LV_GetCount()
			{
				; get the ID in each ListView row
				LV_GetText(actionID, A_Index, 1)
				
				; ensure ID is present in _ACTIONS array 
				if( _ACTIONS.HasKey(actionID) ){
					
					if( action_id_to_delete == actionID ){
						LV_Delete( A_Index )
						
						p1 := "action"
						p2 := "delete"
						p3 := action_id_to_delete
						FILE_HELPER.Change_Savefile( p1, p2, p3 )
						
						break
					}
				}
			}
			
			return
		}


		Fn_Change_to_Settings_Tab() {
		global 
		
			text := "Commands|Actions|Settings||   ?   "
			GuiControl, ConfigMain: Choose, GuiConfigMain_Tabs, 3
			
			return 
		}

		Fn_Settings_SetIcon( icon_id ) {
		global _ICON_INDEX
		
			setting := {"setting_name":"icon", "new_value":icon_id}
			
			FILE_HELPER.Change_Savefile(  "setting"
										, "edit"
										, NA_actionCommand :=""
										, NA_commandName   :=""
										, setting )
			_ICON_INDEX := icon_id 
			
			Menu, Tray, Icon, Shell32.dll, %_ICON_INDEX%
			
			gosub ReloadConfigurationWindow
			
			return
		}
		
		
		Fn_AboutTab_Get_Text(g_width:="") {
			12spaces := "           "
			3nl      := "`n`n`n"
			2nl      := "`n`n"
			1nl      := "`n"
			
			text := "" 
			
			if( "" != g_width 
			and g_width < 585 ){
				12spaces := "    "
			}
			
			
			
			   text  :=  ""
			   text   .= 12spaces   
			   text   .= 12spaces "   gamepad-coder.github.io "
			   text   .=    3nl
			   text   .= 12spaces  "===========================" 12spaces
			   text   .=    2nl
			   text   .= 12spaces  "   _program_launcher.ahk"
			   text   .=    2nl
			   text   .= 12spaces  "==========================="
			   text   .=    2nl
			   text   .= 12spaces  "License:"
			   text   .=    1nl
			   text   .= 12spaces  "Community Commons Zero"
			   text   .=    2nl
			
			; msgBOX text is `n%text%
			
			return text
		}
		
		;============================================================
		;         end of class:
		;         GuiConfigMain (Main Window)  
		;============================================================
	}

	class GuiConfigIconPicker {

		;-----------------------------------------------------
		; Preload "ImageList" of system icons upon app start 
		; to prevent lag when this window is launched
		; (stored in _LV_IconList).
		;-----------------------------------------------------
		
		static _LV_IconList := "" ; Used across multiple window instances.
		static _icon_chosen := "" ; Unique per window instance
		

		__New() {
		global
			
			options_for_Popup :=  A_Space "+Label" "GuiConfigIconPicker.GUI_EVENT_On"
			options_for_Popup  .= A_Space "+Resize"
			options_for_Popup  .= A_Space "+MinSize300x475"
			
			title_for_Popup_Window := "Select Icon for Program Launcher :"
			  
			Gui, IconConfig:New
				, %options_for_Popup% 
				,   %title_for_Popup_Window%


			; Preload fn should be run during config window launch to (potentially) reduce lag.
			;
			if("" == GuiConfigIconPicker._LV_IconList){
				GuiConfigIconPicker.Preload_IconList()
			}
			
			GuiConfigIconPicker.Init_AddControls()
			
			;--------------------------------------------------------------;`
			; Temporarily disable GuiConfigMain while this popup exists.   ;
			;--------------------------------------------------------------;``
			;                                                              ;
			; GuiConfigIconPicker will be a child window of GuiConfigMain, ;
			; which will prevent GuiConfigMain                             ;
			; from displaying on top of this popup.                        ;
			;--------------------------------------------------------------;```
			
			Gui, IconConfig:+OwnerConfigMain
			Gui, IconConfig: Show
			
			Gui ConfigMain: +Disabled

			return this
			
		}
		
		__Delete() {
		global
		
			;---------------------------------------
			; Clear static class member variable 
			;---------------------------------------
			
			GuiConfigIconPicker._icon_chosen := ""
			
			;-----------------------------------------------------------------
			; Re-enable GuiConfigMain, 
			; now that GuiConfigIconPicker no longer needs prioritized focus.
			;-----------------------------------------------------------------
			
			Gui ConfigMain: -Disabled
			
			;------------------------------------
			; Destroy GuiConfigIconPicker Window
			;------------------------------------
			
			Gui IconConfig: Destroy
			
			return
		}
			
		Preload_IconList() {
		global 
		
			;----------------------------------------------------------
			; Source:
			; 	"TreeView Large Icons - Is it possible?"
			;   https://www.autohotkey.com/boards/viewtopic.php?t=65043
			;----------------------------------------------------------
			
			option_use_large_images := true
			ImageListID_large := IL_Create(10, , option_use_large_images) 
			
			;--------------------------------------------
			; Load the ImageList with system icons.
			;--------------------------------------------
			Loop 329
			{
				IL_Add(ImageListID_large, "shell32.dll", A_Index)
			}
			
			GuiConfigIconPicker._LV_IconList := ImageListID_large
			
			return
		}
		
		Init_AddControls() {
		global
		
		
			  text  := "Use Selected Icon"
			options :=  A_Space "g" "GuiConfigIconPicker.GUI_EVENT_Button"
			options  .= A_Space "+Default"
			
			Gui, IconConfig:Add, Button
				, %options%
				, %text%
			
			  text  :=  "Use Selected Icon"
			options :=  A_Space "g"    "GuiConfigIconPicker.GUI_EVENT_TreeView"
			options  .= A_Space "v"    "GuiConfigIconPicker_TreeView"
			options  .= A_Space "hwnd" "HwndIconPickerTreeView"
			options  .= A_Space "ImageList" GuiConfigIconPicker._LV_IconList
			
			Gui, IconConfig:Add, TreeView
				, %options%

			select_this_one := "" 
			TV_Delete()
			parent_id := 0
			Loop 329 {
				tv_id := TV_Add("Icon " A_Index, %parent_id%, "Icon" A_Index) 
				if( A_Index == _ICON_INDEX ){
					select_this_one := tv_id 
				}
			}
			
			if( select_this_one ){
				TV_Modify( select_this_one )
			}
			
			return	   
		}
		
		GUI_EVENT_OnEscape() {
		global
			GuiConfigIconPicker.GUI_EVENT_OnClose()
			return
		}
		
		GUI_EVENT_OnClose() {
		global
		
			;------------------------------------------------------;`
			; Call the Destructor method for class GuiConfigPopup. ;
			;------------------------------------------------------;``
			;                                                      ;
			; GuiConfigPopup.__Delete() will:                      ;
			;                                                      ;
			; - push or revert changes                             ;
			; - restore control to GuiConfigMain                   ;
			; - delete and free any vars this object is using      ;
			; - destroy the popup GUI                              ;
			;------------------------------------------------------;```
			
			;-----------------------------------------------------------------
			; AutoHotkey Info 
			;-----------------------------------------------------------------
			; obj := "" 
			;   Calls the object's __Delete() class destrutor 
			;   if this is the last variable referencing the object instance 
			;   (in this case, it is).
			;-----------------------------------------------------------------
			
			_o_Gui_Config_IconPicker := ""
			return
			
		}
		
		GUI_EVENT_OnSize() {
		global HwndIconPickerTreeView
		
			control_padding := 10
			
			op_w := A_GuiWidth
			op_h := A_GuiHeight
			
			
			;; padding, probably
			op_w := op_w -(2*control_padding )
			op_h := op_h -(2*control_padding ) - 20
			
			op_x := control_padding
			op_y := control_padding + 20
			
			c1 := HwndIconPickerTreeView
			options_movedraw := "H" . op_h . " " . "W" . op_w . " "
			options_movedraw .= "X" . op_x . " " . "Y" . op_y
			GuiControl, MoveDraw, %c1%, % options_movedraw
			
			return
		}
		
		GUI_EVENT_Button() {
		global 
			icon_id := GuiConfigIconPicker._icon_chosen
			GuiConfigIconPicker.SubmitIcon( icon_id )
			return
		}
		
		GUI_EVENT_TreeView() {
		global 
		
			;---------------------------------------------------------------
			; If event triggered because user double-clicked 
			if ( "DoubleClick" = A_GuiEvent ){
			
				;------------------------------------------------------------
				; Extract the icon number from selected TreeView Item's text.
				;
				icon_id := GuiConfigIconPicker.Get_IconID_From_TreeViewID( A_EventInfo )
				
				;---------------------------------------
				; Submit icon choice upon double-click
				;
				GuiConfigIconPicker.SubmitIcon( icon_id )
			}
			;---------------------------------------------------------------
			; If event triggered because of TreeView item selection changed 
			else if ( "S" == A_GuiEvent ){
				
				;------------------------------------------------------------
				; Extract the icon number from selected TreeView Item's text.
				;
				icon_id := GuiConfigIconPicker.Get_IconID_From_TreeViewID( A_EventInfo )
				
				;--------------------------------------------------
				; Store icon choice (referenced by submit button).
				;
				GuiConfigIconPicker._icon_chosen := icon_id
				
			}
			return
		}
		
		SubmitIcon( icon_id ) {
		global
		
			if( "" != icon_id 
			and  0 != icon_id ){
				
				;-----------------------------------------------------
				; Tell main Gui to update settings to use this icon.
				;
				GuiConfigMain.Fn_Settings_SetIcon( icon_id ) 
				
				;---------------------------
				; Close Icon Config Window.
				;
				GuiConfigIconPicker.GUI_EVENT_OnClose()
				
			}
			return
		}
		
		Get_IconID_From_TreeViewID( TreeViewItemID ) {
		global 
			
			;------------------------------------------------------------
			; TreeView IDs are not linear, 
			; so we know which TreeView Item was clicked or selected,
			; but we don't know what its position is within the treeview.
			;
			; So we need to extract the Icon ID 
			; from the selected TreeView Item's text. 
			;------------------------------------------------------------
			
			icon_id := "" 
			
			;------------------------------------------------------
			; First, we get the text of the selected TreeView Item 
			;
			TV_GetText(tv_text, A_EventInfo)
			
			;------------------------------------------------------------------
			; Next we remove the leading "Icon " to store 
			; only the trailing number at the end of the TreeView Item's text
			;
			icon_id := RegExReplace(tv_text, "^Icon[ ]*", "")
			
			
			return icon_id
		}

	}

	class GuiConfigPopup {

		static _popup_mode    := "" ; either:   "command" or "action"
		static _popup_purpose := "" ; either:   "add"     or "edit"
		
		static _LV_RowData_FromMainGui := {}
		

		static _isPathValid := ""	
		static _LV_selected_action_id := "" ; for Command 

		
		;-------------------------------------------------------------------------------
		; storing all the different text branches for this submit button 
		; inside this associative array 
		;
		; can access using : 
		; a := GuiConfigPopup.text["action_popup"]["add"]
		; b := GuiConfigPopup.text["command_popup"]["edit"]["tab2"]
		;
		static text := { 	"" 
			. "action_popup"

				:{  "add"  : "Add NEW ACTION!" 
				   ,"edit" : "Change this action!"}  
				
			, "command_popup"
			
				:{  "add"
						:{ "tab1"
							:   "Add NEW ACTION and `n" 
							  . "assign to NEW COMMAND! "
						  ,"tab2"
							:   "Use Action[] and `n" 
							  . "assign to NEW COMMAND!"}
				
				   ,"edit"
						:{ "tab1"
							:   "Add NEW ACTION and `n" 
							  . "   assign to this command!    "
						  ,"tab2"
							:   "Use Action[] and `n" 
							  . "   assign to this command!    " }    } } 
		
		
		;[~]
		;======================================================================================
		;         This class, GuiConfigPopup, is a grouping of functionality for 
		;         the popup config windows (GUIS) generated for GuiConfigMain's first tab,
		;         - "Edit a Command" or
		;         - "New Command"
		;         
		;         Contained below is all the functionality needed
		;         to process input & respond to UI events, 
		;
		;         and are grouped here primarily for organizational cleanliness.
		;
		;         To make this app simple to understand, 
		;         I initially tried to use labels exclusively instead of functions or classes.
		;         However, 
		;         this led to a long long stream of labels with no clear visual oranization.
		;         
		;         
		;======================================================================================

		

		;====================================================;
		; Creates the GUI to edit a command                  ;
		;   When:                                            ;
		;     - User double-clicks a Command or              ;
		;     - User selects a Command and presses <Enter>   ;
		;   in GuiConfigMain's Tab "Commands"                      ;
		;====================================================;
		__New(mode, purpose, row_data_if_editing:="", silent:=false ) {
		global
			
			
			GuiConfigPopup._popup_mode              := mode 
			GuiConfigPopup._popup_purpose           := purpose
			
			GuiConfigPopup._LV_RowData_FromMainGui  := row_data_if_editing
			/* Syntax reference:
				
					row_dat["LV_id"]               := selected_row
					row_dat["row_cmd"]             := got_cmd
					row_dat["row_cmd_is_enabled"]  := got_cmd_is_enabled
					row_dat["row_actionID"]        := got_actionId
					row_dat["row_actionType"]      := got_actionType
					row_dat["row_actionPath"]      := got_actionPath
					row_dat["row_actionArg"]       := got_actionArg
			*/
			
			GuiConfigPopup.Initialize_Gui_gVariables()
			
			GuiConfigPopup.Init_Config_GuiWindow_Options()		
			GuiConfigPopup.Init_AddControls_1()
			GuiConfigPopup.Init_AddControls_2_Both_ConfigNewAction()
			GuiConfigPopup.Init_AddControls_3_Cmd_SecondTab()
			GuiConfigPopup.Init_AddControls_4_Both_SubmitButton()

			
			;--------------------------------------------------------------------;`
			; Note:                                                              ;
			;--------------------------------------------------------------------;``
			;                                                                    ;
			;   The name "PopupConfig" is arbitrarily used here                  ;
			;   to tell commands like                                            ;
			;                                                                    ;
			;     - "Gui, ArbitraryGuiName:Add, .." and                          ;
			;     - "GuiControl, ArbitraryGuiName: %stringSubCommand%            ;
			;       , ArbitraryControlName, %someVar%"                           ;
			;                                                                    ;
			;   which GUI they should specifically operate upon.                 ;
			;                                                                    ;
			;   This "PopupConfig" just a name, not a variable                   ;
			;   and should not be confused with:                                 ;
			;                                                                    ;
			;     - "GuiConfigPopup",                                            ;
			;        which is the class organizing all these functions together  ;
			;                                                                    ;
			;     - nor with "_o_Gui_Config_Popup",                              ;
			;       which is an instatiated object of the class "GuiConfigPopup".;
			;                                                                    ;
			;--------------------------------------------------------------------;```
			
			;==========================================================;
			; Render + Display GuiConfigPopup's GUI window             ;
			;==========================================================;
			
			;----------------------------------------------------------;
			; Temporarily disable GuiConfigMain while                  ;
			; this popup exists (so the ListView order                 ;
			; cannot be changed/rearranged while editing)              ;
			;                                                          ;
			; GuiConfigPopup will be a child window of GuiConfigMain,  ;
			; which will prevent GuiConfigMain                         ;
			; from displaying on top of this popup.                    ;
			;==========================================================;

			
			Gui, PopupConfig:+OwnerConfigMain
			
			if( false == silent ){
			
				Gui, PopupConfig: Show
				
				Gui ConfigMain: +Disabled
			
			}

			
			;---------------------------------------------------------------
			; Manual call to OnSize() with this flag:
			;    Initializes the functions static variables which 
			;    store previous window width and height between Event calls.
			GuiConfigPopup.GUI_EVENT_OnSize("Gui up and running")
			
			;----------------------------------
			; Fine tuning of Control Widths 
			; and 
			; initializes the label reporting 
			; whether the file path is valid
			GuiConfigPopup.Init_Config_Controls_After_Render()
			
			
			return this
		}
		
		__Delete() {
		global 
			
			; If PopupCommand successfully edited a command, this will be ignored.
			; If PopupCommand was cancelled by User, then this will restore the command.
			
			if( "action" == GuiConfigPopup._popup_mode ){
				GuiConfigMain.Restore_Plucked_Action_If_User_Cancelled()
			}
			if( "command" == GuiConfigPopup._popup_mode ){
				GuiConfigMain.Restore_Plucked_Command_If_User_Cancelled()
			}
			
			
			;--------------------------------------------------
			; Clear instance class member vars 
			;
			;  (used for storing gui's recent size & comparing 
			;  to current w+h upon gui window "OnSize()" event)
			;--------------------------------------------------
			
			GuiConfigPopup._popup_mode    := "" 
			GuiConfigPopup._popup_purpose := ""
			
			GuiConfigPopup.GUI_EVENT_OnSize("RESET")
			
			GuiConfigPopup._isPathValid                 := ""
			GuiConfigPopup._LV_selected_action_id       := ""
			
					
			;---------------------------------------------------
			; Readjust main GUI's ListView columns for Commands 
			;---------------------------------------------------
			
			GuiConfigMain.ListViewCommands_ReadjustAllCols()
			
			;--------------------------------------------------------
			; Re-enable GuiConfigMain, 
			; now that GuiConfigPopup no longer needs prioritized focus.
			;--------------------------------------------------------
			
			Gui ConfigMain: -Disabled
			Gui PopupConfig: Destroy
			
			return
		}
		
		Initialize_Gui_gVariables() {
		global	
			
			GuiConfigPopup_Cmd_InputCommandName          := ""
			GuiConfigPopup_Cmd_Tabs                      := ""		; see footnote[1]
			GuiConfigPopup_Cmd_Tab2_ListViewActions      := ""
			
			GuiConfigPopup_ActionConfig_TextDragAndDrop  := ""
			GuiConfigPopup_ActionConfig_RadioFolder      := ""
			GuiConfigPopup_ActionConfig_RadioApp         := ""
			GuiConfigPopup_ActionConfig_InputPath        := ""
			GuiConfigPopup_ActionConfig_LabelVerified    := ""
			GuiConfigPopup_ButtonSubmit                  := ""
			
			;-------------------------------------------------------------------------`
			; footnote[1]
			;-------------------------------------------------------------------------
			; GuiConfigPopup_Cmd_Tabs
			;-------------------------------------------------------------------------``
			; Used for dynamically changing the submit button for Add|Edit Command.
			; If not cleared here, it will persist between popups, 
			; and exiting an "Edit Command" popup on the 2nd tab 
			; would glitch future "Add Command" or "Edit Command" popups
			;   (causing the text for the second tab's submit button 
			;   to display incorrectly on the 1st tab)
			; when they open (by default) to the 1st tab.
			;
			; Hence it's a good practice to clear global variables 
			; for GUIs which are created multiple times over the lifespan of a script.
			;-------------------------------------------------------------------------```	
			
			return
		}
		
		Init_Config_GuiWindow_Options() {
		global 
		
			;========================================================
			; Configure a GUI popup to [Add|Edit] a [Command|Action]
			;========================================================
			
				minsize := ("command" == this._popup_mode) 
								? "+MinSize340x567" 
								: "+MinSize275x425"
								
				options_for_Popup :=  A_Space "+Label" "GuiConfigPopup.GUI_EVENT_On"
				options_for_Popup  .= A_Space "+Resize"
				options_for_Popup  .= A_Space minsize
				
				title_mode    := ("command" == this._popup_mode) 
									? "COMMAND" 
									: "ACTION"
				title_purpose := ("add" == this._popup_purpose)
									? "add new!"
									: "edit..."
				
				title_for_Popup_Window := title_mode "  -  " title_purpose
				  
				Gui, PopupConfig:New
					, %options_for_Popup% 
					,   %title_for_Popup_Window%
					
			return
			
			;----------------------------------------------------------------------`
			; AutoHotkey Info : Ternary Operator
			;----------------------------------------------------------------------``
			; myVar := (ifThisEvalsToTrue) ? thenAssignThis : otherwiseAssignThis
			;----------------------------------------------------------------------
			; https://www.autohotkey.com/docs/Variables.htm#ternary
			;----------------------------------------------------------------------```
		}
		
		Init_AddControls_1() {
		global 
		
			;=======================================================;
			; These Controls:                                       ;
			;=======================================================;
			;   - `Text` Label "Command:" for input field           ;
			;   - `Edit` Input field for Command                    ;
			;   - `Tab3` Tab container for action selection         ;
			;      to assign to Command                             ;
			;                                                       ;
			;=======================================================;
			; are only present for these Popups:                    ;
			;=======================================================;
			;   - Command Add                              
			;   - Command Edit                             
			;
			if("command" == this._popup_mode){
			
				;===================================
				; Add `Text` labled "Command:" and  
				; Add `Edit` user input for Command 
				;===================================

					;-----------------------------------------
					; Label "Command:" before user input field 
					;-----------------------------------------
					
					if("add" == this._popup_purpose){
						text := "Type the text for your new Command :"
					}
					else if("edit" == this._popup_purpose){
						text := "Command :"
					}
					
					options := "y+15 cBlue"
					
					Gui, PopupConfig:Add, Text
						, %options%
						,    %text%
					
					;--------------------------------------
					; User input field 
					;--------------------------------------
					
					   ;-----------------------------------------
					   ; If editing a command, 
					   ;   then this `Edit` Control uses 
					   ;   var LV Row's command as initial text
					   ;
					   text := GuiConfigPopup._LV_RowData_FromMainGui["row_cmd"]
					options :=  A_Space "v" "GuiConfigPopup_Cmd_InputCommandName"
					options  .= A_Space "-Multi -WantTab"
					options  .= A_Space "w500"
					options  .= A_Space "y+10"
					
					
					Gui, PopupConfig:Add, Edit
						, %options%
						,    %text%

					;------------------------------------------
					; Label "Choose the Action it will trigger" 
					; after Command input area
					; just before Tab container for Actions
					;------------------------------------------
					
					   text := "Choose the Action it will trigger :" 
					options := A_Space "y+20 cBlue"
					Gui, PopupConfig:Add, Text
						, %options%
						, %text%
				
				
				;================================
				; Add Tab Container with 2 tabs
				; - Add New Action
				; - Use Existing Action
				;================================

					   text := "Add New Action|Use Existing Action"
					options :=  A_Space "v" "GuiConfigPopup_Cmd_Tabs"
					options  .= A_Space "g" "GuiConfigPopup.GUI_EVENT_Cmd_TabChanged"
					options  .= A_Space "w500"
					options  .= A_Space "y+10"
					   
					   
					; Gui, PopupConfig:Add, Tab3, w600 h500 vGuiConfigPopup_Cmd_Tabs
					Gui, PopupConfig:Add, Tab3
						, %options%
						,    %text%
				
			}

			;===============================================================;
			; This "Text" Control labeled "Create/Configure Action:"        ;
			; is only present for these Popups:                             ;
			;===============================================================;
			;   - Action Add
			;   - Action Edit
			;
			else if("action" == this._popup_mode){
				
				row_actionID := GuiConfigPopup._LV_RowData_FromMainGui["row_actionID"]
				
				   text := ("add" == this._popup_purpose)
							 ? "Create a new Action :"
							 : "Configure Action[" row_actionID "] :"
							 
				options :=  A_Space "cBlue"
				options  .= A_Space "y+15"
				
				Gui, PopupConfig:Add, Text
					, %options%
					, %text%
			}
			return
			
		}
		
		Init_AddControls_2_Both_ConfigNewAction() {
		global 
		
			;=========================================================================;
			; The following Controls:                                                 ;
			;   - `Text` Control informing about "Drag-n-Drop"                        ;
			;   - `Radio` Control choice between "Open Folder" or "Open Application"  ;
			;   - series of Controls to choose Action's Path (to folder or app)       ;
			;=========================================================================;
			; are present for all Popups:                                             ;
			;=========================================================================;
			;   - Action Add                                                          ;
			;   - Action Edit                                                         ;
			;   - Command Add                                                         ;
			;   - Command Edit                                                        ;
			;=========================================================================;
			
			
			if("command" == this._popup_mode){
			
			  ;----------------------------TAB SWITCH----------------------------
			  ;
			  ; `Tab` present for Command Add & Command Edit.
			  ;
			  ; GuiConfigPopup's 
			  ; 1st Tab will receive Gui Controls added after the following line:

				Gui, Tab, 1		

			  ;
			  ;----------------------------TAB SWITCH----------------------------
			  
			}

			
			
			;=========================================
			; Add `Text` Label:
			;-----------------------------------------
			; Inform User Drag-n-Drop is possible here
			;=========================================

				   text :=  "`n"
				   text  .= "Note:`n`n"
				   text  .= "   You can drag and drop a single file or folder   `n"
				   text  .= "onto of any portion of this window`n"
				   text  .= "to populate the fields below."
				   text  .= "`n`n"
				
				options :=  A_Space "v" "GuiConfigPopup_ActionConfig_TextDragAndDrop"
				options  .= A_Space "Border Center"
				options  .= A_Space "y+20"
				   
				Gui, PopupConfig:Add, Text
					, %options%
					, %text% 



			;===============================
			; Add `Radio` choice: 
			;    () Open Folder
			;    () Open Application
			;===============================

				;-----------------------------------------
				; Display "Type:" before radio choice 
				;-----------------------------------------
				
				   text := "Action Type :"
				options :=  A_Space "y+20"
				options  .= A_Space "cTeal"
				   
				Gui, PopupConfig:Add, Text
					,%options%
					, %text%

				row_actionType := GuiConfigPopup._LV_RowData_FromMainGui["row_actionType"]
				
				;-----------------------------------------
				; `Radio` choice: Open Folder
				;-----------------------------------------

				   text   := "Open Folder" 
				options   :=  A_Space "g" "GuiConfigPopup.GUI_EVENT_ActionConfig_RadioChanged" 
				options    .= A_Space "v"           "GuiConfigPopup_ActionConfig_RadioFolder" 
				; options    .= A_Space "y+15" 
				options    .= A_Space "y+10" 
				
				if( "folder" = row_actionType ){
					options   .= A_Space "+Checked" 
				}
				
				Gui, PopupConfig:Add, Radio
					, %options%
					, %text%

				;-----------------------------------------
				; `Radio` choice: Open Application
				;-----------------------------------------

				   text      := "Open Application" 
				options      :=  A_Space "g" "GuiConfigPopup.GUI_EVENT_ActionConfig_RadioChanged" 
				options       .= A_Space "v"           "GuiConfigPopup_ActionConfig_RadioApp" 
			   
				if( "app" = row_actionType ){
					options   .= A_Space "+Checked" 
				}
				
				Gui, PopupConfig:Add, Radio
					, %options%
					,    %text%



			;================================================================
			; Add Controls to Configure Action's Path 
			;----------------------------------------------------------------
			;   - `Text`   : Display "Path" 
			;   - `Button` : Open file or folder picker
			;   - `Edit`   : Input field for path (to Folder or Application)
			;   - `Text`   : Display "(valid folder)" or "(valid path)"
			;================================================================

				   text := "Path :"
				; options :=  A_Space "y+30"
				options :=  A_Space "y+20"
				options  .= A_Space "cTeal"
				
				Gui, PopupConfig:Add, Text
					, %options%
					,    %text%
				
				
				   text := "Browse"
				options :=  A_Space "g" "GuiConfigPopup.GUI_EVENT_ActionConfig_BrowseButton"
				options  .= A_Space "-Default"
				options  .= A_Space "section"
				; options  .= A_Space "y+15"
				options  .= A_Space "y+10"
				
				Gui, PopupConfig:Add, Button
					, %options%
					,    %text%


				   text := GuiConfigPopup._LV_RowData_FromMainGui["row_actionPath"]
				options :=  A_Space "g" "GuiConfigPopup.GUI_EVENT_ActionConfig_InputPath"
				options  .= A_Space "v" "GuiConfigPopup_ActionConfig_InputPath"
				options  .= A_Space "-Multi -WantTab"
				options  .= A_Space "ys w400"

				Gui, PopupConfig:Add, Edit
					, %options%
					,    %text%

				   ;--------------------------------------------------
				   ; The "(valid folder)" "(valid file)" label 
				   ;  will be dynamically populated every time 
				   ;  the path is checked for an existing file/folder.
				   ; 
				   text := "" 
				options := A_Space "v" "GuiConfigPopup_ActionConfig_LabelVerified"
				options .= A_Space "w120"
				
				Gui, PopupConfig:Add, Text
					, %options%


			;================================================================
			; Add Controls to Configure Action's Arguments if App 
			;----------------------------------------------------------------
			;   - `Text`   : Display "Arguments" 
			;   - `Edit`   : Input field for Arguments to call App with
			;================================================================

				   text := "Arguments :"
				options :=  A_Space "v" "GuiConfigPopup_ActionConfig_LabelArguments1"
				; options  .= A_Space "y+30"
				options  .= A_Space "y+17"
				options  .= A_Space "xs"
				options  .= A_Space "cTeal"
				
				Gui, PopupConfig:Add, Text
					, %options%
					,    %text%
			
				text := ""
				if( "app" = row_actionType ){
					text := GuiConfigPopup._LV_RowData_FromMainGui["row_actionArg"]
				}
				
				; options :=  A_Space "g" "GuiConfigPopup.GUI_EVENT_ActionConfig_Arguments"
				options :=  A_Space "v" "GuiConfigPopup_ActionConfig_InputArguments"
				options  .= A_Space "-Multi -WantTab"
				; options  .= A_Space "ys w390"
				options  .= A_Space "w457"

				Gui, PopupConfig:Add, Edit
					, %options%
					,    %text%
				   
					
			
				   text := "  ( Optional: for advanced use. See tutorial in Savefile. )  " 
				options := A_Space "v" "GuiConfigPopup_ActionConfig_LabelArguments2"
				options  .= A_Space "section"
				; options  .= A_Space "+Border"
				options  .= A_Space "h30"
				; options  .= A_Space "cTeal"
				
					
				Gui, PopupConfig:Add, Text
					, %options%
					,    %text%
					
			return 
		}
		
		Init_AddControls_3_Cmd_SecondTab() {
		global 
		
			;========================================================;
			; This `ListView` displaying all current Actions         ;
			; is only present in these Popups:                       ;
			;========================================================;
			;   - Command Add 
			;   - Command Edit 
			;
			if("command" == this._popup_mode){
			
			  ;----------------------------TAB SWITCH----------------------------
			  ;
			  ; `Tab` present for Command Add & Command Edit.
			  ;
			  ; GuiConfigPopup's 
			  ; 2nd Tab will receive Gui Controls added after the following line:

				Gui, Tab, 2	

			  ;
			  ;----------------------------TAB SWITCH----------------------------
			  
			
				;==========================================
				; Add `ListView` to choose existing Action 
				;==========================================

				
				gui_name     := "PopupConfig"
				goto_name    := "GuiConfigPopup.GUI_EVENT_Cmd_Tab2_ListViewActions"
				control_name := "GuiConfigPopup_Cmd_Tab2_ListViewActions"
				REUSABLE_GUI_CONTROLS.create_listview_of_actions( gui_name
					, goto_name
					, control_name )
				
				LV_ModifyCol(1,"AutoHdr")
				LV_ModifyCol(2,"AutoHdr")
				LV_ModifyCol(3,"AutoHdr")
				LV_ModifyCol(4,"AutoHdr")
				
			}

			
			return
		}
		
		Init_AddControls_4_Both_SubmitButton() {
		global
			
			if("command" == this._popup_mode){
			
			  ;----------------------------TAB SWITCH----------------------------
			  ;
			  ; `Tab` present for Command Add & Command Edit only.
			  ;
			  ; GuiConfigPopup will place Gui Controls added after 
			  ; the following line below the Tab Container:

				Gui, Tab,

			  ;
			  ;----------------------------TAB SWITCH----------------------------
			
			}
			
			;=========================================================================;
			; The `Button` Control named GuiConfigPopup_ButtonSubmit                  ;
			; is present for all Popups:                                              ;
			;=========================================================================;
			;   - Action Add                                                          ;
			;   - Action Edit                                                         ;
			;   - Command Add                                                         ;
			;   - Command Edit                                                        ;
			;=========================================================================;
			
			;---------------------------------------------------------------`
			;  About the Submit Button's Functionality
			;---------------------------------------------------------------``
			; If all the options the user enters into the above Controls 
			; are valid paths & non-duplicate Command names
			; this button will either: 
			;
			;	- Add a new Action or
			;   - Automatically assign 
			;     a preexisting identical Action
			;
			; Then (for Commands)
			;
			;   1. This command:ID pair will be added
			;      to internal _COMMANDS array as:
			;      - a totally new entry, or
			;      - a restored entry, or
			;      - a modified entry).
			;
			;   2. The Command (in the first "Edit" input box)
			;      can now be used to trigger this Action.
			;
			;   3. Then this "GuiConfigPopup" Gui will close.
			;
			; Or Then (for Actions)
			;
			;   1. If edited, the updated Action will be added to _ACTIONS 
			;      and any Commands referencing that ID will now trigger it.
			;
			;   2. If added, the new Action will be added to _ACTIONS 
			;      but it will need to be assigned to a Command 
			;      before it can be triggered.
			;
			;---------------------------------------------------------------```

			;==========================================
			; Add `Button` to Submit Command or Action 
			;==========================================
			
			   text := GuiConfigPopup.get_submit_button_text()
			options :=  A_Space "g" "GuiConfigPopup.GUI_EVENT_ButtonSubmit"
			options  .= A_Space "v" "GuiConfigPopup_ButtonSubmit"
			options  .= A_Space "+Default"
			options  .= A_Space "y+20 xm"
			   
			Gui, PopupConfig:Add, Button
				, %options%
				,    %text%


			return
		}
		
		Init_Config_Controls_After_Render() {
		global 
		
			;==================================================
			; stretch the info label's width 
			;==================================================
			; 
			;  present in all Popups:                       
			;
			;   - Action  Add 
			;   - Action  Edit 
			;   - Command Add 
			;   - Command Edit 
			;----------------------------
			
			c := "GuiConfigPopup_ActionConfig_TextDragAndDrop"
			w := 470 
			
			if( "action" == this._popup_mode){
				w := w - 15
			}
			
			GuiControl, PopupConfig: MoveDraw, %c%, w%w% 
			
			
			;==================================================
			; stretch ListView on any Command Popup's 2nd Tab
			;==================================================
			; 
			;  present in Popups:                       
			;
			;   - Command Add 
			;   - Command Edit 
			;----------------------------
			
			if( "command" == this._popup_mode ){
				
				c := "GuiConfigPopup_Cmd_Tab2_ListViewActions"
				w := 470 ; - 50
				GuiControl, PopupConfig: MoveDraw, %c%, w%w% 
				
			}
			
			;====================================================
			; If the action's path is okay, 
			; make the GuiConfigPopup_ActionConfig_LabelVerified
			; control display the text "(Valid)" 
			;====================================================
			;
			;  present in all Popups:                       
			;
			;   - Action  Add 
			;   - Action  Edit 
			;   - Command Add 
			;   - Command Edit 
			;----------------------------
			
			GuiConfigPopup.GUI_FN_LabelPathVerified_CheckAndRefresh()
			
			;-------------------------------------------------------------------------
			; When a folder is the Action type, 
			; don't display the fields to input Arguments for opening an executable.
			;-------------------------------------------------------------------------
			
			GuiConfigPopup.GUI_FN_ToggleArgumentsIfNotApp()
			
			return 
		}





		GUI_EVENT_OnSize(FLAG:="") {
		global
			
			;=================================
			; Adjust Size of 
			;
			; Tab box 
			; Input Box: Command Name 
			; Input Box: Action Path 
			; Label: About Drag and Drop
			;=================================
			
			;------------------------------------------------------------`
			; OnSize() will be called once when the Gui is rendered
			;------------------------------------------------------------``
			; 
			; Every time this function is called automatically due 
			;  to an AutoHotkey event triggering OnSize(), 
			;  this function's static vars will persistently remember  
			;  the Gui's last size before a resize event.
			;
			; We'll ignore the resizing branch during the first call, 
			;  (a) because all the Controls are properly placed
			;  (b) because the user hasn't resized the window yet.
			;
			;
			; Then all subsequent calls will get the "delta" height value 
			;  (representing the amount of change in height)
			;  comparing the current size to the previous size.
			;
			; This is especially useful to easily calculate y-coordinates
			; but with rapid calls, sometimes AutoHotkey can't keep up 
			; and a bit of deviations in consistency will appear.
			;
			; When possible, it's better to use absolute positionings 
			;  and offsets, but this delta method works well enough
			;  considering its ease.
			;
			; Shout-out to AutoXYWH:
			;  https://www.autohotkey.com/boards/viewtopic.php?f=6&t=1079
			;------------------------------------------------------------```
			
			
			static previous_width
			static previous_height
			static is_baked
			
			
		  ;******************************************************************************
		  ;
		  ;                     Manual Function Calls with Flags
		  ;
		  ;******************************************************************************
			
			;==========================================
			; Initialize static vars & control offsets
			;==========================================
			
			if( "Gui up and running" == FLAG){
				is_baked := true
				return ; A_GuiWidth isn't populated when OnSize() is called manually.
			}
			else if( "RESET" == FLAG){
				is_baked := false
				return ; in process of calling __Delete() for this popup gui instance.
			}
			
			
		  ;******************************************************************************
		  ;
		  ;                    AutoHotkey Event calls to OnSize()
		  ;
		  ;******************************************************************************
		  
			if( true ==  is_baked )
			{
			
				ar_ctrls := [ "GuiConfigPopup_Cmd_InputCommandName"
							, "GuiConfigPopup_Cmd_Tabs"
							, "GuiConfigPopup_ActionConfig_InputPath" 
							, "GuiConfigPopup_ActionConfig_TextDragAndDrop" 
							, "GuiConfigPopup_ActionConfig_InputArguments" 
							, "GuiConfigPopup_Cmd_Tab2_ListViewActions" 
							, "GuiConfigPopup_ButtonSubmit" ]
			
				for i, c in ar_ctrls
				{
					
					;------------------------------------------------------------`
					; Note on algorithm, past and present.
					;------------------------------------------------------------``
					; I replaced my previous implementation using:
					;
					;   delta_w := A_GuiWidth  - previous_width
					;
					; with the following offsets I found through 
					; trial-and-error.
					;
					; These seemingly arbitrary offsets 
					; take the Gui's Client Area's Width (A_GuiWidth)
					; and subtract the margins 
					; and (where applicable) the tab container's offset.
					;
					;------------------------------------------------------------
					; Gui's Client Area:
					;   The window's area available to control placement.
					; 
					;   the Y coordinates start below the title bar
					;	 and (if applicable) menu bar.		
					;   The X coordinates start to to the right 
					;    of the leftmost window style borders (if they exist).
					;------------------------------------------------------------
					; AutoHotkey Docs:
					;   https://www.autohotkey.com/docs/commands/Gui.htm#GuiSize
					;   https://www.autohotkey.com/docs/Variables.htm#GuiWidth
					;------------------------------------------------------------```
					
					
					;========================================================
					; Stretch the width of these Controls 
					; by taking the overall width and subtracting the margins
					;========================================================
					
					w := A_GuiWidth - 20
					if( c = "GuiConfigPopup_ActionConfig_TextDragAndDrop" ){
						
						;---------------------------------------------
						; This layout is reused in:
						;   All Command Popups [Add or Edit] on Tab 1
						;   All Action Popups  [Add or Edit]
						;
						; However, the Actions layout 
						; is not embedded inside a Tab container,
						; so the offsets will differ.
						;---------------------------------------------
						
						if( "action" == GuiConfigPopup._popup_mode){
							w := w - 2
						}
						else{
							w := w - 30
						}
					}
					else if( c = "GuiConfigPopup_ActionConfig_InputPath" ){
						
						;---------------------
						;   Same as above 
						;---------------------
						
						if( "action" == GuiConfigPopup._popup_mode){
							w := w - 57
						}
						else{
							w := w - 100
						}
					}
					else if( c = "GuiConfigPopup_ActionConfig_InputArguments" ){
						
						if( "action" == GuiConfigPopup._popup_mode){
							; w := w - 67
							w := w
						}
						else{
							; w := w - 110
							w := w - 43
						}
						
					}
					;========================================================`
					; Stretch the height for Tab container + ListViews
					; Reposition y-coordinate for buttons.
					;========================================================``
					; 
					; Most of the controls are only stretching their width, 
					; but some need to 
					;   - change their y-coordinate 
					;   - or stretch their height in addition to their width
					;     (i.e. Tab Container and ListView)
					;
					; This branch will 
					;   - calculate these specific needs 
					;   - move the Control, 
					;   - then continue the for loop.
					;========================================================```
					;
					else {
					
						;-----------------------------------------
						; output: ctrl_X, ctrl_Y, ctrl_W, ctrl_H
						;
						GuiControlGet, ctrl_, Pos, %c%
						delta_h := A_GuiHeight - previous_height
						
						if( c = "GuiConfigPopup_Cmd_Tabs" ){
							h := delta_h + ctrl_H
							w := A_GuiWidth - 20 
							GuiControl, PopupConfig: MoveDraw, %c%, w%w% h%h%
							
							continue
						}
						else if( c = "GuiConfigPopup_Cmd_Tab2_ListViewActions" ){
							h := delta_h + ctrl_H
							w := A_GuiWidth - 50
							GuiControl, PopupConfig: MoveDraw, %c%, w%w% h%h%
							
							continue
						}
						else if( c = "GuiConfigPopup_ButtonSubmit"){
							y := ctrl_Y + delta_h
							GuiControl, PopupConfig: MoveDraw, %c%, y%y% 
							
							continue
						}
					}
					
					;========================================================
					; For all controls which just need their width stretched 
					;========================================================
					
					;-----------------------------------------
					; output: ctrl_X, ctrl_Y, ctrl_W, ctrl_H
					;
					GuiControlGet, ctrl_, Pos, %c%
					
					w := (w>150) ? w : ctrl_W
					GuiControl, PopupConfig: MoveDraw, %c%, w%w% 
					
					
				}
				
				
			}
			
			;--------------------------------------------
			; These function-scoped static variables 
			; will remember their values between calls
			;
			previous_width := A_GuiWidth
			previous_height := A_GuiHeight
			
			
			return
		}

		GUI_EVENT_OnEscape() {
		global
		
			_o_Gui_Config_Popup.GUI_EVENT_OnClose()
			
			return
		}
		
		GUI_EVENT_OnClose() {
		global
		
			;------------------------------------------------------;`
			; Call the Destructor method for class GuiConfigPopup. ;
			;------------------------------------------------------;``
			;                                                      ;
			; GuiConfigPopup.__Delete() will:                      ;
			;                                                      ;
			; - push or revert changes                             ;
			; - restore control to GuiConfigMain                   ;
			; - delete and free any vars this object is using      ;
			; - destroy the popup GUI                              ;
			;------------------------------------------------------;```
			
			;-----------------------------------------------------------------
			; AutoHotkey Info 
			;-----------------------------------------------------------------
			; obj := "" 
			;   Calls the object's __Delete() class destrutor 
			;   if this is the last variable referencing the object instance 
			;   (in this case, it is).
			;-----------------------------------------------------------------
			;
			_o_Gui_Config_Popup := "" 
			return
		}

		GUI_EVENT_OnDropFiles() {
		global
		
			;---------------------------------------------------------------------`
			; AutoHotkey Docs for GuiDropFiles
			;---------------------------------------------------------------------``
			; A_EventInfo and ErrorLevel:
			;   Both contain the number of files dropped.
			;---------------------------------------------------------------------
			; A_GuiEvent:
			;   Contains the names of the files that were dropped, 
			;   with each filename except the last terminated by a linefeed (`n).
			;---------------------------------------------------------------------
			; https://www.autohotkey.com/docs/commands/Gui.htm#GuiDropFiles
			;---------------------------------------------------------------------```
			
			Gui, PopupConfig:Submit, NoHide 
			
			if( "action" == GuiConfigPopup._popup_mode
			or  "Add New Action" == GuiConfigPopup_Cmd_Tabs )
			{
				;--------------------------------------------
				; Populate GUI data with drag-n-dropped file.
				;--------------------------------------------
				; User dropped 1 file onto GuiConfigPopup GUI 
				;--------------------------------------------
				if( A_EventInfo == 1 ){
					
					is_dragNdrop_valid := FileExist(A_GuiEvent)
			
					if( "" !=  is_dragNdrop_valid ){
					
						if( InStr(is_dragNdrop_valid, "D") ){
							; populate as dir 
							
							GuiControl,, GuiConfigPopup_ActionConfig_RadioFolder, 1
							GuiControl,, GuiConfigPopup_ActionConfig_RadioApp   , 0
							
							GuiControl,, GuiConfigPopup_ActionConfig_InputPath, %A_GuiEvent%
						}
						else {
							; populate as file 
							
							GuiControl,, GuiConfigPopup_ActionConfig_RadioFolder, 0
							GuiControl,, GuiConfigPopup_ActionConfig_RadioApp   , 1
							
							GuiControl,, GuiConfigPopup_ActionConfig_InputPath, %A_GuiEvent%
						}
					
					}
				}
				;----------------------------------------------------
				; Unsupported.
				;----------------------------------------------------
				; User dropped more than 1 file onto GuiConfigPopup GUI 
				;----------------------------------------------------
				else if( A_EventInfo > 1 ){
					str_for_usr_output := "_program_launcher.ahk`n`n"
					str_for_usr_output .= "--------------`nOops`n--------------`n"
					str_for_usr_output .= """Edit a Command"" can't process more than one file.`n`n"
					str_for_usr_output .= "Ensure you only have one file selected `n"
					str_for_usr_output .= "in Windows Explorer.`n`n"
					str_for_usr_output .= "Then try to drag-and-drop it onto this window again.`n"
					
					MsgBox,, % "[X] Can't process more than one file for a path.", %str_for_usr_output%
				}
			}
			
			return
		}





		GUI_EVENT_Cmd_TabChanged() {
		global
			GuiConfigPopup.GUI_FN_ButtonSubmit_Refresh_Text()
			return
		}
		
		GUI_EVENT_ActionConfig_RadioChanged() {
		global
			GuiConfigPopup.GUI_FN_LabelPathVerified_CheckAndRefresh()
			GuiConfigPopup.GUI_FN_ToggleArgumentsIfNotApp()
			return
		}

		GUI_EVENT_ActionConfig_BrowseButton() {
		global
		
			GuiConfigPopup.GUI_FN_LabelPathVerified_CheckAndRefresh()
			
			is_folder_chosen := GuiConfigPopup_ActionConfig_RadioFolder
			is_app_chosen    := GuiConfigPopup_ActionConfig_RadioApp
			user_chose_path  := ""
			
			row_actionPath := GuiConfigPopup._LV_RowData_FromMainGui["row_actionPath"]
			
			if( is_folder_chosen ){
				SplitPath, row_actionPath,, dir
				FileSelectFolder, user_chose_path, *%dir%,, Select Folder To Open With Command
			}
			else if( is_app_chosen ){
				FileSelectFile, user_chose_path, 3, %row_actionPath%, Select Program To Open With Command
			}
			
			GuiControl,, GuiConfigPopup_ActionConfig_InputPath, %user_chose_path%
			return 
		}
		
		GUI_EVENT_ActionConfig_InputPath() {
		global
			
			; Display (Valid Folder) or (Valid File) if it exists
			GuiConfigPopup.GUI_FN_LabelPathVerified_CheckAndRefresh()		
			
			GuiControlGet, pathSoFar, PopupConfig: , GuiConfigPopup_ActionConfig_InputPath
			
			match_without_quotes := "^[""]([^`n`r]*)[""]$"
			
			if( RegExMatch(pathSoFar, match_without_quotes ) ){
				path_without_quotes := RegExReplace( pathSoFar, match_without_quotes, "$1" )
				
				GuiControl, PopupConfig: , GuiConfigPopup_ActionConfig_InputPath, %path_without_quotes%
				; msgbox without quotes %path_without_quotes%
			}
			return
		}
		
		GUI_EVENT_ActionConfig_Arguments() {
		global
		
			return
		}
		
		GUI_EVENT_Cmd_Tab2_ListViewActions() {
		global
			GuiConfigPopup.GUI_FN_Cmd_Tab2_ListView_Activate()
			
			; msgbox A_EventInfo %A_EventInfo%
			if ( "DoubleClick" = A_GuiEvent ){
				
			}
			
			if ( "I" = A_GuiEvent ){
				
				;-------------------------------------------------------------
				; If a row is selected, the if branch will be entered
				; and the Action ID will be stored in this variable.
				; 
				; If a row is deselected, then this variable will be cleared.
				;
				; Used for 
				;   - Submit Button text in Command Popup's "Use Existing Action" tab 
				;   - Submitting the Command Popup's input to GuiMain and _COMMANDS 
				;
				GuiConfigPopup._LV_selected_action_id := ""
				
				is_a_selection_event := InStr(ErrorLevel, "S", CaseSensitive:=true)
				if( is_a_selection_event ){
					LV_GetText(sel_act_id, A_EventInfo,1)
					GuiConfigPopup._LV_selected_action_id := sel_act_id
					
					; debug := "gui tab2 actions selected row[" A_EventInfo "]"
					; debug .= " id[" sel_act_id "] is_sel[" is_a_selection_event "]"
					; debug .= " er[%ErrorLevel%]"
					; msgbox, %debug% 
				}
				GuiConfigPopup.GUI_FN_ButtonSubmit_Refresh_Text()
			}
			
			return
		}
		
		GUI_EVENT_ButtonSubmit() {
		global
			GuiConfigPopup.Submit_Changes()		
		return
		}
			
				
		GUI_FN_Cmd_Tab2_ListView_Activate() {
		global

			;--------------------------------------------------------------------;
			; This line ensures "Gui, " commands operate on the main GUI window  ;
			;--------------------------------------------------------------------;
			
			Gui, PopupConfig:Default

			;---------------------------------------------------;
			; This line ensures ListView commands "LV_..()"     ;
			; operate on this specific ListView                 ;
			;---------------------------------------------------;
			
			Gui, PopupConfig:ListView, GuiConfigPopup_Cmd_Tab2_ListViewActions
			
			
			;----------------------------------------------------------------
			; see:                                                          
			; https://www.autohotkey.com/docs/commands/Gui.htm#MultiWin     
			; https://www.autohotkey.com/docs/commands/Gui.htm#Default      
			; https://www.autohotkey.com/docs/commands/ListView.htm#BuiltIn 
			;----------------------------------------------------------------

			return
		}
		
		GUI_FN_ButtonSubmit_Refresh_Text() {
		global 
			
			Gui, PopupConfig:Submit, NoHide
			
			button_text := GuiConfigPopup.get_submit_button_text()		
			c := "GuiConfigPopup_ButtonSubmit"				
			GuiControl, PopupConfig: Text, %c%, %button_text%
			
			return 
		}
		
		GUI_FN_LabelPathVerified_CheckAndRefresh() {
		global
		
			Gui, PopupConfig:Submit, NoHide
			
			is_path_valid := false
			string_for_valid_label := ""
			
			c := "GuiConfigPopup_ActionConfig_InputPath"
			GuiControlGet, path,, %c%
			
			is_valid_path := FileExist(path)
			
			if(  is_valid_path != "" ){
				if( GuiConfigPopup_ActionConfig_RadioFolder ){
					if( InStr(is_valid_path, "D") ){
						string_for_valid_label := "(valid folder)"
						is_path_valid := true
					}
				}
				else if( GuiConfigPopup_ActionConfig_RadioApp ){
					if( !InStr(is_valid_path, "D") ){
						string_for_valid_label := "(valid file)"
						is_path_valid := true
					}
				}
			}
			
			; msgbox % string_for_valid_label
			
			c := "GuiConfigPopup_ActionConfig_LabelVerified"
			GuiControl,, %c%, %string_for_valid_label%
			
			
			GuiConfigPopup._isPathValid := is_path_valid
			return is_path_valid
		}
	
		GUI_FN_ToggleArgumentsIfNotApp() {
		global
		
			Gui, PopupConfig:Submit, NoHide
			
			if( GuiConfigPopup_ActionConfig_RadioApp ){
			
				GuiControl
					,PopupConfig: -Hidden
					,GuiConfigPopup_ActionConfig_InputArguments
					
				GuiControl
					,PopupConfig: -Hidden
					,GuiConfigPopup_ActionConfig_LabelArguments1
					
				GuiControl
					,PopupConfig: -Hidden
					,GuiConfigPopup_ActionConfig_LabelArguments2
				
			}
			else{ ; if GuiConfigPopup_ActionConfig_RadioFolder OR if uninitialized
			
				GuiControl
					,PopupConfig: +Hidden
					,GuiConfigPopup_ActionConfig_InputArguments
					
				GuiControl
					,PopupConfig: +Hidden
					,GuiConfigPopup_ActionConfig_LabelArguments1
					
				GuiControl
					,PopupConfig: +Hidden
					,GuiConfigPopup_ActionConfig_LabelArguments2
			
			}
			return
		}

		
		get_submit_button_text() {
		global 
			
			button_text := ""
			
			;---------------------------------------------------------------------`
			; This "tab_num" var won't be used for Action New or Action Edit, 
			; so we don't need an if branch checking "this._popup_mode"
			;---------------------------------------------------------------------``
			;
			; When this function get_submit_button_text() is called from __New(), 
			; the var "GuiConfigPopup_Cmd_Tabs" won't be populated yet, 
			; but we can safely default it to "tab1".
			;                                                                     ```
			tab_num := ("Use Existing Action" = GuiConfigPopup_Cmd_Tabs) ? "tab2" : "tab1"
			
			
			;--------------------------------------------------------------
			; The static class member var "text"
			; is an associative array holding more associative arrays.
			;
			; It holds the text to display on the submit button 
			; using the kys of
			; 	- type of config popup 
			; 	- purpose for popup ("add" or "edit")
			; 	- (and for the Command popups, different text for each tab)
			;
			button_text := ("command" == this._popup_mode)
				;----------------------------
				; if Command config popup
				? this.text["command_popup"][this._popup_purpose][tab_num]
				;----------------------------
				; else, Action config popup
				: this.text["action_popup"][this._popup_purpose]
			
			if( "tab2" == tab_num ){
			
				;------------------------------------------------------------
				; _LV_selected_action_id, updated on ListView selection events
				;
				lv_item_actID := GuiConfigPopup._LV_selected_action_id
				
				if( "" != lv_item_actID ){
					
					;--------------------------------------------------------------------
					; change "Use Action[]" to "Use Action[123]" on LV selection change
					;
					button_text := RegExReplace(button_text, "^Use Action\[", "Use Action[" lv_item_actID)
					
				}
			}
			
			return button_text
		}
		
		
		
		Submit_Changes() {
		global
		
			Gui, PopupConfig:Submit, NoHide
			
			mode    := GuiConfigPopup._popup_mode
			purpose := GuiConfigPopup._popup_purpose
			
			/*
				GuiConfigPopup.Submit_Changes()
				GuiConfigPopup.Submit_Changes_1_GatherVariables()
				GuiConfigPopup.Submit_Changes_2__VerifyActionVars()
				GuiConfigPopup.Submit_Changes_2__VerifyCommandVars()
				GuiConfigPopup.Submit_Changes_3___ActionSubmit()
				GuiConfigPopup.Submit_Changes_3___CommandSubmit()
				GuiConfigPopup.Submit_Changes_4____Finalize_And_Close()
			*/
			
			GuiConfigPopup.Submit_Changes_1_GatherVariables()
			
			varsOK := false 
			success := false 
			
			if("action"  == mode)
				varsOK := GuiConfigPopup.Submit_Changes_2__VerifyActionVars()
				
			if("command" == mode)
				varsOK := GuiConfigPopup.Submit_Changes_2__VerifyCommandVars()
			
			if( varsOK == "User notified to try again." ){
			
				; No errors, but Command name conflict.
				; Cancel submit, keep popup open.
				;
				return 
				
			}
			if( varsOK == false ){ ;then bug;
			
				msgbox, 16, [ PROGRAM ERROR ], Failed to submit changes -- var verify failed.
				GuiConfigPopup.Submit_Changes_DEBUG()
				return
				
			}
			
			if("action"  == mode)
				success := GuiConfigPopup.Submit_Changes_3___ActionSubmit()
				
			if("command" == mode)
				success := GuiConfigPopup.Submit_Changes_3___CommandSubmit()
			
			if( success == "notified user of conflict, no errors" ){
				return 
			}
			
			if( true == success )
				GuiConfigPopup.Submit_Changes_4____Finalize_And_Close()
			
			if( false == success ){ ;then bug;
				msgbox, 16, [ PROGRAM ERROR ], Failed to submit changes.
				GuiConfigPopup.Submit_Changes_DEBUG()
			}
			
			return
			
			/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
			   alternate if branches, different paths but same functionality in fewer lines:
			 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
			 
				if("action"  == mode)
					if true =      GuiConfigPopup.Submit_Changes_2__VerifyActionVars()
						if true =  GuiConfigPopup.Submit_Changes_3___ActionSubmit()
								   GuiConfigPopup.Submit_Changes_4____Finalize_And_Close()
				
				if("command" == mode)
					if true =      GuiConfigPopup.Submit_Changes_2__VerifyCommandVars()
						if true =  GuiConfigPopup.Submit_Changes_3___CommandSubmit()
								   GuiConfigPopup.Submit_Changes_4____Finalize_And_Close()
								   
			 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
			*/
		}
		
		Submit_Changes_DEBUG() {
		global	
			mode    := GuiConfigPopup._popup_mode
			purpose := GuiConfigPopup._popup_purpose
			
			debug_out := "" 
			debug_out .= "mode"                           "`n["     mode                         "]`n`n"
			debug_out .= "purpose"                        "`n["     purpose                      "]`n`n"
			debug_out .= "A_input_newAction_type"         "`n["     A_input_newAction_type       "]`n`n"
			debug_out .= "B_input_newAction_path"         "`n["     B_input_newAction_path       "]`n`n"
			debug_out .= "C_input_newAction_arg "         "`n["     C_input_newAction_arg        "]`n`n"
			debug_out .= "D_input_oldAction_id     "      "`n["     D_input_oldAction_id         "]`n`n"
			debug_out .= "E_input_cmd_theCommand   "      "`n["     E_input_cmd_theCommand       "]`n`n"
			debug_out .= "TAB_cmd_tab_is_new_action"      "`n["     TAB_cmd_tab_is_new_action    "]`n`n"
			debug_out .= "F_insertion_point_for_mainLV"   "`n["     F_insertion_point_for_mainLV "]`n`n"
			
			msgbox % debug_out
			
			return
		}
		
		Submit_Changes_1_GatherVariables() {
		global 
		
		;--------------------------------------------------------------------------------------`
		; Note on scope and globals
		;--------------------------------------------------------------------------------------``
		; ABCDEF_vars + TAB_var (in table below)  are all global 
		;
		; and will be used in:
		;   - Submit_Changes_2_Action()
		;   - Submit_Changes_3_Command()
		;
		; The benefit of using single instance popups
		; is we can safely use global variables instead of parameters.
		;
		; The only tradeoffs are : 
		;   - (1) We need to be sure: these vars are unique and not edited elsewhere. 
		;   - (2) We need to  ensure: these vars are reset between Popup __New() calls.
		;   - (3) We cannot make multiple instances of these popups 
		;         without refactoring these globals into this._class_members.
		;
		; For the scope and function of this app, this design works fine.
		;--------------------------------------------------------------------------------------```
		
			
			/*
				  ------------------------------------------------------------------------
							  Vars we need to be valid in order to submit:
				  ------------------------------------------------------------------------
				
			----------------------------------------------------------------------------------
			 #      var to store per input              Overview of Each Popup & Input Used
			----------------------------------------------------------------------------------
												 |                                
												 |  Gui Popup: Action 
												 |  
												 |    purpose: add
												 |      [x] main.LV_selected_row
			 A     input_newAction_type          |      [✓] pop.newact.folder || pop.newact.app
			 B     input_newAction_path          |      [✓] pop.newact.path
			 C     input_newAction_arg           |      [✓] pop.newact.arg 
												 |           
												 |    purpose: edit
			 F     LV row data["LV_id"]          |      [✓] main.LV_selected_row
			 A     input_newAction_type          |      [✓] pop.newact.folder || pop.newact.app
			 B     input_newAction_path          |      [✓] pop.newact.path
			 C     input_newAction_arg           |      [✓] pop.newact.arg 
			 D     input_oldAction_id            |      [✓] pop.oldact.id
												 |  
												 |  
												 |  Gui Popup: Command 
												 |  
												 |    purpose: add
												 |  
												 |      [x] main.LV_selected_row
			 E     input_cmd_theCommand          |      [✓] pop.cmd
												 |  
			 TAB   cmd_tab_is_new_action         |      if tab: add action
			 A     input_newAction_type          |          [✓] pop.newact.folder || pop.newact.app
			 B     input_newAction_path          |          [✓] pop.newact.path
			 C     input_newAction_arg           |          [✓] pop.newact.arg 
												 |  
			 TAB   cmd_tab_is_new_action         |      if tab: use existing action
			 D     input_oldAction_id            |          [✓] pop.oldact.id
												 |            
												 |    purpose: edit
												 |                                
			 F     LV row data["LV_id"]          |      [✓] main.LV_selected_row
			 E     input_cmd_theCommand          |      [✓] pop.cmd
												 |                                
			 TAB   cmd_tab_is_new_action         |      if tab: add action
			 A     input_newAction_type          |          [✓] pop.newact.folder || pop.newact.app
			 B     input_newAction_path          |          [✓] pop.newact.path
			 C     input_newAction_arg           |          [✓] pop.newact.arg 
												 |                                
			 TAB   cmd_tab_is_new_action         |      if tab: use existing action
			 D     input_oldAction_id            |          [✓] pop.oldact.id
												 |                                
												 |                                
			----------------------------------------------------------------------------------
			[A,B,C,D,E,F,TAB]          Which Popups use which of the var #s? 
			----------------------------------------------------------------------------------
			
				  A :            act.add, act.edit,   cmd.add.tab1, cmd.edit.tab1
				  B :            act.add, act.edit,   cmd.add.tab1, cmd.edit.tab1
				  C :            act.add, act.edit,   cmd.add.tab1, cmd.edit.tab1
				  D :                     act.edit,   cmd.add.tab2, cmd.edit.tab2
				  E :                                 cmd.add,      cmd.edit
				  F :                     act.edit,                 cmd.edit
				TAB :                                 cmd.add       cmd.edit
				
			----------------------------------------------------------------------------------
			
			*/
			
			
			mode    := GuiConfigPopup._popup_mode
			purpose := GuiConfigPopup._popup_purpose
			
			
			A_input_newAction_type       := ""     ; A ;   all pop.act,   all pop.cmd (if tab 1)
			B_input_newAction_path       := ""     ; B ;   all pop.act,   all pop.cmd (if tab 1)
			C_input_newAction_arg        := ""     ; C ;   all pop.act,   all pop.cmd (if tab 1)
			
			D_input_oldAction_id         := ""     ; D ;       pop.edit   all pop.cmd (if tab 2)
			E_input_cmd_theCommand       := ""     ; E ;                  all pop.cmd
			TAB_cmd_tab_is_new_action    := ""     ; TAB ;                all pop.cmd
			
			F_insertion_point_for_mainLV := ""     ; F ;   edit pop.act, edit pop.cmd
			
			
			if("edit" == purpose){
			
				;-----------------------------------------------------------------------`
				; If editing a Command or an Action 
				;-----------------------------------------------------------------------``
				;
				; the original needs a valid insertion point 
				; in GuiConfigMain's corresponding ListView.
				;
				; Before the popup was rendered, the Action or Command 
				; was removed from _ACTIONS or _COMMANDS 
				; to make duplication-checking logic simpler below 
				; (and that entry will be added back, possibly modified,
				;  after successful Submit). 
				;
				; Their entry inside their ListView is still there in the GUI, unaltered 
				; (but will be changed upon a successful edit)
				;-----------------------------------------------------------------------```
				
				;---;
				; F ;
				;---;
				F_insertion_point_for_mainLV := GuiConfigPopup._LV_RowData_FromMainGui["LV_id"]
			}
			
			if( "command" == mode ){
			
				;-----;
				; TAB ;
				;-----;
				TAB_cmd_tab_is_new_action := ("Add New Action" = GuiConfigPopup_Cmd_Tabs) ? true : false
				
				;---;
				; E ;
				;---;
				c := "GuiConfigPopup_Cmd_InputCommandName"
				GuiControlGet, cmd,, %c%
				E_input_cmd_theCommand := cmd 

				;-------------------------------------
				; Command Tab2 "Use Existing Action"
				;-------------------------------------
				;
				if( false == TAB_cmd_tab_is_new_action ){
					; tmp := GuiConfigPopup._LV_selected_action_id
					; msgbox in gather lv is %tmp%
					
					action_id := GuiConfigPopup._LV_selected_action_id
					
					if( _ACTIONS.HasKey(action_id) ){
					
						;---;   ;---;   ;---;
						; A ;   ; B ;   ; C ;
						;---;   ;---;   ;---;
						A_input_newAction_type := _ACTIONS[action_id]["type"]
						B_input_newAction_path := _ACTIONS[action_id]["path"]
						C_input_newAction_arg  := _ACTIONS[action_id]["arg"]
						
						;---;
						; D ;
						;---;
						D_input_oldAction_id := action_id
					}
					
				}
			}
			
			if("action" == mode
			or true     == TAB_cmd_tab_is_new_action){
				
				
				;---;
				; A ;
				;---;
				if(GuiConfigPopup_ActionConfig_RadioFolder){
					A_input_newAction_type := "folder"
				}
				else if( GuiConfigPopup_ActionConfig_RadioApp ){
					A_input_newAction_type := "app"
				}
				
				;---------------------------------------------------
				; sets GuiConfigPopup._isPathValid to true or false
				;
				GuiConfigPopup.GUI_FN_LabelPathVerified_CheckAndRefresh()
				if( GuiConfigPopup._isPathValid ){
				
					;---;
					; B ;
					;---;
					c := "GuiConfigPopup_ActionConfig_InputPath"
					GuiControlGet, path,, %c%
					B_input_newAction_path := path
					; msgbox in gather path is {%path%}
				}
				
				;-----------------------------------------------------------
				; Only actions which open an application
				; will possibly have a custom Argument provided by the user 
				;
				if( GuiConfigPopup_ActionConfig_RadioApp ){
				
					;---;
					; C ;
					;---;
					c := "GuiConfigPopup_ActionConfig_InputArguments"
					GuiControlGet, userInputArg,, %c%
					C_input_newAction_arg := userInputArg
				}
				
				if( "action" == mode 
				and "edit"   == purpose ){
					
						;---;
						; D ;
						;---;
						D_input_oldAction_id := GuiConfigMain._plucked_action["action_id"]
				}
			}
			
			; msgbox gather: path[%B_input_newAction_path%]
			
			;-------------------------------------;
			;   A,B,C,D,E,F,TAB are now all set   ;
			;-------------------------------------;
			;   1 - [✓] Gather Variables          ;
			;-------------------------------------;
			
			;-----------------------------------------------------------;
			; GuiConfigPopup.Submit_Changes()                           ;
			; will continue from here and:                              ;
			;-----------------------------------------------------------;
			;   2 - validate the vars                                   ;
			;   3 - attempt to submit if all vars valid                 ;
			;   4 - then if it all worked: close down the gui instance  ;
			;-----------------------------------------------------------;
			
			return
		}
			
		Submit_Changes_2__VerifyActionVars() {
		global 
			/*
				A_input_newAction_type       := ""     ; A ;   all pop.act
				B_input_newAction_path       := ""     ; B ;   all pop.act
				C_input_newAction_arg        := ""     ; C ;   all pop.act
				D_input_oldAction_id         := ""     ; D ;       pop.edit   all pop.cmd (if tab 2)
				
				F_insertion_point_for_mainLV := ""     ; F ;   edit pop.act
			*/
			
			mode    := GuiConfigPopup._popup_mode
			purpose := GuiConfigPopup._popup_purpose
			
			FAILURE := false
			SUCCESS := true
			USER_NOTIFIED := "User notified to try again."
				
				
				
			;=========================
			; Cancel if vars not set
			;=========================
			
			;---;   ;---;   ;---;
			; A ;   ; B ;   ; C ;
			;---;   ;---;   ;---;
			if( "" == A_input_newAction_type
			or  "" == B_input_newAction_path ){
			; it's okay if C_input_newAction_arg is empty
			
				return FAILURE
				
			}
		
			if("edit" == purpose){
			
				;---;
				; D ;
				;---;
				if( "" == D_input_oldAction_id ){
					return FAILURE				
				}
				
				;---;
				; F ;
				;---;
				if( "" == F_insertion_point_for_mainLV ){
					return FAILURE
				}
				
			}
			
			
			
			
			;========================================================
			; Standardize Action Path (directory or app) string
			;========================================================
			
			;--------------------------------------------------
			; Standardize paths like:
			;    "C:/somdir\another/dir"
			; 
			; to have uniform backslashes and trailing slashes:
			;    "C:\somdir\another\dir\"
			;
			p1 := B_input_newAction_path
			p2 := A_input_newAction_type
			
			;---;
			; B ;
			;---;
			B_input_newAction_path := FILE_HELPER.Fn_Standardize_Path_String( p1, p2 )
			
			
			
			;========================================================
			; Check for identical preexisting Actions
			;========================================================
			
			found_duplicate_action := GuiConfigPopup.does_action_already_exist( ""
				.   A_input_newAction_type
				  , B_input_newAction_path
				  , C_input_newAction_arg  )
			
			if( found_duplicate_action ){
				inform_user := "Action already exists.`n`n"
				inform_user .= "Action[" found_duplicate_action "] is already configured to do this:`n"
				inform_user .= "    Type:`t" A_input_newAction_type "`n"
				inform_user .= "    Path:`t" B_input_newAction_path "`n"
				inform_user .= ("" != C_input_newAction_arg) 
								? "    Arg:`t" C_input_newAction_arg 
								: "`n`n"
				inform_user .= "`n`n"
				inform_user .= "No action taken."
				
				MsgBox,, [Duplicate Action], %inform_user%
				return USER_NOTIFIED
			}
			
			
			
			;------------------------------------------------------;
			;   If this line is reached, then all vars are good!   ;
			;------------------------------------------------------;
			;   1 - [✓] Gather Variables                           ;
			;   2 - [✓] Verify Variables                           ;
			;------------------------------------------------------;
			
			;-----------------------------------------------------------;
			; GuiConfigPopup.Submit_Changes()                           ;
			; will continue from here and:                              ;
			;-----------------------------------------------------------;
			;   3 - attempt to submit changes and (if succeessful)      ;
			;   4 - close down the gui instance                         ;
			;-----------------------------------------------------------;
			
			return SUCCESS
		}
		
		
		Submit_Changes_2__VerifyCommandVars() {
		global 
			/*
				A_input_newAction_type       := ""     ; A ;     all pop.cmd (if tab 1)
				B_input_newAction_path       := ""     ; B ;     all pop.cmd (if tab 1)
				C_input_newAction_arg        := ""     ; C ;     all pop.cmd (if tab 1)
				
				D_input_oldAction_id         := ""     ; D ;     all pop.cmd (if tab 2)
				E_input_cmd_theCommand       := ""     ; E ;     all pop.cmd
				F_insertion_point_for_mainLV := ""     ; F ;   edit  pop.cmd
				
				TAB_cmd_tab_is_new_action    := ""     ; TAB ;   all pop.cmd
			*/
			
			; msgbox in verfcmd
			
			mode    := GuiConfigPopup._popup_mode
			purpose := GuiConfigPopup._popup_purpose
			
			is_tab_1 := TAB_cmd_tab_is_new_action
			is_tab_2 := !TAB_cmd_tab_is_new_action
			
			SUCCESS := true
			FAILURE := false
			USER_NOTIFIED := "User notified to try again."
			
			
			;=========================
			; Cancel if vars not set
			;=========================
			
			;--------------------------------
			; Tab1 -> "Add New Action" tab.
			;
			if( is_tab_1 ){
			
				;---;   ;---;   ;---;
				; A ;   ; B ;   ; C ;
				;---;   ;---;   ;---;
				if( "" == A_input_newAction_type
				or  "" == B_input_newAction_path ){
				; it's okay if C_input_newAction_arg is empty 
				
					return FAILURE
					
				}
				
			}
			
			;---------------------------------------
			; Tab2 -> "Using Existing Action" tab.
			;
			if( is_tab_2 ){
			
				;---;
				; D ;
				;---;
				if( "" == D_input_oldAction_id ){ ; error
					return FAILURE
				}
			
			}
			
			;-------------------------
			; Either Tab 
			;-------------------------
			
			;---;
			; E ;
			;---;
			if( "" == E_input_cmd_theCommand ){ ; error
			; If Command text is empty 
			
				
				return FAILURE			
			}
			
			
			if("edit" == purpose){
			
				;---;
				; F ;
				;---;
				if( "" == F_insertion_point_for_mainLV ){  ; error
					return FAILURE
				}
				
			}
			
			
			;========================================================
			; Ensure Command (if renamed) is unique.
			;========================================================
			
			;---;
			; E ;
			;---;
			if( _COMMANDS.HasKey( E_input_cmd_theCommand ) ){
			; If another Command already uses this text 
			
				
				usr_output := "Oops, there's already a command with the word or phrase:`n`n"
				usr_output .= "    " E_input_cmd_theCommand "`n`n"
				usr_output .= "Either remove that command first,`n"
				usr_output .= "or try another phrase."
				
				MsgBox,,Duplicate Command, %usr_output%			
				
				return USER_NOTIFIED			
			}
			
			
			
			;========================================================
			; If new Action:
			;
			;   Standardize all Action path strings
			;   (a) So all path strings are uniform across the App.
			;   (b) To aid in comparisons searching for duplicates.
			;========================================================
			
			;--------------------------------
			; Tab1 -> "Add New Action" tab.
			;
			if( is_tab_1 ){
			
				;========================================================
				; Format Action Path (directory or app) string
				;========================================================
				
				;--------------------------------------------------
				; Standardize paths like:
				;    "C:/somdir\another/dir"
				; 
				; to have uniform backslashes and trailing slashes:
				;    "C:\somdir\another\dir\"
				;
				p1 := B_input_newAction_path
				p2 := A_input_newAction_type
				
				
				;---;
				; B ;
				;---;
				B_input_newAction_path := FILE_HELPER.Fn_Standardize_Path_String( p1, p2 )
				
			}
			
			
			;------------------------------------------------------;
			;   If this line is reached, then all vars are good!   ;
			;------------------------------------------------------;
			;   1 - [✓] Gather Variables                           ;
			;   2 - [✓] Verify Variables                           ;
			;------------------------------------------------------;
			
			;-----------------------------------------------------------;
			; GuiConfigPopup.Submit_Changes()                           ;
			; will continue from here and:                              ;
			;-----------------------------------------------------------;
			;   3 - attempt to submit changes and (if succeessful)      ;
			;   4 - close down the gui instance                         ;
			;-----------------------------------------------------------;
			
			return SUCCESS
		}
		
		Submit_Changes_3___ActionSubmit() {
		global
		
			/*
				A_input_newAction_type       := ""     ; A ;   all pop.act
				B_input_newAction_path       := ""     ; B ;   all pop.act
				C_input_newAction_arg        := ""     ; C ;   all pop.act
				
				F_insertion_point_for_mainLV := ""     ; F ;   edit pop.act
			*/
			
			mode    := GuiConfigPopup._popup_mode
			purpose := GuiConfigPopup._popup_purpose
			
			FAILURE := false
			SUCCESS := true
			USER_NOTIFIED := "notified user of conflict, no errors"
			
			popup_actionType := A_input_newAction_type
			popup_actionPath := B_input_newAction_path
			popup_actionArg  := C_input_newAction_arg
			
			popup_actionID   := ""

			if( "add" == purpose ){
				popup_actionID := _ACTIONS.Length()+1	
			}
			if( "edit" == purpose ){
				popup_actionID := D_input_oldAction_id		
			}
			
			
			
			;========================================================
			; Submit new or edited Action to _ACTIONS array 
			;========================================================
			
			if( !_ACTIONS.HasKey(popup_actionID) ){
				
				_ACTIONS[popup_actionID] := { "" 
					. "type": popup_actionType
					, "path": popup_actionPath
					, "arg" : popup_actionArg   }
					
			}
			
			
			
			;=======================================================================
			; Submit new or edited Action to ListView for Actions in GuiConfigMain
			;=======================================================================
			
			;------------------------------------------------------------------------------
			; Tells future ListView operations to operate on this specific ListView control
			GuiConfigMain.ListViewActions_Activate()
			
			LV_FAILURE := 0
			
			if( "add" == purpose ){
			
				options := ""
				LV_returned := LV_ADD( ""
					. options             ; no options needed
					, popup_actionID        ; row 1
					, popup_actionType      ; row 2
					, popup_actionPath      ; row 3
					, popup_actionArg  )    ; row 4
				
				; for debugging
				;
				; msgBOX lv %LV_returned%
				; GuiConfigPopup.Submit_Changes_DEBUG()
				
				;----------------------------------------------
				; cancel submit, inform user, return to popup
				;
				if(LV_returned == LV_FAILURE ){
					MSGBOX, Failed to add new action to ListView.
					
					GuiConfigPopup.Submit_Changes_DEBUG()
					
					return FAILURE
				}
			}
			
			else
			if( "edit" == purpose){
			
				modify_this_row := F_insertion_point_for_mainLV
				
				LV_returned := LV_MODIFY( modify_this_row
					,                     ; no options needed
					, popup_actionID		; row 1
					, popup_actionType	    ; row 2
					, popup_actionPath	    ; row 3
					, popup_actionArg  )    ; row 4
				
				if(LV_returned == LV_FAILURE ){
					msgbox, Failed to edit existing action in ListView.
					
					GuiConfigPopup.Submit_Changes_DEBUG()
					
					return FAILURE
				}
					
				;----------------------------------------
				; Remove backup of (now) edited Action
				;----------------------------------------
				; Making this variable empty will prevent 
				;
				;   GUI_EVENT_GuiConfigPopup_OnClose and
				;   GUI_EVENT_GuiConfigPopup_OnEscape
				;
				; from automatically restoring 
				; the old version of this Action
				;
				; when the GuiConfigPopup GUI is closed.
				;----------------------------------------
				
				GuiConfigMain.Discard_Plucked_Action()
				
				GuiConfigMain.ListViewCommands_UpdateAllWhichUseAction(popup_actionID)
			}
			
			
			
			;=======================================================================
			; Submit changes to Savefile (all above operations were successful)
			;=======================================================================
			
			;-------------------------------------------------------------------`
			; Syntax Reference
			;-------------------------------------------------------------------``
			; class:    FILE_HELPER
			; function: Change_Savefile( p1,p2,p3,p4 )
			;
			; p1:  mode                      action|command
			; p2:  purpose                   add|delete|edit|enable|disable
			; p2:  action_id__or__cmd        new Action's ID 
			; p2:  cmd_name_before_rename    not applicable here
			;-------------------------------------------------------------------```
			
			p1 := "action"
			p2 := purpose 
			p3 := popup_actionID
			p4 := ""
			savefile_updated := FILE_HELPER.Change_Savefile( p1,p2,p3,p4 )
			
			if( !savefile_updated ){
				MSGBOX, 16, ERROR WRITING TO SAVEFILE, [~]
				return FAILURE
			}
			
			
			return SUCCESS
			
		} ; end of Submit_Changes_3___ActionSubmit()
		
		
		does_action_already_exist(action_type, action_path, action_arg:="") {
		global 
		
			;===========================================
			; return 0 if no Action matches this config
			;===========================================
			
			id_exists := 0
			
			for id, action in _ACTIONS 
			{
				aType := action["type"]
				aPath := action["path"]
				aArg  := action["arg"]
				
				if( aType == action_type 
				and aPath == action_path 
				and aArg  == action_arg ){
				
					id_exists := id 
					break
					
				}

			}
			
			return id_exists
		}
		
		Submit_Changes_3___CommandSubmit() {
		global 
		
			/*
				A_input_newAction_type       := ""     ; A ;     all pop.cmd (if tab 1)
				B_input_newAction_path       := ""     ; B ;     all pop.cmd (if tab 1)
				C_input_newAction_arg        := ""     ; C ;     all pop.cmd (if tab 1)
				
				D_input_oldAction_id         := ""     ; D ;     all pop.cmd (if tab 2)
				E_input_cmd_theCommand       := ""     ; E ;     all pop.cmd
				F_insertion_point_for_mainLV := ""     ; F ;   edit  pop.cmd
				
				TAB_cmd_tab_is_new_action    := ""     ; TAB ;   all pop.cmd
			*/
			
			mode    := GuiConfigPopup._popup_mode
			purpose := GuiConfigPopup._popup_purpose
			
			FAILURE := false
			SUCCESS := true
			
			is_action_new := false
			
			is_tab_1 := TAB_cmd_tab_is_new_action
			is_tab_2 := !TAB_cmd_tab_is_new_action
			
			popup_cmd        := E_input_cmd_theCommand
			popup_actionType := A_input_newAction_type
			popup_actionPath := B_input_newAction_path
			popup_actionArg  := C_input_newAction_arg
			
			popup_actionID   := ""
			   use_actionID   := ""
			
			original_command_name := GuiConfigMain._plucked_command["command"]
			
			
			;==============================================================
			; Determine Action ID 
			;   (if duplicate, use preexisting, don't make a new Action).
			;==============================================================
			
			;--------------------------------
			; Tab1 -> "Add New Action" tab.
			;
			if( is_tab_1 ){
				
				;--------------------------------------------------------`
				; Determine Action ID - New or use Preexisting
				;--------------------------------------------------------``
				;
				; If user is on the "Add New Action" tab
				; an unused ID will be assigned to the new Action.
				; 
				; However, if the entire "Add New Action" config 
				; matches an identical preexisting Action
				; that Action will be used instead of creating a new one.
				;                                                         ```
				use_actionID := _ACTIONS.Length()+1	
				
				duplicate_action_id_found := GuiConfigPopup.does_action_already_exist(""
					.   popup_actionType
					  , popup_actionPath
					  , popup_actionArg)
				
				if( duplicate_action_id_found ){
					use_actionID := duplicate_action_id_found
				}
				else{
				
					is_action_new := true
					
				}
			}		
			;---------------------------------------
			; Tab2 -> "Using Existing Action" tab.
			;
			else if( is_tab_2 ){
			
				;--------------------------------------------------
				; Determine Action ID -- use existing Action's ID
				;--------------------------------------------------
				;
				use_actionID := D_input_oldAction_id
			}
			
			
			;=============
			; Action ID 
			;=============
			
			popup_actionID   := use_actionID
			
			
			
			
			; msgbox popup_cmd[%popup_cmd%] path[%popup_actionPath%] type[%popup_actionType%] 
			
			
			
			
			;========================================================
			; Submit Command (new or modified):
			; to _COMMANDS array 
			;========================================================		
			
			;---------------------------------------------------------`
			; Assign a key value pair in _COMMANDS 
			;---------------------------------------------------------``
			;
			; If this is a new Command, 
			; then it has never been in _COMMANDS.
			;
			; If this is an existing Command being edited, 
			; then GuiConfigMain plucked it from _COMMANDS to 
			; simplify the code here.
			;
			; Key: 
			;        This Command's phrase
			;        (stored in popup_cmd)
			; Value:
			;        An associative array holding:
			;			Key:   "enabled" 
			;			Value: true or false 
			;                  (true if a new command,
			;                  otherwise we'll use its original state)
			;			Key:   "action_id" 
			;			Value: The integer ID for the Action
			;                  (currently stored in popup_actionID)
			;---------------------------------------------------------```
			
			cmd        := popup_cmd
			aID        := popup_actionID
			is_enabled := ("add"==purpose) 
							? "true" 
							: GuiConfigMain._plucked_command["enabled"]
							
							;------------------------------------------------------
							; AutoHotkey Docs, Ternary Operator: 
							; https://www.autohotkey.com/docs/Variables.htm#ternary
							;------------------------------------------------------
			
			
			_COMMANDS[cmd] := { "action_id":aID, "enabled":is_enabled }
			
			
			
			;===================================================
			; Submit Command (new or modified) 
			; to GuiConfigMain's Command ListView
			;===================================================
			
			;----------------------------------------------------------------
			; This label ensures the next AHK ListView function ("LV_...()")
			; will specifically use GuiConfigMain's ListView for Commands
			;----------------------------------------------------------------
			
			GuiConfigMain.ListViewCommands_Activate()
			
			; msgbox cmd submit: purpose is [%purpose%]
			
			if("add" == purpose){
				
				options := "+Check"
				LV_ADD( options      ; enable by default
					, popup_cmd			    ; row 1
					,                       ; row 2 is always empty
					, popup_actionID		; row 3
					, popup_actionType	    ; row 4
					, popup_actionPath	    ; row 5
					, popup_actionArg  )    ; row 6
				
			}
			else 
			if("edit" == purpose){
			
				;---------------------------------------------------------------------
				; Update the Command's entry in GuiConfigMain's ListView for Commands
				;---------------------------------------------------------------------
			
				modify_this_row := F_insertion_point_for_mainLV
				
				;[~]
				
				LV_MODIFY(modify_this_row
					,                     ; no options needed
					, popup_cmd			    ; row 1
					,                       ; row 2 is always empty
					, popup_actionID		; row 3
					, popup_actionType	    ; row 4
					, popup_actionPath	    ; row 5
					, popup_actionArg  )    ; row 6
					
				;----------------------------------------`
				; Remove backup of (now) edited command
				;----------------------------------------``
				; Making this variable empty will prevent 
				;
				;   GUI_EVENT_GuiConfigPopup_OnClose and
				;   GUI_EVENT_GuiConfigPopup_OnEscape
				;
				; from automatically restoring 
				; the old version of this Command
				;
				; when the GuiConfigPopup GUI is closed.
				;----------------------------------------```
				
				GuiConfigMain.Discard_Plucked_Command()
			}
			
			
			
			;========================================================
			; Add if Action is new:
			;
			;    Submit new Action to _ACTIONS array 
			;    Submit new Action to GuiConfigMain's Action ListView
			;    Submit new Action to Savefile
			;========================================================
				
			if( is_action_new ){
			
				;========================================
				; Submit Action 
				; to GuiConfigMain's Action ListView
				;========================================
				
				if( !_ACTIONS.HasKey(popup_actionID) ){
					
					_ACTIONS[popup_actionID] := {"type":popup_actionType
											   , "path":popup_actionPath
											   , "arg" :popup_actionArg  }
					
					GuiConfigMain.ListViewActions_AddNewAction(popup_actionID
						, popup_actionType
						, popup_actionPath
						, popup_actionArg)				
				}
				
				;========================================
				; Submit Action to Savefile 
				;========================================
				
				;-------------------------------------------------------------------
				; Syntax Reference
				;-------------------------------------------------------------------
				; class:    FILE_HELPER
				; function: Change_Savefile( p1,p2,p3,p4 )
				;
				; p1:  mode                      action|command
				; p2:  purpose                   add|delete|edit|enable|disable
				; p2:  action_id__or__cmd        new Action's ID 
				; p2:  cmd_name_before_rename    not applicable here
				;-------------------------------------------------------------------
				
				p1 := "action"
				p2 := "add" 
				p3 := popup_actionID
				p4 := ""
				savefile_updated := FILE_HELPER.Change_Savefile( p1,p2,p3,p4 )
				
				if( !savefile_updated ){
					MSGBOX, 16, ERROR WRITING NEW ACTION TO SAVEFILE, [~]
					return FAILURE
				}
				
				
			}
			
			
			;=======================================================================
			; Submit Command (new or modified)
			; to Savefile (all above operations were successful)
			;=======================================================================
			
			;-------------------------------------------------------------------
			; Syntax Reference
			;-------------------------------------------------------------------
			; class:    FILE_HELPER
			; function: Change_Savefile( p1,p2,p3,p4 )
			;
			; p1:  mode                      action|command
			; p2:  purpose                   add|delete|edit|enable|disable
			; p2:  action_id__or__cmd        updated text for Command
			; p2:  cmd_name_before_rename    old text before Command renamed
			;-------------------------------------------------------------------
			
			p1 := mode
			p2 := purpose 
			p3 := popup_cmd
			p4 := original_command_name
			savefile_updated := FILE_HELPER.Change_Savefile( p1,p2,p3,p4 )
				
			if( !savefile_updated ){
				MSGBOX, 16, ERROR WRITING COMMAND TO SAVEFILE, [~]
				return FAILURE
			}
			
			
			return SUCCESS
				
		} ; end of Submit_Changes_3___CommandSubmit()
		
		
		Submit_Changes_4____Finalize_And_Close() {
		global
			GuiConfigMain.ListViewActions_ReadjustAllCols()
			GuiConfigMain.ListViewCommands_ReadjustAllCols()
			
			GuiConfigPopup.GUI_EVENT_OnClose()
			return
		}


	;=======================================================================
	;         end of class:
	;         GuiConfigPopup (Popup from GuiConfigMain's first tab)
	;=======================================================================

	}



	class REUSABLE_GUI_CONTROLS {
	
		create_listview_of_actions( GuiName, GotoFuncOnEvent, ControlNameForLV ) {
		global 
			
			options := A_Space "g" GotoFuncOnEvent  ;"GuiConfigMain.GUI_EVENT_ListViewActions" 
			options .= A_Space "v" ControlNameForLV ;"GuiConfigMain_ListViewActions" 
			options .= A_Space "-checked +ReadOnly +AltSubmit -Multi" 
			options .= A_Space "r20 w700" 
			options .= A_Space "+LV0x10000" 
				; see: https://www.autohotkey.com/docs/misc/Styles.htm#ListView
			
			
			text_column1 := "Action ID"
			text_column2 := "|Action Type"
			text_column3 := "|Action Path"
			text_column4 := "|Action Arg for Programs"
			text := text_column1
										  .  text_column2
										  .  text_column3
										  .  text_column4
			
			Gui, %GuiName%:Add, ListView
				, %options%
				,    %text%
			
			
			
			Gui, %GuiName%:Default
			Gui, %GuiName%:ListView, %ControlNameForLV%
			
			for id, action in _ACTIONS {
				action_type := action["type"]
				action_path := action["path"]
				action_arg  := action["arg"]
				
				LV_Add(, id, action_type, action_path, action_arg )
				
			}
			
			return
		}
	
	}



	 









































