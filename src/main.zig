const r = @cImport(@cInclude("raylib.h"));

const WIDTH = 900;
const GRID_SIZE = 3;
const CELL_SIZE = WIDTH / 3 - 2;

pub fn main() !void {
    r.SetConfigFlags(r.FLAG_VSYNC_HINT);
    r.InitWindow(WIDTH, WIDTH, "Zig Zac Zoe");
    defer r.CloseWindow();

    while (!r.WindowShouldClose()) {
        r.BeginDrawing();
        r.ClearBackground(r.RAYWHITE);

        for (0..GRID_SIZE) |_row| {
            const row = @as(c_int, @intCast(_row));
            const x = row * CELL_SIZE;
            for (0..GRID_SIZE) |_col| {
                const col = @as(c_int, @intCast(_col));
                const y = col * CELL_SIZE;
                r.DrawRectangle(x, y, CELL_SIZE + 8, CELL_SIZE + 8, r.WHITE);
                r.DrawRectangle(x + 2, y + 2, CELL_SIZE, CELL_SIZE, r.BLACK);
            }
        }

        r.EndDrawing();
    }
}
