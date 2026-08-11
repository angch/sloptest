const std = @import("std");
const Pet = @import("../../models/pet.zig").Pet;
const helpers = @import("../../helpers/view_helper.zig");

pub fn render(allocator: std.mem.Allocator, pets: []Pet, current_species: []const u8, current_status: []const u8, current_search: []const u8) ![]const u8 {
    var buf = std.ArrayList(u8).init(allocator);
    errdefer buf.deinit();

    const writer = buf.writer();

    try writer.writeAll(
        \\<div class="page-header">
        \\  <div>
        \\    <h1 class="page-title">Adoptable Companions</h1>
        \\    <p class="page-subtitle">Search and filter through our animals waiting for a warm forever home</p>
        \\  </div>
        \\  <a href="/pets/new" class="btn btn-primary btn-sm">+ List a Pet</a>
        \\</div>
        \\
        \\<!-- Filter Form -->
        \\<form action="/pets" method="GET" class="filter-bar" id="filter-form">
        \\  <div class="form-group">
        \\    <label class="form-label">Search</label>
        \\    <input type="text" name="search" class="form-control" placeholder="Search by name, breed..." value="
    );
    try writer.print("{s}", .{current_search});
    try writer.writeAll(
        \\">
        \\  </div>
        \\  <div class="form-group">
        \\    <label class="form-label">Species</label>
        \\    <select name="species" class="form-select" id="species-select">
        \\      <option value="All" 
    );
    if (std.mem.eql(u8, current_species, "All") or current_species.len == 0) try writer.writeAll("selected");
    try writer.writeAll(
        \\>All Species</option>
        \\      <option value="Dog" 
    );
    if (std.mem.eql(u8, current_species, "Dog")) try writer.writeAll("selected");
    try writer.writeAll(
        \\>Dogs 🐶</option>
        \\      <option value="Cat" 
    );
    if (std.mem.eql(u8, current_species, "Cat")) try writer.writeAll("selected");
    try writer.writeAll(
        \\>Cats 🐱</option>
        \\      <option value="Rabbit" 
    );
    if (std.mem.eql(u8, current_species, "Rabbit")) try writer.writeAll("selected");
    try writer.writeAll(
        \\>Rabbits 🐰</option>
        \\      <option value="Bird" 
    );
    if (std.mem.eql(u8, current_species, "Bird")) try writer.writeAll("selected");
    try writer.writeAll(
        \\>Birds 🦜</option>
        \\    </select>
        \\  </div>
        \\  <div class="form-group">
        \\    <label class="form-label">Adoption Status</label>
        \\    <select name="status" class="form-select" id="status-select">
        \\      <option value="All" 
    );
    if (std.mem.eql(u8, current_status, "All") or current_status.len == 0) try writer.writeAll("selected");
    try writer.writeAll(
        \\>All Statuses</option>
        \\      <option value="Available" 
    );
    if (std.mem.eql(u8, current_status, "Available")) try writer.writeAll("selected");
    try writer.writeAll(
        \\>Available</option>
        \\      <option value="Pending" 
    );
    if (std.mem.eql(u8, current_status, "Pending")) try writer.writeAll("selected");
    try writer.writeAll(
        \\>Pending Adoption</option>
        \\      <option value="Adopted" 
    );
    if (std.mem.eql(u8, current_status, "Adopted")) try writer.writeAll("selected");
    try writer.writeAll(
        \\>Adopted 🎉</option>
        \\    </select>
        \\  </div>
        \\  <div style="align-self: flex-end;">
        \\    <button type="submit" class="btn btn-secondary">Apply Filters</button>
        \\  </div>
        \\</form>
        \\
        \\<!-- Pets Grid -->
        \\<div class="pet-grid">
    );

    if (pets.len == 0) {
        try writer.writeAll(
            \\  <div style="grid-column: 1 / -1; text-align: center; padding: 4rem 2rem; background: white; border-radius: var(--radius-md); border: 1px solid var(--border);">
            \\    <div style="font-size: 3rem; margin-bottom: 1rem;">🔍</div>
            \\    <h3>No pets match your criteria</h3>
            \\    <p style="color: var(--text-muted); margin-top: 0.5rem;">Try adjusting your filters or search query above.</p>
            \\  </div>
        );
    } else {
        for (pets) |pet| {
            try writer.print(
                \\  <div class="pet-card">
                \\    <div class="pet-card-img-container">
                \\      <img src="{s}" alt="{s}" class="pet-card-img">
                \\      <span class="badge-status {s}">{s}</span>
                \\      <span class="badge-species">{s}</span>
                \\    </div>
                \\    <div class="pet-card-body">
                \\      <h3 class="pet-name">{s}</h3>
                \\      <div class="pet-breed">{s} &bull; {d} mos</div>
                \\      <div class="pet-meta">
                \\        <span class="pet-meta-item">📍 {s}</span>
                \\        <span class="pet-meta-item">⚖️ {s}</span>
                \\      </div>
                \\      <p class="pet-desc">{s}</p>
                \\      <div class="pet-card-footer">
                \\        <a href="/pets/{d}" class="btn btn-outline btn-sm">View Profile</a>
                \\        <a href="#" class="btn btn-primary btn-sm open-adoption-modal" data-pet-id="{d}" data-pet-name="{s}">Adopt Me</a>
                \\      </div>
                \\    </div>
                \\  </div>
            , .{
                pet.image_url, pet.name, pet.status, pet.status, helpers.speciesEmoji(pet.species),
                pet.name,      pet.breed, pet.age,   pet.location,             pet.size,
                pet.description,
                pet.id,        pet.id,    pet.name,
            });
        }
    }

    try writer.writeAll(
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
        \\      <input type="hidden" name="pet_id" id="modal-pet-id" value="">
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
    return try helpers.renderLayout(allocator, "Adoptable Pets", body, "pets");
}
