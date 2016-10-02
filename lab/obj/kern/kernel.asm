
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 80 11 f0       	mov    $0xf0118000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 50 4c 17 f0       	mov    $0xf0174c50,%eax
f010004b:	2d 26 3d 17 f0       	sub    $0xf0173d26,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 26 3d 17 f0       	push   $0xf0173d26
f0100058:	e8 b8 3d 00 00       	call   f0103e15 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 9d 04 00 00       	call   f01004ff <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 c0 42 10 f0       	push   $0xf01042c0
f010006f:	e8 2d 2f 00 00       	call   f0102fa1 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 2c 10 00 00       	call   f01010a5 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 1a 29 00 00       	call   f0102998 <env_init>
	trap_init();
f010007e:	e8 8f 2f 00 00       	call   f0103012 <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100083:	83 c4 08             	add    $0x8,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 56 a3 11 f0       	push   $0xf011a356
f010008d:	e8 f1 2a 00 00       	call   f0102b83 <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100092:	83 c4 04             	add    $0x4,%esp
f0100095:	ff 35 88 3f 17 f0    	pushl  0xf0173f88
f010009b:	e8 34 2e 00 00       	call   f0102ed4 <env_run>

f01000a0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000a0:	55                   	push   %ebp
f01000a1:	89 e5                	mov    %esp,%ebp
f01000a3:	56                   	push   %esi
f01000a4:	53                   	push   %ebx
f01000a5:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000a8:	83 3d 40 4c 17 f0 00 	cmpl   $0x0,0xf0174c40
f01000af:	75 37                	jne    f01000e8 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000b1:	89 35 40 4c 17 f0    	mov    %esi,0xf0174c40

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000b7:	fa                   	cli    
f01000b8:	fc                   	cld    

	va_start(ap, fmt);
f01000b9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000bc:	83 ec 04             	sub    $0x4,%esp
f01000bf:	ff 75 0c             	pushl  0xc(%ebp)
f01000c2:	ff 75 08             	pushl  0x8(%ebp)
f01000c5:	68 db 42 10 f0       	push   $0xf01042db
f01000ca:	e8 d2 2e 00 00       	call   f0102fa1 <cprintf>
	vcprintf(fmt, ap);
f01000cf:	83 c4 08             	add    $0x8,%esp
f01000d2:	53                   	push   %ebx
f01000d3:	56                   	push   %esi
f01000d4:	e8 a2 2e 00 00       	call   f0102f7b <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 f5 4a 10 f0 	movl   $0xf0104af5,(%esp)
f01000e0:	e8 bc 2e 00 00       	call   f0102fa1 <cprintf>
	va_end(ap);
f01000e5:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e8:	83 ec 0c             	sub    $0xc,%esp
f01000eb:	6a 00                	push   $0x0
f01000ed:	e8 b9 06 00 00       	call   f01007ab <monitor>
f01000f2:	83 c4 10             	add    $0x10,%esp
f01000f5:	eb f1                	jmp    f01000e8 <_panic+0x48>

f01000f7 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f7:	55                   	push   %ebp
f01000f8:	89 e5                	mov    %esp,%ebp
f01000fa:	53                   	push   %ebx
f01000fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000fe:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100101:	ff 75 0c             	pushl  0xc(%ebp)
f0100104:	ff 75 08             	pushl  0x8(%ebp)
f0100107:	68 f3 42 10 f0       	push   $0xf01042f3
f010010c:	e8 90 2e 00 00       	call   f0102fa1 <cprintf>
	vcprintf(fmt, ap);
f0100111:	83 c4 08             	add    $0x8,%esp
f0100114:	53                   	push   %ebx
f0100115:	ff 75 10             	pushl  0x10(%ebp)
f0100118:	e8 5e 2e 00 00       	call   f0102f7b <vcprintf>
	cprintf("\n");
f010011d:	c7 04 24 f5 4a 10 f0 	movl   $0xf0104af5,(%esp)
f0100124:	e8 78 2e 00 00       	call   f0102fa1 <cprintf>
	va_end(ap);
}
f0100129:	83 c4 10             	add    $0x10,%esp
f010012c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010012f:	c9                   	leave  
f0100130:	c3                   	ret    

f0100131 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100131:	55                   	push   %ebp
f0100132:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100134:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100139:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010013a:	a8 01                	test   $0x1,%al
f010013c:	74 0b                	je     f0100149 <serial_proc_data+0x18>
f010013e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100143:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100144:	0f b6 c0             	movzbl %al,%eax
f0100147:	eb 05                	jmp    f010014e <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100149:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010014e:	5d                   	pop    %ebp
f010014f:	c3                   	ret    

f0100150 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100150:	55                   	push   %ebp
f0100151:	89 e5                	mov    %esp,%ebp
f0100153:	53                   	push   %ebx
f0100154:	83 ec 04             	sub    $0x4,%esp
f0100157:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100159:	eb 2b                	jmp    f0100186 <cons_intr+0x36>
		if (c == 0)
f010015b:	85 c0                	test   %eax,%eax
f010015d:	74 27                	je     f0100186 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010015f:	8b 0d 64 3f 17 f0    	mov    0xf0173f64,%ecx
f0100165:	8d 51 01             	lea    0x1(%ecx),%edx
f0100168:	89 15 64 3f 17 f0    	mov    %edx,0xf0173f64
f010016e:	88 81 60 3d 17 f0    	mov    %al,-0xfe8c2a0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100174:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010017a:	75 0a                	jne    f0100186 <cons_intr+0x36>
			cons.wpos = 0;
f010017c:	c7 05 64 3f 17 f0 00 	movl   $0x0,0xf0173f64
f0100183:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100186:	ff d3                	call   *%ebx
f0100188:	83 f8 ff             	cmp    $0xffffffff,%eax
f010018b:	75 ce                	jne    f010015b <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010018d:	83 c4 04             	add    $0x4,%esp
f0100190:	5b                   	pop    %ebx
f0100191:	5d                   	pop    %ebp
f0100192:	c3                   	ret    

f0100193 <kbd_proc_data>:
f0100193:	ba 64 00 00 00       	mov    $0x64,%edx
f0100198:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100199:	a8 01                	test   $0x1,%al
f010019b:	0f 84 f0 00 00 00    	je     f0100291 <kbd_proc_data+0xfe>
f01001a1:	ba 60 00 00 00       	mov    $0x60,%edx
f01001a6:	ec                   	in     (%dx),%al
f01001a7:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001a9:	3c e0                	cmp    $0xe0,%al
f01001ab:	75 0d                	jne    f01001ba <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01001ad:	83 0d 40 3d 17 f0 40 	orl    $0x40,0xf0173d40
		return 0;
f01001b4:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001b9:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001ba:	55                   	push   %ebp
f01001bb:	89 e5                	mov    %esp,%ebp
f01001bd:	53                   	push   %ebx
f01001be:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001c1:	84 c0                	test   %al,%al
f01001c3:	79 36                	jns    f01001fb <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001c5:	8b 0d 40 3d 17 f0    	mov    0xf0173d40,%ecx
f01001cb:	89 cb                	mov    %ecx,%ebx
f01001cd:	83 e3 40             	and    $0x40,%ebx
f01001d0:	83 e0 7f             	and    $0x7f,%eax
f01001d3:	85 db                	test   %ebx,%ebx
f01001d5:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001d8:	0f b6 d2             	movzbl %dl,%edx
f01001db:	0f b6 82 60 44 10 f0 	movzbl -0xfefbba0(%edx),%eax
f01001e2:	83 c8 40             	or     $0x40,%eax
f01001e5:	0f b6 c0             	movzbl %al,%eax
f01001e8:	f7 d0                	not    %eax
f01001ea:	21 c8                	and    %ecx,%eax
f01001ec:	a3 40 3d 17 f0       	mov    %eax,0xf0173d40
		return 0;
f01001f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01001f6:	e9 9e 00 00 00       	jmp    f0100299 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f01001fb:	8b 0d 40 3d 17 f0    	mov    0xf0173d40,%ecx
f0100201:	f6 c1 40             	test   $0x40,%cl
f0100204:	74 0e                	je     f0100214 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100206:	83 c8 80             	or     $0xffffff80,%eax
f0100209:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010020b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010020e:	89 0d 40 3d 17 f0    	mov    %ecx,0xf0173d40
	}

	shift |= shiftcode[data];
f0100214:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100217:	0f b6 82 60 44 10 f0 	movzbl -0xfefbba0(%edx),%eax
f010021e:	0b 05 40 3d 17 f0    	or     0xf0173d40,%eax
f0100224:	0f b6 8a 60 43 10 f0 	movzbl -0xfefbca0(%edx),%ecx
f010022b:	31 c8                	xor    %ecx,%eax
f010022d:	a3 40 3d 17 f0       	mov    %eax,0xf0173d40

	c = charcode[shift & (CTL | SHIFT)][data];
f0100232:	89 c1                	mov    %eax,%ecx
f0100234:	83 e1 03             	and    $0x3,%ecx
f0100237:	8b 0c 8d 40 43 10 f0 	mov    -0xfefbcc0(,%ecx,4),%ecx
f010023e:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100242:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100245:	a8 08                	test   $0x8,%al
f0100247:	74 1b                	je     f0100264 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100249:	89 da                	mov    %ebx,%edx
f010024b:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010024e:	83 f9 19             	cmp    $0x19,%ecx
f0100251:	77 05                	ja     f0100258 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100253:	83 eb 20             	sub    $0x20,%ebx
f0100256:	eb 0c                	jmp    f0100264 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100258:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010025b:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010025e:	83 fa 19             	cmp    $0x19,%edx
f0100261:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100264:	f7 d0                	not    %eax
f0100266:	a8 06                	test   $0x6,%al
f0100268:	75 2d                	jne    f0100297 <kbd_proc_data+0x104>
f010026a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100270:	75 25                	jne    f0100297 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f0100272:	83 ec 0c             	sub    $0xc,%esp
f0100275:	68 0d 43 10 f0       	push   $0xf010430d
f010027a:	e8 22 2d 00 00       	call   f0102fa1 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010027f:	ba 92 00 00 00       	mov    $0x92,%edx
f0100284:	b8 03 00 00 00       	mov    $0x3,%eax
f0100289:	ee                   	out    %al,(%dx)
f010028a:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010028d:	89 d8                	mov    %ebx,%eax
f010028f:	eb 08                	jmp    f0100299 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100291:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100296:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100297:	89 d8                	mov    %ebx,%eax
}
f0100299:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010029c:	c9                   	leave  
f010029d:	c3                   	ret    

f010029e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010029e:	55                   	push   %ebp
f010029f:	89 e5                	mov    %esp,%ebp
f01002a1:	57                   	push   %edi
f01002a2:	56                   	push   %esi
f01002a3:	53                   	push   %ebx
f01002a4:	83 ec 1c             	sub    $0x1c,%esp
f01002a7:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002a9:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ae:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002b3:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002b8:	eb 09                	jmp    f01002c3 <cons_putc+0x25>
f01002ba:	89 ca                	mov    %ecx,%edx
f01002bc:	ec                   	in     (%dx),%al
f01002bd:	ec                   	in     (%dx),%al
f01002be:	ec                   	in     (%dx),%al
f01002bf:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002c0:	83 c3 01             	add    $0x1,%ebx
f01002c3:	89 f2                	mov    %esi,%edx
f01002c5:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002c6:	a8 20                	test   $0x20,%al
f01002c8:	75 08                	jne    f01002d2 <cons_putc+0x34>
f01002ca:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002d0:	7e e8                	jle    f01002ba <cons_putc+0x1c>
f01002d2:	89 f8                	mov    %edi,%eax
f01002d4:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002dc:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002dd:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e2:	be 79 03 00 00       	mov    $0x379,%esi
f01002e7:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002ec:	eb 09                	jmp    f01002f7 <cons_putc+0x59>
f01002ee:	89 ca                	mov    %ecx,%edx
f01002f0:	ec                   	in     (%dx),%al
f01002f1:	ec                   	in     (%dx),%al
f01002f2:	ec                   	in     (%dx),%al
f01002f3:	ec                   	in     (%dx),%al
f01002f4:	83 c3 01             	add    $0x1,%ebx
f01002f7:	89 f2                	mov    %esi,%edx
f01002f9:	ec                   	in     (%dx),%al
f01002fa:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100300:	7f 04                	jg     f0100306 <cons_putc+0x68>
f0100302:	84 c0                	test   %al,%al
f0100304:	79 e8                	jns    f01002ee <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100306:	ba 78 03 00 00       	mov    $0x378,%edx
f010030b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010030f:	ee                   	out    %al,(%dx)
f0100310:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100315:	b8 0d 00 00 00       	mov    $0xd,%eax
f010031a:	ee                   	out    %al,(%dx)
f010031b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100320:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100321:	89 fa                	mov    %edi,%edx
f0100323:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100329:	89 f8                	mov    %edi,%eax
f010032b:	80 cc 07             	or     $0x7,%ah
f010032e:	85 d2                	test   %edx,%edx
f0100330:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100333:	89 f8                	mov    %edi,%eax
f0100335:	0f b6 c0             	movzbl %al,%eax
f0100338:	83 f8 09             	cmp    $0x9,%eax
f010033b:	74 74                	je     f01003b1 <cons_putc+0x113>
f010033d:	83 f8 09             	cmp    $0x9,%eax
f0100340:	7f 0a                	jg     f010034c <cons_putc+0xae>
f0100342:	83 f8 08             	cmp    $0x8,%eax
f0100345:	74 14                	je     f010035b <cons_putc+0xbd>
f0100347:	e9 99 00 00 00       	jmp    f01003e5 <cons_putc+0x147>
f010034c:	83 f8 0a             	cmp    $0xa,%eax
f010034f:	74 3a                	je     f010038b <cons_putc+0xed>
f0100351:	83 f8 0d             	cmp    $0xd,%eax
f0100354:	74 3d                	je     f0100393 <cons_putc+0xf5>
f0100356:	e9 8a 00 00 00       	jmp    f01003e5 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f010035b:	0f b7 05 68 3f 17 f0 	movzwl 0xf0173f68,%eax
f0100362:	66 85 c0             	test   %ax,%ax
f0100365:	0f 84 e6 00 00 00    	je     f0100451 <cons_putc+0x1b3>
			crt_pos--;
f010036b:	83 e8 01             	sub    $0x1,%eax
f010036e:	66 a3 68 3f 17 f0    	mov    %ax,0xf0173f68
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100374:	0f b7 c0             	movzwl %ax,%eax
f0100377:	66 81 e7 00 ff       	and    $0xff00,%di
f010037c:	83 cf 20             	or     $0x20,%edi
f010037f:	8b 15 6c 3f 17 f0    	mov    0xf0173f6c,%edx
f0100385:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100389:	eb 78                	jmp    f0100403 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010038b:	66 83 05 68 3f 17 f0 	addw   $0x50,0xf0173f68
f0100392:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100393:	0f b7 05 68 3f 17 f0 	movzwl 0xf0173f68,%eax
f010039a:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003a0:	c1 e8 16             	shr    $0x16,%eax
f01003a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003a6:	c1 e0 04             	shl    $0x4,%eax
f01003a9:	66 a3 68 3f 17 f0    	mov    %ax,0xf0173f68
f01003af:	eb 52                	jmp    f0100403 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003b1:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b6:	e8 e3 fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003bb:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c0:	e8 d9 fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003c5:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ca:	e8 cf fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003cf:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d4:	e8 c5 fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003d9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003de:	e8 bb fe ff ff       	call   f010029e <cons_putc>
f01003e3:	eb 1e                	jmp    f0100403 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003e5:	0f b7 05 68 3f 17 f0 	movzwl 0xf0173f68,%eax
f01003ec:	8d 50 01             	lea    0x1(%eax),%edx
f01003ef:	66 89 15 68 3f 17 f0 	mov    %dx,0xf0173f68
f01003f6:	0f b7 c0             	movzwl %ax,%eax
f01003f9:	8b 15 6c 3f 17 f0    	mov    0xf0173f6c,%edx
f01003ff:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100403:	66 81 3d 68 3f 17 f0 	cmpw   $0x7cf,0xf0173f68
f010040a:	cf 07 
f010040c:	76 43                	jbe    f0100451 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010040e:	a1 6c 3f 17 f0       	mov    0xf0173f6c,%eax
f0100413:	83 ec 04             	sub    $0x4,%esp
f0100416:	68 00 0f 00 00       	push   $0xf00
f010041b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100421:	52                   	push   %edx
f0100422:	50                   	push   %eax
f0100423:	e8 3a 3a 00 00       	call   f0103e62 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100428:	8b 15 6c 3f 17 f0    	mov    0xf0173f6c,%edx
f010042e:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100434:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010043a:	83 c4 10             	add    $0x10,%esp
f010043d:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100442:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100445:	39 d0                	cmp    %edx,%eax
f0100447:	75 f4                	jne    f010043d <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100449:	66 83 2d 68 3f 17 f0 	subw   $0x50,0xf0173f68
f0100450:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100451:	8b 0d 70 3f 17 f0    	mov    0xf0173f70,%ecx
f0100457:	b8 0e 00 00 00       	mov    $0xe,%eax
f010045c:	89 ca                	mov    %ecx,%edx
f010045e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010045f:	0f b7 1d 68 3f 17 f0 	movzwl 0xf0173f68,%ebx
f0100466:	8d 71 01             	lea    0x1(%ecx),%esi
f0100469:	89 d8                	mov    %ebx,%eax
f010046b:	66 c1 e8 08          	shr    $0x8,%ax
f010046f:	89 f2                	mov    %esi,%edx
f0100471:	ee                   	out    %al,(%dx)
f0100472:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100477:	89 ca                	mov    %ecx,%edx
f0100479:	ee                   	out    %al,(%dx)
f010047a:	89 d8                	mov    %ebx,%eax
f010047c:	89 f2                	mov    %esi,%edx
f010047e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010047f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100482:	5b                   	pop    %ebx
f0100483:	5e                   	pop    %esi
f0100484:	5f                   	pop    %edi
f0100485:	5d                   	pop    %ebp
f0100486:	c3                   	ret    

f0100487 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100487:	80 3d 74 3f 17 f0 00 	cmpb   $0x0,0xf0173f74
f010048e:	74 11                	je     f01004a1 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100490:	55                   	push   %ebp
f0100491:	89 e5                	mov    %esp,%ebp
f0100493:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100496:	b8 31 01 10 f0       	mov    $0xf0100131,%eax
f010049b:	e8 b0 fc ff ff       	call   f0100150 <cons_intr>
}
f01004a0:	c9                   	leave  
f01004a1:	f3 c3                	repz ret 

f01004a3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004a3:	55                   	push   %ebp
f01004a4:	89 e5                	mov    %esp,%ebp
f01004a6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a9:	b8 93 01 10 f0       	mov    $0xf0100193,%eax
f01004ae:	e8 9d fc ff ff       	call   f0100150 <cons_intr>
}
f01004b3:	c9                   	leave  
f01004b4:	c3                   	ret    

f01004b5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004b5:	55                   	push   %ebp
f01004b6:	89 e5                	mov    %esp,%ebp
f01004b8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004bb:	e8 c7 ff ff ff       	call   f0100487 <serial_intr>
	kbd_intr();
f01004c0:	e8 de ff ff ff       	call   f01004a3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004c5:	a1 60 3f 17 f0       	mov    0xf0173f60,%eax
f01004ca:	3b 05 64 3f 17 f0    	cmp    0xf0173f64,%eax
f01004d0:	74 26                	je     f01004f8 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004d2:	8d 50 01             	lea    0x1(%eax),%edx
f01004d5:	89 15 60 3f 17 f0    	mov    %edx,0xf0173f60
f01004db:	0f b6 88 60 3d 17 f0 	movzbl -0xfe8c2a0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004e2:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004e4:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004ea:	75 11                	jne    f01004fd <cons_getc+0x48>
			cons.rpos = 0;
f01004ec:	c7 05 60 3f 17 f0 00 	movl   $0x0,0xf0173f60
f01004f3:	00 00 00 
f01004f6:	eb 05                	jmp    f01004fd <cons_getc+0x48>
		return c;
	}
	return 0;
f01004f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004fd:	c9                   	leave  
f01004fe:	c3                   	ret    

f01004ff <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004ff:	55                   	push   %ebp
f0100500:	89 e5                	mov    %esp,%ebp
f0100502:	57                   	push   %edi
f0100503:	56                   	push   %esi
f0100504:	53                   	push   %ebx
f0100505:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100508:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010050f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100516:	5a a5 
	if (*cp != 0xA55A) {
f0100518:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010051f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100523:	74 11                	je     f0100536 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100525:	c7 05 70 3f 17 f0 b4 	movl   $0x3b4,0xf0173f70
f010052c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010052f:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100534:	eb 16                	jmp    f010054c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100536:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010053d:	c7 05 70 3f 17 f0 d4 	movl   $0x3d4,0xf0173f70
f0100544:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100547:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010054c:	8b 3d 70 3f 17 f0    	mov    0xf0173f70,%edi
f0100552:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100557:	89 fa                	mov    %edi,%edx
f0100559:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010055a:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010055d:	89 da                	mov    %ebx,%edx
f010055f:	ec                   	in     (%dx),%al
f0100560:	0f b6 c8             	movzbl %al,%ecx
f0100563:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100566:	b8 0f 00 00 00       	mov    $0xf,%eax
f010056b:	89 fa                	mov    %edi,%edx
f010056d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056e:	89 da                	mov    %ebx,%edx
f0100570:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100571:	89 35 6c 3f 17 f0    	mov    %esi,0xf0173f6c
	crt_pos = pos;
f0100577:	0f b6 c0             	movzbl %al,%eax
f010057a:	09 c8                	or     %ecx,%eax
f010057c:	66 a3 68 3f 17 f0    	mov    %ax,0xf0173f68
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100582:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100587:	b8 00 00 00 00       	mov    $0x0,%eax
f010058c:	89 f2                	mov    %esi,%edx
f010058e:	ee                   	out    %al,(%dx)
f010058f:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100594:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100599:	ee                   	out    %al,(%dx)
f010059a:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010059f:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005a4:	89 da                	mov    %ebx,%edx
f01005a6:	ee                   	out    %al,(%dx)
f01005a7:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01005b1:	ee                   	out    %al,(%dx)
f01005b2:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005b7:	b8 03 00 00 00       	mov    $0x3,%eax
f01005bc:	ee                   	out    %al,(%dx)
f01005bd:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c7:	ee                   	out    %al,(%dx)
f01005c8:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005cd:	b8 01 00 00 00       	mov    $0x1,%eax
f01005d2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005d3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005d8:	ec                   	in     (%dx),%al
f01005d9:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005db:	3c ff                	cmp    $0xff,%al
f01005dd:	0f 95 05 74 3f 17 f0 	setne  0xf0173f74
f01005e4:	89 f2                	mov    %esi,%edx
f01005e6:	ec                   	in     (%dx),%al
f01005e7:	89 da                	mov    %ebx,%edx
f01005e9:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005ea:	80 f9 ff             	cmp    $0xff,%cl
f01005ed:	75 10                	jne    f01005ff <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005ef:	83 ec 0c             	sub    $0xc,%esp
f01005f2:	68 19 43 10 f0       	push   $0xf0104319
f01005f7:	e8 a5 29 00 00       	call   f0102fa1 <cprintf>
f01005fc:	83 c4 10             	add    $0x10,%esp
}
f01005ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5e                   	pop    %esi
f0100604:	5f                   	pop    %edi
f0100605:	5d                   	pop    %ebp
f0100606:	c3                   	ret    

f0100607 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100607:	55                   	push   %ebp
f0100608:	89 e5                	mov    %esp,%ebp
f010060a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010060d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100610:	e8 89 fc ff ff       	call   f010029e <cons_putc>
}
f0100615:	c9                   	leave  
f0100616:	c3                   	ret    

f0100617 <getchar>:

int
getchar(void)
{
f0100617:	55                   	push   %ebp
f0100618:	89 e5                	mov    %esp,%ebp
f010061a:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010061d:	e8 93 fe ff ff       	call   f01004b5 <cons_getc>
f0100622:	85 c0                	test   %eax,%eax
f0100624:	74 f7                	je     f010061d <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100626:	c9                   	leave  
f0100627:	c3                   	ret    

f0100628 <iscons>:

int
iscons(int fdnum)
{
f0100628:	55                   	push   %ebp
f0100629:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010062b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100630:	5d                   	pop    %ebp
f0100631:	c3                   	ret    

f0100632 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100632:	55                   	push   %ebp
f0100633:	89 e5                	mov    %esp,%ebp
f0100635:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100638:	68 60 45 10 f0       	push   $0xf0104560
f010063d:	68 7e 45 10 f0       	push   $0xf010457e
f0100642:	68 83 45 10 f0       	push   $0xf0104583
f0100647:	e8 55 29 00 00       	call   f0102fa1 <cprintf>
f010064c:	83 c4 0c             	add    $0xc,%esp
f010064f:	68 30 46 10 f0       	push   $0xf0104630
f0100654:	68 8c 45 10 f0       	push   $0xf010458c
f0100659:	68 83 45 10 f0       	push   $0xf0104583
f010065e:	e8 3e 29 00 00       	call   f0102fa1 <cprintf>
f0100663:	83 c4 0c             	add    $0xc,%esp
f0100666:	68 95 45 10 f0       	push   $0xf0104595
f010066b:	68 a3 45 10 f0       	push   $0xf01045a3
f0100670:	68 83 45 10 f0       	push   $0xf0104583
f0100675:	e8 27 29 00 00       	call   f0102fa1 <cprintf>
	return 0;
}
f010067a:	b8 00 00 00 00       	mov    $0x0,%eax
f010067f:	c9                   	leave  
f0100680:	c3                   	ret    

f0100681 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100681:	55                   	push   %ebp
f0100682:	89 e5                	mov    %esp,%ebp
f0100684:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100687:	68 ad 45 10 f0       	push   $0xf01045ad
f010068c:	e8 10 29 00 00       	call   f0102fa1 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100691:	83 c4 08             	add    $0x8,%esp
f0100694:	68 0c 00 10 00       	push   $0x10000c
f0100699:	68 58 46 10 f0       	push   $0xf0104658
f010069e:	e8 fe 28 00 00       	call   f0102fa1 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006a3:	83 c4 0c             	add    $0xc,%esp
f01006a6:	68 0c 00 10 00       	push   $0x10000c
f01006ab:	68 0c 00 10 f0       	push   $0xf010000c
f01006b0:	68 80 46 10 f0       	push   $0xf0104680
f01006b5:	e8 e7 28 00 00       	call   f0102fa1 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006ba:	83 c4 0c             	add    $0xc,%esp
f01006bd:	68 a1 42 10 00       	push   $0x1042a1
f01006c2:	68 a1 42 10 f0       	push   $0xf01042a1
f01006c7:	68 a4 46 10 f0       	push   $0xf01046a4
f01006cc:	e8 d0 28 00 00       	call   f0102fa1 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006d1:	83 c4 0c             	add    $0xc,%esp
f01006d4:	68 26 3d 17 00       	push   $0x173d26
f01006d9:	68 26 3d 17 f0       	push   $0xf0173d26
f01006de:	68 c8 46 10 f0       	push   $0xf01046c8
f01006e3:	e8 b9 28 00 00       	call   f0102fa1 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006e8:	83 c4 0c             	add    $0xc,%esp
f01006eb:	68 50 4c 17 00       	push   $0x174c50
f01006f0:	68 50 4c 17 f0       	push   $0xf0174c50
f01006f5:	68 ec 46 10 f0       	push   $0xf01046ec
f01006fa:	e8 a2 28 00 00       	call   f0102fa1 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006ff:	b8 4f 50 17 f0       	mov    $0xf017504f,%eax
f0100704:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100709:	83 c4 08             	add    $0x8,%esp
f010070c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100711:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100717:	85 c0                	test   %eax,%eax
f0100719:	0f 48 c2             	cmovs  %edx,%eax
f010071c:	c1 f8 0a             	sar    $0xa,%eax
f010071f:	50                   	push   %eax
f0100720:	68 10 47 10 f0       	push   $0xf0104710
f0100725:	e8 77 28 00 00       	call   f0102fa1 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010072a:	b8 00 00 00 00       	mov    $0x0,%eax
f010072f:	c9                   	leave  
f0100730:	c3                   	ret    

f0100731 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100731:	55                   	push   %ebp
f0100732:	89 e5                	mov    %esp,%ebp
f0100734:	56                   	push   %esi
f0100735:	53                   	push   %ebx
f0100736:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100739:	89 eb                	mov    %ebp,%ebx
	
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
f010073b:	68 c6 45 10 f0       	push   $0xf01045c6
f0100740:	e8 5c 28 00 00       	call   f0102fa1 <cprintf>
	
	while (ebp) {
f0100745:	83 c4 10             	add    $0x10,%esp
                  *(ebp+3),
                  *(ebp+4),
                  *(ebp+5),
                  *(ebp+6));
                  
	     debuginfo_eip((*(ebp+1)),&info);
f0100748:	8d 75 e0             	lea    -0x20(%ebp),%esi
	
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
	
	while (ebp) {
f010074b:	eb 4e                	jmp    f010079b <mon_backtrace+0x6a>
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",ebp,*(ebp+1),
f010074d:	ff 73 18             	pushl  0x18(%ebx)
f0100750:	ff 73 14             	pushl  0x14(%ebx)
f0100753:	ff 73 10             	pushl  0x10(%ebx)
f0100756:	ff 73 0c             	pushl  0xc(%ebx)
f0100759:	ff 73 08             	pushl  0x8(%ebx)
f010075c:	ff 73 04             	pushl  0x4(%ebx)
f010075f:	53                   	push   %ebx
f0100760:	68 3c 47 10 f0       	push   $0xf010473c
f0100765:	e8 37 28 00 00       	call   f0102fa1 <cprintf>
                  *(ebp+3),
                  *(ebp+4),
                  *(ebp+5),
                  *(ebp+6));
                  
	     debuginfo_eip((*(ebp+1)),&info);
f010076a:	83 c4 18             	add    $0x18,%esp
f010076d:	56                   	push   %esi
f010076e:	ff 73 04             	pushl  0x4(%ebx)
f0100771:	e8 df 2c 00 00       	call   f0103455 <debuginfo_eip>
	     cprintf("         %s:%d: %.*s+%d\n", 
f0100776:	83 c4 08             	add    $0x8,%esp
f0100779:	8b 43 04             	mov    0x4(%ebx),%eax
f010077c:	2b 45 f0             	sub    -0x10(%ebp),%eax
f010077f:	50                   	push   %eax
f0100780:	ff 75 e8             	pushl  -0x18(%ebp)
f0100783:	ff 75 ec             	pushl  -0x14(%ebp)
f0100786:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100789:	ff 75 e0             	pushl  -0x20(%ebp)
f010078c:	68 d8 45 10 f0       	push   $0xf01045d8
f0100791:	e8 0b 28 00 00       	call   f0102fa1 <cprintf>
	     info.eip_file, info.eip_line,
	     info.eip_fn_namelen, info.eip_fn_name, (*(ebp+1)) - info.eip_fn_addr);

	     ebp = (uint32_t *)*(ebp);
f0100796:	8b 1b                	mov    (%ebx),%ebx
f0100798:	83 c4 20             	add    $0x20,%esp
	
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
	
	while (ebp) {
f010079b:	85 db                	test   %ebx,%ebx
f010079d:	75 ae                	jne    f010074d <mon_backtrace+0x1c>
	     ebp = (uint32_t *)*(ebp);
    }

	
	return 0;
}
f010079f:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007a7:	5b                   	pop    %ebx
f01007a8:	5e                   	pop    %esi
f01007a9:	5d                   	pop    %ebp
f01007aa:	c3                   	ret    

f01007ab <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007ab:	55                   	push   %ebp
f01007ac:	89 e5                	mov    %esp,%ebp
f01007ae:	57                   	push   %edi
f01007af:	56                   	push   %esi
f01007b0:	53                   	push   %ebx
f01007b1:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007b4:	68 70 47 10 f0       	push   $0xf0104770
f01007b9:	e8 e3 27 00 00       	call   f0102fa1 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007be:	c7 04 24 94 47 10 f0 	movl   $0xf0104794,(%esp)
f01007c5:	e8 d7 27 00 00       	call   f0102fa1 <cprintf>

	if (tf != NULL)
f01007ca:	83 c4 10             	add    $0x10,%esp
f01007cd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01007d1:	74 0e                	je     f01007e1 <monitor+0x36>
		print_trapframe(tf);
