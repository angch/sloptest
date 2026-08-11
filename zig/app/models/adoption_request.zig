const std = @import("std");
const Db = @import("../../src/rails/db.zig").Db;
const config_db = @import("../../config/database.zig");

pub const AdoptionRequest = struct {
    id: i64,
    pet_id: i64,
    pet_name: []const u8,
    applicant_name: []const u8,
    email: []const u8,
    phone: []const u8,
    housing_type: []const u8,
    has_yard: bool,
    other_pets: []const u8,
    experience: []const u8,
    status: []const u8,
    notes: []const u8,
    created_at: []const u8,

    pub fn all(allocator: std.mem.Allocator) ![]AdoptionRequest {
        var db = try config_db.getDb();
        defer db.close();

        const sql = "SELECT a.id, a.pet_id, COALESCE(p.name, 'Unknown Pet'), a.applicant_name, a.email, a.phone, a.housing_type, a.has_yard, a.other_pets, a.experience, a.status, a.notes, a.created_at FROM adoptions a LEFT JOIN pets p ON a.pet_id = p.id ORDER BY a.id DESC";

        var stmt = try db.prepare(sql);
        defer stmt.deinit();

        var list: std.ArrayList(AdoptionRequest) = .empty;

        while (try stmt.step()) {
            const req = AdoptionRequest{
                .id = stmt.getColumnInt(0),
                .pet_id = stmt.getColumnInt(1),
                .pet_name = try allocator.dupe(u8, stmt.getColumnText(2)),
                .applicant_name = try allocator.dupe(u8, stmt.getColumnText(3)),
                .email = try allocator.dupe(u8, stmt.getColumnText(4)),
                .phone = try allocator.dupe(u8, stmt.getColumnText(5)),
                .housing_type = try allocator.dupe(u8, stmt.getColumnText(6)),
                .has_yard = stmt.getColumnInt(7) != 0,
                .other_pets = try allocator.dupe(u8, stmt.getColumnText(8)),
                .experience = try allocator.dupe(u8, stmt.getColumnText(9)),
                .status = try allocator.dupe(u8, stmt.getColumnText(10)),
                .notes = try allocator.dupe(u8, stmt.getColumnText(11)),
                .created_at = try allocator.dupe(u8, stmt.getColumnText(12)),
            };
            try list.append(allocator, req);
        }

        return list.toOwnedSlice(allocator);
    }

    pub fn create(allocator: std.mem.Allocator, pet_id: i64, applicant_name: []const u8, email: []const u8, phone: []const u8, housing_type: []const u8, has_yard: bool, other_pets: []const u8, experience: []const u8) !i64 {
        _ = allocator;
        var db = try config_db.getDb();
        defer db.close();

        var stmt = try db.prepare("INSERT INTO adoptions (pet_id, applicant_name, email, phone, housing_type, has_yard, other_pets, experience, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Submitted')");
        defer stmt.deinit();

        try stmt.bindInt(1, pet_id);
        try stmt.bindText(2, applicant_name);
        try stmt.bindText(3, email);
        try stmt.bindText(4, phone);
        try stmt.bindText(5, housing_type);
        try stmt.bindInt(6, if (has_yard) 1 else 0);
        try stmt.bindText(7, other_pets);
        try stmt.bindText(8, experience);

        _ = try stmt.step();

        // Update pet status to 'Pending'
        var update_pet = try db.prepare("UPDATE pets SET status = 'Pending' WHERE id = ?");
        defer update_pet.deinit();
        try update_pet.bindInt(1, pet_id);
        _ = try update_pet.step();

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

        var stmt = try db.prepare("UPDATE adoptions SET status = ? WHERE id = ?");
        defer stmt.deinit();

        try stmt.bindText(1, new_status);
        try stmt.bindInt(2, id);

        _ = try stmt.step();
    }

    pub fn deinitSlice(allocator: std.mem.Allocator, items: []AdoptionRequest) void {
        for (items) |req| {
            allocator.free(req.pet_name);
            allocator.free(req.applicant_name);
            allocator.free(req.email);
            allocator.free(req.phone);
            allocator.free(req.housing_type);
            allocator.free(req.other_pets);
            allocator.free(req.experience);
            allocator.free(req.status);
            allocator.free(req.notes);
            allocator.free(req.created_at);
        }
        allocator.free(items);
    }
};
