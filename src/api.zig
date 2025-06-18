const std = @import("std");
const build = @import("build.zig.zon");

pub const protobuf = @import("protobuf");

// pub const protobuf_msg = @import("proto/mmc.pb.zig");
pub const command_msg = @import("proto/mmc/command.pb.zig");
pub const core_msg = @import("proto/mmc/core.pb.zig");
pub const info_msg = @import("proto/mmc/info.pb.zig");

pub const version =
    std.SemanticVersion.parse(build.version) catch unreachable;

// TODO: Find a way to modify generated zig protobuf file to get axis directly
/// Get axis specific information from a register's field.
pub fn getAxisInfo(comptime Output: type, src: anytype, local_axis_idx: u2) Output {
    const ti = @typeInfo(@TypeOf(src)).@"struct";
    inline for (ti.fields, 0..) |field, axis| {
        const res = @field(src, field.name);
        const res_ti = @typeInfo(@TypeOf(res));
        if (local_axis_idx == axis) return if (res_ti == .optional) res.? else res;
    }
    unreachable;
}

test getAxisInfo {
    const axis2: info_msg.InfoResponse.RegisterX.HallAlarm.Side = .{
        .back = false,
        .front = false,
    };
    const example_x: info_msg.InfoResponse.RegisterX = .{
        .hall_alarm = .{ .axis2 = axis2 },
    };
    try std.testing.expectEqual(axis2, getAxisInfo(
        info_msg.InfoResponse.RegisterX.HallAlarm.Side,
        example_x.hall_alarm.?,
        1,
    ));
}

pub fn nestedWrite(
    name: []const u8,
    val: anytype,
    indent: usize,
    writer: anytype,
) !usize {
    var written_bytes: usize = 0;
    const ti = @typeInfo(@TypeOf(val));
    switch (ti) {
        .optional => {
            written_bytes += try nestedWrite(
                name,
                val.?,
                indent,
                writer,
            );
        },
        .@"struct" => {
            try writer.writeBytesNTimes("    ", indent);
            written_bytes += 4 * indent;
            try writer.print("{s}: {{\n", .{name});
            written_bytes += name.len + 4;
            inline for (ti.@"struct".fields) |field| {
                if (field.name[0] == '_') {
                    continue;
                }
                written_bytes += try nestedWrite(
                    field.name,
                    @field(val, field.name),
                    indent + 1,
                    writer,
                );
            }
            try writer.writeBytesNTimes("    ", indent);
            written_bytes += 4 * indent;
            try writer.writeAll("},\n");
            written_bytes += 3;
        },
        .bool, .int => {
            try writer.writeBytesNTimes("    ", indent);
            written_bytes += 4 * indent;
            try writer.print("{s}: ", .{name});
            written_bytes += name.len + 2;
            try writer.print("{},\n", .{val});
            written_bytes += std.fmt.count("{},\n", .{val});
        },
        .float => {
            try writer.writeBytesNTimes("    ", indent);
            written_bytes += 4 * indent;
            try writer.print("{s}: ", .{name});
            written_bytes += name.len + 2;
            try writer.print("{d},\n", .{val});
            written_bytes += std.fmt.count("{d},\n", .{val});
        },
        .@"enum" => {
            try writer.writeBytesNTimes("    ", indent);
            written_bytes += 4 * indent;
            try writer.print("{s}: ", .{name});
            written_bytes += name.len + 2;
            try writer.print("{s},\n", .{@tagName(val)});
            written_bytes += std.fmt.count("{s},\n", .{@tagName(val)});
        },
        .@"union" => {
            switch (val) {
                inline else => |_, tag| {
                    const union_val = @field(val, @tagName(tag));
                    try writer.writeBytesNTimes("    ", indent);
                    written_bytes += 4 * indent;
                    try writer.print("{s}: ", .{name});
                    written_bytes += name.len + 2;
                    try writer.print("{d},\n", .{union_val});
                    written_bytes += std.fmt.count("{d},\n", .{union_val});
                },
            }
        },
        else => {
            unreachable;
        },
    }
    return written_bytes;
}

test nestedWrite {
    const example_x: info_msg.InfoResponse.RegisterX = .{
        .hall_alarm = .{
            .axis1 = .{
                .back = false,
                .front = false,
            },
            .axis2 = .{
                .back = false,
                .front = false,
            },
            .axis3 = .{
                .back = false,
                .front = false,
            },
        },
    };
    var result_buffer: [2048]u8 = undefined;
    var buf = std.io.fixedBufferStream(&result_buffer);
    const buf_writer = buf.writer();
    try std.testing.expectEqualStrings(
        \\hall_alarm: {
        \\    axis1: {
        \\        back: false,
        \\        front: false,
        \\    },
        \\    axis2: {
        \\        back: false,
        \\        front: false,
        \\    },
        \\    axis3: {
        \\        back: false,
        \\        front: false,
        \\    },
        \\},
        \\
    ,
        result_buffer[0..try nestedWrite(
            "hall_alarm",
            example_x.hall_alarm,
            0,
            buf_writer,
        )],
    );
}

