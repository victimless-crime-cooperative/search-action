const std = @import("std");
const rl = @import("raylib");
const ren = @import("rendering.zig");
const phys = @import("physics.zig");

pub const Block = struct {
    position: rl.Vector3,
    velocity: rl.Vector3 = .{ .x = 0, .y = 0, .z = 0 },
    colliding: bool = false,

    const Self = @This();

    pub fn new(x: f32, y: f32, z: f32) Self {
        return Self{ .position = .{ .x = x, .y = y, .z = z } };
    }

    pub fn draw(ptr: *anyopaque) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        const color = if (self.colliding) rl.Color.red else rl.Color.blue;
        rl.drawCubeV(self.position, .{ .x = 1, .y = 1, .z = 1 }, color);
    }

    pub fn set_collision(ptr: *anyopaque, is_colliding: bool) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.colliding = is_colliding;
    }

    pub fn renderable(self: *Self) ren.Renderable {
        return .{
            .ptr = self,
            .drawFn = draw,
        };
    }

    pub fn rigidbody(self: *Self) phys.Rigidbody {
        return .{ .ptr = self, .position = &self.position, .velocity = &self.velocity, .collider = phys.Collider{ .cube = .{ .x = 1, .y = 1, .z = 1 } }, .collisionFn = set_collision };
    }
};
