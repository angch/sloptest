const std = @import("std");

pub const Request = struct {
    method: []const u8,
    path: []const u8,
    query_string: []const u8,
    body: []const u8,
    params: std.StringHashMap([]const u8),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, raw_request: []const u8) !Request {
        var req = Request{
            .method = "GET",
            .path = "/",
            .query_string = "",
            .body = "",
            .params = std.StringHashMap([]const u8).init(allocator),
            .allocator = allocator,
        };

        // Split head and body
        var body_start: usize = raw_request.len;
        if (std.mem.indexOf(u8, raw_request, "\r\n\r\n")) |idx| {
            body_start = idx + 4;
            req.body = raw_request[body_start..];
        }

        const head = raw_request[0..body_start];
        var lines = std.mem.splitSequence(u8, head, "\r\n");
        if (lines.next()) |first_line| {
            var parts = std.mem.splitScalar(u8, first_line, ' ');
            if (parts.next()) |m| req.method = m;
            if (parts.next()) |full_path| {
                if (std.mem.indexOfScalar(u8, full_path, '?')) |q_idx| {
                    req.path = full_path[0..q_idx];
                    req.query_string = full_path[q_idx + 1 ..];
                } else {
                    req.path = full_path;
                }
            }
        }

        // Parse query string into params
        try parseUrlEncoded(&req.params, req.query_string, allocator);

        // Parse body if form-urlencoded
        if (req.body.len > 0) {
            try parseUrlEncoded(&req.params, req.body, allocator);
        }

        return req;
    }

    pub fn getParam(self: *const Request, key: []const u8) []const u8 {
        return self.params.get(key) orelse "";
    }

    pub fn deinit(self: *Request) void {
        var it = self.params.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            self.allocator.free(entry.value_ptr.*);
        }
        self.params.deinit();
    }
};

fn parseUrlEncoded(map: *std.StringHashMap([]const u8), input: []const u8, allocator: std.mem.Allocator) !void {
    if (input.len == 0) return;
    var pairs = std.mem.splitScalar(u8, input, '&');
    while (pairs.next()) |pair| {
        if (pair.len == 0) continue;
        var kv = std.mem.splitScalar(u8, pair, '=');
        const k_raw = kv.next() orelse continue;
        const v_raw = kv.next() orelse "";

        const key = try urlDecode(allocator, k_raw);
        const val = try urlDecode(allocator, v_raw);

        try putOrReplace(map, key, val, allocator);
    }
}

fn putOrReplace(map: *std.StringHashMap([]const u8), key: []const u8, val: []const u8, allocator: std.mem.Allocator) !void {
    const res = try map.getOrPut(key);
    if (res.found_existing) {
        allocator.free(key);
        allocator.free(res.value_ptr.*);
        res.value_ptr.* = val;
    } else {
        res.value_ptr.* = val;
    }
}

fn urlDecode(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var out: std.ArrayList(u8) = .empty;
    defer out.deinit(allocator);

    var i: usize = 0;
    while (i < input.len) {
        if (input[i] == '+') {
            try out.append(allocator, ' ');
            i += 1;
        } else if (input[i] == '%' and i + 2 < input.len) {
            const hex = input[i + 1 .. i + 3];
            const byte = std.fmt.parseInt(u8, hex, 16) catch ' ';
            try out.append(allocator, byte);
            i += 3;
        } else {
            try out.append(allocator, input[i]);
            i += 1;
        }
    }

    return out.toOwnedSlice(allocator);
}
