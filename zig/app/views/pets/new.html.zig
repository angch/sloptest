const std = @import("std");
const Erb = @import("../../../src/rails/erb.zig");

pub fn render(allocator: std.mem.Allocator) ![]const u8 {
    return Erb.renderPetNew(allocator);
}
