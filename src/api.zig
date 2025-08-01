const std = @import("std");
const build = @import("build.zig.zon");

pub const protobuf = @import("protobuf");

pub const mmc_msg = @import("proto/mmc.pb.zig");
pub const command_msg = @import("proto/mmc/command.pb.zig");
pub const core_msg = @import("proto/mmc/core.pb.zig");
pub const info_msg = @import("proto/mmc/info.pb.zig");

pub const version =
    std.SemanticVersion.parse(build.version) catch unreachable;
