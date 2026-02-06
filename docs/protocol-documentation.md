# Protocol Documentation
<a name="top"></a>

## Table of Contents

- [mmc.proto](#mmc-proto)
    - [Request](#mmc-Request)
    - [Response](#mmc-Response)
  
    - [Request.Error](#mmc-Request-Error)
  
- [range.proto](#range-proto)
    - [Range](#-Range)
  
- [mmc/command.proto](#mmc_command-proto)
    - [Request](#mmc-command-Request)
    - [Request.AutoInitialize](#mmc-command-Request-AutoInitialize)
    - [Request.AutoInitialize.Line](#mmc-command-Request-AutoInitialize-Line)
    - [Request.Calibrate](#mmc-command-Request-Calibrate)
    - [Request.ClearErrors](#mmc-command-Request-ClearErrors)
    - [Request.Deinitialize](#mmc-command-Request-Deinitialize)
    - [Request.Initialize](#mmc-command-Request-Initialize)
    - [Request.Move](#mmc-command-Request-Move)
    - [Request.Pause](#mmc-command-Request-Pause)
    - [Request.Pull](#mmc-command-Request-Pull)
    - [Request.Pull.Transition](#mmc-command-Request-Pull-Transition)
    - [Request.Push](#mmc-command-Request-Push)
    - [Request.Release](#mmc-command-Request-Release)
    - [Request.RemoveCommand](#mmc-command-Request-RemoveCommand)
    - [Request.Resume](#mmc-command-Request-Resume)
    - [Request.SetCarrierId](#mmc-command-Request-SetCarrierId)
    - [Request.SetZero](#mmc-command-Request-SetZero)
    - [Request.Stop](#mmc-command-Request-Stop)
    - [Request.StopPull](#mmc-command-Request-StopPull)
    - [Request.StopPush](#mmc-command-Request-StopPush)
    - [Response](#mmc-command-Response)
  
    - [Request.Direction](#mmc-command-Request-Direction)
    - [Request.Error](#mmc-command-Request-Error)
  
- [mmc/control.proto](#mmc_control-proto)
    - [Control](#mmc-Control)
  
- [mmc/core.proto](#mmc_core-proto)
    - [Request](#mmc-core-Request)
    - [Response](#mmc-core-Response)
    - [Response.SemanticVersion](#mmc-core-Response-SemanticVersion)
    - [Response.Server](#mmc-core-Response-Server)
    - [Response.TrackConfig](#mmc-core-Response-TrackConfig)
    - [Response.TrackConfig.Line](#mmc-core-Response-TrackConfig-Line)
  
    - [Request.Error](#mmc-core-Request-Error)
    - [Request.Kind](#mmc-core-Request-Kind)
  
- [mmc/info.proto](#mmc_info-proto)
    - [Request](#mmc-info-Request)
    - [Request.Command](#mmc-info-Request-Command)
    - [Request.Track](#mmc-info-Request-Track)
    - [Request.Track.Ids](#mmc-info-Request-Track-Ids)
    - [Response](#mmc-info-Response)
    - [Response.Command](#mmc-info-Response-Command)
    - [Response.Commands](#mmc-info-Response-Commands)
    - [Response.Line](#mmc-info-Response-Line)
    - [Response.Line.Axis](#mmc-info-Response-Line-Axis)
    - [Response.Line.Axis.Error](#mmc-info-Response-Line-Axis-Error)
    - [Response.Line.Axis.State](#mmc-info-Response-Line-Axis-State)
    - [Response.Line.Carrier](#mmc-info-Response-Line-Carrier)
    - [Response.Line.Carrier.State](#mmc-info-Response-Line-Carrier-State)
    - [Response.Line.Driver](#mmc-info-Response-Line-Driver)
    - [Response.Line.Driver.Error](#mmc-info-Response-Line-Driver-Error)
    - [Response.Line.Driver.State](#mmc-info-Response-Line-Driver-State)
    - [Response.Track](#mmc-info-Response-Track)
  
    - [Request.Error](#mmc-info-Request-Error)
    - [Response.Command.Error](#mmc-info-Response-Command-Error)
    - [Response.Command.Status](#mmc-info-Response-Command-Status)
    - [Response.Line.Carrier.State.State](#mmc-info-Response-Line-Carrier-State-State)
  
- [Scalar Value Types](#scalar-value-types)



<a name="mmc-proto"></a>
<p align="right"><a href="#top">Top</a></p>

## mmc.proto



<a name="mmc-Request"></a>

### Request
Request message. All client-to-server messages should be of this message
type.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| core | [core.Request](#mmc-core-Request) |  | Core request. Used to retrieve information about the server or the configured track. |
| command | [command.Request](#mmc-command-Request) |  | Command request. Used to send and manage commands to the server, which will execute commands on the connected track. |
| info | [info.Request](#mmc-info-Request) |  | Info request. Used to retrieve information about track state or commands processed by the server. |






<a name="mmc-Response"></a>

### Response
Response message. All server-to-client messages will be of this message
type.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| core | [core.Response](#mmc-core-Response) |  | Core response. |
| command | [command.Response](#mmc-command-Response) |  | Command response. |
| info | [info.Response](#mmc-info-Response) |  | Info Response. |
| request_error | [Request.Error](#mmc-Request-Error) |  | Top-level request error. This error field will be returned only if the top-level request could not be handled properly. Otherwise, response kinds may contain more specific error codes. |





 


<a name="mmc-Request-Error"></a>

### Request.Error


| Name | Number | Description |
| ---- | ------ | ----------- |
| MMC_REQUEST_ERROR_UNSPECIFIED | 0 | This error code is unused, and will never be returned. It is reserved as the default error code according to protobuf specification. |
| MMC_REQUEST_ERROR_INVALID_MESSAGE | 1 | The request could not be decoded as a valid protobuf message. |


 

 

 



<a name="range-proto"></a>
<p align="right"><a href="#top">Top</a></p>

## range.proto



<a name="-Range"></a>

### Range



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| start | [uint32](#uint32) |  | Start of range, inclusive. |
| end | [uint32](#uint32) |  | End of range, inclusive. |





 

 

 

 



<a name="mmc_command-proto"></a>
<p align="right"><a href="#top">Top</a></p>

## mmc/command.proto



<a name="mmc-command-Request"></a>

### Request
Command API: List of commands to operate the PMF&#39;s motion system.

When a command is sent to the server, it will be queued for execution.
Command execution status can be polled through the Info API. The status
remains stored in a limited history buffer, and should be cleared with
`remove_command` after completion.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| calibrate | [Request.Calibrate](#mmc-command-Request-Calibrate) |  | Calibrate a line. This command only needs to be run once after hardware setup; calibrated values will remain stored in drivers even after a power cycle. |
| set_zero | [Request.SetZero](#mmc-command-Request-SetZero) |  | Set the zero position of the specified line. This command can be run optionally after calibration, upon which all drivers will store the set zero position of the line. The set zero position will remain unchanged even after a power cycle. |
| initialize | [Request.Initialize](#mmc-command-Request-Initialize) |  | Initialize a carrier. Carriers must be initialized before they can be moved. Initialization is required after every power cycle. |
| auto_initialize | [Request.AutoInitialize](#mmc-command-Request-AutoInitialize) |  | Initialize all carriers of the specified line(s). If no lines are specified, initialize all carriers across all lines in the track. |
| deinitialize | [Request.Deinitialize](#mmc-command-Request-Deinitialize) |  | Deinitialize a carrier. This removes all carrier information, such as recognized position and carrier ID. |
| move | [Request.Move](#mmc-command-Request-Move) |  | Move an initialized carrier to the desired position. |
| pull | [Request.Pull](#mmc-command-Request-Pull) |  | Pull and initialize a new carrier into a line. |
| push | [Request.Push](#mmc-command-Request-Push) |  | Push an initialized carrier to the specified direction. |
| stop_pull | [Request.StopPull](#mmc-command-Request-StopPull) |  | Stop waiting to pull a new carrier at an axis. |
| stop_push | [Request.StopPush](#mmc-command-Request-StopPush) |  | Stop waiting to push an initialized carrier at an axis. |
| release | [Request.Release](#mmc-command-Request-Release) |  | Release the motor control of a carrier. |
| clear_errors | [Request.ClearErrors](#mmc-command-Request-ClearErrors) |  | Clear all errors within the specified driver range. |
| remove_command | [Request.RemoveCommand](#mmc-command-Request-RemoveCommand) |  | Cancel a running command or remove its status history. |
| stop | [Request.Stop](#mmc-command-Request-Stop) |  | Activate emergency stop for all drivers in line(s). Emergency stop will cause all carriers to deccelerate to rest, then reset all carriers&#39; movement commands. |
| pause | [Request.Pause](#mmc-command-Request-Pause) |  | Activate pause for all drivers in line(s). Pause will cause all carriers to deccelerate to rest. On resume, the carriers will continue their previously assigned movement commands. |
| resume | [Request.Resume](#mmc-command-Request-Resume) |  | Deactivate emergency stop and pause for all drivers in line(s). |
| set_carrier_id | [Request.SetCarrierId](#mmc-command-Request-SetCarrierId) |  | Change an existing carrier ID to a new unique carrier ID. |






<a name="mmc-command-Request-AutoInitialize"></a>

### Request.AutoInitialize
Automatically initialize carriers on every specified lines.

Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| lines | [Request.AutoInitialize.Line](#mmc-command-Request-AutoInitialize-Line) | repeated |  |






<a name="mmc-command-Request-AutoInitialize-Line"></a>

### Request.AutoInitialize.Line



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| line | [uint32](#uint32) |  | Line ID. |
| velocity | [float](#float) | optional | Velocity of carrier movement. Floating point with range 0.1 - 6,000 mm/s (default 600 mm/s). |
| acceleration | [float](#float) | optional | Acceleration of carrier movement. Floating point with range 100 - 24,500 mm/s^2 (default 6000 mm/s^2). |






<a name="mmc-command-Request-Calibrate"></a>

### Request.Calibrate
Calibrate a line by positioning an unitiliazed carrier on the first axis
of the line.

Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| line | [uint32](#uint32) |  | Line ID. |






<a name="mmc-command-Request-ClearErrors"></a>

### Request.ClearErrors
Clear all error information on the driver. If a target is specified,
clear error information of drivers which is located on the target. If not,
clear error information on every driver of the specified line ID.

Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| line | [uint32](#uint32) |  | Line ID. |
| drivers | [Range](#Range) |  | Driver ID range. |
| axes | [Range](#Range) |  | Axis ID range. |
| carrier | [uint32](#uint32) |  | Carrier ID. |






<a name="mmc-command-Request-Deinitialize"></a>

### Request.Deinitialize
Clear carrier information located on the axis. If a target is specified,
clear information of carriers which is located on the target. If not,
clear all carrier information of the specified line ID

Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| line | [uint32](#uint32) |  | Line ID. |
| axes | [Range](#Range) |  | Axis ID range. |
| drivers | [Range](#Range) |  | Driver ID range. |
| carrier | [uint32](#uint32) |  | Carrier ID. |






<a name="mmc-command-Request-Initialize"></a>

### Request.Initialize
Initialize a carrier.

Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| line | [uint32](#uint32) |  | Line ID. |
| axis | [uint32](#uint32) |  | Axis ID. |
| carrier | [uint32](#uint32) |  | ID for the new carrier. |
| direction | [Request.Direction](#mmc-command-Request-Direction) |  | Initialization direction for the new carrier. |
| link_axis | [Request.Direction](#mmc-command-Request-Direction) | optional | Linked axis direction from the specified axis. |






<a name="mmc-command-Request-Move"></a>

### Request.Move
Move a carrier to the desired position.

Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| line | [uint32](#uint32) |  | Line ID. |
| carrier | [uint32](#uint32) |  | Carrier ID. |
| velocity | [float](#float) |  | Velocity of carrier movement. Floating point with range 0.1 - 6,000 mm/s. |
| acceleration | [float](#float) |  | Acceleration of carrier movement. Floating point with range 100 - 24,500 mm/s^2. |
| axis | [uint32](#uint32) |  | Move carrier to the center of the axis. |
| location | [float](#float) |  | Move carrier to relative location to the zero-point of the line, which is set by default at the center of the line&#39;s first axis after calibration, but can also be set with the `SetZero` command. |
| distance | [float](#float) |  | Move carrier to relative distance to current carrier position. Negative distance moves the carrier backwards. |
| control | [mmc.Control](#mmc-Control) |  | Control method for moving carrier. |
| disable_cas | [bool](#bool) |  | Disable the carrier&#39;s collision avoidance system (CAS). |






<a name="mmc-command-Request-Pause"></a>

### Request.Pause
Pause any operation in PMF LMS. Any queued commands in the server will be
continued once the resume command is given.

Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| lines | [uint32](#uint32) | repeated | Line ID. If provided, pause operations only on the specified lines. |






<a name="mmc-command-Request-Pull"></a>

### Request.Pull
Pull and initialize a new carrier into a line.

Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| line | [uint32](#uint32) |  | Line ID. |
| axis | [uint32](#uint32) |  | Axis ID. |
| carrier | [uint32](#uint32) |  | ID for the incoming carrier. |
| direction | [Request.Direction](#mmc-command-Request-Direction) |  | The direction from which the incoming carrier is moving. |
| velocity | [float](#float) |  | Velocity of carrier movement. Floating point with range 0.1 - 6,000 mm/s. When the transition location target is set to `NaN`, the velocity must be 0. |
| acceleration | [float](#float) |  | Acceleration of carrier movement. Floating point with range 100 - 24,500 mm/s^2. When the transition location target is set to `NaN`, the acceleration must be 0. |
| transition | [Request.Pull.Transition](#mmc-command-Request-Pull-Transition) | optional | Smoothly transition to carrier movement after pull completion. |






<a name="mmc-command-Request-Pull-Transition"></a>

### Request.Pull.Transition



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| control | [mmc.Control](#mmc-Control) |  | Control method for moving carrier. |
| disable_cas | [bool](#bool) |  | Disabling the carrier&#39;s collision avoidance system (CAS). |
| target | [float](#float) |  | Move carrier to relative location to the zero-point of the line, which is set by default at the center of the line&#39;s first axis after calibration, but can also be set with the `SetZero` command. Pass NaN to pull carrier without motor control, allowing carrier to be pulled with external force. |






<a name="mmc-command-Request-Push"></a>

### Request.Push
Push an initialized carrier to the specified direction.

Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| line | [uint32](#uint32) |  | Line ID. |
| axis | [uint32](#uint32) |  | Axis ID. |
| direction | [Request.Direction](#mmc-command-Request-Direction) |  | Direction of carrier movement. |
| velocity | [float](#float) |  | Velocity of carrier movement. Floating point with range 0.1 - 6,000 mm/s. |
| acceleration | [float](#float) |  | Acceleration of carrier movement. Floating point with range 100 - 24,500 mm/s^2. |
| carrier | [uint32](#uint32) | optional | Carrier ID. If provided, wait for the specified carrier at the axis and push it once the carrier arrives. |






<a name="mmc-command-Request-Release"></a>

### Request.Release
Release the control imposed by the motor to the carrier. If a target is
specified, the motor which is located on the target release the control.
Otherwise, all carriers on the provided line will be released from control.
Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| line | [uint32](#uint32) |  | Line ID. |
| carrier | [uint32](#uint32) |  | Carrier ID. |
| axes | [Range](#Range) |  | Axis ID range. |
| drivers | [Range](#Range) |  | Driver ID range. |






<a name="mmc-command-Request-RemoveCommand"></a>

### Request.RemoveCommand
Remove a command on the server if the command ID is specified. If no
command ID is specified, remove any commands received by the server. If
the commands are still progressing, cancel the command execution.

Expected response: `mmc.Response.body.command.body.removed_id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| command | [uint32](#uint32) | optional | Command ID. |






<a name="mmc-command-Request-Resume"></a>

### Request.Resume
Resume lines that have been stopped or paused. If the line is not paused
or emergency stopped, this command will succeed without any effect.

Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| lines | [uint32](#uint32) | repeated | Line ID. If provided, resume operations only to those specified lines. |






<a name="mmc-command-Request-SetCarrierId"></a>

### Request.SetCarrierId
Change the carrier ID of an existing initialized carrier. If the new
carrier ID already exists on the line, returns INVALID_CARRIER.

Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| line | [uint32](#uint32) |  | Line ID. |
| carrier | [uint32](#uint32) |  | Target existing initialized carrier ID. |
| new_carrier | [uint32](#uint32) |  | New desired carrier ID (unique in line). |






<a name="mmc-command-Request-SetZero"></a>

### Request.SetZero
Set a zero position of a line by positioning an initialized carrier on
the first axis of the line.

Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| line | [uint32](#uint32) |  | Line ID. |






<a name="mmc-command-Request-Stop"></a>

### Request.Stop
Send an emergency stop command to stop any operation in PMF LMS. This
command also removes all queued commands in the server.

Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| lines | [uint32](#uint32) | repeated | Line ID. If provided, stop operations only on the specified lines and remove all commands that targeting those lines. |






<a name="mmc-command-Request-StopPull"></a>

### Request.StopPull
Stop pulling a carrier to the specified axis. If no axis is provided,
then all pending carrier pulls on the line will be stopped.

Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| line | [uint32](#uint32) |  | Line ID. |
| axes | [Range](#Range) | optional | Axis ID range. |






<a name="mmc-command-Request-StopPush"></a>

### Request.StopPush
Stop pushing a carrier from the specified axis. If no axis is provided,
then all pending carrier pushes on the line will be stopped.

Expected response: `mmc.Response.body.command.body.id` (uint32).


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| line | [uint32](#uint32) |  | Line ID. |
| axes | [Range](#Range) | optional | Axis ID range. |






<a name="mmc-command-Response"></a>

### Response
Response description to the command API.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| id | [uint32](#uint32) |  | Assigned ID for newly sent command. |
| removed_id | [uint32](#uint32) |  | ID of cleared existing command. |
| request_error | [Request.Error](#mmc-command-Request-Error) |  | Error during command&#39;s execution. |





 


<a name="mmc-command-Request-Direction"></a>

### Request.Direction


| Name | Number | Description |
| ---- | ------ | ----------- |
| DIRECTION_UNSPECIFIED | 0 |  |
| DIRECTION_BACKWARD | 1 |  |
| DIRECTION_FORWARD | 2 |  |



<a name="mmc-command-Request-Error"></a>

### Request.Error


| Name | Number | Description |
| ---- | ------ | ----------- |
| COMMAND_REQUEST_ERROR_UNSPECIFIED | 0 |  |
| COMMAND_REQUEST_ERROR_INVALID_LINE | 1 | Attempted to use line ID outside of the configured lines. |
| COMMAND_REQUEST_ERROR_INVALID_AXIS | 2 | Attempted to use axis ID outside of the configured axes of the line. |
| COMMAND_REQUEST_ERROR_INVALID_DRIVER | 3 | Attempted to use driver ID outside of the configured drivers of the line. |
| COMMAND_REQUEST_ERROR_INVALID_ACCELERATION | 4 | Attempted to use acceleration value outside of 1-245. |
| COMMAND_REQUEST_ERROR_INVALID_VELOCITY | 5 | Attempted to use velocity value outside of 1-60. |
| COMMAND_REQUEST_ERROR_INVALID_DIRECTION | 6 | Using invalid direction for the command. |
| COMMAND_REQUEST_ERROR_INVALID_LOCATION | 7 | Deprecated. Check `COMMAND_ERROR_INVALID_CARRIER_TARGET` on `Info.Response.Command.Error`. |
| COMMAND_REQUEST_ERROR_INVALID_DISTANCE | 8 | Deprecated. Check `COMMAND_ERROR_INVALID_CARRIER_TARGET` on `Info.Response.Command.Error`. |
| COMMAND_REQUEST_ERROR_INVALID_CARRIER | 9 | Attempted to send a command to carrier outside of 1-2048. |
| COMMAND_REQUEST_ERROR_MISSING_PARAMETER | 10 | A command missing the required parameter. |
| COMMAND_REQUEST_ERROR_COMMAND_NOT_FOUND | 11 | Attempted to remove or cancel a non-existing command. |
| COMMAND_REQUEST_ERROR_CARRIER_NOT_FOUND | 12 | Attempted to send command to uninitialized carrier. |
| COMMAND_REQUEST_ERROR_CC_LINK_DISCONNECTED | 13 | Deprecated. Check `COMMAND_ERROR_DRIVER_DISCONNECTED` on `Info.Response.Command.Error`. |
| COMMAND_REQUEST_ERROR_OUT_OF_MEMORY | 14 | Server unable to receive new command caused by out of memory. Try `Command.Request.remove_command` to free the memory. |
| COMMAND_REQUEST_ERROR_MAXIMUM_AUTO_INITIALIZE_EXCEEDED | 15 | Attempted to run more than 8 auto initialize instance. |
| COMMAND_REQUEST_ERROR_CONFLICTING_CARRIER_ID | 16 | Attempted to assign a new carrier with an ID that is already used by other carrier on the same line |


 

 

 



<a name="mmc_control-proto"></a>
<p align="right"><a href="#top">Top</a></p>

## mmc/control.proto


 


<a name="mmc-Control"></a>

### Control
Carrier motor control kind.

| Name | Number | Description |
| ---- | ------ | ----------- |
| CONTROL_UNSPECIFIED | 0 |  |
| CONTROL_POSITION | 1 | Carrier controlled with position priority. |
| CONTROL_VELOCITY | 2 | Carrier controlled with velocity priority. |


 

 

 



<a name="mmc_core-proto"></a>
<p align="right"><a href="#top">Top</a></p>

## mmc/core.proto



<a name="mmc-core-Request"></a>

### Request



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| kind | [Request.Kind](#mmc-core-Request-Kind) |  |  |






<a name="mmc-core-Response"></a>

### Response
Response description to the core API.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| server | [Response.Server](#mmc-core-Response-Server) |  | Server process information. |
| api_version | [Response.SemanticVersion](#mmc-core-Response-SemanticVersion) |  | Server&#39;s API version. |
| track_config | [Response.TrackConfig](#mmc-core-Response-TrackConfig) |  | Track configuration. |
| request_error | [Request.Error](#mmc-core-Request-Error) |  | Error response if the core request could not be handled. |






<a name="mmc-core-Response-SemanticVersion"></a>

### Response.SemanticVersion



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| major | [uint32](#uint32) |  |  |
| minor | [uint32](#uint32) |  |  |
| patch | [uint32](#uint32) |  |  |






<a name="mmc-core-Response-Server"></a>

### Response.Server
Server version and name.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| name | [string](#string) |  | Server name. |
| version | [Response.SemanticVersion](#mmc-core-Response-SemanticVersion) |  | Server implementation version. |






<a name="mmc-core-Response-TrackConfig"></a>

### Response.TrackConfig



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| lines | [Response.TrackConfig.Line](#mmc-core-Response-TrackConfig-Line) | repeated | All configured lines in track. |






<a name="mmc-core-Response-TrackConfig-Line"></a>

### Response.TrackConfig.Line



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| id | [uint32](#uint32) |  | Line ID. Numeric ID, starting from 1, that is unique to each line in the track. This ID is used to address the line in other requests. |
| name | [string](#string) |  | Configured line name. This name is otherwise unused by the API, and is provided to the client for end-user convenience. |
| axes | [uint32](#uint32) |  | Total number of axes in the line. |
| axis_length | [float](#float) |  | Length of each axis in the line, in meters. |
| carrier_length | [float](#float) |  | Carrier magnet length, in meters. |
| drivers | [uint32](#uint32) |  | Total number of drivers in the line. |





 


<a name="mmc-core-Request-Error"></a>

### Request.Error


| Name | Number | Description |
| ---- | ------ | ----------- |
| CORE_REQUEST_ERROR_UNSPECIFIED | 0 | This error code is unused, and will never be returned. It is reserved as the default error code according to protobuf specification. |
| CORE_REQUEST_ERROR_REQUEST_UNKNOWN | 1 | The core request kind was unspecified. |



<a name="mmc-core-Request-Kind"></a>

### Request.Kind


| Name | Number | Description |
| ---- | ------ | ----------- |
| CORE_REQUEST_KIND_UNSPECIFIED | 0 | This request kind is unused, and should never be sent. It is reserved as the default request kind according to protobuf specification. |
| CORE_REQUEST_KIND_API_VERSION | 1 | Request server&#39;s API version. Use to check if API version matches client API compatibility. |
| CORE_REQUEST_KIND_SERVER_INFO | 2 | Request server process information. This includes the configured server name and server implementation version. |
| CORE_REQUEST_KIND_TRACK_CONFIG | 3 | Request the configured track information of the server. |


 

 

 



<a name="mmc_info-proto"></a>
<p align="right"><a href="#top">Top</a></p>

## mmc/info.proto



<a name="mmc-info-Request"></a>

### Request



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| command | [Request.Command](#mmc-info-Request-Command) |  | Command information request. Get current status of command; necessary to determine if command is currently running, completed, or failed. |
| track | [Request.Track](#mmc-info-Request-Track) |  | Track information request. Get current track state information. |






<a name="mmc-info-Request-Command"></a>

### Request.Command
Request for status of specified command ID from the server. If no command
ID is provided, then request for status of all commands from the server.

Expected response: `mmc.Response.body.info.body.commands`


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| id | [uint32](#uint32) | optional |  |






<a name="mmc-info-Request-Track"></a>

### Request.Track
Request track state information from server. One or more of the `info_`
flags must be enabled to select the kind of track information desired.
A filter may be optionally provided to limit the source of information
from the track.

Expected response: `mmc.Response.body.info.body.track`


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| lines | [uint32](#uint32) | repeated | Line ID(s). Select line(s) from which information will be retrieved. |
| info_driver_state | [bool](#bool) |  | Retrieve driver state information. |
| info_driver_errors | [bool](#bool) |  | Retrieve driver error information. |
| info_axis_state | [bool](#bool) |  | Retrieve axis state information. |
| info_axis_errors | [bool](#bool) |  | Retrieve axis errors information. |
| info_carrier_state | [bool](#bool) |  | Retrieve carrier state information. |
| drivers | [Range](#Range) |  | Retrieve information from driver ID range. Driver information flags will include drivers within this range. Axis information flags will include every axis belonging to the drivers in this range. Carrier information flags will include every carrier currently controlled by one of the drivers in this range. |
| axes | [Range](#Range) |  | Retrieve information from axis ID range. Driver information flags will include drivers that contain one of the axes within this range. Axis information flags will include axes within this range. Carrier information flags will include every carrier currently controlled by one of the axes in this range. |
| carriers | [Request.Track.Ids](#mmc-info-Request-Track-Ids) |  | Retrieve information from carrier IDs. Driver information flags will include drivers that control one of the carriers within this list. Axis information flags will include axes that control one of the carriers within this list. Carrier information flags will include carriers within this list. |






<a name="mmc-info-Request-Track-Ids"></a>

### Request.Track.Ids
List of IDs. At least one ID must be provided.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| ids | [uint32](#uint32) | repeated |  |






<a name="mmc-info-Response"></a>

### Response



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| command | [Response.Commands](#mmc-info-Response-Commands) |  | Information for requested command(s). If empty, no matching command(s) was found. |
| track | [Response.Track](#mmc-info-Response-Track) |  | Information for requested track state. |
| request_error | [Request.Error](#mmc-info-Request-Error) |  | Info request error. This error field will be returned if the provided info request could not be handled properly. |






<a name="mmc-info-Response-Command"></a>

### Response.Command



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| id | [uint32](#uint32) |  | Command ID. Valid IDs begin from 1, and may be reused after command status is cleared from server history. |
| status | [Response.Command.Status](#mmc-info-Response-Command-Status) |  | Command status. |
| error | [Response.Command.Error](#mmc-info-Response-Command-Error) | optional | Command error response, only if the status is `COMMAND_STATUS_FAILED`. |






<a name="mmc-info-Response-Commands"></a>

### Response.Commands



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| items | [Response.Command](#mmc-info-Response-Command) | repeated |  |






<a name="mmc-info-Response-Line"></a>

### Response.Line



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| id | [uint32](#uint32) |  | Line ID. |
| driver_state | [Response.Line.Driver.State](#mmc-info-Response-Line-Driver-State) | repeated | Driver state information list. Empty if request flag was disabled. |
| driver_errors | [Response.Line.Driver.Error](#mmc-info-Response-Line-Driver-Error) | repeated | Driver error information list. Empty if request flag was disabled. |
| axis_state | [Response.Line.Axis.State](#mmc-info-Response-Line-Axis-State) | repeated | Axis state information list. Empty if request flag was disabled. |
| axis_errors | [Response.Line.Axis.Error](#mmc-info-Response-Line-Axis-Error) | repeated | Axis error information list. Empty if request flag was disabled. |
| carrier_state | [Response.Line.Carrier.State](#mmc-info-Response-Line-Carrier-State) | repeated | Carrier state information list. Empty if request flag was disabled. |






<a name="mmc-info-Response-Line-Axis"></a>

### Response.Line.Axis







<a name="mmc-info-Response-Line-Axis-Error"></a>

### Response.Line.Axis.Error



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| id | [uint32](#uint32) |  | Axis ID. |
| overcurrent | [bool](#bool) |  | Motor overcurrent detected. Motor control released to prevent damage. |






<a name="mmc-info-Response-Line-Axis-State"></a>

### Response.Line.Axis.State



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| id | [uint32](#uint32) |  | Axis ID. |
| motor_active | [bool](#bool) |  | Axis is currently controlling a carrier. |
| waiting_pull | [bool](#bool) |  | Axis is waiting to pull carrier. |
| waiting_push | [bool](#bool) |  | Axis is waiting to push carrier. |
| carrier | [uint32](#uint32) |  | Carrier ID; non-zero if an initialized carrier is on the axis. |
| hall_alarm_back | [bool](#bool) |  | Axis back hall alarm is active. Magnet is detected above back hall sensor. |
| hall_alarm_front | [bool](#bool) |  | Axis front hall alarm is active. Magnet is detected above front hall sensor. |






<a name="mmc-info-Response-Line-Carrier"></a>

### Response.Line.Carrier







<a name="mmc-info-Response-Line-Carrier-State"></a>

### Response.Line.Carrier.State



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| id | [uint32](#uint32) |  | Carrier ID. Will always be non-zero. |
| position | [float](#float) |  | Position of the carrier in line, in meters. |
| axis_main | [uint32](#uint32) |  | Carrier&#39;s primary axis ID. |
| axis_auxiliary | [uint32](#uint32) | optional | Carrier&#39;s auxiliary axis ID, if carrier is on top of two axes. |
| cas_disabled | [bool](#bool) |  | Collision avoidance system (CAS) disabled. |
| cas_triggered | [bool](#bool) |  | Collision avoidance system (CAS) triggered. Carrier will automatically resume movement when path is clear. |
| state | [Response.Line.Carrier.State.State](#mmc-info-Response-Line-Carrier-State-State) |  | Carrier state. |






<a name="mmc-info-Response-Line-Driver"></a>

### Response.Line.Driver







<a name="mmc-info-Response-Line-Driver-Error"></a>

### Response.Line.Driver.Error



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| id | [uint32](#uint32) |  | Driver ID. |
| control_loop_time_exceeded | [bool](#bool) |  | Control loop exceeded maximum loop time. |
| inverter_overheat | [bool](#bool) |  | Inverter is overheated. |
| undervoltage | [bool](#bool) |  | Driver voltage supply too low. |
| overvoltage | [bool](#bool) |  | Driver voltage supply too high. |
| comm_error_prev | [bool](#bool) |  | Communication error with previous driver in line. |
| comm_error_next | [bool](#bool) |  | Communication error with next driver in line. |






<a name="mmc-info-Response-Line-Driver-State"></a>

### Response.Line.Driver.State



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| id | [uint32](#uint32) |  | Driver ID. |
| connected | [bool](#bool) |  | Connection status between driver and server. |
| busy | [bool](#bool) |  | Driver is currently executing a command. |
| motor_disabled | [bool](#bool) |  | Driver motor release activated. All driver motors are inactive. |
| stopped | [bool](#bool) |  | Driver emergency stop activated. |
| paused | [bool](#bool) |  | Driver pause activated. |






<a name="mmc-info-Response-Track"></a>

### Response.Track



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| lines | [Response.Line](#mmc-info-Response-Line) | repeated |  |





 


<a name="mmc-info-Request-Error"></a>

### Request.Error


| Name | Number | Description |
| ---- | ------ | ----------- |
| INFO_REQUEST_ERROR_UNSPECIFIED | 0 | This error code is unused, and will never be returned. It is reserved as the default error code according to protobuf specification. |
| INFO_REQUEST_ERROR_INVALID_LINE | 1 | Invalid line ID provided. Ensure that line ID exists in track configuration. |
| INFO_REQUEST_ERROR_INVALID_AXIS | 2 | Invalid axis ID provided. Ensure that axis ID exists in line. |
| INFO_REQUEST_ERROR_INVALID_DRIVER | 3 | Invalid driver ID provided. Ensure that driver ID exists in line. |
| INFO_REQUEST_ERROR_MISSING_PARAMETER | 4 | Request is missing a required parameter. Ensure that at least one of the information flag is selected when requesting track information. |



<a name="mmc-info-Response-Command-Error"></a>

### Response.Command.Error


| Name | Number | Description |
| ---- | ------ | ----------- |
| COMMAND_ERROR_UNSPECIFIED | 0 | This error code is unused, and will never be returned. It is reserved as the default error code according to protobuf specification. |
| COMMAND_ERROR_INVALID_SYSTEM_STATE | 1 | System state prevented successful command execution. Ensure that all preconditions are met with track info request before sending command. |
| COMMAND_ERROR_INVALID_CARRIER_ID | 2 | Deprecated. Check `COMMAND_REQUEST_ERROR_INVALID_CARRIER` on `Command.Request.Error`. |
| COMMAND_ERROR_DRIVER_DISCONNECTED | 3 | Driver connection failed while command progressing. |
| COMMAND_ERROR_UNEXPECTED | 4 | Unexpected command execution error. This is likely an implementation bug; please contact PMF support for assistance. |
| COMMAND_ERROR_CARRIER_NOT_FOUND | 5 | Target carrier is removed while command progressing. |
| COMMAND_ERROR_CARRIER_ALREADY_INITIALIZED | 6 | Attempted to initialize an initialized carrier. |
| COMMAND_ERROR_DRIVER_STOPPED | 7 | Target driver is stopped while command progressing. Consider resume the driver before sending further command. |
| COMMAND_ERROR_INVALID_CARRIER_TARGET | 8 | Carrier targetting a location outside of the configured track. |
| COMMAND_ERROR_CONFLICTING_CARRIER_ID | 9 | Attempted to assign a new carrier with an ID that is already used by other carrier on the same line |



<a name="mmc-info-Response-Command-Status"></a>

### Response.Command.Status


| Name | Number | Description |
| ---- | ------ | ----------- |
| COMMAND_STATUS_UNSPECIFIED | 0 | This command status is unused, and will never be returned. It is reserved as the default status code according to protobuf specification. |
| COMMAND_STATUS_PROGRESSING | 1 | Command currently executing. |
| COMMAND_STATUS_COMPLETED | 2 | Command completed. |
| COMMAND_STATUS_FAILED | 3 | Command execution failed. |



<a name="mmc-info-Response-Line-Carrier-State-State"></a>

### Response.Line.Carrier.State.State


| Name | Number | Description |
| ---- | ------ | ----------- |
| CARRIER_STATE_NONE | 0 |  |
| CARRIER_STATE_CALIBRATING | 1 | Carrier is currently operating for line calibration. |
| CARRIER_STATE_CALIBRATE_COMPLETED | 2 | Carrier has completed line calibration, and may now be used for normal operation. |
| CARRIER_STATE_MOVING | 3 | Carrier is currently moving towards target destination. |
| CARRIER_STATE_MOVE_COMPLETED | 4 | Carrier has arrived within threshold at target destination. |
| CARRIER_STATE_INITIALIZING | 5 | Carrier is initializing. Must not be used until initialization is completed. |
| CARRIER_STATE_INITIALIZE_COMPLETED | 6 | Carrier initialization completed. May now be used for normal operation. |
| CARRIER_STATE_PUSHING | 7 | Carrier is being pushed by axis. Used to eject carrier from line. |
| CARRIER_STATE_PUSH_COMPLETED | 8 | Carrier push completed by axis. This state is not observed when carrier is ejected from line. |
| CARRIER_STATE_PULLING | 9 | Carrier is being pulled by axis. Must not be used until pull is completed. |
| CARRIER_STATE_PULL_COMPLETED | 10 | Carrier pull completed by axis. May now be used for normal operation. |
| CARRIER_STATE_OVERCURRENT | 11 | Overcurrent detected in carrier axis motor. Carrier movement has been canceled. |


 

 

 



## Scalar Value Types

| .proto Type | Notes | C++ | Java | Python | Go | C# | PHP | Ruby |
| ----------- | ----- | --- | ---- | ------ | -- | -- | --- | ---- |
| <a name="double" /> double |  | double | double | float | float64 | double | float | Float |
| <a name="float" /> float |  | float | float | float | float32 | float | float | Float |
| <a name="int32" /> int32 | Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint32 instead. | int32 | int | int | int32 | int | integer | Bignum or Fixnum (as required) |
| <a name="int64" /> int64 | Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint64 instead. | int64 | long | int/long | int64 | long | integer/string | Bignum |
| <a name="uint32" /> uint32 | Uses variable-length encoding. | uint32 | int | int/long | uint32 | uint | integer | Bignum or Fixnum (as required) |
| <a name="uint64" /> uint64 | Uses variable-length encoding. | uint64 | long | int/long | uint64 | ulong | integer/string | Bignum or Fixnum (as required) |
| <a name="sint32" /> sint32 | Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int32s. | int32 | int | int | int32 | int | integer | Bignum or Fixnum (as required) |
| <a name="sint64" /> sint64 | Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int64s. | int64 | long | int/long | int64 | long | integer/string | Bignum |
| <a name="fixed32" /> fixed32 | Always four bytes. More efficient than uint32 if values are often greater than 2^28. | uint32 | int | int | uint32 | uint | integer | Bignum or Fixnum (as required) |
| <a name="fixed64" /> fixed64 | Always eight bytes. More efficient than uint64 if values are often greater than 2^56. | uint64 | long | int/long | uint64 | ulong | integer/string | Bignum |
| <a name="sfixed32" /> sfixed32 | Always four bytes. | int32 | int | int | int32 | int | integer | Bignum or Fixnum (as required) |
| <a name="sfixed64" /> sfixed64 | Always eight bytes. | int64 | long | int/long | int64 | long | integer/string | Bignum |
| <a name="bool" /> bool |  | bool | boolean | boolean | bool | bool | boolean | TrueClass/FalseClass |
| <a name="string" /> string | A string must always contain UTF-8 encoded or 7-bit ASCII text. | string | String | str/unicode | string | string | string | String (UTF-8) |
| <a name="bytes" /> bytes | May contain any arbitrary sequence of bytes. | string | ByteString | str | []byte | ByteString | string | String (ASCII-8BIT) |

