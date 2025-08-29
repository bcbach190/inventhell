extends Control

@onready var username_field: LineEdit = $Background/LogInContainer/FieldContainer/Username
@onready var password_field: LineEdit = $Background/LogInContainer/FieldContainer/Password
@onready var login_button: Button = $Background/LogInContainer/ButtonContainer/LogInButton
@onready var login_text: Label = $Background/WarningText
@onready var sign_up_button: Button = $Background/LogInContainer/ButtonContainer/SignInButton


var config := ConfigFile.new()
const FILE_PATH := "user://players.cfg"
var login_attempts := 0
var max_attempts := 5
var last_attempt_time := 0.0

func _ready():
	# Check if all required nodes exist
	if not all_nodes_valid():
		return
	
	# Enable password masking
	password_field.secret = true

	# Load or create config file
	load_config()

	# Connect signals
	login_button.pressed.connect(_on_login_button_pressed)
	sign_up_button.pressed.connect(_on_sign_up_button_pressed)
	username_field.focus_entered.connect(_on_username_focus)
	password_field.focus_entered.connect(_on_password_focus)
	username_field.text_submitted.connect(_on_enter_pressed)
	password_field.text_submitted.connect(_on_enter_pressed)

func all_nodes_valid():
	var valid = true
	if password_field == null:
		push_error("Password field is null — check node path.")
		valid = false
	if username_field == null:
		push_error("Username field is null — check node path.")
		valid = false
	if login_button == null:
		push_error("Login button is null — check node path.")
		valid = false
	if sign_up_button == null:
		push_error("Sign up button is null — check node path.")
		valid = false
	if login_text == null:
		push_error("Warning text label is null — check node path.")
		valid = false
	return valid

func load_config():
	var err = config.load(FILE_PATH)
	if err != OK:
		print("No config file found. Creating a new one.")
		config.set_value("settings", "version", "1.0")
		save_config()

func save_config():
	var err = config.save(FILE_PATH)
	if err != OK:
		push_error("Failed to save config file: " + str(err))

func _on_username_focus():
	if username_field.text == "Username":
		username_field.clear()

func _on_password_focus():
	if password_field.text == "Password":
		password_field.clear()

func _on_enter_pressed(_text = ""):
	_on_login_button_pressed()

func show_error(message: String):
	login_text.text = message
	login_text.add_theme_color_override("font_color", Color.RED)

func show_success(message: String):
	login_text.text = message
	login_text.add_theme_color_override("font_color", Color.GREEN)

func show_info(message: String):
	login_text.text = message
	login_text.add_theme_color_override("font_color", Color.WHITE)

func clear_message():
	login_text.text = ""
	login_text.remove_theme_color_override("font_color")

func _on_login_button_pressed():
	# Rate limiting
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_attempt_time < 1.0:
		return
	if login_attempts >= max_attempts:
		show_error("Too many failed attempts. Please wait.")
		return
	
	# Disable buttons during processing
	login_button.disabled = true
	sign_up_button.disabled = true
	var original_text = login_button.text
	login_button.text = "Logging in..."
	
	var username = username_field.text.strip_edges().to_upper()
	var password = password_field.text

	# Clear previous messages
	clear_message()
	
	# Validation
	if username.is_empty() and password.is_empty():
		show_error("Please enter username and password.")
		username_field.grab_focus()
		reset_buttons(original_text)
		return
	elif username.is_empty():
		show_error("Please enter username.")
		username_field.grab_focus()
		reset_buttons(original_text)
		return
	elif password.is_empty():
		show_error("Please enter password.")
		password_field.grab_focus()
		reset_buttons(original_text)
		return
	
	if username.length() < 3:
		show_error("Username must be at least 3 characters.")
		username_field.grab_focus()
		reset_buttons(original_text)
		return
	
	if password.length() < 6:
		show_error("Password must be at least 6 characters.")
		password_field.grab_focus()
		reset_buttons(original_text)
		return

	if not config.has_section_key("users", username):
		show_error("No account found.")
		login_attempts += 1
		reset_buttons(original_text)
		return

	var saved_hash = config.get_value("users", username)
	if saved_hash == password.sha256_text():
		show_success("Login successful!")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://Scenes/home_page.tscn")
	else:
		show_error("Incorrect password.")
		login_attempts += 1
		reset_buttons(original_text)

func reset_buttons(original_text: String):
	login_button.disabled = false
	sign_up_button.disabled = false
	login_button.text = original_text
	last_attempt_time = Time.get_unix_time_from_system()

func _on_sign_up_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/sign_up_page.tscn")



	
