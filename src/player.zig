const std = @import("std");
const rl = @import("raylib");
const ren = @import("rendering.zig");

pub const Player = struct {
    position: rl.Vector3,

    const Self = @This();

    pub fn init(position: rl.Vector3) Self {
        return Self{ .position = position };
    }

    pub fn draw(ptr: *anyopaque) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        rl.drawCube(self.position, 1, 1, 1, rl.Color.red);
    }

    pub fn move(self: *Self, velocity: rl.Vector3) void {
        self.position = self.position.add(velocity.scale(rl.getFrameTime()));
    }

    //
    pub fn draw_object(self: *Self) ren.Renderable {
        return .{
            .ptr = self,
            .drawFn = draw,
        };
    }
};
