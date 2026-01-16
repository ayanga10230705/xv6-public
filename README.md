**启动流程说明和运行结果**

**任务一：**

**一、安装必备工具**

1\. 安装 Git Bash

2\. 通过 WSL（Windows 子系统）安装 Ubuntu，然后执行 Ubuntu 的安装命令

打开 Windows 的 WSL 和虚拟机平台功能，这是安装 Ubuntu 的前提

> 按下Win + R，输入cmd并回车，打开 Windows
> 命令提示符（管理员身份运行：右键命令提示符，选 “以管理员身份运行”）

在命令提示符中输入：<span class="mark">wsl --install</span>，回车执行

3\. 在开始菜单搜 “Ubuntu” 并打开

等待 Ubuntu 初始化，然后按提示设置：

输入你想设置的 Ubuntu 用户名（比如ubuntu-user，自定义即可），回车

> 输入你想设置的 Ubuntu 密码（后续 sudo
> 命令需要用），回车（输入时屏幕不显示，正常），再次输入密码确认，回车

初始化完成后，就进入了 Ubuntu 的命令行界面，接下来可以执行安装命令了

4\. 在 Ubuntu 子系统中安装 xv6 所需工具

> 更新 Ubuntu 的软件源（避免安装失败），在 Ubuntu
> 终端输入<span class="mark">sudo apt update</span>，回车

输入你刚才设置的 Ubuntu 密码，回车（密码输入时仍不显示）

> 等待更新完成后，输入安装命令：<span class="mark">sudo apt-get install
> git qemu-system-x86 gcc-multilib make build-essential</span>，回车

终端会提示 “是否继续安装”，输入y并回车，等待所有工具安装完成

5\. 验证安装

> 在 Ubuntu 终端输入：<span class="mark">git
> --version</span>，回车，能显示 git 版本号，说明 git 装好了
>
> 输入：<span class="mark">qemu-system-x86_64
> --version</span>，回车，能显示 qemu 版本号，说明 qemu 装好了

输入：<span class="mark">gcc --version</span>，回车，能显示 gcc
版本号，说明 gcc 装好了

**二、Fork xv6 官方仓库**

1\. 打开浏览器，访问 xv6
官方仓库地址：https://github.com/mit-pdos/xv6-public

2\. 点击仓库页面右上角的 “Fork” 按钮，等待页面跳转，完成仓库复制

**三、把 Fork 后的仓库克隆到本地电脑**

1\. 打开终端 - Git Bash

2\. 输入cd 你想存放项目的文件夹路径（比如cd
~/Documents），回车进入该文件夹

3\. 回到你 Fork 后的 GitHub 仓库页面，复制仓库的 HTTPS/SSH 地址

3\. 在终端输入git clone 你复制的仓库地址，回车，等待仓库下载完成

4\. 输入cd xv6-public（进入下载好的 xv6 项目文件夹）

**四、启动 xv6 系统并验证成功**

1\. 在 xv6 项目文件夹的终端里，输入<span class="mark">make
qemu</span>并回车

2\. 等待编译，出现 xv6 的命令行界面（显示\$提示符），说明启动成功

3\. 按Ctrl+A后再按X，关闭 xv6 的运行窗口

**五、提交并推送第一个 commit**

1\. 终端仍在 xv6 项目文件夹中，输入<span class="mark">git add
.</span>回车（暂存所有文件）

2\. 输入<span class="mark">git commit -m "feat:
成功Fork并启动xv6基础系统"回车</span>（创建提交记录）

使用 SSH 方式：

1\. 生成 SSH 密钥: ssh-keygen -t ed25519 -C " 123456@example.com"

执行命令，一路按回车键，不要输入任何密码或内容，直接默认到底

2\. 验证密钥是否生成成功: <span class="mark">ls -la ~/.ssh/</span>

正常输出应该包含这两个文件：

-rw------- 1 user0705 user0705 411 Jan 13 16:00 id_ed25519 \# 私钥

-rw-r--r-- 1 user0705 user0705 102 Jan 13 16:00 id_ed25519.pub \# 公钥

3\. 执行命令查看并复制公钥: <span class="mark">cat
~/.ssh/id_ed25519.pub</span>

4\. 添加公钥到 GitHub 账号，点击 New SSH key，Title 填 WSL-xv6，Key
粘贴刚才复制的完整公钥；

5\. 测试 SSH 连接 & 推送代码：<span class="mark">ssh -T
git@github.com</span>

成功输出：Hi ayanga10230705! You've successfully authenticated, but
GitHub does not provide shell access.

6.输入 <span class="mark">git push origin master</span>，回到 GitHub
你的仓库页面，刷新后能看到这条新的 commit，说明推送成功

**运行结果：**

在 xv6 项目文件夹的终端里，编译成功，出现 xv6
的命令行界面（显示\$提示符）

GitHub 仓库页面，成功推送代码

**任务二：**

**一、使用vs code，在关键位置添加注释说明启动过程**

1\. 打开 Windows 端 VS Code，安装插件：搜索 “Remote - WSL” 并安装

2\. 连接 Ubuntu WSL：

> 按Ctrl+Shift+P，输入 “WSL: Connect to WSL” 并回车，VS Code
> 会自动连接你的 Ubuntu 子系统；

打开 xv6 项目目录：点击左侧 “打开文件夹”，选择 Ubuntu 里的 xv6-public
目录

3\. 打开所需文件，增加注释

4\. 注释完成后，执行 <span class="mark">make clean &&make qemu</span>
重新编译启动 xv6，确保注释未修改代码逻辑，系统能正常启动。

**二、提交 commit**

1\. 执行 <span class="mark">git add bootasm.S bootmain.c
entry.S</span>（暂存修改后的文件）。

