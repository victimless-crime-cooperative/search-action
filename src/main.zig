const std = @import("std");
const rl = @import("raylib");
const Player = @import("player.zig").Player;
const World = @import("core.zig").World;

pub fn main() !void {
    const screen_width = 1600;
    const screen_height = 900;

    rl.setConfigFlags(.{ .window_resizable = true });

    // try physics.particle_sim();

    rl.initWindow(screen_width, screen_height, "search action");
    defer rl.closeWindow();

    const world = World.init();

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
            const transformed_velocity = world.interpolate_vector(velocity);
            player.move(transformed_velocity);
        }
        rl.beginDrawing();
        rl.clearBackground(rl.Color.ray_white);

        world.start_3d();
        defer world.end_3d();
        {
            rl.drawGrid(10, 1);
            player.draw();
        }

        rl.endDrawing();
    }
}
