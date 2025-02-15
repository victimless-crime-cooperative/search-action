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

// The results of this test is just me reailizing how powerful zigs type system is
// This will allow making DrawObject, UpdateObject, and CleanupObjects for any type we need to with less boilerplate, since you can inspect and interact with type declarations, we can essentially add the fields/methods unique to an object and then insert engine necessary stuff (position, visibility, velocity, mesh)
test "decl test" {
    const MyType = struct {
        pub fn do_nothing() void {}
    };

    const expect = @import("std").testing.expect;

    const typeInfo = @typeInfo(MyType);

    try expect(std.mem.eql(u8, typeInfo.Struct.decls[0].name, "do_nothing"));
}

//Realizing now that we can use multi array strings to handle extracted struct data for some mini-ecs stuff (physical object can be generated from an interface method, output uniform structs for velocity, position, etc, amd update them from while crawling the multi array list, giving us cache-locality and a more ecs like flow, can also include a state machine struct as well to, simmilar to how I'm handling state in bevy, but a little better in this case because we switch on the [state] of the object instead of querying for the state and checking
//
// Computers are so fucking cool
