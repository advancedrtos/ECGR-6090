
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
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


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
f0100046:	b8 50 29 11 f0       	mov    $0xf0112950,%eax
f010004b:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 23 11 f0       	push   $0xf0112300
f0100058:	e8 de 14 00 00       	call   f010153b <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 88 04 00 00       	call   f01004ea <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 e0 19 10 f0       	push   $0xf01019e0
f010006f:	e8 1e 0a 00 00       	call   f0100a92 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 51 08 00 00       	call   f01008ca <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 10 07 00 00       	call   f0100796 <monitor>
f0100086:	83 c4 10             	add    $0x10,%esp
f0100089:	eb f1                	jmp    f010007c <i386_init+0x3c>

f010008b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010008b:	55                   	push   %ebp
f010008c:	89 e5                	mov    %esp,%ebp
f010008e:	56                   	push   %esi
f010008f:	53                   	push   %ebx
f0100090:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100093:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000a2:	fa                   	cli    
f01000a3:	fc                   	cld    

	va_start(ap, fmt);
f01000a4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a7:	83 ec 04             	sub    $0x4,%esp
f01000aa:	ff 75 0c             	pushl  0xc(%ebp)
f01000ad:	ff 75 08             	pushl  0x8(%ebp)
f01000b0:	68 fb 19 10 f0       	push   $0xf01019fb
f01000b5:	e8 d8 09 00 00       	call   f0100a92 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 a8 09 00 00       	call   f0100a6c <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 37 1a 10 f0 	movl   $0xf0101a37,(%esp)
f01000cb:	e8 c2 09 00 00       	call   f0100a92 <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 b9 06 00 00       	call   f0100796 <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x48>

f01000e2 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000e2:	55                   	push   %ebp
f01000e3:	89 e5                	mov    %esp,%ebp
f01000e5:	53                   	push   %ebx
f01000e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000e9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	68 13 1a 10 f0       	push   $0xf0101a13
f01000f7:	e8 96 09 00 00       	call   f0100a92 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 64 09 00 00       	call   f0100a6c <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 37 1a 10 f0 	movl   $0xf0101a37,(%esp)
f010010f:	e8 7e 09 00 00       	call   f0100a92 <cprintf>
	va_end(ap);
}
f0100114:	83 c4 10             	add    $0x10,%esp
f0100117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010011a:	c9                   	leave  
f010011b:	c3                   	ret    

f010011c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010011c:	55                   	push   %ebp
f010011d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010011f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100124:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100125:	a8 01                	test   $0x1,%al
f0100127:	74 0b                	je     f0100134 <serial_proc_data+0x18>
f0100129:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010012e:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010012f:	0f b6 c0             	movzbl %al,%eax
f0100132:	eb 05                	jmp    f0100139 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100139:	5d                   	pop    %ebp
f010013a:	c3                   	ret    

f010013b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010013b:	55                   	push   %ebp
f010013c:	89 e5                	mov    %esp,%ebp
f010013e:	53                   	push   %ebx
f010013f:	83 ec 04             	sub    $0x4,%esp
f0100142:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100144:	eb 2b                	jmp    f0100171 <cons_intr+0x36>
		if (c == 0)
f0100146:	85 c0                	test   %eax,%eax
f0100148:	74 27                	je     f0100171 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010014a:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f0100150:	8d 51 01             	lea    0x1(%ecx),%edx
f0100153:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f0100159:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010015f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100165:	75 0a                	jne    f0100171 <cons_intr+0x36>
			cons.wpos = 0;
f0100167:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f010016e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100171:	ff d3                	call   *%ebx
f0100173:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100176:	75 ce                	jne    f0100146 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100178:	83 c4 04             	add    $0x4,%esp
f010017b:	5b                   	pop    %ebx
f010017c:	5d                   	pop    %ebp
f010017d:	c3                   	ret    

f010017e <kbd_proc_data>:
f010017e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100183:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100184:	a8 01                	test   $0x1,%al
f0100186:	0f 84 f0 00 00 00    	je     f010027c <kbd_proc_data+0xfe>
f010018c:	ba 60 00 00 00       	mov    $0x60,%edx
f0100191:	ec                   	in     (%dx),%al
f0100192:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100194:	3c e0                	cmp    $0xe0,%al
f0100196:	75 0d                	jne    f01001a5 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f0100198:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f010019f:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001a4:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001a5:	55                   	push   %ebp
f01001a6:	89 e5                	mov    %esp,%ebp
f01001a8:	53                   	push   %ebx
f01001a9:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001ac:	84 c0                	test   %al,%al
f01001ae:	79 36                	jns    f01001e6 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001b0:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f01001b6:	89 cb                	mov    %ecx,%ebx
f01001b8:	83 e3 40             	and    $0x40,%ebx
f01001bb:	83 e0 7f             	and    $0x7f,%eax
f01001be:	85 db                	test   %ebx,%ebx
f01001c0:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001c3:	0f b6 d2             	movzbl %dl,%edx
f01001c6:	0f b6 82 80 1b 10 f0 	movzbl -0xfefe480(%edx),%eax
f01001cd:	83 c8 40             	or     $0x40,%eax
f01001d0:	0f b6 c0             	movzbl %al,%eax
f01001d3:	f7 d0                	not    %eax
f01001d5:	21 c8                	and    %ecx,%eax
f01001d7:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f01001dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01001e1:	e9 9e 00 00 00       	jmp    f0100284 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f01001e6:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f01001ec:	f6 c1 40             	test   $0x40,%cl
f01001ef:	74 0e                	je     f01001ff <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001f1:	83 c8 80             	or     $0xffffff80,%eax
f01001f4:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001f6:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001f9:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f01001ff:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100202:	0f b6 82 80 1b 10 f0 	movzbl -0xfefe480(%edx),%eax
f0100209:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f010020f:	0f b6 8a 80 1a 10 f0 	movzbl -0xfefe580(%edx),%ecx
f0100216:	31 c8                	xor    %ecx,%eax
f0100218:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f010021d:	89 c1                	mov    %eax,%ecx
f010021f:	83 e1 03             	and    $0x3,%ecx
f0100222:	8b 0c 8d 60 1a 10 f0 	mov    -0xfefe5a0(,%ecx,4),%ecx
f0100229:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010022d:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100230:	a8 08                	test   $0x8,%al
f0100232:	74 1b                	je     f010024f <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100234:	89 da                	mov    %ebx,%edx
f0100236:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100239:	83 f9 19             	cmp    $0x19,%ecx
f010023c:	77 05                	ja     f0100243 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f010023e:	83 eb 20             	sub    $0x20,%ebx
f0100241:	eb 0c                	jmp    f010024f <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100243:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100246:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100249:	83 fa 19             	cmp    $0x19,%edx
f010024c:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010024f:	f7 d0                	not    %eax
f0100251:	a8 06                	test   $0x6,%al
f0100253:	75 2d                	jne    f0100282 <kbd_proc_data+0x104>
f0100255:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010025b:	75 25                	jne    f0100282 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010025d:	83 ec 0c             	sub    $0xc,%esp
f0100260:	68 2d 1a 10 f0       	push   $0xf0101a2d
f0100265:	e8 28 08 00 00       	call   f0100a92 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010026a:	ba 92 00 00 00       	mov    $0x92,%edx
f010026f:	b8 03 00 00 00       	mov    $0x3,%eax
f0100274:	ee                   	out    %al,(%dx)
f0100275:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100278:	89 d8                	mov    %ebx,%eax
f010027a:	eb 08                	jmp    f0100284 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010027c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100281:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100282:	89 d8                	mov    %ebx,%eax
}
f0100284:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100287:	c9                   	leave  
f0100288:	c3                   	ret    

f0100289 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100289:	55                   	push   %ebp
f010028a:	89 e5                	mov    %esp,%ebp
f010028c:	57                   	push   %edi
f010028d:	56                   	push   %esi
f010028e:	53                   	push   %ebx
f010028f:	83 ec 1c             	sub    $0x1c,%esp
f0100292:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100294:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100299:	be fd 03 00 00       	mov    $0x3fd,%esi
f010029e:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002a3:	eb 09                	jmp    f01002ae <cons_putc+0x25>
f01002a5:	89 ca                	mov    %ecx,%edx
f01002a7:	ec                   	in     (%dx),%al
f01002a8:	ec                   	in     (%dx),%al
f01002a9:	ec                   	in     (%dx),%al
f01002aa:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002ab:	83 c3 01             	add    $0x1,%ebx
f01002ae:	89 f2                	mov    %esi,%edx
f01002b0:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002b1:	a8 20                	test   $0x20,%al
f01002b3:	75 08                	jne    f01002bd <cons_putc+0x34>
f01002b5:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002bb:	7e e8                	jle    f01002a5 <cons_putc+0x1c>
f01002bd:	89 f8                	mov    %edi,%eax
f01002bf:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c2:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002c7:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002c8:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002cd:	be 79 03 00 00       	mov    $0x379,%esi
f01002d2:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002d7:	eb 09                	jmp    f01002e2 <cons_putc+0x59>
f01002d9:	89 ca                	mov    %ecx,%edx
f01002db:	ec                   	in     (%dx),%al
f01002dc:	ec                   	in     (%dx),%al
f01002dd:	ec                   	in     (%dx),%al
f01002de:	ec                   	in     (%dx),%al
f01002df:	83 c3 01             	add    $0x1,%ebx
f01002e2:	89 f2                	mov    %esi,%edx
f01002e4:	ec                   	in     (%dx),%al
f01002e5:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002eb:	7f 04                	jg     f01002f1 <cons_putc+0x68>
f01002ed:	84 c0                	test   %al,%al
f01002ef:	79 e8                	jns    f01002d9 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002f1:	ba 78 03 00 00       	mov    $0x378,%edx
f01002f6:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01002fa:	ee                   	out    %al,(%dx)
f01002fb:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100300:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100305:	ee                   	out    %al,(%dx)
f0100306:	b8 08 00 00 00       	mov    $0x8,%eax
f010030b:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010030c:	89 fa                	mov    %edi,%edx
f010030e:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100314:	89 f8                	mov    %edi,%eax
f0100316:	80 cc 07             	or     $0x7,%ah
f0100319:	85 d2                	test   %edx,%edx
f010031b:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010031e:	89 f8                	mov    %edi,%eax
f0100320:	0f b6 c0             	movzbl %al,%eax
f0100323:	83 f8 09             	cmp    $0x9,%eax
f0100326:	74 74                	je     f010039c <cons_putc+0x113>
f0100328:	83 f8 09             	cmp    $0x9,%eax
f010032b:	7f 0a                	jg     f0100337 <cons_putc+0xae>
f010032d:	83 f8 08             	cmp    $0x8,%eax
f0100330:	74 14                	je     f0100346 <cons_putc+0xbd>
f0100332:	e9 99 00 00 00       	jmp    f01003d0 <cons_putc+0x147>
f0100337:	83 f8 0a             	cmp    $0xa,%eax
f010033a:	74 3a                	je     f0100376 <cons_putc+0xed>
f010033c:	83 f8 0d             	cmp    $0xd,%eax
f010033f:	74 3d                	je     f010037e <cons_putc+0xf5>
f0100341:	e9 8a 00 00 00       	jmp    f01003d0 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100346:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010034d:	66 85 c0             	test   %ax,%ax
f0100350:	0f 84 e6 00 00 00    	je     f010043c <cons_putc+0x1b3>
			crt_pos--;
f0100356:	83 e8 01             	sub    $0x1,%eax
f0100359:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010035f:	0f b7 c0             	movzwl %ax,%eax
f0100362:	66 81 e7 00 ff       	and    $0xff00,%di
f0100367:	83 cf 20             	or     $0x20,%edi
f010036a:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100370:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100374:	eb 78                	jmp    f01003ee <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100376:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f010037d:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010037e:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100385:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010038b:	c1 e8 16             	shr    $0x16,%eax
f010038e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100391:	c1 e0 04             	shl    $0x4,%eax
f0100394:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f010039a:	eb 52                	jmp    f01003ee <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f010039c:	b8 20 00 00 00       	mov    $0x20,%eax
f01003a1:	e8 e3 fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003a6:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ab:	e8 d9 fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003b0:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b5:	e8 cf fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003ba:	b8 20 00 00 00       	mov    $0x20,%eax
f01003bf:	e8 c5 fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003c4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c9:	e8 bb fe ff ff       	call   f0100289 <cons_putc>
f01003ce:	eb 1e                	jmp    f01003ee <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003d0:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003d7:	8d 50 01             	lea    0x1(%eax),%edx
f01003da:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f01003e1:	0f b7 c0             	movzwl %ax,%eax
f01003e4:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003ea:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003ee:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f01003f5:	cf 07 
f01003f7:	76 43                	jbe    f010043c <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01003f9:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f01003fe:	83 ec 04             	sub    $0x4,%esp
f0100401:	68 00 0f 00 00       	push   $0xf00
f0100406:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010040c:	52                   	push   %edx
f010040d:	50                   	push   %eax
f010040e:	e8 75 11 00 00       	call   f0101588 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100413:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100419:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010041f:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100425:	83 c4 10             	add    $0x10,%esp
f0100428:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010042d:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100430:	39 d0                	cmp    %edx,%eax
f0100432:	75 f4                	jne    f0100428 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100434:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f010043b:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010043c:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f0100442:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100447:	89 ca                	mov    %ecx,%edx
f0100449:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010044a:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f0100451:	8d 71 01             	lea    0x1(%ecx),%esi
f0100454:	89 d8                	mov    %ebx,%eax
f0100456:	66 c1 e8 08          	shr    $0x8,%ax
f010045a:	89 f2                	mov    %esi,%edx
f010045c:	ee                   	out    %al,(%dx)
f010045d:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100462:	89 ca                	mov    %ecx,%edx
f0100464:	ee                   	out    %al,(%dx)
f0100465:	89 d8                	mov    %ebx,%eax
f0100467:	89 f2                	mov    %esi,%edx
f0100469:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010046a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010046d:	5b                   	pop    %ebx
f010046e:	5e                   	pop    %esi
f010046f:	5f                   	pop    %edi
f0100470:	5d                   	pop    %ebp
f0100471:	c3                   	ret    

f0100472 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100472:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f0100479:	74 11                	je     f010048c <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010047b:	55                   	push   %ebp
f010047c:	89 e5                	mov    %esp,%ebp
f010047e:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100481:	b8 1c 01 10 f0       	mov    $0xf010011c,%eax
f0100486:	e8 b0 fc ff ff       	call   f010013b <cons_intr>
}
f010048b:	c9                   	leave  
f010048c:	f3 c3                	repz ret 

