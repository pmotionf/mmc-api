const std = @import("std");
const registers = @import("../registers.zig");

const Direction = registers.Direction;

/// Registers written through CC-Link's "DevX" device. Used as a "read"
/// register bank.
pub const X = packed struct(u64) {
    cc_link_enabled: bool = false,
    service_enabled: bool = false,
    ready_for_command: bool = false,
    servo_active: packed struct(u3) {
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), a: u2) bool {
            return switch (a) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `servo_active`",
                        .{},
                    );
                    unreachable;
                },
            };
        }
    } = .{},
    servo_enabled: bool = false,
    emergency_stop_enabled: bool = false,
    paused: bool = false,
    axis_slider_info_cleared: bool = false,
    command_received: bool = false,
    axis_enabled: packed struct(u3) {
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), a: u2) bool {
            return switch (a) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `axis_enabled`",
                        .{},
                    );
                    unreachable;
                },
            };
        }
    } = .{},
    in_position: packed struct(u3) {
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), a: u2) bool {
            return switch (a) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err("Invalid axis index 3 for `in_position`", .{});
                    unreachable;
                },
            };
        }
    } = .{},
    entered_front: packed struct(u3) {
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), a: u2) bool {
            return switch (a) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `entered_front`",
                        .{},
                    );
                    unreachable;
                },
            };
        }
    } = .{},
    entered_back: packed struct(u3) {
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), a: u2) bool {
            return switch (a) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `entered_back`",
                        .{},
                    );
                    unreachable;
                },
            };
        }
    } = .{},
    transmission_stopped: packed struct(u2) {
        to_prev: bool = false,
        to_next: bool = false,

        pub fn to(self: @This(), dir: Direction) bool {
            return switch (dir) {
                .backward => self.to_prev,
                .forward => self.to_next,
            };
        }
    } = .{},
    errors_cleared: bool = false,
    communication_error: packed struct(u2) {
        to_prev: bool = false,
        to_next: bool = false,

        pub fn to(self: @This(), dir: Direction) bool {
            return switch (dir) {
                .backward => self.to_prev,
                .forward => self.to_next,
            };
        }
    } = .{},
    inverter_overheat_detected: bool = false,
    overcurrent_detected: packed struct(u3) {
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), a: u2) bool {
            return switch (a) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `overcurrent_detected`",
                        .{},
                    );
                    unreachable;
                },
            };
        }
    } = .{},
    control_failure: packed struct(u3) {
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), a: u2) bool {
            return switch (a) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `control_failure`",
                        .{},
                    );
                    unreachable;
                },
            };
        }
    } = .{},
    hall_alarm: packed struct(u6) {
        axis1: packed struct(u2) {
            back: bool = false,
            front: bool = false,
        } = .{},
        axis2: packed struct(u2) {
            back: bool = false,
            front: bool = false,
        } = .{},
        axis3: packed struct(u2) {
            back: bool = false,
            front: bool = false,
        } = .{},

        pub fn axis(self: @This(), a: u2) packed struct(u2) {
            back: bool,
            front: bool,
        } {
            return switch (a) {
                0 => .{
                    .back = self.axis1.back,
                    .front = self.axis1.front,
                },
                1 => .{
                    .back = self.axis2.back,
                    .front = self.axis2.front,
                },
                2 => .{
                    .back = self.axis3.back,
                    .front = self.axis3.front,
                },
                3 => {
                    std.log.err("Invalid axis index 3 for `hall_alarm`", .{});
                    unreachable;
                },
            };
        }
    } = .{},
    self_pause: packed struct(u3) {
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), a: u2) bool {
            return switch (a) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err("Invalid axis index 3 for `self_pause`", .{});
                    unreachable;
                },
            };
        }
    } = .{},
    pulling_slider: packed struct(u3) {
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), a: u2) bool {
            return switch (a) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `pulling_slider`",
                        .{},
                    );
                    unreachable;
                },
            };
        }
    } = .{},
    control_loop_max_time_exceeded: bool = false,
    hall_alarm_abnormal: packed struct(u6) {
        axis1: packed struct(u2) {
            back: bool = false,
            front: bool = false,
        } = .{},
        axis2: packed struct(u2) {
            back: bool = false,
            front: bool = false,
        } = .{},
        axis3: packed struct(u2) {
            back: bool = false,
            front: bool = false,
        } = .{},

        pub fn axis(self: @This(), a: u2) packed struct(u2) {
            back: bool,
            front: bool,
        } {
            return switch (a) {
                0 => .{
                    .back = self.axis1.back,
                    .front = self.axis1.front,
                },
                1 => .{
                    .back = self.axis2.back,
                    .front = self.axis2.front,
                },
                2 => .{
                    .back = self.axis3.back,
                    .front = self.axis3.front,
                },
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `hall_alarm_abnormal`",
                        .{},
                    );
                    unreachable;
                },
            };
        }
    } = .{},
    chain_enabled: packed struct(u6) {
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
                        "Invalid axis index 3 for `chain_enabled`",
                        .{},
                    );
                    unreachable;
                },
            };
        }
    } = .{},
    _60: u4 = 0,

    pub fn format(x: X, writer: anytype) !void {
        _ = try registers.nestedWrite("x", x, 0, writer);
    }
};

test "X" {
    try std.testing.expectEqual(8, @sizeOf(X));
}

test {
    std.testing.refAllDecls(@This());
}
