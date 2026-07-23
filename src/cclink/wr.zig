const std = @import("std");
const registers = @import("../registers.zig");

const Distance = registers.Distance;

/// Registers written through CC-Link's "DevWr" device. Used as a "read"
/// register bank.
pub const Wr = packed struct(u256) {
    command_response: CommandResponseCode = .no_error,
    slider_number: packed struct(u48) {
        axis1: u16 = 0,
        axis2: u16 = 0,
        axis3: u16 = 0,

        pub fn axis(self: @This(), a: u2) u16 {
            return switch (a) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `slider_number`",
                        .{},
                    );
                    unreachable;
                },
            };
        }
    } = .{},
    slider_location: packed struct(u96) {
        axis1: Distance = .{},
        axis2: Distance = .{},
        axis3: Distance = .{},

        pub fn axis(self: @This(), a: u2) Distance {
            return switch (a) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `slider_location`",
                        .{},
                    );
                    unreachable;
                },
            };
        }
    } = .{},
    slider_state: packed struct(u48) {
        axis1: SliderStateCode = .None,
        axis2: SliderStateCode = .None,
        axis3: SliderStateCode = .None,

        pub fn axis(self: @This(), a: u2) SliderStateCode {
            return switch (a) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `slider_state`",
                        .{},
                    );
                    unreachable;
                },
            };
        }
    } = .{},
    pitch_count: packed struct(u48) {
        axis1: i16 = 0,
        axis2: i16 = 0,
        axis3: i16 = 0,

        pub fn axis(self: @This(), a: u2) i16 {
            return switch (a) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                3 => {
                    std.log.err(
                        "Invalid axis index 3 for `pitch_count`",
                        .{},
                    );
                    unreachable;
                },
            };
        }
    } = .{},

    pub const CommandResponseCode = enum(i16) {
        no_error = 0,
        invalid_command = 1,
        slider_not_found = 2,
        homing_failed = 3,
        invalid_parameter = 4,
        invalid_system_state = 5,
        slider_already_exists = 6,
        invalid_axis = 7,
        invalid_target_location = 8,

        pub fn throwError(code: CommandResponseCode) !void {
            return switch (code) {
                .no_error => {},
                .invalid_command => return error.InvalidCommand,
                .slider_not_found => return error.SliderNotFound,
                .homing_failed => return error.HomingFailed,
                .invalid_parameter => return error.InvalidParameter,
                .invalid_system_state => return error.InvalidSystemState,
                .slider_already_exists => return error.SliderAlreadyExists,
                .invalid_axis => return error.InvalidAxis,
                .invalid_target_location => return error.InvalidTargetLocation,
            };
        }
    };

    pub const SliderStateCode = enum(i16) {
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
        // TODO: Clarify names of below
        FwdEncProgressing = 14,
        FwdEncCompleted = 15,
        FwdEncFault = 16,
        BwdEncProgressing = 17,
        BwdEncCompleted = 18,
        BwdEncFault = 19,
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
        ForwardRestartProgressing = 36,
        ForwardRestartCompleted = 37,
        BackwardRestartProgressing = 38,
        BackwardRestartCompleted = 39,
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
        PullForward = 52,
        PullForwardCompleted = 53,
        PullForwardFault = 54,
        PullBackward = 55,
        PullBackwardCompleted = 56,
        PullBackwardFault = 57,
        BackwardCalibrationProgressing = 58,
        BackwardCalibrationCompleted = 59,
        BackwardCalibrationFault = 60,
        ForwardCalibrationFault = 61,

        ChainProgressing = 62,
        ChainCompleted = 63,
        ChainFault = 64,
        ChainSlaveProgressing = 65,
        ChainSlaveCompleted = 66,
    };

    pub fn format(wr: Wr, writer: anytype) !void {
        _ = try registers.nestedWrite("Wr", wr, 0, writer);
    }
};

test "Wr" {
    try std.testing.expectEqual(32, @sizeOf(Wr));
}

test {
    std.testing.refAllDecls(@This());
}