f010048e <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010048e:	55                   	push   %ebp
f010048f:	89 e5                	mov    %esp,%ebp
f0100491:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100494:	b8 7e 01 10 f0       	mov    $0xf010017e,%eax
f0100499:	e8 9d fc ff ff       	call   f010013b <cons_intr>
}
f010049e:	c9                   	leave  
f010049f:	c3                   	ret    

f01004a0 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004a0:	55                   	push   %ebp
f01004a1:	89 e5                	mov    %esp,%ebp
f01004a3:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004a6:	e8 c7 ff ff ff       	call   f0100472 <serial_intr>
	kbd_intr();
f01004ab:	e8 de ff ff ff       	call   f010048e <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004b0:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f01004b5:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f01004bb:	74 26                	je     f01004e3 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004bd:	8d 50 01             	lea    0x1(%eax),%edx
f01004c0:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f01004c6:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004cd:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004cf:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004d5:	75 11                	jne    f01004e8 <cons_getc+0x48>
			cons.rpos = 0;
f01004d7:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f01004de:	00 00 00 
f01004e1:	eb 05                	jmp    f01004e8 <cons_getc+0x48>
		return c;
	}
	return 0;
f01004e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004e8:	c9                   	leave  
f01004e9:	c3                   	ret    

f01004ea <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004ea:	55                   	push   %ebp
f01004eb:	89 e5                	mov    %esp,%ebp
f01004ed:	57                   	push   %edi
f01004ee:	56                   	push   %esi
f01004ef:	53                   	push   %ebx
f01004f0:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01004f3:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01004fa:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100501:	5a a5 
	if (*cp != 0xA55A) {
f0100503:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010050a:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010050e:	74 11                	je     f0100521 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100510:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100517:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010051a:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010051f:	eb 16                	jmp    f0100537 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100521:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100528:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f010052f:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100532:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100537:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f010053d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100542:	89 fa                	mov    %edi,%edx
f0100544:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100545:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100548:	89 da                	mov    %ebx,%edx
f010054a:	ec                   	in     (%dx),%al
f010054b:	0f b6 c8             	movzbl %al,%ecx
f010054e:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100551:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100556:	89 fa                	mov    %edi,%edx
f0100558:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100559:	89 da                	mov    %ebx,%edx
f010055b:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010055c:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f0100562:	0f b6 c0             	movzbl %al,%eax
f0100565:	09 c8                	or     %ecx,%eax
f0100567:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010056d:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100572:	b8 00 00 00 00       	mov    $0x0,%eax
f0100577:	89 f2                	mov    %esi,%edx
f0100579:	ee                   	out    %al,(%dx)
f010057a:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010057f:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100584:	ee                   	out    %al,(%dx)
f0100585:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010058a:	b8 0c 00 00 00       	mov    $0xc,%eax
f010058f:	89 da                	mov    %ebx,%edx
f0100591:	ee                   	out    %al,(%dx)
f0100592:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100597:	b8 00 00 00 00       	mov    $0x0,%eax
f010059c:	ee                   	out    %al,(%dx)
f010059d:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005a2:	b8 03 00 00 00       	mov    $0x3,%eax
f01005a7:	ee                   	out    %al,(%dx)
f01005a8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01005b2:	ee                   	out    %al,(%dx)
f01005b3:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005b8:	b8 01 00 00 00       	mov    $0x1,%eax
f01005bd:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005be:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005c3:	ec                   	in     (%dx),%al
f01005c4:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005c6:	3c ff                	cmp    $0xff,%al
f01005c8:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f01005cf:	89 f2                	mov    %esi,%edx
f01005d1:	ec                   	in     (%dx),%al
f01005d2:	89 da                	mov    %ebx,%edx
f01005d4:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005d5:	80 f9 ff             	cmp    $0xff,%cl
f01005d8:	75 10                	jne    f01005ea <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005da:	83 ec 0c             	sub    $0xc,%esp
f01005dd:	68 39 1a 10 f0       	push   $0xf0101a39
f01005e2:	e8 ab 04 00 00       	call   f0100a92 <cprintf>
f01005e7:	83 c4 10             	add    $0x10,%esp
}
f01005ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005ed:	5b                   	pop    %ebx
f01005ee:	5e                   	pop    %esi
f01005ef:	5f                   	pop    %edi
f01005f0:	5d                   	pop    %ebp
f01005f1:	c3                   	ret    

f01005f2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005f2:	55                   	push   %ebp
f01005f3:	89 e5                	mov    %esp,%ebp
f01005f5:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01005fb:	e8 89 fc ff ff       	call   f0100289 <cons_putc>
}
f0100600:	c9                   	leave  
f0100601:	c3                   	ret    

f0100602 <getchar>:

int
getchar(void)
{
f0100602:	55                   	push   %ebp
f0100603:	89 e5                	mov    %esp,%ebp
f0100605:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100608:	e8 93 fe ff ff       	call   f01004a0 <cons_getc>
f010060d:	85 c0                	test   %eax,%eax
f010060f:	74 f7                	je     f0100608 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100611:	c9                   	leave  
f0100612:	c3                   	ret    

f0100613 <iscons>:

int
iscons(int fdnum)
{
f0100613:	55                   	push   %ebp
f0100614:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100616:	b8 01 00 00 00       	mov    $0x1,%eax
f010061b:	5d                   	pop    %ebp
f010061c:	c3                   	ret    

f010061d <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010061d:	55                   	push   %ebp
f010061e:	89 e5                	mov    %esp,%ebp
f0100620:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100623:	68 80 1c 10 f0       	push   $0xf0101c80
f0100628:	68 9e 1c 10 f0       	push   $0xf0101c9e
f010062d:	68 a3 1c 10 f0       	push   $0xf0101ca3
f0100632:	e8 5b 04 00 00       	call   f0100a92 <cprintf>
f0100637:	83 c4 0c             	add    $0xc,%esp
f010063a:	68 50 1d 10 f0       	push   $0xf0101d50
f010063f:	68 ac 1c 10 f0       	push   $0xf0101cac
f0100644:	68 a3 1c 10 f0       	push   $0xf0101ca3
f0100649:	e8 44 04 00 00       	call   f0100a92 <cprintf>
f010064e:	83 c4 0c             	add    $0xc,%esp
f0100651:	68 b5 1c 10 f0       	push   $0xf0101cb5
f0100656:	68 c3 1c 10 f0       	push   $0xf0101cc3
f010065b:	68 a3 1c 10 f0       	push   $0xf0101ca3
f0100660:	e8 2d 04 00 00       	call   f0100a92 <cprintf>
	return 0;
}
f0100665:	b8 00 00 00 00       	mov    $0x0,%eax
f010066a:	c9                   	leave  
f010066b:	c3                   	ret    

f010066c <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010066c:	55                   	push   %ebp
f010066d:	89 e5                	mov    %esp,%ebp
f010066f:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100672:	68 cd 1c 10 f0       	push   $0xf0101ccd
f0100677:	e8 16 04 00 00       	call   f0100a92 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010067c:	83 c4 08             	add    $0x8,%esp
f010067f:	68 0c 00 10 00       	push   $0x10000c
f0100684:	68 78 1d 10 f0       	push   $0xf0101d78
f0100689:	e8 04 04 00 00       	call   f0100a92 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010068e:	83 c4 0c             	add    $0xc,%esp
f0100691:	68 0c 00 10 00       	push   $0x10000c
f0100696:	68 0c 00 10 f0       	push   $0xf010000c
f010069b:	68 a0 1d 10 f0       	push   $0xf0101da0
f01006a0:	e8 ed 03 00 00       	call   f0100a92 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006a5:	83 c4 0c             	add    $0xc,%esp
f01006a8:	68 c1 19 10 00       	push   $0x1019c1
f01006ad:	68 c1 19 10 f0       	push   $0xf01019c1
f01006b2:	68 c4 1d 10 f0       	push   $0xf0101dc4
f01006b7:	e8 d6 03 00 00       	call   f0100a92 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006bc:	83 c4 0c             	add    $0xc,%esp
f01006bf:	68 00 23 11 00       	push   $0x112300
f01006c4:	68 00 23 11 f0       	push   $0xf0112300
f01006c9:	68 e8 1d 10 f0       	push   $0xf0101de8
f01006ce:	e8 bf 03 00 00       	call   f0100a92 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006d3:	83 c4 0c             	add    $0xc,%esp
f01006d6:	68 50 29 11 00       	push   $0x112950
f01006db:	68 50 29 11 f0       	push   $0xf0112950
f01006e0:	68 0c 1e 10 f0       	push   $0xf0101e0c
f01006e5:	e8 a8 03 00 00       	call   f0100a92 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006ea:	b8 4f 2d 11 f0       	mov    $0xf0112d4f,%eax
f01006ef:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006f4:	83 c4 08             	add    $0x8,%esp
f01006f7:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01006fc:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100702:	85 c0                	test   %eax,%eax
f0100704:	0f 48 c2             	cmovs  %edx,%eax
f0100707:	c1 f8 0a             	sar    $0xa,%eax
f010070a:	50                   	push   %eax
f010070b:	68 30 1e 10 f0       	push   $0xf0101e30
f0100710:	e8 7d 03 00 00       	call   f0100a92 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100715:	b8 00 00 00 00       	mov    $0x0,%eax
f010071a:	c9                   	leave  
f010071b:	c3                   	ret    

f010071c <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010071c:	55                   	push   %ebp
f010071d:	89 e5                	mov    %esp,%ebp
f010071f:	56                   	push   %esi
f0100720:	53                   	push   %ebx
f0100721:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100724:	89 eb                	mov    %ebp,%ebx
	
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
f0100726:	68 e6 1c 10 f0       	push   $0xf0101ce6
f010072b:	e8 62 03 00 00       	call   f0100a92 <cprintf>
	
	while (ebp) {
f0100730:	83 c4 10             	add    $0x10,%esp
                  *(ebp+3),
                  *(ebp+4),
                  *(ebp+5),
                  *(ebp+6));
                  
	     debuginfo_eip((*(ebp+1)),&info);
f0100733:	8d 75 e0             	lea    -0x20(%ebp),%esi
	
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
	
	while (ebp) {
f0100736:	eb 4e                	jmp    f0100786 <mon_backtrace+0x6a>
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",ebp,*(ebp+1),
f0100738:	ff 73 18             	pushl  0x18(%ebx)
f010073b:	ff 73 14             	pushl  0x14(%ebx)
f010073e:	ff 73 10             	pushl  0x10(%ebx)
f0100741:	ff 73 0c             	pushl  0xc(%ebx)
f0100744:	ff 73 08             	pushl  0x8(%ebx)
f0100747:	ff 73 04             	pushl  0x4(%ebx)
f010074a:	53                   	push   %ebx
f010074b:	68 5c 1e 10 f0       	push   $0xf0101e5c
f0100750:	e8 3d 03 00 00       	call   f0100a92 <cprintf>
                  *(ebp+3),
                  *(ebp+4),
                  *(ebp+5),
                  *(ebp+6));
                  
	     debuginfo_eip((*(ebp+1)),&info);
f0100755:	83 c4 18             	add    $0x18,%esp
f0100758:	56                   	push   %esi
f0100759:	ff 73 04             	pushl  0x4(%ebx)
f010075c:	e8 3b 04 00 00       	call   f0100b9c <debuginfo_eip>
	     cprintf("         %s:%d: %.*s+%d\n", 
f0100761:	83 c4 08             	add    $0x8,%esp
f0100764:	8b 43 04             	mov    0x4(%ebx),%eax
f0100767:	2b 45 f0             	sub    -0x10(%ebp),%eax
f010076a:	50                   	push   %eax
f010076b:	ff 75 e8             	pushl  -0x18(%ebp)
f010076e:	ff 75 ec             	pushl  -0x14(%ebp)
f0100771:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100774:	ff 75 e0             	pushl  -0x20(%ebp)
f0100777:	68 f8 1c 10 f0       	push   $0xf0101cf8
f010077c:	e8 11 03 00 00       	call   f0100a92 <cprintf>
	     info.eip_file, info.eip_line,
	     info.eip_fn_namelen, info.eip_fn_name, (*(ebp+1)) - info.eip_fn_addr);

	     ebp = (uint32_t *)*(ebp);
f0100781:	8b 1b                	mov    (%ebx),%ebx
f0100783:	83 c4 20             	add    $0x20,%esp
	
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
	
	while (ebp) {
f0100786:	85 db                	test   %ebx,%ebx
f0100788:	75 ae                	jne    f0100738 <mon_backtrace+0x1c>
	     ebp = (uint32_t *)*(ebp);
    }

	
	return 0;
}
f010078a:	b8 00 00 00 00       	mov    $0x0,%eax
f010078f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100792:	5b                   	pop    %ebx
f0100793:	5e                   	pop    %esi
f0100794:	5d                   	pop    %ebp
f0100795:	c3                   	ret    

