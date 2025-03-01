const std = @import("std");
const rl = @import("raylib");
const entity = @import("entity.zig");
const PhysicsSolver = @import("physics.zig").PhysicsSolver;
const Renderer = @import("rendering.zig").Renderer;

pub const World = struct {
    camera: rl.Camera3D,
    entity_generator: entity.EntityGenerator = .{},
    physics_solver: PhysicsSolver,
    renderer: Renderer,

    const Self = @This();

    pub fn init() Self {
        const camera = rl.Camera3D{ .position = .{ .x = 0, .y = 10, .z = -10 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .up = .{ .x = 0, .y = 1, .z = 0 }, .fovy = 45, .projection = .perspective };
        const physics_solver = PhysicsSolver.init();
        const renderer = Renderer.init();
        return .{ .camera = camera, .renderer = renderer, .physics_solver = physics_solver };
    }

    pub fn insert(self: *Self, allocator: std.mem.Allocator, comptime T: type, object: *T) !entity.Entity {
        const new_id = self.entity_generator.create();
        if (@hasDecl(T, "rigidbody")) {
            std.debug.print("Found physical guy, adding to world", .{});
            try self.physics_solver.put(allocator, new_id, object.rigidbody());
        }

        return new_id;
    }

    pub fn interpolate_vector(self: Self, value: rl.Vector3) rl.Vector3 {
        const matrix = self.camera.getMatrix();
        const target_matrix = matrix.invert();
        var new_value = value.transform(target_matrix).subtract(self.camera.position);
        new_value.y = 0;
        return new_value.normalize();
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
