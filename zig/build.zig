const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "paws_and_homes",
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.addCSourceFile(.{
        .file = b.path("db/vendor/sqlite3.c"),
        .flags = &[_][]const u8{
            "-DSQLITE_THREADSAFE=1",
        },
    });
    exe.addIncludePath(b.path("db/vendor"));
    exe.linkLibC();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the pet adoption Rails-like web application");
    run_step.dependOn(&run_cmd.step);
}
