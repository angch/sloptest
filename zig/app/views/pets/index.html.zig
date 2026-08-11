const std = @import("std");
const Pet = @import("../../models/pet.zig").Pet;
const Erb = @import("../../../src/rails/erb.zig");

pub fn render(allocator: std.mem.Allocator, pets: []Pet, current_species: []const u8, current_status: []const u8, current_search: []const u8) ![]const u8 {
    return Erb.renderPetsIndex(allocator, pets, current_species, current_status, current_search);
}
