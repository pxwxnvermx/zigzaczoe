const r = @cImport(@cInclude("raylib.h"));

const WIDTH = 900;
const GRID_SIZE = 3;
const CELL_SIZE = WIDTH / 3 - 2;
const CELLS = enum {
    E,
    O,
    X,
    pub fn str(self: CELLS) [:0]const u8 {
        return switch (self) {
            CELLS.X => "X",
            CELLS.O => "O",
            CELLS.E => " ",
        };
    }
};
const PLAYER_CELL = CELLS.O;

pub fn main() !void {
    r.SetConfigFlags(r.FLAG_VSYNC_HINT);
    r.InitWindow(WIDTH, WIDTH, "Zig Zac Zoe");
    defer r.CloseWindow();

    var board = [_][3]CELLS{
        [_]CELLS{ CELLS.E, CELLS.E, CELLS.E },
        [_]CELLS{ CELLS.E, CELLS.E, CELLS.E },
        [_]CELLS{ CELLS.E, CELLS.E, CELLS.E },
    };

    var cpu_turn = false;

    while (!r.WindowShouldClose()) {
        r.BeginDrawing();
        r.ClearBackground(r.RAYWHITE);

        for (0..GRID_SIZE) |_row| {
            const row = @as(c_int, @intCast(_row));
            const x = row * CELL_SIZE;
            for (0..GRID_SIZE) |_col| {
                const col = @as(c_int, @intCast(_col));
                const y = col * CELL_SIZE;
                const cell = r.Rectangle{
                    .x = @floatFromInt(x + 2),
                    .y = @floatFromInt(y + 2),
                    .width = CELL_SIZE,
                    .height = CELL_SIZE,
                };
                r.DrawRectangle(x, y, CELL_SIZE + 8, CELL_SIZE + 8, r.WHITE);
                r.DrawRectangleRec(cell, r.BLACK);
                const sym = board[_row][_col].str();
                r.DrawText(sym, x + 65, y + 20, CELL_SIZE - 20, r.WHITE);
                if (cpu_turn and board[_row][_col] == CELLS.E) {
                    board[_row][_col] = CELLS.X;
                    cpu_turn = false;
                }
                if (r.CheckCollisionPointRec(r.GetMousePosition(), cell) and !cpu_turn) {
                    if (r.IsMouseButtonPressed(r.MOUSE_BUTTON_LEFT)) {
                        board[_row][_col] = PLAYER_CELL;
                        cpu_turn = true;
                    }
                    r.DrawText(PLAYER_CELL.str(), x + 65, y + 20, CELL_SIZE - 20, r.GRAY);
                }
            }
        }

        r.EndDrawing();
    }
}
