const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        .os_tag = .freestanding,
        .abi = .eabi,
    });

    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });

    const firmware = b.addExecutable(.{
        .name = "microbit",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .single_threaded = true,
        }),
    });

    firmware.entry = .disabled;

    firmware.setLinkerScript(
        b.path("linker.ld"),
    );

    const hex = b.addObjCopy(
        firmware.getEmittedBin(),
        .{
            .format = .hex,
            .basename = "firmware.hex",
        },
    );

    const install_hex = b.addInstallFile(
        hex.getOutput(),
        "firmware.hex",
    );

    b.getInstallStep().dependOn(&install_hex.step);

    const default_mount = "/run/media/dispe/MICROBIT";

    const microbit_mount = b.option(
        []const u8,
        "microbit",
        "Mount point of the MICROBIT volume",
    ) orelse default_mount;

    const flash_cmd = b.addSystemCommand(&.{"cp"});

    flash_cmd.addFileArg(hex.getOutput());
    flash_cmd.addArg(b.pathJoin(&.{ microbit_mount, "firmware.hex" }));

    const flash_step = b.step(
        "flash",
        "Flash firmware to the micro:bit",
    );

    flash_step.dependOn(&flash_cmd.step);
}
