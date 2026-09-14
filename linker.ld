ENTRY(_start)

MEMORY
{
  FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 512K
  RAM (rwx) : ORIGIN = 0x20000000, LENGTH = 128K 
}

_stack_top = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
  .vectors :
  {
    . = ALIGN(4);
    KEEP(*(.vectors))
  } > FLASH

  .text :
  {
    . = ALIGN(4);
    *(.text*)
    *(.rodata*)

    . = ALIGN(4);
  } > FLASH

  .ARM.extab :
  {
    *(.ARM.extab*)
  } > FLASH

  .ARM.exidx :
  {
    __exidx_start = .;

    *(.ARM.edidx*)

    __exidx_end = .;
  } > FLASH

  .data :
  {
    . = ALIGN(4);
    _sdata = .;

    *(.data*)

    . = ALIGN(4);
    _edata = .;
  } > RAM AT > FLASH

  _sidata = LOADADDR(.data);

  .bss (NOLOAD) :
  {
    . = ALIGN(4);
    _sbss = .;

    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    _ebss = .;
  } > RAM

}
