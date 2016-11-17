
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 b3 12 00 00       	call   8012e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 00 31 80 00       	push   $0x803100
  8000b7:	e8 59 13 00 00       	call   801415 <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 17 31 80 00       	push   $0x803117
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 27 31 80 00       	push   $0x803127
  8000e0:	e8 57 12 00 00       	call   80133c <_panic>
	diskno = d;
  8000e5:	a3 00 40 80 00       	mov    %eax,0x804000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 30 31 80 00       	push   $0x803130
  80010b:	68 3d 31 80 00       	push   $0x80313d
  800110:	6a 44                	push   $0x44
  800112:	68 27 31 80 00       	push   $0x803127
  800117:	e8 20 12 00 00       	call   80133c <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 40 80 00 	movzbl 0x804000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 30 31 80 00       	push   $0x803130
  8001cf:	68 3d 31 80 00       	push   $0x80313d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 27 31 80 00       	push   $0x803127
  8001db:	e8 5c 11 00 00       	call   80133c <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 40 80 00 	movzbl 0x804000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	53                   	push   %ebx
  800278:	83 ec 04             	sub    $0x4,%esp
  80027b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	void *addr = (void *) utf->utf_fault_va;
  80027e:	8b 01                	mov    (%ecx),%eax
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800280:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
  800286:	89 d3                	mov    %edx,%ebx
  800288:	c1 eb 0c             	shr    $0xc,%ebx
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80028b:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  800291:	76 1b                	jbe    8002ae <bc_pgfault+0x3a>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	ff 71 04             	pushl  0x4(%ecx)
  800299:	50                   	push   %eax
  80029a:	ff 71 28             	pushl  0x28(%ecx)
  80029d:	68 54 31 80 00       	push   $0x803154
  8002a2:	6a 27                	push   $0x27
  8002a4:	68 ea 31 80 00       	push   $0x8031ea
  8002a9:	e8 8e 10 00 00       	call   80133c <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ae:	8b 15 08 90 80 00    	mov    0x809008,%edx
  8002b4:	85 d2                	test   %edx,%edx
  8002b6:	74 17                	je     8002cf <bc_pgfault+0x5b>
  8002b8:	3b 5a 04             	cmp    0x4(%edx),%ebx
  8002bb:	72 12                	jb     8002cf <bc_pgfault+0x5b>
		panic("reading non-existent block %08x\n", blockno);
  8002bd:	53                   	push   %ebx
  8002be:	68 84 31 80 00       	push   $0x803184
  8002c3:	6a 2b                	push   $0x2b
  8002c5:	68 ea 31 80 00       	push   $0x8031ea
  8002ca:	e8 6d 10 00 00       	call   80133c <_panic>
	//
	// LAB 5: you code here:

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  8002cf:	89 c2                	mov    %eax,%edx
  8002d1:	c1 ea 0c             	shr    $0xc,%edx
  8002d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8002e4:	52                   	push   %edx
  8002e5:	50                   	push   %eax
  8002e6:	6a 00                	push   $0x0
  8002e8:	50                   	push   %eax
  8002e9:	6a 00                	push   $0x0
  8002eb:	e8 f0 1a 00 00       	call   801de0 <sys_page_map>
  8002f0:	83 c4 20             	add    $0x20,%esp
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	79 12                	jns    800309 <bc_pgfault+0x95>
		panic("in bc_pgfault, sys_page_map: %e", r);
  8002f7:	50                   	push   %eax
  8002f8:	68 a8 31 80 00       	push   $0x8031a8
  8002fd:	6a 37                	push   $0x37
  8002ff:	68 ea 31 80 00       	push   $0x8031ea
  800304:	e8 33 10 00 00       	call   80133c <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800309:	83 3d 04 90 80 00 00 	cmpl   $0x0,0x809004
  800310:	74 22                	je     800334 <bc_pgfault+0xc0>
  800312:	83 ec 0c             	sub    $0xc,%esp
  800315:	53                   	push   %ebx
  800316:	e8 39 03 00 00       	call   800654 <block_is_free>
  80031b:	83 c4 10             	add    $0x10,%esp
  80031e:	84 c0                	test   %al,%al
  800320:	74 12                	je     800334 <bc_pgfault+0xc0>
		panic("reading free block %08x\n", blockno);
  800322:	53                   	push   %ebx
  800323:	68 f2 31 80 00       	push   $0x8031f2
  800328:	6a 3d                	push   $0x3d
  80032a:	68 ea 31 80 00       	push   $0x8031ea
  80032f:	e8 08 10 00 00       	call   80133c <_panic>
}
  800334:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800337:	c9                   	leave  
  800338:	c3                   	ret    

00800339 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	83 ec 08             	sub    $0x8,%esp
  80033f:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800342:	85 c0                	test   %eax,%eax
  800344:	74 0f                	je     800355 <diskaddr+0x1c>
  800346:	8b 15 08 90 80 00    	mov    0x809008,%edx
  80034c:	85 d2                	test   %edx,%edx
  80034e:	74 17                	je     800367 <diskaddr+0x2e>
  800350:	3b 42 04             	cmp    0x4(%edx),%eax
  800353:	72 12                	jb     800367 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  800355:	50                   	push   %eax
  800356:	68 c8 31 80 00       	push   $0x8031c8
  80035b:	6a 09                	push   $0x9
  80035d:	68 ea 31 80 00       	push   $0x8031ea
  800362:	e8 d5 0f 00 00       	call   80133c <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  800367:	05 00 00 01 00       	add    $0x10000,%eax
  80036c:	c1 e0 0c             	shl    $0xc,%eax
}
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  800377:	89 d0                	mov    %edx,%eax
  800379:	c1 e8 16             	shr    $0x16,%eax
  80037c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  800383:	b8 00 00 00 00       	mov    $0x0,%eax
  800388:	f6 c1 01             	test   $0x1,%cl
  80038b:	74 0d                	je     80039a <va_is_mapped+0x29>
  80038d:	c1 ea 0c             	shr    $0xc,%edx
  800390:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800397:	83 e0 01             	and    $0x1,%eax
  80039a:	83 e0 01             	and    $0x1,%eax
}
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a5:	c1 e8 0c             	shr    $0xc,%eax
  8003a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003af:	c1 e8 06             	shr    $0x6,%eax
  8003b2:	83 e0 01             	and    $0x1,%eax
}
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 08             	sub    $0x8,%esp
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8003c0:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
  8003c6:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  8003cc:	76 12                	jbe    8003e0 <flush_block+0x29>
		panic("flush_block of bad va %08x", addr);
  8003ce:	50                   	push   %eax
  8003cf:	68 0b 32 80 00       	push   $0x80320b
  8003d4:	6a 4d                	push   $0x4d
  8003d6:	68 ea 31 80 00       	push   $0x8031ea
  8003db:	e8 5c 0f 00 00       	call   80133c <_panic>

	// LAB 5: Your code here.
	panic("flush_block not implemented");
  8003e0:	83 ec 04             	sub    $0x4,%esp
  8003e3:	68 26 32 80 00       	push   $0x803226
  8003e8:	6a 50                	push   $0x50
  8003ea:	68 ea 31 80 00       	push   $0x8031ea
  8003ef:	e8 48 0f 00 00       	call   80133c <_panic>

008003f4 <check_bc>:

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	81 ec 24 01 00 00    	sub    $0x124,%esp
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8003fd:	6a 01                	push   $0x1
  8003ff:	e8 35 ff ff ff       	call   800339 <diskaddr>
  800404:	83 c4 0c             	add    $0xc,%esp
  800407:	68 08 01 00 00       	push   $0x108
  80040c:	50                   	push   %eax
  80040d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800413:	50                   	push   %eax
  800414:	e8 13 17 00 00       	call   801b2c <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800419:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800420:	e8 14 ff ff ff       	call   800339 <diskaddr>
  800425:	83 c4 08             	add    $0x8,%esp
  800428:	68 42 32 80 00       	push   $0x803242
  80042d:	50                   	push   %eax
  80042e:	e8 67 15 00 00       	call   80199a <strcpy>
	flush_block(diskaddr(1));
  800433:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80043a:	e8 fa fe ff ff       	call   800339 <diskaddr>
  80043f:	89 04 24             	mov    %eax,(%esp)
  800442:	e8 70 ff ff ff       	call   8003b7 <flush_block>

00800447 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  800447:	55                   	push   %ebp
  800448:	89 e5                	mov    %esp,%ebp
  80044a:	83 ec 14             	sub    $0x14,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  80044d:	68 74 02 80 00       	push   $0x800274
  800452:	e8 37 1b 00 00       	call   801f8e <set_pgfault_handler>
	check_bc();
  800457:	e8 98 ff ff ff       	call   8003f4 <check_bc>

0080045c <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
  80045f:	57                   	push   %edi
  800460:	56                   	push   %esi
  800461:	53                   	push   %ebx
  800462:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  800468:	89 95 64 ff ff ff    	mov    %edx,-0x9c(%ebp)
  80046e:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  800474:	eb 03                	jmp    800479 <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800476:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800479:	80 38 2f             	cmpb   $0x2f,(%eax)
  80047c:	74 f8                	je     800476 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  80047e:	8b 3d 08 90 80 00    	mov    0x809008,%edi
  800484:	8d 4f 08             	lea    0x8(%edi),%ecx
  800487:	89 8d 5c ff ff ff    	mov    %ecx,-0xa4(%ebp)
	dir = 0;
	name[0] = 0;
  80048d:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800494:	8b 8d 64 ff ff ff    	mov    -0x9c(%ebp),%ecx
  80049a:	85 c9                	test   %ecx,%ecx
  80049c:	0f 84 3d 01 00 00    	je     8005df <walk_path+0x183>
		*pdir = 0;
  8004a2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  8004a8:	8b 8d 60 ff ff ff    	mov    -0xa0(%ebp),%ecx
  8004ae:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	while (*path != '\0') {
  8004b4:	80 38 00             	cmpb   $0x0,(%eax)
  8004b7:	0f 84 f3 00 00 00    	je     8005b0 <walk_path+0x154>
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	eb 03                	jmp    8004c4 <walk_path+0x68>
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  8004c1:	83 c3 01             	add    $0x1,%ebx
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  8004c4:	0f b6 13             	movzbl (%ebx),%edx
  8004c7:	80 fa 2f             	cmp    $0x2f,%dl
  8004ca:	74 04                	je     8004d0 <walk_path+0x74>
  8004cc:	84 d2                	test   %dl,%dl
  8004ce:	75 f1                	jne    8004c1 <walk_path+0x65>
			path++;
		if (path - p >= MAXNAMELEN)
  8004d0:	89 de                	mov    %ebx,%esi
  8004d2:	29 c6                	sub    %eax,%esi
  8004d4:	83 fe 7f             	cmp    $0x7f,%esi
  8004d7:	0f 8f f4 00 00 00    	jg     8005d1 <walk_path+0x175>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  8004dd:	83 ec 04             	sub    $0x4,%esp
  8004e0:	56                   	push   %esi
  8004e1:	50                   	push   %eax
  8004e2:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8004e8:	50                   	push   %eax
  8004e9:	e8 3e 16 00 00       	call   801b2c <memmove>
		name[path - p] = '\0';
  8004ee:	c6 84 35 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%esi,1)
  8004f5:	00 
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb 03                	jmp    8004fe <walk_path+0xa2>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  8004fb:	83 c3 01             	add    $0x1,%ebx

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8004fe:	0f b6 13             	movzbl (%ebx),%edx
  800501:	80 fa 2f             	cmp    $0x2f,%dl
  800504:	74 f5                	je     8004fb <walk_path+0x9f>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800506:	83 bf 8c 00 00 00 01 	cmpl   $0x1,0x8c(%edi)
  80050d:	0f 85 c5 00 00 00    	jne    8005d8 <walk_path+0x17c>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800513:	8b 8f 88 00 00 00    	mov    0x88(%edi),%ecx
  800519:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
  80051f:	74 19                	je     80053a <walk_path+0xde>
  800521:	68 49 32 80 00       	push   $0x803249
  800526:	68 3d 31 80 00       	push   $0x80313d
  80052b:	68 ab 00 00 00       	push   $0xab
  800530:	68 66 32 80 00       	push   $0x803266
  800535:	e8 02 0e 00 00       	call   80133c <_panic>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  80053a:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
  800540:	85 c9                	test   %ecx,%ecx
  800542:	0f 49 c1             	cmovns %ecx,%eax
  800545:	c1 f8 0c             	sar    $0xc,%eax
  800548:	85 c0                	test   %eax,%eax
  80054a:	74 17                	je     800563 <walk_path+0x107>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  80054c:	83 ec 04             	sub    $0x4,%esp
  80054f:	68 38 33 80 00       	push   $0x803338
  800554:	68 99 00 00 00       	push   $0x99
  800559:	68 66 32 80 00       	push   $0x803266
  80055e:	e8 d9 0d 00 00       	call   80133c <_panic>
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800563:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800568:	84 d2                	test   %dl,%dl
  80056a:	0f 85 86 00 00 00    	jne    8005f6 <walk_path+0x19a>
				if (pdir)
  800570:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  800576:	85 c0                	test   %eax,%eax
  800578:	74 08                	je     800582 <walk_path+0x126>
					*pdir = dir;
  80057a:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  800580:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800582:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800586:	74 15                	je     80059d <walk_path+0x141>
					strcpy(lastelem, name);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800591:	50                   	push   %eax
  800592:	ff 75 08             	pushl  0x8(%ebp)
  800595:	e8 00 14 00 00       	call   80199a <strcpy>
  80059a:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  80059d:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  8005a3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  8005a9:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8005ae:	eb 46                	jmp    8005f6 <walk_path+0x19a>
		}
	}

	if (pdir)
		*pdir = dir;
  8005b0:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  8005b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pf = f;
  8005bc:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  8005c2:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  8005c8:	89 08                	mov    %ecx,(%eax)
	return 0;
  8005ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8005cf:	eb 25                	jmp    8005f6 <walk_path+0x19a>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  8005d1:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8005d6:	eb 1e                	jmp    8005f6 <walk_path+0x19a>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  8005d8:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8005dd:	eb 17                	jmp    8005f6 <walk_path+0x19a>
	dir = 0;
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
  8005df:	8b 8d 60 ff ff ff    	mov    -0xa0(%ebp),%ecx
  8005e5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	while (*path != '\0') {
  8005eb:	80 38 00             	cmpb   $0x0,(%eax)
  8005ee:	0f 85 c9 fe ff ff    	jne    8004bd <walk_path+0x61>
  8005f4:	eb c6                	jmp    8005bc <walk_path+0x160>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  8005f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f9:	5b                   	pop    %ebx
  8005fa:	5e                   	pop    %esi
  8005fb:	5f                   	pop    %edi
  8005fc:	5d                   	pop    %ebp
  8005fd:	c3                   	ret    

008005fe <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8005fe:	55                   	push   %ebp
  8005ff:	89 e5                	mov    %esp,%ebp
  800601:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  800604:	a1 08 90 80 00       	mov    0x809008,%eax
  800609:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  80060f:	74 14                	je     800625 <check_super+0x27>
		panic("bad file system magic number");
  800611:	83 ec 04             	sub    $0x4,%esp
  800614:	68 6e 32 80 00       	push   $0x80326e
  800619:	6a 0f                	push   $0xf
  80061b:	68 66 32 80 00       	push   $0x803266
  800620:	e8 17 0d 00 00       	call   80133c <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800625:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  80062c:	76 14                	jbe    800642 <check_super+0x44>
		panic("file system is too large");
  80062e:	83 ec 04             	sub    $0x4,%esp
  800631:	68 8b 32 80 00       	push   $0x80328b
  800636:	6a 12                	push   $0x12
  800638:	68 66 32 80 00       	push   $0x803266
  80063d:	e8 fa 0c 00 00       	call   80133c <_panic>

	cprintf("superblock is good\n");
  800642:	83 ec 0c             	sub    $0xc,%esp
  800645:	68 a4 32 80 00       	push   $0x8032a4
  80064a:	e8 c6 0d 00 00       	call   801415 <cprintf>
}
  80064f:	83 c4 10             	add    $0x10,%esp
  800652:	c9                   	leave  
  800653:	c3                   	ret    

00800654 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800654:	55                   	push   %ebp
  800655:	89 e5                	mov    %esp,%ebp
  800657:	53                   	push   %ebx
  800658:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  80065b:	8b 15 08 90 80 00    	mov    0x809008,%edx
  800661:	85 d2                	test   %edx,%edx
  800663:	74 24                	je     800689 <block_is_free+0x35>
		return 0;
  800665:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  80066a:	39 4a 04             	cmp    %ecx,0x4(%edx)
  80066d:	76 1f                	jbe    80068e <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  80066f:	89 cb                	mov    %ecx,%ebx
  800671:	c1 eb 05             	shr    $0x5,%ebx
  800674:	b8 01 00 00 00       	mov    $0x1,%eax
  800679:	d3 e0                	shl    %cl,%eax
  80067b:	8b 15 04 90 80 00    	mov    0x809004,%edx
  800681:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  800684:	0f 95 c0             	setne  %al
  800687:	eb 05                	jmp    80068e <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800689:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  80068e:	5b                   	pop    %ebx
  80068f:	5d                   	pop    %ebp
  800690:	c3                   	ret    

00800691 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	53                   	push   %ebx
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  80069b:	85 c9                	test   %ecx,%ecx
  80069d:	75 14                	jne    8006b3 <free_block+0x22>
		panic("attempt to free zero block");
  80069f:	83 ec 04             	sub    $0x4,%esp
  8006a2:	68 b8 32 80 00       	push   $0x8032b8
  8006a7:	6a 2d                	push   $0x2d
  8006a9:	68 66 32 80 00       	push   $0x803266
  8006ae:	e8 89 0c 00 00       	call   80133c <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  8006b3:	89 cb                	mov    %ecx,%ebx
  8006b5:	c1 eb 05             	shr    $0x5,%ebx
  8006b8:	8b 15 04 90 80 00    	mov    0x809004,%edx
  8006be:	b8 01 00 00 00       	mov    $0x1,%eax
  8006c3:	d3 e0                	shl    %cl,%eax
  8006c5:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  8006c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006cb:	c9                   	leave  
  8006cc:	c3                   	ret    

008006cd <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 0c             	sub    $0xc,%esp
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	panic("alloc_block not implemented");
  8006d3:	68 d3 32 80 00       	push   $0x8032d3
  8006d8:	6a 41                	push   $0x41
  8006da:	68 66 32 80 00       	push   $0x803266
  8006df:	e8 58 0c 00 00       	call   80133c <_panic>

008006e4 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	56                   	push   %esi
  8006e8:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8006e9:	a1 08 90 80 00       	mov    0x809008,%eax
  8006ee:	8b 70 04             	mov    0x4(%eax),%esi
  8006f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f6:	eb 29                	jmp    800721 <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  8006f8:	8d 43 02             	lea    0x2(%ebx),%eax
  8006fb:	50                   	push   %eax
  8006fc:	e8 53 ff ff ff       	call   800654 <block_is_free>
  800701:	83 c4 04             	add    $0x4,%esp
  800704:	84 c0                	test   %al,%al
  800706:	74 16                	je     80071e <check_bitmap+0x3a>
  800708:	68 ef 32 80 00       	push   $0x8032ef
  80070d:	68 3d 31 80 00       	push   $0x80313d
  800712:	6a 50                	push   $0x50
  800714:	68 66 32 80 00       	push   $0x803266
  800719:	e8 1e 0c 00 00       	call   80133c <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80071e:	83 c3 01             	add    $0x1,%ebx
  800721:	89 d8                	mov    %ebx,%eax
  800723:	c1 e0 0f             	shl    $0xf,%eax
  800726:	39 f0                	cmp    %esi,%eax
  800728:	72 ce                	jb     8006f8 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  80072a:	83 ec 0c             	sub    $0xc,%esp
  80072d:	6a 00                	push   $0x0
  80072f:	e8 20 ff ff ff       	call   800654 <block_is_free>
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	84 c0                	test   %al,%al
  800739:	74 16                	je     800751 <check_bitmap+0x6d>
  80073b:	68 03 33 80 00       	push   $0x803303
  800740:	68 3d 31 80 00       	push   $0x80313d
  800745:	6a 53                	push   $0x53
  800747:	68 66 32 80 00       	push   $0x803266
  80074c:	e8 eb 0b 00 00       	call   80133c <_panic>
	assert(!block_is_free(1));
  800751:	83 ec 0c             	sub    $0xc,%esp
  800754:	6a 01                	push   $0x1
  800756:	e8 f9 fe ff ff       	call   800654 <block_is_free>
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	84 c0                	test   %al,%al
  800760:	74 16                	je     800778 <check_bitmap+0x94>
  800762:	68 15 33 80 00       	push   $0x803315
  800767:	68 3d 31 80 00       	push   $0x80313d
  80076c:	6a 54                	push   $0x54
  80076e:	68 66 32 80 00       	push   $0x803266
  800773:	e8 c4 0b 00 00       	call   80133c <_panic>

	cprintf("bitmap is good\n");
  800778:	83 ec 0c             	sub    $0xc,%esp
  80077b:	68 27 33 80 00       	push   $0x803327
  800780:	e8 90 0c 00 00       	call   801415 <cprintf>
}
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80078b:	5b                   	pop    %ebx
  80078c:	5e                   	pop    %esi
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

       // Find a JOS disk.  Use the second IDE disk (number 1) if availabl
       if (ide_probe_disk1())
  800795:	e8 c5 f8 ff ff       	call   80005f <ide_probe_disk1>
  80079a:	84 c0                	test   %al,%al
  80079c:	74 0f                	je     8007ad <fs_init+0x1e>
               ide_set_disk(1);
  80079e:	83 ec 0c             	sub    $0xc,%esp
  8007a1:	6a 01                	push   $0x1
  8007a3:	e8 1b f9 ff ff       	call   8000c3 <ide_set_disk>
  8007a8:	83 c4 10             	add    $0x10,%esp
  8007ab:	eb 0d                	jmp    8007ba <fs_init+0x2b>
       else
               ide_set_disk(0);
  8007ad:	83 ec 0c             	sub    $0xc,%esp
  8007b0:	6a 00                	push   $0x0
  8007b2:	e8 0c f9 ff ff       	call   8000c3 <ide_set_disk>
  8007b7:	83 c4 10             	add    $0x10,%esp
	bc_init();
  8007ba:	e8 88 fc ff ff       	call   800447 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  8007bf:	83 ec 0c             	sub    $0xc,%esp
  8007c2:	6a 01                	push   $0x1
  8007c4:	e8 70 fb ff ff       	call   800339 <diskaddr>
  8007c9:	a3 08 90 80 00       	mov    %eax,0x809008
	check_super();
  8007ce:	e8 2b fe ff ff       	call   8005fe <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  8007d3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8007da:	e8 5a fb ff ff       	call   800339 <diskaddr>
  8007df:	a3 04 90 80 00       	mov    %eax,0x809004
	check_bitmap();
  8007e4:	e8 fb fe ff ff       	call   8006e4 <check_bitmap>
	
}
  8007e9:	83 c4 10             	add    $0x10,%esp
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	83 ec 0c             	sub    $0xc,%esp
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  8007f4:	68 38 33 80 00       	push   $0x803338
  8007f9:	68 99 00 00 00       	push   $0x99
  8007fe:	68 66 32 80 00       	push   $0x803266
  800803:	e8 34 0b 00 00       	call   80133c <_panic>