f0100796 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100796:	55                   	push   %ebp
f0100797:	89 e5                	mov    %esp,%ebp
f0100799:	57                   	push   %edi
f010079a:	56                   	push   %esi
f010079b:	53                   	push   %ebx
f010079c:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010079f:	68 90 1e 10 f0       	push   $0xf0101e90
f01007a4:	e8 e9 02 00 00       	call   f0100a92 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007a9:	c7 04 24 b4 1e 10 f0 	movl   $0xf0101eb4,(%esp)
f01007b0:	e8 dd 02 00 00       	call   f0100a92 <cprintf>
f01007b5:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01007b8:	83 ec 0c             	sub    $0xc,%esp
f01007bb:	68 11 1d 10 f0       	push   $0xf0101d11
f01007c0:	e8 1f 0b 00 00       	call   f01012e4 <readline>
f01007c5:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007c7:	83 c4 10             	add    $0x10,%esp
f01007ca:	85 c0                	test   %eax,%eax
f01007cc:	74 ea                	je     f01007b8 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007ce:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007d5:	be 00 00 00 00       	mov    $0x0,%esi
f01007da:	eb 0a                	jmp    f01007e6 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007dc:	c6 03 00             	movb   $0x0,(%ebx)
f01007df:	89 f7                	mov    %esi,%edi
f01007e1:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01007e4:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007e6:	0f b6 03             	movzbl (%ebx),%eax
f01007e9:	84 c0                	test   %al,%al
f01007eb:	74 63                	je     f0100850 <monitor+0xba>
f01007ed:	83 ec 08             	sub    $0x8,%esp
f01007f0:	0f be c0             	movsbl %al,%eax
f01007f3:	50                   	push   %eax
f01007f4:	68 15 1d 10 f0       	push   $0xf0101d15
f01007f9:	e8 00 0d 00 00       	call   f01014fe <strchr>
f01007fe:	83 c4 10             	add    $0x10,%esp
f0100801:	85 c0                	test   %eax,%eax
f0100803:	75 d7                	jne    f01007dc <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100805:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100808:	74 46                	je     f0100850 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010080a:	83 fe 0f             	cmp    $0xf,%esi
f010080d:	75 14                	jne    f0100823 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010080f:	83 ec 08             	sub    $0x8,%esp
f0100812:	6a 10                	push   $0x10
f0100814:	68 1a 1d 10 f0       	push   $0xf0101d1a
f0100819:	e8 74 02 00 00       	call   f0100a92 <cprintf>
f010081e:	83 c4 10             	add    $0x10,%esp
f0100821:	eb 95                	jmp    f01007b8 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100823:	8d 7e 01             	lea    0x1(%esi),%edi
f0100826:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010082a:	eb 03                	jmp    f010082f <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010082c:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010082f:	0f b6 03             	movzbl (%ebx),%eax
f0100832:	84 c0                	test   %al,%al
f0100834:	74 ae                	je     f01007e4 <monitor+0x4e>
f0100836:	83 ec 08             	sub    $0x8,%esp
f0100839:	0f be c0             	movsbl %al,%eax
f010083c:	50                   	push   %eax
f010083d:	68 15 1d 10 f0       	push   $0xf0101d15
f0100842:	e8 b7 0c 00 00       	call   f01014fe <strchr>
f0100847:	83 c4 10             	add    $0x10,%esp
f010084a:	85 c0                	test   %eax,%eax
f010084c:	74 de                	je     f010082c <monitor+0x96>
f010084e:	eb 94                	jmp    f01007e4 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f0100850:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100857:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100858:	85 f6                	test   %esi,%esi
f010085a:	0f 84 58 ff ff ff    	je     f01007b8 <monitor+0x22>
f0100860:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100865:	83 ec 08             	sub    $0x8,%esp
f0100868:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010086b:	ff 34 85 e0 1e 10 f0 	pushl  -0xfefe120(,%eax,4)
f0100872:	ff 75 a8             	pushl  -0x58(%ebp)
f0100875:	e8 26 0c 00 00       	call   f01014a0 <strcmp>
f010087a:	83 c4 10             	add    $0x10,%esp
f010087d:	85 c0                	test   %eax,%eax
f010087f:	75 21                	jne    f01008a2 <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f0100881:	83 ec 04             	sub    $0x4,%esp
f0100884:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100887:	ff 75 08             	pushl  0x8(%ebp)
f010088a:	8d 55 a8             	lea    -0x58(%ebp),%edx
f010088d:	52                   	push   %edx
f010088e:	56                   	push   %esi
f010088f:	ff 14 85 e8 1e 10 f0 	call   *-0xfefe118(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100896:	83 c4 10             	add    $0x10,%esp
f0100899:	85 c0                	test   %eax,%eax
f010089b:	78 25                	js     f01008c2 <monitor+0x12c>
f010089d:	e9 16 ff ff ff       	jmp    f01007b8 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008a2:	83 c3 01             	add    $0x1,%ebx
f01008a5:	83 fb 03             	cmp    $0x3,%ebx
f01008a8:	75 bb                	jne    f0100865 <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008aa:	83 ec 08             	sub    $0x8,%esp
f01008ad:	ff 75 a8             	pushl  -0x58(%ebp)
f01008b0:	68 37 1d 10 f0       	push   $0xf0101d37
f01008b5:	e8 d8 01 00 00       	call   f0100a92 <cprintf>
f01008ba:	83 c4 10             	add    $0x10,%esp
f01008bd:	e9 f6 fe ff ff       	jmp    f01007b8 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008c5:	5b                   	pop    %ebx
f01008c6:	5e                   	pop    %esi
f01008c7:	5f                   	pop    %edi
f01008c8:	5d                   	pop    %ebp
f01008c9:	c3                   	ret    

f01008ca <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01008ca:	55                   	push   %ebp
f01008cb:	89 e5                	mov    %esp,%ebp
f01008cd:	53                   	push   %ebx
f01008ce:	83 ec 10             	sub    $0x10,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01008d1:	6a 15                	push   $0x15
f01008d3:	e8 53 01 00 00       	call   f0100a2b <mc146818_read>
f01008d8:	89 c3                	mov    %eax,%ebx
f01008da:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01008e1:	e8 45 01 00 00       	call   f0100a2b <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01008e6:	c1 e0 08             	shl    $0x8,%eax
f01008e9:	09 d8                	or     %ebx,%eax
f01008eb:	c1 e0 0a             	shl    $0xa,%eax
f01008ee:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01008f4:	85 c0                	test   %eax,%eax
f01008f6:	0f 48 c2             	cmovs  %edx,%eax
f01008f9:	c1 f8 0c             	sar    $0xc,%eax
f01008fc:	a3 3c 25 11 f0       	mov    %eax,0xf011253c
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100901:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0100908:	e8 1e 01 00 00       	call   f0100a2b <mc146818_read>
f010090d:	89 c3                	mov    %eax,%ebx
f010090f:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0100916:	e8 10 01 00 00       	call   f0100a2b <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010091b:	c1 e0 08             	shl    $0x8,%eax
f010091e:	09 d8                	or     %ebx,%eax
f0100920:	c1 e0 0a             	shl    $0xa,%eax
f0100923:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100929:	83 c4 10             	add    $0x10,%esp
f010092c:	85 c0                	test   %eax,%eax
f010092e:	0f 48 c2             	cmovs  %edx,%eax
f0100931:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100934:	85 c0                	test   %eax,%eax
f0100936:	74 0e                	je     f0100946 <mem_init+0x7c>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100938:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010093e:	89 15 44 29 11 f0    	mov    %edx,0xf0112944
f0100944:	eb 0c                	jmp    f0100952 <mem_init+0x88>
	else
		npages = npages_basemem;
f0100946:	8b 15 3c 25 11 f0    	mov    0xf011253c,%edx
f010094c:	89 15 44 29 11 f0    	mov    %edx,0xf0112944

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100952:	c1 e0 0c             	shl    $0xc,%eax
f0100955:	c1 e8 0a             	shr    $0xa,%eax
f0100958:	50                   	push   %eax
f0100959:	a1 3c 25 11 f0       	mov    0xf011253c,%eax
f010095e:	c1 e0 0c             	shl    $0xc,%eax
f0100961:	c1 e8 0a             	shr    $0xa,%eax
f0100964:	50                   	push   %eax
f0100965:	a1 44 29 11 f0       	mov    0xf0112944,%eax
f010096a:	c1 e0 0c             	shl    $0xc,%eax
f010096d:	c1 e8 0a             	shr    $0xa,%eax
f0100970:	50                   	push   %eax
f0100971:	68 04 1f 10 f0       	push   $0xf0101f04
f0100976:	e8 17 01 00 00       	call   f0100a92 <cprintf>

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	// Remove this line when you're ready to test this function.
	panic("mem_init: This function is not finished\n");
f010097b:	83 c4 0c             	add    $0xc,%esp
f010097e:	68 40 1f 10 f0       	push   $0xf0101f40
f0100983:	6a 7c                	push   $0x7c
f0100985:	68 6c 1f 10 f0       	push   $0xf0101f6c
f010098a:	e8 fc f6 ff ff       	call   f010008b <_panic>

f010098f <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f010098f:	55                   	push   %ebp
f0100990:	89 e5                	mov    %esp,%ebp
f0100992:	53                   	push   %ebx
f0100993:	8b 1d 38 25 11 f0    	mov    0xf0112538,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100999:	ba 00 00 00 00       	mov    $0x0,%edx
f010099e:	b8 00 00 00 00       	mov    $0x0,%eax
f01009a3:	eb 27                	jmp    f01009cc <page_init+0x3d>
f01009a5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f01009ac:	89 d1                	mov    %edx,%ecx
f01009ae:	03 0d 4c 29 11 f0    	add    0xf011294c,%ecx
f01009b4:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01009ba:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01009bc:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f01009bf:	89 d3                	mov    %edx,%ebx
f01009c1:	03 1d 4c 29 11 f0    	add    0xf011294c,%ebx
f01009c7:	ba 01 00 00 00       	mov    $0x1,%edx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01009cc:	3b 05 44 29 11 f0    	cmp    0xf0112944,%eax
f01009d2:	72 d1                	jb     f01009a5 <page_init+0x16>
f01009d4:	84 d2                	test   %dl,%dl
f01009d6:	74 06                	je     f01009de <page_init+0x4f>
f01009d8:	89 1d 38 25 11 f0    	mov    %ebx,0xf0112538
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f01009de:	5b                   	pop    %ebx
f01009df:	5d                   	pop    %ebp
f01009e0:	c3                   	ret    

f01009e1 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01009e1:	55                   	push   %ebp
f01009e2:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f01009e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01009e9:	5d                   	pop    %ebp
f01009ea:	c3                   	ret    

f01009eb <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01009eb:	55                   	push   %ebp
f01009ec:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
}
f01009ee:	5d                   	pop    %ebp
f01009ef:	c3                   	ret    

f01009f0 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01009f0:	55                   	push   %ebp
f01009f1:	89 e5                	mov    %esp,%ebp
f01009f3:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01009f6:	66 83 68 04 01       	subw   $0x1,0x4(%eax)
		page_free(pp);
}
f01009fb:	5d                   	pop    %ebp
f01009fc:	c3                   	ret    

f01009fd <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01009fd:	55                   	push   %ebp
f01009fe:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100a00:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a05:	5d                   	pop    %ebp
f0100a06:	c3                   	ret    

f0100a07 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100a07:	55                   	push   %ebp
f0100a08:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100a0a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a0f:	5d                   	pop    %ebp
f0100a10:	c3                   	ret    

f0100a11 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100a11:	55                   	push   %ebp
f0100a12:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100a14:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a19:	5d                   	pop    %ebp
f0100a1a:	c3                   	ret    

f0100a1b <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100a1b:	55                   	push   %ebp
f0100a1c:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100a1e:	5d                   	pop    %ebp
f0100a1f:	c3                   	ret    

f0100a20 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100a20:	55                   	push   %ebp
f0100a21:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100a23:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a26:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100a29:	5d                   	pop    %ebp
f0100a2a:	c3                   	ret    

f0100a2b <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100a2b:	55                   	push   %ebp
f0100a2c:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100a2e:	ba 70 00 00 00       	mov    $0x70,%edx
f0100a33:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a36:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100a37:	ba 71 00 00 00       	mov    $0x71,%edx
f0100a3c:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0100a3d:	0f b6 c0             	movzbl %al,%eax
}
f0100a40:	5d                   	pop    %ebp
f0100a41:	c3                   	ret    

f0100a42 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100a42:	55                   	push   %ebp
f0100a43:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100a45:	ba 70 00 00 00       	mov    $0x70,%edx
f0100a4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a4d:	ee                   	out    %al,(%dx)
f0100a4e:	ba 71 00 00 00       	mov    $0x71,%edx
f0100a53:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a56:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100a57:	5d                   	pop    %ebp
f0100a58:	c3                   	ret    

f0100a59 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100a59:	55                   	push   %ebp
f0100a5a:	89 e5                	mov    %esp,%ebp
f0100a5c:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100a5f:	ff 75 08             	pushl  0x8(%ebp)
f0100a62:	e8 8b fb ff ff       	call   f01005f2 <cputchar>
	*cnt++;
}
f0100a67:	83 c4 10             	add    $0x10,%esp
f0100a6a:	c9                   	leave  
f0100a6b:	c3                   	ret    

f0100a6c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100a6c:	55                   	push   %ebp
f0100a6d:	89 e5                	mov    %esp,%ebp
f0100a6f:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100a72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100a79:	ff 75 0c             	pushl  0xc(%ebp)
f0100a7c:	ff 75 08             	pushl  0x8(%ebp)
f0100a7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a82:	50                   	push   %eax
f0100a83:	68 59 0a 10 f0       	push   $0xf0100a59
f0100a88:	e8 42 04 00 00       	call   f0100ecf <vprintfmt>
	return cnt;
}
f0100a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a90:	c9                   	leave  
f0100a91:	c3                   	ret    

f0100a92 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100a92:	55                   	push   %ebp
f0100a93:	89 e5                	mov    %esp,%ebp
f0100a95:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100a98:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100a9b:	50                   	push   %eax
f0100a9c:	ff 75 08             	pushl  0x8(%ebp)
f0100a9f:	e8 c8 ff ff ff       	call   f0100a6c <vcprintf>
	va_end(ap);

	return cnt;
}
f0100aa4:	c9                   	leave  
f0100aa5:	c3                   	ret    

f0100aa6 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100aa6:	55                   	push   %ebp
f0100aa7:	89 e5                	mov    %esp,%ebp
f0100aa9:	57                   	push   %edi
f0100aaa:	56                   	push   %esi
f0100aab:	53                   	push   %ebx
f0100aac:	83 ec 14             	sub    $0x14,%esp
f0100aaf:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100ab2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100ab5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100ab8:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100abb:	8b 1a                	mov    (%edx),%ebx
f0100abd:	8b 01                	mov    (%ecx),%eax
f0100abf:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100ac2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100ac9:	eb 7f                	jmp    f0100b4a <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0100acb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100ace:	01 d8                	add    %ebx,%eax
f0100ad0:	89 c6                	mov    %eax,%esi
f0100ad2:	c1 ee 1f             	shr    $0x1f,%esi
f0100ad5:	01 c6                	add    %eax,%esi
f0100ad7:	d1 fe                	sar    %esi
f0100ad9:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100adc:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100adf:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100ae2:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100ae4:	eb 03                	jmp    f0100ae9 <stab_binsearch+0x43>
			m--;
f0100ae6:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100ae9:	39 c3                	cmp    %eax,%ebx
f0100aeb:	7f 0d                	jg     f0100afa <stab_binsearch+0x54>
f0100aed:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100af1:	83 ea 0c             	sub    $0xc,%edx
f0100af4:	39 f9                	cmp    %edi,%ecx
f0100af6:	75 ee                	jne    f0100ae6 <stab_binsearch+0x40>
f0100af8:	eb 05                	jmp    f0100aff <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100afa:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100afd:	eb 4b                	jmp    f0100b4a <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100aff:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b02:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b05:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b09:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100b0c:	76 11                	jbe    f0100b1f <stab_binsearch+0x79>
			*region_left = m;
