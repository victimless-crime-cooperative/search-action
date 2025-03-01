const std = @import("std");
const rl = @import("raylib");

pub const PhysicsSolver = struct {
    rigidbodies: std.ArrayListUnmanaged(Rigidbody),

    const Self = @This();

    pub fn init() Self {
        const rigidbodies: std.ArrayListUnmanaged(Rigidbody) = .{};
        return Self{ .rigidbodies = rigidbodies };
    }

    pub fn deinit(self: Self) void {
        self.rigidbodies.deinit();
    }

    pub fn append(self: *Self, allocator: std.mem.Allocator, rigidbody: Rigidbody) !void {
        try self.rigidbodies.append(allocator, rigidbody);
    }
};

pub const Rigidbody = struct {
    ptr: *anyopaque,
    position: *rl.Vector3,
    velocity: *rl.Vector3,
    collider: Collider,

    const Self = @This();

    pub fn physics_update(ptr: *anyopaque) void {
        const self: *Rigidbody = @ptrCast(@alignCast(ptr));
        _ = self;
    }

    pub fn colliding_with(self: Self, other: Self) bool {
        switch (self.collider) {
            .cube => |extents| {
                const self_box = rl.BoundingBox{ .min = self.position.subtract(extents.scale(0.5)), .max = self.position.add(extents.scale(0.5)) };
                switch (other.collider) {
                    .cube => |o_extents| {
                        const other_box = rl.BoundingBox{ .min = other.position.subtract(o_extents.scale(0.5)), .max = other.position.add(o_extents.scale(0.5)) };
                        return rl.checkCollisionBoxes(self_box, other_box);
                    },
                    .sphere => |o_radius| {
                        return rl.checkCollisionBoxSphere(self_box, other.position, o_radius);
                    },
                }
            },
            .sphere => |radius| {
                switch (other.collider) {
                    .cube => |o_extents| {
                        const other_box = rl.BoundingBox{ .min = other.position.subtract(o_extents.scale(0.5)), .max = other.position.add(o_extents.scale(0.5)) };
                        return rl.checkCollisionBoxSphere(other_box, self.position, radius);
                    },
                    .sphere => |o_radius| {
                        return rl.checkCollisionSpheres(self.position, radius, other.position, o_radius);
                    },
                }
            },
        }
    }
};

pub const ColliderTag = enum { cube, sphere };

pub const Collider = union(ColliderTag) { cube: rl.Vector3, sphere: f32 };
