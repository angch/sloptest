const app_main = @import("../main.zig");

pub fn main() !void {
    try app_main.main();
}
