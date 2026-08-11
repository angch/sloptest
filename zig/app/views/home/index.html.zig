const std = @import("std");
const Pet = @import("../../models/pet.zig").Pet;
const Erb = @import("../../../src/rails/erb.zig");

pub fn render(allocator: std.mem.Allocator, featured_pets: []Pet) ![]const u8 {
    return Erb.renderHomeIndex(allocator, featured_pets);
}
