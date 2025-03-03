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
        // For each struct implementing the rigidbody interface, add it's rigidbody to the solver
        if (@hasDecl(T, "rigidbody")) {
            std.debug.print("////\nStruct with a rigidbody found,\n adding to world\n////\n", .{});
            try self.physics_solver.put(allocator, new_id, object.rigidbody());
        }
        // For each struct implementing the renderable interface, add it's renderable to the renderer
        if (@hasDecl(T, "renderable")) {
            std.debug.print("////\nStruct with a renderable found,\nadding to world\n////\n", .{});
            try self.renderer.put(allocator, new_id, object.renderable());
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

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        self.physics_solver.deinit(allocator);
        self.renderer.deinit(allocator);
    }

    pub fn start_3d(self: Self) void {
        self.camera.begin();
    }
    pub fn end_3d(self: Self) void {
        self.camera.end();
    }

    pub fn physics_step(self: Self) void {
        self.physics_solver.apply_velocity();
    }

    pub fn draw_step(self: Self) void {
        self.renderer.draw();
    }

    pub fn game_loop(self: Self) void {
        self.physics_step();
    }
};
