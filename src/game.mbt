let random : @random.Rand = @random.Rand::new()

let fruit : @wasm4.Sprite = @wasm4.sprite(
  b"\x00\xa0\x02\x00\x0e\xf0\x36\x5c\xd6\x57\xd5\x57\x35\x5c\x0f\xf0",
)

pub struct Game {
  snake : Snake
  mut frame_count : UInt
  mut prev_gamepad : @wasm4.GamePad
  mut fruit : Point
  mut game_over : Bool
}

pub fn Game::new() -> Game {
  {
    snake: Snake::new(),
    frame_count: 0,
    prev_gamepad: @wasm4.GamePad::default(),
    fruit: Point::{
      x: random.int(limit=21),
      y: random.int(limit=21),
    },
    game_over: false,
  }
}

pub fn update(self : Game) -> Unit {
  if self.game_over {
    self.show_game_over()
    return
  }

  self.frame_count += 1
  self.input()

  if self.frame_count % 15 == 0 {
    let dropped_pos = self.snake.update()
    if self.snake.is_dead() {
      self.game_over = true
      @wasm4.tone_note_mode(
        (@wasm4.Note::new(60, bend=0), None),
        @wasm4.ADSR::new(60),
        @wasm4.ADSRVolume::new(100),
        @wasm4.ToneFlag::new(), 
      )
      return
    }

    if self.snake.body.front() == Some(self.fruit) {
      match dropped_pos {
        Some(pos) => self.snake.body.push_back(pos)
        None => ()
      }
      self.fruit = Point::{
        x: random.int(limit=21),
        y: random.int(limit=21),
      }
    }
  }

  self.snake.draw()

  @wasm4.set_draw_colors(0, index=1)
  @wasm4.set_draw_colors(2, index=2)
  @wasm4.set_draw_colors(3, index=3)
  @wasm4.set_draw_colors(4, index=4)
  fruit.blit(
    self.fruit.x * 8,
    self.fruit.y * 8,
    8,
    8,
    { one_bit_per_pixel: false, flip_x: false, flip_y: false, rotate: false },
  )
}

pub fn input(self : Game) -> Unit {
  let gamepad = @wasm4.get_gamepad()
  if gamepad != self.prev_gamepad {
    if gamepad.button_up {
      self.snake.up()
    }
    if gamepad.button_down {
      self.snake.down()
    }
    if gamepad.button_left {
      self.snake.left()
    }
    if gamepad.button_right {
      self.snake.right()
    }
  }
  self.prev_gamepad = gamepad
}

pub fn show_game_over(self : Game) -> Unit {
  @wasm4.set_draw_colors(4, index=4)
  @wasm4.text("GAME OVER", 5, 70)
  @wasm4.text("Score:" + self.snake.body.length().to_string(), 5, 90)
  @wasm4.text("Press X to restart", 5, 110)

  // 检查是否按下 X 键重新开始游戏
  let gamepad = @wasm4.get_gamepad()
  if gamepad.button_1 {
    self.reset()
  }
}

pub fn reset(self : Game) -> Unit {
  self.snake.reset()
  self.fruit = Point::{
      x: random.int(limit=21),
      y: random.int(limit=21),
    }
  self.frame_count = 0
  self.game_over = false
}