f01007d3:	83 ec 0c             	sub    $0xc,%esp
f01007d6:	ff 75 08             	pushl  0x8(%ebp)
f01007d9:	e8 cc 28 00 00       	call   f01030aa <print_trapframe>
f01007de:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01007e1:	83 ec 0c             	sub    $0xc,%esp
f01007e4:	68 f1 45 10 f0       	push   $0xf01045f1
f01007e9:	e8 d0 33 00 00       	call   f0103bbe <readline>
f01007ee:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007f0:	83 c4 10             	add    $0x10,%esp
f01007f3:	85 c0                	test   %eax,%eax
f01007f5:	74 ea                	je     f01007e1 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007f7:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007fe:	be 00 00 00 00       	mov    $0x0,%esi
f0100803:	eb 0a                	jmp    f010080f <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100805:	c6 03 00             	movb   $0x0,(%ebx)
f0100808:	89 f7                	mov    %esi,%edi
f010080a:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010080d:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010080f:	0f b6 03             	movzbl (%ebx),%eax
f0100812:	84 c0                	test   %al,%al
f0100814:	74 63                	je     f0100879 <monitor+0xce>
f0100816:	83 ec 08             	sub    $0x8,%esp
f0100819:	0f be c0             	movsbl %al,%eax
f010081c:	50                   	push   %eax
f010081d:	68 f5 45 10 f0       	push   $0xf01045f5
f0100822:	e8 b1 35 00 00       	call   f0103dd8 <strchr>
f0100827:	83 c4 10             	add    $0x10,%esp
f010082a:	85 c0                	test   %eax,%eax
f010082c:	75 d7                	jne    f0100805 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f010082e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100831:	74 46                	je     f0100879 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100833:	83 fe 0f             	cmp    $0xf,%esi
f0100836:	75 14                	jne    f010084c <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100838:	83 ec 08             	sub    $0x8,%esp
f010083b:	6a 10                	push   $0x10
f010083d:	68 fa 45 10 f0       	push   $0xf01045fa
f0100842:	e8 5a 27 00 00       	call   f0102fa1 <cprintf>
f0100847:	83 c4 10             	add    $0x10,%esp
f010084a:	eb 95                	jmp    f01007e1 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f010084c:	8d 7e 01             	lea    0x1(%esi),%edi
f010084f:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100853:	eb 03                	jmp    f0100858 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100855:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100858:	0f b6 03             	movzbl (%ebx),%eax
f010085b:	84 c0                	test   %al,%al
f010085d:	74 ae                	je     f010080d <monitor+0x62>
f010085f:	83 ec 08             	sub    $0x8,%esp
f0100862:	0f be c0             	movsbl %al,%eax
f0100865:	50                   	push   %eax
f0100866:	68 f5 45 10 f0       	push   $0xf01045f5
f010086b:	e8 68 35 00 00       	call   f0103dd8 <strchr>
f0100870:	83 c4 10             	add    $0x10,%esp
f0100873:	85 c0                	test   %eax,%eax
f0100875:	74 de                	je     f0100855 <monitor+0xaa>
f0100877:	eb 94                	jmp    f010080d <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100879:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100880:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100881:	85 f6                	test   %esi,%esi
f0100883:	0f 84 58 ff ff ff    	je     f01007e1 <monitor+0x36>
f0100889:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010088e:	83 ec 08             	sub    $0x8,%esp
f0100891:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100894:	ff 34 85 c0 47 10 f0 	pushl  -0xfefb840(,%eax,4)
f010089b:	ff 75 a8             	pushl  -0x58(%ebp)
f010089e:	e8 d7 34 00 00       	call   f0103d7a <strcmp>
f01008a3:	83 c4 10             	add    $0x10,%esp
f01008a6:	85 c0                	test   %eax,%eax
f01008a8:	75 21                	jne    f01008cb <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f01008aa:	83 ec 04             	sub    $0x4,%esp
f01008ad:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008b0:	ff 75 08             	pushl  0x8(%ebp)
f01008b3:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008b6:	52                   	push   %edx
f01008b7:	56                   	push   %esi
f01008b8:	ff 14 85 c8 47 10 f0 	call   *-0xfefb838(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008bf:	83 c4 10             	add    $0x10,%esp
f01008c2:	85 c0                	test   %eax,%eax
f01008c4:	78 25                	js     f01008eb <monitor+0x140>
f01008c6:	e9 16 ff ff ff       	jmp    f01007e1 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008cb:	83 c3 01             	add    $0x1,%ebx
f01008ce:	83 fb 03             	cmp    $0x3,%ebx
f01008d1:	75 bb                	jne    f010088e <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008d3:	83 ec 08             	sub    $0x8,%esp
f01008d6:	ff 75 a8             	pushl  -0x58(%ebp)
f01008d9:	68 17 46 10 f0       	push   $0xf0104617
f01008de:	e8 be 26 00 00       	call   f0102fa1 <cprintf>
f01008e3:	83 c4 10             	add    $0x10,%esp
f01008e6:	e9 f6 fe ff ff       	jmp    f01007e1 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008ee:	5b                   	pop    %ebx
f01008ef:	5e                   	pop    %esi
f01008f0:	5f                   	pop    %edi
f01008f1:	5d                   	pop    %ebp
f01008f2:	c3                   	ret    

f01008f3 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01008f3:	55                   	push   %ebp
f01008f4:	89 e5                	mov    %esp,%ebp
f01008f6:	56                   	push   %esi
f01008f7:	53                   	push   %ebx
f01008f8:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01008fa:	83 3d 78 3f 17 f0 00 	cmpl   $0x0,0xf0173f78
f0100901:	75 24                	jne    f0100927 <boot_alloc+0x34>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100903:	b8 4f 5c 17 f0       	mov    $0xf0175c4f,%eax
f0100908:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010090d:	a3 78 3f 17 f0       	mov    %eax,0xf0173f78
		cprintf ("%x", end);
f0100912:	83 ec 08             	sub    $0x8,%esp
f0100915:	68 50 4c 17 f0       	push   $0xf0174c50
f010091a:	68 e4 47 10 f0       	push   $0xf01047e4
f010091f:	e8 7d 26 00 00       	call   f0102fa1 <cprintf>
f0100924:	83 c4 10             	add    $0x10,%esp
					
		}	
	}

	else{
		result = nextfree;
f0100927:	8b 35 78 3f 17 f0    	mov    0xf0173f78,%esi
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n > 0){
f010092d:	85 db                	test   %ebx,%ebx
f010092f:	0f 84 bc 00 00 00    	je     f01009f1 <boot_alloc+0xfe>
		cprintf("\nNextfree before allocation %x\n", nextfree);
f0100935:	83 ec 08             	sub    $0x8,%esp
f0100938:	56                   	push   %esi
f0100939:	68 28 4b 10 f0       	push   $0xf0104b28
f010093e:	e8 5e 26 00 00       	call   f0102fa1 <cprintf>
		result = nextfree;
f0100943:	8b 35 78 3f 17 f0    	mov    0xf0173f78,%esi
		struct PageInfo *pp;
		nextfree = nextfree + n;
f0100949:	01 f3                	add    %esi,%ebx
f010094b:	89 1d 78 3f 17 f0    	mov    %ebx,0xf0173f78

		cprintf("Nextfree after allocation %x\n", nextfree);
f0100951:	83 c4 08             	add    $0x8,%esp
f0100954:	53                   	push   %ebx
f0100955:	68 e7 47 10 f0       	push   $0xf01047e7
f010095a:	e8 42 26 00 00       	call   f0102fa1 <cprintf>
		cprintf ("Bytes to be allocated %u\n", ((nextfree - result)/8));
f010095f:	83 c4 08             	add    $0x8,%esp
f0100962:	8b 15 78 3f 17 f0    	mov    0xf0173f78,%edx
f0100968:	29 f2                	sub    %esi,%edx
f010096a:	8d 42 07             	lea    0x7(%edx),%eax
f010096d:	85 d2                	test   %edx,%edx
f010096f:	0f 49 c2             	cmovns %edx,%eax
f0100972:	c1 f8 03             	sar    $0x3,%eax
f0100975:	50                   	push   %eax
f0100976:	68 05 48 10 f0       	push   $0xf0104805
f010097b:	e8 21 26 00 00       	call   f0102fa1 <cprintf>
		 
		nextfree = ROUNDUP(nextfree , PGSIZE);
f0100980:	a1 78 3f 17 f0       	mov    0xf0173f78,%eax
f0100985:	05 ff 0f 00 00       	add    $0xfff,%eax
f010098a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010098f:	a3 78 3f 17 f0       	mov    %eax,0xf0173f78
		
		
		cprintf ("Nextfree after rounding up to page size %x\n", nextfree);
f0100994:	83 c4 08             	add    $0x8,%esp
f0100997:	50                   	push   %eax
f0100998:	68 48 4b 10 f0       	push   $0xf0104b48
f010099d:	e8 ff 25 00 00       	call   f0102fa1 <cprintf>
		cprintf ("Bytes allocated %u\n", ((nextfree - result)/8));
f01009a2:	83 c4 08             	add    $0x8,%esp
f01009a5:	8b 15 78 3f 17 f0    	mov    0xf0173f78,%edx
f01009ab:	29 f2                	sub    %esi,%edx
f01009ad:	8d 42 07             	lea    0x7(%edx),%eax
f01009b0:	85 d2                	test   %edx,%edx
f01009b2:	0f 49 c2             	cmovns %edx,%eax
f01009b5:	c1 f8 03             	sar    $0x3,%eax
f01009b8:	50                   	push   %eax
f01009b9:	68 1f 48 10 f0       	push   $0xf010481f
f01009be:	e8 de 25 00 00       	call   f0102fa1 <cprintf>
		//cprintf ("Check%x\n ",((uint32_t)nextfree - KERNBASE));
		if (((uint32_t)nextfree - KERNBASE) > (npages * PGSIZE)){
f01009c3:	a1 78 3f 17 f0       	mov    0xf0173f78,%eax
f01009c8:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01009ce:	a1 44 4c 17 f0       	mov    0xf0174c44,%eax
f01009d3:	c1 e0 0c             	shl    $0xc,%eax
f01009d6:	83 c4 10             	add    $0x10,%esp
f01009d9:	39 c2                	cmp    %eax,%edx
f01009db:	76 14                	jbe    f01009f1 <boot_alloc+0xfe>
			panic("boot_alloc panicked: Out of Memory\n");
f01009dd:	83 ec 04             	sub    $0x4,%esp
f01009e0:	68 74 4b 10 f0       	push   $0xf0104b74
f01009e5:	6a 7a                	push   $0x7a
f01009e7:	68 33 48 10 f0       	push   $0xf0104833
f01009ec:	e8 af f6 ff ff       	call   f01000a0 <_panic>
	else{
		result = nextfree;
	} 

	return result;
}
f01009f1:	89 f0                	mov    %esi,%eax
f01009f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01009f6:	5b                   	pop    %ebx
f01009f7:	5e                   	pop    %esi
f01009f8:	5d                   	pop    %ebp
f01009f9:	c3                   	ret    

f01009fa <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f01009fa:	89 d1                	mov    %edx,%ecx
f01009fc:	c1 e9 16             	shr    $0x16,%ecx
f01009ff:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a02:	a8 01                	test   $0x1,%al
f0100a04:	74 52                	je     f0100a58 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a0b:	89 c1                	mov    %eax,%ecx
f0100a0d:	c1 e9 0c             	shr    $0xc,%ecx
f0100a10:	3b 0d 44 4c 17 f0    	cmp    0xf0174c44,%ecx
f0100a16:	72 1b                	jb     f0100a33 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a18:	55                   	push   %ebp
f0100a19:	89 e5                	mov    %esp,%ebp
f0100a1b:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a1e:	50                   	push   %eax
f0100a1f:	68 98 4b 10 f0       	push   $0xf0104b98
f0100a24:	68 42 03 00 00       	push   $0x342
f0100a29:	68 33 48 10 f0       	push   $0xf0104833
f0100a2e:	e8 6d f6 ff ff       	call   f01000a0 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100a33:	c1 ea 0c             	shr    $0xc,%edx
f0100a36:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a3c:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a43:	89 c2                	mov    %eax,%edx
f0100a45:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a4d:	85 d2                	test   %edx,%edx
f0100a4f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a54:	0f 44 c2             	cmove  %edx,%eax
f0100a57:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a5d:	c3                   	ret    

f0100a5e <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a5e:	55                   	push   %ebp
f0100a5f:	89 e5                	mov    %esp,%ebp
f0100a61:	57                   	push   %edi
f0100a62:	56                   	push   %esi
f0100a63:	53                   	push   %ebx
f0100a64:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a67:	84 c0                	test   %al,%al
f0100a69:	0f 85 72 02 00 00    	jne    f0100ce1 <check_page_free_list+0x283>
f0100a6f:	e9 7f 02 00 00       	jmp    f0100cf3 <check_page_free_list+0x295>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a74:	83 ec 04             	sub    $0x4,%esp
f0100a77:	68 bc 4b 10 f0       	push   $0xf0104bbc
f0100a7c:	68 80 02 00 00       	push   $0x280
f0100a81:	68 33 48 10 f0       	push   $0xf0104833
f0100a86:	e8 15 f6 ff ff       	call   f01000a0 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a8b:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a8e:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a91:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a94:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a97:	89 c2                	mov    %eax,%edx
f0100a99:	2b 15 4c 4c 17 f0    	sub    0xf0174c4c,%edx
f0100a9f:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100aa5:	0f 95 c2             	setne  %dl
f0100aa8:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100aab:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100aaf:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ab1:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ab5:	8b 00                	mov    (%eax),%eax
f0100ab7:	85 c0                	test   %eax,%eax
f0100ab9:	75 dc                	jne    f0100a97 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100abb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100abe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ac4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ac7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100aca:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100acc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100acf:	a3 7c 3f 17 f0       	mov    %eax,0xf0173f7c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ad4:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ad9:	8b 1d 7c 3f 17 f0    	mov    0xf0173f7c,%ebx
f0100adf:	eb 53                	jmp    f0100b34 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ae1:	89 d8                	mov    %ebx,%eax
f0100ae3:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0100ae9:	c1 f8 03             	sar    $0x3,%eax
f0100aec:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100aef:	89 c2                	mov    %eax,%edx
f0100af1:	c1 ea 16             	shr    $0x16,%edx
f0100af4:	39 f2                	cmp    %esi,%edx
f0100af6:	73 3a                	jae    f0100b32 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100af8:	89 c2                	mov    %eax,%edx
f0100afa:	c1 ea 0c             	shr    $0xc,%edx
f0100afd:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f0100b03:	72 12                	jb     f0100b17 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b05:	50                   	push   %eax
f0100b06:	68 98 4b 10 f0       	push   $0xf0104b98
f0100b0b:	6a 56                	push   $0x56
f0100b0d:	68 3f 48 10 f0       	push   $0xf010483f
f0100b12:	e8 89 f5 ff ff       	call   f01000a0 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b17:	83 ec 04             	sub    $0x4,%esp
f0100b1a:	68 80 00 00 00       	push   $0x80
f0100b1f:	68 97 00 00 00       	push   $0x97
f0100b24:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b29:	50                   	push   %eax
f0100b2a:	e8 e6 32 00 00       	call   f0103e15 <memset>
f0100b2f:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b32:	8b 1b                	mov    (%ebx),%ebx
f0100b34:	85 db                	test   %ebx,%ebx
f0100b36:	75 a9                	jne    f0100ae1 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b38:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b3d:	e8 b1 fd ff ff       	call   f01008f3 <boot_alloc>
f0100b42:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b45:	8b 15 7c 3f 17 f0    	mov    0xf0173f7c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b4b:	8b 0d 4c 4c 17 f0    	mov    0xf0174c4c,%ecx
		assert(pp < pages + npages);
f0100b51:	a1 44 4c 17 f0       	mov    0xf0174c44,%eax
f0100b56:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b59:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b5c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b5f:	be 00 00 00 00       	mov    $0x0,%esi
f0100b64:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b67:	e9 30 01 00 00       	jmp    f0100c9c <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b6c:	39 ca                	cmp    %ecx,%edx
f0100b6e:	73 19                	jae    f0100b89 <check_page_free_list+0x12b>
f0100b70:	68 4d 48 10 f0       	push   $0xf010484d
f0100b75:	68 59 48 10 f0       	push   $0xf0104859
f0100b7a:	68 9a 02 00 00       	push   $0x29a
f0100b7f:	68 33 48 10 f0       	push   $0xf0104833
f0100b84:	e8 17 f5 ff ff       	call   f01000a0 <_panic>
		assert(pp < pages + npages);
f0100b89:	39 fa                	cmp    %edi,%edx
f0100b8b:	72 19                	jb     f0100ba6 <check_page_free_list+0x148>
f0100b8d:	68 6e 48 10 f0       	push   $0xf010486e
f0100b92:	68 59 48 10 f0       	push   $0xf0104859
f0100b97:	68 9b 02 00 00       	push   $0x29b
f0100b9c:	68 33 48 10 f0       	push   $0xf0104833
f0100ba1:	e8 fa f4 ff ff       	call   f01000a0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ba6:	89 d0                	mov    %edx,%eax
f0100ba8:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100bab:	a8 07                	test   $0x7,%al
f0100bad:	74 19                	je     f0100bc8 <check_page_free_list+0x16a>
f0100baf:	68 e0 4b 10 f0       	push   $0xf0104be0
f0100bb4:	68 59 48 10 f0       	push   $0xf0104859
f0100bb9:	68 9c 02 00 00       	push   $0x29c
f0100bbe:	68 33 48 10 f0       	push   $0xf0104833
f0100bc3:	e8 d8 f4 ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bc8:	c1 f8 03             	sar    $0x3,%eax
f0100bcb:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100bce:	85 c0                	test   %eax,%eax
f0100bd0:	75 19                	jne    f0100beb <check_page_free_list+0x18d>
f0100bd2:	68 82 48 10 f0       	push   $0xf0104882
f0100bd7:	68 59 48 10 f0       	push   $0xf0104859
f0100bdc:	68 9f 02 00 00       	push   $0x29f
f0100be1:	68 33 48 10 f0       	push   $0xf0104833
f0100be6:	e8 b5 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100beb:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bf0:	75 19                	jne    f0100c0b <check_page_free_list+0x1ad>
f0100bf2:	68 93 48 10 f0       	push   $0xf0104893
f0100bf7:	68 59 48 10 f0       	push   $0xf0104859
f0100bfc:	68 a0 02 00 00       	push   $0x2a0
f0100c01:	68 33 48 10 f0       	push   $0xf0104833
f0100c06:	e8 95 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c0b:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c10:	75 19                	jne    f0100c2b <check_page_free_list+0x1cd>
f0100c12:	68 14 4c 10 f0       	push   $0xf0104c14
f0100c17:	68 59 48 10 f0       	push   $0xf0104859
f0100c1c:	68 a1 02 00 00       	push   $0x2a1
f0100c21:	68 33 48 10 f0       	push   $0xf0104833
f0100c26:	e8 75 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c2b:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c30:	75 19                	jne    f0100c4b <check_page_free_list+0x1ed>
f0100c32:	68 ac 48 10 f0       	push   $0xf01048ac
f0100c37:	68 59 48 10 f0       	push   $0xf0104859
f0100c3c:	68 a2 02 00 00       	push   $0x2a2
f0100c41:	68 33 48 10 f0       	push   $0xf0104833
f0100c46:	e8 55 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c4b:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c50:	76 3f                	jbe    f0100c91 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c52:	89 c3                	mov    %eax,%ebx
f0100c54:	c1 eb 0c             	shr    $0xc,%ebx
f0100c57:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100c5a:	77 12                	ja     f0100c6e <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c5c:	50                   	push   %eax
f0100c5d:	68 98 4b 10 f0       	push   $0xf0104b98
f0100c62:	6a 56                	push   $0x56
f0100c64:	68 3f 48 10 f0       	push   $0xf010483f
f0100c69:	e8 32 f4 ff ff       	call   f01000a0 <_panic>
f0100c6e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c73:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c76:	76 1e                	jbe    f0100c96 <check_page_free_list+0x238>
f0100c78:	68 38 4c 10 f0       	push   $0xf0104c38
f0100c7d:	68 59 48 10 f0       	push   $0xf0104859
f0100c82:	68 a3 02 00 00       	push   $0x2a3
f0100c87:	68 33 48 10 f0       	push   $0xf0104833
f0100c8c:	e8 0f f4 ff ff       	call   f01000a0 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c91:	83 c6 01             	add    $0x1,%esi
f0100c94:	eb 04                	jmp    f0100c9a <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100c96:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c9a:	8b 12                	mov    (%edx),%edx
f0100c9c:	85 d2                	test   %edx,%edx
f0100c9e:	0f 85 c8 fe ff ff    	jne    f0100b6c <check_page_free_list+0x10e>
f0100ca4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100ca7:	85 f6                	test   %esi,%esi
f0100ca9:	7f 19                	jg     f0100cc4 <check_page_free_list+0x266>
f0100cab:	68 c6 48 10 f0       	push   $0xf01048c6
f0100cb0:	68 59 48 10 f0       	push   $0xf0104859
f0100cb5:	68 ab 02 00 00       	push   $0x2ab
f0100cba:	68 33 48 10 f0       	push   $0xf0104833
f0100cbf:	e8 dc f3 ff ff       	call   f01000a0 <_panic>
	assert(nfree_extmem > 0);
f0100cc4:	85 db                	test   %ebx,%ebx
f0100cc6:	7f 42                	jg     f0100d0a <check_page_free_list+0x2ac>
f0100cc8:	68 d8 48 10 f0       	push   $0xf01048d8
f0100ccd:	68 59 48 10 f0       	push   $0xf0104859
f0100cd2:	68 ac 02 00 00       	push   $0x2ac
f0100cd7:	68 33 48 10 f0       	push   $0xf0104833
f0100cdc:	e8 bf f3 ff ff       	call   f01000a0 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100ce1:	a1 7c 3f 17 f0       	mov    0xf0173f7c,%eax
f0100ce6:	85 c0                	test   %eax,%eax
f0100ce8:	0f 85 9d fd ff ff    	jne    f0100a8b <check_page_free_list+0x2d>
f0100cee:	e9 81 fd ff ff       	jmp    f0100a74 <check_page_free_list+0x16>
f0100cf3:	83 3d 7c 3f 17 f0 00 	cmpl   $0x0,0xf0173f7c
f0100cfa:	0f 84 74 fd ff ff    	je     f0100a74 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d00:	be 00 04 00 00       	mov    $0x400,%esi
f0100d05:	e9 cf fd ff ff       	jmp    f0100ad9 <check_page_free_list+0x7b>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d0d:	5b                   	pop    %ebx
f0100d0e:	5e                   	pop    %esi
f0100d0f:	5f                   	pop    %edi
f0100d10:	5d                   	pop    %ebp
f0100d11:	c3                   	ret    

f0100d12 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d12:	55                   	push   %ebp
f0100d13:	89 e5                	mov    %esp,%ebp
f0100d15:	56                   	push   %esi
f0100d16:	53                   	push   %ebx
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	
	 for (i = 0; i < npages; i++) {
f0100d17:	be 00 00 00 00       	mov    $0x0,%esi
f0100d1c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d21:	e9 82 00 00 00       	jmp    f0100da8 <page_init+0x96>
                if(i == 0 || (i >= (IOPHYSMEM/PGSIZE) && i < (EXTPHYSMEM/PGSIZE))) {
f0100d26:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0100d2c:	83 f8 5f             	cmp    $0x5f,%eax
f0100d2f:	76 04                	jbe    f0100d35 <page_init+0x23>
f0100d31:	85 db                	test   %ebx,%ebx
f0100d33:	75 16                	jne    f0100d4b <page_init+0x39>
                        pages[i].pp_ref = (uint16_t) 0;
f0100d35:	89 f0                	mov    %esi,%eax
f0100d37:	03 05 4c 4c 17 f0    	add    0xf0174c4c,%eax
f0100d3d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
                        pages[i].pp_link = NULL;
f0100d43:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d49:	eb 57                	jmp    f0100da2 <page_init+0x90>
                }else if(i >= (EXTPHYSMEM/PGSIZE) && 
f0100d4b:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100d51:	76 2c                	jbe    f0100d7f <page_init+0x6d>
                         i < (((uint32_t)(boot_alloc(0)-KERNBASE))/PGSIZE)) {
f0100d53:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d58:	e8 96 fb ff ff       	call   f01008f3 <boot_alloc>
	
	 for (i = 0; i < npages; i++) {
                if(i == 0 || (i >= (IOPHYSMEM/PGSIZE) && i < (EXTPHYSMEM/PGSIZE))) {
                        pages[i].pp_ref = (uint16_t) 0;
                        pages[i].pp_link = NULL;
                }else if(i >= (EXTPHYSMEM/PGSIZE) && 
f0100d5d:	05 00 00 00 10       	add    $0x10000000,%eax
f0100d62:	c1 e8 0c             	shr    $0xc,%eax
f0100d65:	39 c3                	cmp    %eax,%ebx
f0100d67:	73 16                	jae    f0100d7f <page_init+0x6d>
                         i < (((uint32_t)(boot_alloc(0)-KERNBASE))/PGSIZE)) {
                        pages[i].pp_ref = (uint16_t) 0;
f0100d69:	89 f0                	mov    %esi,%eax
f0100d6b:	03 05 4c 4c 17 f0    	add    0xf0174c4c,%eax
f0100d71:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
                        pages[i].pp_link = NULL;
f0100d77:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d7d:	eb 23                	jmp    f0100da2 <page_init+0x90>
                }else{
                        pages[i].pp_ref = 0;
f0100d7f:	89 f0                	mov    %esi,%eax
f0100d81:	03 05 4c 4c 17 f0    	add    0xf0174c4c,%eax
f0100d87:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
                        pages[i].pp_link = page_free_list;
f0100d8d:	8b 15 7c 3f 17 f0    	mov    0xf0173f7c,%edx
f0100d93:	89 10                	mov    %edx,(%eax)
                        page_free_list = &pages[i];
f0100d95:	89 f0                	mov    %esi,%eax
f0100d97:	03 05 4c 4c 17 f0    	add    0xf0174c4c,%eax
f0100d9d:	a3 7c 3f 17 f0       	mov    %eax,0xf0173f7c
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	
	 for (i = 0; i < npages; i++) {
f0100da2:	83 c3 01             	add    $0x1,%ebx
f0100da5:	83 c6 08             	add    $0x8,%esi
f0100da8:	3b 1d 44 4c 17 f0    	cmp    0xf0174c44,%ebx
f0100dae:	0f 82 72 ff ff ff    	jb     f0100d26 <page_init+0x14>
                        pages[i].pp_ref = 0;
                        pages[i].pp_link = page_free_list;
                        page_free_list = &pages[i];
                }
        }
} 
f0100db4:	5b                   	pop    %ebx
f0100db5:	5e                   	pop    %esi
f0100db6:	5d                   	pop    %ebp
f0100db7:	c3                   	ret    

f0100db8 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100db8:	55                   	push   %ebp
f0100db9:	89 e5                	mov    %esp,%ebp
f0100dbb:	53                   	push   %ebx
f0100dbc:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct PageInfo* allocated_page=NULL;
        
        if(page_free_list != NULL) {
f0100dbf:	8b 1d 7c 3f 17 f0    	mov    0xf0173f7c,%ebx
f0100dc5:	85 db                	test   %ebx,%ebx
f0100dc7:	74 58                	je     f0100e21 <page_alloc+0x69>
                allocated_page = page_free_list;
                page_free_list = allocated_page->pp_link;
f0100dc9:	8b 03                	mov    (%ebx),%eax
f0100dcb:	a3 7c 3f 17 f0       	mov    %eax,0xf0173f7c
                allocated_page->pp_link = NULL;
f0100dd0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
                
                if(alloc_flags & ALLOC_ZERO) {
f0100dd6:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100dda:	74 45                	je     f0100e21 <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ddc:	89 d8                	mov    %ebx,%eax
f0100dde:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0100de4:	c1 f8 03             	sar    $0x3,%eax
f0100de7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dea:	89 c2                	mov    %eax,%edx
f0100dec:	c1 ea 0c             	shr    $0xc,%edx
f0100def:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f0100df5:	72 12                	jb     f0100e09 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100df7:	50                   	push   %eax
f0100df8:	68 98 4b 10 f0       	push   $0xf0104b98
f0100dfd:	6a 56                	push   $0x56
f0100dff:	68 3f 48 10 f0       	push   $0xf010483f
f0100e04:	e8 97 f2 ff ff       	call   f01000a0 <_panic>
                        memset(page2kva(allocated_page), 0,PGSIZE);
f0100e09:	83 ec 04             	sub    $0x4,%esp
f0100e0c:	68 00 10 00 00       	push   $0x1000
f0100e11:	6a 00                	push   $0x0
f0100e13:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e18:	50                   	push   %eax
f0100e19:	e8 f7 2f 00 00       	call   f0103e15 <memset>
f0100e1e:	83 c4 10             	add    $0x10,%esp
                }
        }
        return allocated_page;
        
}
f0100e21:	89 d8                	mov    %ebx,%eax
f0100e23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e26:	c9                   	leave  
f0100e27:	c3                   	ret    

f0100e28 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100e28:	55                   	push   %ebp
f0100e29:	89 e5                	mov    %esp,%ebp
f0100e2b:	83 ec 08             	sub    $0x8,%esp
f0100e2e:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if((pp->pp_link != NULL) || (pp->pp_ref !=0)) {
f0100e31:	83 38 00             	cmpl   $0x0,(%eax)
f0100e34:	75 07                	jne    f0100e3d <page_free+0x15>
f0100e36:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e3b:	74 17                	je     f0100e54 <page_free+0x2c>
                panic("ref count is not zero or pp_link is not NULL");
f0100e3d:	83 ec 04             	sub    $0x4,%esp
f0100e40:	68 80 4c 10 f0       	push   $0xf0104c80
f0100e45:	68 6d 01 00 00       	push   $0x16d
f0100e4a:	68 33 48 10 f0       	push   $0xf0104833
f0100e4f:	e8 4c f2 ff ff       	call   f01000a0 <_panic>
        }
        
        else{


                pp->pp_link = page_free_list;
f0100e54:	8b 15 7c 3f 17 f0    	mov    0xf0173f7c,%edx
f0100e5a:	89 10                	mov    %edx,(%eax)
                page_free_list = pp;
f0100e5c:	a3 7c 3f 17 f0       	mov    %eax,0xf0173f7c
        }
	
				
}
f0100e61:	c9                   	leave  
f0100e62:	c3                   	ret    

f0100e63 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100e63:	55                   	push   %ebp
f0100e64:	89 e5                	mov    %esp,%ebp
f0100e66:	83 ec 08             	sub    $0x8,%esp
f0100e69:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100e6c:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100e70:	83 e8 01             	sub    $0x1,%eax
f0100e73:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100e77:	66 85 c0             	test   %ax,%ax
f0100e7a:	75 0c                	jne    f0100e88 <page_decref+0x25>
		page_free(pp);
f0100e7c:	83 ec 0c             	sub    $0xc,%esp
f0100e7f:	52                   	push   %edx
f0100e80:	e8 a3 ff ff ff       	call   f0100e28 <page_free>
f0100e85:	83 c4 10             	add    $0x10,%esp
}
f0100e88:	c9                   	leave  
f0100e89:	c3                   	ret    

f0100e8a <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e8a:	55                   	push   %ebp
f0100e8b:	89 e5                	mov    %esp,%ebp
f0100e8d:	56                   	push   %esi
f0100e8e:	53                   	push   %ebx
f0100e8f:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo* new_pg_table;
	pde_t *pdep;
	pte_t *ptep;
	// Fill this function in
	if((pgdir[PDX(va)] & PTE_P) != PTE_P) {
f0100e92:	89 f3                	mov    %esi,%ebx
f0100e94:	c1 eb 16             	shr    $0x16,%ebx
f0100e97:	c1 e3 02             	shl    $0x2,%ebx
f0100e9a:	03 5d 08             	add    0x8(%ebp),%ebx
f0100e9d:	f6 03 01             	testb  $0x1,(%ebx)
f0100ea0:	75 2d                	jne    f0100ecf <pgdir_walk+0x45>
		if(create == false) {
f0100ea2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100ea6:	74 62                	je     f0100f0a <pgdir_walk+0x80>
			return NULL;
		}else{
			new_pg_table = page_alloc(ALLOC_ZERO);
f0100ea8:	83 ec 0c             	sub    $0xc,%esp
f0100eab:	6a 01                	push   $0x1
f0100ead:	e8 06 ff ff ff       	call   f0100db8 <page_alloc>
			if(new_pg_table == NULL) {
f0100eb2:	83 c4 10             	add    $0x10,%esp
f0100eb5:	85 c0                	test   %eax,%eax
f0100eb7:	74 58                	je     f0100f11 <pgdir_walk+0x87>
				return NULL;
			}else{
				new_pg_table->pp_ref += 1;
f0100eb9:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
				pgdir[PDX(va)] = (page2pa(new_pg_table) | PTE_W | PTE_P);
f0100ebe:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0100ec4:	c1 f8 03             	sar    $0x3,%eax
f0100ec7:	c1 e0 0c             	shl    $0xc,%eax
f0100eca:	83 c8 03             	or     $0x3,%eax
f0100ecd:	89 03                	mov    %eax,(%ebx)
			}
		}
	}
	pdep = (pde_t *)&pgdir[PDX(va)];
	ptep = (pte_t *)KADDR(PTE_ADDR(*pdep));
f0100ecf:	8b 03                	mov    (%ebx),%eax
f0100ed1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ed6:	89 c2                	mov    %eax,%edx
f0100ed8:	c1 ea 0c             	shr    $0xc,%edx
f0100edb:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f0100ee1:	72 15                	jb     f0100ef8 <pgdir_walk+0x6e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ee3:	50                   	push   %eax
f0100ee4:	68 98 4b 10 f0       	push   $0xf0104b98
f0100ee9:	68 b0 01 00 00       	push   $0x1b0
f0100eee:	68 33 48 10 f0       	push   $0xf0104833
f0100ef3:	e8 a8 f1 ff ff       	call   f01000a0 <_panic>
	return &ptep[PTX(va)];
f0100ef8:	c1 ee 0a             	shr    $0xa,%esi
f0100efb:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100f01:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0100f08:	eb 0c                	jmp    f0100f16 <pgdir_walk+0x8c>
	pde_t *pdep;
	pte_t *ptep;
	// Fill this function in
	if((pgdir[PDX(va)] & PTE_P) != PTE_P) {
		if(create == false) {
			return NULL;
f0100f0a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f0f:	eb 05                	jmp    f0100f16 <pgdir_walk+0x8c>
		}else{
			new_pg_table = page_alloc(ALLOC_ZERO);
			if(new_pg_table == NULL) {
				return NULL;
f0100f11:	b8 00 00 00 00       	mov    $0x0,%eax
		}
	}
	pdep = (pde_t *)&pgdir[PDX(va)];
	ptep = (pte_t *)KADDR(PTE_ADDR(*pdep));
	return &ptep[PTX(va)];
}
f0100f16:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f19:	5b                   	pop    %ebx
f0100f1a:	5e                   	pop    %esi
f0100f1b:	5d                   	pop    %ebp
f0100f1c:	c3                   	ret    

f0100f1d <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100f1d:	55                   	push   %ebp
f0100f1e:	89 e5                	mov    %esp,%ebp
f0100f20:	57                   	push   %edi
f0100f21:	56                   	push   %esi
f0100f22:	53                   	push   %ebx
f0100f23:	83 ec 1c             	sub    $0x1c,%esp
f0100f26:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f29:	89 c8                	mov    %ecx,%eax
f0100f2b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	pte_t *ptep;
	if(va+size < va)
f0100f2e:	01 d0                	add    %edx,%eax
f0100f30:	73 3f                	jae    f0100f71 <boot_map_region+0x54>
		panic("boot_map_region: Kernel panicked ");
