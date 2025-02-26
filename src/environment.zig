const std = @import("std");
const rl = @import("raylib");
const ren = @import("rendering.zig");

pub const Block = struct {
    position: rl.Vector3,
    rotation: f32 = 0,
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

    pub fn draw_object(self: *Self) ren.Renderable {
        return .{
            .ptr = self,
            .drawFn = draw,
        };
    }
};
