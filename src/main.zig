const std = @import("std");
const r = @cImport(@cInclude("raylib.h"));

const str = *const [1:0]u8;

const WIDTH = 900;
const GRID_SIZE = 3;
const CELL_SIZE = WIDTH / GRID_SIZE - 2;
const PLAYER_CELL = "O";
const CPU_CELL = "X";
const Board = [GRID_SIZE][GRID_SIZE]str;

fn check_win(board: *Board) bool {
    var win = false;
    for (0..GRID_SIZE) |row| {
        if (std.mem.allEqual(str, &board[row], PLAYER_CELL)) {
            win = true;
            break;
        }
    }

    for (0..GRID_SIZE) |col| {
        var col_slice = [_]str{" "} ** GRID_SIZE;
        for (0..GRID_SIZE) |row| {
            col_slice[row] = board[row][col];
        }
        if (std.mem.allEqual(str, &col_slice, PLAYER_CELL)) {
            win = true;
            break;
        }
    }

    var pos_diag = [_]str{" "} ** GRID_SIZE;
    var negative_diag = [_]str{" "} ** GRID_SIZE;
    for (0..GRID_SIZE) |y| {
        for (0..GRID_SIZE) |x| {
            if (x + y == GRID_SIZE - 1)
                negative_diag[y] = board[x][y];
        }
        pos_diag[y] = board[y][y];
    }
    if (std.mem.allEqual(str, &pos_diag, PLAYER_CELL)) win = true;
    if (std.mem.allEqual(str, &negative_diag, PLAYER_CELL)) win = true;
    return win;
}

pub fn main() !void {
    r.SetConfigFlags(r.FLAG_VSYNC_HINT);
    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();
    r.InitWindow(WIDTH, WIDTH, "Zig Zac Zoe");
    defer r.CloseWindow();
    var board = [_][GRID_SIZE]str{[_]str{" "} ** GRID_SIZE} ** GRID_SIZE;
    var cpu_turn = false;
    var turns: u8 = 0;

    while (!r.WindowShouldClose()) {
        if (check_win(&board)) return;
        const random_x = rand.intRangeAtMost(usize, 0, GRID_SIZE - 1);
        const random_y = rand.intRangeAtMost(usize, 0, GRID_SIZE - 1);
        if (std.mem.eql(u8, board[random_x][random_y], " ") and cpu_turn) {
            board[random_x][random_y] = CPU_CELL;
            cpu_turn = false;
            turns += 1;
        }

        r.BeginDrawing();
        r.ClearBackground(r.RAYWHITE);
        for (0..GRID_SIZE) |_row| {
            const row = @as(c_int, @intCast(_row));
            const x = row * CELL_SIZE;
            for (0..GRID_SIZE) |_col| {
                const col = @as(c_int, @intCast(_col));
                const y = col * CELL_SIZE;
                const cell_rect = r.Rectangle{
                    .x = @floatFromInt(x + 2),
                    .y = @floatFromInt(y + 2),
                    .width = CELL_SIZE,
                    .height = CELL_SIZE,
                };
                r.DrawRectangle(x, y, CELL_SIZE + 8, CELL_SIZE + 8, r.WHITE);
                r.DrawRectangleRec(cell_rect, r.BLACK);
                const cell = board[_row][_col];
                r.DrawText(cell, x + 65, y + 20, CELL_SIZE - 20, r.WHITE);
                const cell_is_clicked = r.CheckCollisionPointRec(r.GetMousePosition(), cell_rect);
                if (cell_is_clicked and !cpu_turn and std.mem.eql(u8, cell, " ")) {
                    if (r.IsMouseButtonPressed(r.MOUSE_BUTTON_LEFT)) {
                        board[_row][_col] = PLAYER_CELL;
                        cpu_turn = true;
                        turns += 1;
                    }
                    r.DrawText(PLAYER_CELL, x + 65, y + 20, CELL_SIZE - 20, r.GRAY);
                }
            }
        }
        r.EndDrawing();
    }
}