f0100b0e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100b11:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100b13:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100b16:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b1d:	eb 2b                	jmp    f0100b4a <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100b1f:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100b22:	73 14                	jae    f0100b38 <stab_binsearch+0x92>
			*region_right = m - 1;
f0100b24:	83 e8 01             	sub    $0x1,%eax
f0100b27:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b2a:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100b2d:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100b2f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b36:	eb 12                	jmp    f0100b4a <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100b38:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b3b:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100b3d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100b41:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100b43:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100b4a:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100b4d:	0f 8e 78 ff ff ff    	jle    f0100acb <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100b53:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100b57:	75 0f                	jne    f0100b68 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100b59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b5c:	8b 00                	mov    (%eax),%eax
f0100b5e:	83 e8 01             	sub    $0x1,%eax
f0100b61:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100b64:	89 06                	mov    %eax,(%esi)
f0100b66:	eb 2c                	jmp    f0100b94 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b68:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b6b:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100b6d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b70:	8b 0e                	mov    (%esi),%ecx
f0100b72:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b75:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100b78:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b7b:	eb 03                	jmp    f0100b80 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100b7d:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b80:	39 c8                	cmp    %ecx,%eax
f0100b82:	7e 0b                	jle    f0100b8f <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100b84:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100b88:	83 ea 0c             	sub    $0xc,%edx
f0100b8b:	39 df                	cmp    %ebx,%edi
f0100b8d:	75 ee                	jne    f0100b7d <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100b8f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b92:	89 06                	mov    %eax,(%esi)
	}
}
f0100b94:	83 c4 14             	add    $0x14,%esp
f0100b97:	5b                   	pop    %ebx
f0100b98:	5e                   	pop    %esi
f0100b99:	5f                   	pop    %edi
f0100b9a:	5d                   	pop    %ebp
f0100b9b:	c3                   	ret    

f0100b9c <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100b9c:	55                   	push   %ebp
f0100b9d:	89 e5                	mov    %esp,%ebp
f0100b9f:	57                   	push   %edi
f0100ba0:	56                   	push   %esi
f0100ba1:	53                   	push   %ebx
f0100ba2:	83 ec 3c             	sub    $0x3c,%esp
f0100ba5:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ba8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100bab:	c7 03 78 1f 10 f0    	movl   $0xf0101f78,(%ebx)
	info->eip_line = 0;
f0100bb1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100bb8:	c7 43 08 78 1f 10 f0 	movl   $0xf0101f78,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100bbf:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100bc6:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100bc9:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100bd0:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100bd6:	76 11                	jbe    f0100be9 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100bd8:	b8 cd 7d 10 f0       	mov    $0xf0107dcd,%eax
f0100bdd:	3d 09 62 10 f0       	cmp    $0xf0106209,%eax
f0100be2:	77 19                	ja     f0100bfd <debuginfo_eip+0x61>
f0100be4:	e9 a1 01 00 00       	jmp    f0100d8a <debuginfo_eip+0x1ee>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100be9:	83 ec 04             	sub    $0x4,%esp
f0100bec:	68 82 1f 10 f0       	push   $0xf0101f82
f0100bf1:	6a 7f                	push   $0x7f
f0100bf3:	68 8f 1f 10 f0       	push   $0xf0101f8f
f0100bf8:	e8 8e f4 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100bfd:	80 3d cc 7d 10 f0 00 	cmpb   $0x0,0xf0107dcc
f0100c04:	0f 85 87 01 00 00    	jne    f0100d91 <debuginfo_eip+0x1f5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c0a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c11:	b8 08 62 10 f0       	mov    $0xf0106208,%eax
f0100c16:	2d d0 21 10 f0       	sub    $0xf01021d0,%eax
f0100c1b:	c1 f8 02             	sar    $0x2,%eax
f0100c1e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100c24:	83 e8 01             	sub    $0x1,%eax
f0100c27:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100c2a:	83 ec 08             	sub    $0x8,%esp
f0100c2d:	56                   	push   %esi
f0100c2e:	6a 64                	push   $0x64
f0100c30:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c33:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c36:	b8 d0 21 10 f0       	mov    $0xf01021d0,%eax
f0100c3b:	e8 66 fe ff ff       	call   f0100aa6 <stab_binsearch>
	if (lfile == 0)
f0100c40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c43:	83 c4 10             	add    $0x10,%esp
f0100c46:	85 c0                	test   %eax,%eax
f0100c48:	0f 84 4a 01 00 00    	je     f0100d98 <debuginfo_eip+0x1fc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c4e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100c51:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c54:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c57:	83 ec 08             	sub    $0x8,%esp
f0100c5a:	56                   	push   %esi
f0100c5b:	6a 24                	push   $0x24
f0100c5d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c60:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c63:	b8 d0 21 10 f0       	mov    $0xf01021d0,%eax
f0100c68:	e8 39 fe ff ff       	call   f0100aa6 <stab_binsearch>

	if (lfun <= rfun) {
f0100c6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c70:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100c73:	83 c4 10             	add    $0x10,%esp
f0100c76:	39 d0                	cmp    %edx,%eax
f0100c78:	7f 40                	jg     f0100cba <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100c7a:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100c7d:	c1 e1 02             	shl    $0x2,%ecx
f0100c80:	8d b9 d0 21 10 f0    	lea    -0xfefde30(%ecx),%edi
f0100c86:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100c89:	8b b9 d0 21 10 f0    	mov    -0xfefde30(%ecx),%edi
f0100c8f:	b9 cd 7d 10 f0       	mov    $0xf0107dcd,%ecx
f0100c94:	81 e9 09 62 10 f0    	sub    $0xf0106209,%ecx
f0100c9a:	39 cf                	cmp    %ecx,%edi
f0100c9c:	73 09                	jae    f0100ca7 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100c9e:	81 c7 09 62 10 f0    	add    $0xf0106209,%edi
f0100ca4:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100ca7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100caa:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100cad:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100cb0:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100cb2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100cb5:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100cb8:	eb 0f                	jmp    f0100cc9 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100cba:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100cbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cc0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100cc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cc6:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100cc9:	83 ec 08             	sub    $0x8,%esp
f0100ccc:	6a 3a                	push   $0x3a
f0100cce:	ff 73 08             	pushl  0x8(%ebx)
f0100cd1:	e8 49 08 00 00       	call   f010151f <strfind>
f0100cd6:	2b 43 08             	sub    0x8(%ebx),%eax
f0100cd9:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100cdc:	83 c4 08             	add    $0x8,%esp
f0100cdf:	56                   	push   %esi
f0100ce0:	6a 44                	push   $0x44
f0100ce2:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100ce5:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100ce8:	b8 d0 21 10 f0       	mov    $0xf01021d0,%eax
f0100ced:	e8 b4 fd ff ff       	call   f0100aa6 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0100cf2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100cf5:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100cf8:	8d 04 85 d0 21 10 f0 	lea    -0xfefde30(,%eax,4),%eax
f0100cff:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0100d03:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d06:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100d09:	83 c4 10             	add    $0x10,%esp
f0100d0c:	eb 06                	jmp    f0100d14 <debuginfo_eip+0x178>
f0100d0e:	83 ea 01             	sub    $0x1,%edx
f0100d11:	83 e8 0c             	sub    $0xc,%eax
f0100d14:	39 d6                	cmp    %edx,%esi
f0100d16:	7f 34                	jg     f0100d4c <debuginfo_eip+0x1b0>
	       && stabs[lline].n_type != N_SOL
f0100d18:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100d1c:	80 f9 84             	cmp    $0x84,%cl
f0100d1f:	74 0b                	je     f0100d2c <debuginfo_eip+0x190>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100d21:	80 f9 64             	cmp    $0x64,%cl
f0100d24:	75 e8                	jne    f0100d0e <debuginfo_eip+0x172>
f0100d26:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100d2a:	74 e2                	je     f0100d0e <debuginfo_eip+0x172>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100d2c:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100d2f:	8b 14 85 d0 21 10 f0 	mov    -0xfefde30(,%eax,4),%edx
f0100d36:	b8 cd 7d 10 f0       	mov    $0xf0107dcd,%eax
f0100d3b:	2d 09 62 10 f0       	sub    $0xf0106209,%eax
f0100d40:	39 c2                	cmp    %eax,%edx
f0100d42:	73 08                	jae    f0100d4c <debuginfo_eip+0x1b0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100d44:	81 c2 09 62 10 f0    	add    $0xf0106209,%edx
f0100d4a:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100d4c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d4f:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d52:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100d57:	39 f2                	cmp    %esi,%edx
f0100d59:	7d 49                	jge    f0100da4 <debuginfo_eip+0x208>
		for (lline = lfun + 1;
f0100d5b:	83 c2 01             	add    $0x1,%edx
f0100d5e:	89 d0                	mov    %edx,%eax
f0100d60:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100d63:	8d 14 95 d0 21 10 f0 	lea    -0xfefde30(,%edx,4),%edx
f0100d6a:	eb 04                	jmp    f0100d70 <debuginfo_eip+0x1d4>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100d6c:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100d70:	39 c6                	cmp    %eax,%esi
f0100d72:	7e 2b                	jle    f0100d9f <debuginfo_eip+0x203>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d74:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100d78:	83 c0 01             	add    $0x1,%eax
f0100d7b:	83 c2 0c             	add    $0xc,%edx
f0100d7e:	80 f9 a0             	cmp    $0xa0,%cl
f0100d81:	74 e9                	je     f0100d6c <debuginfo_eip+0x1d0>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d83:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d88:	eb 1a                	jmp    f0100da4 <debuginfo_eip+0x208>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100d8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d8f:	eb 13                	jmp    f0100da4 <debuginfo_eip+0x208>
f0100d91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d96:	eb 0c                	jmp    f0100da4 <debuginfo_eip+0x208>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100d98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d9d:	eb 05                	jmp    f0100da4 <debuginfo_eip+0x208>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100da4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100da7:	5b                   	pop    %ebx
f0100da8:	5e                   	pop    %esi
f0100da9:	5f                   	pop    %edi
f0100daa:	5d                   	pop    %ebp
f0100dab:	c3                   	ret    

f0100dac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100dac:	55                   	push   %ebp
f0100dad:	89 e5                	mov    %esp,%ebp
f0100daf:	57                   	push   %edi
f0100db0:	56                   	push   %esi
f0100db1:	53                   	push   %ebx
f0100db2:	83 ec 1c             	sub    $0x1c,%esp
f0100db5:	89 c7                	mov    %eax,%edi
f0100db7:	89 d6                	mov    %edx,%esi
f0100db9:	8b 45 08             	mov    0x8(%ebp),%eax
f0100dbc:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100dbf:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100dc2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100dc5:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100dc8:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100dcd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100dd0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100dd3:	39 d3                	cmp    %edx,%ebx
f0100dd5:	72 05                	jb     f0100ddc <printnum+0x30>
f0100dd7:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100dda:	77 45                	ja     f0100e21 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ddc:	83 ec 0c             	sub    $0xc,%esp
f0100ddf:	ff 75 18             	pushl  0x18(%ebp)
f0100de2:	8b 45 14             	mov    0x14(%ebp),%eax
f0100de5:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100de8:	53                   	push   %ebx
f0100de9:	ff 75 10             	pushl  0x10(%ebp)
f0100dec:	83 ec 08             	sub    $0x8,%esp
f0100def:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100df2:	ff 75 e0             	pushl  -0x20(%ebp)
f0100df5:	ff 75 dc             	pushl  -0x24(%ebp)
f0100df8:	ff 75 d8             	pushl  -0x28(%ebp)
f0100dfb:	e8 40 09 00 00       	call   f0101740 <__udivdi3>
f0100e00:	83 c4 18             	add    $0x18,%esp
f0100e03:	52                   	push   %edx
f0100e04:	50                   	push   %eax
f0100e05:	89 f2                	mov    %esi,%edx
f0100e07:	89 f8                	mov    %edi,%eax
f0100e09:	e8 9e ff ff ff       	call   f0100dac <printnum>
f0100e0e:	83 c4 20             	add    $0x20,%esp
f0100e11:	eb 18                	jmp    f0100e2b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100e13:	83 ec 08             	sub    $0x8,%esp
f0100e16:	56                   	push   %esi
f0100e17:	ff 75 18             	pushl  0x18(%ebp)
f0100e1a:	ff d7                	call   *%edi
f0100e1c:	83 c4 10             	add    $0x10,%esp
f0100e1f:	eb 03                	jmp    f0100e24 <printnum+0x78>
f0100e21:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100e24:	83 eb 01             	sub    $0x1,%ebx
f0100e27:	85 db                	test   %ebx,%ebx
f0100e29:	7f e8                	jg     f0100e13 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100e2b:	83 ec 08             	sub    $0x8,%esp
f0100e2e:	56                   	push   %esi
f0100e2f:	83 ec 04             	sub    $0x4,%esp
f0100e32:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100e35:	ff 75 e0             	pushl  -0x20(%ebp)
f0100e38:	ff 75 dc             	pushl  -0x24(%ebp)
f0100e3b:	ff 75 d8             	pushl  -0x28(%ebp)
f0100e3e:	e8 2d 0a 00 00       	call   f0101870 <__umoddi3>
f0100e43:	83 c4 14             	add    $0x14,%esp
f0100e46:	0f be 80 9d 1f 10 f0 	movsbl -0xfefe063(%eax),%eax
f0100e4d:	50                   	push   %eax
f0100e4e:	ff d7                	call   *%edi
}
f0100e50:	83 c4 10             	add    $0x10,%esp
f0100e53:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e56:	5b                   	pop    %ebx
f0100e57:	5e                   	pop    %esi
f0100e58:	5f                   	pop    %edi
f0100e59:	5d                   	pop    %ebp
f0100e5a:	c3                   	ret    

f0100e5b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100e5b:	55                   	push   %ebp
f0100e5c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100e5e:	83 fa 01             	cmp    $0x1,%edx
f0100e61:	7e 0e                	jle    f0100e71 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100e63:	8b 10                	mov    (%eax),%edx
f0100e65:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100e68:	89 08                	mov    %ecx,(%eax)
f0100e6a:	8b 02                	mov    (%edx),%eax
f0100e6c:	8b 52 04             	mov    0x4(%edx),%edx
f0100e6f:	eb 22                	jmp    f0100e93 <getuint+0x38>
	else if (lflag)
f0100e71:	85 d2                	test   %edx,%edx
f0100e73:	74 10                	je     f0100e85 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100e75:	8b 10                	mov    (%eax),%edx
f0100e77:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100e7a:	89 08                	mov    %ecx,(%eax)
f0100e7c:	8b 02                	mov    (%edx),%eax
f0100e7e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e83:	eb 0e                	jmp    f0100e93 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100e85:	8b 10                	mov    (%eax),%edx
f0100e87:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100e8a:	89 08                	mov    %ecx,(%eax)
f0100e8c:	8b 02                	mov    (%edx),%eax
f0100e8e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100e93:	5d                   	pop    %ebp
f0100e94:	c3                   	ret    

f0100e95 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100e95:	55                   	push   %ebp
f0100e96:	89 e5                	mov    %esp,%ebp
f0100e98:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100e9b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100e9f:	8b 10                	mov    (%eax),%edx
f0100ea1:	3b 50 04             	cmp    0x4(%eax),%edx
f0100ea4:	73 0a                	jae    f0100eb0 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100ea6:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100ea9:	89 08                	mov    %ecx,(%eax)
f0100eab:	8b 45 08             	mov    0x8(%ebp),%eax
f0100eae:	88 02                	mov    %al,(%edx)
}
f0100eb0:	5d                   	pop    %ebp
f0100eb1:	c3                   	ret    

