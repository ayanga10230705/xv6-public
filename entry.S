# The xv6 kernel starts executing in this file. This file is linked with
# the kernel C code, so it can refer to kernel symbols such as main().
# The boot block (bootasm.S and bootmain.c) jumps to entry below.

# xv6内核汇编入口（保护模式，32位）
# 作用：完成内核启动的最后一步汇编初始化，设置内核栈，跳转到C语言的main函数执行
# 运行环境：由bootmain.c的entry()函数跳转至此，CPU处于32位保护模式，特权级0（内核态）
# 内存布局：内核ELF已加载到0x80100000，此代码位于内核入口地址处

# Multiboot header, for multiboot boot loaders like GNU Grub.
# http://www.gnu.org/software/grub/manual/multiboot/multiboot.html
#
# Using GRUB 2, you can boot xv6 from a file stored in a
# Linux file system by copying kernel or kernelmemfs to /boot
# and then adding this menu entry:
#
# menuentry "xv6" {
# 	insmod ext2
# 	set root='(hd0,msdos1)'
# 	set kernel='/boot/kernel'
# 	echo "Loading ${kernel}..."
# 	multiboot ${kernel} ${kernel}
# 	boot
# }

#include "asm.h"
#include "memlayout.h"
#include "mmu.h"
#include "param.h"

# Multiboot header.  Data to direct multiboot loader.
# Multiboot头部：兼容GRUB等多引导加载器的规范，加载器会识别此头部并正确加载内核
.p2align 2                        # 强制4字节对齐（Multiboot规范要求）
.text
.globl multiboot_header           # 导出Multiboot头部符号，供加载器识别    
multiboot_header:
  #define magic 0x1badb002
  #define flags 0
  .long magic
  .long flags
  .long (-magic-flags)

# By convention, the _start symbol specifies the ELF entry point.
# Since we haven't set up virtual memory yet, our entry point is
# the physical address of 'entry'.
# 按ELF规范，_start是程序入口点；此时未开启虚拟内存，需用entry的物理地址（V2P_WO转换）
.globl _start
_start = V2P_WO(entry)

# Entering xv6 on boot processor, with paging off.
# 启动处理器（BSP）进入xv6内核时，分页机制尚未开启（仍为物理地址寻址）
.globl entry
# entry：xv6内核的入口点（boot阶段结束后跳转至此）
# 核心逻辑：开启4MB大页分页机制 → 初始化页目录 → 开启分页 → 初始化栈 → 跳转到main()
entry:
  # Turn on page size extension for 4Mbyte pages
  # 开启4MB大页扩展：x86架构默认支持4KB小页，开启CR4.PSE位后支持4MB大页（减少页表层级）
  movl    %cr4, %eax
  orl     $(CR4_PSE), %eax
  movl    %eax, %cr4
  # Set page directory
  # 设置页目录基址：CR3寄存器存储页目录表（PGDIR）的物理地址，是分页机制的核心寄存器
  movl    $(V2P_WO(entrypgdir)), %eax
  movl    %eax, %cr3
  # Turn on paging.
  # 开启分页机制：CR0.PG位开启分页，CR0.WP位开启写保护（内核只读，用户可写）
  movl    %cr0, %eax
  orl     $(CR0_PG|CR0_WP), %eax
  movl    %eax, %cr0

  # Set up the stack pointer.
  # 初始化内核栈指针：栈从stack+KSTACKSIZE（栈顶）向下生长，KSTACKSIZE是内核栈大小（默认8KB）
  movl $(stack + KSTACKSIZE), %esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  # 初始化内核栈指针：栈从stack+KSTACKSIZE（栈顶）向下生长，KSTACKSIZE是内核栈大小（默认8KB）
  mov $main, %eax
  jmp *%eax

.comm stack, KSTACKSIZE
