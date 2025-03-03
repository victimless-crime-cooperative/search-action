const std = @import("std");
const rl = @import("raylib");
const e = @import("entity.zig");

pub const PhysicsSolver = struct {
    rigidbodies: std.ArrayHashMapUnmanaged(e.Entity, Rigidbody, e.EntityContext, false),

    const Self = @This();

    pub fn init() Self {
        const rigidbodies: std.ArrayHashMapUnmanaged(e.Entity, Rigidbody, e.EntityContext, false) = .{};
        return Self{ .rigidbodies = rigidbodies };
    }

    /// De-initialize the physics solver
    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        self.rigidbodies.deinit(allocator);
    }

    pub fn put(self: *Self, allocator: std.mem.Allocator, entity: e.Entity, rigidbody: Rigidbody) !void {
        try self.rigidbodies.put(allocator, entity, rigidbody);
    }

    pub fn apply_velocity(self: Self) void {
        var iterator = self.rigidbodies.iterator();
        while (iterator.next()) |entry| {
            entry.value_ptr.apply_velocity();
        }
    }

    pub fn check_collisions(self: Self, allocator: std.mem.Allocator) ![]CollisionPair {
        const collisions_list: std.ArrayListUnmanaged(CollisionPair) = .{};
        const it1 = self.rigidbodies.iterator();
        const it2 = self.rigidbodies.iterator();
        for (it1) |a| {
            for (it2) |b| {
                if (a.key != b.key) {
                    if (a.value.colliding_with(b.value)) {
                        try collisions_list.append(allocator, .{
                            .a = a.key,
                            .b = b.key,
                        });
                    }
                }
            }
        }

        return collisions_list.toOwnedSlice(allocator);
    }
};

pub const CollisionPair = struct {
    a: e.Entity,
    b: e.Entity,

    const Self = @This();
};

pub fn vec3_is_any(value: *rl.Vector3) bool {
    return !(value.x == 0 and value.y == 0 and value.z == 0);
}

pub const Rigidbody = struct {
    ptr: *anyopaque,
    position: *rl.Vector3,
    velocity: *rl.Vector3,
    collider: Collider,

    const Self = @This();

    pub fn apply_velocity(self: *Self) void {
        if (vec3_is_any(self.velocity)) {
            self.position.* = self.position.add(self.velocity.*);
        }
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
