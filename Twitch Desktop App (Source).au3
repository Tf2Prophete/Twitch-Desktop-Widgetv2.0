#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Data\Icon.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Res_Fileversion=2.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=R.S.S.
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Add_Constants=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;~ #AutoIt3Wrapper_Icon=Images\Icon.ico

#include ".\Skins\Hex.au3"
#include "_UskinLibrary.au3"
#include "MessageboxModule.au3"

#Include <WinAPI.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Timers.au3>


_Uskin_LoadDLL()
_USkin_Init(_Hex(True))

Opt("GUIOnEventMode", 1)
Opt("TrayMenuMode", 3)
Opt("TrayOnEventMode", 1)

TrayCreateItem("Exit..")
TrayItemSetOnEvent(-1, "_Exit")
TrayCreateItem("Update..")
TrayItemSetOnEvent(-1, "_Update")

Global $MainGui, $CurrentGui, $PositionGui, $OptionsGui, $UpdateButton, $UpdatingButton, $CurrentStreams = 1
Global $MessageBoxGUI

Global $OnlineColor = "0x00FF3C", $OfflineColor = "0xFF0000"

Dim $StreamerButton[30]

Global $h_Desktop_SysListView32
_GetDesktopHandle()

$Width = @DesktopWidth
$Height = @DesktopHeight

$CheckFirstRun = IniRead(@ScriptDir & "/Data/Preferences.ini", "Settings", "FirstRun", "NA")
If $CheckFirstRun = "0" Then
	MsgBox(0, "Welcome", "Welcome to the Twitch Desktop App. This program will help let you know when a streamer is online quickly!")
	MsgBox(0, "Welcome", "You can set various options on it which can all be found in the help file!")
	MsgBox(0, "Welcome", "But first, we must set the position of the window that you will be using!")
	IniWrite(@ScriptDir & "/Data/Preferences.ini", "Settings", "FirstRun", "1")
	_CreatePositionGui()
Else
_CreateMainGui()
EndIf


Func _CreatePositionGui()
	GuiDelete($MainGui)
	$CurrentGui = "PositionGui"
	$PositionGui = GUICreate("Position GUI", 200, 440, Default, Default, Default, Default, WinGetHandle(AutoItWinGetTitle()))
	GuiSetFont(13)
    GUICtrlSetDefColor(0xFFFFFF)
    GUISetBkColor(0x000000)
    WinSetTrans($PositionGui,"",200)
	$SavePositionButton = GuiCtrlCreateButton("Set Positioning", 40, 160, 120,30)
	GUICtrlSetOnEvent(-1, "_SavePosition")
    GuiSetState()
	DllCall("user32.dll", "hwnd", "SetParent", "hwnd", $PositionGUI, "hwnd", $h_Desktop_SysListView32)
	MsgBox(0, "Positioning..", "Please move the window to where you would like it to reside then press the 'Set Positioning' button")
EndFunc

Func _SavePosition()
	$PositionToSave = WinGetPos("Position GUI")
	IniWrite(@ScriptDir & "/Data/Preferences.ini", "Position", "X", $PositionToSave[0])
	IniWrite(@ScriptDir & "/Data/Preferences.ini", "Position", "Y", $PositionToSave[1])
	GuiDelete($PositionGui)
	_CreateMainGui()
EndFunc

Func _CreateMainGui()
	$Y = 20
	$Count = 1
	$XPos = IniRead(@ScriptDir & "/Data/Preferences.ini", "Position", "X", "NA")
	$YPos = IniRead(@ScriptDir & "/Data/Preferences.ini", "Position", "Y", "NA")
	$CurrentGui = "MainGUI"
	$MainGui = GUICreate("", 200, 440, $XPos, $YPos, BitOR($WS_POPUP,$WS_BORDER), Default, WinGetHandle(AutoItWinGetTitle()))
	GuiSetFont(13)
    GUISetBkColor(0x000000)
	For $i = 1 To 20
		If $Count = 6 Then
			$Y = 20
			$Count = 1
		EndIf
	$StreamerButton[$i] = GuiCtrlCreateButton("", 20, $Y, 160,30)
	$Y += 45
	$Count += 1
	GuiCtrlSetOnEvent(-1, "_StreamClickedMessageBox")
	Next
	$Streams = IniReadSection(@ScriptDir & "/Data/Preferences.ini", "Streams")
	For $i = 1 To 20
		$SplitData = StringSplit($Streams[$i][1], "|")
		If $SplitData[0] > 1 Then
		GuiCtrlSetData($StreamerButton[$i], $i & ". " & $SplitData[1])
		GuiCtrlSetColor($StreamerButton[$i], $OfflineColor)
		GUICtrlSetBkColor($StreamerButton[$i], 0x000000)
	Else
		GuiCtrlSetData($StreamerButton[$i], "Streamer " & $i)
		GuiCtrlSetColor($StreamerButton[$i], $OfflineColor)
		GUICtrlSetBkColor($StreamerButton[$i], 0x000000)
	EndIf
