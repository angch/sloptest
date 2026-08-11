const std = @import("std");
const Request = @import("request.zig").Request;
const Response = @import("response.zig").Response;
const Router = @import("router.zig").Router;

pub const HttpServer = struct {
    port: u16,
    router: *Router,

    pub fn init(port: u16, router: *Router) HttpServer {
        return HttpServer{
            .port = port,
            .router = router,
        };
    }

    pub fn listen(self: *HttpServer) !void {
        const address = try std.net.Address.parseIp4("127.0.0.1", self.port);
        var listener = try address.listen(.{ .reuse_address = true });
        defer listener.deinit();

        std.debug.print("\n🐾 Paws & Homes Pet Adoption Server running on http://127.0.0.1:{d}\n", .{self.port});

        while (true) {
            const conn = listener.accept() catch |err| {
                std.debug.print("Accept error: {}\n", .{err});
                continue;
            };
            self.handleConnection(conn) catch |err| {
                std.debug.print("Connection handler error: {}\n", .{err});
            };
        }
    }

    fn handleConnection(self: *HttpServer, conn: std.net.Server.Connection) !void {
        defer conn.stream.close();

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const allocator = arena.allocator();

        var buf: [64 * 1024]u8 = undefined;
        const bytes_read = conn.stream.read(&buf) catch return;
        if (bytes_read == 0) return;

        const raw_req = buf[0..bytes_read];
        var req = try Request.init(allocator, raw_req);
        defer req.deinit();

        var resp = self.router.dispatch(allocator, &req) catch |err| {
            std.debug.print("Dispatch error: {}\n", .{err});
            var err_resp = Response{
                .status = 500,
                .status_text = "Internal Server Error",
                .content_type = "text/html; charset=utf-8",
                .body = "<h1>500 Internal Server Error</h1>",
                .allocator = allocator,
            };
            const err_bytes = try err_resp.toRawHttp(allocator);
            _ = try conn.stream.writeAll(err_bytes);
            return;
        };
        defer resp.deinit();

        const resp_bytes = try resp.toRawHttp(allocator);
        _ = try conn.stream.writeAll(resp_bytes);
    }
};
