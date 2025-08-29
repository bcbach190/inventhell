extends Control

@onready var username_field: LineEdit = $Background/LogInContainer/InputContainer/Username
@onready var email_field: LineEdit = $Background/LogInContainer/InputContainer/Email
@onready var password_field: LineEdit = $Background/LogInContainer/InputContainer/Password
@onready var confirm_field: LineEdit = $Background/LogInContainer/InputContainer/ConfirmPassword
@onready var create_button: Button = $Background/LogInContainer/InputContainer/CreateAccountButton
@onready var back_button: Button = $Background/LogInContainer/InputContainer/BackButton
@onready var signup_text: Label = $Background/LogInContainer/SignUpText

var config := ConfigFile.new()
const FILE_PATH := "user://players.cfg"

func _ready():
	# Enable password masking
	password_field.secret = true
	confirm_field.secret = true
	
	# Load or create config file
	var err = config.load(FILE_PATH)
	if err != OK:
		print("No config file found, creating new one.")
		config.save(FILE_PATH)
	
	# Connect signals
	create_button.pressed.connect(_on_CreateAccountBut_pressed)
	
	
	# Connect enter key submission
	username_field.text_submitted.connect(_on_enter_pressed)
	email_field.text_submitted.connect(_on_enter_pressed)
	password_field.text_submitted.connect(_on_enter_pressed)
	confirm_field.text_submitted.connect(_on_enter_pressed)

func _on_enter_pressed(_text = ""):
	_on_CreateAccountBut_pressed()

func show_error(message: String):
	signup_text.text = message
	signup_text.add_theme_color_override("font_color", Color.RED)

func show_success(message: String):
	signup_text.text = message
	signup_text.add_theme_color_override("font_color", Color.GREEN)

func clear_message():
	signup_text.text = ""
	signup_text.remove_theme_color_override("font_color")

func _on_CreateAccountBut_pressed():
	var username = username_field.text.strip_edges().to_upper()
	var email = email_field.text.strip_edges()
	var password = password_field.text
	var confirm = confirm_field.text

	# Clear previous messages
	clear_message()

	# Validation
	if username.is_empty() or email.is_empty() or password.is_empty() or confirm.is_empty():
		show_error("All fields are required.")
		return

	if username.length() < 3:
		show_error("Username must be at least 3 characters.")
		username_field.grab_focus()
		return

	if password.length() < 6:
		show_error("Password must be at least 6 characters.")
		password_field.grab_focus()
		return

	# Simple @ check for email
	if not "@" in email:
		show_error("Enter a valid email address.")
		email_field.grab_focus()
		return

	if password != confirm:
		show_error("Passwords do not match.")
		password_field.clear()
		confirm_field.clear()
		password_field.grab_focus()
		return

	if config.has_section_key("users", username):
		show_error("Username already exists.")
		username_field.grab_focus()
		return

	# Save new user (password + email)
	config.set_value("users", username, password.sha256_text())
	config.set_value("emails", username, email)
	
	var err = config.save(FILE_PATH)
	if err != OK:
		show_error("Failed to save account. Please try again.")
		return

	show_success("Account created! Returning to login...")
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://Scenes/log_in_page.tscn")

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/log_in_page.tscn")
