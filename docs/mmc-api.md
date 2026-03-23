# MMC-API Guidelines
This page covers how to use MMC-API to operate on LMS connected to PMF's MMC system.

## MMC-API Structure
The MMC API consists of three categories: **core, command, and info**. Each category contains corresponding **requests and responses**. Please refer to the [protocol documentation](protocol-documentation.md) page for the expected response for each request.

### MMC Core
Use MMC core messages to retrieve server information and track configuration. PMF recommends that clients verify compatibility with the server API version before operation. Starting from version 2.0.0, breaking changes may occur between major versions, therefore clients must ensure they are compatible with the server's API version. Mismatched versions may result in invalid requests or undefined behavior. Clients must fetch the **track configuration** prior to operating the PMF MMC system to ensure all messages passed to the server contain valid parameters. Refer to the [MMC core documentation](protocol-documentation.md#mmccoreproto) for a comprehensive list of message types and expected responses.

### MMC Command
Use MMC command messages to operate the PMF MMC system. Clients must use the following rules when sending MMC command messages.

- **Command ID**: Each command returns a command ID in the response. Clients must use this ID to monitor the command's state.
- **Cleanup**: Clients must invoke `remove_command` once the command state becomes `COMPLETED`. **Failure to do so will block the queue and prevent the server from accepting further commands**.
- **Queueing**: Each driver executes only one command at a time. Commands sent to a busy driver will be queued in the order of arrival.

