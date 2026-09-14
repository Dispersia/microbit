const root = @import("root");

const Handler = *const fn () callconv(.c) void;
const ResetHandler = *const fn () callconv(.c) noreturn;

extern var _stack_top: u8;

extern var _sidata: u8;
extern var _sdata: u8;
extern var _edata: u8;

extern var _sbss: u8;
extern var _ebss: u8;

const VectorTable = extern struct {
    initial_stack_pointer: *u8,
    reset: ResetHandler,

    handlers: [62]Handler,
};

const handlers: [62]Handler = blk: {
    var result: [62]Handler = undefined;

    for (&result) |*handler| {
        handler.* = &default_handler;
    }

    break :blk result;
};

const vector_table: VectorTable align(256) = .{
    .initial_stack_pointer = &_stack_top,
    .reset = &_start,
    .handlers = handlers,
};

fn default_handler() callconv(.c) void {
    while (true) {
        asm volatile ("wfi");
    }
}

fn initialize_data() void {
    const src: [*]const u8 = @ptrCast(&_sidata);
    const dst: [*]u8 = @ptrCast(&_sdata);

    const len =
        @intFromPtr(&_edata) -
        @intFromPtr(&_sdata);

    var i: usize = 0;
    while (i < len) : (i += 1) {
        dst[i] = src[i];
    }
}

fn initialize_bss() void {
    const dst: [*]u8 = @ptrCast(&_sbss);

    const len =
        @intFromPtr(&_ebss) -
        @intFromPtr(&_sbss);

    var i: usize = 0;
    while (i < len) : (i += 1) {
        dst[i] = 0;
    }
}

fn _start() callconv(.c) noreturn {
    initialize_data();
    initialize_bss();

    root.firmware_main();
}

pub fn exportStartup() void {
    @export(&vector_table, .{
        .name = "_vector_table",
        .section = ".vectors",
        .linkage = .strong,
    });

    @export(&_start, .{
        .name = "_start",
        .linkage = .strong,
    });
}