00800808 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800813:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
  800819:	50                   	push   %eax
  80081a:	8d 8d 70 ff ff ff    	lea    -0x90(%ebp),%ecx
  800820:	8d 95 74 ff ff ff    	lea    -0x8c(%ebp),%edx
  800826:	8b 45 08             	mov    0x8(%ebp),%eax
  800829:	e8 2e fc ff ff       	call   80045c <walk_path>
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	85 c0                	test   %eax,%eax
  800833:	0f 84 82 00 00 00    	je     8008bb <file_create+0xb3>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800839:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80083c:	0f 85 85 00 00 00    	jne    8008c7 <file_create+0xbf>
  800842:	8b 8d 74 ff ff ff    	mov    -0x8c(%ebp),%ecx
  800848:	85 c9                	test   %ecx,%ecx
  80084a:	74 76                	je     8008c2 <file_create+0xba>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  80084c:	8b 99 80 00 00 00    	mov    0x80(%ecx),%ebx
  800852:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
  800858:	74 19                	je     800873 <file_create+0x6b>
  80085a:	68 49 32 80 00       	push   $0x803249
  80085f:	68 3d 31 80 00       	push   $0x80313d
  800864:	68 c4 00 00 00       	push   $0xc4
  800869:	68 66 32 80 00       	push   $0x803266
  80086e:	e8 c9 0a 00 00       	call   80133c <_panic>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800873:	be 00 10 00 00       	mov    $0x1000,%esi
  800878:	89 d8                	mov    %ebx,%eax
  80087a:	99                   	cltd   
  80087b:	f7 fe                	idiv   %esi
  80087d:	85 c0                	test   %eax,%eax
  80087f:	74 17                	je     800898 <file_create+0x90>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800881:	83 ec 04             	sub    $0x4,%esp
  800884:	68 38 33 80 00       	push   $0x803338
  800889:	68 99 00 00 00       	push   $0x99
  80088e:	68 66 32 80 00       	push   $0x803266
  800893:	e8 a4 0a 00 00       	call   80133c <_panic>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800898:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80089e:	89 99 80 00 00 00    	mov    %ebx,0x80(%ecx)
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  8008a4:	83 ec 04             	sub    $0x4,%esp
  8008a7:	68 38 33 80 00       	push   $0x803338
  8008ac:	68 99 00 00 00       	push   $0x99
  8008b1:	68 66 32 80 00       	push   $0x803266
  8008b6:	e8 81 0a 00 00       	call   80133c <_panic>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  8008bb:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  8008c0:	eb 05                	jmp    8008c7 <file_create+0xbf>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  8008c2:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  8008c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  8008d4:	6a 00                	push   $0x0
  8008d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	e8 76 fb ff ff       	call   80045c <walk_path>
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 08             	sub    $0x8,%esp
  8008ee:	8b 55 14             	mov    0x14(%ebp),%edx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8008fa:	39 d0                	cmp    %edx,%eax
  8008fc:	7e 27                	jle    800925 <file_read+0x3d>
		return 0;

	count = MIN(count, f->f_size - offset);
  8008fe:	29 d0                	sub    %edx,%eax
  800900:	3b 45 10             	cmp    0x10(%ebp),%eax
  800903:	0f 47 45 10          	cmova  0x10(%ebp),%eax

	for (pos = offset; pos < offset + count; ) {
  800907:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  80090a:	39 ca                	cmp    %ecx,%edx
  80090c:	73 1c                	jae    80092a <file_read+0x42>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  80090e:	83 ec 04             	sub    $0x4,%esp
  800911:	68 38 33 80 00       	push   $0x803338
  800916:	68 99 00 00 00       	push   $0x99
  80091b:	68 66 32 80 00       	push   $0x803266
  800920:	e8 17 0a 00 00       	call   80133c <_panic>
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
		pos += bn;
		buf += bn;
	}

	return count;
}
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    

0080092c <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800934:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (f->f_size > newsize)
  800937:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  80093d:	39 f0                	cmp    %esi,%eax
  80093f:	7e 65                	jle    8009a6 <file_set_size+0x7a>
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800941:	8d 96 fe 1f 00 00    	lea    0x1ffe(%esi),%edx
  800947:	89 f1                	mov    %esi,%ecx
  800949:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
  80094f:	0f 49 d1             	cmovns %ecx,%edx
  800952:	c1 fa 0c             	sar    $0xc,%edx
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800955:	8d 88 fe 1f 00 00    	lea    0x1ffe(%eax),%ecx
  80095b:	05 ff 0f 00 00       	add    $0xfff,%eax
  800960:	0f 48 c1             	cmovs  %ecx,%eax
  800963:	c1 f8 0c             	sar    $0xc,%eax
  800966:	39 d0                	cmp    %edx,%eax
  800968:	76 17                	jbe    800981 <file_set_size+0x55>
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
       panic("file_block_walk not implemented");
  80096a:	83 ec 04             	sub    $0x4,%esp
  80096d:	68 58 33 80 00       	push   $0x803358
  800972:	68 8a 00 00 00       	push   $0x8a
  800977:	68 66 32 80 00       	push   $0x803266
  80097c:	e8 bb 09 00 00       	call   80133c <_panic>
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800981:	83 fa 0a             	cmp    $0xa,%edx
  800984:	77 20                	ja     8009a6 <file_set_size+0x7a>
  800986:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  80098c:	85 c0                	test   %eax,%eax
  80098e:	74 16                	je     8009a6 <file_set_size+0x7a>
		free_block(f->f_indirect);
  800990:	83 ec 0c             	sub    $0xc,%esp
  800993:	50                   	push   %eax
  800994:	e8 f8 fc ff ff       	call   800691 <free_block>
		f->f_indirect = 0;
  800999:	c7 83 b0 00 00 00 00 	movl   $0x0,0xb0(%ebx)
  8009a0:	00 00 00 
  8009a3:	83 c4 10             	add    $0x10,%esp
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  8009a6:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
	flush_block(f);
  8009ac:	83 ec 0c             	sub    $0xc,%esp
  8009af:	53                   	push   %ebx
  8009b0:	e8 02 fa ff ff       	call   8003b7 <flush_block>
	return 0;
}
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009bd:	5b                   	pop    %ebx
  8009be:	5e                   	pop    %esi
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	57                   	push   %edi
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	83 ec 0c             	sub    $0xc,%esp
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009d0:	8b 7d 14             	mov    0x14(%ebp),%edi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  8009d3:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
  8009d6:	3b b0 80 00 00 00    	cmp    0x80(%eax),%esi
  8009dc:	76 11                	jbe    8009ef <file_write+0x2e>
		if ((r = file_set_size(f, offset + count)) < 0)
  8009de:	83 ec 08             	sub    $0x8,%esp
  8009e1:	56                   	push   %esi
  8009e2:	50                   	push   %eax
  8009e3:	e8 44 ff ff ff       	call   80092c <file_set_size>
  8009e8:	83 c4 10             	add    $0x10,%esp
  8009eb:	85 c0                	test   %eax,%eax
  8009ed:	78 1d                	js     800a0c <file_write+0x4b>
			return r;

	for (pos = offset; pos < offset + count; ) {
  8009ef:	39 f7                	cmp    %esi,%edi
  8009f1:	73 17                	jae    800a0a <file_write+0x49>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  8009f3:	83 ec 04             	sub    $0x4,%esp
  8009f6:	68 38 33 80 00       	push   $0x803338
  8009fb:	68 99 00 00 00       	push   $0x99
  800a00:	68 66 32 80 00       	push   $0x803266
  800a05:	e8 32 09 00 00       	call   80133c <_panic>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800a0a:	89 d8                	mov    %ebx,%eax
}
  800a0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5f                   	pop    %edi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	53                   	push   %ebx
  800a18:	83 ec 04             	sub    $0x4,%esp
  800a1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800a1e:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800a24:	05 ff 0f 00 00       	add    $0xfff,%eax
  800a29:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  800a2e:	7e 17                	jle    800a47 <file_flush+0x33>
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
       panic("file_block_walk not implemented");
  800a30:	83 ec 04             	sub    $0x4,%esp
  800a33:	68 58 33 80 00       	push   $0x803358
  800a38:	68 8a 00 00 00       	push   $0x8a
  800a3d:	68 66 32 80 00       	push   $0x803266
  800a42:	e8 f5 08 00 00       	call   80133c <_panic>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800a47:	83 ec 0c             	sub    $0xc,%esp
  800a4a:	53                   	push   %ebx
  800a4b:	e8 67 f9 ff ff       	call   8003b7 <flush_block>
	if (f->f_indirect)
  800a50:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800a56:	83 c4 10             	add    $0x10,%esp
  800a59:	85 c0                	test   %eax,%eax
  800a5b:	74 14                	je     800a71 <file_flush+0x5d>
		flush_block(diskaddr(f->f_indirect));
  800a5d:	83 ec 0c             	sub    $0xc,%esp
  800a60:	50                   	push   %eax
  800a61:	e8 d3 f8 ff ff       	call   800339 <diskaddr>
  800a66:	89 04 24             	mov    %eax,(%esp)
  800a69:	e8 49 f9 ff ff       	call   8003b7 <flush_block>
  800a6e:	83 c4 10             	add    $0x10,%esp
}
  800a71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a74:	c9                   	leave  
  800a75:	c3                   	ret    

00800a76 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	53                   	push   %ebx
  800a7a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800a7d:	bb 01 00 00 00       	mov    $0x1,%ebx
  800a82:	eb 17                	jmp    800a9b <fs_sync+0x25>
		flush_block(diskaddr(i));
  800a84:	83 ec 0c             	sub    $0xc,%esp
  800a87:	53                   	push   %ebx
  800a88:	e8 ac f8 ff ff       	call   800339 <diskaddr>
  800a8d:	89 04 24             	mov    %eax,(%esp)
  800a90:	e8 22 f9 ff ff       	call   8003b7 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800a95:	83 c3 01             	add    $0x1,%ebx
  800a98:	83 c4 10             	add    $0x10,%esp
  800a9b:	a1 08 90 80 00       	mov    0x809008,%eax
  800aa0:	39 58 04             	cmp    %ebx,0x4(%eax)
  800aa3:	77 df                	ja     800a84 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  800aa5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa8:	c9                   	leave  
  800aa9:	c3                   	ret    

00800aaa <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	return 0;
}
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	83 ec 0c             	sub    $0xc,%esp
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	panic("serve_write not implemented");
  800aba:	68 78 33 80 00       	push   $0x803378
  800abf:	68 e8 00 00 00       	push   $0xe8
  800ac4:	68 94 33 80 00       	push   $0x803394
  800ac9:	e8 6e 08 00 00       	call   80133c <_panic>

00800ace <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  800ad4:	e8 9d ff ff ff       	call   800a76 <fs_sync>
	return 0;
}
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ade:	c9                   	leave  
  800adf:	c3                   	ret    

00800ae0 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	ba 60 40 80 00       	mov    $0x804060,%edx
	int i;
	uintptr_t va = FILEVA;
  800ae8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  800af2:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  800af4:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  800af7:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  800afd:	83 c0 01             	add    $0x1,%eax
  800b00:	83 c2 10             	add    $0x10,%edx
  800b03:	3d 00 04 00 00       	cmp    $0x400,%eax
  800b08:	75 e8                	jne    800af2 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800b14:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	89 d8                	mov    %ebx,%eax
  800b1e:	c1 e0 04             	shl    $0x4,%eax
  800b21:	ff b0 6c 40 80 00    	pushl  0x80406c(%eax)
  800b27:	e8 6e 18 00 00       	call   80239a <pageref>
  800b2c:	83 c4 10             	add    $0x10,%esp
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	74 07                	je     800b3a <openfile_alloc+0x2e>
  800b33:	83 f8 01             	cmp    $0x1,%eax
  800b36:	74 20                	je     800b58 <openfile_alloc+0x4c>
  800b38:	eb 51                	jmp    800b8b <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  800b3a:	83 ec 04             	sub    $0x4,%esp
  800b3d:	6a 07                	push   $0x7
  800b3f:	89 d8                	mov    %ebx,%eax
  800b41:	c1 e0 04             	shl    $0x4,%eax
  800b44:	ff b0 6c 40 80 00    	pushl  0x80406c(%eax)
  800b4a:	6a 00                	push   $0x0
  800b4c:	e8 4c 12 00 00       	call   801d9d <sys_page_alloc>
  800b51:	83 c4 10             	add    $0x10,%esp
  800b54:	85 c0                	test   %eax,%eax
  800b56:	78 43                	js     800b9b <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  800b58:	c1 e3 04             	shl    $0x4,%ebx
  800b5b:	8d 83 60 40 80 00    	lea    0x804060(%ebx),%eax
  800b61:	81 83 60 40 80 00 00 	addl   $0x400,0x804060(%ebx)
  800b68:	04 00 00 
			*o = &opentab[i];
  800b6b:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  800b6d:	83 ec 04             	sub    $0x4,%esp
  800b70:	68 00 10 00 00       	push   $0x1000
  800b75:	6a 00                	push   $0x0
  800b77:	ff b3 6c 40 80 00    	pushl  0x80406c(%ebx)
  800b7d:	e8 5d 0f 00 00       	call   801adf <memset>
			return (*o)->o_fileid;
  800b82:	8b 06                	mov    (%esi),%eax
  800b84:	8b 00                	mov    (%eax),%eax
  800b86:	83 c4 10             	add    $0x10,%esp
  800b89:	eb 10                	jmp    800b9b <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800b8b:	83 c3 01             	add    $0x1,%ebx
  800b8e:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800b94:	75 83                	jne    800b19 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  800b96:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800b9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 18             	sub    $0x18,%esp
  800bab:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  800bae:	89 fb                	mov    %edi,%ebx
  800bb0:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800bb6:	89 de                	mov    %ebx,%esi
  800bb8:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  800bbb:	ff b6 6c 40 80 00    	pushl  0x80406c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  800bc1:	81 c6 60 40 80 00    	add    $0x804060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  800bc7:	e8 ce 17 00 00       	call   80239a <pageref>
  800bcc:	83 c4 10             	add    $0x10,%esp
  800bcf:	83 f8 01             	cmp    $0x1,%eax
  800bd2:	7e 17                	jle    800beb <openfile_lookup+0x49>
  800bd4:	c1 e3 04             	shl    $0x4,%ebx
  800bd7:	3b bb 60 40 80 00    	cmp    0x804060(%ebx),%edi
  800bdd:	75 13                	jne    800bf2 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  800bdf:	8b 45 10             	mov    0x10(%ebp),%eax
  800be2:	89 30                	mov    %esi,(%eax)
	return 0;
  800be4:	b8 00 00 00 00       	mov    $0x0,%eax
  800be9:	eb 0c                	jmp    800bf7 <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  800beb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bf0:	eb 05                	jmp    800bf7 <openfile_lookup+0x55>
  800bf2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  800bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	53                   	push   %ebx
  800c03:	83 ec 18             	sub    $0x18,%esp
  800c06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800c09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c0c:	50                   	push   %eax
  800c0d:	ff 33                	pushl  (%ebx)
  800c0f:	ff 75 08             	pushl  0x8(%ebp)
  800c12:	e8 8b ff ff ff       	call   800ba2 <openfile_lookup>
  800c17:	83 c4 10             	add    $0x10,%esp
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	78 14                	js     800c32 <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  800c1e:	83 ec 08             	sub    $0x8,%esp
  800c21:	ff 73 04             	pushl  0x4(%ebx)
  800c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c27:	ff 70 04             	pushl  0x4(%eax)
  800c2a:	e8 fd fc ff ff       	call   80092c <file_set_size>
  800c2f:	83 c4 10             	add    $0x10,%esp
}
  800c32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 18             	sub    $0x18,%esp
  800c3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800c41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c44:	50                   	push   %eax
  800c45:	ff 33                	pushl  (%ebx)
  800c47:	ff 75 08             	pushl  0x8(%ebp)
  800c4a:	e8 53 ff ff ff       	call   800ba2 <openfile_lookup>
  800c4f:	83 c4 10             	add    $0x10,%esp
  800c52:	85 c0                	test   %eax,%eax
  800c54:	78 3f                	js     800c95 <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  800c56:	83 ec 08             	sub    $0x8,%esp
  800c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c5c:	ff 70 04             	pushl  0x4(%eax)
  800c5f:	53                   	push   %ebx
  800c60:	e8 35 0d 00 00       	call   80199a <strcpy>
	ret->ret_size = o->o_file->f_size;
  800c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c68:	8b 50 04             	mov    0x4(%eax),%edx
  800c6b:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  800c71:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  800c77:	8b 40 04             	mov    0x4(%eax),%eax
  800c7a:	83 c4 10             	add    $0x10,%esp
  800c7d:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800c84:	0f 94 c0             	sete   %al
  800c87:	0f b6 c0             	movzbl %al,%eax
  800c8a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800c90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c98:	c9                   	leave  
  800c99:	c3                   	ret    

00800c9a <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800ca0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca3:	50                   	push   %eax
  800ca4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca7:	ff 30                	pushl  (%eax)
  800ca9:	ff 75 08             	pushl  0x8(%ebp)
  800cac:	e8 f1 fe ff ff       	call   800ba2 <openfile_lookup>
  800cb1:	83 c4 10             	add    $0x10,%esp
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	78 16                	js     800cce <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cbe:	ff 70 04             	pushl  0x4(%eax)
  800cc1:	e8 4e fd ff ff       	call   800a14 <file_flush>
	return 0;
  800cc6:	83 c4 10             	add    $0x10,%esp
  800cc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cce:	c9                   	leave  
  800ccf:	c3                   	ret    

00800cd0 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	53                   	push   %ebx
  800cd4:	81 ec 18 04 00 00    	sub    $0x418,%esp
  800cda:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  800cdd:	68 00 04 00 00       	push   $0x400
  800ce2:	53                   	push   %ebx
  800ce3:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800ce9:	50                   	push   %eax
  800cea:	e8 3d 0e 00 00       	call   801b2c <memmove>
	path[MAXPATHLEN-1] = 0;
  800cef:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  800cf3:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  800cf9:	89 04 24             	mov    %eax,(%esp)
  800cfc:	e8 0b fe ff ff       	call   800b0c <openfile_alloc>
  800d01:	83 c4 10             	add    $0x10,%esp
  800d04:	85 c0                	test   %eax,%eax
  800d06:	0f 88 f0 00 00 00    	js     800dfc <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  800d0c:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  800d13:	74 33                	je     800d48 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  800d15:	83 ec 08             	sub    $0x8,%esp
  800d18:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800d1e:	50                   	push   %eax
  800d1f:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800d25:	50                   	push   %eax
  800d26:	e8 dd fa ff ff       	call   800808 <file_create>
  800d2b:	83 c4 10             	add    $0x10,%esp
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	79 37                	jns    800d69 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  800d32:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  800d39:	0f 85 bd 00 00 00    	jne    800dfc <serve_open+0x12c>
  800d3f:	83 f8 f3             	cmp    $0xfffffff3,%eax
  800d42:	0f 85 b4 00 00 00    	jne    800dfc <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  800d48:	83 ec 08             	sub    $0x8,%esp
  800d4b:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800d51:	50                   	push   %eax
  800d52:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800d58:	50                   	push   %eax
  800d59:	e8 70 fb ff ff       	call   8008ce <file_open>
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	85 c0                	test   %eax,%eax
  800d63:	0f 88 93 00 00 00    	js     800dfc <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  800d69:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  800d70:	74 17                	je     800d89 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  800d72:	83 ec 08             	sub    $0x8,%esp
  800d75:	6a 00                	push   $0x0
  800d77:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  800d7d:	e8 aa fb ff ff       	call   80092c <file_set_size>
  800d82:	83 c4 10             	add    $0x10,%esp
  800d85:	85 c0                	test   %eax,%eax
  800d87:	78 73                	js     800dfc <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  800d89:	83 ec 08             	sub    $0x8,%esp
  800d8c:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800d92:	50                   	push   %eax
  800d93:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800d99:	50                   	push   %eax
  800d9a:	e8 2f fb ff ff       	call   8008ce <file_open>
  800d9f:	83 c4 10             	add    $0x10,%esp
  800da2:	85 c0                	test   %eax,%eax
  800da4:	78 56                	js     800dfc <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  800da6:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  800dac:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  800db2:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  800db5:	8b 50 0c             	mov    0xc(%eax),%edx
  800db8:	8b 08                	mov    (%eax),%ecx
  800dba:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  800dbd:	8b 48 0c             	mov    0xc(%eax),%ecx
  800dc0:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  800dc6:	83 e2 03             	and    $0x3,%edx
  800dc9:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  800dcc:	8b 40 0c             	mov    0xc(%eax),%eax
  800dcf:	8b 15 64 80 80 00    	mov    0x808064,%edx
  800dd5:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  800dd7:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  800ddd:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  800de3:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  800de6:	8b 50 0c             	mov    0xc(%eax),%edx
  800de9:	8b 45 10             	mov    0x10(%ebp),%eax
  800dec:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  800dee:	8b 45 14             	mov    0x14(%ebp),%eax
  800df1:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  800df7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dfc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dff:	c9                   	leave  
  800e00:	c3                   	ret    