Monitor command status via the command info request defined in the MMC Info section. A list of commands are available on [MMC command documentation](protocol-documentation.md#mmccommandproto).

### MMC Info
Use MMC info messages to monitor the real-time state of the track and command status. The client can specify which track information to request by enabling the relevant flags within the track info message definition. The API also allows filtering track info based on driver range, axis range, or specific carrier IDs. Refer to the [MMC info documentation](protocol-documentation.md#mmcinfoproto) for the complete message definitions used to request track and command states.

## Create Request
This section demonstrates how to construct and encode a request for transmission. The first example illustrates how to decode and validate a response before use. Subsequent examples will omit the response processing logic to focus on request creation and key considerations for specific commands.
!!! info
    Client must exclusively use the [mmc.Request](protocol-documentation.md#request) message type to send requests to the server. The server always returns an [mmc.Response](protocol-documentation.md#response) message to be decoded on client side. Any other message sent to server will return `mmc.Response.request_error`, showing the message is invalid.

### Requesting Core Information
!!! info
    A core request message contains only one enum field. The following example demonstrates how to **request the API version** used by the server. Other core requests are implemented in the same manner.
!!! warning
    Sending a core request with kind `CORE_REQUEST_KIND_SERVER_INFO` will always return `mmc.Response.core.request_error`.

=== "zig"
    !!! tip
        Zig users can directly use the [pmotionf/mmc-api](https://github.com/pmotionf/mmc-api) repository for ease of integration. If you are using a different Zig version, generate the Zig files from the source Protobuf files using [zig-protobuf](https://github.com/Arwalk/zig-protobuf) library.
    
    ```zig
    const api = @import("mmc-api");
    // Create a request and encode the message. Encode with passing the
    // transport writer interface pointer and allocator. Send the message by 
    // flush the writer..
    const request: api.protobuf.mmc.Request = .{
        .body = .{
            .core = .{ .kind = .CORE_REQUEST_KIND_SERVER_INFO },
        },
    };
    try request.encode(&writer.interface, allocator);
    try writer.interface.flush();
    // Receive and decode the message by passing the reader interface pointer 
    // and allocator.
    const decoded: api.protobuf.mmc.Response = try .decode(
        &client.reader.interface,
        client.allocator,
    );
    switch (decoded.body orelse std.log.err("Invalid Response",.{})) {
        .core => |core_resp| switch (core_resp.body orelse
            std.log.err("Invalid Response",.{})) {
            .server => |server| std.log.info(
                  "Server API version: {}.{}.{}",
                  .{server.api.major, server.api.minor, server.api.patch,}
              ),
              .request_error => |req_err| std.log.err("{t}",.{req_err}),
              else => std.log.err("Invalid Response",.{}),
        },
        .request_error => |req_err| std.log.err("{t}",.{req_err}),
        else => std.log.err("Invalid Response",.{}),
    };
    ```

=== "python"

    ```python
    import mmc_pb2 as mmc
  
    # Snipped: Create and connect socket to server
    
    # Create a request message
    request = mmc.Request()
    request.core.kind = mmc.mmc_dot_core__pb2.Request.CORE_REQUEST_KIND_SERVER_INFO
    
    # Snipped: Send and receive the message
    
    # Parse response
    msg = mmc.Response()
    msg.ParseFromString(response)
    
    # Validate and use the response accordingly
    if msg.WhichOneof("body") == "request_error":
        print("Error: ", mmc.Request.Error.Name(msg.request_error))
    elif msg.WhichOneof("body") == "core":
        # Validate if the core response that we receive is `api_version`
        if msg.core.WhichOneof("body") == "request_error":
            print(
                "Error: ",
                mmc.mmc_dot_core__pb2.Request.Error.Name(msg.core.request_error),
            )
        elif msg.core.WhichOneof("body") == "server":
            api = msg.core.server.api
            print(
                f"Server API Version: {api.major}.{api.minor}.{api.patch}"
          )
        else:
            print("Invalid Response")
    else:
        print("Invalid Response")
    
    s.close()
    ```

### Command Request
!!! warning "Mandatory Command Cleanup"
    Every command request returns a unique **Command ID**. The client is required to:

    1. **Track** the command status using this ID.
    2. **Invoke** `remove_command` once the state reaches `COMPLETED` or `FAILED`.

    Failure to remove finished commands will block the server queue and prevent further command execution.

    !!! tip "Check Error Reason"
        If the command status is `FAILED`, users can find a descriptive reason by checking the command's `error` field.
      
#### [Initialize Carrier](protocol-documentation.md#requestinitialize)
!!! info
    A carrier must be initialized before any actions can be performed. The `initialize` command is one of many available **methods** for initializing carriers. This command is sent to the axis specified by the `axis` parameter.

    * **Single Axis Placement:** If the uninitialized carrier is located on top of only one axis, the `link_axis` field must be ignored.
    * **Multi-Axis Placement:** If a carrier is placed on top of two axes, the axis not specified in the `axis` parameter must be given as a `link_axis`, and specified as a direction relative to the provided axis.

!!! warning "Unique Carrier ID Requirement"
    The client must ensure the `carrier_id` is unique across the entire line. If the ID is already in use by another initialized carrier on the same line, the server will return `CONFLICTING_CARRIER_ID`.

!!! example
    The following request initializes an **uninitialized carrier** with **ID 1** on the first line in the **forward direction**. This carrier's position is on top of **axis 1 and axis 2**.
    === "zig"
    
        ``` zig
        const api = @import("mmc-api");
      
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .initialize = .{
                            .line = 1,
                            .axis = 2,
                            .carrier = 1,
                            .direction = .DIRECTION_BACKWARD,
                            .link_axis = .DIRECTION_FORWARD,
                        },
                    },
                },
            },
        };
        // Snipped content: 
        // - Send `initialize` command
        // - Receive command ID as the response of command request
        // - Track command state until state `COMPLETED`
        // - Send `remove_command` command
        // - Receive `removed_id` response as the response of `remove_command` request
        ```
    
    === "python"
    
        ```python
        import mmc_pb2 as mmc
        
        # Creating a request message
        Command = mmc.mmc_dot_command__pb2.Request()
        request = mmc.Request()
        request.command.initialize.line = 1
        request.command.initialize.axis = 2
        request.command.initialize.carrier = 1
        request.command.initialize.direction = Command.Direction.DIRECTION_FORWARD
        request.command.initialize.link_axis = Command.Direction.DIRECTION_BACKWARD
        # Snipped content: 
        # - Send `initialize` command
        # - Receive command ID as the response of command request
        # - Track command state until state `COMPLETED`
        # - Send `remove_command` command
        # - Receive `removed_id` response as the response of `remove_command` request
        ```
  
#### [Auto Initialize Carriers](protocol-documentation.md#requestautoinitialize)
!!! info
    Auto initialize all carriers on the specified lines simultaneously. This process operates on carrier clusters, where a cluster is defined as a group of uninitialized carriers located on adjacent axis.
!!! warning
    Each cluster requires at least one free axis to successfully perform the auto-initialization. Any cluster lacking a free axis will be ignored, and all carriers within that cluster will remain uninitialized upon command completion.
!!! tip
    Ignore the `acceleration` and `velocity` fields to use the default values. The default value are:
    
    - Velocity: 0.6 m/s
    - Acceleration: 6 m/s²
!!! example
    Auto initialize all carriers on line 1 and line 2.
    === "zig"
        ``` zig
        const api = @import("mmc-api");
        
        // Allocate lines
        var lines: std.ArrayList(
            api.protobuf.mmc.command.Request.AutoInitialize.Line,
        ) = .empty;
        defer lines.deinit(allocator);
      
        // Define first line
        try lines.append(allocator, .{
            .line = 1,
            .acceleration = 60,
            .velocity = 6,
        });
      
        // Define second line
        try lines.append(allocator, .{
            .line = 2,
            .acceleration = 60,
            .velocity = 6,
        });
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .auto_initialize = .{
                            .lines = lines,
                        },
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        Command = mmc.mmc_dot_command__pb2.Request()
      
        # Define first line
        line1 = Command.AutoInitialize.Line()
        line1.line = 1
        line1.velocity = 6
        line1.acceleration = 60
      
        # Define second line
        line2 = Command.AutoInitialize.Line()
        line2.line = 2
        line2.velocity = 6
        line2.acceleration = 60
    
        # Create a request
        request = mmc.Request()
        request.command.auto_initialize.lines.append(line1)
        request.command.auto_initialize.lines.append(line2)
        ```
#### [Deinitialize Carriers](protocol-documentation.md#requestdeinitialize)
!!! info
    Deinitialize will release motor control on the specified carriers and remove carrier states from MMC system. Deinitialize all carriers on a line by not specifying a target. If a target is specified, carriers are deinitialized based on that target:
    
    - **Carrier** target deinitializes carrier with the specified ID.
    - **Driver** target deinitializes carriers on the specified driver range.
    - **Axis** target deinitializes carriers on the specified axis range.

!!! example
    Deinitialize carrier 1 on the first line.
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .deinitialize = .{
                            .line = line.id,
                            .target = .{ .carrier = 1 }
                        },
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        # Create a request
        request = mmc.Request()
        request.command.deinitialize.line = 1
        request.command.deinitialize.carrier = 1
        ```
#### [Move Carrier](protocol-documentation.md#requestmove)
!!! tip
    Track the carrier state until it reaches `MOVE_COMPLETED` before sending further commands to the specified carrier to avoid unwanted behavior. The command state `COMPLETED` only indicates that the command was successfully received and is being processed by the MMC system.
!!! warning
    The `target` field must be specified by the user, and only the last `target` value will be serialized to the server. See [Oneof](https://protobuf.dev/programming-guides/proto3/#oneof) for complete a description on `Oneof` protobuf type.
!!! example
    Move initialized carrier 1 to axis 3 on the second line.
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .move = .{
                            .line = 2,
                            .carrier = 1,
                            .velocity = 10,
                            .acceleration = 60,
                            .target = .{.axis = 3},
                            .control = .CONTROL_POSITION,
                            .disable_cas = false,
                        },
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        # Create a request
        request = mmc.Request()
        request.command.move.line = 2
        request.command.move.carrier = 1
        request.command.move.velocity = 10
        request.command.move.acceleration = 60
        request.command.move.axis = 3
        # mmc.Control() message is not generated by protoc compiler because Python does
        # not allow to use definition based on namespace.
        # 1 for CONTROL_POSITION
        # 2 for CONTROL_VELOCITY.
        request.command.move.control = 1
        request.command.move.disable_cas = False
        ```

#### [Push](protocol-documentation.md#requestpush)
!!! info
    Forcefully moves an initialized carrier on the specified axis by one carrier length. Use this movement to cross a line boundary, which deinitializes the carrier from the current line upon completion. 

    If the `carrier` field is provided in the push command, the axis enters a **pushing state**. In this state, the axis remains busy and waits for the specified carrier to arrive; once it arrives, the axis automatically pushes the carrier.
  
    !!! warning
        When pushing the carrier to a different line, the receiving axis on the destination line must be in a **pulling state**.
    !!! tip
        To disable the **pushing state** on an axis, utilize the [stop push](protocol-documentation.md#requeststoppush) command.
      
!!! example
    Push carrier on axis 1 of line 2 backward to line 1. 
    !!! warning
        The destination axis on line 1 must be in **pulling state**.
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .push = .{
                            .line = 2,
                            .axis = 1,
                            .direction = .DIRECTION_BACKWARD,
                            .velocity = 10,
                            .acceleration = line.acceleration,
                        },
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        Command = mmc.mmc_dot_command__pb2.Request()
        # Create a request
        request = mmc.Request()
        request.command.push.line = 2
        request.command.push.axis = 1
        request.command.push.direction = Command.Direction.DIRECTION_BACKWARD
        request.command.push.velocity = 10
        request.command.push.acceleration = 60
    
        ```
    

#### [Pull](protocol-documentation.md#requestpull)
!!! info
    Initialize an incoming carrier located outside the current line. This command puts the specified axis into **pulling state**. This initialization procedure has the following behavior:

    - **Center Alignment**: Omit the `transition` field to initialize the carrier at the center of the pulling axis
    - **Smooth Transition**: Provide a `transition` field to automatically move to the specified destination as soon as the carrier is recognized.
    - **Manual Mode (External Force)**: Omit the `transition`, `velocity`, and `acceleration` fields to initializes the carrier in the NONE state (not controlled by the motor), allowing it to be moved manually or by external systems.

!!! example
    Set axis 6 of line 1 to pulling state, and move the pulled carrier to axis 3.
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .pull = .{
                            .line = 1,
                            .axis = 6,
                            .carrier = 1,
                            .velocity = 10,
                            .acceleration = 10,
                            .direction = .DIRECTION_BACKWARD,
                            .transition = .{
                                .control = .CONTROL_POSITION,
                                .disable_cas = false,
                                .target = .{.axis = 3},
                            },
                        },
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        Command = mmc.mmc_dot_command__pb2.Request()
        # Create a request
        request = mmc.Request()
        request.command.pull.line = 1
        request.command.pull.axis = 6
        request.command.pull.carrier = 1
        request.command.pull.direction = Command.Direction.DIRECTION_BACKWARD
        request.command.pull.velocity = 10
        request.command.pull.acceleration = 60
        request.command.pull.transition.control = 1
        request.command.pull.transition.disable_cas = False
        request.command.pull.transition.axis = 3

    
        ```

#### [Release Carrier](protocol-documentation.md#requestrelease)
!!! info
    Put the initialized carrier into the `NONE` state, allowing it to be moved manually or by external systems.
!!! example
    Release control of carrier 1 on line 1.
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .release = .{
                            .line = 1,
                            .target = .{.carrier = 1},
                        },
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        # Create a request
        request = mmc.Request()
        request.command.release.line = 1
        request.command.release.carrier = 1
        ```

#### [Calibrate Line](protocol-documentation.md#requestcalibrate)
!!! info
    To calibrate the drivers' configuration on a line, an uninitialized carrier must be located at the center of the first axis
!!! example
    Calibrate the drivers' configuration on the first line.
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .calibrate = .{.line = 1},
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        # Create a request
        request = mmc.Request()
        request.command.calibrate.line = 1
        ```

#### [Stop Push](protocol-documentation.md#requeststoppush)
!!! tip
    To reset pushing state on all axis, ignore the `axes` field.
  
!!! example
    Reset the pushing state on axes 1 to 4 of the first line. 
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .stop_push = .{
                            .line = 1,
                            .axes = .{
                                .start = 1,
                                .end = 4,
                            },
                        },
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        # Create a request
        request = mmc.Request()
        request.command.stop_push.line = 1
        request.command.stop_push.axes.start = 1
        request.command.stop_push.axes.end = 4
        ```

#### [Stop Pull](protocol-documentation.md#requeststoppull)
!!! tip
    To reset the pulling state on all axes, omit the `axes` field.
  
!!! example
    Reset the pulling state on axes 1 to 4 of the first line. 
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .stop_pull = .{
                            .line = 1,
                            .axes = .{
                                .start = 1,
                                .end = 4,
                            },
                        },
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        # Create a request
        request = mmc.Request()
        request.command.stop_pull.line = 1
        request.command.stop_pull.axes.start = 1
        request.command.stop_pull.axes.end = 4
        ```

#### [Set Carrier ID](protocol-documentation.md#requestsetcarrierid)
!!! warning
    The carrier ID of each carrier must be unique within a line.
!!! example
    Change the carrier ID of carrier 1 to 4 on the first line.
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .set_carrier_id = .{
                            .line = 1,
                            .carrier = 1,
                            .new_carrier = 4,
                        },
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        # Create a request
        request = mmc.Request()
        request.command.set_carrier_id.line = 1
        request.command.set_carrier_id.carrier = 1
        request.command.set_carrier_id.new_carrier = 4
        ```

#### [Set Zero](protocol-documentation.md#requestsetzero)
!!! example
    Set the zero point of the first line.
    !!! warning
        An initialized carrier must be located on the first axis of the first line.
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .set_zero = .{.line = 1},
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        # Create a request
        request = mmc.Request()
        request.command.set_zero.line = 1
        ```
#### [Clear Errors](protocol-documentation.md#requestclearerrors)
!!! warning
    Always clear errors whenever an error is detected on an axis or driver. Failing to clear errors may result in unwanted behavior.
!!! tip
    Ignore the `axes` field to clear errors on all drivers and axes on the line.
!!! example
    Clear all errors on the first line.
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .clear_errors = .{.line = 1},
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        # Create a request
        request = mmc.Request()
        request.command.clear_errors.line = 1
        ```
#### [Emergency Stop](protocol-documentation.md#requeststop)
!!! tip
    Pass an empty list to stop operations on all lines.
!!! example
    Stop operations on all lines.
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .stop = .{.lines = &.{}},
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        # Create a request
        request = mmc.Request()
        request.command.stop.lines.extend([])
        ```
#### [Pause Execution](protocol-documentation.md#requestpause)
!!! tip
    Pass empty list to pause operations on all lines.
!!! example
    Pause operations on all lines.
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .pause = .{.lines = &.{}},
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        # Create a request
        request = mmc.Request()
        request.command.pause.lines.extend([])
        ```
#### [Resume Execution](protocol-documentation.md#requestresume)
!!! tip
    Pass an empty list to resume operation on all lines.
!!! example
    Resume operations on all lines.
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .@"resume" = .{.lines = &.{}},
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        # Create a request
        request = mmc.Request()
        request.command.resume.lines.extend([])
        ```
#### [Remove Command](protocol-documentation.md#requestremovecommand)
!!! warning
    Failure to remove a command will block the queue and prevent the server from accepting further commands.
!!! tip
    Always check the command status after sending a command message. ([Request Command State](#request-command-state))
!!! example
    Remove the command with ID 1 from the server.
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        // Create a request
        const request: api.protobuf.mmc.Request = .{
            .body = .{
                .command = .{
                    .body = .{
                        .remove_command = .{.command = 1},
                    },
                },
            },
        };
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        # Creating a request message
        request = mmc.Request()
        request.command.remove_command.command = id
        ```


### Info Request
#### [Request Command State](protocol-documentation.md#requestcommand)
!!! example
    Wait till the command state becomes `COMPLETED` or `FAILED`, then remove the command.
    === "zig"
        ``` zig
        const api = @import("mmc-api");
      
        fn waitCommand(id: u32) !void {
            defer removeCommand(id);
            const request: api.protobuf.mmc.Request = .{
                .body = .{
                    .info = .{
                        .body = .{
                            .command = .{ .id = id },
                        },
                    },
                },
            };
            while (true) {
                try request.encode(&writer.interface, allocator);
                try writer.interface.flush();
                var decoded: api.protobuf.mmc.Response = try .decode(
                    &reader.interface,
                    allocator,
                );
                defer decoded.deinit(allocator);
                const command_response = switch (decoded.body orelse
                    return error.InvalidResponse) {
                    .request_error => |req_err| {
                        std.log.err("{t}", .{req_err});
                        return;
                    },
                    .info => |info_resp| switch (info_resp.body orelse
                        return error.InvalidResponse) {
                        .command => |commands_resp| commands_resp.items.items[0],
                        .request_error => |req_err| {
                            std.log.err("{t}", .{req_err});
                            return;
                        },
                        else => return error.InvalidResponse,
                    },
                    else => return error.InvalidResponse,
                };
                switch (command_response.status) {
                    .COMMAND_STATUS_PROGRESSING => {}, // continue the loop
                    .COMMAND_STATUS_COMPLETED => return,
                    .COMMAND_STATUS_FAILED => {
                        std.log.err("{t}", .{command_response.@"error".?});
                        return;
                    },
                    .COMMAND_STATUS_UNSPECIFIED => return error.InvalidResponse,
                }
            }
        }
        ```
    === "python"
        ``` python
        import mmc_pb2 as mmc
        
        def waitCommand(id):
            # Creating a request message
            request = mmc.Request()
            request.info.command.id = id
            while True:
                # Send and receive response
                s.sendall(request.SerializeToString())
                response = s.recv(4096)
        
                # Parsing the response
                msg = mmc.Response()
                msg.ParseFromString(response)
                Command = mmc.mmc_dot_info__pb2.Response.Command()
        
                # Validate and use the response accordingly
                if msg.WhichOneof("body") == "request_error":
                    print("Request Error", mmc.Request.Error.Name(msg.request_error))
                    return
                elif msg.WhichOneof("body") == "info":
                    # Validate if the core response that we receive is `api_version`
                    if msg.info.WhichOneof("body") == "request_error":
                        print(
                            "Request Error",
                            mmc.mmc_dot_info__pb2.Request.Error.Name(msg.info.request_error),
                        )
                        return
                    elif msg.info.WhichOneof("body") == "command":
                        command = msg.info.command.items[0]
                        if command.status == Command.Status.COMMAND_STATUS_COMPLETED:
                            removeCommand(id)
                            return
                        elif command.status == Command.Status.COMMAND_STATUS_FAILED:
                            removeCommand(id)
                            raise Exception(Command.Error.Name(command.error))
                        else:
                            print("Invalid Response")
                            return
                    else:
                        print("Invalid Response")
                        return
                else:
                    print("Invalid Response")
                    return

        ```

#### [Request Track State](protocol-documentation.md#requesttrack)
!!! tip
    Certain commands require the client to monitor carrier status to ensure movement is completed.
    
    * **Move**: Wait until the carrier state is `MOVE_COMPLETED` before sending a new command to that carrier.
    * **Calibrate**: Wait until the carrier state is `CALIBRATE_COMPLETED` to ensure the driver configuration is valid.
    * **Initialize**: Wait until the carrier state is `INITIALIZE_COMPLETED` before performing further operations on the carrier.
    * **Pull**: If the `transition` field is omitted, wait for `PULL_COMPLETED`; otherwise, wait for `MOVE_COMPLETED`.

!!! warning
    Monitor the `error` flags of driver, axis and carriers to prevent damage to the motor or driver board. Pay close attention to `inverter_overheat` on the driver and `overcurrent` flags on the axis; immediately deinitialize any carrier on the affected axes and drivers if these are detected. The `overvoltage` and `undervoltage` flags indicate that the system voltage supply may have a problem; please consult with our engineers to resolve the issue.

!!! example "Request carrier state"
    !!! tip
        * Omit the `filter` field when sending track info message to retrieve all toggled flags information.
        * Set all flags in the track info message to retrieve every message in one request.
    === "zig"
        ```zig
        const api = @import("mmc-api");
        fn carrierState(line: u32, carrier: u32) !void {
            var carrier_id = [1]u32{carrier};
            const request: api.protobuf.mmc.Request = .{
                .body = .{
                    .info = .{
                        .body = .{
                            .track = .{
                                .line = line,
                                .info_carrier_state = true,
                                .filter = .{
                                    .carriers = .{
                                        .ids = .fromOwnedSlice(&carrier_id),
                                    },
                                },
                            },
                        },
                    },
                },
            };
            try request.encode(&writer.interface, allocator);
            try writer.interface.flush();
            var decoded: api.protobuf.mmc.Response = try .decode(
                &reader.interface,
                allocator,
            );
            defer decoded.deinit(allocator);
            switch (decoded.body orelse return error.InvalidResponse) {
                .info => |info_resp| switch (info_resp.body orelse
                    return error.InvalidResponse) {
                    .track => |track_resp| {
                        std.log.info("{}", .{track_resp.carrier_state.items[0]});
                    },
                    .request_error => |req_err| {
                        std.log.err("{t}", .{req_err});
                    },
                    else => return error.InvalidResponse,
                },
                .request_error => |req_err| {
                    std.log.err("{t}", .{req_err});
                    return;
                },
                else => return error.InvalidResponse,
            }
        }
        ```
    === "python"
        ```python
        import mmc_pb2 as mmc
        def carrierState(line, carrier):
            # Creating a request message
            request = mmc.Request()
            request.info.track.line = line
            request.info.track.info_carrier_state = True
            request.info.track.carriers.ids.append(carrier)
        
            # Parsing the response
            msg = mmc.Response()
            msg.ParseFromString(response)
            # Validate and use the response accordingly
            if msg.WhichOneof("body") == "request_error":
                print("Request Error", mmc.Request.Error.Name(msg.request_error))
            elif msg.WhichOneof("body") == "info":
                # Validate if the core response that we receive is `api_version`
                if msg.info.WhichOneof("body") == "request_error":
                    print(
                        "Request Error",
                        mmc.mmc_dot_info__pb2.Request.Error.Name(msg.info.request_error),
                    )
                elif msg.info.WhichOneof("body") == "track":
                    assert len(msg.info.track.carrier_state) != 0
                    carrier = msg.info.track.carrier_state[0]
                    print(carrier)
                else:
                    print("Invalid Response")
            else:
                print("Invalid Response")

        ```
