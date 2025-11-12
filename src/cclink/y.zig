const std = @import("std");
const cclink = @import("../cclink.zig");

const Direction = cclink.Direction;

/// Registers written through CC-Link's "DevY" device. Used as a "write"
/// register bank.
pub const Y = packed struct(u64) {
    cc_link_enable: bool = false,
    emergency_stop: bool = false,
    temporary_pause: bool = false,
    release_motor: packed struct(u3) {
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), local_axis: u2) bool {
            return switch (local_axis) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `release_motor`",
                        .{},
                    );
                    unreachable;
                },
            };
        }

        pub fn setAxis(
            self: *align(8:3:8) @This(),
            local_axis: u2,
            val: bool,
        ) void {
            switch (local_axis) {
                0 => self.axis1 = val,
                1 => self.axis2 = val,
                2 => self.axis3 = val,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `release_motor`",
                        .{},
                    );
                    unreachable;
                },
            }
        }
    } = .{},
    deinitialize_carrier: packed struct(u3) {
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), local_axis: u2) bool {
            return switch (local_axis) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `deinitialize_carrier`",
                        .{},
                    );
                    unreachable;
                },
            };
        }

        pub fn setAxis(
            self: *align(8:6:8) @This(),
            local_axis: u2,
            val: bool,
        ) void {
            switch (local_axis) {
                0 => self.axis1 = val,
                1 => self.axis2 = val,
                2 => self.axis3 = val,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `deinitialize_carrier`",
                        .{},
                    );
                    unreachable;
                },
            }
        }
    } = .{},
    calibrate: bool = false,
    clear_errors: bool = false,
    stop_pull_carrier: packed struct(u3) {
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), local_axis: u2) bool {
            return switch (local_axis) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `stop_pull_carrier`",
                        .{},
                    );
                    unreachable;
                },
            };
        }

        pub fn setAxis(
            self: *align(8:11:8) @This(),
            local_axis: u2,
            val: bool,
        ) void {
            switch (local_axis) {
                0 => self.axis1 = val,
                1 => self.axis2 = val,
                2 => self.axis3 = val,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `stop_pull_carrier`",
                        .{},
                    );
                    unreachable;
                },
            }
        }
    } = .{},
    stop_push_carrier: packed struct(u3) {
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), local_axis: u2) bool {
            return switch (local_axis) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `stop_push_carrier`",
                        .{},
                    );
                    unreachable;
                },
            };
        }

        pub fn setAxis(
            self: *align(8:14:8) @This(),
            local_axis: u2,
            val: bool,
        ) void {
            switch (local_axis) {
                0 => self.axis1 = val,
                1 => self.axis2 = val,
                2 => self.axis3 = val,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `stop_push_carrier`",
                        .{},
                    );
                    unreachable;
                },
            }
        }
    } = .{},
    _22: u47 = 0,

    pub fn format(y: Y, writer: anytype) !void {
        _ = try cclink.nestedWrite("Y", y, 0, writer);
    }
};

test "Y" {
    try std.testing.expectEqual(8, @sizeOf(Y));
}
