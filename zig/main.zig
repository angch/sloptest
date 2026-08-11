const std = @import("std");
const config_db = @import("config/database.zig");
const routes = @import("config/routes.zig");
const Router = @import("src/rails/router.zig").Router;
const HttpServer = @import("src/rails/http_server.zig").HttpServer;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("==================================================\n", .{});
    std.debug.print("  🐾 Paws & Homes - Pet Adoption Shop (Zig + Rails)\n", .{});
    std.debug.print("==================================================\n", .{});

    // Step 1: Initialize Database & Run Migrations / Seeding
    std.debug.print("[DB] Initializing SQLite database at {s}...\n", .{config_db.DB_PATH});
    try config_db.initAndSeed(allocator);

    // Step 2: Draw Routes into Router
    var router = Router.init(allocator);
    defer router.deinit();
    try routes.drawRoutes(&router);
    std.debug.print("[Router] Routes initialized successfully.\n", .{});

    // Step 3: Start HTTP Server
    const port: u16 = 3000;
    var server = HttpServer.init(port, &router);
    try server.listen();
}
