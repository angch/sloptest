const std = @import("std");
const orm = @import("../../src/rails/orm.zig");
const Db = @import("../../src/rails/db.zig").Db;
const config_db = @import("../../config/database.zig");

pub const Pet = struct {
    pub const table_name = "pets";

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
        return try orm.Model(Pet).find(allocator, id);
    }

    pub fn where(allocator: std.mem.Allocator, species_filter: []const u8, status_filter: []const u8, search_query: []const u8) ![]Pet {
        var q = orm.Model(Pet).query(allocator);
        defer q.deinit();

        if (species_filter.len > 0 and !std.mem.eql(u8, species_filter, "All")) {
            try q.whereEq("species", species_filter);
        }
        if (status_filter.len > 0 and !std.mem.eql(u8, status_filter, "All")) {
            try q.whereEq("status", status_filter);
        }
        if (search_query.len > 0) {
            try q.whereLikeGroup(&[_][]const u8{ "name", "breed", "description" }, search_query);
        }
        try q.orderBy("id DESC");

        return try q.execute();
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
        try orm.Model(Pet).updateColumn(id, "status", new_status);
    }

    pub fn deinitSlice(allocator: std.mem.Allocator, pets: []Pet) void {
        orm.deinitSlice(Pet, allocator, pets);
    }
};
