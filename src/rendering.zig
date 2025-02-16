const std = @import("std");
const rl = @import("raylib");

pub const ModelHandles = struct {
    player_model: *rl.Model,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) !Self {
        const player_model = try Self.loadModel(allocator, "./assets/models/cheffy.glb");
        return .{ .player_model = player_model };
    }

    pub fn deinit(self: Self, allocator: std.mem.Allocator) void {
        allocator.destroy(self.player_model);
    }

    fn loadModel(allocator: std.mem.Allocator, path: [*:0]const u8) !*rl.Model {
        const raw_model = try rl.loadModel(path);
        const model = try allocator.create(rl.Model);
        model.* = raw_model;
        return model;
    }
};
