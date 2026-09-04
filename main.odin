package main

import "core:fmt"

main :: proc() {
	fmt.printfln("hellope")
}

// The Board stores the maze in a graph. Each elememt is bit packed 4 bit integer. 
Board :: struct {
	height: int,
	width: int,
	vec: [dynamic]int
}

Directions :: enum {
	Right,
	Up,
	Left,
	Down,
}

init_board :: proc(height, width: int) -> Board {
	board := Board{ height, width, make([dynamic]int, height * width)}
	return board
}

get_at_board :: proc(board: ^Board, x: int, y: int) -> (int, bool) {
	if x < 0 || x >= board.width || y < 0 || y >= board.height {
		return 0, true
	}
	return board.vec[x + (y * board.width)], false
}
