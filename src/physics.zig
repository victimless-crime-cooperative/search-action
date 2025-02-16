const std = @import("std");
const rl = @import("raylib");

const PhysicsObject = struct {
    ptr: *anyopaque,
    updateFn: *const fn (ptr: *anyopaque) void,

    const Self = @This();

    fn update(self: Self) void {
        _ = self;
    }
};
