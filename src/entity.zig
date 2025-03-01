const std = @import("std");

pub const Entity = struct {
    index: u32,

    const Self = @This();

    pub fn eql(self: Self, other: Self) bool {
        return self.index == other.index;
    }
};

pub const EntityContext = struct {
    const Self = @This();

    pub fn hash(self: Self, entity: Entity) u32 {
        _ = self;
        return entity.index;
    }

    pub fn eql(self: Self, a: Entity, b: Entity, i: usize) bool {
        _ = self;
        _ = i;

        return a.eql(b);
    }
};

pub const EntityGenerator = struct {
    index: u32 = 0,

    const Self = @This();

    pub fn create(self: *Self) Entity {
        const entity: Entity = .{ .index = self.index };
        self.index += 1;
        return entity;
    }
};
