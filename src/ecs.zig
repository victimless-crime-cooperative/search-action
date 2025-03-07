const std = @import("std");
const Allocator = std.mem.Allocator;

pub const void_archetype_hash = std.math.maxInt(u64);

pub const EntityId = u64;

pub const Entities = struct {
    allocator: Allocator,
    archetypes: std.AutoArrayHashMapUnmanaged(u64, ArchetypeStorage) = .{},
    counter: EntityId = 0,
    entities: std.AutoArrayHashMapUnmanaged(EntityId, Pointer) = .{},

    pub const Pointer = struct {
        archetype_index: u16,
        row_index: u32,
    };

    const Self = @This();

    pub fn init(allocator: Allocator) !Entities {
        var entities = Entities{ .allocator = allocator };
        try entities.archetypes.put(allocator, void_archetype_hash, ArchetypeStorage{
            .allocator = allocator,
            .components = .{},
            .hash = void_archetype_hash,
        });

        return entities;
    }

    pub fn deinit(self: *Self) void {
        var iter = self.archetypes.iterator();
        while (iter.next()) |entry| {
            entry.value_ptr.deinit();
        }
        self.archetypes.deinit(self.allocator);
    }

    pub fn initErasedStorage(entities: *const Self, total_rows: *usize, comptime Component: type) !ErasedComponentStorage {
        const new_ptr = try entities.allocator.create(ComponentStorage(Component));
        new_ptr.* = ComponentStorage(Component){ .total_rows = total_rows };

        return ErasedComponentStorage{
            .ptr = new_ptr,
            .deinit = (struct {
                pub fn deinit(erased: *anyopaque, allocator: Allocator) void {
                    var ptr = ErasedComponentStorage.cast(erased, Component);
                    ptr.deinit(allocator);
                    allocator.destroy(ptr);
                }
            }).deinit,
        };
    }
};

pub const ArchetypeStorage = struct {
    allocator: Allocator,
    hash: u64,
    components: std.StringArrayHashMapUnmanaged(ErasedComponentStorage),

    pub fn deinit(storage: *ArchetypeStorage) void {
        for (storage.components.values()) |erased| {
            erased.deinit(erased.ptr, storage.allocator);
        }
        storage.components.deinit(storage.allocator);
    }
};

pub fn ComponentStorage(comptime Component: type) type {
    return struct {
        // Total number of this component in the world
        total_rows: *usize,
        // Actual component data
        data: std.ArrayListUnmanaged(Component) = .{},

        const Self = @This();

        pub fn deinit(storage: *Self, allocator: Allocator) void {
            storage.data.deinit(allocator);
        }
    };
}

pub const ErasedComponentStorage = struct {
    ptr: *anyopaque,
    deinit: fn (erased: *anyopaque, allocator: Allocator) void,

    // Cast into component Storage
    // (unsafe)
    pub fn cast(ptr: *anyopaque, comptime Component: type) *ComponentStorage(Component) {
        const converted: *ComponentStorage(Component) = @ptrCast(ptr);
        return converted;
    }
};

test "newtypes" {
    const SuperInt = u32;
    const a: SuperInt = 4;
    const b: u32 = 4;

    try std.testing.expect(a == b);
}
