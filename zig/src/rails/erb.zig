const std = @import("std");
const Pet = @import("../../app/models/pet.zig").Pet;
const AdoptionRequest = @import("../../app/models/adoption_request.zig").AdoptionRequest;
const helpers = @import("../../app/helpers/view_helper.zig");

pub const layout_tmpl = @embedFile("../../app/views/layouts/application.html.erb");
pub const home_index_tmpl = @embedFile("../../app/views/home/index.html.erb");
pub const pets_index_tmpl = @embedFile("../../app/views/pets/index.html.erb");
pub const pets_new_tmpl = @embedFile("../../app/views/pets/new.html.erb");
pub const pets_show_tmpl = @embedFile("../../app/views/pets/show.html.erb");
pub const adoptions_index_tmpl = @embedFile("../../app/views/adoptions/index.html.erb");

/// Helper to render layout with yield and ERB tag evaluation
pub fn renderLayout(allocator: std.mem.Allocator, title: []const u8, content: []const u8, active_nav: []const u8) ![]const u8 {
    var buf: std.ArrayList(u8) = .empty;
    defer buf.deinit(allocator);

    const writer = buf.writer(allocator);
    var i: usize = 0;
    const tmpl = layout_tmpl;

    while (i < tmpl.len) {
        if (std.mem.startsWith(u8, tmpl[i..], "<%#")) {
            if (std.mem.indexOf(u8, tmpl[i..], "%>")) |end| {
                i += end + 2;
            } else {
                break;
            }
        } else if (std.mem.startsWith(u8, tmpl[i..], "<%=")) {
            const end_idx = std.mem.indexOf(u8, tmpl[i..], "%>") orelse break;
            const tag = std.mem.trim(u8, tmpl[i + 3 .. i + end_idx], " \t\r\n");
            i += end_idx + 2;

            if (std.mem.eql(u8, tag, "title")) {
                try writer.writeAll(title);
            } else if (std.mem.eql(u8, tag, "yield")) {
                try writer.writeAll(content);
            } else if (std.mem.eql(u8, tag, "active_nav_home")) {
                if (std.mem.eql(u8, active_nav, "home")) try writer.writeAll("active");
            } else if (std.mem.eql(u8, tag, "active_nav_pets")) {
                if (std.mem.eql(u8, active_nav, "pets")) try writer.writeAll("active");
            } else if (std.mem.eql(u8, tag, "active_nav_adoptions")) {
                if (std.mem.eql(u8, active_nav, "adoptions")) try writer.writeAll("active");
            }
        } else {
            try writer.writeByte(tmpl[i]);
            i += 1;
        }
    }

    return try buf.toOwnedSlice(allocator);
}

pub fn renderHomeIndex(allocator: std.mem.Allocator, featured_pets: []const Pet) ![]const u8 {
    var buf: std.ArrayList(u8) = .empty;
    defer buf.deinit(allocator);

    const writer = buf.writer(allocator);
    var i: usize = 0;
    const tmpl = home_index_tmpl;

    while (i < tmpl.len) {
        if (std.mem.startsWith(u8, tmpl[i..], "<%#")) {
            if (std.mem.indexOf(u8, tmpl[i..], "%>")) |end| {
                i += end + 2;
            } else {
                break;
            }
        } else if (std.mem.startsWith(u8, tmpl[i..], "<% for (featured_pets) |pet| %>")) {
            const loop_start = i + "<% for (featured_pets) |pet| %>".len;
            const loop_end_rel = std.mem.indexOf(u8, tmpl[loop_start..], "<% end %>") orelse break;
            const loop_body = tmpl[loop_start .. loop_start + loop_end_rel];
            i = loop_start + loop_end_rel + "<% end %>".len;

            for (featured_pets) |pet| {
                try renderPetCard(writer, loop_body, pet);
            }
        } else {
            try writer.writeByte(tmpl[i]);
            i += 1;
        }
    }

    const body = try buf.toOwnedSlice(allocator);
    defer allocator.free(body);

    return try renderLayout(allocator, "Home", body, "home");
}