Next
For $i = 6 To 20
	GuiCtrlSetState($StreamerButton[$i], $GUI_HIDE)
Next

	$NextButton = GuiCtrlCreateButton("Next", 110, 255, 80,30)
	GUICtrlSetColor($NextButton, 0xEFFF00)
	GUICtrlSetBkColor($NextButton, 0x000000)
	GUICtrlSetOnEvent(-1, "_Next")
	$PreviousButton = GuiCtrlCreateButton("Previous", 10, 255, 80,30)
	GUICtrlSetColor($PreviousButton, 0xEFFF00)
	GUICtrlSetBkColor($PreviousButton, 0x000000)
	GUICtrlSetOnEvent(-1, "_Previous")
	$OptionsButton = GuiCtrlCreateButton("Options", 50, 300, 100,30)
	GUICtrlSetColor($OptionsButton, 0xEFFF00)
	GUICtrlSetBkColor($OptionsButton, 0x000000)
	GUICtrlSetOnEvent(-1, "_CreateOptionsGui")
	$RepositionButton = GuiCtrlCreateButton("Reposition", 50, 345, 100,30)
	GUICtrlSetColor($RepositionButton, 0xEFFF00)
	GUICtrlSetBkColor($RepositionButton, 0x000000)
	GUICtrlSetOnEvent(-1, "_CreatePositionGui")
	$UpdateButton = GuiCtrlCreateButton("Update", 50, 390, 100,30)
	GUICtrlSetColor($UpdateButton, 0xEFFF00)
	GUICtrlSetBkColor($UpdateButton, 0x000000)
	GUICtrlSetOnEvent(-1, "_Update")
	$UpdatingButton = GuiCtrlCreateButton("Updating..", 50, 390, 100,30)
	GUICtrlSetColor($UpdatingButton, $OnlineColor)
	GUICtrlSetBkColor($UpdatingButton, 0x000000)
	GUiCtrlSetState(-1, $GUI_HIDE)
	WinSetTrans($MainGui,"",200)
	GuiCtrlCreateLabel("Prophete's Twitch Widget v2.0", 30, 0, 200, 15)
	GuiCtrlSetColor(-1, $OfflineColor)
	GuiCtrlSetFont(-1, 8)
	GuiCtrlCreateLabel("An R.S.S. Production ©2014", 53, 425, 200, 20)
		GuiCtrlSetColor(-1, $OfflineColor)
	GuiCtrlSetFont(-1, 6)
    GuiSetState()
	_Update()
	DllCall("user32.dll", "hwnd", "SetParent", "hwnd", $MainGUI, "hwnd", $h_Desktop_SysListView32)
EndFunc

Func _Next()
	If $CurrentStreams = 1 Then
		For $i = 1 To 5
			GuiCtrlSetState($StreamerButton[$i], $GUI_HIDE)
		Next
		For $i = 6 To 10
			GuiCtrlSetState($StreamerButton[$i], $GUI_SHOW)
		Next
		$CurrentStreams = 2
	ElseIf $CurrentStreams = 2 Then
		For $i = 6 To 10
			GuiCtrlSetState($StreamerButton[$i], $GUI_HIDE)
		Next
		For $i = 11 To 15
			GuiCtrlSetState($StreamerButton[$i], $GUI_SHOW)
		Next
		$CurrentStreams = 3
	ElseIf $CurrentStreams = 3 Then
		For $i = 11 To 15
			GuiCtrlSetState($StreamerButton[$i], $GUI_HIDE)
		Next
		For $i = 16 To 20
			GuiCtrlSetState($StreamerButton[$i], $GUI_SHOW)
		Next
		$CurrentStreams = 4
	ElseIf $CurrentStreams = 4 Then
		For $i = 16 To 20
			GuiCtrlSetState($StreamerButton[$i], $GUI_HIDE)
		Next
		For $i = 1 To 5
			GuiCtrlSetState($StreamerButton[$i], $GUI_SHOW)
		Next
		$CurrentStreams = 1
	EndIf
EndFunc

