const std = @import("std");
const rl = @import("raylib");

pub const PhysicsObject = struct {
    position: *rl.Vector3,
    velocity: *rl.Vector3,
    ptr: *anyopaque,
    physicsUpdateFn: *const fn (ptr: *anyopaque) void,

    const Self = @This();

    fn physics_update(self: Self) void {
        return self.physicsUpdateFn(self.ptr);
    }
};

pub const Rigidbody = struct {
    position: rl.Vector3,
    velocity: rl.Vector3 = .{ .x = 0, .y = 0, .z = 0 },

    const Self = @This();

    pub fn physics_update(ptr: *anyopaque) void {
        const self: *Rigidbody = @ptrCast(@alignCast(ptr));
        _ = self;
    }

    pub fn physics_object(self: *Self) PhysicsObject {
        return .{
            .position = *self.position,
            .velocity = *self.velocity,
            .ptr = self,
            .physicsUpdateFn = self.physics_update,
        };
    }
};
