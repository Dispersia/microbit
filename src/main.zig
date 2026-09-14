const startup = @import("startup.zig");

comptime {
    startup.exportStartup();
}

const GPIO0_BASE: usize = 0x5000_0000;
const GPIO1_BASE: usize = 0x5000_0300;

fn gpioBase(port: u1) usize {
    return switch (port) {
        0 => GPIO0_BASE,
        1 => GPIO1_BASE,
    };
}

const OUTSET: usize = 0x508;
const OUTCLR: usize = 0x50C;
const DIRSET: usize = 0x518;

const Pin = struct {
    port: u1,
    pin: u5,
};

const rows = [_]Pin{
    .{ .port = 0, .pin = 21 },
    .{ .port = 0, .pin = 22 },
    .{ .port = 0, .pin = 15 },
    .{ .port = 0, .pin = 24 },
    .{ .port = 0, .pin = 19 },
};

const columns = [_]Pin{
    .{ .port = 0, .pin = 28 },
    .{ .port = 0, .pin = 11 },
    .{ .port = 0, .pin = 31 },
    .{ .port = 1, .pin = 5 },
    .{ .port = 0, .pin = 30 },
};

inline fn reg32(address: usize) *volatile u32 {
    return @ptrFromInt(address);
}

inline fn bit(pin: u5) u32 {
    return @as(u32, 1) << pin;
}

fn setHigh(p: Pin) void {
    reg32(gpioBase(p.port) + OUTSET).* = bit(p.pin);
}

fn setLow(p: Pin) void {
    reg32(gpioBase(p.port) + OUTCLR).* = bit(p.pin);
}

fn makeOutput(p: Pin) void {
    reg32(gpioBase(p.port) + DIRSET).* = bit(p.pin);
}

fn delay(cycles: u32) void {
    var i: u32 = 0;
    while (i < cycles) : (i += 1) asm volatile ("nop");
}

const heart = [5]u5{
    0b01010,
    0b10101,
    0b10001,
    0b01010,
    0b00100,
};

pub fn firmware_main() noreturn {
    for (rows) |r| {
        makeOutput(r);
        setLow(r);
    }
    for (columns) |c| {
        makeOutput(c);
        setHigh(c);
    }

    while (true) {
        for (heart, 0..) |bits, r| {
            for (columns, 0..) |col, c| {
                const shift: u3 = @intCast(4 - c);
                if ((bits >> shift) & 1 == 1) setLow(col) else setHigh(col);
            }
            setHigh(rows[r]);
            delay(2_000);
            setLow(rows[r]);
        }
    }
}
