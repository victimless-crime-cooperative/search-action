const std = @import("std");
const rl = @import("raylib");

pub fn World(allocator: std.mem.Allocator) type {
    return struct {
        camera: *rl.Camera3D,

        const Self = @This();

        pub fn setup(self: Self) void {
            const camera = allocator.create(rl.Camera3D);
            camera.* = rl.Camera3D{ .position = .{ .x = 0, .y = 0, .z = -10 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .up = .{ .x = 0, .y = 1, .z = 0 }, .fovy = 45, .projection = .perspective };
            self.camera = camera;
        }

        pub fn start_3d(self: Self) void {
            self.camera.begin();
        }
        pub fn end_3d(self: Self) void {
            self.camera.end();
        }
    };
}