f0100f32:	83 ec 04             	sub    $0x4,%esp
f0100f35:	68 b0 4c 10 f0       	push   $0xf0104cb0
f0100f3a:	68 c5 01 00 00       	push   $0x1c5
f0100f3f:	68 33 48 10 f0       	push   $0xf0104833
f0100f44:	e8 57 f1 ff ff       	call   f01000a0 <_panic>
	for(int i=0; i<size; i+=PGSIZE) {
		ptep = pgdir_walk(pgdir,(void*)(va+i),1);
f0100f49:	83 ec 04             	sub    $0x4,%esp
f0100f4c:	6a 01                	push   $0x1
f0100f4e:	8d 04 37             	lea    (%edi,%esi,1),%eax
f0100f51:	50                   	push   %eax
f0100f52:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f55:	e8 30 ff ff ff       	call   f0100e8a <pgdir_walk>
		if(ptep != NULL){
f0100f5a:	83 c4 10             	add    $0x10,%esp
f0100f5d:	85 c0                	test   %eax,%eax
f0100f5f:	74 08                	je     f0100f69 <boot_map_region+0x4c>
			*ptep = ((pa+i) | perm | PTE_P);
f0100f61:	03 5d 08             	add    0x8(%ebp),%ebx
f0100f64:	0b 5d dc             	or     -0x24(%ebp),%ebx
f0100f67:	89 18                	mov    %ebx,(%eax)
{
	// Fill this function in
	pte_t *ptep;
	if(va+size < va)
		panic("boot_map_region: Kernel panicked ");
	for(int i=0; i<size; i+=PGSIZE) {
f0100f69:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100f6f:	eb 10                	jmp    f0100f81 <boot_map_region+0x64>
f0100f71:	89 d7                	mov    %edx,%edi
f0100f73:	be 00 00 00 00       	mov    $0x0,%esi
		ptep = pgdir_walk(pgdir,(void*)(va+i),1);
		if(ptep != NULL){
			*ptep = ((pa+i) | perm | PTE_P);
f0100f78:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f7b:	83 c8 01             	or     $0x1,%eax
f0100f7e:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100f81:	89 f3                	mov    %esi,%ebx
{
	// Fill this function in
	pte_t *ptep;
	if(va+size < va)
		panic("boot_map_region: Kernel panicked ");
	for(int i=0; i<size; i+=PGSIZE) {
f0100f83:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f0100f86:	77 c1                	ja     f0100f49 <boot_map_region+0x2c>
		ptep = pgdir_walk(pgdir,(void*)(va+i),1);
		if(ptep != NULL){
			*ptep = ((pa+i) | perm | PTE_P);
		}
	}
}
f0100f88:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f8b:	5b                   	pop    %ebx
f0100f8c:	5e                   	pop    %esi
f0100f8d:	5f                   	pop    %edi
f0100f8e:	5d                   	pop    %ebp
f0100f8f:	c3                   	ret    

f0100f90 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f90:	55                   	push   %ebp
f0100f91:	89 e5                	mov    %esp,%ebp
f0100f93:	53                   	push   %ebx
f0100f94:	83 ec 08             	sub    $0x8,%esp
f0100f97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *ptep;
	struct PageInfo *pp=NULL;
	ptep = pgdir_walk(pgdir,va,0);
f0100f9a:	6a 00                	push   $0x0
f0100f9c:	ff 75 0c             	pushl  0xc(%ebp)
f0100f9f:	ff 75 08             	pushl  0x8(%ebp)
f0100fa2:	e8 e3 fe ff ff       	call   f0100e8a <pgdir_walk>
	if(ptep == NULL) {
f0100fa7:	83 c4 10             	add    $0x10,%esp
f0100faa:	85 c0                	test   %eax,%eax
f0100fac:	74 39                	je     f0100fe7 <page_lookup+0x57>
f0100fae:	89 c1                	mov    %eax,%ecx
		return NULL;
	}else if((*ptep & PTE_P) != PTE_P) {
f0100fb0:	8b 10                	mov    (%eax),%edx
f0100fb2:	f6 c2 01             	test   $0x1,%dl
f0100fb5:	74 37                	je     f0100fee <page_lookup+0x5e>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fb7:	c1 ea 0c             	shr    $0xc,%edx
f0100fba:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f0100fc0:	72 14                	jb     f0100fd6 <page_lookup+0x46>
		panic("pa2page called with invalid pa");
f0100fc2:	83 ec 04             	sub    $0x4,%esp
f0100fc5:	68 d4 4c 10 f0       	push   $0xf0104cd4
f0100fca:	6a 4f                	push   $0x4f
f0100fcc:	68 3f 48 10 f0       	push   $0xf010483f
f0100fd1:	e8 ca f0 ff ff       	call   f01000a0 <_panic>
	return &pages[PGNUM(pa)];
f0100fd6:	a1 4c 4c 17 f0       	mov    0xf0174c4c,%eax
f0100fdb:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		return NULL;
	}else{
		pp = pa2page(PTE_ADDR(*ptep));
		if(*pte_store != 0) {
f0100fde:	83 3b 00             	cmpl   $0x0,(%ebx)
f0100fe1:	74 10                	je     f0100ff3 <page_lookup+0x63>
			*pte_store = ptep; 
f0100fe3:	89 0b                	mov    %ecx,(%ebx)
f0100fe5:	eb 0c                	jmp    f0100ff3 <page_lookup+0x63>
	// Fill this function in
	pte_t *ptep;
	struct PageInfo *pp=NULL;
	ptep = pgdir_walk(pgdir,va,0);
	if(ptep == NULL) {
		return NULL;
f0100fe7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fec:	eb 05                	jmp    f0100ff3 <page_lookup+0x63>
	}else if((*ptep & PTE_P) != PTE_P) {
		return NULL;
f0100fee:	b8 00 00 00 00       	mov    $0x0,%eax
		if(*pte_store != 0) {
			*pte_store = ptep; 
		}
	}
	return pp;
}
f0100ff3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ff6:	c9                   	leave  
f0100ff7:	c3                   	ret    

f0100ff8 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100ff8:	55                   	push   %ebp
f0100ff9:	89 e5                	mov    %esp,%ebp
f0100ffb:	53                   	push   %ebx
f0100ffc:	83 ec 18             	sub    $0x18,%esp
f0100fff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	//pte_t **ptep_store;
	pte_t *ptep;
	struct PageInfo *pp=NULL;
	pp = page_lookup(pgdir, va, &ptep);
f0101002:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101005:	50                   	push   %eax
f0101006:	53                   	push   %ebx
f0101007:	ff 75 08             	pushl  0x8(%ebp)
f010100a:	e8 81 ff ff ff       	call   f0100f90 <page_lookup>
	if(pp != NULL) {
f010100f:	83 c4 10             	add    $0x10,%esp
f0101012:	85 c0                	test   %eax,%eax
f0101014:	74 18                	je     f010102e <page_remove+0x36>
		page_decref(pp);
f0101016:	83 ec 0c             	sub    $0xc,%esp
f0101019:	50                   	push   %eax
f010101a:	e8 44 fe ff ff       	call   f0100e63 <page_decref>
		*ptep = 0x0;
f010101f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101022:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101028:	0f 01 3b             	invlpg (%ebx)
f010102b:	83 c4 10             	add    $0x10,%esp
		tlb_invalidate(pgdir,va);	
	}
}
f010102e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101031:	c9                   	leave  
f0101032:	c3                   	ret    

f0101033 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101033:	55                   	push   %ebp
f0101034:	89 e5                	mov    %esp,%ebp
f0101036:	57                   	push   %edi
f0101037:	56                   	push   %esi
f0101038:	53                   	push   %ebx
f0101039:	83 ec 10             	sub    $0x10,%esp
f010103c:	8b 75 08             	mov    0x8(%ebp),%esi
f010103f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *ptep;

	ptep = pgdir_walk(pgdir, va, 1);
f0101042:	6a 01                	push   $0x1
f0101044:	ff 75 10             	pushl  0x10(%ebp)
f0101047:	56                   	push   %esi
f0101048:	e8 3d fe ff ff       	call   f0100e8a <pgdir_walk>
	if(ptep == NULL) {
f010104d:	83 c4 10             	add    $0x10,%esp
f0101050:	85 c0                	test   %eax,%eax
f0101052:	74 44                	je     f0101098 <page_insert+0x65>
f0101054:	89 c7                	mov    %eax,%edi
		
		return (-E_NO_MEM);
	}
	pp->pp_ref++;
f0101056:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if((*ptep & PTE_P) == PTE_P) {
f010105b:	f6 00 01             	testb  $0x1,(%eax)
f010105e:	74 0f                	je     f010106f <page_insert+0x3c>
		page_remove(pgdir,va);
f0101060:	83 ec 08             	sub    $0x8,%esp
f0101063:	ff 75 10             	pushl  0x10(%ebp)
f0101066:	56                   	push   %esi
f0101067:	e8 8c ff ff ff       	call   f0100ff8 <page_remove>
f010106c:	83 c4 10             	add    $0x10,%esp
	}
	*ptep = (page2pa(pp) | perm | PTE_P);
f010106f:	2b 1d 4c 4c 17 f0    	sub    0xf0174c4c,%ebx
f0101075:	c1 fb 03             	sar    $0x3,%ebx
f0101078:	c1 e3 0c             	shl    $0xc,%ebx
f010107b:	8b 45 14             	mov    0x14(%ebp),%eax
f010107e:	83 c8 01             	or     $0x1,%eax
f0101081:	09 c3                	or     %eax,%ebx
f0101083:	89 1f                	mov    %ebx,(%edi)
	pgdir[PDX(va)] |= perm;
f0101085:	8b 45 10             	mov    0x10(%ebp),%eax
f0101088:	c1 e8 16             	shr    $0x16,%eax
f010108b:	8b 55 14             	mov    0x14(%ebp),%edx
f010108e:	09 14 86             	or     %edx,(%esi,%eax,4)
	return 0;
f0101091:	b8 00 00 00 00       	mov    $0x0,%eax
f0101096:	eb 05                	jmp    f010109d <page_insert+0x6a>
	pte_t *ptep;

	ptep = pgdir_walk(pgdir, va, 1);
	if(ptep == NULL) {
		
		return (-E_NO_MEM);
f0101098:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir,va);
	}
	*ptep = (page2pa(pp) | perm | PTE_P);
	pgdir[PDX(va)] |= perm;
	return 0;
}
f010109d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010a0:	5b                   	pop    %ebx
f01010a1:	5e                   	pop    %esi
f01010a2:	5f                   	pop    %edi
f01010a3:	5d                   	pop    %ebp
f01010a4:	c3                   	ret    

f01010a5 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01010a5:	55                   	push   %ebp
f01010a6:	89 e5                	mov    %esp,%ebp
f01010a8:	57                   	push   %edi
f01010a9:	56                   	push   %esi
f01010aa:	53                   	push   %ebx
f01010ab:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01010ae:	6a 15                	push   $0x15
f01010b0:	e8 85 1e 00 00       	call   f0102f3a <mc146818_read>
f01010b5:	89 c3                	mov    %eax,%ebx
f01010b7:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01010be:	e8 77 1e 00 00       	call   f0102f3a <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01010c3:	c1 e0 08             	shl    $0x8,%eax
f01010c6:	09 d8                	or     %ebx,%eax
f01010c8:	c1 e0 0a             	shl    $0xa,%eax
f01010cb:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01010d1:	85 c0                	test   %eax,%eax
f01010d3:	0f 48 c2             	cmovs  %edx,%eax
f01010d6:	c1 f8 0c             	sar    $0xc,%eax
f01010d9:	a3 80 3f 17 f0       	mov    %eax,0xf0173f80
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01010de:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01010e5:	e8 50 1e 00 00       	call   f0102f3a <mc146818_read>
f01010ea:	89 c6                	mov    %eax,%esi
f01010ec:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01010f3:	e8 42 1e 00 00       	call   f0102f3a <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01010f8:	c1 e0 08             	shl    $0x8,%eax
f01010fb:	89 c3                	mov    %eax,%ebx
f01010fd:	09 f3                	or     %esi,%ebx
f01010ff:	c1 e3 0a             	shl    $0xa,%ebx
f0101102:	8d 93 ff 0f 00 00    	lea    0xfff(%ebx),%edx
f0101108:	83 c4 10             	add    $0x10,%esp
f010110b:	85 db                	test   %ebx,%ebx
f010110d:	0f 48 da             	cmovs  %edx,%ebx
f0101110:	c1 fb 0c             	sar    $0xc,%ebx

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101113:	85 db                	test   %ebx,%ebx
f0101115:	74 0d                	je     f0101124 <mem_init+0x7f>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101117:	8d 83 00 01 00 00    	lea    0x100(%ebx),%eax
f010111d:	a3 44 4c 17 f0       	mov    %eax,0xf0174c44
f0101122:	eb 0a                	jmp    f010112e <mem_init+0x89>
	else
		npages = npages_basemem;
f0101124:	a1 80 3f 17 f0       	mov    0xf0173f80,%eax
f0101129:	a3 44 4c 17 f0       	mov    %eax,0xf0174c44
	cprintf("Amount of physical memory (in pages) %u\n",npages);
f010112e:	83 ec 08             	sub    $0x8,%esp
f0101131:	ff 35 44 4c 17 f0    	pushl  0xf0174c44
f0101137:	68 f4 4c 10 f0       	push   $0xf0104cf4
f010113c:	e8 60 1e 00 00       	call   f0102fa1 <cprintf>
	cprintf("Page Size is %u\n", PGSIZE);
f0101141:	83 c4 08             	add    $0x8,%esp
f0101144:	68 00 10 00 00       	push   $0x1000
f0101149:	68 e9 48 10 f0       	push   $0xf01048e9
f010114e:	e8 4e 1e 00 00       	call   f0102fa1 <cprintf>
	cprintf("Amount of base memory (in pages) is %u\n\n", npages_basemem);
f0101153:	83 c4 08             	add    $0x8,%esp
f0101156:	ff 35 80 3f 17 f0    	pushl  0xf0173f80
f010115c:	68 20 4d 10 f0       	push   $0xf0104d20
f0101161:	e8 3b 1e 00 00       	call   f0102fa1 <cprintf>
	
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101166:	c1 e3 0c             	shl    $0xc,%ebx
f0101169:	c1 eb 0a             	shr    $0xa,%ebx
f010116c:	53                   	push   %ebx
f010116d:	a1 80 3f 17 f0       	mov    0xf0173f80,%eax
f0101172:	c1 e0 0c             	shl    $0xc,%eax
f0101175:	c1 e8 0a             	shr    $0xa,%eax
f0101178:	50                   	push   %eax
f0101179:	a1 44 4c 17 f0       	mov    0xf0174c44,%eax
f010117e:	c1 e0 0c             	shl    $0xc,%eax
f0101181:	c1 e8 0a             	shr    $0xa,%eax
f0101184:	50                   	push   %eax
f0101185:	68 4c 4d 10 f0       	push   $0xf0104d4c
f010118a:	e8 12 1e 00 00       	call   f0102fa1 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010118f:	83 c4 20             	add    $0x20,%esp
f0101192:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101197:	e8 57 f7 ff ff       	call   f01008f3 <boot_alloc>
f010119c:	a3 48 4c 17 f0       	mov    %eax,0xf0174c48
	memset(kern_pgdir, 0, PGSIZE);
f01011a1:	83 ec 04             	sub    $0x4,%esp
f01011a4:	68 00 10 00 00       	push   $0x1000
f01011a9:	6a 00                	push   $0x0
f01011ab:	50                   	push   %eax
f01011ac:	e8 64 2c 00 00       	call   f0103e15 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01011b1:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01011b6:	83 c4 10             	add    $0x10,%esp
f01011b9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01011be:	77 15                	ja     f01011d5 <mem_init+0x130>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01011c0:	50                   	push   %eax
f01011c1:	68 88 4d 10 f0       	push   $0xf0104d88
f01011c6:	68 a7 00 00 00       	push   $0xa7
f01011cb:	68 33 48 10 f0       	push   $0xf0104833
f01011d0:	e8 cb ee ff ff       	call   f01000a0 <_panic>
f01011d5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01011db:	83 ca 05             	or     $0x5,%edx
f01011de:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	
	pages = boot_alloc (npages * sizeof (struct PageInfo));
f01011e4:	a1 44 4c 17 f0       	mov    0xf0174c44,%eax
f01011e9:	c1 e0 03             	shl    $0x3,%eax
f01011ec:	e8 02 f7 ff ff       	call   f01008f3 <boot_alloc>
f01011f1:	a3 4c 4c 17 f0       	mov    %eax,0xf0174c4c
	
	memset(pages, 0 , npages * sizeof (struct PageInfo));
f01011f6:	83 ec 04             	sub    $0x4,%esp
f01011f9:	8b 3d 44 4c 17 f0    	mov    0xf0174c44,%edi
f01011ff:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0101206:	52                   	push   %edx
f0101207:	6a 00                	push   $0x0
f0101209:	50                   	push   %eax
f010120a:	e8 06 2c 00 00       	call   f0103e15 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	
	envs = (struct Env *) boot_alloc(NENV*sizeof(struct Env));
f010120f:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101214:	e8 da f6 ff ff       	call   f01008f3 <boot_alloc>
f0101219:	a3 88 3f 17 f0       	mov    %eax,0xf0173f88
	
	memset(envs, 0, NENV*sizeof(struct Env));
f010121e:	83 c4 0c             	add    $0xc,%esp
f0101221:	68 00 80 01 00       	push   $0x18000
f0101226:	6a 00                	push   $0x0
f0101228:	50                   	push   %eax
f0101229:	e8 e7 2b 00 00       	call   f0103e15 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010122e:	e8 df fa ff ff       	call   f0100d12 <page_init>

	check_page_free_list(1);
f0101233:	b8 01 00 00 00       	mov    $0x1,%eax
f0101238:	e8 21 f8 ff ff       	call   f0100a5e <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010123d:	83 c4 10             	add    $0x10,%esp
f0101240:	83 3d 4c 4c 17 f0 00 	cmpl   $0x0,0xf0174c4c
f0101247:	75 17                	jne    f0101260 <mem_init+0x1bb>
		panic("'pages' is a null pointer!");
f0101249:	83 ec 04             	sub    $0x4,%esp
f010124c:	68 fa 48 10 f0       	push   $0xf01048fa
f0101251:	68 bd 02 00 00       	push   $0x2bd
f0101256:	68 33 48 10 f0       	push   $0xf0104833
f010125b:	e8 40 ee ff ff       	call   f01000a0 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101260:	a1 7c 3f 17 f0       	mov    0xf0173f7c,%eax
f0101265:	bb 00 00 00 00       	mov    $0x0,%ebx
f010126a:	eb 05                	jmp    f0101271 <mem_init+0x1cc>
		++nfree;
f010126c:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010126f:	8b 00                	mov    (%eax),%eax
f0101271:	85 c0                	test   %eax,%eax
f0101273:	75 f7                	jne    f010126c <mem_init+0x1c7>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101275:	83 ec 0c             	sub    $0xc,%esp
f0101278:	6a 00                	push   $0x0
f010127a:	e8 39 fb ff ff       	call   f0100db8 <page_alloc>
f010127f:	89 c7                	mov    %eax,%edi
f0101281:	83 c4 10             	add    $0x10,%esp
f0101284:	85 c0                	test   %eax,%eax
f0101286:	75 19                	jne    f01012a1 <mem_init+0x1fc>
f0101288:	68 15 49 10 f0       	push   $0xf0104915
f010128d:	68 59 48 10 f0       	push   $0xf0104859
f0101292:	68 c5 02 00 00       	push   $0x2c5
f0101297:	68 33 48 10 f0       	push   $0xf0104833
f010129c:	e8 ff ed ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01012a1:	83 ec 0c             	sub    $0xc,%esp
f01012a4:	6a 00                	push   $0x0
f01012a6:	e8 0d fb ff ff       	call   f0100db8 <page_alloc>
f01012ab:	89 c6                	mov    %eax,%esi
f01012ad:	83 c4 10             	add    $0x10,%esp
f01012b0:	85 c0                	test   %eax,%eax
f01012b2:	75 19                	jne    f01012cd <mem_init+0x228>
f01012b4:	68 2b 49 10 f0       	push   $0xf010492b
f01012b9:	68 59 48 10 f0       	push   $0xf0104859
f01012be:	68 c6 02 00 00       	push   $0x2c6
f01012c3:	68 33 48 10 f0       	push   $0xf0104833
f01012c8:	e8 d3 ed ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01012cd:	83 ec 0c             	sub    $0xc,%esp
f01012d0:	6a 00                	push   $0x0
f01012d2:	e8 e1 fa ff ff       	call   f0100db8 <page_alloc>
f01012d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01012da:	83 c4 10             	add    $0x10,%esp
f01012dd:	85 c0                	test   %eax,%eax
f01012df:	75 19                	jne    f01012fa <mem_init+0x255>
f01012e1:	68 41 49 10 f0       	push   $0xf0104941
f01012e6:	68 59 48 10 f0       	push   $0xf0104859
f01012eb:	68 c7 02 00 00       	push   $0x2c7
f01012f0:	68 33 48 10 f0       	push   $0xf0104833
f01012f5:	e8 a6 ed ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01012fa:	39 f7                	cmp    %esi,%edi
f01012fc:	75 19                	jne    f0101317 <mem_init+0x272>
f01012fe:	68 57 49 10 f0       	push   $0xf0104957
f0101303:	68 59 48 10 f0       	push   $0xf0104859
f0101308:	68 ca 02 00 00       	push   $0x2ca
f010130d:	68 33 48 10 f0       	push   $0xf0104833
f0101312:	e8 89 ed ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101317:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010131a:	39 c6                	cmp    %eax,%esi
f010131c:	74 04                	je     f0101322 <mem_init+0x27d>
f010131e:	39 c7                	cmp    %eax,%edi
f0101320:	75 19                	jne    f010133b <mem_init+0x296>
f0101322:	68 ac 4d 10 f0       	push   $0xf0104dac
f0101327:	68 59 48 10 f0       	push   $0xf0104859
f010132c:	68 cb 02 00 00       	push   $0x2cb
f0101331:	68 33 48 10 f0       	push   $0xf0104833
f0101336:	e8 65 ed ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010133b:	8b 0d 4c 4c 17 f0    	mov    0xf0174c4c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101341:	8b 15 44 4c 17 f0    	mov    0xf0174c44,%edx
f0101347:	c1 e2 0c             	shl    $0xc,%edx
f010134a:	89 f8                	mov    %edi,%eax
f010134c:	29 c8                	sub    %ecx,%eax
f010134e:	c1 f8 03             	sar    $0x3,%eax
f0101351:	c1 e0 0c             	shl    $0xc,%eax
f0101354:	39 d0                	cmp    %edx,%eax
f0101356:	72 19                	jb     f0101371 <mem_init+0x2cc>
f0101358:	68 69 49 10 f0       	push   $0xf0104969
f010135d:	68 59 48 10 f0       	push   $0xf0104859
f0101362:	68 cc 02 00 00       	push   $0x2cc
f0101367:	68 33 48 10 f0       	push   $0xf0104833
f010136c:	e8 2f ed ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101371:	89 f0                	mov    %esi,%eax
f0101373:	29 c8                	sub    %ecx,%eax
f0101375:	c1 f8 03             	sar    $0x3,%eax
f0101378:	c1 e0 0c             	shl    $0xc,%eax
f010137b:	39 c2                	cmp    %eax,%edx
f010137d:	77 19                	ja     f0101398 <mem_init+0x2f3>
f010137f:	68 86 49 10 f0       	push   $0xf0104986
f0101384:	68 59 48 10 f0       	push   $0xf0104859
f0101389:	68 cd 02 00 00       	push   $0x2cd
f010138e:	68 33 48 10 f0       	push   $0xf0104833
f0101393:	e8 08 ed ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101398:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010139b:	29 c8                	sub    %ecx,%eax
f010139d:	c1 f8 03             	sar    $0x3,%eax
f01013a0:	c1 e0 0c             	shl    $0xc,%eax
f01013a3:	39 c2                	cmp    %eax,%edx
f01013a5:	77 19                	ja     f01013c0 <mem_init+0x31b>
f01013a7:	68 a3 49 10 f0       	push   $0xf01049a3
f01013ac:	68 59 48 10 f0       	push   $0xf0104859
f01013b1:	68 ce 02 00 00       	push   $0x2ce
f01013b6:	68 33 48 10 f0       	push   $0xf0104833
f01013bb:	e8 e0 ec ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01013c0:	a1 7c 3f 17 f0       	mov    0xf0173f7c,%eax
f01013c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01013c8:	c7 05 7c 3f 17 f0 00 	movl   $0x0,0xf0173f7c
f01013cf:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01013d2:	83 ec 0c             	sub    $0xc,%esp
f01013d5:	6a 00                	push   $0x0
f01013d7:	e8 dc f9 ff ff       	call   f0100db8 <page_alloc>
f01013dc:	83 c4 10             	add    $0x10,%esp
f01013df:	85 c0                	test   %eax,%eax
f01013e1:	74 19                	je     f01013fc <mem_init+0x357>
f01013e3:	68 c0 49 10 f0       	push   $0xf01049c0
f01013e8:	68 59 48 10 f0       	push   $0xf0104859
f01013ed:	68 d5 02 00 00       	push   $0x2d5
f01013f2:	68 33 48 10 f0       	push   $0xf0104833
f01013f7:	e8 a4 ec ff ff       	call   f01000a0 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01013fc:	83 ec 0c             	sub    $0xc,%esp
f01013ff:	57                   	push   %edi
f0101400:	e8 23 fa ff ff       	call   f0100e28 <page_free>
	page_free(pp1);
f0101405:	89 34 24             	mov    %esi,(%esp)
f0101408:	e8 1b fa ff ff       	call   f0100e28 <page_free>
	page_free(pp2);
f010140d:	83 c4 04             	add    $0x4,%esp
f0101410:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101413:	e8 10 fa ff ff       	call   f0100e28 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101418:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010141f:	e8 94 f9 ff ff       	call   f0100db8 <page_alloc>
f0101424:	89 c6                	mov    %eax,%esi
f0101426:	83 c4 10             	add    $0x10,%esp
f0101429:	85 c0                	test   %eax,%eax
f010142b:	75 19                	jne    f0101446 <mem_init+0x3a1>
f010142d:	68 15 49 10 f0       	push   $0xf0104915
f0101432:	68 59 48 10 f0       	push   $0xf0104859
f0101437:	68 dc 02 00 00       	push   $0x2dc
f010143c:	68 33 48 10 f0       	push   $0xf0104833
f0101441:	e8 5a ec ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101446:	83 ec 0c             	sub    $0xc,%esp
f0101449:	6a 00                	push   $0x0
f010144b:	e8 68 f9 ff ff       	call   f0100db8 <page_alloc>
f0101450:	89 c7                	mov    %eax,%edi
f0101452:	83 c4 10             	add    $0x10,%esp
f0101455:	85 c0                	test   %eax,%eax
f0101457:	75 19                	jne    f0101472 <mem_init+0x3cd>
f0101459:	68 2b 49 10 f0       	push   $0xf010492b
f010145e:	68 59 48 10 f0       	push   $0xf0104859
f0101463:	68 dd 02 00 00       	push   $0x2dd
f0101468:	68 33 48 10 f0       	push   $0xf0104833
f010146d:	e8 2e ec ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101472:	83 ec 0c             	sub    $0xc,%esp
f0101475:	6a 00                	push   $0x0
f0101477:	e8 3c f9 ff ff       	call   f0100db8 <page_alloc>
f010147c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010147f:	83 c4 10             	add    $0x10,%esp
f0101482:	85 c0                	test   %eax,%eax
f0101484:	75 19                	jne    f010149f <mem_init+0x3fa>
f0101486:	68 41 49 10 f0       	push   $0xf0104941
f010148b:	68 59 48 10 f0       	push   $0xf0104859
f0101490:	68 de 02 00 00       	push   $0x2de
f0101495:	68 33 48 10 f0       	push   $0xf0104833
f010149a:	e8 01 ec ff ff       	call   f01000a0 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010149f:	39 fe                	cmp    %edi,%esi
f01014a1:	75 19                	jne    f01014bc <mem_init+0x417>
f01014a3:	68 57 49 10 f0       	push   $0xf0104957
f01014a8:	68 59 48 10 f0       	push   $0xf0104859
f01014ad:	68 e0 02 00 00       	push   $0x2e0
f01014b2:	68 33 48 10 f0       	push   $0xf0104833
f01014b7:	e8 e4 eb ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014bf:	39 c7                	cmp    %eax,%edi
f01014c1:	74 04                	je     f01014c7 <mem_init+0x422>
f01014c3:	39 c6                	cmp    %eax,%esi
f01014c5:	75 19                	jne    f01014e0 <mem_init+0x43b>
f01014c7:	68 ac 4d 10 f0       	push   $0xf0104dac
f01014cc:	68 59 48 10 f0       	push   $0xf0104859
f01014d1:	68 e1 02 00 00       	push   $0x2e1
f01014d6:	68 33 48 10 f0       	push   $0xf0104833
f01014db:	e8 c0 eb ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f01014e0:	83 ec 0c             	sub    $0xc,%esp
f01014e3:	6a 00                	push   $0x0
f01014e5:	e8 ce f8 ff ff       	call   f0100db8 <page_alloc>
f01014ea:	83 c4 10             	add    $0x10,%esp
f01014ed:	85 c0                	test   %eax,%eax
f01014ef:	74 19                	je     f010150a <mem_init+0x465>
f01014f1:	68 c0 49 10 f0       	push   $0xf01049c0
f01014f6:	68 59 48 10 f0       	push   $0xf0104859
f01014fb:	68 e2 02 00 00       	push   $0x2e2
f0101500:	68 33 48 10 f0       	push   $0xf0104833
f0101505:	e8 96 eb ff ff       	call   f01000a0 <_panic>
f010150a:	89 f0                	mov    %esi,%eax
f010150c:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0101512:	c1 f8 03             	sar    $0x3,%eax
f0101515:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101518:	89 c2                	mov    %eax,%edx
f010151a:	c1 ea 0c             	shr    $0xc,%edx
f010151d:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f0101523:	72 12                	jb     f0101537 <mem_init+0x492>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101525:	50                   	push   %eax
f0101526:	68 98 4b 10 f0       	push   $0xf0104b98
f010152b:	6a 56                	push   $0x56
f010152d:	68 3f 48 10 f0       	push   $0xf010483f
f0101532:	e8 69 eb ff ff       	call   f01000a0 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101537:	83 ec 04             	sub    $0x4,%esp
f010153a:	68 00 10 00 00       	push   $0x1000
f010153f:	6a 01                	push   $0x1
f0101541:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101546:	50                   	push   %eax
f0101547:	e8 c9 28 00 00       	call   f0103e15 <memset>
	page_free(pp0);
f010154c:	89 34 24             	mov    %esi,(%esp)
f010154f:	e8 d4 f8 ff ff       	call   f0100e28 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101554:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010155b:	e8 58 f8 ff ff       	call   f0100db8 <page_alloc>
f0101560:	83 c4 10             	add    $0x10,%esp
f0101563:	85 c0                	test   %eax,%eax
f0101565:	75 19                	jne    f0101580 <mem_init+0x4db>
f0101567:	68 cf 49 10 f0       	push   $0xf01049cf
f010156c:	68 59 48 10 f0       	push   $0xf0104859
f0101571:	68 e7 02 00 00       	push   $0x2e7
f0101576:	68 33 48 10 f0       	push   $0xf0104833
f010157b:	e8 20 eb ff ff       	call   f01000a0 <_panic>
	assert(pp && pp0 == pp);
f0101580:	39 c6                	cmp    %eax,%esi
f0101582:	74 19                	je     f010159d <mem_init+0x4f8>
f0101584:	68 ed 49 10 f0       	push   $0xf01049ed
f0101589:	68 59 48 10 f0       	push   $0xf0104859
f010158e:	68 e8 02 00 00       	push   $0x2e8
f0101593:	68 33 48 10 f0       	push   $0xf0104833
f0101598:	e8 03 eb ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010159d:	89 f0                	mov    %esi,%eax
f010159f:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f01015a5:	c1 f8 03             	sar    $0x3,%eax
f01015a8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015ab:	89 c2                	mov    %eax,%edx
f01015ad:	c1 ea 0c             	shr    $0xc,%edx
f01015b0:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f01015b6:	72 12                	jb     f01015ca <mem_init+0x525>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015b8:	50                   	push   %eax
f01015b9:	68 98 4b 10 f0       	push   $0xf0104b98
f01015be:	6a 56                	push   $0x56
f01015c0:	68 3f 48 10 f0       	push   $0xf010483f
f01015c5:	e8 d6 ea ff ff       	call   f01000a0 <_panic>
f01015ca:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01015d0:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01015d6:	80 38 00             	cmpb   $0x0,(%eax)
f01015d9:	74 19                	je     f01015f4 <mem_init+0x54f>
f01015db:	68 fd 49 10 f0       	push   $0xf01049fd
f01015e0:	68 59 48 10 f0       	push   $0xf0104859
f01015e5:	68 eb 02 00 00       	push   $0x2eb
f01015ea:	68 33 48 10 f0       	push   $0xf0104833
f01015ef:	e8 ac ea ff ff       	call   f01000a0 <_panic>
f01015f4:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01015f7:	39 d0                	cmp    %edx,%eax
f01015f9:	75 db                	jne    f01015d6 <mem_init+0x531>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01015fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015fe:	a3 7c 3f 17 f0       	mov    %eax,0xf0173f7c

	// free the pages we took
	page_free(pp0);
f0101603:	83 ec 0c             	sub    $0xc,%esp
f0101606:	56                   	push   %esi
f0101607:	e8 1c f8 ff ff       	call   f0100e28 <page_free>
	page_free(pp1);
f010160c:	89 3c 24             	mov    %edi,(%esp)
f010160f:	e8 14 f8 ff ff       	call   f0100e28 <page_free>
	page_free(pp2);
f0101614:	83 c4 04             	add    $0x4,%esp
f0101617:	ff 75 d4             	pushl  -0x2c(%ebp)
f010161a:	e8 09 f8 ff ff       	call   f0100e28 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010161f:	a1 7c 3f 17 f0       	mov    0xf0173f7c,%eax
f0101624:	83 c4 10             	add    $0x10,%esp
f0101627:	eb 05                	jmp    f010162e <mem_init+0x589>
		--nfree;
f0101629:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010162c:	8b 00                	mov    (%eax),%eax
f010162e:	85 c0                	test   %eax,%eax
f0101630:	75 f7                	jne    f0101629 <mem_init+0x584>
		--nfree;
	assert(nfree == 0);
f0101632:	85 db                	test   %ebx,%ebx
f0101634:	74 19                	je     f010164f <mem_init+0x5aa>
f0101636:	68 07 4a 10 f0       	push   $0xf0104a07
f010163b:	68 59 48 10 f0       	push   $0xf0104859
f0101640:	68 f8 02 00 00       	push   $0x2f8
f0101645:	68 33 48 10 f0       	push   $0xf0104833
f010164a:	e8 51 ea ff ff       	call   f01000a0 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010164f:	83 ec 0c             	sub    $0xc,%esp
f0101652:	68 cc 4d 10 f0       	push   $0xf0104dcc
f0101657:	e8 45 19 00 00       	call   f0102fa1 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010165c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101663:	e8 50 f7 ff ff       	call   f0100db8 <page_alloc>
f0101668:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010166b:	83 c4 10             	add    $0x10,%esp
f010166e:	85 c0                	test   %eax,%eax
f0101670:	75 19                	jne    f010168b <mem_init+0x5e6>
f0101672:	68 15 49 10 f0       	push   $0xf0104915
f0101677:	68 59 48 10 f0       	push   $0xf0104859
f010167c:	68 56 03 00 00       	push   $0x356
f0101681:	68 33 48 10 f0       	push   $0xf0104833
f0101686:	e8 15 ea ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f010168b:	83 ec 0c             	sub    $0xc,%esp
f010168e:	6a 00                	push   $0x0
f0101690:	e8 23 f7 ff ff       	call   f0100db8 <page_alloc>
f0101695:	89 c3                	mov    %eax,%ebx
f0101697:	83 c4 10             	add    $0x10,%esp
f010169a:	85 c0                	test   %eax,%eax
f010169c:	75 19                	jne    f01016b7 <mem_init+0x612>
f010169e:	68 2b 49 10 f0       	push   $0xf010492b
f01016a3:	68 59 48 10 f0       	push   $0xf0104859
f01016a8:	68 57 03 00 00       	push   $0x357
f01016ad:	68 33 48 10 f0       	push   $0xf0104833
f01016b2:	e8 e9 e9 ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01016b7:	83 ec 0c             	sub    $0xc,%esp
f01016ba:	6a 00                	push   $0x0
f01016bc:	e8 f7 f6 ff ff       	call   f0100db8 <page_alloc>
f01016c1:	89 c6                	mov    %eax,%esi
f01016c3:	83 c4 10             	add    $0x10,%esp
f01016c6:	85 c0                	test   %eax,%eax
f01016c8:	75 19                	jne    f01016e3 <mem_init+0x63e>
f01016ca:	68 41 49 10 f0       	push   $0xf0104941
f01016cf:	68 59 48 10 f0       	push   $0xf0104859
f01016d4:	68 58 03 00 00       	push   $0x358
f01016d9:	68 33 48 10 f0       	push   $0xf0104833
f01016de:	e8 bd e9 ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016e3:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01016e6:	75 19                	jne    f0101701 <mem_init+0x65c>
f01016e8:	68 57 49 10 f0       	push   $0xf0104957
f01016ed:	68 59 48 10 f0       	push   $0xf0104859
f01016f2:	68 5b 03 00 00       	push   $0x35b
f01016f7:	68 33 48 10 f0       	push   $0xf0104833
f01016fc:	e8 9f e9 ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101701:	39 c3                	cmp    %eax,%ebx
f0101703:	74 05                	je     f010170a <mem_init+0x665>
f0101705:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101708:	75 19                	jne    f0101723 <mem_init+0x67e>
f010170a:	68 ac 4d 10 f0       	push   $0xf0104dac
f010170f:	68 59 48 10 f0       	push   $0xf0104859
f0101714:	68 5c 03 00 00       	push   $0x35c
f0101719:	68 33 48 10 f0       	push   $0xf0104833
f010171e:	e8 7d e9 ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101723:	a1 7c 3f 17 f0       	mov    0xf0173f7c,%eax
f0101728:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010172b:	c7 05 7c 3f 17 f0 00 	movl   $0x0,0xf0173f7c
f0101732:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101735:	83 ec 0c             	sub    $0xc,%esp
f0101738:	6a 00                	push   $0x0
f010173a:	e8 79 f6 ff ff       	call   f0100db8 <page_alloc>
f010173f:	83 c4 10             	add    $0x10,%esp
f0101742:	85 c0                	test   %eax,%eax
f0101744:	74 19                	je     f010175f <mem_init+0x6ba>
f0101746:	68 c0 49 10 f0       	push   $0xf01049c0
f010174b:	68 59 48 10 f0       	push   $0xf0104859
f0101750:	68 63 03 00 00       	push   $0x363
f0101755:	68 33 48 10 f0       	push   $0xf0104833
f010175a:	e8 41 e9 ff ff       	call   f01000a0 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010175f:	83 ec 04             	sub    $0x4,%esp
f0101762:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101765:	50                   	push   %eax
f0101766:	6a 00                	push   $0x0
f0101768:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f010176e:	e8 1d f8 ff ff       	call   f0100f90 <page_lookup>
f0101773:	83 c4 10             	add    $0x10,%esp
f0101776:	85 c0                	test   %eax,%eax
f0101778:	74 19                	je     f0101793 <mem_init+0x6ee>
f010177a:	68 ec 4d 10 f0       	push   $0xf0104dec
f010177f:	68 59 48 10 f0       	push   $0xf0104859
f0101784:	68 66 03 00 00       	push   $0x366
f0101789:	68 33 48 10 f0       	push   $0xf0104833
f010178e:	e8 0d e9 ff ff       	call   f01000a0 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101793:	6a 02                	push   $0x2
f0101795:	6a 00                	push   $0x0
f0101797:	53                   	push   %ebx
f0101798:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f010179e:	e8 90 f8 ff ff       	call   f0101033 <page_insert>
f01017a3:	83 c4 10             	add    $0x10,%esp
f01017a6:	85 c0                	test   %eax,%eax
f01017a8:	78 19                	js     f01017c3 <mem_init+0x71e>
f01017aa:	68 24 4e 10 f0       	push   $0xf0104e24
f01017af:	68 59 48 10 f0       	push   $0xf0104859
f01017b4:	68 69 03 00 00       	push   $0x369
f01017b9:	68 33 48 10 f0       	push   $0xf0104833
f01017be:	e8 dd e8 ff ff       	call   f01000a0 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01017c3:	83 ec 0c             	sub    $0xc,%esp
f01017c6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017c9:	e8 5a f6 ff ff       	call   f0100e28 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01017ce:	6a 02                	push   $0x2
f01017d0:	6a 00                	push   $0x0
f01017d2:	53                   	push   %ebx
f01017d3:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f01017d9:	e8 55 f8 ff ff       	call   f0101033 <page_insert>
f01017de:	83 c4 20             	add    $0x20,%esp
f01017e1:	85 c0                	test   %eax,%eax
f01017e3:	74 19                	je     f01017fe <mem_init+0x759>
f01017e5:	68 54 4e 10 f0       	push   $0xf0104e54
f01017ea:	68 59 48 10 f0       	push   $0xf0104859
f01017ef:	68 6d 03 00 00       	push   $0x36d
f01017f4:	68 33 48 10 f0       	push   $0xf0104833
f01017f9:	e8 a2 e8 ff ff       	call   f01000a0 <_panic>

	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01017fe:	8b 3d 48 4c 17 f0    	mov    0xf0174c48,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101804:	a1 4c 4c 17 f0       	mov    0xf0174c4c,%eax
f0101809:	89 c1                	mov    %eax,%ecx
f010180b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010180e:	8b 17                	mov    (%edi),%edx
f0101810:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101816:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101819:	29 c8                	sub    %ecx,%eax
f010181b:	c1 f8 03             	sar    $0x3,%eax
f010181e:	c1 e0 0c             	shl    $0xc,%eax
f0101821:	39 c2                	cmp    %eax,%edx
f0101823:	74 19                	je     f010183e <mem_init+0x799>
f0101825:	68 84 4e 10 f0       	push   $0xf0104e84
f010182a:	68 59 48 10 f0       	push   $0xf0104859
f010182f:	68 6f 03 00 00       	push   $0x36f
f0101834:	68 33 48 10 f0       	push   $0xf0104833
f0101839:	e8 62 e8 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010183e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101843:	89 f8                	mov    %edi,%eax
f0101845:	e8 b0 f1 ff ff       	call   f01009fa <check_va2pa>
f010184a:	89 da                	mov    %ebx,%edx
f010184c:	2b 55 cc             	sub    -0x34(%ebp),%edx
f010184f:	c1 fa 03             	sar    $0x3,%edx
f0101852:	c1 e2 0c             	shl    $0xc,%edx
f0101855:	39 d0                	cmp    %edx,%eax
f0101857:	74 19                	je     f0101872 <mem_init+0x7cd>
f0101859:	68 ac 4e 10 f0       	push   $0xf0104eac
f010185e:	68 59 48 10 f0       	push   $0xf0104859
f0101863:	68 70 03 00 00       	push   $0x370
f0101868:	68 33 48 10 f0       	push   $0xf0104833
f010186d:	e8 2e e8 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101872:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101877:	74 19                	je     f0101892 <mem_init+0x7ed>
f0101879:	68 12 4a 10 f0       	push   $0xf0104a12
f010187e:	68 59 48 10 f0       	push   $0xf0104859
f0101883:	68 71 03 00 00       	push   $0x371
f0101888:	68 33 48 10 f0       	push   $0xf0104833
f010188d:	e8 0e e8 ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f0101892:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101895:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010189a:	74 19                	je     f01018b5 <mem_init+0x810>
f010189c:	68 23 4a 10 f0       	push   $0xf0104a23
f01018a1:	68 59 48 10 f0       	push   $0xf0104859
f01018a6:	68 72 03 00 00       	push   $0x372
f01018ab:	68 33 48 10 f0       	push   $0xf0104833
f01018b0:	e8 eb e7 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01018b5:	6a 02                	push   $0x2
f01018b7:	68 00 10 00 00       	push   $0x1000
f01018bc:	56                   	push   %esi
f01018bd:	57                   	push   %edi
f01018be:	e8 70 f7 ff ff       	call   f0101033 <page_insert>
f01018c3:	83 c4 10             	add    $0x10,%esp
f01018c6:	85 c0                	test   %eax,%eax
f01018c8:	74 19                	je     f01018e3 <mem_init+0x83e>
f01018ca:	68 dc 4e 10 f0       	push   $0xf0104edc
f01018cf:	68 59 48 10 f0       	push   $0xf0104859
f01018d4:	68 75 03 00 00       	push   $0x375
f01018d9:	68 33 48 10 f0       	push   $0xf0104833
f01018de:	e8 bd e7 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018e3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018e8:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f01018ed:	e8 08 f1 ff ff       	call   f01009fa <check_va2pa>
f01018f2:	89 f2                	mov    %esi,%edx
f01018f4:	2b 15 4c 4c 17 f0    	sub    0xf0174c4c,%edx
f01018fa:	c1 fa 03             	sar    $0x3,%edx
f01018fd:	c1 e2 0c             	shl    $0xc,%edx
f0101900:	39 d0                	cmp    %edx,%eax
f0101902:	74 19                	je     f010191d <mem_init+0x878>
f0101904:	68 18 4f 10 f0       	push   $0xf0104f18
f0101909:	68 59 48 10 f0       	push   $0xf0104859
f010190e:	68 76 03 00 00       	push   $0x376
f0101913:	68 33 48 10 f0       	push   $0xf0104833
f0101918:	e8 83 e7 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f010191d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101922:	74 19                	je     f010193d <mem_init+0x898>
f0101924:	68 34 4a 10 f0       	push   $0xf0104a34
f0101929:	68 59 48 10 f0       	push   $0xf0104859
f010192e:	68 77 03 00 00       	push   $0x377
f0101933:	68 33 48 10 f0       	push   $0xf0104833
f0101938:	e8 63 e7 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010193d:	83 ec 0c             	sub    $0xc,%esp
f0101940:	6a 00                	push   $0x0
f0101942:	e8 71 f4 ff ff       	call   f0100db8 <page_alloc>
f0101947:	83 c4 10             	add    $0x10,%esp
f010194a:	85 c0                	test   %eax,%eax
f010194c:	74 19                	je     f0101967 <mem_init+0x8c2>
f010194e:	68 c0 49 10 f0       	push   $0xf01049c0
f0101953:	68 59 48 10 f0       	push   $0xf0104859
f0101958:	68 7a 03 00 00       	push   $0x37a
f010195d:	68 33 48 10 f0       	push   $0xf0104833
f0101962:	e8 39 e7 ff ff       	call   f01000a0 <_panic>
	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101967:	6a 02                	push   $0x2
f0101969:	68 00 10 00 00       	push   $0x1000
f010196e:	56                   	push   %esi
f010196f:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101975:	e8 b9 f6 ff ff       	call   f0101033 <page_insert>
f010197a:	83 c4 10             	add    $0x10,%esp
f010197d:	85 c0                	test   %eax,%eax
f010197f:	74 19                	je     f010199a <mem_init+0x8f5>
f0101981:	68 dc 4e 10 f0       	push   $0xf0104edc
f0101986:	68 59 48 10 f0       	push   $0xf0104859
f010198b:	68 7c 03 00 00       	push   $0x37c
f0101990:	68 33 48 10 f0       	push   $0xf0104833
f0101995:	e8 06 e7 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010199a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010199f:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f01019a4:	e8 51 f0 ff ff       	call   f01009fa <check_va2pa>
f01019a9:	89 f2                	mov    %esi,%edx
f01019ab:	2b 15 4c 4c 17 f0    	sub    0xf0174c4c,%edx
f01019b1:	c1 fa 03             	sar    $0x3,%edx
f01019b4:	c1 e2 0c             	shl    $0xc,%edx
f01019b7:	39 d0                	cmp    %edx,%eax
f01019b9:	74 19                	je     f01019d4 <mem_init+0x92f>
f01019bb:	68 18 4f 10 f0       	push   $0xf0104f18
f01019c0:	68 59 48 10 f0       	push   $0xf0104859
f01019c5:	68 7d 03 00 00       	push   $0x37d
f01019ca:	68 33 48 10 f0       	push   $0xf0104833
f01019cf:	e8 cc e6 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f01019d4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019d9:	74 19                	je     f01019f4 <mem_init+0x94f>
f01019db:	68 34 4a 10 f0       	push   $0xf0104a34
f01019e0:	68 59 48 10 f0       	push   $0xf0104859
f01019e5:	68 7e 03 00 00       	push   $0x37e
f01019ea:	68 33 48 10 f0       	push   $0xf0104833
f01019ef:	e8 ac e6 ff ff       	call   f01000a0 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01019f4:	83 ec 0c             	sub    $0xc,%esp
f01019f7:	6a 00                	push   $0x0
f01019f9:	e8 ba f3 ff ff       	call   f0100db8 <page_alloc>
f01019fe:	83 c4 10             	add    $0x10,%esp
f0101a01:	85 c0                	test   %eax,%eax
f0101a03:	74 19                	je     f0101a1e <mem_init+0x979>
f0101a05:	68 c0 49 10 f0       	push   $0xf01049c0
f0101a0a:	68 59 48 10 f0       	push   $0xf0104859
f0101a0f:	68 82 03 00 00       	push   $0x382
f0101a14:	68 33 48 10 f0       	push   $0xf0104833
f0101a19:	e8 82 e6 ff ff       	call   f01000a0 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a1e:	8b 15 48 4c 17 f0    	mov    0xf0174c48,%edx
f0101a24:	8b 02                	mov    (%edx),%eax
f0101a26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a2b:	89 c1                	mov    %eax,%ecx
f0101a2d:	c1 e9 0c             	shr    $0xc,%ecx
f0101a30:	3b 0d 44 4c 17 f0    	cmp    0xf0174c44,%ecx
f0101a36:	72 15                	jb     f0101a4d <mem_init+0x9a8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a38:	50                   	push   %eax
f0101a39:	68 98 4b 10 f0       	push   $0xf0104b98
f0101a3e:	68 85 03 00 00       	push   $0x385
f0101a43:	68 33 48 10 f0       	push   $0xf0104833
f0101a48:	e8 53 e6 ff ff       	call   f01000a0 <_panic>
f0101a4d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a55:	83 ec 04             	sub    $0x4,%esp
f0101a58:	6a 00                	push   $0x0
f0101a5a:	68 00 10 00 00       	push   $0x1000
f0101a5f:	52                   	push   %edx
f0101a60:	e8 25 f4 ff ff       	call   f0100e8a <pgdir_walk>
f0101a65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101a68:	8d 57 04             	lea    0x4(%edi),%edx
f0101a6b:	83 c4 10             	add    $0x10,%esp
f0101a6e:	39 d0                	cmp    %edx,%eax
f0101a70:	74 19                	je     f0101a8b <mem_init+0x9e6>
f0101a72:	68 48 4f 10 f0       	push   $0xf0104f48
f0101a77:	68 59 48 10 f0       	push   $0xf0104859
f0101a7c:	68 86 03 00 00       	push   $0x386
f0101a81:	68 33 48 10 f0       	push   $0xf0104833
f0101a86:	e8 15 e6 ff ff       	call   f01000a0 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a8b:	6a 06                	push   $0x6
f0101a8d:	68 00 10 00 00       	push   $0x1000
f0101a92:	56                   	push   %esi
f0101a93:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101a99:	e8 95 f5 ff ff       	call   f0101033 <page_insert>
f0101a9e:	83 c4 10             	add    $0x10,%esp
f0101aa1:	85 c0                	test   %eax,%eax
f0101aa3:	74 19                	je     f0101abe <mem_init+0xa19>
f0101aa5:	68 88 4f 10 f0       	push   $0xf0104f88
f0101aaa:	68 59 48 10 f0       	push   $0xf0104859
f0101aaf:	68 89 03 00 00       	push   $0x389
f0101ab4:	68 33 48 10 f0       	push   $0xf0104833
f0101ab9:	e8 e2 e5 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101abe:	8b 3d 48 4c 17 f0    	mov    0xf0174c48,%edi
f0101ac4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ac9:	89 f8                	mov    %edi,%eax
f0101acb:	e8 2a ef ff ff       	call   f01009fa <check_va2pa>
f0101ad0:	89 f2                	mov    %esi,%edx
f0101ad2:	2b 15 4c 4c 17 f0    	sub    0xf0174c4c,%edx
f0101ad8:	c1 fa 03             	sar    $0x3,%edx
f0101adb:	c1 e2 0c             	shl    $0xc,%edx
f0101ade:	39 d0                	cmp    %edx,%eax
f0101ae0:	74 19                	je     f0101afb <mem_init+0xa56>
f0101ae2:	68 18 4f 10 f0       	push   $0xf0104f18
f0101ae7:	68 59 48 10 f0       	push   $0xf0104859
f0101aec:	68 8a 03 00 00       	push   $0x38a
f0101af1:	68 33 48 10 f0       	push   $0xf0104833
f0101af6:	e8 a5 e5 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101afb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b00:	74 19                	je     f0101b1b <mem_init+0xa76>
f0101b02:	68 34 4a 10 f0       	push   $0xf0104a34
f0101b07:	68 59 48 10 f0       	push   $0xf0104859
f0101b0c:	68 8b 03 00 00       	push   $0x38b
f0101b11:	68 33 48 10 f0       	push   $0xf0104833
f0101b16:	e8 85 e5 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b1b:	83 ec 04             	sub    $0x4,%esp
f0101b1e:	6a 00                	push   $0x0
f0101b20:	68 00 10 00 00       	push   $0x1000
f0101b25:	57                   	push   %edi
f0101b26:	e8 5f f3 ff ff       	call   f0100e8a <pgdir_walk>
f0101b2b:	83 c4 10             	add    $0x10,%esp
f0101b2e:	f6 00 04             	testb  $0x4,(%eax)
f0101b31:	75 19                	jne    f0101b4c <mem_init+0xaa7>
f0101b33:	68 c8 4f 10 f0       	push   $0xf0104fc8
f0101b38:	68 59 48 10 f0       	push   $0xf0104859
f0101b3d:	68 8c 03 00 00       	push   $0x38c
f0101b42:	68 33 48 10 f0       	push   $0xf0104833
f0101b47:	e8 54 e5 ff ff       	call   f01000a0 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101b4c:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f0101b51:	f6 00 04             	testb  $0x4,(%eax)
f0101b54:	75 19                	jne    f0101b6f <mem_init+0xaca>
f0101b56:	68 45 4a 10 f0       	push   $0xf0104a45
f0101b5b:	68 59 48 10 f0       	push   $0xf0104859
f0101b60:	68 8d 03 00 00       	push   $0x38d
f0101b65:	68 33 48 10 f0       	push   $0xf0104833
f0101b6a:	e8 31 e5 ff ff       	call   f01000a0 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b6f:	6a 02                	push   $0x2
f0101b71:	68 00 10 00 00       	push   $0x1000
f0101b76:	56                   	push   %esi
f0101b77:	50                   	push   %eax
f0101b78:	e8 b6 f4 ff ff       	call   f0101033 <page_insert>
f0101b7d:	83 c4 10             	add    $0x10,%esp
f0101b80:	85 c0                	test   %eax,%eax
f0101b82:	74 19                	je     f0101b9d <mem_init+0xaf8>
f0101b84:	68 dc 4e 10 f0       	push   $0xf0104edc
f0101b89:	68 59 48 10 f0       	push   $0xf0104859
f0101b8e:	68 90 03 00 00       	push   $0x390
f0101b93:	68 33 48 10 f0       	push   $0xf0104833
f0101b98:	e8 03 e5 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b9d:	83 ec 04             	sub    $0x4,%esp
f0101ba0:	6a 00                	push   $0x0
f0101ba2:	68 00 10 00 00       	push   $0x1000
f0101ba7:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101bad:	e8 d8 f2 ff ff       	call   f0100e8a <pgdir_walk>
f0101bb2:	83 c4 10             	add    $0x10,%esp
f0101bb5:	f6 00 02             	testb  $0x2,(%eax)
f0101bb8:	75 19                	jne    f0101bd3 <mem_init+0xb2e>
f0101bba:	68 fc 4f 10 f0       	push   $0xf0104ffc
f0101bbf:	68 59 48 10 f0       	push   $0xf0104859
f0101bc4:	68 91 03 00 00       	push   $0x391
f0101bc9:	68 33 48 10 f0       	push   $0xf0104833
f0101bce:	e8 cd e4 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bd3:	83 ec 04             	sub    $0x4,%esp
f0101bd6:	6a 00                	push   $0x0
f0101bd8:	68 00 10 00 00       	push   $0x1000
f0101bdd:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101be3:	e8 a2 f2 ff ff       	call   f0100e8a <pgdir_walk>
f0101be8:	83 c4 10             	add    $0x10,%esp
f0101beb:	f6 00 04             	testb  $0x4,(%eax)
f0101bee:	74 19                	je     f0101c09 <mem_init+0xb64>
f0101bf0:	68 30 50 10 f0       	push   $0xf0105030
f0101bf5:	68 59 48 10 f0       	push   $0xf0104859
f0101bfa:	68 92 03 00 00       	push   $0x392
f0101bff:	68 33 48 10 f0       	push   $0xf0104833
f0101c04:	e8 97 e4 ff ff       	call   f01000a0 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c09:	6a 02                	push   $0x2
f0101c0b:	68 00 00 40 00       	push   $0x400000
f0101c10:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c13:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101c19:	e8 15 f4 ff ff       	call   f0101033 <page_insert>
f0101c1e:	83 c4 10             	add    $0x10,%esp
f0101c21:	85 c0                	test   %eax,%eax
f0101c23:	78 19                	js     f0101c3e <mem_init+0xb99>
f0101c25:	68 68 50 10 f0       	push   $0xf0105068
f0101c2a:	68 59 48 10 f0       	push   $0xf0104859
f0101c2f:	68 95 03 00 00       	push   $0x395
f0101c34:	68 33 48 10 f0       	push   $0xf0104833
f0101c39:	e8 62 e4 ff ff       	call   f01000a0 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c3e:	6a 02                	push   $0x2
f0101c40:	68 00 10 00 00       	push   $0x1000
f0101c45:	53                   	push   %ebx
f0101c46:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101c4c:	e8 e2 f3 ff ff       	call   f0101033 <page_insert>
f0101c51:	83 c4 10             	add    $0x10,%esp
f0101c54:	85 c0                	test   %eax,%eax
f0101c56:	74 19                	je     f0101c71 <mem_init+0xbcc>
f0101c58:	68 a0 50 10 f0       	push   $0xf01050a0
f0101c5d:	68 59 48 10 f0       	push   $0xf0104859
f0101c62:	68 98 03 00 00       	push   $0x398
f0101c67:	68 33 48 10 f0       	push   $0xf0104833
f0101c6c:	e8 2f e4 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c71:	83 ec 04             	sub    $0x4,%esp
f0101c74:	6a 00                	push   $0x0
f0101c76:	68 00 10 00 00       	push   $0x1000
f0101c7b:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101c81:	e8 04 f2 ff ff       	call   f0100e8a <pgdir_walk>
f0101c86:	83 c4 10             	add    $0x10,%esp
f0101c89:	f6 00 04             	testb  $0x4,(%eax)
f0101c8c:	74 19                	je     f0101ca7 <mem_init+0xc02>
f0101c8e:	68 30 50 10 f0       	push   $0xf0105030
f0101c93:	68 59 48 10 f0       	push   $0xf0104859
f0101c98:	68 99 03 00 00       	push   $0x399
f0101c9d:	68 33 48 10 f0       	push   $0xf0104833
f0101ca2:	e8 f9 e3 ff ff       	call   f01000a0 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101ca7:	8b 3d 48 4c 17 f0    	mov    0xf0174c48,%edi
f0101cad:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cb2:	89 f8                	mov    %edi,%eax
f0101cb4:	e8 41 ed ff ff       	call   f01009fa <check_va2pa>
f0101cb9:	89 c1                	mov    %eax,%ecx
f0101cbb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101cbe:	89 d8                	mov    %ebx,%eax
f0101cc0:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0101cc6:	c1 f8 03             	sar    $0x3,%eax
f0101cc9:	c1 e0 0c             	shl    $0xc,%eax
f0101ccc:	39 c1                	cmp    %eax,%ecx
f0101cce:	74 19                	je     f0101ce9 <mem_init+0xc44>
f0101cd0:	68 dc 50 10 f0       	push   $0xf01050dc
f0101cd5:	68 59 48 10 f0       	push   $0xf0104859
f0101cda:	68 9c 03 00 00       	push   $0x39c
f0101cdf:	68 33 48 10 f0       	push   $0xf0104833
f0101ce4:	e8 b7 e3 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ce9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cee:	89 f8                	mov    %edi,%eax
f0101cf0:	e8 05 ed ff ff       	call   f01009fa <check_va2pa>
f0101cf5:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101cf8:	74 19                	je     f0101d13 <mem_init+0xc6e>
f0101cfa:	68 08 51 10 f0       	push   $0xf0105108
f0101cff:	68 59 48 10 f0       	push   $0xf0104859
f0101d04:	68 9d 03 00 00       	push   $0x39d
f0101d09:	68 33 48 10 f0       	push   $0xf0104833
f0101d0e:	e8 8d e3 ff ff       	call   f01000a0 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101d13:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101d18:	74 19                	je     f0101d33 <mem_init+0xc8e>
f0101d1a:	68 5b 4a 10 f0       	push   $0xf0104a5b
f0101d1f:	68 59 48 10 f0       	push   $0xf0104859
f0101d24:	68 9f 03 00 00       	push   $0x39f
f0101d29:	68 33 48 10 f0       	push   $0xf0104833
f0101d2e:	e8 6d e3 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101d33:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d38:	74 19                	je     f0101d53 <mem_init+0xcae>
f0101d3a:	68 6c 4a 10 f0       	push   $0xf0104a6c
f0101d3f:	68 59 48 10 f0       	push   $0xf0104859
f0101d44:	68 a0 03 00 00       	push   $0x3a0
f0101d49:	68 33 48 10 f0       	push   $0xf0104833
f0101d4e:	e8 4d e3 ff ff       	call   f01000a0 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d53:	83 ec 0c             	sub    $0xc,%esp
f0101d56:	6a 00                	push   $0x0
f0101d58:	e8 5b f0 ff ff       	call   f0100db8 <page_alloc>
f0101d5d:	83 c4 10             	add    $0x10,%esp
f0101d60:	85 c0                	test   %eax,%eax
f0101d62:	74 04                	je     f0101d68 <mem_init+0xcc3>
f0101d64:	39 c6                	cmp    %eax,%esi
f0101d66:	74 19                	je     f0101d81 <mem_init+0xcdc>
f0101d68:	68 38 51 10 f0       	push   $0xf0105138
f0101d6d:	68 59 48 10 f0       	push   $0xf0104859
f0101d72:	68 a3 03 00 00       	push   $0x3a3
f0101d77:	68 33 48 10 f0       	push   $0xf0104833
f0101d7c:	e8 1f e3 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d81:	83 ec 08             	sub    $0x8,%esp
f0101d84:	6a 00                	push   $0x0
f0101d86:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101d8c:	e8 67 f2 ff ff       	call   f0100ff8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d91:	8b 3d 48 4c 17 f0    	mov    0xf0174c48,%edi
f0101d97:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d9c:	89 f8                	mov    %edi,%eax
f0101d9e:	e8 57 ec ff ff       	call   f01009fa <check_va2pa>
f0101da3:	83 c4 10             	add    $0x10,%esp
f0101da6:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101da9:	74 19                	je     f0101dc4 <mem_init+0xd1f>
f0101dab:	68 5c 51 10 f0       	push   $0xf010515c
f0101db0:	68 59 48 10 f0       	push   $0xf0104859
f0101db5:	68 a7 03 00 00       	push   $0x3a7
f0101dba:	68 33 48 10 f0       	push   $0xf0104833
f0101dbf:	e8 dc e2 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101dc4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dc9:	89 f8                	mov    %edi,%eax
f0101dcb:	e8 2a ec ff ff       	call   f01009fa <check_va2pa>
f0101dd0:	89 da                	mov    %ebx,%edx
f0101dd2:	2b 15 4c 4c 17 f0    	sub    0xf0174c4c,%edx
f0101dd8:	c1 fa 03             	sar    $0x3,%edx
f0101ddb:	c1 e2 0c             	shl    $0xc,%edx
f0101dde:	39 d0                	cmp    %edx,%eax
f0101de0:	74 19                	je     f0101dfb <mem_init+0xd56>
f0101de2:	68 08 51 10 f0       	push   $0xf0105108
f0101de7:	68 59 48 10 f0       	push   $0xf0104859
f0101dec:	68 a8 03 00 00       	push   $0x3a8
f0101df1:	68 33 48 10 f0       	push   $0xf0104833
f0101df6:	e8 a5 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101dfb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e00:	74 19                	je     f0101e1b <mem_init+0xd76>
f0101e02:	68 12 4a 10 f0       	push   $0xf0104a12
f0101e07:	68 59 48 10 f0       	push   $0xf0104859
f0101e0c:	68 a9 03 00 00       	push   $0x3a9
f0101e11:	68 33 48 10 f0       	push   $0xf0104833
f0101e16:	e8 85 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101e1b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e20:	74 19                	je     f0101e3b <mem_init+0xd96>
f0101e22:	68 6c 4a 10 f0       	push   $0xf0104a6c
f0101e27:	68 59 48 10 f0       	push   $0xf0104859
f0101e2c:	68 aa 03 00 00       	push   $0x3aa
f0101e31:	68 33 48 10 f0       	push   $0xf0104833
f0101e36:	e8 65 e2 ff ff       	call   f01000a0 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101e3b:	6a 00                	push   $0x0
f0101e3d:	68 00 10 00 00       	push   $0x1000
f0101e42:	53                   	push   %ebx
f0101e43:	57                   	push   %edi
f0101e44:	e8 ea f1 ff ff       	call   f0101033 <page_insert>
f0101e49:	83 c4 10             	add    $0x10,%esp
f0101e4c:	85 c0                	test   %eax,%eax
f0101e4e:	74 19                	je     f0101e69 <mem_init+0xdc4>
f0101e50:	68 80 51 10 f0       	push   $0xf0105180
f0101e55:	68 59 48 10 f0       	push   $0xf0104859
f0101e5a:	68 ad 03 00 00       	push   $0x3ad
f0101e5f:	68 33 48 10 f0       	push   $0xf0104833
f0101e64:	e8 37 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref);
f0101e69:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e6e:	75 19                	jne    f0101e89 <mem_init+0xde4>
f0101e70:	68 7d 4a 10 f0       	push   $0xf0104a7d
f0101e75:	68 59 48 10 f0       	push   $0xf0104859
f0101e7a:	68 ae 03 00 00       	push   $0x3ae
f0101e7f:	68 33 48 10 f0       	push   $0xf0104833
f0101e84:	e8 17 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_link == NULL);
f0101e89:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101e8c:	74 19                	je     f0101ea7 <mem_init+0xe02>
f0101e8e:	68 89 4a 10 f0       	push   $0xf0104a89
f0101e93:	68 59 48 10 f0       	push   $0xf0104859
f0101e98:	68 af 03 00 00       	push   $0x3af
f0101e9d:	68 33 48 10 f0       	push   $0xf0104833
f0101ea2:	e8 f9 e1 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101ea7:	83 ec 08             	sub    $0x8,%esp
f0101eaa:	68 00 10 00 00       	push   $0x1000
f0101eaf:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101eb5:	e8 3e f1 ff ff       	call   f0100ff8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101eba:	8b 3d 48 4c 17 f0    	mov    0xf0174c48,%edi
f0101ec0:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ec5:	89 f8                	mov    %edi,%eax
f0101ec7:	e8 2e eb ff ff       	call   f01009fa <check_va2pa>
f0101ecc:	83 c4 10             	add    $0x10,%esp
f0101ecf:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ed2:	74 19                	je     f0101eed <mem_init+0xe48>
f0101ed4:	68 5c 51 10 f0       	push   $0xf010515c
f0101ed9:	68 59 48 10 f0       	push   $0xf0104859
f0101ede:	68 b3 03 00 00       	push   $0x3b3
f0101ee3:	68 33 48 10 f0       	push   $0xf0104833
f0101ee8:	e8 b3 e1 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101eed:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ef2:	89 f8                	mov    %edi,%eax
f0101ef4:	e8 01 eb ff ff       	call   f01009fa <check_va2pa>
f0101ef9:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101efc:	74 19                	je     f0101f17 <mem_init+0xe72>
f0101efe:	68 b8 51 10 f0       	push   $0xf01051b8
f0101f03:	68 59 48 10 f0       	push   $0xf0104859
f0101f08:	68 b4 03 00 00       	push   $0x3b4
f0101f0d:	68 33 48 10 f0       	push   $0xf0104833
f0101f12:	e8 89 e1 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f0101f17:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f1c:	74 19                	je     f0101f37 <mem_init+0xe92>
f0101f1e:	68 9e 4a 10 f0       	push   $0xf0104a9e
f0101f23:	68 59 48 10 f0       	push   $0xf0104859
f0101f28:	68 b5 03 00 00       	push   $0x3b5
f0101f2d:	68 33 48 10 f0       	push   $0xf0104833
f0101f32:	e8 69 e1 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101f37:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f3c:	74 19                	je     f0101f57 <mem_init+0xeb2>
f0101f3e:	68 6c 4a 10 f0       	push   $0xf0104a6c
f0101f43:	68 59 48 10 f0       	push   $0xf0104859
f0101f48:	68 b6 03 00 00       	push   $0x3b6
f0101f4d:	68 33 48 10 f0       	push   $0xf0104833
f0101f52:	e8 49 e1 ff ff       	call   f01000a0 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f57:	83 ec 0c             	sub    $0xc,%esp
f0101f5a:	6a 00                	push   $0x0
f0101f5c:	e8 57 ee ff ff       	call   f0100db8 <page_alloc>
f0101f61:	83 c4 10             	add    $0x10,%esp
f0101f64:	39 c3                	cmp    %eax,%ebx
f0101f66:	75 04                	jne    f0101f6c <mem_init+0xec7>
f0101f68:	85 c0                	test   %eax,%eax
f0101f6a:	75 19                	jne    f0101f85 <mem_init+0xee0>
f0101f6c:	68 e0 51 10 f0       	push   $0xf01051e0
f0101f71:	68 59 48 10 f0       	push   $0xf0104859
f0101f76:	68 b9 03 00 00       	push   $0x3b9
f0101f7b:	68 33 48 10 f0       	push   $0xf0104833
f0101f80:	e8 1b e1 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f85:	83 ec 0c             	sub    $0xc,%esp
f0101f88:	6a 00                	push   $0x0
f0101f8a:	e8 29 ee ff ff       	call   f0100db8 <page_alloc>
f0101f8f:	83 c4 10             	add    $0x10,%esp
f0101f92:	85 c0                	test   %eax,%eax
f0101f94:	74 19                	je     f0101faf <mem_init+0xf0a>
f0101f96:	68 c0 49 10 f0       	push   $0xf01049c0
f0101f9b:	68 59 48 10 f0       	push   $0xf0104859
f0101fa0:	68 bc 03 00 00       	push   $0x3bc
f0101fa5:	68 33 48 10 f0       	push   $0xf0104833
f0101faa:	e8 f1 e0 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101faf:	8b 0d 48 4c 17 f0    	mov    0xf0174c48,%ecx
f0101fb5:	8b 11                	mov    (%ecx),%edx
f0101fb7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101fbd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fc0:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0101fc6:	c1 f8 03             	sar    $0x3,%eax
f0101fc9:	c1 e0 0c             	shl    $0xc,%eax
f0101fcc:	39 c2                	cmp    %eax,%edx
f0101fce:	74 19                	je     f0101fe9 <mem_init+0xf44>
f0101fd0:	68 84 4e 10 f0       	push   $0xf0104e84
f0101fd5:	68 59 48 10 f0       	push   $0xf0104859
f0101fda:	68 bf 03 00 00       	push   $0x3bf
f0101fdf:	68 33 48 10 f0       	push   $0xf0104833
f0101fe4:	e8 b7 e0 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f0101fe9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101fef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ff2:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ff7:	74 19                	je     f0102012 <mem_init+0xf6d>
f0101ff9:	68 23 4a 10 f0       	push   $0xf0104a23
f0101ffe:	68 59 48 10 f0       	push   $0xf0104859
f0102003:	68 c1 03 00 00       	push   $0x3c1
f0102008:	68 33 48 10 f0       	push   $0xf0104833
f010200d:	e8 8e e0 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f0102012:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102015:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010201b:	83 ec 0c             	sub    $0xc,%esp
f010201e:	50                   	push   %eax
f010201f:	e8 04 ee ff ff       	call   f0100e28 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102024:	83 c4 0c             	add    $0xc,%esp
f0102027:	6a 01                	push   $0x1
f0102029:	68 00 10 40 00       	push   $0x401000
f010202e:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0102034:	e8 51 ee ff ff       	call   f0100e8a <pgdir_walk>
f0102039:	89 c7                	mov    %eax,%edi
f010203b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010203e:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f0102043:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102046:	8b 40 04             	mov    0x4(%eax),%eax
f0102049:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010204e:	8b 0d 44 4c 17 f0    	mov    0xf0174c44,%ecx
f0102054:	89 c2                	mov    %eax,%edx
f0102056:	c1 ea 0c             	shr    $0xc,%edx
f0102059:	83 c4 10             	add    $0x10,%esp
f010205c:	39 ca                	cmp    %ecx,%edx
f010205e:	72 15                	jb     f0102075 <mem_init+0xfd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102060:	50                   	push   %eax
f0102061:	68 98 4b 10 f0       	push   $0xf0104b98
f0102066:	68 c8 03 00 00       	push   $0x3c8
f010206b:	68 33 48 10 f0       	push   $0xf0104833
f0102070:	e8 2b e0 ff ff       	call   f01000a0 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102075:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010207a:	39 c7                	cmp    %eax,%edi
f010207c:	74 19                	je     f0102097 <mem_init+0xff2>
f010207e:	68 af 4a 10 f0       	push   $0xf0104aaf
f0102083:	68 59 48 10 f0       	push   $0xf0104859
f0102088:	68 c9 03 00 00       	push   $0x3c9
f010208d:	68 33 48 10 f0       	push   $0xf0104833
f0102092:	e8 09 e0 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102097:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010209a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01020a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020a4:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020aa:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f01020b0:	c1 f8 03             	sar    $0x3,%eax
f01020b3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020b6:	89 c2                	mov    %eax,%edx
f01020b8:	c1 ea 0c             	shr    $0xc,%edx
f01020bb:	39 d1                	cmp    %edx,%ecx
f01020bd:	77 12                	ja     f01020d1 <mem_init+0x102c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020bf:	50                   	push   %eax
f01020c0:	68 98 4b 10 f0       	push   $0xf0104b98
f01020c5:	6a 56                	push   $0x56
f01020c7:	68 3f 48 10 f0       	push   $0xf010483f
f01020cc:	e8 cf df ff ff       	call   f01000a0 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01020d1:	83 ec 04             	sub    $0x4,%esp
f01020d4:	68 00 10 00 00       	push   $0x1000
f01020d9:	68 ff 00 00 00       	push   $0xff
f01020de:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020e3:	50                   	push   %eax
f01020e4:	e8 2c 1d 00 00       	call   f0103e15 <memset>
	page_free(pp0);
f01020e9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01020ec:	89 3c 24             	mov    %edi,(%esp)
f01020ef:	e8 34 ed ff ff       	call   f0100e28 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01020f4:	83 c4 0c             	add    $0xc,%esp
f01020f7:	6a 01                	push   $0x1
f01020f9:	6a 00                	push   $0x0
f01020fb:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0102101:	e8 84 ed ff ff       	call   f0100e8a <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102106:	89 fa                	mov    %edi,%edx
f0102108:	2b 15 4c 4c 17 f0    	sub    0xf0174c4c,%edx
f010210e:	c1 fa 03             	sar    $0x3,%edx
f0102111:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102114:	89 d0                	mov    %edx,%eax
f0102116:	c1 e8 0c             	shr    $0xc,%eax
f0102119:	83 c4 10             	add    $0x10,%esp
f010211c:	3b 05 44 4c 17 f0    	cmp    0xf0174c44,%eax
f0102122:	72 12                	jb     f0102136 <mem_init+0x1091>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102124:	52                   	push   %edx
f0102125:	68 98 4b 10 f0       	push   $0xf0104b98
f010212a:	6a 56                	push   $0x56
f010212c:	68 3f 48 10 f0       	push   $0xf010483f
f0102131:	e8 6a df ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f0102136:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010213c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010213f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102145:	f6 00 01             	testb  $0x1,(%eax)
f0102148:	74 19                	je     f0102163 <mem_init+0x10be>
f010214a:	68 c7 4a 10 f0       	push   $0xf0104ac7
f010214f:	68 59 48 10 f0       	push   $0xf0104859
f0102154:	68 d3 03 00 00       	push   $0x3d3
f0102159:	68 33 48 10 f0       	push   $0xf0104833
f010215e:	e8 3d df ff ff       	call   f01000a0 <_panic>
f0102163:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102166:	39 c2                	cmp    %eax,%edx
f0102168:	75 db                	jne    f0102145 <mem_init+0x10a0>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010216a:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f010216f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102175:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102178:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010217e:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102181:	89 3d 7c 3f 17 f0    	mov    %edi,0xf0173f7c

	// free the pages we took
	page_free(pp0);
f0102187:	83 ec 0c             	sub    $0xc,%esp
f010218a:	50                   	push   %eax
f010218b:	e8 98 ec ff ff       	call   f0100e28 <page_free>
	page_free(pp1);
f0102190:	89 1c 24             	mov    %ebx,(%esp)
f0102193:	e8 90 ec ff ff       	call   f0100e28 <page_free>
	page_free(pp2);
f0102198:	89 34 24             	mov    %esi,(%esp)
f010219b:	e8 88 ec ff ff       	call   f0100e28 <page_free>

	cprintf("check_page() succeeded!\n");
f01021a0:	c7 04 24 de 4a 10 f0 	movl   $0xf0104ade,(%esp)
f01021a7:	e8 f5 0d 00 00       	call   f0102fa1 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f01021ac:	a1 4c 4c 17 f0       	mov    0xf0174c4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021b1:	83 c4 10             	add    $0x10,%esp
f01021b4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021b9:	77 15                	ja     f01021d0 <mem_init+0x112b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021bb:	50                   	push   %eax
f01021bc:	68 88 4d 10 f0       	push   $0xf0104d88
f01021c1:	68 d4 00 00 00       	push   $0xd4
f01021c6:	68 33 48 10 f0       	push   $0xf0104833
f01021cb:	e8 d0 de ff ff       	call   f01000a0 <_panic>
f01021d0:	83 ec 08             	sub    $0x8,%esp
f01021d3:	6a 05                	push   $0x5
f01021d5:	05 00 00 00 10       	add    $0x10000000,%eax
f01021da:	50                   	push   %eax
f01021db:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01021e0:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01021e5:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f01021ea:	e8 2e ed ff ff       	call   f0100f1d <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f01021ef:	a1 88 3f 17 f0       	mov    0xf0173f88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021f4:	83 c4 10             	add    $0x10,%esp
f01021f7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021fc:	77 15                	ja     f0102213 <mem_init+0x116e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021fe:	50                   	push   %eax
f01021ff:	68 88 4d 10 f0       	push   $0xf0104d88
f0102204:	68 de 00 00 00       	push   $0xde
f0102209:	68 33 48 10 f0       	push   $0xf0104833
f010220e:	e8 8d de ff ff       	call   f01000a0 <_panic>
f0102213:	83 ec 08             	sub    $0x8,%esp
f0102216:	6a 05                	push   $0x5
f0102218:	05 00 00 00 10       	add    $0x10000000,%eax
f010221d:	50                   	push   %eax
f010221e:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102223:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102228:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f010222d:	e8 eb ec ff ff       	call   f0100f1d <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102232:	83 c4 10             	add    $0x10,%esp
f0102235:	b8 00 00 11 f0       	mov    $0xf0110000,%eax
f010223a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010223f:	77 15                	ja     f0102256 <mem_init+0x11b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102241:	50                   	push   %eax
f0102242:	68 88 4d 10 f0       	push   $0xf0104d88
f0102247:	68 eb 00 00 00       	push   $0xeb
f010224c:	68 33 48 10 f0       	push   $0xf0104833
f0102251:	e8 4a de ff ff       	call   f01000a0 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f0102256:	83 ec 08             	sub    $0x8,%esp
f0102259:	6a 03                	push   $0x3
f010225b:	68 00 00 11 00       	push   $0x110000
f0102260:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102265:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010226a:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f010226f:	e8 a9 ec ff ff       	call   f0100f1d <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0x0, PTE_W | PTE_P);
f0102274:	83 c4 08             	add    $0x8,%esp
f0102277:	6a 03                	push   $0x3
f0102279:	6a 00                	push   $0x0
f010227b:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102280:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102285:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f010228a:	e8 8e ec ff ff       	call   f0100f1d <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010228f:	8b 1d 48 4c 17 f0    	mov    0xf0174c48,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102295:	a1 44 4c 17 f0       	mov    0xf0174c44,%eax
f010229a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010229d:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01022a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01022a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022ac:	8b 3d 4c 4c 17 f0    	mov    0xf0174c4c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01022b2:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01022b5:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01022b8:	be 00 00 00 00       	mov    $0x0,%esi
f01022bd:	eb 55                	jmp    f0102314 <mem_init+0x126f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022bf:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01022c5:	89 d8                	mov    %ebx,%eax
f01022c7:	e8 2e e7 ff ff       	call   f01009fa <check_va2pa>
f01022cc:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01022d3:	77 15                	ja     f01022ea <mem_init+0x1245>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022d5:	57                   	push   %edi
f01022d6:	68 88 4d 10 f0       	push   $0xf0104d88
f01022db:	68 10 03 00 00       	push   $0x310
f01022e0:	68 33 48 10 f0       	push   $0xf0104833
f01022e5:	e8 b6 dd ff ff       	call   f01000a0 <_panic>
f01022ea:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f01022f1:	39 d0                	cmp    %edx,%eax
f01022f3:	74 19                	je     f010230e <mem_init+0x1269>
f01022f5:	68 04 52 10 f0       	push   $0xf0105204
f01022fa:	68 59 48 10 f0       	push   $0xf0104859
f01022ff:	68 10 03 00 00       	push   $0x310
f0102304:	68 33 48 10 f0       	push   $0xf0104833
f0102309:	e8 92 dd ff ff       	call   f01000a0 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010230e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102314:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0102317:	77 a6                	ja     f01022bf <mem_init+0x121a>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102319:	8b 3d 88 3f 17 f0    	mov    0xf0173f88,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010231f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102322:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f0102327:	89 f2                	mov    %esi,%edx
f0102329:	89 d8                	mov    %ebx,%eax
f010232b:	e8 ca e6 ff ff       	call   f01009fa <check_va2pa>
f0102330:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102337:	77 15                	ja     f010234e <mem_init+0x12a9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102339:	57                   	push   %edi
f010233a:	68 88 4d 10 f0       	push   $0xf0104d88
f010233f:	68 15 03 00 00       	push   $0x315
f0102344:	68 33 48 10 f0       	push   $0xf0104833
f0102349:	e8 52 dd ff ff       	call   f01000a0 <_panic>
f010234e:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f0102355:	39 c2                	cmp    %eax,%edx
f0102357:	74 19                	je     f0102372 <mem_init+0x12cd>
f0102359:	68 38 52 10 f0       	push   $0xf0105238
f010235e:	68 59 48 10 f0       	push   $0xf0104859
f0102363:	68 15 03 00 00       	push   $0x315
f0102368:	68 33 48 10 f0       	push   $0xf0104833
f010236d:	e8 2e dd ff ff       	call   f01000a0 <_panic>
f0102372:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102378:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f010237e:	75 a7                	jne    f0102327 <mem_init+0x1282>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102380:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102383:	c1 e7 0c             	shl    $0xc,%edi
f0102386:	be 00 00 00 00       	mov    $0x0,%esi
f010238b:	eb 30                	jmp    f01023bd <mem_init+0x1318>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010238d:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102393:	89 d8                	mov    %ebx,%eax
f0102395:	e8 60 e6 ff ff       	call   f01009fa <check_va2pa>
f010239a:	39 c6                	cmp    %eax,%esi
f010239c:	74 19                	je     f01023b7 <mem_init+0x1312>
f010239e:	68 6c 52 10 f0       	push   $0xf010526c
f01023a3:	68 59 48 10 f0       	push   $0xf0104859
f01023a8:	68 19 03 00 00       	push   $0x319
f01023ad:	68 33 48 10 f0       	push   $0xf0104833
f01023b2:	e8 e9 dc ff ff       	call   f01000a0 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01023b7:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01023bd:	39 fe                	cmp    %edi,%esi
f01023bf:	72 cc                	jb     f010238d <mem_init+0x12e8>
f01023c1:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01023c6:	89 f2                	mov    %esi,%edx
f01023c8:	89 d8                	mov    %ebx,%eax
f01023ca:	e8 2b e6 ff ff       	call   f01009fa <check_va2pa>
f01023cf:	8d 96 00 80 11 10    	lea    0x10118000(%esi),%edx
f01023d5:	39 c2                	cmp    %eax,%edx
f01023d7:	74 19                	je     f01023f2 <mem_init+0x134d>
f01023d9:	68 94 52 10 f0       	push   $0xf0105294
f01023de:	68 59 48 10 f0       	push   $0xf0104859
f01023e3:	68 1d 03 00 00       	push   $0x31d
f01023e8:	68 33 48 10 f0       	push   $0xf0104833
f01023ed:	e8 ae dc ff ff       	call   f01000a0 <_panic>
f01023f2:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01023f8:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01023fe:	75 c6                	jne    f01023c6 <mem_init+0x1321>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102400:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102405:	89 d8                	mov    %ebx,%eax
f0102407:	e8 ee e5 ff ff       	call   f01009fa <check_va2pa>
f010240c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010240f:	74 51                	je     f0102462 <mem_init+0x13bd>
f0102411:	68 dc 52 10 f0       	push   $0xf01052dc
f0102416:	68 59 48 10 f0       	push   $0xf0104859
f010241b:	68 1e 03 00 00       	push   $0x31e
f0102420:	68 33 48 10 f0       	push   $0xf0104833
f0102425:	e8 76 dc ff ff       	call   f01000a0 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010242a:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010242f:	72 36                	jb     f0102467 <mem_init+0x13c2>
f0102431:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102436:	76 07                	jbe    f010243f <mem_init+0x139a>
f0102438:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010243d:	75 28                	jne    f0102467 <mem_init+0x13c2>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f010243f:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102443:	0f 85 83 00 00 00    	jne    f01024cc <mem_init+0x1427>
f0102449:	68 f7 4a 10 f0       	push   $0xf0104af7
f010244e:	68 59 48 10 f0       	push   $0xf0104859
f0102453:	68 27 03 00 00       	push   $0x327
f0102458:	68 33 48 10 f0       	push   $0xf0104833
f010245d:	e8 3e dc ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102462:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102467:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010246c:	76 3f                	jbe    f01024ad <mem_init+0x1408>
				assert(pgdir[i] & PTE_P);
