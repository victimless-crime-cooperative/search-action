const std = @import("std");

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

pub fn main() !void {}

test "decl test" {
    const MyType = struct {
        pub fn do_nothing() void {}
    };

    const expect = @import("std").testing.expect;

    const typeInfo = @typeInfo(MyType);

    try expect(std.mem.eql(u8, typeInfo.Struct.decls[0].name, "do_nothing"));
}