00800e01 <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  800e09:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  800e0c:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  800e0f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  800e16:	83 ec 04             	sub    $0x4,%esp
  800e19:	53                   	push   %ebx
  800e1a:	ff 35 44 40 80 00    	pushl  0x804044
  800e20:	56                   	push   %esi
  800e21:	e8 0a 12 00 00       	call   802030 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  800e26:	83 c4 10             	add    $0x10,%esp
  800e29:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  800e2d:	75 15                	jne    800e44 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  800e2f:	83 ec 08             	sub    $0x8,%esp
  800e32:	ff 75 f4             	pushl  -0xc(%ebp)
  800e35:	68 c0 33 80 00       	push   $0x8033c0
  800e3a:	e8 d6 05 00 00       	call   801415 <cprintf>
				whom);
			continue; // just leave it hanging...
  800e3f:	83 c4 10             	add    $0x10,%esp
  800e42:	eb cb                	jmp    800e0f <serve+0xe>
		}

		pg = NULL;
  800e44:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  800e4b:	83 f8 01             	cmp    $0x1,%eax
  800e4e:	75 18                	jne    800e68 <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  800e50:	53                   	push   %ebx
  800e51:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e54:	50                   	push   %eax
  800e55:	ff 35 44 40 80 00    	pushl  0x804044
  800e5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e5e:	e8 6d fe ff ff       	call   800cd0 <serve_open>
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	eb 3c                	jmp    800ea4 <serve+0xa3>
		} else if (req < NHANDLERS && handlers[req]) {
  800e68:	83 f8 08             	cmp    $0x8,%eax
  800e6b:	77 1e                	ja     800e8b <serve+0x8a>
  800e6d:	8b 14 85 20 40 80 00 	mov    0x804020(,%eax,4),%edx
  800e74:	85 d2                	test   %edx,%edx
  800e76:	74 13                	je     800e8b <serve+0x8a>
			r = handlers[req](whom, fsreq);
  800e78:	83 ec 08             	sub    $0x8,%esp
  800e7b:	ff 35 44 40 80 00    	pushl  0x804044
  800e81:	ff 75 f4             	pushl  -0xc(%ebp)
  800e84:	ff d2                	call   *%edx
  800e86:	83 c4 10             	add    $0x10,%esp
  800e89:	eb 19                	jmp    800ea4 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e91:	50                   	push   %eax
  800e92:	68 f0 33 80 00       	push   $0x8033f0
  800e97:	e8 79 05 00 00       	call   801415 <cprintf>
  800e9c:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  800e9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  800ea4:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea7:	ff 75 ec             	pushl  -0x14(%ebp)
  800eaa:	50                   	push   %eax
  800eab:	ff 75 f4             	pushl  -0xc(%ebp)
  800eae:	e8 f2 11 00 00       	call   8020a5 <ipc_send>
		sys_page_unmap(0, fsreq);
  800eb3:	83 c4 08             	add    $0x8,%esp
  800eb6:	ff 35 44 40 80 00    	pushl  0x804044
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 5f 0f 00 00       	call   801e22 <sys_page_unmap>
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	e9 44 ff ff ff       	jmp    800e0f <serve+0xe>

00800ecb <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  800ed1:	c7 05 60 80 80 00 9e 	movl   $0x80339e,0x808060
  800ed8:	33 80 00 
	cprintf("FS is running\n");
  800edb:	68 a1 33 80 00       	push   $0x8033a1
  800ee0:	e8 30 05 00 00       	call   801415 <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  800ee5:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  800eea:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  800eef:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  800ef1:	c7 04 24 b0 33 80 00 	movl   $0x8033b0,(%esp)
  800ef8:	e8 18 05 00 00       	call   801415 <cprintf>

	serve_init();
  800efd:	e8 de fb ff ff       	call   800ae0 <serve_init>
	fs_init();
  800f02:	e8 88 f8 ff ff       	call   80078f <fs_init>
        fs_test();
  800f07:	e8 05 00 00 00       	call   800f11 <fs_test>
	serve();
  800f0c:	e8 f0 fe ff ff       	call   800e01 <serve>

00800f11 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	53                   	push   %ebx
  800f15:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  800f18:	6a 07                	push   $0x7
  800f1a:	68 00 10 00 00       	push   $0x1000
  800f1f:	6a 00                	push   $0x0
  800f21:	e8 77 0e 00 00       	call   801d9d <sys_page_alloc>
  800f26:	83 c4 10             	add    $0x10,%esp
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	79 12                	jns    800f3f <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  800f2d:	50                   	push   %eax
  800f2e:	68 13 34 80 00       	push   $0x803413
  800f33:	6a 12                	push   $0x12
  800f35:	68 26 34 80 00       	push   $0x803426
  800f3a:	e8 fd 03 00 00       	call   80133c <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  800f3f:	83 ec 04             	sub    $0x4,%esp
  800f42:	68 00 10 00 00       	push   $0x1000
  800f47:	ff 35 04 90 80 00    	pushl  0x809004
  800f4d:	68 00 10 00 00       	push   $0x1000
  800f52:	e8 d5 0b 00 00       	call   801b2c <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  800f57:	e8 71 f7 ff ff       	call   8006cd <alloc_block>
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	79 12                	jns    800f75 <fs_test+0x64>
		panic("alloc_block: %e", r);
  800f63:	50                   	push   %eax
  800f64:	68 30 34 80 00       	push   $0x803430
  800f69:	6a 17                	push   $0x17
  800f6b:	68 26 34 80 00       	push   $0x803426
  800f70:	e8 c7 03 00 00       	call   80133c <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  800f75:	8d 50 1f             	lea    0x1f(%eax),%edx
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	0f 49 d0             	cmovns %eax,%edx
  800f7d:	c1 fa 05             	sar    $0x5,%edx
  800f80:	89 c3                	mov    %eax,%ebx
  800f82:	c1 fb 1f             	sar    $0x1f,%ebx
  800f85:	c1 eb 1b             	shr    $0x1b,%ebx
  800f88:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  800f8b:	83 e1 1f             	and    $0x1f,%ecx
  800f8e:	29 d9                	sub    %ebx,%ecx
  800f90:	b8 01 00 00 00       	mov    $0x1,%eax
  800f95:	d3 e0                	shl    %cl,%eax
  800f97:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  800f9e:	75 16                	jne    800fb6 <fs_test+0xa5>
  800fa0:	68 40 34 80 00       	push   $0x803440
  800fa5:	68 3d 31 80 00       	push   $0x80313d
  800faa:	6a 19                	push   $0x19
  800fac:	68 26 34 80 00       	push   $0x803426
  800fb1:	e8 86 03 00 00       	call   80133c <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  800fb6:	8b 0d 04 90 80 00    	mov    0x809004,%ecx
  800fbc:	85 04 91             	test   %eax,(%ecx,%edx,4)
  800fbf:	74 16                	je     800fd7 <fs_test+0xc6>
  800fc1:	68 b8 35 80 00       	push   $0x8035b8
  800fc6:	68 3d 31 80 00       	push   $0x80313d
  800fcb:	6a 1b                	push   $0x1b
  800fcd:	68 26 34 80 00       	push   $0x803426
  800fd2:	e8 65 03 00 00       	call   80133c <_panic>
	cprintf("alloc_block is good\n");
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	68 5b 34 80 00       	push   $0x80345b
  800fdf:	e8 31 04 00 00       	call   801415 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  800fe4:	83 c4 08             	add    $0x8,%esp
  800fe7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fea:	50                   	push   %eax
  800feb:	68 70 34 80 00       	push   $0x803470
  800ff0:	e8 d9 f8 ff ff       	call   8008ce <file_open>
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800ffb:	74 1b                	je     801018 <fs_test+0x107>
  800ffd:	89 c2                	mov    %eax,%edx
  800fff:	c1 ea 1f             	shr    $0x1f,%edx
  801002:	84 d2                	test   %dl,%dl
  801004:	74 12                	je     801018 <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  801006:	50                   	push   %eax
  801007:	68 7b 34 80 00       	push   $0x80347b
  80100c:	6a 1f                	push   $0x1f
  80100e:	68 26 34 80 00       	push   $0x803426
  801013:	e8 24 03 00 00       	call   80133c <_panic>
	else if (r == 0)
  801018:	85 c0                	test   %eax,%eax
  80101a:	75 14                	jne    801030 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  80101c:	83 ec 04             	sub    $0x4,%esp
  80101f:	68 d8 35 80 00       	push   $0x8035d8
  801024:	6a 21                	push   $0x21
  801026:	68 26 34 80 00       	push   $0x803426
  80102b:	e8 0c 03 00 00       	call   80133c <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801030:	83 ec 08             	sub    $0x8,%esp
  801033:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801036:	50                   	push   %eax
  801037:	68 94 34 80 00       	push   $0x803494
  80103c:	e8 8d f8 ff ff       	call   8008ce <file_open>
  801041:	83 c4 10             	add    $0x10,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	79 12                	jns    80105a <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  801048:	50                   	push   %eax
  801049:	68 9d 34 80 00       	push   $0x80349d
  80104e:	6a 23                	push   $0x23
  801050:	68 26 34 80 00       	push   $0x803426
  801055:	e8 e2 02 00 00       	call   80133c <_panic>
	cprintf("file_open is good\n");
  80105a:	83 ec 0c             	sub    $0xc,%esp
  80105d:	68 b4 34 80 00       	push   $0x8034b4
  801062:	e8 ae 03 00 00       	call   801415 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801067:	83 c4 0c             	add    $0xc,%esp
  80106a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106d:	50                   	push   %eax
  80106e:	6a 00                	push   $0x0
  801070:	ff 75 f4             	pushl  -0xc(%ebp)
  801073:	e8 76 f7 ff ff       	call   8007ee <file_get_block>
  801078:	83 c4 10             	add    $0x10,%esp
  80107b:	85 c0                	test   %eax,%eax
  80107d:	79 12                	jns    801091 <fs_test+0x180>
		panic("file_get_block: %e", r);
  80107f:	50                   	push   %eax
  801080:	68 c7 34 80 00       	push   $0x8034c7
  801085:	6a 27                	push   $0x27
  801087:	68 26 34 80 00       	push   $0x803426
  80108c:	e8 ab 02 00 00       	call   80133c <_panic>
	if (strcmp(blk, msg) != 0)
  801091:	83 ec 08             	sub    $0x8,%esp
  801094:	68 f8 35 80 00       	push   $0x8035f8
  801099:	ff 75 f0             	pushl  -0x10(%ebp)
  80109c:	e8 a3 09 00 00       	call   801a44 <strcmp>
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	74 14                	je     8010bc <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8010a8:	83 ec 04             	sub    $0x4,%esp
  8010ab:	68 20 36 80 00       	push   $0x803620
  8010b0:	6a 29                	push   $0x29
  8010b2:	68 26 34 80 00       	push   $0x803426
  8010b7:	e8 80 02 00 00       	call   80133c <_panic>
	cprintf("file_get_block is good\n");
  8010bc:	83 ec 0c             	sub    $0xc,%esp
  8010bf:	68 da 34 80 00       	push   $0x8034da
  8010c4:	e8 4c 03 00 00       	call   801415 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  8010c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cc:	0f b6 10             	movzbl (%eax),%edx
  8010cf:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8010d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d4:	c1 e8 0c             	shr    $0xc,%eax
  8010d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	a8 40                	test   $0x40,%al
  8010e3:	75 16                	jne    8010fb <fs_test+0x1ea>
  8010e5:	68 f3 34 80 00       	push   $0x8034f3
  8010ea:	68 3d 31 80 00       	push   $0x80313d
  8010ef:	6a 2d                	push   $0x2d
  8010f1:	68 26 34 80 00       	push   $0x803426
  8010f6:	e8 41 02 00 00       	call   80133c <_panic>
	file_flush(f);
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801101:	e8 0e f9 ff ff       	call   800a14 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801106:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801109:	c1 e8 0c             	shr    $0xc,%eax
  80110c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	a8 40                	test   $0x40,%al
  801118:	74 16                	je     801130 <fs_test+0x21f>
  80111a:	68 f2 34 80 00       	push   $0x8034f2
  80111f:	68 3d 31 80 00       	push   $0x80313d
  801124:	6a 2f                	push   $0x2f
  801126:	68 26 34 80 00       	push   $0x803426
  80112b:	e8 0c 02 00 00       	call   80133c <_panic>
	cprintf("file_flush is good\n");
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	68 0e 35 80 00       	push   $0x80350e
  801138:	e8 d8 02 00 00       	call   801415 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  80113d:	83 c4 08             	add    $0x8,%esp
  801140:	6a 00                	push   $0x0
  801142:	ff 75 f4             	pushl  -0xc(%ebp)
  801145:	e8 e2 f7 ff ff       	call   80092c <file_set_size>
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	85 c0                	test   %eax,%eax
  80114f:	79 12                	jns    801163 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801151:	50                   	push   %eax
  801152:	68 22 35 80 00       	push   $0x803522
  801157:	6a 33                	push   $0x33
  801159:	68 26 34 80 00       	push   $0x803426
  80115e:	e8 d9 01 00 00       	call   80133c <_panic>
	assert(f->f_direct[0] == 0);
  801163:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801166:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  80116d:	74 16                	je     801185 <fs_test+0x274>
  80116f:	68 34 35 80 00       	push   $0x803534
  801174:	68 3d 31 80 00       	push   $0x80313d
  801179:	6a 34                	push   $0x34
  80117b:	68 26 34 80 00       	push   $0x803426
  801180:	e8 b7 01 00 00       	call   80133c <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801185:	c1 e8 0c             	shr    $0xc,%eax
  801188:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80118f:	a8 40                	test   $0x40,%al
  801191:	74 16                	je     8011a9 <fs_test+0x298>
  801193:	68 48 35 80 00       	push   $0x803548
  801198:	68 3d 31 80 00       	push   $0x80313d
  80119d:	6a 35                	push   $0x35
  80119f:	68 26 34 80 00       	push   $0x803426
  8011a4:	e8 93 01 00 00       	call   80133c <_panic>
	cprintf("file_truncate is good\n");
  8011a9:	83 ec 0c             	sub    $0xc,%esp
  8011ac:	68 62 35 80 00       	push   $0x803562
  8011b1:	e8 5f 02 00 00       	call   801415 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8011b6:	c7 04 24 f8 35 80 00 	movl   $0x8035f8,(%esp)
  8011bd:	e8 9f 07 00 00       	call   801961 <strlen>
  8011c2:	83 c4 08             	add    $0x8,%esp
  8011c5:	50                   	push   %eax
  8011c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8011c9:	e8 5e f7 ff ff       	call   80092c <file_set_size>
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	79 12                	jns    8011e7 <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  8011d5:	50                   	push   %eax
  8011d6:	68 79 35 80 00       	push   $0x803579
  8011db:	6a 39                	push   $0x39
  8011dd:	68 26 34 80 00       	push   $0x803426
  8011e2:	e8 55 01 00 00       	call   80133c <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8011e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	c1 ea 0c             	shr    $0xc,%edx
  8011ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f6:	f6 c2 40             	test   $0x40,%dl
  8011f9:	74 16                	je     801211 <fs_test+0x300>
  8011fb:	68 48 35 80 00       	push   $0x803548
  801200:	68 3d 31 80 00       	push   $0x80313d
  801205:	6a 3a                	push   $0x3a
  801207:	68 26 34 80 00       	push   $0x803426
  80120c:	e8 2b 01 00 00       	call   80133c <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801211:	83 ec 04             	sub    $0x4,%esp
  801214:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801217:	52                   	push   %edx
  801218:	6a 00                	push   $0x0
  80121a:	50                   	push   %eax
  80121b:	e8 ce f5 ff ff       	call   8007ee <file_get_block>
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	79 12                	jns    801239 <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  801227:	50                   	push   %eax
  801228:	68 8d 35 80 00       	push   $0x80358d
  80122d:	6a 3c                	push   $0x3c
  80122f:	68 26 34 80 00       	push   $0x803426
  801234:	e8 03 01 00 00       	call   80133c <_panic>
	strcpy(blk, msg);
  801239:	83 ec 08             	sub    $0x8,%esp
  80123c:	68 f8 35 80 00       	push   $0x8035f8
  801241:	ff 75 f0             	pushl  -0x10(%ebp)
  801244:	e8 51 07 00 00       	call   80199a <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801249:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124c:	c1 e8 0c             	shr    $0xc,%eax
  80124f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	a8 40                	test   $0x40,%al
  80125b:	75 16                	jne    801273 <fs_test+0x362>
  80125d:	68 f3 34 80 00       	push   $0x8034f3
  801262:	68 3d 31 80 00       	push   $0x80313d
  801267:	6a 3e                	push   $0x3e
  801269:	68 26 34 80 00       	push   $0x803426
  80126e:	e8 c9 00 00 00       	call   80133c <_panic>
	file_flush(f);
  801273:	83 ec 0c             	sub    $0xc,%esp
  801276:	ff 75 f4             	pushl  -0xc(%ebp)
  801279:	e8 96 f7 ff ff       	call   800a14 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	c1 e8 0c             	shr    $0xc,%eax
  801284:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	a8 40                	test   $0x40,%al
  801290:	74 16                	je     8012a8 <fs_test+0x397>
  801292:	68 f2 34 80 00       	push   $0x8034f2
  801297:	68 3d 31 80 00       	push   $0x80313d
  80129c:	6a 40                	push   $0x40
  80129e:	68 26 34 80 00       	push   $0x803426
  8012a3:	e8 94 00 00 00       	call   80133c <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8012a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ab:	c1 e8 0c             	shr    $0xc,%eax
  8012ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b5:	a8 40                	test   $0x40,%al
  8012b7:	74 16                	je     8012cf <fs_test+0x3be>
  8012b9:	68 48 35 80 00       	push   $0x803548
  8012be:	68 3d 31 80 00       	push   $0x80313d
  8012c3:	6a 41                	push   $0x41
  8012c5:	68 26 34 80 00       	push   $0x803426
  8012ca:	e8 6d 00 00 00       	call   80133c <_panic>
	cprintf("file rewrite is good\n");
  8012cf:	83 ec 0c             	sub    $0xc,%esp
  8012d2:	68 a2 35 80 00       	push   $0x8035a2
  8012d7:	e8 39 01 00 00       	call   801415 <cprintf>
}
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e2:	c9                   	leave  
  8012e3:	c3                   	ret    

008012e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	56                   	push   %esi
  8012e8:	53                   	push   %ebx
  8012e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  8012ef:	e8 6b 0a 00 00       	call   801d5f <sys_getenvid>
  8012f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801301:	a3 0c 90 80 00       	mov    %eax,0x80900c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801306:	85 db                	test   %ebx,%ebx
  801308:	7e 07                	jle    801311 <libmain+0x2d>
		binaryname = argv[0];
  80130a:	8b 06                	mov    (%esi),%eax
  80130c:	a3 60 80 80 00       	mov    %eax,0x808060

	// call user main routine
	umain(argc, argv);
  801311:	83 ec 08             	sub    $0x8,%esp
  801314:	56                   	push   %esi
  801315:	53                   	push   %ebx
  801316:	e8 b0 fb ff ff       	call   800ecb <umain>

	// exit gracefully
	exit();
  80131b:	e8 0a 00 00 00       	call   80132a <exit>
}
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801326:	5b                   	pop    %ebx
  801327:	5e                   	pop    %esi
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  801330:	6a 00                	push   $0x0
  801332:	e8 e7 09 00 00       	call   801d1e <sys_env_destroy>
}
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    

0080133c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	56                   	push   %esi
  801340:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801341:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801344:	8b 35 60 80 80 00    	mov    0x808060,%esi
  80134a:	e8 10 0a 00 00       	call   801d5f <sys_getenvid>
  80134f:	83 ec 0c             	sub    $0xc,%esp
  801352:	ff 75 0c             	pushl  0xc(%ebp)
  801355:	ff 75 08             	pushl  0x8(%ebp)
  801358:	56                   	push   %esi
  801359:	50                   	push   %eax
  80135a:	68 50 36 80 00       	push   $0x803650
  80135f:	e8 b1 00 00 00       	call   801415 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801364:	83 c4 18             	add    $0x18,%esp
  801367:	53                   	push   %ebx
  801368:	ff 75 10             	pushl  0x10(%ebp)
  80136b:	e8 54 00 00 00       	call   8013c4 <vcprintf>
	cprintf("\n");
  801370:	c7 04 24 47 32 80 00 	movl   $0x803247,(%esp)
  801377:	e8 99 00 00 00       	call   801415 <cprintf>
  80137c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80137f:	cc                   	int3   
  801380:	eb fd                	jmp    80137f <_panic+0x43>

00801382 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	53                   	push   %ebx
  801386:	83 ec 04             	sub    $0x4,%esp
  801389:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80138c:	8b 13                	mov    (%ebx),%edx
  80138e:	8d 42 01             	lea    0x1(%edx),%eax
  801391:	89 03                	mov    %eax,(%ebx)
  801393:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801396:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80139a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80139f:	75 1a                	jne    8013bb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8013a1:	83 ec 08             	sub    $0x8,%esp
  8013a4:	68 ff 00 00 00       	push   $0xff
  8013a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8013ac:	50                   	push   %eax
  8013ad:	e8 2f 09 00 00       	call   801ce1 <sys_cputs>
		b->idx = 0;
  8013b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8013bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8013bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c2:	c9                   	leave  
  8013c3:	c3                   	ret    

008013c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8013cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8013d4:	00 00 00 
	b.cnt = 0;
  8013d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8013de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8013e1:	ff 75 0c             	pushl  0xc(%ebp)
  8013e4:	ff 75 08             	pushl  0x8(%ebp)
  8013e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8013ed:	50                   	push   %eax
  8013ee:	68 82 13 80 00       	push   $0x801382
  8013f3:	e8 54 01 00 00       	call   80154c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8013f8:	83 c4 08             	add    $0x8,%esp
  8013fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801401:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801407:	50                   	push   %eax
  801408:	e8 d4 08 00 00       	call   801ce1 <sys_cputs>

	return b.cnt;
}
  80140d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801413:	c9                   	leave  
  801414:	c3                   	ret    

00801415 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80141b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80141e:	50                   	push   %eax
  80141f:	ff 75 08             	pushl  0x8(%ebp)
  801422:	e8 9d ff ff ff       	call   8013c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	57                   	push   %edi
  80142d:	56                   	push   %esi
  80142e:	53                   	push   %ebx
  80142f:	83 ec 1c             	sub    $0x1c,%esp
  801432:	89 c7                	mov    %eax,%edi
  801434:	89 d6                	mov    %edx,%esi
  801436:	8b 45 08             	mov    0x8(%ebp),%eax
  801439:	8b 55 0c             	mov    0xc(%ebp),%edx
  80143c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80143f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801442:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801445:	bb 00 00 00 00       	mov    $0x0,%ebx
  80144a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80144d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801450:	39 d3                	cmp    %edx,%ebx
  801452:	72 05                	jb     801459 <printnum+0x30>
  801454:	39 45 10             	cmp    %eax,0x10(%ebp)
  801457:	77 45                	ja     80149e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801459:	83 ec 0c             	sub    $0xc,%esp
  80145c:	ff 75 18             	pushl  0x18(%ebp)
  80145f:	8b 45 14             	mov    0x14(%ebp),%eax
  801462:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801465:	53                   	push   %ebx
  801466:	ff 75 10             	pushl  0x10(%ebp)
  801469:	83 ec 08             	sub    $0x8,%esp
  80146c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80146f:	ff 75 e0             	pushl  -0x20(%ebp)
  801472:	ff 75 dc             	pushl  -0x24(%ebp)
  801475:	ff 75 d8             	pushl  -0x28(%ebp)
  801478:	e8 f3 19 00 00       	call   802e70 <__udivdi3>
  80147d:	83 c4 18             	add    $0x18,%esp
  801480:	52                   	push   %edx
  801481:	50                   	push   %eax
  801482:	89 f2                	mov    %esi,%edx
  801484:	89 f8                	mov    %edi,%eax
  801486:	e8 9e ff ff ff       	call   801429 <printnum>
  80148b:	83 c4 20             	add    $0x20,%esp
  80148e:	eb 18                	jmp    8014a8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801490:	83 ec 08             	sub    $0x8,%esp
  801493:	56                   	push   %esi
  801494:	ff 75 18             	pushl  0x18(%ebp)
  801497:	ff d7                	call   *%edi
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	eb 03                	jmp    8014a1 <printnum+0x78>
  80149e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014a1:	83 eb 01             	sub    $0x1,%ebx
  8014a4:	85 db                	test   %ebx,%ebx
  8014a6:	7f e8                	jg     801490 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	56                   	push   %esi
  8014ac:	83 ec 04             	sub    $0x4,%esp
  8014af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8014b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8014b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8014bb:	e8 e0 1a 00 00       	call   802fa0 <__umoddi3>
  8014c0:	83 c4 14             	add    $0x14,%esp
  8014c3:	0f be 80 73 36 80 00 	movsbl 0x803673(%eax),%eax
  8014ca:	50                   	push   %eax
  8014cb:	ff d7                	call   *%edi
}
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d3:	5b                   	pop    %ebx
  8014d4:	5e                   	pop    %esi
  8014d5:	5f                   	pop    %edi
  8014d6:	5d                   	pop    %ebp
  8014d7:	c3                   	ret    

008014d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8014db:	83 fa 01             	cmp    $0x1,%edx
  8014de:	7e 0e                	jle    8014ee <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8014e0:	8b 10                	mov    (%eax),%edx
  8014e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8014e5:	89 08                	mov    %ecx,(%eax)
  8014e7:	8b 02                	mov    (%edx),%eax
  8014e9:	8b 52 04             	mov    0x4(%edx),%edx
  8014ec:	eb 22                	jmp    801510 <getuint+0x38>
	else if (lflag)
  8014ee:	85 d2                	test   %edx,%edx
  8014f0:	74 10                	je     801502 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8014f2:	8b 10                	mov    (%eax),%edx
  8014f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8014f7:	89 08                	mov    %ecx,(%eax)
  8014f9:	8b 02                	mov    (%edx),%eax
  8014fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801500:	eb 0e                	jmp    801510 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801502:	8b 10                	mov    (%eax),%edx
  801504:	8d 4a 04             	lea    0x4(%edx),%ecx
  801507:	89 08                	mov    %ecx,(%eax)
  801509:	8b 02                	mov    (%edx),%eax
  80150b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801510:	5d                   	pop    %ebp
  801511:	c3                   	ret    

00801512 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801518:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80151c:	8b 10                	mov    (%eax),%edx
  80151e:	3b 50 04             	cmp    0x4(%eax),%edx
  801521:	73 0a                	jae    80152d <sprintputch+0x1b>
		*b->buf++ = ch;
  801523:	8d 4a 01             	lea    0x1(%edx),%ecx
  801526:	89 08                	mov    %ecx,(%eax)
  801528:	8b 45 08             	mov    0x8(%ebp),%eax
  80152b:	88 02                	mov    %al,(%edx)
}
  80152d:	5d                   	pop    %ebp
  80152e:	c3                   	ret    

0080152f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801535:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801538:	50                   	push   %eax
  801539:	ff 75 10             	pushl  0x10(%ebp)
  80153c:	ff 75 0c             	pushl  0xc(%ebp)
  80153f:	ff 75 08             	pushl  0x8(%ebp)
  801542:	e8 05 00 00 00       	call   80154c <vprintfmt>
	va_end(ap);
}
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	c9                   	leave  
  80154b:	c3                   	ret    

