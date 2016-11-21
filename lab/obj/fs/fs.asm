
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
  80002c:	e8 f7 18 00 00       	call   801928 <libmain>
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
  8000b2:	68 00 3c 80 00       	push   $0x803c00
  8000b7:	e8 9d 19 00 00       	call   801a59 <cprintf>
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
  8000d4:	68 17 3c 80 00       	push   $0x803c17
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 27 3c 80 00       	push   $0x803c27
  8000e0:	e8 9b 18 00 00       	call   801980 <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
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
  800106:	68 30 3c 80 00       	push   $0x803c30
  80010b:	68 3d 3c 80 00       	push   $0x803c3d
  800110:	6a 44                	push   $0x44
  800112:	68 27 3c 80 00       	push   $0x803c27
  800117:	e8 64 18 00 00       	call   801980 <_panic>

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
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
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
  8001ca:	68 30 3c 80 00       	push   $0x803c30
  8001cf:	68 3d 3c 80 00       	push   $0x803c3d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 27 3c 80 00       	push   $0x803c27
  8001db:	e8 a0 17 00 00       	call   801980 <_panic>

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
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
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
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800280:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800282:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800288:	89 c7                	mov    %eax,%edi
  80028a:	c1 ef 0c             	shr    $0xc,%edi
	uint32_t secno=0;
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80028d:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800292:	76 1b                	jbe    8002af <bc_pgfault+0x3b>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	ff 72 04             	pushl  0x4(%edx)
  80029a:	53                   	push   %ebx
  80029b:	ff 72 28             	pushl  0x28(%edx)
  80029e:	68 54 3c 80 00       	push   $0x803c54
  8002a3:	6a 29                	push   $0x29
  8002a5:	68 80 3d 80 00       	push   $0x803d80
  8002aa:	e8 d1 16 00 00       	call   801980 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002af:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8002b4:	85 c0                	test   %eax,%eax
  8002b6:	74 17                	je     8002cf <bc_pgfault+0x5b>
  8002b8:	3b 78 04             	cmp    0x4(%eax),%edi
  8002bb:	72 12                	jb     8002cf <bc_pgfault+0x5b>
		panic("reading non-existent block %08x\n", blockno);
  8002bd:	57                   	push   %edi
  8002be:	68 84 3c 80 00       	push   $0x803c84
  8002c3:	6a 2d                	push   $0x2d
  8002c5:	68 80 3d 80 00       	push   $0x803d80
  8002ca:	e8 b1 16 00 00       	call   801980 <_panic>
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	
	addr = (void *)(ROUNDDOWN(addr,PGSIZE));
  8002cf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	secno = (((uint32_t)addr - DISKMAP) / BLKSIZE)*8;
  8002d5:	8d b3 00 00 00 f0    	lea    -0x10000000(%ebx),%esi
  8002db:	c1 ee 09             	shr    $0x9,%esi
	r = sys_page_alloc(thisenv->env_id, addr, PTE_P|PTE_U|PTE_W);
  8002de:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8002e3:	8b 40 48             	mov    0x48(%eax),%eax
  8002e6:	83 ec 04             	sub    $0x4,%esp
  8002e9:	6a 07                	push   $0x7
  8002eb:	53                   	push   %ebx
  8002ec:	50                   	push   %eax
  8002ed:	e8 ef 20 00 00       	call   8023e1 <sys_page_alloc>
	if(r<0)
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	85 c0                	test   %eax,%eax
  8002f7:	79 14                	jns    80030d <bc_pgfault+0x99>
	{
		panic("Page allocation failed in bc_pgfault \n");
  8002f9:	83 ec 04             	sub    $0x4,%esp
  8002fc:	68 a8 3c 80 00       	push   $0x803ca8
  800301:	6a 3b                	push   $0x3b
  800303:	68 80 3d 80 00       	push   $0x803d80
  800308:	e8 73 16 00 00       	call   801980 <_panic>
	}
	r = ide_read(secno, addr, 8);
  80030d:	83 ec 04             	sub    $0x4,%esp
  800310:	6a 08                	push   $0x8
  800312:	53                   	push   %ebx
  800313:	56                   	push   %esi
  800314:	e8 d3 fd ff ff       	call   8000ec <ide_read>
	if(r<0)
  800319:	83 c4 10             	add    $0x10,%esp
  80031c:	85 c0                	test   %eax,%eax
  80031e:	79 14                	jns    800334 <bc_pgfault+0xc0>
	{
		panic("ide_read failed in handler\n");
  800320:	83 ec 04             	sub    $0x4,%esp
  800323:	68 88 3d 80 00       	push   $0x803d88
  800328:	6a 40                	push   $0x40
  80032a:	68 80 3d 80 00       	push   $0x803d80
  80032f:	e8 4c 16 00 00       	call   801980 <_panic>
	}

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800334:	89 d8                	mov    %ebx,%eax
  800336:	c1 e8 0c             	shr    $0xc,%eax
  800339:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	25 07 0e 00 00       	and    $0xe07,%eax
  800348:	50                   	push   %eax
  800349:	53                   	push   %ebx
  80034a:	6a 00                	push   $0x0
  80034c:	53                   	push   %ebx
  80034d:	6a 00                	push   $0x0
  80034f:	e8 d0 20 00 00       	call   802424 <sys_page_map>
  800354:	83 c4 20             	add    $0x20,%esp
  800357:	85 c0                	test   %eax,%eax
  800359:	79 12                	jns    80036d <bc_pgfault+0xf9>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80035b:	50                   	push   %eax
  80035c:	68 d0 3c 80 00       	push   $0x803cd0
  800361:	6a 46                	push   $0x46
  800363:	68 80 3d 80 00       	push   $0x803d80
  800368:	e8 13 16 00 00       	call   801980 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80036d:	83 3d 08 a0 80 00 00 	cmpl   $0x0,0x80a008
  800374:	74 22                	je     800398 <bc_pgfault+0x124>
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	57                   	push   %edi
  80037a:	e8 61 03 00 00       	call   8006e0 <block_is_free>
  80037f:	83 c4 10             	add    $0x10,%esp
  800382:	84 c0                	test   %al,%al
  800384:	74 12                	je     800398 <bc_pgfault+0x124>
		panic("reading free block %08x\n", blockno);
  800386:	57                   	push   %edi
  800387:	68 a4 3d 80 00       	push   $0x803da4
  80038c:	6a 4c                	push   $0x4c
  80038e:	68 80 3d 80 00       	push   $0x803d80
  800393:	e8 e8 15 00 00       	call   801980 <_panic>
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  8003a9:	85 c0                	test   %eax,%eax
  8003ab:	74 0f                	je     8003bc <diskaddr+0x1c>
  8003ad:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8003b3:	85 d2                	test   %edx,%edx
  8003b5:	74 17                	je     8003ce <diskaddr+0x2e>
  8003b7:	3b 42 04             	cmp    0x4(%edx),%eax
  8003ba:	72 12                	jb     8003ce <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003bc:	50                   	push   %eax
  8003bd:	68 f0 3c 80 00       	push   $0x803cf0
  8003c2:	6a 09                	push   $0x9
  8003c4:	68 80 3d 80 00       	push   $0x803d80
  8003c9:	e8 b2 15 00 00       	call   801980 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003ce:	05 00 00 01 00       	add    $0x10000,%eax
  8003d3:	c1 e0 0c             	shl    $0xc,%eax
	
}
  8003d6:	c9                   	leave  
  8003d7:	c3                   	ret    

008003d8 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003de:	89 d0                	mov    %edx,%eax
  8003e0:	c1 e8 16             	shr    $0x16,%eax
  8003e3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ef:	f6 c1 01             	test   $0x1,%cl
  8003f2:	74 0d                	je     800401 <va_is_mapped+0x29>
  8003f4:	c1 ea 0c             	shr    $0xc,%edx
  8003f7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003fe:	83 e0 01             	and    $0x1,%eax
  800401:	83 e0 01             	and    $0x1,%eax
}
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  800409:	8b 45 08             	mov    0x8(%ebp),%eax
  80040c:	c1 e8 0c             	shr    $0xc,%eax
  80040f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800416:	c1 e8 06             	shr    $0x6,%eax
  800419:	83 e0 01             	and    $0x1,%eax
}
  80041c:	5d                   	pop    %ebp
  80041d:	c3                   	ret    

0080041e <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	56                   	push   %esi
  800422:	53                   	push   %ebx
  800423:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int ret;
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800426:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80042c:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800431:	76 12                	jbe    800445 <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800433:	53                   	push   %ebx
  800434:	68 bd 3d 80 00       	push   $0x803dbd
  800439:	6a 5c                	push   $0x5c
  80043b:	68 80 3d 80 00       	push   $0x803d80
  800440:	e8 3b 15 00 00       	call   801980 <_panic>

	// LAB 5: Your code here.
	//panic("flush_block not implemented");
	addr = (void *)(ROUNDDOWN(addr, PGSIZE));
  800445:	89 de                	mov    %ebx,%esi
  800447:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if( va_is_mapped(addr) && va_is_dirty(addr))
  80044d:	83 ec 0c             	sub    $0xc,%esp
  800450:	56                   	push   %esi
  800451:	e8 82 ff ff ff       	call   8003d8 <va_is_mapped>
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	84 c0                	test   %al,%al
  80045b:	74 7e                	je     8004db <flush_block+0xbd>
  80045d:	83 ec 0c             	sub    $0xc,%esp
  800460:	56                   	push   %esi
  800461:	e8 a0 ff ff ff       	call   800406 <va_is_dirty>
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	84 c0                	test   %al,%al
  80046b:	74 6e                	je     8004db <flush_block+0xbd>
	{
		ret = ide_write(blockno*8, addr, 8);
  80046d:	83 ec 04             	sub    $0x4,%esp
  800470:	6a 08                	push   $0x8
  800472:	56                   	push   %esi
  800473:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  800479:	c1 eb 0c             	shr    $0xc,%ebx
  80047c:	c1 e3 03             	shl    $0x3,%ebx
  80047f:	53                   	push   %ebx
  800480:	e8 2b fd ff ff       	call   8001b0 <ide_write>
		if(ret < 0)
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	85 c0                	test   %eax,%eax
  80048a:	79 14                	jns    8004a0 <flush_block+0x82>
		{
			panic("ide_write failed in flush_block \n");
  80048c:	83 ec 04             	sub    $0x4,%esp
  80048f:	68 14 3d 80 00       	push   $0x803d14
  800494:	6a 66                	push   $0x66
  800496:	68 80 3d 80 00       	push   $0x803d80
  80049b:	e8 e0 14 00 00       	call   801980 <_panic>
		}
		ret = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)]&PTE_SYSCALL);
  8004a0:	89 f0                	mov    %esi,%eax
  8004a2:	c1 e8 0c             	shr    $0xc,%eax
  8004a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8004ac:	83 ec 0c             	sub    $0xc,%esp
  8004af:	25 07 0e 00 00       	and    $0xe07,%eax
  8004b4:	50                   	push   %eax
  8004b5:	56                   	push   %esi
  8004b6:	6a 00                	push   $0x0
  8004b8:	56                   	push   %esi
  8004b9:	6a 00                	push   $0x0
  8004bb:	e8 64 1f 00 00       	call   802424 <sys_page_map>
		if(ret < 0)
  8004c0:	83 c4 20             	add    $0x20,%esp
  8004c3:	85 c0                	test   %eax,%eax
  8004c5:	79 14                	jns    8004db <flush_block+0xbd>
		{
			panic("page map failed in flush_block \n");
  8004c7:	83 ec 04             	sub    $0x4,%esp
  8004ca:	68 38 3d 80 00       	push   $0x803d38
  8004cf:	6a 6b                	push   $0x6b
  8004d1:	68 80 3d 80 00       	push   $0x803d80
  8004d6:	e8 a5 14 00 00       	call   801980 <_panic>
		}
	}

}
  8004db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004de:	5b                   	pop    %ebx
  8004df:	5e                   	pop    %esi
  8004e0:	5d                   	pop    %ebp
  8004e1:	c3                   	ret    

008004e2 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004eb:	68 74 02 80 00       	push   $0x800274
  8004f0:	e8 fc 20 00 00       	call   8025f1 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004fc:	e8 9f fe ff ff       	call   8003a0 <diskaddr>
  800501:	83 c4 0c             	add    $0xc,%esp
  800504:	68 08 01 00 00       	push   $0x108
  800509:	50                   	push   %eax
  80050a:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  800510:	50                   	push   %eax
  800511:	e8 5a 1c 00 00       	call   802170 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800516:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80051d:	e8 7e fe ff ff       	call   8003a0 <diskaddr>
  800522:	83 c4 08             	add    $0x8,%esp
  800525:	68 d8 3d 80 00       	push   $0x803dd8
  80052a:	50                   	push   %eax
  80052b:	e8 ae 1a 00 00       	call   801fde <strcpy>
	flush_block(diskaddr(1));
  800530:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800537:	e8 64 fe ff ff       	call   8003a0 <diskaddr>
  80053c:	89 04 24             	mov    %eax,(%esp)
  80053f:	e8 da fe ff ff       	call   80041e <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800544:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80054b:	e8 50 fe ff ff       	call   8003a0 <diskaddr>
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	e8 80 fe ff ff       	call   8003d8 <va_is_mapped>
  800558:	83 c4 10             	add    $0x10,%esp
  80055b:	84 c0                	test   %al,%al
  80055d:	75 16                	jne    800575 <bc_init+0x93>
  80055f:	68 fa 3d 80 00       	push   $0x803dfa
  800564:	68 3d 3c 80 00       	push   $0x803c3d
  800569:	6a 7e                	push   $0x7e
  80056b:	68 80 3d 80 00       	push   $0x803d80
  800570:	e8 0b 14 00 00       	call   801980 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800575:	83 ec 0c             	sub    $0xc,%esp
  800578:	6a 01                	push   $0x1
  80057a:	e8 21 fe ff ff       	call   8003a0 <diskaddr>
  80057f:	89 04 24             	mov    %eax,(%esp)
  800582:	e8 7f fe ff ff       	call   800406 <va_is_dirty>
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	84 c0                	test   %al,%al
  80058c:	74 16                	je     8005a4 <bc_init+0xc2>
  80058e:	68 df 3d 80 00       	push   $0x803ddf
  800593:	68 3d 3c 80 00       	push   $0x803c3d
  800598:	6a 7f                	push   $0x7f
  80059a:	68 80 3d 80 00       	push   $0x803d80
  80059f:	e8 dc 13 00 00       	call   801980 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  8005a4:	83 ec 0c             	sub    $0xc,%esp
  8005a7:	6a 01                	push   $0x1
  8005a9:	e8 f2 fd ff ff       	call   8003a0 <diskaddr>
  8005ae:	83 c4 08             	add    $0x8,%esp
  8005b1:	50                   	push   %eax
  8005b2:	6a 00                	push   $0x0
  8005b4:	e8 ad 1e 00 00       	call   802466 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005c0:	e8 db fd ff ff       	call   8003a0 <diskaddr>
  8005c5:	89 04 24             	mov    %eax,(%esp)
  8005c8:	e8 0b fe ff ff       	call   8003d8 <va_is_mapped>
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	84 c0                	test   %al,%al
  8005d2:	74 19                	je     8005ed <bc_init+0x10b>
  8005d4:	68 f9 3d 80 00       	push   $0x803df9
  8005d9:	68 3d 3c 80 00       	push   $0x803c3d
  8005de:	68 83 00 00 00       	push   $0x83
  8005e3:	68 80 3d 80 00       	push   $0x803d80
  8005e8:	e8 93 13 00 00       	call   801980 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005ed:	83 ec 0c             	sub    $0xc,%esp
  8005f0:	6a 01                	push   $0x1
  8005f2:	e8 a9 fd ff ff       	call   8003a0 <diskaddr>
  8005f7:	83 c4 08             	add    $0x8,%esp
  8005fa:	68 d8 3d 80 00       	push   $0x803dd8
  8005ff:	50                   	push   %eax
  800600:	e8 83 1a 00 00       	call   802088 <strcmp>
  800605:	83 c4 10             	add    $0x10,%esp
  800608:	85 c0                	test   %eax,%eax
  80060a:	74 19                	je     800625 <bc_init+0x143>
  80060c:	68 5c 3d 80 00       	push   $0x803d5c
  800611:	68 3d 3c 80 00       	push   $0x803c3d
  800616:	68 86 00 00 00       	push   $0x86
  80061b:	68 80 3d 80 00       	push   $0x803d80
  800620:	e8 5b 13 00 00       	call   801980 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800625:	83 ec 0c             	sub    $0xc,%esp
  800628:	6a 01                	push   $0x1
  80062a:	e8 71 fd ff ff       	call   8003a0 <diskaddr>
  80062f:	83 c4 0c             	add    $0xc,%esp
  800632:	68 08 01 00 00       	push   $0x108
  800637:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  80063d:	52                   	push   %edx
  80063e:	50                   	push   %eax
  80063f:	e8 2c 1b 00 00       	call   802170 <memmove>
	flush_block(diskaddr(1));
  800644:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80064b:	e8 50 fd ff ff       	call   8003a0 <diskaddr>
  800650:	89 04 24             	mov    %eax,(%esp)
  800653:	e8 c6 fd ff ff       	call   80041e <flush_block>

	cprintf("block cache is good\n");
  800658:	c7 04 24 14 3e 80 00 	movl   $0x803e14,(%esp)
  80065f:	e8 f5 13 00 00       	call   801a59 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800664:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80066b:	e8 30 fd ff ff       	call   8003a0 <diskaddr>
  800670:	83 c4 0c             	add    $0xc,%esp
  800673:	68 08 01 00 00       	push   $0x108
  800678:	50                   	push   %eax
  800679:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80067f:	50                   	push   %eax
  800680:	e8 eb 1a 00 00       	call   802170 <memmove>
}
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	c9                   	leave  
  800689:	c3                   	ret    

0080068a <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  800690:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800695:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  80069b:	74 14                	je     8006b1 <check_super+0x27>
		panic("bad file system magic number");
  80069d:	83 ec 04             	sub    $0x4,%esp
  8006a0:	68 29 3e 80 00       	push   $0x803e29
  8006a5:	6a 0f                	push   $0xf
  8006a7:	68 46 3e 80 00       	push   $0x803e46
  8006ac:	e8 cf 12 00 00       	call   801980 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8006b1:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8006b8:	76 14                	jbe    8006ce <check_super+0x44>
		panic("file system is too large");
  8006ba:	83 ec 04             	sub    $0x4,%esp
  8006bd:	68 4e 3e 80 00       	push   $0x803e4e
  8006c2:	6a 12                	push   $0x12
  8006c4:	68 46 3e 80 00       	push   $0x803e46
  8006c9:	e8 b2 12 00 00       	call   801980 <_panic>

	cprintf("superblock is good\n");
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	68 67 3e 80 00       	push   $0x803e67
  8006d6:	e8 7e 13 00 00       	call   801a59 <cprintf>
}
  8006db:	83 c4 10             	add    $0x10,%esp
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	53                   	push   %ebx
  8006e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8006e7:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8006ed:	85 d2                	test   %edx,%edx
  8006ef:	74 24                	je     800715 <block_is_free+0x35>
		return 0;
  8006f1:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8006f6:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8006f9:	76 1f                	jbe    80071a <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8006fb:	89 cb                	mov    %ecx,%ebx
  8006fd:	c1 eb 05             	shr    $0x5,%ebx
  800700:	b8 01 00 00 00       	mov    $0x1,%eax
  800705:	d3 e0                	shl    %cl,%eax
  800707:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80070d:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  800710:	0f 95 c0             	setne  %al
  800713:	eb 05                	jmp    80071a <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800715:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  80071a:	5b                   	pop    %ebx
  80071b:	5d                   	pop    %ebp
  80071c:	c3                   	ret    

0080071d <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	53                   	push   %ebx
  800721:	83 ec 04             	sub    $0x4,%esp
  800724:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800727:	85 c9                	test   %ecx,%ecx
  800729:	75 14                	jne    80073f <free_block+0x22>
		panic("attempt to free zero block");
  80072b:	83 ec 04             	sub    $0x4,%esp
  80072e:	68 7b 3e 80 00       	push   $0x803e7b
  800733:	6a 2d                	push   $0x2d
  800735:	68 46 3e 80 00       	push   $0x803e46
  80073a:	e8 41 12 00 00       	call   801980 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  80073f:	89 cb                	mov    %ecx,%ebx
  800741:	c1 eb 05             	shr    $0x5,%ebx
  800744:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80074a:	b8 01 00 00 00       	mov    $0x1,%eax
  80074f:	d3 e0                	shl    %cl,%eax
  800751:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800754:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800757:	c9                   	leave  
  800758:	c3                   	ret    

00800759 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	57                   	push   %edi
  80075d:	56                   	push   %esi
  80075e:	53                   	push   %ebx
  80075f:	83 ec 1c             	sub    $0x1c,%esp
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//panic("alloc_block not implemented");
	uint32_t blockno = 0;
	while(blockno < super->s_nblocks)
  800762:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800767:	8b 40 04             	mov    0x4(%eax),%eax
  80076a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	{
		if((bitmap[blockno/32] | 0) == 0)
  80076d:	8b 3d 08 a0 80 00    	mov    0x80a008,%edi
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//panic("alloc_block not implemented");
	uint32_t blockno = 0;
  800773:	bb 00 00 00 00       	mov    $0x0,%ebx
  800778:	89 7d e0             	mov    %edi,-0x20(%ebp)
	while(blockno < super->s_nblocks)
  80077b:	eb 47                	jmp    8007c4 <alloc_block+0x6b>
	{
		if((bitmap[blockno/32] | 0) == 0)
  80077d:	89 d8                	mov    %ebx,%eax
  80077f:	c1 e8 05             	shr    $0x5,%eax
  800782:	c1 e0 02             	shl    $0x2,%eax
  800785:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800788:	8d 34 07             	lea    (%edi,%eax,1),%esi
  80078b:	8b 16                	mov    (%esi),%edx
  80078d:	85 d2                	test   %edx,%edx
  80078f:	75 05                	jne    800796 <alloc_block+0x3d>
		{
			blockno += 32 ;
  800791:	83 c3 20             	add    $0x20,%ebx
  800794:	eb 2e                	jmp    8007c4 <alloc_block+0x6b>
		} else {
			if((bitmap[blockno/32] & 1<<(blockno%32)))
  800796:	bf 01 00 00 00       	mov    $0x1,%edi
  80079b:	89 d9                	mov    %ebx,%ecx
  80079d:	d3 e7                	shl    %cl,%edi
  80079f:	89 f9                	mov    %edi,%ecx
  8007a1:	85 d7                	test   %edx,%edi
  8007a3:	74 1c                	je     8007c1 <alloc_block+0x68>
                        {
                                bitmap[blockno/32] &= ~(1<<(blockno%32));
  8007a5:	f7 d1                	not    %ecx
  8007a7:	21 ca                	and    %ecx,%edx
  8007a9:	89 16                	mov    %edx,(%esi)
                                flush_block((void *) &bitmap[blockno / 32]);
  8007ab:	83 ec 0c             	sub    $0xc,%esp
  8007ae:	03 05 08 a0 80 00    	add    0x80a008,%eax
  8007b4:	50                   	push   %eax
  8007b5:	e8 64 fc ff ff       	call   80041e <flush_block>
                                return blockno;
  8007ba:	89 d8                	mov    %ebx,%eax
  8007bc:	83 c4 10             	add    $0x10,%esp
  8007bf:	eb 0d                	jmp    8007ce <alloc_block+0x75>
                        } else {
                                blockno += 1;
  8007c1:	83 c3 01             	add    $0x1,%ebx
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//panic("alloc_block not implemented");
	uint32_t blockno = 0;
	while(blockno < super->s_nblocks)
  8007c4:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
  8007c7:	72 b4                	jb     80077d <alloc_block+0x24>
                                blockno += 1;
                        }
		}
	}
	
	return -E_NO_DISK;
  8007c9:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8007ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d1:	5b                   	pop    %ebx
  8007d2:	5e                   	pop    %esi
  8007d3:	5f                   	pop    %edi
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	57                   	push   %edi
  8007da:	56                   	push   %esi
  8007db:	53                   	push   %ebx
  8007dc:	83 ec 0c             	sub    $0xc,%esp
  8007df:	89 ce                	mov    %ecx,%esi
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
       // LAB 5: Your code here.
       //panic("file_block_walk not implemented");
       uint32_t ret;
	if(filebno >= (NDIRECT+NINDIRECT))
  8007e4:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8007ea:	77 64                	ja     800850 <file_block_walk+0x7a>
	{
		return -E_INVAL;
	}
	if(filebno < NDIRECT)
  8007ec:	83 fa 09             	cmp    $0x9,%edx
  8007ef:	77 10                	ja     800801 <file_block_walk+0x2b>
	{
		*ppdiskbno = &f->f_direct[filebno];
  8007f1:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  8007f8:	89 06                	mov    %eax,(%esi)
		return 0;
  8007fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ff:	eb 5b                	jmp    80085c <file_block_walk+0x86>
  800801:	89 d3                	mov    %edx,%ebx
  800803:	89 c7                	mov    %eax,%edi
	}	
	if(f->f_indirect != 0)
  800805:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  80080b:	85 c0                	test   %eax,%eax
  80080d:	74 19                	je     800828 <file_block_walk+0x52>
	{
		*ppdiskbno = &(((uint32_t *)diskaddr(f->f_indirect))[filebno - NDIRECT]);
  80080f:	83 ec 0c             	sub    $0xc,%esp
  800812:	50                   	push   %eax
  800813:	e8 88 fb ff ff       	call   8003a0 <diskaddr>
  800818:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  80081c:	89 06                	mov    %eax,(%esi)
		return 0;
  80081e:	83 c4 10             	add    $0x10,%esp
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
  800826:	eb 34                	jmp    80085c <file_block_walk+0x86>
	} else {
		if(alloc)
  800828:	84 c9                	test   %cl,%cl
  80082a:	74 2b                	je     800857 <file_block_walk+0x81>
		{
			ret = alloc_block();
  80082c:	e8 28 ff ff ff       	call   800759 <alloc_block>
			if(ret < 0)
			{
				return ret;
			}
			f->f_indirect = ret;
  800831:	89 87 b0 00 00 00    	mov    %eax,0xb0(%edi)
			*ppdiskbno = &(((uint32_t *)diskaddr(f->f_indirect))[filebno - NDIRECT]);
  800837:	83 ec 0c             	sub    $0xc,%esp
  80083a:	50                   	push   %eax
  80083b:	e8 60 fb ff ff       	call   8003a0 <diskaddr>
  800840:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800844:	89 06                	mov    %eax,(%esi)
			return 0;
  800846:	83 c4 10             	add    $0x10,%esp
  800849:	b8 00 00 00 00       	mov    $0x0,%eax
  80084e:	eb 0c                	jmp    80085c <file_block_walk+0x86>
       // LAB 5: Your code here.
       //panic("file_block_walk not implemented");
       uint32_t ret;
	if(filebno >= (NDIRECT+NINDIRECT))
	{
		return -E_INVAL;
  800850:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800855:	eb 05                	jmp    80085c <file_block_walk+0x86>
			}
			f->f_indirect = ret;
			*ppdiskbno = &(((uint32_t *)diskaddr(f->f_indirect))[filebno - NDIRECT]);
			return 0;
		} else {
			return -E_NOT_FOUND;
  800857:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
		}
	}
}
  80085c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5f                   	pop    %edi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800869:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80086e:	8b 70 04             	mov    0x4(%eax),%esi
  800871:	bb 00 00 00 00       	mov    $0x0,%ebx
  800876:	eb 29                	jmp    8008a1 <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  800878:	8d 43 02             	lea    0x2(%ebx),%eax
  80087b:	50                   	push   %eax
  80087c:	e8 5f fe ff ff       	call   8006e0 <block_is_free>
  800881:	83 c4 04             	add    $0x4,%esp
  800884:	84 c0                	test   %al,%al
  800886:	74 16                	je     80089e <check_bitmap+0x3a>
  800888:	68 96 3e 80 00       	push   $0x803e96
  80088d:	68 3d 3c 80 00       	push   $0x803c3d
  800892:	6a 62                	push   $0x62
  800894:	68 46 3e 80 00       	push   $0x803e46
  800899:	e8 e2 10 00 00       	call   801980 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80089e:	83 c3 01             	add    $0x1,%ebx
  8008a1:	89 d8                	mov    %ebx,%eax
  8008a3:	c1 e0 0f             	shl    $0xf,%eax
  8008a6:	39 f0                	cmp    %esi,%eax
  8008a8:	72 ce                	jb     800878 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8008aa:	83 ec 0c             	sub    $0xc,%esp
  8008ad:	6a 00                	push   $0x0
  8008af:	e8 2c fe ff ff       	call   8006e0 <block_is_free>
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	84 c0                	test   %al,%al
  8008b9:	74 16                	je     8008d1 <check_bitmap+0x6d>
  8008bb:	68 aa 3e 80 00       	push   $0x803eaa
  8008c0:	68 3d 3c 80 00       	push   $0x803c3d
  8008c5:	6a 65                	push   $0x65
  8008c7:	68 46 3e 80 00       	push   $0x803e46
  8008cc:	e8 af 10 00 00       	call   801980 <_panic>
	assert(!block_is_free(1));
  8008d1:	83 ec 0c             	sub    $0xc,%esp
  8008d4:	6a 01                	push   $0x1
  8008d6:	e8 05 fe ff ff       	call   8006e0 <block_is_free>
  8008db:	83 c4 10             	add    $0x10,%esp
  8008de:	84 c0                	test   %al,%al
  8008e0:	74 16                	je     8008f8 <check_bitmap+0x94>
  8008e2:	68 bc 3e 80 00       	push   $0x803ebc
  8008e7:	68 3d 3c 80 00       	push   $0x803c3d
  8008ec:	6a 66                	push   $0x66
  8008ee:	68 46 3e 80 00       	push   $0x803e46
  8008f3:	e8 88 10 00 00       	call   801980 <_panic>

	cprintf("bitmap is good\n");
  8008f8:	83 ec 0c             	sub    $0xc,%esp
  8008fb:	68 ce 3e 80 00       	push   $0x803ece
  800900:	e8 54 11 00 00       	call   801a59 <cprintf>
}
  800905:	83 c4 10             	add    $0x10,%esp
  800908:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

       // Find a JOS disk.  Use the second IDE disk (number 1) if availabl
       if (ide_probe_disk1())
  800915:	e8 45 f7 ff ff       	call   80005f <ide_probe_disk1>
  80091a:	84 c0                	test   %al,%al
  80091c:	74 0f                	je     80092d <fs_init+0x1e>
               ide_set_disk(1);
  80091e:	83 ec 0c             	sub    $0xc,%esp
  800921:	6a 01                	push   $0x1
  800923:	e8 9b f7 ff ff       	call   8000c3 <ide_set_disk>
  800928:	83 c4 10             	add    $0x10,%esp
  80092b:	eb 0d                	jmp    80093a <fs_init+0x2b>
       else
               ide_set_disk(0);
  80092d:	83 ec 0c             	sub    $0xc,%esp
  800930:	6a 00                	push   $0x0
  800932:	e8 8c f7 ff ff       	call   8000c3 <ide_set_disk>
  800937:	83 c4 10             	add    $0x10,%esp
	bc_init();
  80093a:	e8 a3 fb ff ff       	call   8004e2 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  80093f:	83 ec 0c             	sub    $0xc,%esp
  800942:	6a 01                	push   $0x1
  800944:	e8 57 fa ff ff       	call   8003a0 <diskaddr>
  800949:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	check_super();
  80094e:	e8 37 fd ff ff       	call   80068a <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800953:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80095a:	e8 41 fa ff ff       	call   8003a0 <diskaddr>
  80095f:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_bitmap();
  800964:	e8 fb fe ff ff       	call   800864 <check_bitmap>
	
}
  800969:	83 c4 10             	add    $0x10,%esp
  80096c:	c9                   	leave  
  80096d:	c3                   	ret    

