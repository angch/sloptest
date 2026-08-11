const std = @import("std");

pub const Response = struct {
    status: u16 = 200,
    status_text: []const u8 = "OK",
    content_type: []const u8 = "text/html; charset=utf-8",
    body: []const u8 = "",
    redirect_url: ?[]const u8 = null,
    allocator: std.mem.Allocator,
    owns_body: bool = false,

    pub fn html(allocator: std.mem.Allocator, body: []const u8) Response {
        return Response{
            .status = 200,
            .status_text = "OK",
            .content_type = "text/html; charset=utf-8",
            .body = body,
            .allocator = allocator,
            .owns_body = true,
        };
    }

    pub fn redirect(allocator: std.mem.Allocator, target_url: []const u8) !Response {
        return Response{
            .status = 302,
            .status_text = "Found",
            .content_type = "text/html; charset=utf-8",
            .body = "Redirecting...",
            .redirect_url = try allocator.dupe(u8, target_url),
            .allocator = allocator,
            .owns_body = false,
        };
    }

    pub fn notFound(allocator: std.mem.Allocator) Response {
        return Response{
            .status = 404,
            .status_text = "Not Found",
            .content_type = "text/html; charset=utf-8",
            .body = "<h1>404 Not Found</h1>",
            .allocator = allocator,
            .owns_body = false,
        };
    }

    pub fn toRawHttp(self: *const Response, allocator: std.mem.Allocator) ![]const u8 {
        var buf: std.ArrayList(u8) = .empty;
        defer buf.deinit(allocator);

        const writer = buf.writer(allocator);

        try writer.print("HTTP/1.1 {d} {s}\r\n", .{ self.status, self.status_text });
        try writer.print("Content-Type: {s}\r\n", .{self.content_type});
        try writer.print("Content-Length: {d}\r\n", .{self.body.len});

        if (self.redirect_url) |url| {
            try writer.print("Location: {s}\r\n", .{url});
        }

        try writer.writeAll("Connection: close\r\n\r\n");
        try writer.writeAll(self.body);

        return buf.toOwnedSlice(allocator);
    }

    pub fn deinit(self: *Response) void {
        if (self.owns_body and self.body.len > 0) {
            self.allocator.free(self.body);
        }
        if (self.redirect_url) |url| {
            self.allocator.free(url);
        }
    }
};