f010246e:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102471:	f6 c2 01             	test   $0x1,%dl
f0102474:	75 19                	jne    f010248f <mem_init+0x13ea>
f0102476:	68 f7 4a 10 f0       	push   $0xf0104af7
f010247b:	68 59 48 10 f0       	push   $0xf0104859
f0102480:	68 2b 03 00 00       	push   $0x32b
f0102485:	68 33 48 10 f0       	push   $0xf0104833
f010248a:	e8 11 dc ff ff       	call   f01000a0 <_panic>
				assert(pgdir[i] & PTE_W);
f010248f:	f6 c2 02             	test   $0x2,%dl
f0102492:	75 38                	jne    f01024cc <mem_init+0x1427>
f0102494:	68 08 4b 10 f0       	push   $0xf0104b08
f0102499:	68 59 48 10 f0       	push   $0xf0104859
f010249e:	68 2c 03 00 00       	push   $0x32c
f01024a3:	68 33 48 10 f0       	push   $0xf0104833
f01024a8:	e8 f3 db ff ff       	call   f01000a0 <_panic>
			} else
				assert(pgdir[i] == 0);
f01024ad:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01024b1:	74 19                	je     f01024cc <mem_init+0x1427>
f01024b3:	68 19 4b 10 f0       	push   $0xf0104b19
f01024b8:	68 59 48 10 f0       	push   $0xf0104859
f01024bd:	68 2e 03 00 00       	push   $0x32e
f01024c2:	68 33 48 10 f0       	push   $0xf0104833
f01024c7:	e8 d4 db ff ff       	call   f01000a0 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01024cc:	83 c0 01             	add    $0x1,%eax
f01024cf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01024d4:	0f 86 50 ff ff ff    	jbe    f010242a <mem_init+0x1385>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01024da:	83 ec 0c             	sub    $0xc,%esp
f01024dd:	68 0c 53 10 f0       	push   $0xf010530c
f01024e2:	e8 ba 0a 00 00       	call   f0102fa1 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01024e7:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01024ec:	83 c4 10             	add    $0x10,%esp
f01024ef:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01024f4:	77 15                	ja     f010250b <mem_init+0x1466>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01024f6:	50                   	push   %eax
f01024f7:	68 88 4d 10 f0       	push   $0xf0104d88
f01024fc:	68 02 01 00 00       	push   $0x102
f0102501:	68 33 48 10 f0       	push   $0xf0104833
f0102506:	e8 95 db ff ff       	call   f01000a0 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010250b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102510:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102513:	b8 00 00 00 00       	mov    $0x0,%eax
f0102518:	e8 41 e5 ff ff       	call   f0100a5e <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010251d:	0f 20 c0             	mov    %cr0,%eax
f0102520:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102523:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102528:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010252b:	83 ec 0c             	sub    $0xc,%esp
f010252e:	6a 00                	push   $0x0
f0102530:	e8 83 e8 ff ff       	call   f0100db8 <page_alloc>
f0102535:	89 c3                	mov    %eax,%ebx
f0102537:	83 c4 10             	add    $0x10,%esp
f010253a:	85 c0                	test   %eax,%eax
f010253c:	75 19                	jne    f0102557 <mem_init+0x14b2>
f010253e:	68 15 49 10 f0       	push   $0xf0104915
f0102543:	68 59 48 10 f0       	push   $0xf0104859
f0102548:	68 ee 03 00 00       	push   $0x3ee
f010254d:	68 33 48 10 f0       	push   $0xf0104833
f0102552:	e8 49 db ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0102557:	83 ec 0c             	sub    $0xc,%esp
f010255a:	6a 00                	push   $0x0
f010255c:	e8 57 e8 ff ff       	call   f0100db8 <page_alloc>
f0102561:	89 c7                	mov    %eax,%edi
f0102563:	83 c4 10             	add    $0x10,%esp
f0102566:	85 c0                	test   %eax,%eax
f0102568:	75 19                	jne    f0102583 <mem_init+0x14de>
f010256a:	68 2b 49 10 f0       	push   $0xf010492b
f010256f:	68 59 48 10 f0       	push   $0xf0104859
f0102574:	68 ef 03 00 00       	push   $0x3ef
f0102579:	68 33 48 10 f0       	push   $0xf0104833
f010257e:	e8 1d db ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0102583:	83 ec 0c             	sub    $0xc,%esp
f0102586:	6a 00                	push   $0x0
f0102588:	e8 2b e8 ff ff       	call   f0100db8 <page_alloc>
f010258d:	89 c6                	mov    %eax,%esi
f010258f:	83 c4 10             	add    $0x10,%esp
f0102592:	85 c0                	test   %eax,%eax
f0102594:	75 19                	jne    f01025af <mem_init+0x150a>
f0102596:	68 41 49 10 f0       	push   $0xf0104941
f010259b:	68 59 48 10 f0       	push   $0xf0104859
f01025a0:	68 f0 03 00 00       	push   $0x3f0
f01025a5:	68 33 48 10 f0       	push   $0xf0104833
f01025aa:	e8 f1 da ff ff       	call   f01000a0 <_panic>
	page_free(pp0);