0080096e <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	83 ec 18             	sub    $0x18,%esp
  800974:	8b 55 0c             	mov    0xc(%ebp),%edx
       // LAB 5: Your code here.
       //panic("file_get_block not implemented");
       	uint32_t ret;
	uint32_t *block;
	if(filebno >= (NDIRECT+NINDIRECT))
  800977:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  80097d:	77 5a                	ja     8009d9 <file_get_block+0x6b>
        {
                return -E_INVAL;
        }
	
	ret = file_block_walk(f, filebno, &block, 1);
  80097f:	83 ec 0c             	sub    $0xc,%esp
  800982:	6a 01                	push   $0x1
  800984:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	e8 47 fe ff ff       	call   8007d6 <file_block_walk>
	if(ret < 0)
	{
		return ret;
	}
	
	if(*block != 0)
  80098f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800992:	8b 00                	mov    (%eax),%eax
  800994:	83 c4 10             	add    $0x10,%esp
  800997:	85 c0                	test   %eax,%eax
  800999:	74 18                	je     8009b3 <file_get_block+0x45>
	{
		*blk = (char *)diskaddr(*block);
  80099b:	83 ec 0c             	sub    $0xc,%esp
  80099e:	50                   	push   %eax
  80099f:	e8 fc f9 ff ff       	call   8003a0 <diskaddr>
  8009a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009a7:	89 01                	mov    %eax,(%ecx)
		return 0;
  8009a9:	83 c4 10             	add    $0x10,%esp
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b1:	eb 2b                	jmp    8009de <file_get_block+0x70>
	} else {
		ret = alloc_block();
  8009b3:	e8 a1 fd ff ff       	call   800759 <alloc_block>
		if(ret < 0)
		{
			return ret;
		}
		*block = ret;
  8009b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009bb:	89 02                	mov    %eax,(%edx)
		*blk = (char *)diskaddr(*block);
  8009bd:	83 ec 0c             	sub    $0xc,%esp
  8009c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c3:	ff 30                	pushl  (%eax)
  8009c5:	e8 d6 f9 ff ff       	call   8003a0 <diskaddr>
  8009ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009cd:	89 01                	mov    %eax,(%ecx)
		return 0;
  8009cf:	83 c4 10             	add    $0x10,%esp
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d7:	eb 05                	jmp    8009de <file_get_block+0x70>
       //panic("file_get_block not implemented");
       	uint32_t ret;
	uint32_t *block;
	if(filebno >= (NDIRECT+NINDIRECT))
        {
                return -E_INVAL;
  8009d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		*block = ret;
		*blk = (char *)diskaddr(*block);
		return 0;
	}
}
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  8009ec:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  8009f2:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  8009f8:	eb 03                	jmp    8009fd <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  8009fa:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8009fd:	80 38 2f             	cmpb   $0x2f,(%eax)
  800a00:	74 f8                	je     8009fa <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800a02:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
  800a08:	83 c1 08             	add    $0x8,%ecx
  800a0b:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800a11:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800a18:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800a1e:	85 c9                	test   %ecx,%ecx
  800a20:	74 06                	je     800a28 <walk_path+0x48>
		*pdir = 0;
  800a22:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800a28:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800a2e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800a34:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a39:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800a3f:	e9 5f 01 00 00       	jmp    800ba3 <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800a44:	83 c7 01             	add    $0x1,%edi
  800a47:	eb 02                	jmp    800a4b <walk_path+0x6b>
  800a49:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800a4b:	0f b6 17             	movzbl (%edi),%edx
  800a4e:	80 fa 2f             	cmp    $0x2f,%dl
  800a51:	74 04                	je     800a57 <walk_path+0x77>
  800a53:	84 d2                	test   %dl,%dl
  800a55:	75 ed                	jne    800a44 <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800a57:	89 fb                	mov    %edi,%ebx
  800a59:	29 c3                	sub    %eax,%ebx
  800a5b:	83 fb 7f             	cmp    $0x7f,%ebx
  800a5e:	0f 8f 69 01 00 00    	jg     800bcd <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a64:	83 ec 04             	sub    $0x4,%esp
  800a67:	53                   	push   %ebx
  800a68:	50                   	push   %eax
  800a69:	56                   	push   %esi
  800a6a:	e8 01 17 00 00       	call   802170 <memmove>
		name[path - p] = '\0';
  800a6f:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800a76:	00 
  800a77:	83 c4 10             	add    $0x10,%esp
  800a7a:	eb 03                	jmp    800a7f <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800a7c:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800a7f:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800a82:	74 f8                	je     800a7c <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800a84:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800a8a:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800a91:	0f 85 3d 01 00 00    	jne    800bd4 <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800a97:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800a9d:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800aa2:	74 19                	je     800abd <walk_path+0xdd>
  800aa4:	68 de 3e 80 00       	push   $0x803ede
  800aa9:	68 3d 3c 80 00       	push   $0x803c3d
  800aae:	68 f5 00 00 00       	push   $0xf5
  800ab3:	68 46 3e 80 00       	push   $0x803e46
  800ab8:	e8 c3 0e 00 00       	call   801980 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800abd:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800ac3:	85 c0                	test   %eax,%eax
  800ac5:	0f 48 c2             	cmovs  %edx,%eax
  800ac8:	c1 f8 0c             	sar    $0xc,%eax
  800acb:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800ad1:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800ad8:	00 00 00 
  800adb:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800ae1:	eb 5e                	jmp    800b41 <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800ae3:	83 ec 04             	sub    $0x4,%esp
  800ae6:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800aec:	50                   	push   %eax
  800aed:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800af3:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800af9:	e8 70 fe ff ff       	call   80096e <file_get_block>
  800afe:	83 c4 10             	add    $0x10,%esp
  800b01:	85 c0                	test   %eax,%eax
  800b03:	0f 88 ee 00 00 00    	js     800bf7 <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800b09:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800b0f:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800b15:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800b1b:	83 ec 08             	sub    $0x8,%esp
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
  800b20:	e8 63 15 00 00       	call   802088 <strcmp>
  800b25:	83 c4 10             	add    $0x10,%esp
  800b28:	85 c0                	test   %eax,%eax
  800b2a:	0f 84 ab 00 00 00    	je     800bdb <walk_path+0x1fb>
  800b30:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800b36:	39 fb                	cmp    %edi,%ebx
  800b38:	75 db                	jne    800b15 <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800b3a:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800b41:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800b47:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800b4d:	75 94                	jne    800ae3 <walk_path+0x103>
  800b4f:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800b55:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800b5a:	80 3f 00             	cmpb   $0x0,(%edi)
  800b5d:	0f 85 a3 00 00 00    	jne    800c06 <walk_path+0x226>
				if (pdir)
  800b63:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b69:	85 c0                	test   %eax,%eax
  800b6b:	74 08                	je     800b75 <walk_path+0x195>
					*pdir = dir;
  800b6d:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800b73:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800b75:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b79:	74 15                	je     800b90 <walk_path+0x1b0>
					strcpy(lastelem, name);
  800b7b:	83 ec 08             	sub    $0x8,%esp
  800b7e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800b84:	50                   	push   %eax
  800b85:	ff 75 08             	pushl  0x8(%ebp)
  800b88:	e8 51 14 00 00       	call   801fde <strcpy>
  800b8d:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800b90:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800b96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800b9c:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800ba1:	eb 63                	jmp    800c06 <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800ba3:	80 38 00             	cmpb   $0x0,(%eax)
  800ba6:	0f 85 9d fe ff ff    	jne    800a49 <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800bac:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800bb2:	85 c0                	test   %eax,%eax
  800bb4:	74 02                	je     800bb8 <walk_path+0x1d8>
		*pdir = dir;
  800bb6:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800bb8:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800bbe:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800bc4:	89 08                	mov    %ecx,(%eax)
	return 0;
  800bc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcb:	eb 39                	jmp    800c06 <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800bcd:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800bd2:	eb 32                	jmp    800c06 <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800bd4:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800bd9:	eb 2b                	jmp    800c06 <walk_path+0x226>
  800bdb:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800be1:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800be7:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800bed:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800bf3:	89 f8                	mov    %edi,%eax
  800bf5:	eb ac                	jmp    800ba3 <walk_path+0x1c3>
  800bf7:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800bfd:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800c00:	0f 84 4f ff ff ff    	je     800b55 <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800c06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800c14:	6a 00                	push   $0x0
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	e8 ba fd ff ff       	call   8009e0 <walk_path>
}
  800c26:	c9                   	leave  
  800c27:	c3                   	ret    

00800c28 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	53                   	push   %ebx
  800c2e:	83 ec 2c             	sub    $0x2c,%esp
  800c31:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c34:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c37:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3a:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800c40:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c45:	39 ca                	cmp    %ecx,%edx
  800c47:	7e 7c                	jle    800cc5 <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800c49:	29 ca                	sub    %ecx,%edx
  800c4b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c4e:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800c52:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800c55:	89 ce                	mov    %ecx,%esi
  800c57:	01 d1                	add    %edx,%ecx
  800c59:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800c5c:	eb 5d                	jmp    800cbb <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800c5e:	83 ec 04             	sub    $0x4,%esp
  800c61:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800c64:	50                   	push   %eax
  800c65:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800c6b:	85 f6                	test   %esi,%esi
  800c6d:	0f 49 c6             	cmovns %esi,%eax
  800c70:	c1 f8 0c             	sar    $0xc,%eax
  800c73:	50                   	push   %eax
  800c74:	ff 75 08             	pushl  0x8(%ebp)
  800c77:	e8 f2 fc ff ff       	call   80096e <file_get_block>
  800c7c:	83 c4 10             	add    $0x10,%esp
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	78 42                	js     800cc5 <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800c83:	89 f2                	mov    %esi,%edx
  800c85:	c1 fa 1f             	sar    $0x1f,%edx
  800c88:	c1 ea 14             	shr    $0x14,%edx
  800c8b:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800c8e:	25 ff 0f 00 00       	and    $0xfff,%eax
  800c93:	29 d0                	sub    %edx,%eax
  800c95:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800c98:	29 da                	sub    %ebx,%edx
  800c9a:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800c9f:	29 c3                	sub    %eax,%ebx
  800ca1:	39 da                	cmp    %ebx,%edx
  800ca3:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800ca6:	83 ec 04             	sub    $0x4,%esp
  800ca9:	53                   	push   %ebx
  800caa:	03 45 e4             	add    -0x1c(%ebp),%eax
  800cad:	50                   	push   %eax
  800cae:	57                   	push   %edi
  800caf:	e8 bc 14 00 00       	call   802170 <memmove>
		pos += bn;
  800cb4:	01 de                	add    %ebx,%esi
		buf += bn;
  800cb6:	01 df                	add    %ebx,%edi
  800cb8:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800cbb:	89 f3                	mov    %esi,%ebx
  800cbd:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800cc0:	77 9c                	ja     800c5e <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800cc2:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 2c             	sub    $0x2c,%esp
  800cd6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800cd9:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800cdf:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800ce2:	0f 8e a7 00 00 00    	jle    800d8f <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800ce8:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800cee:	05 ff 0f 00 00       	add    $0xfff,%eax
  800cf3:	0f 49 f8             	cmovns %eax,%edi
  800cf6:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800cf9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfc:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800d01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d04:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800d0a:	0f 49 c2             	cmovns %edx,%eax
  800d0d:	c1 f8 0c             	sar    $0xc,%eax
  800d10:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d13:	89 c3                	mov    %eax,%ebx
  800d15:	eb 39                	jmp    800d50 <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800d17:	83 ec 0c             	sub    $0xc,%esp
  800d1a:	6a 00                	push   $0x0
  800d1c:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800d1f:	89 da                	mov    %ebx,%edx
  800d21:	89 f0                	mov    %esi,%eax
  800d23:	e8 ae fa ff ff       	call   8007d6 <file_block_walk>
  800d28:	83 c4 10             	add    $0x10,%esp
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	78 4d                	js     800d7c <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800d2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d32:	8b 00                	mov    (%eax),%eax
  800d34:	85 c0                	test   %eax,%eax
  800d36:	74 15                	je     800d4d <file_set_size+0x80>
		free_block(*ptr);
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	50                   	push   %eax
  800d3c:	e8 dc f9 ff ff       	call   80071d <free_block>
		*ptr = 0;
  800d41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d44:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800d4a:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d4d:	83 c3 01             	add    $0x1,%ebx
  800d50:	39 df                	cmp    %ebx,%edi
  800d52:	77 c3                	ja     800d17 <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800d54:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800d58:	77 35                	ja     800d8f <file_set_size+0xc2>
  800d5a:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800d60:	85 c0                	test   %eax,%eax
  800d62:	74 2b                	je     800d8f <file_set_size+0xc2>
		free_block(f->f_indirect);
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	50                   	push   %eax
  800d68:	e8 b0 f9 ff ff       	call   80071d <free_block>
		f->f_indirect = 0;
  800d6d:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800d74:	00 00 00 
  800d77:	83 c4 10             	add    $0x10,%esp
  800d7a:	eb 13                	jmp    800d8f <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800d7c:	83 ec 08             	sub    $0x8,%esp
  800d7f:	50                   	push   %eax
  800d80:	68 fb 3e 80 00       	push   $0x803efb
  800d85:	e8 cf 0c 00 00       	call   801a59 <cprintf>
  800d8a:	83 c4 10             	add    $0x10,%esp
  800d8d:	eb be                	jmp    800d4d <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d92:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800d98:	83 ec 0c             	sub    $0xc,%esp
  800d9b:	56                   	push   %esi
  800d9c:	e8 7d f6 ff ff       	call   80041e <flush_block>
	return 0;
}
  800da1:	b8 00 00 00 00       	mov    $0x0,%eax
  800da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 2c             	sub    $0x2c,%esp
  800db7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dba:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800dbd:	89 f0                	mov    %esi,%eax
  800dbf:	03 45 10             	add    0x10(%ebp),%eax
  800dc2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800dc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc8:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800dce:	76 72                	jbe    800e42 <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800dd0:	83 ec 08             	sub    $0x8,%esp
  800dd3:	50                   	push   %eax
  800dd4:	51                   	push   %ecx
  800dd5:	e8 f3 fe ff ff       	call   800ccd <file_set_size>
  800dda:	83 c4 10             	add    $0x10,%esp
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	79 61                	jns    800e42 <file_write+0x94>
  800de1:	eb 69                	jmp    800e4c <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800de3:	83 ec 04             	sub    $0x4,%esp
  800de6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800de9:	50                   	push   %eax
  800dea:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800df0:	85 f6                	test   %esi,%esi
  800df2:	0f 49 c6             	cmovns %esi,%eax
  800df5:	c1 f8 0c             	sar    $0xc,%eax
  800df8:	50                   	push   %eax
  800df9:	ff 75 08             	pushl  0x8(%ebp)
  800dfc:	e8 6d fb ff ff       	call   80096e <file_get_block>
  800e01:	83 c4 10             	add    $0x10,%esp
  800e04:	85 c0                	test   %eax,%eax
  800e06:	78 44                	js     800e4c <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800e08:	89 f2                	mov    %esi,%edx
  800e0a:	c1 fa 1f             	sar    $0x1f,%edx
  800e0d:	c1 ea 14             	shr    $0x14,%edx
  800e10:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800e13:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e18:	29 d0                	sub    %edx,%eax
  800e1a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800e1d:	29 d9                	sub    %ebx,%ecx
  800e1f:	89 cb                	mov    %ecx,%ebx
  800e21:	ba 00 10 00 00       	mov    $0x1000,%edx
  800e26:	29 c2                	sub    %eax,%edx
  800e28:	39 d1                	cmp    %edx,%ecx
  800e2a:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800e2d:	83 ec 04             	sub    $0x4,%esp
  800e30:	53                   	push   %ebx
  800e31:	57                   	push   %edi
  800e32:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e35:	50                   	push   %eax
  800e36:	e8 35 13 00 00       	call   802170 <memmove>
		pos += bn;
  800e3b:	01 de                	add    %ebx,%esi
		buf += bn;
  800e3d:	01 df                	add    %ebx,%edi
  800e3f:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800e42:	89 f3                	mov    %esi,%ebx
  800e44:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800e47:	77 9a                	ja     800de3 <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800e49:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800e4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
  800e59:	83 ec 10             	sub    $0x10,%esp
  800e5c:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e64:	eb 3c                	jmp    800ea2 <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e66:	83 ec 0c             	sub    $0xc,%esp
  800e69:	6a 00                	push   $0x0
  800e6b:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800e6e:	89 da                	mov    %ebx,%edx
  800e70:	89 f0                	mov    %esi,%eax
  800e72:	e8 5f f9 ff ff       	call   8007d6 <file_block_walk>
  800e77:	83 c4 10             	add    $0x10,%esp
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	78 21                	js     800e9f <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e81:	85 c0                	test   %eax,%eax
  800e83:	74 1a                	je     800e9f <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e85:	8b 00                	mov    (%eax),%eax
  800e87:	85 c0                	test   %eax,%eax
  800e89:	74 14                	je     800e9f <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800e8b:	83 ec 0c             	sub    $0xc,%esp
  800e8e:	50                   	push   %eax
  800e8f:	e8 0c f5 ff ff       	call   8003a0 <diskaddr>
  800e94:	89 04 24             	mov    %eax,(%esp)
  800e97:	e8 82 f5 ff ff       	call   80041e <flush_block>
  800e9c:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e9f:	83 c3 01             	add    $0x1,%ebx
  800ea2:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800ea8:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800eae:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800eb4:	85 c9                	test   %ecx,%ecx
  800eb6:	0f 49 c1             	cmovns %ecx,%eax
  800eb9:	c1 f8 0c             	sar    $0xc,%eax
  800ebc:	39 c3                	cmp    %eax,%ebx
  800ebe:	7c a6                	jl     800e66 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800ec0:	83 ec 0c             	sub    $0xc,%esp
  800ec3:	56                   	push   %esi
  800ec4:	e8 55 f5 ff ff       	call   80041e <flush_block>
	if (f->f_indirect)
  800ec9:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800ecf:	83 c4 10             	add    $0x10,%esp
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	74 14                	je     800eea <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  800ed6:	83 ec 0c             	sub    $0xc,%esp
  800ed9:	50                   	push   %eax
  800eda:	e8 c1 f4 ff ff       	call   8003a0 <diskaddr>
  800edf:	89 04 24             	mov    %eax,(%esp)
  800ee2:	e8 37 f5 ff ff       	call   80041e <flush_block>
  800ee7:	83 c4 10             	add    $0x10,%esp
}
  800eea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	57                   	push   %edi
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
  800ef7:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800efd:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800f03:	50                   	push   %eax
  800f04:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  800f0a:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  800f10:	8b 45 08             	mov    0x8(%ebp),%eax
  800f13:	e8 c8 fa ff ff       	call   8009e0 <walk_path>
  800f18:	83 c4 10             	add    $0x10,%esp
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	0f 84 d1 00 00 00    	je     800ff4 <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800f23:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800f26:	0f 85 0c 01 00 00    	jne    801038 <file_create+0x147>
  800f2c:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  800f32:	85 f6                	test   %esi,%esi
  800f34:	0f 84 c1 00 00 00    	je     800ffb <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  800f3a:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800f40:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800f45:	74 19                	je     800f60 <file_create+0x6f>
  800f47:	68 de 3e 80 00       	push   $0x803ede
  800f4c:	68 3d 3c 80 00       	push   $0x803c3d
  800f51:	68 0e 01 00 00       	push   $0x10e
  800f56:	68 46 3e 80 00       	push   $0x803e46
  800f5b:	e8 20 0a 00 00       	call   801980 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800f60:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800f66:	85 c0                	test   %eax,%eax
  800f68:	0f 48 c2             	cmovs  %edx,%eax
  800f6b:	c1 f8 0c             	sar    $0xc,%eax
  800f6e:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  800f74:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800f79:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  800f7f:	eb 3b                	jmp    800fbc <file_create+0xcb>
  800f81:	83 ec 04             	sub    $0x4,%esp
  800f84:	57                   	push   %edi
  800f85:	53                   	push   %ebx
  800f86:	56                   	push   %esi
  800f87:	e8 e2 f9 ff ff       	call   80096e <file_get_block>
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	0f 88 a1 00 00 00    	js     801038 <file_create+0x147>
			return r;
		f = (struct File*) blk;
  800f97:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800f9d:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  800fa3:	80 38 00             	cmpb   $0x0,(%eax)
  800fa6:	75 08                	jne    800fb0 <file_create+0xbf>
				*file = &f[j];
  800fa8:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800fae:	eb 52                	jmp    801002 <file_create+0x111>
  800fb0:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800fb5:	39 d0                	cmp    %edx,%eax
  800fb7:	75 ea                	jne    800fa3 <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800fb9:	83 c3 01             	add    $0x1,%ebx
  800fbc:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  800fc2:	75 bd                	jne    800f81 <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800fc4:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  800fcb:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800fce:	83 ec 04             	sub    $0x4,%esp
  800fd1:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  800fd7:	50                   	push   %eax
  800fd8:	53                   	push   %ebx
  800fd9:	56                   	push   %esi
  800fda:	e8 8f f9 ff ff       	call   80096e <file_get_block>
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	78 52                	js     801038 <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  800fe6:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800fec:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800ff2:	eb 0e                	jmp    801002 <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  800ff4:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  800ff9:	eb 3d                	jmp    801038 <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  800ffb:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  801000:	eb 36                	jmp    801038 <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  801002:	83 ec 08             	sub    $0x8,%esp
  801005:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80100b:	50                   	push   %eax
  80100c:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  801012:	e8 c7 0f 00 00       	call   801fde <strcpy>
	*pf = f;
  801017:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  80101d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801020:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  801022:	83 c4 04             	add    $0x4,%esp
  801025:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  80102b:	e8 24 fe ff ff       	call   800e54 <file_flush>
	return 0;
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801038:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103b:	5b                   	pop    %ebx
  80103c:	5e                   	pop    %esi
  80103d:	5f                   	pop    %edi
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	53                   	push   %ebx
  801044:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801047:	bb 01 00 00 00       	mov    $0x1,%ebx
  80104c:	eb 17                	jmp    801065 <fs_sync+0x25>
		flush_block(diskaddr(i));
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	53                   	push   %ebx
  801052:	e8 49 f3 ff ff       	call   8003a0 <diskaddr>
  801057:	89 04 24             	mov    %eax,(%esp)
  80105a:	e8 bf f3 ff ff       	call   80041e <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80105f:	83 c3 01             	add    $0x1,%ebx
  801062:	83 c4 10             	add    $0x10,%esp
  801065:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80106a:	39 58 04             	cmp    %ebx,0x4(%eax)
  80106d:	77 df                	ja     80104e <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  80106f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801072:	c9                   	leave  
  801073:	c3                   	ret    

00801074 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  80107a:	e8 c1 ff ff ff       	call   801040 <fs_sync>
	return 0;
}
  80107f:	b8 00 00 00 00       	mov    $0x0,%eax
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  80108e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801093:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  801098:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  80109a:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  80109d:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8010a3:	83 c0 01             	add    $0x1,%eax
  8010a6:	83 c2 10             	add    $0x10,%edx
  8010a9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010ae:	75 e8                	jne    801098 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	56                   	push   %esi
  8010b6:	53                   	push   %ebx
  8010b7:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8010ba:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  8010bf:	83 ec 0c             	sub    $0xc,%esp
  8010c2:	89 d8                	mov    %ebx,%eax
  8010c4:	c1 e0 04             	shl    $0x4,%eax
  8010c7:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8010cd:	e8 57 19 00 00       	call   802a29 <pageref>
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	74 07                	je     8010e0 <openfile_alloc+0x2e>
  8010d9:	83 f8 01             	cmp    $0x1,%eax
  8010dc:	74 20                	je     8010fe <openfile_alloc+0x4c>
  8010de:	eb 51                	jmp    801131 <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8010e0:	83 ec 04             	sub    $0x4,%esp
  8010e3:	6a 07                	push   $0x7
  8010e5:	89 d8                	mov    %ebx,%eax
  8010e7:	c1 e0 04             	shl    $0x4,%eax
  8010ea:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8010f0:	6a 00                	push   $0x0
  8010f2:	e8 ea 12 00 00       	call   8023e1 <sys_page_alloc>
  8010f7:	83 c4 10             	add    $0x10,%esp
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	78 43                	js     801141 <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8010fe:	c1 e3 04             	shl    $0x4,%ebx
  801101:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  801107:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  80110e:	04 00 00 
			*o = &opentab[i];
  801111:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  801113:	83 ec 04             	sub    $0x4,%esp
  801116:	68 00 10 00 00       	push   $0x1000
  80111b:	6a 00                	push   $0x0
  80111d:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  801123:	e8 fb 0f 00 00       	call   802123 <memset>
			return (*o)->o_fileid;
  801128:	8b 06                	mov    (%esi),%eax
  80112a:	8b 00                	mov    (%eax),%eax
  80112c:	83 c4 10             	add    $0x10,%esp
  80112f:	eb 10                	jmp    801141 <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801131:	83 c3 01             	add    $0x1,%ebx
  801134:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80113a:	75 83                	jne    8010bf <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  80113c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801141:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801144:	5b                   	pop    %ebx
  801145:	5e                   	pop    %esi
  801146:	5d                   	pop    %ebp
  801147:	c3                   	ret    

00801148 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	57                   	push   %edi
  80114c:	56                   	push   %esi
  80114d:	53                   	push   %ebx
  80114e:	83 ec 18             	sub    $0x18,%esp
  801151:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801154:	89 fb                	mov    %edi,%ebx
  801156:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80115c:	89 de                	mov    %ebx,%esi
  80115e:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801161:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801167:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80116d:	e8 b7 18 00 00       	call   802a29 <pageref>
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	83 f8 01             	cmp    $0x1,%eax
  801178:	7e 17                	jle    801191 <openfile_lookup+0x49>
  80117a:	c1 e3 04             	shl    $0x4,%ebx
  80117d:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  801183:	75 13                	jne    801198 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  801185:	8b 45 10             	mov    0x10(%ebp),%eax
  801188:	89 30                	mov    %esi,(%eax)
	return 0;
  80118a:	b8 00 00 00 00       	mov    $0x0,%eax
  80118f:	eb 0c                	jmp    80119d <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  801191:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801196:	eb 05                	jmp    80119d <openfile_lookup+0x55>
  801198:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  80119d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5e                   	pop    %esi
  8011a2:	5f                   	pop    %edi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 18             	sub    $0x18,%esp
  8011ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8011af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b2:	50                   	push   %eax
  8011b3:	ff 33                	pushl  (%ebx)
  8011b5:	ff 75 08             	pushl  0x8(%ebp)
  8011b8:	e8 8b ff ff ff       	call   801148 <openfile_lookup>
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	78 14                	js     8011d8 <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8011c4:	83 ec 08             	sub    $0x8,%esp
  8011c7:	ff 73 04             	pushl  0x4(%ebx)
  8011ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011cd:	ff 70 04             	pushl  0x4(%eax)
  8011d0:	e8 f8 fa ff ff       	call   800ccd <file_set_size>
  8011d5:	83 c4 10             	add    $0x10,%esp
}
  8011d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011db:	c9                   	leave  
  8011dc:	c3                   	ret    

008011dd <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	53                   	push   %ebx
  8011e1:	83 ec 18             	sub    $0x18,%esp
  8011e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	
		res = openfile_lookup(envid, req->req_fileid, &o);
  8011e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ea:	50                   	push   %eax
  8011eb:	ff 33                	pushl  (%ebx)
  8011ed:	ff 75 08             	pushl  0x8(%ebp)
  8011f0:	e8 53 ff ff ff       	call   801148 <openfile_lookup>
	if(res < 0)
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	78 27                	js     801223 <serve_read+0x46>
	{
		return -E_INVAL;
	}	
	value = file_read(o->o_file, (void *)ret->ret_buf, req->req_n, o->o_fd->fd_offset);
  8011fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ff:	8b 50 0c             	mov    0xc(%eax),%edx
  801202:	ff 72 04             	pushl  0x4(%edx)
  801205:	ff 73 04             	pushl  0x4(%ebx)
  801208:	53                   	push   %ebx
  801209:	ff 70 04             	pushl  0x4(%eax)
  80120c:	e8 17 fa ff ff       	call   800c28 <file_read>
	if(value < 0)
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	85 c0                	test   %eax,%eax
  801216:	78 10                	js     801228 <serve_read+0x4b>
	{
		return value;
	} else {
		o->o_fd->fd_offset += (off_t)value;
  801218:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121b:	8b 52 0c             	mov    0xc(%edx),%edx
  80121e:	01 42 04             	add    %eax,0x4(%edx)
		return value;
  801221:	eb 05                	jmp    801228 <serve_read+0x4b>
	// Lab 5: Your code here:
	
		res = openfile_lookup(envid, req->req_fileid, &o);
	if(res < 0)
	{
		return -E_INVAL;
  801223:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	} else {
		o->o_fd->fd_offset += (off_t)value;
		return value;
	}
	
}
  801228:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122b:	c9                   	leave  
  80122c:	c3                   	ret    

0080122d <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	53                   	push   %ebx
  801231:	83 ec 18             	sub    $0x18,%esp
  801234:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	//panic("serve_write not implemented");
	
		res = openfile_lookup(envid, req->req_fileid, &o);
  801237:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123a:	50                   	push   %eax
  80123b:	ff 33                	pushl  (%ebx)
  80123d:	ff 75 08             	pushl  0x8(%ebp)
  801240:	e8 03 ff ff ff       	call   801148 <openfile_lookup>
        if(res < 0)
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	85 c0                	test   %eax,%eax
  80124a:	78 2a                	js     801276 <serve_write+0x49>
        {
                return -E_INVAL;
        }
	res = file_write(o->o_file, (void *)req->req_buf, req->req_n, o->o_fd->fd_offset);
  80124c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124f:	8b 50 0c             	mov    0xc(%eax),%edx
  801252:	ff 72 04             	pushl  0x4(%edx)
  801255:	ff 73 04             	pushl  0x4(%ebx)
  801258:	83 c3 08             	add    $0x8,%ebx
  80125b:	53                   	push   %ebx
  80125c:	ff 70 04             	pushl  0x4(%eax)
  80125f:	e8 4a fb ff ff       	call   800dae <file_write>
	if(res < 0)
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	78 10                	js     80127b <serve_write+0x4e>
	{
		return res;
	} else {
		o->o_fd->fd_offset += (off_t)res;
  80126b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80126e:	8b 52 0c             	mov    0xc(%edx),%edx
  801271:	01 42 04             	add    %eax,0x4(%edx)
		return res;
  801274:	eb 05                	jmp    80127b <serve_write+0x4e>
	//panic("serve_write not implemented");
	
		res = openfile_lookup(envid, req->req_fileid, &o);
        if(res < 0)
        {
                return -E_INVAL;
  801276:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return res;
	} else {
		o->o_fd->fd_offset += (off_t)res;
		return res;
	}
}
  80127b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127e:	c9                   	leave  
  80127f:	c3                   	ret    

