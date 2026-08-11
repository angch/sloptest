const std = @import("std");
const Request = @import("request.zig").Request;
const Response = @import("response.zig").Response;

pub const ActionFn = *const fn (allocator: std.mem.Allocator, req: *Request) anyerror!Response;

pub const Route = struct {
    method: []const u8,
    pattern: []const u8,
    action: ActionFn,
};

pub const Router = struct {
    routes: std.ArrayList(Route),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Router {
        return Router{
            .routes = .empty,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Router) void {
        self.routes.deinit(self.allocator);
    }

    pub fn get(self: *Router, pattern: []const u8, action: ActionFn) !void {
        try self.routes.append(self.allocator, Route{
            .method = "GET",
            .pattern = pattern,
            .action = action,
        });
    }

    pub fn post(self: *Router, pattern: []const u8, action: ActionFn) !void {
        try self.routes.append(self.allocator, Route{
            .method = "POST",
            .pattern = pattern,
            .action = action,
        });
    }

    pub fn dispatch(self: *Router, allocator: std.mem.Allocator, req: *Request) !Response {
        // First check static files in public/
        if (std.mem.startsWith(u8, req.path, "/css/") or
            std.mem.startsWith(u8, req.path, "/js/") or
            std.mem.startsWith(u8, req.path, "/images/") or
            std.mem.eql(u8, req.path, "/favicon.ico"))
        {
            var relative_path = req.path;
            if (relative_path[0] == '/') relative_path = relative_path[1..];
            const full_file_path = try std.fmt.allocPrint(allocator, "public/{s}", .{relative_path[0..]});
            defer allocator.free(full_file_path);

            const file = std.fs.cwd().openFile(full_file_path, .{}) catch null;
            if (file) |f| {
                defer f.close();
                const content = try f.readToEndAlloc(allocator, 10 * 1024 * 1024);

                var mime: []const u8 = "text/plain";
                if (std.mem.endsWith(u8, req.path, ".css")) mime = "text/css"
                else if (std.mem.endsWith(u8, req.path, ".js")) mime = "application/javascript"
                else if (std.mem.endsWith(u8, req.path, ".jpg") or std.mem.endsWith(u8, req.path, ".jpeg")) mime = "image/jpeg"
                else if (std.mem.endsWith(u8, req.path, ".png")) mime = "image/png"
                else if (std.mem.endsWith(u8, req.path, ".svg")) mime = "image/svg+xml"
                else if (std.mem.endsWith(u8, req.path, ".ico")) mime = "image/x-icon";

                return Response{
                    .status = 200,
                    .status_text = "OK",
                    .content_type = mime,
                    .body = content,
                    .allocator = allocator,
                    .owns_body = true,
                };
            }
        }

        // Match dynamic routes
        for (self.routes.items) |route| {
            if (!std.mem.eql(u8, route.method, req.method)) continue;

            if (matchRoute(allocator, route.pattern, req.path, &req.params)) {
                return try route.action(allocator, req);
            }
        }

        return Response.notFound(allocator);
    }
};

fn matchRoute(allocator: std.mem.Allocator, pattern: []const u8, path: []const u8, params: *std.StringHashMap([]const u8)) bool {
    var p_iter = std.mem.splitScalar(u8, pattern, '/');
    var r_iter = std.mem.splitScalar(u8, path, '/');

    while (true) {
        const p_seg = p_iter.next();
        const r_seg = r_iter.next();

        if (p_seg == null and r_seg == null) return true;
        if (p_seg == null or r_seg == null) return false;

        const p_str = p_seg.?;
        const r_str = r_seg.?;

        if (p_str.len > 0 and p_str[0] == ':') {
            // Path parameter, e.g. :id
            const param_key = p_str[1..];
            const param_val = allocator.dupe(u8, r_str) catch return false;
            const key_dup = allocator.dupe(u8, param_key) catch return false;
            const res = params.getOrPut(key_dup) catch return false;
            if (res.found_existing) {
                allocator.free(key_dup);
                allocator.free(res.value_ptr.*);
                res.value_ptr.* = param_val;
            } else {
                res.value_ptr.* = param_val;
            }
        } else if (!std.mem.eql(u8, p_str, r_str)) {
            return false;
        }
    }
}
