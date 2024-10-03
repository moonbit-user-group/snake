let game : Game = Game::new()

pub fn start() -> Unit {
  @wasm4.set_palette(1, @wasm4.rgb(0xfbf7f3))
  @wasm4.set_palette(2, @wasm4.rgb(0xe5b083))
  @wasm4.set_palette(3, @wasm4.rgb(0x426e5d))
  @wasm4.set_palette(4, @wasm4.rgb(0x20283d))
}

pub fn upd() -> Unit {
  game.update()
}
