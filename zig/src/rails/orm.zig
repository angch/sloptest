const std = @import("std");
const Db = @import("db.zig").Db;
const Stmt = @import("db.zig").Stmt;
const config_db = @import("../../config/database.zig");

/// Compile-time helper to generate comma-separated column names for struct T
pub fn selectColumns(comptime T: type) []const u8 {
    comptime {
        var sql: []const u8 = "";
        const fields = std.meta.fields(T);
        for (fields, 0..) |field, idx| {
            if (idx > 0) sql = sql ++ ", ";
            sql = sql ++ field.name;
        }
        return sql;
    }
}

/// Infer table name from struct T (defaulting to lowercased type name or T.table_name)
pub fn tableName(comptime T: type) []const u8 {
    if (@hasDecl(T, "table_name")) {
        return T.table_name;
    } else {
        comptime {
            const raw_name = @typeName(T);
            var name = raw_name;
            if (std.mem.lastIndexOfScalar(u8, raw_name, '.')) |idx| {
                name = raw_name[idx + 1 ..];
            }
            return name;
        }
    }
}

/// Reflectively map a SQLite row to struct instance T
pub fn mapRow(comptime T: type, allocator: std.mem.Allocator, stmt: *Stmt) !T {
    var instance: T = undefined;
    const fields = std.meta.fields(T);
    inline for (fields, 0..) |field, i| {
        const col: c_int = @intCast(i);
        switch (field.type) {
            i64 => {
                @field(instance, field.name) = stmt.getColumnInt(col);
            },
            c_int, i32 => {
                @field(instance, field.name) = @intCast(stmt.getColumnInt(col));
            },
            bool => {
                @field(instance, field.name) = (stmt.getColumnInt(col) != 0);
            },
            []const u8 => {
                const text = stmt.getColumnText(col);
                @field(instance, field.name) = try allocator.dupe(u8, text);
            },
            else => {
                @compileError("Unsupported ORM field type: " ++ @typeName(field.type));
            },
        }
    }
    return instance;
}

/// Reflectively free allocated string fields of struct instance T
pub fn deinitStruct(comptime T: type, allocator: std.mem.Allocator, instance: *T) void {
    const fields = std.meta.fields(T);
    inline for (fields) |field| {
        if (field.type == []const u8) {
            const val = @field(instance, field.name);
            if (val.len > 0) {
                allocator.free(val);
            }
        }
    }
}

/// Reflectively free allocated slice of struct instances
pub fn deinitSlice(comptime T: type, allocator: std.mem.Allocator, slice: []T) void {
    for (slice) |*item| {
        deinitStruct(T, allocator, item);
    }
    allocator.free(slice);
}

/// Generic ORM Model interface providing active record operations
pub fn Model(comptime T: type) type {
    const table = tableName(T);
    const cols = selectColumns(T);

    return struct {
        /// Find record by ID using reflection
        pub fn find(allocator: std.mem.Allocator, id: i64) !?T {
            var db = try config_db.getDb();
            defer db.close();

            const sql = "SELECT " ++ cols ++ " FROM " ++ table ++ " WHERE id = ?";
            var stmt = try db.prepare(sql);
            defer stmt.deinit();

            try stmt.bindInt(1, id);

            if (try stmt.step()) {
                return try mapRow(T, allocator, &stmt);
            }
            return null;
        }

        /// Fetch all records ordered by ID DESC using reflection
        pub fn all(allocator: std.mem.Allocator) ![]T {
            var db = try config_db.getDb();
            defer db.close();

            const sql = "SELECT " ++ cols ++ " FROM " ++ table ++ " ORDER BY id DESC";
            var stmt = try db.prepare(sql);
            defer stmt.deinit();

            var list: std.ArrayList(T) = .empty;
            errdefer freeSlice(allocator, list.items);

            while (try stmt.step()) {
                const item = try mapRow(T, allocator, &stmt);
                try list.append(allocator, item);
            }

            return list.toOwnedSlice(allocator);
        }

        /// Execute a custom SELECT query and reflectively map rows to T
        pub fn querySql(allocator: std.mem.Allocator, sql_z: [:0]const u8) ![]T {
            var db = try config_db.getDb();
            defer db.close();

            var stmt = try db.prepare(sql_z);
            defer stmt.deinit();

            var list: std.ArrayList(T) = .empty;
            errdefer freeSlice(allocator, list.items);

            while (try stmt.step()) {
                const item = try mapRow(T, allocator, &stmt);
                try list.append(allocator, item);
            }

            return list.toOwnedSlice(allocator);
        }

        /// Update a single column value by ID
        pub fn updateColumn(id: i64, comptime col_name: []const u8, value: []const u8) !void {
            var db = try config_db.getDb();
            defer db.close();

            const sql = "UPDATE " ++ table ++ " SET " ++ col_name ++ " = ? WHERE id = ?";
            var stmt = try db.prepare(sql);
            defer stmt.deinit();

            try stmt.bindText(1, value);
            try stmt.bindInt(2, id);

            _ = try stmt.step();
        }

        /// Dynamic Query Builder for T
        pub const Query = struct {
            allocator: std.mem.Allocator,
            buf: std.ArrayList(u8),

            pub fn init(allocator: std.mem.Allocator) Query {
                var q = Query{
                    .allocator = allocator,
                    .buf = .empty,
                };
                const writer = q.buf.writer(allocator);
                writer.writeAll("SELECT " ++ cols ++ " FROM " ++ table ++ " WHERE 1=1") catch {};
                return q;
            }

            pub fn deinit(self: *Query) void {
                self.buf.deinit(self.allocator);
            }

            pub fn whereEq(self: *Query, col_name: []const u8, val: []const u8) !void {
                const writer = self.buf.writer(self.allocator);
                try writer.print(" AND {s} = '{s}'", .{ col_name, val });
            }

            pub fn whereLikeGroup(self: *Query, col_names: []const []const u8, val: []const u8) !void {
                const writer = self.buf.writer(self.allocator);
                try writer.writeAll(" AND (");
                for (col_names, 0..) |col, idx| {
                    if (idx > 0) try writer.writeAll(" OR ");
                    try writer.print("{s} LIKE '%{s}%'", .{ col, val });
                }
                try writer.writeAll(")");
            }

            pub fn orderBy(self: *Query, order_clause: []const u8) !void {
                const writer = self.buf.writer(self.allocator);
                try writer.print(" ORDER BY {s}", .{order_clause});
            }

            pub fn execute(self: *Query) ![]T {
                const raw = self.buf.items;
                const sql_z = try self.allocator.dupeZ(u8, raw);
                defer self.allocator.free(sql_z);

                return try querySql(self.allocator, sql_z);
            }
        };

        pub fn query(allocator: std.mem.Allocator) Query {
            return Query.init(allocator);
        }

        /// Reflective memory cleanup for T
        pub fn freeSlice(allocator: std.mem.Allocator, slice: []T) void {
            for (slice) |*item| {
                deinitStruct(T, allocator, item);
            }
            allocator.free(slice);
        }
    };
}
