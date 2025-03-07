const std = @import("std");
const rl = @import("raylib");
const e = @import("entity.zig");

pub const PhysicsSolver = struct {
    rigidbodies: std.ArrayHashMapUnmanaged(e.Entity, Rigidbody, e.EntityContext, false),
    collision_pairs: ?[]Rigidbody.CollisionPair = null,

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

    pub fn manage_collision_flags(self: *Self) void {
        var it = self.rigidbodies.iterator();
        while (it.next()) |entry| {
            var is_colliding = false;
            if (self.collision_pairs) |pairs| {
                for (pairs) |pair| {
                    if (pair.contains(entry.key_ptr.*)) {
                        is_colliding = true;
                    }
                }
            }
            entry.value_ptr.set_collision(is_colliding);
        }
    }

    pub fn refresh_collisions(self: *Self, allocator: std.mem.Allocator) !void {
        var collisions_list: std.ArrayListUnmanaged(Rigidbody.CollisionPair) = .{};
        var it1 = self.rigidbodies.iterator();
        var it2 = self.rigidbodies.iterator();
        while (it1.next()) |*a| {
            while (it2.next()) |*b| {
                if (!a.key_ptr.*.eql(b.key_ptr.*)) {
                    if (a.value_ptr.*.colliding_with(b.value_ptr.*)) {
                        a.value_ptr.set_colliding(true);
                        b.value_ptr.set_colliding(true);
                        try collisions_list.append(allocator, .{
                            .a = a.key_ptr.*,
                            .b = b.key_ptr.*,
                        });
                    }
                }
            }
        }

        if (self.collision_pairs) |pairs| {
            self.collision_pairs = null;
            allocator.free(pairs);
        }
        const collision_slice = try collisions_list.toOwnedSlice(allocator);
        self.collision_pairs = collision_slice;
    }
};

pub fn vec3_is_any(value: *rl.Vector3) bool {
    return !(value.x == 0 and value.y == 0 and value.z == 0);
}

pub const Rigidbody = struct {
    ptr: *anyopaque,
    position: *rl.Vector3,
    velocity: *rl.Vector3,
    collider: Collider,
    collisionFn: *const fn (ptr: *anyopaque, is_colliding: bool) void,

    pub const ColliderTag = enum { cube, sphere };

    pub const Collider = union(ColliderTag) { cube: rl.Vector3, sphere: f32 };
    pub const CollisionStatus = packed struct { current: bool, potential: bool, _padding: u6 = 0 };

    pub const CollisionPair = struct {
        a: e.Entity,
        b: e.Entity,

        pub fn contains(self: CollisionPair, entity: e.Entity) bool {
            return self.a.eql(entity) or self.b.eql(entity);
        }
    };

    const Self = @This();

    pub fn set_colliding(self: *Self, is_colliding: bool) void {
        return self.collisionFn(self.ptr, is_colliding);
    }

    pub fn projected_position(self: Self) rl.Vector3 {
        return self.position.*.add(self.velocity.*);
    }

    pub fn apply_velocity(self: *Self) void {
        if (vec3_is_any(self.velocity)) {
            self.position.* = self.position.add(self.velocity.*);
        }
    }

    pub fn set_collision(self: Self, is_colliding: bool) void {
        return self.collisionFn(self.ptr, is_colliding);
    }

    //Todo, make this report collisions as well as potential collisions
    pub fn colliding_with(self: Self, other: Self) bool {
        switch (self.collider) {
            .cube => |extents| {
                const self_box = rl.BoundingBox{ .min = self.position.*.subtract(extents.scale(0.5)), .max = self.position.*.add(extents.scale(0.5)) };
                switch (other.collider) {
                    .cube => |o_extents| {
                        const other_box = rl.BoundingBox{ .min = other.position.*.subtract(o_extents.scale(0.5)), .max = other.position.*.add(o_extents.scale(0.5)) };
                        return rl.checkCollisionBoxes(self_box, other_box);
                    },
                    .sphere => |o_radius| {
                        return rl.checkCollisionBoxSphere(self_box, other.position.*, o_radius);
                    },
                }
            },
            .sphere => |radius| {
                switch (other.collider) {
                    .cube => |o_extents| {
                        const other_box = rl.BoundingBox{ .min = other.position.*.subtract(o_extents.scale(0.5)), .max = other.position.*.add(o_extents.scale(0.5)) };
                        return rl.checkCollisionBoxSphere(other_box, self.position.*, radius);
                    },
                    .sphere => |o_radius| {
                        return rl.checkCollisionSpheres(self.position.*, radius, other.position.*, o_radius);
                    },
                }
            },
        }
    }
};

test "collision type packing" {
    try std.testing.expect(@sizeOf(Rigidbody.CollisionStatus) == 1);
}
test "newtypes" {
    const SuperInt = u32;
    const a: SuperInt = 4;
    const b: u32 = 4;

    try std.testing.expect(a == b);
}
