const std = @import("std");
const helpers = @import("../../helpers/view_helper.zig");

pub fn render(allocator: std.mem.Allocator) ![]const u8 {
    var buf = std.ArrayList(u8).init(allocator);
    errdefer buf.deinit();

    const writer = buf.writer();

    try writer.writeAll(
        \\<div style="max-width: 700px; margin: 0 auto; background: white; border-radius: var(--radius-lg); padding: 2.5rem; border: 1px solid var(--border); box-shadow: var(--shadow-lg);">
        \\  <div class="page-header" style="margin-bottom: 1.5rem;">
        \\    <div>
        \\      <h1 class="page-title">List a Rescued Pet</h1>
        \\      <p class="page-subtitle">Add a new animal into the Paws & Homes adoption database</p>
        \\    </div>
        \\  </div>
        \\  
        \\  <form action="/pets" method="POST">
        \\    <div class="form-group" style="margin-bottom: 1.25rem;">
        \\      <label class="form-label">Pet Name *</label>
        \\      <input type="text" name="name" class="form-control" placeholder="e.g. Buster" required>
        \\    </div>
        \\    
        \\    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1.25rem;">
        \\      <div class="form-group">
        \\        <label class="form-label">Species *</label>
        \\        <select name="species" class="form-select" required>
        \\          <option value="Dog">Dog 🐶</option>
        \\          <option value="Cat">Cat 🐱</option>
        \\          <option value="Rabbit">Rabbit 🐰</option>
        \\          <option value="Bird">Bird 🦜</option>
        \\        </select>
        \\      </div>
        \\      <div class="form-group">
        \\        <label class="form-label">Breed / Mix *</label>
        \\        <input type="text" name="breed" class="form-control" placeholder="e.g. Golden Retriever" required>
        \\      </div>
        \\    </div>
        \\    
        \\    <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 1rem; margin-bottom: 1.25rem;">
        \\      <div class="form-group">
        \\        <label class="form-label">Age (in months) *</label>
        \\        <input type="number" name="age" class="form-control" placeholder="12" min="1" required>
        \\      </div>
        \\      <div class="form-group">
        \\        <label class="form-label">Gender *</label>
        \\        <select name="gender" class="form-select" required>
        \\          <option value="Male">Male</option>
        \\          <option value="Female">Female</option>
        \\        </select>
        \\      </div>
        \\      <div class="form-group">
        \\        <label class="form-label">Size *</label>
        \\        <select name="size" class="form-select" required>
        \\          <option value="Small">Small</option>
        \\          <option value="Medium">Medium</option>
        \\          <option value="Large">Large</option>
        \\        </select>
        \\      </div>
        \\    </div>
        \\    
        \\    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1.25rem;">
        \\      <div class="form-group">
        \\        <label class="form-label">Location / Shelter *</label>
        \\        <input type="text" name="location" class="form-control" placeholder="e.g. San Francisco Haven" required>
        \\      </div>
        \\      <div class="form-group">
        \\        <label class="form-label">Image URL</label>
        \\        <input type="text" name="image_url" class="form-control" placeholder="/images/golden_retriever.jpg">
        \\      </div>
        \\    </div>
        \\    
        \\    <div class="form-group" style="margin-bottom: 2rem;">
        \\      <label class="form-label">Biography & Personality Description *</label>
        \\      <textarea name="description" class="form-control" rows="4" placeholder="Tell potential adopters about their traits, energy level, temperament..." required></textarea>
        \\    </div>
        \\    
        \\    <div style="display: flex; gap: 1rem; justify-content: flex-end;">
        \\      <a href="/pets" class="btn btn-outline">Cancel</a>
        \\      <button type="submit" class="btn btn-primary">Save Pet Record</button>
        \\    </div>
        \\  </form>
        \\</div>
    );

    const body = try buf.toOwnedSlice();
    return try helpers.renderLayout(allocator, "List New Pet", body, "pets");
}
