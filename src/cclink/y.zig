const std = @import("std");
const registers = @import("../registers.zig");

const Direction = registers.Direction;

/// Registers written through CC-Link's "DevY" device. Used as a "write"
/// register bank.
pub const Y = packed struct(u64) {
    cc_link_enable: bool = false,
    service_enable: bool = false,
    start_command: bool = false,
    reset_command_received: bool = false,
    _4: u1 = 0,
    axis_servo_release: bool = false,
    servo_release: bool = false,
    emergency_stop: bool = false,
    temporary_pause: bool = false,
    stop_driver_transmission: packed struct(u2) {
        to_prev: bool = false,
        to_next: bool = false,

        pub fn to(self: @This(), dir: Direction) bool {
            return switch (dir) {
                .backward => self.to_prev,
                .forward => self.to_next,
            };
        }

        pub fn setTo(
            self: *align(8:9:8) @This(),
            dir: Direction,
            val: bool,
        ) void {
            switch (dir) {
                .backward => self.to_prev = val,
                .forward => self.to_next = val,
            }
        }
    } = .{},
    clear_errors: bool = false,
    clear_axis_slider_info: bool = false,
    prev_axis_isolate_link: bool = false,
    next_axis_isolate_link: bool = false,
    _15: u1 = 0,
    reset_pull_slider: packed struct(u3) {
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
                        "Invalid axis index 3 for `reset_pull_slider`",
                        .{},
                    );
                    unreachable;
                },
            };
        }

        pub fn setAxis(
            self: *align(8:16:8) @This(),
            local_axis: u2,
            val: bool,
        ) void {
            switch (local_axis) {
                0 => self.axis1 = val,
                1 => self.axis2 = val,
                2 => self.axis3 = val,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `reset_pull_slider`",
                        .{},
                    );
                    unreachable;
                },
            }
        }
    } = .{},
    recovery_use_hall_sensor: packed struct(u2) {
        back: bool = false,
        front: bool = false,

        pub fn side(self: @This(), dir: Direction) bool {
            return switch (dir) {
                .backward => self.back,
                .forward => self.front,
            };
        }

        pub fn setSide(
            self: *align(8:19:8) @This(),
            dir: Direction,
            val: bool,
        ) void {
            switch (dir) {
                .backward => self.back = val,
                .forward => self.front = val,
            }
        }
    } = .{},
    link_chain: packed struct(u6) {
        axis1: packed struct(u2) {
            backward: bool = false,
            forward: bool = false,
        } = .{},
        axis2: packed struct(u2) {
            backward: bool = false,
            forward: bool = false,
        } = .{},
        axis3: packed struct(u2) {
            backward: bool = false,
            forward: bool = false,
        } = .{},

        pub fn axis(self: @This(), a: u2) packed struct(u2) {
            backward: bool,
            forward: bool,
        } {
            return switch (a) {
                0 => .{
                    .backward = self.axis1.backward,
                    .forward = self.axis1.forward,
                },
                1 => .{
                    .backward = self.axis2.backward,
                    .forward = self.axis2.forward,
                },
                2 => .{
                    .backward = self.axis3.backward,
                    .forward = self.axis3.forward,
                },
                3 => {
                    std.log.err("Invalid axis index 3 for `link_chain`", .{});
                    unreachable;
                },
            };
        }

        pub fn setAxis(self: *align(8:21:8) @This(), a: u2, val: struct {
            backward: ?bool = null,
            forward: ?bool = null,
        }) void {
            switch (a) {
                0 => {
                    if (val.backward) |b| {
                        self.axis1.backward = b;
                    }
                    if (val.forward) |f| {
                        self.axis1.forward = f;
                    }
                },
                1 => {
                    if (val.backward) |b| {
                        self.axis2.backward = b;
                    }
                    if (val.forward) |f| {
                        self.axis2.forward = f;
                    }
                },
                2 => {
                    if (val.backward) |b| {
                        self.axis3.backward = b;
                    }
                    if (val.forward) |f| {
                        self.axis3.forward = f;
                    }
                },
                3 => {
                    std.log.err("Invalid axis index 3 for `link_chain`", .{});
                    unreachable;
                },
            }
        }
    } = .{},
    unlink_chain: packed struct(u6) {
        axis1: packed struct(u2) {
            backward: bool = false,
            forward: bool = false,
        } = .{},
        axis2: packed struct(u2) {
            backward: bool = false,
            forward: bool = false,
        } = .{},
        axis3: packed struct(u2) {
            backward: bool = false,
            forward: bool = false,
        } = .{},

        pub fn axis(self: @This(), a: u2) packed struct(u2) {
            backward: bool,
            forward: bool,
        } {
            return switch (a) {
                0 => .{
                    .backward = self.axis1.backward,
                    .forward = self.axis1.forward,
                },
                1 => .{
                    .backward = self.axis2.backward,
                    .forward = self.axis2.forward,
                },
                2 => .{
                    .backward = self.axis3.backward,
                    .forward = self.axis3.forward,
                },
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `unlink_chain`",
                        .{},
                    );
                    unreachable;
                },
            };
        }

        pub fn setAxis(self: *align(8:27:8) @This(), a: u2, val: struct {
            backward: ?bool = null,
            forward: ?bool = null,
        }) void {
            switch (a) {
                0 => {
                    if (val.backward) |b| {
                        self.axis1.backward = b;
                    }
                    if (val.forward) |f| {
                        self.axis1.forward = f;
                    }
                },
                1 => {
                    if (val.backward) |b| {
                        self.axis2.backward = b;
                    }
                    if (val.forward) |f| {
                        self.axis2.forward = f;
                    }
                },
                2 => {
                    if (val.backward) |b| {
                        self.axis3.backward = b;
                    }
                    if (val.forward) |f| {
                        self.axis3.forward = f;
                    }
                },
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `unlink_chain`",
                        .{},
                    );
                    unreachable;
                },
            }
        }
    } = .{},
    _33: u31 = 0,

    pub fn format(y: Y, writer: anytype) !void {
        _ = try registers.nestedWrite("Y", y, 0, writer);
    }
};

test "Y" {
    try std.testing.expectEqual(8, @sizeOf(Y));
}

test {
    std.testing.refAllDecls(@This());
}
