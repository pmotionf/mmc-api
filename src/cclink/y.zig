const std = @import("std");
const cclink = @import("../cclink.zig");

const Direction = cclink.Direction;

/// Registers written through CC-Link's "DevY" device. Used as a "write"
/// register bank.
pub const Y = packed struct(u64) {
    cc_link_enable: bool = false, //Y00
    service_enable: bool = false, //Y01
    start_command: bool = false, //Y02
    reset_command_received: bool = false, //Y03
    cancel_slider_commands: bool = false, //Y04, deprecated,
    axis_servo_release: bool = false, //Y05,deprecated
    release_control: bool = false, //Y06, Release all motor control
    emergency_stop: bool = false, //Y07
    temporary_pause: bool = false, //Y08
    stop_driver_transmission: packed struct(u2) { //Y09,Y0A
        from_prev: bool = false,
        from_next: bool = false,

        pub fn set(
            self: *align(8:9:8) @This(),
            dir: Direction,
        ) void {
            switch (dir) {
                .backward => self.from_prev = true,
                .forward => self.from_next = true,
            }
        }

        pub fn reset(self: *align(8:9:8) @This(), dir: Direction) void {
            switch (dir) {
                .backward => self.from_prev = false,
                .forward => self.from_next = false,
            }
        }
    } = .{},
    clear_errors: bool = false, //Y0B
    clear_axis_slider_info: bool = false, //Y0C
    prev_axis_isolate_link: bool = false, //Y0D
    next_axis_isolate_link: bool = false, //Y0E
    _15: u1 = 0, //Y0F
    reset_pull_slider: packed struct(u3) { //Y10,Y11,Y12
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), a: u2) error{InvalidAxis}!bool {
            return switch (a) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                _ => error.InvalidAxis,
            };
        }

        pub fn setAxis(
            self: *align(8:16:8) @This(),
            local_axis: u2,
        ) error{InvalidAxis}!void {
            switch (local_axis) {
                0 => self.axis1 = true,
                1 => self.axis2 = true,
                2 => self.axis3 = true,
                _ => return error.InvalidAxis,
            }
        }

        pub fn resetAxis(
            self: *align(8:16:8) @This(),
            local_axis: u2,
        ) error{InvalidAxis}!void {
            switch (local_axis) {
                0 => self.axis1 = false,
                1 => self.axis2 = false,
                2 => self.axis3 = false,
                _ => return error.InvalidAxis,
            }
        }
    } = .{},
    recovery_use_hall_sensor: packed struct(u2) { //Y13,Y14
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
        ) void {
            switch (dir) {
                .backward => self.back = true,
                .forward => self.front = true,
            }
        }
        pub fn resetSide(
            self: *align(8:19:8) @This(),
            dir: Direction,
        ) void {
            switch (dir) {
                .backward => self.back = false,
                .forward => self.front = false,
            }
        }
    } = .{},
    link_chain: packed struct(u6) { //Y15,Y16,Y17,Y18,Y19,Y1A
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

        pub fn axis(self: @This(), a: u2) error{InvalidAxis}!packed struct(u2) {
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
                _ => error.InvalidAxis,
            };
        }

        const ChainSide = enum {
            Forward,
            Backward,
            BothSide,
        };

        pub fn setAxis(
            self: *align(8:21:8) @This(),
            a: u2,
            side: ChainSide,
        ) error{InvalidAxis}!void {
            switch (a) {
                0 => switch (side) {
                    .Forward => self.axis1.forward = true,
                    .Backward => self.axis1.backward = true,
                    .BothSide => {
                        self.axis1.forward = true;
                        self.axis1.backward = true;
                    },
                },
                1 => switch (side) {
                    .Forward => self.axis2.forward = true,
                    .Backward => self.axis2.backward = true,
                    .BothSide => {
                        self.axis2.forward = true;
                        self.axis2.backward = true;
                    },
                },
                2 => switch (side) {
                    .Forward => self.axis3.forward = true,
                    .Backward => self.axis3.backward = true,
                    .BothSide => {
                        self.axis3.forward = true;
                        self.axis3.backward = true;
                    },
                },
                _ => return error.InvalidAxis,
            }
        }

        pub fn resetAxis(
            self: *align(8:21:8) @This(),
            a: u2,
            side: ChainSide,
        ) error{InvalidAxis}!void {
            switch (a) {
                0 => switch (side) {
                    .Forward => self.axis1.forward = false,
                    .Backward => self.axis1.backward = false,
                    .BothSide => {
                        self.axis1.forward = false;
                        self.axis1.backward = false;
                    },
                },
                1 => switch (side) {
                    .Forward => self.axis2.forward = false,
                    .Backward => self.axis2.backward = false,
                    .BothSide => {
                        self.axis2.forward = false;
                        self.axis2.backward = false;
                    },
                },
                2 => switch (side) {
                    .Forward => self.axis3.forward = false,
                    .Backward => self.axis3.backward = false,
                    .BothSide => {
                        self.axis3.forward = false;
                        self.axis3.backward = false;
                    },
                },
                _ => return error.InvalidAxis,
            }
        }
    } = .{},
    unlink_chain: packed struct(u6) { //Y1B,Y1C,Y1D,Y1E,Y1F,Y20
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

        pub fn axis(
            self: @This(),
            a: u2,
        ) error{InvalidAxis}!packed struct(u2) {
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
                _ => error.InvalidAxis,
            };
        }

        const ChainSide = enum {
            Forward,
            Backward,
            BothSide,
        };

        pub fn setAxis(
            self: *align(8:27:8) @This(),
            a: u2,
            side: ChainSide,
        ) error{InvalidAxis}!void {
            switch (a) {
                0 => switch (side) {
                    .Forward => self.axis1.forward = true,
                    .Backward => self.axis1.backward = true,
                    .BothSide => {
                        self.axis1.forward = true;
                        self.axis1.backward = true;
                    },
                },
                1 => switch (side) {
                    .Forward => self.axis2.forward = true,
                    .Backward => self.axis2.backward = true,
                    .BothSide => {
                        self.axis2.forward = true;
                        self.axis2.backward = true;
                    },
                },
                2 => switch (side) {
                    .Forward => self.axis3.forward = true,
                    .Backward => self.axis3.backward = true,
                    .BothSide => {
                        self.axis3.forward = true;
                        self.axis3.backward = true;
                    },
                },
                _ => return error.InvalidAxis,
            }
        }

        pub fn resetAxis(
            self: *align(8:27:8) @This(),
            a: u2,
            side: ChainSide,
        ) error{InvalidAxis}!void {
            switch (a) {
                0 => switch (side) {
                    .Forward => self.axis1.forward = false,
                    .Backward => self.axis1.backward = false,
                    .BothSide => {
                        self.axis1.forward = false;
                        self.axis1.backward = false;
                    },
                },
                1 => switch (side) {
                    .Forward => self.axis2.forward = false,
                    .Backward => self.axis2.backward = false,
                    .BothSide => {
                        self.axis2.forward = false;
                        self.axis2.backward = false;
                    },
                },
                2 => switch (side) {
                    .Forward => self.axis3.forward = false,
                    .Backward => self.axis3.backward = false,
                    .BothSide => {
                        self.axis3.forward = false;
                        self.axis3.backward = false;
                    },
                },
                _ => return error.InvalidAxis,
            }
        }
    } = .{},
    get_speed_info: bool, //Y21,
    get_current_info: bool, //Y22
    lockup: packed struct(u3) { //Y23,Y24,Y25
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), a: u2) error{InvalidAxis}!bool {
            return switch (a) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                _ => error.InvalidAxis,
            };
        }

        pub fn setAxis(
            self: *align(8:35:8) @This(),
            local_axis: u2,
        ) error{InvalidAxis}!void {
            switch (local_axis) {
                0 => self.axis1 = true,
                1 => self.axis2 = true,
                2 => self.axis3 = true,
                _ => return error.InvalidAxis,
            }
        }

        pub fn resetAxis(
            self: *align(8:35:8) @This(),
            local_axis: u2,
        ) error{InvalidAxis}!void {
            switch (local_axis) {
                0 => self.axis1 = false,
                1 => self.axis2 = false,
                2 => self.axis3 = false,
                _ => return error.InvalidAxis,
            }
        }
    } = .{},
    _38: u25 = 0,

    pub fn format(y: Y, writer: anytype) !void {
        _ = try cclink.nestedWrite("Y", y, 0, writer);
    }
};

test "Y" {
    try std.testing.expectEqual(8, @sizeOf(Y));
}

test {
    std.testing.refAllDecls(@This());
}