0080154c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	57                   	push   %edi
  801550:	56                   	push   %esi
  801551:	53                   	push   %ebx
  801552:	83 ec 2c             	sub    $0x2c,%esp
  801555:	8b 75 08             	mov    0x8(%ebp),%esi
  801558:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80155b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80155e:	eb 12                	jmp    801572 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801560:	85 c0                	test   %eax,%eax
  801562:	0f 84 89 03 00 00    	je     8018f1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801568:	83 ec 08             	sub    $0x8,%esp
  80156b:	53                   	push   %ebx
  80156c:	50                   	push   %eax
  80156d:	ff d6                	call   *%esi
  80156f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801572:	83 c7 01             	add    $0x1,%edi
  801575:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801579:	83 f8 25             	cmp    $0x25,%eax
  80157c:	75 e2                	jne    801560 <vprintfmt+0x14>
  80157e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801582:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801589:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801590:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801597:	ba 00 00 00 00       	mov    $0x0,%edx
  80159c:	eb 07                	jmp    8015a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80159e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8015a1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a5:	8d 47 01             	lea    0x1(%edi),%eax
  8015a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015ab:	0f b6 07             	movzbl (%edi),%eax
  8015ae:	0f b6 c8             	movzbl %al,%ecx
  8015b1:	83 e8 23             	sub    $0x23,%eax
  8015b4:	3c 55                	cmp    $0x55,%al
  8015b6:	0f 87 1a 03 00 00    	ja     8018d6 <vprintfmt+0x38a>
  8015bc:	0f b6 c0             	movzbl %al,%eax
  8015bf:	ff 24 85 c0 37 80 00 	jmp    *0x8037c0(,%eax,4)
  8015c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8015c9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8015cd:	eb d6                	jmp    8015a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8015da:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8015dd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8015e1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8015e4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8015e7:	83 fa 09             	cmp    $0x9,%edx
  8015ea:	77 39                	ja     801625 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8015ec:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8015ef:	eb e9                	jmp    8015da <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8015f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f4:	8d 48 04             	lea    0x4(%eax),%ecx
  8015f7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015fa:	8b 00                	mov    (%eax),%eax
  8015fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801602:	eb 27                	jmp    80162b <vprintfmt+0xdf>
  801604:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801607:	85 c0                	test   %eax,%eax
  801609:	b9 00 00 00 00       	mov    $0x0,%ecx
  80160e:	0f 49 c8             	cmovns %eax,%ecx
  801611:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801614:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801617:	eb 8c                	jmp    8015a5 <vprintfmt+0x59>
  801619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80161c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801623:	eb 80                	jmp    8015a5 <vprintfmt+0x59>
  801625:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801628:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80162b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80162f:	0f 89 70 ff ff ff    	jns    8015a5 <vprintfmt+0x59>
				width = precision, precision = -1;
  801635:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801638:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80163b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801642:	e9 5e ff ff ff       	jmp    8015a5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801647:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80164d:	e9 53 ff ff ff       	jmp    8015a5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801652:	8b 45 14             	mov    0x14(%ebp),%eax
  801655:	8d 50 04             	lea    0x4(%eax),%edx
  801658:	89 55 14             	mov    %edx,0x14(%ebp)
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	53                   	push   %ebx
  80165f:	ff 30                	pushl  (%eax)
  801661:	ff d6                	call   *%esi
			break;
  801663:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801669:	e9 04 ff ff ff       	jmp    801572 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80166e:	8b 45 14             	mov    0x14(%ebp),%eax
  801671:	8d 50 04             	lea    0x4(%eax),%edx
  801674:	89 55 14             	mov    %edx,0x14(%ebp)
  801677:	8b 00                	mov    (%eax),%eax
  801679:	99                   	cltd   
  80167a:	31 d0                	xor    %edx,%eax
  80167c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80167e:	83 f8 0f             	cmp    $0xf,%eax
  801681:	7f 0b                	jg     80168e <vprintfmt+0x142>
  801683:	8b 14 85 20 39 80 00 	mov    0x803920(,%eax,4),%edx
  80168a:	85 d2                	test   %edx,%edx
  80168c:	75 18                	jne    8016a6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80168e:	50                   	push   %eax
  80168f:	68 8b 36 80 00       	push   $0x80368b
  801694:	53                   	push   %ebx
  801695:	56                   	push   %esi
  801696:	e8 94 fe ff ff       	call   80152f <printfmt>
  80169b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80169e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8016a1:	e9 cc fe ff ff       	jmp    801572 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8016a6:	52                   	push   %edx
  8016a7:	68 4f 31 80 00       	push   $0x80314f
  8016ac:	53                   	push   %ebx
  8016ad:	56                   	push   %esi
  8016ae:	e8 7c fe ff ff       	call   80152f <printfmt>
  8016b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016b9:	e9 b4 fe ff ff       	jmp    801572 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8016be:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c1:	8d 50 04             	lea    0x4(%eax),%edx
  8016c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8016c7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8016c9:	85 ff                	test   %edi,%edi
  8016cb:	b8 84 36 80 00       	mov    $0x803684,%eax
  8016d0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8016d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016d7:	0f 8e 94 00 00 00    	jle    801771 <vprintfmt+0x225>
  8016dd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8016e1:	0f 84 98 00 00 00    	je     80177f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8016e7:	83 ec 08             	sub    $0x8,%esp
  8016ea:	ff 75 d0             	pushl  -0x30(%ebp)
  8016ed:	57                   	push   %edi
  8016ee:	e8 86 02 00 00       	call   801979 <strnlen>
  8016f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8016f6:	29 c1                	sub    %eax,%ecx
  8016f8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8016fb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8016fe:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801702:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801705:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801708:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80170a:	eb 0f                	jmp    80171b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80170c:	83 ec 08             	sub    $0x8,%esp
  80170f:	53                   	push   %ebx
  801710:	ff 75 e0             	pushl  -0x20(%ebp)
  801713:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801715:	83 ef 01             	sub    $0x1,%edi
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	85 ff                	test   %edi,%edi
  80171d:	7f ed                	jg     80170c <vprintfmt+0x1c0>
  80171f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801722:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801725:	85 c9                	test   %ecx,%ecx
  801727:	b8 00 00 00 00       	mov    $0x0,%eax
  80172c:	0f 49 c1             	cmovns %ecx,%eax
  80172f:	29 c1                	sub    %eax,%ecx
  801731:	89 75 08             	mov    %esi,0x8(%ebp)
  801734:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801737:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80173a:	89 cb                	mov    %ecx,%ebx
  80173c:	eb 4d                	jmp    80178b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80173e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801742:	74 1b                	je     80175f <vprintfmt+0x213>
  801744:	0f be c0             	movsbl %al,%eax
  801747:	83 e8 20             	sub    $0x20,%eax
  80174a:	83 f8 5e             	cmp    $0x5e,%eax
  80174d:	76 10                	jbe    80175f <vprintfmt+0x213>
					putch('?', putdat);
  80174f:	83 ec 08             	sub    $0x8,%esp
  801752:	ff 75 0c             	pushl  0xc(%ebp)
  801755:	6a 3f                	push   $0x3f
  801757:	ff 55 08             	call   *0x8(%ebp)
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	eb 0d                	jmp    80176c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80175f:	83 ec 08             	sub    $0x8,%esp
  801762:	ff 75 0c             	pushl  0xc(%ebp)
  801765:	52                   	push   %edx
  801766:	ff 55 08             	call   *0x8(%ebp)
  801769:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80176c:	83 eb 01             	sub    $0x1,%ebx
  80176f:	eb 1a                	jmp    80178b <vprintfmt+0x23f>
  801771:	89 75 08             	mov    %esi,0x8(%ebp)
  801774:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801777:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80177a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80177d:	eb 0c                	jmp    80178b <vprintfmt+0x23f>
  80177f:	89 75 08             	mov    %esi,0x8(%ebp)
  801782:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801785:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801788:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80178b:	83 c7 01             	add    $0x1,%edi
  80178e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801792:	0f be d0             	movsbl %al,%edx
  801795:	85 d2                	test   %edx,%edx
  801797:	74 23                	je     8017bc <vprintfmt+0x270>
  801799:	85 f6                	test   %esi,%esi
  80179b:	78 a1                	js     80173e <vprintfmt+0x1f2>
  80179d:	83 ee 01             	sub    $0x1,%esi
  8017a0:	79 9c                	jns    80173e <vprintfmt+0x1f2>
  8017a2:	89 df                	mov    %ebx,%edi
  8017a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8017a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017aa:	eb 18                	jmp    8017c4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8017ac:	83 ec 08             	sub    $0x8,%esp
  8017af:	53                   	push   %ebx
  8017b0:	6a 20                	push   $0x20
  8017b2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8017b4:	83 ef 01             	sub    $0x1,%edi
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	eb 08                	jmp    8017c4 <vprintfmt+0x278>
  8017bc:	89 df                	mov    %ebx,%edi
  8017be:	8b 75 08             	mov    0x8(%ebp),%esi
  8017c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017c4:	85 ff                	test   %edi,%edi
  8017c6:	7f e4                	jg     8017ac <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017cb:	e9 a2 fd ff ff       	jmp    801572 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8017d0:	83 fa 01             	cmp    $0x1,%edx
  8017d3:	7e 16                	jle    8017eb <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8017d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d8:	8d 50 08             	lea    0x8(%eax),%edx
  8017db:	89 55 14             	mov    %edx,0x14(%ebp)
  8017de:	8b 50 04             	mov    0x4(%eax),%edx
  8017e1:	8b 00                	mov    (%eax),%eax
  8017e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8017e9:	eb 32                	jmp    80181d <vprintfmt+0x2d1>
	else if (lflag)
  8017eb:	85 d2                	test   %edx,%edx
  8017ed:	74 18                	je     801807 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8017ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f2:	8d 50 04             	lea    0x4(%eax),%edx
  8017f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8017f8:	8b 00                	mov    (%eax),%eax
  8017fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017fd:	89 c1                	mov    %eax,%ecx
  8017ff:	c1 f9 1f             	sar    $0x1f,%ecx
  801802:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801805:	eb 16                	jmp    80181d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801807:	8b 45 14             	mov    0x14(%ebp),%eax
  80180a:	8d 50 04             	lea    0x4(%eax),%edx
  80180d:	89 55 14             	mov    %edx,0x14(%ebp)
  801810:	8b 00                	mov    (%eax),%eax
  801812:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801815:	89 c1                	mov    %eax,%ecx
  801817:	c1 f9 1f             	sar    $0x1f,%ecx
  80181a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80181d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801820:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801823:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801828:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80182c:	79 74                	jns    8018a2 <vprintfmt+0x356>
				putch('-', putdat);
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	53                   	push   %ebx
  801832:	6a 2d                	push   $0x2d
  801834:	ff d6                	call   *%esi
				num = -(long long) num;
  801836:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801839:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80183c:	f7 d8                	neg    %eax
  80183e:	83 d2 00             	adc    $0x0,%edx
  801841:	f7 da                	neg    %edx
  801843:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801846:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80184b:	eb 55                	jmp    8018a2 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80184d:	8d 45 14             	lea    0x14(%ebp),%eax
  801850:	e8 83 fc ff ff       	call   8014d8 <getuint>
			base = 10;
  801855:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80185a:	eb 46                	jmp    8018a2 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80185c:	8d 45 14             	lea    0x14(%ebp),%eax
  80185f:	e8 74 fc ff ff       	call   8014d8 <getuint>
			base = 8;
  801864:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801869:	eb 37                	jmp    8018a2 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  80186b:	83 ec 08             	sub    $0x8,%esp
  80186e:	53                   	push   %ebx
  80186f:	6a 30                	push   $0x30
  801871:	ff d6                	call   *%esi
			putch('x', putdat);
  801873:	83 c4 08             	add    $0x8,%esp
  801876:	53                   	push   %ebx
  801877:	6a 78                	push   $0x78
  801879:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80187b:	8b 45 14             	mov    0x14(%ebp),%eax
  80187e:	8d 50 04             	lea    0x4(%eax),%edx
  801881:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801884:	8b 00                	mov    (%eax),%eax
  801886:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80188b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80188e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801893:	eb 0d                	jmp    8018a2 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801895:	8d 45 14             	lea    0x14(%ebp),%eax
  801898:	e8 3b fc ff ff       	call   8014d8 <getuint>
			base = 16;
  80189d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8018a2:	83 ec 0c             	sub    $0xc,%esp
  8018a5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8018a9:	57                   	push   %edi
  8018aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8018ad:	51                   	push   %ecx
  8018ae:	52                   	push   %edx
  8018af:	50                   	push   %eax
  8018b0:	89 da                	mov    %ebx,%edx
  8018b2:	89 f0                	mov    %esi,%eax
  8018b4:	e8 70 fb ff ff       	call   801429 <printnum>
			break;
  8018b9:	83 c4 20             	add    $0x20,%esp
  8018bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018bf:	e9 ae fc ff ff       	jmp    801572 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8018c4:	83 ec 08             	sub    $0x8,%esp
  8018c7:	53                   	push   %ebx
  8018c8:	51                   	push   %ecx
  8018c9:	ff d6                	call   *%esi
			break;
  8018cb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8018d1:	e9 9c fc ff ff       	jmp    801572 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8018d6:	83 ec 08             	sub    $0x8,%esp
  8018d9:	53                   	push   %ebx
  8018da:	6a 25                	push   $0x25
  8018dc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8018de:	83 c4 10             	add    $0x10,%esp
  8018e1:	eb 03                	jmp    8018e6 <vprintfmt+0x39a>
  8018e3:	83 ef 01             	sub    $0x1,%edi
  8018e6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8018ea:	75 f7                	jne    8018e3 <vprintfmt+0x397>
  8018ec:	e9 81 fc ff ff       	jmp    801572 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8018f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5e                   	pop    %esi
  8018f6:	5f                   	pop    %edi
  8018f7:	5d                   	pop    %ebp
  8018f8:	c3                   	ret    

008018f9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	83 ec 18             	sub    $0x18,%esp
  8018ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801902:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801905:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801908:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80190c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80190f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801916:	85 c0                	test   %eax,%eax
  801918:	74 26                	je     801940 <vsnprintf+0x47>
  80191a:	85 d2                	test   %edx,%edx
  80191c:	7e 22                	jle    801940 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80191e:	ff 75 14             	pushl  0x14(%ebp)
  801921:	ff 75 10             	pushl  0x10(%ebp)
  801924:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801927:	50                   	push   %eax
  801928:	68 12 15 80 00       	push   $0x801512
  80192d:	e8 1a fc ff ff       	call   80154c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801932:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801935:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801938:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	eb 05                	jmp    801945 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801940:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801945:	c9                   	leave  
  801946:	c3                   	ret    

00801947 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80194d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801950:	50                   	push   %eax
  801951:	ff 75 10             	pushl  0x10(%ebp)
  801954:	ff 75 0c             	pushl  0xc(%ebp)
  801957:	ff 75 08             	pushl  0x8(%ebp)
  80195a:	e8 9a ff ff ff       	call   8018f9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80195f:	c9                   	leave  
  801960:	c3                   	ret    

00801961 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801967:	b8 00 00 00 00       	mov    $0x0,%eax
  80196c:	eb 03                	jmp    801971 <strlen+0x10>
		n++;
  80196e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801971:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801975:	75 f7                	jne    80196e <strlen+0xd>
		n++;
	return n;
}
  801977:	5d                   	pop    %ebp
  801978:	c3                   	ret    

00801979 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80197f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801982:	ba 00 00 00 00       	mov    $0x0,%edx
  801987:	eb 03                	jmp    80198c <strnlen+0x13>
		n++;
  801989:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80198c:	39 c2                	cmp    %eax,%edx
  80198e:	74 08                	je     801998 <strnlen+0x1f>
  801990:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801994:	75 f3                	jne    801989 <strnlen+0x10>
  801996:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    

0080199a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	53                   	push   %ebx
  80199e:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8019a4:	89 c2                	mov    %eax,%edx
  8019a6:	83 c2 01             	add    $0x1,%edx
  8019a9:	83 c1 01             	add    $0x1,%ecx
  8019ac:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8019b0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8019b3:	84 db                	test   %bl,%bl
  8019b5:	75 ef                	jne    8019a6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8019b7:	5b                   	pop    %ebx
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	53                   	push   %ebx
  8019be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8019c1:	53                   	push   %ebx
  8019c2:	e8 9a ff ff ff       	call   801961 <strlen>
  8019c7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8019ca:	ff 75 0c             	pushl  0xc(%ebp)
  8019cd:	01 d8                	add    %ebx,%eax
  8019cf:	50                   	push   %eax
  8019d0:	e8 c5 ff ff ff       	call   80199a <strcpy>
	return dst;
}
  8019d5:	89 d8                	mov    %ebx,%eax
  8019d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019da:	c9                   	leave  
  8019db:	c3                   	ret    

008019dc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	56                   	push   %esi
  8019e0:	53                   	push   %ebx
  8019e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e7:	89 f3                	mov    %esi,%ebx
  8019e9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8019ec:	89 f2                	mov    %esi,%edx
  8019ee:	eb 0f                	jmp    8019ff <strncpy+0x23>
		*dst++ = *src;
  8019f0:	83 c2 01             	add    $0x1,%edx
  8019f3:	0f b6 01             	movzbl (%ecx),%eax
  8019f6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8019f9:	80 39 01             	cmpb   $0x1,(%ecx)
  8019fc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8019ff:	39 da                	cmp    %ebx,%edx
  801a01:	75 ed                	jne    8019f0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a03:	89 f0                	mov    %esi,%eax
  801a05:	5b                   	pop    %ebx
  801a06:	5e                   	pop    %esi
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    

00801a09 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	56                   	push   %esi
  801a0d:	53                   	push   %ebx
  801a0e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a14:	8b 55 10             	mov    0x10(%ebp),%edx
  801a17:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a19:	85 d2                	test   %edx,%edx
  801a1b:	74 21                	je     801a3e <strlcpy+0x35>
  801a1d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a21:	89 f2                	mov    %esi,%edx
  801a23:	eb 09                	jmp    801a2e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a25:	83 c2 01             	add    $0x1,%edx
  801a28:	83 c1 01             	add    $0x1,%ecx
  801a2b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a2e:	39 c2                	cmp    %eax,%edx
  801a30:	74 09                	je     801a3b <strlcpy+0x32>
  801a32:	0f b6 19             	movzbl (%ecx),%ebx
  801a35:	84 db                	test   %bl,%bl
  801a37:	75 ec                	jne    801a25 <strlcpy+0x1c>
  801a39:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a3b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801a3e:	29 f0                	sub    %esi,%eax
}
  801a40:	5b                   	pop    %ebx
  801a41:	5e                   	pop    %esi
  801a42:	5d                   	pop    %ebp
  801a43:	c3                   	ret    

00801a44 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a4a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801a4d:	eb 06                	jmp    801a55 <strcmp+0x11>
		p++, q++;
  801a4f:	83 c1 01             	add    $0x1,%ecx
  801a52:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801a55:	0f b6 01             	movzbl (%ecx),%eax
  801a58:	84 c0                	test   %al,%al
  801a5a:	74 04                	je     801a60 <strcmp+0x1c>
  801a5c:	3a 02                	cmp    (%edx),%al
  801a5e:	74 ef                	je     801a4f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801a60:	0f b6 c0             	movzbl %al,%eax
  801a63:	0f b6 12             	movzbl (%edx),%edx
  801a66:	29 d0                	sub    %edx,%eax
}
  801a68:	5d                   	pop    %ebp
  801a69:	c3                   	ret    

00801a6a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	53                   	push   %ebx
  801a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a71:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a74:	89 c3                	mov    %eax,%ebx
  801a76:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801a79:	eb 06                	jmp    801a81 <strncmp+0x17>
		n--, p++, q++;
  801a7b:	83 c0 01             	add    $0x1,%eax
  801a7e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801a81:	39 d8                	cmp    %ebx,%eax
  801a83:	74 15                	je     801a9a <strncmp+0x30>
  801a85:	0f b6 08             	movzbl (%eax),%ecx
  801a88:	84 c9                	test   %cl,%cl
  801a8a:	74 04                	je     801a90 <strncmp+0x26>
  801a8c:	3a 0a                	cmp    (%edx),%cl
  801a8e:	74 eb                	je     801a7b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801a90:	0f b6 00             	movzbl (%eax),%eax
  801a93:	0f b6 12             	movzbl (%edx),%edx
  801a96:	29 d0                	sub    %edx,%eax
  801a98:	eb 05                	jmp    801a9f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801a9a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801a9f:	5b                   	pop    %ebx
  801aa0:	5d                   	pop    %ebp
  801aa1:	c3                   	ret    

00801aa2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801aac:	eb 07                	jmp    801ab5 <strchr+0x13>
		if (*s == c)
  801aae:	38 ca                	cmp    %cl,%dl
  801ab0:	74 0f                	je     801ac1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ab2:	83 c0 01             	add    $0x1,%eax
  801ab5:	0f b6 10             	movzbl (%eax),%edx
  801ab8:	84 d2                	test   %dl,%dl
  801aba:	75 f2                	jne    801aae <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801abc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac1:	5d                   	pop    %ebp
  801ac2:	c3                   	ret    

00801ac3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801acd:	eb 03                	jmp    801ad2 <strfind+0xf>
  801acf:	83 c0 01             	add    $0x1,%eax
  801ad2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801ad5:	38 ca                	cmp    %cl,%dl
  801ad7:	74 04                	je     801add <strfind+0x1a>
  801ad9:	84 d2                	test   %dl,%dl
  801adb:	75 f2                	jne    801acf <strfind+0xc>
			break;
	return (char *) s;
}
  801add:	5d                   	pop    %ebp
  801ade:	c3                   	ret    

00801adf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	57                   	push   %edi
  801ae3:	56                   	push   %esi
  801ae4:	53                   	push   %ebx
  801ae5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801aeb:	85 c9                	test   %ecx,%ecx
  801aed:	74 36                	je     801b25 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801aef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801af5:	75 28                	jne    801b1f <memset+0x40>
  801af7:	f6 c1 03             	test   $0x3,%cl
  801afa:	75 23                	jne    801b1f <memset+0x40>
		c &= 0xFF;
  801afc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b00:	89 d3                	mov    %edx,%ebx
  801b02:	c1 e3 08             	shl    $0x8,%ebx
  801b05:	89 d6                	mov    %edx,%esi
  801b07:	c1 e6 18             	shl    $0x18,%esi
  801b0a:	89 d0                	mov    %edx,%eax
  801b0c:	c1 e0 10             	shl    $0x10,%eax
  801b0f:	09 f0                	or     %esi,%eax
  801b11:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b13:	89 d8                	mov    %ebx,%eax
  801b15:	09 d0                	or     %edx,%eax
  801b17:	c1 e9 02             	shr    $0x2,%ecx
  801b1a:	fc                   	cld    
  801b1b:	f3 ab                	rep stos %eax,%es:(%edi)
  801b1d:	eb 06                	jmp    801b25 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b22:	fc                   	cld    
  801b23:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b25:	89 f8                	mov    %edi,%eax
  801b27:	5b                   	pop    %ebx
  801b28:	5e                   	pop    %esi
  801b29:	5f                   	pop    %edi
  801b2a:	5d                   	pop    %ebp
  801b2b:	c3                   	ret    

00801b2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	57                   	push   %edi
  801b30:	56                   	push   %esi
  801b31:	8b 45 08             	mov    0x8(%ebp),%eax
  801b34:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b3a:	39 c6                	cmp    %eax,%esi
  801b3c:	73 35                	jae    801b73 <memmove+0x47>
  801b3e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b41:	39 d0                	cmp    %edx,%eax
  801b43:	73 2e                	jae    801b73 <memmove+0x47>
		s += n;
		d += n;
  801b45:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b48:	89 d6                	mov    %edx,%esi
  801b4a:	09 fe                	or     %edi,%esi
  801b4c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801b52:	75 13                	jne    801b67 <memmove+0x3b>
  801b54:	f6 c1 03             	test   $0x3,%cl
  801b57:	75 0e                	jne    801b67 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801b59:	83 ef 04             	sub    $0x4,%edi
  801b5c:	8d 72 fc             	lea    -0x4(%edx),%esi
  801b5f:	c1 e9 02             	shr    $0x2,%ecx
  801b62:	fd                   	std    
  801b63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801b65:	eb 09                	jmp    801b70 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801b67:	83 ef 01             	sub    $0x1,%edi
  801b6a:	8d 72 ff             	lea    -0x1(%edx),%esi
  801b6d:	fd                   	std    
  801b6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801b70:	fc                   	cld    
  801b71:	eb 1d                	jmp    801b90 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b73:	89 f2                	mov    %esi,%edx
  801b75:	09 c2                	or     %eax,%edx
  801b77:	f6 c2 03             	test   $0x3,%dl
  801b7a:	75 0f                	jne    801b8b <memmove+0x5f>
  801b7c:	f6 c1 03             	test   $0x3,%cl
  801b7f:	75 0a                	jne    801b8b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801b81:	c1 e9 02             	shr    $0x2,%ecx
  801b84:	89 c7                	mov    %eax,%edi
  801b86:	fc                   	cld    
  801b87:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801b89:	eb 05                	jmp    801b90 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801b8b:	89 c7                	mov    %eax,%edi
  801b8d:	fc                   	cld    
  801b8e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801b90:	5e                   	pop    %esi
  801b91:	5f                   	pop    %edi
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    

00801b94 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801b97:	ff 75 10             	pushl  0x10(%ebp)
  801b9a:	ff 75 0c             	pushl  0xc(%ebp)
  801b9d:	ff 75 08             	pushl  0x8(%ebp)
  801ba0:	e8 87 ff ff ff       	call   801b2c <memmove>
}
  801ba5:	c9                   	leave  
  801ba6:	c3                   	ret    

00801ba7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	56                   	push   %esi
  801bab:	53                   	push   %ebx
  801bac:	8b 45 08             	mov    0x8(%ebp),%eax
  801baf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bb2:	89 c6                	mov    %eax,%esi
  801bb4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801bb7:	eb 1a                	jmp    801bd3 <memcmp+0x2c>
		if (*s1 != *s2)
  801bb9:	0f b6 08             	movzbl (%eax),%ecx
  801bbc:	0f b6 1a             	movzbl (%edx),%ebx
  801bbf:	38 d9                	cmp    %bl,%cl
  801bc1:	74 0a                	je     801bcd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801bc3:	0f b6 c1             	movzbl %cl,%eax
  801bc6:	0f b6 db             	movzbl %bl,%ebx
  801bc9:	29 d8                	sub    %ebx,%eax
  801bcb:	eb 0f                	jmp    801bdc <memcmp+0x35>
		s1++, s2++;
  801bcd:	83 c0 01             	add    $0x1,%eax
  801bd0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801bd3:	39 f0                	cmp    %esi,%eax
  801bd5:	75 e2                	jne    801bb9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801bd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bdc:	5b                   	pop    %ebx
  801bdd:	5e                   	pop    %esi
  801bde:	5d                   	pop    %ebp
  801bdf:	c3                   	ret    

00801be0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	53                   	push   %ebx
  801be4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801be7:	89 c1                	mov    %eax,%ecx
  801be9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801bec:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801bf0:	eb 0a                	jmp    801bfc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801bf2:	0f b6 10             	movzbl (%eax),%edx
  801bf5:	39 da                	cmp    %ebx,%edx
  801bf7:	74 07                	je     801c00 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801bf9:	83 c0 01             	add    $0x1,%eax
  801bfc:	39 c8                	cmp    %ecx,%eax
  801bfe:	72 f2                	jb     801bf2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c00:	5b                   	pop    %ebx
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    