Func _Previous()
	If $CurrentStreams = 1 Then
		For $i = 16 To 20
			GuiCtrlSetState($StreamerButton[$i], $GUI_SHOW)
		Next
		For $i = 1 To 5
			GuiCtrlSetState($StreamerButton[$i], $GUI_HIDE)
		Next
		$CurrentStreams = 4
	ElseIf $CurrentStreams = 2 Then
		For $i = 1 To 5
			GuiCtrlSetState($StreamerButton[$i], $GUI_SHOW)
		Next
		For $i = 6 To 10
			GuiCtrlSetState($StreamerButton[$i], $GUI_HIDE)
		Next
		$CurrentStreams = 1
	ElseIf $CurrentStreams = 3 Then
		For $i = 6 To 10
			GuiCtrlSetState($StreamerButton[$i], $GUI_SHOW)
		Next
		For $i = 11 To 15
			GuiCtrlSetState($StreamerButton[$i], $GUI_HIDE)
		Next
		$CurrentStreams = 2
	ElseIf $CurrentStreams = 4 Then
		For $i = 11 To 15
			GuiCtrlSetState($StreamerButton[$i], $GUI_SHOW)
		Next
		For $i = 16 To 20
			GuiCtrlSetState($StreamerButton[$i], $GUI_HIDE)
		Next
		$CurrentStreams = 3
	EndIf
EndFunc

Func _SetTimer()
	$TimerSet = 0
	$TimerVar = 0
	$CheckTimer = IniRead(@ScriptDir & "/Data/Preferences.ini", "Settings", "AutomaticUpdate", "NA")
If $CheckTimer = 1 Then
	$TimerVar = IniRead(@ScriptDir & "/Data/Preferences.ini", "Settings", "UpdateTime", "NA")
	For $i = 1 To $TimerVar
		$TimerSet += 60000
	Next
	AdlibRegister("_Update", $TimerSet)
EndIf
EndFunc

Func _CreateOptionsGui()
	GuiSetState(@SW_DISABLE, $MainGui)
	$CurrentGui = "OptionsGui"
	$OptionsGui = GuiCreate("Options", 300, 200)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
	GuiSetFont(13)
	$ManualUpdateButton = GuiCtrlCreateButton("Manual Update", 55, 25, 180, 30)
	GUICtrlSetOnEvent(-1, "_ManualUpdateSet")
	$AutomaticUpdateButton = GuiCtrlCreateButton("Automatic Update", 55, 65, 180, 30)
	GUICtrlSetOnEvent(-1, "_AutomaticUpdateSet")
	$NewUserButton = GuiCtrlCreateButton("Update Streamer", 55, 105, 180, 30)
	GUICtrlSetOnEvent(-1, "_UpdateStreamer")
	$ChangeTimerButton = GuiCtrlCreateButton("Change Update Timer", 55, 145, 180, 30)
	GuiCtrlSetOnEvent(-1, "_ChangeUpdateTimer")
	GuiSetState()
EndFunc

Func _ChangeUpdateTimer()
	$NewTimer = InputBox("Timer Update", "How many minutes would you like to pass before the Twitch Desktop App checks for live streams? Please enter a time of 1-60 (1 being 1 minute ect.)")
	If $NewTimer > "" Then
		If $NewTimer < 60 Then
			If StringIsAlNum($NewTimer) Then
		IniWrite(@ScriptDir & "/Data/Preferences.ini", "Settings", "UpdateTime", $NewTimer)
	EndIf
		EndIf
	Else
		MsgBox(48, "Error", "No time input, please try again.")
	EndIf
	$NewTimer = ""
EndFunc

Func _UpdateStreamer()
	$CurrentGui = "MainGui"
	GuiDelete($OptionsGui)
	$GetNumber = InputBox("Stream Update", "Please input a number 1-20 according to the number of the stream button you want to update. 1 being the top most button")
	If $GetNumber > "" Then
		If $GetNumber > 20 Then
			MsgBox(48, "Error", "You have input an incorrect number. Please try again.")
		Else
			$InputName = InputBox("Stream Update", "Please input the name you wish to show on the button.")
			$InputLink = InputBox("Stream Update", "Please input the link to the Twitch.tv stream you wish to associate with this button.")
			$Split = StringSplit($InputLink, "tv/", 1)
			If $Split[1] = "http://twitch." OR "www.twitch." Then
			$CheckSave = MsgBox(4, "Stream Update", "Is this information correct?" & @CRLF & @CRLF & "Stream Number: " & $GetNumber & @CRLF & "Stream Name: " & $InputName & @CRLF & "Stream Link: " & $InputLink)
			If $CheckSave = 6 Then
				IniWrite(@ScriptDir & "/Data/Preferences.ini", "Streams", $GetNumber, $InputName & "|" & "https://api.twitch.tv/kraken/streams/" & $Split[2] & "|" & "0")
			EndIf
		Else
			MsgBox(48, "Error", "Stream link invalid. Please go to Twitch.tv in a web browser and copy/paste the link of the stream to which you wish to use.")
		EndIf
