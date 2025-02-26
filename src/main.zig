const std = @import("std");
const rl = @import("raylib");
const Player = @import("player.zig").Player;
const World = @import("core.zig").World;

pub fn main() !void {
    var WINDOW_WIDTH: i32 = 1600;
    var WINDOW_HEIGHT: i32 = 900;
    const RENDER_WIDTH: i32 = 480;
    const RENDER_HEIGHT: i32 = 320;

    rl.setConfigFlags(.{ .window_resizable = true });

    rl.initWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "search action");
    const monitor = rl.getCurrentMonitor();
    WINDOW_WIDTH = rl.getMonitorWidth(monitor);
    WINDOW_HEIGHT = rl.getMonitorHeight(monitor);
    defer rl.closeWindow();

    const world = World.init();

    var player = Player.init(.{ .x = 0, .y = 2, .z = 0 });

    var rt = try rl.loadRenderTexture(RENDER_WIDTH, RENDER_HEIGHT);

    while (!rl.windowShouldClose()) {
        input(world, &player);
        // Start drawing to the render texture
        rt.begin();
        {
            world.start_3d();
            rl.clearBackground(rl.Color.white);
            rl.drawGrid(10, 1);
            player.draw();
            world.end_3d();
        }
        rt.end();

        //Draw our render texture to the screen
        rl.beginDrawing();
        rl.drawTexturePro(rt.texture, .{
            .x = 0,
            .y = 0,
            .width = RENDER_WIDTH,
            //set a negative height to flip the texture vertically
            .height = -RENDER_HEIGHT,
        }, .{
            .x = 0,
            .y = 0,
            .width = @floatFromInt(WINDOW_WIDTH),
            .height = @floatFromInt(WINDOW_HEIGHT),
        }, rl.Vector2.zero(), 0, rl.Color.white);
        rl.endDrawing();
    }
}

pub fn input(world: World, player: *Player) void {
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
}
