const std = @import("std");
const cclink = @import("../cclink.zig");

/// Registers written through CC-Link's "DevWw" device. Used as a "write"
/// register bank.
pub const Ww = packed struct(u256) {
    command: Command = .none,
    axis: u16 = 0,
    carrier: packed struct(u80) {
        target: f32 = 0.0,
        id: u10 = 0,
        control_kind: ControlKind = .none,
        disable_cas: bool = false,
        isolate_link_prev_axis: bool = false,
        isolate_link_next_axis: bool = false,
        _46: u1 = 0,
        velocity: u10 = 0,
        /// Whether velocity should be interpreted in centimeters (false) or
        /// in 100-micrometers (true).
        low_velocity: bool = false,
        _59: u5 = 0,
        acceleration: u16 = 0,
    } = .{},
    _112: u144 = 0,

    pub const ControlKind = enum(u2) {
        none = 0,
        velocity = 1,
        position = 2,
    };

    pub const Command = enum(i16) {
        none = 0x0,

        /// Find and set zero offset of axis's hall sensor angles.
        set_sensors_zero = 0x1,
        /// Set zero point of line at current carrier position.
        set_line_zero = 0x2,

        initialize_fwd = 0x3,
        initialize_bwd = 0x4,

        /// Set initialized carrier's ID at axis.
        set_id_axis = 0x6,

        /// Release carrier control.
        release = 0x7,
        /// Deinitialize carrier, releasing control and erasing stored info.
        deinitialize = 0x8,

        /// Absolute location movement.
        move_abs = 0x10,
        /// Relative distance movement.
        move_rel = 0x11,

        push = 0x20,
        pull = 0x21,
    };

    pub fn format(ww: Ww, writer: anytype) !void {
        _ = try cclink.nestedWrite("Ww", ww, 0, writer);
    }
};

test "Ww" {
    try std.testing.expectEqual(32, @sizeOf(Ww));
    try std.testing.expectEqual(
        32,
        @bitSizeOf(
            @FieldType(
                @FieldType(Ww, "carrier"),
                "target",
            ),
        ),
    );
}
