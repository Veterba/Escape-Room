## Draws one of Root's windows (retexture spec, "Approved boss: Root"). A window opens and closes
## like on a desktop: it folds up to its title bar, then the bar shrinks to a dot. Its title bar
## can flash (a roar, or an error window about to shoot), and it turns white when hit.
## Used by Root and by its error windows.
class_name RootWindow

## Rows of the picture that stay when a window folds up: the outline and the title bar.
const TITLE_HEIGHT := 5.0
## The title bar inside the outline: where it starts, its height, and the close button's width
## at its right end, which a flash leaves alone.
const TITLE_BAR := Vector2(1, 1)
const TITLE_BAR_HEIGHT := 3.0
const CLOSE_BUTTON := 4.0
const FLASH_COLOR := Color("#ffd3da")
const OUTLINE := Color("#07060d")
## The last dot of a closing window shows below this much open.
const DOT_BELOW := 0.25


## Draws `texture` on `canvas` with its middle at `center`. `open` is 1 for a whole window, 0.5
## for only its title bar and 0 for nothing.
static func draw(canvas: CanvasItem, texture: Texture2D, center: Vector2, open: float, flash := false, white := false) -> void:
	if open <= 0.0:
		return
	var size := texture.get_size()
	var top_left := (center - size / 2.0).round()
	if open >= 1.0:
		if white:
			canvas.draw_rect(Rect2(top_left, size), OUTLINE)
			canvas.draw_rect(Rect2(top_left + Vector2.ONE, size - Vector2(2, 2)), Color.WHITE)
			return
		canvas.draw_texture(texture, top_left)
		if flash:
			canvas.draw_rect(Rect2(top_left + TITLE_BAR, Vector2(size.x - 2.0 - CLOSE_BUTTON, TITLE_BAR_HEIGHT)), FLASH_COLOR)
	elif open > 0.5:
		var height := maxf(TITLE_HEIGHT, roundf(TITLE_HEIGHT + (size.y - TITLE_HEIGHT) * (open - 0.5) * 2.0))
		canvas.draw_texture_rect_region(texture, Rect2(top_left, Vector2(size.x, TITLE_HEIGHT)), Rect2(0, 0, size.x, TITLE_HEIGHT))
		if height > TITLE_HEIGHT:
			canvas.draw_texture_rect_region(texture, Rect2(top_left + Vector2(0, TITLE_HEIGHT), Vector2(size.x, height - TITLE_HEIGHT)),
					Rect2(0, TITLE_HEIGHT, size.x, size.y - TITLE_HEIGHT))
	else:
		var width := maxf(2.0, roundf(size.x * open * 2.0))
		canvas.draw_texture_rect_region(texture, Rect2(Vector2(roundf(center.x - width / 2.0), top_left.y), Vector2(width, TITLE_HEIGHT)),
				Rect2(0, 0, size.x, TITLE_HEIGHT))
		if open < DOT_BELOW:
			canvas.draw_rect(Rect2(Vector2(roundf(center.x), top_left.y + 2.0), Vector2.ONE), Color.WHITE)


## How far `k` (0 to 1) has got from `start` to `end`, as 0 to 1: one step of an animation.
static func step(k: float, start: float, end: float) -> float:
	return clampf((k - start) / (end - start), 0.0, 1.0)
