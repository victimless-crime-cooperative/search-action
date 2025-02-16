const std = @import("std");
const rl = @import("raylib");

pub const World = struct {
    camera: *rl.Camera3D,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) !Self {
        const camera = try allocator.create(rl.Camera3D);
        camera.* = rl.Camera3D{ .position = .{ .x = 0, .y = 10, .z = 10 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .up = .{ .x = 0, .y = 1, .z = 0 }, .fovy = 45, .projection = .perspective };
        return .{ .camera = camera };
    }

    pub fn deinit(self: Self, allocator: std.mem.Allocator) void {
        allocator.destroy(self.camera);
    }

    pub fn start_3d(self: Self) void {
        self.camera.begin();
    }
    pub fn end_3d(self: Self) void {
        self.camera.end();
    }
};
