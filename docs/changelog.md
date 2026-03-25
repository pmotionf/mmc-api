# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-03-16

- Added: API documentation
- Added: Carrier validation
- Changed: **BREAKING** Ability to retrieve all track information without specifying a Line ID  
Removed:
```
mmc.info.Request.Track.line
```
Use instead:
```
mmc.info.Request.Track.lines
```

- Changed: **BREAKING:** Track info response structure updated  
Removed:
```
mmc.info.Response.Track.line 
mmc.info.Response.Line.line
```
Use instead:
```
mmc.info.Response.Track.lines
mmc.info.Response.Line.id
```

- Changed: **BREAKING:** `velocity` and `acceleration` behaviour  
Changed unit from `dm/s` to `mm/s` and `dm/s^2` to `mm/s^2`, respectively. Additionally, changed type from `uint32` to `float`:
```
mmc_client.Line.velocity
mmc_client.Line.acceleration
AutoInitialize.Line.velocity
AutoInitialize.Line.acceleration
Move.velocity
Move.acceleration
Push.velocity
Push.acceleration
Pull.velocity
Pull.acceleration
```
Removed velocity mode enum and related fields:  
```
mmc.command.Request.VelocityMode
mmc.command.Request.AutoInitialize.Line.velocity_mode
mmc.command.Request.Move.velocity_mode
mmc.command.Request.Push.velocity_mode
mmc.command.Request.Pull.velocity_mode
```

- Changed: **BREAKING:** Error and state enum definitions updated  
If you were using these error enums, they have been removed:
```
mmc.command.Request.Error.COMMAND_REQUEST_ERROR_CC_LINK_DISCONNECTED
```
Use instead:
```
mmc.info.Response.Command.Error.COMMAND_ERROR_DRIVER_DISCONNECTED
```
If you were using these carrier states, they have been removed:
```
mmc.info.Response.Command.Carrier.State.CARRIER_STATE_PUSH_COMPLETED
mmc.info.Response.Command.Carrier.State.CARRIER_STATE_PULL_COMPLETED
```
The following error enums were added:
```
mmc.command.Request.Error.COMMAND_REQUEST_ERROR_INVALID_COMMAND
mmc.info.Request.Error.INFO_REQUEST_ERROR_COMMAND_NOT_FOUND
mmc.info.Request.Error.INFO_REQUEST_ERROR_INVALID_COMMAND
mmc.info.Request.Error.INFO_REQUEST_ERROR_INVALID_CARRIER
```

- Changed: **BREAKING:** Pull command target behavior  
Removed:
```
mmc.command.Request.Pull.Transition.axis
mmc.command.Request.Pull.Transition.location
mmc.command.Request.Pull.Transition.distance
``` 
Use instead:
```
mmc.command.Request.Pull.Transition.target
```
The behavior of `target` is equivalent to the previous `location` field.  
Additional change: Pass `NaN` to pull without motor-controlled transition.

- Changed: Release pipeline and artifacts updated
- Changed: API version handling merged into server message structure  
Removed:
```
mmc.core.Request.Kind.CORE_REQUEST_KIND_API_VERSION
mmc.core.Response.api_version
```
Use instead:
```
mmc.core.Request.Kind.CORE_REQUEST_KIND_SERVER_INFO
mmc.core.Response.Server.api
```

- Removed: Documentation component `sabledocs`


- Fixed: Documentation build issues

## [1.2.1] - 2026-01-21 
- Changelog starting point

[2.0.0]: https://github.com/pmotionf/mmc-api/releases/tag/protobuf-api-2.0.0
[1.2.1]: https://github.com/pmotionf/mmc-api/releases/tag/protobuf-api-1.2.0