f01025af:	83 ec 0c             	sub    $0xc,%esp
f01025b2:	53                   	push   %ebx
f01025b3:	e8 70 e8 ff ff       	call   f0100e28 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025b8:	89 f8                	mov    %edi,%eax
f01025ba:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f01025c0:	c1 f8 03             	sar    $0x3,%eax
f01025c3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025c6:	89 c2                	mov    %eax,%edx
f01025c8:	c1 ea 0c             	shr    $0xc,%edx
f01025cb:	83 c4 10             	add    $0x10,%esp
f01025ce:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f01025d4:	72 12                	jb     f01025e8 <mem_init+0x1543>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025d6:	50                   	push   %eax
f01025d7:	68 98 4b 10 f0       	push   $0xf0104b98
f01025dc:	6a 56                	push   $0x56
f01025de:	68 3f 48 10 f0       	push   $0xf010483f
f01025e3:	e8 b8 da ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01025e8:	83 ec 04             	sub    $0x4,%esp
f01025eb:	68 00 10 00 00       	push   $0x1000
f01025f0:	6a 01                	push   $0x1
f01025f2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025f7:	50                   	push   %eax
f01025f8:	e8 18 18 00 00       	call   f0103e15 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025fd:	89 f0                	mov    %esi,%eax
f01025ff:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0102605:	c1 f8 03             	sar    $0x3,%eax
f0102608:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010260b:	89 c2                	mov    %eax,%edx
f010260d:	c1 ea 0c             	shr    $0xc,%edx
f0102610:	83 c4 10             	add    $0x10,%esp
f0102613:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f0102619:	72 12                	jb     f010262d <mem_init+0x1588>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010261b:	50                   	push   %eax
f010261c:	68 98 4b 10 f0       	push   $0xf0104b98
f0102621:	6a 56                	push   $0x56
f0102623:	68 3f 48 10 f0       	push   $0xf010483f
f0102628:	e8 73 da ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010262d:	83 ec 04             	sub    $0x4,%esp
f0102630:	68 00 10 00 00       	push   $0x1000
f0102635:	6a 02                	push   $0x2
f0102637:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010263c:	50                   	push   %eax
f010263d:	e8 d3 17 00 00       	call   f0103e15 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102642:	6a 02                	push   $0x2
f0102644:	68 00 10 00 00       	push   $0x1000
f0102649:	57                   	push   %edi
f010264a:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0102650:	e8 de e9 ff ff       	call   f0101033 <page_insert>
	assert(pp1->pp_ref == 1);
f0102655:	83 c4 20             	add    $0x20,%esp
f0102658:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010265d:	74 19                	je     f0102678 <mem_init+0x15d3>
f010265f:	68 12 4a 10 f0       	push   $0xf0104a12
f0102664:	68 59 48 10 f0       	push   $0xf0104859
f0102669:	68 f5 03 00 00       	push   $0x3f5
f010266e:	68 33 48 10 f0       	push   $0xf0104833
f0102673:	e8 28 da ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102678:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010267f:	01 01 01 
f0102682:	74 19                	je     f010269d <mem_init+0x15f8>
f0102684:	68 2c 53 10 f0       	push   $0xf010532c
f0102689:	68 59 48 10 f0       	push   $0xf0104859
f010268e:	68 f6 03 00 00       	push   $0x3f6
f0102693:	68 33 48 10 f0       	push   $0xf0104833
f0102698:	e8 03 da ff ff       	call   f01000a0 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010269d:	6a 02                	push   $0x2
f010269f:	68 00 10 00 00       	push   $0x1000
f01026a4:	56                   	push   %esi
f01026a5:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f01026ab:	e8 83 e9 ff ff       	call   f0101033 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01026b0:	83 c4 10             	add    $0x10,%esp
f01026b3:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01026ba:	02 02 02 
f01026bd:	74 19                	je     f01026d8 <mem_init+0x1633>
f01026bf:	68 50 53 10 f0       	push   $0xf0105350
f01026c4:	68 59 48 10 f0       	push   $0xf0104859
f01026c9:	68 f8 03 00 00       	push   $0x3f8
f01026ce:	68 33 48 10 f0       	push   $0xf0104833
f01026d3:	e8 c8 d9 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f01026d8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01026dd:	74 19                	je     f01026f8 <mem_init+0x1653>
f01026df:	68 34 4a 10 f0       	push   $0xf0104a34
f01026e4:	68 59 48 10 f0       	push   $0xf0104859
f01026e9:	68 f9 03 00 00       	push   $0x3f9
f01026ee:	68 33 48 10 f0       	push   $0xf0104833
f01026f3:	e8 a8 d9 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f01026f8:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01026fd:	74 19                	je     f0102718 <mem_init+0x1673>
f01026ff:	68 9e 4a 10 f0       	push   $0xf0104a9e
f0102704:	68 59 48 10 f0       	push   $0xf0104859
f0102709:	68 fa 03 00 00       	push   $0x3fa
f010270e:	68 33 48 10 f0       	push   $0xf0104833
f0102713:	e8 88 d9 ff ff       	call   f01000a0 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102718:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010271f:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102722:	89 f0                	mov    %esi,%eax
f0102724:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f010272a:	c1 f8 03             	sar    $0x3,%eax
f010272d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102730:	89 c2                	mov    %eax,%edx
f0102732:	c1 ea 0c             	shr    $0xc,%edx
f0102735:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f010273b:	72 12                	jb     f010274f <mem_init+0x16aa>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010273d:	50                   	push   %eax
f010273e:	68 98 4b 10 f0       	push   $0xf0104b98
f0102743:	6a 56                	push   $0x56
f0102745:	68 3f 48 10 f0       	push   $0xf010483f
f010274a:	e8 51 d9 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010274f:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102756:	03 03 03 
f0102759:	74 19                	je     f0102774 <mem_init+0x16cf>
f010275b:	68 74 53 10 f0       	push   $0xf0105374
f0102760:	68 59 48 10 f0       	push   $0xf0104859
f0102765:	68 fc 03 00 00       	push   $0x3fc
f010276a:	68 33 48 10 f0       	push   $0xf0104833
f010276f:	e8 2c d9 ff ff       	call   f01000a0 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102774:	83 ec 08             	sub    $0x8,%esp
f0102777:	68 00 10 00 00       	push   $0x1000
f010277c:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0102782:	e8 71 e8 ff ff       	call   f0100ff8 <page_remove>
	assert(pp2->pp_ref == 0);
f0102787:	83 c4 10             	add    $0x10,%esp
f010278a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010278f:	74 19                	je     f01027aa <mem_init+0x1705>
f0102791:	68 6c 4a 10 f0       	push   $0xf0104a6c
f0102796:	68 59 48 10 f0       	push   $0xf0104859
f010279b:	68 fe 03 00 00       	push   $0x3fe
f01027a0:	68 33 48 10 f0       	push   $0xf0104833
f01027a5:	e8 f6 d8 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027aa:	8b 0d 48 4c 17 f0    	mov    0xf0174c48,%ecx
f01027b0:	8b 11                	mov    (%ecx),%edx
f01027b2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01027b8:	89 d8                	mov    %ebx,%eax
f01027ba:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f01027c0:	c1 f8 03             	sar    $0x3,%eax
f01027c3:	c1 e0 0c             	shl    $0xc,%eax
f01027c6:	39 c2                	cmp    %eax,%edx
f01027c8:	74 19                	je     f01027e3 <mem_init+0x173e>
f01027ca:	68 84 4e 10 f0       	push   $0xf0104e84
f01027cf:	68 59 48 10 f0       	push   $0xf0104859
f01027d4:	68 01 04 00 00       	push   $0x401
f01027d9:	68 33 48 10 f0       	push   $0xf0104833
f01027de:	e8 bd d8 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f01027e3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01027e9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01027ee:	74 19                	je     f0102809 <mem_init+0x1764>
f01027f0:	68 23 4a 10 f0       	push   $0xf0104a23
f01027f5:	68 59 48 10 f0       	push   $0xf0104859
f01027fa:	68 03 04 00 00       	push   $0x403
f01027ff:	68 33 48 10 f0       	push   $0xf0104833
f0102804:	e8 97 d8 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f0102809:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010280f:	83 ec 0c             	sub    $0xc,%esp
f0102812:	53                   	push   %ebx
f0102813:	e8 10 e6 ff ff       	call   f0100e28 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102818:	c7 04 24 a0 53 10 f0 	movl   $0xf01053a0,(%esp)
f010281f:	e8 7d 07 00 00       	call   f0102fa1 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102824:	83 c4 10             	add    $0x10,%esp
f0102827:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010282a:	5b                   	pop    %ebx
f010282b:	5e                   	pop    %esi
f010282c:	5f                   	pop    %edi
f010282d:	5d                   	pop    %ebp
f010282e:	c3                   	ret    

f010282f <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010282f:	55                   	push   %ebp
f0102830:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102832:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102835:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102838:	5d                   	pop    %ebp
f0102839:	c3                   	ret    

f010283a <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010283a:	55                   	push   %ebp
f010283b:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f010283d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102842:	5d                   	pop    %ebp
f0102843:	c3                   	ret    

f0102844 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102844:	55                   	push   %ebp
f0102845:	89 e5                	mov    %esp,%ebp
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
		cprintf("[%08x] user_mem_check assertion failure for "
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
	}
}
f0102847:	5d                   	pop    %ebp
f0102848:	c3                   	ret    

f0102849 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102849:	55                   	push   %ebp
f010284a:	89 e5                	mov    %esp,%ebp
f010284c:	57                   	push   %edi
f010284d:	56                   	push   %esi
f010284e:	53                   	push   %ebx
f010284f:	83 ec 0c             	sub    $0xc,%esp
f0102852:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)
	
	void *region_alloc_start = (void *) ROUNDDOWN((uint32_t) va, PGSIZE);
f0102854:	89 d3                	mov    %edx,%ebx
f0102856:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	void *region_alloc_end = (void *) ROUNDUP(((uint32_t) va + len), PGSIZE);
f010285c:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0102863:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102868:	89 c6                	mov    %eax,%esi
	
	if ((uint32_t)region_alloc_end > UTOP)
f010286a:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f010286f:	76 6d                	jbe    f01028de <region_alloc+0x95>
		panic("region_alloc failed: Cannot allocate memory above UTOP");
f0102871:	83 ec 04             	sub    $0x4,%esp
f0102874:	68 cc 53 10 f0       	push   $0xf01053cc
f0102879:	68 25 01 00 00       	push   $0x125
f010287e:	68 e6 54 10 f0       	push   $0xf01054e6
f0102883:	e8 18 d8 ff ff       	call   f01000a0 <_panic>
	//for(region_alloc_start; region_alloc_start < region_alloc_end; region_alloc_start += PGSIZE){
	struct PageInfo *page;
	
	while(region_alloc_start < region_alloc_end){
	
		page = page_alloc(0);
f0102888:	83 ec 0c             	sub    $0xc,%esp
f010288b:	6a 00                	push   $0x0
f010288d:	e8 26 e5 ff ff       	call   f0100db8 <page_alloc>
		
		if (page == NULL) 
f0102892:	83 c4 10             	add    $0x10,%esp
f0102895:	85 c0                	test   %eax,%eax
f0102897:	75 17                	jne    f01028b0 <region_alloc+0x67>
			panic("region_alloc failed: Allocation failed!");
f0102899:	83 ec 04             	sub    $0x4,%esp
f010289c:	68 04 54 10 f0       	push   $0xf0105404
f01028a1:	68 2f 01 00 00       	push   $0x12f
f01028a6:	68 e6 54 10 f0       	push   $0xf01054e6
f01028ab:	e8 f0 d7 ff ff       	call   f01000a0 <_panic>
	
		int r = page_insert(e->env_pgdir, page, region_alloc_start, (PTE_W | PTE_U));	
f01028b0:	6a 06                	push   $0x6
f01028b2:	53                   	push   %ebx
f01028b3:	50                   	push   %eax
f01028b4:	ff 77 5c             	pushl  0x5c(%edi)
f01028b7:	e8 77 e7 ff ff       	call   f0101033 <page_insert>
		
		if(r != 0)
f01028bc:	83 c4 10             	add    $0x10,%esp
f01028bf:	85 c0                	test   %eax,%eax
f01028c1:	74 15                	je     f01028d8 <region_alloc+0x8f>
			panic("region_alloc: %e", r);
f01028c3:	50                   	push   %eax
f01028c4:	68 f1 54 10 f0       	push   $0xf01054f1
f01028c9:	68 34 01 00 00       	push   $0x134
f01028ce:	68 e6 54 10 f0       	push   $0xf01054e6
f01028d3:	e8 c8 d7 ff ff       	call   f01000a0 <_panic>
	
		region_alloc_start += PGSIZE;
f01028d8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		panic("region_alloc failed: Cannot allocate memory above UTOP");
	
	//for(region_alloc_start; region_alloc_start < region_alloc_end; region_alloc_start += PGSIZE){
	struct PageInfo *page;
	
	while(region_alloc_start < region_alloc_end){
f01028de:	39 f3                	cmp    %esi,%ebx
f01028e0:	72 a6                	jb     f0102888 <region_alloc+0x3f>
	
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f01028e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01028e5:	5b                   	pop    %ebx
f01028e6:	5e                   	pop    %esi
f01028e7:	5f                   	pop    %edi
f01028e8:	5d                   	pop    %ebp
f01028e9:	c3                   	ret    

f01028ea <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01028ea:	55                   	push   %ebp
f01028eb:	89 e5                	mov    %esp,%ebp
f01028ed:	8b 55 08             	mov    0x8(%ebp),%edx
f01028f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01028f3:	85 d2                	test   %edx,%edx
f01028f5:	75 11                	jne    f0102908 <envid2env+0x1e>
		*env_store = curenv;
f01028f7:	a1 84 3f 17 f0       	mov    0xf0173f84,%eax
f01028fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01028ff:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102901:	b8 00 00 00 00       	mov    $0x0,%eax
f0102906:	eb 5e                	jmp    f0102966 <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102908:	89 d0                	mov    %edx,%eax
f010290a:	25 ff 03 00 00       	and    $0x3ff,%eax
f010290f:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102912:	c1 e0 05             	shl    $0x5,%eax
f0102915:	03 05 88 3f 17 f0    	add    0xf0173f88,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010291b:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f010291f:	74 05                	je     f0102926 <envid2env+0x3c>
f0102921:	3b 50 48             	cmp    0x48(%eax),%edx
f0102924:	74 10                	je     f0102936 <envid2env+0x4c>
		*env_store = 0;
f0102926:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102929:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010292f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102934:	eb 30                	jmp    f0102966 <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102936:	84 c9                	test   %cl,%cl
f0102938:	74 22                	je     f010295c <envid2env+0x72>
f010293a:	8b 15 84 3f 17 f0    	mov    0xf0173f84,%edx
f0102940:	39 d0                	cmp    %edx,%eax
f0102942:	74 18                	je     f010295c <envid2env+0x72>
f0102944:	8b 4a 48             	mov    0x48(%edx),%ecx
f0102947:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f010294a:	74 10                	je     f010295c <envid2env+0x72>
		*env_store = 0;
f010294c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010294f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102955:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010295a:	eb 0a                	jmp    f0102966 <envid2env+0x7c>
	}

	*env_store = e;
f010295c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010295f:	89 01                	mov    %eax,(%ecx)
	return 0;
f0102961:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102966:	5d                   	pop    %ebp
f0102967:	c3                   	ret    

f0102968 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102968:	55                   	push   %ebp
f0102969:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f010296b:	b8 00 a3 11 f0       	mov    $0xf011a300,%eax
f0102970:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102973:	b8 23 00 00 00       	mov    $0x23,%eax
f0102978:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010297a:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f010297c:	b8 10 00 00 00       	mov    $0x10,%eax
f0102981:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102983:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102985:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102987:	ea 8e 29 10 f0 08 00 	ljmp   $0x8,$0xf010298e
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f010298e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102993:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102996:	5d                   	pop    %ebp
f0102997:	c3                   	ret    

f0102998 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102998:	55                   	push   %ebp
f0102999:	89 e5                	mov    %esp,%ebp
f010299b:	56                   	push   %esi
f010299c:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = NULL;
f010299d:	c7 05 8c 3f 17 f0 00 	movl   $0x0,0xf0173f8c
f01029a4:	00 00 00 
	int i;
	
	cprintf("PDX(UTOP) %u\n", PDX(UTOP) );
f01029a7:	83 ec 08             	sub    $0x8,%esp
f01029aa:	68 bb 03 00 00       	push   $0x3bb
f01029af:	68 02 55 10 f0       	push   $0xf0105502
f01029b4:	e8 e8 05 00 00       	call   f0102fa1 <cprintf>
	for (i = (NENV - 1); i >= 0; --i){
	
		envs[i].env_status = ENV_FREE;
f01029b9:	8b 35 88 3f 17 f0    	mov    0xf0173f88,%esi
f01029bf:	8b 15 8c 3f 17 f0    	mov    0xf0173f8c,%edx
f01029c5:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f01029cb:	8d 5e a0             	lea    -0x60(%esi),%ebx
f01029ce:	83 c4 10             	add    $0x10,%esp
f01029d1:	89 c1                	mov    %eax,%ecx
f01029d3:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f01029da:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01029e1:	89 50 44             	mov    %edx,0x44(%eax)
f01029e4:	83 e8 60             	sub    $0x60,%eax
		env_free_list = &envs[i];
f01029e7:	89 ca                	mov    %ecx,%edx
	// LAB 3: Your code here.
	env_free_list = NULL;
	int i;
	
	cprintf("PDX(UTOP) %u\n", PDX(UTOP) );
	for (i = (NENV - 1); i >= 0; --i){
f01029e9:	39 d8                	cmp    %ebx,%eax
f01029eb:	75 e4                	jne    f01029d1 <env_init+0x39>
f01029ed:	89 35 8c 3f 17 f0    	mov    %esi,0xf0173f8c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f01029f3:	e8 70 ff ff ff       	call   f0102968 <env_init_percpu>
}
f01029f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01029fb:	5b                   	pop    %ebx
f01029fc:	5e                   	pop    %esi
f01029fd:	5d                   	pop    %ebp
f01029fe:	c3                   	ret    

f01029ff <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01029ff:	55                   	push   %ebp
f0102a00:	89 e5                	mov    %esp,%ebp
f0102a02:	53                   	push   %ebx
f0102a03:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102a06:	8b 1d 8c 3f 17 f0    	mov    0xf0173f8c,%ebx
f0102a0c:	85 db                	test   %ebx,%ebx
f0102a0e:	0f 84 5e 01 00 00    	je     f0102b72 <env_alloc+0x173>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102a14:	83 ec 0c             	sub    $0xc,%esp
f0102a17:	6a 01                	push   $0x1
f0102a19:	e8 9a e3 ff ff       	call   f0100db8 <page_alloc>
f0102a1e:	83 c4 10             	add    $0x10,%esp
f0102a21:	85 c0                	test   %eax,%eax
f0102a23:	0f 84 50 01 00 00    	je     f0102b79 <env_alloc+0x17a>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0102a29:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a2e:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0102a34:	c1 f8 03             	sar    $0x3,%eax
f0102a37:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a3a:	89 c2                	mov    %eax,%edx
f0102a3c:	c1 ea 0c             	shr    $0xc,%edx
f0102a3f:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f0102a45:	72 12                	jb     f0102a59 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a47:	50                   	push   %eax
f0102a48:	68 98 4b 10 f0       	push   $0xf0104b98
f0102a4d:	6a 56                	push   $0x56
f0102a4f:	68 3f 48 10 f0       	push   $0xf010483f
f0102a54:	e8 47 d6 ff ff       	call   f01000a0 <_panic>
	e->env_pgdir = (pde_t *) page2kva(p);
f0102a59:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a5e:	89 43 5c             	mov    %eax,0x5c(%ebx)
f0102a61:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (i = 0; i < PDX(UTOP); i++)
	{
		e->env_pgdir[i]= 0;
f0102a66:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0102a69:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f0102a70:	83 c0 04             	add    $0x4,%eax

	// LAB 3: Your code here.
	p->pp_ref++;
	e->env_pgdir = (pde_t *) page2kva(p);
	
	for (i = 0; i < PDX(UTOP); i++)
f0102a73:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0102a78:	75 ec                	jne    f0102a66 <env_alloc+0x67>
	{
		e->env_pgdir[i]= 0;
	}
	for (i = PDX(UTOP) ;  i < NPDENTRIES; i++ )
	{
		e->env_pgdir[i] = kern_pgdir[i];
f0102a7a:	8b 15 48 4c 17 f0    	mov    0xf0174c48,%edx
f0102a80:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0102a83:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0102a86:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0102a89:	83 c0 04             	add    $0x4,%eax
	
	for (i = 0; i < PDX(UTOP); i++)
	{
		e->env_pgdir[i]= 0;
	}
	for (i = PDX(UTOP) ;  i < NPDENTRIES; i++ )
f0102a8c:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102a91:	75 e7                	jne    f0102a7a <env_alloc+0x7b>
		e->env_pgdir[i] = kern_pgdir[i];
	}
		
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102a93:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a96:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a9b:	77 15                	ja     f0102ab2 <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a9d:	50                   	push   %eax
f0102a9e:	68 88 4d 10 f0       	push   $0xf0104d88
f0102aa3:	68 cf 00 00 00       	push   $0xcf
f0102aa8:	68 e6 54 10 f0       	push   $0xf01054e6
f0102aad:	e8 ee d5 ff ff       	call   f01000a0 <_panic>
f0102ab2:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102ab8:	83 ca 05             	or     $0x5,%edx
f0102abb:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102ac1:	8b 43 48             	mov    0x48(%ebx),%eax
f0102ac4:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102ac9:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102ace:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102ad3:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102ad6:	89 da                	mov    %ebx,%edx
f0102ad8:	2b 15 88 3f 17 f0    	sub    0xf0173f88,%edx
f0102ade:	c1 fa 05             	sar    $0x5,%edx
f0102ae1:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102ae7:	09 d0                	or     %edx,%eax
f0102ae9:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102aec:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102aef:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102af2:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102af9:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102b00:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102b07:	83 ec 04             	sub    $0x4,%esp
f0102b0a:	6a 44                	push   $0x44
f0102b0c:	6a 00                	push   $0x0
f0102b0e:	53                   	push   %ebx
f0102b0f:	e8 01 13 00 00       	call   f0103e15 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102b14:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102b1a:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102b20:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102b26:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102b2d:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102b33:	8b 43 44             	mov    0x44(%ebx),%eax
f0102b36:	a3 8c 3f 17 f0       	mov    %eax,0xf0173f8c
	*newenv_store = e;
f0102b3b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b3e:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102b40:	8b 53 48             	mov    0x48(%ebx),%edx
f0102b43:	a1 84 3f 17 f0       	mov    0xf0173f84,%eax
f0102b48:	83 c4 10             	add    $0x10,%esp
f0102b4b:	85 c0                	test   %eax,%eax
f0102b4d:	74 05                	je     f0102b54 <env_alloc+0x155>
f0102b4f:	8b 40 48             	mov    0x48(%eax),%eax
f0102b52:	eb 05                	jmp    f0102b59 <env_alloc+0x15a>
f0102b54:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b59:	83 ec 04             	sub    $0x4,%esp
f0102b5c:	52                   	push   %edx
f0102b5d:	50                   	push   %eax
f0102b5e:	68 10 55 10 f0       	push   $0xf0105510
f0102b63:	e8 39 04 00 00       	call   f0102fa1 <cprintf>
	return 0;
f0102b68:	83 c4 10             	add    $0x10,%esp
f0102b6b:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b70:	eb 0c                	jmp    f0102b7e <env_alloc+0x17f>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102b72:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102b77:	eb 05                	jmp    f0102b7e <env_alloc+0x17f>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102b79:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102b7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102b81:	c9                   	leave  
f0102b82:	c3                   	ret    

f0102b83 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102b83:	55                   	push   %ebp
f0102b84:	89 e5                	mov    %esp,%ebp
f0102b86:	57                   	push   %edi
f0102b87:	56                   	push   %esi
f0102b88:	53                   	push   %ebx
f0102b89:	83 ec 34             	sub    $0x34,%esp
f0102b8c:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	
	int r = env_alloc(&e, (envid_t) 0);
f0102b8f:	6a 00                	push   $0x0
f0102b91:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102b94:	50                   	push   %eax
f0102b95:	e8 65 fe ff ff       	call   f01029ff <env_alloc>
	
	if(r != 0) {
f0102b9a:	83 c4 10             	add    $0x10,%esp
f0102b9d:	85 c0                	test   %eax,%eax
f0102b9f:	74 15                	je     f0102bb6 <env_create+0x33>
		panic("env_alloc failed: env_create failed %e\n", r);
f0102ba1:	50                   	push   %eax
f0102ba2:	68 2c 54 10 f0       	push   $0xf010542c
f0102ba7:	68 b5 01 00 00       	push   $0x1b5
f0102bac:	68 e6 54 10 f0       	push   $0xf01054e6
f0102bb1:	e8 ea d4 ff ff       	call   f01000a0 <_panic>
	}
	
	load_icode(e,binary);
f0102bb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102bb9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Elf * elfHeader = (struct Elf *) binary;

	struct Proghdr *ph, *eph;

	// is this a valid ELF?
	if (elfHeader->e_magic != ELF_MAGIC)
f0102bbc:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102bc2:	74 17                	je     f0102bdb <env_create+0x58>
		panic("load_icode failed: Not a valid ELF file!");
f0102bc4:	83 ec 04             	sub    $0x4,%esp
f0102bc7:	68 54 54 10 f0       	push   $0xf0105454
f0102bcc:	68 7c 01 00 00       	push   $0x17c
f0102bd1:	68 e6 54 10 f0       	push   $0xf01054e6
f0102bd6:	e8 c5 d4 ff ff       	call   f01000a0 <_panic>
	
	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) elfHeader + elfHeader->e_phoff);
f0102bdb:	89 fb                	mov    %edi,%ebx
f0102bdd:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elfHeader->e_phnum;
f0102be0:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102be4:	c1 e6 05             	shl    $0x5,%esi
f0102be7:	01 de                	add    %ebx,%esi
	
	lcr3(PADDR(e->env_pgdir));
f0102be9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bec:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bef:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bf4:	77 15                	ja     f0102c0b <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bf6:	50                   	push   %eax
f0102bf7:	68 88 4d 10 f0       	push   $0xf0104d88
f0102bfc:	68 82 01 00 00       	push   $0x182
f0102c01:	68 e6 54 10 f0       	push   $0xf01054e6
f0102c06:	e8 95 d4 ff ff       	call   f01000a0 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102c0b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c10:	0f 22 d8             	mov    %eax,%cr3
f0102c13:	eb 5b                	jmp    f0102c70 <env_create+0xed>
	
	for (; ph < eph; ph++)
	{
		// p_pa is the load address of this segment (as well
		// as the physical address)
		if (ph->p_type == ELF_PROG_LOAD)
f0102c15:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102c18:	75 53                	jne    f0102c6d <env_create+0xea>
		{
			if(ph->p_filesz <= ph->p_memsz){
f0102c1a:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102c1d:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0102c20:	77 34                	ja     f0102c56 <env_create+0xd3>
			
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102c22:	8b 53 08             	mov    0x8(%ebx),%edx
f0102c25:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c28:	e8 1c fc ff ff       	call   f0102849 <region_alloc>
			memset((void *) ph->p_va, 0, ph->p_memsz);
f0102c2d:	83 ec 04             	sub    $0x4,%esp
f0102c30:	ff 73 14             	pushl  0x14(%ebx)
f0102c33:	6a 00                	push   $0x0
f0102c35:	ff 73 08             	pushl  0x8(%ebx)
f0102c38:	e8 d8 11 00 00       	call   f0103e15 <memset>
			memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0102c3d:	83 c4 0c             	add    $0xc,%esp
f0102c40:	ff 73 10             	pushl  0x10(%ebx)
f0102c43:	89 f8                	mov    %edi,%eax
f0102c45:	03 43 04             	add    0x4(%ebx),%eax
f0102c48:	50                   	push   %eax
f0102c49:	ff 73 08             	pushl  0x8(%ebx)
f0102c4c:	e8 11 12 00 00       	call   f0103e62 <memmove>
f0102c51:	83 c4 10             	add    $0x10,%esp
f0102c54:	eb 17                	jmp    f0102c6d <env_create+0xea>
			}
			
			else
				panic("load_icode failed: filesz is greater than memsz");
f0102c56:	83 ec 04             	sub    $0x4,%esp
f0102c59:	68 80 54 10 f0       	push   $0xf0105480
f0102c5e:	68 92 01 00 00       	push   $0x192
f0102c63:	68 e6 54 10 f0       	push   $0xf01054e6
f0102c68:	e8 33 d4 ff ff       	call   f01000a0 <_panic>
	ph = (struct Proghdr *) ((uint8_t *) elfHeader + elfHeader->e_phoff);
	eph = ph + elfHeader->e_phnum;
	
	lcr3(PADDR(e->env_pgdir));
	
	for (; ph < eph; ph++)
f0102c6d:	83 c3 20             	add    $0x20,%ebx
f0102c70:	39 de                	cmp    %ebx,%esi
f0102c72:	77 a1                	ja     f0102c15 <env_create+0x92>
				panic("load_icode failed: filesz is greater than memsz");
				
		}
	}
	
	e->env_tf.tf_eip = elfHeader->e_entry;
f0102c74:	8b 47 18             	mov    0x18(%edi),%eax
f0102c77:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102c7a:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0102c7d:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102c82:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102c87:	89 f8                	mov    %edi,%eax
f0102c89:	e8 bb fb ff ff       	call   f0102849 <region_alloc>
	
	lcr3(PADDR(kern_pgdir));
f0102c8e:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c93:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c98:	77 15                	ja     f0102caf <env_create+0x12c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c9a:	50                   	push   %eax
f0102c9b:	68 88 4d 10 f0       	push   $0xf0104d88
f0102ca0:	68 a2 01 00 00       	push   $0x1a2
f0102ca5:	68 e6 54 10 f0       	push   $0xf01054e6
f0102caa:	e8 f1 d3 ff ff       	call   f01000a0 <_panic>
f0102caf:	05 00 00 00 10       	add    $0x10000000,%eax
f0102cb4:	0f 22 d8             	mov    %eax,%cr3
	if(r != 0) {
		panic("env_alloc failed: env_create failed %e\n", r);
	}
	
	load_icode(e,binary);
	e->env_type = type;
f0102cb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102cba:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102cbd:	89 50 50             	mov    %edx,0x50(%eax)
	
}
f0102cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cc3:	5b                   	pop    %ebx
f0102cc4:	5e                   	pop    %esi
f0102cc5:	5f                   	pop    %edi
f0102cc6:	5d                   	pop    %ebp
f0102cc7:	c3                   	ret    

