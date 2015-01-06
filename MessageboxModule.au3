	#include <WindowsConstants.au3>

	Global $MessageBoxGUI, $ID, $Info
	Dim $GetNumber[4000]

Opt("GUIOnEventMode", 1)

Func _StreamClickedMessageBox()
		$ID = @GUI_CtrlID
    $Info = GuiCtrlRead($ID, 1)
	$GetNumber = StringSplit($Info, ".")
	If StringLen($GetNumber[1]) < 3 Then
	$MessageBoxGUI = GuiCreate("", 320, 80, Default, Default, $WS_BORDER)
	$RunStreamButton = GuiCtrlCreateButton("Run Stream", 20, 15, 80,30)
	GuiCtrlSetOnEvent(-1, "_RunStream")
	$EditStreamButton = GuiCtrlCreateButton("Edit Stream", 120, 15, 80, 30)
	GuiCtrlSetOnEvent(-1, "_EditStreamClicked")
	$CancelStreamButton = GuiCtrlCreateButton("Cancel", 220, 15, 80, 30)
	GuiCtrlSetOnEvent(-1, "_CancelMessageBox")
	GuiSetState()
	Else
	MsgBox(48, "Error", "No stream added. Please use the 'Update Steamer' option under 'Options' to add a streamer to the list.")
	EndIf
EndFunc

Func _EditStreamClicked()
	_EditStream()
	GuiDelete($MessageBoxGUI)
EndFunc

Func _CancelMessageBox()
	GuiDelete($MessageBoxGUI)
EndFunc