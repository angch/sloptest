const std = @import("std");
const Pet = @import("../../models/pet.zig").Pet;
const helpers = @import("../../helpers/view_helper.zig");

pub fn render(allocator: std.mem.Allocator, featured_pets: []Pet) ![]const u8 {
    var buf = std.ArrayList(u8).init(allocator);
    errdefer buf.deinit();

    const writer = buf.writer();

    try writer.writeAll(
        \\<!-- Hero Section -->
        \\<section class="hero">
        \\  <div class="hero-content">
        \\    <h1>Find Your New <span>Best Friend</span> Today</h1>
        \\    <p>Every pet deserves a loving forever home. Browse our adorable rescued dogs, cats, rabbits, and birds ready to bring endless joy into your life.</p>
        \\    <div class="hero-buttons">
        \\      <a href="/pets" class="btn btn-primary">Browse All Pets</a>
        \\      <a href="/pets/new" class="btn btn-outline">List a Rescued Pet</a>
        \\    </div>
        \\  </div>
        \\  <div class="hero-image-wrapper">
        \\    <img src="/images/hero.jpg" alt="Pet Adoption Banner" class="hero-image">
        \\  </div>
        \\</section>
        \\
        \\<!-- Quick Stats -->
        \\<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.5rem; margin-bottom: 3.5rem;">
        \\  <div style="background: white; padding: 1.5rem; border-radius: var(--radius-md); border: 1px solid var(--border); text-align: center; box-shadow: var(--shadow-sm);">
        \\    <div style="font-size: 2.5rem; font-weight: 900; color: var(--primary);">120+</div>
        \\    <div style="color: var(--text-muted); font-weight: 600;">Pets Rescued This Month</div>
        \\  </div>
        \\  <div style="background: white; padding: 1.5rem; border-radius: var(--radius-md); border: 1px solid var(--border); text-align: center; box-shadow: var(--shadow-sm);">
        \\    <div style="font-size: 2.5rem; font-weight: 900; color: var(--accent);">98%</div>
        \\    <div style="color: var(--text-muted); font-weight: 600;">Successful Adoption Rate</div>
        \\  </div>
        \\  <div style="background: white; padding: 1.5rem; border-radius: var(--radius-md); border: 1px solid var(--border); text-align: center; box-shadow: var(--shadow-sm);">
        \\    <div style="font-size: 2.5rem; font-weight: 900; color: var(--secondary);">15</div>
        \\    <div style="color: var(--text-muted); font-weight: 600;">Partner Shelters</div>
        \\  </div>
        \\</div>
        \\
        \\<!-- Featured Pets Section -->
        \\<div class="page-header">
        \\  <div>
        \\    <h2 class="page-title">Featured Companions</h2>
        \\    <p class="page-subtitle">Meet some of our newest available animals looking for a loving family</p>
        \\  </div>
        \\  <a href="/pets" class="btn btn-outline btn-sm">View All &rarr;</a>
        \\</div>
        \\
        \\<div class="pet-grid">
    );

    for (featured_pets) |pet| {
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
            \\        <a href="/pets/{d}" class="btn btn-outline btn-sm">Meet {s}</a>
            \\        <a href="#" class="btn btn-primary btn-sm open-adoption-modal" data-pet-id="{d}" data-pet-name="{s}">Adopt Me</a>
            \\      </div>
            \\    </div>
            \\  </div>
        , .{
            pet.image_url, pet.name, pet.status, pet.status, helpers.speciesEmoji(pet.species),
            pet.name,      pet.breed, pet.age,   pet.location,             pet.size,
            pet.description,
            pet.id,        pet.name,  pet.id,    pet.name,
        });
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
    return try helpers.renderLayout(allocator, "Home", body, "home");
}
