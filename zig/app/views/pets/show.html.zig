const std = @import("std");
const Pet = @import("../../models/pet.zig").Pet;
const helpers = @import("../../helpers/view_helper.zig");

pub fn render(allocator: std.mem.Allocator, pet: Pet) ![]const u8 {
    var buf = std.ArrayList(u8).init(allocator);
    errdefer buf.deinit();

    const writer = buf.writer();

    try writer.writeAll(
        \\<div style="margin-bottom: 1.5rem;">
        \\  <a href="/pets" style="color: var(--text-muted); font-weight: 600; font-size: 0.9rem;">&larr; Back to all pets</a>
        \\</div>
        \\
        \\<div class="pet-detail-container">
        \\  <div>
        \\    <img src="
    );
    try writer.print("{s}", .{pet.image_url});
    try writer.writeAll(
        \\" alt="
    );
    try writer.print("{s}", .{pet.name});
    try writer.writeAll(
        \\" class="pet-detail-img">
        \\  </div>
        \\  
        \\  <div class="pet-detail-info">
        \\    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 0.5rem;">
        \\      <h1>
    );
    try writer.print("{s}", .{pet.name});
    try writer.writeAll(
        \\</h1>
        \\      <span class="badge-status 
    );
    try writer.print("{s}", .{pet.status});
    try writer.writeAll(
        \\" style="position: static;">
    );
    try writer.print("{s}", .{pet.status});
    try writer.writeAll(
        \\</span>
        \\    </div>
        \\    
        \\    <div style="font-size: 1.25rem; font-weight: 700; color: var(--primary); margin-bottom: 1rem;">
    );
    try writer.print("{s} &bull; {s}", .{ pet.breed, helpers.speciesEmoji(pet.species) });
    try writer.writeAll(
        \\</div>
        \\    
        \\    <div class="info-grid">
        \\      <div class="info-item">
        \\        <span class="label">Age</span>
        \\        <span class="value">
    );
    try writer.print("{d} months", .{pet.age});
    try writer.writeAll(
        \\</span>
        \\      </div>
        \\      <div class="info-item">
        \\        <span class="label">Gender</span>
        \\        <span class="value">
    );
    try writer.print("{s}", .{pet.gender});
    try writer.writeAll(
        \\</span>
        \\      </div>
        \\      <div class="info-item">
        \\        <span class="label">Size</span>
        \\        <span class="value">
    );
    try writer.print("{s}", .{pet.size});
    try writer.writeAll(
        \\</span>
        \\      </div>
        \\      <div class="info-item">
        \\        <span class="label">Location</span>
        \\        <span class="value">
    );
    try writer.print("{s}", .{pet.location});
    try writer.writeAll(
        \\</span>
        \\      </div>
        \\    </div>
        \\    
        \\    <h3 style="font-size: 1.1rem; font-weight: 800; margin-bottom: 0.5rem; color: var(--dark);">About 
    );
    try writer.print("{s}", .{pet.name});
    try writer.writeAll(
        \\</h3>
        \\    <p style="color: var(--text-main); line-height: 1.8; margin-bottom: 2rem;">
    );
    try writer.print("{s}", .{pet.description});
    try writer.writeAll(
        \\</p>
        \\    
        \\    <div style="display: flex; gap: 1rem;">
        \\      <a href="#" class="btn btn-primary open-adoption-modal" data-pet-id="
    );
    try writer.print("{d}", .{pet.id});
    try writer.writeAll(
        \\" data-pet-name="
    );
    try writer.print("{s}", .{pet.name});
    try writer.writeAll(
        \\" style="flex: 1;">Apply to Adopt 
    );
    try writer.print("{s}", .{pet.name});
    try writer.writeAll(
        \\</a>
        \\    </div>
        \\  </div>
        \\</div>
        \\
        \\<!-- Adoption Modal -->
        \\<div class="modal-overlay" id="adoption-modal">
        \\  <div class="modal-card">
        \\    <button class="modal-close">&times;</button>
        \\    <h2 style="font-size: 1.5rem; font-weight: 800; margin-bottom: 0.5rem;">Adopt <span id="modal-pet-name" style="color: var(--primary);">Pet</span></h2>
        \\    <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1.5rem;">Fill out this quick adoption application and our shelter team will get in touch with you shortly.</p>
        \\    
        \\    <form action="/adoptions" method="POST">
        \\      <input type="hidden" name="pet_id" id="modal-pet-id" value="
    );
    try writer.print("{d}", .{pet.id});
    try writer.writeAll(
        \\">
        \\      
        \\      <div class="form-group" style="margin-bottom: 1rem;">
        \\        <label class="form-label">Your Full Name</label>
        \\        <input type="text" name="applicant_name" class="form-control" placeholder="e.g. Jane Doe" required>
        \\      </div>
        \\      
        \\      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;">
        \\        <div class="form-group">
        \\          <label class="form-label">Email Address</label>
        \\          <input type="email" name="email" class="form-control" placeholder="jane@example.com" required>
        \\        </div>
        \\        <div class="form-group">
        \\          <label class="form-label">Phone Number</label>
        \\          <input type="tel" name="phone" class="form-control" placeholder="(555) 123-4567" required>
        \\        </div>
        \\      </div>
        \\      
        \\      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;">
        \\        <div class="form-group">
        \\          <label class="form-label">Housing Type</label>
        \\          <select name="housing_type" class="form-select">
        \\            <option value="House">House</option>
        \\            <option value="Apartment">Apartment</option>
        \\            <option value="Condo">Condo</option>
        \\          </select>
        \\        </div>
        \\        <div class="form-group">
        \\          <label class="form-label">Fenced Yard?</label>
        \\          <select name="has_yard" class="form-select">
        \\            <option value="1">Yes</option>
        \\            <option value="0">No</option>
        \\          </select>
        \\        </div>
        \\      </div>
        \\      
        \\      <div class="form-group" style="margin-bottom: 1rem;">
        \\        <label class="form-label">Current Pets in Home</label>
        \\        <input type="text" name="other_pets" class="form-control" placeholder="e.g. 1 senior cat, none">
        \\      </div>
        \\      
        \\      <div class="form-group" style="margin-bottom: 1.5rem;">
        \\        <label class="form-label">Pet Care Experience</label>
        \\        <textarea name="experience" class="form-control" rows="3" placeholder="Tell us a little about your experience caring for pets..."></textarea>
        \\      </div>
        \\      
        \\      <button type="submit" class="btn btn-primary" style="width: 100%;">Submit Adoption Application</button>
        \\    </form>
        \\  </div>
        \\</div>
    );

    const body = try buf.toOwnedSlice();
    const title = try std.fmt.allocPrint(allocator, "Meet {s}", .{pet.name});
    defer allocator.free(title);

    return try helpers.renderLayout(allocator, title, body, "pets");
}
