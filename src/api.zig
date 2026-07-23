const std = @import("std");
const build = @import("build.zig.zon");

pub const protobuf = struct {
    pub const root = @import("protobuf/protobuf.pb.zig");
    pub const mmc = @import("protobuf/mmc.pb.zig");

    pub const version = std.SemanticVersion.parse("2.0.0") catch unreachable;
};

pub const registers = @import("registers.zig");

test {
    std.testing.refAllDecls(@This());
}