pub fn renderPetsIndex(allocator: std.mem.Allocator, pets: []const Pet, current_species: []const u8, current_status: []const u8, current_search: []const u8) ![]const u8 {
    var buf: std.ArrayList(u8) = .empty;
    defer buf.deinit(allocator);

    const writer = buf.writer(allocator);
    var i: usize = 0;
    const tmpl = pets_index_tmpl;

    while (i < tmpl.len) {
        if (std.mem.startsWith(u8, tmpl[i..], "<%#")) {
            if (std.mem.indexOf(u8, tmpl[i..], "%>")) |end| {
                i += end + 2;
            } else {
                break;
            }
        } else if (std.mem.startsWith(u8, tmpl[i..], "<%=")) {
            const end_idx = std.mem.indexOf(u8, tmpl[i..], "%>") orelse break;
            const tag = std.mem.trim(u8, tmpl[i + 3 .. i + end_idx], " \t\r\n");
            i += end_idx + 2;

            if (std.mem.eql(u8, tag, "current_search")) {
                try writer.writeAll(current_search);
            } else if (std.mem.eql(u8, tag, "species_all_selected")) {
                if (std.mem.eql(u8, current_species, "All") or current_species.len == 0) try writer.writeAll("selected");
            } else if (std.mem.eql(u8, tag, "species_dog_selected")) {
                if (std.mem.eql(u8, current_species, "Dog")) try writer.writeAll("selected");
            } else if (std.mem.eql(u8, tag, "species_cat_selected")) {
                if (std.mem.eql(u8, current_species, "Cat")) try writer.writeAll("selected");
            } else if (std.mem.eql(u8, tag, "species_rabbit_selected")) {
                if (std.mem.eql(u8, current_species, "Rabbit")) try writer.writeAll("selected");
            } else if (std.mem.eql(u8, tag, "species_bird_selected")) {
                if (std.mem.eql(u8, current_species, "Bird")) try writer.writeAll("selected");
            } else if (std.mem.eql(u8, tag, "status_all_selected")) {
                if (std.mem.eql(u8, current_status, "All") or current_status.len == 0) try writer.writeAll("selected");
            } else if (std.mem.eql(u8, tag, "status_available_selected")) {
                if (std.mem.eql(u8, current_status, "Available")) try writer.writeAll("selected");
            } else if (std.mem.eql(u8, tag, "status_pending_selected")) {
                if (std.mem.eql(u8, current_status, "Pending")) try writer.writeAll("selected");
            } else if (std.mem.eql(u8, tag, "status_adopted_selected")) {
                if (std.mem.eql(u8, current_status, "Adopted")) try writer.writeAll("selected");
            }
        } else if (std.mem.startsWith(u8, tmpl[i..], "<% if (pets.len == 0) %>")) {
            const if_start = i + "<% if (pets.len == 0) %>".len;
            const else_rel = std.mem.indexOf(u8, tmpl[if_start..], "<% else %>") orelse break;
            const if_body = tmpl[if_start .. if_start + else_rel];
            
            const else_start = if_start + else_rel + "<% else %>".len;
            const endif_rel = std.mem.indexOf(u8, tmpl[else_start..], "<% end %>") orelse break;
            const else_body = tmpl[else_start .. else_start + endif_rel];

            i = else_start + endif_rel + "<% end %>".len;

            if (pets.len == 0) {
                try writer.writeAll(if_body);
            } else {
                // Render else body which contains <% for (pets) |pet| %> ... <% end %>
                var e_idx: usize = 0;
                while (e_idx < else_body.len) {
                    if (std.mem.startsWith(u8, else_body[e_idx..], "<% for (pets) |pet| %>")) {
                        const for_start = e_idx + "<% for (pets) |pet| %>".len;
                        const for_end_rel = std.mem.indexOf(u8, else_body[for_start..], "<% end %>") orelse break;
                        const loop_body = else_body[for_start .. for_start + for_end_rel];
                        e_idx = for_start + for_end_rel + "<% end %>".len;

                        for (pets) |pet| {
                            try renderPetCard(writer, loop_body, pet);
                        }
                    } else {
                        try writer.writeByte(else_body[e_idx]);
                        e_idx += 1;
                    }
                }
            }
        } else {
            try writer.writeByte(tmpl[i]);
            i += 1;
        }
    }

    const body = try buf.toOwnedSlice(allocator);
    defer allocator.free(body);

    return try renderLayout(allocator, "Adoptable Pets", body, "pets");
}

