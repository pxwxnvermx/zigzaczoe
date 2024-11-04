const std = @import("std");
const r = @cImport(@cInclude("raylib.h"));

const str = *const [1:0]u8;

const WIDTH = 900;
const GRID_SIZE = 3;
const CELL_SIZE = WIDTH / 3 - 2;
const PLAYER_CELL = "O";
const CPU_CELL = "X";

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
    var board = [3][3]str{
        [3]str{ " ", " ", " " },
        [3]str{ " ", " ", " " },
        [3]str{ " ", " ", " " },
    };

    var cpu_turn = false;

    while (!r.WindowShouldClose()) {
        r.BeginDrawing();
        r.ClearBackground(r.RAYWHITE);

        var random_x = rand.intRangeAtMost(usize, 0, 2);
        var random_y = rand.intRangeAtMost(usize, 0, 2);
        while (!std.mem.eql(u8, board[random_x][random_y], " ")) {
            random_x = rand.intRangeAtMost(usize, 0, 2);
            random_y = rand.intRangeAtMost(usize, 0, 2);
        }
        while (std.mem.eql(u8, board[random_x][random_y], " ") and cpu_turn) {
            board[random_x][random_y] = CPU_CELL;
            cpu_turn = false;
        }

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
                    }
                    r.DrawText(PLAYER_CELL, x + 65, y + 20, CELL_SIZE - 20, r.GRAY);
                }
            }
        }

        r.EndDrawing();
    }
}