00801c03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	57                   	push   %edi
  801c07:	56                   	push   %esi
  801c08:	53                   	push   %ebx
  801c09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c0f:	eb 03                	jmp    801c14 <strtol+0x11>
		s++;
  801c11:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c14:	0f b6 01             	movzbl (%ecx),%eax
  801c17:	3c 20                	cmp    $0x20,%al
  801c19:	74 f6                	je     801c11 <strtol+0xe>
  801c1b:	3c 09                	cmp    $0x9,%al
  801c1d:	74 f2                	je     801c11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c1f:	3c 2b                	cmp    $0x2b,%al
  801c21:	75 0a                	jne    801c2d <strtol+0x2a>
		s++;
  801c23:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c26:	bf 00 00 00 00       	mov    $0x0,%edi
  801c2b:	eb 11                	jmp    801c3e <strtol+0x3b>
  801c2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c32:	3c 2d                	cmp    $0x2d,%al
  801c34:	75 08                	jne    801c3e <strtol+0x3b>
		s++, neg = 1;
  801c36:	83 c1 01             	add    $0x1,%ecx
  801c39:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c3e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801c44:	75 15                	jne    801c5b <strtol+0x58>
  801c46:	80 39 30             	cmpb   $0x30,(%ecx)
  801c49:	75 10                	jne    801c5b <strtol+0x58>
  801c4b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801c4f:	75 7c                	jne    801ccd <strtol+0xca>
		s += 2, base = 16;
  801c51:	83 c1 02             	add    $0x2,%ecx
  801c54:	bb 10 00 00 00       	mov    $0x10,%ebx
  801c59:	eb 16                	jmp    801c71 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801c5b:	85 db                	test   %ebx,%ebx
  801c5d:	75 12                	jne    801c71 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801c5f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801c64:	80 39 30             	cmpb   $0x30,(%ecx)
  801c67:	75 08                	jne    801c71 <strtol+0x6e>
		s++, base = 8;
  801c69:	83 c1 01             	add    $0x1,%ecx
  801c6c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801c71:	b8 00 00 00 00       	mov    $0x0,%eax
  801c76:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801c79:	0f b6 11             	movzbl (%ecx),%edx
  801c7c:	8d 72 d0             	lea    -0x30(%edx),%esi
  801c7f:	89 f3                	mov    %esi,%ebx
  801c81:	80 fb 09             	cmp    $0x9,%bl
  801c84:	77 08                	ja     801c8e <strtol+0x8b>
			dig = *s - '0';
  801c86:	0f be d2             	movsbl %dl,%edx
  801c89:	83 ea 30             	sub    $0x30,%edx
  801c8c:	eb 22                	jmp    801cb0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801c8e:	8d 72 9f             	lea    -0x61(%edx),%esi
  801c91:	89 f3                	mov    %esi,%ebx
  801c93:	80 fb 19             	cmp    $0x19,%bl
  801c96:	77 08                	ja     801ca0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801c98:	0f be d2             	movsbl %dl,%edx
  801c9b:	83 ea 57             	sub    $0x57,%edx
  801c9e:	eb 10                	jmp    801cb0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801ca0:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ca3:	89 f3                	mov    %esi,%ebx
  801ca5:	80 fb 19             	cmp    $0x19,%bl
  801ca8:	77 16                	ja     801cc0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801caa:	0f be d2             	movsbl %dl,%edx
  801cad:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801cb0:	3b 55 10             	cmp    0x10(%ebp),%edx
  801cb3:	7d 0b                	jge    801cc0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801cb5:	83 c1 01             	add    $0x1,%ecx
  801cb8:	0f af 45 10          	imul   0x10(%ebp),%eax
  801cbc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801cbe:	eb b9                	jmp    801c79 <strtol+0x76>

	if (endptr)
  801cc0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801cc4:	74 0d                	je     801cd3 <strtol+0xd0>
		*endptr = (char *) s;
  801cc6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cc9:	89 0e                	mov    %ecx,(%esi)
  801ccb:	eb 06                	jmp    801cd3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ccd:	85 db                	test   %ebx,%ebx
  801ccf:	74 98                	je     801c69 <strtol+0x66>
  801cd1:	eb 9e                	jmp    801c71 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801cd3:	89 c2                	mov    %eax,%edx
  801cd5:	f7 da                	neg    %edx
  801cd7:	85 ff                	test   %edi,%edi
  801cd9:	0f 45 c2             	cmovne %edx,%eax
}
  801cdc:	5b                   	pop    %ebx
  801cdd:	5e                   	pop    %esi
  801cde:	5f                   	pop    %edi
  801cdf:	5d                   	pop    %ebp
  801ce0:	c3                   	ret    

00801ce1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	57                   	push   %edi
  801ce5:	56                   	push   %esi
  801ce6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801ce7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cef:	8b 55 08             	mov    0x8(%ebp),%edx
  801cf2:	89 c3                	mov    %eax,%ebx
  801cf4:	89 c7                	mov    %eax,%edi
  801cf6:	89 c6                	mov    %eax,%esi
  801cf8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801cfa:	5b                   	pop    %ebx
  801cfb:	5e                   	pop    %esi
  801cfc:	5f                   	pop    %edi
  801cfd:	5d                   	pop    %ebp
  801cfe:	c3                   	ret    

00801cff <sys_cgetc>:

int
sys_cgetc(void)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	57                   	push   %edi
  801d03:	56                   	push   %esi
  801d04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801d05:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0a:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0f:	89 d1                	mov    %edx,%ecx
  801d11:	89 d3                	mov    %edx,%ebx
  801d13:	89 d7                	mov    %edx,%edi
  801d15:	89 d6                	mov    %edx,%esi
  801d17:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801d19:	5b                   	pop    %ebx
  801d1a:	5e                   	pop    %esi
  801d1b:	5f                   	pop    %edi
  801d1c:	5d                   	pop    %ebp
  801d1d:	c3                   	ret    

00801d1e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801d27:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d2c:	b8 03 00 00 00       	mov    $0x3,%eax
  801d31:	8b 55 08             	mov    0x8(%ebp),%edx
  801d34:	89 cb                	mov    %ecx,%ebx
  801d36:	89 cf                	mov    %ecx,%edi
  801d38:	89 ce                	mov    %ecx,%esi
  801d3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	7e 17                	jle    801d57 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801d40:	83 ec 0c             	sub    $0xc,%esp
  801d43:	50                   	push   %eax
  801d44:	6a 03                	push   $0x3
  801d46:	68 7f 39 80 00       	push   $0x80397f
  801d4b:	6a 23                	push   $0x23
  801d4d:	68 9c 39 80 00       	push   $0x80399c
  801d52:	e8 e5 f5 ff ff       	call   80133c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801d57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d5a:	5b                   	pop    %ebx
  801d5b:	5e                   	pop    %esi
  801d5c:	5f                   	pop    %edi
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    

00801d5f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	57                   	push   %edi
  801d63:	56                   	push   %esi
  801d64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801d65:	ba 00 00 00 00       	mov    $0x0,%edx
  801d6a:	b8 02 00 00 00       	mov    $0x2,%eax
  801d6f:	89 d1                	mov    %edx,%ecx
  801d71:	89 d3                	mov    %edx,%ebx
  801d73:	89 d7                	mov    %edx,%edi
  801d75:	89 d6                	mov    %edx,%esi
  801d77:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801d79:	5b                   	pop    %ebx
  801d7a:	5e                   	pop    %esi
  801d7b:	5f                   	pop    %edi
  801d7c:	5d                   	pop    %ebp
  801d7d:	c3                   	ret    

00801d7e <sys_yield>:

void
sys_yield(void)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	57                   	push   %edi
  801d82:	56                   	push   %esi
  801d83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801d84:	ba 00 00 00 00       	mov    $0x0,%edx
  801d89:	b8 0b 00 00 00       	mov    $0xb,%eax
  801d8e:	89 d1                	mov    %edx,%ecx
  801d90:	89 d3                	mov    %edx,%ebx
  801d92:	89 d7                	mov    %edx,%edi
  801d94:	89 d6                	mov    %edx,%esi
  801d96:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801d98:	5b                   	pop    %ebx
  801d99:	5e                   	pop    %esi
  801d9a:	5f                   	pop    %edi
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    

00801d9d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	57                   	push   %edi
  801da1:	56                   	push   %esi
  801da2:	53                   	push   %ebx
  801da3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801da6:	be 00 00 00 00       	mov    $0x0,%esi
  801dab:	b8 04 00 00 00       	mov    $0x4,%eax
  801db0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801db3:	8b 55 08             	mov    0x8(%ebp),%edx
  801db6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801db9:	89 f7                	mov    %esi,%edi
  801dbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	7e 17                	jle    801dd8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801dc1:	83 ec 0c             	sub    $0xc,%esp
  801dc4:	50                   	push   %eax
  801dc5:	6a 04                	push   $0x4
  801dc7:	68 7f 39 80 00       	push   $0x80397f
  801dcc:	6a 23                	push   $0x23
  801dce:	68 9c 39 80 00       	push   $0x80399c
  801dd3:	e8 64 f5 ff ff       	call   80133c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ddb:	5b                   	pop    %ebx
  801ddc:	5e                   	pop    %esi
  801ddd:	5f                   	pop    %edi
  801dde:	5d                   	pop    %ebp
  801ddf:	c3                   	ret    

00801de0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	57                   	push   %edi
  801de4:	56                   	push   %esi
  801de5:	53                   	push   %ebx
  801de6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801de9:	b8 05 00 00 00       	mov    $0x5,%eax
  801dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801df1:	8b 55 08             	mov    0x8(%ebp),%edx
  801df4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801df7:	8b 7d 14             	mov    0x14(%ebp),%edi
  801dfa:	8b 75 18             	mov    0x18(%ebp),%esi
  801dfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801dff:	85 c0                	test   %eax,%eax
  801e01:	7e 17                	jle    801e1a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801e03:	83 ec 0c             	sub    $0xc,%esp
  801e06:	50                   	push   %eax
  801e07:	6a 05                	push   $0x5
  801e09:	68 7f 39 80 00       	push   $0x80397f
  801e0e:	6a 23                	push   $0x23
  801e10:	68 9c 39 80 00       	push   $0x80399c
  801e15:	e8 22 f5 ff ff       	call   80133c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e1d:	5b                   	pop    %ebx
  801e1e:	5e                   	pop    %esi
  801e1f:	5f                   	pop    %edi
  801e20:	5d                   	pop    %ebp
  801e21:	c3                   	ret    

00801e22 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	57                   	push   %edi
  801e26:	56                   	push   %esi
  801e27:	53                   	push   %ebx
  801e28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801e2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e30:	b8 06 00 00 00       	mov    $0x6,%eax
  801e35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e38:	8b 55 08             	mov    0x8(%ebp),%edx
  801e3b:	89 df                	mov    %ebx,%edi
  801e3d:	89 de                	mov    %ebx,%esi
  801e3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801e41:	85 c0                	test   %eax,%eax
  801e43:	7e 17                	jle    801e5c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801e45:	83 ec 0c             	sub    $0xc,%esp
  801e48:	50                   	push   %eax
  801e49:	6a 06                	push   $0x6
  801e4b:	68 7f 39 80 00       	push   $0x80397f
  801e50:	6a 23                	push   $0x23
  801e52:	68 9c 39 80 00       	push   $0x80399c
  801e57:	e8 e0 f4 ff ff       	call   80133c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801e5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e5f:	5b                   	pop    %ebx
  801e60:	5e                   	pop    %esi
  801e61:	5f                   	pop    %edi
  801e62:	5d                   	pop    %ebp
  801e63:	c3                   	ret    

00801e64 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	57                   	push   %edi
  801e68:	56                   	push   %esi
  801e69:	53                   	push   %ebx
  801e6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801e6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e72:	b8 08 00 00 00       	mov    $0x8,%eax
  801e77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e7a:	8b 55 08             	mov    0x8(%ebp),%edx
  801e7d:	89 df                	mov    %ebx,%edi
  801e7f:	89 de                	mov    %ebx,%esi
  801e81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801e83:	85 c0                	test   %eax,%eax
  801e85:	7e 17                	jle    801e9e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801e87:	83 ec 0c             	sub    $0xc,%esp
  801e8a:	50                   	push   %eax
  801e8b:	6a 08                	push   $0x8
  801e8d:	68 7f 39 80 00       	push   $0x80397f
  801e92:	6a 23                	push   $0x23
  801e94:	68 9c 39 80 00       	push   $0x80399c
  801e99:	e8 9e f4 ff ff       	call   80133c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801e9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea1:	5b                   	pop    %ebx
  801ea2:	5e                   	pop    %esi
  801ea3:	5f                   	pop    %edi
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    

00801ea6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	57                   	push   %edi
  801eaa:	56                   	push   %esi
  801eab:	53                   	push   %ebx
  801eac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801eaf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801eb4:	b8 09 00 00 00       	mov    $0x9,%eax
  801eb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  801ebf:	89 df                	mov    %ebx,%edi
  801ec1:	89 de                	mov    %ebx,%esi
  801ec3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	7e 17                	jle    801ee0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801ec9:	83 ec 0c             	sub    $0xc,%esp
  801ecc:	50                   	push   %eax
  801ecd:	6a 09                	push   $0x9
  801ecf:	68 7f 39 80 00       	push   $0x80397f
  801ed4:	6a 23                	push   $0x23
  801ed6:	68 9c 39 80 00       	push   $0x80399c
  801edb:	e8 5c f4 ff ff       	call   80133c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801ee0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee3:	5b                   	pop    %ebx
  801ee4:	5e                   	pop    %esi
  801ee5:	5f                   	pop    %edi
  801ee6:	5d                   	pop    %ebp
  801ee7:	c3                   	ret    

00801ee8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	57                   	push   %edi
  801eec:	56                   	push   %esi
  801eed:	53                   	push   %ebx
  801eee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801ef1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ef6:	b8 0a 00 00 00       	mov    $0xa,%eax
  801efb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801efe:	8b 55 08             	mov    0x8(%ebp),%edx
  801f01:	89 df                	mov    %ebx,%edi
  801f03:	89 de                	mov    %ebx,%esi
  801f05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801f07:	85 c0                	test   %eax,%eax
  801f09:	7e 17                	jle    801f22 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801f0b:	83 ec 0c             	sub    $0xc,%esp
  801f0e:	50                   	push   %eax
  801f0f:	6a 0a                	push   $0xa
  801f11:	68 7f 39 80 00       	push   $0x80397f
  801f16:	6a 23                	push   $0x23
  801f18:	68 9c 39 80 00       	push   $0x80399c
  801f1d:	e8 1a f4 ff ff       	call   80133c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f25:	5b                   	pop    %ebx
  801f26:	5e                   	pop    %esi
  801f27:	5f                   	pop    %edi
  801f28:	5d                   	pop    %ebp
  801f29:	c3                   	ret    

00801f2a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	57                   	push   %edi
  801f2e:	56                   	push   %esi
  801f2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801f30:	be 00 00 00 00       	mov    $0x0,%esi
  801f35:	b8 0c 00 00 00       	mov    $0xc,%eax
  801f3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f3d:	8b 55 08             	mov    0x8(%ebp),%edx
  801f40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f43:	8b 7d 14             	mov    0x14(%ebp),%edi
  801f46:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801f48:	5b                   	pop    %ebx
  801f49:	5e                   	pop    %esi
  801f4a:	5f                   	pop    %edi
  801f4b:	5d                   	pop    %ebp
  801f4c:	c3                   	ret    

00801f4d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801f4d:	55                   	push   %ebp
  801f4e:	89 e5                	mov    %esp,%ebp
  801f50:	57                   	push   %edi
  801f51:	56                   	push   %esi
  801f52:	53                   	push   %ebx
  801f53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801f56:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f5b:	b8 0d 00 00 00       	mov    $0xd,%eax
  801f60:	8b 55 08             	mov    0x8(%ebp),%edx
  801f63:	89 cb                	mov    %ecx,%ebx
  801f65:	89 cf                	mov    %ecx,%edi
  801f67:	89 ce                	mov    %ecx,%esi
  801f69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801f6b:	85 c0                	test   %eax,%eax
  801f6d:	7e 17                	jle    801f86 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801f6f:	83 ec 0c             	sub    $0xc,%esp
  801f72:	50                   	push   %eax
  801f73:	6a 0d                	push   $0xd
  801f75:	68 7f 39 80 00       	push   $0x80397f
  801f7a:	6a 23                	push   $0x23
  801f7c:	68 9c 39 80 00       	push   $0x80399c
  801f81:	e8 b6 f3 ff ff       	call   80133c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801f86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f89:	5b                   	pop    %ebx
  801f8a:	5e                   	pop    %esi
  801f8b:	5f                   	pop    %edi
  801f8c:	5d                   	pop    %ebp
  801f8d:	c3                   	ret    

00801f8e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f94:	83 3d 10 90 80 00 00 	cmpl   $0x0,0x809010
  801f9b:	75 64                	jne    802001 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		int r;
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801f9d:	a1 0c 90 80 00       	mov    0x80900c,%eax
  801fa2:	8b 40 48             	mov    0x48(%eax),%eax
  801fa5:	83 ec 04             	sub    $0x4,%esp
  801fa8:	6a 07                	push   $0x7
  801faa:	68 00 f0 bf ee       	push   $0xeebff000
  801faf:	50                   	push   %eax
  801fb0:	e8 e8 fd ff ff       	call   801d9d <sys_page_alloc>
		if ( r != 0)
  801fb5:	83 c4 10             	add    $0x10,%esp
  801fb8:	85 c0                	test   %eax,%eax
  801fba:	74 14                	je     801fd0 <set_pgfault_handler+0x42>
			panic("set_pgfault_handler: sys_page_alloc failed.");
  801fbc:	83 ec 04             	sub    $0x4,%esp
  801fbf:	68 ac 39 80 00       	push   $0x8039ac
  801fc4:	6a 24                	push   $0x24
  801fc6:	68 fa 39 80 00       	push   $0x8039fa
  801fcb:	e8 6c f3 ff ff       	call   80133c <_panic>
			
		if (sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall) < 0)
  801fd0:	a1 0c 90 80 00       	mov    0x80900c,%eax
  801fd5:	8b 40 48             	mov    0x48(%eax),%eax
  801fd8:	83 ec 08             	sub    $0x8,%esp
  801fdb:	68 0b 20 80 00       	push   $0x80200b
  801fe0:	50                   	push   %eax
  801fe1:	e8 02 ff ff ff       	call   801ee8 <sys_env_set_pgfault_upcall>
  801fe6:	83 c4 10             	add    $0x10,%esp
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	79 14                	jns    802001 <set_pgfault_handler+0x73>
		 	panic("sys_env_set_pgfault_upcall failed");
  801fed:	83 ec 04             	sub    $0x4,%esp
  801ff0:	68 d8 39 80 00       	push   $0x8039d8
  801ff5:	6a 27                	push   $0x27
  801ff7:	68 fa 39 80 00       	push   $0x8039fa
  801ffc:	e8 3b f3 ff ff       	call   80133c <_panic>
			
	}

	
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802001:	8b 45 08             	mov    0x8(%ebp),%eax
  802004:	a3 10 90 80 00       	mov    %eax,0x809010
}
  802009:	c9                   	leave  
  80200a:	c3                   	ret    

0080200b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80200b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80200c:	a1 10 90 80 00       	mov    0x809010,%eax
	call *%eax
  802011:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802013:	83 c4 04             	add    $0x4,%esp
	addl $0x4,%esp
	popfl
	popl %esp
	ret
*/
movl 0x28(%esp), %eax
  802016:	8b 44 24 28          	mov    0x28(%esp),%eax
movl %esp, %ebx
  80201a:	89 e3                	mov    %esp,%ebx
movl 0x30(%esp), %esp
  80201c:	8b 64 24 30          	mov    0x30(%esp),%esp
pushl %eax
  802020:	50                   	push   %eax
movl %esp, 0x30(%ebx)
  802021:	89 63 30             	mov    %esp,0x30(%ebx)
movl %ebx, %esp
  802024:	89 dc                	mov    %ebx,%esp
addl $0x8, %esp
  802026:	83 c4 08             	add    $0x8,%esp
popal
  802029:	61                   	popa   
addl $0x4, %esp
  80202a:	83 c4 04             	add    $0x4,%esp
popfl
  80202d:	9d                   	popf   
popl %esp
  80202e:	5c                   	pop    %esp
ret
  80202f:	c3                   	ret    

00802030 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	56                   	push   %esi
  802034:	53                   	push   %ebx
  802035:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802038:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203b:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  80203e:	85 c0                	test   %eax,%eax
  802040:	74 0e                	je     802050 <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  802042:	83 ec 0c             	sub    $0xc,%esp
  802045:	50                   	push   %eax
  802046:	e8 02 ff ff ff       	call   801f4d <sys_ipc_recv>
  80204b:	83 c4 10             	add    $0x10,%esp
  80204e:	eb 10                	jmp    802060 <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  802050:	83 ec 0c             	sub    $0xc,%esp
  802053:	68 00 00 00 f0       	push   $0xf0000000
  802058:	e8 f0 fe ff ff       	call   801f4d <sys_ipc_recv>
  80205d:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  802060:	85 c0                	test   %eax,%eax
  802062:	74 16                	je     80207a <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  802064:	85 db                	test   %ebx,%ebx
  802066:	74 36                	je     80209e <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  802068:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  80206e:	85 f6                	test   %esi,%esi
  802070:	74 2c                	je     80209e <ipc_recv+0x6e>
				*perm_store = 0;
  802072:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802078:	eb 24                	jmp    80209e <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  80207a:	85 db                	test   %ebx,%ebx
  80207c:	74 18                	je     802096 <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  80207e:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802083:	8b 40 74             	mov    0x74(%eax),%eax
  802086:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  802088:	85 f6                	test   %esi,%esi
  80208a:	74 0a                	je     802096 <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  80208c:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802091:	8b 40 78             	mov    0x78(%eax),%eax
  802094:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  802096:	a1 0c 90 80 00       	mov    0x80900c,%eax
  80209b:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  80209e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a1:	5b                   	pop    %ebx
  8020a2:	5e                   	pop    %esi
  8020a3:	5d                   	pop    %ebp
  8020a4:	c3                   	ret    

008020a5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020a5:	55                   	push   %ebp
  8020a6:	89 e5                	mov    %esp,%ebp
  8020a8:	57                   	push   %edi
  8020a9:	56                   	push   %esi
  8020aa:	53                   	push   %ebx
  8020ab:	83 ec 0c             	sub    $0xc,%esp
  8020ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020b1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  8020b4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020b8:	75 39                	jne    8020f3 <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  8020ba:	6a 00                	push   $0x0
  8020bc:	68 00 00 00 f0       	push   $0xf0000000
  8020c1:	56                   	push   %esi
  8020c2:	57                   	push   %edi
  8020c3:	e8 62 fe ff ff       	call   801f2a <sys_ipc_try_send>
  8020c8:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  8020ca:	83 c4 10             	add    $0x10,%esp
  8020cd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d0:	74 16                	je     8020e8 <ipc_send+0x43>
  8020d2:	85 c0                	test   %eax,%eax
  8020d4:	74 12                	je     8020e8 <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  8020d6:	50                   	push   %eax
  8020d7:	68 08 3a 80 00       	push   $0x803a08
  8020dc:	6a 4f                	push   $0x4f
  8020de:	68 40 3a 80 00       	push   $0x803a40
  8020e3:	e8 54 f2 ff ff       	call   80133c <_panic>
			sys_yield();
  8020e8:	e8 91 fc ff ff       	call   801d7e <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  8020ed:	85 db                	test   %ebx,%ebx
  8020ef:	75 c9                	jne    8020ba <ipc_send+0x15>
  8020f1:	eb 36                	jmp    802129 <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  8020f3:	ff 75 14             	pushl  0x14(%ebp)
  8020f6:	ff 75 10             	pushl  0x10(%ebp)
  8020f9:	56                   	push   %esi
  8020fa:	57                   	push   %edi
  8020fb:	e8 2a fe ff ff       	call   801f2a <sys_ipc_try_send>
  802100:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  802102:	83 c4 10             	add    $0x10,%esp
  802105:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802108:	74 16                	je     802120 <ipc_send+0x7b>
  80210a:	85 c0                	test   %eax,%eax
  80210c:	74 12                	je     802120 <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  80210e:	50                   	push   %eax
  80210f:	68 08 3a 80 00       	push   $0x803a08
  802114:	6a 5a                	push   $0x5a
  802116:	68 40 3a 80 00       	push   $0x803a40
  80211b:	e8 1c f2 ff ff       	call   80133c <_panic>
			sys_yield();
  802120:	e8 59 fc ff ff       	call   801d7e <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  802125:	85 db                	test   %ebx,%ebx
  802127:	75 ca                	jne    8020f3 <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  802129:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80212c:	5b                   	pop    %ebx
  80212d:	5e                   	pop    %esi
  80212e:	5f                   	pop    %edi
  80212f:	5d                   	pop    %ebp
  802130:	c3                   	ret    

