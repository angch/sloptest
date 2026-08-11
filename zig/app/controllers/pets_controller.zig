const std = @import("std");
const Request = @import("../../src/rails/request.zig").Request;
const Response = @import("../../src/rails/response.zig").Response;
const Pet = @import("../models/pet.zig").Pet;
const PetsIndexView = @import("../views/pets/index.html.zig");
const PetShowView = @import("../views/pets/show.html.zig");
const PetNewView = @import("../views/pets/new.html.zig");

pub fn index(allocator: std.mem.Allocator, req: *Request) !Response {
    const species = req.getParam("species");
    const status = req.getParam("status");
    const search = req.getParam("search");

    const pets = try Pet.where(allocator, species, status, search);
    defer Pet.deinitSlice(allocator, pets);

    const html_content = try PetsIndexView.render(allocator, pets, species, status, search);
    return Response.html(allocator, html_content);
}

pub fn show(allocator: std.mem.Allocator, req: *Request) !Response {
    const id_str = req.getParam("id");
    const pet_id = std.fmt.parseInt(i64, id_str, 10) catch return Response.notFound(allocator);

    const pet_opt = try Pet.find(allocator, pet_id);
    if (pet_opt) |pet| {
        defer {
            allocator.free(pet.name);
            allocator.free(pet.species);
            allocator.free(pet.breed);
            allocator.free(pet.gender);
            allocator.free(pet.size);
            allocator.free(pet.description);
            allocator.free(pet.image_url);
            allocator.free(pet.status);
            allocator.free(pet.location);
            allocator.free(pet.created_at);
        }
        const html_content = try PetShowView.render(allocator, pet);
        return Response.html(allocator, html_content);
    }

    return Response.notFound(allocator);
}

pub fn newForm(allocator: std.mem.Allocator, req: *Request) !Response {
    _ = req;
    const html_content = try PetNewView.render(allocator);
    return Response.html(allocator, html_content);
}

pub fn create(allocator: std.mem.Allocator, req: *Request) !Response {
    const name = req.getParam("name");
    const species = req.getParam("species");
    const breed = req.getParam("breed");
    const age_str = req.getParam("age");
    const gender = req.getParam("gender");
    const size = req.getParam("size");
    const location = req.getParam("location");
    const image_url = req.getParam("image_url");
    const description = req.getParam("description");

    const age = std.fmt.parseInt(i64, age_str, 10) catch 12;

    const new_id = try Pet.create(allocator, name, species, breed, age, gender, size, description, image_url, location);
    _ = new_id;

    return try Response.redirect(allocator, "/pets");
}