f0102cc8 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102cc8:	55                   	push   %ebp
f0102cc9:	89 e5                	mov    %esp,%ebp
f0102ccb:	57                   	push   %edi
f0102ccc:	56                   	push   %esi
f0102ccd:	53                   	push   %ebx
f0102cce:	83 ec 1c             	sub    $0x1c,%esp
f0102cd1:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102cd4:	8b 15 84 3f 17 f0    	mov    0xf0173f84,%edx
f0102cda:	39 fa                	cmp    %edi,%edx
f0102cdc:	75 29                	jne    f0102d07 <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0102cde:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ce3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ce8:	77 15                	ja     f0102cff <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cea:	50                   	push   %eax
f0102ceb:	68 88 4d 10 f0       	push   $0xf0104d88
f0102cf0:	68 cc 01 00 00       	push   $0x1cc
f0102cf5:	68 e6 54 10 f0       	push   $0xf01054e6
f0102cfa:	e8 a1 d3 ff ff       	call   f01000a0 <_panic>
f0102cff:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d04:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102d07:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102d0a:	85 d2                	test   %edx,%edx
f0102d0c:	74 05                	je     f0102d13 <env_free+0x4b>
f0102d0e:	8b 42 48             	mov    0x48(%edx),%eax
f0102d11:	eb 05                	jmp    f0102d18 <env_free+0x50>
f0102d13:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d18:	83 ec 04             	sub    $0x4,%esp
f0102d1b:	51                   	push   %ecx
f0102d1c:	50                   	push   %eax
f0102d1d:	68 25 55 10 f0       	push   $0xf0105525
f0102d22:	e8 7a 02 00 00       	call   f0102fa1 <cprintf>
f0102d27:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102d2a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102d31:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102d34:	89 d0                	mov    %edx,%eax
f0102d36:	c1 e0 02             	shl    $0x2,%eax
f0102d39:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102d3c:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102d3f:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102d42:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102d48:	0f 84 a8 00 00 00    	je     f0102df6 <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102d4e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d54:	89 f0                	mov    %esi,%eax
f0102d56:	c1 e8 0c             	shr    $0xc,%eax
f0102d59:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102d5c:	39 05 44 4c 17 f0    	cmp    %eax,0xf0174c44
f0102d62:	77 15                	ja     f0102d79 <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d64:	56                   	push   %esi
f0102d65:	68 98 4b 10 f0       	push   $0xf0104b98
f0102d6a:	68 db 01 00 00       	push   $0x1db
f0102d6f:	68 e6 54 10 f0       	push   $0xf01054e6
f0102d74:	e8 27 d3 ff ff       	call   f01000a0 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102d79:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d7c:	c1 e0 16             	shl    $0x16,%eax
f0102d7f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102d82:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102d87:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102d8e:	01 
f0102d8f:	74 17                	je     f0102da8 <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102d91:	83 ec 08             	sub    $0x8,%esp
f0102d94:	89 d8                	mov    %ebx,%eax
f0102d96:	c1 e0 0c             	shl    $0xc,%eax
f0102d99:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102d9c:	50                   	push   %eax
f0102d9d:	ff 77 5c             	pushl  0x5c(%edi)
f0102da0:	e8 53 e2 ff ff       	call   f0100ff8 <page_remove>
f0102da5:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102da8:	83 c3 01             	add    $0x1,%ebx
f0102dab:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102db1:	75 d4                	jne    f0102d87 <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102db3:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102db6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102db9:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102dc0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102dc3:	3b 05 44 4c 17 f0    	cmp    0xf0174c44,%eax
f0102dc9:	72 14                	jb     f0102ddf <env_free+0x117>
		panic("pa2page called with invalid pa");
f0102dcb:	83 ec 04             	sub    $0x4,%esp
f0102dce:	68 d4 4c 10 f0       	push   $0xf0104cd4
f0102dd3:	6a 4f                	push   $0x4f
f0102dd5:	68 3f 48 10 f0       	push   $0xf010483f
f0102dda:	e8 c1 d2 ff ff       	call   f01000a0 <_panic>
		page_decref(pa2page(pa));
f0102ddf:	83 ec 0c             	sub    $0xc,%esp
f0102de2:	a1 4c 4c 17 f0       	mov    0xf0174c4c,%eax
f0102de7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102dea:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102ded:	50                   	push   %eax
f0102dee:	e8 70 e0 ff ff       	call   f0100e63 <page_decref>
f0102df3:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102df6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102dfa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102dfd:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102e02:	0f 85 29 ff ff ff    	jne    f0102d31 <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102e08:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e0b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e10:	77 15                	ja     f0102e27 <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e12:	50                   	push   %eax
f0102e13:	68 88 4d 10 f0       	push   $0xf0104d88
f0102e18:	68 e9 01 00 00       	push   $0x1e9
f0102e1d:	68 e6 54 10 f0       	push   $0xf01054e6
f0102e22:	e8 79 d2 ff ff       	call   f01000a0 <_panic>
	e->env_pgdir = 0;
f0102e27:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e2e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e33:	c1 e8 0c             	shr    $0xc,%eax
f0102e36:	3b 05 44 4c 17 f0    	cmp    0xf0174c44,%eax
f0102e3c:	72 14                	jb     f0102e52 <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0102e3e:	83 ec 04             	sub    $0x4,%esp
f0102e41:	68 d4 4c 10 f0       	push   $0xf0104cd4
f0102e46:	6a 4f                	push   $0x4f
f0102e48:	68 3f 48 10 f0       	push   $0xf010483f
f0102e4d:	e8 4e d2 ff ff       	call   f01000a0 <_panic>
	page_decref(pa2page(pa));
f0102e52:	83 ec 0c             	sub    $0xc,%esp
f0102e55:	8b 15 4c 4c 17 f0    	mov    0xf0174c4c,%edx
f0102e5b:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102e5e:	50                   	push   %eax
f0102e5f:	e8 ff df ff ff       	call   f0100e63 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102e64:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102e6b:	a1 8c 3f 17 f0       	mov    0xf0173f8c,%eax
f0102e70:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102e73:	89 3d 8c 3f 17 f0    	mov    %edi,0xf0173f8c
}
f0102e79:	83 c4 10             	add    $0x10,%esp
f0102e7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e7f:	5b                   	pop    %ebx
f0102e80:	5e                   	pop    %esi
f0102e81:	5f                   	pop    %edi
f0102e82:	5d                   	pop    %ebp
f0102e83:	c3                   	ret    

f0102e84 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0102e84:	55                   	push   %ebp
f0102e85:	89 e5                	mov    %esp,%ebp
f0102e87:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102e8a:	ff 75 08             	pushl  0x8(%ebp)
f0102e8d:	e8 36 fe ff ff       	call   f0102cc8 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102e92:	c7 04 24 b0 54 10 f0 	movl   $0xf01054b0,(%esp)
f0102e99:	e8 03 01 00 00       	call   f0102fa1 <cprintf>
f0102e9e:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0102ea1:	83 ec 0c             	sub    $0xc,%esp
f0102ea4:	6a 00                	push   $0x0
f0102ea6:	e8 00 d9 ff ff       	call   f01007ab <monitor>
f0102eab:	83 c4 10             	add    $0x10,%esp
f0102eae:	eb f1                	jmp    f0102ea1 <env_destroy+0x1d>

f0102eb0 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102eb0:	55                   	push   %ebp
f0102eb1:	89 e5                	mov    %esp,%ebp
f0102eb3:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102eb6:	8b 65 08             	mov    0x8(%ebp),%esp
f0102eb9:	61                   	popa   
f0102eba:	07                   	pop    %es
f0102ebb:	1f                   	pop    %ds
f0102ebc:	83 c4 08             	add    $0x8,%esp
f0102ebf:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102ec0:	68 3b 55 10 f0       	push   $0xf010553b
f0102ec5:	68 11 02 00 00       	push   $0x211
f0102eca:	68 e6 54 10 f0       	push   $0xf01054e6
f0102ecf:	e8 cc d1 ff ff       	call   f01000a0 <_panic>

f0102ed4 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102ed4:	55                   	push   %ebp
f0102ed5:	89 e5                	mov    %esp,%ebp
f0102ed7:	83 ec 08             	sub    $0x8,%esp
f0102eda:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv != e){
f0102edd:	8b 15 84 3f 17 f0    	mov    0xf0173f84,%edx
f0102ee3:	39 c2                	cmp    %eax,%edx
f0102ee5:	74 4a                	je     f0102f31 <env_run+0x5d>
	
		if (curenv != NULL && curenv->env_status == ENV_RUNNING){
f0102ee7:	85 d2                	test   %edx,%edx
f0102ee9:	74 0d                	je     f0102ef8 <env_run+0x24>
f0102eeb:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0102eef:	75 07                	jne    f0102ef8 <env_run+0x24>
			curenv->env_status = ENV_RUNNABLE;
f0102ef1:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
		}
		curenv = e;
f0102ef8:	a3 84 3f 17 f0       	mov    %eax,0xf0173f84
		curenv->env_status = ENV_RUNNING;
f0102efd:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f0102f04:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f0102f08:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f0b:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102f11:	77 15                	ja     f0102f28 <env_run+0x54>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f13:	52                   	push   %edx
f0102f14:	68 88 4d 10 f0       	push   $0xf0104d88
f0102f19:	68 37 02 00 00       	push   $0x237
f0102f1e:	68 e6 54 10 f0       	push   $0xf01054e6
f0102f23:	e8 78 d1 ff ff       	call   f01000a0 <_panic>
f0102f28:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102f2e:	0f 22 da             	mov    %edx,%cr3
	}
	
	env_pop_tf(&e->env_tf);
f0102f31:	83 ec 0c             	sub    $0xc,%esp
f0102f34:	50                   	push   %eax
f0102f35:	e8 76 ff ff ff       	call   f0102eb0 <env_pop_tf>

f0102f3a <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102f3a:	55                   	push   %ebp
f0102f3b:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f3d:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f42:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f45:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102f46:	ba 71 00 00 00       	mov    $0x71,%edx
f0102f4b:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102f4c:	0f b6 c0             	movzbl %al,%eax
}
f0102f4f:	5d                   	pop    %ebp
f0102f50:	c3                   	ret    

f0102f51 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102f51:	55                   	push   %ebp
f0102f52:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f54:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f59:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f5c:	ee                   	out    %al,(%dx)
f0102f5d:	ba 71 00 00 00       	mov    $0x71,%edx
f0102f62:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f65:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102f66:	5d                   	pop    %ebp
f0102f67:	c3                   	ret    

f0102f68 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102f68:	55                   	push   %ebp
f0102f69:	89 e5                	mov    %esp,%ebp
f0102f6b:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102f6e:	ff 75 08             	pushl  0x8(%ebp)
f0102f71:	e8 91 d6 ff ff       	call   f0100607 <cputchar>
	*cnt++;
}
f0102f76:	83 c4 10             	add    $0x10,%esp
f0102f79:	c9                   	leave  
f0102f7a:	c3                   	ret    

f0102f7b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102f7b:	55                   	push   %ebp
f0102f7c:	89 e5                	mov    %esp,%ebp
f0102f7e:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102f81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102f88:	ff 75 0c             	pushl  0xc(%ebp)
f0102f8b:	ff 75 08             	pushl  0x8(%ebp)
f0102f8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102f91:	50                   	push   %eax
f0102f92:	68 68 2f 10 f0       	push   $0xf0102f68
f0102f97:	e8 0d 08 00 00       	call   f01037a9 <vprintfmt>
	return cnt;
}
f0102f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f9f:	c9                   	leave  
f0102fa0:	c3                   	ret    

f0102fa1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102fa1:	55                   	push   %ebp
f0102fa2:	89 e5                	mov    %esp,%ebp
f0102fa4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102fa7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102faa:	50                   	push   %eax
f0102fab:	ff 75 08             	pushl  0x8(%ebp)
f0102fae:	e8 c8 ff ff ff       	call   f0102f7b <vcprintf>
	va_end(ap);

	return cnt;
}
f0102fb3:	c9                   	leave  
f0102fb4:	c3                   	ret    

f0102fb5 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0102fb5:	55                   	push   %ebp
f0102fb6:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0102fb8:	b8 c0 47 17 f0       	mov    $0xf01747c0,%eax
f0102fbd:	c7 05 c4 47 17 f0 00 	movl   $0xf0000000,0xf01747c4
f0102fc4:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0102fc7:	66 c7 05 c8 47 17 f0 	movw   $0x10,0xf01747c8
f0102fce:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0102fd0:	66 c7 05 48 a3 11 f0 	movw   $0x67,0xf011a348
f0102fd7:	67 00 
f0102fd9:	66 a3 4a a3 11 f0    	mov    %ax,0xf011a34a
f0102fdf:	89 c2                	mov    %eax,%edx
f0102fe1:	c1 ea 10             	shr    $0x10,%edx
f0102fe4:	88 15 4c a3 11 f0    	mov    %dl,0xf011a34c
f0102fea:	c6 05 4e a3 11 f0 40 	movb   $0x40,0xf011a34e
f0102ff1:	c1 e8 18             	shr    $0x18,%eax
f0102ff4:	a2 4f a3 11 f0       	mov    %al,0xf011a34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0102ff9:	c6 05 4d a3 11 f0 89 	movb   $0x89,0xf011a34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103000:	b8 28 00 00 00       	mov    $0x28,%eax
f0103005:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103008:	b8 50 a3 11 f0       	mov    $0xf011a350,%eax
f010300d:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103010:	5d                   	pop    %ebp
f0103011:	c3                   	ret    

f0103012 <trap_init>:
}


void
trap_init(void)
{
f0103012:	55                   	push   %ebp
f0103013:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	// Per-CPU setup 
	trap_init_percpu();
f0103015:	e8 9b ff ff ff       	call   f0102fb5 <trap_init_percpu>
}
f010301a:	5d                   	pop    %ebp
f010301b:	c3                   	ret    

f010301c <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010301c:	55                   	push   %ebp
f010301d:	89 e5                	mov    %esp,%ebp
f010301f:	53                   	push   %ebx
f0103020:	83 ec 0c             	sub    $0xc,%esp
f0103023:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103026:	ff 33                	pushl  (%ebx)
f0103028:	68 47 55 10 f0       	push   $0xf0105547
f010302d:	e8 6f ff ff ff       	call   f0102fa1 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103032:	83 c4 08             	add    $0x8,%esp
f0103035:	ff 73 04             	pushl  0x4(%ebx)
f0103038:	68 56 55 10 f0       	push   $0xf0105556
f010303d:	e8 5f ff ff ff       	call   f0102fa1 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103042:	83 c4 08             	add    $0x8,%esp
f0103045:	ff 73 08             	pushl  0x8(%ebx)
f0103048:	68 65 55 10 f0       	push   $0xf0105565
f010304d:	e8 4f ff ff ff       	call   f0102fa1 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103052:	83 c4 08             	add    $0x8,%esp
f0103055:	ff 73 0c             	pushl  0xc(%ebx)
f0103058:	68 74 55 10 f0       	push   $0xf0105574
f010305d:	e8 3f ff ff ff       	call   f0102fa1 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103062:	83 c4 08             	add    $0x8,%esp
f0103065:	ff 73 10             	pushl  0x10(%ebx)
f0103068:	68 83 55 10 f0       	push   $0xf0105583
f010306d:	e8 2f ff ff ff       	call   f0102fa1 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103072:	83 c4 08             	add    $0x8,%esp
f0103075:	ff 73 14             	pushl  0x14(%ebx)
f0103078:	68 92 55 10 f0       	push   $0xf0105592
f010307d:	e8 1f ff ff ff       	call   f0102fa1 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103082:	83 c4 08             	add    $0x8,%esp
f0103085:	ff 73 18             	pushl  0x18(%ebx)
f0103088:	68 a1 55 10 f0       	push   $0xf01055a1
f010308d:	e8 0f ff ff ff       	call   f0102fa1 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103092:	83 c4 08             	add    $0x8,%esp
f0103095:	ff 73 1c             	pushl  0x1c(%ebx)
f0103098:	68 b0 55 10 f0       	push   $0xf01055b0
f010309d:	e8 ff fe ff ff       	call   f0102fa1 <cprintf>
}
f01030a2:	83 c4 10             	add    $0x10,%esp
f01030a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01030a8:	c9                   	leave  
f01030a9:	c3                   	ret    

f01030aa <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01030aa:	55                   	push   %ebp
f01030ab:	89 e5                	mov    %esp,%ebp
f01030ad:	56                   	push   %esi
f01030ae:	53                   	push   %ebx
f01030af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f01030b2:	83 ec 08             	sub    $0x8,%esp
f01030b5:	53                   	push   %ebx
f01030b6:	68 e6 56 10 f0       	push   $0xf01056e6
f01030bb:	e8 e1 fe ff ff       	call   f0102fa1 <cprintf>
	print_regs(&tf->tf_regs);
f01030c0:	89 1c 24             	mov    %ebx,(%esp)
f01030c3:	e8 54 ff ff ff       	call   f010301c <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01030c8:	83 c4 08             	add    $0x8,%esp
f01030cb:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01030cf:	50                   	push   %eax
f01030d0:	68 01 56 10 f0       	push   $0xf0105601
f01030d5:	e8 c7 fe ff ff       	call   f0102fa1 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01030da:	83 c4 08             	add    $0x8,%esp
f01030dd:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01030e1:	50                   	push   %eax
f01030e2:	68 14 56 10 f0       	push   $0xf0105614
f01030e7:	e8 b5 fe ff ff       	call   f0102fa1 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01030ec:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01030ef:	83 c4 10             	add    $0x10,%esp
f01030f2:	83 f8 13             	cmp    $0x13,%eax
f01030f5:	77 09                	ja     f0103100 <print_trapframe+0x56>
		return excnames[trapno];
f01030f7:	8b 14 85 c0 58 10 f0 	mov    -0xfefa740(,%eax,4),%edx
f01030fe:	eb 10                	jmp    f0103110 <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f0103100:	83 f8 30             	cmp    $0x30,%eax
f0103103:	b9 cb 55 10 f0       	mov    $0xf01055cb,%ecx
f0103108:	ba bf 55 10 f0       	mov    $0xf01055bf,%edx
f010310d:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103110:	83 ec 04             	sub    $0x4,%esp
f0103113:	52                   	push   %edx
f0103114:	50                   	push   %eax
f0103115:	68 27 56 10 f0       	push   $0xf0105627
f010311a:	e8 82 fe ff ff       	call   f0102fa1 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010311f:	83 c4 10             	add    $0x10,%esp
f0103122:	3b 1d a0 47 17 f0    	cmp    0xf01747a0,%ebx
f0103128:	75 1a                	jne    f0103144 <print_trapframe+0x9a>
f010312a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010312e:	75 14                	jne    f0103144 <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103130:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103133:	83 ec 08             	sub    $0x8,%esp
f0103136:	50                   	push   %eax
f0103137:	68 39 56 10 f0       	push   $0xf0105639
f010313c:	e8 60 fe ff ff       	call   f0102fa1 <cprintf>
f0103141:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103144:	83 ec 08             	sub    $0x8,%esp
f0103147:	ff 73 2c             	pushl  0x2c(%ebx)
f010314a:	68 48 56 10 f0       	push   $0xf0105648
f010314f:	e8 4d fe ff ff       	call   f0102fa1 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103154:	83 c4 10             	add    $0x10,%esp
f0103157:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010315b:	75 49                	jne    f01031a6 <print_trapframe+0xfc>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010315d:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103160:	89 c2                	mov    %eax,%edx
f0103162:	83 e2 01             	and    $0x1,%edx
f0103165:	ba e5 55 10 f0       	mov    $0xf01055e5,%edx
f010316a:	b9 da 55 10 f0       	mov    $0xf01055da,%ecx
f010316f:	0f 44 ca             	cmove  %edx,%ecx
f0103172:	89 c2                	mov    %eax,%edx
f0103174:	83 e2 02             	and    $0x2,%edx
f0103177:	ba f7 55 10 f0       	mov    $0xf01055f7,%edx
f010317c:	be f1 55 10 f0       	mov    $0xf01055f1,%esi
f0103181:	0f 45 d6             	cmovne %esi,%edx
f0103184:	83 e0 04             	and    $0x4,%eax
f0103187:	be 11 57 10 f0       	mov    $0xf0105711,%esi
f010318c:	b8 fc 55 10 f0       	mov    $0xf01055fc,%eax
f0103191:	0f 44 c6             	cmove  %esi,%eax
f0103194:	51                   	push   %ecx
f0103195:	52                   	push   %edx
f0103196:	50                   	push   %eax
f0103197:	68 56 56 10 f0       	push   $0xf0105656
f010319c:	e8 00 fe ff ff       	call   f0102fa1 <cprintf>
f01031a1:	83 c4 10             	add    $0x10,%esp
f01031a4:	eb 10                	jmp    f01031b6 <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01031a6:	83 ec 0c             	sub    $0xc,%esp
f01031a9:	68 f5 4a 10 f0       	push   $0xf0104af5
f01031ae:	e8 ee fd ff ff       	call   f0102fa1 <cprintf>
f01031b3:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01031b6:	83 ec 08             	sub    $0x8,%esp
f01031b9:	ff 73 30             	pushl  0x30(%ebx)
f01031bc:	68 65 56 10 f0       	push   $0xf0105665
f01031c1:	e8 db fd ff ff       	call   f0102fa1 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01031c6:	83 c4 08             	add    $0x8,%esp
f01031c9:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01031cd:	50                   	push   %eax
f01031ce:	68 74 56 10 f0       	push   $0xf0105674
f01031d3:	e8 c9 fd ff ff       	call   f0102fa1 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01031d8:	83 c4 08             	add    $0x8,%esp
f01031db:	ff 73 38             	pushl  0x38(%ebx)
f01031de:	68 87 56 10 f0       	push   $0xf0105687
f01031e3:	e8 b9 fd ff ff       	call   f0102fa1 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01031e8:	83 c4 10             	add    $0x10,%esp
f01031eb:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01031ef:	74 25                	je     f0103216 <print_trapframe+0x16c>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01031f1:	83 ec 08             	sub    $0x8,%esp
f01031f4:	ff 73 3c             	pushl  0x3c(%ebx)
f01031f7:	68 96 56 10 f0       	push   $0xf0105696
f01031fc:	e8 a0 fd ff ff       	call   f0102fa1 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103201:	83 c4 08             	add    $0x8,%esp
f0103204:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103208:	50                   	push   %eax
f0103209:	68 a5 56 10 f0       	push   $0xf01056a5
f010320e:	e8 8e fd ff ff       	call   f0102fa1 <cprintf>
f0103213:	83 c4 10             	add    $0x10,%esp
	}
}
f0103216:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103219:	5b                   	pop    %ebx
f010321a:	5e                   	pop    %esi
f010321b:	5d                   	pop    %ebp
f010321c:	c3                   	ret    

f010321d <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010321d:	55                   	push   %ebp
f010321e:	89 e5                	mov    %esp,%ebp
f0103220:	57                   	push   %edi
f0103221:	56                   	push   %esi
f0103222:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103225:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103226:	9c                   	pushf  
f0103227:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103228:	f6 c4 02             	test   $0x2,%ah
f010322b:	74 19                	je     f0103246 <trap+0x29>
f010322d:	68 b8 56 10 f0       	push   $0xf01056b8
f0103232:	68 59 48 10 f0       	push   $0xf0104859
f0103237:	68 a7 00 00 00       	push   $0xa7
f010323c:	68 d1 56 10 f0       	push   $0xf01056d1
f0103241:	e8 5a ce ff ff       	call   f01000a0 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103246:	83 ec 08             	sub    $0x8,%esp
f0103249:	56                   	push   %esi
f010324a:	68 dd 56 10 f0       	push   $0xf01056dd
f010324f:	e8 4d fd ff ff       	call   f0102fa1 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103254:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103258:	83 e0 03             	and    $0x3,%eax
f010325b:	83 c4 10             	add    $0x10,%esp
f010325e:	66 83 f8 03          	cmp    $0x3,%ax
f0103262:	75 31                	jne    f0103295 <trap+0x78>
		// Trapped from user mode.
		assert(curenv);
f0103264:	a1 84 3f 17 f0       	mov    0xf0173f84,%eax
f0103269:	85 c0                	test   %eax,%eax
f010326b:	75 19                	jne    f0103286 <trap+0x69>
f010326d:	68 f8 56 10 f0       	push   $0xf01056f8
f0103272:	68 59 48 10 f0       	push   $0xf0104859
f0103277:	68 ad 00 00 00       	push   $0xad
f010327c:	68 d1 56 10 f0       	push   $0xf01056d1
f0103281:	e8 1a ce ff ff       	call   f01000a0 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103286:	b9 11 00 00 00       	mov    $0x11,%ecx
f010328b:	89 c7                	mov    %eax,%edi
f010328d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010328f:	8b 35 84 3f 17 f0    	mov    0xf0173f84,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103295:	89 35 a0 47 17 f0    	mov    %esi,0xf01747a0
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010329b:	83 ec 0c             	sub    $0xc,%esp
f010329e:	56                   	push   %esi
f010329f:	e8 06 fe ff ff       	call   f01030aa <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01032a4:	83 c4 10             	add    $0x10,%esp
f01032a7:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01032ac:	75 17                	jne    f01032c5 <trap+0xa8>
		panic("unhandled trap in kernel");
f01032ae:	83 ec 04             	sub    $0x4,%esp
f01032b1:	68 ff 56 10 f0       	push   $0xf01056ff
f01032b6:	68 96 00 00 00       	push   $0x96
f01032bb:	68 d1 56 10 f0       	push   $0xf01056d1
f01032c0:	e8 db cd ff ff       	call   f01000a0 <_panic>
	else {
		env_destroy(curenv);
f01032c5:	83 ec 0c             	sub    $0xc,%esp
f01032c8:	ff 35 84 3f 17 f0    	pushl  0xf0173f84
f01032ce:	e8 b1 fb ff ff       	call   f0102e84 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f01032d3:	a1 84 3f 17 f0       	mov    0xf0173f84,%eax
f01032d8:	83 c4 10             	add    $0x10,%esp
f01032db:	85 c0                	test   %eax,%eax
f01032dd:	74 06                	je     f01032e5 <trap+0xc8>
f01032df:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01032e3:	74 19                	je     f01032fe <trap+0xe1>
f01032e5:	68 5c 58 10 f0       	push   $0xf010585c
f01032ea:	68 59 48 10 f0       	push   $0xf0104859
f01032ef:	68 bf 00 00 00       	push   $0xbf
f01032f4:	68 d1 56 10 f0       	push   $0xf01056d1
f01032f9:	e8 a2 cd ff ff       	call   f01000a0 <_panic>
	env_run(curenv);
f01032fe:	83 ec 0c             	sub    $0xc,%esp
f0103301:	50                   	push   %eax
f0103302:	e8 cd fb ff ff       	call   f0102ed4 <env_run>

f0103307 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103307:	55                   	push   %ebp
f0103308:	89 e5                	mov    %esp,%ebp
f010330a:	53                   	push   %ebx
f010330b:	83 ec 04             	sub    $0x4,%esp
f010330e:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103311:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103314:	ff 73 30             	pushl  0x30(%ebx)
f0103317:	50                   	push   %eax
f0103318:	a1 84 3f 17 f0       	mov    0xf0173f84,%eax
f010331d:	ff 70 48             	pushl  0x48(%eax)
f0103320:	68 88 58 10 f0       	push   $0xf0105888
f0103325:	e8 77 fc ff ff       	call   f0102fa1 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010332a:	89 1c 24             	mov    %ebx,(%esp)
f010332d:	e8 78 fd ff ff       	call   f01030aa <print_trapframe>
	env_destroy(curenv);
f0103332:	83 c4 04             	add    $0x4,%esp
f0103335:	ff 35 84 3f 17 f0    	pushl  0xf0173f84
f010333b:	e8 44 fb ff ff       	call   f0102e84 <env_destroy>
}
f0103340:	83 c4 10             	add    $0x10,%esp
f0103343:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103346:	c9                   	leave  
f0103347:	c3                   	ret    

f0103348 <syscall>:
f0103348:	55                   	push   %ebp
f0103349:	89 e5                	mov    %esp,%ebp
f010334b:	83 ec 0c             	sub    $0xc,%esp
f010334e:	68 10 59 10 f0       	push   $0xf0105910
f0103353:	6a 49                	push   $0x49
f0103355:	68 28 59 10 f0       	push   $0xf0105928
f010335a:	e8 41 cd ff ff       	call   f01000a0 <_panic>

