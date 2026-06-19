extends Control

@onready var bookMohito: Sprite2D = %BookMohito;
@onready var bookDaikiri: Sprite2D = %BookDaikiri;
@onready var bookAnanaslimonad: Sprite2D = %BookAnanaslimonad;
@onready var bookBauntibriz: Sprite2D = %BookBauntibriz;
@onready var bookPinocolada: Sprite2D = %BookPinocolada;
@onready var bookAnimSprite: AnimatedSprite2D = %BookAnimSprite;
@onready var subViewportContainer: SubViewportContainer = %SubViewportContainer;
var books: Array[Sprite2D];
var currentIndex = 0;

func _ready() -> void:
	subViewportContainer.gui_input.connect(_onGuiInput);
	books = [bookMohito, bookDaikiri, bookAnanaslimonad, bookBauntibriz, bookPinocolada];

func _onGuiInput(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		nextBook();

func nextBook():
	clearBook();
	currentIndex += 1;
	if(currentIndex >= books.size()):
		currentIndex = 0;
	bookAnimSprite.play("changePage");
	bookAnimSprite.animation_finished.connect(func(): books[currentIndex].show(), CONNECT_ONE_SHOT);

func prevBook():
	clearBook();
	currentIndex -= 1;
	if(currentIndex <= -1):
		currentIndex = books.size() - 1;
	bookAnimSprite.play("changePage");
	bookAnimSprite.animation_finished.connect(func(): books[currentIndex].show(), CONNECT_ONE_SHOT);


func clearBook():
	for book in books:
		book.hide();