f0100eb2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100eb2:	55                   	push   %ebp
f0100eb3:	89 e5                	mov    %esp,%ebp
f0100eb5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100eb8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100ebb:	50                   	push   %eax
f0100ebc:	ff 75 10             	pushl  0x10(%ebp)
f0100ebf:	ff 75 0c             	pushl  0xc(%ebp)
f0100ec2:	ff 75 08             	pushl  0x8(%ebp)
f0100ec5:	e8 05 00 00 00       	call   f0100ecf <vprintfmt>
	va_end(ap);
}
f0100eca:	83 c4 10             	add    $0x10,%esp
f0100ecd:	c9                   	leave  
f0100ece:	c3                   	ret    

f0100ecf <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100ecf:	55                   	push   %ebp
f0100ed0:	89 e5                	mov    %esp,%ebp
f0100ed2:	57                   	push   %edi
f0100ed3:	56                   	push   %esi
f0100ed4:	53                   	push   %ebx
f0100ed5:	83 ec 2c             	sub    $0x2c,%esp
f0100ed8:	8b 75 08             	mov    0x8(%ebp),%esi
f0100edb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100ede:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100ee1:	eb 12                	jmp    f0100ef5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100ee3:	85 c0                	test   %eax,%eax
f0100ee5:	0f 84 89 03 00 00    	je     f0101274 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100eeb:	83 ec 08             	sub    $0x8,%esp
f0100eee:	53                   	push   %ebx
f0100eef:	50                   	push   %eax
f0100ef0:	ff d6                	call   *%esi
f0100ef2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100ef5:	83 c7 01             	add    $0x1,%edi
f0100ef8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100efc:	83 f8 25             	cmp    $0x25,%eax
f0100eff:	75 e2                	jne    f0100ee3 <vprintfmt+0x14>
f0100f01:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100f05:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100f0c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100f13:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100f1a:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f1f:	eb 07                	jmp    f0100f28 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f21:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100f24:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f28:	8d 47 01             	lea    0x1(%edi),%eax
f0100f2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100f2e:	0f b6 07             	movzbl (%edi),%eax
f0100f31:	0f b6 c8             	movzbl %al,%ecx
f0100f34:	83 e8 23             	sub    $0x23,%eax
f0100f37:	3c 55                	cmp    $0x55,%al
f0100f39:	0f 87 1a 03 00 00    	ja     f0101259 <vprintfmt+0x38a>
f0100f3f:	0f b6 c0             	movzbl %al,%eax
f0100f42:	ff 24 85 40 20 10 f0 	jmp    *-0xfefdfc0(,%eax,4)
f0100f49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100f4c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100f50:	eb d6                	jmp    f0100f28 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f52:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f55:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f5a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100f5d:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100f60:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100f64:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100f67:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100f6a:	83 fa 09             	cmp    $0x9,%edx
f0100f6d:	77 39                	ja     f0100fa8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100f6f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100f72:	eb e9                	jmp    f0100f5d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100f74:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f77:	8d 48 04             	lea    0x4(%eax),%ecx
f0100f7a:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100f7d:	8b 00                	mov    (%eax),%eax
f0100f7f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f82:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100f85:	eb 27                	jmp    f0100fae <vprintfmt+0xdf>
f0100f87:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f8a:	85 c0                	test   %eax,%eax
f0100f8c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f91:	0f 49 c8             	cmovns %eax,%ecx
f0100f94:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f9a:	eb 8c                	jmp    f0100f28 <vprintfmt+0x59>
f0100f9c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100f9f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100fa6:	eb 80                	jmp    f0100f28 <vprintfmt+0x59>
f0100fa8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100fab:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100fae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100fb2:	0f 89 70 ff ff ff    	jns    f0100f28 <vprintfmt+0x59>
				width = precision, precision = -1;
f0100fb8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100fbb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100fbe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100fc5:	e9 5e ff ff ff       	jmp    f0100f28 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100fca:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fcd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100fd0:	e9 53 ff ff ff       	jmp    f0100f28 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100fd5:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fd8:	8d 50 04             	lea    0x4(%eax),%edx
f0100fdb:	89 55 14             	mov    %edx,0x14(%ebp)
f0100fde:	83 ec 08             	sub    $0x8,%esp
f0100fe1:	53                   	push   %ebx
f0100fe2:	ff 30                	pushl  (%eax)
f0100fe4:	ff d6                	call   *%esi
			break;
f0100fe6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fe9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100fec:	e9 04 ff ff ff       	jmp    f0100ef5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100ff1:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff4:	8d 50 04             	lea    0x4(%eax),%edx
f0100ff7:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ffa:	8b 00                	mov    (%eax),%eax
f0100ffc:	99                   	cltd   
f0100ffd:	31 d0                	xor    %edx,%eax
f0100fff:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101001:	83 f8 07             	cmp    $0x7,%eax
f0101004:	7f 0b                	jg     f0101011 <vprintfmt+0x142>
f0101006:	8b 14 85 a0 21 10 f0 	mov    -0xfefde60(,%eax,4),%edx
f010100d:	85 d2                	test   %edx,%edx
f010100f:	75 18                	jne    f0101029 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0101011:	50                   	push   %eax
f0101012:	68 b5 1f 10 f0       	push   $0xf0101fb5
f0101017:	53                   	push   %ebx
f0101018:	56                   	push   %esi
f0101019:	e8 94 fe ff ff       	call   f0100eb2 <printfmt>
f010101e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101021:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0101024:	e9 cc fe ff ff       	jmp    f0100ef5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0101029:	52                   	push   %edx
f010102a:	68 be 1f 10 f0       	push   $0xf0101fbe
f010102f:	53                   	push   %ebx
f0101030:	56                   	push   %esi
f0101031:	e8 7c fe ff ff       	call   f0100eb2 <printfmt>
f0101036:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101039:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010103c:	e9 b4 fe ff ff       	jmp    f0100ef5 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101041:	8b 45 14             	mov    0x14(%ebp),%eax
f0101044:	8d 50 04             	lea    0x4(%eax),%edx
f0101047:	89 55 14             	mov    %edx,0x14(%ebp)
f010104a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f010104c:	85 ff                	test   %edi,%edi
f010104e:	b8 ae 1f 10 f0       	mov    $0xf0101fae,%eax
f0101053:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0101056:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010105a:	0f 8e 94 00 00 00    	jle    f01010f4 <vprintfmt+0x225>
f0101060:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101064:	0f 84 98 00 00 00    	je     f0101102 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f010106a:	83 ec 08             	sub    $0x8,%esp
f010106d:	ff 75 d0             	pushl  -0x30(%ebp)
f0101070:	57                   	push   %edi
f0101071:	e8 5f 03 00 00       	call   f01013d5 <strnlen>
f0101076:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101079:	29 c1                	sub    %eax,%ecx
f010107b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010107e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0101081:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101085:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101088:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010108b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010108d:	eb 0f                	jmp    f010109e <vprintfmt+0x1cf>
					putch(padc, putdat);
f010108f:	83 ec 08             	sub    $0x8,%esp
f0101092:	53                   	push   %ebx
f0101093:	ff 75 e0             	pushl  -0x20(%ebp)
f0101096:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101098:	83 ef 01             	sub    $0x1,%edi
f010109b:	83 c4 10             	add    $0x10,%esp
f010109e:	85 ff                	test   %edi,%edi
f01010a0:	7f ed                	jg     f010108f <vprintfmt+0x1c0>
f01010a2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01010a5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01010a8:	85 c9                	test   %ecx,%ecx
f01010aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01010af:	0f 49 c1             	cmovns %ecx,%eax
f01010b2:	29 c1                	sub    %eax,%ecx
f01010b4:	89 75 08             	mov    %esi,0x8(%ebp)
f01010b7:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01010ba:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01010bd:	89 cb                	mov    %ecx,%ebx
f01010bf:	eb 4d                	jmp    f010110e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01010c1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01010c5:	74 1b                	je     f01010e2 <vprintfmt+0x213>
f01010c7:	0f be c0             	movsbl %al,%eax
f01010ca:	83 e8 20             	sub    $0x20,%eax
f01010cd:	83 f8 5e             	cmp    $0x5e,%eax
f01010d0:	76 10                	jbe    f01010e2 <vprintfmt+0x213>
					putch('?', putdat);
f01010d2:	83 ec 08             	sub    $0x8,%esp
f01010d5:	ff 75 0c             	pushl  0xc(%ebp)
f01010d8:	6a 3f                	push   $0x3f
f01010da:	ff 55 08             	call   *0x8(%ebp)
f01010dd:	83 c4 10             	add    $0x10,%esp
f01010e0:	eb 0d                	jmp    f01010ef <vprintfmt+0x220>
				else
					putch(ch, putdat);
f01010e2:	83 ec 08             	sub    $0x8,%esp
f01010e5:	ff 75 0c             	pushl  0xc(%ebp)
f01010e8:	52                   	push   %edx
f01010e9:	ff 55 08             	call   *0x8(%ebp)
f01010ec:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01010ef:	83 eb 01             	sub    $0x1,%ebx
f01010f2:	eb 1a                	jmp    f010110e <vprintfmt+0x23f>
f01010f4:	89 75 08             	mov    %esi,0x8(%ebp)
f01010f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01010fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01010fd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101100:	eb 0c                	jmp    f010110e <vprintfmt+0x23f>
f0101102:	89 75 08             	mov    %esi,0x8(%ebp)
f0101105:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101108:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010110b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010110e:	83 c7 01             	add    $0x1,%edi
f0101111:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101115:	0f be d0             	movsbl %al,%edx
f0101118:	85 d2                	test   %edx,%edx
f010111a:	74 23                	je     f010113f <vprintfmt+0x270>
f010111c:	85 f6                	test   %esi,%esi
f010111e:	78 a1                	js     f01010c1 <vprintfmt+0x1f2>
f0101120:	83 ee 01             	sub    $0x1,%esi
f0101123:	79 9c                	jns    f01010c1 <vprintfmt+0x1f2>
f0101125:	89 df                	mov    %ebx,%edi
f0101127:	8b 75 08             	mov    0x8(%ebp),%esi
f010112a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010112d:	eb 18                	jmp    f0101147 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010112f:	83 ec 08             	sub    $0x8,%esp
f0101132:	53                   	push   %ebx
f0101133:	6a 20                	push   $0x20
f0101135:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101137:	83 ef 01             	sub    $0x1,%edi
f010113a:	83 c4 10             	add    $0x10,%esp
f010113d:	eb 08                	jmp    f0101147 <vprintfmt+0x278>
f010113f:	89 df                	mov    %ebx,%edi
f0101141:	8b 75 08             	mov    0x8(%ebp),%esi
f0101144:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101147:	85 ff                	test   %edi,%edi
f0101149:	7f e4                	jg     f010112f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010114b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010114e:	e9 a2 fd ff ff       	jmp    f0100ef5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101153:	83 fa 01             	cmp    $0x1,%edx
f0101156:	7e 16                	jle    f010116e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0101158:	8b 45 14             	mov    0x14(%ebp),%eax
f010115b:	8d 50 08             	lea    0x8(%eax),%edx
f010115e:	89 55 14             	mov    %edx,0x14(%ebp)
f0101161:	8b 50 04             	mov    0x4(%eax),%edx
f0101164:	8b 00                	mov    (%eax),%eax
f0101166:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101169:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010116c:	eb 32                	jmp    f01011a0 <vprintfmt+0x2d1>
	else if (lflag)
f010116e:	85 d2                	test   %edx,%edx
f0101170:	74 18                	je     f010118a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0101172:	8b 45 14             	mov    0x14(%ebp),%eax
f0101175:	8d 50 04             	lea    0x4(%eax),%edx
f0101178:	89 55 14             	mov    %edx,0x14(%ebp)
f010117b:	8b 00                	mov    (%eax),%eax
f010117d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101180:	89 c1                	mov    %eax,%ecx
f0101182:	c1 f9 1f             	sar    $0x1f,%ecx
f0101185:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101188:	eb 16                	jmp    f01011a0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f010118a:	8b 45 14             	mov    0x14(%ebp),%eax
f010118d:	8d 50 04             	lea    0x4(%eax),%edx
f0101190:	89 55 14             	mov    %edx,0x14(%ebp)
f0101193:	8b 00                	mov    (%eax),%eax
f0101195:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101198:	89 c1                	mov    %eax,%ecx
f010119a:	c1 f9 1f             	sar    $0x1f,%ecx
f010119d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01011a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01011a3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01011a6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01011ab:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01011af:	79 74                	jns    f0101225 <vprintfmt+0x356>
				putch('-', putdat);
f01011b1:	83 ec 08             	sub    $0x8,%esp
f01011b4:	53                   	push   %ebx
f01011b5:	6a 2d                	push   $0x2d
f01011b7:	ff d6                	call   *%esi
				num = -(long long) num;
f01011b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01011bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01011bf:	f7 d8                	neg    %eax
f01011c1:	83 d2 00             	adc    $0x0,%edx
f01011c4:	f7 da                	neg    %edx
f01011c6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01011c9:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01011ce:	eb 55                	jmp    f0101225 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01011d0:	8d 45 14             	lea    0x14(%ebp),%eax
f01011d3:	e8 83 fc ff ff       	call   f0100e5b <getuint>
			base = 10;
