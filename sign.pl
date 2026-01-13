#!/usr/bin/perl
# 修正版 sign.pl：自动补全 bootblock 到 510 字节，再添加 0x55aa
my $buf;
my $n;

open(F, "<bootblock") || die "sign: can't open bootblock";
$n = read(F, $buf, 510);
close(F);

# 自动补 0 到 510 字节（关键修改）
if($n < 510){
  $buf .= "\0" x (510 - $n);
}elsif($n > 510){
  $buf = substr($buf, 0, 510); # 超过则截断
}

open(F, ">bootblock") || die "sign: can't open bootblock for writing";
print F $buf;
# 添加引导扇区结束标志 0x55aa
print F "\x55\xaa";
close(F);

print "sign: bootblock padded to 512 bytes (510 + 0x55aa)\n";
exit 0;
