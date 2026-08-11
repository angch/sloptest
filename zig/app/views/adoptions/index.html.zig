const std = @import("std");
const AdoptionRequest = @import("../../models/adoption_request.zig").AdoptionRequest;
const Erb = @import("../../../src/rails/erb.zig");

pub fn render(allocator: std.mem.Allocator, requests: []AdoptionRequest) ![]const u8 {
    return Erb.renderAdoptionsIndex(allocator, requests);
}