f01011d8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01011dd:	eb 46                	jmp    f0101225 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f01011df:	8d 45 14             	lea    0x14(%ebp),%eax
f01011e2:	e8 74 fc ff ff       	call   f0100e5b <getuint>
			base = 8;
f01011e7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f01011ec:	eb 37                	jmp    f0101225 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
f01011ee:	83 ec 08             	sub    $0x8,%esp
f01011f1:	53                   	push   %ebx
f01011f2:	6a 30                	push   $0x30
f01011f4:	ff d6                	call   *%esi
			putch('x', putdat);
f01011f6:	83 c4 08             	add    $0x8,%esp
f01011f9:	53                   	push   %ebx
f01011fa:	6a 78                	push   $0x78
f01011fc:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01011fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0101201:	8d 50 04             	lea    0x4(%eax),%edx
f0101204:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101207:	8b 00                	mov    (%eax),%eax
f0101209:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010120e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101211:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0101216:	eb 0d                	jmp    f0101225 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101218:	8d 45 14             	lea    0x14(%ebp),%eax
f010121b:	e8 3b fc ff ff       	call   f0100e5b <getuint>
			base = 16;
f0101220:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101225:	83 ec 0c             	sub    $0xc,%esp
f0101228:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010122c:	57                   	push   %edi
f010122d:	ff 75 e0             	pushl  -0x20(%ebp)
f0101230:	51                   	push   %ecx
f0101231:	52                   	push   %edx
f0101232:	50                   	push   %eax
f0101233:	89 da                	mov    %ebx,%edx
f0101235:	89 f0                	mov    %esi,%eax
f0101237:	e8 70 fb ff ff       	call   f0100dac <printnum>
			break;
f010123c:	83 c4 20             	add    $0x20,%esp
f010123f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101242:	e9 ae fc ff ff       	jmp    f0100ef5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101247:	83 ec 08             	sub    $0x8,%esp
f010124a:	53                   	push   %ebx
f010124b:	51                   	push   %ecx
f010124c:	ff d6                	call   *%esi
			break;
f010124e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101251:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101254:	e9 9c fc ff ff       	jmp    f0100ef5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101259:	83 ec 08             	sub    $0x8,%esp
f010125c:	53                   	push   %ebx
f010125d:	6a 25                	push   $0x25
f010125f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101261:	83 c4 10             	add    $0x10,%esp
f0101264:	eb 03                	jmp    f0101269 <vprintfmt+0x39a>
f0101266:	83 ef 01             	sub    $0x1,%edi
f0101269:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010126d:	75 f7                	jne    f0101266 <vprintfmt+0x397>
f010126f:	e9 81 fc ff ff       	jmp    f0100ef5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0101274:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101277:	5b                   	pop    %ebx
f0101278:	5e                   	pop    %esi
f0101279:	5f                   	pop    %edi
f010127a:	5d                   	pop    %ebp
f010127b:	c3                   	ret    

f010127c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010127c:	55                   	push   %ebp
f010127d:	89 e5                	mov    %esp,%ebp
f010127f:	83 ec 18             	sub    $0x18,%esp
f0101282:	8b 45 08             	mov    0x8(%ebp),%eax
f0101285:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101288:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010128b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010128f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101292:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101299:	85 c0                	test   %eax,%eax
f010129b:	74 26                	je     f01012c3 <vsnprintf+0x47>
f010129d:	85 d2                	test   %edx,%edx
f010129f:	7e 22                	jle    f01012c3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01012a1:	ff 75 14             	pushl  0x14(%ebp)
f01012a4:	ff 75 10             	pushl  0x10(%ebp)
f01012a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01012aa:	50                   	push   %eax
f01012ab:	68 95 0e 10 f0       	push   $0xf0100e95
f01012b0:	e8 1a fc ff ff       	call   f0100ecf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01012b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01012b8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01012bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01012be:	83 c4 10             	add    $0x10,%esp
f01012c1:	eb 05                	jmp    f01012c8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01012c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01012c8:	c9                   	leave  
f01012c9:	c3                   	ret    

f01012ca <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01012ca:	55                   	push   %ebp
f01012cb:	89 e5                	mov    %esp,%ebp
f01012cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01012d0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01012d3:	50                   	push   %eax
f01012d4:	ff 75 10             	pushl  0x10(%ebp)
f01012d7:	ff 75 0c             	pushl  0xc(%ebp)
f01012da:	ff 75 08             	pushl  0x8(%ebp)
f01012dd:	e8 9a ff ff ff       	call   f010127c <vsnprintf>
	va_end(ap);

	return rc;
}
f01012e2:	c9                   	leave  
f01012e3:	c3                   	ret    

f01012e4 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01012e4:	55                   	push   %ebp
f01012e5:	89 e5                	mov    %esp,%ebp
f01012e7:	57                   	push   %edi
f01012e8:	56                   	push   %esi
f01012e9:	53                   	push   %ebx
f01012ea:	83 ec 0c             	sub    $0xc,%esp
f01012ed:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01012f0:	85 c0                	test   %eax,%eax
f01012f2:	74 11                	je     f0101305 <readline+0x21>
		cprintf("%s", prompt);
f01012f4:	83 ec 08             	sub    $0x8,%esp
f01012f7:	50                   	push   %eax
f01012f8:	68 be 1f 10 f0       	push   $0xf0101fbe
f01012fd:	e8 90 f7 ff ff       	call   f0100a92 <cprintf>
f0101302:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101305:	83 ec 0c             	sub    $0xc,%esp
f0101308:	6a 00                	push   $0x0
f010130a:	e8 04 f3 ff ff       	call   f0100613 <iscons>
f010130f:	89 c7                	mov    %eax,%edi
f0101311:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101314:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101319:	e8 e4 f2 ff ff       	call   f0100602 <getchar>
f010131e:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101320:	85 c0                	test   %eax,%eax
f0101322:	79 18                	jns    f010133c <readline+0x58>
			cprintf("read error: %e\n", c);
f0101324:	83 ec 08             	sub    $0x8,%esp
f0101327:	50                   	push   %eax
f0101328:	68 c0 21 10 f0       	push   $0xf01021c0
f010132d:	e8 60 f7 ff ff       	call   f0100a92 <cprintf>
			return NULL;
f0101332:	83 c4 10             	add    $0x10,%esp
f0101335:	b8 00 00 00 00       	mov    $0x0,%eax
f010133a:	eb 79                	jmp    f01013b5 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010133c:	83 f8 08             	cmp    $0x8,%eax
f010133f:	0f 94 c2             	sete   %dl
f0101342:	83 f8 7f             	cmp    $0x7f,%eax
f0101345:	0f 94 c0             	sete   %al
f0101348:	08 c2                	or     %al,%dl
f010134a:	74 1a                	je     f0101366 <readline+0x82>
f010134c:	85 f6                	test   %esi,%esi
f010134e:	7e 16                	jle    f0101366 <readline+0x82>
			if (echoing)
f0101350:	85 ff                	test   %edi,%edi
f0101352:	74 0d                	je     f0101361 <readline+0x7d>
				cputchar('\b');
f0101354:	83 ec 0c             	sub    $0xc,%esp
f0101357:	6a 08                	push   $0x8
f0101359:	e8 94 f2 ff ff       	call   f01005f2 <cputchar>
f010135e:	83 c4 10             	add    $0x10,%esp
			i--;
f0101361:	83 ee 01             	sub    $0x1,%esi
f0101364:	eb b3                	jmp    f0101319 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101366:	83 fb 1f             	cmp    $0x1f,%ebx
f0101369:	7e 23                	jle    f010138e <readline+0xaa>
f010136b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101371:	7f 1b                	jg     f010138e <readline+0xaa>
			if (echoing)
f0101373:	85 ff                	test   %edi,%edi
f0101375:	74 0c                	je     f0101383 <readline+0x9f>
				cputchar(c);
f0101377:	83 ec 0c             	sub    $0xc,%esp
f010137a:	53                   	push   %ebx
f010137b:	e8 72 f2 ff ff       	call   f01005f2 <cputchar>
f0101380:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101383:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101389:	8d 76 01             	lea    0x1(%esi),%esi
f010138c:	eb 8b                	jmp    f0101319 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010138e:	83 fb 0a             	cmp    $0xa,%ebx
f0101391:	74 05                	je     f0101398 <readline+0xb4>
f0101393:	83 fb 0d             	cmp    $0xd,%ebx
f0101396:	75 81                	jne    f0101319 <readline+0x35>
			if (echoing)
f0101398:	85 ff                	test   %edi,%edi
f010139a:	74 0d                	je     f01013a9 <readline+0xc5>
				cputchar('\n');
f010139c:	83 ec 0c             	sub    $0xc,%esp
f010139f:	6a 0a                	push   $0xa
f01013a1:	e8 4c f2 ff ff       	call   f01005f2 <cputchar>
f01013a6:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01013a9:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01013b0:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f01013b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013b8:	5b                   	pop    %ebx
f01013b9:	5e                   	pop    %esi
f01013ba:	5f                   	pop    %edi
f01013bb:	5d                   	pop    %ebp
f01013bc:	c3                   	ret    

f01013bd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01013bd:	55                   	push   %ebp
f01013be:	89 e5                	mov    %esp,%ebp
f01013c0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01013c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01013c8:	eb 03                	jmp    f01013cd <strlen+0x10>
		n++;
f01013ca:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01013cd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01013d1:	75 f7                	jne    f01013ca <strlen+0xd>
		n++;
	return n;
}
f01013d3:	5d                   	pop    %ebp
f01013d4:	c3                   	ret    

f01013d5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01013d5:	55                   	push   %ebp
f01013d6:	89 e5                	mov    %esp,%ebp
f01013d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013db:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01013de:	ba 00 00 00 00       	mov    $0x0,%edx
f01013e3:	eb 03                	jmp    f01013e8 <strnlen+0x13>
		n++;
f01013e5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01013e8:	39 c2                	cmp    %eax,%edx
f01013ea:	74 08                	je     f01013f4 <strnlen+0x1f>
f01013ec:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01013f0:	75 f3                	jne    f01013e5 <strnlen+0x10>
f01013f2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01013f4:	5d                   	pop    %ebp
f01013f5:	c3                   	ret    

f01013f6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01013f6:	55                   	push   %ebp
f01013f7:	89 e5                	mov    %esp,%ebp
f01013f9:	53                   	push   %ebx
f01013fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01013fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101400:	89 c2                	mov    %eax,%edx
f0101402:	83 c2 01             	add    $0x1,%edx
f0101405:	83 c1 01             	add    $0x1,%ecx
f0101408:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010140c:	88 5a ff             	mov    %bl,-0x1(%edx)
f010140f:	84 db                	test   %bl,%bl
f0101411:	75 ef                	jne    f0101402 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101413:	5b                   	pop    %ebx
f0101414:	5d                   	pop    %ebp
f0101415:	c3                   	ret    

f0101416 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101416:	55                   	push   %ebp
f0101417:	89 e5                	mov    %esp,%ebp
f0101419:	53                   	push   %ebx
f010141a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010141d:	53                   	push   %ebx
f010141e:	e8 9a ff ff ff       	call   f01013bd <strlen>
f0101423:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101426:	ff 75 0c             	pushl  0xc(%ebp)
f0101429:	01 d8                	add    %ebx,%eax
f010142b:	50                   	push   %eax
f010142c:	e8 c5 ff ff ff       	call   f01013f6 <strcpy>
	return dst;
}
f0101431:	89 d8                	mov    %ebx,%eax
f0101433:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101436:	c9                   	leave  
f0101437:	c3                   	ret    

f0101438 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101438:	55                   	push   %ebp
f0101439:	89 e5                	mov    %esp,%ebp
f010143b:	56                   	push   %esi
f010143c:	53                   	push   %ebx
f010143d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101440:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101443:	89 f3                	mov    %esi,%ebx
f0101445:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101448:	89 f2                	mov    %esi,%edx
f010144a:	eb 0f                	jmp    f010145b <strncpy+0x23>
		*dst++ = *src;
f010144c:	83 c2 01             	add    $0x1,%edx
f010144f:	0f b6 01             	movzbl (%ecx),%eax
f0101452:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101455:	80 39 01             	cmpb   $0x1,(%ecx)
f0101458:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010145b:	39 da                	cmp    %ebx,%edx
f010145d:	75 ed                	jne    f010144c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010145f:	89 f0                	mov    %esi,%eax
f0101461:	5b                   	pop    %ebx
f0101462:	5e                   	pop    %esi
f0101463:	5d                   	pop    %ebp
f0101464:	c3                   	ret    

f0101465 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101465:	55                   	push   %ebp
f0101466:	89 e5                	mov    %esp,%ebp
f0101468:	56                   	push   %esi
f0101469:	53                   	push   %ebx
f010146a:	8b 75 08             	mov    0x8(%ebp),%esi
f010146d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101470:	8b 55 10             	mov    0x10(%ebp),%edx
f0101473:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101475:	85 d2                	test   %edx,%edx
f0101477:	74 21                	je     f010149a <strlcpy+0x35>
f0101479:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010147d:	89 f2                	mov    %esi,%edx
f010147f:	eb 09                	jmp    f010148a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101481:	83 c2 01             	add    $0x1,%edx
f0101484:	83 c1 01             	add    $0x1,%ecx
f0101487:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010148a:	39 c2                	cmp    %eax,%edx
f010148c:	74 09                	je     f0101497 <strlcpy+0x32>
f010148e:	0f b6 19             	movzbl (%ecx),%ebx
f0101491:	84 db                	test   %bl,%bl
f0101493:	75 ec                	jne    f0101481 <strlcpy+0x1c>
f0101495:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101497:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010149a:	29 f0                	sub    %esi,%eax
}
f010149c:	5b                   	pop    %ebx
f010149d:	5e                   	pop    %esi
f010149e:	5d                   	pop    %ebp
f010149f:	c3                   	ret    

f01014a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01014a0:	55                   	push   %ebp
f01014a1:	89 e5                	mov    %esp,%ebp
f01014a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01014a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01014a9:	eb 06                	jmp    f01014b1 <strcmp+0x11>
		p++, q++;
f01014ab:	83 c1 01             	add    $0x1,%ecx
f01014ae:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01014b1:	0f b6 01             	movzbl (%ecx),%eax
f01014b4:	84 c0                	test   %al,%al
f01014b6:	74 04                	je     f01014bc <strcmp+0x1c>
f01014b8:	3a 02                	cmp    (%edx),%al
f01014ba:	74 ef                	je     f01014ab <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01014bc:	0f b6 c0             	movzbl %al,%eax
f01014bf:	0f b6 12             	movzbl (%edx),%edx
f01014c2:	29 d0                	sub    %edx,%eax
}
f01014c4:	5d                   	pop    %ebp
f01014c5:	c3                   	ret    