00801280 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	53                   	push   %ebx
  801284:	83 ec 18             	sub    $0x18,%esp
  801287:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80128a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128d:	50                   	push   %eax
  80128e:	ff 33                	pushl  (%ebx)
  801290:	ff 75 08             	pushl  0x8(%ebp)
  801293:	e8 b0 fe ff ff       	call   801148 <openfile_lookup>
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 3f                	js     8012de <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  80129f:	83 ec 08             	sub    $0x8,%esp
  8012a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a5:	ff 70 04             	pushl  0x4(%eax)
  8012a8:	53                   	push   %ebx
  8012a9:	e8 30 0d 00 00       	call   801fde <strcpy>
	ret->ret_size = o->o_file->f_size;
  8012ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b1:	8b 50 04             	mov    0x4(%eax),%edx
  8012b4:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8012ba:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8012c0:	8b 40 04             	mov    0x4(%eax),%eax
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8012cd:	0f 94 c0             	sete   %al
  8012d0:	0f b6 c0             	movzbl %al,%eax
  8012d3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8012d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e1:	c9                   	leave  
  8012e2:	c3                   	ret    

008012e3 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ec:	50                   	push   %eax
  8012ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f0:	ff 30                	pushl  (%eax)
  8012f2:	ff 75 08             	pushl  0x8(%ebp)
  8012f5:	e8 4e fe ff ff       	call   801148 <openfile_lookup>
  8012fa:	83 c4 10             	add    $0x10,%esp
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	78 16                	js     801317 <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  801301:	83 ec 0c             	sub    $0xc,%esp
  801304:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801307:	ff 70 04             	pushl  0x4(%eax)
  80130a:	e8 45 fb ff ff       	call   800e54 <file_flush>
	return 0;
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801317:	c9                   	leave  
  801318:	c3                   	ret    

00801319 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801319:	55                   	push   %ebp
  80131a:	89 e5                	mov    %esp,%ebp
  80131c:	53                   	push   %ebx
  80131d:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801323:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801326:	68 00 04 00 00       	push   $0x400
  80132b:	53                   	push   %ebx
  80132c:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801332:	50                   	push   %eax
  801333:	e8 38 0e 00 00       	call   802170 <memmove>
	path[MAXPATHLEN-1] = 0;
  801338:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80133c:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801342:	89 04 24             	mov    %eax,(%esp)
  801345:	e8 68 fd ff ff       	call   8010b2 <openfile_alloc>
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	85 c0                	test   %eax,%eax
  80134f:	0f 88 f0 00 00 00    	js     801445 <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801355:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  80135c:	74 33                	je     801391 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  80135e:	83 ec 08             	sub    $0x8,%esp
  801361:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80136e:	50                   	push   %eax
  80136f:	e8 7d fb ff ff       	call   800ef1 <file_create>
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	85 c0                	test   %eax,%eax
  801379:	79 37                	jns    8013b2 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  80137b:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801382:	0f 85 bd 00 00 00    	jne    801445 <serve_open+0x12c>
  801388:	83 f8 f3             	cmp    $0xfffffff3,%eax
  80138b:	0f 85 b4 00 00 00    	jne    801445 <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8013a1:	50                   	push   %eax
  8013a2:	e8 67 f8 ff ff       	call   800c0e <file_open>
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	0f 88 93 00 00 00    	js     801445 <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8013b2:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8013b9:	74 17                	je     8013d2 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	6a 00                	push   $0x0
  8013c0:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8013c6:	e8 02 f9 ff ff       	call   800ccd <file_set_size>
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 73                	js     801445 <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8013db:	50                   	push   %eax
  8013dc:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8013e2:	50                   	push   %eax
  8013e3:	e8 26 f8 ff ff       	call   800c0e <file_open>
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	78 56                	js     801445 <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  8013ef:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8013f5:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8013fb:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8013fe:	8b 50 0c             	mov    0xc(%eax),%edx
  801401:	8b 08                	mov    (%eax),%ecx
  801403:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801406:	8b 48 0c             	mov    0xc(%eax),%ecx
  801409:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80140f:	83 e2 03             	and    $0x3,%edx
  801412:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801415:	8b 40 0c             	mov    0xc(%eax),%eax
  801418:	8b 15 64 90 80 00    	mov    0x809064,%edx
  80141e:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801420:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801426:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80142c:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  80142f:	8b 50 0c             	mov    0xc(%eax),%edx
  801432:	8b 45 10             	mov    0x10(%ebp),%eax
  801435:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801437:	8b 45 14             	mov    0x14(%ebp),%eax
  80143a:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  801440:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801445:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801448:	c9                   	leave  
  801449:	c3                   	ret    

0080144a <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	56                   	push   %esi
  80144e:	53                   	push   %ebx
  80144f:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801452:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801455:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801458:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80145f:	83 ec 04             	sub    $0x4,%esp
  801462:	53                   	push   %ebx
  801463:	ff 35 44 50 80 00    	pushl  0x805044
  801469:	56                   	push   %esi
  80146a:	e8 24 12 00 00       	call   802693 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801476:	75 15                	jne    80148d <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	ff 75 f4             	pushl  -0xc(%ebp)
  80147e:	68 18 3f 80 00       	push   $0x803f18
  801483:	e8 d1 05 00 00       	call   801a59 <cprintf>
				whom);
			continue; // just leave it hanging...
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	eb cb                	jmp    801458 <serve+0xe>
		}

		pg = NULL;
  80148d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  801494:	83 f8 01             	cmp    $0x1,%eax
  801497:	75 18                	jne    8014b1 <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801499:	53                   	push   %ebx
  80149a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80149d:	50                   	push   %eax
  80149e:	ff 35 44 50 80 00    	pushl  0x805044
  8014a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a7:	e8 6d fe ff ff       	call   801319 <serve_open>
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	eb 3c                	jmp    8014ed <serve+0xa3>
		} else if (req < NHANDLERS && handlers[req]) {
  8014b1:	83 f8 08             	cmp    $0x8,%eax
  8014b4:	77 1e                	ja     8014d4 <serve+0x8a>
  8014b6:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8014bd:	85 d2                	test   %edx,%edx
  8014bf:	74 13                	je     8014d4 <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	ff 35 44 50 80 00    	pushl  0x805044
  8014ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8014cd:	ff d2                	call   *%edx
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	eb 19                	jmp    8014ed <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8014d4:	83 ec 04             	sub    $0x4,%esp
  8014d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8014da:	50                   	push   %eax
  8014db:	68 48 3f 80 00       	push   $0x803f48
  8014e0:	e8 74 05 00 00       	call   801a59 <cprintf>
  8014e5:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8014e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8014ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8014f0:	ff 75 ec             	pushl  -0x14(%ebp)
  8014f3:	50                   	push   %eax
  8014f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f7:	e8 0c 12 00 00       	call   802708 <ipc_send>
		sys_page_unmap(0, fsreq);
  8014fc:	83 c4 08             	add    $0x8,%esp
  8014ff:	ff 35 44 50 80 00    	pushl  0x805044
  801505:	6a 00                	push   $0x0
  801507:	e8 5a 0f 00 00       	call   802466 <sys_page_unmap>
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	e9 44 ff ff ff       	jmp    801458 <serve+0xe>

00801514 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  80151a:	c7 05 60 90 80 00 6b 	movl   $0x803f6b,0x809060
  801521:	3f 80 00 
	cprintf("FS is running\n");
  801524:	68 6e 3f 80 00       	push   $0x803f6e
  801529:	e8 2b 05 00 00       	call   801a59 <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80152e:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801533:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801538:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  80153a:	c7 04 24 7d 3f 80 00 	movl   $0x803f7d,(%esp)
  801541:	e8 13 05 00 00       	call   801a59 <cprintf>

	serve_init();
  801546:	e8 3b fb ff ff       	call   801086 <serve_init>
	fs_init();
  80154b:	e8 bf f3 ff ff       	call   80090f <fs_init>
	serve();
  801550:	e8 f5 fe ff ff       	call   80144a <serve>

00801555 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	53                   	push   %ebx
  801559:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80155c:	6a 07                	push   $0x7
  80155e:	68 00 10 00 00       	push   $0x1000
  801563:	6a 00                	push   $0x0
  801565:	e8 77 0e 00 00       	call   8023e1 <sys_page_alloc>
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	85 c0                	test   %eax,%eax
  80156f:	79 12                	jns    801583 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  801571:	50                   	push   %eax
  801572:	68 8c 3f 80 00       	push   $0x803f8c
  801577:	6a 12                	push   $0x12
  801579:	68 9f 3f 80 00       	push   $0x803f9f
  80157e:	e8 fd 03 00 00       	call   801980 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801583:	83 ec 04             	sub    $0x4,%esp
  801586:	68 00 10 00 00       	push   $0x1000
  80158b:	ff 35 08 a0 80 00    	pushl  0x80a008
  801591:	68 00 10 00 00       	push   $0x1000
  801596:	e8 d5 0b 00 00       	call   802170 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  80159b:	e8 b9 f1 ff ff       	call   800759 <alloc_block>
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	79 12                	jns    8015b9 <fs_test+0x64>
		panic("alloc_block: %e", r);
  8015a7:	50                   	push   %eax
  8015a8:	68 a9 3f 80 00       	push   $0x803fa9
  8015ad:	6a 17                	push   $0x17
  8015af:	68 9f 3f 80 00       	push   $0x803f9f
  8015b4:	e8 c7 03 00 00       	call   801980 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8015b9:	8d 50 1f             	lea    0x1f(%eax),%edx
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	0f 49 d0             	cmovns %eax,%edx
  8015c1:	c1 fa 05             	sar    $0x5,%edx
  8015c4:	89 c3                	mov    %eax,%ebx
  8015c6:	c1 fb 1f             	sar    $0x1f,%ebx
  8015c9:	c1 eb 1b             	shr    $0x1b,%ebx
  8015cc:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8015cf:	83 e1 1f             	and    $0x1f,%ecx
  8015d2:	29 d9                	sub    %ebx,%ecx
  8015d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d9:	d3 e0                	shl    %cl,%eax
  8015db:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  8015e2:	75 16                	jne    8015fa <fs_test+0xa5>
  8015e4:	68 b9 3f 80 00       	push   $0x803fb9
  8015e9:	68 3d 3c 80 00       	push   $0x803c3d
  8015ee:	6a 19                	push   $0x19
  8015f0:	68 9f 3f 80 00       	push   $0x803f9f
  8015f5:	e8 86 03 00 00       	call   801980 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8015fa:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  801600:	85 04 91             	test   %eax,(%ecx,%edx,4)
  801603:	74 16                	je     80161b <fs_test+0xc6>
  801605:	68 34 41 80 00       	push   $0x804134
  80160a:	68 3d 3c 80 00       	push   $0x803c3d
  80160f:	6a 1b                	push   $0x1b
  801611:	68 9f 3f 80 00       	push   $0x803f9f
  801616:	e8 65 03 00 00       	call   801980 <_panic>
	cprintf("alloc_block is good\n");
  80161b:	83 ec 0c             	sub    $0xc,%esp
  80161e:	68 d4 3f 80 00       	push   $0x803fd4
  801623:	e8 31 04 00 00       	call   801a59 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801628:	83 c4 08             	add    $0x8,%esp
  80162b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162e:	50                   	push   %eax
  80162f:	68 e9 3f 80 00       	push   $0x803fe9
  801634:	e8 d5 f5 ff ff       	call   800c0e <file_open>
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80163f:	74 1b                	je     80165c <fs_test+0x107>
  801641:	89 c2                	mov    %eax,%edx
  801643:	c1 ea 1f             	shr    $0x1f,%edx
  801646:	84 d2                	test   %dl,%dl
  801648:	74 12                	je     80165c <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  80164a:	50                   	push   %eax
  80164b:	68 f4 3f 80 00       	push   $0x803ff4
  801650:	6a 1f                	push   $0x1f
  801652:	68 9f 3f 80 00       	push   $0x803f9f
  801657:	e8 24 03 00 00       	call   801980 <_panic>
	else if (r == 0)
  80165c:	85 c0                	test   %eax,%eax
  80165e:	75 14                	jne    801674 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  801660:	83 ec 04             	sub    $0x4,%esp
  801663:	68 54 41 80 00       	push   $0x804154
  801668:	6a 21                	push   $0x21
  80166a:	68 9f 3f 80 00       	push   $0x803f9f
  80166f:	e8 0c 03 00 00       	call   801980 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801674:	83 ec 08             	sub    $0x8,%esp
  801677:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167a:	50                   	push   %eax
  80167b:	68 0d 40 80 00       	push   $0x80400d
  801680:	e8 89 f5 ff ff       	call   800c0e <file_open>
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	85 c0                	test   %eax,%eax
  80168a:	79 12                	jns    80169e <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  80168c:	50                   	push   %eax
  80168d:	68 16 40 80 00       	push   $0x804016
  801692:	6a 23                	push   $0x23
  801694:	68 9f 3f 80 00       	push   $0x803f9f
  801699:	e8 e2 02 00 00       	call   801980 <_panic>
	cprintf("file_open is good\n");
  80169e:	83 ec 0c             	sub    $0xc,%esp
  8016a1:	68 2d 40 80 00       	push   $0x80402d
  8016a6:	e8 ae 03 00 00       	call   801a59 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8016ab:	83 c4 0c             	add    $0xc,%esp
  8016ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b1:	50                   	push   %eax
  8016b2:	6a 00                	push   $0x0
  8016b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b7:	e8 b2 f2 ff ff       	call   80096e <file_get_block>
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	79 12                	jns    8016d5 <fs_test+0x180>
		panic("file_get_block: %e", r);
  8016c3:	50                   	push   %eax
  8016c4:	68 40 40 80 00       	push   $0x804040
  8016c9:	6a 27                	push   $0x27
  8016cb:	68 9f 3f 80 00       	push   $0x803f9f
  8016d0:	e8 ab 02 00 00       	call   801980 <_panic>
	if (strcmp(blk, msg) != 0)
  8016d5:	83 ec 08             	sub    $0x8,%esp
  8016d8:	68 74 41 80 00       	push   $0x804174
  8016dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e0:	e8 a3 09 00 00       	call   802088 <strcmp>
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	85 c0                	test   %eax,%eax
  8016ea:	74 14                	je     801700 <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8016ec:	83 ec 04             	sub    $0x4,%esp
  8016ef:	68 9c 41 80 00       	push   $0x80419c
  8016f4:	6a 29                	push   $0x29
  8016f6:	68 9f 3f 80 00       	push   $0x803f9f
  8016fb:	e8 80 02 00 00       	call   801980 <_panic>
	cprintf("file_get_block is good\n");
  801700:	83 ec 0c             	sub    $0xc,%esp
  801703:	68 53 40 80 00       	push   $0x804053
  801708:	e8 4c 03 00 00       	call   801a59 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80170d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801710:	0f b6 10             	movzbl (%eax),%edx
  801713:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801715:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801718:	c1 e8 0c             	shr    $0xc,%eax
  80171b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	a8 40                	test   $0x40,%al
  801727:	75 16                	jne    80173f <fs_test+0x1ea>
  801729:	68 6c 40 80 00       	push   $0x80406c
  80172e:	68 3d 3c 80 00       	push   $0x803c3d
  801733:	6a 2d                	push   $0x2d
  801735:	68 9f 3f 80 00       	push   $0x803f9f
  80173a:	e8 41 02 00 00       	call   801980 <_panic>
	file_flush(f);
  80173f:	83 ec 0c             	sub    $0xc,%esp
  801742:	ff 75 f4             	pushl  -0xc(%ebp)
  801745:	e8 0a f7 ff ff       	call   800e54 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80174a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174d:	c1 e8 0c             	shr    $0xc,%eax
  801750:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	a8 40                	test   $0x40,%al
  80175c:	74 16                	je     801774 <fs_test+0x21f>
  80175e:	68 6b 40 80 00       	push   $0x80406b
  801763:	68 3d 3c 80 00       	push   $0x803c3d
  801768:	6a 2f                	push   $0x2f
  80176a:	68 9f 3f 80 00       	push   $0x803f9f
  80176f:	e8 0c 02 00 00       	call   801980 <_panic>
	cprintf("file_flush is good\n");
  801774:	83 ec 0c             	sub    $0xc,%esp
  801777:	68 87 40 80 00       	push   $0x804087
  80177c:	e8 d8 02 00 00       	call   801a59 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801781:	83 c4 08             	add    $0x8,%esp
  801784:	6a 00                	push   $0x0
  801786:	ff 75 f4             	pushl  -0xc(%ebp)
  801789:	e8 3f f5 ff ff       	call   800ccd <file_set_size>
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	85 c0                	test   %eax,%eax
  801793:	79 12                	jns    8017a7 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801795:	50                   	push   %eax
  801796:	68 9b 40 80 00       	push   $0x80409b
  80179b:	6a 33                	push   $0x33
  80179d:	68 9f 3f 80 00       	push   $0x803f9f
  8017a2:	e8 d9 01 00 00       	call   801980 <_panic>
	assert(f->f_direct[0] == 0);
  8017a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017aa:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8017b1:	74 16                	je     8017c9 <fs_test+0x274>
  8017b3:	68 ad 40 80 00       	push   $0x8040ad
  8017b8:	68 3d 3c 80 00       	push   $0x803c3d
  8017bd:	6a 34                	push   $0x34
  8017bf:	68 9f 3f 80 00       	push   $0x803f9f
  8017c4:	e8 b7 01 00 00       	call   801980 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8017c9:	c1 e8 0c             	shr    $0xc,%eax
  8017cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017d3:	a8 40                	test   $0x40,%al
  8017d5:	74 16                	je     8017ed <fs_test+0x298>
  8017d7:	68 c1 40 80 00       	push   $0x8040c1
  8017dc:	68 3d 3c 80 00       	push   $0x803c3d
  8017e1:	6a 35                	push   $0x35
  8017e3:	68 9f 3f 80 00       	push   $0x803f9f
  8017e8:	e8 93 01 00 00       	call   801980 <_panic>
	cprintf("file_truncate is good\n");
  8017ed:	83 ec 0c             	sub    $0xc,%esp
  8017f0:	68 db 40 80 00       	push   $0x8040db
  8017f5:	e8 5f 02 00 00       	call   801a59 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8017fa:	c7 04 24 74 41 80 00 	movl   $0x804174,(%esp)
  801801:	e8 9f 07 00 00       	call   801fa5 <strlen>
  801806:	83 c4 08             	add    $0x8,%esp
  801809:	50                   	push   %eax
  80180a:	ff 75 f4             	pushl  -0xc(%ebp)
  80180d:	e8 bb f4 ff ff       	call   800ccd <file_set_size>
  801812:	83 c4 10             	add    $0x10,%esp
  801815:	85 c0                	test   %eax,%eax
  801817:	79 12                	jns    80182b <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  801819:	50                   	push   %eax
  80181a:	68 f2 40 80 00       	push   $0x8040f2
  80181f:	6a 39                	push   $0x39
  801821:	68 9f 3f 80 00       	push   $0x803f9f
  801826:	e8 55 01 00 00       	call   801980 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80182b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182e:	89 c2                	mov    %eax,%edx
  801830:	c1 ea 0c             	shr    $0xc,%edx
  801833:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80183a:	f6 c2 40             	test   $0x40,%dl
  80183d:	74 16                	je     801855 <fs_test+0x300>
  80183f:	68 c1 40 80 00       	push   $0x8040c1
  801844:	68 3d 3c 80 00       	push   $0x803c3d
  801849:	6a 3a                	push   $0x3a
  80184b:	68 9f 3f 80 00       	push   $0x803f9f
  801850:	e8 2b 01 00 00       	call   801980 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801855:	83 ec 04             	sub    $0x4,%esp
  801858:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80185b:	52                   	push   %edx
  80185c:	6a 00                	push   $0x0
  80185e:	50                   	push   %eax
  80185f:	e8 0a f1 ff ff       	call   80096e <file_get_block>
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	85 c0                	test   %eax,%eax
  801869:	79 12                	jns    80187d <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  80186b:	50                   	push   %eax
  80186c:	68 06 41 80 00       	push   $0x804106
  801871:	6a 3c                	push   $0x3c
  801873:	68 9f 3f 80 00       	push   $0x803f9f
  801878:	e8 03 01 00 00       	call   801980 <_panic>
	strcpy(blk, msg);
  80187d:	83 ec 08             	sub    $0x8,%esp
  801880:	68 74 41 80 00       	push   $0x804174
  801885:	ff 75 f0             	pushl  -0x10(%ebp)
  801888:	e8 51 07 00 00       	call   801fde <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80188d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801890:	c1 e8 0c             	shr    $0xc,%eax
  801893:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	a8 40                	test   $0x40,%al
  80189f:	75 16                	jne    8018b7 <fs_test+0x362>
  8018a1:	68 6c 40 80 00       	push   $0x80406c
  8018a6:	68 3d 3c 80 00       	push   $0x803c3d
  8018ab:	6a 3e                	push   $0x3e
  8018ad:	68 9f 3f 80 00       	push   $0x803f9f
  8018b2:	e8 c9 00 00 00       	call   801980 <_panic>
	file_flush(f);
  8018b7:	83 ec 0c             	sub    $0xc,%esp
  8018ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8018bd:	e8 92 f5 ff ff       	call   800e54 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c5:	c1 e8 0c             	shr    $0xc,%eax
  8018c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	a8 40                	test   $0x40,%al
  8018d4:	74 16                	je     8018ec <fs_test+0x397>
  8018d6:	68 6b 40 80 00       	push   $0x80406b
  8018db:	68 3d 3c 80 00       	push   $0x803c3d
  8018e0:	6a 40                	push   $0x40
  8018e2:	68 9f 3f 80 00       	push   $0x803f9f
  8018e7:	e8 94 00 00 00       	call   801980 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ef:	c1 e8 0c             	shr    $0xc,%eax
  8018f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018f9:	a8 40                	test   $0x40,%al
  8018fb:	74 16                	je     801913 <fs_test+0x3be>
  8018fd:	68 c1 40 80 00       	push   $0x8040c1
  801902:	68 3d 3c 80 00       	push   $0x803c3d
  801907:	6a 41                	push   $0x41
  801909:	68 9f 3f 80 00       	push   $0x803f9f
  80190e:	e8 6d 00 00 00       	call   801980 <_panic>
	cprintf("file rewrite is good\n");
  801913:	83 ec 0c             	sub    $0xc,%esp
  801916:	68 1b 41 80 00       	push   $0x80411b
  80191b:	e8 39 01 00 00       	call   801a59 <cprintf>
}
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801926:	c9                   	leave  
  801927:	c3                   	ret    

00801928 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	56                   	push   %esi
  80192c:	53                   	push   %ebx
  80192d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801930:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  801933:	e8 6b 0a 00 00       	call   8023a3 <sys_getenvid>
  801938:	25 ff 03 00 00       	and    $0x3ff,%eax
  80193d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801940:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801945:	a3 10 a0 80 00       	mov    %eax,0x80a010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80194a:	85 db                	test   %ebx,%ebx
  80194c:	7e 07                	jle    801955 <libmain+0x2d>
		binaryname = argv[0];
  80194e:	8b 06                	mov    (%esi),%eax
  801950:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801955:	83 ec 08             	sub    $0x8,%esp
  801958:	56                   	push   %esi
  801959:	53                   	push   %ebx
  80195a:	e8 b5 fb ff ff       	call   801514 <umain>

	// exit gracefully
	exit();
  80195f:	e8 0a 00 00 00       	call   80196e <exit>
}
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196a:	5b                   	pop    %ebx
  80196b:	5e                   	pop    %esi
  80196c:	5d                   	pop    %ebp
  80196d:	c3                   	ret    

0080196e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  801974:	6a 00                	push   $0x0
  801976:	e8 e7 09 00 00       	call   802362 <sys_env_destroy>
}
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    

00801980 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	56                   	push   %esi
  801984:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801985:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801988:	8b 35 60 90 80 00    	mov    0x809060,%esi
  80198e:	e8 10 0a 00 00       	call   8023a3 <sys_getenvid>
  801993:	83 ec 0c             	sub    $0xc,%esp
  801996:	ff 75 0c             	pushl  0xc(%ebp)
  801999:	ff 75 08             	pushl  0x8(%ebp)
  80199c:	56                   	push   %esi
  80199d:	50                   	push   %eax
  80199e:	68 cc 41 80 00       	push   $0x8041cc
  8019a3:	e8 b1 00 00 00       	call   801a59 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019a8:	83 c4 18             	add    $0x18,%esp
  8019ab:	53                   	push   %ebx
  8019ac:	ff 75 10             	pushl  0x10(%ebp)
  8019af:	e8 54 00 00 00       	call   801a08 <vcprintf>
	cprintf("\n");
  8019b4:	c7 04 24 dd 3d 80 00 	movl   $0x803ddd,(%esp)
  8019bb:	e8 99 00 00 00       	call   801a59 <cprintf>
  8019c0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019c3:	cc                   	int3   
  8019c4:	eb fd                	jmp    8019c3 <_panic+0x43>

008019c6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	53                   	push   %ebx
  8019ca:	83 ec 04             	sub    $0x4,%esp
  8019cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8019d0:	8b 13                	mov    (%ebx),%edx
  8019d2:	8d 42 01             	lea    0x1(%edx),%eax
  8019d5:	89 03                	mov    %eax,(%ebx)
  8019d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019da:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8019de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8019e3:	75 1a                	jne    8019ff <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8019e5:	83 ec 08             	sub    $0x8,%esp
  8019e8:	68 ff 00 00 00       	push   $0xff
  8019ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8019f0:	50                   	push   %eax
  8019f1:	e8 2f 09 00 00       	call   802325 <sys_cputs>
		b->idx = 0;
  8019f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8019fc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8019ff:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801a03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801a11:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a18:	00 00 00 
	b.cnt = 0;
  801a1b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801a22:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801a25:	ff 75 0c             	pushl  0xc(%ebp)
  801a28:	ff 75 08             	pushl  0x8(%ebp)
  801a2b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a31:	50                   	push   %eax
  801a32:	68 c6 19 80 00       	push   $0x8019c6
  801a37:	e8 54 01 00 00       	call   801b90 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801a3c:	83 c4 08             	add    $0x8,%esp
  801a3f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801a45:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801a4b:	50                   	push   %eax
  801a4c:	e8 d4 08 00 00       	call   802325 <sys_cputs>

	return b.cnt;
}
  801a51:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    

00801a59 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a5f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801a62:	50                   	push   %eax
  801a63:	ff 75 08             	pushl  0x8(%ebp)
  801a66:	e8 9d ff ff ff       	call   801a08 <vcprintf>
	va_end(ap);

	return cnt;
}
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	57                   	push   %edi
  801a71:	56                   	push   %esi
  801a72:	53                   	push   %ebx
  801a73:	83 ec 1c             	sub    $0x1c,%esp
  801a76:	89 c7                	mov    %eax,%edi
  801a78:	89 d6                	mov    %edx,%esi
  801a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a80:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a83:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801a86:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a89:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a8e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801a91:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801a94:	39 d3                	cmp    %edx,%ebx
  801a96:	72 05                	jb     801a9d <printnum+0x30>
  801a98:	39 45 10             	cmp    %eax,0x10(%ebp)
  801a9b:	77 45                	ja     801ae2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801a9d:	83 ec 0c             	sub    $0xc,%esp
  801aa0:	ff 75 18             	pushl  0x18(%ebp)
  801aa3:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801aa9:	53                   	push   %ebx
  801aaa:	ff 75 10             	pushl  0x10(%ebp)
  801aad:	83 ec 08             	sub    $0x8,%esp
  801ab0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ab3:	ff 75 e0             	pushl  -0x20(%ebp)
  801ab6:	ff 75 dc             	pushl  -0x24(%ebp)
  801ab9:	ff 75 d8             	pushl  -0x28(%ebp)
  801abc:	e8 9f 1e 00 00       	call   803960 <__udivdi3>
  801ac1:	83 c4 18             	add    $0x18,%esp
  801ac4:	52                   	push   %edx
  801ac5:	50                   	push   %eax
  801ac6:	89 f2                	mov    %esi,%edx
  801ac8:	89 f8                	mov    %edi,%eax
  801aca:	e8 9e ff ff ff       	call   801a6d <printnum>
  801acf:	83 c4 20             	add    $0x20,%esp
  801ad2:	eb 18                	jmp    801aec <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801ad4:	83 ec 08             	sub    $0x8,%esp
  801ad7:	56                   	push   %esi
  801ad8:	ff 75 18             	pushl  0x18(%ebp)
  801adb:	ff d7                	call   *%edi
  801add:	83 c4 10             	add    $0x10,%esp
  801ae0:	eb 03                	jmp    801ae5 <printnum+0x78>
  801ae2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801ae5:	83 eb 01             	sub    $0x1,%ebx
  801ae8:	85 db                	test   %ebx,%ebx
  801aea:	7f e8                	jg     801ad4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801aec:	83 ec 08             	sub    $0x8,%esp
  801aef:	56                   	push   %esi
  801af0:	83 ec 04             	sub    $0x4,%esp
  801af3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801af6:	ff 75 e0             	pushl  -0x20(%ebp)
  801af9:	ff 75 dc             	pushl  -0x24(%ebp)
  801afc:	ff 75 d8             	pushl  -0x28(%ebp)
  801aff:	e8 8c 1f 00 00       	call   803a90 <__umoddi3>
  801b04:	83 c4 14             	add    $0x14,%esp
  801b07:	0f be 80 ef 41 80 00 	movsbl 0x8041ef(%eax),%eax
  801b0e:	50                   	push   %eax
  801b0f:	ff d7                	call   *%edi
}
  801b11:	83 c4 10             	add    $0x10,%esp
  801b14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b17:	5b                   	pop    %ebx
  801b18:	5e                   	pop    %esi
  801b19:	5f                   	pop    %edi
  801b1a:	5d                   	pop    %ebp
  801b1b:	c3                   	ret    