f010335f <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010335f:	55                   	push   %ebp
f0103360:	89 e5                	mov    %esp,%ebp
f0103362:	57                   	push   %edi
f0103363:	56                   	push   %esi
f0103364:	53                   	push   %ebx
f0103365:	83 ec 14             	sub    $0x14,%esp
f0103368:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010336b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010336e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103371:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103374:	8b 1a                	mov    (%edx),%ebx
f0103376:	8b 01                	mov    (%ecx),%eax
f0103378:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010337b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103382:	eb 7f                	jmp    f0103403 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0103384:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103387:	01 d8                	add    %ebx,%eax
f0103389:	89 c6                	mov    %eax,%esi
f010338b:	c1 ee 1f             	shr    $0x1f,%esi
f010338e:	01 c6                	add    %eax,%esi
f0103390:	d1 fe                	sar    %esi
f0103392:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0103395:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103398:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010339b:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010339d:	eb 03                	jmp    f01033a2 <stab_binsearch+0x43>
			m--;
f010339f:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01033a2:	39 c3                	cmp    %eax,%ebx
f01033a4:	7f 0d                	jg     f01033b3 <stab_binsearch+0x54>
f01033a6:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01033aa:	83 ea 0c             	sub    $0xc,%edx
f01033ad:	39 f9                	cmp    %edi,%ecx
f01033af:	75 ee                	jne    f010339f <stab_binsearch+0x40>
f01033b1:	eb 05                	jmp    f01033b8 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01033b3:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01033b6:	eb 4b                	jmp    f0103403 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01033b8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01033bb:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01033be:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01033c2:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01033c5:	76 11                	jbe    f01033d8 <stab_binsearch+0x79>
			*region_left = m;
f01033c7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01033ca:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01033cc:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01033cf:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01033d6:	eb 2b                	jmp    f0103403 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01033d8:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01033db:	73 14                	jae    f01033f1 <stab_binsearch+0x92>
			*region_right = m - 1;
f01033dd:	83 e8 01             	sub    $0x1,%eax
f01033e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01033e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01033e6:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01033e8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01033ef:	eb 12                	jmp    f0103403 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01033f1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01033f4:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01033f6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01033fa:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01033fc:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103403:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103406:	0f 8e 78 ff ff ff    	jle    f0103384 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010340c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103410:	75 0f                	jne    f0103421 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0103412:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103415:	8b 00                	mov    (%eax),%eax
f0103417:	83 e8 01             	sub    $0x1,%eax
f010341a:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010341d:	89 06                	mov    %eax,(%esi)
f010341f:	eb 2c                	jmp    f010344d <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103421:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103424:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103426:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103429:	8b 0e                	mov    (%esi),%ecx
f010342b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010342e:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0103431:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103434:	eb 03                	jmp    f0103439 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103436:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103439:	39 c8                	cmp    %ecx,%eax
f010343b:	7e 0b                	jle    f0103448 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010343d:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0103441:	83 ea 0c             	sub    $0xc,%edx
f0103444:	39 df                	cmp    %ebx,%edi
f0103446:	75 ee                	jne    f0103436 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103448:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010344b:	89 06                	mov    %eax,(%esi)
	}
}
f010344d:	83 c4 14             	add    $0x14,%esp
f0103450:	5b                   	pop    %ebx
f0103451:	5e                   	pop    %esi
f0103452:	5f                   	pop    %edi
f0103453:	5d                   	pop    %ebp
f0103454:	c3                   	ret    

f0103455 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103455:	55                   	push   %ebp
f0103456:	89 e5                	mov    %esp,%ebp
f0103458:	57                   	push   %edi
f0103459:	56                   	push   %esi
f010345a:	53                   	push   %ebx
f010345b:	83 ec 3c             	sub    $0x3c,%esp
f010345e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103461:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103464:	c7 03 37 59 10 f0    	movl   $0xf0105937,(%ebx)
	info->eip_line = 0;
f010346a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103471:	c7 43 08 37 59 10 f0 	movl   $0xf0105937,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103478:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010347f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103482:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103489:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010348f:	77 21                	ja     f01034b2 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103491:	a1 00 00 20 00       	mov    0x200000,%eax
f0103496:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f0103499:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f010349e:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f01034a4:	89 7d b8             	mov    %edi,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f01034a7:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f01034ad:	89 7d c0             	mov    %edi,-0x40(%ebp)
f01034b0:	eb 1a                	jmp    f01034cc <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01034b2:	c7 45 c0 aa f8 10 f0 	movl   $0xf010f8aa,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01034b9:	c7 45 b8 9d ce 10 f0 	movl   $0xf010ce9d,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01034c0:	b8 9c ce 10 f0       	mov    $0xf010ce9c,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01034c5:	c7 45 bc 70 5b 10 f0 	movl   $0xf0105b70,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01034cc:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01034cf:	39 7d b8             	cmp    %edi,-0x48(%ebp)
f01034d2:	0f 83 8c 01 00 00    	jae    f0103664 <debuginfo_eip+0x20f>
f01034d8:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f01034dc:	0f 85 89 01 00 00    	jne    f010366b <debuginfo_eip+0x216>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01034e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01034e9:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01034ec:	29 f8                	sub    %edi,%eax
f01034ee:	c1 f8 02             	sar    $0x2,%eax
f01034f1:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01034f7:	83 e8 01             	sub    $0x1,%eax
f01034fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01034fd:	56                   	push   %esi
f01034fe:	6a 64                	push   $0x64
f0103500:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0103503:	89 c1                	mov    %eax,%ecx
f0103505:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103508:	89 f8                	mov    %edi,%eax
f010350a:	e8 50 fe ff ff       	call   f010335f <stab_binsearch>
	if (lfile == 0)
f010350f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103512:	83 c4 08             	add    $0x8,%esp
f0103515:	85 c0                	test   %eax,%eax
f0103517:	0f 84 55 01 00 00    	je     f0103672 <debuginfo_eip+0x21d>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010351d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103520:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103523:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103526:	56                   	push   %esi
f0103527:	6a 24                	push   $0x24
f0103529:	8d 45 d8             	lea    -0x28(%ebp),%eax
f010352c:	89 c1                	mov    %eax,%ecx
f010352e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103531:	89 f8                	mov    %edi,%eax
f0103533:	e8 27 fe ff ff       	call   f010335f <stab_binsearch>

	if (lfun <= rfun) {
f0103538:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010353b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010353e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0103541:	83 c4 08             	add    $0x8,%esp
f0103544:	39 d0                	cmp    %edx,%eax
f0103546:	7f 2b                	jg     f0103573 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103548:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010354b:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f010354e:	8b 11                	mov    (%ecx),%edx
f0103550:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103553:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0103556:	39 fa                	cmp    %edi,%edx
f0103558:	73 06                	jae    f0103560 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010355a:	03 55 b8             	add    -0x48(%ebp),%edx
f010355d:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103560:	8b 51 08             	mov    0x8(%ecx),%edx
f0103563:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103566:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103568:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010356b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010356e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103571:	eb 0f                	jmp    f0103582 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103573:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103576:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103579:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010357c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010357f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103582:	83 ec 08             	sub    $0x8,%esp
f0103585:	6a 3a                	push   $0x3a
f0103587:	ff 73 08             	pushl  0x8(%ebx)
f010358a:	e8 6a 08 00 00       	call   f0103df9 <strfind>
f010358f:	2b 43 08             	sub    0x8(%ebx),%eax
f0103592:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103595:	83 c4 08             	add    $0x8,%esp
f0103598:	56                   	push   %esi
f0103599:	6a 44                	push   $0x44
f010359b:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010359e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01035a1:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01035a4:	89 f0                	mov    %esi,%eax
f01035a6:	e8 b4 fd ff ff       	call   f010335f <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f01035ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01035ae:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01035b1:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01035b4:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f01035b8:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01035bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01035be:	83 c4 10             	add    $0x10,%esp
f01035c1:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01035c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01035c8:	eb 0a                	jmp    f01035d4 <debuginfo_eip+0x17f>
f01035ca:	83 e8 01             	sub    $0x1,%eax
f01035cd:	83 ea 0c             	sub    $0xc,%edx
f01035d0:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01035d4:	39 c7                	cmp    %eax,%edi
f01035d6:	7e 05                	jle    f01035dd <debuginfo_eip+0x188>
f01035d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01035db:	eb 47                	jmp    f0103624 <debuginfo_eip+0x1cf>
	       && stabs[lline].n_type != N_SOL
f01035dd:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01035e1:	80 f9 84             	cmp    $0x84,%cl
f01035e4:	75 0e                	jne    f01035f4 <debuginfo_eip+0x19f>
f01035e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01035e9:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01035ed:	74 1c                	je     f010360b <debuginfo_eip+0x1b6>
f01035ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01035f2:	eb 17                	jmp    f010360b <debuginfo_eip+0x1b6>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01035f4:	80 f9 64             	cmp    $0x64,%cl
f01035f7:	75 d1                	jne    f01035ca <debuginfo_eip+0x175>
f01035f9:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01035fd:	74 cb                	je     f01035ca <debuginfo_eip+0x175>
f01035ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103602:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103606:	74 03                	je     f010360b <debuginfo_eip+0x1b6>
f0103608:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010360b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010360e:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103611:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103614:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0103617:	8b 75 b8             	mov    -0x48(%ebp),%esi
f010361a:	29 f0                	sub    %esi,%eax
f010361c:	39 c2                	cmp    %eax,%edx
f010361e:	73 04                	jae    f0103624 <debuginfo_eip+0x1cf>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103620:	01 f2                	add    %esi,%edx
f0103622:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103624:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103627:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010362a:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010362f:	39 f2                	cmp    %esi,%edx
f0103631:	7d 4b                	jge    f010367e <debuginfo_eip+0x229>
		for (lline = lfun + 1;
f0103633:	83 c2 01             	add    $0x1,%edx
f0103636:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103639:	89 d0                	mov    %edx,%eax
f010363b:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010363e:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103641:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103644:	eb 04                	jmp    f010364a <debuginfo_eip+0x1f5>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103646:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010364a:	39 c6                	cmp    %eax,%esi
f010364c:	7e 2b                	jle    f0103679 <debuginfo_eip+0x224>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010364e:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103652:	83 c0 01             	add    $0x1,%eax
f0103655:	83 c2 0c             	add    $0xc,%edx
f0103658:	80 f9 a0             	cmp    $0xa0,%cl
f010365b:	74 e9                	je     f0103646 <debuginfo_eip+0x1f1>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010365d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103662:	eb 1a                	jmp    f010367e <debuginfo_eip+0x229>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103664:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103669:	eb 13                	jmp    f010367e <debuginfo_eip+0x229>
f010366b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103670:	eb 0c                	jmp    f010367e <debuginfo_eip+0x229>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103672:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103677:	eb 05                	jmp    f010367e <debuginfo_eip+0x229>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103679:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010367e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103681:	5b                   	pop    %ebx
f0103682:	5e                   	pop    %esi
f0103683:	5f                   	pop    %edi
f0103684:	5d                   	pop    %ebp
f0103685:	c3                   	ret    

f0103686 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103686:	55                   	push   %ebp
f0103687:	89 e5                	mov    %esp,%ebp
f0103689:	57                   	push   %edi
f010368a:	56                   	push   %esi
f010368b:	53                   	push   %ebx
f010368c:	83 ec 1c             	sub    $0x1c,%esp
f010368f:	89 c7                	mov    %eax,%edi
f0103691:	89 d6                	mov    %edx,%esi
f0103693:	8b 45 08             	mov    0x8(%ebp),%eax
f0103696:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103699:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010369c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010369f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01036a2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01036a7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01036aa:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01036ad:	39 d3                	cmp    %edx,%ebx
f01036af:	72 05                	jb     f01036b6 <printnum+0x30>
f01036b1:	39 45 10             	cmp    %eax,0x10(%ebp)
f01036b4:	77 45                	ja     f01036fb <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01036b6:	83 ec 0c             	sub    $0xc,%esp
f01036b9:	ff 75 18             	pushl  0x18(%ebp)
f01036bc:	8b 45 14             	mov    0x14(%ebp),%eax
f01036bf:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01036c2:	53                   	push   %ebx
f01036c3:	ff 75 10             	pushl  0x10(%ebp)
f01036c6:	83 ec 08             	sub    $0x8,%esp
f01036c9:	ff 75 e4             	pushl  -0x1c(%ebp)
f01036cc:	ff 75 e0             	pushl  -0x20(%ebp)
f01036cf:	ff 75 dc             	pushl  -0x24(%ebp)
f01036d2:	ff 75 d8             	pushl  -0x28(%ebp)
f01036d5:	e8 46 09 00 00       	call   f0104020 <__udivdi3>
f01036da:	83 c4 18             	add    $0x18,%esp
f01036dd:	52                   	push   %edx
f01036de:	50                   	push   %eax
f01036df:	89 f2                	mov    %esi,%edx
f01036e1:	89 f8                	mov    %edi,%eax
f01036e3:	e8 9e ff ff ff       	call   f0103686 <printnum>
f01036e8:	83 c4 20             	add    $0x20,%esp
f01036eb:	eb 18                	jmp    f0103705 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01036ed:	83 ec 08             	sub    $0x8,%esp
f01036f0:	56                   	push   %esi
f01036f1:	ff 75 18             	pushl  0x18(%ebp)
f01036f4:	ff d7                	call   *%edi
f01036f6:	83 c4 10             	add    $0x10,%esp
f01036f9:	eb 03                	jmp    f01036fe <printnum+0x78>
f01036fb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01036fe:	83 eb 01             	sub    $0x1,%ebx
f0103701:	85 db                	test   %ebx,%ebx
f0103703:	7f e8                	jg     f01036ed <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103705:	83 ec 08             	sub    $0x8,%esp
f0103708:	56                   	push   %esi
f0103709:	83 ec 04             	sub    $0x4,%esp
f010370c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010370f:	ff 75 e0             	pushl  -0x20(%ebp)
f0103712:	ff 75 dc             	pushl  -0x24(%ebp)
f0103715:	ff 75 d8             	pushl  -0x28(%ebp)
f0103718:	e8 33 0a 00 00       	call   f0104150 <__umoddi3>
f010371d:	83 c4 14             	add    $0x14,%esp
f0103720:	0f be 80 41 59 10 f0 	movsbl -0xfefa6bf(%eax),%eax
f0103727:	50                   	push   %eax
f0103728:	ff d7                	call   *%edi
}
f010372a:	83 c4 10             	add    $0x10,%esp
f010372d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103730:	5b                   	pop    %ebx
f0103731:	5e                   	pop    %esi
f0103732:	5f                   	pop    %edi
f0103733:	5d                   	pop    %ebp
f0103734:	c3                   	ret    

f0103735 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103735:	55                   	push   %ebp
f0103736:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103738:	83 fa 01             	cmp    $0x1,%edx
f010373b:	7e 0e                	jle    f010374b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010373d:	8b 10                	mov    (%eax),%edx
f010373f:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103742:	89 08                	mov    %ecx,(%eax)
f0103744:	8b 02                	mov    (%edx),%eax
f0103746:	8b 52 04             	mov    0x4(%edx),%edx
f0103749:	eb 22                	jmp    f010376d <getuint+0x38>
	else if (lflag)
f010374b:	85 d2                	test   %edx,%edx
f010374d:	74 10                	je     f010375f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010374f:	8b 10                	mov    (%eax),%edx
f0103751:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103754:	89 08                	mov    %ecx,(%eax)
f0103756:	8b 02                	mov    (%edx),%eax
f0103758:	ba 00 00 00 00       	mov    $0x0,%edx
f010375d:	eb 0e                	jmp    f010376d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010375f:	8b 10                	mov    (%eax),%edx
f0103761:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103764:	89 08                	mov    %ecx,(%eax)
f0103766:	8b 02                	mov    (%edx),%eax
f0103768:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010376d:	5d                   	pop    %ebp
f010376e:	c3                   	ret    

f010376f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010376f:	55                   	push   %ebp
f0103770:	89 e5                	mov    %esp,%ebp
f0103772:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103775:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103779:	8b 10                	mov    (%eax),%edx
f010377b:	3b 50 04             	cmp    0x4(%eax),%edx
f010377e:	73 0a                	jae    f010378a <sprintputch+0x1b>
		*b->buf++ = ch;
f0103780:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103783:	89 08                	mov    %ecx,(%eax)
f0103785:	8b 45 08             	mov    0x8(%ebp),%eax
f0103788:	88 02                	mov    %al,(%edx)
}
f010378a:	5d                   	pop    %ebp
f010378b:	c3                   	ret    

f010378c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010378c:	55                   	push   %ebp
f010378d:	89 e5                	mov    %esp,%ebp
f010378f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103792:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103795:	50                   	push   %eax
f0103796:	ff 75 10             	pushl  0x10(%ebp)
f0103799:	ff 75 0c             	pushl  0xc(%ebp)
f010379c:	ff 75 08             	pushl  0x8(%ebp)
f010379f:	e8 05 00 00 00       	call   f01037a9 <vprintfmt>
	va_end(ap);
}
f01037a4:	83 c4 10             	add    $0x10,%esp
f01037a7:	c9                   	leave  
f01037a8:	c3                   	ret    

f01037a9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01037a9:	55                   	push   %ebp
f01037aa:	89 e5                	mov    %esp,%ebp
f01037ac:	57                   	push   %edi
f01037ad:	56                   	push   %esi
f01037ae:	53                   	push   %ebx
f01037af:	83 ec 2c             	sub    $0x2c,%esp
f01037b2:	8b 75 08             	mov    0x8(%ebp),%esi
f01037b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01037b8:	8b 7d 10             	mov    0x10(%ebp),%edi
f01037bb:	eb 12                	jmp    f01037cf <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01037bd:	85 c0                	test   %eax,%eax
f01037bf:	0f 84 89 03 00 00    	je     f0103b4e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f01037c5:	83 ec 08             	sub    $0x8,%esp
f01037c8:	53                   	push   %ebx
f01037c9:	50                   	push   %eax
f01037ca:	ff d6                	call   *%esi
f01037cc:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01037cf:	83 c7 01             	add    $0x1,%edi
f01037d2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01037d6:	83 f8 25             	cmp    $0x25,%eax
f01037d9:	75 e2                	jne    f01037bd <vprintfmt+0x14>
f01037db:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01037df:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01037e6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01037ed:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01037f4:	ba 00 00 00 00       	mov    $0x0,%edx
f01037f9:	eb 07                	jmp    f0103802 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01037fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01037fe:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103802:	8d 47 01             	lea    0x1(%edi),%eax
f0103805:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103808:	0f b6 07             	movzbl (%edi),%eax
f010380b:	0f b6 c8             	movzbl %al,%ecx
f010380e:	83 e8 23             	sub    $0x23,%eax
f0103811:	3c 55                	cmp    $0x55,%al
f0103813:	0f 87 1a 03 00 00    	ja     f0103b33 <vprintfmt+0x38a>
f0103819:	0f b6 c0             	movzbl %al,%eax
f010381c:	ff 24 85 e0 59 10 f0 	jmp    *-0xfefa620(,%eax,4)
f0103823:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103826:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010382a:	eb d6                	jmp    f0103802 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010382c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010382f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103834:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103837:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010383a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f010383e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0103841:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0103844:	83 fa 09             	cmp    $0x9,%edx
f0103847:	77 39                	ja     f0103882 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103849:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010384c:	eb e9                	jmp    f0103837 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010384e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103851:	8d 48 04             	lea    0x4(%eax),%ecx
f0103854:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103857:	8b 00                	mov    (%eax),%eax
f0103859:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010385c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010385f:	eb 27                	jmp    f0103888 <vprintfmt+0xdf>
f0103861:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103864:	85 c0                	test   %eax,%eax
f0103866:	b9 00 00 00 00       	mov    $0x0,%ecx
f010386b:	0f 49 c8             	cmovns %eax,%ecx
f010386e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103871:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103874:	eb 8c                	jmp    f0103802 <vprintfmt+0x59>
f0103876:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103879:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103880:	eb 80                	jmp    f0103802 <vprintfmt+0x59>
f0103882:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103885:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0103888:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010388c:	0f 89 70 ff ff ff    	jns    f0103802 <vprintfmt+0x59>
				width = precision, precision = -1;
f0103892:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103895:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103898:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010389f:	e9 5e ff ff ff       	jmp    f0103802 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01038a4:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01038a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01038aa:	e9 53 ff ff ff       	jmp    f0103802 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01038af:	8b 45 14             	mov    0x14(%ebp),%eax
f01038b2:	8d 50 04             	lea    0x4(%eax),%edx
f01038b5:	89 55 14             	mov    %edx,0x14(%ebp)
f01038b8:	83 ec 08             	sub    $0x8,%esp
f01038bb:	53                   	push   %ebx
f01038bc:	ff 30                	pushl  (%eax)
f01038be:	ff d6                	call   *%esi
			break;
f01038c0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01038c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01038c6:	e9 04 ff ff ff       	jmp    f01037cf <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01038cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01038ce:	8d 50 04             	lea    0x4(%eax),%edx
f01038d1:	89 55 14             	mov    %edx,0x14(%ebp)
f01038d4:	8b 00                	mov    (%eax),%eax
f01038d6:	99                   	cltd   
f01038d7:	31 d0                	xor    %edx,%eax
f01038d9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01038db:	83 f8 07             	cmp    $0x7,%eax
f01038de:	7f 0b                	jg     f01038eb <vprintfmt+0x142>
f01038e0:	8b 14 85 40 5b 10 f0 	mov    -0xfefa4c0(,%eax,4),%edx
f01038e7:	85 d2                	test   %edx,%edx
f01038e9:	75 18                	jne    f0103903 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f01038eb:	50                   	push   %eax
f01038ec:	68 59 59 10 f0       	push   $0xf0105959
f01038f1:	53                   	push   %ebx
f01038f2:	56                   	push   %esi
f01038f3:	e8 94 fe ff ff       	call   f010378c <printfmt>
f01038f8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01038fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01038fe:	e9 cc fe ff ff       	jmp    f01037cf <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0103903:	52                   	push   %edx
f0103904:	68 6b 48 10 f0       	push   $0xf010486b
f0103909:	53                   	push   %ebx
f010390a:	56                   	push   %esi
f010390b:	e8 7c fe ff ff       	call   f010378c <printfmt>
f0103910:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103913:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103916:	e9 b4 fe ff ff       	jmp    f01037cf <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010391b:	8b 45 14             	mov    0x14(%ebp),%eax
f010391e:	8d 50 04             	lea    0x4(%eax),%edx
f0103921:	89 55 14             	mov    %edx,0x14(%ebp)
f0103924:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103926:	85 ff                	test   %edi,%edi
f0103928:	b8 52 59 10 f0       	mov    $0xf0105952,%eax
f010392d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103930:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103934:	0f 8e 94 00 00 00    	jle    f01039ce <vprintfmt+0x225>
f010393a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010393e:	0f 84 98 00 00 00    	je     f01039dc <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103944:	83 ec 08             	sub    $0x8,%esp
f0103947:	ff 75 d0             	pushl  -0x30(%ebp)
f010394a:	57                   	push   %edi
f010394b:	e8 5f 03 00 00       	call   f0103caf <strnlen>
f0103950:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103953:	29 c1                	sub    %eax,%ecx
f0103955:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0103958:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010395b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010395f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103962:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103965:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103967:	eb 0f                	jmp    f0103978 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0103969:	83 ec 08             	sub    $0x8,%esp
f010396c:	53                   	push   %ebx
f010396d:	ff 75 e0             	pushl  -0x20(%ebp)
f0103970:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103972:	83 ef 01             	sub    $0x1,%edi
f0103975:	83 c4 10             	add    $0x10,%esp
f0103978:	85 ff                	test   %edi,%edi
f010397a:	7f ed                	jg     f0103969 <vprintfmt+0x1c0>
f010397c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010397f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103982:	85 c9                	test   %ecx,%ecx
f0103984:	b8 00 00 00 00       	mov    $0x0,%eax
f0103989:	0f 49 c1             	cmovns %ecx,%eax
f010398c:	29 c1                	sub    %eax,%ecx
f010398e:	89 75 08             	mov    %esi,0x8(%ebp)
f0103991:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103994:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103997:	89 cb                	mov    %ecx,%ebx
f0103999:	eb 4d                	jmp    f01039e8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010399b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010399f:	74 1b                	je     f01039bc <vprintfmt+0x213>
f01039a1:	0f be c0             	movsbl %al,%eax
f01039a4:	83 e8 20             	sub    $0x20,%eax
f01039a7:	83 f8 5e             	cmp    $0x5e,%eax
f01039aa:	76 10                	jbe    f01039bc <vprintfmt+0x213>
					putch('?', putdat);
f01039ac:	83 ec 08             	sub    $0x8,%esp
f01039af:	ff 75 0c             	pushl  0xc(%ebp)
f01039b2:	6a 3f                	push   $0x3f
f01039b4:	ff 55 08             	call   *0x8(%ebp)
f01039b7:	83 c4 10             	add    $0x10,%esp
f01039ba:	eb 0d                	jmp    f01039c9 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f01039bc:	83 ec 08             	sub    $0x8,%esp
f01039bf:	ff 75 0c             	pushl  0xc(%ebp)
f01039c2:	52                   	push   %edx
f01039c3:	ff 55 08             	call   *0x8(%ebp)
f01039c6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01039c9:	83 eb 01             	sub    $0x1,%ebx
f01039cc:	eb 1a                	jmp    f01039e8 <vprintfmt+0x23f>
f01039ce:	89 75 08             	mov    %esi,0x8(%ebp)
f01039d1:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01039d4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01039d7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01039da:	eb 0c                	jmp    f01039e8 <vprintfmt+0x23f>
f01039dc:	89 75 08             	mov    %esi,0x8(%ebp)
f01039df:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01039e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01039e5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01039e8:	83 c7 01             	add    $0x1,%edi
f01039eb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01039ef:	0f be d0             	movsbl %al,%edx
f01039f2:	85 d2                	test   %edx,%edx
f01039f4:	74 23                	je     f0103a19 <vprintfmt+0x270>
f01039f6:	85 f6                	test   %esi,%esi
f01039f8:	78 a1                	js     f010399b <vprintfmt+0x1f2>
f01039fa:	83 ee 01             	sub    $0x1,%esi
f01039fd:	79 9c                	jns    f010399b <vprintfmt+0x1f2>
f01039ff:	89 df                	mov    %ebx,%edi
f0103a01:	8b 75 08             	mov    0x8(%ebp),%esi
f0103a04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a07:	eb 18                	jmp    f0103a21 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103a09:	83 ec 08             	sub    $0x8,%esp
f0103a0c:	53                   	push   %ebx
f0103a0d:	6a 20                	push   $0x20
f0103a0f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103a11:	83 ef 01             	sub    $0x1,%edi
f0103a14:	83 c4 10             	add    $0x10,%esp
f0103a17:	eb 08                	jmp    f0103a21 <vprintfmt+0x278>
f0103a19:	89 df                	mov    %ebx,%edi
f0103a1b:	8b 75 08             	mov    0x8(%ebp),%esi
f0103a1e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a21:	85 ff                	test   %edi,%edi
f0103a23:	7f e4                	jg     f0103a09 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103a28:	e9 a2 fd ff ff       	jmp    f01037cf <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103a2d:	83 fa 01             	cmp    $0x1,%edx
f0103a30:	7e 16                	jle    f0103a48 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0103a32:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a35:	8d 50 08             	lea    0x8(%eax),%edx
f0103a38:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a3b:	8b 50 04             	mov    0x4(%eax),%edx
f0103a3e:	8b 00                	mov    (%eax),%eax
f0103a40:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103a43:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103a46:	eb 32                	jmp    f0103a7a <vprintfmt+0x2d1>
	else if (lflag)
f0103a48:	85 d2                	test   %edx,%edx
f0103a4a:	74 18                	je     f0103a64 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0103a4c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a4f:	8d 50 04             	lea    0x4(%eax),%edx
f0103a52:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a55:	8b 00                	mov    (%eax),%eax
f0103a57:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103a5a:	89 c1                	mov    %eax,%ecx
f0103a5c:	c1 f9 1f             	sar    $0x1f,%ecx
f0103a5f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103a62:	eb 16                	jmp    f0103a7a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0103a64:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a67:	8d 50 04             	lea    0x4(%eax),%edx
f0103a6a:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a6d:	8b 00                	mov    (%eax),%eax
f0103a6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103a72:	89 c1                	mov    %eax,%ecx
f0103a74:	c1 f9 1f             	sar    $0x1f,%ecx
f0103a77:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103a7a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103a7d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103a80:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103a85:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103a89:	79 74                	jns    f0103aff <vprintfmt+0x356>
				putch('-', putdat);
f0103a8b:	83 ec 08             	sub    $0x8,%esp
f0103a8e:	53                   	push   %ebx
f0103a8f:	6a 2d                	push   $0x2d
f0103a91:	ff d6                	call   *%esi
				num = -(long long) num;
f0103a93:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103a96:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a99:	f7 d8                	neg    %eax
f0103a9b:	83 d2 00             	adc    $0x0,%edx
f0103a9e:	f7 da                	neg    %edx
f0103aa0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103aa3:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103aa8:	eb 55                	jmp    f0103aff <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103aaa:	8d 45 14             	lea    0x14(%ebp),%eax
f0103aad:	e8 83 fc ff ff       	call   f0103735 <getuint>
			base = 10;
f0103ab2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0103ab7:	eb 46                	jmp    f0103aff <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0103ab9:	8d 45 14             	lea    0x14(%ebp),%eax
f0103abc:	e8 74 fc ff ff       	call   f0103735 <getuint>
			base = 8;
f0103ac1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0103ac6:	eb 37                	jmp    f0103aff <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
f0103ac8:	83 ec 08             	sub    $0x8,%esp
f0103acb:	53                   	push   %ebx
f0103acc:	6a 30                	push   $0x30
f0103ace:	ff d6                	call   *%esi
			putch('x', putdat);
f0103ad0:	83 c4 08             	add    $0x8,%esp
f0103ad3:	53                   	push   %ebx
f0103ad4:	6a 78                	push   $0x78
f0103ad6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103ad8:	8b 45 14             	mov    0x14(%ebp),%eax
f0103adb:	8d 50 04             	lea    0x4(%eax),%edx
f0103ade:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103ae1:	8b 00                	mov    (%eax),%eax
f0103ae3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103ae8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103aeb:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0103af0:	eb 0d                	jmp    f0103aff <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103af2:	8d 45 14             	lea    0x14(%ebp),%eax
f0103af5:	e8 3b fc ff ff       	call   f0103735 <getuint>
			base = 16;
f0103afa:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103aff:	83 ec 0c             	sub    $0xc,%esp
f0103b02:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103b06:	57                   	push   %edi
f0103b07:	ff 75 e0             	pushl  -0x20(%ebp)
f0103b0a:	51                   	push   %ecx
f0103b0b:	52                   	push   %edx
f0103b0c:	50                   	push   %eax
f0103b0d:	89 da                	mov    %ebx,%edx
f0103b0f:	89 f0                	mov    %esi,%eax
f0103b11:	e8 70 fb ff ff       	call   f0103686 <printnum>
			break;
f0103b16:	83 c4 20             	add    $0x20,%esp
f0103b19:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103b1c:	e9 ae fc ff ff       	jmp    f01037cf <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103b21:	83 ec 08             	sub    $0x8,%esp
f0103b24:	53                   	push   %ebx
f0103b25:	51                   	push   %ecx
f0103b26:	ff d6                	call   *%esi
			break;
f0103b28:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103b2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103b2e:	e9 9c fc ff ff       	jmp    f01037cf <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103b33:	83 ec 08             	sub    $0x8,%esp
f0103b36:	53                   	push   %ebx
f0103b37:	6a 25                	push   $0x25
f0103b39:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103b3b:	83 c4 10             	add    $0x10,%esp
f0103b3e:	eb 03                	jmp    f0103b43 <vprintfmt+0x39a>
f0103b40:	83 ef 01             	sub    $0x1,%edi
f0103b43:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103b47:	75 f7                	jne    f0103b40 <vprintfmt+0x397>
f0103b49:	e9 81 fc ff ff       	jmp    f01037cf <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0103b4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b51:	5b                   	pop    %ebx
f0103b52:	5e                   	pop    %esi
f0103b53:	5f                   	pop    %edi
f0103b54:	5d                   	pop    %ebp
f0103b55:	c3                   	ret    

f0103b56 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103b56:	55                   	push   %ebp
f0103b57:	89 e5                	mov    %esp,%ebp
f0103b59:	83 ec 18             	sub    $0x18,%esp
f0103b5c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b5f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103b62:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103b65:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103b69:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103b6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103b73:	85 c0                	test   %eax,%eax
f0103b75:	74 26                	je     f0103b9d <vsnprintf+0x47>
f0103b77:	85 d2                	test   %edx,%edx
f0103b79:	7e 22                	jle    f0103b9d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103b7b:	ff 75 14             	pushl  0x14(%ebp)
f0103b7e:	ff 75 10             	pushl  0x10(%ebp)
f0103b81:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103b84:	50                   	push   %eax
f0103b85:	68 6f 37 10 f0       	push   $0xf010376f
f0103b8a:	e8 1a fc ff ff       	call   f01037a9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103b8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103b92:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b98:	83 c4 10             	add    $0x10,%esp
f0103b9b:	eb 05                	jmp    f0103ba2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103b9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103ba2:	c9                   	leave  
f0103ba3:	c3                   	ret    

f0103ba4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103ba4:	55                   	push   %ebp
f0103ba5:	89 e5                	mov    %esp,%ebp
f0103ba7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103baa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103bad:	50                   	push   %eax
f0103bae:	ff 75 10             	pushl  0x10(%ebp)
f0103bb1:	ff 75 0c             	pushl  0xc(%ebp)
f0103bb4:	ff 75 08             	pushl  0x8(%ebp)
f0103bb7:	e8 9a ff ff ff       	call   f0103b56 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103bbc:	c9                   	leave  
f0103bbd:	c3                   	ret    

f0103bbe <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103bbe:	55                   	push   %ebp
f0103bbf:	89 e5                	mov    %esp,%ebp
f0103bc1:	57                   	push   %edi
f0103bc2:	56                   	push   %esi
f0103bc3:	53                   	push   %ebx
f0103bc4:	83 ec 0c             	sub    $0xc,%esp
f0103bc7:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103bca:	85 c0                	test   %eax,%eax
f0103bcc:	74 11                	je     f0103bdf <readline+0x21>
		cprintf("%s", prompt);
f0103bce:	83 ec 08             	sub    $0x8,%esp
f0103bd1:	50                   	push   %eax
f0103bd2:	68 6b 48 10 f0       	push   $0xf010486b
f0103bd7:	e8 c5 f3 ff ff       	call   f0102fa1 <cprintf>
f0103bdc:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103bdf:	83 ec 0c             	sub    $0xc,%esp
f0103be2:	6a 00                	push   $0x0
f0103be4:	e8 3f ca ff ff       	call   f0100628 <iscons>
f0103be9:	89 c7                	mov    %eax,%edi
f0103beb:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103bee:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103bf3:	e8 1f ca ff ff       	call   f0100617 <getchar>
f0103bf8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103bfa:	85 c0                	test   %eax,%eax
f0103bfc:	79 18                	jns    f0103c16 <readline+0x58>
			cprintf("read error: %e\n", c);
f0103bfe:	83 ec 08             	sub    $0x8,%esp
f0103c01:	50                   	push   %eax
f0103c02:	68 60 5b 10 f0       	push   $0xf0105b60
f0103c07:	e8 95 f3 ff ff       	call   f0102fa1 <cprintf>
			return NULL;
f0103c0c:	83 c4 10             	add    $0x10,%esp
f0103c0f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c14:	eb 79                	jmp    f0103c8f <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103c16:	83 f8 08             	cmp    $0x8,%eax
f0103c19:	0f 94 c2             	sete   %dl
f0103c1c:	83 f8 7f             	cmp    $0x7f,%eax
f0103c1f:	0f 94 c0             	sete   %al
f0103c22:	08 c2                	or     %al,%dl
f0103c24:	74 1a                	je     f0103c40 <readline+0x82>
f0103c26:	85 f6                	test   %esi,%esi
f0103c28:	7e 16                	jle    f0103c40 <readline+0x82>
			if (echoing)
f0103c2a:	85 ff                	test   %edi,%edi
f0103c2c:	74 0d                	je     f0103c3b <readline+0x7d>
				cputchar('\b');
f0103c2e:	83 ec 0c             	sub    $0xc,%esp
f0103c31:	6a 08                	push   $0x8
f0103c33:	e8 cf c9 ff ff       	call   f0100607 <cputchar>
f0103c38:	83 c4 10             	add    $0x10,%esp
			i--;
f0103c3b:	83 ee 01             	sub    $0x1,%esi
f0103c3e:	eb b3                	jmp    f0103bf3 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103c40:	83 fb 1f             	cmp    $0x1f,%ebx
f0103c43:	7e 23                	jle    f0103c68 <readline+0xaa>
f0103c45:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103c4b:	7f 1b                	jg     f0103c68 <readline+0xaa>
			if (echoing)
