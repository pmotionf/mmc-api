const std = @import("std");
const build = @import("build.zig.zon");

pub const protobuf = struct {
    pub const root = @import("protobuf/protobuf.pb.zig");
    pub const mmc = @import("protobuf/mmc.pb.zig");
};

pub const version =
    std.SemanticVersion.parse(build.version) catch unreachable;

test {
    std.testing.refAllDeclsRecursive(@This());
}