f01014c6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01014c6:	55                   	push   %ebp
f01014c7:	89 e5                	mov    %esp,%ebp
f01014c9:	53                   	push   %ebx
f01014ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01014cd:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014d0:	89 c3                	mov    %eax,%ebx
f01014d2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01014d5:	eb 06                	jmp    f01014dd <strncmp+0x17>
		n--, p++, q++;
f01014d7:	83 c0 01             	add    $0x1,%eax
f01014da:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01014dd:	39 d8                	cmp    %ebx,%eax
f01014df:	74 15                	je     f01014f6 <strncmp+0x30>
f01014e1:	0f b6 08             	movzbl (%eax),%ecx
f01014e4:	84 c9                	test   %cl,%cl
f01014e6:	74 04                	je     f01014ec <strncmp+0x26>
f01014e8:	3a 0a                	cmp    (%edx),%cl
f01014ea:	74 eb                	je     f01014d7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01014ec:	0f b6 00             	movzbl (%eax),%eax
f01014ef:	0f b6 12             	movzbl (%edx),%edx
f01014f2:	29 d0                	sub    %edx,%eax
f01014f4:	eb 05                	jmp    f01014fb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01014f6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01014fb:	5b                   	pop    %ebx
f01014fc:	5d                   	pop    %ebp
f01014fd:	c3                   	ret    

f01014fe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01014fe:	55                   	push   %ebp
f01014ff:	89 e5                	mov    %esp,%ebp
f0101501:	8b 45 08             	mov    0x8(%ebp),%eax
f0101504:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101508:	eb 07                	jmp    f0101511 <strchr+0x13>
		if (*s == c)
f010150a:	38 ca                	cmp    %cl,%dl
f010150c:	74 0f                	je     f010151d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010150e:	83 c0 01             	add    $0x1,%eax
f0101511:	0f b6 10             	movzbl (%eax),%edx
f0101514:	84 d2                	test   %dl,%dl
f0101516:	75 f2                	jne    f010150a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101518:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010151d:	5d                   	pop    %ebp
f010151e:	c3                   	ret    

f010151f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010151f:	55                   	push   %ebp
f0101520:	89 e5                	mov    %esp,%ebp
f0101522:	8b 45 08             	mov    0x8(%ebp),%eax
f0101525:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101529:	eb 03                	jmp    f010152e <strfind+0xf>
f010152b:	83 c0 01             	add    $0x1,%eax
f010152e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101531:	38 ca                	cmp    %cl,%dl
f0101533:	74 04                	je     f0101539 <strfind+0x1a>
f0101535:	84 d2                	test   %dl,%dl
f0101537:	75 f2                	jne    f010152b <strfind+0xc>
			break;
	return (char *) s;
}
f0101539:	5d                   	pop    %ebp
f010153a:	c3                   	ret    

f010153b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010153b:	55                   	push   %ebp
f010153c:	89 e5                	mov    %esp,%ebp
f010153e:	57                   	push   %edi
f010153f:	56                   	push   %esi
f0101540:	53                   	push   %ebx
f0101541:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101544:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101547:	85 c9                	test   %ecx,%ecx
f0101549:	74 36                	je     f0101581 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010154b:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101551:	75 28                	jne    f010157b <memset+0x40>
f0101553:	f6 c1 03             	test   $0x3,%cl
f0101556:	75 23                	jne    f010157b <memset+0x40>
		c &= 0xFF;
f0101558:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010155c:	89 d3                	mov    %edx,%ebx
f010155e:	c1 e3 08             	shl    $0x8,%ebx
f0101561:	89 d6                	mov    %edx,%esi
f0101563:	c1 e6 18             	shl    $0x18,%esi
f0101566:	89 d0                	mov    %edx,%eax
f0101568:	c1 e0 10             	shl    $0x10,%eax
f010156b:	09 f0                	or     %esi,%eax
f010156d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010156f:	89 d8                	mov    %ebx,%eax
f0101571:	09 d0                	or     %edx,%eax
f0101573:	c1 e9 02             	shr    $0x2,%ecx
f0101576:	fc                   	cld    
f0101577:	f3 ab                	rep stos %eax,%es:(%edi)
f0101579:	eb 06                	jmp    f0101581 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010157b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010157e:	fc                   	cld    
f010157f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101581:	89 f8                	mov    %edi,%eax
f0101583:	5b                   	pop    %ebx
f0101584:	5e                   	pop    %esi
f0101585:	5f                   	pop    %edi
f0101586:	5d                   	pop    %ebp
f0101587:	c3                   	ret    

f0101588 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101588:	55                   	push   %ebp
f0101589:	89 e5                	mov    %esp,%ebp
f010158b:	57                   	push   %edi
f010158c:	56                   	push   %esi
f010158d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101590:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101593:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101596:	39 c6                	cmp    %eax,%esi
f0101598:	73 35                	jae    f01015cf <memmove+0x47>
f010159a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010159d:	39 d0                	cmp    %edx,%eax
f010159f:	73 2e                	jae    f01015cf <memmove+0x47>
		s += n;
		d += n;
f01015a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01015a4:	89 d6                	mov    %edx,%esi
f01015a6:	09 fe                	or     %edi,%esi
f01015a8:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01015ae:	75 13                	jne    f01015c3 <memmove+0x3b>
f01015b0:	f6 c1 03             	test   $0x3,%cl
f01015b3:	75 0e                	jne    f01015c3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01015b5:	83 ef 04             	sub    $0x4,%edi
f01015b8:	8d 72 fc             	lea    -0x4(%edx),%esi
f01015bb:	c1 e9 02             	shr    $0x2,%ecx
f01015be:	fd                   	std    
f01015bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01015c1:	eb 09                	jmp    f01015cc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01015c3:	83 ef 01             	sub    $0x1,%edi
f01015c6:	8d 72 ff             	lea    -0x1(%edx),%esi
f01015c9:	fd                   	std    
f01015ca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01015cc:	fc                   	cld    
f01015cd:	eb 1d                	jmp    f01015ec <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01015cf:	89 f2                	mov    %esi,%edx
f01015d1:	09 c2                	or     %eax,%edx
f01015d3:	f6 c2 03             	test   $0x3,%dl
f01015d6:	75 0f                	jne    f01015e7 <memmove+0x5f>
f01015d8:	f6 c1 03             	test   $0x3,%cl
f01015db:	75 0a                	jne    f01015e7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01015dd:	c1 e9 02             	shr    $0x2,%ecx
f01015e0:	89 c7                	mov    %eax,%edi
f01015e2:	fc                   	cld    
f01015e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01015e5:	eb 05                	jmp    f01015ec <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01015e7:	89 c7                	mov    %eax,%edi
f01015e9:	fc                   	cld    
f01015ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01015ec:	5e                   	pop    %esi
f01015ed:	5f                   	pop    %edi
f01015ee:	5d                   	pop    %ebp
f01015ef:	c3                   	ret    

f01015f0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01015f0:	55                   	push   %ebp
f01015f1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01015f3:	ff 75 10             	pushl  0x10(%ebp)
f01015f6:	ff 75 0c             	pushl  0xc(%ebp)
f01015f9:	ff 75 08             	pushl  0x8(%ebp)
f01015fc:	e8 87 ff ff ff       	call   f0101588 <memmove>
}
f0101601:	c9                   	leave  
f0101602:	c3                   	ret    

f0101603 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101603:	55                   	push   %ebp
f0101604:	89 e5                	mov    %esp,%ebp
f0101606:	56                   	push   %esi
f0101607:	53                   	push   %ebx
f0101608:	8b 45 08             	mov    0x8(%ebp),%eax
f010160b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010160e:	89 c6                	mov    %eax,%esi
f0101610:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101613:	eb 1a                	jmp    f010162f <memcmp+0x2c>
		if (*s1 != *s2)
f0101615:	0f b6 08             	movzbl (%eax),%ecx
f0101618:	0f b6 1a             	movzbl (%edx),%ebx
f010161b:	38 d9                	cmp    %bl,%cl
f010161d:	74 0a                	je     f0101629 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010161f:	0f b6 c1             	movzbl %cl,%eax
f0101622:	0f b6 db             	movzbl %bl,%ebx
f0101625:	29 d8                	sub    %ebx,%eax
f0101627:	eb 0f                	jmp    f0101638 <memcmp+0x35>
		s1++, s2++;
f0101629:	83 c0 01             	add    $0x1,%eax
f010162c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010162f:	39 f0                	cmp    %esi,%eax
f0101631:	75 e2                	jne    f0101615 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101633:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101638:	5b                   	pop    %ebx
f0101639:	5e                   	pop    %esi
f010163a:	5d                   	pop    %ebp
f010163b:	c3                   	ret    

f010163c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010163c:	55                   	push   %ebp
f010163d:	89 e5                	mov    %esp,%ebp
f010163f:	53                   	push   %ebx
f0101640:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101643:	89 c1                	mov    %eax,%ecx
f0101645:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0101648:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010164c:	eb 0a                	jmp    f0101658 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010164e:	0f b6 10             	movzbl (%eax),%edx
f0101651:	39 da                	cmp    %ebx,%edx
f0101653:	74 07                	je     f010165c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101655:	83 c0 01             	add    $0x1,%eax
f0101658:	39 c8                	cmp    %ecx,%eax
f010165a:	72 f2                	jb     f010164e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010165c:	5b                   	pop    %ebx
f010165d:	5d                   	pop    %ebp
f010165e:	c3                   	ret    

f010165f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010165f:	55                   	push   %ebp
f0101660:	89 e5                	mov    %esp,%ebp
f0101662:	57                   	push   %edi
f0101663:	56                   	push   %esi
f0101664:	53                   	push   %ebx
f0101665:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101668:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010166b:	eb 03                	jmp    f0101670 <strtol+0x11>
		s++;
f010166d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101670:	0f b6 01             	movzbl (%ecx),%eax
f0101673:	3c 20                	cmp    $0x20,%al
f0101675:	74 f6                	je     f010166d <strtol+0xe>
f0101677:	3c 09                	cmp    $0x9,%al
f0101679:	74 f2                	je     f010166d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010167b:	3c 2b                	cmp    $0x2b,%al
f010167d:	75 0a                	jne    f0101689 <strtol+0x2a>
		s++;
f010167f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101682:	bf 00 00 00 00       	mov    $0x0,%edi
f0101687:	eb 11                	jmp    f010169a <strtol+0x3b>
f0101689:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010168e:	3c 2d                	cmp    $0x2d,%al
f0101690:	75 08                	jne    f010169a <strtol+0x3b>
		s++, neg = 1;
f0101692:	83 c1 01             	add    $0x1,%ecx
f0101695:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010169a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01016a0:	75 15                	jne    f01016b7 <strtol+0x58>
f01016a2:	80 39 30             	cmpb   $0x30,(%ecx)
f01016a5:	75 10                	jne    f01016b7 <strtol+0x58>
f01016a7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01016ab:	75 7c                	jne    f0101729 <strtol+0xca>
		s += 2, base = 16;
f01016ad:	83 c1 02             	add    $0x2,%ecx
f01016b0:	bb 10 00 00 00       	mov    $0x10,%ebx
f01016b5:	eb 16                	jmp    f01016cd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01016b7:	85 db                	test   %ebx,%ebx
f01016b9:	75 12                	jne    f01016cd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01016bb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01016c0:	80 39 30             	cmpb   $0x30,(%ecx)
f01016c3:	75 08                	jne    f01016cd <strtol+0x6e>
		s++, base = 8;
f01016c5:	83 c1 01             	add    $0x1,%ecx
f01016c8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01016cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01016d2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01016d5:	0f b6 11             	movzbl (%ecx),%edx
f01016d8:	8d 72 d0             	lea    -0x30(%edx),%esi
f01016db:	89 f3                	mov    %esi,%ebx
f01016dd:	80 fb 09             	cmp    $0x9,%bl
f01016e0:	77 08                	ja     f01016ea <strtol+0x8b>
			dig = *s - '0';
f01016e2:	0f be d2             	movsbl %dl,%edx
f01016e5:	83 ea 30             	sub    $0x30,%edx
f01016e8:	eb 22                	jmp    f010170c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01016ea:	8d 72 9f             	lea    -0x61(%edx),%esi
f01016ed:	89 f3                	mov    %esi,%ebx
f01016ef:	80 fb 19             	cmp    $0x19,%bl
f01016f2:	77 08                	ja     f01016fc <strtol+0x9d>
			dig = *s - 'a' + 10;
f01016f4:	0f be d2             	movsbl %dl,%edx
f01016f7:	83 ea 57             	sub    $0x57,%edx
f01016fa:	eb 10                	jmp    f010170c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01016fc:	8d 72 bf             	lea    -0x41(%edx),%esi
f01016ff:	89 f3                	mov    %esi,%ebx
f0101701:	80 fb 19             	cmp    $0x19,%bl
f0101704:	77 16                	ja     f010171c <strtol+0xbd>
			dig = *s - 'A' + 10;
f0101706:	0f be d2             	movsbl %dl,%edx
f0101709:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010170c:	3b 55 10             	cmp    0x10(%ebp),%edx
f010170f:	7d 0b                	jge    f010171c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0101711:	83 c1 01             	add    $0x1,%ecx
f0101714:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101718:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f010171a:	eb b9                	jmp    f01016d5 <strtol+0x76>

	if (endptr)
f010171c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101720:	74 0d                	je     f010172f <strtol+0xd0>
		*endptr = (char *) s;
f0101722:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101725:	89 0e                	mov    %ecx,(%esi)
f0101727:	eb 06                	jmp    f010172f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101729:	85 db                	test   %ebx,%ebx
f010172b:	74 98                	je     f01016c5 <strtol+0x66>
f010172d:	eb 9e                	jmp    f01016cd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010172f:	89 c2                	mov    %eax,%edx
f0101731:	f7 da                	neg    %edx
f0101733:	85 ff                	test   %edi,%edi
f0101735:	0f 45 c2             	cmovne %edx,%eax
}
f0101738:	5b                   	pop    %ebx
f0101739:	5e                   	pop    %esi
f010173a:	5f                   	pop    %edi
f010173b:	5d                   	pop    %ebp
f010173c:	c3                   	ret    
f010173d:	66 90                	xchg   %ax,%ax
f010173f:	90                   	nop

