package main

import "core:fmt"
import "core:unicode/utf8"
import "core:strings"

main :: proc() {
	fmt.printfln("hellope")
	height := 8
	width := 8
	board := init_board(height, width)
	print_board(&board)
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

get_mask ::proc(dir: Directions) -> int {
	mask: int;
	switch dir {
		case .Right:
			mask = 0b0001
		case .Up:
			mask = 0b0010
		case .Left:
			mask = 0b0100
		case .Down:
			mask = 0b1000
	}
	return mask
}

has_direction :: proc(val: int, dir: Directions) -> bool {
	mask := get_mask(dir)
	masked_bit := mask & val
	return masked_bit != 0
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

PrintBufferCustom :: struct {
	cell_height, cell_width: int,
	new_line: int,
	buff_height, buff_width: int,
	buff: [dynamic]rune,
}

init_print_buff :: proc(board: ^Board) -> PrintBufferCustom {
	cell_height := 3
	cell_width := 6
	new_line := 1
	buff_width := (cell_width * board.width + new_line)
	buff_height := cell_height * board.height
	buff_size := buff_width * buff_height
	buff := make([dynamic]rune, buff_size)
	return PrintBufferCustom { cell_height, cell_width, new_line, buff_height, buff_width, buff }
}

draw_cell_at_buffer :: proc(print_buff: ^PrintBufferCustom, board: ^Board, x, y: int) {
	buff_idx := x * print_buff.cell_width + (y * print_buff.cell_height) * print_buff.buff_width
	val, _ := get_at_board(board, x, y)
	// to_print := "███▀ ▄▀ ▄▀ ▄▀ ▄███"
	left_wall := [3]rune{'█', '█', '█'};
	right_wall := [3]rune{'█', '█', '█'};
	up_wall_char := '▀';
	down_wall_char := '▄';
	centre_char := ' '
	if has_direction(val, .Right) {
		right_wall = "▀ ▄"
	}
	if has_direction(val, .Left) {
		left_wall = "▀ ▄"
	}
	if has_direction(val, .Up) {
		up_wall_char = ' '
	}
	if has_direction(val, .Down) {
		down_wall_char = ' '
	}
	mid := [3]rune{up_wall_char, centre_char, down_wall_char}
	to_print: [dynamic]rune
	append(&to_print, ..left_wall[:])
	for _ in 1..<(print_buff.cell_width-1) {
		append(&to_print, ..mid[:])
	}
	append(&to_print, ..right_wall[:])
	idx := 0
	for off_x in 0..<print_buff.cell_width {
		for off_y in 0..<print_buff.cell_height {
			offset_idx := off_x + off_y * print_buff.buff_width
			print_buff.buff[buff_idx + offset_idx] = to_print[idx]
			idx += 1
		}
	}
}

add_new_line :: proc(print_buff: ^PrintBufferCustom, board: ^Board) {
	idx := print_buff.buff_width -1
	for _ in 0..<print_buff.buff_height {
		print_buff.buff[idx] = '\n'
		idx += print_buff.buff_width
	}
}

print_board :: proc(board: ^Board) {
	print_buff := init_print_buff(board)
	for x in 0..<board.width {
		for y in 0..<board.height {
			draw_cell_at_buffer(&print_buff, board, x, y)
		}
	}
	add_new_line(&print_buff, board)
	fmt.printf("%s", print_buff.buff[:])
}