f0103c4d:	85 ff                	test   %edi,%edi
f0103c4f:	74 0c                	je     f0103c5d <readline+0x9f>
				cputchar(c);
f0103c51:	83 ec 0c             	sub    $0xc,%esp
f0103c54:	53                   	push   %ebx
f0103c55:	e8 ad c9 ff ff       	call   f0100607 <cputchar>
f0103c5a:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103c5d:	88 9e 40 48 17 f0    	mov    %bl,-0xfe8b7c0(%esi)
f0103c63:	8d 76 01             	lea    0x1(%esi),%esi
f0103c66:	eb 8b                	jmp    f0103bf3 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103c68:	83 fb 0a             	cmp    $0xa,%ebx
f0103c6b:	74 05                	je     f0103c72 <readline+0xb4>
f0103c6d:	83 fb 0d             	cmp    $0xd,%ebx
f0103c70:	75 81                	jne    f0103bf3 <readline+0x35>
			if (echoing)
f0103c72:	85 ff                	test   %edi,%edi
f0103c74:	74 0d                	je     f0103c83 <readline+0xc5>
				cputchar('\n');
f0103c76:	83 ec 0c             	sub    $0xc,%esp
f0103c79:	6a 0a                	push   $0xa
f0103c7b:	e8 87 c9 ff ff       	call   f0100607 <cputchar>
f0103c80:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103c83:	c6 86 40 48 17 f0 00 	movb   $0x0,-0xfe8b7c0(%esi)
			return buf;
f0103c8a:	b8 40 48 17 f0       	mov    $0xf0174840,%eax
		}
	}
}
f0103c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103c92:	5b                   	pop    %ebx
f0103c93:	5e                   	pop    %esi
f0103c94:	5f                   	pop    %edi
f0103c95:	5d                   	pop    %ebp
f0103c96:	c3                   	ret    

f0103c97 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103c97:	55                   	push   %ebp
f0103c98:	89 e5                	mov    %esp,%ebp
f0103c9a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103c9d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ca2:	eb 03                	jmp    f0103ca7 <strlen+0x10>
		n++;
f0103ca4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103ca7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103cab:	75 f7                	jne    f0103ca4 <strlen+0xd>
		n++;
	return n;
}
f0103cad:	5d                   	pop    %ebp
f0103cae:	c3                   	ret    

f0103caf <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103caf:	55                   	push   %ebp
f0103cb0:	89 e5                	mov    %esp,%ebp
f0103cb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103cb8:	ba 00 00 00 00       	mov    $0x0,%edx
f0103cbd:	eb 03                	jmp    f0103cc2 <strnlen+0x13>
		n++;
f0103cbf:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103cc2:	39 c2                	cmp    %eax,%edx
f0103cc4:	74 08                	je     f0103cce <strnlen+0x1f>
f0103cc6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0103cca:	75 f3                	jne    f0103cbf <strnlen+0x10>
f0103ccc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0103cce:	5d                   	pop    %ebp
f0103ccf:	c3                   	ret    

f0103cd0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103cd0:	55                   	push   %ebp
f0103cd1:	89 e5                	mov    %esp,%ebp
f0103cd3:	53                   	push   %ebx
f0103cd4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103cda:	89 c2                	mov    %eax,%edx
f0103cdc:	83 c2 01             	add    $0x1,%edx
f0103cdf:	83 c1 01             	add    $0x1,%ecx
f0103ce2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103ce6:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103ce9:	84 db                	test   %bl,%bl
f0103ceb:	75 ef                	jne    f0103cdc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103ced:	5b                   	pop    %ebx
f0103cee:	5d                   	pop    %ebp
f0103cef:	c3                   	ret    

f0103cf0 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103cf0:	55                   	push   %ebp
f0103cf1:	89 e5                	mov    %esp,%ebp
f0103cf3:	53                   	push   %ebx
f0103cf4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103cf7:	53                   	push   %ebx
f0103cf8:	e8 9a ff ff ff       	call   f0103c97 <strlen>
f0103cfd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103d00:	ff 75 0c             	pushl  0xc(%ebp)
f0103d03:	01 d8                	add    %ebx,%eax
f0103d05:	50                   	push   %eax
f0103d06:	e8 c5 ff ff ff       	call   f0103cd0 <strcpy>
	return dst;
}
f0103d0b:	89 d8                	mov    %ebx,%eax
f0103d0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103d10:	c9                   	leave  
f0103d11:	c3                   	ret    

f0103d12 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103d12:	55                   	push   %ebp
f0103d13:	89 e5                	mov    %esp,%ebp
f0103d15:	56                   	push   %esi
f0103d16:	53                   	push   %ebx
f0103d17:	8b 75 08             	mov    0x8(%ebp),%esi
f0103d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103d1d:	89 f3                	mov    %esi,%ebx
f0103d1f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103d22:	89 f2                	mov    %esi,%edx
f0103d24:	eb 0f                	jmp    f0103d35 <strncpy+0x23>
		*dst++ = *src;
f0103d26:	83 c2 01             	add    $0x1,%edx
f0103d29:	0f b6 01             	movzbl (%ecx),%eax
f0103d2c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103d2f:	80 39 01             	cmpb   $0x1,(%ecx)
f0103d32:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103d35:	39 da                	cmp    %ebx,%edx
f0103d37:	75 ed                	jne    f0103d26 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103d39:	89 f0                	mov    %esi,%eax
f0103d3b:	5b                   	pop    %ebx
f0103d3c:	5e                   	pop    %esi
f0103d3d:	5d                   	pop    %ebp
f0103d3e:	c3                   	ret    

f0103d3f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103d3f:	55                   	push   %ebp
f0103d40:	89 e5                	mov    %esp,%ebp
f0103d42:	56                   	push   %esi
f0103d43:	53                   	push   %ebx
f0103d44:	8b 75 08             	mov    0x8(%ebp),%esi
f0103d47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103d4a:	8b 55 10             	mov    0x10(%ebp),%edx
f0103d4d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103d4f:	85 d2                	test   %edx,%edx
f0103d51:	74 21                	je     f0103d74 <strlcpy+0x35>
f0103d53:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103d57:	89 f2                	mov    %esi,%edx
f0103d59:	eb 09                	jmp    f0103d64 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103d5b:	83 c2 01             	add    $0x1,%edx
f0103d5e:	83 c1 01             	add    $0x1,%ecx
f0103d61:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103d64:	39 c2                	cmp    %eax,%edx
f0103d66:	74 09                	je     f0103d71 <strlcpy+0x32>
f0103d68:	0f b6 19             	movzbl (%ecx),%ebx
f0103d6b:	84 db                	test   %bl,%bl
f0103d6d:	75 ec                	jne    f0103d5b <strlcpy+0x1c>
f0103d6f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103d71:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103d74:	29 f0                	sub    %esi,%eax
}
f0103d76:	5b                   	pop    %ebx
f0103d77:	5e                   	pop    %esi
f0103d78:	5d                   	pop    %ebp
f0103d79:	c3                   	ret    

f0103d7a <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103d7a:	55                   	push   %ebp
f0103d7b:	89 e5                	mov    %esp,%ebp
f0103d7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103d80:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103d83:	eb 06                	jmp    f0103d8b <strcmp+0x11>
		p++, q++;
f0103d85:	83 c1 01             	add    $0x1,%ecx
f0103d88:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103d8b:	0f b6 01             	movzbl (%ecx),%eax
f0103d8e:	84 c0                	test   %al,%al
f0103d90:	74 04                	je     f0103d96 <strcmp+0x1c>
f0103d92:	3a 02                	cmp    (%edx),%al
f0103d94:	74 ef                	je     f0103d85 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103d96:	0f b6 c0             	movzbl %al,%eax
f0103d99:	0f b6 12             	movzbl (%edx),%edx
f0103d9c:	29 d0                	sub    %edx,%eax
}
f0103d9e:	5d                   	pop    %ebp
f0103d9f:	c3                   	ret    

f0103da0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103da0:	55                   	push   %ebp
f0103da1:	89 e5                	mov    %esp,%ebp
f0103da3:	53                   	push   %ebx
f0103da4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103da7:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103daa:	89 c3                	mov    %eax,%ebx
f0103dac:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103daf:	eb 06                	jmp    f0103db7 <strncmp+0x17>
		n--, p++, q++;
f0103db1:	83 c0 01             	add    $0x1,%eax
f0103db4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103db7:	39 d8                	cmp    %ebx,%eax
f0103db9:	74 15                	je     f0103dd0 <strncmp+0x30>
f0103dbb:	0f b6 08             	movzbl (%eax),%ecx
f0103dbe:	84 c9                	test   %cl,%cl
f0103dc0:	74 04                	je     f0103dc6 <strncmp+0x26>
f0103dc2:	3a 0a                	cmp    (%edx),%cl
f0103dc4:	74 eb                	je     f0103db1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103dc6:	0f b6 00             	movzbl (%eax),%eax
f0103dc9:	0f b6 12             	movzbl (%edx),%edx
f0103dcc:	29 d0                	sub    %edx,%eax
f0103dce:	eb 05                	jmp    f0103dd5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103dd0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103dd5:	5b                   	pop    %ebx
f0103dd6:	5d                   	pop    %ebp
f0103dd7:	c3                   	ret    

f0103dd8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103dd8:	55                   	push   %ebp
f0103dd9:	89 e5                	mov    %esp,%ebp
f0103ddb:	8b 45 08             	mov    0x8(%ebp),%eax
f0103dde:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103de2:	eb 07                	jmp    f0103deb <strchr+0x13>
		if (*s == c)
f0103de4:	38 ca                	cmp    %cl,%dl
f0103de6:	74 0f                	je     f0103df7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103de8:	83 c0 01             	add    $0x1,%eax
f0103deb:	0f b6 10             	movzbl (%eax),%edx
f0103dee:	84 d2                	test   %dl,%dl
f0103df0:	75 f2                	jne    f0103de4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0103df2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103df7:	5d                   	pop    %ebp
f0103df8:	c3                   	ret    

f0103df9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103df9:	55                   	push   %ebp
f0103dfa:	89 e5                	mov    %esp,%ebp
f0103dfc:	8b 45 08             	mov    0x8(%ebp),%eax
f0103dff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103e03:	eb 03                	jmp    f0103e08 <strfind+0xf>
f0103e05:	83 c0 01             	add    $0x1,%eax
f0103e08:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103e0b:	38 ca                	cmp    %cl,%dl
f0103e0d:	74 04                	je     f0103e13 <strfind+0x1a>
f0103e0f:	84 d2                	test   %dl,%dl
f0103e11:	75 f2                	jne    f0103e05 <strfind+0xc>
			break;
	return (char *) s;
}
f0103e13:	5d                   	pop    %ebp
f0103e14:	c3                   	ret    

f0103e15 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103e15:	55                   	push   %ebp
f0103e16:	89 e5                	mov    %esp,%ebp
f0103e18:	57                   	push   %edi
f0103e19:	56                   	push   %esi
f0103e1a:	53                   	push   %ebx
f0103e1b:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103e1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103e21:	85 c9                	test   %ecx,%ecx
f0103e23:	74 36                	je     f0103e5b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103e25:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103e2b:	75 28                	jne    f0103e55 <memset+0x40>
f0103e2d:	f6 c1 03             	test   $0x3,%cl
f0103e30:	75 23                	jne    f0103e55 <memset+0x40>
		c &= 0xFF;
f0103e32:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103e36:	89 d3                	mov    %edx,%ebx
f0103e38:	c1 e3 08             	shl    $0x8,%ebx
f0103e3b:	89 d6                	mov    %edx,%esi
f0103e3d:	c1 e6 18             	shl    $0x18,%esi
f0103e40:	89 d0                	mov    %edx,%eax
f0103e42:	c1 e0 10             	shl    $0x10,%eax
f0103e45:	09 f0                	or     %esi,%eax
f0103e47:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0103e49:	89 d8                	mov    %ebx,%eax
f0103e4b:	09 d0                	or     %edx,%eax
f0103e4d:	c1 e9 02             	shr    $0x2,%ecx
f0103e50:	fc                   	cld    
f0103e51:	f3 ab                	rep stos %eax,%es:(%edi)
f0103e53:	eb 06                	jmp    f0103e5b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103e55:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e58:	fc                   	cld    
f0103e59:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103e5b:	89 f8                	mov    %edi,%eax
f0103e5d:	5b                   	pop    %ebx
f0103e5e:	5e                   	pop    %esi
f0103e5f:	5f                   	pop    %edi
f0103e60:	5d                   	pop    %ebp
f0103e61:	c3                   	ret    

f0103e62 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103e62:	55                   	push   %ebp
f0103e63:	89 e5                	mov    %esp,%ebp
f0103e65:	57                   	push   %edi
f0103e66:	56                   	push   %esi
f0103e67:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e6a:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103e6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103e70:	39 c6                	cmp    %eax,%esi
f0103e72:	73 35                	jae    f0103ea9 <memmove+0x47>
f0103e74:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103e77:	39 d0                	cmp    %edx,%eax
f0103e79:	73 2e                	jae    f0103ea9 <memmove+0x47>
		s += n;
		d += n;
f0103e7b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103e7e:	89 d6                	mov    %edx,%esi
f0103e80:	09 fe                	or     %edi,%esi
f0103e82:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103e88:	75 13                	jne    f0103e9d <memmove+0x3b>
f0103e8a:	f6 c1 03             	test   $0x3,%cl
f0103e8d:	75 0e                	jne    f0103e9d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0103e8f:	83 ef 04             	sub    $0x4,%edi
f0103e92:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103e95:	c1 e9 02             	shr    $0x2,%ecx
f0103e98:	fd                   	std    
f0103e99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103e9b:	eb 09                	jmp    f0103ea6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103e9d:	83 ef 01             	sub    $0x1,%edi
f0103ea0:	8d 72 ff             	lea    -0x1(%edx),%esi
f0103ea3:	fd                   	std    
f0103ea4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103ea6:	fc                   	cld    
f0103ea7:	eb 1d                	jmp    f0103ec6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103ea9:	89 f2                	mov    %esi,%edx
f0103eab:	09 c2                	or     %eax,%edx
f0103ead:	f6 c2 03             	test   $0x3,%dl
f0103eb0:	75 0f                	jne    f0103ec1 <memmove+0x5f>
f0103eb2:	f6 c1 03             	test   $0x3,%cl
f0103eb5:	75 0a                	jne    f0103ec1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0103eb7:	c1 e9 02             	shr    $0x2,%ecx
f0103eba:	89 c7                	mov    %eax,%edi
f0103ebc:	fc                   	cld    
f0103ebd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103ebf:	eb 05                	jmp    f0103ec6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103ec1:	89 c7                	mov    %eax,%edi
f0103ec3:	fc                   	cld    
f0103ec4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103ec6:	5e                   	pop    %esi
f0103ec7:	5f                   	pop    %edi
f0103ec8:	5d                   	pop    %ebp
f0103ec9:	c3                   	ret    

f0103eca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103eca:	55                   	push   %ebp
f0103ecb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103ecd:	ff 75 10             	pushl  0x10(%ebp)
f0103ed0:	ff 75 0c             	pushl  0xc(%ebp)
f0103ed3:	ff 75 08             	pushl  0x8(%ebp)
f0103ed6:	e8 87 ff ff ff       	call   f0103e62 <memmove>
}
f0103edb:	c9                   	leave  
f0103edc:	c3                   	ret    

f0103edd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103edd:	55                   	push   %ebp
f0103ede:	89 e5                	mov    %esp,%ebp
f0103ee0:	56                   	push   %esi
f0103ee1:	53                   	push   %ebx
f0103ee2:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ee5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103ee8:	89 c6                	mov    %eax,%esi
f0103eea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103eed:	eb 1a                	jmp    f0103f09 <memcmp+0x2c>
		if (*s1 != *s2)
f0103eef:	0f b6 08             	movzbl (%eax),%ecx
f0103ef2:	0f b6 1a             	movzbl (%edx),%ebx
f0103ef5:	38 d9                	cmp    %bl,%cl
f0103ef7:	74 0a                	je     f0103f03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0103ef9:	0f b6 c1             	movzbl %cl,%eax
f0103efc:	0f b6 db             	movzbl %bl,%ebx
f0103eff:	29 d8                	sub    %ebx,%eax
f0103f01:	eb 0f                	jmp    f0103f12 <memcmp+0x35>
		s1++, s2++;
f0103f03:	83 c0 01             	add    $0x1,%eax
f0103f06:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103f09:	39 f0                	cmp    %esi,%eax
f0103f0b:	75 e2                	jne    f0103eef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103f0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103f12:	5b                   	pop    %ebx
f0103f13:	5e                   	pop    %esi
f0103f14:	5d                   	pop    %ebp
f0103f15:	c3                   	ret    

f0103f16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103f16:	55                   	push   %ebp
f0103f17:	89 e5                	mov    %esp,%ebp
f0103f19:	53                   	push   %ebx
f0103f1a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103f1d:	89 c1                	mov    %eax,%ecx
f0103f1f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0103f22:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103f26:	eb 0a                	jmp    f0103f32 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103f28:	0f b6 10             	movzbl (%eax),%edx
f0103f2b:	39 da                	cmp    %ebx,%edx
f0103f2d:	74 07                	je     f0103f36 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103f2f:	83 c0 01             	add    $0x1,%eax
f0103f32:	39 c8                	cmp    %ecx,%eax
f0103f34:	72 f2                	jb     f0103f28 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103f36:	5b                   	pop    %ebx
f0103f37:	5d                   	pop    %ebp
f0103f38:	c3                   	ret    

f0103f39 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103f39:	55                   	push   %ebp
f0103f3a:	89 e5                	mov    %esp,%ebp
f0103f3c:	57                   	push   %edi
f0103f3d:	56                   	push   %esi
f0103f3e:	53                   	push   %ebx
f0103f3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103f42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103f45:	eb 03                	jmp    f0103f4a <strtol+0x11>
		s++;
f0103f47:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103f4a:	0f b6 01             	movzbl (%ecx),%eax
f0103f4d:	3c 20                	cmp    $0x20,%al
f0103f4f:	74 f6                	je     f0103f47 <strtol+0xe>
f0103f51:	3c 09                	cmp    $0x9,%al
f0103f53:	74 f2                	je     f0103f47 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103f55:	3c 2b                	cmp    $0x2b,%al
f0103f57:	75 0a                	jne    f0103f63 <strtol+0x2a>
		s++;
f0103f59:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103f5c:	bf 00 00 00 00       	mov    $0x0,%edi
f0103f61:	eb 11                	jmp    f0103f74 <strtol+0x3b>
f0103f63:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103f68:	3c 2d                	cmp    $0x2d,%al
f0103f6a:	75 08                	jne    f0103f74 <strtol+0x3b>
		s++, neg = 1;
f0103f6c:	83 c1 01             	add    $0x1,%ecx
f0103f6f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103f74:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103f7a:	75 15                	jne    f0103f91 <strtol+0x58>
f0103f7c:	80 39 30             	cmpb   $0x30,(%ecx)
f0103f7f:	75 10                	jne    f0103f91 <strtol+0x58>
f0103f81:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103f85:	75 7c                	jne    f0104003 <strtol+0xca>
		s += 2, base = 16;
f0103f87:	83 c1 02             	add    $0x2,%ecx
f0103f8a:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103f8f:	eb 16                	jmp    f0103fa7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0103f91:	85 db                	test   %ebx,%ebx
f0103f93:	75 12                	jne    f0103fa7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103f95:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103f9a:	80 39 30             	cmpb   $0x30,(%ecx)
f0103f9d:	75 08                	jne    f0103fa7 <strtol+0x6e>
		s++, base = 8;
f0103f9f:	83 c1 01             	add    $0x1,%ecx
f0103fa2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0103fa7:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fac:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103faf:	0f b6 11             	movzbl (%ecx),%edx
f0103fb2:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103fb5:	89 f3                	mov    %esi,%ebx
f0103fb7:	80 fb 09             	cmp    $0x9,%bl
f0103fba:	77 08                	ja     f0103fc4 <strtol+0x8b>
			dig = *s - '0';
f0103fbc:	0f be d2             	movsbl %dl,%edx
f0103fbf:	83 ea 30             	sub    $0x30,%edx
f0103fc2:	eb 22                	jmp    f0103fe6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0103fc4:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103fc7:	89 f3                	mov    %esi,%ebx
f0103fc9:	80 fb 19             	cmp    $0x19,%bl
f0103fcc:	77 08                	ja     f0103fd6 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0103fce:	0f be d2             	movsbl %dl,%edx
f0103fd1:	83 ea 57             	sub    $0x57,%edx
f0103fd4:	eb 10                	jmp    f0103fe6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0103fd6:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103fd9:	89 f3                	mov    %esi,%ebx
f0103fdb:	80 fb 19             	cmp    $0x19,%bl
f0103fde:	77 16                	ja     f0103ff6 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0103fe0:	0f be d2             	movsbl %dl,%edx
f0103fe3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0103fe6:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103fe9:	7d 0b                	jge    f0103ff6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0103feb:	83 c1 01             	add    $0x1,%ecx
f0103fee:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103ff2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0103ff4:	eb b9                	jmp    f0103faf <strtol+0x76>

	if (endptr)
f0103ff6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103ffa:	74 0d                	je     f0104009 <strtol+0xd0>
		*endptr = (char *) s;
f0103ffc:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103fff:	89 0e                	mov    %ecx,(%esi)
f0104001:	eb 06                	jmp    f0104009 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104003:	85 db                	test   %ebx,%ebx
f0104005:	74 98                	je     f0103f9f <strtol+0x66>
f0104007:	eb 9e                	jmp    f0103fa7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0104009:	89 c2                	mov    %eax,%edx
f010400b:	f7 da                	neg    %edx
f010400d:	85 ff                	test   %edi,%edi
f010400f:	0f 45 c2             	cmovne %edx,%eax
}
f0104012:	5b                   	pop    %ebx
f0104013:	5e                   	pop    %esi
f0104014:	5f                   	pop    %edi
f0104015:	5d                   	pop    %ebp
f0104016:	c3                   	ret    
f0104017:	66 90                	xchg   %ax,%ax
f0104019:	66 90                	xchg   %ax,%ax
f010401b:	66 90                	xchg   %ax,%ax
f010401d:	66 90                	xchg   %ax,%ax
f010401f:	90                   	nop

f0104020 <__udivdi3>:
f0104020:	55                   	push   %ebp
f0104021:	57                   	push   %edi
f0104022:	56                   	push   %esi
f0104023:	53                   	push   %ebx
f0104024:	83 ec 1c             	sub    $0x1c,%esp
f0104027:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010402b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010402f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0104033:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104037:	85 f6                	test   %esi,%esi
f0104039:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010403d:	89 ca                	mov    %ecx,%edx
f010403f:	89 f8                	mov    %edi,%eax
f0104041:	75 3d                	jne    f0104080 <__udivdi3+0x60>
f0104043:	39 cf                	cmp    %ecx,%edi
f0104045:	0f 87 c5 00 00 00    	ja     f0104110 <__udivdi3+0xf0>
f010404b:	85 ff                	test   %edi,%edi
f010404d:	89 fd                	mov    %edi,%ebp
f010404f:	75 0b                	jne    f010405c <__udivdi3+0x3c>
f0104051:	b8 01 00 00 00       	mov    $0x1,%eax
f0104056:	31 d2                	xor    %edx,%edx
f0104058:	f7 f7                	div    %edi
f010405a:	89 c5                	mov    %eax,%ebp
f010405c:	89 c8                	mov    %ecx,%eax
f010405e:	31 d2                	xor    %edx,%edx
f0104060:	f7 f5                	div    %ebp
f0104062:	89 c1                	mov    %eax,%ecx
f0104064:	89 d8                	mov    %ebx,%eax
f0104066:	89 cf                	mov    %ecx,%edi
f0104068:	f7 f5                	div    %ebp
f010406a:	89 c3                	mov    %eax,%ebx
f010406c:	89 d8                	mov    %ebx,%eax
f010406e:	89 fa                	mov    %edi,%edx
f0104070:	83 c4 1c             	add    $0x1c,%esp
f0104073:	5b                   	pop    %ebx
f0104074:	5e                   	pop    %esi
f0104075:	5f                   	pop    %edi
f0104076:	5d                   	pop    %ebp
f0104077:	c3                   	ret    
f0104078:	90                   	nop
f0104079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104080:	39 ce                	cmp    %ecx,%esi
f0104082:	77 74                	ja     f01040f8 <__udivdi3+0xd8>
f0104084:	0f bd fe             	bsr    %esi,%edi
f0104087:	83 f7 1f             	xor    $0x1f,%edi
f010408a:	0f 84 98 00 00 00    	je     f0104128 <__udivdi3+0x108>
f0104090:	bb 20 00 00 00       	mov    $0x20,%ebx
f0104095:	89 f9                	mov    %edi,%ecx
f0104097:	89 c5                	mov    %eax,%ebp
f0104099:	29 fb                	sub    %edi,%ebx
f010409b:	d3 e6                	shl    %cl,%esi
f010409d:	89 d9                	mov    %ebx,%ecx
f010409f:	d3 ed                	shr    %cl,%ebp
f01040a1:	89 f9                	mov    %edi,%ecx
f01040a3:	d3 e0                	shl    %cl,%eax
f01040a5:	09 ee                	or     %ebp,%esi
f01040a7:	89 d9                	mov    %ebx,%ecx
f01040a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01040ad:	89 d5                	mov    %edx,%ebp
f01040af:	8b 44 24 08          	mov    0x8(%esp),%eax
f01040b3:	d3 ed                	shr    %cl,%ebp
f01040b5:	89 f9                	mov    %edi,%ecx
f01040b7:	d3 e2                	shl    %cl,%edx
f01040b9:	89 d9                	mov    %ebx,%ecx
f01040bb:	d3 e8                	shr    %cl,%eax
f01040bd:	09 c2                	or     %eax,%edx
f01040bf:	89 d0                	mov    %edx,%eax
f01040c1:	89 ea                	mov    %ebp,%edx
f01040c3:	f7 f6                	div    %esi
f01040c5:	89 d5                	mov    %edx,%ebp
f01040c7:	89 c3                	mov    %eax,%ebx
f01040c9:	f7 64 24 0c          	mull   0xc(%esp)
f01040cd:	39 d5                	cmp    %edx,%ebp
f01040cf:	72 10                	jb     f01040e1 <__udivdi3+0xc1>
f01040d1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01040d5:	89 f9                	mov    %edi,%ecx
f01040d7:	d3 e6                	shl    %cl,%esi
f01040d9:	39 c6                	cmp    %eax,%esi
f01040db:	73 07                	jae    f01040e4 <__udivdi3+0xc4>
f01040dd:	39 d5                	cmp    %edx,%ebp
f01040df:	75 03                	jne    f01040e4 <__udivdi3+0xc4>
f01040e1:	83 eb 01             	sub    $0x1,%ebx
f01040e4:	31 ff                	xor    %edi,%edi
f01040e6:	89 d8                	mov    %ebx,%eax
f01040e8:	89 fa                	mov    %edi,%edx
f01040ea:	83 c4 1c             	add    $0x1c,%esp
f01040ed:	5b                   	pop    %ebx
f01040ee:	5e                   	pop    %esi
f01040ef:	5f                   	pop    %edi
f01040f0:	5d                   	pop    %ebp
f01040f1:	c3                   	ret    
f01040f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01040f8:	31 ff                	xor    %edi,%edi
f01040fa:	31 db                	xor    %ebx,%ebx
f01040fc:	89 d8                	mov    %ebx,%eax
f01040fe:	89 fa                	mov    %edi,%edx
f0104100:	83 c4 1c             	add    $0x1c,%esp
f0104103:	5b                   	pop    %ebx
f0104104:	5e                   	pop    %esi
f0104105:	5f                   	pop    %edi
f0104106:	5d                   	pop    %ebp
f0104107:	c3                   	ret    
f0104108:	90                   	nop
f0104109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104110:	89 d8                	mov    %ebx,%eax
f0104112:	f7 f7                	div    %edi
f0104114:	31 ff                	xor    %edi,%edi
f0104116:	89 c3                	mov    %eax,%ebx
f0104118:	89 d8                	mov    %ebx,%eax
f010411a:	89 fa                	mov    %edi,%edx
f010411c:	83 c4 1c             	add    $0x1c,%esp
f010411f:	5b                   	pop    %ebx
f0104120:	5e                   	pop    %esi
f0104121:	5f                   	pop    %edi
f0104122:	5d                   	pop    %ebp
f0104123:	c3                   	ret    
f0104124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104128:	39 ce                	cmp    %ecx,%esi
f010412a:	72 0c                	jb     f0104138 <__udivdi3+0x118>
f010412c:	31 db                	xor    %ebx,%ebx
f010412e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0104132:	0f 87 34 ff ff ff    	ja     f010406c <__udivdi3+0x4c>
f0104138:	bb 01 00 00 00       	mov    $0x1,%ebx
f010413d:	e9 2a ff ff ff       	jmp    f010406c <__udivdi3+0x4c>
f0104142:	66 90                	xchg   %ax,%ax
f0104144:	66 90                	xchg   %ax,%ax
f0104146:	66 90                	xchg   %ax,%ax
f0104148:	66 90                	xchg   %ax,%ax
f010414a:	66 90                	xchg   %ax,%ax
f010414c:	66 90                	xchg   %ax,%ax
f010414e:	66 90                	xchg   %ax,%ax

f0104150 <__umoddi3>:
f0104150:	55                   	push   %ebp
f0104151:	57                   	push   %edi
f0104152:	56                   	push   %esi
f0104153:	53                   	push   %ebx
f0104154:	83 ec 1c             	sub    $0x1c,%esp
f0104157:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010415b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010415f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104163:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104167:	85 d2                	test   %edx,%edx
f0104169:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010416d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104171:	89 f3                	mov    %esi,%ebx
f0104173:	89 3c 24             	mov    %edi,(%esp)
f0104176:	89 74 24 04          	mov    %esi,0x4(%esp)
f010417a:	75 1c                	jne    f0104198 <__umoddi3+0x48>
f010417c:	39 f7                	cmp    %esi,%edi
f010417e:	76 50                	jbe    f01041d0 <__umoddi3+0x80>
f0104180:	89 c8                	mov    %ecx,%eax
f0104182:	89 f2                	mov    %esi,%edx
f0104184:	f7 f7                	div    %edi
f0104186:	89 d0                	mov    %edx,%eax
f0104188:	31 d2                	xor    %edx,%edx
f010418a:	83 c4 1c             	add    $0x1c,%esp
f010418d:	5b                   	pop    %ebx
f010418e:	5e                   	pop    %esi
f010418f:	5f                   	pop    %edi
f0104190:	5d                   	pop    %ebp
f0104191:	c3                   	ret    
f0104192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104198:	39 f2                	cmp    %esi,%edx
f010419a:	89 d0                	mov    %edx,%eax
f010419c:	77 52                	ja     f01041f0 <__umoddi3+0xa0>
f010419e:	0f bd ea             	bsr    %edx,%ebp
f01041a1:	83 f5 1f             	xor    $0x1f,%ebp
f01041a4:	75 5a                	jne    f0104200 <__umoddi3+0xb0>
f01041a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01041aa:	0f 82 e0 00 00 00    	jb     f0104290 <__umoddi3+0x140>
f01041b0:	39 0c 24             	cmp    %ecx,(%esp)
f01041b3:	0f 86 d7 00 00 00    	jbe    f0104290 <__umoddi3+0x140>
f01041b9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01041bd:	8b 54 24 04          	mov    0x4(%esp),%edx
f01041c1:	83 c4 1c             	add    $0x1c,%esp
f01041c4:	5b                   	pop    %ebx
f01041c5:	5e                   	pop    %esi
f01041c6:	5f                   	pop    %edi
f01041c7:	5d                   	pop    %ebp
f01041c8:	c3                   	ret    
f01041c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01041d0:	85 ff                	test   %edi,%edi
f01041d2:	89 fd                	mov    %edi,%ebp
f01041d4:	75 0b                	jne    f01041e1 <__umoddi3+0x91>
f01041d6:	b8 01 00 00 00       	mov    $0x1,%eax
f01041db:	31 d2                	xor    %edx,%edx
f01041dd:	f7 f7                	div    %edi
f01041df:	89 c5                	mov    %eax,%ebp
f01041e1:	89 f0                	mov    %esi,%eax
f01041e3:	31 d2                	xor    %edx,%edx
f01041e5:	f7 f5                	div    %ebp
f01041e7:	89 c8                	mov    %ecx,%eax
f01041e9:	f7 f5                	div    %ebp
f01041eb:	89 d0                	mov    %edx,%eax
f01041ed:	eb 99                	jmp    f0104188 <__umoddi3+0x38>
f01041ef:	90                   	nop
f01041f0:	89 c8                	mov    %ecx,%eax
f01041f2:	89 f2                	mov    %esi,%edx
f01041f4:	83 c4 1c             	add    $0x1c,%esp
f01041f7:	5b                   	pop    %ebx
f01041f8:	5e                   	pop    %esi
f01041f9:	5f                   	pop    %edi
f01041fa:	5d                   	pop    %ebp
f01041fb:	c3                   	ret    
f01041fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104200:	8b 34 24             	mov    (%esp),%esi
f0104203:	bf 20 00 00 00       	mov    $0x20,%edi
f0104208:	89 e9                	mov    %ebp,%ecx
f010420a:	29 ef                	sub    %ebp,%edi
f010420c:	d3 e0                	shl    %cl,%eax
f010420e:	89 f9                	mov    %edi,%ecx
f0104210:	89 f2                	mov    %esi,%edx
f0104212:	d3 ea                	shr    %cl,%edx
f0104214:	89 e9                	mov    %ebp,%ecx
f0104216:	09 c2                	or     %eax,%edx
f0104218:	89 d8                	mov    %ebx,%eax
f010421a:	89 14 24             	mov    %edx,(%esp)
f010421d:	89 f2                	mov    %esi,%edx
f010421f:	d3 e2                	shl    %cl,%edx
f0104221:	89 f9                	mov    %edi,%ecx
f0104223:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104227:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010422b:	d3 e8                	shr    %cl,%eax
f010422d:	89 e9                	mov    %ebp,%ecx
f010422f:	89 c6                	mov    %eax,%esi
f0104231:	d3 e3                	shl    %cl,%ebx
f0104233:	89 f9                	mov    %edi,%ecx
f0104235:	89 d0                	mov    %edx,%eax
f0104237:	d3 e8                	shr    %cl,%eax
f0104239:	89 e9                	mov    %ebp,%ecx
f010423b:	09 d8                	or     %ebx,%eax
f010423d:	89 d3                	mov    %edx,%ebx
f010423f:	89 f2                	mov    %esi,%edx
f0104241:	f7 34 24             	divl   (%esp)
f0104244:	89 d6                	mov    %edx,%esi
f0104246:	d3 e3                	shl    %cl,%ebx
f0104248:	f7 64 24 04          	mull   0x4(%esp)
f010424c:	39 d6                	cmp    %edx,%esi
f010424e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104252:	89 d1                	mov    %edx,%ecx
f0104254:	89 c3                	mov    %eax,%ebx
f0104256:	72 08                	jb     f0104260 <__umoddi3+0x110>
f0104258:	75 11                	jne    f010426b <__umoddi3+0x11b>
f010425a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010425e:	73 0b                	jae    f010426b <__umoddi3+0x11b>
f0104260:	2b 44 24 04          	sub    0x4(%esp),%eax
f0104264:	1b 14 24             	sbb    (%esp),%edx
f0104267:	89 d1                	mov    %edx,%ecx
f0104269:	89 c3                	mov    %eax,%ebx
f010426b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010426f:	29 da                	sub    %ebx,%edx
f0104271:	19 ce                	sbb    %ecx,%esi
f0104273:	89 f9                	mov    %edi,%ecx
f0104275:	89 f0                	mov    %esi,%eax
f0104277:	d3 e0                	shl    %cl,%eax
f0104279:	89 e9                	mov    %ebp,%ecx
f010427b:	d3 ea                	shr    %cl,%edx
f010427d:	89 e9                	mov    %ebp,%ecx
f010427f:	d3 ee                	shr    %cl,%esi
f0104281:	09 d0                	or     %edx,%eax
f0104283:	89 f2                	mov    %esi,%edx
f0104285:	83 c4 1c             	add    $0x1c,%esp
f0104288:	5b                   	pop    %ebx
f0104289:	5e                   	pop    %esi
f010428a:	5f                   	pop    %edi
f010428b:	5d                   	pop    %ebp
f010428c:	c3                   	ret    
f010428d:	8d 76 00             	lea    0x0(%esi),%esi
f0104290:	29 f9                	sub    %edi,%ecx
f0104292:	19 d6                	sbb    %edx,%esi
f0104294:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104298:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010429c:	e9 18 ff ff ff       	jmp    f01041b9 <__umoddi3+0x69>
