const std = @import("std");
const rl = @import("raylib");
const e = @import("entity.zig");

pub const ModelHandles = struct {
    player: *rl.Model,
    road: *rl.Model,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) !Self {
        const player = try Self.loadModel(allocator, "./assets/models/cheffy.glb");
        const road = try Self.loadModel(allocator, "./assets/models/road.glb");
        return .{ .player = player, .road = road };
    }

    pub fn deinit(self: Self, allocator: std.mem.Allocator) void {
        allocator.destroy(self.player);
        allocator.destroy(self.road);
    }

    fn loadModel(allocator: std.mem.Allocator, path: [*:0]const u8) !*rl.Model {
        const raw_model = try rl.loadModel(path);
        const model = try allocator.create(rl.Model);
        model.* = raw_model;
        return model;
    }
};

pub const Renderer = struct {
    renderables: std.ArrayHashMapUnmanaged(e.Entity, Renderable, e.EntityContext, false),

    const Self = @This();

    pub fn init() Self {
        const renderables: std.ArrayHashMapUnmanaged(e.Entity, Renderable, e.EntityContext, false) = .{};
        return Self{ .renderables = renderables };
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        self.renderables.deinit(allocator);
    }

    pub fn put(self: *Self, allocator: std.mem.Allocator, entity: e.Entity, renderable: Renderable) !void {
        try self.renderables.put(allocator, entity, renderable);
    }

    pub fn draw(self: Self) void {
        var iterator = self.renderables.iterator();
        while (iterator.next()) |entry| {
            entry.value_ptr.draw();
        }
    }
};

pub const Renderable = struct {
    ptr: *anyopaque,
    drawFn: *const fn (ptr: *anyopaque) void,

    const Self = @This();

    fn draw(self: Self) void {
        return self.drawFn(self.ptr);
    }
};
