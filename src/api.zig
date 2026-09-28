const std = @import("std");
const build = @import("build.zig.zon");

pub const protobuf = struct {
    pub const root = @import("protobuf/root.pb.zig");
    pub const mmc = @import("protobuf/mmc.pb.zig");

    pub const version = std.SemanticVersion.parse("3.1.0") catch unreachable;
};

pub const registers = @import("registers.zig");

test {
    std.testing.refAllDecls(@This());
}
