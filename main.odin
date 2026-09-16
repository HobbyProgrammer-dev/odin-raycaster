package main

import "core:fmt"

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
	Right = 0b0001,
	Up    = 0b0010,
	Left  = 0b0100,
	Down  = 0b1000,
}

has_direction :: proc(val: int, dir: Directions) -> bool {
	mask := int(dir)
	masked_bit := mask & val
	return masked_bit != 0
}

init_board :: proc(height, width: int) -> Board {
	board := Board{ height, width, make([dynamic]int, height * width)}
	return board
}

get_at_board :: proc(board: ^Board, x: int, y: int) -> (int, bool) {
	if x < 0 || x >= board.width || y < 0 || y >= board.height {
		return 0, false
	}
	return board.vec[x + (y * board.width)], true
}

PrintBufferCustom :: struct {
	cell_height, cell_width: int,
	new_line: int,
	buff_height, buff_width: int,
	buff: [dynamic]rune,
}

init_print_buff :: proc(board: ^Board, cell_size: int) -> (PrintBufferCustom, bool) {
	if cell_size  < 2 {
		return PrintBufferCustom {}, false
	}
	cell_height := cell_size
	cell_width := cell_size * 2
	new_line := 1
	buff_width := (cell_width * board.width + new_line)
	buff_height := cell_height * board.height
	buff_size := buff_width * buff_height
	buff := make([dynamic]rune, buff_size)
	return PrintBufferCustom { cell_height, cell_width, new_line, buff_height, buff_width, buff }, true
}

draw_cell_at_buffer :: proc(print_buff: ^PrintBufferCustom, board: ^Board, x, y: int) {
	buff_idx := x * print_buff.cell_width + (y * print_buff.cell_height) * print_buff.buff_width
	val, _ := get_at_board(board, x, y)
	// autotile could be an hashmap. but having an hasmap feels unnecesary, as it would introduce complexness,
	// an array is easier to implement.
	auto_tile: [16]rune = [?]rune{
		0b0000..=0b1111 = '?',
		
	};
	if has_direction(val, .Right) {
		auto_tile[int(Directions.Right)] = ' ';
		auto_tile[int(Directions.Right) | int(Directions.Up)] = '▀'
		auto_tile[int(Directions.Right) | int(Directions.Down)] = '▄'
	} else {
		auto_tile[int(Directions.Right)] = '█';
		auto_tile[int(Directions.Right) | int(Directions.Up)] = '█'
		auto_tile[int(Directions.Right) | int(Directions.Down)] = '█'
		
	}
	if has_direction(val, .Left) {
		auto_tile[int(Directions.Left)] = ' ';
		auto_tile[int(Directions.Left) | int(Directions.Up)] = '▀'
		auto_tile[int(Directions.Left) | int(Directions.Down)] = '▄'
	} else {
		auto_tile[int(Directions.Left)] = '█';
		auto_tile[int(Directions.Left) | int(Directions.Up)] = '█'
		auto_tile[int(Directions.Left) | int(Directions.Down)] = '█'
		
	}
	if has_direction(val, .Up) {
		auto_tile[int(Directions.Up)] = ' '
	} else {
		auto_tile[int(Directions.Up)] = '▀'
	}
	if has_direction(val, .Down) {
		auto_tile[int(Directions.Down)] = ' '
	} else {
		auto_tile[int(Directions.Down)] = '▄'
	}
	auto_tile[0b0000] = ' '
	idx := 0
	for off_y in 0..<print_buff.cell_height {
		up, down := 0, 0;
		if off_y == 0 {
			up = int(Directions.Up)
		}
		if off_y == print_buff.cell_height - 1 {
			down = int(Directions.Down)
		}
		for off_x in 0..<print_buff.cell_width {
			left, right := 0, 0;
			if off_x == 0 {
				left = int(Directions.Left)
			}
			if off_x == print_buff.cell_width - 1 {
				right = int(Directions.Right)
			}
			auto_tile_idx := right + up + left + down;
			offset_idx := off_x + off_y * print_buff.buff_width
			print_buff.buff[buff_idx + offset_idx] = auto_tile[auto_tile_idx]
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
	cell_size := 3
	print_buff, ok := init_print_buff(board, cell_size)
	if !ok {
		fmt.eprintfln("Cell size(%i) smaller than minimum.", cell_size)
	}
	for y in 0..<board.height {
		for x in 0..<board.width {
			draw_cell_at_buffer(&print_buff, board, x, y)
		}
	}
	add_new_line(&print_buff, board)
	fmt.printf("%s", print_buff.buff[:])
}
