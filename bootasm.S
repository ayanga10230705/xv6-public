#include "asm.h"
#include "memlayout.h"
#include "mmu.h"

# Start the first CPU: switch to 32-bit protected mode, jump into C.
# The BIOS loads this code from the first sector of the hard disk into
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs=0 %ip=7c00.
# xv6 bootloader 汇编入口（实模式，16位）
# 作用：初始化硬件环境，从实模式切换到32位保护模式，加载并跳转到bootmain.c执行
# 运行环境：BIOS将此代码加载到内存0x7c00处，占据第一个扇区（512字节）

.code16                       # Assemble for 16-bit mode
.globl start                  # 定义全局入口符号，BIOS会跳转到此处执行
start:
  # 关闭中断：禁止CPU响应外部中断，避免启动过程被干扰
  cli                         # BIOS enabled interrupts; disable

  # Zero data segment registers DS, ES, and SS.
  # 初始化数据段寄存器：实模式下将ds/es等寄存器置0，保证寻址正确
  xorw    %ax,%ax             # Set %ax to zero
  movw    %ax,%ds             # -> Data Segment
  movw    %ax,%es             # -> Extra Segment
  movw    %ax,%ss             # -> Stack Segment

  # Physical address line A20 is tied to zero so that the first PCs 
  # with 2 MB would run software that assumed 1 MB.  Undo that.
seta20.1:
  inb     $0x64,%al               # Wait for not busy
  testb   $0x2,%al
  jnz     seta20.1

  movb    $0xd1,%al               # 0xd1 -> port 0x64
  outb    %al,$0x64

seta20.2:
  inb     $0x64,%al               # Wait for not busy
  testb   $0x2,%al
  jnz     seta20.2

  movb    $0xdf,%al               # 0xdf -> port 0x60
  outb    %al,$0x60

  # Switch from real to protected mode.  Use a bootstrap GDT that makes
  # virtual addresses map directly to physical addresses so that the
  # effective memory map doesn't change during the transition.
  # 加载全局描述符表（GDT）：为切换到保护模式做准备，GDT定义了内存段的权限和地址映射
  lgdt    gdtdesc
  movl    %cr0, %eax              # 将CR0控制寄存器的值加载到eax（CR0控制CPU运行模式）
  orl     $CR0_PE, %eax           # 将CR0的第0位置1（PE=1）：开启保护模式
  movl    %eax, %cr0              # 将修改后的值写回CR0，CPU立即进入保护模式（但指令流水线仍为16位）

//PAGEBREAK!
  # Complete the transition to 32-bit protected mode by using a long jmp
  # to reload %cs and %eip.  The segment descriptors are set up with no
  # translation, so that the mapping is still the identity mapping.
  # 远跳转：刷新CPU指令流水线，跳转到保护模式下的代码段（seg=KERNEL_CS），执行bootmain
  ljmp    $(SEG_KCODE<<3), $start32

.code32  # Tell assembler to generate 32-bit code now.
start32:
  # Set up the protected-mode data segment registers
  movw    $(SEG_KDATA<<3), %ax    # Our data segment selector
  movw    %ax, %ds                # -> DS: Data Segment
  movw    %ax, %es                # -> ES: Extra Segment
  movw    %ax, %ss                # -> SS: Stack Segment
  movw    $0, %ax                 # Zero segments not ready for use
  movw    %ax, %fs                # -> FS
  movw    %ax, %gs                # -> GS

  # Set up the stack pointer and call into C.
  movl    $start, %esp
  call    bootmain

  # If bootmain returns (it shouldn't), trigger a Bochs
  # breakpoint if running under Bochs, then loop.
  movw    $0x8a00, %ax            # 0x8a00 -> port 0x8a00  0x8a00是Bochs调试端口指令
  movw    %ax, %dx
  outw    %ax, %dx                # 写入0x8a00到0x8a00端口，触发Bochs断点
  movw    $0x8ae0, %ax            # 0x8ae0 -> port 0x8a00
  outw    %ax, %dx
spin:
  jmp     spin                    # 死循环，CPU停在此处（内核加载失败）

# Bootstrap GDT
.p2align 2                                # force 4 byte alignment
gdt:
  SEG_NULLASM                             # null seg
  SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)   # code seg
  SEG_ASM(STA_W, 0x0, 0xffffffff)         # data seg

gdtdesc:
  .word   (gdtdesc - gdt - 1)             # sizeof(gdt) - 1
  .long   gdt                             # address gdt

