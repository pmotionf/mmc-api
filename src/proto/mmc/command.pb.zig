// Code generated by protoc-gen-zig
///! package mmc.command
const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const protobuf = @import("protobuf");
const ManagedString = protobuf.ManagedString;
const fd = protobuf.fd;
const ManagedStruct = protobuf.ManagedStruct;

pub const Direction = enum(i32) {
    DIRECTION_UNSPECIFIED = 0,
    DIRECTION_BACKWARD = 1,
    DIRECTION_FORWARD = 2,
    _,
};

pub const ControlKind = enum(i32) {
    CONTROL_UNSPECIFIED = 0,
    CONTROL_POSITION = 1,
    CONTROL_VELOCITY = 2,
    _,
};

pub const Request = struct {
    body: ?body_union,

    pub const _body_case = enum {
        clear_errors,
        clear_carrier_info,
        release_control,
        stop_pull_carrier,
        stop_push_carrier,
        auto_initialize,
        move_carrier,
        push_carrier,
        pull_carrier,
        isolate_carrier,
        calibrate,
        set_line_zero,
        clear_command,
        clear_commands,
    };
    pub const body_union = union(_body_case) {
        clear_errors: Request.ClearErrors,
        clear_carrier_info: Request.ClearCarriers,
        release_control: Request.ReleaseControl,
        stop_pull_carrier: Request.StopPullCarrier,
        stop_push_carrier: Request.StopPushCarrier,
        auto_initialize: Request.AutoInitialize,
        move_carrier: Request.MoveCarrier,
        push_carrier: Request.PushCarrier,
        pull_carrier: Request.PullCarrier,
        isolate_carrier: Request.IsolateCarrier,
        calibrate: Request.Calibrate,
        set_line_zero: Request.SetLineZero,
        clear_command: Request.ClearCommand,
        clear_commands: Request.ClearCommands,
        pub const _union_desc = .{
            .clear_errors = fd(1, .{ .SubMessage = {} }),
            .clear_carrier_info = fd(2, .{ .SubMessage = {} }),
            .release_control = fd(3, .{ .SubMessage = {} }),
            .stop_pull_carrier = fd(4, .{ .SubMessage = {} }),
            .stop_push_carrier = fd(5, .{ .SubMessage = {} }),
            .auto_initialize = fd(6, .{ .SubMessage = {} }),
            .move_carrier = fd(7, .{ .SubMessage = {} }),
            .push_carrier = fd(8, .{ .SubMessage = {} }),
            .pull_carrier = fd(9, .{ .SubMessage = {} }),
            .isolate_carrier = fd(10, .{ .SubMessage = {} }),
            .calibrate = fd(11, .{ .SubMessage = {} }),
            .set_line_zero = fd(12, .{ .SubMessage = {} }),
            .clear_command = fd(13, .{ .SubMessage = {} }),
            .clear_commands = fd(14, .{ .SubMessage = {} }),
        };
    };

    pub const _desc_table = .{
        .body = fd(null, .{ .OneOf = body_union }),
    };

    pub const ReleaseControl = struct {
        line_id: u32 = 0,
        axis_id: ?u32 = null,

        pub const _desc_table = .{
            .line_id = fd(1, .{ .Varint = .Simple }),
            .axis_id = fd(2, .{ .Varint = .Simple }),
        };

        pub usingnamespace protobuf.MessageMixins(@This());
    };

    pub const StopPullCarrier = struct {
        line_id: u32 = 0,
        axis_id: ?u32 = null,

        pub const _desc_table = .{
            .line_id = fd(1, .{ .Varint = .Simple }),
            .axis_id = fd(2, .{ .Varint = .Simple }),
        };

        pub usingnamespace protobuf.MessageMixins(@This());
    };

    pub const StopPushCarrier = struct {
        line_id: u32 = 0,
        axis_id: ?u32 = null,

        pub const _desc_table = .{
            .line_id = fd(1, .{ .Varint = .Simple }),
            .axis_id = fd(2, .{ .Varint = .Simple }),
        };

        pub usingnamespace protobuf.MessageMixins(@This());
    };

    pub const ClearErrors = struct {
        line_id: u32 = 0,
        driver_id: ?u32 = null,

        pub const _desc_table = .{
            .line_id = fd(1, .{ .Varint = .Simple }),
            .driver_id = fd(2, .{ .Varint = .Simple }),
        };

        pub usingnamespace protobuf.MessageMixins(@This());
    };

    pub const ClearCarriers = struct {
        line_id: u32 = 0,
        axis_id: ?u32 = null,

        pub const _desc_table = .{
            .line_id = fd(1, .{ .Varint = .Simple }),
            .axis_id = fd(2, .{ .Varint = .Simple }),
        };

        pub usingnamespace protobuf.MessageMixins(@This());
    };

    pub const Calibrate = struct {
        line_id: u32 = 0,

        pub const _desc_table = .{
            .line_id = fd(1, .{ .Varint = .Simple }),
        };

        pub usingnamespace protobuf.MessageMixins(@This());
    };

    pub const SetLineZero = struct {
        line_id: u32 = 0,

        pub const _desc_table = .{
            .line_id = fd(1, .{ .Varint = .Simple }),
        };

        pub usingnamespace protobuf.MessageMixins(@This());
    };

    pub const AutoInitialize = struct {
        lines: ArrayList(Request.AutoInitialize.Line),

        pub const _desc_table = .{
            .lines = fd(1, .{ .List = .{ .SubMessage = {} } }),
        };

        pub const Line = struct {
            line_id: u32 = 0,
            velocity: ?u32 = null,
            acceleration: ?u32 = null,

            pub const _desc_table = .{
                .line_id = fd(1, .{ .Varint = .Simple }),
                .velocity = fd(2, .{ .Varint = .Simple }),
                .acceleration = fd(3, .{ .Varint = .Simple }),
            };

            pub usingnamespace protobuf.MessageMixins(@This());
        };

        pub usingnamespace protobuf.MessageMixins(@This());
    };

    pub const MoveCarrier = struct {
        line_id: u32 = 0,
        carrier_id: u32 = 0,
        velocity: u32 = 0,
        acceleration: u32 = 0,
        control_kind: ControlKind = @enumFromInt(0),
        disable_cas: bool = false,
        target: ?target_union,

        pub const _target_case = enum {
            axis,
            location,
            distance,
        };
        pub const target_union = union(_target_case) {
            axis: u32,
            location: f32,
            distance: f32,
            pub const _union_desc = .{
                .axis = fd(5, .{ .Varint = .Simple }),
                .location = fd(6, .{ .FixedInt = .I32 }),
                .distance = fd(7, .{ .FixedInt = .I32 }),
            };
        };

        pub const _desc_table = .{
            .line_id = fd(1, .{ .Varint = .Simple }),
            .carrier_id = fd(2, .{ .Varint = .Simple }),
            .velocity = fd(3, .{ .Varint = .Simple }),
            .acceleration = fd(4, .{ .Varint = .Simple }),
            .control_kind = fd(8, .{ .Varint = .Simple }),
            .disable_cas = fd(9, .{ .Varint = .Simple }),
            .target = fd(null, .{ .OneOf = target_union }),
        };

        pub usingnamespace protobuf.MessageMixins(@This());
    };

    pub const PushCarrier = struct {
        line_id: u32 = 0,
        carrier_id: u32 = 0,
        direction: Direction = @enumFromInt(0),
        velocity: u32 = 0,
        acceleration: u32 = 0,
        axis_id: ?u32 = null,

        pub const _desc_table = .{
            .line_id = fd(1, .{ .Varint = .Simple }),
            .carrier_id = fd(2, .{ .Varint = .Simple }),
            .direction = fd(3, .{ .Varint = .Simple }),
            .velocity = fd(4, .{ .Varint = .Simple }),
            .acceleration = fd(5, .{ .Varint = .Simple }),
            .axis_id = fd(6, .{ .Varint = .Simple }),
        };

        pub usingnamespace protobuf.MessageMixins(@This());
    };

    pub const PullCarrier = struct {
        line_id: u32 = 0,
        axis_id: u32 = 0,
        carrier_id: u32 = 0,
        direction: Direction = @enumFromInt(0),
        velocity: u32 = 0,
        acceleration: u32 = 0,
        transition: ?Request.PullCarrier.Transition = null,

        pub const _desc_table = .{
            .line_id = fd(1, .{ .Varint = .Simple }),
            .axis_id = fd(2, .{ .Varint = .Simple }),
            .carrier_id = fd(3, .{ .Varint = .Simple }),
            .direction = fd(4, .{ .Varint = .Simple }),
            .velocity = fd(5, .{ .Varint = .Simple }),
            .acceleration = fd(6, .{ .Varint = .Simple }),
            .transition = fd(7, .{ .SubMessage = {} }),
        };

        pub const Transition = struct {
            control_kind: ControlKind = @enumFromInt(0),
            disable_cas: bool = false,
            target: ?target_union,

            pub const _target_case = enum {
                axis,
                location,
                distance,
            };
            pub const target_union = union(_target_case) {
                axis: u32,
                location: f32,
                distance: f32,
                pub const _union_desc = .{
                    .axis = fd(2, .{ .Varint = .Simple }),
                    .location = fd(3, .{ .FixedInt = .I32 }),
                    .distance = fd(4, .{ .FixedInt = .I32 }),
                };
            };

            pub const _desc_table = .{
                .control_kind = fd(1, .{ .Varint = .Simple }),
                .disable_cas = fd(5, .{ .Varint = .Simple }),
                .target = fd(null, .{ .OneOf = target_union }),
            };

            pub usingnamespace protobuf.MessageMixins(@This());
        };

        pub usingnamespace protobuf.MessageMixins(@This());
    };

    pub const IsolateCarrier = struct {
        line_id: u32 = 0,
        axis_id: u32 = 0,
        carrier_id: u32 = 0,
        direction: Direction = @enumFromInt(0),
        link_axis: ?Direction = null,

        pub const _desc_table = .{
            .line_id = fd(1, .{ .Varint = .Simple }),
            .axis_id = fd(2, .{ .Varint = .Simple }),
            .carrier_id = fd(3, .{ .Varint = .Simple }),
            .direction = fd(4, .{ .Varint = .Simple }),
            .link_axis = fd(5, .{ .Varint = .Simple }),
        };

        pub usingnamespace protobuf.MessageMixins(@This());
    };

    pub const ClearCommand = struct {
        command_id: u32 = 0,

        pub const _desc_table = .{
            .command_id = fd(1, .{ .Varint = .Simple }),
        };

        pub usingnamespace protobuf.MessageMixins(@This());
    };

    pub const ClearCommands = struct {
        pub const _desc_table = .{};

        pub usingnamespace protobuf.MessageMixins(@This());
    };

    pub usingnamespace protobuf.MessageMixins(@This());
};