EndIf
	EndIf
	GuiDelete($MainGui)
	_CreateMainGUI()
EndFunc

Func _ManualUpdateSet()
	MsgBox(0, "Options..", "Manual updates have been set. Please use the 'Update' button on the window to check stream activity.")
	IniWrite(@ScriptDir & "/Data/Preferences.ini", "Settings", "ManualUpdate", "1")
	IniWrite(@ScriptDir & "/Data/Preferences.ini", "Settings", "AutomaticUpdate", "0")
EndFunc

Func _AutomaticUpdateSet()
	MsgBox(0, "Options..", "Automatic updates have been set. Please refer to the 'Change Update Timer' button to check or change the time inbetween checking of streams.")
	IniWrite(@ScriptDir & "/Data/Preferences.ini", "Settings", "ManualUpdate", "0")
	IniWrite(@ScriptDir & "/Data/Preferences.ini", "Settings", "AutomaticUpdate", "1")
EndFunc

Func _Update()
	GuiCtrlSetState($UpdateButton, $GUI_HIDE)
	GuiCtrlSetState($UpdatingButton, $GUI_SHOW)
	$StreamData = IniReadSection(@ScriptDir & "/Data/Preferences.ini", "Streams")
	For $i = 1 To $StreamData[0][0]
		If StringInStr($StreamData[$i][1], "|") Then
		$SplitData = StringSplit($StreamData[$i][1], "|")
		$Url = $SplitData[2]
		$sSource = BinaryToString(InetRead($Url))
		If StringInStr($sSource, '"stream":null') Then
			IniWrite(@ScriptDir & "/Data/Preferences.ini", "Streams", $StreamData[$i][0], $SplitData[1] & "|" & $SplitData[2] & "|" & "0")
			GuiCtrlSetColor($StreamerButton[$i], $OfflineColor)
		Else
			IniWrite(@ScriptDir & "/Data/Preferences.ini", "Streams", $StreamData[$i][0], $SplitData[1] & "|" & $SplitData[2] & "|" & "1")
			GuiCtrlSetColor($StreamerButton[$i], $OnlineColor)
		EndIf
	Else
		Sleep(10)
	EndIf
	Next
		$CheckTimer = IniRead(@ScriptDir & "/Data/Preferences.ini", "Settings", "AutomaticUpdate", "NA")
	If $CheckTimer = 1 Then
		_SetTimer()
	EndIf
	Sleep(1000)
	GUiCtrlSetState($UpdatingButton, $GUI_HIDE)
	GUiCtrlSetState($UpdateButton, $GUI_SHOW)
EndFunc


Func _Exit()
	If $CurrentGui = "MainGui" Then
	Exit
ElseIf $CurrentGui = "OptionsGui" Then
	$CurrentGui = "MainGui"
	GuiDelete($OptionsGui)
	GuiSetState(@SW_ENABLE, $MainGui)
	WinActivate($MainGui)
EndIf
EndFunc