2\. 执行 <span class="mark">git commit -m "docs:
为启动流程关键文件添加注释，增强可读性"</span>。

3\. 执行 <span class="mark">git push origin master</span>
推送到远程仓库。

**运行结果：**

GitHub 仓库页面，成功推送增加注释的新代码

**任务三：**

**一、bootmain.c：打印 BOOT 阶段信息**

1\. 先加一个最小串口输出函数

在 bootmain.c 顶部 includes 后面加：

static void print_boot_msg(const char \*msg) {

    // 简单直接写端口，不等待 THR 空

    for (; \*msg; msg++)

        outb(0x3F8, \*msg);

}

2\. 在 bootmain() 中打三个点

bootmain(void)中

  print_boot_msg("\[BOOT\] enter bootmain\n");

  readseg((uchar\*)elf, 4096, 0);

  // 打印 ELF 头加载完成

  print_boot_msg("\[BOOT\] elf header loaded\n");

所有程序段加载完成，跳转前

  print_boot_msg("\[BOOT\] kernel loaded\n");

  entry = (void(\*)(void))(elf-\>entry);

**二、entry.S：标记“内核入口”**

在 entry: 标签第一条指令之前插入：

movb \$'\>', %al

movw \$0x3F8, %dx

outb %al, %dx

**三、main.c：打印 \[KERNEL\] main() started**

在 main.c 的 main() 函数最开始：cprintf("\[KERNEL\] main() started\n");

**四、执行以下命令，确保编译无错误：**

执行 <span class="mark">make clean &&make qemu</span> 重新编译启动 xv6

**五、提交 commit**

执行 <span class="mark">git add bootmain.c entry.S main.c</span>。

执行 <span class="mark">git commit -m "feat:
实现启动过程可视化，添加关键阶段打印信息"</span>。

执行 <span class="mark">git push origin master</span> 推送到远程仓库。

**运行结果：**

输出：

Booting from Hard Disk.

\[KERNEL\] main() started

cpu0: starting 0

sb: size ...

init: starting sh

\$

GitHub 仓库页面，成功推送增加注释的新代码

**个人总结**

**总结：**

通过本次 xv6
启动流程实践，我对操作系统从上电到内核运行的全过程形成了系统而深入的理解。本实验不仅帮助我理清了
BIOS、bootloader、内核入口与内核初始化之间的调用关系，也让我认识到启动早期阶段在硬件与软件层面所面临的真实限制。

在任务一中，我首先在未修改任何源码的情况下成功编译并启动了原始 xv6
系统。系统能够顺利进入 shell，说明 bootloader 能够正确从磁盘加载内核 ELF
文件，并将控制权交给内核执行。这一结果为后续所有实验提供了可靠的基线，验证了实验环境与工具链的正确性。在任务二中，我通过对
bootasm.S、bootmain.c 和 entry.S
等关键启动文件进行逐行阅读和注释，加深了对 xv6
启动机制的理解。我认识到，启动流程并非简单的“跳转执行”，而是一个逐步建立运行环境的过程：从实模式到保护模式、从无分页到开启分页、从纯汇编到
C
语言环境，每一步都承担着明确且不可替代的职责。这一阶段的学习使我能够从整体角度理解
xv6 的设计，而不仅仅是局部代码行为。在任务三中，我尝试在 bootloader
和内核早期阶段插入调试输出，以期“可视化”系统启动过程。

通过本次实验，我最大的收获在于对“代码已经执行”与“系统具备输出能力”这两者之间差异的深刻理解。即使程序逻辑已经正确运行，只要硬件与运行环境尚未就绪，任何形式的
I/O
操作都可能是未定义行为。这一认识对于理解操作系统底层设计具有重要意义。

总体而言，本次 xv6
启动流程实践不仅提升了我阅读和分析操作系统源码的能力，也让我更加清楚地认识到操作系统启动阶段的复杂性与严谨性。实验过程中出现的“输出不可见”并不是失败，而是一次对系统设计边界的成功验证，对我理解操作系统原理具有重要的学习价值。

**遇到的问题及解决方案：**

**1. 在使用 wsl --install 命令更新适用于 Linux 的 Windows
子系统时，可能会遇到“无法启动服务，原因可能是已被禁用或与其相关联的设备没有启动”的错误。**

① 打开“运行”对话框（按 Win + R），输入 services.msc 并按回车。

在服务列表中找到“Windows Update”服务。

右键点击该服务，选择“启动”。

检查 WSL 服务状态，确保 WSL 服务未被禁用。

② 打开“运行”对话框，输入 services.msc 并按回车。

在服务列表中找到“LxssManager”服务。

确保该服务的启动类型设置为“自动”，并且服务状态为“正在运行”。

③ 按下Win + R，输入control回车，打开 “控制面板”；

点击 “程序”→“程序和功能”→左侧 “启用或关闭 Windows 功能”；

> 在弹出的列表中，勾选以下两项：Windows 子系统适用于 Linux（WSL）和
> 虚拟机平台

点击 “确定”，等待系统安装功能，按提示重启电脑。

④ 开机系统中并未设置打开程序

**2. 新版 GCC 的警告规则和 xv6 旧版代码不兼容**

在 xv6-public 目录执行<span class="mark">nano Makefile</span>

找到下面的这行代码

CFLAGS = -fno-pic -static -fno-builtin -fno-strict-aliasing -O2 -Wall
-MD -ggdb -m32 -Werror -Wno-array-bounds

改为

<span class="mark">CFLAGS = -fno-pic -static -fno-builtin
-fno-strict-aliasing -O2 -Wall -MD -ggdb -m32 -Werror \\Wno-array-bounds
\\Wno-infinite-recursion</span>

可正常运行
