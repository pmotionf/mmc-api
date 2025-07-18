const std = @import("std");
const build = @import("build.zig.zon");

pub const protobuf = @import("protobuf");

pub const mmc_msg = @import("proto/mmc.pb.zig");
pub const command_msg = @import("proto/mmc/command.pb.zig");
pub const core_msg = @import("proto/mmc/core.pb.zig");
pub const info_msg = @import("proto/mmc/info.pb.zig");

pub const version =
    std.SemanticVersion.parse(build.version) catch unreachable;

pub fn convertEnum(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime Target: type,
    comptime style: enum {
        upper_snake_to_pascal,
        pascal_to_upper_snake,
        lower_snake_to_upper_snake,
        upper_snake_to_lower_snake,
    },
) !Target {
    if ((@typeInfo(@TypeOf(source)) != .@"enum" or
        @typeInfo(@TypeOf(source)) != .error_set) and
        @typeInfo(Target) != .@"enum")
        @compileError("InvalidType");
    const prefix = comptime blk: {
        const ti = @typeInfo(Target).@"enum";
        // Compare the first two enum field to get the correct prefix
        const diff_idx = std.mem.indexOfDiff(
            u8,
            ti.fields[0].name,
            ti.fields[1].name,
        ).?;
        break :blk ti.fields[0].name[0..diff_idx];
    };
    const target_style = blk: {
        switch (@typeInfo(@TypeOf(source))) {
            .@"enum" => |ti| {
                inline for (ti.fields) |field| {
                    if (field.value == @intFromEnum(source)) {
                        break :blk switch (style) {
                            .upper_snake_to_pascal => upperSnakeToPascal(field.name),
                            .pascal_to_upper_snake => pascalToUpperSnake(field.name),
                            .lower_snake_to_upper_snake => lowerSnakeToUpperSnake(field.name),
                            .upper_snake_to_lower_snake => upperSnakeToLowerSnake(field.name),
                        };
                    }
                }
                unreachable;
            },
            .error_set => |ti| {
                inline for (ti.?) |err| {
                    if (std.mem.eql(u8, err.name, @errorName(source))) break :blk switch (style) {
                        .upper_snake_to_pascal => upperSnakeToPascal(err.name),
                        .pascal_to_upper_snake => pascalToUpperSnake(err.name),
                        .lower_snake_to_upper_snake => lowerSnakeToUpperSnake(err.name),
                        .upper_snake_to_lower_snake => upperSnakeToLowerSnake(err.name),
                    };
                }
                unreachable;
            },
            else => unreachable,
        }
    };
    const target_name = try std.fmt.allocPrint(
        allocator,
        "{s}{s}",
        .{ prefix, target_style },
    );
    defer allocator.free(target_name);
    const ti = @typeInfo(Target).@"enum";
    inline for (ti.fields) |field| {
        if (std.mem.eql(u8, field.name, target_name)) {
            return @enumFromInt(field.value);
        }
    }
    unreachable;
}

test convertEnum {
    const CommandStatus = enum { Completed };
    const command_status: CommandStatus = .Completed;
    const res: info_msg.Response.Command.Status = try convertEnum(
        std.testing.allocator,
        command_status,
        info_msg.Response.Command.Status,
        .pascal_to_upper_snake,
    );
    try std.testing.expectEqual(
        res,
        info_msg.Response.Command.Status.STATUS_COMPLETED,
    );
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
            if (val) |v| {
                written_bytes += try nestedWrite(
                    name,
                    v,
                    indent,
                    writer,
                );
            } else {
                try writer.writeBytesNTimes("    ", indent);
                written_bytes += 4 * indent;
                try writer.print("{s}: ", .{name});
                written_bytes += name.len + 2;
                try writer.print("None,\n", .{});
                written_bytes += std.fmt.count("None,\n", .{});
            }
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

pub fn upperSnakeToPascal(comptime input: []const u8) []const u8 {
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

test upperSnakeToPascal {
    const upper_snake = "CLEAR_CARRIER_INFO8";
    const pascal = "ClearCarrierInfo8";
    try std.testing.expectEqualStrings(pascal, upperSnakeToPascal(upper_snake));
}

pub fn pascalToUpperSnake(comptime input: []const u8) []const u8 {
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

test pascalToUpperSnake {
    const upper_snake = "CLEAR_CARRIER_INFO8";
    const pascal = "ClearCarrierInfo8";
    try std.testing.expectEqualStrings(
        upper_snake,
        pascalToUpperSnake(pascal),
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
