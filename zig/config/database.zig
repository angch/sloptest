const std = @import("std");
const Db = @import("../src/rails/db.zig").Db;

pub const DB_PATH = "db/pets.db";

pub fn getDb() !Db {
    return try Db.open(DB_PATH);
}

pub fn initAndSeed(allocator: std.mem.Allocator) !void {
    var db = try Db.open(DB_PATH);
    defer db.close();

    const schema = try std.fs.cwd().readFileAlloc(allocator, "db/schema.sql", 1024 * 1024);
    defer allocator.free(schema);

    // Convert schema slice to null-terminated string for SQLite
    const schema_z = try allocator.dupeZ(u8, schema);
    defer allocator.free(schema_z);

    try db.exec(schema_z);

    // Check if pets table is empty, if so run seed
    var stmt = try db.prepare("SELECT COUNT(*) FROM pets");
    defer stmt.deinit();

    if (try stmt.step()) {
        const count = stmt.getColumnInt(0);
        if (count == 0) {
            std.debug.print("[DB] Seeding initial pet adoption data...\n", .{});
            const seed = try std.fs.cwd().readFileAlloc(allocator, "db/seed.sql", 1024 * 1024);
            defer allocator.free(seed);

            const seed_z = try allocator.dupeZ(u8, seed);
            defer allocator.free(seed_z);

            try db.exec(seed_z);
            std.debug.print("[DB] Database successfully seeded!\n", .{});
        }
    }
}
