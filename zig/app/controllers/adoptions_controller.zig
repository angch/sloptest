const std = @import("std");
const Request = @import("../../src/rails/request.zig").Request;
const Response = @import("../../src/rails/response.zig").Response;
const AdoptionRequest = @import("../models/adoption_request.zig").AdoptionRequest;
const Pet = @import("../models/pet.zig").Pet;
const AdoptionsIndexView = @import("../views/adoptions/index.html.zig");

pub fn index(allocator: std.mem.Allocator, req: *Request) !Response {
    _ = req;
    const requests = try AdoptionRequest.all(allocator);
    defer AdoptionRequest.deinitSlice(allocator, requests);

    const html_content = try AdoptionsIndexView.render(allocator, requests);
    return Response.html(allocator, html_content);
}

pub fn create(allocator: std.mem.Allocator, req: *Request) !Response {
    const pet_id_str = req.getParam("pet_id");
    const applicant_name = req.getParam("applicant_name");
    const email = req.getParam("email");
    const phone = req.getParam("phone");
    const housing_type = req.getParam("housing_type");
    const has_yard_str = req.getParam("has_yard");
    const other_pets = req.getParam("other_pets");
    const experience = req.getParam("experience");

    const pet_id = std.fmt.parseInt(i64, pet_id_str, 10) catch 0;
    const has_yard = std.mem.eql(u8, has_yard_str, "1") or std.mem.eql(u8, has_yard_str, "true");

    if (pet_id > 0) {
        _ = try AdoptionRequest.create(allocator, pet_id, applicant_name, email, phone, housing_type, has_yard, other_pets, experience);
    }

    return try Response.redirect(allocator, "/adoptions");
}

pub fn updateStatus(allocator: std.mem.Allocator, req: *Request) !Response {
    const id_str = req.getParam("id");
    const pet_id_str = req.getParam("pet_id");
    const new_status = req.getParam("status");

    const app_id = std.fmt.parseInt(i64, id_str, 10) catch 0;
    const pet_id = std.fmt.parseInt(i64, pet_id_str, 10) catch 0;

    if (app_id > 0) {
        try AdoptionRequest.updateStatus(app_id, new_status);
        if (std.mem.eql(u8, new_status, "Approved") and pet_id > 0) {
            try Pet.updateStatus(pet_id, "Adopted");
        }
    }

    return try Response.redirect(allocator, "/adoptions");
}
