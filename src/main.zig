const std = @import("std");
const rl = @import("raylib");
const core = @import("core.zig");
const physics = @import("physics.zig");
const rendering = @import("rendering.zig");

// Create a world struct that will act as a simplified ECS, that handles the following
// run game logic in seperate schedules
// Update,
// Draw,
// Cleanup
//
// Global references (asset handles, singleton objects)
// Entities
// try out an interface to implement for objects that share common behavior (like with the `drawer` interface), and then a comptime function to reproduce that pattern for new object types
// these types will define what they do in their (update, draw, cleanup) steps
//
//
//

pub fn main() !void {
    const screen_width = 1600;
    const screen_height = 900;

    rl.setConfigFlags(.{ .window_resizable = true });
    rl.initWindow(screen_width, screen_height, "search action");
    defer rl.closeWindow();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const handles = try rendering.ModelHandles.init(allocator);
    defer handles.deinit(allocator);

    const world = try core.World.init(allocator);
    defer world.deinit(allocator);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        // Clear color
        rl.clearBackground(rl.Color.ray_white);

        //3D Draw Step
        world.start_3d();
        rl.drawGrid(10, 1);
        rl.drawModel(handles.player_model.*, .{ .x = 0, .y = 0, .z = 0 }, 1, rl.Color.white);
        rl.drawModel(handles.player_model.*, .{ .x = 2, .y = 0, .z = 0 }, 1, rl.Color.white);

        world.end_3d();
        //UI Draw Step
    }
}

//Realizing now that we can use multi array strings to handle extracted struct data for some mini-ecs stuff (physical object can be generated from an interface method, output uniform structs for velocity, position, etc, amd update them from while crawling the multi array list, giving us cache-locality and a more ecs like flow, can also include a state machine struct as well to, simmilar to how I'm handling state in bevy, but a little better in this case because we switch on the [state] of the object instead of querying for the state and checking
//
// Computers are so fucking cool