00802131 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802131:	55                   	push   %ebp
  802132:	89 e5                	mov    %esp,%ebp
  802134:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802137:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80213c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80213f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802145:	8b 52 50             	mov    0x50(%edx),%edx
  802148:	39 ca                	cmp    %ecx,%edx
  80214a:	75 0d                	jne    802159 <ipc_find_env+0x28>
			return envs[i].env_id;
  80214c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80214f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802154:	8b 40 48             	mov    0x48(%eax),%eax
  802157:	eb 0f                	jmp    802168 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802159:	83 c0 01             	add    $0x1,%eax
  80215c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802161:	75 d9                	jne    80213c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802163:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802168:	5d                   	pop    %ebp
  802169:	c3                   	ret    

0080216a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80216a:	55                   	push   %ebp
  80216b:	89 e5                	mov    %esp,%ebp
  80216d:	56                   	push   %esi
  80216e:	53                   	push   %ebx
  80216f:	89 c6                	mov    %eax,%esi
  802171:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802173:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  80217a:	75 12                	jne    80218e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80217c:	83 ec 0c             	sub    $0xc,%esp
  80217f:	6a 01                	push   $0x1
  802181:	e8 ab ff ff ff       	call   802131 <ipc_find_env>
  802186:	a3 00 90 80 00       	mov    %eax,0x809000
  80218b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80218e:	6a 07                	push   $0x7
  802190:	68 00 a0 80 00       	push   $0x80a000
  802195:	56                   	push   %esi
  802196:	ff 35 00 90 80 00    	pushl  0x809000
  80219c:	e8 04 ff ff ff       	call   8020a5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021a1:	83 c4 0c             	add    $0xc,%esp
  8021a4:	6a 00                	push   $0x0
  8021a6:	53                   	push   %ebx
  8021a7:	6a 00                	push   $0x0
  8021a9:	e8 82 fe ff ff       	call   802030 <ipc_recv>
}
  8021ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021b1:	5b                   	pop    %ebx
  8021b2:	5e                   	pop    %esi
  8021b3:	5d                   	pop    %ebp
  8021b4:	c3                   	ret    

008021b5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8021b5:	55                   	push   %ebp
  8021b6:	89 e5                	mov    %esp,%ebp
  8021b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8021bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021be:	8b 40 0c             	mov    0xc(%eax),%eax
  8021c1:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.set_size.req_size = newsize;
  8021c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021c9:	a3 04 a0 80 00       	mov    %eax,0x80a004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8021ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8021d3:	b8 02 00 00 00       	mov    $0x2,%eax
  8021d8:	e8 8d ff ff ff       	call   80216a <fsipc>
}
  8021dd:	c9                   	leave  
  8021de:	c3                   	ret    

008021df <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8021df:	55                   	push   %ebp
  8021e0:	89 e5                	mov    %esp,%ebp
  8021e2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8021e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8021eb:	a3 00 a0 80 00       	mov    %eax,0x80a000
	return fsipc(FSREQ_FLUSH, NULL);
  8021f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8021f5:	b8 06 00 00 00       	mov    $0x6,%eax
  8021fa:	e8 6b ff ff ff       	call   80216a <fsipc>
}
  8021ff:	c9                   	leave  
  802200:	c3                   	ret    

00802201 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802201:	55                   	push   %ebp
  802202:	89 e5                	mov    %esp,%ebp
  802204:	53                   	push   %ebx
  802205:	83 ec 04             	sub    $0x4,%esp
  802208:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80220b:	8b 45 08             	mov    0x8(%ebp),%eax
  80220e:	8b 40 0c             	mov    0xc(%eax),%eax
  802211:	a3 00 a0 80 00       	mov    %eax,0x80a000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802216:	ba 00 00 00 00       	mov    $0x0,%edx
  80221b:	b8 05 00 00 00       	mov    $0x5,%eax
  802220:	e8 45 ff ff ff       	call   80216a <fsipc>
  802225:	85 c0                	test   %eax,%eax
  802227:	78 2c                	js     802255 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802229:	83 ec 08             	sub    $0x8,%esp
  80222c:	68 00 a0 80 00       	push   $0x80a000
  802231:	53                   	push   %ebx
  802232:	e8 63 f7 ff ff       	call   80199a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802237:	a1 80 a0 80 00       	mov    0x80a080,%eax
  80223c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802242:	a1 84 a0 80 00       	mov    0x80a084,%eax
  802247:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80224d:	83 c4 10             	add    $0x10,%esp
  802250:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802255:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802258:	c9                   	leave  
  802259:	c3                   	ret    

0080225a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80225a:	55                   	push   %ebp
  80225b:	89 e5                	mov    %esp,%ebp
  80225d:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  802260:	68 4a 3a 80 00       	push   $0x803a4a
  802265:	68 90 00 00 00       	push   $0x90
  80226a:	68 68 3a 80 00       	push   $0x803a68
  80226f:	e8 c8 f0 ff ff       	call   80133c <_panic>

00802274 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802274:	55                   	push   %ebp
  802275:	89 e5                	mov    %esp,%ebp
  802277:	56                   	push   %esi
  802278:	53                   	push   %ebx
  802279:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80227c:	8b 45 08             	mov    0x8(%ebp),%eax
  80227f:	8b 40 0c             	mov    0xc(%eax),%eax
  802282:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.read.req_n = n;
  802287:	89 35 04 a0 80 00    	mov    %esi,0x80a004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80228d:	ba 00 00 00 00       	mov    $0x0,%edx
  802292:	b8 03 00 00 00       	mov    $0x3,%eax
  802297:	e8 ce fe ff ff       	call   80216a <fsipc>
  80229c:	89 c3                	mov    %eax,%ebx
  80229e:	85 c0                	test   %eax,%eax
  8022a0:	78 4b                	js     8022ed <devfile_read+0x79>
		return r;
	assert(r <= n);
  8022a2:	39 c6                	cmp    %eax,%esi
  8022a4:	73 16                	jae    8022bc <devfile_read+0x48>
  8022a6:	68 73 3a 80 00       	push   $0x803a73
  8022ab:	68 3d 31 80 00       	push   $0x80313d
  8022b0:	6a 7c                	push   $0x7c
  8022b2:	68 68 3a 80 00       	push   $0x803a68
  8022b7:	e8 80 f0 ff ff       	call   80133c <_panic>
	assert(r <= PGSIZE);
  8022bc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8022c1:	7e 16                	jle    8022d9 <devfile_read+0x65>
  8022c3:	68 7a 3a 80 00       	push   $0x803a7a
  8022c8:	68 3d 31 80 00       	push   $0x80313d
  8022cd:	6a 7d                	push   $0x7d
  8022cf:	68 68 3a 80 00       	push   $0x803a68
  8022d4:	e8 63 f0 ff ff       	call   80133c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8022d9:	83 ec 04             	sub    $0x4,%esp
  8022dc:	50                   	push   %eax
  8022dd:	68 00 a0 80 00       	push   $0x80a000
  8022e2:	ff 75 0c             	pushl  0xc(%ebp)
  8022e5:	e8 42 f8 ff ff       	call   801b2c <memmove>
	return r;
  8022ea:	83 c4 10             	add    $0x10,%esp
}
  8022ed:	89 d8                	mov    %ebx,%eax
  8022ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022f2:	5b                   	pop    %ebx
  8022f3:	5e                   	pop    %esi
  8022f4:	5d                   	pop    %ebp
  8022f5:	c3                   	ret    

008022f6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8022f6:	55                   	push   %ebp
  8022f7:	89 e5                	mov    %esp,%ebp
  8022f9:	53                   	push   %ebx
  8022fa:	83 ec 20             	sub    $0x20,%esp
  8022fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802300:	53                   	push   %ebx
  802301:	e8 5b f6 ff ff       	call   801961 <strlen>
  802306:	83 c4 10             	add    $0x10,%esp
  802309:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80230e:	7f 67                	jg     802377 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802310:	83 ec 0c             	sub    $0xc,%esp
  802313:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802316:	50                   	push   %eax
  802317:	e8 e0 00 00 00       	call   8023fc <fd_alloc>
  80231c:	83 c4 10             	add    $0x10,%esp
		return r;
  80231f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802321:	85 c0                	test   %eax,%eax
  802323:	78 57                	js     80237c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802325:	83 ec 08             	sub    $0x8,%esp
  802328:	53                   	push   %ebx
  802329:	68 00 a0 80 00       	push   $0x80a000
  80232e:	e8 67 f6 ff ff       	call   80199a <strcpy>
	fsipcbuf.open.req_omode = mode;
  802333:	8b 45 0c             	mov    0xc(%ebp),%eax
  802336:	a3 00 a4 80 00       	mov    %eax,0x80a400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80233b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80233e:	b8 01 00 00 00       	mov    $0x1,%eax
  802343:	e8 22 fe ff ff       	call   80216a <fsipc>
  802348:	89 c3                	mov    %eax,%ebx
  80234a:	83 c4 10             	add    $0x10,%esp
  80234d:	85 c0                	test   %eax,%eax
  80234f:	79 14                	jns    802365 <open+0x6f>
		fd_close(fd, 0);
  802351:	83 ec 08             	sub    $0x8,%esp
  802354:	6a 00                	push   $0x0
  802356:	ff 75 f4             	pushl  -0xc(%ebp)
  802359:	e8 96 01 00 00       	call   8024f4 <fd_close>
		return r;
  80235e:	83 c4 10             	add    $0x10,%esp
  802361:	89 da                	mov    %ebx,%edx
  802363:	eb 17                	jmp    80237c <open+0x86>
	}

	return fd2num(fd);
  802365:	83 ec 0c             	sub    $0xc,%esp
  802368:	ff 75 f4             	pushl  -0xc(%ebp)
  80236b:	e8 65 00 00 00       	call   8023d5 <fd2num>
  802370:	89 c2                	mov    %eax,%edx
  802372:	83 c4 10             	add    $0x10,%esp
  802375:	eb 05                	jmp    80237c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802377:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80237c:	89 d0                	mov    %edx,%eax
  80237e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802381:	c9                   	leave  
  802382:	c3                   	ret    

00802383 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802383:	55                   	push   %ebp
  802384:	89 e5                	mov    %esp,%ebp
  802386:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802389:	ba 00 00 00 00       	mov    $0x0,%edx
  80238e:	b8 08 00 00 00       	mov    $0x8,%eax
  802393:	e8 d2 fd ff ff       	call   80216a <fsipc>
}
  802398:	c9                   	leave  
  802399:	c3                   	ret    

0080239a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80239a:	55                   	push   %ebp
  80239b:	89 e5                	mov    %esp,%ebp
  80239d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023a0:	89 d0                	mov    %edx,%eax
  8023a2:	c1 e8 16             	shr    $0x16,%eax
  8023a5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023ac:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023b1:	f6 c1 01             	test   $0x1,%cl
  8023b4:	74 1d                	je     8023d3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023b6:	c1 ea 0c             	shr    $0xc,%edx
  8023b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023c0:	f6 c2 01             	test   $0x1,%dl
  8023c3:	74 0e                	je     8023d3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023c5:	c1 ea 0c             	shr    $0xc,%edx
  8023c8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023cf:	ef 
  8023d0:	0f b7 c0             	movzwl %ax,%eax
}
  8023d3:	5d                   	pop    %ebp
  8023d4:	c3                   	ret    

008023d5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8023d5:	55                   	push   %ebp
  8023d6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8023d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023db:	05 00 00 00 30       	add    $0x30000000,%eax
  8023e0:	c1 e8 0c             	shr    $0xc,%eax
}
  8023e3:	5d                   	pop    %ebp
  8023e4:	c3                   	ret    

008023e5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8023e5:	55                   	push   %ebp
  8023e6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8023e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023eb:	05 00 00 00 30       	add    $0x30000000,%eax
  8023f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8023f5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8023fa:	5d                   	pop    %ebp
  8023fb:	c3                   	ret    

008023fc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8023fc:	55                   	push   %ebp
  8023fd:	89 e5                	mov    %esp,%ebp
  8023ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802402:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802407:	89 c2                	mov    %eax,%edx
  802409:	c1 ea 16             	shr    $0x16,%edx
  80240c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802413:	f6 c2 01             	test   $0x1,%dl
  802416:	74 11                	je     802429 <fd_alloc+0x2d>
  802418:	89 c2                	mov    %eax,%edx
  80241a:	c1 ea 0c             	shr    $0xc,%edx
  80241d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802424:	f6 c2 01             	test   $0x1,%dl
  802427:	75 09                	jne    802432 <fd_alloc+0x36>
			*fd_store = fd;
  802429:	89 01                	mov    %eax,(%ecx)
			return 0;
  80242b:	b8 00 00 00 00       	mov    $0x0,%eax
  802430:	eb 17                	jmp    802449 <fd_alloc+0x4d>
  802432:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802437:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80243c:	75 c9                	jne    802407 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80243e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802444:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802449:	5d                   	pop    %ebp
  80244a:	c3                   	ret    

0080244b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80244b:	55                   	push   %ebp
  80244c:	89 e5                	mov    %esp,%ebp
  80244e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802451:	83 f8 1f             	cmp    $0x1f,%eax
  802454:	77 36                	ja     80248c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802456:	c1 e0 0c             	shl    $0xc,%eax
  802459:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80245e:	89 c2                	mov    %eax,%edx
  802460:	c1 ea 16             	shr    $0x16,%edx
  802463:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80246a:	f6 c2 01             	test   $0x1,%dl
  80246d:	74 24                	je     802493 <fd_lookup+0x48>
  80246f:	89 c2                	mov    %eax,%edx
  802471:	c1 ea 0c             	shr    $0xc,%edx
  802474:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80247b:	f6 c2 01             	test   $0x1,%dl
  80247e:	74 1a                	je     80249a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802480:	8b 55 0c             	mov    0xc(%ebp),%edx
  802483:	89 02                	mov    %eax,(%edx)
	return 0;
  802485:	b8 00 00 00 00       	mov    $0x0,%eax
  80248a:	eb 13                	jmp    80249f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80248c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802491:	eb 0c                	jmp    80249f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802493:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802498:	eb 05                	jmp    80249f <fd_lookup+0x54>
  80249a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80249f:	5d                   	pop    %ebp
  8024a0:	c3                   	ret    

008024a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8024a1:	55                   	push   %ebp
  8024a2:	89 e5                	mov    %esp,%ebp
  8024a4:	83 ec 08             	sub    $0x8,%esp
  8024a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024aa:	ba 08 3b 80 00       	mov    $0x803b08,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8024af:	eb 13                	jmp    8024c4 <dev_lookup+0x23>
  8024b1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8024b4:	39 08                	cmp    %ecx,(%eax)
  8024b6:	75 0c                	jne    8024c4 <dev_lookup+0x23>
			*dev = devtab[i];
  8024b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024bb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8024bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8024c2:	eb 2e                	jmp    8024f2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8024c4:	8b 02                	mov    (%edx),%eax
  8024c6:	85 c0                	test   %eax,%eax
  8024c8:	75 e7                	jne    8024b1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8024ca:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8024cf:	8b 40 48             	mov    0x48(%eax),%eax
  8024d2:	83 ec 04             	sub    $0x4,%esp
  8024d5:	51                   	push   %ecx
  8024d6:	50                   	push   %eax
  8024d7:	68 88 3a 80 00       	push   $0x803a88
  8024dc:	e8 34 ef ff ff       	call   801415 <cprintf>
	*dev = 0;
  8024e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8024ea:	83 c4 10             	add    $0x10,%esp
  8024ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8024f2:	c9                   	leave  
  8024f3:	c3                   	ret    

008024f4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8024f4:	55                   	push   %ebp
  8024f5:	89 e5                	mov    %esp,%ebp
  8024f7:	56                   	push   %esi
  8024f8:	53                   	push   %ebx
  8024f9:	83 ec 10             	sub    $0x10,%esp
  8024fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8024ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802502:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802505:	50                   	push   %eax
  802506:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80250c:	c1 e8 0c             	shr    $0xc,%eax
  80250f:	50                   	push   %eax
  802510:	e8 36 ff ff ff       	call   80244b <fd_lookup>
  802515:	83 c4 08             	add    $0x8,%esp
  802518:	85 c0                	test   %eax,%eax
  80251a:	78 05                	js     802521 <fd_close+0x2d>
	    || fd != fd2)
  80251c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80251f:	74 0c                	je     80252d <fd_close+0x39>
		return (must_exist ? r : 0);
  802521:	84 db                	test   %bl,%bl
  802523:	ba 00 00 00 00       	mov    $0x0,%edx
  802528:	0f 44 c2             	cmove  %edx,%eax
  80252b:	eb 41                	jmp    80256e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80252d:	83 ec 08             	sub    $0x8,%esp
  802530:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802533:	50                   	push   %eax
  802534:	ff 36                	pushl  (%esi)
  802536:	e8 66 ff ff ff       	call   8024a1 <dev_lookup>
  80253b:	89 c3                	mov    %eax,%ebx
  80253d:	83 c4 10             	add    $0x10,%esp
  802540:	85 c0                	test   %eax,%eax
  802542:	78 1a                	js     80255e <fd_close+0x6a>
		if (dev->dev_close)
  802544:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802547:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80254a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80254f:	85 c0                	test   %eax,%eax
  802551:	74 0b                	je     80255e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802553:	83 ec 0c             	sub    $0xc,%esp
  802556:	56                   	push   %esi
  802557:	ff d0                	call   *%eax
  802559:	89 c3                	mov    %eax,%ebx
  80255b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80255e:	83 ec 08             	sub    $0x8,%esp
  802561:	56                   	push   %esi
  802562:	6a 00                	push   $0x0
  802564:	e8 b9 f8 ff ff       	call   801e22 <sys_page_unmap>
	return r;
  802569:	83 c4 10             	add    $0x10,%esp
  80256c:	89 d8                	mov    %ebx,%eax
}
  80256e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802571:	5b                   	pop    %ebx
  802572:	5e                   	pop    %esi
  802573:	5d                   	pop    %ebp
  802574:	c3                   	ret    

00802575 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802575:	55                   	push   %ebp
  802576:	89 e5                	mov    %esp,%ebp
  802578:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80257b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80257e:	50                   	push   %eax
  80257f:	ff 75 08             	pushl  0x8(%ebp)
  802582:	e8 c4 fe ff ff       	call   80244b <fd_lookup>
  802587:	83 c4 08             	add    $0x8,%esp
  80258a:	85 c0                	test   %eax,%eax
  80258c:	78 10                	js     80259e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80258e:	83 ec 08             	sub    $0x8,%esp
  802591:	6a 01                	push   $0x1
  802593:	ff 75 f4             	pushl  -0xc(%ebp)
  802596:	e8 59 ff ff ff       	call   8024f4 <fd_close>
  80259b:	83 c4 10             	add    $0x10,%esp
}
  80259e:	c9                   	leave  
  80259f:	c3                   	ret    

008025a0 <close_all>:

void
close_all(void)
{
  8025a0:	55                   	push   %ebp
  8025a1:	89 e5                	mov    %esp,%ebp
  8025a3:	53                   	push   %ebx
  8025a4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8025a7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8025ac:	83 ec 0c             	sub    $0xc,%esp
  8025af:	53                   	push   %ebx
  8025b0:	e8 c0 ff ff ff       	call   802575 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8025b5:	83 c3 01             	add    $0x1,%ebx
  8025b8:	83 c4 10             	add    $0x10,%esp
  8025bb:	83 fb 20             	cmp    $0x20,%ebx
  8025be:	75 ec                	jne    8025ac <close_all+0xc>
		close(i);
}
  8025c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025c3:	c9                   	leave  
  8025c4:	c3                   	ret    

008025c5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8025c5:	55                   	push   %ebp
  8025c6:	89 e5                	mov    %esp,%ebp
  8025c8:	57                   	push   %edi
  8025c9:	56                   	push   %esi
  8025ca:	53                   	push   %ebx
  8025cb:	83 ec 2c             	sub    $0x2c,%esp
  8025ce:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8025d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8025d4:	50                   	push   %eax
  8025d5:	ff 75 08             	pushl  0x8(%ebp)
  8025d8:	e8 6e fe ff ff       	call   80244b <fd_lookup>
  8025dd:	83 c4 08             	add    $0x8,%esp
  8025e0:	85 c0                	test   %eax,%eax
  8025e2:	0f 88 c1 00 00 00    	js     8026a9 <dup+0xe4>
		return r;
	close(newfdnum);
  8025e8:	83 ec 0c             	sub    $0xc,%esp
  8025eb:	56                   	push   %esi
  8025ec:	e8 84 ff ff ff       	call   802575 <close>

	newfd = INDEX2FD(newfdnum);
  8025f1:	89 f3                	mov    %esi,%ebx
  8025f3:	c1 e3 0c             	shl    $0xc,%ebx
  8025f6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8025fc:	83 c4 04             	add    $0x4,%esp
  8025ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  802602:	e8 de fd ff ff       	call   8023e5 <fd2data>
  802607:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802609:	89 1c 24             	mov    %ebx,(%esp)
  80260c:	e8 d4 fd ff ff       	call   8023e5 <fd2data>
  802611:	83 c4 10             	add    $0x10,%esp
  802614:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802617:	89 f8                	mov    %edi,%eax
  802619:	c1 e8 16             	shr    $0x16,%eax
  80261c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802623:	a8 01                	test   $0x1,%al
  802625:	74 37                	je     80265e <dup+0x99>
  802627:	89 f8                	mov    %edi,%eax
  802629:	c1 e8 0c             	shr    $0xc,%eax
  80262c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802633:	f6 c2 01             	test   $0x1,%dl
  802636:	74 26                	je     80265e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802638:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80263f:	83 ec 0c             	sub    $0xc,%esp
  802642:	25 07 0e 00 00       	and    $0xe07,%eax
  802647:	50                   	push   %eax
  802648:	ff 75 d4             	pushl  -0x2c(%ebp)
  80264b:	6a 00                	push   $0x0
  80264d:	57                   	push   %edi
  80264e:	6a 00                	push   $0x0
  802650:	e8 8b f7 ff ff       	call   801de0 <sys_page_map>
  802655:	89 c7                	mov    %eax,%edi
  802657:	83 c4 20             	add    $0x20,%esp
  80265a:	85 c0                	test   %eax,%eax
  80265c:	78 2e                	js     80268c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80265e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802661:	89 d0                	mov    %edx,%eax
  802663:	c1 e8 0c             	shr    $0xc,%eax
  802666:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80266d:	83 ec 0c             	sub    $0xc,%esp
  802670:	25 07 0e 00 00       	and    $0xe07,%eax
  802675:	50                   	push   %eax
  802676:	53                   	push   %ebx
  802677:	6a 00                	push   $0x0
  802679:	52                   	push   %edx
  80267a:	6a 00                	push   $0x0
  80267c:	e8 5f f7 ff ff       	call   801de0 <sys_page_map>
  802681:	89 c7                	mov    %eax,%edi
  802683:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802686:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802688:	85 ff                	test   %edi,%edi
  80268a:	79 1d                	jns    8026a9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80268c:	83 ec 08             	sub    $0x8,%esp
  80268f:	53                   	push   %ebx
  802690:	6a 00                	push   $0x0
  802692:	e8 8b f7 ff ff       	call   801e22 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802697:	83 c4 08             	add    $0x8,%esp
  80269a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80269d:	6a 00                	push   $0x0
  80269f:	e8 7e f7 ff ff       	call   801e22 <sys_page_unmap>
	return r;
  8026a4:	83 c4 10             	add    $0x10,%esp
  8026a7:	89 f8                	mov    %edi,%eax
}
  8026a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026ac:	5b                   	pop    %ebx
  8026ad:	5e                   	pop    %esi
  8026ae:	5f                   	pop    %edi
  8026af:	5d                   	pop    %ebp
  8026b0:	c3                   	ret    