pub const Response = struct {
    body: ?body_union,

    pub const _body_case = enum {
        command_id,
        request_error,
        command_operation,
    };
    pub const body_union = union(_body_case) {
        command_id: u32,
        request_error: Response.RequestErrorKind,
        command_operation: Response.CommandOperationStatus,
        pub const _union_desc = .{
            .command_id = fd(1, .{ .Varint = .Simple }),
            .request_error = fd(2, .{ .Varint = .Simple }),
            .command_operation = fd(3, .{ .Varint = .Simple }),
        };
    };

    pub const _desc_table = .{
        .body = fd(null, .{ .OneOf = body_union }),
    };

    pub const CommandOperationStatus = enum(i32) {
        COMMAND_STATUS_UNSPECIFIED = 0,
        COMMAND_STATUS_COMPLETED = 1,
        _,
    };

    pub const RequestErrorKind = enum(i32) {
        COMMAND_REQUEST_ERROR_UNSPECIFIED = 0,
        COMMAND_REQUEST_ERROR_INVALID_LINE = 1,
        COMMAND_REQUEST_ERROR_INVALID_AXIS = 2,
        COMMAND_REQUEST_ERROR_CARRIER_NOT_FOUND = 3,
        COMMAND_REQUEST_ERROR_CC_LINK_DISCONNECTED = 4,
        COMMAND_REQUEST_ERROR_INVALID_ACCELERATION = 5,
        COMMAND_REQUEST_ERROR_INVALID_VELOCITY = 6,
        COMMAND_REQUEST_ERROR_OUT_OF_MEMORY = 7,
        COMMAND_REQUEST_ERROR_MISSING_PARAMETER = 8,
        COMMAND_REQUEST_ERROR_INVALID_DIRECTION = 9,
        COMMAND_REQUEST_ERROR_INVALID_LOCATION = 10,
        COMMAND_REQUEST_ERROR_INVALID_DISTANCE = 11,
        COMMAND_REQUEST_ERROR_INVALID_CARRIER = 12,
        COMMAND_REQUEST_ERROR_COMMAND_PROGRESSING = 13,
        COMMAND_REQUEST_ERROR_COMMAND_NOT_FOUND = 14,
        COMMAND_REQUEST_ERROR_MAXIMUM_AUTO_INITIALIZE_EXCEEDED = 15,
        COMMAND_REQUEST_ERROR_INVALID_DRIVER = 16,
        _,
    };

    pub usingnamespace protobuf.MessageMixins(@This());
};
