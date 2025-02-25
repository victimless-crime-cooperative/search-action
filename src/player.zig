const std = @import("std");
const rl = @import("raylib");

pub const Player = struct {
    position: rl.Vector3,

    const Self = @This();

    pub fn init(position: rl.Vector3) Self {
        return Self{ .position = position };
    }

    pub fn draw(self: Self) void {
        rl.drawCube(self.position, 1, 1, 1, rl.Color.red);
    }

    pub fn move(self: *Self, velocity: rl.Vector3) void {
        self.position = self.position.add(velocity.scale(rl.getFrameTime()));
    }
};