008026b1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8026b1:	55                   	push   %ebp
  8026b2:	89 e5                	mov    %esp,%ebp
  8026b4:	53                   	push   %ebx
  8026b5:	83 ec 14             	sub    $0x14,%esp
  8026b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8026bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8026be:	50                   	push   %eax
  8026bf:	53                   	push   %ebx
  8026c0:	e8 86 fd ff ff       	call   80244b <fd_lookup>
  8026c5:	83 c4 08             	add    $0x8,%esp
  8026c8:	89 c2                	mov    %eax,%edx
  8026ca:	85 c0                	test   %eax,%eax
  8026cc:	78 6d                	js     80273b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8026ce:	83 ec 08             	sub    $0x8,%esp
  8026d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026d4:	50                   	push   %eax
  8026d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026d8:	ff 30                	pushl  (%eax)
  8026da:	e8 c2 fd ff ff       	call   8024a1 <dev_lookup>
  8026df:	83 c4 10             	add    $0x10,%esp
  8026e2:	85 c0                	test   %eax,%eax
  8026e4:	78 4c                	js     802732 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8026e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026e9:	8b 42 08             	mov    0x8(%edx),%eax
  8026ec:	83 e0 03             	and    $0x3,%eax
  8026ef:	83 f8 01             	cmp    $0x1,%eax
  8026f2:	75 21                	jne    802715 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8026f4:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8026f9:	8b 40 48             	mov    0x48(%eax),%eax
  8026fc:	83 ec 04             	sub    $0x4,%esp
  8026ff:	53                   	push   %ebx
  802700:	50                   	push   %eax
  802701:	68 cc 3a 80 00       	push   $0x803acc
  802706:	e8 0a ed ff ff       	call   801415 <cprintf>
		return -E_INVAL;
  80270b:	83 c4 10             	add    $0x10,%esp
  80270e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802713:	eb 26                	jmp    80273b <read+0x8a>
	}
	if (!dev->dev_read)
  802715:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802718:	8b 40 08             	mov    0x8(%eax),%eax
  80271b:	85 c0                	test   %eax,%eax
  80271d:	74 17                	je     802736 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80271f:	83 ec 04             	sub    $0x4,%esp
  802722:	ff 75 10             	pushl  0x10(%ebp)
  802725:	ff 75 0c             	pushl  0xc(%ebp)
  802728:	52                   	push   %edx
  802729:	ff d0                	call   *%eax
  80272b:	89 c2                	mov    %eax,%edx
  80272d:	83 c4 10             	add    $0x10,%esp
  802730:	eb 09                	jmp    80273b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802732:	89 c2                	mov    %eax,%edx
  802734:	eb 05                	jmp    80273b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802736:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80273b:	89 d0                	mov    %edx,%eax
  80273d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802740:	c9                   	leave  
  802741:	c3                   	ret    

00802742 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802742:	55                   	push   %ebp
  802743:	89 e5                	mov    %esp,%ebp
  802745:	57                   	push   %edi
  802746:	56                   	push   %esi
  802747:	53                   	push   %ebx
  802748:	83 ec 0c             	sub    $0xc,%esp
  80274b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80274e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802751:	bb 00 00 00 00       	mov    $0x0,%ebx
  802756:	eb 21                	jmp    802779 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802758:	83 ec 04             	sub    $0x4,%esp
  80275b:	89 f0                	mov    %esi,%eax
  80275d:	29 d8                	sub    %ebx,%eax
  80275f:	50                   	push   %eax
  802760:	89 d8                	mov    %ebx,%eax
  802762:	03 45 0c             	add    0xc(%ebp),%eax
  802765:	50                   	push   %eax
  802766:	57                   	push   %edi
  802767:	e8 45 ff ff ff       	call   8026b1 <read>
		if (m < 0)
  80276c:	83 c4 10             	add    $0x10,%esp
  80276f:	85 c0                	test   %eax,%eax
  802771:	78 10                	js     802783 <readn+0x41>
			return m;
		if (m == 0)
  802773:	85 c0                	test   %eax,%eax
  802775:	74 0a                	je     802781 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802777:	01 c3                	add    %eax,%ebx
  802779:	39 f3                	cmp    %esi,%ebx
  80277b:	72 db                	jb     802758 <readn+0x16>
  80277d:	89 d8                	mov    %ebx,%eax
  80277f:	eb 02                	jmp    802783 <readn+0x41>
  802781:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802783:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802786:	5b                   	pop    %ebx
  802787:	5e                   	pop    %esi
  802788:	5f                   	pop    %edi
  802789:	5d                   	pop    %ebp
  80278a:	c3                   	ret    

0080278b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80278b:	55                   	push   %ebp
  80278c:	89 e5                	mov    %esp,%ebp
  80278e:	53                   	push   %ebx
  80278f:	83 ec 14             	sub    $0x14,%esp
  802792:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802795:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802798:	50                   	push   %eax
  802799:	53                   	push   %ebx
  80279a:	e8 ac fc ff ff       	call   80244b <fd_lookup>
  80279f:	83 c4 08             	add    $0x8,%esp
  8027a2:	89 c2                	mov    %eax,%edx
  8027a4:	85 c0                	test   %eax,%eax
  8027a6:	78 68                	js     802810 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8027a8:	83 ec 08             	sub    $0x8,%esp
  8027ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027ae:	50                   	push   %eax
  8027af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8027b2:	ff 30                	pushl  (%eax)
  8027b4:	e8 e8 fc ff ff       	call   8024a1 <dev_lookup>
  8027b9:	83 c4 10             	add    $0x10,%esp
  8027bc:	85 c0                	test   %eax,%eax
  8027be:	78 47                	js     802807 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8027c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8027c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8027c7:	75 21                	jne    8027ea <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8027c9:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8027ce:	8b 40 48             	mov    0x48(%eax),%eax
  8027d1:	83 ec 04             	sub    $0x4,%esp
  8027d4:	53                   	push   %ebx
  8027d5:	50                   	push   %eax
  8027d6:	68 e8 3a 80 00       	push   $0x803ae8
  8027db:	e8 35 ec ff ff       	call   801415 <cprintf>
		return -E_INVAL;
  8027e0:	83 c4 10             	add    $0x10,%esp
  8027e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8027e8:	eb 26                	jmp    802810 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8027ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8027ed:	8b 52 0c             	mov    0xc(%edx),%edx
  8027f0:	85 d2                	test   %edx,%edx
  8027f2:	74 17                	je     80280b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8027f4:	83 ec 04             	sub    $0x4,%esp
  8027f7:	ff 75 10             	pushl  0x10(%ebp)
  8027fa:	ff 75 0c             	pushl  0xc(%ebp)
  8027fd:	50                   	push   %eax
  8027fe:	ff d2                	call   *%edx
  802800:	89 c2                	mov    %eax,%edx
  802802:	83 c4 10             	add    $0x10,%esp
  802805:	eb 09                	jmp    802810 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802807:	89 c2                	mov    %eax,%edx
  802809:	eb 05                	jmp    802810 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80280b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802810:	89 d0                	mov    %edx,%eax
  802812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802815:	c9                   	leave  
  802816:	c3                   	ret    

00802817 <seek>:

int
seek(int fdnum, off_t offset)
{
  802817:	55                   	push   %ebp
  802818:	89 e5                	mov    %esp,%ebp
  80281a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80281d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802820:	50                   	push   %eax
  802821:	ff 75 08             	pushl  0x8(%ebp)
  802824:	e8 22 fc ff ff       	call   80244b <fd_lookup>
  802829:	83 c4 08             	add    $0x8,%esp
  80282c:	85 c0                	test   %eax,%eax
  80282e:	78 0e                	js     80283e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802830:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802833:	8b 55 0c             	mov    0xc(%ebp),%edx
  802836:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802839:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80283e:	c9                   	leave  
  80283f:	c3                   	ret    

00802840 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802840:	55                   	push   %ebp
  802841:	89 e5                	mov    %esp,%ebp
  802843:	53                   	push   %ebx
  802844:	83 ec 14             	sub    $0x14,%esp
  802847:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80284a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80284d:	50                   	push   %eax
  80284e:	53                   	push   %ebx
  80284f:	e8 f7 fb ff ff       	call   80244b <fd_lookup>
  802854:	83 c4 08             	add    $0x8,%esp
  802857:	89 c2                	mov    %eax,%edx
  802859:	85 c0                	test   %eax,%eax
  80285b:	78 65                	js     8028c2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80285d:	83 ec 08             	sub    $0x8,%esp
  802860:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802863:	50                   	push   %eax
  802864:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802867:	ff 30                	pushl  (%eax)
  802869:	e8 33 fc ff ff       	call   8024a1 <dev_lookup>
  80286e:	83 c4 10             	add    $0x10,%esp
  802871:	85 c0                	test   %eax,%eax
  802873:	78 44                	js     8028b9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802878:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80287c:	75 21                	jne    80289f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80287e:	a1 0c 90 80 00       	mov    0x80900c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802883:	8b 40 48             	mov    0x48(%eax),%eax
  802886:	83 ec 04             	sub    $0x4,%esp
  802889:	53                   	push   %ebx
  80288a:	50                   	push   %eax
  80288b:	68 a8 3a 80 00       	push   $0x803aa8
  802890:	e8 80 eb ff ff       	call   801415 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802895:	83 c4 10             	add    $0x10,%esp
  802898:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80289d:	eb 23                	jmp    8028c2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80289f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8028a2:	8b 52 18             	mov    0x18(%edx),%edx
  8028a5:	85 d2                	test   %edx,%edx
  8028a7:	74 14                	je     8028bd <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8028a9:	83 ec 08             	sub    $0x8,%esp
  8028ac:	ff 75 0c             	pushl  0xc(%ebp)
  8028af:	50                   	push   %eax
  8028b0:	ff d2                	call   *%edx
  8028b2:	89 c2                	mov    %eax,%edx
  8028b4:	83 c4 10             	add    $0x10,%esp
  8028b7:	eb 09                	jmp    8028c2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8028b9:	89 c2                	mov    %eax,%edx
  8028bb:	eb 05                	jmp    8028c2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8028bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8028c2:	89 d0                	mov    %edx,%eax
  8028c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8028c7:	c9                   	leave  
  8028c8:	c3                   	ret    

008028c9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8028c9:	55                   	push   %ebp
  8028ca:	89 e5                	mov    %esp,%ebp
  8028cc:	53                   	push   %ebx
  8028cd:	83 ec 14             	sub    $0x14,%esp
  8028d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8028d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8028d6:	50                   	push   %eax
  8028d7:	ff 75 08             	pushl  0x8(%ebp)
  8028da:	e8 6c fb ff ff       	call   80244b <fd_lookup>
  8028df:	83 c4 08             	add    $0x8,%esp
  8028e2:	89 c2                	mov    %eax,%edx
  8028e4:	85 c0                	test   %eax,%eax
  8028e6:	78 58                	js     802940 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8028e8:	83 ec 08             	sub    $0x8,%esp
  8028eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028ee:	50                   	push   %eax
  8028ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028f2:	ff 30                	pushl  (%eax)
  8028f4:	e8 a8 fb ff ff       	call   8024a1 <dev_lookup>
  8028f9:	83 c4 10             	add    $0x10,%esp
  8028fc:	85 c0                	test   %eax,%eax
  8028fe:	78 37                	js     802937 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802900:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802903:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802907:	74 32                	je     80293b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802909:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80290c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802913:	00 00 00 
	stat->st_isdir = 0;
  802916:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80291d:	00 00 00 
	stat->st_dev = dev;
  802920:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802926:	83 ec 08             	sub    $0x8,%esp
  802929:	53                   	push   %ebx
  80292a:	ff 75 f0             	pushl  -0x10(%ebp)
  80292d:	ff 50 14             	call   *0x14(%eax)
  802930:	89 c2                	mov    %eax,%edx
  802932:	83 c4 10             	add    $0x10,%esp
  802935:	eb 09                	jmp    802940 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802937:	89 c2                	mov    %eax,%edx
  802939:	eb 05                	jmp    802940 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80293b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802940:	89 d0                	mov    %edx,%eax
  802942:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802945:	c9                   	leave  
  802946:	c3                   	ret    

00802947 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802947:	55                   	push   %ebp
  802948:	89 e5                	mov    %esp,%ebp
  80294a:	56                   	push   %esi
  80294b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80294c:	83 ec 08             	sub    $0x8,%esp
  80294f:	6a 00                	push   $0x0
  802951:	ff 75 08             	pushl  0x8(%ebp)
  802954:	e8 9d f9 ff ff       	call   8022f6 <open>
  802959:	89 c3                	mov    %eax,%ebx
  80295b:	83 c4 10             	add    $0x10,%esp
  80295e:	85 c0                	test   %eax,%eax
  802960:	78 1b                	js     80297d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802962:	83 ec 08             	sub    $0x8,%esp
  802965:	ff 75 0c             	pushl  0xc(%ebp)
  802968:	50                   	push   %eax
  802969:	e8 5b ff ff ff       	call   8028c9 <fstat>
  80296e:	89 c6                	mov    %eax,%esi
	close(fd);
  802970:	89 1c 24             	mov    %ebx,(%esp)
  802973:	e8 fd fb ff ff       	call   802575 <close>
	return r;
  802978:	83 c4 10             	add    $0x10,%esp
  80297b:	89 f0                	mov    %esi,%eax
}
  80297d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802980:	5b                   	pop    %ebx
  802981:	5e                   	pop    %esi
  802982:	5d                   	pop    %ebp
  802983:	c3                   	ret    

00802984 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802984:	55                   	push   %ebp
  802985:	89 e5                	mov    %esp,%ebp
  802987:	56                   	push   %esi
  802988:	53                   	push   %ebx
  802989:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80298c:	83 ec 0c             	sub    $0xc,%esp
  80298f:	ff 75 08             	pushl  0x8(%ebp)
  802992:	e8 4e fa ff ff       	call   8023e5 <fd2data>
  802997:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802999:	83 c4 08             	add    $0x8,%esp
  80299c:	68 18 3b 80 00       	push   $0x803b18
  8029a1:	53                   	push   %ebx
  8029a2:	e8 f3 ef ff ff       	call   80199a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8029a7:	8b 46 04             	mov    0x4(%esi),%eax
  8029aa:	2b 06                	sub    (%esi),%eax
  8029ac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8029b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8029b9:	00 00 00 
	stat->st_dev = &devpipe;
  8029bc:	c7 83 88 00 00 00 80 	movl   $0x808080,0x88(%ebx)
  8029c3:	80 80 00 
	return 0;
}
  8029c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8029cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029ce:	5b                   	pop    %ebx
  8029cf:	5e                   	pop    %esi
  8029d0:	5d                   	pop    %ebp
  8029d1:	c3                   	ret    

008029d2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8029d2:	55                   	push   %ebp
  8029d3:	89 e5                	mov    %esp,%ebp
  8029d5:	53                   	push   %ebx
  8029d6:	83 ec 0c             	sub    $0xc,%esp
  8029d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8029dc:	53                   	push   %ebx
  8029dd:	6a 00                	push   $0x0
  8029df:	e8 3e f4 ff ff       	call   801e22 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8029e4:	89 1c 24             	mov    %ebx,(%esp)
  8029e7:	e8 f9 f9 ff ff       	call   8023e5 <fd2data>
  8029ec:	83 c4 08             	add    $0x8,%esp
  8029ef:	50                   	push   %eax
  8029f0:	6a 00                	push   $0x0
  8029f2:	e8 2b f4 ff ff       	call   801e22 <sys_page_unmap>
}
  8029f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8029fa:	c9                   	leave  
  8029fb:	c3                   	ret    

008029fc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8029fc:	55                   	push   %ebp
  8029fd:	89 e5                	mov    %esp,%ebp
  8029ff:	57                   	push   %edi
  802a00:	56                   	push   %esi
  802a01:	53                   	push   %ebx
  802a02:	83 ec 1c             	sub    $0x1c,%esp
  802a05:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802a08:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802a0a:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802a0f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802a12:	83 ec 0c             	sub    $0xc,%esp
  802a15:	ff 75 e0             	pushl  -0x20(%ebp)
  802a18:	e8 7d f9 ff ff       	call   80239a <pageref>
  802a1d:	89 c3                	mov    %eax,%ebx
  802a1f:	89 3c 24             	mov    %edi,(%esp)
  802a22:	e8 73 f9 ff ff       	call   80239a <pageref>
  802a27:	83 c4 10             	add    $0x10,%esp
  802a2a:	39 c3                	cmp    %eax,%ebx
  802a2c:	0f 94 c1             	sete   %cl
  802a2f:	0f b6 c9             	movzbl %cl,%ecx
  802a32:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802a35:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  802a3b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802a3e:	39 ce                	cmp    %ecx,%esi
  802a40:	74 1b                	je     802a5d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802a42:	39 c3                	cmp    %eax,%ebx
  802a44:	75 c4                	jne    802a0a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802a46:	8b 42 58             	mov    0x58(%edx),%eax
  802a49:	ff 75 e4             	pushl  -0x1c(%ebp)
  802a4c:	50                   	push   %eax
  802a4d:	56                   	push   %esi
  802a4e:	68 1f 3b 80 00       	push   $0x803b1f
  802a53:	e8 bd e9 ff ff       	call   801415 <cprintf>
  802a58:	83 c4 10             	add    $0x10,%esp
  802a5b:	eb ad                	jmp    802a0a <_pipeisclosed+0xe>
	}
}
  802a5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a63:	5b                   	pop    %ebx
  802a64:	5e                   	pop    %esi
  802a65:	5f                   	pop    %edi
  802a66:	5d                   	pop    %ebp
  802a67:	c3                   	ret    

00802a68 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802a68:	55                   	push   %ebp
  802a69:	89 e5                	mov    %esp,%ebp
  802a6b:	57                   	push   %edi
  802a6c:	56                   	push   %esi
  802a6d:	53                   	push   %ebx
  802a6e:	83 ec 28             	sub    $0x28,%esp
  802a71:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802a74:	56                   	push   %esi
  802a75:	e8 6b f9 ff ff       	call   8023e5 <fd2data>
  802a7a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802a7c:	83 c4 10             	add    $0x10,%esp
  802a7f:	bf 00 00 00 00       	mov    $0x0,%edi
  802a84:	eb 4b                	jmp    802ad1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802a86:	89 da                	mov    %ebx,%edx
  802a88:	89 f0                	mov    %esi,%eax
  802a8a:	e8 6d ff ff ff       	call   8029fc <_pipeisclosed>
  802a8f:	85 c0                	test   %eax,%eax
  802a91:	75 48                	jne    802adb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802a93:	e8 e6 f2 ff ff       	call   801d7e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802a98:	8b 43 04             	mov    0x4(%ebx),%eax
  802a9b:	8b 0b                	mov    (%ebx),%ecx
  802a9d:	8d 51 20             	lea    0x20(%ecx),%edx
  802aa0:	39 d0                	cmp    %edx,%eax
  802aa2:	73 e2                	jae    802a86 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802aa4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802aa7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802aab:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802aae:	89 c2                	mov    %eax,%edx
  802ab0:	c1 fa 1f             	sar    $0x1f,%edx
  802ab3:	89 d1                	mov    %edx,%ecx
  802ab5:	c1 e9 1b             	shr    $0x1b,%ecx
  802ab8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802abb:	83 e2 1f             	and    $0x1f,%edx
  802abe:	29 ca                	sub    %ecx,%edx
  802ac0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802ac4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802ac8:	83 c0 01             	add    $0x1,%eax
  802acb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ace:	83 c7 01             	add    $0x1,%edi
  802ad1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802ad4:	75 c2                	jne    802a98 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802ad6:	8b 45 10             	mov    0x10(%ebp),%eax
  802ad9:	eb 05                	jmp    802ae0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802adb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802ae0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ae3:	5b                   	pop    %ebx
  802ae4:	5e                   	pop    %esi
  802ae5:	5f                   	pop    %edi
  802ae6:	5d                   	pop    %ebp
  802ae7:	c3                   	ret    

00802ae8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802ae8:	55                   	push   %ebp
  802ae9:	89 e5                	mov    %esp,%ebp
  802aeb:	57                   	push   %edi
  802aec:	56                   	push   %esi
  802aed:	53                   	push   %ebx
  802aee:	83 ec 18             	sub    $0x18,%esp
  802af1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802af4:	57                   	push   %edi
  802af5:	e8 eb f8 ff ff       	call   8023e5 <fd2data>
  802afa:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802afc:	83 c4 10             	add    $0x10,%esp
  802aff:	bb 00 00 00 00       	mov    $0x0,%ebx
  802b04:	eb 3d                	jmp    802b43 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802b06:	85 db                	test   %ebx,%ebx
  802b08:	74 04                	je     802b0e <devpipe_read+0x26>
				return i;
  802b0a:	89 d8                	mov    %ebx,%eax
  802b0c:	eb 44                	jmp    802b52 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802b0e:	89 f2                	mov    %esi,%edx
  802b10:	89 f8                	mov    %edi,%eax
  802b12:	e8 e5 fe ff ff       	call   8029fc <_pipeisclosed>
  802b17:	85 c0                	test   %eax,%eax
  802b19:	75 32                	jne    802b4d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802b1b:	e8 5e f2 ff ff       	call   801d7e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802b20:	8b 06                	mov    (%esi),%eax
  802b22:	3b 46 04             	cmp    0x4(%esi),%eax
  802b25:	74 df                	je     802b06 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802b27:	99                   	cltd   
  802b28:	c1 ea 1b             	shr    $0x1b,%edx
  802b2b:	01 d0                	add    %edx,%eax
  802b2d:	83 e0 1f             	and    $0x1f,%eax
  802b30:	29 d0                	sub    %edx,%eax
  802b32:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b3a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802b3d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b40:	83 c3 01             	add    $0x1,%ebx
  802b43:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802b46:	75 d8                	jne    802b20 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802b48:	8b 45 10             	mov    0x10(%ebp),%eax
  802b4b:	eb 05                	jmp    802b52 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802b4d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802b52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b55:	5b                   	pop    %ebx
  802b56:	5e                   	pop    %esi
  802b57:	5f                   	pop    %edi
  802b58:	5d                   	pop    %ebp
  802b59:	c3                   	ret    

00802b5a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802b5a:	55                   	push   %ebp
  802b5b:	89 e5                	mov    %esp,%ebp
  802b5d:	56                   	push   %esi
  802b5e:	53                   	push   %ebx
  802b5f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802b62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b65:	50                   	push   %eax
  802b66:	e8 91 f8 ff ff       	call   8023fc <fd_alloc>
  802b6b:	83 c4 10             	add    $0x10,%esp
  802b6e:	89 c2                	mov    %eax,%edx
  802b70:	85 c0                	test   %eax,%eax
  802b72:	0f 88 2c 01 00 00    	js     802ca4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802b78:	83 ec 04             	sub    $0x4,%esp
  802b7b:	68 07 04 00 00       	push   $0x407
  802b80:	ff 75 f4             	pushl  -0xc(%ebp)
  802b83:	6a 00                	push   $0x0
  802b85:	e8 13 f2 ff ff       	call   801d9d <sys_page_alloc>
  802b8a:	83 c4 10             	add    $0x10,%esp
  802b8d:	89 c2                	mov    %eax,%edx
  802b8f:	85 c0                	test   %eax,%eax
  802b91:	0f 88 0d 01 00 00    	js     802ca4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802b97:	83 ec 0c             	sub    $0xc,%esp
  802b9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b9d:	50                   	push   %eax
  802b9e:	e8 59 f8 ff ff       	call   8023fc <fd_alloc>
  802ba3:	89 c3                	mov    %eax,%ebx
  802ba5:	83 c4 10             	add    $0x10,%esp
  802ba8:	85 c0                	test   %eax,%eax
  802baa:	0f 88 e2 00 00 00    	js     802c92 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802bb0:	83 ec 04             	sub    $0x4,%esp
  802bb3:	68 07 04 00 00       	push   $0x407
  802bb8:	ff 75 f0             	pushl  -0x10(%ebp)
  802bbb:	6a 00                	push   $0x0
  802bbd:	e8 db f1 ff ff       	call   801d9d <sys_page_alloc>
  802bc2:	89 c3                	mov    %eax,%ebx
  802bc4:	83 c4 10             	add    $0x10,%esp
  802bc7:	85 c0                	test   %eax,%eax
  802bc9:	0f 88 c3 00 00 00    	js     802c92 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802bcf:	83 ec 0c             	sub    $0xc,%esp
  802bd2:	ff 75 f4             	pushl  -0xc(%ebp)
  802bd5:	e8 0b f8 ff ff       	call   8023e5 <fd2data>
  802bda:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802bdc:	83 c4 0c             	add    $0xc,%esp
  802bdf:	68 07 04 00 00       	push   $0x407
  802be4:	50                   	push   %eax
  802be5:	6a 00                	push   $0x0
  802be7:	e8 b1 f1 ff ff       	call   801d9d <sys_page_alloc>
  802bec:	89 c3                	mov    %eax,%ebx
  802bee:	83 c4 10             	add    $0x10,%esp
  802bf1:	85 c0                	test   %eax,%eax
  802bf3:	0f 88 89 00 00 00    	js     802c82 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802bf9:	83 ec 0c             	sub    $0xc,%esp
  802bfc:	ff 75 f0             	pushl  -0x10(%ebp)
  802bff:	e8 e1 f7 ff ff       	call   8023e5 <fd2data>
  802c04:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802c0b:	50                   	push   %eax
  802c0c:	6a 00                	push   $0x0
  802c0e:	56                   	push   %esi
  802c0f:	6a 00                	push   $0x0
  802c11:	e8 ca f1 ff ff       	call   801de0 <sys_page_map>
  802c16:	89 c3                	mov    %eax,%ebx
  802c18:	83 c4 20             	add    $0x20,%esp
  802c1b:	85 c0                	test   %eax,%eax
  802c1d:	78 55                	js     802c74 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802c1f:	8b 15 80 80 80 00    	mov    0x808080,%edx
  802c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c28:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c2d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802c34:	8b 15 80 80 80 00    	mov    0x808080,%edx
  802c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c3d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802c3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c42:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802c49:	83 ec 0c             	sub    $0xc,%esp
  802c4c:	ff 75 f4             	pushl  -0xc(%ebp)
  802c4f:	e8 81 f7 ff ff       	call   8023d5 <fd2num>
  802c54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802c57:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802c59:	83 c4 04             	add    $0x4,%esp
  802c5c:	ff 75 f0             	pushl  -0x10(%ebp)
  802c5f:	e8 71 f7 ff ff       	call   8023d5 <fd2num>
  802c64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802c67:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802c6a:	83 c4 10             	add    $0x10,%esp
  802c6d:	ba 00 00 00 00       	mov    $0x0,%edx
  802c72:	eb 30                	jmp    802ca4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802c74:	83 ec 08             	sub    $0x8,%esp
  802c77:	56                   	push   %esi
  802c78:	6a 00                	push   $0x0
  802c7a:	e8 a3 f1 ff ff       	call   801e22 <sys_page_unmap>
  802c7f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802c82:	83 ec 08             	sub    $0x8,%esp
  802c85:	ff 75 f0             	pushl  -0x10(%ebp)
  802c88:	6a 00                	push   $0x0
  802c8a:	e8 93 f1 ff ff       	call   801e22 <sys_page_unmap>
  802c8f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802c92:	83 ec 08             	sub    $0x8,%esp
  802c95:	ff 75 f4             	pushl  -0xc(%ebp)
  802c98:	6a 00                	push   $0x0
  802c9a:	e8 83 f1 ff ff       	call   801e22 <sys_page_unmap>
  802c9f:	83 c4 10             	add    $0x10,%esp
  802ca2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802ca4:	89 d0                	mov    %edx,%eax
  802ca6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ca9:	5b                   	pop    %ebx
  802caa:	5e                   	pop    %esi
  802cab:	5d                   	pop    %ebp
  802cac:	c3                   	ret    

