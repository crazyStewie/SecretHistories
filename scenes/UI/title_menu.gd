extends Control


func _ready():
	if LoadQuotes.list2.empty() and LoadQuotes.list1.empty():
		LoadQuotes.load_files()

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$VBoxContainer/ContinueButton.grab_focus()
	
	if !BackgroundMusic.is_playing():
		BackgroundMusic.play()


func _input(event):
	if event.is_action_pressed("fullscreen"):
		VideoSettings.set_fullscreen_enabled(!VideoSettings.is_fullscreen_enabled())


func _on_ContinueButton_pressed():
	pass   # Replace with function body once save/load implemented.


#needs work
func _on_StartButton_pressed():
#	get_parent().title_menu_active = false    #doesn't work this stuff
	var _error = get_tree().change_scene("res://scenes/UI/start_game_menu.tscn")


func _on_SettingsButton_pressed():
	$"%SettingsMenu".show()


func _on_CreditsButton_pressed():
	pass   # Replace with function body once Credits screen implemented.


func _on_QuitButton_pressed():
	get_tree().quit()
