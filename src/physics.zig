const std = @import("std");
const rl = @import("raylib");

pub const PhysicsObject = struct {
    position: *rl.Vector3,
    velocity: *rl.Vector3,
    ptr: *anyopaque,
    physicsUpdateFn: *const fn (ptr: *anyopaque) void,

    const Self = @This();

    fn physics_update(self: Self) void {
        return self.physicsUpdateFn(self.ptr);
    }
};

pub const ColliderTag = enum { cube, sphere };

pub const Collider = union(ColliderTag) { cube: rl.Vector3, sphere: f32 };

pub const Rigidbody = struct {
    position: rl.Vector3,
    collider: Collider,
    velocity: rl.Vector3 = .{ .x = 0, .y = 0, .z = 0 },

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

    pub fn physics_object(self: *Self) PhysicsObject {
        return .{
            .position = *self.position,
            .velocity = *self.velocity,
            .ptr = self,
            .physicsUpdateFn = self.physics_update,
        };
    }
};

pub const Particle = struct {
    position: rl.Vector3,
    velocity: rl.Vector3,
    mass: f32,

    const Self = @This();

    pub fn init(rand: std.Random) Self {
        const position = .{ .x = rand.float(f32) * 10, .y = rand.float(f32) * 10, .z = rand.float(f32) * 10 };
        const velocity = .{ .x = 0, .y = 0, .z = 0 };
        const mass = 1;
        return .{ .position = position, .velocity = velocity, .mass = mass };
    }

    pub fn physics_update(self: *Self) void {
        const force = self.compute_gravity();
        const acceleration: rl.Vector3 = .{ .x = force.x / self.mass, .y = force.y / self.mass, .z = force.z / self.mass };
        self.velocity.x += acceleration.x;
        self.velocity.y += acceleration.y;
        self.velocity.z += acceleration.z;

        self.position.x += self.velocity.x;
        self.position.y += self.velocity.y;
        self.position.z += self.velocity.z;
    }

    pub fn compute_gravity(self: *Self) rl.Vector3 {
        return .{ .x = 0, .y = self.mass * -9.81, .z = 0 };
    }

    pub fn print(self: Self) void {
        std.debug.print("{},{},{}\n", .{ self.position.x, self.position.y, self.position.z });
    }
};

pub fn particle_sim() !void {
    const particle_count: u8 = 1;

    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();
    const p1 = Particle.init(rand);
    var particles = [particle_count]Particle{p1};

    for (particles) |p| {
        p.print();
    }

    const sim_time: u8 = 100;
    var current_time: u8 = 0;

    while (current_time < sim_time) {
        std.time.sleep(1_000_000_000);

        for (&particles) |*p| {
            p.physics_update();
            p.print();
        }
        current_time += 1;
    }
}
