pub const Entity = struct {
    index: u32,

    const Self = @This();

    pub fn eql(self: Self, other: Self) bool {
        return self.index == other.index;
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
