const startup = @import("startup.zig");

comptime {
    startup.exportStartup();
}

const GPIO0_BASE: usize = 0x5000_0000;

const OUTSET: usize = 0x508;
const OUTCLR: usize = 0x50C;
const DIRSET: usize = 0x518;

inline fn reg32(address: usize) *volatile u32 {
    return @ptrFromInt(address);
}

inline fn bit(pin: u5) u32 {
    return @as(u32, 1) << pin;
}

pub fn firmware_main() noreturn {
    const row: u5 = 15;
    const col: u5 = 31;

    reg32(GPIO0_BASE + OUTSET).* = bit(row);
    reg32(GPIO0_BASE + OUTCLR).* = bit(col);

    reg32(GPIO0_BASE + DIRSET).* = bit(row) | bit(col);

    while (true) {
        asm volatile ("wfi");
    }
}