00802cad <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802cad:	55                   	push   %ebp
  802cae:	89 e5                	mov    %esp,%ebp
  802cb0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802cb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cb6:	50                   	push   %eax
  802cb7:	ff 75 08             	pushl  0x8(%ebp)
  802cba:	e8 8c f7 ff ff       	call   80244b <fd_lookup>
  802cbf:	83 c4 10             	add    $0x10,%esp
  802cc2:	85 c0                	test   %eax,%eax
  802cc4:	78 18                	js     802cde <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802cc6:	83 ec 0c             	sub    $0xc,%esp
  802cc9:	ff 75 f4             	pushl  -0xc(%ebp)
  802ccc:	e8 14 f7 ff ff       	call   8023e5 <fd2data>
	return _pipeisclosed(fd, p);
  802cd1:	89 c2                	mov    %eax,%edx
  802cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cd6:	e8 21 fd ff ff       	call   8029fc <_pipeisclosed>
  802cdb:	83 c4 10             	add    $0x10,%esp
}
  802cde:	c9                   	leave  
  802cdf:	c3                   	ret    

00802ce0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802ce0:	55                   	push   %ebp
  802ce1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802ce3:	b8 00 00 00 00       	mov    $0x0,%eax
  802ce8:	5d                   	pop    %ebp
  802ce9:	c3                   	ret    

00802cea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802cea:	55                   	push   %ebp
  802ceb:	89 e5                	mov    %esp,%ebp
  802ced:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802cf0:	68 37 3b 80 00       	push   $0x803b37
  802cf5:	ff 75 0c             	pushl  0xc(%ebp)
  802cf8:	e8 9d ec ff ff       	call   80199a <strcpy>
	return 0;
}
  802cfd:	b8 00 00 00 00       	mov    $0x0,%eax
  802d02:	c9                   	leave  
  802d03:	c3                   	ret    

00802d04 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802d04:	55                   	push   %ebp
  802d05:	89 e5                	mov    %esp,%ebp
  802d07:	57                   	push   %edi
  802d08:	56                   	push   %esi
  802d09:	53                   	push   %ebx
  802d0a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802d10:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802d15:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802d1b:	eb 2d                	jmp    802d4a <devcons_write+0x46>
		m = n - tot;
  802d1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802d20:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802d22:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802d25:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802d2a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802d2d:	83 ec 04             	sub    $0x4,%esp
  802d30:	53                   	push   %ebx
  802d31:	03 45 0c             	add    0xc(%ebp),%eax
  802d34:	50                   	push   %eax
  802d35:	57                   	push   %edi
  802d36:	e8 f1 ed ff ff       	call   801b2c <memmove>
		sys_cputs(buf, m);
  802d3b:	83 c4 08             	add    $0x8,%esp
  802d3e:	53                   	push   %ebx
  802d3f:	57                   	push   %edi
  802d40:	e8 9c ef ff ff       	call   801ce1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802d45:	01 de                	add    %ebx,%esi
  802d47:	83 c4 10             	add    $0x10,%esp
  802d4a:	89 f0                	mov    %esi,%eax
  802d4c:	3b 75 10             	cmp    0x10(%ebp),%esi
  802d4f:	72 cc                	jb     802d1d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d54:	5b                   	pop    %ebx
  802d55:	5e                   	pop    %esi
  802d56:	5f                   	pop    %edi
  802d57:	5d                   	pop    %ebp
  802d58:	c3                   	ret    

00802d59 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802d59:	55                   	push   %ebp
  802d5a:	89 e5                	mov    %esp,%ebp
  802d5c:	83 ec 08             	sub    $0x8,%esp
  802d5f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802d64:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802d68:	74 2a                	je     802d94 <devcons_read+0x3b>
  802d6a:	eb 05                	jmp    802d71 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802d6c:	e8 0d f0 ff ff       	call   801d7e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802d71:	e8 89 ef ff ff       	call   801cff <sys_cgetc>
  802d76:	85 c0                	test   %eax,%eax
  802d78:	74 f2                	je     802d6c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802d7a:	85 c0                	test   %eax,%eax
  802d7c:	78 16                	js     802d94 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802d7e:	83 f8 04             	cmp    $0x4,%eax
  802d81:	74 0c                	je     802d8f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802d83:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d86:	88 02                	mov    %al,(%edx)
	return 1;
  802d88:	b8 01 00 00 00       	mov    $0x1,%eax
  802d8d:	eb 05                	jmp    802d94 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802d8f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802d94:	c9                   	leave  
  802d95:	c3                   	ret    

00802d96 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802d96:	55                   	push   %ebp
  802d97:	89 e5                	mov    %esp,%ebp
  802d99:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  802d9f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802da2:	6a 01                	push   $0x1
  802da4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802da7:	50                   	push   %eax
  802da8:	e8 34 ef ff ff       	call   801ce1 <sys_cputs>
}
  802dad:	83 c4 10             	add    $0x10,%esp
  802db0:	c9                   	leave  
  802db1:	c3                   	ret    

00802db2 <getchar>:

int
getchar(void)
{
  802db2:	55                   	push   %ebp
  802db3:	89 e5                	mov    %esp,%ebp
  802db5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802db8:	6a 01                	push   $0x1
  802dba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802dbd:	50                   	push   %eax
  802dbe:	6a 00                	push   $0x0
  802dc0:	e8 ec f8 ff ff       	call   8026b1 <read>
	if (r < 0)
  802dc5:	83 c4 10             	add    $0x10,%esp
  802dc8:	85 c0                	test   %eax,%eax
  802dca:	78 0f                	js     802ddb <getchar+0x29>
		return r;
	if (r < 1)
  802dcc:	85 c0                	test   %eax,%eax
  802dce:	7e 06                	jle    802dd6 <getchar+0x24>
		return -E_EOF;
	return c;
  802dd0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802dd4:	eb 05                	jmp    802ddb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802dd6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802ddb:	c9                   	leave  
  802ddc:	c3                   	ret    

00802ddd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802ddd:	55                   	push   %ebp
  802dde:	89 e5                	mov    %esp,%ebp
  802de0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802de3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802de6:	50                   	push   %eax
  802de7:	ff 75 08             	pushl  0x8(%ebp)
  802dea:	e8 5c f6 ff ff       	call   80244b <fd_lookup>
  802def:	83 c4 10             	add    $0x10,%esp
  802df2:	85 c0                	test   %eax,%eax
  802df4:	78 11                	js     802e07 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802df9:	8b 15 9c 80 80 00    	mov    0x80809c,%edx
  802dff:	39 10                	cmp    %edx,(%eax)
  802e01:	0f 94 c0             	sete   %al
  802e04:	0f b6 c0             	movzbl %al,%eax
}
  802e07:	c9                   	leave  
  802e08:	c3                   	ret    

00802e09 <opencons>:

int
opencons(void)
{
  802e09:	55                   	push   %ebp
  802e0a:	89 e5                	mov    %esp,%ebp
  802e0c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802e0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e12:	50                   	push   %eax
  802e13:	e8 e4 f5 ff ff       	call   8023fc <fd_alloc>
  802e18:	83 c4 10             	add    $0x10,%esp
		return r;
  802e1b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802e1d:	85 c0                	test   %eax,%eax
  802e1f:	78 3e                	js     802e5f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802e21:	83 ec 04             	sub    $0x4,%esp
  802e24:	68 07 04 00 00       	push   $0x407
  802e29:	ff 75 f4             	pushl  -0xc(%ebp)
  802e2c:	6a 00                	push   $0x0
  802e2e:	e8 6a ef ff ff       	call   801d9d <sys_page_alloc>
  802e33:	83 c4 10             	add    $0x10,%esp
		return r;
  802e36:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802e38:	85 c0                	test   %eax,%eax
  802e3a:	78 23                	js     802e5f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802e3c:	8b 15 9c 80 80 00    	mov    0x80809c,%edx
  802e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e45:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e4a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802e51:	83 ec 0c             	sub    $0xc,%esp
  802e54:	50                   	push   %eax
  802e55:	e8 7b f5 ff ff       	call   8023d5 <fd2num>
  802e5a:	89 c2                	mov    %eax,%edx
  802e5c:	83 c4 10             	add    $0x10,%esp
}
  802e5f:	89 d0                	mov    %edx,%eax
  802e61:	c9                   	leave  
  802e62:	c3                   	ret    
  802e63:	66 90                	xchg   %ax,%ax
  802e65:	66 90                	xchg   %ax,%ax
  802e67:	66 90                	xchg   %ax,%ax
  802e69:	66 90                	xchg   %ax,%ax
  802e6b:	66 90                	xchg   %ax,%ax
  802e6d:	66 90                	xchg   %ax,%ax
  802e6f:	90                   	nop

00802e70 <__udivdi3>:
  802e70:	55                   	push   %ebp
  802e71:	57                   	push   %edi
  802e72:	56                   	push   %esi
  802e73:	53                   	push   %ebx
  802e74:	83 ec 1c             	sub    $0x1c,%esp
  802e77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802e7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802e7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802e83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802e87:	85 f6                	test   %esi,%esi
  802e89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802e8d:	89 ca                	mov    %ecx,%edx
  802e8f:	89 f8                	mov    %edi,%eax
  802e91:	75 3d                	jne    802ed0 <__udivdi3+0x60>
  802e93:	39 cf                	cmp    %ecx,%edi
  802e95:	0f 87 c5 00 00 00    	ja     802f60 <__udivdi3+0xf0>
  802e9b:	85 ff                	test   %edi,%edi
  802e9d:	89 fd                	mov    %edi,%ebp
  802e9f:	75 0b                	jne    802eac <__udivdi3+0x3c>
  802ea1:	b8 01 00 00 00       	mov    $0x1,%eax
  802ea6:	31 d2                	xor    %edx,%edx
  802ea8:	f7 f7                	div    %edi
  802eaa:	89 c5                	mov    %eax,%ebp
  802eac:	89 c8                	mov    %ecx,%eax
  802eae:	31 d2                	xor    %edx,%edx
  802eb0:	f7 f5                	div    %ebp
  802eb2:	89 c1                	mov    %eax,%ecx
  802eb4:	89 d8                	mov    %ebx,%eax
  802eb6:	89 cf                	mov    %ecx,%edi
  802eb8:	f7 f5                	div    %ebp
  802eba:	89 c3                	mov    %eax,%ebx
  802ebc:	89 d8                	mov    %ebx,%eax
  802ebe:	89 fa                	mov    %edi,%edx
  802ec0:	83 c4 1c             	add    $0x1c,%esp
  802ec3:	5b                   	pop    %ebx
  802ec4:	5e                   	pop    %esi
  802ec5:	5f                   	pop    %edi
  802ec6:	5d                   	pop    %ebp
  802ec7:	c3                   	ret    
  802ec8:	90                   	nop
  802ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ed0:	39 ce                	cmp    %ecx,%esi
  802ed2:	77 74                	ja     802f48 <__udivdi3+0xd8>
  802ed4:	0f bd fe             	bsr    %esi,%edi
  802ed7:	83 f7 1f             	xor    $0x1f,%edi
  802eda:	0f 84 98 00 00 00    	je     802f78 <__udivdi3+0x108>
  802ee0:	bb 20 00 00 00       	mov    $0x20,%ebx
  802ee5:	89 f9                	mov    %edi,%ecx
  802ee7:	89 c5                	mov    %eax,%ebp
  802ee9:	29 fb                	sub    %edi,%ebx
  802eeb:	d3 e6                	shl    %cl,%esi
  802eed:	89 d9                	mov    %ebx,%ecx
  802eef:	d3 ed                	shr    %cl,%ebp
  802ef1:	89 f9                	mov    %edi,%ecx
  802ef3:	d3 e0                	shl    %cl,%eax
  802ef5:	09 ee                	or     %ebp,%esi
  802ef7:	89 d9                	mov    %ebx,%ecx
  802ef9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802efd:	89 d5                	mov    %edx,%ebp
  802eff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802f03:	d3 ed                	shr    %cl,%ebp
  802f05:	89 f9                	mov    %edi,%ecx
  802f07:	d3 e2                	shl    %cl,%edx
  802f09:	89 d9                	mov    %ebx,%ecx
  802f0b:	d3 e8                	shr    %cl,%eax
  802f0d:	09 c2                	or     %eax,%edx
  802f0f:	89 d0                	mov    %edx,%eax
  802f11:	89 ea                	mov    %ebp,%edx
  802f13:	f7 f6                	div    %esi
  802f15:	89 d5                	mov    %edx,%ebp
  802f17:	89 c3                	mov    %eax,%ebx
  802f19:	f7 64 24 0c          	mull   0xc(%esp)
  802f1d:	39 d5                	cmp    %edx,%ebp
  802f1f:	72 10                	jb     802f31 <__udivdi3+0xc1>
  802f21:	8b 74 24 08          	mov    0x8(%esp),%esi
  802f25:	89 f9                	mov    %edi,%ecx
  802f27:	d3 e6                	shl    %cl,%esi
  802f29:	39 c6                	cmp    %eax,%esi
  802f2b:	73 07                	jae    802f34 <__udivdi3+0xc4>
  802f2d:	39 d5                	cmp    %edx,%ebp
  802f2f:	75 03                	jne    802f34 <__udivdi3+0xc4>
  802f31:	83 eb 01             	sub    $0x1,%ebx
  802f34:	31 ff                	xor    %edi,%edi
  802f36:	89 d8                	mov    %ebx,%eax
  802f38:	89 fa                	mov    %edi,%edx
  802f3a:	83 c4 1c             	add    $0x1c,%esp
  802f3d:	5b                   	pop    %ebx
  802f3e:	5e                   	pop    %esi
  802f3f:	5f                   	pop    %edi
  802f40:	5d                   	pop    %ebp
  802f41:	c3                   	ret    
  802f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802f48:	31 ff                	xor    %edi,%edi
  802f4a:	31 db                	xor    %ebx,%ebx
  802f4c:	89 d8                	mov    %ebx,%eax
  802f4e:	89 fa                	mov    %edi,%edx
  802f50:	83 c4 1c             	add    $0x1c,%esp
  802f53:	5b                   	pop    %ebx
  802f54:	5e                   	pop    %esi
  802f55:	5f                   	pop    %edi
  802f56:	5d                   	pop    %ebp
  802f57:	c3                   	ret    
  802f58:	90                   	nop
  802f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802f60:	89 d8                	mov    %ebx,%eax
  802f62:	f7 f7                	div    %edi
  802f64:	31 ff                	xor    %edi,%edi
  802f66:	89 c3                	mov    %eax,%ebx
  802f68:	89 d8                	mov    %ebx,%eax
  802f6a:	89 fa                	mov    %edi,%edx
  802f6c:	83 c4 1c             	add    $0x1c,%esp
  802f6f:	5b                   	pop    %ebx
  802f70:	5e                   	pop    %esi
  802f71:	5f                   	pop    %edi
  802f72:	5d                   	pop    %ebp
  802f73:	c3                   	ret    
  802f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802f78:	39 ce                	cmp    %ecx,%esi
  802f7a:	72 0c                	jb     802f88 <__udivdi3+0x118>
  802f7c:	31 db                	xor    %ebx,%ebx
  802f7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802f82:	0f 87 34 ff ff ff    	ja     802ebc <__udivdi3+0x4c>
  802f88:	bb 01 00 00 00       	mov    $0x1,%ebx
  802f8d:	e9 2a ff ff ff       	jmp    802ebc <__udivdi3+0x4c>
  802f92:	66 90                	xchg   %ax,%ax
  802f94:	66 90                	xchg   %ax,%ax
  802f96:	66 90                	xchg   %ax,%ax
  802f98:	66 90                	xchg   %ax,%ax
  802f9a:	66 90                	xchg   %ax,%ax
  802f9c:	66 90                	xchg   %ax,%ax
  802f9e:	66 90                	xchg   %ax,%ax

00802fa0 <__umoddi3>:
  802fa0:	55                   	push   %ebp
  802fa1:	57                   	push   %edi
  802fa2:	56                   	push   %esi
  802fa3:	53                   	push   %ebx
  802fa4:	83 ec 1c             	sub    $0x1c,%esp
  802fa7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802fab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802faf:	8b 74 24 34          	mov    0x34(%esp),%esi
  802fb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802fb7:	85 d2                	test   %edx,%edx
  802fb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802fbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802fc1:	89 f3                	mov    %esi,%ebx
  802fc3:	89 3c 24             	mov    %edi,(%esp)
  802fc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802fca:	75 1c                	jne    802fe8 <__umoddi3+0x48>
  802fcc:	39 f7                	cmp    %esi,%edi
  802fce:	76 50                	jbe    803020 <__umoddi3+0x80>
  802fd0:	89 c8                	mov    %ecx,%eax
  802fd2:	89 f2                	mov    %esi,%edx
  802fd4:	f7 f7                	div    %edi
  802fd6:	89 d0                	mov    %edx,%eax
  802fd8:	31 d2                	xor    %edx,%edx
  802fda:	83 c4 1c             	add    $0x1c,%esp
  802fdd:	5b                   	pop    %ebx
  802fde:	5e                   	pop    %esi
  802fdf:	5f                   	pop    %edi
  802fe0:	5d                   	pop    %ebp
  802fe1:	c3                   	ret    
  802fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802fe8:	39 f2                	cmp    %esi,%edx
  802fea:	89 d0                	mov    %edx,%eax
  802fec:	77 52                	ja     803040 <__umoddi3+0xa0>
  802fee:	0f bd ea             	bsr    %edx,%ebp
  802ff1:	83 f5 1f             	xor    $0x1f,%ebp
  802ff4:	75 5a                	jne    803050 <__umoddi3+0xb0>
  802ff6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802ffa:	0f 82 e0 00 00 00    	jb     8030e0 <__umoddi3+0x140>
  803000:	39 0c 24             	cmp    %ecx,(%esp)
  803003:	0f 86 d7 00 00 00    	jbe    8030e0 <__umoddi3+0x140>
  803009:	8b 44 24 08          	mov    0x8(%esp),%eax
  80300d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803011:	83 c4 1c             	add    $0x1c,%esp
  803014:	5b                   	pop    %ebx
  803015:	5e                   	pop    %esi
  803016:	5f                   	pop    %edi
  803017:	5d                   	pop    %ebp
  803018:	c3                   	ret    
  803019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803020:	85 ff                	test   %edi,%edi
  803022:	89 fd                	mov    %edi,%ebp
  803024:	75 0b                	jne    803031 <__umoddi3+0x91>
  803026:	b8 01 00 00 00       	mov    $0x1,%eax
  80302b:	31 d2                	xor    %edx,%edx
  80302d:	f7 f7                	div    %edi
  80302f:	89 c5                	mov    %eax,%ebp
  803031:	89 f0                	mov    %esi,%eax
  803033:	31 d2                	xor    %edx,%edx
  803035:	f7 f5                	div    %ebp
  803037:	89 c8                	mov    %ecx,%eax
  803039:	f7 f5                	div    %ebp
  80303b:	89 d0                	mov    %edx,%eax
  80303d:	eb 99                	jmp    802fd8 <__umoddi3+0x38>
  80303f:	90                   	nop
  803040:	89 c8                	mov    %ecx,%eax
  803042:	89 f2                	mov    %esi,%edx
  803044:	83 c4 1c             	add    $0x1c,%esp
  803047:	5b                   	pop    %ebx
  803048:	5e                   	pop    %esi
  803049:	5f                   	pop    %edi
  80304a:	5d                   	pop    %ebp
  80304b:	c3                   	ret    
  80304c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803050:	8b 34 24             	mov    (%esp),%esi
  803053:	bf 20 00 00 00       	mov    $0x20,%edi
  803058:	89 e9                	mov    %ebp,%ecx
  80305a:	29 ef                	sub    %ebp,%edi
  80305c:	d3 e0                	shl    %cl,%eax
  80305e:	89 f9                	mov    %edi,%ecx
  803060:	89 f2                	mov    %esi,%edx
  803062:	d3 ea                	shr    %cl,%edx
  803064:	89 e9                	mov    %ebp,%ecx
  803066:	09 c2                	or     %eax,%edx
  803068:	89 d8                	mov    %ebx,%eax
  80306a:	89 14 24             	mov    %edx,(%esp)
  80306d:	89 f2                	mov    %esi,%edx
  80306f:	d3 e2                	shl    %cl,%edx
  803071:	89 f9                	mov    %edi,%ecx
  803073:	89 54 24 04          	mov    %edx,0x4(%esp)
  803077:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80307b:	d3 e8                	shr    %cl,%eax
  80307d:	89 e9                	mov    %ebp,%ecx
  80307f:	89 c6                	mov    %eax,%esi
  803081:	d3 e3                	shl    %cl,%ebx
  803083:	89 f9                	mov    %edi,%ecx
  803085:	89 d0                	mov    %edx,%eax
  803087:	d3 e8                	shr    %cl,%eax
  803089:	89 e9                	mov    %ebp,%ecx
  80308b:	09 d8                	or     %ebx,%eax
  80308d:	89 d3                	mov    %edx,%ebx
  80308f:	89 f2                	mov    %esi,%edx
  803091:	f7 34 24             	divl   (%esp)
  803094:	89 d6                	mov    %edx,%esi
  803096:	d3 e3                	shl    %cl,%ebx
  803098:	f7 64 24 04          	mull   0x4(%esp)
  80309c:	39 d6                	cmp    %edx,%esi
  80309e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8030a2:	89 d1                	mov    %edx,%ecx
  8030a4:	89 c3                	mov    %eax,%ebx
  8030a6:	72 08                	jb     8030b0 <__umoddi3+0x110>
  8030a8:	75 11                	jne    8030bb <__umoddi3+0x11b>
  8030aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8030ae:	73 0b                	jae    8030bb <__umoddi3+0x11b>
  8030b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8030b4:	1b 14 24             	sbb    (%esp),%edx
  8030b7:	89 d1                	mov    %edx,%ecx
  8030b9:	89 c3                	mov    %eax,%ebx
  8030bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8030bf:	29 da                	sub    %ebx,%edx
  8030c1:	19 ce                	sbb    %ecx,%esi
  8030c3:	89 f9                	mov    %edi,%ecx
  8030c5:	89 f0                	mov    %esi,%eax
  8030c7:	d3 e0                	shl    %cl,%eax
  8030c9:	89 e9                	mov    %ebp,%ecx
  8030cb:	d3 ea                	shr    %cl,%edx
  8030cd:	89 e9                	mov    %ebp,%ecx
  8030cf:	d3 ee                	shr    %cl,%esi
  8030d1:	09 d0                	or     %edx,%eax
  8030d3:	89 f2                	mov    %esi,%edx
  8030d5:	83 c4 1c             	add    $0x1c,%esp
  8030d8:	5b                   	pop    %ebx
  8030d9:	5e                   	pop    %esi
  8030da:	5f                   	pop    %edi
  8030db:	5d                   	pop    %ebp
  8030dc:	c3                   	ret    
  8030dd:	8d 76 00             	lea    0x0(%esi),%esi
  8030e0:	29 f9                	sub    %edi,%ecx
  8030e2:	19 d6                	sbb    %edx,%esi
  8030e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8030e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8030ec:	e9 18 ff ff ff       	jmp    803009 <__umoddi3+0x69>
