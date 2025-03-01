const std = @import("std");
const rl = @import("raylib");

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
    renderable_objects: std.ArrayListUnmanaged(Renderable),

    const Self = @This();

    pub fn init() Self {
        const renderable_objects: std.ArrayListUnmanaged(Renderable) = .{};
        return Self{ .renderable_objects = renderable_objects };
    }

    pub fn deinit(self: Self) void {
        self.renderable_objects.deinit();
    }

    pub fn append(self: *Self, allocator: std.mem.Allocator, draw_object: Renderable) !void {
        try self.renderable_objects.append(allocator, draw_object);
    }

    pub fn draw(self: Self) void {
        for (self.renderable_objects.items) |ro| {
            ro.draw();
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