00801b1c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801b1f:	83 fa 01             	cmp    $0x1,%edx
  801b22:	7e 0e                	jle    801b32 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801b24:	8b 10                	mov    (%eax),%edx
  801b26:	8d 4a 08             	lea    0x8(%edx),%ecx
  801b29:	89 08                	mov    %ecx,(%eax)
  801b2b:	8b 02                	mov    (%edx),%eax
  801b2d:	8b 52 04             	mov    0x4(%edx),%edx
  801b30:	eb 22                	jmp    801b54 <getuint+0x38>
	else if (lflag)
  801b32:	85 d2                	test   %edx,%edx
  801b34:	74 10                	je     801b46 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801b36:	8b 10                	mov    (%eax),%edx
  801b38:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b3b:	89 08                	mov    %ecx,(%eax)
  801b3d:	8b 02                	mov    (%edx),%eax
  801b3f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b44:	eb 0e                	jmp    801b54 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801b46:	8b 10                	mov    (%eax),%edx
  801b48:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b4b:	89 08                	mov    %ecx,(%eax)
  801b4d:	8b 02                	mov    (%edx),%eax
  801b4f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    

00801b56 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801b5c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801b60:	8b 10                	mov    (%eax),%edx
  801b62:	3b 50 04             	cmp    0x4(%eax),%edx
  801b65:	73 0a                	jae    801b71 <sprintputch+0x1b>
		*b->buf++ = ch;
  801b67:	8d 4a 01             	lea    0x1(%edx),%ecx
  801b6a:	89 08                	mov    %ecx,(%eax)
  801b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6f:	88 02                	mov    %al,(%edx)
}
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801b79:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801b7c:	50                   	push   %eax
  801b7d:	ff 75 10             	pushl  0x10(%ebp)
  801b80:	ff 75 0c             	pushl  0xc(%ebp)
  801b83:	ff 75 08             	pushl  0x8(%ebp)
  801b86:	e8 05 00 00 00       	call   801b90 <vprintfmt>
	va_end(ap);
}
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	57                   	push   %edi
  801b94:	56                   	push   %esi
  801b95:	53                   	push   %ebx
  801b96:	83 ec 2c             	sub    $0x2c,%esp
  801b99:	8b 75 08             	mov    0x8(%ebp),%esi
  801b9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b9f:	8b 7d 10             	mov    0x10(%ebp),%edi
  801ba2:	eb 12                	jmp    801bb6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	0f 84 89 03 00 00    	je     801f35 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801bac:	83 ec 08             	sub    $0x8,%esp
  801baf:	53                   	push   %ebx
  801bb0:	50                   	push   %eax
  801bb1:	ff d6                	call   *%esi
  801bb3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801bb6:	83 c7 01             	add    $0x1,%edi
  801bb9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801bbd:	83 f8 25             	cmp    $0x25,%eax
  801bc0:	75 e2                	jne    801ba4 <vprintfmt+0x14>
  801bc2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801bc6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801bcd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801bd4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  801be0:	eb 07                	jmp    801be9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801be2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801be5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801be9:	8d 47 01             	lea    0x1(%edi),%eax
  801bec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bef:	0f b6 07             	movzbl (%edi),%eax
  801bf2:	0f b6 c8             	movzbl %al,%ecx
  801bf5:	83 e8 23             	sub    $0x23,%eax
  801bf8:	3c 55                	cmp    $0x55,%al
  801bfa:	0f 87 1a 03 00 00    	ja     801f1a <vprintfmt+0x38a>
  801c00:	0f b6 c0             	movzbl %al,%eax
  801c03:	ff 24 85 40 43 80 00 	jmp    *0x804340(,%eax,4)
  801c0a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801c0d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801c11:	eb d6                	jmp    801be9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c13:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c16:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801c1e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801c21:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801c25:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801c28:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801c2b:	83 fa 09             	cmp    $0x9,%edx
  801c2e:	77 39                	ja     801c69 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801c30:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801c33:	eb e9                	jmp    801c1e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801c35:	8b 45 14             	mov    0x14(%ebp),%eax
  801c38:	8d 48 04             	lea    0x4(%eax),%ecx
  801c3b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801c3e:	8b 00                	mov    (%eax),%eax
  801c40:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801c46:	eb 27                	jmp    801c6f <vprintfmt+0xdf>
  801c48:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801c52:	0f 49 c8             	cmovns %eax,%ecx
  801c55:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c58:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c5b:	eb 8c                	jmp    801be9 <vprintfmt+0x59>
  801c5d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801c60:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801c67:	eb 80                	jmp    801be9 <vprintfmt+0x59>
  801c69:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c6c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801c6f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c73:	0f 89 70 ff ff ff    	jns    801be9 <vprintfmt+0x59>
				width = precision, precision = -1;
  801c79:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801c7c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c7f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801c86:	e9 5e ff ff ff       	jmp    801be9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801c8b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c8e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801c91:	e9 53 ff ff ff       	jmp    801be9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801c96:	8b 45 14             	mov    0x14(%ebp),%eax
  801c99:	8d 50 04             	lea    0x4(%eax),%edx
  801c9c:	89 55 14             	mov    %edx,0x14(%ebp)
  801c9f:	83 ec 08             	sub    $0x8,%esp
  801ca2:	53                   	push   %ebx
  801ca3:	ff 30                	pushl  (%eax)
  801ca5:	ff d6                	call   *%esi
			break;
  801ca7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801caa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801cad:	e9 04 ff ff ff       	jmp    801bb6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801cb2:	8b 45 14             	mov    0x14(%ebp),%eax
  801cb5:	8d 50 04             	lea    0x4(%eax),%edx
  801cb8:	89 55 14             	mov    %edx,0x14(%ebp)
  801cbb:	8b 00                	mov    (%eax),%eax
  801cbd:	99                   	cltd   
  801cbe:	31 d0                	xor    %edx,%eax
  801cc0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801cc2:	83 f8 0f             	cmp    $0xf,%eax
  801cc5:	7f 0b                	jg     801cd2 <vprintfmt+0x142>
  801cc7:	8b 14 85 a0 44 80 00 	mov    0x8044a0(,%eax,4),%edx
  801cce:	85 d2                	test   %edx,%edx
  801cd0:	75 18                	jne    801cea <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801cd2:	50                   	push   %eax
  801cd3:	68 07 42 80 00       	push   $0x804207
  801cd8:	53                   	push   %ebx
  801cd9:	56                   	push   %esi
  801cda:	e8 94 fe ff ff       	call   801b73 <printfmt>
  801cdf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ce2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801ce5:	e9 cc fe ff ff       	jmp    801bb6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801cea:	52                   	push   %edx
  801ceb:	68 4f 3c 80 00       	push   $0x803c4f
  801cf0:	53                   	push   %ebx
  801cf1:	56                   	push   %esi
  801cf2:	e8 7c fe ff ff       	call   801b73 <printfmt>
  801cf7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cfa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801cfd:	e9 b4 fe ff ff       	jmp    801bb6 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801d02:	8b 45 14             	mov    0x14(%ebp),%eax
  801d05:	8d 50 04             	lea    0x4(%eax),%edx
  801d08:	89 55 14             	mov    %edx,0x14(%ebp)
  801d0b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801d0d:	85 ff                	test   %edi,%edi
  801d0f:	b8 00 42 80 00       	mov    $0x804200,%eax
  801d14:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801d17:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d1b:	0f 8e 94 00 00 00    	jle    801db5 <vprintfmt+0x225>
  801d21:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801d25:	0f 84 98 00 00 00    	je     801dc3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801d2b:	83 ec 08             	sub    $0x8,%esp
  801d2e:	ff 75 d0             	pushl  -0x30(%ebp)
  801d31:	57                   	push   %edi
  801d32:	e8 86 02 00 00       	call   801fbd <strnlen>
  801d37:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801d3a:	29 c1                	sub    %eax,%ecx
  801d3c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801d3f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801d42:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801d46:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d49:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801d4c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d4e:	eb 0f                	jmp    801d5f <vprintfmt+0x1cf>
					putch(padc, putdat);
  801d50:	83 ec 08             	sub    $0x8,%esp
  801d53:	53                   	push   %ebx
  801d54:	ff 75 e0             	pushl  -0x20(%ebp)
  801d57:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d59:	83 ef 01             	sub    $0x1,%edi
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	85 ff                	test   %edi,%edi
  801d61:	7f ed                	jg     801d50 <vprintfmt+0x1c0>
  801d63:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801d66:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d69:	85 c9                	test   %ecx,%ecx
  801d6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d70:	0f 49 c1             	cmovns %ecx,%eax
  801d73:	29 c1                	sub    %eax,%ecx
  801d75:	89 75 08             	mov    %esi,0x8(%ebp)
  801d78:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d7b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d7e:	89 cb                	mov    %ecx,%ebx
  801d80:	eb 4d                	jmp    801dcf <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801d82:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801d86:	74 1b                	je     801da3 <vprintfmt+0x213>
  801d88:	0f be c0             	movsbl %al,%eax
  801d8b:	83 e8 20             	sub    $0x20,%eax
  801d8e:	83 f8 5e             	cmp    $0x5e,%eax
  801d91:	76 10                	jbe    801da3 <vprintfmt+0x213>
					putch('?', putdat);
  801d93:	83 ec 08             	sub    $0x8,%esp
  801d96:	ff 75 0c             	pushl  0xc(%ebp)
  801d99:	6a 3f                	push   $0x3f
  801d9b:	ff 55 08             	call   *0x8(%ebp)
  801d9e:	83 c4 10             	add    $0x10,%esp
  801da1:	eb 0d                	jmp    801db0 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801da3:	83 ec 08             	sub    $0x8,%esp
  801da6:	ff 75 0c             	pushl  0xc(%ebp)
  801da9:	52                   	push   %edx
  801daa:	ff 55 08             	call   *0x8(%ebp)
  801dad:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801db0:	83 eb 01             	sub    $0x1,%ebx
  801db3:	eb 1a                	jmp    801dcf <vprintfmt+0x23f>
  801db5:	89 75 08             	mov    %esi,0x8(%ebp)
  801db8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801dbb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801dbe:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801dc1:	eb 0c                	jmp    801dcf <vprintfmt+0x23f>
  801dc3:	89 75 08             	mov    %esi,0x8(%ebp)
  801dc6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801dc9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801dcc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801dcf:	83 c7 01             	add    $0x1,%edi
  801dd2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801dd6:	0f be d0             	movsbl %al,%edx
  801dd9:	85 d2                	test   %edx,%edx
  801ddb:	74 23                	je     801e00 <vprintfmt+0x270>
  801ddd:	85 f6                	test   %esi,%esi
  801ddf:	78 a1                	js     801d82 <vprintfmt+0x1f2>
  801de1:	83 ee 01             	sub    $0x1,%esi
  801de4:	79 9c                	jns    801d82 <vprintfmt+0x1f2>
  801de6:	89 df                	mov    %ebx,%edi
  801de8:	8b 75 08             	mov    0x8(%ebp),%esi
  801deb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dee:	eb 18                	jmp    801e08 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801df0:	83 ec 08             	sub    $0x8,%esp
  801df3:	53                   	push   %ebx
  801df4:	6a 20                	push   $0x20
  801df6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801df8:	83 ef 01             	sub    $0x1,%edi
  801dfb:	83 c4 10             	add    $0x10,%esp
  801dfe:	eb 08                	jmp    801e08 <vprintfmt+0x278>
  801e00:	89 df                	mov    %ebx,%edi
  801e02:	8b 75 08             	mov    0x8(%ebp),%esi
  801e05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e08:	85 ff                	test   %edi,%edi
  801e0a:	7f e4                	jg     801df0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e0c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e0f:	e9 a2 fd ff ff       	jmp    801bb6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e14:	83 fa 01             	cmp    $0x1,%edx
  801e17:	7e 16                	jle    801e2f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801e19:	8b 45 14             	mov    0x14(%ebp),%eax
  801e1c:	8d 50 08             	lea    0x8(%eax),%edx
  801e1f:	89 55 14             	mov    %edx,0x14(%ebp)
  801e22:	8b 50 04             	mov    0x4(%eax),%edx
  801e25:	8b 00                	mov    (%eax),%eax
  801e27:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e2a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801e2d:	eb 32                	jmp    801e61 <vprintfmt+0x2d1>
	else if (lflag)
  801e2f:	85 d2                	test   %edx,%edx
  801e31:	74 18                	je     801e4b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801e33:	8b 45 14             	mov    0x14(%ebp),%eax
  801e36:	8d 50 04             	lea    0x4(%eax),%edx
  801e39:	89 55 14             	mov    %edx,0x14(%ebp)
  801e3c:	8b 00                	mov    (%eax),%eax
  801e3e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e41:	89 c1                	mov    %eax,%ecx
  801e43:	c1 f9 1f             	sar    $0x1f,%ecx
  801e46:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801e49:	eb 16                	jmp    801e61 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801e4b:	8b 45 14             	mov    0x14(%ebp),%eax
  801e4e:	8d 50 04             	lea    0x4(%eax),%edx
  801e51:	89 55 14             	mov    %edx,0x14(%ebp)
  801e54:	8b 00                	mov    (%eax),%eax
  801e56:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e59:	89 c1                	mov    %eax,%ecx
  801e5b:	c1 f9 1f             	sar    $0x1f,%ecx
  801e5e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801e61:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e64:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801e67:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801e6c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801e70:	79 74                	jns    801ee6 <vprintfmt+0x356>
				putch('-', putdat);
  801e72:	83 ec 08             	sub    $0x8,%esp
  801e75:	53                   	push   %ebx
  801e76:	6a 2d                	push   $0x2d
  801e78:	ff d6                	call   *%esi
				num = -(long long) num;
  801e7a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e7d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801e80:	f7 d8                	neg    %eax
  801e82:	83 d2 00             	adc    $0x0,%edx
  801e85:	f7 da                	neg    %edx
  801e87:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801e8a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801e8f:	eb 55                	jmp    801ee6 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801e91:	8d 45 14             	lea    0x14(%ebp),%eax
  801e94:	e8 83 fc ff ff       	call   801b1c <getuint>
			base = 10;
  801e99:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801e9e:	eb 46                	jmp    801ee6 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  801ea0:	8d 45 14             	lea    0x14(%ebp),%eax
  801ea3:	e8 74 fc ff ff       	call   801b1c <getuint>
			base = 8;
  801ea8:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801ead:	eb 37                	jmp    801ee6 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  801eaf:	83 ec 08             	sub    $0x8,%esp
  801eb2:	53                   	push   %ebx
  801eb3:	6a 30                	push   $0x30
  801eb5:	ff d6                	call   *%esi
			putch('x', putdat);
  801eb7:	83 c4 08             	add    $0x8,%esp
  801eba:	53                   	push   %ebx
  801ebb:	6a 78                	push   $0x78
  801ebd:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801ebf:	8b 45 14             	mov    0x14(%ebp),%eax
  801ec2:	8d 50 04             	lea    0x4(%eax),%edx
  801ec5:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801ec8:	8b 00                	mov    (%eax),%eax
  801eca:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ecf:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ed2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ed7:	eb 0d                	jmp    801ee6 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801ed9:	8d 45 14             	lea    0x14(%ebp),%eax
  801edc:	e8 3b fc ff ff       	call   801b1c <getuint>
			base = 16;
  801ee1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ee6:	83 ec 0c             	sub    $0xc,%esp
  801ee9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801eed:	57                   	push   %edi
  801eee:	ff 75 e0             	pushl  -0x20(%ebp)
  801ef1:	51                   	push   %ecx
  801ef2:	52                   	push   %edx
  801ef3:	50                   	push   %eax
  801ef4:	89 da                	mov    %ebx,%edx
  801ef6:	89 f0                	mov    %esi,%eax
  801ef8:	e8 70 fb ff ff       	call   801a6d <printnum>
			break;
  801efd:	83 c4 20             	add    $0x20,%esp
  801f00:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f03:	e9 ae fc ff ff       	jmp    801bb6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801f08:	83 ec 08             	sub    $0x8,%esp
  801f0b:	53                   	push   %ebx
  801f0c:	51                   	push   %ecx
  801f0d:	ff d6                	call   *%esi
			break;
  801f0f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801f15:	e9 9c fc ff ff       	jmp    801bb6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801f1a:	83 ec 08             	sub    $0x8,%esp
  801f1d:	53                   	push   %ebx
  801f1e:	6a 25                	push   $0x25
  801f20:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	eb 03                	jmp    801f2a <vprintfmt+0x39a>
  801f27:	83 ef 01             	sub    $0x1,%edi
  801f2a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801f2e:	75 f7                	jne    801f27 <vprintfmt+0x397>
  801f30:	e9 81 fc ff ff       	jmp    801bb6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801f35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f38:	5b                   	pop    %ebx
  801f39:	5e                   	pop    %esi
  801f3a:	5f                   	pop    %edi
  801f3b:	5d                   	pop    %ebp
  801f3c:	c3                   	ret    

00801f3d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
  801f40:	83 ec 18             	sub    $0x18,%esp
  801f43:	8b 45 08             	mov    0x8(%ebp),%eax
  801f46:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801f49:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f4c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f50:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801f5a:	85 c0                	test   %eax,%eax
  801f5c:	74 26                	je     801f84 <vsnprintf+0x47>
  801f5e:	85 d2                	test   %edx,%edx
  801f60:	7e 22                	jle    801f84 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801f62:	ff 75 14             	pushl  0x14(%ebp)
  801f65:	ff 75 10             	pushl  0x10(%ebp)
  801f68:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801f6b:	50                   	push   %eax
  801f6c:	68 56 1b 80 00       	push   $0x801b56
  801f71:	e8 1a fc ff ff       	call   801b90 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801f76:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f79:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	eb 05                	jmp    801f89 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801f84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801f89:	c9                   	leave  
  801f8a:	c3                   	ret    

00801f8b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801f91:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801f94:	50                   	push   %eax
  801f95:	ff 75 10             	pushl  0x10(%ebp)
  801f98:	ff 75 0c             	pushl  0xc(%ebp)
  801f9b:	ff 75 08             	pushl  0x8(%ebp)
  801f9e:	e8 9a ff ff ff       	call   801f3d <vsnprintf>
	va_end(ap);

	return rc;
}
  801fa3:	c9                   	leave  
  801fa4:	c3                   	ret    

00801fa5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801fab:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb0:	eb 03                	jmp    801fb5 <strlen+0x10>
		n++;
  801fb2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801fb5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801fb9:	75 f7                	jne    801fb2 <strlen+0xd>
		n++;
	return n;
}
  801fbb:	5d                   	pop    %ebp
  801fbc:	c3                   	ret    

00801fbd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801fbd:	55                   	push   %ebp
  801fbe:	89 e5                	mov    %esp,%ebp
  801fc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801fc6:	ba 00 00 00 00       	mov    $0x0,%edx
  801fcb:	eb 03                	jmp    801fd0 <strnlen+0x13>
		n++;
  801fcd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801fd0:	39 c2                	cmp    %eax,%edx
  801fd2:	74 08                	je     801fdc <strnlen+0x1f>
  801fd4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801fd8:	75 f3                	jne    801fcd <strnlen+0x10>
  801fda:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    

00801fde <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	53                   	push   %ebx
  801fe2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801fe8:	89 c2                	mov    %eax,%edx
  801fea:	83 c2 01             	add    $0x1,%edx
  801fed:	83 c1 01             	add    $0x1,%ecx
  801ff0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801ff4:	88 5a ff             	mov    %bl,-0x1(%edx)
  801ff7:	84 db                	test   %bl,%bl
  801ff9:	75 ef                	jne    801fea <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801ffb:	5b                   	pop    %ebx
  801ffc:	5d                   	pop    %ebp
  801ffd:	c3                   	ret    

00801ffe <strcat>:

char *
strcat(char *dst, const char *src)
{
  801ffe:	55                   	push   %ebp
  801fff:	89 e5                	mov    %esp,%ebp
  802001:	53                   	push   %ebx
  802002:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802005:	53                   	push   %ebx
  802006:	e8 9a ff ff ff       	call   801fa5 <strlen>
  80200b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80200e:	ff 75 0c             	pushl  0xc(%ebp)
  802011:	01 d8                	add    %ebx,%eax
  802013:	50                   	push   %eax
  802014:	e8 c5 ff ff ff       	call   801fde <strcpy>
	return dst;
}
  802019:	89 d8                	mov    %ebx,%eax
  80201b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80201e:	c9                   	leave  
  80201f:	c3                   	ret    

00802020 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	56                   	push   %esi
  802024:	53                   	push   %ebx
  802025:	8b 75 08             	mov    0x8(%ebp),%esi
  802028:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80202b:	89 f3                	mov    %esi,%ebx
  80202d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802030:	89 f2                	mov    %esi,%edx
  802032:	eb 0f                	jmp    802043 <strncpy+0x23>
		*dst++ = *src;
  802034:	83 c2 01             	add    $0x1,%edx
  802037:	0f b6 01             	movzbl (%ecx),%eax
  80203a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80203d:	80 39 01             	cmpb   $0x1,(%ecx)
  802040:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802043:	39 da                	cmp    %ebx,%edx
  802045:	75 ed                	jne    802034 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802047:	89 f0                	mov    %esi,%eax
  802049:	5b                   	pop    %ebx
  80204a:	5e                   	pop    %esi
  80204b:	5d                   	pop    %ebp
  80204c:	c3                   	ret    

0080204d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	56                   	push   %esi
  802051:	53                   	push   %ebx
  802052:	8b 75 08             	mov    0x8(%ebp),%esi
  802055:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802058:	8b 55 10             	mov    0x10(%ebp),%edx
  80205b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80205d:	85 d2                	test   %edx,%edx
  80205f:	74 21                	je     802082 <strlcpy+0x35>
  802061:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  802065:	89 f2                	mov    %esi,%edx
  802067:	eb 09                	jmp    802072 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802069:	83 c2 01             	add    $0x1,%edx
  80206c:	83 c1 01             	add    $0x1,%ecx
  80206f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802072:	39 c2                	cmp    %eax,%edx
  802074:	74 09                	je     80207f <strlcpy+0x32>
  802076:	0f b6 19             	movzbl (%ecx),%ebx
  802079:	84 db                	test   %bl,%bl
  80207b:	75 ec                	jne    802069 <strlcpy+0x1c>
  80207d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80207f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  802082:	29 f0                	sub    %esi,%eax
}
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    

00802088 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80208e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802091:	eb 06                	jmp    802099 <strcmp+0x11>
		p++, q++;
  802093:	83 c1 01             	add    $0x1,%ecx
  802096:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  802099:	0f b6 01             	movzbl (%ecx),%eax
  80209c:	84 c0                	test   %al,%al
  80209e:	74 04                	je     8020a4 <strcmp+0x1c>
  8020a0:	3a 02                	cmp    (%edx),%al
  8020a2:	74 ef                	je     802093 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8020a4:	0f b6 c0             	movzbl %al,%eax
  8020a7:	0f b6 12             	movzbl (%edx),%edx
  8020aa:	29 d0                	sub    %edx,%eax
}
  8020ac:	5d                   	pop    %ebp
  8020ad:	c3                   	ret    

008020ae <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	53                   	push   %ebx
  8020b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020b8:	89 c3                	mov    %eax,%ebx
  8020ba:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8020bd:	eb 06                	jmp    8020c5 <strncmp+0x17>
		n--, p++, q++;
  8020bf:	83 c0 01             	add    $0x1,%eax
  8020c2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8020c5:	39 d8                	cmp    %ebx,%eax
  8020c7:	74 15                	je     8020de <strncmp+0x30>
  8020c9:	0f b6 08             	movzbl (%eax),%ecx
  8020cc:	84 c9                	test   %cl,%cl
  8020ce:	74 04                	je     8020d4 <strncmp+0x26>
  8020d0:	3a 0a                	cmp    (%edx),%cl
  8020d2:	74 eb                	je     8020bf <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8020d4:	0f b6 00             	movzbl (%eax),%eax
  8020d7:	0f b6 12             	movzbl (%edx),%edx
  8020da:	29 d0                	sub    %edx,%eax
  8020dc:	eb 05                	jmp    8020e3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8020de:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8020e3:	5b                   	pop    %ebx
  8020e4:	5d                   	pop    %ebp
  8020e5:	c3                   	ret    

008020e6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8020f0:	eb 07                	jmp    8020f9 <strchr+0x13>
		if (*s == c)
  8020f2:	38 ca                	cmp    %cl,%dl
  8020f4:	74 0f                	je     802105 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8020f6:	83 c0 01             	add    $0x1,%eax
  8020f9:	0f b6 10             	movzbl (%eax),%edx
  8020fc:	84 d2                	test   %dl,%dl
  8020fe:	75 f2                	jne    8020f2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  802100:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802105:	5d                   	pop    %ebp
  802106:	c3                   	ret    

00802107 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802107:	55                   	push   %ebp
  802108:	89 e5                	mov    %esp,%ebp
  80210a:	8b 45 08             	mov    0x8(%ebp),%eax
  80210d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802111:	eb 03                	jmp    802116 <strfind+0xf>
  802113:	83 c0 01             	add    $0x1,%eax
  802116:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802119:	38 ca                	cmp    %cl,%dl
  80211b:	74 04                	je     802121 <strfind+0x1a>
  80211d:	84 d2                	test   %dl,%dl
  80211f:	75 f2                	jne    802113 <strfind+0xc>
			break;
	return (char *) s;
}
  802121:	5d                   	pop    %ebp
  802122:	c3                   	ret    

00802123 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802123:	55                   	push   %ebp
  802124:	89 e5                	mov    %esp,%ebp
  802126:	57                   	push   %edi
  802127:	56                   	push   %esi
  802128:	53                   	push   %ebx
  802129:	8b 7d 08             	mov    0x8(%ebp),%edi
  80212c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80212f:	85 c9                	test   %ecx,%ecx
  802131:	74 36                	je     802169 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802133:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802139:	75 28                	jne    802163 <memset+0x40>
  80213b:	f6 c1 03             	test   $0x3,%cl
  80213e:	75 23                	jne    802163 <memset+0x40>
		c &= 0xFF;
  802140:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802144:	89 d3                	mov    %edx,%ebx
  802146:	c1 e3 08             	shl    $0x8,%ebx
  802149:	89 d6                	mov    %edx,%esi
  80214b:	c1 e6 18             	shl    $0x18,%esi
  80214e:	89 d0                	mov    %edx,%eax
  802150:	c1 e0 10             	shl    $0x10,%eax
  802153:	09 f0                	or     %esi,%eax
  802155:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  802157:	89 d8                	mov    %ebx,%eax
  802159:	09 d0                	or     %edx,%eax
  80215b:	c1 e9 02             	shr    $0x2,%ecx
  80215e:	fc                   	cld    
  80215f:	f3 ab                	rep stos %eax,%es:(%edi)
  802161:	eb 06                	jmp    802169 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802163:	8b 45 0c             	mov    0xc(%ebp),%eax
  802166:	fc                   	cld    
  802167:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802169:	89 f8                	mov    %edi,%eax
  80216b:	5b                   	pop    %ebx
  80216c:	5e                   	pop    %esi
  80216d:	5f                   	pop    %edi
  80216e:	5d                   	pop    %ebp
  80216f:	c3                   	ret    

00802170 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	57                   	push   %edi
  802174:	56                   	push   %esi
  802175:	8b 45 08             	mov    0x8(%ebp),%eax
  802178:	8b 75 0c             	mov    0xc(%ebp),%esi
  80217b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80217e:	39 c6                	cmp    %eax,%esi
  802180:	73 35                	jae    8021b7 <memmove+0x47>
  802182:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802185:	39 d0                	cmp    %edx,%eax
  802187:	73 2e                	jae    8021b7 <memmove+0x47>
		s += n;
		d += n;
  802189:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80218c:	89 d6                	mov    %edx,%esi
  80218e:	09 fe                	or     %edi,%esi
  802190:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802196:	75 13                	jne    8021ab <memmove+0x3b>
  802198:	f6 c1 03             	test   $0x3,%cl
  80219b:	75 0e                	jne    8021ab <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80219d:	83 ef 04             	sub    $0x4,%edi
  8021a0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8021a3:	c1 e9 02             	shr    $0x2,%ecx
  8021a6:	fd                   	std    
  8021a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021a9:	eb 09                	jmp    8021b4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8021ab:	83 ef 01             	sub    $0x1,%edi
  8021ae:	8d 72 ff             	lea    -0x1(%edx),%esi
  8021b1:	fd                   	std    
  8021b2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8021b4:	fc                   	cld    
  8021b5:	eb 1d                	jmp    8021d4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021b7:	89 f2                	mov    %esi,%edx
  8021b9:	09 c2                	or     %eax,%edx
  8021bb:	f6 c2 03             	test   $0x3,%dl
  8021be:	75 0f                	jne    8021cf <memmove+0x5f>
  8021c0:	f6 c1 03             	test   $0x3,%cl
  8021c3:	75 0a                	jne    8021cf <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8021c5:	c1 e9 02             	shr    $0x2,%ecx
  8021c8:	89 c7                	mov    %eax,%edi
  8021ca:	fc                   	cld    
  8021cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021cd:	eb 05                	jmp    8021d4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8021cf:	89 c7                	mov    %eax,%edi
  8021d1:	fc                   	cld    
  8021d2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    

008021d8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8021d8:	55                   	push   %ebp
  8021d9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8021db:	ff 75 10             	pushl  0x10(%ebp)
  8021de:	ff 75 0c             	pushl  0xc(%ebp)
  8021e1:	ff 75 08             	pushl  0x8(%ebp)
  8021e4:	e8 87 ff ff ff       	call   802170 <memmove>
}
  8021e9:	c9                   	leave  
  8021ea:	c3                   	ret    

008021eb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8021eb:	55                   	push   %ebp
  8021ec:	89 e5                	mov    %esp,%ebp
  8021ee:	56                   	push   %esi
  8021ef:	53                   	push   %ebx
  8021f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f6:	89 c6                	mov    %eax,%esi
  8021f8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8021fb:	eb 1a                	jmp    802217 <memcmp+0x2c>
		if (*s1 != *s2)
  8021fd:	0f b6 08             	movzbl (%eax),%ecx
  802200:	0f b6 1a             	movzbl (%edx),%ebx
  802203:	38 d9                	cmp    %bl,%cl
  802205:	74 0a                	je     802211 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  802207:	0f b6 c1             	movzbl %cl,%eax
  80220a:	0f b6 db             	movzbl %bl,%ebx
  80220d:	29 d8                	sub    %ebx,%eax
  80220f:	eb 0f                	jmp    802220 <memcmp+0x35>
		s1++, s2++;
  802211:	83 c0 01             	add    $0x1,%eax
  802214:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802217:	39 f0                	cmp    %esi,%eax
  802219:	75 e2                	jne    8021fd <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80221b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802220:	5b                   	pop    %ebx
  802221:	5e                   	pop    %esi
  802222:	5d                   	pop    %ebp
  802223:	c3                   	ret    

