const std = @import("std");
const Request = @import("../../src/rails/request.zig").Request;
const Response = @import("../../src/rails/response.zig").Response;
const Pet = @import("../models/pet.zig").Pet;
const HomeView = @import("../views/home/index.html.zig");

pub fn index(allocator: std.mem.Allocator, req: *Request) !Response {
    _ = req;
    const featured = try Pet.where(allocator, "All", "Available", "");
    defer Pet.deinitSlice(allocator, featured);

    const html_content = try HomeView.render(allocator, featured);
    return Response.html(allocator, html_content);
}
