const std = @import("std");

pub fn speciesEmoji(species: []const u8) []const u8 {
    if (std.mem.eql(u8, species, "Dog")) return "🐶 Dog";
    if (std.mem.eql(u8, species, "Cat")) return "🐱 Cat";
    if (std.mem.eql(u8, species, "Rabbit")) return "🐰 Rabbit";
    if (std.mem.eql(u8, species, "Bird")) return "🦜 Bird";
    return "🐾 Other";
}

pub fn renderLayout(allocator: std.mem.Allocator, title: []const u8, content: []const u8, active_nav: []const u8) ![]const u8 {
    var buf = std.ArrayList(u8).init(allocator);
    errdefer buf.deinit();

    const writer = buf.writer();

    try writer.writeAll(
        \\<!DOCTYPE html>
        \\<html lang="en">
        \\<head>
        \\  <meta charset="UTF-8">
        \\  <meta name="viewport" content="width=device-width, initial-scale=1.0">
        \\  <title>
    );
    try writer.print("{s} - Paws & Homes Pet Adoption</title>\n", .{title});
    try writer.writeAll(
        \\  <link rel="stylesheet" href="/css/application.css">
        \\</head>
        \\<body>
        \\  <!-- Navbar -->
        \\  <nav class="navbar">
        \\    <div class="nav-container">
        \\      <a href="/" class="brand">
        \\        <span class="brand-icon">🐾</span>
        \\        <span>Paws & Homes</span>
        \\      </a>
        \\      <ul class="nav-links">
        \\        <li><a href="/" class="nav-link 
    );
    if (std.mem.eql(u8, active_nav, "home")) try writer.writeAll("active");
    try writer.writeAll(
        \\">Home</a></li>
        \\        <li><a href="/pets" class="nav-link 
    );
    if (std.mem.eql(u8, active_nav, "pets")) try writer.writeAll("active");
    try writer.writeAll(
        \\">Adoptable Pets</a></li>
        \\        <li><a href="/adoptions" class="nav-link 
    );
    if (std.mem.eql(u8, active_nav, "adoptions")) try writer.writeAll("active");
    try writer.writeAll(
        \\">Adoption Requests</a></li>
        \\        <li><a href="/pets/new" class="btn btn-primary btn-sm">+ List a Pet</a></li>
        \\      </ul>
        \\    </div>
        \\  </nav>
        \\
        \\  <!-- Main Body -->
        \\  <main class="container">
        \\
    );

    try writer.writeAll(content);

    try writer.writeAll(
        \\
        \\  </main>
        \\
        \\  <!-- Footer -->
        \\  <footer class="footer">
        \\    <div class="footer-container">
        \\      <div>
        \\        <div class="footer-brand">🐾 Paws & Homes</div>
        \\        <p>Connecting loving families with animals in need. Structured with Zig & Rails MVC Architecture.</p>
        \\      </div>
        \\      <div>
        \\        <h4 style="color: white; margin-bottom: 0.75rem;">Quick Links</h4>
        \\        <p><a href="/pets">Available Pets</a></p>
        \\        <p><a href="/pets/new">Add New Pet</a></p>
        \\        <p><a href="/adoptions">Applications</a></p>
        \\      </div>
        \\      <div>
        \\        <h4 style="color: white; margin-bottom: 0.75rem;">Contact Us</h4>
        \\        <p>📍 100 Adopt Me Way, SF</p>
        \\        <p>📞 (555) 019-2834</p>
        \\        <p>✉️ hello@pawshomes.org</p>
        \\      </div>
        \\    </div>
        \\    <div class="footer-copy">
        \\      &copy; 2026 Paws & Homes Pet Adoption Shop. Built in Zig (Rails MVC structure).
        \\    </div>
        \\  </footer>
        \\
        \\  <script src="/js/application.js"></script>
        \\</body>
        \\</html>
    );

    return try buf.toOwnedSlice();
}