pub fn renderPetShow(allocator: std.mem.Allocator, pet: Pet) ![]const u8 {
    var buf: std.ArrayList(u8) = .empty;
    defer buf.deinit(allocator);

    const writer = buf.writer(allocator);
    var i: usize = 0;
    const tmpl = pets_show_tmpl;

    while (i < tmpl.len) {
        if (std.mem.startsWith(u8, tmpl[i..], "<%#")) {
            if (std.mem.indexOf(u8, tmpl[i..], "%>")) |end| {
                i += end + 2;
            } else {
                break;
            }
        } else if (std.mem.startsWith(u8, tmpl[i..], "<%=")) {
            const end_idx = std.mem.indexOf(u8, tmpl[i..], "%>") orelse break;
            const tag = std.mem.trim(u8, tmpl[i + 3 .. i + end_idx], " \t\r\n");
            i += end_idx + 2;

            if (std.mem.eql(u8, tag, "pet.id")) {
                try writer.print("{d}", .{pet.id});
            } else if (std.mem.eql(u8, tag, "pet.name")) {
                try writer.writeAll(pet.name);
            } else if (std.mem.eql(u8, tag, "pet.species")) {
                try writer.writeAll(pet.species);
            } else if (std.mem.eql(u8, tag, "species_emoji(pet.species)")) {
                try writer.writeAll(helpers.speciesEmoji(pet.species));
            } else if (std.mem.eql(u8, tag, "pet.breed")) {
                try writer.writeAll(pet.breed);
            } else if (std.mem.eql(u8, tag, "pet.age")) {
                try writer.print("{d}", .{pet.age});
            } else if (std.mem.eql(u8, tag, "pet.gender")) {
                try writer.writeAll(pet.gender);
            } else if (std.mem.eql(u8, tag, "pet.size")) {
                try writer.writeAll(pet.size);
            } else if (std.mem.eql(u8, tag, "pet.description")) {
                try writer.writeAll(pet.description);
            } else if (std.mem.eql(u8, tag, "pet.image_url")) {
                try writer.writeAll(pet.image_url);
            } else if (std.mem.eql(u8, tag, "pet.status")) {
                try writer.writeAll(pet.status);
            } else if (std.mem.eql(u8, tag, "pet.location")) {
                try writer.writeAll(pet.location);
            }
        } else {
            try writer.writeByte(tmpl[i]);
            i += 1;
        }
    }

    const body = try buf.toOwnedSlice(allocator);
    defer allocator.free(body);

    const title = try std.fmt.allocPrint(allocator, "Meet {s}", .{pet.name});
    defer allocator.free(title);

    return try renderLayout(allocator, title, body, "pets");
}

pub fn renderPetNew(allocator: std.mem.Allocator) ![]const u8 {
    var buf: std.ArrayList(u8) = .empty;
    defer buf.deinit(allocator);

    const writer = buf.writer(allocator);
    var i: usize = 0;
    const tmpl = pets_new_tmpl;

    while (i < tmpl.len) {
        if (std.mem.startsWith(u8, tmpl[i..], "<%#")) {
            if (std.mem.indexOf(u8, tmpl[i..], "%>")) |end| {
                i += end + 2;
            } else {
                break;
            }
        } else {
            try writer.writeByte(tmpl[i]);
            i += 1;
        }
    }

    const body = try buf.toOwnedSlice(allocator);
    defer allocator.free(body);

    return try renderLayout(allocator, "List New Pet", body, "pets");
}

pub fn renderAdoptionsIndex(allocator: std.mem.Allocator, requests: []const AdoptionRequest) ![]const u8 {
    var buf: std.ArrayList(u8) = .empty;
    defer buf.deinit(allocator);

    const writer = buf.writer(allocator);
    var i: usize = 0;
    const tmpl = adoptions_index_tmpl;

    while (i < tmpl.len) {
        if (std.mem.startsWith(u8, tmpl[i..], "<%#")) {
            if (std.mem.indexOf(u8, tmpl[i..], "%>")) |end| {
                i += end + 2;
            } else {
                break;
            }
        } else if (std.mem.startsWith(u8, tmpl[i..], "<% if (requests.len == 0) %>")) {
            const if_start = i + "<% if (requests.len == 0) %>".len;
            const else_rel = std.mem.indexOf(u8, tmpl[if_start..], "<% else %>") orelse break;
            const if_body = tmpl[if_start .. if_start + else_rel];

            const else_start = if_start + else_rel + "<% else %>".len;
            const endif_rel = std.mem.indexOf(u8, tmpl[else_start..], "<% end %>") orelse break;
            const else_body = tmpl[else_start .. else_start + endif_rel];

            i = else_start + endif_rel + "<% end %>".len;

            if (requests.len == 0) {
                try writer.writeAll(if_body);
            } else {
                var e_idx: usize = 0;
                while (e_idx < else_body.len) {
                    if (std.mem.startsWith(u8, else_body[e_idx..], "<% for (requests) |req| %>")) {
                        const for_start = e_idx + "<% for (requests) |req| %>".len;
                        const for_end_rel = std.mem.indexOf(u8, else_body[for_start..], "<% end %>") orelse break;
                        const loop_body = else_body[for_start .. for_start + for_end_rel];
                        e_idx = for_start + for_end_rel + "<% end %>".len;

                        for (requests) |req| {
                            try renderAdoptionRow(writer, loop_body, req);
                        }
                    } else {
                        try writer.writeByte(else_body[e_idx]);
                        e_idx += 1;
                    }
                }
            }
        } else {
            try writer.writeByte(tmpl[i]);
            i += 1;
        }
    }

    const body = try buf.toOwnedSlice(allocator);
    defer allocator.free(body);

    return try renderLayout(allocator, "Adoption Applications", body, "adoptions");
}

