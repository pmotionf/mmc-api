const std = @import("std");
const cclink = @import("../cclink.zig");

const Distance = cclink.Distance;
/// Registers written through CC-Link's "DevWr" device. Used as a "read"
/// register bank.
pub const Wr = packed struct(u256) {
    command_response: CommandResponseCode = .NoError,
    slider_number: packed struct(u48) {
        axis1: u16 = 0,
        axis2: u16 = 0,
        axis3: u16 = 0,

        pub fn axis(self: @This(), local_axis: u2) u16 {
            std.debug.assert(local_axis <= 2);
            return switch (local_axis) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                _ => error.InvalidAxis,
            };
        }
    } = .{},
    slider_location: packed struct(u96) {
        axis1: Distance = .{},
        axis2: Distance = .{},
        axis3: Distance = .{},

        pub fn axis(self: @This(), local_axis: u2) Distance {
            std.debug.assert(local_axis <= 2);
            return switch (local_axis) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                _ => error.InvalidAxis,
            };
        }
    } = .{},
    slider_state: packed struct(u48) {
        axis1: SliderStateCode = .None,
        axis2: SliderStateCode = .None,
        axis3: SliderStateCode = .None,

        pub fn axis(self: @This(), local_axis: u2) SliderStateCode {
            std.debug.assert(local_axis <= 2);
            return switch (local_axis) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                _ => error.InvalidAxis,
            };
        }
    } = .{},
    pitch_count: packed struct(u48) {
        axis1: i16 = 0,
        axis2: i16 = 0,
        axis3: i16 = 0,

        pub fn axis(self: @This(), local_axis: u2) i16 {
            std.debug.assert(local_axis <= 2);
            return switch (local_axis) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                _ => error.InvalidAxis,
            };
        }
    } = .{},

    pub const CommandResponseCode = enum(i16) {
        NoError = 0,
        InvalidCommand = 1,
        SliderNotFound = 2,
        HomingFailed = 3,
        InvalidParameter = 4,
        InvalidSystemState = 5,
        SliderAlreadyExists = 6,
        InvalidAxis = 7,

        pub fn throwError(code: CommandResponseCode) !void {
            return switch (code) {
                .NoError => {},
                .InvalidCommand => error.InvalidCommand,
                .SliderNotFound => error.SliderNotFound,
                .HomingFailed => error.HomingFailed,
                .InvalidParameter => error.InvalidParameter,
                .InvalidSystemState => error.InvalidSystemState,
                .SliderAlreadyExists => error.SliderAlreadyExists,
                .InvalidAxis => error.InvalidAxis,
            };
        }
    };

    pub const SliderStateCode = enum(u16) {
        None = 0,
        WarmupProgressing = 1,
        WarmupCompleted = 2,
        WarmupFault = 3,
        CurrentBiasProgressing = 4,
        CurrentBiasCompleted = 5,
        HomeForward = 6,
        HomeBackward = 7,
        RampForwardProgressing = 8,
        RampForwardCompleted = 9,
        RampForwardFault = 10,
        RampBackwardProgressing = 11,
        RampBackwardCompleted = 12,
        RampBackwardFault = 13,
        CurrentStepProgressing = 20,
        CurrentStepCompleted = 21,
        CurrentStepFault = 22,
        SpeedStepProgressing = 23,
        SpeedStepCompleted = 24,
        SpeedStepFault = 25,
        PosStepProgressing = 26,
        PosStepCompleted = 27,
        PosStepFault = 28,
        PosMoveProgressing = 29,
        PosMoveCompleted = 30,
        PosMoveFault = 31,
        ForwardCalibrationProgressing = 32,
        ForwardCalibrationCompleted = 33,
        BackwardIsolationProgressing = 34,
        BackwardIsolationCompleted = 35,
        ForwardRecoveryProgressing = 36,
        ForwardRecoveryCompleted = 37,
        BackwardRecoveryProgressing = 38,
        BackwardRecoveryCompleted = 39,
        SpdMoveProgressing = 40,
        SpdMoveCompleted = 41,
        SpdMoveFault = 42,
        NextAxisAuxiliary = 43,
        // Note: Next Axis Completed will show even when the next axis is
        // progressing, if the slider is paused for collision avoidance on the
        // next axis.
        NextAxisCompleted = 44,
        PrevAxisAuxiliary = 45,
        // Note: Prev Axis Completed will show even when the prev axis is
        // progressing, if the slider is paused for collision avoidance on the
        // prev axis.
        PrevAxisCompleted = 46,
        ForwardIsolationProgressing = 47,
        ForwardIsolationCompleted = 48,
        Overcurrent = 50,
        CommunicationError = 51,
        PullForwardProgressing = 52,
        PullForwardCompleted = 53,
        PullForwardFault = 54,
        PullBackwardProgressing = 55,
        PullBackwardCompleted = 56,
        PullBackwardFault = 57,
        BackwardCalibrationProgressing = 58,
        BackwardCalibrationCompleted = 59,
        BackwardCalibrationFault = 60,
        ForwardCalibrationFault = 61,
        _,
    };

    pub fn format(wr: Wr, writer: anytype) !void {
        _ = try cclink.nestedWrite("Wr", wr, 0, writer);
    }
};

test "Wr" {
    try std.testing.expectEqual(32, @sizeOf(Wr));
}

test {
    std.testing.refAllDecls(@This());
}
