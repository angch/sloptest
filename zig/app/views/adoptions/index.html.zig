const std = @import("std");
const AdoptionRequest = @import("../../models/adoption_request.zig").AdoptionRequest;
const helpers = @import("../../helpers/view_helper.zig");

pub fn render(allocator: std.mem.Allocator, requests: []AdoptionRequest) ![]const u8 {
    var buf = std.ArrayList(u8).init(allocator);
    errdefer buf.deinit();

    const writer = buf.writer();

    try writer.writeAll(
        \\<div class="page-header">
        \\  <div>
        \\    <h1 class="page-title">Adoption Applications</h1>
        \\    <p class="page-subtitle">Review submitted applications from prospective pet parents</p>
        \\  </div>
        \\</div>
        \\
        \\<div class="table-container">
        \\  <table class="table">
        \\    <thead>
        \\      <tr>
        \\        <th>App ID</th>
        \\        <th>Pet</th>
        \\        <th>Applicant</th>
        \\        <th>Contact</th>
        \\        <th>Housing</th>
        \\        <th>Yard</th>
        \\        <th>Status</th>
        \\        <th>Action</th>
        \\      </tr>
        \\    </thead>
        \\    <tbody>
    );

    if (requests.len == 0) {
        try writer.writeAll(
            \\      <tr>
            \\        <td colspan="8" style="text-align: center; padding: 3rem; color: var(--text-muted);">
            \\          No adoption applications submitted yet.
            \\        </td>
            \\      </tr>
        );
    } else {
        for (requests) |req| {
            try writer.print(
                \\      <tr>
                \\        <td><strong>#{d}</strong></td>
                \\        <td><a href="/pets/{d}" style="font-weight: 700; color: var(--primary);">{s}</a></td>
                \\        <td>
                \\          <div style="font-weight: 700; color: var(--dark);">{s}</div>
                \\          <div style="font-size: 0.8rem; color: var(--text-muted);">{s}</div>
                \\        </td>
                \\        <td>
                \\          <div>{s}</div>
                \\          <div style="font-size: 0.8rem; color: var(--text-muted);">{s}</div>
                \\        </td>
                \\        <td>{s}</td>
                \\        <td>{s}</td>
                \\        <td><span class="badge-status {s}" style="position: static; font-size: 0.7rem;">{s}</span></td>
                \\        <td>
                \\          <form action="/adoptions/status" method="POST" style="display: flex; gap: 0.3rem;">
                \\            <input type="hidden" name="id" value="{d}">
                \\            <input type="hidden" name="pet_id" value="{d}">
                \\            <button type="submit" name="status" value="Approved" class="btn btn-primary btn-sm" style="padding: 0.25rem 0.6rem; font-size: 0.75rem;">Approve</button>
                \\            <button type="submit" name="status" value="Under Review" class="btn btn-outline btn-sm" style="padding: 0.25rem 0.6rem; font-size: 0.75rem;">Review</button>
                \\          </form>
                \\        </td>
                \\      </tr>
            , .{
                req.id,        req.pet_id, req.pet_name,
                req.applicant_name, req.experience,
                req.email,     req.phone,
                req.housing_type, if (req.has_yard) "Yes 🌳" else "No 🚫",
                req.status,    req.status,
                req.id,        req.pet_id,
            });
        }
    }

    try writer.writeAll(
        \\    </tbody>
        \\  </table>
        \\</div>
    );

    const body = try buf.toOwnedSlice();
    return try helpers.renderLayout(allocator, "Adoption Applications", body, "adoptions");
}
