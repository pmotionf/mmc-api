const std = @import("std");
const cclink = @import("../cclink.zig");

const Direction = cclink.Direction;

/// Registers written through CC-Link's "DevX" device. Used as a "read"
/// register bank.
pub const X = packed struct(u64) {
    cc_link_enabled: bool = false, //X00
    service_enabled: bool = false, //X01
    ready_for_command: bool = false, //X02
    servo_active: packed struct(u3) { //X03-X05
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
    } = .{},
    servo_enabled: bool = false, //X06
    emergency_stop_enabled: bool = false, //X07
    paused: bool = false, //X08
    axis_slider_info_cleared: bool = false, //X09
    command_received: bool = false, //X0A
    axis_enabled: packed struct(u3) { //X0B,X0C,X0D
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
    } = .{},
    in_position: packed struct(u3) { //X0E,X0F,X10
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
    } = .{},
    entered_front: packed struct(u3) { //X11,X12,X13
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
    } = .{},
    entered_back: packed struct(u3) { //X14,X15,X16
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
    } = .{},
    transmission_stopped: packed struct(u2) { //X17,X18
        from_prev: bool = false,
        from_next: bool = false,

        pub fn from(self: @This(), dir: Direction) bool {
            return switch (dir) {
                .backward => self.from_prev,
                .forward => self.from_next,
            };
        }
    } = .{},
    errors_cleared: bool = false, //X19
    communication_error: packed struct(u2) { //X1A,X1B
        from_prev: bool = false,
        from_next: bool = false,

        pub fn from(self: @This(), dir: Direction) bool {
            return switch (dir) {
                .backward => self.from_prev,
                .forward => self.from_next,
            };
        }
    } = .{},
    inverter_overheat_detected: bool = false, //X1C
    overcurrent_detected: packed struct(u3) { //X1D,X1E,X1F
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
    } = .{},
    control_failure: packed struct(u3) { //X20,X21,X22
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
    } = .{},
    hall_alarm: packed struct(u6) {
        axis1: packed struct(u2) { //X23,X24
            back: bool = false,
            front: bool = false,
        } = .{},
        axis2: packed struct(u2) { //X25,X26
            back: bool = false,
            front: bool = false,
        } = .{},
        axis3: packed struct(u2) { //X27,X28
            back: bool = false,
            front: bool = false,
        } = .{},

        pub fn axis(self: @This(), a: u2) error{InvalidAxis}!packed struct(u2) {
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
                _ => error.InvalidAxis,
            };
        }
    } = .{},
    self_pause: packed struct(u3) { //X29,X2A,X2B
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
    } = .{},
    pulling_slider: packed struct(u3) { //X2C,X2D,X2E
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
    } = .{},
    _x2f: u1 = 0, //X2F
    hall_alarm_abnormal: packed struct(u6) {
        axis1: packed struct(u2) { //X30,X31
            back: bool = false,
            front: bool = false,
        } = .{},
        axis2: packed struct(u2) { //X32,X33
            back: bool = false,
            front: bool = false,
        } = .{},
        axis3: packed struct(u2) { //X34,X35
            back: bool = false,
            front: bool = false,
        } = .{},

        pub fn axis(
            self: @This(),
            a: u2,
        ) error{InvalidAxis}!packed struct(u2) { back: bool, front: bool } {
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
                _ => error.InvalidAxis,
            };
        }
    } = .{},
    lockup: packed struct(u3) { //X36,X37,X38
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
    } = .{},
    _57: u7 = 0, //X39,X3A,X3B,X3C,X3D,X3E,X3F

    pub fn format(x: X, writer: anytype) !void {
        _ = try cclink.nestedWrite("X", x, 0, writer);
    }
};

test "X" {
    try std.testing.expectEqual(8, @sizeOf(X));
}

test {
    std.testing.refAllDecls(@This());
}
