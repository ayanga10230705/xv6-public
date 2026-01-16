// Boot loader.
//
// Part of the boot block, along with bootasm.S, which calls bootmain().
// bootasm.S has put the processor into protected 32-bit mode.
// bootmain() loads an ELF kernel image from the disk starting at
// sector 1 and then jumps to the kernel entry routine.

// xv6 bootloader核心C函数（保护模式，32位）
// 作用：从磁盘读取ELF格式的内核文件，解析ELF头部，将内核段加载到指定内存地址，最后跳转到内核入口
// 运行环境：由bootasm.S切换到保护模式后调用，栈已初始化，寻址范围0~4GB
// 依赖：bootasm.S的实模式初始化、磁盘读写函数loadseg()

#include "types.h"
#include "elf.h"
#include "x86.h"
#include "memlayout.h"

static void print_boot_msg(const char *msg) {
    // 简单直接写端口，不等待 THR 空
    for (; *msg; msg++)
        outb(0x3F8, *msg);
}

#define SECTSIZE  512       // 磁盘扇区大小（512字节），与bootasm.S中的SECTORS一致

// 函数声明：从磁盘读取指定扇区到内存
void readseg(uchar*, uint, uint);

// bootmain：bootloader的核心函数，完成内核加载的核心逻辑
// 输入：无
// 输出：无（成功则跳转到内核入口，不会返回；失败则静默退出）
// 流程：1. 读取ELF头部 → 2. 验证ELF合法性 → 3. 加载所有程序段 → 4. 跳转到内核入口
void
bootmain(void)
{
  // 1. 定义核心变量
  struct elfhdr *elf;     // ELF文件头部指针（指向内存0x10000）
  struct proghdr *ph, *eph;       // ELF程序段表头指针（ph=当前段，eph=段表末尾）
  void (*entry)(void);            // 内核入口函数指针（存储ELF头部的entry字段）
  uchar* pa;                      // 物理内存地址指针（程序段加载的目标地址）

  // 2. 定位ELF头部：将ELF内核文件的头部加载到内存0x10000处
  // 原因：0x10000（64KB）是xv6约定的内核ELF头部起始地址，避开bootloader占用的0x7c00~0x8000
  elf = (struct elfhdr*)0x10000;  // scratch space

  // Read 1st page off disk
  // 3. 从磁盘读取ELF头部到内存：读取从磁盘扇区2开始的1个扇区（512字节）
  // 磁盘扇区0：bootasm.S（512字节）；扇区1：bootmain.c（512字节）；扇区2及以后：内核ELF文件
  print_boot_msg("[BOOT] enter bootmain\n");
  readseg((uchar*)elf, 4096, 0);
  // 打印 ELF 头加载完成
  print_boot_msg("[BOOT] elf header loaded\n");

  // Is this an ELF executable?
  // 4. 验证ELF文件合法性：检查ELF魔数（固定为0x7F454C46，对应ASCII的"\x7FELF"）
  // 作用：防止加载非ELF格式的文件（如损坏的内核、其他二进制文件），保证内核合法性
  if(elf->magic != ELF_MAGIC)
    return;  // let bootasm.S handle error

  // Load each program segment (ignores ph flags).
  // 5. 遍历ELF程序段表，加载所有程序段到物理内存
  // elf->phoff：ELF头部中程序段表的偏移量（相对于ELF文件开头）
  // (uchar*)elf + elf->phoff：计算程序段表在内存中的起始地址
  ph = (struct proghdr*)((uchar*)elf + elf->phoff);
  eph = ph + elf->phnum;
  for(; ph < eph; ph++){
    // 获取当前段的目标物理地址
    // xv6内核是物理地址链接的，paddr直接对应物理内存地址（无需地址转换）
    pa = (uchar*)ph->paddr;
    readseg(pa, ph->filesz, ph->off);
    if(ph->memsz > ph->filesz)
      stosb(pa + ph->filesz, 0, ph->memsz - ph->filesz);
  }

  // Call the entry point from the ELF header.
  // Does not return!
  // 打印内核加载完成
  print_boot_msg("[BOOT] kernel loaded\n");
  entry = (void(*)(void))(elf->entry);
  entry();
}

void
waitdisk(void)
{
  // Wait for disk ready.
  while((inb(0x1F7) & 0xC0) != 0x40)
    ;
}

// Read a single sector at offset into dst.
void
readsect(void *dst, uint offset)
{
  // Issue command.
  waitdisk();
  outb(0x1F2, 1);   // count = 1
  outb(0x1F3, offset);
  outb(0x1F4, offset >> 8);
  outb(0x1F5, offset >> 16);
  outb(0x1F6, (offset >> 24) | 0xE0);
  outb(0x1F7, 0x20);  // cmd 0x20 - read sectors

  // Read data.
  waitdisk();
  insl(0x1F0, dst, SECTSIZE/4);
}

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked.
void
readseg(uchar* pa, uint count, uint offset)
{
  uchar* epa;

  epa = pa + count;

  // Round down to sector boundary.
  pa -= offset % SECTSIZE;

  // Translate from bytes to sectors; kernel starts at sector 1.
  offset = (offset / SECTSIZE) + 1;

  // If this is too slow, we could read lots of sectors at a time.
  // We'd write more to memory than asked, but it doesn't matter --
  // we load in increasing order.
  for(; pa < epa; pa += SECTSIZE, offset++)
    readsect(pa, offset);
}
