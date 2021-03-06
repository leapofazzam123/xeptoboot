const console = @import("console.zig");
const allocator = @import("allocator.zig").allocator;
const stage1 = @import("../stage1.zig");
const toUtf16 = @import("root").toUtf16;
const uefi = @import("std").os.uefi;

var file_protocol: *uefi.protocols.FileProtocol = undefined;
var filesystem_protocol: ?*uefi.protocols.SimpleFileSystemProtocol = undefined;

pub fn initialize() void {
    if (stage1.boot_services.locateProtocol(
        &uefi.protocols.SimpleFileSystemProtocol.guid,
        null,
        @ptrCast(*?*anyopaque, &filesystem_protocol),
    ) != .Success) {
        console.puts("[error] couldn't initialize file system\n");
    }

    if (filesystem_protocol.?.openVolume(&file_protocol) != .Success) {
        console.puts("[error] couldn't open the file system volume\n");
    }
}

pub fn readFile(comptime path: []const u8) []u8 {
    const utf16_path = comptime toUtf16(path);

    var file: *uefi.protocols.FileProtocol = undefined;

    if (file_protocol.open(
        &file,
        &utf16_path,
        uefi.protocols.FileProtocol.efi_file_mode_read,
        uefi.protocols.FileProtocol.efi_file_read_only,
    ) != .Success) {
        console.printf("[error] couldn't open file {s}", .{path});
    }

    var position = uefi.protocols.FileProtocol.efi_file_position_end_of_file;
    _ = file.setPosition(position);
    _ = file.getPosition(&position);
    _ = file.setPosition(0);

    var buffer: []u8 = allocator.alloc(u8, position) catch unreachable;
    if (file.read(&position, buffer.ptr) != .Success) {
        console.printf("[error] couldn't read file {s}", .{path});
    }

    return buffer;
}