00802224 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802224:	55                   	push   %ebp
  802225:	89 e5                	mov    %esp,%ebp
  802227:	53                   	push   %ebx
  802228:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80222b:	89 c1                	mov    %eax,%ecx
  80222d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  802230:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802234:	eb 0a                	jmp    802240 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  802236:	0f b6 10             	movzbl (%eax),%edx
  802239:	39 da                	cmp    %ebx,%edx
  80223b:	74 07                	je     802244 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80223d:	83 c0 01             	add    $0x1,%eax
  802240:	39 c8                	cmp    %ecx,%eax
  802242:	72 f2                	jb     802236 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802244:	5b                   	pop    %ebx
  802245:	5d                   	pop    %ebp
  802246:	c3                   	ret    

00802247 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802247:	55                   	push   %ebp
  802248:	89 e5                	mov    %esp,%ebp
  80224a:	57                   	push   %edi
  80224b:	56                   	push   %esi
  80224c:	53                   	push   %ebx
  80224d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802250:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802253:	eb 03                	jmp    802258 <strtol+0x11>
		s++;
  802255:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802258:	0f b6 01             	movzbl (%ecx),%eax
  80225b:	3c 20                	cmp    $0x20,%al
  80225d:	74 f6                	je     802255 <strtol+0xe>
  80225f:	3c 09                	cmp    $0x9,%al
  802261:	74 f2                	je     802255 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802263:	3c 2b                	cmp    $0x2b,%al
  802265:	75 0a                	jne    802271 <strtol+0x2a>
		s++;
  802267:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80226a:	bf 00 00 00 00       	mov    $0x0,%edi
  80226f:	eb 11                	jmp    802282 <strtol+0x3b>
  802271:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802276:	3c 2d                	cmp    $0x2d,%al
  802278:	75 08                	jne    802282 <strtol+0x3b>
		s++, neg = 1;
  80227a:	83 c1 01             	add    $0x1,%ecx
  80227d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802282:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  802288:	75 15                	jne    80229f <strtol+0x58>
  80228a:	80 39 30             	cmpb   $0x30,(%ecx)
  80228d:	75 10                	jne    80229f <strtol+0x58>
  80228f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  802293:	75 7c                	jne    802311 <strtol+0xca>
		s += 2, base = 16;
  802295:	83 c1 02             	add    $0x2,%ecx
  802298:	bb 10 00 00 00       	mov    $0x10,%ebx
  80229d:	eb 16                	jmp    8022b5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80229f:	85 db                	test   %ebx,%ebx
  8022a1:	75 12                	jne    8022b5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8022a3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022a8:	80 39 30             	cmpb   $0x30,(%ecx)
  8022ab:	75 08                	jne    8022b5 <strtol+0x6e>
		s++, base = 8;
  8022ad:	83 c1 01             	add    $0x1,%ecx
  8022b0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8022b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ba:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8022bd:	0f b6 11             	movzbl (%ecx),%edx
  8022c0:	8d 72 d0             	lea    -0x30(%edx),%esi
  8022c3:	89 f3                	mov    %esi,%ebx
  8022c5:	80 fb 09             	cmp    $0x9,%bl
  8022c8:	77 08                	ja     8022d2 <strtol+0x8b>
			dig = *s - '0';
  8022ca:	0f be d2             	movsbl %dl,%edx
  8022cd:	83 ea 30             	sub    $0x30,%edx
  8022d0:	eb 22                	jmp    8022f4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8022d2:	8d 72 9f             	lea    -0x61(%edx),%esi
  8022d5:	89 f3                	mov    %esi,%ebx
  8022d7:	80 fb 19             	cmp    $0x19,%bl
  8022da:	77 08                	ja     8022e4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8022dc:	0f be d2             	movsbl %dl,%edx
  8022df:	83 ea 57             	sub    $0x57,%edx
  8022e2:	eb 10                	jmp    8022f4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8022e4:	8d 72 bf             	lea    -0x41(%edx),%esi
  8022e7:	89 f3                	mov    %esi,%ebx
  8022e9:	80 fb 19             	cmp    $0x19,%bl
  8022ec:	77 16                	ja     802304 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8022ee:	0f be d2             	movsbl %dl,%edx
  8022f1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8022f4:	3b 55 10             	cmp    0x10(%ebp),%edx
  8022f7:	7d 0b                	jge    802304 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8022f9:	83 c1 01             	add    $0x1,%ecx
  8022fc:	0f af 45 10          	imul   0x10(%ebp),%eax
  802300:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  802302:	eb b9                	jmp    8022bd <strtol+0x76>

	if (endptr)
  802304:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802308:	74 0d                	je     802317 <strtol+0xd0>
		*endptr = (char *) s;
  80230a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80230d:	89 0e                	mov    %ecx,(%esi)
  80230f:	eb 06                	jmp    802317 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802311:	85 db                	test   %ebx,%ebx
  802313:	74 98                	je     8022ad <strtol+0x66>
  802315:	eb 9e                	jmp    8022b5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  802317:	89 c2                	mov    %eax,%edx
  802319:	f7 da                	neg    %edx
  80231b:	85 ff                	test   %edi,%edi
  80231d:	0f 45 c2             	cmovne %edx,%eax
}
  802320:	5b                   	pop    %ebx
  802321:	5e                   	pop    %esi
  802322:	5f                   	pop    %edi
  802323:	5d                   	pop    %ebp
  802324:	c3                   	ret    

00802325 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802325:	55                   	push   %ebp
  802326:	89 e5                	mov    %esp,%ebp
  802328:	57                   	push   %edi
  802329:	56                   	push   %esi
  80232a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80232b:	b8 00 00 00 00       	mov    $0x0,%eax
  802330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802333:	8b 55 08             	mov    0x8(%ebp),%edx
  802336:	89 c3                	mov    %eax,%ebx
  802338:	89 c7                	mov    %eax,%edi
  80233a:	89 c6                	mov    %eax,%esi
  80233c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80233e:	5b                   	pop    %ebx
  80233f:	5e                   	pop    %esi
  802340:	5f                   	pop    %edi
  802341:	5d                   	pop    %ebp
  802342:	c3                   	ret    

00802343 <sys_cgetc>:

int
sys_cgetc(void)
{
  802343:	55                   	push   %ebp
  802344:	89 e5                	mov    %esp,%ebp
  802346:	57                   	push   %edi
  802347:	56                   	push   %esi
  802348:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802349:	ba 00 00 00 00       	mov    $0x0,%edx
  80234e:	b8 01 00 00 00       	mov    $0x1,%eax
  802353:	89 d1                	mov    %edx,%ecx
  802355:	89 d3                	mov    %edx,%ebx
  802357:	89 d7                	mov    %edx,%edi
  802359:	89 d6                	mov    %edx,%esi
  80235b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80235d:	5b                   	pop    %ebx
  80235e:	5e                   	pop    %esi
  80235f:	5f                   	pop    %edi
  802360:	5d                   	pop    %ebp
  802361:	c3                   	ret    

00802362 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802362:	55                   	push   %ebp
  802363:	89 e5                	mov    %esp,%ebp
  802365:	57                   	push   %edi
  802366:	56                   	push   %esi
  802367:	53                   	push   %ebx
  802368:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80236b:	b9 00 00 00 00       	mov    $0x0,%ecx
  802370:	b8 03 00 00 00       	mov    $0x3,%eax
  802375:	8b 55 08             	mov    0x8(%ebp),%edx
  802378:	89 cb                	mov    %ecx,%ebx
  80237a:	89 cf                	mov    %ecx,%edi
  80237c:	89 ce                	mov    %ecx,%esi
  80237e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802380:	85 c0                	test   %eax,%eax
  802382:	7e 17                	jle    80239b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802384:	83 ec 0c             	sub    $0xc,%esp
  802387:	50                   	push   %eax
  802388:	6a 03                	push   $0x3
  80238a:	68 ff 44 80 00       	push   $0x8044ff
  80238f:	6a 23                	push   $0x23
  802391:	68 1c 45 80 00       	push   $0x80451c
  802396:	e8 e5 f5 ff ff       	call   801980 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80239b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80239e:	5b                   	pop    %ebx
  80239f:	5e                   	pop    %esi
  8023a0:	5f                   	pop    %edi
  8023a1:	5d                   	pop    %ebp
  8023a2:	c3                   	ret    

008023a3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8023a3:	55                   	push   %ebp
  8023a4:	89 e5                	mov    %esp,%ebp
  8023a6:	57                   	push   %edi
  8023a7:	56                   	push   %esi
  8023a8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8023ae:	b8 02 00 00 00       	mov    $0x2,%eax
  8023b3:	89 d1                	mov    %edx,%ecx
  8023b5:	89 d3                	mov    %edx,%ebx
  8023b7:	89 d7                	mov    %edx,%edi
  8023b9:	89 d6                	mov    %edx,%esi
  8023bb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8023bd:	5b                   	pop    %ebx
  8023be:	5e                   	pop    %esi
  8023bf:	5f                   	pop    %edi
  8023c0:	5d                   	pop    %ebp
  8023c1:	c3                   	ret    

008023c2 <sys_yield>:

void
sys_yield(void)
{
  8023c2:	55                   	push   %ebp
  8023c3:	89 e5                	mov    %esp,%ebp
  8023c5:	57                   	push   %edi
  8023c6:	56                   	push   %esi
  8023c7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8023cd:	b8 0b 00 00 00       	mov    $0xb,%eax
  8023d2:	89 d1                	mov    %edx,%ecx
  8023d4:	89 d3                	mov    %edx,%ebx
  8023d6:	89 d7                	mov    %edx,%edi
  8023d8:	89 d6                	mov    %edx,%esi
  8023da:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8023dc:	5b                   	pop    %ebx
  8023dd:	5e                   	pop    %esi
  8023de:	5f                   	pop    %edi
  8023df:	5d                   	pop    %ebp
  8023e0:	c3                   	ret    

008023e1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8023e1:	55                   	push   %ebp
  8023e2:	89 e5                	mov    %esp,%ebp
  8023e4:	57                   	push   %edi
  8023e5:	56                   	push   %esi
  8023e6:	53                   	push   %ebx
  8023e7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023ea:	be 00 00 00 00       	mov    $0x0,%esi
  8023ef:	b8 04 00 00 00       	mov    $0x4,%eax
  8023f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8023fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023fd:	89 f7                	mov    %esi,%edi
  8023ff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802401:	85 c0                	test   %eax,%eax
  802403:	7e 17                	jle    80241c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802405:	83 ec 0c             	sub    $0xc,%esp
  802408:	50                   	push   %eax
  802409:	6a 04                	push   $0x4
  80240b:	68 ff 44 80 00       	push   $0x8044ff
  802410:	6a 23                	push   $0x23
  802412:	68 1c 45 80 00       	push   $0x80451c
  802417:	e8 64 f5 ff ff       	call   801980 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80241c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80241f:	5b                   	pop    %ebx
  802420:	5e                   	pop    %esi
  802421:	5f                   	pop    %edi
  802422:	5d                   	pop    %ebp
  802423:	c3                   	ret    

00802424 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802424:	55                   	push   %ebp
  802425:	89 e5                	mov    %esp,%ebp
  802427:	57                   	push   %edi
  802428:	56                   	push   %esi
  802429:	53                   	push   %ebx
  80242a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80242d:	b8 05 00 00 00       	mov    $0x5,%eax
  802432:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802435:	8b 55 08             	mov    0x8(%ebp),%edx
  802438:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80243b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80243e:	8b 75 18             	mov    0x18(%ebp),%esi
  802441:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802443:	85 c0                	test   %eax,%eax
  802445:	7e 17                	jle    80245e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802447:	83 ec 0c             	sub    $0xc,%esp
  80244a:	50                   	push   %eax
  80244b:	6a 05                	push   $0x5
  80244d:	68 ff 44 80 00       	push   $0x8044ff
  802452:	6a 23                	push   $0x23
  802454:	68 1c 45 80 00       	push   $0x80451c
  802459:	e8 22 f5 ff ff       	call   801980 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80245e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802461:	5b                   	pop    %ebx
  802462:	5e                   	pop    %esi
  802463:	5f                   	pop    %edi
  802464:	5d                   	pop    %ebp
  802465:	c3                   	ret    

00802466 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802466:	55                   	push   %ebp
  802467:	89 e5                	mov    %esp,%ebp
  802469:	57                   	push   %edi
  80246a:	56                   	push   %esi
  80246b:	53                   	push   %ebx
  80246c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80246f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802474:	b8 06 00 00 00       	mov    $0x6,%eax
  802479:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80247c:	8b 55 08             	mov    0x8(%ebp),%edx
  80247f:	89 df                	mov    %ebx,%edi
  802481:	89 de                	mov    %ebx,%esi
  802483:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802485:	85 c0                	test   %eax,%eax
  802487:	7e 17                	jle    8024a0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802489:	83 ec 0c             	sub    $0xc,%esp
  80248c:	50                   	push   %eax
  80248d:	6a 06                	push   $0x6
  80248f:	68 ff 44 80 00       	push   $0x8044ff
  802494:	6a 23                	push   $0x23
  802496:	68 1c 45 80 00       	push   $0x80451c
  80249b:	e8 e0 f4 ff ff       	call   801980 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8024a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024a3:	5b                   	pop    %ebx
  8024a4:	5e                   	pop    %esi
  8024a5:	5f                   	pop    %edi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    

008024a8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8024a8:	55                   	push   %ebp
  8024a9:	89 e5                	mov    %esp,%ebp
  8024ab:	57                   	push   %edi
  8024ac:	56                   	push   %esi
  8024ad:	53                   	push   %ebx
  8024ae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024b6:	b8 08 00 00 00       	mov    $0x8,%eax
  8024bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024be:	8b 55 08             	mov    0x8(%ebp),%edx
  8024c1:	89 df                	mov    %ebx,%edi
  8024c3:	89 de                	mov    %ebx,%esi
  8024c5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024c7:	85 c0                	test   %eax,%eax
  8024c9:	7e 17                	jle    8024e2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024cb:	83 ec 0c             	sub    $0xc,%esp
  8024ce:	50                   	push   %eax
  8024cf:	6a 08                	push   $0x8
  8024d1:	68 ff 44 80 00       	push   $0x8044ff
  8024d6:	6a 23                	push   $0x23
  8024d8:	68 1c 45 80 00       	push   $0x80451c
  8024dd:	e8 9e f4 ff ff       	call   801980 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8024e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024e5:	5b                   	pop    %ebx
  8024e6:	5e                   	pop    %esi
  8024e7:	5f                   	pop    %edi
  8024e8:	5d                   	pop    %ebp
  8024e9:	c3                   	ret    

008024ea <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8024ea:	55                   	push   %ebp
  8024eb:	89 e5                	mov    %esp,%ebp
  8024ed:	57                   	push   %edi
  8024ee:	56                   	push   %esi
  8024ef:	53                   	push   %ebx
  8024f0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024f8:	b8 09 00 00 00       	mov    $0x9,%eax
  8024fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802500:	8b 55 08             	mov    0x8(%ebp),%edx
  802503:	89 df                	mov    %ebx,%edi
  802505:	89 de                	mov    %ebx,%esi
  802507:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802509:	85 c0                	test   %eax,%eax
  80250b:	7e 17                	jle    802524 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80250d:	83 ec 0c             	sub    $0xc,%esp
  802510:	50                   	push   %eax
  802511:	6a 09                	push   $0x9
  802513:	68 ff 44 80 00       	push   $0x8044ff
  802518:	6a 23                	push   $0x23
  80251a:	68 1c 45 80 00       	push   $0x80451c
  80251f:	e8 5c f4 ff ff       	call   801980 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802524:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802527:	5b                   	pop    %ebx
  802528:	5e                   	pop    %esi
  802529:	5f                   	pop    %edi
  80252a:	5d                   	pop    %ebp
  80252b:	c3                   	ret    

0080252c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80252c:	55                   	push   %ebp
  80252d:	89 e5                	mov    %esp,%ebp
  80252f:	57                   	push   %edi
  802530:	56                   	push   %esi
  802531:	53                   	push   %ebx
  802532:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802535:	bb 00 00 00 00       	mov    $0x0,%ebx
  80253a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80253f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802542:	8b 55 08             	mov    0x8(%ebp),%edx
  802545:	89 df                	mov    %ebx,%edi
  802547:	89 de                	mov    %ebx,%esi
  802549:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80254b:	85 c0                	test   %eax,%eax
  80254d:	7e 17                	jle    802566 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80254f:	83 ec 0c             	sub    $0xc,%esp
  802552:	50                   	push   %eax
  802553:	6a 0a                	push   $0xa
  802555:	68 ff 44 80 00       	push   $0x8044ff
  80255a:	6a 23                	push   $0x23
  80255c:	68 1c 45 80 00       	push   $0x80451c
  802561:	e8 1a f4 ff ff       	call   801980 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802566:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802569:	5b                   	pop    %ebx
  80256a:	5e                   	pop    %esi
  80256b:	5f                   	pop    %edi
  80256c:	5d                   	pop    %ebp
  80256d:	c3                   	ret    

0080256e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80256e:	55                   	push   %ebp
  80256f:	89 e5                	mov    %esp,%ebp
  802571:	57                   	push   %edi
  802572:	56                   	push   %esi
  802573:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802574:	be 00 00 00 00       	mov    $0x0,%esi
  802579:	b8 0c 00 00 00       	mov    $0xc,%eax
  80257e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802581:	8b 55 08             	mov    0x8(%ebp),%edx
  802584:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802587:	8b 7d 14             	mov    0x14(%ebp),%edi
  80258a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80258c:	5b                   	pop    %ebx
  80258d:	5e                   	pop    %esi
  80258e:	5f                   	pop    %edi
  80258f:	5d                   	pop    %ebp
  802590:	c3                   	ret    

00802591 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802591:	55                   	push   %ebp
  802592:	89 e5                	mov    %esp,%ebp
  802594:	57                   	push   %edi
  802595:	56                   	push   %esi
  802596:	53                   	push   %ebx
  802597:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80259a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80259f:	b8 0d 00 00 00       	mov    $0xd,%eax
  8025a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8025a7:	89 cb                	mov    %ecx,%ebx
  8025a9:	89 cf                	mov    %ecx,%edi
  8025ab:	89 ce                	mov    %ecx,%esi
  8025ad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8025af:	85 c0                	test   %eax,%eax
  8025b1:	7e 17                	jle    8025ca <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025b3:	83 ec 0c             	sub    $0xc,%esp
  8025b6:	50                   	push   %eax
  8025b7:	6a 0d                	push   $0xd
  8025b9:	68 ff 44 80 00       	push   $0x8044ff
  8025be:	6a 23                	push   $0x23
  8025c0:	68 1c 45 80 00       	push   $0x80451c
  8025c5:	e8 b6 f3 ff ff       	call   801980 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8025ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025cd:	5b                   	pop    %ebx
  8025ce:	5e                   	pop    %esi
  8025cf:	5f                   	pop    %edi
  8025d0:	5d                   	pop    %ebp
  8025d1:	c3                   	ret    

008025d2 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8025d2:	55                   	push   %ebp
  8025d3:	89 e5                	mov    %esp,%ebp
  8025d5:	57                   	push   %edi
  8025d6:	56                   	push   %esi
  8025d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8025dd:	b8 0e 00 00 00       	mov    $0xe,%eax
  8025e2:	89 d1                	mov    %edx,%ecx
  8025e4:	89 d3                	mov    %edx,%ebx
  8025e6:	89 d7                	mov    %edx,%edi
  8025e8:	89 d6                	mov    %edx,%esi
  8025ea:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8025ec:	5b                   	pop    %ebx
  8025ed:	5e                   	pop    %esi
  8025ee:	5f                   	pop    %edi
  8025ef:	5d                   	pop    %ebp
  8025f0:	c3                   	ret    

008025f1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8025f1:	55                   	push   %ebp
  8025f2:	89 e5                	mov    %esp,%ebp
  8025f4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8025f7:	83 3d 14 a0 80 00 00 	cmpl   $0x0,0x80a014
  8025fe:	75 64                	jne    802664 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		int r;
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  802600:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802605:	8b 40 48             	mov    0x48(%eax),%eax
  802608:	83 ec 04             	sub    $0x4,%esp
  80260b:	6a 07                	push   $0x7
  80260d:	68 00 f0 bf ee       	push   $0xeebff000
  802612:	50                   	push   %eax
  802613:	e8 c9 fd ff ff       	call   8023e1 <sys_page_alloc>
		if ( r != 0)
  802618:	83 c4 10             	add    $0x10,%esp
  80261b:	85 c0                	test   %eax,%eax
  80261d:	74 14                	je     802633 <set_pgfault_handler+0x42>
			panic("set_pgfault_handler: sys_page_alloc failed.");
  80261f:	83 ec 04             	sub    $0x4,%esp
  802622:	68 2c 45 80 00       	push   $0x80452c
  802627:	6a 24                	push   $0x24
  802629:	68 7a 45 80 00       	push   $0x80457a
  80262e:	e8 4d f3 ff ff       	call   801980 <_panic>
			
		if (sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall) < 0)
  802633:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802638:	8b 40 48             	mov    0x48(%eax),%eax
  80263b:	83 ec 08             	sub    $0x8,%esp
  80263e:	68 6e 26 80 00       	push   $0x80266e
  802643:	50                   	push   %eax
  802644:	e8 e3 fe ff ff       	call   80252c <sys_env_set_pgfault_upcall>
  802649:	83 c4 10             	add    $0x10,%esp
  80264c:	85 c0                	test   %eax,%eax
  80264e:	79 14                	jns    802664 <set_pgfault_handler+0x73>
		 	panic("sys_env_set_pgfault_upcall failed");
  802650:	83 ec 04             	sub    $0x4,%esp
  802653:	68 58 45 80 00       	push   $0x804558
  802658:	6a 27                	push   $0x27
  80265a:	68 7a 45 80 00       	push   $0x80457a
  80265f:	e8 1c f3 ff ff       	call   801980 <_panic>
			
	}

	
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802664:	8b 45 08             	mov    0x8(%ebp),%eax
  802667:	a3 14 a0 80 00       	mov    %eax,0x80a014
}
  80266c:	c9                   	leave  
  80266d:	c3                   	ret    

0080266e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80266e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80266f:	a1 14 a0 80 00       	mov    0x80a014,%eax
	call *%eax
  802674:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802676:	83 c4 04             	add    $0x4,%esp
	addl $0x4,%esp
	popfl
	popl %esp
	ret
*/
movl 0x28(%esp), %eax
  802679:	8b 44 24 28          	mov    0x28(%esp),%eax
movl %esp, %ebx
  80267d:	89 e3                	mov    %esp,%ebx
movl 0x30(%esp), %esp
  80267f:	8b 64 24 30          	mov    0x30(%esp),%esp
pushl %eax
  802683:	50                   	push   %eax
movl %esp, 0x30(%ebx)
  802684:	89 63 30             	mov    %esp,0x30(%ebx)
movl %ebx, %esp
  802687:	89 dc                	mov    %ebx,%esp
addl $0x8, %esp
  802689:	83 c4 08             	add    $0x8,%esp
popal
  80268c:	61                   	popa   
addl $0x4, %esp
  80268d:	83 c4 04             	add    $0x4,%esp
popfl
  802690:	9d                   	popf   
popl %esp
  802691:	5c                   	pop    %esp
ret
  802692:	c3                   	ret    

00802693 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802693:	55                   	push   %ebp
  802694:	89 e5                	mov    %esp,%ebp
  802696:	56                   	push   %esi
  802697:	53                   	push   %ebx
  802698:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80269b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80269e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  8026a1:	85 c0                	test   %eax,%eax
  8026a3:	74 0e                	je     8026b3 <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  8026a5:	83 ec 0c             	sub    $0xc,%esp
  8026a8:	50                   	push   %eax
  8026a9:	e8 e3 fe ff ff       	call   802591 <sys_ipc_recv>
  8026ae:	83 c4 10             	add    $0x10,%esp
  8026b1:	eb 10                	jmp    8026c3 <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  8026b3:	83 ec 0c             	sub    $0xc,%esp
  8026b6:	68 00 00 00 f0       	push   $0xf0000000
  8026bb:	e8 d1 fe ff ff       	call   802591 <sys_ipc_recv>
  8026c0:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  8026c3:	85 c0                	test   %eax,%eax
  8026c5:	74 16                	je     8026dd <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  8026c7:	85 db                	test   %ebx,%ebx
  8026c9:	74 36                	je     802701 <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  8026cb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  8026d1:	85 f6                	test   %esi,%esi
  8026d3:	74 2c                	je     802701 <ipc_recv+0x6e>
				*perm_store = 0;
  8026d5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8026db:	eb 24                	jmp    802701 <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  8026dd:	85 db                	test   %ebx,%ebx
  8026df:	74 18                	je     8026f9 <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  8026e1:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8026e6:	8b 40 74             	mov    0x74(%eax),%eax
  8026e9:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  8026eb:	85 f6                	test   %esi,%esi
  8026ed:	74 0a                	je     8026f9 <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  8026ef:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8026f4:	8b 40 78             	mov    0x78(%eax),%eax
  8026f7:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  8026f9:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8026fe:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  802701:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802704:	5b                   	pop    %ebx
  802705:	5e                   	pop    %esi
  802706:	5d                   	pop    %ebp
  802707:	c3                   	ret    

00802708 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802708:	55                   	push   %ebp
  802709:	89 e5                	mov    %esp,%ebp
  80270b:	57                   	push   %edi
  80270c:	56                   	push   %esi
  80270d:	53                   	push   %ebx
  80270e:	83 ec 0c             	sub    $0xc,%esp
  802711:	8b 7d 08             	mov    0x8(%ebp),%edi
  802714:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  802717:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80271b:	75 39                	jne    802756 <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  80271d:	6a 00                	push   $0x0
  80271f:	68 00 00 00 f0       	push   $0xf0000000
  802724:	56                   	push   %esi
  802725:	57                   	push   %edi
  802726:	e8 43 fe ff ff       	call   80256e <sys_ipc_try_send>
  80272b:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  80272d:	83 c4 10             	add    $0x10,%esp
  802730:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802733:	74 16                	je     80274b <ipc_send+0x43>
  802735:	85 c0                	test   %eax,%eax
  802737:	74 12                	je     80274b <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  802739:	50                   	push   %eax
  80273a:	68 88 45 80 00       	push   $0x804588
  80273f:	6a 4f                	push   $0x4f
  802741:	68 c0 45 80 00       	push   $0x8045c0
  802746:	e8 35 f2 ff ff       	call   801980 <_panic>
			sys_yield();
  80274b:	e8 72 fc ff ff       	call   8023c2 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  802750:	85 db                	test   %ebx,%ebx
  802752:	75 c9                	jne    80271d <ipc_send+0x15>
  802754:	eb 36                	jmp    80278c <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  802756:	ff 75 14             	pushl  0x14(%ebp)
  802759:	ff 75 10             	pushl  0x10(%ebp)
  80275c:	56                   	push   %esi
  80275d:	57                   	push   %edi
  80275e:	e8 0b fe ff ff       	call   80256e <sys_ipc_try_send>
  802763:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  802765:	83 c4 10             	add    $0x10,%esp
  802768:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80276b:	74 16                	je     802783 <ipc_send+0x7b>
  80276d:	85 c0                	test   %eax,%eax
  80276f:	74 12                	je     802783 <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  802771:	50                   	push   %eax
  802772:	68 88 45 80 00       	push   $0x804588
  802777:	6a 5a                	push   $0x5a
  802779:	68 c0 45 80 00       	push   $0x8045c0
  80277e:	e8 fd f1 ff ff       	call   801980 <_panic>
			sys_yield();
  802783:	e8 3a fc ff ff       	call   8023c2 <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  802788:	85 db                	test   %ebx,%ebx
  80278a:	75 ca                	jne    802756 <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  80278c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80278f:	5b                   	pop    %ebx
  802790:	5e                   	pop    %esi
  802791:	5f                   	pop    %edi
  802792:	5d                   	pop    %ebp
  802793:	c3                   	ret    

00802794 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802794:	55                   	push   %ebp
  802795:	89 e5                	mov    %esp,%ebp
  802797:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80279a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80279f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8027a2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027a8:	8b 52 50             	mov    0x50(%edx),%edx
  8027ab:	39 ca                	cmp    %ecx,%edx
  8027ad:	75 0d                	jne    8027bc <ipc_find_env+0x28>
			return envs[i].env_id;
  8027af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8027b7:	8b 40 48             	mov    0x48(%eax),%eax
  8027ba:	eb 0f                	jmp    8027cb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027bc:	83 c0 01             	add    $0x1,%eax
  8027bf:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027c4:	75 d9                	jne    80279f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8027c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8027cb:	5d                   	pop    %ebp
  8027cc:	c3                   	ret    

008027cd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8027cd:	55                   	push   %ebp
  8027ce:	89 e5                	mov    %esp,%ebp
  8027d0:	56                   	push   %esi
  8027d1:	53                   	push   %ebx
  8027d2:	89 c6                	mov    %eax,%esi
  8027d4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8027d6:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  8027dd:	75 12                	jne    8027f1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8027df:	83 ec 0c             	sub    $0xc,%esp
  8027e2:	6a 01                	push   $0x1
  8027e4:	e8 ab ff ff ff       	call   802794 <ipc_find_env>
  8027e9:	a3 00 a0 80 00       	mov    %eax,0x80a000
  8027ee:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8027f1:	6a 07                	push   $0x7
  8027f3:	68 00 b0 80 00       	push   $0x80b000
  8027f8:	56                   	push   %esi
  8027f9:	ff 35 00 a0 80 00    	pushl  0x80a000
  8027ff:	e8 04 ff ff ff       	call   802708 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802804:	83 c4 0c             	add    $0xc,%esp
  802807:	6a 00                	push   $0x0
  802809:	53                   	push   %ebx
  80280a:	6a 00                	push   $0x0
  80280c:	e8 82 fe ff ff       	call   802693 <ipc_recv>
}
  802811:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802814:	5b                   	pop    %ebx
  802815:	5e                   	pop    %esi
  802816:	5d                   	pop    %ebp
  802817:	c3                   	ret    

00802818 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802818:	55                   	push   %ebp
  802819:	89 e5                	mov    %esp,%ebp
  80281b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80281e:	8b 45 08             	mov    0x8(%ebp),%eax
  802821:	8b 40 0c             	mov    0xc(%eax),%eax
  802824:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802829:	8b 45 0c             	mov    0xc(%ebp),%eax
  80282c:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802831:	ba 00 00 00 00       	mov    $0x0,%edx
  802836:	b8 02 00 00 00       	mov    $0x2,%eax
  80283b:	e8 8d ff ff ff       	call   8027cd <fsipc>
}
  802840:	c9                   	leave  
  802841:	c3                   	ret    

00802842 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802842:	55                   	push   %ebp
  802843:	89 e5                	mov    %esp,%ebp
  802845:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802848:	8b 45 08             	mov    0x8(%ebp),%eax
  80284b:	8b 40 0c             	mov    0xc(%eax),%eax
  80284e:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802853:	ba 00 00 00 00       	mov    $0x0,%edx
  802858:	b8 06 00 00 00       	mov    $0x6,%eax
  80285d:	e8 6b ff ff ff       	call   8027cd <fsipc>
}
  802862:	c9                   	leave  
  802863:	c3                   	ret    