f0101740 <__udivdi3>:
f0101740:	55                   	push   %ebp
f0101741:	57                   	push   %edi
f0101742:	56                   	push   %esi
f0101743:	53                   	push   %ebx
f0101744:	83 ec 1c             	sub    $0x1c,%esp
f0101747:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010174b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010174f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101753:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101757:	85 f6                	test   %esi,%esi
f0101759:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010175d:	89 ca                	mov    %ecx,%edx
f010175f:	89 f8                	mov    %edi,%eax
f0101761:	75 3d                	jne    f01017a0 <__udivdi3+0x60>
f0101763:	39 cf                	cmp    %ecx,%edi
f0101765:	0f 87 c5 00 00 00    	ja     f0101830 <__udivdi3+0xf0>
f010176b:	85 ff                	test   %edi,%edi
f010176d:	89 fd                	mov    %edi,%ebp
f010176f:	75 0b                	jne    f010177c <__udivdi3+0x3c>
f0101771:	b8 01 00 00 00       	mov    $0x1,%eax
f0101776:	31 d2                	xor    %edx,%edx
f0101778:	f7 f7                	div    %edi
f010177a:	89 c5                	mov    %eax,%ebp
f010177c:	89 c8                	mov    %ecx,%eax
f010177e:	31 d2                	xor    %edx,%edx
f0101780:	f7 f5                	div    %ebp
f0101782:	89 c1                	mov    %eax,%ecx
f0101784:	89 d8                	mov    %ebx,%eax
f0101786:	89 cf                	mov    %ecx,%edi
f0101788:	f7 f5                	div    %ebp
f010178a:	89 c3                	mov    %eax,%ebx
f010178c:	89 d8                	mov    %ebx,%eax
f010178e:	89 fa                	mov    %edi,%edx
f0101790:	83 c4 1c             	add    $0x1c,%esp
f0101793:	5b                   	pop    %ebx
f0101794:	5e                   	pop    %esi
f0101795:	5f                   	pop    %edi
f0101796:	5d                   	pop    %ebp
f0101797:	c3                   	ret    
f0101798:	90                   	nop
f0101799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017a0:	39 ce                	cmp    %ecx,%esi
f01017a2:	77 74                	ja     f0101818 <__udivdi3+0xd8>
f01017a4:	0f bd fe             	bsr    %esi,%edi
f01017a7:	83 f7 1f             	xor    $0x1f,%edi
f01017aa:	0f 84 98 00 00 00    	je     f0101848 <__udivdi3+0x108>
f01017b0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01017b5:	89 f9                	mov    %edi,%ecx
f01017b7:	89 c5                	mov    %eax,%ebp
f01017b9:	29 fb                	sub    %edi,%ebx
f01017bb:	d3 e6                	shl    %cl,%esi
f01017bd:	89 d9                	mov    %ebx,%ecx
f01017bf:	d3 ed                	shr    %cl,%ebp
f01017c1:	89 f9                	mov    %edi,%ecx
f01017c3:	d3 e0                	shl    %cl,%eax
f01017c5:	09 ee                	or     %ebp,%esi
f01017c7:	89 d9                	mov    %ebx,%ecx
f01017c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017cd:	89 d5                	mov    %edx,%ebp
f01017cf:	8b 44 24 08          	mov    0x8(%esp),%eax
f01017d3:	d3 ed                	shr    %cl,%ebp
f01017d5:	89 f9                	mov    %edi,%ecx
f01017d7:	d3 e2                	shl    %cl,%edx
f01017d9:	89 d9                	mov    %ebx,%ecx
f01017db:	d3 e8                	shr    %cl,%eax
f01017dd:	09 c2                	or     %eax,%edx
f01017df:	89 d0                	mov    %edx,%eax
f01017e1:	89 ea                	mov    %ebp,%edx
f01017e3:	f7 f6                	div    %esi
f01017e5:	89 d5                	mov    %edx,%ebp
f01017e7:	89 c3                	mov    %eax,%ebx
f01017e9:	f7 64 24 0c          	mull   0xc(%esp)
f01017ed:	39 d5                	cmp    %edx,%ebp
f01017ef:	72 10                	jb     f0101801 <__udivdi3+0xc1>
f01017f1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01017f5:	89 f9                	mov    %edi,%ecx
f01017f7:	d3 e6                	shl    %cl,%esi
f01017f9:	39 c6                	cmp    %eax,%esi
f01017fb:	73 07                	jae    f0101804 <__udivdi3+0xc4>
f01017fd:	39 d5                	cmp    %edx,%ebp
f01017ff:	75 03                	jne    f0101804 <__udivdi3+0xc4>
f0101801:	83 eb 01             	sub    $0x1,%ebx
f0101804:	31 ff                	xor    %edi,%edi
f0101806:	89 d8                	mov    %ebx,%eax
f0101808:	89 fa                	mov    %edi,%edx
f010180a:	83 c4 1c             	add    $0x1c,%esp
f010180d:	5b                   	pop    %ebx
f010180e:	5e                   	pop    %esi
f010180f:	5f                   	pop    %edi
f0101810:	5d                   	pop    %ebp
f0101811:	c3                   	ret    
f0101812:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101818:	31 ff                	xor    %edi,%edi
f010181a:	31 db                	xor    %ebx,%ebx
f010181c:	89 d8                	mov    %ebx,%eax
f010181e:	89 fa                	mov    %edi,%edx
f0101820:	83 c4 1c             	add    $0x1c,%esp
f0101823:	5b                   	pop    %ebx
f0101824:	5e                   	pop    %esi
f0101825:	5f                   	pop    %edi
f0101826:	5d                   	pop    %ebp
f0101827:	c3                   	ret    
f0101828:	90                   	nop
f0101829:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101830:	89 d8                	mov    %ebx,%eax
f0101832:	f7 f7                	div    %edi
f0101834:	31 ff                	xor    %edi,%edi
f0101836:	89 c3                	mov    %eax,%ebx
f0101838:	89 d8                	mov    %ebx,%eax
f010183a:	89 fa                	mov    %edi,%edx
f010183c:	83 c4 1c             	add    $0x1c,%esp
f010183f:	5b                   	pop    %ebx
f0101840:	5e                   	pop    %esi
f0101841:	5f                   	pop    %edi
f0101842:	5d                   	pop    %ebp
f0101843:	c3                   	ret    
f0101844:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101848:	39 ce                	cmp    %ecx,%esi
f010184a:	72 0c                	jb     f0101858 <__udivdi3+0x118>
f010184c:	31 db                	xor    %ebx,%ebx
f010184e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101852:	0f 87 34 ff ff ff    	ja     f010178c <__udivdi3+0x4c>
f0101858:	bb 01 00 00 00       	mov    $0x1,%ebx
f010185d:	e9 2a ff ff ff       	jmp    f010178c <__udivdi3+0x4c>
f0101862:	66 90                	xchg   %ax,%ax
f0101864:	66 90                	xchg   %ax,%ax
f0101866:	66 90                	xchg   %ax,%ax
f0101868:	66 90                	xchg   %ax,%ax
f010186a:	66 90                	xchg   %ax,%ax
f010186c:	66 90                	xchg   %ax,%ax
f010186e:	66 90                	xchg   %ax,%ax

f0101870 <__umoddi3>:
f0101870:	55                   	push   %ebp
f0101871:	57                   	push   %edi
f0101872:	56                   	push   %esi
f0101873:	53                   	push   %ebx
f0101874:	83 ec 1c             	sub    $0x1c,%esp
f0101877:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010187b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010187f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101883:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101887:	85 d2                	test   %edx,%edx
f0101889:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010188d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101891:	89 f3                	mov    %esi,%ebx
f0101893:	89 3c 24             	mov    %edi,(%esp)
f0101896:	89 74 24 04          	mov    %esi,0x4(%esp)
f010189a:	75 1c                	jne    f01018b8 <__umoddi3+0x48>
f010189c:	39 f7                	cmp    %esi,%edi
f010189e:	76 50                	jbe    f01018f0 <__umoddi3+0x80>
f01018a0:	89 c8                	mov    %ecx,%eax
f01018a2:	89 f2                	mov    %esi,%edx
f01018a4:	f7 f7                	div    %edi
f01018a6:	89 d0                	mov    %edx,%eax
f01018a8:	31 d2                	xor    %edx,%edx
f01018aa:	83 c4 1c             	add    $0x1c,%esp
f01018ad:	5b                   	pop    %ebx
f01018ae:	5e                   	pop    %esi
f01018af:	5f                   	pop    %edi
f01018b0:	5d                   	pop    %ebp
f01018b1:	c3                   	ret    
f01018b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01018b8:	39 f2                	cmp    %esi,%edx
f01018ba:	89 d0                	mov    %edx,%eax
f01018bc:	77 52                	ja     f0101910 <__umoddi3+0xa0>
f01018be:	0f bd ea             	bsr    %edx,%ebp
f01018c1:	83 f5 1f             	xor    $0x1f,%ebp
f01018c4:	75 5a                	jne    f0101920 <__umoddi3+0xb0>
f01018c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01018ca:	0f 82 e0 00 00 00    	jb     f01019b0 <__umoddi3+0x140>
f01018d0:	39 0c 24             	cmp    %ecx,(%esp)
f01018d3:	0f 86 d7 00 00 00    	jbe    f01019b0 <__umoddi3+0x140>
f01018d9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01018dd:	8b 54 24 04          	mov    0x4(%esp),%edx
f01018e1:	83 c4 1c             	add    $0x1c,%esp
f01018e4:	5b                   	pop    %ebx
f01018e5:	5e                   	pop    %esi
f01018e6:	5f                   	pop    %edi
f01018e7:	5d                   	pop    %ebp
f01018e8:	c3                   	ret    
f01018e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01018f0:	85 ff                	test   %edi,%edi
f01018f2:	89 fd                	mov    %edi,%ebp
f01018f4:	75 0b                	jne    f0101901 <__umoddi3+0x91>
f01018f6:	b8 01 00 00 00       	mov    $0x1,%eax
f01018fb:	31 d2                	xor    %edx,%edx
f01018fd:	f7 f7                	div    %edi
f01018ff:	89 c5                	mov    %eax,%ebp
f0101901:	89 f0                	mov    %esi,%eax
f0101903:	31 d2                	xor    %edx,%edx
f0101905:	f7 f5                	div    %ebp
f0101907:	89 c8                	mov    %ecx,%eax
f0101909:	f7 f5                	div    %ebp
f010190b:	89 d0                	mov    %edx,%eax
f010190d:	eb 99                	jmp    f01018a8 <__umoddi3+0x38>
f010190f:	90                   	nop
f0101910:	89 c8                	mov    %ecx,%eax
f0101912:	89 f2                	mov    %esi,%edx
f0101914:	83 c4 1c             	add    $0x1c,%esp
f0101917:	5b                   	pop    %ebx
f0101918:	5e                   	pop    %esi
f0101919:	5f                   	pop    %edi
f010191a:	5d                   	pop    %ebp
f010191b:	c3                   	ret    
f010191c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101920:	8b 34 24             	mov    (%esp),%esi
f0101923:	bf 20 00 00 00       	mov    $0x20,%edi
f0101928:	89 e9                	mov    %ebp,%ecx
f010192a:	29 ef                	sub    %ebp,%edi
f010192c:	d3 e0                	shl    %cl,%eax
f010192e:	89 f9                	mov    %edi,%ecx
f0101930:	89 f2                	mov    %esi,%edx
f0101932:	d3 ea                	shr    %cl,%edx
f0101934:	89 e9                	mov    %ebp,%ecx
f0101936:	09 c2                	or     %eax,%edx
f0101938:	89 d8                	mov    %ebx,%eax
f010193a:	89 14 24             	mov    %edx,(%esp)
f010193d:	89 f2                	mov    %esi,%edx
f010193f:	d3 e2                	shl    %cl,%edx
f0101941:	89 f9                	mov    %edi,%ecx
f0101943:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101947:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010194b:	d3 e8                	shr    %cl,%eax
f010194d:	89 e9                	mov    %ebp,%ecx
f010194f:	89 c6                	mov    %eax,%esi
f0101951:	d3 e3                	shl    %cl,%ebx
f0101953:	89 f9                	mov    %edi,%ecx
f0101955:	89 d0                	mov    %edx,%eax
f0101957:	d3 e8                	shr    %cl,%eax
f0101959:	89 e9                	mov    %ebp,%ecx
f010195b:	09 d8                	or     %ebx,%eax
f010195d:	89 d3                	mov    %edx,%ebx
f010195f:	89 f2                	mov    %esi,%edx
f0101961:	f7 34 24             	divl   (%esp)
f0101964:	89 d6                	mov    %edx,%esi
f0101966:	d3 e3                	shl    %cl,%ebx
f0101968:	f7 64 24 04          	mull   0x4(%esp)
f010196c:	39 d6                	cmp    %edx,%esi
f010196e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101972:	89 d1                	mov    %edx,%ecx
f0101974:	89 c3                	mov    %eax,%ebx
f0101976:	72 08                	jb     f0101980 <__umoddi3+0x110>
f0101978:	75 11                	jne    f010198b <__umoddi3+0x11b>
f010197a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010197e:	73 0b                	jae    f010198b <__umoddi3+0x11b>
f0101980:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101984:	1b 14 24             	sbb    (%esp),%edx
f0101987:	89 d1                	mov    %edx,%ecx
f0101989:	89 c3                	mov    %eax,%ebx
f010198b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010198f:	29 da                	sub    %ebx,%edx
f0101991:	19 ce                	sbb    %ecx,%esi
f0101993:	89 f9                	mov    %edi,%ecx
f0101995:	89 f0                	mov    %esi,%eax
f0101997:	d3 e0                	shl    %cl,%eax
f0101999:	89 e9                	mov    %ebp,%ecx
f010199b:	d3 ea                	shr    %cl,%edx
f010199d:	89 e9                	mov    %ebp,%ecx
f010199f:	d3 ee                	shr    %cl,%esi
f01019a1:	09 d0                	or     %edx,%eax
f01019a3:	89 f2                	mov    %esi,%edx
f01019a5:	83 c4 1c             	add    $0x1c,%esp
f01019a8:	5b                   	pop    %ebx
f01019a9:	5e                   	pop    %esi
f01019aa:	5f                   	pop    %edi
f01019ab:	5d                   	pop    %ebp
f01019ac:	c3                   	ret    
f01019ad:	8d 76 00             	lea    0x0(%esi),%esi
f01019b0:	29 f9                	sub    %edi,%ecx
f01019b2:	19 d6                	sbb    %edx,%esi
f01019b4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01019b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01019bc:	e9 18 ff ff ff       	jmp    f01018d9 <__umoddi3+0x69>