test "union nestedWrite" {
    const example_ww: info_msg.InfoResponse.RegisterWw = .{
        .carrier = .{
            .target = .{
                .f32 = 3.14,
            },
        },
    };
    var result_buffer: [2048]u8 = undefined;
    var buf = std.io.fixedBufferStream(&result_buffer);
    const buf_writer = buf.writer();
    try std.testing.expectEqualStrings(
        \\carrier: {
        \\    id: 0,
        \\    enable_cas: false,
        \\    isolate_link_prev_axis: false,
        \\    isolate_link_next_axis: false,
        \\    speed: 0,
        \\    acceleration: 0,
        \\    target: 3.14,
        \\},
        \\
    ,
        result_buffer[0..try nestedWrite(
            "carrier",
            example_ww.carrier,
            0,
            buf_writer,
        )],
    );
}

pub fn upperSnakeToTitle(comptime input: []const u8) []const u8 {
    comptime var result: []const u8 = "";
    comptime var prev_underscore: bool = false;
    inline for (input, 0..) |c, i| {
        if (prev_underscore or i == 0) {
            result = result ++ input[i .. i + 1];
            prev_underscore = false;
        } else if (c != '_') {
            result = result ++ std.fmt.comptimePrint(
                "{c}",
                .{comptime std.ascii.toLower(c)},
            );
        } else {
            prev_underscore = true;
        }
    }
    return result;
}

test upperSnakeToTitle {
    const upper_snake = "CLEAR_CARRIER_INFO8";
    const title = "ClearCarrierInfo8";
    try std.testing.expectEqualStrings(
        title,
        upperSnakeToTitle(upper_snake),
    );
}

pub fn titleToUpperSnake(comptime input: []const u8) []const u8 {
    comptime var result: []const u8 = "";
    inline for (input, 0..) |c, i| {
        if (i == 0) {
            result = result ++ input[i .. i + 1];
        } else if (comptime std.ascii.isUpper(c)) {
            result = result ++ "_";
            result = result ++ input[i .. i + 1];
        } else {
            result = result ++ std.fmt.comptimePrint(
                "{c}",
                .{comptime std.ascii.toUpper(c)},
            );
        }
    }
    return result;
}

test titleToUpperSnake {
    const upper_snake = "CLEAR_CARRIER_INFO8";
    const title = "ClearCarrierInfo8";
    try std.testing.expectEqualStrings(
        upper_snake,
        titleToUpperSnake(title),
    );
}

pub fn lowerSnakeToUpperSnake(comptime input: []const u8) []const u8 {
    comptime var result: []const u8 = "";
    inline for (input) |c| {
        result = result ++ std.fmt.comptimePrint(
            "{c}",
            .{comptime std.ascii.toUpper(c)},
        );
    }
    return result;
}

test lowerSnakeToUpperSnake {
    const lower_snake = "cc_link_1slot";
    const upper_snake = "CC_LINK_1SLOT";
    try std.testing.expectEqualStrings(
        upper_snake,
        lowerSnakeToUpperSnake(lower_snake),
    );
}

pub fn upperSnakeToLowerSnake(comptime input: []const u8) []const u8 {
    comptime var result: []const u8 = "";
    inline for (input) |c| {
        result = result ++ std.fmt.comptimePrint(
            "{c}",
            .{comptime std.ascii.toLower(c)},
        );
    }
    return result;
}

test upperSnakeToLowerSnake {
    const lower_snake = "cc_link_1slot";
    const upper_snake = "CC_LINK_1SLOT";
    try std.testing.expectEqualStrings(
        lower_snake,
        upperSnakeToLowerSnake(upper_snake),
    );
}

pub fn convertEnum(
    source: anytype,
    comptime target: type,
    style: enum {
        UpperSnakeToTitle,
        TitleToUpperSnake,
        LowerSnakeToUpperSnake,
        UpperSnakeToLowerSnake,
    },
) !target {
    if (@typeInfo(@TypeOf(source)) != .@"enum" and @typeInfo(target) != .@"enum")
        return error.InvalidType;
    const target_style = blk: {
        const ti = @typeInfo(@TypeOf(source)).@"enum";
        inline for (ti.fields) |field| {
            if (field.value == @intFromEnum(source)) {
                break :blk switch (style) {
                    .UpperSnakeToTitle => upperSnakeToTitle(field.name),
                    .TitleToUpperSnake => titleToUpperSnake(field.name),
                    .LowerSnakeToUpperSnake => lowerSnakeToUpperSnake(field.name),
                    .UpperSnakeToLowerSnake => upperSnakeToLowerSnake(field.name),
                };
            }
        }
        unreachable;
    };
    std.log.debug(
        "target style: {s}, source: {s}",
        .{ target_style, @tagName(source) },
    );
    const ti = @typeInfo(target).@"enum";
    inline for (ti.fields) |field| {
        if (std.mem.eql(u8, field.name, target_style)) {
            return @enumFromInt(field.value);
        }
    }
    return error.UnmatchedEnumField;
}