00802864 <devfile_stat>:
                return ((ssize_t)r);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802864:	55                   	push   %ebp
  802865:	89 e5                	mov    %esp,%ebp
  802867:	53                   	push   %ebx
  802868:	83 ec 04             	sub    $0x4,%esp
  80286b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80286e:	8b 45 08             	mov    0x8(%ebp),%eax
  802871:	8b 40 0c             	mov    0xc(%eax),%eax
  802874:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802879:	ba 00 00 00 00       	mov    $0x0,%edx
  80287e:	b8 05 00 00 00       	mov    $0x5,%eax
  802883:	e8 45 ff ff ff       	call   8027cd <fsipc>
  802888:	85 c0                	test   %eax,%eax
  80288a:	78 2c                	js     8028b8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80288c:	83 ec 08             	sub    $0x8,%esp
  80288f:	68 00 b0 80 00       	push   $0x80b000
  802894:	53                   	push   %ebx
  802895:	e8 44 f7 ff ff       	call   801fde <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80289a:	a1 80 b0 80 00       	mov    0x80b080,%eax
  80289f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8028a5:	a1 84 b0 80 00       	mov    0x80b084,%eax
  8028aa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8028b0:	83 c4 10             	add    $0x10,%esp
  8028b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8028b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8028bb:	c9                   	leave  
  8028bc:	c3                   	ret    

008028bd <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8028bd:	55                   	push   %ebp
  8028be:	89 e5                	mov    %esp,%ebp
  8028c0:	83 ec 0c             	sub    $0xc,%esp
  8028c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8028c6:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8028cb:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8028d0:	0f 47 c2             	cmova  %edx,%eax
	int r;
	if(n > (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t))))
	{
		n = (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t)));
	}
		fsipcbuf.write.req_fileid = fd->fd_file.id;
  8028d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8028d6:	8b 52 0c             	mov    0xc(%edx),%edx
  8028d9:	89 15 00 b0 80 00    	mov    %edx,0x80b000
		fsipcbuf.write.req_n = n;
  8028df:	a3 04 b0 80 00       	mov    %eax,0x80b004
		memmove((void *)fsipcbuf.write.req_buf, buf, n);
  8028e4:	50                   	push   %eax
  8028e5:	ff 75 0c             	pushl  0xc(%ebp)
  8028e8:	68 08 b0 80 00       	push   $0x80b008
  8028ed:	e8 7e f8 ff ff       	call   802170 <memmove>
		r = fsipc(FSREQ_WRITE, NULL);
  8028f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8028f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8028fc:	e8 cc fe ff ff       	call   8027cd <fsipc>
                return ((ssize_t)r);
}
  802901:	c9                   	leave  
  802902:	c3                   	ret    

00802903 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802903:	55                   	push   %ebp
  802904:	89 e5                	mov    %esp,%ebp
  802906:	56                   	push   %esi
  802907:	53                   	push   %ebx
  802908:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80290b:	8b 45 08             	mov    0x8(%ebp),%eax
  80290e:	8b 40 0c             	mov    0xc(%eax),%eax
  802911:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802916:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80291c:	ba 00 00 00 00       	mov    $0x0,%edx
  802921:	b8 03 00 00 00       	mov    $0x3,%eax
  802926:	e8 a2 fe ff ff       	call   8027cd <fsipc>
  80292b:	89 c3                	mov    %eax,%ebx
  80292d:	85 c0                	test   %eax,%eax
  80292f:	78 4b                	js     80297c <devfile_read+0x79>
		return r;
	assert(r <= n);
  802931:	39 c6                	cmp    %eax,%esi
  802933:	73 16                	jae    80294b <devfile_read+0x48>
  802935:	68 ca 45 80 00       	push   $0x8045ca
  80293a:	68 3d 3c 80 00       	push   $0x803c3d
  80293f:	6a 7c                	push   $0x7c
  802941:	68 d1 45 80 00       	push   $0x8045d1
  802946:	e8 35 f0 ff ff       	call   801980 <_panic>
	assert(r <= PGSIZE);
  80294b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802950:	7e 16                	jle    802968 <devfile_read+0x65>
  802952:	68 dc 45 80 00       	push   $0x8045dc
  802957:	68 3d 3c 80 00       	push   $0x803c3d
  80295c:	6a 7d                	push   $0x7d
  80295e:	68 d1 45 80 00       	push   $0x8045d1
  802963:	e8 18 f0 ff ff       	call   801980 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802968:	83 ec 04             	sub    $0x4,%esp
  80296b:	50                   	push   %eax
  80296c:	68 00 b0 80 00       	push   $0x80b000
  802971:	ff 75 0c             	pushl  0xc(%ebp)
  802974:	e8 f7 f7 ff ff       	call   802170 <memmove>
	return r;
  802979:	83 c4 10             	add    $0x10,%esp
}
  80297c:	89 d8                	mov    %ebx,%eax
  80297e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802981:	5b                   	pop    %ebx
  802982:	5e                   	pop    %esi
  802983:	5d                   	pop    %ebp
  802984:	c3                   	ret    

00802985 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802985:	55                   	push   %ebp
  802986:	89 e5                	mov    %esp,%ebp
  802988:	53                   	push   %ebx
  802989:	83 ec 20             	sub    $0x20,%esp
  80298c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80298f:	53                   	push   %ebx
  802990:	e8 10 f6 ff ff       	call   801fa5 <strlen>
  802995:	83 c4 10             	add    $0x10,%esp
  802998:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80299d:	7f 67                	jg     802a06 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80299f:	83 ec 0c             	sub    $0xc,%esp
  8029a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029a5:	50                   	push   %eax
  8029a6:	e8 e0 00 00 00       	call   802a8b <fd_alloc>
  8029ab:	83 c4 10             	add    $0x10,%esp
		return r;
  8029ae:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8029b0:	85 c0                	test   %eax,%eax
  8029b2:	78 57                	js     802a0b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8029b4:	83 ec 08             	sub    $0x8,%esp
  8029b7:	53                   	push   %ebx
  8029b8:	68 00 b0 80 00       	push   $0x80b000
  8029bd:	e8 1c f6 ff ff       	call   801fde <strcpy>
	fsipcbuf.open.req_omode = mode;
  8029c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029c5:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8029ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8029cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8029d2:	e8 f6 fd ff ff       	call   8027cd <fsipc>
  8029d7:	89 c3                	mov    %eax,%ebx
  8029d9:	83 c4 10             	add    $0x10,%esp
  8029dc:	85 c0                	test   %eax,%eax
  8029de:	79 14                	jns    8029f4 <open+0x6f>
		fd_close(fd, 0);
  8029e0:	83 ec 08             	sub    $0x8,%esp
  8029e3:	6a 00                	push   $0x0
  8029e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8029e8:	e8 96 01 00 00       	call   802b83 <fd_close>
		return r;
  8029ed:	83 c4 10             	add    $0x10,%esp
  8029f0:	89 da                	mov    %ebx,%edx
  8029f2:	eb 17                	jmp    802a0b <open+0x86>
	}

	return fd2num(fd);
  8029f4:	83 ec 0c             	sub    $0xc,%esp
  8029f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8029fa:	e8 65 00 00 00       	call   802a64 <fd2num>
  8029ff:	89 c2                	mov    %eax,%edx
  802a01:	83 c4 10             	add    $0x10,%esp
  802a04:	eb 05                	jmp    802a0b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802a06:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802a0b:	89 d0                	mov    %edx,%eax
  802a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a10:	c9                   	leave  
  802a11:	c3                   	ret    

00802a12 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802a12:	55                   	push   %ebp
  802a13:	89 e5                	mov    %esp,%ebp
  802a15:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802a18:	ba 00 00 00 00       	mov    $0x0,%edx
  802a1d:	b8 08 00 00 00       	mov    $0x8,%eax
  802a22:	e8 a6 fd ff ff       	call   8027cd <fsipc>
}
  802a27:	c9                   	leave  
  802a28:	c3                   	ret    

00802a29 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a29:	55                   	push   %ebp
  802a2a:	89 e5                	mov    %esp,%ebp
  802a2c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a2f:	89 d0                	mov    %edx,%eax
  802a31:	c1 e8 16             	shr    $0x16,%eax
  802a34:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802a3b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a40:	f6 c1 01             	test   $0x1,%cl
  802a43:	74 1d                	je     802a62 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802a45:	c1 ea 0c             	shr    $0xc,%edx
  802a48:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802a4f:	f6 c2 01             	test   $0x1,%dl
  802a52:	74 0e                	je     802a62 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a54:	c1 ea 0c             	shr    $0xc,%edx
  802a57:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802a5e:	ef 
  802a5f:	0f b7 c0             	movzwl %ax,%eax
}
  802a62:	5d                   	pop    %ebp
  802a63:	c3                   	ret    

00802a64 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802a64:	55                   	push   %ebp
  802a65:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802a67:	8b 45 08             	mov    0x8(%ebp),%eax
  802a6a:	05 00 00 00 30       	add    $0x30000000,%eax
  802a6f:	c1 e8 0c             	shr    $0xc,%eax
}
  802a72:	5d                   	pop    %ebp
  802a73:	c3                   	ret    

00802a74 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802a74:	55                   	push   %ebp
  802a75:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  802a77:	8b 45 08             	mov    0x8(%ebp),%eax
  802a7a:	05 00 00 00 30       	add    $0x30000000,%eax
  802a7f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802a84:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802a89:	5d                   	pop    %ebp
  802a8a:	c3                   	ret    

00802a8b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802a8b:	55                   	push   %ebp
  802a8c:	89 e5                	mov    %esp,%ebp
  802a8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a91:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802a96:	89 c2                	mov    %eax,%edx
  802a98:	c1 ea 16             	shr    $0x16,%edx
  802a9b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802aa2:	f6 c2 01             	test   $0x1,%dl
  802aa5:	74 11                	je     802ab8 <fd_alloc+0x2d>
  802aa7:	89 c2                	mov    %eax,%edx
  802aa9:	c1 ea 0c             	shr    $0xc,%edx
  802aac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802ab3:	f6 c2 01             	test   $0x1,%dl
  802ab6:	75 09                	jne    802ac1 <fd_alloc+0x36>
			*fd_store = fd;
  802ab8:	89 01                	mov    %eax,(%ecx)
			return 0;
  802aba:	b8 00 00 00 00       	mov    $0x0,%eax
  802abf:	eb 17                	jmp    802ad8 <fd_alloc+0x4d>
  802ac1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802ac6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802acb:	75 c9                	jne    802a96 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802acd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802ad3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802ad8:	5d                   	pop    %ebp
  802ad9:	c3                   	ret    

00802ada <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802ada:	55                   	push   %ebp
  802adb:	89 e5                	mov    %esp,%ebp
  802add:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802ae0:	83 f8 1f             	cmp    $0x1f,%eax
  802ae3:	77 36                	ja     802b1b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802ae5:	c1 e0 0c             	shl    $0xc,%eax
  802ae8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802aed:	89 c2                	mov    %eax,%edx
  802aef:	c1 ea 16             	shr    $0x16,%edx
  802af2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802af9:	f6 c2 01             	test   $0x1,%dl
  802afc:	74 24                	je     802b22 <fd_lookup+0x48>
  802afe:	89 c2                	mov    %eax,%edx
  802b00:	c1 ea 0c             	shr    $0xc,%edx
  802b03:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802b0a:	f6 c2 01             	test   $0x1,%dl
  802b0d:	74 1a                	je     802b29 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802b0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b12:	89 02                	mov    %eax,(%edx)
	return 0;
  802b14:	b8 00 00 00 00       	mov    $0x0,%eax
  802b19:	eb 13                	jmp    802b2e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802b1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802b20:	eb 0c                	jmp    802b2e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802b22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802b27:	eb 05                	jmp    802b2e <fd_lookup+0x54>
  802b29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802b2e:	5d                   	pop    %ebp
  802b2f:	c3                   	ret    

00802b30 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802b30:	55                   	push   %ebp
  802b31:	89 e5                	mov    %esp,%ebp
  802b33:	83 ec 08             	sub    $0x8,%esp
  802b36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802b39:	ba 68 46 80 00       	mov    $0x804668,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802b3e:	eb 13                	jmp    802b53 <dev_lookup+0x23>
  802b40:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802b43:	39 08                	cmp    %ecx,(%eax)
  802b45:	75 0c                	jne    802b53 <dev_lookup+0x23>
			*dev = devtab[i];
  802b47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b4a:	89 01                	mov    %eax,(%ecx)
			return 0;
  802b4c:	b8 00 00 00 00       	mov    $0x0,%eax
  802b51:	eb 2e                	jmp    802b81 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802b53:	8b 02                	mov    (%edx),%eax
  802b55:	85 c0                	test   %eax,%eax
  802b57:	75 e7                	jne    802b40 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802b59:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802b5e:	8b 40 48             	mov    0x48(%eax),%eax
  802b61:	83 ec 04             	sub    $0x4,%esp
  802b64:	51                   	push   %ecx
  802b65:	50                   	push   %eax
  802b66:	68 e8 45 80 00       	push   $0x8045e8
  802b6b:	e8 e9 ee ff ff       	call   801a59 <cprintf>
	*dev = 0;
  802b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b73:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802b79:	83 c4 10             	add    $0x10,%esp
  802b7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802b81:	c9                   	leave  
  802b82:	c3                   	ret    

00802b83 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802b83:	55                   	push   %ebp
  802b84:	89 e5                	mov    %esp,%ebp
  802b86:	56                   	push   %esi
  802b87:	53                   	push   %ebx
  802b88:	83 ec 10             	sub    $0x10,%esp
  802b8b:	8b 75 08             	mov    0x8(%ebp),%esi
  802b8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802b91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b94:	50                   	push   %eax
  802b95:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802b9b:	c1 e8 0c             	shr    $0xc,%eax
  802b9e:	50                   	push   %eax
  802b9f:	e8 36 ff ff ff       	call   802ada <fd_lookup>
  802ba4:	83 c4 08             	add    $0x8,%esp
  802ba7:	85 c0                	test   %eax,%eax
  802ba9:	78 05                	js     802bb0 <fd_close+0x2d>
	    || fd != fd2)
  802bab:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802bae:	74 0c                	je     802bbc <fd_close+0x39>
		return (must_exist ? r : 0);
  802bb0:	84 db                	test   %bl,%bl
  802bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  802bb7:	0f 44 c2             	cmove  %edx,%eax
  802bba:	eb 41                	jmp    802bfd <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802bbc:	83 ec 08             	sub    $0x8,%esp
  802bbf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802bc2:	50                   	push   %eax
  802bc3:	ff 36                	pushl  (%esi)
  802bc5:	e8 66 ff ff ff       	call   802b30 <dev_lookup>
  802bca:	89 c3                	mov    %eax,%ebx
  802bcc:	83 c4 10             	add    $0x10,%esp
  802bcf:	85 c0                	test   %eax,%eax
  802bd1:	78 1a                	js     802bed <fd_close+0x6a>
		if (dev->dev_close)
  802bd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bd6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802bd9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802bde:	85 c0                	test   %eax,%eax
  802be0:	74 0b                	je     802bed <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802be2:	83 ec 0c             	sub    $0xc,%esp
  802be5:	56                   	push   %esi
  802be6:	ff d0                	call   *%eax
  802be8:	89 c3                	mov    %eax,%ebx
  802bea:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802bed:	83 ec 08             	sub    $0x8,%esp
  802bf0:	56                   	push   %esi
  802bf1:	6a 00                	push   $0x0
  802bf3:	e8 6e f8 ff ff       	call   802466 <sys_page_unmap>
	return r;
  802bf8:	83 c4 10             	add    $0x10,%esp
  802bfb:	89 d8                	mov    %ebx,%eax
}
  802bfd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802c00:	5b                   	pop    %ebx
  802c01:	5e                   	pop    %esi
  802c02:	5d                   	pop    %ebp
  802c03:	c3                   	ret    

00802c04 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802c04:	55                   	push   %ebp
  802c05:	89 e5                	mov    %esp,%ebp
  802c07:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802c0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c0d:	50                   	push   %eax
  802c0e:	ff 75 08             	pushl  0x8(%ebp)
  802c11:	e8 c4 fe ff ff       	call   802ada <fd_lookup>
  802c16:	83 c4 08             	add    $0x8,%esp
  802c19:	85 c0                	test   %eax,%eax
  802c1b:	78 10                	js     802c2d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802c1d:	83 ec 08             	sub    $0x8,%esp
  802c20:	6a 01                	push   $0x1
  802c22:	ff 75 f4             	pushl  -0xc(%ebp)
  802c25:	e8 59 ff ff ff       	call   802b83 <fd_close>
  802c2a:	83 c4 10             	add    $0x10,%esp
}
  802c2d:	c9                   	leave  
  802c2e:	c3                   	ret    

00802c2f <close_all>:

void
close_all(void)
{
  802c2f:	55                   	push   %ebp
  802c30:	89 e5                	mov    %esp,%ebp
  802c32:	53                   	push   %ebx
  802c33:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802c36:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802c3b:	83 ec 0c             	sub    $0xc,%esp
  802c3e:	53                   	push   %ebx
  802c3f:	e8 c0 ff ff ff       	call   802c04 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802c44:	83 c3 01             	add    $0x1,%ebx
  802c47:	83 c4 10             	add    $0x10,%esp
  802c4a:	83 fb 20             	cmp    $0x20,%ebx
  802c4d:	75 ec                	jne    802c3b <close_all+0xc>
		close(i);
}
  802c4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c52:	c9                   	leave  
  802c53:	c3                   	ret    

00802c54 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802c54:	55                   	push   %ebp
  802c55:	89 e5                	mov    %esp,%ebp
  802c57:	57                   	push   %edi
  802c58:	56                   	push   %esi
  802c59:	53                   	push   %ebx
  802c5a:	83 ec 2c             	sub    $0x2c,%esp
  802c5d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802c60:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802c63:	50                   	push   %eax
  802c64:	ff 75 08             	pushl  0x8(%ebp)
  802c67:	e8 6e fe ff ff       	call   802ada <fd_lookup>
  802c6c:	83 c4 08             	add    $0x8,%esp
  802c6f:	85 c0                	test   %eax,%eax
  802c71:	0f 88 c1 00 00 00    	js     802d38 <dup+0xe4>
		return r;
	close(newfdnum);
  802c77:	83 ec 0c             	sub    $0xc,%esp
  802c7a:	56                   	push   %esi
  802c7b:	e8 84 ff ff ff       	call   802c04 <close>

	newfd = INDEX2FD(newfdnum);
  802c80:	89 f3                	mov    %esi,%ebx
  802c82:	c1 e3 0c             	shl    $0xc,%ebx
  802c85:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802c8b:	83 c4 04             	add    $0x4,%esp
  802c8e:	ff 75 e4             	pushl  -0x1c(%ebp)
  802c91:	e8 de fd ff ff       	call   802a74 <fd2data>
  802c96:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802c98:	89 1c 24             	mov    %ebx,(%esp)
  802c9b:	e8 d4 fd ff ff       	call   802a74 <fd2data>
  802ca0:	83 c4 10             	add    $0x10,%esp
  802ca3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802ca6:	89 f8                	mov    %edi,%eax
  802ca8:	c1 e8 16             	shr    $0x16,%eax
  802cab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802cb2:	a8 01                	test   $0x1,%al
  802cb4:	74 37                	je     802ced <dup+0x99>
  802cb6:	89 f8                	mov    %edi,%eax
  802cb8:	c1 e8 0c             	shr    $0xc,%eax
  802cbb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802cc2:	f6 c2 01             	test   $0x1,%dl
  802cc5:	74 26                	je     802ced <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802cc7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802cce:	83 ec 0c             	sub    $0xc,%esp
  802cd1:	25 07 0e 00 00       	and    $0xe07,%eax
  802cd6:	50                   	push   %eax
  802cd7:	ff 75 d4             	pushl  -0x2c(%ebp)
  802cda:	6a 00                	push   $0x0
  802cdc:	57                   	push   %edi
  802cdd:	6a 00                	push   $0x0
  802cdf:	e8 40 f7 ff ff       	call   802424 <sys_page_map>
  802ce4:	89 c7                	mov    %eax,%edi
  802ce6:	83 c4 20             	add    $0x20,%esp
  802ce9:	85 c0                	test   %eax,%eax
  802ceb:	78 2e                	js     802d1b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802ced:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802cf0:	89 d0                	mov    %edx,%eax
  802cf2:	c1 e8 0c             	shr    $0xc,%eax
  802cf5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802cfc:	83 ec 0c             	sub    $0xc,%esp
  802cff:	25 07 0e 00 00       	and    $0xe07,%eax
  802d04:	50                   	push   %eax
  802d05:	53                   	push   %ebx
  802d06:	6a 00                	push   $0x0
  802d08:	52                   	push   %edx
  802d09:	6a 00                	push   $0x0
  802d0b:	e8 14 f7 ff ff       	call   802424 <sys_page_map>
  802d10:	89 c7                	mov    %eax,%edi
  802d12:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802d15:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802d17:	85 ff                	test   %edi,%edi
  802d19:	79 1d                	jns    802d38 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802d1b:	83 ec 08             	sub    $0x8,%esp
  802d1e:	53                   	push   %ebx
  802d1f:	6a 00                	push   $0x0
  802d21:	e8 40 f7 ff ff       	call   802466 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802d26:	83 c4 08             	add    $0x8,%esp
  802d29:	ff 75 d4             	pushl  -0x2c(%ebp)
  802d2c:	6a 00                	push   $0x0
  802d2e:	e8 33 f7 ff ff       	call   802466 <sys_page_unmap>
	return r;
  802d33:	83 c4 10             	add    $0x10,%esp
  802d36:	89 f8                	mov    %edi,%eax
}
  802d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d3b:	5b                   	pop    %ebx
  802d3c:	5e                   	pop    %esi
  802d3d:	5f                   	pop    %edi
  802d3e:	5d                   	pop    %ebp
  802d3f:	c3                   	ret    

00802d40 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802d40:	55                   	push   %ebp
  802d41:	89 e5                	mov    %esp,%ebp
  802d43:	53                   	push   %ebx
  802d44:	83 ec 14             	sub    $0x14,%esp
  802d47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d4d:	50                   	push   %eax
  802d4e:	53                   	push   %ebx
  802d4f:	e8 86 fd ff ff       	call   802ada <fd_lookup>
  802d54:	83 c4 08             	add    $0x8,%esp
  802d57:	89 c2                	mov    %eax,%edx
  802d59:	85 c0                	test   %eax,%eax
  802d5b:	78 6d                	js     802dca <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d5d:	83 ec 08             	sub    $0x8,%esp
  802d60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d63:	50                   	push   %eax
  802d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d67:	ff 30                	pushl  (%eax)
  802d69:	e8 c2 fd ff ff       	call   802b30 <dev_lookup>
  802d6e:	83 c4 10             	add    $0x10,%esp
  802d71:	85 c0                	test   %eax,%eax
  802d73:	78 4c                	js     802dc1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802d75:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802d78:	8b 42 08             	mov    0x8(%edx),%eax
  802d7b:	83 e0 03             	and    $0x3,%eax
  802d7e:	83 f8 01             	cmp    $0x1,%eax
  802d81:	75 21                	jne    802da4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802d83:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802d88:	8b 40 48             	mov    0x48(%eax),%eax
  802d8b:	83 ec 04             	sub    $0x4,%esp
  802d8e:	53                   	push   %ebx
  802d8f:	50                   	push   %eax
  802d90:	68 2c 46 80 00       	push   $0x80462c
  802d95:	e8 bf ec ff ff       	call   801a59 <cprintf>
		return -E_INVAL;
  802d9a:	83 c4 10             	add    $0x10,%esp
  802d9d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802da2:	eb 26                	jmp    802dca <read+0x8a>
	}
	if (!dev->dev_read)
  802da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802da7:	8b 40 08             	mov    0x8(%eax),%eax
  802daa:	85 c0                	test   %eax,%eax
  802dac:	74 17                	je     802dc5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802dae:	83 ec 04             	sub    $0x4,%esp
  802db1:	ff 75 10             	pushl  0x10(%ebp)
  802db4:	ff 75 0c             	pushl  0xc(%ebp)
  802db7:	52                   	push   %edx
  802db8:	ff d0                	call   *%eax
  802dba:	89 c2                	mov    %eax,%edx
  802dbc:	83 c4 10             	add    $0x10,%esp
  802dbf:	eb 09                	jmp    802dca <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802dc1:	89 c2                	mov    %eax,%edx
  802dc3:	eb 05                	jmp    802dca <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802dc5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802dca:	89 d0                	mov    %edx,%eax
  802dcc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802dcf:	c9                   	leave  
  802dd0:	c3                   	ret    

00802dd1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802dd1:	55                   	push   %ebp
  802dd2:	89 e5                	mov    %esp,%ebp
  802dd4:	57                   	push   %edi
  802dd5:	56                   	push   %esi
  802dd6:	53                   	push   %ebx
  802dd7:	83 ec 0c             	sub    $0xc,%esp
  802dda:	8b 7d 08             	mov    0x8(%ebp),%edi
  802ddd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802de0:	bb 00 00 00 00       	mov    $0x0,%ebx
  802de5:	eb 21                	jmp    802e08 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802de7:	83 ec 04             	sub    $0x4,%esp
  802dea:	89 f0                	mov    %esi,%eax
  802dec:	29 d8                	sub    %ebx,%eax
  802dee:	50                   	push   %eax
  802def:	89 d8                	mov    %ebx,%eax
  802df1:	03 45 0c             	add    0xc(%ebp),%eax
  802df4:	50                   	push   %eax
  802df5:	57                   	push   %edi
  802df6:	e8 45 ff ff ff       	call   802d40 <read>
		if (m < 0)
  802dfb:	83 c4 10             	add    $0x10,%esp
  802dfe:	85 c0                	test   %eax,%eax
  802e00:	78 10                	js     802e12 <readn+0x41>
			return m;
		if (m == 0)
  802e02:	85 c0                	test   %eax,%eax
  802e04:	74 0a                	je     802e10 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802e06:	01 c3                	add    %eax,%ebx
  802e08:	39 f3                	cmp    %esi,%ebx
  802e0a:	72 db                	jb     802de7 <readn+0x16>
  802e0c:	89 d8                	mov    %ebx,%eax
  802e0e:	eb 02                	jmp    802e12 <readn+0x41>
  802e10:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802e12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e15:	5b                   	pop    %ebx
  802e16:	5e                   	pop    %esi
  802e17:	5f                   	pop    %edi
  802e18:	5d                   	pop    %ebp
  802e19:	c3                   	ret    

00802e1a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802e1a:	55                   	push   %ebp
  802e1b:	89 e5                	mov    %esp,%ebp
  802e1d:	53                   	push   %ebx
  802e1e:	83 ec 14             	sub    $0x14,%esp
  802e21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802e24:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e27:	50                   	push   %eax
  802e28:	53                   	push   %ebx
  802e29:	e8 ac fc ff ff       	call   802ada <fd_lookup>
  802e2e:	83 c4 08             	add    $0x8,%esp
  802e31:	89 c2                	mov    %eax,%edx
  802e33:	85 c0                	test   %eax,%eax
  802e35:	78 68                	js     802e9f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e37:	83 ec 08             	sub    $0x8,%esp
  802e3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e3d:	50                   	push   %eax
  802e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e41:	ff 30                	pushl  (%eax)
  802e43:	e8 e8 fc ff ff       	call   802b30 <dev_lookup>
  802e48:	83 c4 10             	add    $0x10,%esp
  802e4b:	85 c0                	test   %eax,%eax
  802e4d:	78 47                	js     802e96 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802e4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e52:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802e56:	75 21                	jne    802e79 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802e58:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802e5d:	8b 40 48             	mov    0x48(%eax),%eax
  802e60:	83 ec 04             	sub    $0x4,%esp
  802e63:	53                   	push   %ebx
  802e64:	50                   	push   %eax
  802e65:	68 48 46 80 00       	push   $0x804648
  802e6a:	e8 ea eb ff ff       	call   801a59 <cprintf>
		return -E_INVAL;
  802e6f:	83 c4 10             	add    $0x10,%esp
  802e72:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802e77:	eb 26                	jmp    802e9f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802e79:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802e7c:	8b 52 0c             	mov    0xc(%edx),%edx
  802e7f:	85 d2                	test   %edx,%edx
  802e81:	74 17                	je     802e9a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802e83:	83 ec 04             	sub    $0x4,%esp
  802e86:	ff 75 10             	pushl  0x10(%ebp)
  802e89:	ff 75 0c             	pushl  0xc(%ebp)
  802e8c:	50                   	push   %eax
  802e8d:	ff d2                	call   *%edx
  802e8f:	89 c2                	mov    %eax,%edx
  802e91:	83 c4 10             	add    $0x10,%esp
  802e94:	eb 09                	jmp    802e9f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e96:	89 c2                	mov    %eax,%edx
  802e98:	eb 05                	jmp    802e9f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802e9a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802e9f:	89 d0                	mov    %edx,%eax
  802ea1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ea4:	c9                   	leave  
  802ea5:	c3                   	ret    

00802ea6 <seek>:

int
seek(int fdnum, off_t offset)
{
  802ea6:	55                   	push   %ebp
  802ea7:	89 e5                	mov    %esp,%ebp
  802ea9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802eac:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802eaf:	50                   	push   %eax
  802eb0:	ff 75 08             	pushl  0x8(%ebp)
  802eb3:	e8 22 fc ff ff       	call   802ada <fd_lookup>
  802eb8:	83 c4 08             	add    $0x8,%esp
  802ebb:	85 c0                	test   %eax,%eax
  802ebd:	78 0e                	js     802ecd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802ebf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802ec2:	8b 55 0c             	mov    0xc(%ebp),%edx
  802ec5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802ec8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ecd:	c9                   	leave  
  802ece:	c3                   	ret    

00802ecf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802ecf:	55                   	push   %ebp
  802ed0:	89 e5                	mov    %esp,%ebp
  802ed2:	53                   	push   %ebx
  802ed3:	83 ec 14             	sub    $0x14,%esp
  802ed6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802ed9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802edc:	50                   	push   %eax
  802edd:	53                   	push   %ebx
  802ede:	e8 f7 fb ff ff       	call   802ada <fd_lookup>
  802ee3:	83 c4 08             	add    $0x8,%esp
  802ee6:	89 c2                	mov    %eax,%edx
  802ee8:	85 c0                	test   %eax,%eax
  802eea:	78 65                	js     802f51 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802eec:	83 ec 08             	sub    $0x8,%esp
  802eef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ef2:	50                   	push   %eax
  802ef3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ef6:	ff 30                	pushl  (%eax)
  802ef8:	e8 33 fc ff ff       	call   802b30 <dev_lookup>
  802efd:	83 c4 10             	add    $0x10,%esp
  802f00:	85 c0                	test   %eax,%eax
  802f02:	78 44                	js     802f48 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f07:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802f0b:	75 21                	jne    802f2e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802f0d:	a1 10 a0 80 00       	mov    0x80a010,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802f12:	8b 40 48             	mov    0x48(%eax),%eax
  802f15:	83 ec 04             	sub    $0x4,%esp
  802f18:	53                   	push   %ebx
  802f19:	50                   	push   %eax
  802f1a:	68 08 46 80 00       	push   $0x804608
  802f1f:	e8 35 eb ff ff       	call   801a59 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802f24:	83 c4 10             	add    $0x10,%esp
  802f27:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802f2c:	eb 23                	jmp    802f51 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802f2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802f31:	8b 52 18             	mov    0x18(%edx),%edx
  802f34:	85 d2                	test   %edx,%edx
  802f36:	74 14                	je     802f4c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802f38:	83 ec 08             	sub    $0x8,%esp
  802f3b:	ff 75 0c             	pushl  0xc(%ebp)
  802f3e:	50                   	push   %eax
  802f3f:	ff d2                	call   *%edx
  802f41:	89 c2                	mov    %eax,%edx
  802f43:	83 c4 10             	add    $0x10,%esp
  802f46:	eb 09                	jmp    802f51 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f48:	89 c2                	mov    %eax,%edx
  802f4a:	eb 05                	jmp    802f51 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802f4c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802f51:	89 d0                	mov    %edx,%eax
  802f53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f56:	c9                   	leave  
  802f57:	c3                   	ret    

00802f58 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802f58:	55                   	push   %ebp
  802f59:	89 e5                	mov    %esp,%ebp
  802f5b:	53                   	push   %ebx
  802f5c:	83 ec 14             	sub    $0x14,%esp
  802f5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802f62:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f65:	50                   	push   %eax
  802f66:	ff 75 08             	pushl  0x8(%ebp)
  802f69:	e8 6c fb ff ff       	call   802ada <fd_lookup>
  802f6e:	83 c4 08             	add    $0x8,%esp
  802f71:	89 c2                	mov    %eax,%edx
  802f73:	85 c0                	test   %eax,%eax
  802f75:	78 58                	js     802fcf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f77:	83 ec 08             	sub    $0x8,%esp
  802f7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f7d:	50                   	push   %eax
  802f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f81:	ff 30                	pushl  (%eax)
  802f83:	e8 a8 fb ff ff       	call   802b30 <dev_lookup>
  802f88:	83 c4 10             	add    $0x10,%esp
  802f8b:	85 c0                	test   %eax,%eax
  802f8d:	78 37                	js     802fc6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f92:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802f96:	74 32                	je     802fca <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802f98:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802f9b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802fa2:	00 00 00 
	stat->st_isdir = 0;
  802fa5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802fac:	00 00 00 
	stat->st_dev = dev;
  802faf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802fb5:	83 ec 08             	sub    $0x8,%esp
  802fb8:	53                   	push   %ebx
  802fb9:	ff 75 f0             	pushl  -0x10(%ebp)
  802fbc:	ff 50 14             	call   *0x14(%eax)
  802fbf:	89 c2                	mov    %eax,%edx
  802fc1:	83 c4 10             	add    $0x10,%esp
  802fc4:	eb 09                	jmp    802fcf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802fc6:	89 c2                	mov    %eax,%edx
  802fc8:	eb 05                	jmp    802fcf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802fca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802fcf:	89 d0                	mov    %edx,%eax
  802fd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802fd4:	c9                   	leave  
  802fd5:	c3                   	ret    

00802fd6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802fd6:	55                   	push   %ebp
  802fd7:	89 e5                	mov    %esp,%ebp
  802fd9:	56                   	push   %esi
  802fda:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802fdb:	83 ec 08             	sub    $0x8,%esp
  802fde:	6a 00                	push   $0x0
  802fe0:	ff 75 08             	pushl  0x8(%ebp)
  802fe3:	e8 9d f9 ff ff       	call   802985 <open>
  802fe8:	89 c3                	mov    %eax,%ebx
  802fea:	83 c4 10             	add    $0x10,%esp
  802fed:	85 c0                	test   %eax,%eax
  802fef:	78 1b                	js     80300c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802ff1:	83 ec 08             	sub    $0x8,%esp
  802ff4:	ff 75 0c             	pushl  0xc(%ebp)
  802ff7:	50                   	push   %eax
  802ff8:	e8 5b ff ff ff       	call   802f58 <fstat>
  802ffd:	89 c6                	mov    %eax,%esi
	close(fd);
  802fff:	89 1c 24             	mov    %ebx,(%esp)
  803002:	e8 fd fb ff ff       	call   802c04 <close>
	return r;
  803007:	83 c4 10             	add    $0x10,%esp
  80300a:	89 f0                	mov    %esi,%eax
}
  80300c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80300f:	5b                   	pop    %ebx
  803010:	5e                   	pop    %esi
  803011:	5d                   	pop    %ebp
  803012:	c3                   	ret    

00803013 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  803013:	55                   	push   %ebp
  803014:	89 e5                	mov    %esp,%ebp
  803016:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  803019:	68 7c 46 80 00       	push   $0x80467c
  80301e:	ff 75 0c             	pushl  0xc(%ebp)
  803021:	e8 b8 ef ff ff       	call   801fde <strcpy>
	return 0;
}
  803026:	b8 00 00 00 00       	mov    $0x0,%eax
  80302b:	c9                   	leave  
  80302c:	c3                   	ret    

0080302d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80302d:	55                   	push   %ebp
  80302e:	89 e5                	mov    %esp,%ebp
  803030:	53                   	push   %ebx
  803031:	83 ec 10             	sub    $0x10,%esp
  803034:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  803037:	53                   	push   %ebx
  803038:	e8 ec f9 ff ff       	call   802a29 <pageref>
  80303d:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  803040:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  803045:	83 f8 01             	cmp    $0x1,%eax
  803048:	75 10                	jne    80305a <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80304a:	83 ec 0c             	sub    $0xc,%esp
  80304d:	ff 73 0c             	pushl  0xc(%ebx)
  803050:	e8 c0 02 00 00       	call   803315 <nsipc_close>
  803055:	89 c2                	mov    %eax,%edx
  803057:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80305a:	89 d0                	mov    %edx,%eax
  80305c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80305f:	c9                   	leave  
  803060:	c3                   	ret    

00803061 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  803061:	55                   	push   %ebp
  803062:	89 e5                	mov    %esp,%ebp
  803064:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  803067:	6a 00                	push   $0x0
  803069:	ff 75 10             	pushl  0x10(%ebp)
  80306c:	ff 75 0c             	pushl  0xc(%ebp)
  80306f:	8b 45 08             	mov    0x8(%ebp),%eax
  803072:	ff 70 0c             	pushl  0xc(%eax)
  803075:	e8 78 03 00 00       	call   8033f2 <nsipc_send>
}
  80307a:	c9                   	leave  
  80307b:	c3                   	ret    

0080307c <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80307c:	55                   	push   %ebp
  80307d:	89 e5                	mov    %esp,%ebp
  80307f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  803082:	6a 00                	push   $0x0
  803084:	ff 75 10             	pushl  0x10(%ebp)
  803087:	ff 75 0c             	pushl  0xc(%ebp)
  80308a:	8b 45 08             	mov    0x8(%ebp),%eax
  80308d:	ff 70 0c             	pushl  0xc(%eax)
  803090:	e8 f1 02 00 00       	call   803386 <nsipc_recv>
}
  803095:	c9                   	leave  
  803096:	c3                   	ret    

00803097 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  803097:	55                   	push   %ebp
  803098:	89 e5                	mov    %esp,%ebp
  80309a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80309d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8030a0:	52                   	push   %edx
  8030a1:	50                   	push   %eax
  8030a2:	e8 33 fa ff ff       	call   802ada <fd_lookup>
  8030a7:	83 c4 10             	add    $0x10,%esp
  8030aa:	85 c0                	test   %eax,%eax
  8030ac:	78 17                	js     8030c5 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8030ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030b1:	8b 0d 80 90 80 00    	mov    0x809080,%ecx
  8030b7:	39 08                	cmp    %ecx,(%eax)
  8030b9:	75 05                	jne    8030c0 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8030bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8030be:	eb 05                	jmp    8030c5 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8030c0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8030c5:	c9                   	leave  
  8030c6:	c3                   	ret    

008030c7 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8030c7:	55                   	push   %ebp
  8030c8:	89 e5                	mov    %esp,%ebp
  8030ca:	56                   	push   %esi
  8030cb:	53                   	push   %ebx
  8030cc:	83 ec 1c             	sub    $0x1c,%esp
  8030cf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8030d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030d4:	50                   	push   %eax
  8030d5:	e8 b1 f9 ff ff       	call   802a8b <fd_alloc>
  8030da:	89 c3                	mov    %eax,%ebx
  8030dc:	83 c4 10             	add    $0x10,%esp
  8030df:	85 c0                	test   %eax,%eax
  8030e1:	78 1b                	js     8030fe <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8030e3:	83 ec 04             	sub    $0x4,%esp
  8030e6:	68 07 04 00 00       	push   $0x407
  8030eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8030ee:	6a 00                	push   $0x0
  8030f0:	e8 ec f2 ff ff       	call   8023e1 <sys_page_alloc>
  8030f5:	89 c3                	mov    %eax,%ebx
  8030f7:	83 c4 10             	add    $0x10,%esp
  8030fa:	85 c0                	test   %eax,%eax
  8030fc:	79 10                	jns    80310e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8030fe:	83 ec 0c             	sub    $0xc,%esp
  803101:	56                   	push   %esi
  803102:	e8 0e 02 00 00       	call   803315 <nsipc_close>
		return r;
  803107:	83 c4 10             	add    $0x10,%esp
  80310a:	89 d8                	mov    %ebx,%eax
  80310c:	eb 24                	jmp    803132 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80310e:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803114:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803117:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  803119:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80311c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  803123:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  803126:	83 ec 0c             	sub    $0xc,%esp
  803129:	50                   	push   %eax
  80312a:	e8 35 f9 ff ff       	call   802a64 <fd2num>
  80312f:	83 c4 10             	add    $0x10,%esp
}
  803132:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803135:	5b                   	pop    %ebx
  803136:	5e                   	pop    %esi
  803137:	5d                   	pop    %ebp
  803138:	c3                   	ret    

00803139 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  803139:	55                   	push   %ebp
  80313a:	89 e5                	mov    %esp,%ebp
  80313c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80313f:	8b 45 08             	mov    0x8(%ebp),%eax
  803142:	e8 50 ff ff ff       	call   803097 <fd2sockid>
		return r;
  803147:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  803149:	85 c0                	test   %eax,%eax
  80314b:	78 1f                	js     80316c <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80314d:	83 ec 04             	sub    $0x4,%esp
  803150:	ff 75 10             	pushl  0x10(%ebp)
  803153:	ff 75 0c             	pushl  0xc(%ebp)
  803156:	50                   	push   %eax
  803157:	e8 12 01 00 00       	call   80326e <nsipc_accept>
  80315c:	83 c4 10             	add    $0x10,%esp
		return r;
  80315f:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  803161:	85 c0                	test   %eax,%eax
  803163:	78 07                	js     80316c <accept+0x33>
		return r;
	return alloc_sockfd(r);
  803165:	e8 5d ff ff ff       	call   8030c7 <alloc_sockfd>
  80316a:	89 c1                	mov    %eax,%ecx
}
  80316c:	89 c8                	mov    %ecx,%eax
  80316e:	c9                   	leave  
  80316f:	c3                   	ret    

00803170 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  803170:	55                   	push   %ebp
  803171:	89 e5                	mov    %esp,%ebp
  803173:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803176:	8b 45 08             	mov    0x8(%ebp),%eax
  803179:	e8 19 ff ff ff       	call   803097 <fd2sockid>
  80317e:	85 c0                	test   %eax,%eax
  803180:	78 12                	js     803194 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  803182:	83 ec 04             	sub    $0x4,%esp
  803185:	ff 75 10             	pushl  0x10(%ebp)
  803188:	ff 75 0c             	pushl  0xc(%ebp)
  80318b:	50                   	push   %eax
  80318c:	e8 2d 01 00 00       	call   8032be <nsipc_bind>
  803191:	83 c4 10             	add    $0x10,%esp
}
  803194:	c9                   	leave  
  803195:	c3                   	ret    

00803196 <shutdown>:

int
shutdown(int s, int how)
{
  803196:	55                   	push   %ebp
  803197:	89 e5                	mov    %esp,%ebp
  803199:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80319c:	8b 45 08             	mov    0x8(%ebp),%eax
  80319f:	e8 f3 fe ff ff       	call   803097 <fd2sockid>
  8031a4:	85 c0                	test   %eax,%eax
  8031a6:	78 0f                	js     8031b7 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8031a8:	83 ec 08             	sub    $0x8,%esp
  8031ab:	ff 75 0c             	pushl  0xc(%ebp)
  8031ae:	50                   	push   %eax
  8031af:	e8 3f 01 00 00       	call   8032f3 <nsipc_shutdown>
  8031b4:	83 c4 10             	add    $0x10,%esp
}
  8031b7:	c9                   	leave  
  8031b8:	c3                   	ret    

008031b9 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8031b9:	55                   	push   %ebp
  8031ba:	89 e5                	mov    %esp,%ebp
  8031bc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8031bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8031c2:	e8 d0 fe ff ff       	call   803097 <fd2sockid>
  8031c7:	85 c0                	test   %eax,%eax
  8031c9:	78 12                	js     8031dd <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8031cb:	83 ec 04             	sub    $0x4,%esp
  8031ce:	ff 75 10             	pushl  0x10(%ebp)
  8031d1:	ff 75 0c             	pushl  0xc(%ebp)
  8031d4:	50                   	push   %eax
  8031d5:	e8 55 01 00 00       	call   80332f <nsipc_connect>
  8031da:	83 c4 10             	add    $0x10,%esp
}
  8031dd:	c9                   	leave  
  8031de:	c3                   	ret    

008031df <listen>:

int
listen(int s, int backlog)
{
  8031df:	55                   	push   %ebp
  8031e0:	89 e5                	mov    %esp,%ebp
  8031e2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8031e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8031e8:	e8 aa fe ff ff       	call   803097 <fd2sockid>
  8031ed:	85 c0                	test   %eax,%eax
  8031ef:	78 0f                	js     803200 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8031f1:	83 ec 08             	sub    $0x8,%esp
  8031f4:	ff 75 0c             	pushl  0xc(%ebp)
  8031f7:	50                   	push   %eax
  8031f8:	e8 67 01 00 00       	call   803364 <nsipc_listen>
  8031fd:	83 c4 10             	add    $0x10,%esp
}
  803200:	c9                   	leave  
  803201:	c3                   	ret    

00803202 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  803202:	55                   	push   %ebp
  803203:	89 e5                	mov    %esp,%ebp
  803205:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  803208:	ff 75 10             	pushl  0x10(%ebp)
  80320b:	ff 75 0c             	pushl  0xc(%ebp)
  80320e:	ff 75 08             	pushl  0x8(%ebp)
  803211:	e8 3a 02 00 00       	call   803450 <nsipc_socket>
  803216:	83 c4 10             	add    $0x10,%esp
  803219:	85 c0                	test   %eax,%eax
  80321b:	78 05                	js     803222 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80321d:	e8 a5 fe ff ff       	call   8030c7 <alloc_sockfd>
}
  803222:	c9                   	leave  
  803223:	c3                   	ret    

00803224 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  803224:	55                   	push   %ebp
  803225:	89 e5                	mov    %esp,%ebp
  803227:	53                   	push   %ebx
  803228:	83 ec 04             	sub    $0x4,%esp
  80322b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80322d:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  803234:	75 12                	jne    803248 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  803236:	83 ec 0c             	sub    $0xc,%esp
  803239:	6a 02                	push   $0x2
  80323b:	e8 54 f5 ff ff       	call   802794 <ipc_find_env>
  803240:	a3 04 a0 80 00       	mov    %eax,0x80a004
  803245:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  803248:	6a 07                	push   $0x7
  80324a:	68 00 c0 80 00       	push   $0x80c000
  80324f:	53                   	push   %ebx
  803250:	ff 35 04 a0 80 00    	pushl  0x80a004
  803256:	e8 ad f4 ff ff       	call   802708 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80325b:	83 c4 0c             	add    $0xc,%esp
  80325e:	6a 00                	push   $0x0
  803260:	6a 00                	push   $0x0
  803262:	6a 00                	push   $0x0
  803264:	e8 2a f4 ff ff       	call   802693 <ipc_recv>
}
  803269:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80326c:	c9                   	leave  
  80326d:	c3                   	ret    

0080326e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80326e:	55                   	push   %ebp
  80326f:	89 e5                	mov    %esp,%ebp
  803271:	56                   	push   %esi
  803272:	53                   	push   %ebx
  803273:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  803276:	8b 45 08             	mov    0x8(%ebp),%eax
  803279:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80327e:	8b 06                	mov    (%esi),%eax
  803280:	a3 04 c0 80 00       	mov    %eax,0x80c004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  803285:	b8 01 00 00 00       	mov    $0x1,%eax
  80328a:	e8 95 ff ff ff       	call   803224 <nsipc>
  80328f:	89 c3                	mov    %eax,%ebx
  803291:	85 c0                	test   %eax,%eax
  803293:	78 20                	js     8032b5 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  803295:	83 ec 04             	sub    $0x4,%esp
  803298:	ff 35 10 c0 80 00    	pushl  0x80c010
  80329e:	68 00 c0 80 00       	push   $0x80c000
  8032a3:	ff 75 0c             	pushl  0xc(%ebp)
  8032a6:	e8 c5 ee ff ff       	call   802170 <memmove>
		*addrlen = ret->ret_addrlen;
  8032ab:	a1 10 c0 80 00       	mov    0x80c010,%eax
  8032b0:	89 06                	mov    %eax,(%esi)
  8032b2:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8032b5:	89 d8                	mov    %ebx,%eax
  8032b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032ba:	5b                   	pop    %ebx
  8032bb:	5e                   	pop    %esi
  8032bc:	5d                   	pop    %ebp
  8032bd:	c3                   	ret    

008032be <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8032be:	55                   	push   %ebp
  8032bf:	89 e5                	mov    %esp,%ebp
  8032c1:	53                   	push   %ebx
  8032c2:	83 ec 08             	sub    $0x8,%esp
  8032c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8032c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8032cb:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8032d0:	53                   	push   %ebx
  8032d1:	ff 75 0c             	pushl  0xc(%ebp)
  8032d4:	68 04 c0 80 00       	push   $0x80c004
  8032d9:	e8 92 ee ff ff       	call   802170 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8032de:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_BIND);
  8032e4:	b8 02 00 00 00       	mov    $0x2,%eax
  8032e9:	e8 36 ff ff ff       	call   803224 <nsipc>
}
  8032ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8032f1:	c9                   	leave  
  8032f2:	c3                   	ret    

008032f3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8032f3:	55                   	push   %ebp
  8032f4:	89 e5                	mov    %esp,%ebp
  8032f6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8032f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8032fc:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.shutdown.req_how = how;
  803301:	8b 45 0c             	mov    0xc(%ebp),%eax
  803304:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_SHUTDOWN);
  803309:	b8 03 00 00 00       	mov    $0x3,%eax
  80330e:	e8 11 ff ff ff       	call   803224 <nsipc>
}
  803313:	c9                   	leave  
  803314:	c3                   	ret    

00803315 <nsipc_close>:

int
nsipc_close(int s)
{
  803315:	55                   	push   %ebp
  803316:	89 e5                	mov    %esp,%ebp
  803318:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80331b:	8b 45 08             	mov    0x8(%ebp),%eax
  80331e:	a3 00 c0 80 00       	mov    %eax,0x80c000
	return nsipc(NSREQ_CLOSE);
  803323:	b8 04 00 00 00       	mov    $0x4,%eax
  803328:	e8 f7 fe ff ff       	call   803224 <nsipc>
}
  80332d:	c9                   	leave  
  80332e:	c3                   	ret    

0080332f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80332f:	55                   	push   %ebp
  803330:	89 e5                	mov    %esp,%ebp
  803332:	53                   	push   %ebx
  803333:	83 ec 08             	sub    $0x8,%esp
  803336:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  803339:	8b 45 08             	mov    0x8(%ebp),%eax
  80333c:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  803341:	53                   	push   %ebx
  803342:	ff 75 0c             	pushl  0xc(%ebp)
  803345:	68 04 c0 80 00       	push   $0x80c004
  80334a:	e8 21 ee ff ff       	call   802170 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80334f:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_CONNECT);
  803355:	b8 05 00 00 00       	mov    $0x5,%eax
  80335a:	e8 c5 fe ff ff       	call   803224 <nsipc>
}
  80335f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803362:	c9                   	leave  
  803363:	c3                   	ret    

00803364 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  803364:	55                   	push   %ebp
  803365:	89 e5                	mov    %esp,%ebp
  803367:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80336a:	8b 45 08             	mov    0x8(%ebp),%eax
  80336d:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.listen.req_backlog = backlog;
  803372:	8b 45 0c             	mov    0xc(%ebp),%eax
  803375:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_LISTEN);
  80337a:	b8 06 00 00 00       	mov    $0x6,%eax
  80337f:	e8 a0 fe ff ff       	call   803224 <nsipc>
}
  803384:	c9                   	leave  
  803385:	c3                   	ret    

00803386 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  803386:	55                   	push   %ebp
  803387:	89 e5                	mov    %esp,%ebp
  803389:	56                   	push   %esi
  80338a:	53                   	push   %ebx
  80338b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80338e:	8b 45 08             	mov    0x8(%ebp),%eax
  803391:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.recv.req_len = len;
  803396:	89 35 04 c0 80 00    	mov    %esi,0x80c004
	nsipcbuf.recv.req_flags = flags;
  80339c:	8b 45 14             	mov    0x14(%ebp),%eax
  80339f:	a3 08 c0 80 00       	mov    %eax,0x80c008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8033a4:	b8 07 00 00 00       	mov    $0x7,%eax
  8033a9:	e8 76 fe ff ff       	call   803224 <nsipc>
  8033ae:	89 c3                	mov    %eax,%ebx
  8033b0:	85 c0                	test   %eax,%eax
  8033b2:	78 35                	js     8033e9 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8033b4:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8033b9:	7f 04                	jg     8033bf <nsipc_recv+0x39>
  8033bb:	39 c6                	cmp    %eax,%esi
  8033bd:	7d 16                	jge    8033d5 <nsipc_recv+0x4f>
  8033bf:	68 88 46 80 00       	push   $0x804688
  8033c4:	68 3d 3c 80 00       	push   $0x803c3d
  8033c9:	6a 62                	push   $0x62
  8033cb:	68 9d 46 80 00       	push   $0x80469d
  8033d0:	e8 ab e5 ff ff       	call   801980 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8033d5:	83 ec 04             	sub    $0x4,%esp
  8033d8:	50                   	push   %eax
  8033d9:	68 00 c0 80 00       	push   $0x80c000
  8033de:	ff 75 0c             	pushl  0xc(%ebp)
  8033e1:	e8 8a ed ff ff       	call   802170 <memmove>
  8033e6:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8033e9:	89 d8                	mov    %ebx,%eax
  8033eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8033ee:	5b                   	pop    %ebx
  8033ef:	5e                   	pop    %esi
  8033f0:	5d                   	pop    %ebp
  8033f1:	c3                   	ret    

008033f2 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8033f2:	55                   	push   %ebp
  8033f3:	89 e5                	mov    %esp,%ebp
  8033f5:	53                   	push   %ebx
  8033f6:	83 ec 04             	sub    $0x4,%esp
  8033f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8033fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8033ff:	a3 00 c0 80 00       	mov    %eax,0x80c000
	assert(size < 1600);
  803404:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80340a:	7e 16                	jle    803422 <nsipc_send+0x30>
  80340c:	68 a9 46 80 00       	push   $0x8046a9
  803411:	68 3d 3c 80 00       	push   $0x803c3d
  803416:	6a 6d                	push   $0x6d
  803418:	68 9d 46 80 00       	push   $0x80469d
  80341d:	e8 5e e5 ff ff       	call   801980 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  803422:	83 ec 04             	sub    $0x4,%esp
  803425:	53                   	push   %ebx
  803426:	ff 75 0c             	pushl  0xc(%ebp)
  803429:	68 0c c0 80 00       	push   $0x80c00c
  80342e:	e8 3d ed ff ff       	call   802170 <memmove>
	nsipcbuf.send.req_size = size;
  803433:	89 1d 04 c0 80 00    	mov    %ebx,0x80c004
	nsipcbuf.send.req_flags = flags;
  803439:	8b 45 14             	mov    0x14(%ebp),%eax
  80343c:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SEND);
  803441:	b8 08 00 00 00       	mov    $0x8,%eax
  803446:	e8 d9 fd ff ff       	call   803224 <nsipc>
}
  80344b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80344e:	c9                   	leave  
  80344f:	c3                   	ret    

00803450 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  803450:	55                   	push   %ebp
  803451:	89 e5                	mov    %esp,%ebp
  803453:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  803456:	8b 45 08             	mov    0x8(%ebp),%eax
  803459:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.socket.req_type = type;
  80345e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803461:	a3 04 c0 80 00       	mov    %eax,0x80c004
	nsipcbuf.socket.req_protocol = protocol;
  803466:	8b 45 10             	mov    0x10(%ebp),%eax
  803469:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SOCKET);
  80346e:	b8 09 00 00 00       	mov    $0x9,%eax
  803473:	e8 ac fd ff ff       	call   803224 <nsipc>
}
  803478:	c9                   	leave  
  803479:	c3                   	ret    

0080347a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80347a:	55                   	push   %ebp
  80347b:	89 e5                	mov    %esp,%ebp
  80347d:	56                   	push   %esi
  80347e:	53                   	push   %ebx
  80347f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803482:	83 ec 0c             	sub    $0xc,%esp
  803485:	ff 75 08             	pushl  0x8(%ebp)
  803488:	e8 e7 f5 ff ff       	call   802a74 <fd2data>
  80348d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80348f:	83 c4 08             	add    $0x8,%esp
  803492:	68 b5 46 80 00       	push   $0x8046b5
  803497:	53                   	push   %ebx
  803498:	e8 41 eb ff ff       	call   801fde <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80349d:	8b 46 04             	mov    0x4(%esi),%eax
  8034a0:	2b 06                	sub    (%esi),%eax
  8034a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8034a8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8034af:	00 00 00 
	stat->st_dev = &devpipe;
  8034b2:	c7 83 88 00 00 00 9c 	movl   $0x80909c,0x88(%ebx)
  8034b9:	90 80 00 
	return 0;
}
  8034bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8034c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8034c4:	5b                   	pop    %ebx
  8034c5:	5e                   	pop    %esi
  8034c6:	5d                   	pop    %ebp
  8034c7:	c3                   	ret    

008034c8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8034c8:	55                   	push   %ebp
  8034c9:	89 e5                	mov    %esp,%ebp
  8034cb:	53                   	push   %ebx
  8034cc:	83 ec 0c             	sub    $0xc,%esp
  8034cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8034d2:	53                   	push   %ebx
  8034d3:	6a 00                	push   $0x0
  8034d5:	e8 8c ef ff ff       	call   802466 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8034da:	89 1c 24             	mov    %ebx,(%esp)
  8034dd:	e8 92 f5 ff ff       	call   802a74 <fd2data>
  8034e2:	83 c4 08             	add    $0x8,%esp
  8034e5:	50                   	push   %eax
  8034e6:	6a 00                	push   $0x0
  8034e8:	e8 79 ef ff ff       	call   802466 <sys_page_unmap>
}
  8034ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8034f0:	c9                   	leave  
  8034f1:	c3                   	ret    

008034f2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8034f2:	55                   	push   %ebp
  8034f3:	89 e5                	mov    %esp,%ebp
  8034f5:	57                   	push   %edi
  8034f6:	56                   	push   %esi
  8034f7:	53                   	push   %ebx
  8034f8:	83 ec 1c             	sub    $0x1c,%esp
  8034fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8034fe:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803500:	a1 10 a0 80 00       	mov    0x80a010,%eax
  803505:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  803508:	83 ec 0c             	sub    $0xc,%esp
  80350b:	ff 75 e0             	pushl  -0x20(%ebp)
  80350e:	e8 16 f5 ff ff       	call   802a29 <pageref>
  803513:	89 c3                	mov    %eax,%ebx
  803515:	89 3c 24             	mov    %edi,(%esp)
  803518:	e8 0c f5 ff ff       	call   802a29 <pageref>
  80351d:	83 c4 10             	add    $0x10,%esp
  803520:	39 c3                	cmp    %eax,%ebx
  803522:	0f 94 c1             	sete   %cl
  803525:	0f b6 c9             	movzbl %cl,%ecx
  803528:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80352b:	8b 15 10 a0 80 00    	mov    0x80a010,%edx
  803531:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803534:	39 ce                	cmp    %ecx,%esi
  803536:	74 1b                	je     803553 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  803538:	39 c3                	cmp    %eax,%ebx
  80353a:	75 c4                	jne    803500 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80353c:	8b 42 58             	mov    0x58(%edx),%eax
  80353f:	ff 75 e4             	pushl  -0x1c(%ebp)
  803542:	50                   	push   %eax
  803543:	56                   	push   %esi
  803544:	68 bc 46 80 00       	push   $0x8046bc
  803549:	e8 0b e5 ff ff       	call   801a59 <cprintf>
  80354e:	83 c4 10             	add    $0x10,%esp
  803551:	eb ad                	jmp    803500 <_pipeisclosed+0xe>
	}
}
  803553:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803556:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803559:	5b                   	pop    %ebx
  80355a:	5e                   	pop    %esi
  80355b:	5f                   	pop    %edi
  80355c:	5d                   	pop    %ebp
  80355d:	c3                   	ret    

0080355e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80355e:	55                   	push   %ebp
  80355f:	89 e5                	mov    %esp,%ebp
  803561:	57                   	push   %edi
  803562:	56                   	push   %esi
  803563:	53                   	push   %ebx
  803564:	83 ec 28             	sub    $0x28,%esp
  803567:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80356a:	56                   	push   %esi
  80356b:	e8 04 f5 ff ff       	call   802a74 <fd2data>
  803570:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803572:	83 c4 10             	add    $0x10,%esp
  803575:	bf 00 00 00 00       	mov    $0x0,%edi
  80357a:	eb 4b                	jmp    8035c7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80357c:	89 da                	mov    %ebx,%edx
  80357e:	89 f0                	mov    %esi,%eax
  803580:	e8 6d ff ff ff       	call   8034f2 <_pipeisclosed>
  803585:	85 c0                	test   %eax,%eax
  803587:	75 48                	jne    8035d1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803589:	e8 34 ee ff ff       	call   8023c2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80358e:	8b 43 04             	mov    0x4(%ebx),%eax
  803591:	8b 0b                	mov    (%ebx),%ecx
  803593:	8d 51 20             	lea    0x20(%ecx),%edx
  803596:	39 d0                	cmp    %edx,%eax
  803598:	73 e2                	jae    80357c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80359a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80359d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8035a1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8035a4:	89 c2                	mov    %eax,%edx
  8035a6:	c1 fa 1f             	sar    $0x1f,%edx
  8035a9:	89 d1                	mov    %edx,%ecx
  8035ab:	c1 e9 1b             	shr    $0x1b,%ecx
  8035ae:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8035b1:	83 e2 1f             	and    $0x1f,%edx
  8035b4:	29 ca                	sub    %ecx,%edx
  8035b6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8035ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8035be:	83 c0 01             	add    $0x1,%eax
  8035c1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8035c4:	83 c7 01             	add    $0x1,%edi
  8035c7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8035ca:	75 c2                	jne    80358e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8035cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8035cf:	eb 05                	jmp    8035d6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8035d1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8035d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8035d9:	5b                   	pop    %ebx
  8035da:	5e                   	pop    %esi
  8035db:	5f                   	pop    %edi
  8035dc:	5d                   	pop    %ebp
  8035dd:	c3                   	ret    

