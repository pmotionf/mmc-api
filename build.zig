const std = @import("std");
const protobuf = @import("protobuf");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const protobuf_dep = b.dependency("protobuf", .{
        .target = target,
        .optimize = optimize,
    });

    const build_zig_zon = b.createModule(.{
        .root_source_file = b.path("build.zig.zon"),
        .target = target,
        .optimize = optimize,
    });

    const mod = b.addModule("mmc-api", .{
        .root_source_file = b.path("src/api.zig"),
        .imports = &.{
            .{ .name = "protobuf", .module = protobuf_dep.module("protobuf") },
            .{ .name = "build.zig.zon", .module = build_zig_zon },
        },
        .target = target,
        .optimize = optimize,
    });

    const unit_tests = b.addTest(.{ .root_module = mod });
    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    // Check step is same as test, as there is no output artifact.
    const check = b.step("check", "Check if foo compiles");
    check.dependOn(&run_unit_tests.step);

    const gen_proto = b.step(
        "gen-proto",
        "generates zig files from protocol buffer definitions",
    );

    const protoc_step = protobuf.RunProtocStep.create(
        b,
        protobuf_dep.builder,
        target,
        .{
            .destination_directory = b.path("src/proto"),
            .source_files = &.{
                "mmc/core.proto",
                "mmc/command.proto",
                "mmc/info.proto",
                "mmc.proto",
            },
            .include_directories = &.{"protocol"},
        },
    );

    gen_proto.dependOn(&protoc_step.step);
}
