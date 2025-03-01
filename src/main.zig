const std = @import("std");
const rl = @import("raylib");
const Player = @import("player.zig").Player;
const World = @import("core.zig").World;
const Renderer = @import("rendering.zig").Renderer;
const PhysicsSolver = @import("physics.zig").PhysicsSolver;
const Block = @import("environment.zig").Block;

pub fn main() !void {
    var WINDOW_WIDTH: i32 = 1600;
    var WINDOW_HEIGHT: i32 = 900;
    const RENDER_WIDTH: i32 = 480;
    const RENDER_HEIGHT: i32 = 320;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var player = Player.init(.{ .x = 0, .y = 2, .z = 0 });
    var renderer = Renderer.init();
    var solver = PhysicsSolver.init();

    var a = Block.new(2, 2, 4);
    var b = Block.new(-2, 2, -4);
    var c = Block.new(3, 2, 5);

    // Register our renderables
    try renderer.append(allocator, player.renderable());
    try renderer.append(allocator, a.renderable());
    try renderer.append(allocator, b.renderable());
    try renderer.append(allocator, c.renderable());
    // Register our rigidbodies
    try solver.put(allocator, .{ .index = 0 }, player.rigidbody());
    try solver.put(allocator, .{ .index = 1 }, a.rigidbody());
    try solver.put(allocator, .{ .index = 2 }, b.rigidbody());
    try solver.put(allocator, .{ .index = 3 }, c.rigidbody());

    rl.setConfigFlags(.{ .window_resizable = true });

    rl.initWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "search action");
    const monitor = rl.getCurrentMonitor();
    WINDOW_WIDTH = rl.getMonitorWidth(monitor);
    WINDOW_HEIGHT = rl.getMonitorHeight(monitor);
    defer rl.closeWindow();

    var world = World.init();
    const player_id = try world.insert(allocator, Player, &player);
    _ = player_id;

    var rt = try rl.loadRenderTexture(RENDER_WIDTH, RENDER_HEIGHT);

    while (!rl.windowShouldClose()) {
        // Physics Step
        {
            input(world, &player);
            solver.apply_velocity();
        }
        // Start drawing to the render texture
        rt.begin();
        {
            world.start_3d();
            rl.clearBackground(rl.Color.white);
            rl.drawGrid(10, 1);
            renderer.draw();
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
    } else {
        player.move(rl.Vector3.zero());
    }
}