008035de <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8035de:	55                   	push   %ebp
  8035df:	89 e5                	mov    %esp,%ebp
  8035e1:	57                   	push   %edi
  8035e2:	56                   	push   %esi
  8035e3:	53                   	push   %ebx
  8035e4:	83 ec 18             	sub    $0x18,%esp
  8035e7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8035ea:	57                   	push   %edi
  8035eb:	e8 84 f4 ff ff       	call   802a74 <fd2data>
  8035f0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8035f2:	83 c4 10             	add    $0x10,%esp
  8035f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8035fa:	eb 3d                	jmp    803639 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8035fc:	85 db                	test   %ebx,%ebx
  8035fe:	74 04                	je     803604 <devpipe_read+0x26>
				return i;
  803600:	89 d8                	mov    %ebx,%eax
  803602:	eb 44                	jmp    803648 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803604:	89 f2                	mov    %esi,%edx
  803606:	89 f8                	mov    %edi,%eax
  803608:	e8 e5 fe ff ff       	call   8034f2 <_pipeisclosed>
  80360d:	85 c0                	test   %eax,%eax
  80360f:	75 32                	jne    803643 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803611:	e8 ac ed ff ff       	call   8023c2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803616:	8b 06                	mov    (%esi),%eax
  803618:	3b 46 04             	cmp    0x4(%esi),%eax
  80361b:	74 df                	je     8035fc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80361d:	99                   	cltd   
  80361e:	c1 ea 1b             	shr    $0x1b,%edx
  803621:	01 d0                	add    %edx,%eax
  803623:	83 e0 1f             	and    $0x1f,%eax
  803626:	29 d0                	sub    %edx,%eax
  803628:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80362d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803630:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  803633:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803636:	83 c3 01             	add    $0x1,%ebx
  803639:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80363c:	75 d8                	jne    803616 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80363e:	8b 45 10             	mov    0x10(%ebp),%eax
  803641:	eb 05                	jmp    803648 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803643:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803648:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80364b:	5b                   	pop    %ebx
  80364c:	5e                   	pop    %esi
  80364d:	5f                   	pop    %edi
  80364e:	5d                   	pop    %ebp
  80364f:	c3                   	ret    

00803650 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803650:	55                   	push   %ebp
  803651:	89 e5                	mov    %esp,%ebp
  803653:	56                   	push   %esi
  803654:	53                   	push   %ebx
  803655:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803658:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80365b:	50                   	push   %eax
  80365c:	e8 2a f4 ff ff       	call   802a8b <fd_alloc>
  803661:	83 c4 10             	add    $0x10,%esp
  803664:	89 c2                	mov    %eax,%edx
  803666:	85 c0                	test   %eax,%eax
  803668:	0f 88 2c 01 00 00    	js     80379a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80366e:	83 ec 04             	sub    $0x4,%esp
  803671:	68 07 04 00 00       	push   $0x407
  803676:	ff 75 f4             	pushl  -0xc(%ebp)
  803679:	6a 00                	push   $0x0
  80367b:	e8 61 ed ff ff       	call   8023e1 <sys_page_alloc>
  803680:	83 c4 10             	add    $0x10,%esp
  803683:	89 c2                	mov    %eax,%edx
  803685:	85 c0                	test   %eax,%eax
  803687:	0f 88 0d 01 00 00    	js     80379a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80368d:	83 ec 0c             	sub    $0xc,%esp
  803690:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803693:	50                   	push   %eax
  803694:	e8 f2 f3 ff ff       	call   802a8b <fd_alloc>
  803699:	89 c3                	mov    %eax,%ebx
  80369b:	83 c4 10             	add    $0x10,%esp
  80369e:	85 c0                	test   %eax,%eax
  8036a0:	0f 88 e2 00 00 00    	js     803788 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8036a6:	83 ec 04             	sub    $0x4,%esp
  8036a9:	68 07 04 00 00       	push   $0x407
  8036ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8036b1:	6a 00                	push   $0x0
  8036b3:	e8 29 ed ff ff       	call   8023e1 <sys_page_alloc>
  8036b8:	89 c3                	mov    %eax,%ebx
  8036ba:	83 c4 10             	add    $0x10,%esp
  8036bd:	85 c0                	test   %eax,%eax
  8036bf:	0f 88 c3 00 00 00    	js     803788 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8036c5:	83 ec 0c             	sub    $0xc,%esp
  8036c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8036cb:	e8 a4 f3 ff ff       	call   802a74 <fd2data>
  8036d0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8036d2:	83 c4 0c             	add    $0xc,%esp
  8036d5:	68 07 04 00 00       	push   $0x407
  8036da:	50                   	push   %eax
  8036db:	6a 00                	push   $0x0
  8036dd:	e8 ff ec ff ff       	call   8023e1 <sys_page_alloc>
  8036e2:	89 c3                	mov    %eax,%ebx
  8036e4:	83 c4 10             	add    $0x10,%esp
  8036e7:	85 c0                	test   %eax,%eax
  8036e9:	0f 88 89 00 00 00    	js     803778 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8036ef:	83 ec 0c             	sub    $0xc,%esp
  8036f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8036f5:	e8 7a f3 ff ff       	call   802a74 <fd2data>
  8036fa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803701:	50                   	push   %eax
  803702:	6a 00                	push   $0x0
  803704:	56                   	push   %esi
  803705:	6a 00                	push   $0x0
  803707:	e8 18 ed ff ff       	call   802424 <sys_page_map>
  80370c:	89 c3                	mov    %eax,%ebx
  80370e:	83 c4 20             	add    $0x20,%esp
  803711:	85 c0                	test   %eax,%eax
  803713:	78 55                	js     80376a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803715:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80371b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80371e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803720:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803723:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80372a:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803730:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803733:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803738:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80373f:	83 ec 0c             	sub    $0xc,%esp
  803742:	ff 75 f4             	pushl  -0xc(%ebp)
  803745:	e8 1a f3 ff ff       	call   802a64 <fd2num>
  80374a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80374d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80374f:	83 c4 04             	add    $0x4,%esp
  803752:	ff 75 f0             	pushl  -0x10(%ebp)
  803755:	e8 0a f3 ff ff       	call   802a64 <fd2num>
  80375a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80375d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803760:	83 c4 10             	add    $0x10,%esp
  803763:	ba 00 00 00 00       	mov    $0x0,%edx
  803768:	eb 30                	jmp    80379a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80376a:	83 ec 08             	sub    $0x8,%esp
  80376d:	56                   	push   %esi
  80376e:	6a 00                	push   $0x0
  803770:	e8 f1 ec ff ff       	call   802466 <sys_page_unmap>
  803775:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  803778:	83 ec 08             	sub    $0x8,%esp
  80377b:	ff 75 f0             	pushl  -0x10(%ebp)
  80377e:	6a 00                	push   $0x0
  803780:	e8 e1 ec ff ff       	call   802466 <sys_page_unmap>
  803785:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  803788:	83 ec 08             	sub    $0x8,%esp
  80378b:	ff 75 f4             	pushl  -0xc(%ebp)
  80378e:	6a 00                	push   $0x0
  803790:	e8 d1 ec ff ff       	call   802466 <sys_page_unmap>
  803795:	83 c4 10             	add    $0x10,%esp
  803798:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80379a:	89 d0                	mov    %edx,%eax
  80379c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80379f:	5b                   	pop    %ebx
  8037a0:	5e                   	pop    %esi
  8037a1:	5d                   	pop    %ebp
  8037a2:	c3                   	ret    

008037a3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8037a3:	55                   	push   %ebp
  8037a4:	89 e5                	mov    %esp,%ebp
  8037a6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8037a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8037ac:	50                   	push   %eax
  8037ad:	ff 75 08             	pushl  0x8(%ebp)
  8037b0:	e8 25 f3 ff ff       	call   802ada <fd_lookup>
  8037b5:	83 c4 10             	add    $0x10,%esp
  8037b8:	85 c0                	test   %eax,%eax
  8037ba:	78 18                	js     8037d4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8037bc:	83 ec 0c             	sub    $0xc,%esp
  8037bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8037c2:	e8 ad f2 ff ff       	call   802a74 <fd2data>
	return _pipeisclosed(fd, p);
  8037c7:	89 c2                	mov    %eax,%edx
  8037c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037cc:	e8 21 fd ff ff       	call   8034f2 <_pipeisclosed>
  8037d1:	83 c4 10             	add    $0x10,%esp
}
  8037d4:	c9                   	leave  
  8037d5:	c3                   	ret    

008037d6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8037d6:	55                   	push   %ebp
  8037d7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8037d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8037de:	5d                   	pop    %ebp
  8037df:	c3                   	ret    

008037e0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8037e0:	55                   	push   %ebp
  8037e1:	89 e5                	mov    %esp,%ebp
  8037e3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8037e6:	68 d4 46 80 00       	push   $0x8046d4
  8037eb:	ff 75 0c             	pushl  0xc(%ebp)
  8037ee:	e8 eb e7 ff ff       	call   801fde <strcpy>
	return 0;
}
  8037f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8037f8:	c9                   	leave  
  8037f9:	c3                   	ret    

008037fa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8037fa:	55                   	push   %ebp
  8037fb:	89 e5                	mov    %esp,%ebp
  8037fd:	57                   	push   %edi
  8037fe:	56                   	push   %esi
  8037ff:	53                   	push   %ebx
  803800:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803806:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80380b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803811:	eb 2d                	jmp    803840 <devcons_write+0x46>
		m = n - tot;
  803813:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803816:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  803818:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80381b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  803820:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803823:	83 ec 04             	sub    $0x4,%esp
  803826:	53                   	push   %ebx
  803827:	03 45 0c             	add    0xc(%ebp),%eax
  80382a:	50                   	push   %eax
  80382b:	57                   	push   %edi
  80382c:	e8 3f e9 ff ff       	call   802170 <memmove>
		sys_cputs(buf, m);
  803831:	83 c4 08             	add    $0x8,%esp
  803834:	53                   	push   %ebx
  803835:	57                   	push   %edi
  803836:	e8 ea ea ff ff       	call   802325 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80383b:	01 de                	add    %ebx,%esi
  80383d:	83 c4 10             	add    $0x10,%esp
  803840:	89 f0                	mov    %esi,%eax
  803842:	3b 75 10             	cmp    0x10(%ebp),%esi
  803845:	72 cc                	jb     803813 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803847:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80384a:	5b                   	pop    %ebx
  80384b:	5e                   	pop    %esi
  80384c:	5f                   	pop    %edi
  80384d:	5d                   	pop    %ebp
  80384e:	c3                   	ret    

0080384f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80384f:	55                   	push   %ebp
  803850:	89 e5                	mov    %esp,%ebp
  803852:	83 ec 08             	sub    $0x8,%esp
  803855:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80385a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80385e:	74 2a                	je     80388a <devcons_read+0x3b>
  803860:	eb 05                	jmp    803867 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  803862:	e8 5b eb ff ff       	call   8023c2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  803867:	e8 d7 ea ff ff       	call   802343 <sys_cgetc>
  80386c:	85 c0                	test   %eax,%eax
  80386e:	74 f2                	je     803862 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  803870:	85 c0                	test   %eax,%eax
  803872:	78 16                	js     80388a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  803874:	83 f8 04             	cmp    $0x4,%eax
  803877:	74 0c                	je     803885 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  803879:	8b 55 0c             	mov    0xc(%ebp),%edx
  80387c:	88 02                	mov    %al,(%edx)
	return 1;
  80387e:	b8 01 00 00 00       	mov    $0x1,%eax
  803883:	eb 05                	jmp    80388a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  803885:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80388a:	c9                   	leave  
  80388b:	c3                   	ret    

0080388c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80388c:	55                   	push   %ebp
  80388d:	89 e5                	mov    %esp,%ebp
  80388f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  803892:	8b 45 08             	mov    0x8(%ebp),%eax
  803895:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803898:	6a 01                	push   $0x1
  80389a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80389d:	50                   	push   %eax
  80389e:	e8 82 ea ff ff       	call   802325 <sys_cputs>
}
  8038a3:	83 c4 10             	add    $0x10,%esp
  8038a6:	c9                   	leave  
  8038a7:	c3                   	ret    

008038a8 <getchar>:

int
getchar(void)
{
  8038a8:	55                   	push   %ebp
  8038a9:	89 e5                	mov    %esp,%ebp
  8038ab:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8038ae:	6a 01                	push   $0x1
  8038b0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8038b3:	50                   	push   %eax
  8038b4:	6a 00                	push   $0x0
  8038b6:	e8 85 f4 ff ff       	call   802d40 <read>
	if (r < 0)
  8038bb:	83 c4 10             	add    $0x10,%esp
  8038be:	85 c0                	test   %eax,%eax
  8038c0:	78 0f                	js     8038d1 <getchar+0x29>
		return r;
	if (r < 1)
  8038c2:	85 c0                	test   %eax,%eax
  8038c4:	7e 06                	jle    8038cc <getchar+0x24>
		return -E_EOF;
	return c;
  8038c6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8038ca:	eb 05                	jmp    8038d1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8038cc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8038d1:	c9                   	leave  
  8038d2:	c3                   	ret    

008038d3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8038d3:	55                   	push   %ebp
  8038d4:	89 e5                	mov    %esp,%ebp
  8038d6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8038d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8038dc:	50                   	push   %eax
  8038dd:	ff 75 08             	pushl  0x8(%ebp)
  8038e0:	e8 f5 f1 ff ff       	call   802ada <fd_lookup>
  8038e5:	83 c4 10             	add    $0x10,%esp
  8038e8:	85 c0                	test   %eax,%eax
  8038ea:	78 11                	js     8038fd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8038ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8038ef:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  8038f5:	39 10                	cmp    %edx,(%eax)
  8038f7:	0f 94 c0             	sete   %al
  8038fa:	0f b6 c0             	movzbl %al,%eax
}
  8038fd:	c9                   	leave  
  8038fe:	c3                   	ret    

008038ff <opencons>:

int
opencons(void)
{
  8038ff:	55                   	push   %ebp
  803900:	89 e5                	mov    %esp,%ebp
  803902:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803905:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803908:	50                   	push   %eax
  803909:	e8 7d f1 ff ff       	call   802a8b <fd_alloc>
  80390e:	83 c4 10             	add    $0x10,%esp
		return r;
  803911:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803913:	85 c0                	test   %eax,%eax
  803915:	78 3e                	js     803955 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803917:	83 ec 04             	sub    $0x4,%esp
  80391a:	68 07 04 00 00       	push   $0x407
  80391f:	ff 75 f4             	pushl  -0xc(%ebp)
  803922:	6a 00                	push   $0x0
  803924:	e8 b8 ea ff ff       	call   8023e1 <sys_page_alloc>
  803929:	83 c4 10             	add    $0x10,%esp
		return r;
  80392c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80392e:	85 c0                	test   %eax,%eax
  803930:	78 23                	js     803955 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803932:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803938:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80393b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80393d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803940:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803947:	83 ec 0c             	sub    $0xc,%esp
  80394a:	50                   	push   %eax
  80394b:	e8 14 f1 ff ff       	call   802a64 <fd2num>
  803950:	89 c2                	mov    %eax,%edx
  803952:	83 c4 10             	add    $0x10,%esp
}
  803955:	89 d0                	mov    %edx,%eax
  803957:	c9                   	leave  
  803958:	c3                   	ret    
  803959:	66 90                	xchg   %ax,%ax
  80395b:	66 90                	xchg   %ax,%ax
  80395d:	66 90                	xchg   %ax,%ax
  80395f:	90                   	nop

00803960 <__udivdi3>:
  803960:	55                   	push   %ebp
  803961:	57                   	push   %edi
  803962:	56                   	push   %esi
  803963:	53                   	push   %ebx
  803964:	83 ec 1c             	sub    $0x1c,%esp
  803967:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80396b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80396f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803973:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803977:	85 f6                	test   %esi,%esi
  803979:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80397d:	89 ca                	mov    %ecx,%edx
  80397f:	89 f8                	mov    %edi,%eax
  803981:	75 3d                	jne    8039c0 <__udivdi3+0x60>
  803983:	39 cf                	cmp    %ecx,%edi
  803985:	0f 87 c5 00 00 00    	ja     803a50 <__udivdi3+0xf0>
  80398b:	85 ff                	test   %edi,%edi
  80398d:	89 fd                	mov    %edi,%ebp
  80398f:	75 0b                	jne    80399c <__udivdi3+0x3c>
  803991:	b8 01 00 00 00       	mov    $0x1,%eax
  803996:	31 d2                	xor    %edx,%edx
  803998:	f7 f7                	div    %edi
  80399a:	89 c5                	mov    %eax,%ebp
  80399c:	89 c8                	mov    %ecx,%eax
  80399e:	31 d2                	xor    %edx,%edx
  8039a0:	f7 f5                	div    %ebp
  8039a2:	89 c1                	mov    %eax,%ecx
  8039a4:	89 d8                	mov    %ebx,%eax
  8039a6:	89 cf                	mov    %ecx,%edi
  8039a8:	f7 f5                	div    %ebp
  8039aa:	89 c3                	mov    %eax,%ebx
  8039ac:	89 d8                	mov    %ebx,%eax
  8039ae:	89 fa                	mov    %edi,%edx
  8039b0:	83 c4 1c             	add    $0x1c,%esp
  8039b3:	5b                   	pop    %ebx
  8039b4:	5e                   	pop    %esi
  8039b5:	5f                   	pop    %edi
  8039b6:	5d                   	pop    %ebp
  8039b7:	c3                   	ret    
  8039b8:	90                   	nop
  8039b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8039c0:	39 ce                	cmp    %ecx,%esi
  8039c2:	77 74                	ja     803a38 <__udivdi3+0xd8>
  8039c4:	0f bd fe             	bsr    %esi,%edi
  8039c7:	83 f7 1f             	xor    $0x1f,%edi
  8039ca:	0f 84 98 00 00 00    	je     803a68 <__udivdi3+0x108>
  8039d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8039d5:	89 f9                	mov    %edi,%ecx
  8039d7:	89 c5                	mov    %eax,%ebp
  8039d9:	29 fb                	sub    %edi,%ebx
  8039db:	d3 e6                	shl    %cl,%esi
  8039dd:	89 d9                	mov    %ebx,%ecx
  8039df:	d3 ed                	shr    %cl,%ebp
  8039e1:	89 f9                	mov    %edi,%ecx
  8039e3:	d3 e0                	shl    %cl,%eax
  8039e5:	09 ee                	or     %ebp,%esi
  8039e7:	89 d9                	mov    %ebx,%ecx
  8039e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8039ed:	89 d5                	mov    %edx,%ebp
  8039ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8039f3:	d3 ed                	shr    %cl,%ebp
  8039f5:	89 f9                	mov    %edi,%ecx
  8039f7:	d3 e2                	shl    %cl,%edx
  8039f9:	89 d9                	mov    %ebx,%ecx
  8039fb:	d3 e8                	shr    %cl,%eax
  8039fd:	09 c2                	or     %eax,%edx
  8039ff:	89 d0                	mov    %edx,%eax
  803a01:	89 ea                	mov    %ebp,%edx
  803a03:	f7 f6                	div    %esi
  803a05:	89 d5                	mov    %edx,%ebp
  803a07:	89 c3                	mov    %eax,%ebx
  803a09:	f7 64 24 0c          	mull   0xc(%esp)
  803a0d:	39 d5                	cmp    %edx,%ebp
  803a0f:	72 10                	jb     803a21 <__udivdi3+0xc1>
  803a11:	8b 74 24 08          	mov    0x8(%esp),%esi
  803a15:	89 f9                	mov    %edi,%ecx
  803a17:	d3 e6                	shl    %cl,%esi
  803a19:	39 c6                	cmp    %eax,%esi
  803a1b:	73 07                	jae    803a24 <__udivdi3+0xc4>
  803a1d:	39 d5                	cmp    %edx,%ebp
  803a1f:	75 03                	jne    803a24 <__udivdi3+0xc4>
  803a21:	83 eb 01             	sub    $0x1,%ebx
  803a24:	31 ff                	xor    %edi,%edi
  803a26:	89 d8                	mov    %ebx,%eax
  803a28:	89 fa                	mov    %edi,%edx
  803a2a:	83 c4 1c             	add    $0x1c,%esp
  803a2d:	5b                   	pop    %ebx
  803a2e:	5e                   	pop    %esi
  803a2f:	5f                   	pop    %edi
  803a30:	5d                   	pop    %ebp
  803a31:	c3                   	ret    
  803a32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803a38:	31 ff                	xor    %edi,%edi
  803a3a:	31 db                	xor    %ebx,%ebx
  803a3c:	89 d8                	mov    %ebx,%eax
  803a3e:	89 fa                	mov    %edi,%edx
  803a40:	83 c4 1c             	add    $0x1c,%esp
  803a43:	5b                   	pop    %ebx
  803a44:	5e                   	pop    %esi
  803a45:	5f                   	pop    %edi
  803a46:	5d                   	pop    %ebp
  803a47:	c3                   	ret    
  803a48:	90                   	nop
  803a49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803a50:	89 d8                	mov    %ebx,%eax
  803a52:	f7 f7                	div    %edi
  803a54:	31 ff                	xor    %edi,%edi
  803a56:	89 c3                	mov    %eax,%ebx
  803a58:	89 d8                	mov    %ebx,%eax
  803a5a:	89 fa                	mov    %edi,%edx
  803a5c:	83 c4 1c             	add    $0x1c,%esp
  803a5f:	5b                   	pop    %ebx
  803a60:	5e                   	pop    %esi
  803a61:	5f                   	pop    %edi
  803a62:	5d                   	pop    %ebp
  803a63:	c3                   	ret    
  803a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803a68:	39 ce                	cmp    %ecx,%esi
  803a6a:	72 0c                	jb     803a78 <__udivdi3+0x118>
  803a6c:	31 db                	xor    %ebx,%ebx
  803a6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803a72:	0f 87 34 ff ff ff    	ja     8039ac <__udivdi3+0x4c>
  803a78:	bb 01 00 00 00       	mov    $0x1,%ebx
  803a7d:	e9 2a ff ff ff       	jmp    8039ac <__udivdi3+0x4c>
  803a82:	66 90                	xchg   %ax,%ax
  803a84:	66 90                	xchg   %ax,%ax
  803a86:	66 90                	xchg   %ax,%ax
  803a88:	66 90                	xchg   %ax,%ax
  803a8a:	66 90                	xchg   %ax,%ax
  803a8c:	66 90                	xchg   %ax,%ax
  803a8e:	66 90                	xchg   %ax,%ax

00803a90 <__umoddi3>:
  803a90:	55                   	push   %ebp
  803a91:	57                   	push   %edi
  803a92:	56                   	push   %esi
  803a93:	53                   	push   %ebx
  803a94:	83 ec 1c             	sub    $0x1c,%esp
  803a97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  803a9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  803a9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803aa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803aa7:	85 d2                	test   %edx,%edx
  803aa9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803aad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803ab1:	89 f3                	mov    %esi,%ebx
  803ab3:	89 3c 24             	mov    %edi,(%esp)
  803ab6:	89 74 24 04          	mov    %esi,0x4(%esp)
  803aba:	75 1c                	jne    803ad8 <__umoddi3+0x48>
  803abc:	39 f7                	cmp    %esi,%edi
  803abe:	76 50                	jbe    803b10 <__umoddi3+0x80>
  803ac0:	89 c8                	mov    %ecx,%eax
  803ac2:	89 f2                	mov    %esi,%edx
  803ac4:	f7 f7                	div    %edi
  803ac6:	89 d0                	mov    %edx,%eax
  803ac8:	31 d2                	xor    %edx,%edx
  803aca:	83 c4 1c             	add    $0x1c,%esp
  803acd:	5b                   	pop    %ebx
  803ace:	5e                   	pop    %esi
  803acf:	5f                   	pop    %edi
  803ad0:	5d                   	pop    %ebp
  803ad1:	c3                   	ret    
  803ad2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803ad8:	39 f2                	cmp    %esi,%edx
  803ada:	89 d0                	mov    %edx,%eax
  803adc:	77 52                	ja     803b30 <__umoddi3+0xa0>
  803ade:	0f bd ea             	bsr    %edx,%ebp
  803ae1:	83 f5 1f             	xor    $0x1f,%ebp
  803ae4:	75 5a                	jne    803b40 <__umoddi3+0xb0>
  803ae6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  803aea:	0f 82 e0 00 00 00    	jb     803bd0 <__umoddi3+0x140>
  803af0:	39 0c 24             	cmp    %ecx,(%esp)
  803af3:	0f 86 d7 00 00 00    	jbe    803bd0 <__umoddi3+0x140>
  803af9:	8b 44 24 08          	mov    0x8(%esp),%eax
  803afd:	8b 54 24 04          	mov    0x4(%esp),%edx
  803b01:	83 c4 1c             	add    $0x1c,%esp
  803b04:	5b                   	pop    %ebx
  803b05:	5e                   	pop    %esi
  803b06:	5f                   	pop    %edi
  803b07:	5d                   	pop    %ebp
  803b08:	c3                   	ret    
  803b09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803b10:	85 ff                	test   %edi,%edi
  803b12:	89 fd                	mov    %edi,%ebp
  803b14:	75 0b                	jne    803b21 <__umoddi3+0x91>
  803b16:	b8 01 00 00 00       	mov    $0x1,%eax
  803b1b:	31 d2                	xor    %edx,%edx
  803b1d:	f7 f7                	div    %edi
  803b1f:	89 c5                	mov    %eax,%ebp
  803b21:	89 f0                	mov    %esi,%eax
  803b23:	31 d2                	xor    %edx,%edx
  803b25:	f7 f5                	div    %ebp
  803b27:	89 c8                	mov    %ecx,%eax
  803b29:	f7 f5                	div    %ebp
  803b2b:	89 d0                	mov    %edx,%eax
  803b2d:	eb 99                	jmp    803ac8 <__umoddi3+0x38>
  803b2f:	90                   	nop
  803b30:	89 c8                	mov    %ecx,%eax
  803b32:	89 f2                	mov    %esi,%edx
  803b34:	83 c4 1c             	add    $0x1c,%esp
  803b37:	5b                   	pop    %ebx
  803b38:	5e                   	pop    %esi
  803b39:	5f                   	pop    %edi
  803b3a:	5d                   	pop    %ebp
  803b3b:	c3                   	ret    
  803b3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803b40:	8b 34 24             	mov    (%esp),%esi
  803b43:	bf 20 00 00 00       	mov    $0x20,%edi
  803b48:	89 e9                	mov    %ebp,%ecx
  803b4a:	29 ef                	sub    %ebp,%edi
  803b4c:	d3 e0                	shl    %cl,%eax
  803b4e:	89 f9                	mov    %edi,%ecx
  803b50:	89 f2                	mov    %esi,%edx
  803b52:	d3 ea                	shr    %cl,%edx
  803b54:	89 e9                	mov    %ebp,%ecx
  803b56:	09 c2                	or     %eax,%edx
  803b58:	89 d8                	mov    %ebx,%eax
  803b5a:	89 14 24             	mov    %edx,(%esp)
  803b5d:	89 f2                	mov    %esi,%edx
  803b5f:	d3 e2                	shl    %cl,%edx
  803b61:	89 f9                	mov    %edi,%ecx
  803b63:	89 54 24 04          	mov    %edx,0x4(%esp)
  803b67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803b6b:	d3 e8                	shr    %cl,%eax
  803b6d:	89 e9                	mov    %ebp,%ecx
  803b6f:	89 c6                	mov    %eax,%esi
  803b71:	d3 e3                	shl    %cl,%ebx
  803b73:	89 f9                	mov    %edi,%ecx
  803b75:	89 d0                	mov    %edx,%eax
  803b77:	d3 e8                	shr    %cl,%eax
  803b79:	89 e9                	mov    %ebp,%ecx
  803b7b:	09 d8                	or     %ebx,%eax
  803b7d:	89 d3                	mov    %edx,%ebx
  803b7f:	89 f2                	mov    %esi,%edx
  803b81:	f7 34 24             	divl   (%esp)
  803b84:	89 d6                	mov    %edx,%esi
  803b86:	d3 e3                	shl    %cl,%ebx
  803b88:	f7 64 24 04          	mull   0x4(%esp)
  803b8c:	39 d6                	cmp    %edx,%esi
  803b8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803b92:	89 d1                	mov    %edx,%ecx
  803b94:	89 c3                	mov    %eax,%ebx
  803b96:	72 08                	jb     803ba0 <__umoddi3+0x110>
  803b98:	75 11                	jne    803bab <__umoddi3+0x11b>
  803b9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  803b9e:	73 0b                	jae    803bab <__umoddi3+0x11b>
  803ba0:	2b 44 24 04          	sub    0x4(%esp),%eax
  803ba4:	1b 14 24             	sbb    (%esp),%edx
  803ba7:	89 d1                	mov    %edx,%ecx
  803ba9:	89 c3                	mov    %eax,%ebx
  803bab:	8b 54 24 08          	mov    0x8(%esp),%edx
  803baf:	29 da                	sub    %ebx,%edx
  803bb1:	19 ce                	sbb    %ecx,%esi
  803bb3:	89 f9                	mov    %edi,%ecx
  803bb5:	89 f0                	mov    %esi,%eax
  803bb7:	d3 e0                	shl    %cl,%eax
  803bb9:	89 e9                	mov    %ebp,%ecx
  803bbb:	d3 ea                	shr    %cl,%edx
  803bbd:	89 e9                	mov    %ebp,%ecx
  803bbf:	d3 ee                	shr    %cl,%esi
  803bc1:	09 d0                	or     %edx,%eax
  803bc3:	89 f2                	mov    %esi,%edx
  803bc5:	83 c4 1c             	add    $0x1c,%esp
  803bc8:	5b                   	pop    %ebx
  803bc9:	5e                   	pop    %esi
  803bca:	5f                   	pop    %edi
  803bcb:	5d                   	pop    %ebp
  803bcc:	c3                   	ret    
  803bcd:	8d 76 00             	lea    0x0(%esi),%esi
  803bd0:	29 f9                	sub    %edi,%ecx
  803bd2:	19 d6                	sbb    %edx,%esi
  803bd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  803bd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803bdc:	e9 18 ff ff ff       	jmp    803af9 <__umoddi3+0x69>
