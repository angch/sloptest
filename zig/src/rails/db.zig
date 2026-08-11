const std = @import("std");
const c = @cImport({
    @cInclude("sqlite3.h");
});

pub const Db = struct {
    handle: ?*c.sqlite3,

    pub fn open(path: [:0]const u8) !Db {
        var db_ptr: ?*c.sqlite3 = null;
        const rc = c.sqlite3_open(path, &db_ptr);
        if (rc != c.SQLITE_OK) {
            if (db_ptr) |ptr| {
                _ = c.sqlite3_close(ptr);
            }
            return error.DatabaseOpenFailed;
        }
        return Db{ .handle = db_ptr };
    }

    pub fn close(self: *Db) void {
        if (self.handle) |ptr| {
            _ = c.sqlite3_close(ptr);
            self.handle = null;
        }
    }

    pub fn exec(self: *Db, sql: [:0]const u8) !void {
        var err_msg: [*c]u8 = null;
        const rc = c.sqlite3_exec(self.handle, sql, null, null, &err_msg);
        if (rc != c.SQLITE_OK) {
            if (err_msg) |msg| {
                std.debug.print("SQLite Exec Error: {s}\nSQL: {s}\n", .{ msg, sql });
                c.sqlite3_free(msg);
            }
            return error.SqliteExecError;
        }
    }

    pub fn prepare(self: *Db, sql: [:0]const u8) !Stmt {
        var stmt_ptr: ?*c.sqlite3_stmt = null;
        const rc = c.sqlite3_prepare_v2(self.handle, sql, -1, &stmt_ptr, null);
        if (rc != c.SQLITE_OK) {
            std.debug.print("SQLite Prepare Error: {s}\nSQL: {s}\n", .{ c.sqlite3_errmsg(self.handle), sql });
            return error.SqlitePrepareError;
        }
        return Stmt{ .handle = stmt_ptr };
    }
};

pub const Stmt = struct {
    handle: ?*c.sqlite3_stmt,

    pub fn deinit(self: *Stmt) void {
        if (self.handle) |ptr| {
            _ = c.sqlite3_finalize(ptr);
            self.handle = null;
        }
    }

    pub fn step(self: *Stmt) !bool {
        const rc = c.sqlite3_step(self.handle);
        if (rc == c.SQLITE_ROW) return true;
        if (rc == c.SQLITE_DONE) return false;
        return error.SqliteStepError;
    }

    pub fn bindText(self: *Stmt, index: c_int, text: []const u8) !void {
        const rc = c.sqlite3_bind_text(self.handle, index, text.ptr, @intCast(text.len), c.SQLITE_TRANSIENT);
        if (rc != c.SQLITE_OK) return error.SqliteBindError;
    }

    pub fn bindInt(self: *Stmt, index: c_int, value: i64) !void {
        const rc = c.sqlite3_bind_int64(self.handle, index, value);
        if (rc != c.SQLITE_OK) return error.SqliteBindError;
    }

    pub fn getColumnText(self: *Stmt, col: c_int) []const u8 {
        const ptr = c.sqlite3_column_text(self.handle, col);
        if (ptr == null) return "";
        const len = c.sqlite3_column_bytes(self.handle, col);
        return ptr[0..@intCast(len)];
    }

    pub fn getColumnInt(self: *Stmt, col: c_int) i64 {
        return c.sqlite3_column_int64(self.handle, col);
    }
};
