const std = @import("std");
const rl = @import("raylib");
const Player = @import("player.zig").Player;

pub fn main() !void {
    const screen_width = 1600;
    const screen_height = 900;

    rl.setConfigFlags(.{ .window_resizable = true });

    // try physics.particle_sim();

    rl.initWindow(screen_width, screen_height, "search action");
    defer rl.closeWindow();

    const camera = rl.Camera3D{ .position = .{ .x = 0, .y = 10, .z = -10 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .up = .{ .x = 0, .y = 1, .z = 0 }, .fovy = 45, .projection = .perspective };
    var player = Player.init(.{ .x = 0, .y = 2, .z = 0 });

    while (!rl.windowShouldClose()) {
        var velocity = rl.Vector3.zero();
        if (rl.isKeyDown(.s)) {
            velocity.z += 1;
        }
        if (rl.isKeyDown(.w)) {
            velocity.z -= 1;
        }
        if (rl.isKeyDown(.d)) {
            velocity.x += 1;
        }
        if (rl.isKeyDown(.a)) {
            velocity.x -= 1;
        }
        if (velocity.x != 0 or velocity.z != 0) {
            const camera_matrix: rl.Matrix = camera.getMatrix();
            const inverted_matrix: rl.Matrix = camera_matrix.invert();
            var transformed_vector = velocity.transform(inverted_matrix).subtract(camera.position);
            transformed_vector.y = 0;
            player.move(transformed_vector.normalize());
        }
        rl.beginDrawing();
        rl.clearBackground(rl.Color.ray_white);

        camera.begin();
        {
            rl.drawGrid(10, 1);
            player.draw();
        }
        camera.end();

        rl.endDrawing();
    }
}
