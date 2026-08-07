const std = @import("std");
const cclink = @import("../cclink.zig");

const Distance = cclink.Distance;

/// Registers written through CC-Link's "DevWw" device. Used as a "write"
/// register bank.
pub const Ww = packed struct(u256) {
    command_code: CommandCode = .None,
    command_slider_number: u16 = 0,
    target_axis_number: u16 = 0,
    location_distance: Distance = .{},
    speed_percentage: u16 = 0,
    acceleration_percentage: u16 = 0,
    _112: u144 = 0,

    pub const CommandCode = enum(u16) {
        None = 0,
        Home = 17,
        // "By Position" commands calculate slider movement by constant hall
        // sensor position feedback, and is much more precise in destination.
        MoveSliderToAxisByPosition = 18,
        MoveSliderToLocationByPosition = 19,
        MoveSliderDistanceByPosition = 20,
        // "By Speed" commands calculate slider movement by constant hall
        // sensor speed feedback. It should mostly not be used, as the
        // destination position becomes far too imprecise. However, it is
        // meant to maintain a certain speed while the slider is traveling, and
        // to avoid the requirement of having a known system position.
        MoveSliderToAxisBySpeed = 21,
        MoveSliderToLocationBySpeed = 22,
        MoveSliderDistanceBySpeed = 23,
        IsolateForward = 24,
        IsolateBackward = 25,
        Calibration = 26,
        RecoverSystemSliders = 27,
        RecoverSliderAtAxis = 28,
        PushAxisSliderForward = 30,
        PushAxisSliderBackward = 31,
        PullAxisSliderForward = 32,
        PullAxisSliderBackward = 33,
        _,
    };

    pub fn format(ww: Ww, writer: anytype) !void {
        _ = try cclink.nestedWrite("Ww", ww, 0, writer);
    }
};

test "Ww" {
    try std.testing.expectEqual(32, @sizeOf(Ww));
}

test {
    std.testing.refAllDecls(@This());
}
