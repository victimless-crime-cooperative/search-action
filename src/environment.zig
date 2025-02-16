const std = @import("std");
const rl = @import("raylib");
const ren = @import("rendering.zig");

pub const Block = struct {
    position: rl.Vector3,
    rotation: f32 = 0,
    model: *rl.Model,

    const Self = @This();

    pub fn new(x: f32, y: f32, z: f32, model: *rl.Model) Self {
        return Self{ .position = .{ .x = x, .y = y, .z = z }, .model = model };
    }

    pub fn draw(ptr: *anyopaque) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        rl.drawModelEx(self.model.*, self.position, .{ .x = 0, .y = 1, .z = 0 }, self.rotation, .{ .x = 1, .y = 1, .z = 1 }, rl.Color.white);
    }

    pub fn draw_object(self: *Self) ren.DrawObject {
        return .{
            .ptr = self,
            .drawFn = draw,
        };
    }
};
