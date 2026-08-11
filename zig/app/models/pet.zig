const std = @import("std");
const Db = @import("../../src/rails/db.zig").Db;
const config_db = @import("../../config/database.zig");

pub const Pet = struct {
    id: i64,
    name: []const u8,
    species: []const u8,
    breed: []const u8,
    age: i64,
    gender: []const u8,
    size: []const u8,
    description: []const u8,
    image_url: []const u8,
    status: []const u8,
    location: []const u8,
    created_at: []const u8,

    pub fn find(allocator: std.mem.Allocator, id: i64) !?Pet {
        var db = try config_db.getDb();
        defer db.close();

        var stmt = try db.prepare("SELECT id, name, species, breed, age, gender, size, description, image_url, status, location, created_at FROM pets WHERE id = ?");
        defer stmt.deinit();

        try stmt.bindInt(1, id);

        if (try stmt.step()) {
            return Pet{
                .id = stmt.getColumnInt(0),
                .name = try allocator.dupe(u8, stmt.getColumnText(1)),
                .species = try allocator.dupe(u8, stmt.getColumnText(2)),
                .breed = try allocator.dupe(u8, stmt.getColumnText(3)),
                .age = stmt.getColumnInt(4),
                .gender = try allocator.dupe(u8, stmt.getColumnText(5)),
                .size = try allocator.dupe(u8, stmt.getColumnText(6)),
                .description = try allocator.dupe(u8, stmt.getColumnText(7)),
                .image_url = try allocator.dupe(u8, stmt.getColumnText(8)),
                .status = try allocator.dupe(u8, stmt.getColumnText(9)),
                .location = try allocator.dupe(u8, stmt.getColumnText(10)),
                .created_at = try allocator.dupe(u8, stmt.getColumnText(11)),
            };
        }
        return null;
    }

    pub fn where(allocator: std.mem.Allocator, species_filter: []const u8, status_filter: []const u8, search_query: []const u8) ![]Pet {
        var db = try config_db.getDb();
        defer db.close();

        var query_buf: [1024]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&query_buf);
        const writer = fbs.writer();

        try writer.writeAll("SELECT id, name, species, breed, age, gender, size, description, image_url, status, location, created_at FROM pets WHERE 1=1");

        if (species_filter.len > 0 and !std.mem.eql(u8, species_filter, "All")) {
            try writer.print(" AND species = '{s}'", .{species_filter});
        }
        if (status_filter.len > 0 and !std.mem.eql(u8, status_filter, "All")) {
            try writer.print(" AND status = '{s}'", .{status_filter});
        }
        if (search_query.len > 0) {
            try writer.print(" AND (name LIKE '%{s}%' OR breed LIKE '%{s}%' OR description LIKE '%{s}%')", .{ search_query, search_query, search_query });
        }
        try writer.writeAll(" ORDER BY id DESC");

        const sql = fbs.getWritten();
        const sql_z = try allocator.dupeZ(u8, sql);
        defer allocator.free(sql_z);

        var stmt = try db.prepare(sql_z);
        defer stmt.deinit();

        var pets_list: std.ArrayList(Pet) = .empty;

        while (try stmt.step()) {
            const pet = Pet{
                .id = stmt.getColumnInt(0),
                .name = try allocator.dupe(u8, stmt.getColumnText(1)),
                .species = try allocator.dupe(u8, stmt.getColumnText(2)),
                .breed = try allocator.dupe(u8, stmt.getColumnText(3)),
                .age = stmt.getColumnInt(4),
                .gender = try allocator.dupe(u8, stmt.getColumnText(5)),
                .size = try allocator.dupe(u8, stmt.getColumnText(6)),
                .description = try allocator.dupe(u8, stmt.getColumnText(7)),
                .image_url = try allocator.dupe(u8, stmt.getColumnText(8)),
                .status = try allocator.dupe(u8, stmt.getColumnText(9)),
                .location = try allocator.dupe(u8, stmt.getColumnText(10)),
                .created_at = try allocator.dupe(u8, stmt.getColumnText(11)),
            };
            try pets_list.append(allocator, pet);
        }

        return pets_list.toOwnedSlice(allocator);
    }

    pub fn create(allocator: std.mem.Allocator, name: []const u8, species: []const u8, breed: []const u8, age: i64, gender: []const u8, size: []const u8, description: []const u8, image_url: []const u8, location: []const u8) !i64 {
        _ = allocator;
        var db = try config_db.getDb();
        defer db.close();

        var stmt = try db.prepare("INSERT INTO pets (name, species, breed, age, gender, size, description, image_url, status, location) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Available', ?)");
        defer stmt.deinit();

        try stmt.bindText(1, name);
        try stmt.bindText(2, species);
        try stmt.bindText(3, breed);
        try stmt.bindInt(4, age);
        try stmt.bindText(5, gender);
        try stmt.bindText(6, size);
        try stmt.bindText(7, description);
        try stmt.bindText(8, if (image_url.len > 0) image_url else "/images/hero.jpg");
        try stmt.bindText(9, location);

        _ = try stmt.step();

        var count_stmt = try db.prepare("SELECT last_insert_rowid()");
        defer count_stmt.deinit();
        if (try count_stmt.step()) {
            return count_stmt.getColumnInt(0);
        }
        return 0;
    }

    pub fn updateStatus(id: i64, new_status: []const u8) !void {
        var db = try config_db.getDb();
        defer db.close();

        var stmt = try db.prepare("UPDATE pets SET status = ? WHERE id = ?");
        defer stmt.deinit();

        try stmt.bindText(1, new_status);
        try stmt.bindInt(2, id);

        _ = try stmt.step();
    }

    pub fn deinitSlice(allocator: std.mem.Allocator, pets: []Pet) void {
        for (pets) |pet| {
            allocator.free(pet.name);
            allocator.free(pet.species);
            allocator.free(pet.breed);
            allocator.free(pet.gender);
            allocator.free(pet.size);
            allocator.free(pet.description);
            allocator.free(pet.image_url);
            allocator.free(pet.status);
            allocator.free(pet.location);
            allocator.free(pet.created_at);
        }
        allocator.free(pets);
    }
};
