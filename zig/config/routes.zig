const std = @import("std");
const Router = @import("../src/rails/router.zig").Router;
const home_controller = @import("../app/controllers/home_controller.zig");
const pets_controller = @import("../app/controllers/pets_controller.zig");
const adoptions_controller = @import("../app/controllers/adoptions_controller.zig");

pub fn drawRoutes(router: *Router) !void {
    // Home route
    try router.get("/", home_controller.index);

    // Pets routes (RESTful)
    try router.get("/pets", pets_controller.index);
    try router.get("/pets/new", pets_controller.newForm);
    try router.get("/pets/:id", pets_controller.show);
    try router.post("/pets", pets_controller.create);

    // Adoption requests routes
    try router.get("/adoptions", adoptions_controller.index);
    try router.post("/adoptions", adoptions_controller.create);
    try router.post("/adoptions/status", adoptions_controller.updateStatus);
}