Func _RunStream()
	$CheckRun = MsgBox(4, "Run Stream..", "Are you sure you wish to run the stream of " & $GetNumber[2] & "?")
	If $CheckRun = 6 Then
	$CheckStream = IniRead(@ScriptDir & "/Data/Preferences.ini", "Streams", $GetNumber[1], "NA")
	If StringInStr($CheckStream, "|") Then
	$CheckRunMethod = InputBox("Run Stream", "Would you like to open this stream in a web browser or use LiveStreamer?" & @CRLF & @CRLF & "1 = Web" & @CRLF & "2 = LiveStreamer")
	If $CheckRunMethod = "" Then
		Sleep(10)
	ElseIf $CheckRunMethod = 1 Then
		$StreamData = IniRead(@ScriptDir & "/Data/Preferences.ini", "Streams", $GetNumber[1], "NA")
		$SplitData = StringSplit($StreamData, "|")
		$Split = StringSplit($SplitData[2], "streams/", 1)
		ShellExecute("http://www.twitch.tv/" & $Split[2])
	ElseIf $CheckRunMethod = 2 Then
		$CheckQuality = InputBox("LiveStreamer", "What quality would you like to run this stream at?" & @CRLF & @CRLF & "1 = Mobile" & @CRLF & "2 = Medium" & @CRLF & "3 = High" & @CRLF & "4 = Source")
		If $CheckQuality = "" Then
			Sleep(10)
		Else
			If $CheckQuality < 5 Then
			If $CheckQuality = 1 Then
				$Quality = "Mobile"
			ElseIf $CheckQuality = 2 Then
				$Quality = "Medium"
			ElseIf $CheckQuality = 3 Then
				$Quality = "High"
			ElseIf $CheckQuality = 4 Then
				$Quality = "Source"
			EndIf
		EndIf
		$StreamData = IniRead(@ScriptDir & "/Data/Preferences.ini", "Streams", $GetNumber[1], "NA")
		$SplitData = StringSplit($StreamData, "|")
		$Split = StringSplit($SplitData[2], "streams/", 1)
		Run("livestreamer " & "http://twitch.tv/" & $Split[2] & " " & $Quality)
	EndIf
EndIf
	$CheckRunMethod = ""
	$CheckQuality = ""
Else
	MsgBox(48, "Error", "Error running stream. Please double check your stream link and or name.")
EndIf
GuiDelete($MessageBoxGUI)
Else
	Sleep(10)
EndIf
EndFunc

FUnc _EditStream()
	$CheckRun = MsgBox(4, "Edit Stream..", "Are you sure you wish to edit the stream of " & $GetNumber[2] & "?")
	If $CheckRun = 6 Then
		$StreamData = IniRead(@ScriptDir & "/Data/Preferences.ini", "Streams", $GetNumber[1], "NA")
			$InputName = InputBox("Stream Update", "Please input the name you wish to show on the button.")
			$InputLink = InputBox("Stream Update", "Please input the link to the Twitch.tv stream you wish to associate with this button.")
			$Split = StringSplit($InputLink, "tv/", 1)
			If $Split[1] = "http://twitch." OR "www.twitch." Then
			$CheckSave = MsgBox(4, "Stream Update", "Is this information correct?" & @CRLF & @CRLF & "Stream Number: " & $GetNumber & @CRLF & "Stream Name: " & $InputName & @CRLF & "Stream Link: " & $InputLink)
			If $CheckSave = 6 Then
				IniWrite(@ScriptDir & "/Data/Preferences.ini", "Streams", $GetNumber[1], $InputName & "|" & "https://api.twitch.tv/kraken/streams/" & $Split[2] & "|" & "0")
				GuiDelete($MainGui)
				_CreateMainGui()
			EndIf
		Else
			MsgBox(48, "Error", "Stream link invalid. Please go to Twitch.tv in a web browser and copy/paste the link of the stream to which you wish to use.")
		EndIf
	EndIf
	EndFunc

Func _MessageBox()
	$MessageBoxGUI = GuiCreate("Message Box", 140, 30)
	$RunStreamButton = GuiCtrlCreateButton("Run Stream", 20, 10, 120,20)
	$EditStreamButton = GuiCtrlCreateButton("Edit Stream", 60, 10, 120, 20)
	$CancelStreamButton = GuiCtrlCreateButton("Cancel", 100, 10, 120, 20)
	GuiSetState()
EndFunc


While 1
	Sleep(10)
WEnd


Func _GetDesktopHandle()
    $h_Desktop_SysListView32 = 0

    Local Const $hDwmApiDll = DllOpen("dwmapi.dll")
    Local $sChkAero = DllStructCreate("int;")
    DllCall($hDwmApiDll, "int", "DwmIsCompositionEnabled", "ptr", DllStructGetPtr($sChkAero))
    Local $aero_on = DllStructGetData($sChkAero, 1)

    If Not $aero_on Then
        $h_Desktop_SysListView32 = WinGetHandle("Program Manager")
        Return 1
    Else
        Local $hCBReg = DllCallbackRegister("_GetDesktopHandle_EnumChildWinProc", "hwnd", "hwnd;lparam")
        If $hCBReg = 0 Then Return SetError(2)
        DllCall("user32.dll", "int", "EnumChildWindows", "hwnd", _WinAPI_GetDesktopWindow(), "ptr", DllCallbackGetPtr($hCBReg), "lparam", 101)
        Local $iErr = @error
        DllCallbackFree($hCBReg)
        If $iErr Then
            Return SetError(3, $iErr, "")
        EndIf
        Return 2
    EndIf
EndFunc