fn renderPetCard(writer: anytype, loop_body: []const u8, pet: Pet) !void {
    var j: usize = 0;
    while (j < loop_body.len) {
        if (std.mem.startsWith(u8, loop_body[j..], "<%=")) {
            const end_idx = std.mem.indexOf(u8, loop_body[j..], "%>") orelse break;
            const tag = std.mem.trim(u8, loop_body[j + 3 .. j + end_idx], " \t\r\n");
            j += end_idx + 2;

            if (std.mem.eql(u8, tag, "pet.id")) {
                try writer.print("{d}", .{pet.id});
            } else if (std.mem.eql(u8, tag, "pet.name")) {
                try writer.writeAll(pet.name);
            } else if (std.mem.eql(u8, tag, "pet.species")) {
                try writer.writeAll(pet.species);
            } else if (std.mem.eql(u8, tag, "species_emoji(pet.species)")) {
                try writer.writeAll(helpers.speciesEmoji(pet.species));
            } else if (std.mem.eql(u8, tag, "pet.breed")) {
                try writer.writeAll(pet.breed);
            } else if (std.mem.eql(u8, tag, "pet.age")) {
                try writer.print("{d}", .{pet.age});
            } else if (std.mem.eql(u8, tag, "pet.gender")) {
                try writer.writeAll(pet.gender);
            } else if (std.mem.eql(u8, tag, "pet.size")) {
                try writer.writeAll(pet.size);
            } else if (std.mem.eql(u8, tag, "pet.description")) {
                try writer.writeAll(pet.description);
            } else if (std.mem.eql(u8, tag, "pet.image_url")) {
                try writer.writeAll(pet.image_url);
            } else if (std.mem.eql(u8, tag, "pet.status")) {
                try writer.writeAll(pet.status);
            } else if (std.mem.eql(u8, tag, "pet.location")) {
                try writer.writeAll(pet.location);
            }
        } else {
            try writer.writeByte(loop_body[j]);
            j += 1;
        }
    }
}

fn renderAdoptionRow(writer: anytype, loop_body: []const u8, req: AdoptionRequest) !void {
    var j: usize = 0;
    while (j < loop_body.len) {
        if (std.mem.startsWith(u8, loop_body[j..], "<%=")) {
            const end_idx = std.mem.indexOf(u8, loop_body[j..], "%>") orelse break;
            const tag = std.mem.trim(u8, loop_body[j + 3 .. j + end_idx], " \t\r\n");
            j += end_idx + 2;

            if (std.mem.eql(u8, tag, "req.id")) {
                try writer.print("{d}", .{req.id});
            } else if (std.mem.eql(u8, tag, "req.pet_id")) {
                try writer.print("{d}", .{req.pet_id});
            } else if (std.mem.eql(u8, tag, "req.pet_name")) {
                try writer.writeAll(req.pet_name);
            } else if (std.mem.eql(u8, tag, "req.applicant_name")) {
                try writer.writeAll(req.applicant_name);
            } else if (std.mem.eql(u8, tag, "req.email")) {
                try writer.writeAll(req.email);
            } else if (std.mem.eql(u8, tag, "req.phone")) {
                try writer.writeAll(req.phone);
            } else if (std.mem.eql(u8, tag, "req.housing_type")) {
                try writer.writeAll(req.housing_type);
            } else if (std.mem.eql(u8, tag, "req.has_yard_text")) {
                try writer.writeAll(if (req.has_yard) "Yes 🌳" else "No 🚫");
            } else if (std.mem.eql(u8, tag, "req.experience")) {
                try writer.writeAll(req.experience);
            } else if (std.mem.eql(u8, tag, "req.status")) {
                try writer.writeAll(req.status);
            }
        } else {
            try writer.writeByte(loop_body[j]);
            j += 1;
        }
    }
}
