
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
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
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
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 de 1d f0 00 	cmpl   $0x0,0xf01dde80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 de 1d f0    	mov    %esi,0xf01dde80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 f1 59 00 00       	call   f0105a52 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 e0 60 10 f0       	push   $0xf01060e0
f010006d:	e8 0a 36 00 00       	call   f010367c <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 da 35 00 00       	call   f0103656 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 fd 72 10 f0 	movl   $0xf01072fd,(%esp)
f0100083:	e8 f4 35 00 00       	call   f010367c <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 8b 08 00 00       	call   f0100920 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 08 f0 21 f0       	mov    $0xf021f008,%eax
f01000a6:	2d 2c c2 1d f0       	sub    $0xf01dc22c,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 2c c2 1d f0       	push   $0xf01dc22c
f01000b3:	e8 7a 53 00 00       	call   f0105432 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 79 05 00 00       	call   f0100636 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 4c 61 10 f0       	push   $0xf010614c
f01000ca:	e8 ad 35 00 00       	call   f010367c <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 76 11 00 00       	call   f010124a <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 ec 2d 00 00       	call   f0102ec5 <env_init>
	trap_init();
f01000d9:	e8 82 36 00 00       	call   f0103760 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 65 56 00 00       	call   f0105748 <mp_init>
	lapic_init();
f01000e3:	e8 85 59 00 00       	call   f0105a6d <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 b6 34 00 00       	call   f01035a3 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000f4:	e8 c7 5b 00 00       	call   f0105cc0 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 de 1d f0 07 	cmpl   $0x7,0xf01dde88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 04 61 10 f0       	push   $0xf0106104
f010010f:	6a 61                	push   $0x61
f0100111:	68 67 61 10 f0       	push   $0xf0106167
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 ae 56 10 f0       	mov    $0xf01056ae,%eax
f0100123:	2d 34 56 10 f0       	sub    $0xf0105634,%eax
f0100128:	50                   	push   %eax
f0100129:	68 34 56 10 f0       	push   $0xf0105634
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 47 53 00 00       	call   f010547f <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 e0 1d f0       	mov    $0xf01de020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 0b 59 00 00       	call   f0105a52 <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 e0 1d f0       	add    $0xf01de020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 e0 1d f0       	sub    $0xf01de020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 70 1e f0       	add    $0xf01e7000,%eax
f010016b:	a3 84 de 1d f0       	mov    %eax,0xf01dde84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 3a 5a 00 00       	call   f0105bbb <lapic_startap>
f0100181:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100184:	8b 43 04             	mov    0x4(%ebx),%eax
f0100187:	83 f8 01             	cmp    $0x1,%eax
f010018a:	75 f8                	jne    f0100184 <i386_init+0xea>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018c:	83 c3 74             	add    $0x74,%ebx
f010018f:	6b 05 c4 e3 1d f0 74 	imul   $0x74,0xf01de3c4,%eax
f0100196:	05 20 e0 1d f0       	add    $0xf01de020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
	// Start fs.
	//ENV_CREATE(fs_fs, ENV_TYPE_FS);

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 00                	push   $0x0
f01001a4:	68 90 e9 18 f0       	push   $0xf018e990
f01001a9:	e8 ec 2e 00 00       	call   f010309a <env_create>
	cprintf("SRHS: all 3 env created\n");

#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001ae:	e8 27 04 00 00       	call   f01005da <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001b3:	e8 c8 40 00 00       	call   f0104280 <sched_yield>

f01001b8 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001b8:	55                   	push   %ebp
f01001b9:	89 e5                	mov    %esp,%ebp
f01001bb:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001be:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001c3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c8:	77 12                	ja     f01001dc <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001ca:	50                   	push   %eax
f01001cb:	68 28 61 10 f0       	push   $0xf0106128
f01001d0:	6a 78                	push   $0x78
f01001d2:	68 67 61 10 f0       	push   $0xf0106167
f01001d7:	e8 64 fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01001dc:	05 00 00 00 10       	add    $0x10000000,%eax
f01001e1:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001e4:	e8 69 58 00 00       	call   f0105a52 <cpunum>
f01001e9:	83 ec 08             	sub    $0x8,%esp
f01001ec:	50                   	push   %eax
f01001ed:	68 73 61 10 f0       	push   $0xf0106173
f01001f2:	e8 85 34 00 00       	call   f010367c <cprintf>

	lapic_init();
f01001f7:	e8 71 58 00 00       	call   f0105a6d <lapic_init>
	env_init_percpu();
f01001fc:	e8 94 2c 00 00       	call   f0102e95 <env_init_percpu>
	trap_init_percpu();
f0100201:	e8 8a 34 00 00       	call   f0103690 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100206:	e8 47 58 00 00       	call   f0105a52 <cpunum>
f010020b:	6b d0 74             	imul   $0x74,%eax,%edx
f010020e:	81 c2 20 e0 1d f0    	add    $0xf01de020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100214:	b8 01 00 00 00       	mov    $0x1,%eax
f0100219:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010021d:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100224:	e8 97 5a 00 00       	call   f0105cc0 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100229:	e8 52 40 00 00       	call   f0104280 <sched_yield>

f010022e <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010022e:	55                   	push   %ebp
f010022f:	89 e5                	mov    %esp,%ebp
f0100231:	53                   	push   %ebx
f0100232:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100235:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100238:	ff 75 0c             	pushl  0xc(%ebp)
f010023b:	ff 75 08             	pushl  0x8(%ebp)
f010023e:	68 89 61 10 f0       	push   $0xf0106189
f0100243:	e8 34 34 00 00       	call   f010367c <cprintf>
	vcprintf(fmt, ap);
f0100248:	83 c4 08             	add    $0x8,%esp
f010024b:	53                   	push   %ebx
f010024c:	ff 75 10             	pushl  0x10(%ebp)
f010024f:	e8 02 34 00 00       	call   f0103656 <vcprintf>
	cprintf("\n");
f0100254:	c7 04 24 fd 72 10 f0 	movl   $0xf01072fd,(%esp)
f010025b:	e8 1c 34 00 00       	call   f010367c <cprintf>
	va_end(ap);
}
f0100260:	83 c4 10             	add    $0x10,%esp
f0100263:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100266:	c9                   	leave  
f0100267:	c3                   	ret    

f0100268 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100268:	55                   	push   %ebp
f0100269:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010026b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100270:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100271:	a8 01                	test   $0x1,%al
f0100273:	74 0b                	je     f0100280 <serial_proc_data+0x18>
f0100275:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010027a:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010027b:	0f b6 c0             	movzbl %al,%eax
f010027e:	eb 05                	jmp    f0100285 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100280:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100285:	5d                   	pop    %ebp
f0100286:	c3                   	ret    

f0100287 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100287:	55                   	push   %ebp
f0100288:	89 e5                	mov    %esp,%ebp
f010028a:	53                   	push   %ebx
f010028b:	83 ec 04             	sub    $0x4,%esp
f010028e:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100290:	eb 2b                	jmp    f01002bd <cons_intr+0x36>
		if (c == 0)
f0100292:	85 c0                	test   %eax,%eax
f0100294:	74 27                	je     f01002bd <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100296:	8b 0d 24 d2 1d f0    	mov    0xf01dd224,%ecx
f010029c:	8d 51 01             	lea    0x1(%ecx),%edx
f010029f:	89 15 24 d2 1d f0    	mov    %edx,0xf01dd224
f01002a5:	88 81 20 d0 1d f0    	mov    %al,-0xfe22fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ab:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002b1:	75 0a                	jne    f01002bd <cons_intr+0x36>
			cons.wpos = 0;
f01002b3:	c7 05 24 d2 1d f0 00 	movl   $0x0,0xf01dd224
f01002ba:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002bd:	ff d3                	call   *%ebx
f01002bf:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002c2:	75 ce                	jne    f0100292 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002c4:	83 c4 04             	add    $0x4,%esp
f01002c7:	5b                   	pop    %ebx
f01002c8:	5d                   	pop    %ebp
f01002c9:	c3                   	ret    

f01002ca <kbd_proc_data>:
f01002ca:	ba 64 00 00 00       	mov    $0x64,%edx
f01002cf:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01002d0:	a8 01                	test   $0x1,%al
f01002d2:	0f 84 f0 00 00 00    	je     f01003c8 <kbd_proc_data+0xfe>
f01002d8:	ba 60 00 00 00       	mov    $0x60,%edx
f01002dd:	ec                   	in     (%dx),%al
f01002de:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002e0:	3c e0                	cmp    $0xe0,%al
f01002e2:	75 0d                	jne    f01002f1 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01002e4:	83 0d 00 d0 1d f0 40 	orl    $0x40,0xf01dd000
		return 0;
f01002eb:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002f0:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002f1:	55                   	push   %ebp
f01002f2:	89 e5                	mov    %esp,%ebp
f01002f4:	53                   	push   %ebx
f01002f5:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002f8:	84 c0                	test   %al,%al
f01002fa:	79 36                	jns    f0100332 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002fc:	8b 0d 00 d0 1d f0    	mov    0xf01dd000,%ecx
f0100302:	89 cb                	mov    %ecx,%ebx
f0100304:	83 e3 40             	and    $0x40,%ebx
f0100307:	83 e0 7f             	and    $0x7f,%eax
f010030a:	85 db                	test   %ebx,%ebx
f010030c:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010030f:	0f b6 d2             	movzbl %dl,%edx
f0100312:	0f b6 82 00 63 10 f0 	movzbl -0xfef9d00(%edx),%eax
f0100319:	83 c8 40             	or     $0x40,%eax
f010031c:	0f b6 c0             	movzbl %al,%eax
f010031f:	f7 d0                	not    %eax
f0100321:	21 c8                	and    %ecx,%eax
f0100323:	a3 00 d0 1d f0       	mov    %eax,0xf01dd000
		return 0;
f0100328:	b8 00 00 00 00       	mov    $0x0,%eax
f010032d:	e9 9e 00 00 00       	jmp    f01003d0 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100332:	8b 0d 00 d0 1d f0    	mov    0xf01dd000,%ecx
f0100338:	f6 c1 40             	test   $0x40,%cl
f010033b:	74 0e                	je     f010034b <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010033d:	83 c8 80             	or     $0xffffff80,%eax
f0100340:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100342:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100345:	89 0d 00 d0 1d f0    	mov    %ecx,0xf01dd000
	}

	shift |= shiftcode[data];
f010034b:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010034e:	0f b6 82 00 63 10 f0 	movzbl -0xfef9d00(%edx),%eax
f0100355:	0b 05 00 d0 1d f0    	or     0xf01dd000,%eax
f010035b:	0f b6 8a 00 62 10 f0 	movzbl -0xfef9e00(%edx),%ecx
f0100362:	31 c8                	xor    %ecx,%eax
f0100364:	a3 00 d0 1d f0       	mov    %eax,0xf01dd000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100369:	89 c1                	mov    %eax,%ecx
f010036b:	83 e1 03             	and    $0x3,%ecx
f010036e:	8b 0c 8d e0 61 10 f0 	mov    -0xfef9e20(,%ecx,4),%ecx
f0100375:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100379:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010037c:	a8 08                	test   $0x8,%al
f010037e:	74 1b                	je     f010039b <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100380:	89 da                	mov    %ebx,%edx
f0100382:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100385:	83 f9 19             	cmp    $0x19,%ecx
f0100388:	77 05                	ja     f010038f <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f010038a:	83 eb 20             	sub    $0x20,%ebx
f010038d:	eb 0c                	jmp    f010039b <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f010038f:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100392:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100395:	83 fa 19             	cmp    $0x19,%edx
f0100398:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010039b:	f7 d0                	not    %eax
f010039d:	a8 06                	test   $0x6,%al
f010039f:	75 2d                	jne    f01003ce <kbd_proc_data+0x104>
f01003a1:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003a7:	75 25                	jne    f01003ce <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01003a9:	83 ec 0c             	sub    $0xc,%esp
f01003ac:	68 a3 61 10 f0       	push   $0xf01061a3
f01003b1:	e8 c6 32 00 00       	call   f010367c <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b6:	ba 92 00 00 00       	mov    $0x92,%edx
f01003bb:	b8 03 00 00 00       	mov    $0x3,%eax
f01003c0:	ee                   	out    %al,(%dx)
f01003c1:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c4:	89 d8                	mov    %ebx,%eax
f01003c6:	eb 08                	jmp    f01003d0 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003cd:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003ce:	89 d8                	mov    %ebx,%eax
}
f01003d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003d3:	c9                   	leave  
f01003d4:	c3                   	ret    

f01003d5 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003d5:	55                   	push   %ebp
f01003d6:	89 e5                	mov    %esp,%ebp
f01003d8:	57                   	push   %edi
f01003d9:	56                   	push   %esi
f01003da:	53                   	push   %ebx
f01003db:	83 ec 1c             	sub    $0x1c,%esp
f01003de:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003e0:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003e5:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003ea:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003ef:	eb 09                	jmp    f01003fa <cons_putc+0x25>
f01003f1:	89 ca                	mov    %ecx,%edx
f01003f3:	ec                   	in     (%dx),%al
f01003f4:	ec                   	in     (%dx),%al
f01003f5:	ec                   	in     (%dx),%al
f01003f6:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003f7:	83 c3 01             	add    $0x1,%ebx
f01003fa:	89 f2                	mov    %esi,%edx
f01003fc:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003fd:	a8 20                	test   $0x20,%al
f01003ff:	75 08                	jne    f0100409 <cons_putc+0x34>
f0100401:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100407:	7e e8                	jle    f01003f1 <cons_putc+0x1c>
f0100409:	89 f8                	mov    %edi,%eax
f010040b:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010040e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100413:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100414:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100419:	be 79 03 00 00       	mov    $0x379,%esi
f010041e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100423:	eb 09                	jmp    f010042e <cons_putc+0x59>
f0100425:	89 ca                	mov    %ecx,%edx
f0100427:	ec                   	in     (%dx),%al
f0100428:	ec                   	in     (%dx),%al
f0100429:	ec                   	in     (%dx),%al
f010042a:	ec                   	in     (%dx),%al
f010042b:	83 c3 01             	add    $0x1,%ebx
f010042e:	89 f2                	mov    %esi,%edx
f0100430:	ec                   	in     (%dx),%al
f0100431:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100437:	7f 04                	jg     f010043d <cons_putc+0x68>
f0100439:	84 c0                	test   %al,%al
f010043b:	79 e8                	jns    f0100425 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010043d:	ba 78 03 00 00       	mov    $0x378,%edx
f0100442:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100446:	ee                   	out    %al,(%dx)
f0100447:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010044c:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100451:	ee                   	out    %al,(%dx)
f0100452:	b8 08 00 00 00       	mov    $0x8,%eax
f0100457:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100458:	89 fa                	mov    %edi,%edx
f010045a:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100460:	89 f8                	mov    %edi,%eax
f0100462:	80 cc 07             	or     $0x7,%ah
f0100465:	85 d2                	test   %edx,%edx
f0100467:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010046a:	89 f8                	mov    %edi,%eax
f010046c:	0f b6 c0             	movzbl %al,%eax
f010046f:	83 f8 09             	cmp    $0x9,%eax
f0100472:	74 74                	je     f01004e8 <cons_putc+0x113>
f0100474:	83 f8 09             	cmp    $0x9,%eax
f0100477:	7f 0a                	jg     f0100483 <cons_putc+0xae>
f0100479:	83 f8 08             	cmp    $0x8,%eax
f010047c:	74 14                	je     f0100492 <cons_putc+0xbd>
f010047e:	e9 99 00 00 00       	jmp    f010051c <cons_putc+0x147>
f0100483:	83 f8 0a             	cmp    $0xa,%eax
f0100486:	74 3a                	je     f01004c2 <cons_putc+0xed>
f0100488:	83 f8 0d             	cmp    $0xd,%eax
f010048b:	74 3d                	je     f01004ca <cons_putc+0xf5>
f010048d:	e9 8a 00 00 00       	jmp    f010051c <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100492:	0f b7 05 28 d2 1d f0 	movzwl 0xf01dd228,%eax
f0100499:	66 85 c0             	test   %ax,%ax
f010049c:	0f 84 e6 00 00 00    	je     f0100588 <cons_putc+0x1b3>
			crt_pos--;
f01004a2:	83 e8 01             	sub    $0x1,%eax
f01004a5:	66 a3 28 d2 1d f0    	mov    %ax,0xf01dd228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004ab:	0f b7 c0             	movzwl %ax,%eax
f01004ae:	66 81 e7 00 ff       	and    $0xff00,%di
f01004b3:	83 cf 20             	or     $0x20,%edi
f01004b6:	8b 15 2c d2 1d f0    	mov    0xf01dd22c,%edx
f01004bc:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004c0:	eb 78                	jmp    f010053a <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004c2:	66 83 05 28 d2 1d f0 	addw   $0x50,0xf01dd228
f01004c9:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004ca:	0f b7 05 28 d2 1d f0 	movzwl 0xf01dd228,%eax
f01004d1:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004d7:	c1 e8 16             	shr    $0x16,%eax
f01004da:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004dd:	c1 e0 04             	shl    $0x4,%eax
f01004e0:	66 a3 28 d2 1d f0    	mov    %ax,0xf01dd228
f01004e6:	eb 52                	jmp    f010053a <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004e8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ed:	e8 e3 fe ff ff       	call   f01003d5 <cons_putc>
		cons_putc(' ');
f01004f2:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f7:	e8 d9 fe ff ff       	call   f01003d5 <cons_putc>
		cons_putc(' ');
f01004fc:	b8 20 00 00 00       	mov    $0x20,%eax
f0100501:	e8 cf fe ff ff       	call   f01003d5 <cons_putc>
		cons_putc(' ');
f0100506:	b8 20 00 00 00       	mov    $0x20,%eax
f010050b:	e8 c5 fe ff ff       	call   f01003d5 <cons_putc>
		cons_putc(' ');
f0100510:	b8 20 00 00 00       	mov    $0x20,%eax
f0100515:	e8 bb fe ff ff       	call   f01003d5 <cons_putc>
f010051a:	eb 1e                	jmp    f010053a <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010051c:	0f b7 05 28 d2 1d f0 	movzwl 0xf01dd228,%eax
f0100523:	8d 50 01             	lea    0x1(%eax),%edx
f0100526:	66 89 15 28 d2 1d f0 	mov    %dx,0xf01dd228
f010052d:	0f b7 c0             	movzwl %ax,%eax
f0100530:	8b 15 2c d2 1d f0    	mov    0xf01dd22c,%edx
f0100536:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010053a:	66 81 3d 28 d2 1d f0 	cmpw   $0x7cf,0xf01dd228
f0100541:	cf 07 
f0100543:	76 43                	jbe    f0100588 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100545:	a1 2c d2 1d f0       	mov    0xf01dd22c,%eax
f010054a:	83 ec 04             	sub    $0x4,%esp
f010054d:	68 00 0f 00 00       	push   $0xf00
f0100552:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100558:	52                   	push   %edx
f0100559:	50                   	push   %eax
f010055a:	e8 20 4f 00 00       	call   f010547f <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010055f:	8b 15 2c d2 1d f0    	mov    0xf01dd22c,%edx
f0100565:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010056b:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100571:	83 c4 10             	add    $0x10,%esp
f0100574:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100579:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010057c:	39 d0                	cmp    %edx,%eax
f010057e:	75 f4                	jne    f0100574 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100580:	66 83 2d 28 d2 1d f0 	subw   $0x50,0xf01dd228
f0100587:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100588:	8b 0d 30 d2 1d f0    	mov    0xf01dd230,%ecx
f010058e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100593:	89 ca                	mov    %ecx,%edx
f0100595:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100596:	0f b7 1d 28 d2 1d f0 	movzwl 0xf01dd228,%ebx
f010059d:	8d 71 01             	lea    0x1(%ecx),%esi
f01005a0:	89 d8                	mov    %ebx,%eax
f01005a2:	66 c1 e8 08          	shr    $0x8,%ax
f01005a6:	89 f2                	mov    %esi,%edx
f01005a8:	ee                   	out    %al,(%dx)
f01005a9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005ae:	89 ca                	mov    %ecx,%edx
f01005b0:	ee                   	out    %al,(%dx)
f01005b1:	89 d8                	mov    %ebx,%eax
f01005b3:	89 f2                	mov    %esi,%edx
f01005b5:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005b9:	5b                   	pop    %ebx
f01005ba:	5e                   	pop    %esi
f01005bb:	5f                   	pop    %edi
f01005bc:	5d                   	pop    %ebp
f01005bd:	c3                   	ret    

f01005be <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005be:	80 3d 34 d2 1d f0 00 	cmpb   $0x0,0xf01dd234
f01005c5:	74 11                	je     f01005d8 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005c7:	55                   	push   %ebp
f01005c8:	89 e5                	mov    %esp,%ebp
f01005ca:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005cd:	b8 68 02 10 f0       	mov    $0xf0100268,%eax
f01005d2:	e8 b0 fc ff ff       	call   f0100287 <cons_intr>
}
f01005d7:	c9                   	leave  
f01005d8:	f3 c3                	repz ret 

f01005da <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005da:	55                   	push   %ebp
f01005db:	89 e5                	mov    %esp,%ebp
f01005dd:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005e0:	b8 ca 02 10 f0       	mov    $0xf01002ca,%eax
f01005e5:	e8 9d fc ff ff       	call   f0100287 <cons_intr>
}
f01005ea:	c9                   	leave  
f01005eb:	c3                   	ret    

f01005ec <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005ec:	55                   	push   %ebp
f01005ed:	89 e5                	mov    %esp,%ebp
f01005ef:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005f2:	e8 c7 ff ff ff       	call   f01005be <serial_intr>
	kbd_intr();
f01005f7:	e8 de ff ff ff       	call   f01005da <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005fc:	a1 20 d2 1d f0       	mov    0xf01dd220,%eax
f0100601:	3b 05 24 d2 1d f0    	cmp    0xf01dd224,%eax
f0100607:	74 26                	je     f010062f <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100609:	8d 50 01             	lea    0x1(%eax),%edx
f010060c:	89 15 20 d2 1d f0    	mov    %edx,0xf01dd220
f0100612:	0f b6 88 20 d0 1d f0 	movzbl -0xfe22fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100619:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010061b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100621:	75 11                	jne    f0100634 <cons_getc+0x48>
			cons.rpos = 0;
f0100623:	c7 05 20 d2 1d f0 00 	movl   $0x0,0xf01dd220
f010062a:	00 00 00 
f010062d:	eb 05                	jmp    f0100634 <cons_getc+0x48>
		return c;
	}
	return 0;
f010062f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100634:	c9                   	leave  
f0100635:	c3                   	ret    

f0100636 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100636:	55                   	push   %ebp
f0100637:	89 e5                	mov    %esp,%ebp
f0100639:	57                   	push   %edi
f010063a:	56                   	push   %esi
f010063b:	53                   	push   %ebx
f010063c:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010063f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100646:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010064d:	5a a5 
	if (*cp != 0xA55A) {
f010064f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100656:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010065a:	74 11                	je     f010066d <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010065c:	c7 05 30 d2 1d f0 b4 	movl   $0x3b4,0xf01dd230
f0100663:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100666:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010066b:	eb 16                	jmp    f0100683 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010066d:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100674:	c7 05 30 d2 1d f0 d4 	movl   $0x3d4,0xf01dd230
f010067b:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010067e:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100683:	8b 3d 30 d2 1d f0    	mov    0xf01dd230,%edi
f0100689:	b8 0e 00 00 00       	mov    $0xe,%eax
f010068e:	89 fa                	mov    %edi,%edx
f0100690:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100691:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100694:	89 da                	mov    %ebx,%edx
f0100696:	ec                   	in     (%dx),%al
f0100697:	0f b6 c8             	movzbl %al,%ecx
f010069a:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010069d:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006a2:	89 fa                	mov    %edi,%edx
f01006a4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a5:	89 da                	mov    %ebx,%edx
f01006a7:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006a8:	89 35 2c d2 1d f0    	mov    %esi,0xf01dd22c
	crt_pos = pos;
f01006ae:	0f b6 c0             	movzbl %al,%eax
f01006b1:	09 c8                	or     %ecx,%eax
f01006b3:	66 a3 28 d2 1d f0    	mov    %ax,0xf01dd228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006b9:	e8 1c ff ff ff       	call   f01005da <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006be:	83 ec 0c             	sub    $0xc,%esp
f01006c1:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006c8:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006cd:	50                   	push   %eax
f01006ce:	e8 58 2e 00 00       	call   f010352b <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d3:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006d8:	b8 00 00 00 00       	mov    $0x0,%eax
f01006dd:	89 f2                	mov    %esi,%edx
f01006df:	ee                   	out    %al,(%dx)
f01006e0:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006e5:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006ea:	ee                   	out    %al,(%dx)
f01006eb:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006f0:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006f5:	89 da                	mov    %ebx,%edx
f01006f7:	ee                   	out    %al,(%dx)
f01006f8:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01006fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100702:	ee                   	out    %al,(%dx)
f0100703:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100708:	b8 03 00 00 00       	mov    $0x3,%eax
f010070d:	ee                   	out    %al,(%dx)
f010070e:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100713:	b8 00 00 00 00       	mov    $0x0,%eax
f0100718:	ee                   	out    %al,(%dx)
f0100719:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010071e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100723:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100724:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100729:	ec                   	in     (%dx),%al
f010072a:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010072c:	83 c4 10             	add    $0x10,%esp
f010072f:	3c ff                	cmp    $0xff,%al
f0100731:	0f 95 05 34 d2 1d f0 	setne  0xf01dd234
f0100738:	89 f2                	mov    %esi,%edx
f010073a:	ec                   	in     (%dx),%al
f010073b:	89 da                	mov    %ebx,%edx
f010073d:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f010073e:	80 f9 ff             	cmp    $0xff,%cl
f0100741:	74 21                	je     f0100764 <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f0100743:	83 ec 0c             	sub    $0xc,%esp
f0100746:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010074d:	25 ef ff 00 00       	and    $0xffef,%eax
f0100752:	50                   	push   %eax
f0100753:	e8 d3 2d 00 00       	call   f010352b <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100758:	83 c4 10             	add    $0x10,%esp
f010075b:	80 3d 34 d2 1d f0 00 	cmpb   $0x0,0xf01dd234
f0100762:	75 10                	jne    f0100774 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100764:	83 ec 0c             	sub    $0xc,%esp
f0100767:	68 af 61 10 f0       	push   $0xf01061af
f010076c:	e8 0b 2f 00 00       	call   f010367c <cprintf>
f0100771:	83 c4 10             	add    $0x10,%esp
}
f0100774:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100777:	5b                   	pop    %ebx
f0100778:	5e                   	pop    %esi
f0100779:	5f                   	pop    %edi
f010077a:	5d                   	pop    %ebp
f010077b:	c3                   	ret    

f010077c <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010077c:	55                   	push   %ebp
f010077d:	89 e5                	mov    %esp,%ebp
f010077f:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100782:	8b 45 08             	mov    0x8(%ebp),%eax
f0100785:	e8 4b fc ff ff       	call   f01003d5 <cons_putc>
}
f010078a:	c9                   	leave  
f010078b:	c3                   	ret    

f010078c <getchar>:

int
getchar(void)
{
f010078c:	55                   	push   %ebp
f010078d:	89 e5                	mov    %esp,%ebp
f010078f:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100792:	e8 55 fe ff ff       	call   f01005ec <cons_getc>
f0100797:	85 c0                	test   %eax,%eax
f0100799:	74 f7                	je     f0100792 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010079b:	c9                   	leave  
f010079c:	c3                   	ret    

f010079d <iscons>:

int
iscons(int fdnum)
{
f010079d:	55                   	push   %ebp
f010079e:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007a0:	b8 01 00 00 00       	mov    $0x1,%eax
f01007a5:	5d                   	pop    %ebp
f01007a6:	c3                   	ret    

f01007a7 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007a7:	55                   	push   %ebp
f01007a8:	89 e5                	mov    %esp,%ebp
f01007aa:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007ad:	68 00 64 10 f0       	push   $0xf0106400
f01007b2:	68 1e 64 10 f0       	push   $0xf010641e
f01007b7:	68 23 64 10 f0       	push   $0xf0106423
f01007bc:	e8 bb 2e 00 00       	call   f010367c <cprintf>
f01007c1:	83 c4 0c             	add    $0xc,%esp
f01007c4:	68 d0 64 10 f0       	push   $0xf01064d0
f01007c9:	68 2c 64 10 f0       	push   $0xf010642c
f01007ce:	68 23 64 10 f0       	push   $0xf0106423
f01007d3:	e8 a4 2e 00 00       	call   f010367c <cprintf>
f01007d8:	83 c4 0c             	add    $0xc,%esp
f01007db:	68 35 64 10 f0       	push   $0xf0106435
f01007e0:	68 43 64 10 f0       	push   $0xf0106443
f01007e5:	68 23 64 10 f0       	push   $0xf0106423
f01007ea:	e8 8d 2e 00 00       	call   f010367c <cprintf>
	return 0;
}
f01007ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f4:	c9                   	leave  
f01007f5:	c3                   	ret    

f01007f6 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007f6:	55                   	push   %ebp
f01007f7:	89 e5                	mov    %esp,%ebp
f01007f9:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007fc:	68 4d 64 10 f0       	push   $0xf010644d
f0100801:	e8 76 2e 00 00       	call   f010367c <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100806:	83 c4 08             	add    $0x8,%esp
f0100809:	68 0c 00 10 00       	push   $0x10000c
f010080e:	68 f8 64 10 f0       	push   $0xf01064f8
f0100813:	e8 64 2e 00 00       	call   f010367c <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100818:	83 c4 0c             	add    $0xc,%esp
f010081b:	68 0c 00 10 00       	push   $0x10000c
f0100820:	68 0c 00 10 f0       	push   $0xf010000c
f0100825:	68 20 65 10 f0       	push   $0xf0106520
f010082a:	e8 4d 2e 00 00       	call   f010367c <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010082f:	83 c4 0c             	add    $0xc,%esp
f0100832:	68 d1 60 10 00       	push   $0x1060d1
f0100837:	68 d1 60 10 f0       	push   $0xf01060d1
f010083c:	68 44 65 10 f0       	push   $0xf0106544
f0100841:	e8 36 2e 00 00       	call   f010367c <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100846:	83 c4 0c             	add    $0xc,%esp
f0100849:	68 2c c2 1d 00       	push   $0x1dc22c
f010084e:	68 2c c2 1d f0       	push   $0xf01dc22c
f0100853:	68 68 65 10 f0       	push   $0xf0106568
f0100858:	e8 1f 2e 00 00       	call   f010367c <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010085d:	83 c4 0c             	add    $0xc,%esp
f0100860:	68 08 f0 21 00       	push   $0x21f008
f0100865:	68 08 f0 21 f0       	push   $0xf021f008
f010086a:	68 8c 65 10 f0       	push   $0xf010658c
f010086f:	e8 08 2e 00 00       	call   f010367c <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100874:	b8 07 f4 21 f0       	mov    $0xf021f407,%eax
f0100879:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010087e:	83 c4 08             	add    $0x8,%esp
f0100881:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100886:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010088c:	85 c0                	test   %eax,%eax
f010088e:	0f 48 c2             	cmovs  %edx,%eax
f0100891:	c1 f8 0a             	sar    $0xa,%eax
f0100894:	50                   	push   %eax
f0100895:	68 b0 65 10 f0       	push   $0xf01065b0
f010089a:	e8 dd 2d 00 00       	call   f010367c <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010089f:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a4:	c9                   	leave  
f01008a5:	c3                   	ret    

f01008a6 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008a6:	55                   	push   %ebp
f01008a7:	89 e5                	mov    %esp,%ebp
f01008a9:	56                   	push   %esi
f01008aa:	53                   	push   %ebx
f01008ab:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ae:	89 eb                	mov    %ebp,%ebx
	
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
f01008b0:	68 66 64 10 f0       	push   $0xf0106466
f01008b5:	e8 c2 2d 00 00       	call   f010367c <cprintf>
	
	while (ebp) {
f01008ba:	83 c4 10             	add    $0x10,%esp
                  *(ebp+3),
                  *(ebp+4),
                  *(ebp+5),
                  *(ebp+6));
                  
	     debuginfo_eip((*(ebp+1)),&info);
f01008bd:	8d 75 e0             	lea    -0x20(%ebp),%esi
	
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
	
	while (ebp) {
f01008c0:	eb 4e                	jmp    f0100910 <mon_backtrace+0x6a>
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",ebp,*(ebp+1),
f01008c2:	ff 73 18             	pushl  0x18(%ebx)
f01008c5:	ff 73 14             	pushl  0x14(%ebx)
f01008c8:	ff 73 10             	pushl  0x10(%ebx)
f01008cb:	ff 73 0c             	pushl  0xc(%ebx)
f01008ce:	ff 73 08             	pushl  0x8(%ebx)
f01008d1:	ff 73 04             	pushl  0x4(%ebx)
f01008d4:	53                   	push   %ebx
f01008d5:	68 dc 65 10 f0       	push   $0xf01065dc
f01008da:	e8 9d 2d 00 00       	call   f010367c <cprintf>
                  *(ebp+3),
                  *(ebp+4),
                  *(ebp+5),
                  *(ebp+6));
                  
	     debuginfo_eip((*(ebp+1)),&info);
f01008df:	83 c4 18             	add    $0x18,%esp
f01008e2:	56                   	push   %esi
f01008e3:	ff 73 04             	pushl  0x4(%ebx)
f01008e6:	e8 cd 40 00 00       	call   f01049b8 <debuginfo_eip>
	     cprintf("         %s:%d: %.*s+%d\n", 
f01008eb:	83 c4 08             	add    $0x8,%esp
f01008ee:	8b 43 04             	mov    0x4(%ebx),%eax
f01008f1:	2b 45 f0             	sub    -0x10(%ebp),%eax
f01008f4:	50                   	push   %eax
f01008f5:	ff 75 e8             	pushl  -0x18(%ebp)
f01008f8:	ff 75 ec             	pushl  -0x14(%ebp)
f01008fb:	ff 75 e4             	pushl  -0x1c(%ebp)
f01008fe:	ff 75 e0             	pushl  -0x20(%ebp)
f0100901:	68 78 64 10 f0       	push   $0xf0106478
f0100906:	e8 71 2d 00 00       	call   f010367c <cprintf>
	     info.eip_file, info.eip_line,
	     info.eip_fn_namelen, info.eip_fn_name, (*(ebp+1)) - info.eip_fn_addr);

	     ebp = (uint32_t *)*(ebp);
f010090b:	8b 1b                	mov    (%ebx),%ebx
f010090d:	83 c4 20             	add    $0x20,%esp
	
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
	
	while (ebp) {
f0100910:	85 db                	test   %ebx,%ebx
f0100912:	75 ae                	jne    f01008c2 <mon_backtrace+0x1c>
	     ebp = (uint32_t *)*(ebp);
    }

	
	return 0;
}
f0100914:	b8 00 00 00 00       	mov    $0x0,%eax
f0100919:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010091c:	5b                   	pop    %ebx
f010091d:	5e                   	pop    %esi
f010091e:	5d                   	pop    %ebp
f010091f:	c3                   	ret    

f0100920 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100920:	55                   	push   %ebp
f0100921:	89 e5                	mov    %esp,%ebp
f0100923:	57                   	push   %edi
f0100924:	56                   	push   %esi
f0100925:	53                   	push   %ebx
f0100926:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100929:	68 10 66 10 f0       	push   $0xf0106610
f010092e:	e8 49 2d 00 00       	call   f010367c <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100933:	c7 04 24 34 66 10 f0 	movl   $0xf0106634,(%esp)
f010093a:	e8 3d 2d 00 00       	call   f010367c <cprintf>

	if (tf != NULL)
f010093f:	83 c4 10             	add    $0x10,%esp
f0100942:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100946:	74 0e                	je     f0100956 <monitor+0x36>
		print_trapframe(tf);
f0100948:	83 ec 0c             	sub    $0xc,%esp
f010094b:	ff 75 08             	pushl  0x8(%ebp)
f010094e:	e8 db 32 00 00       	call   f0103c2e <print_trapframe>
f0100953:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100956:	83 ec 0c             	sub    $0xc,%esp
f0100959:	68 91 64 10 f0       	push   $0xf0106491
f010095e:	e8 60 48 00 00       	call   f01051c3 <readline>
f0100963:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100965:	83 c4 10             	add    $0x10,%esp
f0100968:	85 c0                	test   %eax,%eax
f010096a:	74 ea                	je     f0100956 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010096c:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100973:	be 00 00 00 00       	mov    $0x0,%esi
f0100978:	eb 0a                	jmp    f0100984 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010097a:	c6 03 00             	movb   $0x0,(%ebx)
f010097d:	89 f7                	mov    %esi,%edi
f010097f:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100982:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100984:	0f b6 03             	movzbl (%ebx),%eax
f0100987:	84 c0                	test   %al,%al
f0100989:	74 63                	je     f01009ee <monitor+0xce>
f010098b:	83 ec 08             	sub    $0x8,%esp
f010098e:	0f be c0             	movsbl %al,%eax
f0100991:	50                   	push   %eax
f0100992:	68 95 64 10 f0       	push   $0xf0106495
f0100997:	e8 59 4a 00 00       	call   f01053f5 <strchr>
f010099c:	83 c4 10             	add    $0x10,%esp
f010099f:	85 c0                	test   %eax,%eax
f01009a1:	75 d7                	jne    f010097a <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009a3:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009a6:	74 46                	je     f01009ee <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009a8:	83 fe 0f             	cmp    $0xf,%esi
f01009ab:	75 14                	jne    f01009c1 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009ad:	83 ec 08             	sub    $0x8,%esp
f01009b0:	6a 10                	push   $0x10
f01009b2:	68 9a 64 10 f0       	push   $0xf010649a
f01009b7:	e8 c0 2c 00 00       	call   f010367c <cprintf>
f01009bc:	83 c4 10             	add    $0x10,%esp
f01009bf:	eb 95                	jmp    f0100956 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01009c1:	8d 7e 01             	lea    0x1(%esi),%edi
f01009c4:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009c8:	eb 03                	jmp    f01009cd <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01009ca:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009cd:	0f b6 03             	movzbl (%ebx),%eax
f01009d0:	84 c0                	test   %al,%al
f01009d2:	74 ae                	je     f0100982 <monitor+0x62>
f01009d4:	83 ec 08             	sub    $0x8,%esp
f01009d7:	0f be c0             	movsbl %al,%eax
f01009da:	50                   	push   %eax
f01009db:	68 95 64 10 f0       	push   $0xf0106495
f01009e0:	e8 10 4a 00 00       	call   f01053f5 <strchr>
f01009e5:	83 c4 10             	add    $0x10,%esp
f01009e8:	85 c0                	test   %eax,%eax
f01009ea:	74 de                	je     f01009ca <monitor+0xaa>
f01009ec:	eb 94                	jmp    f0100982 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f01009ee:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009f5:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009f6:	85 f6                	test   %esi,%esi
f01009f8:	0f 84 58 ff ff ff    	je     f0100956 <monitor+0x36>
f01009fe:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a03:	83 ec 08             	sub    $0x8,%esp
f0100a06:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a09:	ff 34 85 60 66 10 f0 	pushl  -0xfef99a0(,%eax,4)
f0100a10:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a13:	e8 7f 49 00 00       	call   f0105397 <strcmp>
f0100a18:	83 c4 10             	add    $0x10,%esp
f0100a1b:	85 c0                	test   %eax,%eax
f0100a1d:	75 21                	jne    f0100a40 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100a1f:	83 ec 04             	sub    $0x4,%esp
f0100a22:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a25:	ff 75 08             	pushl  0x8(%ebp)
f0100a28:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a2b:	52                   	push   %edx
f0100a2c:	56                   	push   %esi
f0100a2d:	ff 14 85 68 66 10 f0 	call   *-0xfef9998(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a34:	83 c4 10             	add    $0x10,%esp
f0100a37:	85 c0                	test   %eax,%eax
f0100a39:	78 25                	js     f0100a60 <monitor+0x140>
f0100a3b:	e9 16 ff ff ff       	jmp    f0100956 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a40:	83 c3 01             	add    $0x1,%ebx
f0100a43:	83 fb 03             	cmp    $0x3,%ebx
f0100a46:	75 bb                	jne    f0100a03 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a48:	83 ec 08             	sub    $0x8,%esp
f0100a4b:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a4e:	68 b7 64 10 f0       	push   $0xf01064b7
f0100a53:	e8 24 2c 00 00       	call   f010367c <cprintf>
f0100a58:	83 c4 10             	add    $0x10,%esp
f0100a5b:	e9 f6 fe ff ff       	jmp    f0100956 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a60:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a63:	5b                   	pop    %ebx
f0100a64:	5e                   	pop    %esi
f0100a65:	5f                   	pop    %edi
f0100a66:	5d                   	pop    %ebp
f0100a67:	c3                   	ret    

f0100a68 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a68:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a6a:	83 3d 38 d2 1d f0 00 	cmpl   $0x0,0xf01dd238
f0100a71:	75 0f                	jne    f0100a82 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a73:	b8 07 00 22 f0       	mov    $0xf0220007,%eax
f0100a78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a7d:	a3 38 d2 1d f0       	mov    %eax,0xf01dd238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n > 0){
f0100a82:	85 d2                	test   %edx,%edx
f0100a84:	74 42                	je     f0100ac8 <boot_alloc+0x60>
		//cprintf("\nNextfree before allocation %x\n", nextfree);
		result = nextfree;
f0100a86:	a1 38 d2 1d f0       	mov    0xf01dd238,%eax
		nextfree = nextfree + n;

		//cprintf("Nextfree after allocation %x\n", nextfree);
		//cprintf ("Bytes to be allocated %u\n", ((nextfree - result)/8));
		 
		nextfree = ROUNDUP((char *)nextfree , PGSIZE);
f0100a8b:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100a92:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a98:	89 15 38 d2 1d f0    	mov    %edx,0xf01dd238
		
		
		//cprintf ("Nextfree after rounding up to page size %x\n", nextfree);
		//cprintf ("Bytes allocated %u\n", ((nextfree - result)/8));
		//cprintf ("Check%x\n ",((uint32_t)nextfree - KERNBASE));
		if (((uint32_t)nextfree - KERNBASE) > (npages * PGSIZE)){
f0100a9e:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100aa4:	8b 0d 88 de 1d f0    	mov    0xf01dde88,%ecx
f0100aaa:	c1 e1 0c             	shl    $0xc,%ecx
f0100aad:	39 ca                	cmp    %ecx,%edx
f0100aaf:	76 1c                	jbe    f0100acd <boot_alloc+0x65>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ab1:	55                   	push   %ebp
f0100ab2:	89 e5                	mov    %esp,%ebp
f0100ab4:	83 ec 0c             	sub    $0xc,%esp
		
		//cprintf ("Nextfree after rounding up to page size %x\n", nextfree);
		//cprintf ("Bytes allocated %u\n", ((nextfree - result)/8));
		//cprintf ("Check%x\n ",((uint32_t)nextfree - KERNBASE));
		if (((uint32_t)nextfree - KERNBASE) > (npages * PGSIZE)){
			panic("boot_alloc panicked: Out of Memory\n");
f0100ab7:	68 84 66 10 f0       	push   $0xf0106684
f0100abc:	6a 7b                	push   $0x7b
f0100abe:	68 1d 70 10 f0       	push   $0xf010701d
f0100ac3:	e8 78 f5 ff ff       	call   f0100040 <_panic>
					
		}	
	}

	else{
		result = nextfree;
f0100ac8:	a1 38 d2 1d f0       	mov    0xf01dd238,%eax
	} 

	return result;
}
f0100acd:	f3 c3                	repz ret 

f0100acf <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100acf:	89 d1                	mov    %edx,%ecx
f0100ad1:	c1 e9 16             	shr    $0x16,%ecx
f0100ad4:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ad7:	a8 01                	test   $0x1,%al
f0100ad9:	74 52                	je     f0100b2d <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100adb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ae0:	89 c1                	mov    %eax,%ecx
f0100ae2:	c1 e9 0c             	shr    $0xc,%ecx
f0100ae5:	3b 0d 88 de 1d f0    	cmp    0xf01dde88,%ecx
f0100aeb:	72 1b                	jb     f0100b08 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100aed:	55                   	push   %ebp
f0100aee:	89 e5                	mov    %esp,%ebp
f0100af0:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100af3:	50                   	push   %eax
f0100af4:	68 04 61 10 f0       	push   $0xf0106104
f0100af9:	68 c0 03 00 00       	push   $0x3c0
f0100afe:	68 1d 70 10 f0       	push   $0xf010701d
f0100b03:	e8 38 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b08:	c1 ea 0c             	shr    $0xc,%edx
f0100b0b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b11:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b18:	89 c2                	mov    %eax,%edx
f0100b1a:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b1d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b22:	85 d2                	test   %edx,%edx
f0100b24:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b29:	0f 44 c2             	cmove  %edx,%eax
f0100b2c:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b32:	c3                   	ret    

f0100b33 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b33:	55                   	push   %ebp
f0100b34:	89 e5                	mov    %esp,%ebp
f0100b36:	57                   	push   %edi
f0100b37:	56                   	push   %esi
f0100b38:	53                   	push   %ebx
f0100b39:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b3c:	84 c0                	test   %al,%al
f0100b3e:	0f 85 91 02 00 00    	jne    f0100dd5 <check_page_free_list+0x2a2>
f0100b44:	e9 9e 02 00 00       	jmp    f0100de7 <check_page_free_list+0x2b4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b49:	83 ec 04             	sub    $0x4,%esp
f0100b4c:	68 a8 66 10 f0       	push   $0xf01066a8
f0100b51:	68 f5 02 00 00       	push   $0x2f5
f0100b56:	68 1d 70 10 f0       	push   $0xf010701d
f0100b5b:	e8 e0 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b60:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b63:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b66:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b6c:	89 c2                	mov    %eax,%edx
f0100b6e:	2b 15 90 de 1d f0    	sub    0xf01dde90,%edx
f0100b74:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b7a:	0f 95 c2             	setne  %dl
f0100b7d:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b80:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b84:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b86:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b8a:	8b 00                	mov    (%eax),%eax
f0100b8c:	85 c0                	test   %eax,%eax
f0100b8e:	75 dc                	jne    f0100b6c <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b93:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b99:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b9c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b9f:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ba1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ba4:	a3 40 d2 1d f0       	mov    %eax,0xf01dd240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ba9:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bae:	8b 1d 40 d2 1d f0    	mov    0xf01dd240,%ebx
f0100bb4:	eb 53                	jmp    f0100c09 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bb6:	89 d8                	mov    %ebx,%eax
f0100bb8:	2b 05 90 de 1d f0    	sub    0xf01dde90,%eax
f0100bbe:	c1 f8 03             	sar    $0x3,%eax
f0100bc1:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bc4:	89 c2                	mov    %eax,%edx
f0100bc6:	c1 ea 16             	shr    $0x16,%edx
f0100bc9:	39 f2                	cmp    %esi,%edx
f0100bcb:	73 3a                	jae    f0100c07 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bcd:	89 c2                	mov    %eax,%edx
f0100bcf:	c1 ea 0c             	shr    $0xc,%edx
f0100bd2:	3b 15 88 de 1d f0    	cmp    0xf01dde88,%edx
f0100bd8:	72 12                	jb     f0100bec <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bda:	50                   	push   %eax
f0100bdb:	68 04 61 10 f0       	push   $0xf0106104
f0100be0:	6a 58                	push   $0x58
f0100be2:	68 29 70 10 f0       	push   $0xf0107029
f0100be7:	e8 54 f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100bec:	83 ec 04             	sub    $0x4,%esp
f0100bef:	68 80 00 00 00       	push   $0x80
f0100bf4:	68 97 00 00 00       	push   $0x97
f0100bf9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bfe:	50                   	push   %eax
f0100bff:	e8 2e 48 00 00       	call   f0105432 <memset>
f0100c04:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c07:	8b 1b                	mov    (%ebx),%ebx
f0100c09:	85 db                	test   %ebx,%ebx
f0100c0b:	75 a9                	jne    f0100bb6 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c0d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c12:	e8 51 fe ff ff       	call   f0100a68 <boot_alloc>
f0100c17:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c1a:	8b 15 40 d2 1d f0    	mov    0xf01dd240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c20:	8b 0d 90 de 1d f0    	mov    0xf01dde90,%ecx
		assert(pp < pages + npages);
f0100c26:	a1 88 de 1d f0       	mov    0xf01dde88,%eax
f0100c2b:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c2e:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c31:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c34:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c37:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c3c:	e9 52 01 00 00       	jmp    f0100d93 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c41:	39 ca                	cmp    %ecx,%edx
f0100c43:	73 19                	jae    f0100c5e <check_page_free_list+0x12b>
f0100c45:	68 37 70 10 f0       	push   $0xf0107037
f0100c4a:	68 43 70 10 f0       	push   $0xf0107043
f0100c4f:	68 0f 03 00 00       	push   $0x30f
f0100c54:	68 1d 70 10 f0       	push   $0xf010701d
f0100c59:	e8 e2 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c5e:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c61:	72 19                	jb     f0100c7c <check_page_free_list+0x149>
f0100c63:	68 58 70 10 f0       	push   $0xf0107058
f0100c68:	68 43 70 10 f0       	push   $0xf0107043
f0100c6d:	68 10 03 00 00       	push   $0x310
f0100c72:	68 1d 70 10 f0       	push   $0xf010701d
f0100c77:	e8 c4 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c7c:	89 d0                	mov    %edx,%eax
f0100c7e:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c81:	a8 07                	test   $0x7,%al
f0100c83:	74 19                	je     f0100c9e <check_page_free_list+0x16b>
f0100c85:	68 cc 66 10 f0       	push   $0xf01066cc
f0100c8a:	68 43 70 10 f0       	push   $0xf0107043
f0100c8f:	68 11 03 00 00       	push   $0x311
f0100c94:	68 1d 70 10 f0       	push   $0xf010701d
f0100c99:	e8 a2 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c9e:	c1 f8 03             	sar    $0x3,%eax
f0100ca1:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100ca4:	85 c0                	test   %eax,%eax
f0100ca6:	75 19                	jne    f0100cc1 <check_page_free_list+0x18e>
f0100ca8:	68 6c 70 10 f0       	push   $0xf010706c
f0100cad:	68 43 70 10 f0       	push   $0xf0107043
f0100cb2:	68 14 03 00 00       	push   $0x314
f0100cb7:	68 1d 70 10 f0       	push   $0xf010701d
f0100cbc:	e8 7f f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cc1:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cc6:	75 19                	jne    f0100ce1 <check_page_free_list+0x1ae>
f0100cc8:	68 7d 70 10 f0       	push   $0xf010707d
f0100ccd:	68 43 70 10 f0       	push   $0xf0107043
f0100cd2:	68 15 03 00 00       	push   $0x315
f0100cd7:	68 1d 70 10 f0       	push   $0xf010701d
f0100cdc:	e8 5f f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ce1:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ce6:	75 19                	jne    f0100d01 <check_page_free_list+0x1ce>
f0100ce8:	68 00 67 10 f0       	push   $0xf0106700
f0100ced:	68 43 70 10 f0       	push   $0xf0107043
f0100cf2:	68 16 03 00 00       	push   $0x316
f0100cf7:	68 1d 70 10 f0       	push   $0xf010701d
f0100cfc:	e8 3f f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d01:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d06:	75 19                	jne    f0100d21 <check_page_free_list+0x1ee>
f0100d08:	68 96 70 10 f0       	push   $0xf0107096
f0100d0d:	68 43 70 10 f0       	push   $0xf0107043
f0100d12:	68 17 03 00 00       	push   $0x317
f0100d17:	68 1d 70 10 f0       	push   $0xf010701d
f0100d1c:	e8 1f f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d21:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d26:	0f 86 de 00 00 00    	jbe    f0100e0a <check_page_free_list+0x2d7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d2c:	89 c7                	mov    %eax,%edi
f0100d2e:	c1 ef 0c             	shr    $0xc,%edi
f0100d31:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d34:	77 12                	ja     f0100d48 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d36:	50                   	push   %eax
f0100d37:	68 04 61 10 f0       	push   $0xf0106104
f0100d3c:	6a 58                	push   $0x58
f0100d3e:	68 29 70 10 f0       	push   $0xf0107029
f0100d43:	e8 f8 f2 ff ff       	call   f0100040 <_panic>
f0100d48:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d4e:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100d51:	0f 86 a7 00 00 00    	jbe    f0100dfe <check_page_free_list+0x2cb>
f0100d57:	68 24 67 10 f0       	push   $0xf0106724
f0100d5c:	68 43 70 10 f0       	push   $0xf0107043
f0100d61:	68 18 03 00 00       	push   $0x318
f0100d66:	68 1d 70 10 f0       	push   $0xf010701d
f0100d6b:	e8 d0 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d70:	68 b0 70 10 f0       	push   $0xf01070b0
f0100d75:	68 43 70 10 f0       	push   $0xf0107043
f0100d7a:	68 1a 03 00 00       	push   $0x31a
f0100d7f:	68 1d 70 10 f0       	push   $0xf010701d
f0100d84:	e8 b7 f2 ff ff       	call   f0100040 <_panic>
		
		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d89:	83 c6 01             	add    $0x1,%esi
f0100d8c:	eb 03                	jmp    f0100d91 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100d8e:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d91:	8b 12                	mov    (%edx),%edx
f0100d93:	85 d2                	test   %edx,%edx
f0100d95:	0f 85 a6 fe ff ff    	jne    f0100c41 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d9b:	85 f6                	test   %esi,%esi
f0100d9d:	7f 19                	jg     f0100db8 <check_page_free_list+0x285>
f0100d9f:	68 cd 70 10 f0       	push   $0xf01070cd
f0100da4:	68 43 70 10 f0       	push   $0xf0107043
f0100da9:	68 22 03 00 00       	push   $0x322
f0100dae:	68 1d 70 10 f0       	push   $0xf010701d
f0100db3:	e8 88 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100db8:	85 db                	test   %ebx,%ebx
f0100dba:	7f 5e                	jg     f0100e1a <check_page_free_list+0x2e7>
f0100dbc:	68 df 70 10 f0       	push   $0xf01070df
f0100dc1:	68 43 70 10 f0       	push   $0xf0107043
f0100dc6:	68 23 03 00 00       	push   $0x323
f0100dcb:	68 1d 70 10 f0       	push   $0xf010701d
f0100dd0:	e8 6b f2 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100dd5:	a1 40 d2 1d f0       	mov    0xf01dd240,%eax
f0100dda:	85 c0                	test   %eax,%eax
f0100ddc:	0f 85 7e fd ff ff    	jne    f0100b60 <check_page_free_list+0x2d>
f0100de2:	e9 62 fd ff ff       	jmp    f0100b49 <check_page_free_list+0x16>
f0100de7:	83 3d 40 d2 1d f0 00 	cmpl   $0x0,0xf01dd240
f0100dee:	0f 84 55 fd ff ff    	je     f0100b49 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100df4:	be 00 04 00 00       	mov    $0x400,%esi
f0100df9:	e9 b0 fd ff ff       	jmp    f0100bae <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100dfe:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e03:	75 89                	jne    f0100d8e <check_page_free_list+0x25b>
f0100e05:	e9 66 ff ff ff       	jmp    f0100d70 <check_page_free_list+0x23d>
f0100e0a:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e0f:	0f 85 74 ff ff ff    	jne    f0100d89 <check_page_free_list+0x256>
f0100e15:	e9 56 ff ff ff       	jmp    f0100d70 <check_page_free_list+0x23d>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e1d:	5b                   	pop    %ebx
f0100e1e:	5e                   	pop    %esi
f0100e1f:	5f                   	pop    %edi
f0100e20:	5d                   	pop    %ebp
f0100e21:	c3                   	ret    

f0100e22 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e22:	55                   	push   %ebp
f0100e23:	89 e5                	mov    %esp,%ebp
f0100e25:	56                   	push   %esi
f0100e26:	53                   	push   %ebx
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	
	 for (i = 0; i < npages; i++) {
f0100e27:	be 00 00 00 00       	mov    $0x0,%esi
f0100e2c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e31:	e9 9b 00 00 00       	jmp    f0100ed1 <page_init+0xaf>
                if(i == 0 || (i >= (IOPHYSMEM/PGSIZE) && i < (EXTPHYSMEM/PGSIZE))) {
f0100e36:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0100e3c:	83 f8 5f             	cmp    $0x5f,%eax
f0100e3f:	76 04                	jbe    f0100e45 <page_init+0x23>
f0100e41:	85 db                	test   %ebx,%ebx
f0100e43:	75 16                	jne    f0100e5b <page_init+0x39>
                        pages[i].pp_ref = (uint16_t) 0;
f0100e45:	89 f0                	mov    %esi,%eax
f0100e47:	03 05 90 de 1d f0    	add    0xf01dde90,%eax
f0100e4d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
                        pages[i].pp_link = NULL;
f0100e53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100e59:	eb 70                	jmp    f0100ecb <page_init+0xa9>
                }else if(i >= (EXTPHYSMEM/PGSIZE) && 
f0100e5b:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100e61:	76 2c                	jbe    f0100e8f <page_init+0x6d>
                         i < (((uint32_t)(boot_alloc(0)-KERNBASE))/PGSIZE)) {
f0100e63:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e68:	e8 fb fb ff ff       	call   f0100a68 <boot_alloc>
	
	 for (i = 0; i < npages; i++) {
                if(i == 0 || (i >= (IOPHYSMEM/PGSIZE) && i < (EXTPHYSMEM/PGSIZE))) {
                        pages[i].pp_ref = (uint16_t) 0;
                        pages[i].pp_link = NULL;
                }else if(i >= (EXTPHYSMEM/PGSIZE) && 
f0100e6d:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e72:	c1 e8 0c             	shr    $0xc,%eax
f0100e75:	39 c3                	cmp    %eax,%ebx
f0100e77:	73 16                	jae    f0100e8f <page_init+0x6d>
                         i < (((uint32_t)(boot_alloc(0)-KERNBASE))/PGSIZE)) {
                        pages[i].pp_ref = (uint16_t) 0;
f0100e79:	89 f0                	mov    %esi,%eax
f0100e7b:	03 05 90 de 1d f0    	add    0xf01dde90,%eax
f0100e81:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
                        pages[i].pp_link = NULL;
f0100e87:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100e8d:	eb 3c                	jmp    f0100ecb <page_init+0xa9>
                }else if(i == (MPENTRY_PADDR/PGSIZE)) {
f0100e8f:	83 fb 07             	cmp    $0x7,%ebx
f0100e92:	75 14                	jne    f0100ea8 <page_init+0x86>
			pages[i].pp_ref = (uint16_t) 0;
f0100e94:	a1 90 de 1d f0       	mov    0xf01dde90,%eax
f0100e99:	66 c7 40 3c 00 00    	movw   $0x0,0x3c(%eax)
                        pages[i].pp_link = NULL;
f0100e9f:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0100ea6:	eb 23                	jmp    f0100ecb <page_init+0xa9>
		}else{
                        pages[i].pp_ref = 0;
f0100ea8:	89 f0                	mov    %esi,%eax
f0100eaa:	03 05 90 de 1d f0    	add    0xf01dde90,%eax
f0100eb0:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
                        pages[i].pp_link = page_free_list;
f0100eb6:	8b 15 40 d2 1d f0    	mov    0xf01dd240,%edx
f0100ebc:	89 10                	mov    %edx,(%eax)
                        page_free_list = &pages[i];
f0100ebe:	89 f0                	mov    %esi,%eax
f0100ec0:	03 05 90 de 1d f0    	add    0xf01dde90,%eax
f0100ec6:	a3 40 d2 1d f0       	mov    %eax,0xf01dd240
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	
	 for (i = 0; i < npages; i++) {
f0100ecb:	83 c3 01             	add    $0x1,%ebx
f0100ece:	83 c6 08             	add    $0x8,%esi
f0100ed1:	3b 1d 88 de 1d f0    	cmp    0xf01dde88,%ebx
f0100ed7:	0f 82 59 ff ff ff    	jb     f0100e36 <page_init+0x14>
                        pages[i].pp_ref = 0;
                        pages[i].pp_link = page_free_list;
                        page_free_list = &pages[i];
                }
        }
} 
f0100edd:	5b                   	pop    %ebx
f0100ede:	5e                   	pop    %esi
f0100edf:	5d                   	pop    %ebp
f0100ee0:	c3                   	ret    

f0100ee1 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100ee1:	55                   	push   %ebp
f0100ee2:	89 e5                	mov    %esp,%ebp
f0100ee4:	53                   	push   %ebx
f0100ee5:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct PageInfo* allocated_page=NULL;
        
        if(page_free_list != NULL) {
f0100ee8:	8b 1d 40 d2 1d f0    	mov    0xf01dd240,%ebx
f0100eee:	85 db                	test   %ebx,%ebx
f0100ef0:	74 58                	je     f0100f4a <page_alloc+0x69>
                allocated_page = page_free_list;
                page_free_list = allocated_page->pp_link;
f0100ef2:	8b 03                	mov    (%ebx),%eax
f0100ef4:	a3 40 d2 1d f0       	mov    %eax,0xf01dd240
                allocated_page->pp_link = NULL;
f0100ef9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
                
                if(alloc_flags & ALLOC_ZERO) {
f0100eff:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f03:	74 45                	je     f0100f4a <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f05:	89 d8                	mov    %ebx,%eax
f0100f07:	2b 05 90 de 1d f0    	sub    0xf01dde90,%eax
f0100f0d:	c1 f8 03             	sar    $0x3,%eax
f0100f10:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f13:	89 c2                	mov    %eax,%edx
f0100f15:	c1 ea 0c             	shr    $0xc,%edx
f0100f18:	3b 15 88 de 1d f0    	cmp    0xf01dde88,%edx
f0100f1e:	72 12                	jb     f0100f32 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f20:	50                   	push   %eax
f0100f21:	68 04 61 10 f0       	push   $0xf0106104
f0100f26:	6a 58                	push   $0x58
f0100f28:	68 29 70 10 f0       	push   $0xf0107029
f0100f2d:	e8 0e f1 ff ff       	call   f0100040 <_panic>
                        memset(page2kva(allocated_page), 0,PGSIZE);
f0100f32:	83 ec 04             	sub    $0x4,%esp
f0100f35:	68 00 10 00 00       	push   $0x1000
f0100f3a:	6a 00                	push   $0x0
f0100f3c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f41:	50                   	push   %eax
f0100f42:	e8 eb 44 00 00       	call   f0105432 <memset>
f0100f47:	83 c4 10             	add    $0x10,%esp
                }
        }
        return allocated_page;
        
}
f0100f4a:	89 d8                	mov    %ebx,%eax
f0100f4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f4f:	c9                   	leave  
f0100f50:	c3                   	ret    

f0100f51 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f51:	55                   	push   %ebp
f0100f52:	89 e5                	mov    %esp,%ebp
f0100f54:	83 ec 08             	sub    $0x8,%esp
f0100f57:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if((pp->pp_link != NULL) || (pp->pp_ref !=0)) {
f0100f5a:	83 38 00             	cmpl   $0x0,(%eax)
f0100f5d:	75 07                	jne    f0100f66 <page_free+0x15>
f0100f5f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f64:	74 17                	je     f0100f7d <page_free+0x2c>
                panic("ref count is not zero or pp_link is not NULL");
f0100f66:	83 ec 04             	sub    $0x4,%esp
f0100f69:	68 6c 67 10 f0       	push   $0xf010676c
f0100f6e:	68 99 01 00 00       	push   $0x199
f0100f73:	68 1d 70 10 f0       	push   $0xf010701d
f0100f78:	e8 c3 f0 ff ff       	call   f0100040 <_panic>
        }
        
        else{


                pp->pp_link = page_free_list;
f0100f7d:	8b 15 40 d2 1d f0    	mov    0xf01dd240,%edx
f0100f83:	89 10                	mov    %edx,(%eax)
                page_free_list = pp;
f0100f85:	a3 40 d2 1d f0       	mov    %eax,0xf01dd240
        }
	
				
}
f0100f8a:	c9                   	leave  
f0100f8b:	c3                   	ret    

f0100f8c <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f8c:	55                   	push   %ebp
f0100f8d:	89 e5                	mov    %esp,%ebp
f0100f8f:	83 ec 08             	sub    $0x8,%esp
f0100f92:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f95:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100f99:	83 e8 01             	sub    $0x1,%eax
f0100f9c:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100fa0:	66 85 c0             	test   %ax,%ax
f0100fa3:	75 0c                	jne    f0100fb1 <page_decref+0x25>
		page_free(pp);
f0100fa5:	83 ec 0c             	sub    $0xc,%esp
f0100fa8:	52                   	push   %edx
f0100fa9:	e8 a3 ff ff ff       	call   f0100f51 <page_free>
f0100fae:	83 c4 10             	add    $0x10,%esp
}
f0100fb1:	c9                   	leave  
f0100fb2:	c3                   	ret    

f0100fb3 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100fb3:	55                   	push   %ebp
f0100fb4:	89 e5                	mov    %esp,%ebp
f0100fb6:	56                   	push   %esi
f0100fb7:	53                   	push   %ebx
f0100fb8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo* new_pg_table;
	pde_t *pdep;
	pte_t *ptep;
	// Fill this function in
	if((pgdir[PDX(va)] & PTE_P) != PTE_P) {
f0100fbb:	89 f3                	mov    %esi,%ebx
f0100fbd:	c1 eb 16             	shr    $0x16,%ebx
f0100fc0:	c1 e3 02             	shl    $0x2,%ebx
f0100fc3:	03 5d 08             	add    0x8(%ebp),%ebx
f0100fc6:	f6 03 01             	testb  $0x1,(%ebx)
f0100fc9:	75 2d                	jne    f0100ff8 <pgdir_walk+0x45>
		if(create == false) {
f0100fcb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100fcf:	74 62                	je     f0101033 <pgdir_walk+0x80>
			return NULL;
		}else{
			new_pg_table = page_alloc(ALLOC_ZERO);
f0100fd1:	83 ec 0c             	sub    $0xc,%esp
f0100fd4:	6a 01                	push   $0x1
f0100fd6:	e8 06 ff ff ff       	call   f0100ee1 <page_alloc>
			if(new_pg_table == NULL) {
f0100fdb:	83 c4 10             	add    $0x10,%esp
f0100fde:	85 c0                	test   %eax,%eax
f0100fe0:	74 58                	je     f010103a <pgdir_walk+0x87>
				return NULL;
			}else{
				new_pg_table->pp_ref += 1;
f0100fe2:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
				pgdir[PDX(va)] = (page2pa(new_pg_table) | PTE_P);
f0100fe7:	2b 05 90 de 1d f0    	sub    0xf01dde90,%eax
f0100fed:	c1 f8 03             	sar    $0x3,%eax
f0100ff0:	c1 e0 0c             	shl    $0xc,%eax
f0100ff3:	83 c8 01             	or     $0x1,%eax
f0100ff6:	89 03                	mov    %eax,(%ebx)
			}
		}
	}
	pdep = (pde_t *)&pgdir[PDX(va)];
	ptep = (pte_t *)KADDR(PTE_ADDR(*pdep));
f0100ff8:	8b 03                	mov    (%ebx),%eax
f0100ffa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fff:	89 c2                	mov    %eax,%edx
f0101001:	c1 ea 0c             	shr    $0xc,%edx
f0101004:	3b 15 88 de 1d f0    	cmp    0xf01dde88,%edx
f010100a:	72 15                	jb     f0101021 <pgdir_walk+0x6e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010100c:	50                   	push   %eax
f010100d:	68 04 61 10 f0       	push   $0xf0106104
f0101012:	68 dc 01 00 00       	push   $0x1dc
f0101017:	68 1d 70 10 f0       	push   $0xf010701d
f010101c:	e8 1f f0 ff ff       	call   f0100040 <_panic>
	return &ptep[PTX(va)];
f0101021:	c1 ee 0a             	shr    $0xa,%esi
f0101024:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010102a:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101031:	eb 0c                	jmp    f010103f <pgdir_walk+0x8c>
	pde_t *pdep;
	pte_t *ptep;
	// Fill this function in
	if((pgdir[PDX(va)] & PTE_P) != PTE_P) {
		if(create == false) {
			return NULL;
f0101033:	b8 00 00 00 00       	mov    $0x0,%eax
f0101038:	eb 05                	jmp    f010103f <pgdir_walk+0x8c>
		}else{
			new_pg_table = page_alloc(ALLOC_ZERO);
			if(new_pg_table == NULL) {
				return NULL;
f010103a:	b8 00 00 00 00       	mov    $0x0,%eax
		}
	}
	pdep = (pde_t *)&pgdir[PDX(va)];
	ptep = (pte_t *)KADDR(PTE_ADDR(*pdep));
	return &ptep[PTX(va)];
}
f010103f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101042:	5b                   	pop    %ebx
f0101043:	5e                   	pop    %esi
f0101044:	5d                   	pop    %ebp
f0101045:	c3                   	ret    

f0101046 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101046:	55                   	push   %ebp
f0101047:	89 e5                	mov    %esp,%ebp
f0101049:	57                   	push   %edi
f010104a:	56                   	push   %esi
f010104b:	53                   	push   %ebx
f010104c:	83 ec 1c             	sub    $0x1c,%esp
f010104f:	89 c3                	mov    %eax,%ebx
f0101051:	89 c8                	mov    %ecx,%eax
f0101053:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	// Fill this function in
	pte_t *ptep;
	if(va+size < va)
f0101056:	01 d0                	add    %edx,%eax
f0101058:	73 4d                	jae    f01010a7 <boot_map_region+0x61>
		panic("boot_map_region: Kernel panicked ");
f010105a:	83 ec 04             	sub    $0x4,%esp
f010105d:	68 9c 67 10 f0       	push   $0xf010679c
f0101062:	68 f1 01 00 00       	push   $0x1f1
f0101067:	68 1d 70 10 f0       	push   $0xf010701d
f010106c:	e8 cf ef ff ff       	call   f0100040 <_panic>
	for(int i=0; i<size; i+=PGSIZE) {
		ptep = pgdir_walk(pgdir,(void*)(va+i),1);
f0101071:	83 ec 04             	sub    $0x4,%esp
f0101074:	6a 01                	push   $0x1
f0101076:	56                   	push   %esi
f0101077:	53                   	push   %ebx
f0101078:	e8 36 ff ff ff       	call   f0100fb3 <pgdir_walk>
		if(ptep != NULL){
f010107d:	83 c4 10             	add    $0x10,%esp
f0101080:	85 c0                	test   %eax,%eax
f0101082:	74 15                	je     f0101099 <boot_map_region+0x53>
			*ptep = ((pa+i) | perm | PTE_P);
f0101084:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101087:	03 55 08             	add    0x8(%ebp),%edx
f010108a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010108d:	09 ca                	or     %ecx,%edx
f010108f:	89 10                	mov    %edx,(%eax)
			pgdir[PDX(va+i)] |= perm | PTE_P;
f0101091:	89 f0                	mov    %esi,%eax
f0101093:	c1 e8 16             	shr    $0x16,%eax
f0101096:	09 0c 83             	or     %ecx,(%ebx,%eax,4)
{
	// Fill this function in
	pte_t *ptep;
	if(va+size < va)
		panic("boot_map_region: Kernel panicked ");
	for(int i=0; i<size; i+=PGSIZE) {
f0101099:	81 c7 00 10 00 00    	add    $0x1000,%edi
f010109f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01010a5:	eb 10                	jmp    f01010b7 <boot_map_region+0x71>
f01010a7:	89 d6                	mov    %edx,%esi
f01010a9:	bf 00 00 00 00       	mov    $0x0,%edi
f01010ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010b1:	83 c8 01             	or     $0x1,%eax
f01010b4:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01010b7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01010ba:	39 7d e0             	cmp    %edi,-0x20(%ebp)
f01010bd:	77 b2                	ja     f0101071 <boot_map_region+0x2b>
		if(ptep != NULL){
			*ptep = ((pa+i) | perm | PTE_P);
			pgdir[PDX(va+i)] |= perm | PTE_P;
		}
	}
}
f01010bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010c2:	5b                   	pop    %ebx
f01010c3:	5e                   	pop    %esi
f01010c4:	5f                   	pop    %edi
f01010c5:	5d                   	pop    %ebp
f01010c6:	c3                   	ret    

f01010c7 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01010c7:	55                   	push   %ebp
f01010c8:	89 e5                	mov    %esp,%ebp
f01010ca:	53                   	push   %ebx
f01010cb:	83 ec 08             	sub    $0x8,%esp
f01010ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *ptep;
	struct PageInfo *pp=NULL;
	ptep = pgdir_walk(pgdir,va,0);
f01010d1:	6a 00                	push   $0x0
f01010d3:	ff 75 0c             	pushl  0xc(%ebp)
f01010d6:	ff 75 08             	pushl  0x8(%ebp)
f01010d9:	e8 d5 fe ff ff       	call   f0100fb3 <pgdir_walk>
	if(ptep == NULL) {
f01010de:	83 c4 10             	add    $0x10,%esp
f01010e1:	85 c0                	test   %eax,%eax
f01010e3:	74 39                	je     f010111e <page_lookup+0x57>
f01010e5:	89 c1                	mov    %eax,%ecx
		return NULL;
	}else if((*ptep & PTE_P) != PTE_P) {
f01010e7:	8b 10                	mov    (%eax),%edx
f01010e9:	f6 c2 01             	test   $0x1,%dl
f01010ec:	74 37                	je     f0101125 <page_lookup+0x5e>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010ee:	c1 ea 0c             	shr    $0xc,%edx
f01010f1:	3b 15 88 de 1d f0    	cmp    0xf01dde88,%edx
f01010f7:	72 14                	jb     f010110d <page_lookup+0x46>
		panic("pa2page called with invalid pa");
f01010f9:	83 ec 04             	sub    $0x4,%esp
f01010fc:	68 c0 67 10 f0       	push   $0xf01067c0
f0101101:	6a 51                	push   $0x51
f0101103:	68 29 70 10 f0       	push   $0xf0107029
f0101108:	e8 33 ef ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010110d:	a1 90 de 1d f0       	mov    0xf01dde90,%eax
f0101112:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		return NULL;
	}else{
		pp = pa2page(PTE_ADDR(*ptep));
		if(*pte_store != 0) {
f0101115:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101118:	74 10                	je     f010112a <page_lookup+0x63>
			*pte_store = ptep; 
f010111a:	89 0b                	mov    %ecx,(%ebx)
f010111c:	eb 0c                	jmp    f010112a <page_lookup+0x63>
	// Fill this function in
	pte_t *ptep;
	struct PageInfo *pp=NULL;
	ptep = pgdir_walk(pgdir,va,0);
	if(ptep == NULL) {
		return NULL;
f010111e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101123:	eb 05                	jmp    f010112a <page_lookup+0x63>
	}else if((*ptep & PTE_P) != PTE_P) {
		return NULL;
f0101125:	b8 00 00 00 00       	mov    $0x0,%eax
		if(*pte_store != 0) {
			*pte_store = ptep; 
		}
	}
	return pp;
}
f010112a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010112d:	c9                   	leave  
f010112e:	c3                   	ret    

f010112f <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010112f:	55                   	push   %ebp
f0101130:	89 e5                	mov    %esp,%ebp
f0101132:	53                   	push   %ebx
f0101133:	83 ec 18             	sub    $0x18,%esp
f0101136:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	//pte_t **ptep_store;
	pte_t *ptep;
	struct PageInfo *pp=NULL;
	pp = page_lookup(pgdir, va, &ptep);
f0101139:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010113c:	50                   	push   %eax
f010113d:	53                   	push   %ebx
f010113e:	ff 75 08             	pushl  0x8(%ebp)
f0101141:	e8 81 ff ff ff       	call   f01010c7 <page_lookup>
	if(pp != NULL) {
f0101146:	83 c4 10             	add    $0x10,%esp
f0101149:	85 c0                	test   %eax,%eax
f010114b:	74 18                	je     f0101165 <page_remove+0x36>
		page_decref(pp);
f010114d:	83 ec 0c             	sub    $0xc,%esp
f0101150:	50                   	push   %eax
f0101151:	e8 36 fe ff ff       	call   f0100f8c <page_decref>
		*ptep = 0x0;
f0101156:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101159:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010115f:	0f 01 3b             	invlpg (%ebx)
f0101162:	83 c4 10             	add    $0x10,%esp
		tlb_invalidate(pgdir,va);	
	}
}
f0101165:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101168:	c9                   	leave  
f0101169:	c3                   	ret    

f010116a <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010116a:	55                   	push   %ebp
f010116b:	89 e5                	mov    %esp,%ebp
f010116d:	57                   	push   %edi
f010116e:	56                   	push   %esi
f010116f:	53                   	push   %ebx
f0101170:	83 ec 10             	sub    $0x10,%esp
f0101173:	8b 75 08             	mov    0x8(%ebp),%esi
f0101176:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *ptep;

	ptep = pgdir_walk(pgdir, va, 1);
f0101179:	6a 01                	push   $0x1
f010117b:	ff 75 10             	pushl  0x10(%ebp)
f010117e:	56                   	push   %esi
f010117f:	e8 2f fe ff ff       	call   f0100fb3 <pgdir_walk>
	if(ptep == NULL) {
f0101184:	83 c4 10             	add    $0x10,%esp
f0101187:	85 c0                	test   %eax,%eax
f0101189:	74 44                	je     f01011cf <page_insert+0x65>
f010118b:	89 c7                	mov    %eax,%edi
		
		return (-E_NO_MEM);
	}
	pp->pp_ref++;
f010118d:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if((*ptep & PTE_P) == PTE_P) {
f0101192:	f6 00 01             	testb  $0x1,(%eax)
f0101195:	74 0f                	je     f01011a6 <page_insert+0x3c>
		page_remove(pgdir,va);
f0101197:	83 ec 08             	sub    $0x8,%esp
f010119a:	ff 75 10             	pushl  0x10(%ebp)
f010119d:	56                   	push   %esi
f010119e:	e8 8c ff ff ff       	call   f010112f <page_remove>
f01011a3:	83 c4 10             	add    $0x10,%esp
	}
	*ptep = (page2pa(pp) | perm | PTE_P);
f01011a6:	2b 1d 90 de 1d f0    	sub    0xf01dde90,%ebx
f01011ac:	c1 fb 03             	sar    $0x3,%ebx
f01011af:	c1 e3 0c             	shl    $0xc,%ebx
f01011b2:	8b 45 14             	mov    0x14(%ebp),%eax
f01011b5:	83 c8 01             	or     $0x1,%eax
f01011b8:	09 c3                	or     %eax,%ebx
f01011ba:	89 1f                	mov    %ebx,(%edi)
	pgdir[PDX(va)] |= perm;
f01011bc:	8b 45 10             	mov    0x10(%ebp),%eax
f01011bf:	c1 e8 16             	shr    $0x16,%eax
f01011c2:	8b 55 14             	mov    0x14(%ebp),%edx
f01011c5:	09 14 86             	or     %edx,(%esi,%eax,4)
	return 0;
f01011c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01011cd:	eb 05                	jmp    f01011d4 <page_insert+0x6a>
	pte_t *ptep;

	ptep = pgdir_walk(pgdir, va, 1);
	if(ptep == NULL) {
		
		return (-E_NO_MEM);
f01011cf:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir,va);
	}
	*ptep = (page2pa(pp) | perm | PTE_P);
	pgdir[PDX(va)] |= perm;
	return 0;
}
f01011d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011d7:	5b                   	pop    %ebx
f01011d8:	5e                   	pop    %esi
f01011d9:	5f                   	pop    %edi
f01011da:	5d                   	pop    %ebp
f01011db:	c3                   	ret    

f01011dc <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01011dc:	55                   	push   %ebp
f01011dd:	89 e5                	mov    %esp,%ebp
f01011df:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011e2:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01011e5:	5d                   	pop    %ebp
f01011e6:	c3                   	ret    

f01011e7 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01011e7:	55                   	push   %ebp
f01011e8:	89 e5                	mov    %esp,%ebp
f01011ea:	53                   	push   %ebx
f01011eb:	83 ec 04             	sub    $0x4,%esp
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
		
	size = ROUNDUP(size,PGSIZE);
f01011ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011f1:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01011f7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(base+size > MMIOLIM)
f01011fd:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f0101203:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0101206:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010120b:	76 17                	jbe    f0101224 <mmio_map_region+0x3d>
	{
		panic("Requested memory cannot be mapped");
f010120d:	83 ec 04             	sub    $0x4,%esp
f0101210:	68 e0 67 10 f0       	push   $0xf01067e0
f0101215:	68 93 02 00 00       	push   $0x293
f010121a:	68 1d 70 10 f0       	push   $0xf010701d
f010121f:	e8 1c ee ff ff       	call   f0100040 <_panic>
	}
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD | PTE_PWT | PTE_W);
f0101224:	83 ec 08             	sub    $0x8,%esp
f0101227:	6a 1a                	push   $0x1a
f0101229:	ff 75 08             	pushl  0x8(%ebp)
f010122c:	89 d9                	mov    %ebx,%ecx
f010122e:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
f0101233:	e8 0e fe ff ff       	call   f0101046 <boot_map_region>
	uintptr_t mapped_base = base;
f0101238:	a1 00 03 12 f0       	mov    0xf0120300,%eax
	base += size;
f010123d:	01 c3                	add    %eax,%ebx
f010123f:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
	return((void *)mapped_base);
}
f0101245:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101248:	c9                   	leave  
f0101249:	c3                   	ret    

f010124a <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010124a:	55                   	push   %ebp
f010124b:	89 e5                	mov    %esp,%ebp
f010124d:	57                   	push   %edi
f010124e:	56                   	push   %esi
f010124f:	53                   	push   %ebx
f0101250:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101253:	6a 15                	push   $0x15
f0101255:	e8 a3 22 00 00       	call   f01034fd <mc146818_read>
f010125a:	89 c3                	mov    %eax,%ebx
f010125c:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101263:	e8 95 22 00 00       	call   f01034fd <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101268:	c1 e0 08             	shl    $0x8,%eax
f010126b:	09 d8                	or     %ebx,%eax
f010126d:	c1 e0 0a             	shl    $0xa,%eax
f0101270:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101276:	85 c0                	test   %eax,%eax
f0101278:	0f 48 c2             	cmovs  %edx,%eax
f010127b:	c1 f8 0c             	sar    $0xc,%eax
f010127e:	a3 44 d2 1d f0       	mov    %eax,0xf01dd244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101283:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f010128a:	e8 6e 22 00 00       	call   f01034fd <mc146818_read>
f010128f:	89 c3                	mov    %eax,%ebx
f0101291:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101298:	e8 60 22 00 00       	call   f01034fd <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010129d:	c1 e0 08             	shl    $0x8,%eax
f01012a0:	09 d8                	or     %ebx,%eax
f01012a2:	c1 e0 0a             	shl    $0xa,%eax
f01012a5:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012ab:	83 c4 10             	add    $0x10,%esp
f01012ae:	85 c0                	test   %eax,%eax
f01012b0:	0f 48 c2             	cmovs  %edx,%eax
f01012b3:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01012b6:	85 c0                	test   %eax,%eax
f01012b8:	74 0e                	je     f01012c8 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01012ba:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01012c0:	89 15 88 de 1d f0    	mov    %edx,0xf01dde88
f01012c6:	eb 0c                	jmp    f01012d4 <mem_init+0x8a>
	else
		npages = npages_basemem;
f01012c8:	8b 15 44 d2 1d f0    	mov    0xf01dd244,%edx
f01012ce:	89 15 88 de 1d f0    	mov    %edx,0xf01dde88
	//cprintf("Amount of physical memory (in pages) %u\n",npages);
	//cprintf("Page Size is %u\n", PGSIZE);
	//cprintf("Amount of base memory (in pages) is %u\n\n", npages_basemem);
	
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012d4:	c1 e0 0c             	shl    $0xc,%eax
f01012d7:	c1 e8 0a             	shr    $0xa,%eax
f01012da:	50                   	push   %eax
f01012db:	a1 44 d2 1d f0       	mov    0xf01dd244,%eax
f01012e0:	c1 e0 0c             	shl    $0xc,%eax
f01012e3:	c1 e8 0a             	shr    $0xa,%eax
f01012e6:	50                   	push   %eax
f01012e7:	a1 88 de 1d f0       	mov    0xf01dde88,%eax
f01012ec:	c1 e0 0c             	shl    $0xc,%eax
f01012ef:	c1 e8 0a             	shr    $0xa,%eax
f01012f2:	50                   	push   %eax
f01012f3:	68 04 68 10 f0       	push   $0xf0106804
f01012f8:	e8 7f 23 00 00       	call   f010367c <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01012fd:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101302:	e8 61 f7 ff ff       	call   f0100a68 <boot_alloc>
f0101307:	a3 8c de 1d f0       	mov    %eax,0xf01dde8c
	memset(kern_pgdir, 0, PGSIZE);
f010130c:	83 c4 0c             	add    $0xc,%esp
f010130f:	68 00 10 00 00       	push   $0x1000
f0101314:	6a 00                	push   $0x0
f0101316:	50                   	push   %eax
f0101317:	e8 16 41 00 00       	call   f0105432 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010131c:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101321:	83 c4 10             	add    $0x10,%esp
f0101324:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101329:	77 15                	ja     f0101340 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010132b:	50                   	push   %eax
f010132c:	68 28 61 10 f0       	push   $0xf0106128
f0101331:	68 a8 00 00 00       	push   $0xa8
f0101336:	68 1d 70 10 f0       	push   $0xf010701d
f010133b:	e8 00 ed ff ff       	call   f0100040 <_panic>
f0101340:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101346:	83 ca 05             	or     $0x5,%edx
f0101349:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	
	pages = boot_alloc (npages * sizeof (struct PageInfo));
f010134f:	a1 88 de 1d f0       	mov    0xf01dde88,%eax
f0101354:	c1 e0 03             	shl    $0x3,%eax
f0101357:	e8 0c f7 ff ff       	call   f0100a68 <boot_alloc>
f010135c:	a3 90 de 1d f0       	mov    %eax,0xf01dde90
	
	memset(pages, 0 , npages * sizeof (struct PageInfo));
f0101361:	83 ec 04             	sub    $0x4,%esp
f0101364:	8b 0d 88 de 1d f0    	mov    0xf01dde88,%ecx
f010136a:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101371:	52                   	push   %edx
f0101372:	6a 00                	push   $0x0
f0101374:	50                   	push   %eax
f0101375:	e8 b8 40 00 00       	call   f0105432 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	
	envs = (struct Env *) boot_alloc(NENV*sizeof(struct Env));
f010137a:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010137f:	e8 e4 f6 ff ff       	call   f0100a68 <boot_alloc>
f0101384:	a3 48 d2 1d f0       	mov    %eax,0xf01dd248
	
	memset(envs, 0, NENV*sizeof(struct Env));
f0101389:	83 c4 0c             	add    $0xc,%esp
f010138c:	68 00 f0 01 00       	push   $0x1f000
f0101391:	6a 00                	push   $0x0
f0101393:	50                   	push   %eax
f0101394:	e8 99 40 00 00       	call   f0105432 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101399:	e8 84 fa ff ff       	call   f0100e22 <page_init>

	check_page_free_list(1);
f010139e:	b8 01 00 00 00       	mov    $0x1,%eax
f01013a3:	e8 8b f7 ff ff       	call   f0100b33 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01013a8:	83 c4 10             	add    $0x10,%esp
f01013ab:	83 3d 90 de 1d f0 00 	cmpl   $0x0,0xf01dde90
f01013b2:	75 17                	jne    f01013cb <mem_init+0x181>
		panic("'pages' is a null pointer!");
f01013b4:	83 ec 04             	sub    $0x4,%esp
f01013b7:	68 f0 70 10 f0       	push   $0xf01070f0
f01013bc:	68 34 03 00 00       	push   $0x334
f01013c1:	68 1d 70 10 f0       	push   $0xf010701d
f01013c6:	e8 75 ec ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013cb:	a1 40 d2 1d f0       	mov    0xf01dd240,%eax
f01013d0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013d5:	eb 05                	jmp    f01013dc <mem_init+0x192>
		++nfree;
f01013d7:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013da:	8b 00                	mov    (%eax),%eax
f01013dc:	85 c0                	test   %eax,%eax
f01013de:	75 f7                	jne    f01013d7 <mem_init+0x18d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01013e0:	83 ec 0c             	sub    $0xc,%esp
f01013e3:	6a 00                	push   $0x0
f01013e5:	e8 f7 fa ff ff       	call   f0100ee1 <page_alloc>
f01013ea:	89 c7                	mov    %eax,%edi
f01013ec:	83 c4 10             	add    $0x10,%esp
f01013ef:	85 c0                	test   %eax,%eax
f01013f1:	75 19                	jne    f010140c <mem_init+0x1c2>
f01013f3:	68 0b 71 10 f0       	push   $0xf010710b
f01013f8:	68 43 70 10 f0       	push   $0xf0107043
f01013fd:	68 3c 03 00 00       	push   $0x33c
f0101402:	68 1d 70 10 f0       	push   $0xf010701d
f0101407:	e8 34 ec ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010140c:	83 ec 0c             	sub    $0xc,%esp
f010140f:	6a 00                	push   $0x0
f0101411:	e8 cb fa ff ff       	call   f0100ee1 <page_alloc>
f0101416:	89 c6                	mov    %eax,%esi
f0101418:	83 c4 10             	add    $0x10,%esp
f010141b:	85 c0                	test   %eax,%eax
f010141d:	75 19                	jne    f0101438 <mem_init+0x1ee>
f010141f:	68 21 71 10 f0       	push   $0xf0107121
f0101424:	68 43 70 10 f0       	push   $0xf0107043
f0101429:	68 3d 03 00 00       	push   $0x33d
f010142e:	68 1d 70 10 f0       	push   $0xf010701d
f0101433:	e8 08 ec ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101438:	83 ec 0c             	sub    $0xc,%esp
f010143b:	6a 00                	push   $0x0
f010143d:	e8 9f fa ff ff       	call   f0100ee1 <page_alloc>
f0101442:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101445:	83 c4 10             	add    $0x10,%esp
f0101448:	85 c0                	test   %eax,%eax
f010144a:	75 19                	jne    f0101465 <mem_init+0x21b>
f010144c:	68 37 71 10 f0       	push   $0xf0107137
f0101451:	68 43 70 10 f0       	push   $0xf0107043
f0101456:	68 3e 03 00 00       	push   $0x33e
f010145b:	68 1d 70 10 f0       	push   $0xf010701d
f0101460:	e8 db eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101465:	39 f7                	cmp    %esi,%edi
f0101467:	75 19                	jne    f0101482 <mem_init+0x238>
f0101469:	68 4d 71 10 f0       	push   $0xf010714d
f010146e:	68 43 70 10 f0       	push   $0xf0107043
f0101473:	68 41 03 00 00       	push   $0x341
f0101478:	68 1d 70 10 f0       	push   $0xf010701d
f010147d:	e8 be eb ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101482:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101485:	39 c6                	cmp    %eax,%esi
f0101487:	74 04                	je     f010148d <mem_init+0x243>
f0101489:	39 c7                	cmp    %eax,%edi
f010148b:	75 19                	jne    f01014a6 <mem_init+0x25c>
f010148d:	68 40 68 10 f0       	push   $0xf0106840
f0101492:	68 43 70 10 f0       	push   $0xf0107043
f0101497:	68 42 03 00 00       	push   $0x342
f010149c:	68 1d 70 10 f0       	push   $0xf010701d
f01014a1:	e8 9a eb ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014a6:	8b 0d 90 de 1d f0    	mov    0xf01dde90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014ac:	8b 15 88 de 1d f0    	mov    0xf01dde88,%edx
f01014b2:	c1 e2 0c             	shl    $0xc,%edx
f01014b5:	89 f8                	mov    %edi,%eax
f01014b7:	29 c8                	sub    %ecx,%eax
f01014b9:	c1 f8 03             	sar    $0x3,%eax
f01014bc:	c1 e0 0c             	shl    $0xc,%eax
f01014bf:	39 d0                	cmp    %edx,%eax
f01014c1:	72 19                	jb     f01014dc <mem_init+0x292>
f01014c3:	68 5f 71 10 f0       	push   $0xf010715f
f01014c8:	68 43 70 10 f0       	push   $0xf0107043
f01014cd:	68 43 03 00 00       	push   $0x343
f01014d2:	68 1d 70 10 f0       	push   $0xf010701d
f01014d7:	e8 64 eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01014dc:	89 f0                	mov    %esi,%eax
f01014de:	29 c8                	sub    %ecx,%eax
f01014e0:	c1 f8 03             	sar    $0x3,%eax
f01014e3:	c1 e0 0c             	shl    $0xc,%eax
f01014e6:	39 c2                	cmp    %eax,%edx
f01014e8:	77 19                	ja     f0101503 <mem_init+0x2b9>
f01014ea:	68 7c 71 10 f0       	push   $0xf010717c
f01014ef:	68 43 70 10 f0       	push   $0xf0107043
f01014f4:	68 44 03 00 00       	push   $0x344
f01014f9:	68 1d 70 10 f0       	push   $0xf010701d
f01014fe:	e8 3d eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101503:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101506:	29 c8                	sub    %ecx,%eax
f0101508:	c1 f8 03             	sar    $0x3,%eax
f010150b:	c1 e0 0c             	shl    $0xc,%eax
f010150e:	39 c2                	cmp    %eax,%edx
f0101510:	77 19                	ja     f010152b <mem_init+0x2e1>
f0101512:	68 99 71 10 f0       	push   $0xf0107199
f0101517:	68 43 70 10 f0       	push   $0xf0107043
f010151c:	68 45 03 00 00       	push   $0x345
f0101521:	68 1d 70 10 f0       	push   $0xf010701d
f0101526:	e8 15 eb ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010152b:	a1 40 d2 1d f0       	mov    0xf01dd240,%eax
f0101530:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101533:	c7 05 40 d2 1d f0 00 	movl   $0x0,0xf01dd240
f010153a:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010153d:	83 ec 0c             	sub    $0xc,%esp
f0101540:	6a 00                	push   $0x0
f0101542:	e8 9a f9 ff ff       	call   f0100ee1 <page_alloc>
f0101547:	83 c4 10             	add    $0x10,%esp
f010154a:	85 c0                	test   %eax,%eax
f010154c:	74 19                	je     f0101567 <mem_init+0x31d>
f010154e:	68 b6 71 10 f0       	push   $0xf01071b6
f0101553:	68 43 70 10 f0       	push   $0xf0107043
f0101558:	68 4c 03 00 00       	push   $0x34c
f010155d:	68 1d 70 10 f0       	push   $0xf010701d
f0101562:	e8 d9 ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101567:	83 ec 0c             	sub    $0xc,%esp
f010156a:	57                   	push   %edi
f010156b:	e8 e1 f9 ff ff       	call   f0100f51 <page_free>
	page_free(pp1);
f0101570:	89 34 24             	mov    %esi,(%esp)
f0101573:	e8 d9 f9 ff ff       	call   f0100f51 <page_free>
	page_free(pp2);
f0101578:	83 c4 04             	add    $0x4,%esp
f010157b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010157e:	e8 ce f9 ff ff       	call   f0100f51 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101583:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010158a:	e8 52 f9 ff ff       	call   f0100ee1 <page_alloc>
f010158f:	89 c6                	mov    %eax,%esi
f0101591:	83 c4 10             	add    $0x10,%esp
f0101594:	85 c0                	test   %eax,%eax
f0101596:	75 19                	jne    f01015b1 <mem_init+0x367>
f0101598:	68 0b 71 10 f0       	push   $0xf010710b
f010159d:	68 43 70 10 f0       	push   $0xf0107043
f01015a2:	68 53 03 00 00       	push   $0x353
f01015a7:	68 1d 70 10 f0       	push   $0xf010701d
f01015ac:	e8 8f ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015b1:	83 ec 0c             	sub    $0xc,%esp
f01015b4:	6a 00                	push   $0x0
f01015b6:	e8 26 f9 ff ff       	call   f0100ee1 <page_alloc>
f01015bb:	89 c7                	mov    %eax,%edi
f01015bd:	83 c4 10             	add    $0x10,%esp
f01015c0:	85 c0                	test   %eax,%eax
f01015c2:	75 19                	jne    f01015dd <mem_init+0x393>
f01015c4:	68 21 71 10 f0       	push   $0xf0107121
f01015c9:	68 43 70 10 f0       	push   $0xf0107043
f01015ce:	68 54 03 00 00       	push   $0x354
f01015d3:	68 1d 70 10 f0       	push   $0xf010701d
f01015d8:	e8 63 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01015dd:	83 ec 0c             	sub    $0xc,%esp
f01015e0:	6a 00                	push   $0x0
f01015e2:	e8 fa f8 ff ff       	call   f0100ee1 <page_alloc>
f01015e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015ea:	83 c4 10             	add    $0x10,%esp
f01015ed:	85 c0                	test   %eax,%eax
f01015ef:	75 19                	jne    f010160a <mem_init+0x3c0>
f01015f1:	68 37 71 10 f0       	push   $0xf0107137
f01015f6:	68 43 70 10 f0       	push   $0xf0107043
f01015fb:	68 55 03 00 00       	push   $0x355
f0101600:	68 1d 70 10 f0       	push   $0xf010701d
f0101605:	e8 36 ea ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010160a:	39 fe                	cmp    %edi,%esi
f010160c:	75 19                	jne    f0101627 <mem_init+0x3dd>
f010160e:	68 4d 71 10 f0       	push   $0xf010714d
f0101613:	68 43 70 10 f0       	push   $0xf0107043
f0101618:	68 57 03 00 00       	push   $0x357
f010161d:	68 1d 70 10 f0       	push   $0xf010701d
f0101622:	e8 19 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101627:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010162a:	39 c7                	cmp    %eax,%edi
f010162c:	74 04                	je     f0101632 <mem_init+0x3e8>
f010162e:	39 c6                	cmp    %eax,%esi
f0101630:	75 19                	jne    f010164b <mem_init+0x401>
f0101632:	68 40 68 10 f0       	push   $0xf0106840
f0101637:	68 43 70 10 f0       	push   $0xf0107043
f010163c:	68 58 03 00 00       	push   $0x358
f0101641:	68 1d 70 10 f0       	push   $0xf010701d
f0101646:	e8 f5 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010164b:	83 ec 0c             	sub    $0xc,%esp
f010164e:	6a 00                	push   $0x0
f0101650:	e8 8c f8 ff ff       	call   f0100ee1 <page_alloc>
f0101655:	83 c4 10             	add    $0x10,%esp
f0101658:	85 c0                	test   %eax,%eax
f010165a:	74 19                	je     f0101675 <mem_init+0x42b>
f010165c:	68 b6 71 10 f0       	push   $0xf01071b6
f0101661:	68 43 70 10 f0       	push   $0xf0107043
f0101666:	68 59 03 00 00       	push   $0x359
f010166b:	68 1d 70 10 f0       	push   $0xf010701d
f0101670:	e8 cb e9 ff ff       	call   f0100040 <_panic>
f0101675:	89 f0                	mov    %esi,%eax
f0101677:	2b 05 90 de 1d f0    	sub    0xf01dde90,%eax
f010167d:	c1 f8 03             	sar    $0x3,%eax
f0101680:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101683:	89 c2                	mov    %eax,%edx
f0101685:	c1 ea 0c             	shr    $0xc,%edx
f0101688:	3b 15 88 de 1d f0    	cmp    0xf01dde88,%edx
f010168e:	72 12                	jb     f01016a2 <mem_init+0x458>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101690:	50                   	push   %eax
f0101691:	68 04 61 10 f0       	push   $0xf0106104
f0101696:	6a 58                	push   $0x58
f0101698:	68 29 70 10 f0       	push   $0xf0107029
f010169d:	e8 9e e9 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01016a2:	83 ec 04             	sub    $0x4,%esp
f01016a5:	68 00 10 00 00       	push   $0x1000
f01016aa:	6a 01                	push   $0x1
f01016ac:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016b1:	50                   	push   %eax
f01016b2:	e8 7b 3d 00 00       	call   f0105432 <memset>
	page_free(pp0);
f01016b7:	89 34 24             	mov    %esi,(%esp)
f01016ba:	e8 92 f8 ff ff       	call   f0100f51 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01016bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01016c6:	e8 16 f8 ff ff       	call   f0100ee1 <page_alloc>
f01016cb:	83 c4 10             	add    $0x10,%esp
f01016ce:	85 c0                	test   %eax,%eax
f01016d0:	75 19                	jne    f01016eb <mem_init+0x4a1>
f01016d2:	68 c5 71 10 f0       	push   $0xf01071c5
f01016d7:	68 43 70 10 f0       	push   $0xf0107043
f01016dc:	68 5e 03 00 00       	push   $0x35e
f01016e1:	68 1d 70 10 f0       	push   $0xf010701d
f01016e6:	e8 55 e9 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01016eb:	39 c6                	cmp    %eax,%esi
f01016ed:	74 19                	je     f0101708 <mem_init+0x4be>
f01016ef:	68 e3 71 10 f0       	push   $0xf01071e3
f01016f4:	68 43 70 10 f0       	push   $0xf0107043
f01016f9:	68 5f 03 00 00       	push   $0x35f
f01016fe:	68 1d 70 10 f0       	push   $0xf010701d
f0101703:	e8 38 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101708:	89 f0                	mov    %esi,%eax
f010170a:	2b 05 90 de 1d f0    	sub    0xf01dde90,%eax
f0101710:	c1 f8 03             	sar    $0x3,%eax
f0101713:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101716:	89 c2                	mov    %eax,%edx
f0101718:	c1 ea 0c             	shr    $0xc,%edx
f010171b:	3b 15 88 de 1d f0    	cmp    0xf01dde88,%edx
f0101721:	72 12                	jb     f0101735 <mem_init+0x4eb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101723:	50                   	push   %eax
f0101724:	68 04 61 10 f0       	push   $0xf0106104
f0101729:	6a 58                	push   $0x58
f010172b:	68 29 70 10 f0       	push   $0xf0107029
f0101730:	e8 0b e9 ff ff       	call   f0100040 <_panic>
f0101735:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010173b:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101741:	80 38 00             	cmpb   $0x0,(%eax)
f0101744:	74 19                	je     f010175f <mem_init+0x515>
f0101746:	68 f3 71 10 f0       	push   $0xf01071f3
f010174b:	68 43 70 10 f0       	push   $0xf0107043
f0101750:	68 62 03 00 00       	push   $0x362
f0101755:	68 1d 70 10 f0       	push   $0xf010701d
f010175a:	e8 e1 e8 ff ff       	call   f0100040 <_panic>
f010175f:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101762:	39 d0                	cmp    %edx,%eax
f0101764:	75 db                	jne    f0101741 <mem_init+0x4f7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101766:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101769:	a3 40 d2 1d f0       	mov    %eax,0xf01dd240

	// free the pages we took
	page_free(pp0);
f010176e:	83 ec 0c             	sub    $0xc,%esp
f0101771:	56                   	push   %esi
f0101772:	e8 da f7 ff ff       	call   f0100f51 <page_free>
	page_free(pp1);
f0101777:	89 3c 24             	mov    %edi,(%esp)
f010177a:	e8 d2 f7 ff ff       	call   f0100f51 <page_free>
	page_free(pp2);
f010177f:	83 c4 04             	add    $0x4,%esp
f0101782:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101785:	e8 c7 f7 ff ff       	call   f0100f51 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010178a:	a1 40 d2 1d f0       	mov    0xf01dd240,%eax
f010178f:	83 c4 10             	add    $0x10,%esp
f0101792:	eb 05                	jmp    f0101799 <mem_init+0x54f>
		--nfree;
f0101794:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101797:	8b 00                	mov    (%eax),%eax
f0101799:	85 c0                	test   %eax,%eax
f010179b:	75 f7                	jne    f0101794 <mem_init+0x54a>
		--nfree;
	assert(nfree == 0);
f010179d:	85 db                	test   %ebx,%ebx
f010179f:	74 19                	je     f01017ba <mem_init+0x570>
f01017a1:	68 fd 71 10 f0       	push   $0xf01071fd
f01017a6:	68 43 70 10 f0       	push   $0xf0107043
f01017ab:	68 6f 03 00 00       	push   $0x36f
f01017b0:	68 1d 70 10 f0       	push   $0xf010701d
f01017b5:	e8 86 e8 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01017ba:	83 ec 0c             	sub    $0xc,%esp
f01017bd:	68 60 68 10 f0       	push   $0xf0106860
f01017c2:	e8 b5 1e 00 00       	call   f010367c <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017ce:	e8 0e f7 ff ff       	call   f0100ee1 <page_alloc>
f01017d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017d6:	83 c4 10             	add    $0x10,%esp
f01017d9:	85 c0                	test   %eax,%eax
f01017db:	75 19                	jne    f01017f6 <mem_init+0x5ac>
f01017dd:	68 0b 71 10 f0       	push   $0xf010710b
f01017e2:	68 43 70 10 f0       	push   $0xf0107043
f01017e7:	68 d5 03 00 00       	push   $0x3d5
f01017ec:	68 1d 70 10 f0       	push   $0xf010701d
f01017f1:	e8 4a e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017f6:	83 ec 0c             	sub    $0xc,%esp
f01017f9:	6a 00                	push   $0x0
f01017fb:	e8 e1 f6 ff ff       	call   f0100ee1 <page_alloc>
f0101800:	89 c3                	mov    %eax,%ebx
f0101802:	83 c4 10             	add    $0x10,%esp
f0101805:	85 c0                	test   %eax,%eax
f0101807:	75 19                	jne    f0101822 <mem_init+0x5d8>
f0101809:	68 21 71 10 f0       	push   $0xf0107121
f010180e:	68 43 70 10 f0       	push   $0xf0107043
f0101813:	68 d6 03 00 00       	push   $0x3d6
f0101818:	68 1d 70 10 f0       	push   $0xf010701d
f010181d:	e8 1e e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101822:	83 ec 0c             	sub    $0xc,%esp
f0101825:	6a 00                	push   $0x0
f0101827:	e8 b5 f6 ff ff       	call   f0100ee1 <page_alloc>
f010182c:	89 c6                	mov    %eax,%esi
f010182e:	83 c4 10             	add    $0x10,%esp
f0101831:	85 c0                	test   %eax,%eax
f0101833:	75 19                	jne    f010184e <mem_init+0x604>
f0101835:	68 37 71 10 f0       	push   $0xf0107137
f010183a:	68 43 70 10 f0       	push   $0xf0107043
f010183f:	68 d7 03 00 00       	push   $0x3d7
f0101844:	68 1d 70 10 f0       	push   $0xf010701d
f0101849:	e8 f2 e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010184e:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101851:	75 19                	jne    f010186c <mem_init+0x622>
f0101853:	68 4d 71 10 f0       	push   $0xf010714d
f0101858:	68 43 70 10 f0       	push   $0xf0107043
f010185d:	68 da 03 00 00       	push   $0x3da
f0101862:	68 1d 70 10 f0       	push   $0xf010701d
f0101867:	e8 d4 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010186c:	39 c3                	cmp    %eax,%ebx
f010186e:	74 05                	je     f0101875 <mem_init+0x62b>
f0101870:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101873:	75 19                	jne    f010188e <mem_init+0x644>
f0101875:	68 40 68 10 f0       	push   $0xf0106840
f010187a:	68 43 70 10 f0       	push   $0xf0107043
f010187f:	68 db 03 00 00       	push   $0x3db
f0101884:	68 1d 70 10 f0       	push   $0xf010701d
f0101889:	e8 b2 e7 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010188e:	a1 40 d2 1d f0       	mov    0xf01dd240,%eax
f0101893:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101896:	c7 05 40 d2 1d f0 00 	movl   $0x0,0xf01dd240
f010189d:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018a0:	83 ec 0c             	sub    $0xc,%esp
f01018a3:	6a 00                	push   $0x0
f01018a5:	e8 37 f6 ff ff       	call   f0100ee1 <page_alloc>
f01018aa:	83 c4 10             	add    $0x10,%esp
f01018ad:	85 c0                	test   %eax,%eax
f01018af:	74 19                	je     f01018ca <mem_init+0x680>
f01018b1:	68 b6 71 10 f0       	push   $0xf01071b6
f01018b6:	68 43 70 10 f0       	push   $0xf0107043
f01018bb:	68 e2 03 00 00       	push   $0x3e2
f01018c0:	68 1d 70 10 f0       	push   $0xf010701d
f01018c5:	e8 76 e7 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018ca:	83 ec 04             	sub    $0x4,%esp
f01018cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018d0:	50                   	push   %eax
f01018d1:	6a 00                	push   $0x0
f01018d3:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f01018d9:	e8 e9 f7 ff ff       	call   f01010c7 <page_lookup>
f01018de:	83 c4 10             	add    $0x10,%esp
f01018e1:	85 c0                	test   %eax,%eax
f01018e3:	74 19                	je     f01018fe <mem_init+0x6b4>
f01018e5:	68 80 68 10 f0       	push   $0xf0106880
f01018ea:	68 43 70 10 f0       	push   $0xf0107043
f01018ef:	68 e5 03 00 00       	push   $0x3e5
f01018f4:	68 1d 70 10 f0       	push   $0xf010701d
f01018f9:	e8 42 e7 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01018fe:	6a 02                	push   $0x2
f0101900:	6a 00                	push   $0x0
f0101902:	53                   	push   %ebx
f0101903:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f0101909:	e8 5c f8 ff ff       	call   f010116a <page_insert>
f010190e:	83 c4 10             	add    $0x10,%esp
f0101911:	85 c0                	test   %eax,%eax
f0101913:	78 19                	js     f010192e <mem_init+0x6e4>
f0101915:	68 b8 68 10 f0       	push   $0xf01068b8
f010191a:	68 43 70 10 f0       	push   $0xf0107043
f010191f:	68 e8 03 00 00       	push   $0x3e8
f0101924:	68 1d 70 10 f0       	push   $0xf010701d
f0101929:	e8 12 e7 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010192e:	83 ec 0c             	sub    $0xc,%esp
f0101931:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101934:	e8 18 f6 ff ff       	call   f0100f51 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101939:	6a 02                	push   $0x2
f010193b:	6a 00                	push   $0x0
f010193d:	53                   	push   %ebx
f010193e:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f0101944:	e8 21 f8 ff ff       	call   f010116a <page_insert>
f0101949:	83 c4 20             	add    $0x20,%esp
f010194c:	85 c0                	test   %eax,%eax
f010194e:	74 19                	je     f0101969 <mem_init+0x71f>
f0101950:	68 e8 68 10 f0       	push   $0xf01068e8
f0101955:	68 43 70 10 f0       	push   $0xf0107043
f010195a:	68 ec 03 00 00       	push   $0x3ec
f010195f:	68 1d 70 10 f0       	push   $0xf010701d
f0101964:	e8 d7 e6 ff ff       	call   f0100040 <_panic>

	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101969:	8b 3d 8c de 1d f0    	mov    0xf01dde8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010196f:	a1 90 de 1d f0       	mov    0xf01dde90,%eax
f0101974:	89 c1                	mov    %eax,%ecx
f0101976:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101979:	8b 17                	mov    (%edi),%edx
f010197b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101981:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101984:	29 c8                	sub    %ecx,%eax
f0101986:	c1 f8 03             	sar    $0x3,%eax
f0101989:	c1 e0 0c             	shl    $0xc,%eax
f010198c:	39 c2                	cmp    %eax,%edx
f010198e:	74 19                	je     f01019a9 <mem_init+0x75f>
f0101990:	68 18 69 10 f0       	push   $0xf0106918
f0101995:	68 43 70 10 f0       	push   $0xf0107043
f010199a:	68 ee 03 00 00       	push   $0x3ee
f010199f:	68 1d 70 10 f0       	push   $0xf010701d
f01019a4:	e8 97 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019a9:	ba 00 00 00 00       	mov    $0x0,%edx
f01019ae:	89 f8                	mov    %edi,%eax
f01019b0:	e8 1a f1 ff ff       	call   f0100acf <check_va2pa>
f01019b5:	89 da                	mov    %ebx,%edx
f01019b7:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01019ba:	c1 fa 03             	sar    $0x3,%edx
f01019bd:	c1 e2 0c             	shl    $0xc,%edx
f01019c0:	39 d0                	cmp    %edx,%eax
f01019c2:	74 19                	je     f01019dd <mem_init+0x793>
f01019c4:	68 40 69 10 f0       	push   $0xf0106940
f01019c9:	68 43 70 10 f0       	push   $0xf0107043
f01019ce:	68 ef 03 00 00       	push   $0x3ef
f01019d3:	68 1d 70 10 f0       	push   $0xf010701d
f01019d8:	e8 63 e6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01019dd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019e2:	74 19                	je     f01019fd <mem_init+0x7b3>
f01019e4:	68 08 72 10 f0       	push   $0xf0107208
f01019e9:	68 43 70 10 f0       	push   $0xf0107043
f01019ee:	68 f0 03 00 00       	push   $0x3f0
f01019f3:	68 1d 70 10 f0       	push   $0xf010701d
f01019f8:	e8 43 e6 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01019fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a00:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a05:	74 19                	je     f0101a20 <mem_init+0x7d6>
f0101a07:	68 19 72 10 f0       	push   $0xf0107219
f0101a0c:	68 43 70 10 f0       	push   $0xf0107043
f0101a11:	68 f1 03 00 00       	push   $0x3f1
f0101a16:	68 1d 70 10 f0       	push   $0xf010701d
f0101a1b:	e8 20 e6 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a20:	6a 02                	push   $0x2
f0101a22:	68 00 10 00 00       	push   $0x1000
f0101a27:	56                   	push   %esi
f0101a28:	57                   	push   %edi
f0101a29:	e8 3c f7 ff ff       	call   f010116a <page_insert>
f0101a2e:	83 c4 10             	add    $0x10,%esp
f0101a31:	85 c0                	test   %eax,%eax
f0101a33:	74 19                	je     f0101a4e <mem_init+0x804>
f0101a35:	68 70 69 10 f0       	push   $0xf0106970
f0101a3a:	68 43 70 10 f0       	push   $0xf0107043
f0101a3f:	68 f4 03 00 00       	push   $0x3f4
f0101a44:	68 1d 70 10 f0       	push   $0xf010701d
f0101a49:	e8 f2 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a4e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a53:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
f0101a58:	e8 72 f0 ff ff       	call   f0100acf <check_va2pa>
f0101a5d:	89 f2                	mov    %esi,%edx
f0101a5f:	2b 15 90 de 1d f0    	sub    0xf01dde90,%edx
f0101a65:	c1 fa 03             	sar    $0x3,%edx
f0101a68:	c1 e2 0c             	shl    $0xc,%edx
f0101a6b:	39 d0                	cmp    %edx,%eax
f0101a6d:	74 19                	je     f0101a88 <mem_init+0x83e>
f0101a6f:	68 ac 69 10 f0       	push   $0xf01069ac
f0101a74:	68 43 70 10 f0       	push   $0xf0107043
f0101a79:	68 f5 03 00 00       	push   $0x3f5
f0101a7e:	68 1d 70 10 f0       	push   $0xf010701d
f0101a83:	e8 b8 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101a88:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a8d:	74 19                	je     f0101aa8 <mem_init+0x85e>
f0101a8f:	68 2a 72 10 f0       	push   $0xf010722a
f0101a94:	68 43 70 10 f0       	push   $0xf0107043
f0101a99:	68 f6 03 00 00       	push   $0x3f6
f0101a9e:	68 1d 70 10 f0       	push   $0xf010701d
f0101aa3:	e8 98 e5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101aa8:	83 ec 0c             	sub    $0xc,%esp
f0101aab:	6a 00                	push   $0x0
f0101aad:	e8 2f f4 ff ff       	call   f0100ee1 <page_alloc>
f0101ab2:	83 c4 10             	add    $0x10,%esp
f0101ab5:	85 c0                	test   %eax,%eax
f0101ab7:	74 19                	je     f0101ad2 <mem_init+0x888>
f0101ab9:	68 b6 71 10 f0       	push   $0xf01071b6
f0101abe:	68 43 70 10 f0       	push   $0xf0107043
f0101ac3:	68 f9 03 00 00       	push   $0x3f9
f0101ac8:	68 1d 70 10 f0       	push   $0xf010701d
f0101acd:	e8 6e e5 ff ff       	call   f0100040 <_panic>
	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ad2:	6a 02                	push   $0x2
f0101ad4:	68 00 10 00 00       	push   $0x1000
f0101ad9:	56                   	push   %esi
f0101ada:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f0101ae0:	e8 85 f6 ff ff       	call   f010116a <page_insert>
f0101ae5:	83 c4 10             	add    $0x10,%esp
f0101ae8:	85 c0                	test   %eax,%eax
f0101aea:	74 19                	je     f0101b05 <mem_init+0x8bb>
f0101aec:	68 70 69 10 f0       	push   $0xf0106970
f0101af1:	68 43 70 10 f0       	push   $0xf0107043
f0101af6:	68 fb 03 00 00       	push   $0x3fb
f0101afb:	68 1d 70 10 f0       	push   $0xf010701d
f0101b00:	e8 3b e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b05:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b0a:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
f0101b0f:	e8 bb ef ff ff       	call   f0100acf <check_va2pa>
f0101b14:	89 f2                	mov    %esi,%edx
f0101b16:	2b 15 90 de 1d f0    	sub    0xf01dde90,%edx
f0101b1c:	c1 fa 03             	sar    $0x3,%edx
f0101b1f:	c1 e2 0c             	shl    $0xc,%edx
f0101b22:	39 d0                	cmp    %edx,%eax
f0101b24:	74 19                	je     f0101b3f <mem_init+0x8f5>
f0101b26:	68 ac 69 10 f0       	push   $0xf01069ac
f0101b2b:	68 43 70 10 f0       	push   $0xf0107043
f0101b30:	68 fc 03 00 00       	push   $0x3fc
f0101b35:	68 1d 70 10 f0       	push   $0xf010701d
f0101b3a:	e8 01 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b3f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b44:	74 19                	je     f0101b5f <mem_init+0x915>
f0101b46:	68 2a 72 10 f0       	push   $0xf010722a
f0101b4b:	68 43 70 10 f0       	push   $0xf0107043
f0101b50:	68 fd 03 00 00       	push   $0x3fd
f0101b55:	68 1d 70 10 f0       	push   $0xf010701d
f0101b5a:	e8 e1 e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101b5f:	83 ec 0c             	sub    $0xc,%esp
f0101b62:	6a 00                	push   $0x0
f0101b64:	e8 78 f3 ff ff       	call   f0100ee1 <page_alloc>
f0101b69:	83 c4 10             	add    $0x10,%esp
f0101b6c:	85 c0                	test   %eax,%eax
f0101b6e:	74 19                	je     f0101b89 <mem_init+0x93f>
f0101b70:	68 b6 71 10 f0       	push   $0xf01071b6
f0101b75:	68 43 70 10 f0       	push   $0xf0107043
f0101b7a:	68 01 04 00 00       	push   $0x401
f0101b7f:	68 1d 70 10 f0       	push   $0xf010701d
f0101b84:	e8 b7 e4 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101b89:	8b 15 8c de 1d f0    	mov    0xf01dde8c,%edx
f0101b8f:	8b 02                	mov    (%edx),%eax
f0101b91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b96:	89 c1                	mov    %eax,%ecx
f0101b98:	c1 e9 0c             	shr    $0xc,%ecx
f0101b9b:	3b 0d 88 de 1d f0    	cmp    0xf01dde88,%ecx
f0101ba1:	72 15                	jb     f0101bb8 <mem_init+0x96e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ba3:	50                   	push   %eax
f0101ba4:	68 04 61 10 f0       	push   $0xf0106104
f0101ba9:	68 04 04 00 00       	push   $0x404
f0101bae:	68 1d 70 10 f0       	push   $0xf010701d
f0101bb3:	e8 88 e4 ff ff       	call   f0100040 <_panic>
f0101bb8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101bbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101bc0:	83 ec 04             	sub    $0x4,%esp
f0101bc3:	6a 00                	push   $0x0
f0101bc5:	68 00 10 00 00       	push   $0x1000
f0101bca:	52                   	push   %edx
f0101bcb:	e8 e3 f3 ff ff       	call   f0100fb3 <pgdir_walk>
f0101bd0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101bd3:	8d 51 04             	lea    0x4(%ecx),%edx
f0101bd6:	83 c4 10             	add    $0x10,%esp
f0101bd9:	39 d0                	cmp    %edx,%eax
f0101bdb:	74 19                	je     f0101bf6 <mem_init+0x9ac>
f0101bdd:	68 dc 69 10 f0       	push   $0xf01069dc
f0101be2:	68 43 70 10 f0       	push   $0xf0107043
f0101be7:	68 05 04 00 00       	push   $0x405
f0101bec:	68 1d 70 10 f0       	push   $0xf010701d
f0101bf1:	e8 4a e4 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101bf6:	6a 06                	push   $0x6
f0101bf8:	68 00 10 00 00       	push   $0x1000
f0101bfd:	56                   	push   %esi
f0101bfe:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f0101c04:	e8 61 f5 ff ff       	call   f010116a <page_insert>
f0101c09:	83 c4 10             	add    $0x10,%esp
f0101c0c:	85 c0                	test   %eax,%eax
f0101c0e:	74 19                	je     f0101c29 <mem_init+0x9df>
f0101c10:	68 1c 6a 10 f0       	push   $0xf0106a1c
f0101c15:	68 43 70 10 f0       	push   $0xf0107043
f0101c1a:	68 08 04 00 00       	push   $0x408
f0101c1f:	68 1d 70 10 f0       	push   $0xf010701d
f0101c24:	e8 17 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c29:	8b 3d 8c de 1d f0    	mov    0xf01dde8c,%edi
f0101c2f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c34:	89 f8                	mov    %edi,%eax
f0101c36:	e8 94 ee ff ff       	call   f0100acf <check_va2pa>
f0101c3b:	89 f2                	mov    %esi,%edx
f0101c3d:	2b 15 90 de 1d f0    	sub    0xf01dde90,%edx
f0101c43:	c1 fa 03             	sar    $0x3,%edx
f0101c46:	c1 e2 0c             	shl    $0xc,%edx
f0101c49:	39 d0                	cmp    %edx,%eax
f0101c4b:	74 19                	je     f0101c66 <mem_init+0xa1c>
f0101c4d:	68 ac 69 10 f0       	push   $0xf01069ac
f0101c52:	68 43 70 10 f0       	push   $0xf0107043
f0101c57:	68 09 04 00 00       	push   $0x409
f0101c5c:	68 1d 70 10 f0       	push   $0xf010701d
f0101c61:	e8 da e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c66:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c6b:	74 19                	je     f0101c86 <mem_init+0xa3c>
f0101c6d:	68 2a 72 10 f0       	push   $0xf010722a
f0101c72:	68 43 70 10 f0       	push   $0xf0107043
f0101c77:	68 0a 04 00 00       	push   $0x40a
f0101c7c:	68 1d 70 10 f0       	push   $0xf010701d
f0101c81:	e8 ba e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101c86:	83 ec 04             	sub    $0x4,%esp
f0101c89:	6a 00                	push   $0x0
f0101c8b:	68 00 10 00 00       	push   $0x1000
f0101c90:	57                   	push   %edi
f0101c91:	e8 1d f3 ff ff       	call   f0100fb3 <pgdir_walk>
f0101c96:	83 c4 10             	add    $0x10,%esp
f0101c99:	f6 00 04             	testb  $0x4,(%eax)
f0101c9c:	75 19                	jne    f0101cb7 <mem_init+0xa6d>
f0101c9e:	68 5c 6a 10 f0       	push   $0xf0106a5c
f0101ca3:	68 43 70 10 f0       	push   $0xf0107043
f0101ca8:	68 0b 04 00 00       	push   $0x40b
f0101cad:	68 1d 70 10 f0       	push   $0xf010701d
f0101cb2:	e8 89 e3 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101cb7:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
f0101cbc:	f6 00 04             	testb  $0x4,(%eax)
f0101cbf:	75 19                	jne    f0101cda <mem_init+0xa90>
f0101cc1:	68 3b 72 10 f0       	push   $0xf010723b
f0101cc6:	68 43 70 10 f0       	push   $0xf0107043
f0101ccb:	68 0c 04 00 00       	push   $0x40c
f0101cd0:	68 1d 70 10 f0       	push   $0xf010701d
f0101cd5:	e8 66 e3 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cda:	6a 02                	push   $0x2
f0101cdc:	68 00 10 00 00       	push   $0x1000
f0101ce1:	56                   	push   %esi
f0101ce2:	50                   	push   %eax
f0101ce3:	e8 82 f4 ff ff       	call   f010116a <page_insert>
f0101ce8:	83 c4 10             	add    $0x10,%esp
f0101ceb:	85 c0                	test   %eax,%eax
f0101ced:	74 19                	je     f0101d08 <mem_init+0xabe>
f0101cef:	68 70 69 10 f0       	push   $0xf0106970
f0101cf4:	68 43 70 10 f0       	push   $0xf0107043
f0101cf9:	68 0f 04 00 00       	push   $0x40f
f0101cfe:	68 1d 70 10 f0       	push   $0xf010701d
f0101d03:	e8 38 e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d08:	83 ec 04             	sub    $0x4,%esp
f0101d0b:	6a 00                	push   $0x0
f0101d0d:	68 00 10 00 00       	push   $0x1000
f0101d12:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f0101d18:	e8 96 f2 ff ff       	call   f0100fb3 <pgdir_walk>
f0101d1d:	83 c4 10             	add    $0x10,%esp
f0101d20:	f6 00 02             	testb  $0x2,(%eax)
f0101d23:	75 19                	jne    f0101d3e <mem_init+0xaf4>
f0101d25:	68 90 6a 10 f0       	push   $0xf0106a90
f0101d2a:	68 43 70 10 f0       	push   $0xf0107043
f0101d2f:	68 10 04 00 00       	push   $0x410
f0101d34:	68 1d 70 10 f0       	push   $0xf010701d
f0101d39:	e8 02 e3 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d3e:	83 ec 04             	sub    $0x4,%esp
f0101d41:	6a 00                	push   $0x0
f0101d43:	68 00 10 00 00       	push   $0x1000
f0101d48:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f0101d4e:	e8 60 f2 ff ff       	call   f0100fb3 <pgdir_walk>
f0101d53:	83 c4 10             	add    $0x10,%esp
f0101d56:	f6 00 04             	testb  $0x4,(%eax)
f0101d59:	74 19                	je     f0101d74 <mem_init+0xb2a>
f0101d5b:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101d60:	68 43 70 10 f0       	push   $0xf0107043
f0101d65:	68 11 04 00 00       	push   $0x411
f0101d6a:	68 1d 70 10 f0       	push   $0xf010701d
f0101d6f:	e8 cc e2 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101d74:	6a 02                	push   $0x2
f0101d76:	68 00 00 40 00       	push   $0x400000
f0101d7b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d7e:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f0101d84:	e8 e1 f3 ff ff       	call   f010116a <page_insert>
f0101d89:	83 c4 10             	add    $0x10,%esp
f0101d8c:	85 c0                	test   %eax,%eax
f0101d8e:	78 19                	js     f0101da9 <mem_init+0xb5f>
f0101d90:	68 fc 6a 10 f0       	push   $0xf0106afc
f0101d95:	68 43 70 10 f0       	push   $0xf0107043
f0101d9a:	68 14 04 00 00       	push   $0x414
f0101d9f:	68 1d 70 10 f0       	push   $0xf010701d
f0101da4:	e8 97 e2 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101da9:	6a 02                	push   $0x2
f0101dab:	68 00 10 00 00       	push   $0x1000
f0101db0:	53                   	push   %ebx
f0101db1:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f0101db7:	e8 ae f3 ff ff       	call   f010116a <page_insert>
f0101dbc:	83 c4 10             	add    $0x10,%esp
f0101dbf:	85 c0                	test   %eax,%eax
f0101dc1:	74 19                	je     f0101ddc <mem_init+0xb92>
f0101dc3:	68 34 6b 10 f0       	push   $0xf0106b34
f0101dc8:	68 43 70 10 f0       	push   $0xf0107043
f0101dcd:	68 17 04 00 00       	push   $0x417
f0101dd2:	68 1d 70 10 f0       	push   $0xf010701d
f0101dd7:	e8 64 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ddc:	83 ec 04             	sub    $0x4,%esp
f0101ddf:	6a 00                	push   $0x0
f0101de1:	68 00 10 00 00       	push   $0x1000
f0101de6:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f0101dec:	e8 c2 f1 ff ff       	call   f0100fb3 <pgdir_walk>
f0101df1:	83 c4 10             	add    $0x10,%esp
f0101df4:	f6 00 04             	testb  $0x4,(%eax)
f0101df7:	74 19                	je     f0101e12 <mem_init+0xbc8>
f0101df9:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101dfe:	68 43 70 10 f0       	push   $0xf0107043
f0101e03:	68 18 04 00 00       	push   $0x418
f0101e08:	68 1d 70 10 f0       	push   $0xf010701d
f0101e0d:	e8 2e e2 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e12:	8b 3d 8c de 1d f0    	mov    0xf01dde8c,%edi
f0101e18:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e1d:	89 f8                	mov    %edi,%eax
f0101e1f:	e8 ab ec ff ff       	call   f0100acf <check_va2pa>
f0101e24:	89 c1                	mov    %eax,%ecx
f0101e26:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e29:	89 d8                	mov    %ebx,%eax
f0101e2b:	2b 05 90 de 1d f0    	sub    0xf01dde90,%eax
f0101e31:	c1 f8 03             	sar    $0x3,%eax
f0101e34:	c1 e0 0c             	shl    $0xc,%eax
f0101e37:	39 c1                	cmp    %eax,%ecx
f0101e39:	74 19                	je     f0101e54 <mem_init+0xc0a>
f0101e3b:	68 70 6b 10 f0       	push   $0xf0106b70
f0101e40:	68 43 70 10 f0       	push   $0xf0107043
f0101e45:	68 1b 04 00 00       	push   $0x41b
f0101e4a:	68 1d 70 10 f0       	push   $0xf010701d
f0101e4f:	e8 ec e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e54:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e59:	89 f8                	mov    %edi,%eax
f0101e5b:	e8 6f ec ff ff       	call   f0100acf <check_va2pa>
f0101e60:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101e63:	74 19                	je     f0101e7e <mem_init+0xc34>
f0101e65:	68 9c 6b 10 f0       	push   $0xf0106b9c
f0101e6a:	68 43 70 10 f0       	push   $0xf0107043
f0101e6f:	68 1c 04 00 00       	push   $0x41c
f0101e74:	68 1d 70 10 f0       	push   $0xf010701d
f0101e79:	e8 c2 e1 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e7e:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101e83:	74 19                	je     f0101e9e <mem_init+0xc54>
f0101e85:	68 51 72 10 f0       	push   $0xf0107251
f0101e8a:	68 43 70 10 f0       	push   $0xf0107043
f0101e8f:	68 1e 04 00 00       	push   $0x41e
f0101e94:	68 1d 70 10 f0       	push   $0xf010701d
f0101e99:	e8 a2 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101e9e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ea3:	74 19                	je     f0101ebe <mem_init+0xc74>
f0101ea5:	68 62 72 10 f0       	push   $0xf0107262
f0101eaa:	68 43 70 10 f0       	push   $0xf0107043
f0101eaf:	68 1f 04 00 00       	push   $0x41f
f0101eb4:	68 1d 70 10 f0       	push   $0xf010701d
f0101eb9:	e8 82 e1 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101ebe:	83 ec 0c             	sub    $0xc,%esp
f0101ec1:	6a 00                	push   $0x0
f0101ec3:	e8 19 f0 ff ff       	call   f0100ee1 <page_alloc>
f0101ec8:	83 c4 10             	add    $0x10,%esp
f0101ecb:	85 c0                	test   %eax,%eax
f0101ecd:	74 04                	je     f0101ed3 <mem_init+0xc89>
f0101ecf:	39 c6                	cmp    %eax,%esi
f0101ed1:	74 19                	je     f0101eec <mem_init+0xca2>
f0101ed3:	68 cc 6b 10 f0       	push   $0xf0106bcc
f0101ed8:	68 43 70 10 f0       	push   $0xf0107043
f0101edd:	68 22 04 00 00       	push   $0x422
f0101ee2:	68 1d 70 10 f0       	push   $0xf010701d
f0101ee7:	e8 54 e1 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101eec:	83 ec 08             	sub    $0x8,%esp
f0101eef:	6a 00                	push   $0x0
f0101ef1:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f0101ef7:	e8 33 f2 ff ff       	call   f010112f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101efc:	8b 3d 8c de 1d f0    	mov    0xf01dde8c,%edi
f0101f02:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f07:	89 f8                	mov    %edi,%eax
f0101f09:	e8 c1 eb ff ff       	call   f0100acf <check_va2pa>
f0101f0e:	83 c4 10             	add    $0x10,%esp
f0101f11:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f14:	74 19                	je     f0101f2f <mem_init+0xce5>
f0101f16:	68 f0 6b 10 f0       	push   $0xf0106bf0
f0101f1b:	68 43 70 10 f0       	push   $0xf0107043
f0101f20:	68 26 04 00 00       	push   $0x426
f0101f25:	68 1d 70 10 f0       	push   $0xf010701d
f0101f2a:	e8 11 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f2f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f34:	89 f8                	mov    %edi,%eax
f0101f36:	e8 94 eb ff ff       	call   f0100acf <check_va2pa>
f0101f3b:	89 da                	mov    %ebx,%edx
f0101f3d:	2b 15 90 de 1d f0    	sub    0xf01dde90,%edx
f0101f43:	c1 fa 03             	sar    $0x3,%edx
f0101f46:	c1 e2 0c             	shl    $0xc,%edx
f0101f49:	39 d0                	cmp    %edx,%eax
f0101f4b:	74 19                	je     f0101f66 <mem_init+0xd1c>
f0101f4d:	68 9c 6b 10 f0       	push   $0xf0106b9c
f0101f52:	68 43 70 10 f0       	push   $0xf0107043
f0101f57:	68 27 04 00 00       	push   $0x427
f0101f5c:	68 1d 70 10 f0       	push   $0xf010701d
f0101f61:	e8 da e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101f66:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f6b:	74 19                	je     f0101f86 <mem_init+0xd3c>
f0101f6d:	68 08 72 10 f0       	push   $0xf0107208
f0101f72:	68 43 70 10 f0       	push   $0xf0107043
f0101f77:	68 28 04 00 00       	push   $0x428
f0101f7c:	68 1d 70 10 f0       	push   $0xf010701d
f0101f81:	e8 ba e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101f86:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f8b:	74 19                	je     f0101fa6 <mem_init+0xd5c>
f0101f8d:	68 62 72 10 f0       	push   $0xf0107262
f0101f92:	68 43 70 10 f0       	push   $0xf0107043
f0101f97:	68 29 04 00 00       	push   $0x429
f0101f9c:	68 1d 70 10 f0       	push   $0xf010701d
f0101fa1:	e8 9a e0 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101fa6:	6a 00                	push   $0x0
f0101fa8:	68 00 10 00 00       	push   $0x1000
f0101fad:	53                   	push   %ebx
f0101fae:	57                   	push   %edi
f0101faf:	e8 b6 f1 ff ff       	call   f010116a <page_insert>
f0101fb4:	83 c4 10             	add    $0x10,%esp
f0101fb7:	85 c0                	test   %eax,%eax
f0101fb9:	74 19                	je     f0101fd4 <mem_init+0xd8a>
f0101fbb:	68 14 6c 10 f0       	push   $0xf0106c14
f0101fc0:	68 43 70 10 f0       	push   $0xf0107043
f0101fc5:	68 2c 04 00 00       	push   $0x42c
f0101fca:	68 1d 70 10 f0       	push   $0xf010701d
f0101fcf:	e8 6c e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0101fd4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101fd9:	75 19                	jne    f0101ff4 <mem_init+0xdaa>
f0101fdb:	68 73 72 10 f0       	push   $0xf0107273
f0101fe0:	68 43 70 10 f0       	push   $0xf0107043
f0101fe5:	68 2d 04 00 00       	push   $0x42d
f0101fea:	68 1d 70 10 f0       	push   $0xf010701d
f0101fef:	e8 4c e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0101ff4:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101ff7:	74 19                	je     f0102012 <mem_init+0xdc8>
f0101ff9:	68 7f 72 10 f0       	push   $0xf010727f
f0101ffe:	68 43 70 10 f0       	push   $0xf0107043
f0102003:	68 2e 04 00 00       	push   $0x42e
f0102008:	68 1d 70 10 f0       	push   $0xf010701d
f010200d:	e8 2e e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102012:	83 ec 08             	sub    $0x8,%esp
f0102015:	68 00 10 00 00       	push   $0x1000
f010201a:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f0102020:	e8 0a f1 ff ff       	call   f010112f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102025:	8b 3d 8c de 1d f0    	mov    0xf01dde8c,%edi
f010202b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102030:	89 f8                	mov    %edi,%eax
f0102032:	e8 98 ea ff ff       	call   f0100acf <check_va2pa>
f0102037:	83 c4 10             	add    $0x10,%esp
f010203a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010203d:	74 19                	je     f0102058 <mem_init+0xe0e>
f010203f:	68 f0 6b 10 f0       	push   $0xf0106bf0
f0102044:	68 43 70 10 f0       	push   $0xf0107043
f0102049:	68 32 04 00 00       	push   $0x432
f010204e:	68 1d 70 10 f0       	push   $0xf010701d
f0102053:	e8 e8 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102058:	ba 00 10 00 00       	mov    $0x1000,%edx
f010205d:	89 f8                	mov    %edi,%eax
f010205f:	e8 6b ea ff ff       	call   f0100acf <check_va2pa>
f0102064:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102067:	74 19                	je     f0102082 <mem_init+0xe38>
f0102069:	68 4c 6c 10 f0       	push   $0xf0106c4c
f010206e:	68 43 70 10 f0       	push   $0xf0107043
f0102073:	68 33 04 00 00       	push   $0x433
f0102078:	68 1d 70 10 f0       	push   $0xf010701d
f010207d:	e8 be df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102082:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102087:	74 19                	je     f01020a2 <mem_init+0xe58>
f0102089:	68 94 72 10 f0       	push   $0xf0107294
f010208e:	68 43 70 10 f0       	push   $0xf0107043
f0102093:	68 34 04 00 00       	push   $0x434
f0102098:	68 1d 70 10 f0       	push   $0xf010701d
f010209d:	e8 9e df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020a2:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020a7:	74 19                	je     f01020c2 <mem_init+0xe78>
f01020a9:	68 62 72 10 f0       	push   $0xf0107262
f01020ae:	68 43 70 10 f0       	push   $0xf0107043
f01020b3:	68 35 04 00 00       	push   $0x435
f01020b8:	68 1d 70 10 f0       	push   $0xf010701d
f01020bd:	e8 7e df ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01020c2:	83 ec 0c             	sub    $0xc,%esp
f01020c5:	6a 00                	push   $0x0
f01020c7:	e8 15 ee ff ff       	call   f0100ee1 <page_alloc>
f01020cc:	83 c4 10             	add    $0x10,%esp
f01020cf:	39 c3                	cmp    %eax,%ebx
f01020d1:	75 04                	jne    f01020d7 <mem_init+0xe8d>
f01020d3:	85 c0                	test   %eax,%eax
f01020d5:	75 19                	jne    f01020f0 <mem_init+0xea6>
f01020d7:	68 74 6c 10 f0       	push   $0xf0106c74
f01020dc:	68 43 70 10 f0       	push   $0xf0107043
f01020e1:	68 38 04 00 00       	push   $0x438
f01020e6:	68 1d 70 10 f0       	push   $0xf010701d
f01020eb:	e8 50 df ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01020f0:	83 ec 0c             	sub    $0xc,%esp
f01020f3:	6a 00                	push   $0x0
f01020f5:	e8 e7 ed ff ff       	call   f0100ee1 <page_alloc>
f01020fa:	83 c4 10             	add    $0x10,%esp
f01020fd:	85 c0                	test   %eax,%eax
f01020ff:	74 19                	je     f010211a <mem_init+0xed0>
f0102101:	68 b6 71 10 f0       	push   $0xf01071b6
f0102106:	68 43 70 10 f0       	push   $0xf0107043
f010210b:	68 3b 04 00 00       	push   $0x43b
f0102110:	68 1d 70 10 f0       	push   $0xf010701d
f0102115:	e8 26 df ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010211a:	8b 0d 8c de 1d f0    	mov    0xf01dde8c,%ecx
f0102120:	8b 11                	mov    (%ecx),%edx
f0102122:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102128:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010212b:	2b 05 90 de 1d f0    	sub    0xf01dde90,%eax
f0102131:	c1 f8 03             	sar    $0x3,%eax
f0102134:	c1 e0 0c             	shl    $0xc,%eax
f0102137:	39 c2                	cmp    %eax,%edx
f0102139:	74 19                	je     f0102154 <mem_init+0xf0a>
f010213b:	68 18 69 10 f0       	push   $0xf0106918
f0102140:	68 43 70 10 f0       	push   $0xf0107043
f0102145:	68 3e 04 00 00       	push   $0x43e
f010214a:	68 1d 70 10 f0       	push   $0xf010701d
f010214f:	e8 ec de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102154:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010215a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010215d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102162:	74 19                	je     f010217d <mem_init+0xf33>
f0102164:	68 19 72 10 f0       	push   $0xf0107219
f0102169:	68 43 70 10 f0       	push   $0xf0107043
f010216e:	68 40 04 00 00       	push   $0x440
f0102173:	68 1d 70 10 f0       	push   $0xf010701d
f0102178:	e8 c3 de ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010217d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102180:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102186:	83 ec 0c             	sub    $0xc,%esp
f0102189:	50                   	push   %eax
f010218a:	e8 c2 ed ff ff       	call   f0100f51 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010218f:	83 c4 0c             	add    $0xc,%esp
f0102192:	6a 01                	push   $0x1
f0102194:	68 00 10 40 00       	push   $0x401000
f0102199:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f010219f:	e8 0f ee ff ff       	call   f0100fb3 <pgdir_walk>
f01021a4:	89 c7                	mov    %eax,%edi
f01021a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01021a9:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
f01021ae:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01021b1:	8b 40 04             	mov    0x4(%eax),%eax
f01021b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021b9:	8b 0d 88 de 1d f0    	mov    0xf01dde88,%ecx
f01021bf:	89 c2                	mov    %eax,%edx
f01021c1:	c1 ea 0c             	shr    $0xc,%edx
f01021c4:	83 c4 10             	add    $0x10,%esp
f01021c7:	39 ca                	cmp    %ecx,%edx
f01021c9:	72 15                	jb     f01021e0 <mem_init+0xf96>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021cb:	50                   	push   %eax
f01021cc:	68 04 61 10 f0       	push   $0xf0106104
f01021d1:	68 47 04 00 00       	push   $0x447
f01021d6:	68 1d 70 10 f0       	push   $0xf010701d
f01021db:	e8 60 de ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01021e0:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01021e5:	39 c7                	cmp    %eax,%edi
f01021e7:	74 19                	je     f0102202 <mem_init+0xfb8>
f01021e9:	68 a5 72 10 f0       	push   $0xf01072a5
f01021ee:	68 43 70 10 f0       	push   $0xf0107043
f01021f3:	68 48 04 00 00       	push   $0x448
f01021f8:	68 1d 70 10 f0       	push   $0xf010701d
f01021fd:	e8 3e de ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102202:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102205:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010220c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010220f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102215:	2b 05 90 de 1d f0    	sub    0xf01dde90,%eax
f010221b:	c1 f8 03             	sar    $0x3,%eax
f010221e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102221:	89 c2                	mov    %eax,%edx
f0102223:	c1 ea 0c             	shr    $0xc,%edx
f0102226:	39 d1                	cmp    %edx,%ecx
f0102228:	77 12                	ja     f010223c <mem_init+0xff2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010222a:	50                   	push   %eax
f010222b:	68 04 61 10 f0       	push   $0xf0106104
f0102230:	6a 58                	push   $0x58
f0102232:	68 29 70 10 f0       	push   $0xf0107029
f0102237:	e8 04 de ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010223c:	83 ec 04             	sub    $0x4,%esp
f010223f:	68 00 10 00 00       	push   $0x1000
f0102244:	68 ff 00 00 00       	push   $0xff
f0102249:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010224e:	50                   	push   %eax
f010224f:	e8 de 31 00 00       	call   f0105432 <memset>
	page_free(pp0);
f0102254:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102257:	89 3c 24             	mov    %edi,(%esp)
f010225a:	e8 f2 ec ff ff       	call   f0100f51 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010225f:	83 c4 0c             	add    $0xc,%esp
f0102262:	6a 01                	push   $0x1
f0102264:	6a 00                	push   $0x0
f0102266:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f010226c:	e8 42 ed ff ff       	call   f0100fb3 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102271:	89 fa                	mov    %edi,%edx
f0102273:	2b 15 90 de 1d f0    	sub    0xf01dde90,%edx
f0102279:	c1 fa 03             	sar    $0x3,%edx
f010227c:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010227f:	89 d0                	mov    %edx,%eax
f0102281:	c1 e8 0c             	shr    $0xc,%eax
f0102284:	83 c4 10             	add    $0x10,%esp
f0102287:	3b 05 88 de 1d f0    	cmp    0xf01dde88,%eax
f010228d:	72 12                	jb     f01022a1 <mem_init+0x1057>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010228f:	52                   	push   %edx
f0102290:	68 04 61 10 f0       	push   $0xf0106104
f0102295:	6a 58                	push   $0x58
f0102297:	68 29 70 10 f0       	push   $0xf0107029
f010229c:	e8 9f dd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01022a1:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01022a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01022aa:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01022b0:	f6 00 01             	testb  $0x1,(%eax)
f01022b3:	74 19                	je     f01022ce <mem_init+0x1084>
f01022b5:	68 bd 72 10 f0       	push   $0xf01072bd
f01022ba:	68 43 70 10 f0       	push   $0xf0107043
f01022bf:	68 52 04 00 00       	push   $0x452
f01022c4:	68 1d 70 10 f0       	push   $0xf010701d
f01022c9:	e8 72 dd ff ff       	call   f0100040 <_panic>
f01022ce:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01022d1:	39 c2                	cmp    %eax,%edx
f01022d3:	75 db                	jne    f01022b0 <mem_init+0x1066>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01022d5:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
f01022da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01022e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022e3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01022e9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01022ec:	89 0d 40 d2 1d f0    	mov    %ecx,0xf01dd240

	// free the pages we took
	page_free(pp0);
f01022f2:	83 ec 0c             	sub    $0xc,%esp
f01022f5:	50                   	push   %eax
f01022f6:	e8 56 ec ff ff       	call   f0100f51 <page_free>
	page_free(pp1);
f01022fb:	89 1c 24             	mov    %ebx,(%esp)
f01022fe:	e8 4e ec ff ff       	call   f0100f51 <page_free>
	page_free(pp2);
f0102303:	89 34 24             	mov    %esi,(%esp)
f0102306:	e8 46 ec ff ff       	call   f0100f51 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010230b:	83 c4 08             	add    $0x8,%esp
f010230e:	68 01 10 00 00       	push   $0x1001
f0102313:	6a 00                	push   $0x0
f0102315:	e8 cd ee ff ff       	call   f01011e7 <mmio_map_region>
f010231a:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010231c:	83 c4 08             	add    $0x8,%esp
f010231f:	68 00 10 00 00       	push   $0x1000
f0102324:	6a 00                	push   $0x0
f0102326:	e8 bc ee ff ff       	call   f01011e7 <mmio_map_region>
f010232b:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010232d:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102333:	83 c4 10             	add    $0x10,%esp
f0102336:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010233c:	76 07                	jbe    f0102345 <mem_init+0x10fb>
f010233e:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102343:	76 19                	jbe    f010235e <mem_init+0x1114>
f0102345:	68 98 6c 10 f0       	push   $0xf0106c98
f010234a:	68 43 70 10 f0       	push   $0xf0107043
f010234f:	68 62 04 00 00       	push   $0x462
f0102354:	68 1d 70 10 f0       	push   $0xf010701d
f0102359:	e8 e2 dc ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010235e:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102364:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010236a:	77 08                	ja     f0102374 <mem_init+0x112a>
f010236c:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102372:	77 19                	ja     f010238d <mem_init+0x1143>
f0102374:	68 c0 6c 10 f0       	push   $0xf0106cc0
f0102379:	68 43 70 10 f0       	push   $0xf0107043
f010237e:	68 63 04 00 00       	push   $0x463
f0102383:	68 1d 70 10 f0       	push   $0xf010701d
f0102388:	e8 b3 dc ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010238d:	89 da                	mov    %ebx,%edx
f010238f:	09 f2                	or     %esi,%edx
f0102391:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102397:	74 19                	je     f01023b2 <mem_init+0x1168>
f0102399:	68 e8 6c 10 f0       	push   $0xf0106ce8
f010239e:	68 43 70 10 f0       	push   $0xf0107043
f01023a3:	68 65 04 00 00       	push   $0x465
f01023a8:	68 1d 70 10 f0       	push   $0xf010701d
f01023ad:	e8 8e dc ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01023b2:	39 c6                	cmp    %eax,%esi
f01023b4:	73 19                	jae    f01023cf <mem_init+0x1185>
f01023b6:	68 d4 72 10 f0       	push   $0xf01072d4
f01023bb:	68 43 70 10 f0       	push   $0xf0107043
f01023c0:	68 67 04 00 00       	push   $0x467
f01023c5:	68 1d 70 10 f0       	push   $0xf010701d
f01023ca:	e8 71 dc ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01023cf:	8b 3d 8c de 1d f0    	mov    0xf01dde8c,%edi
f01023d5:	89 da                	mov    %ebx,%edx
f01023d7:	89 f8                	mov    %edi,%eax
f01023d9:	e8 f1 e6 ff ff       	call   f0100acf <check_va2pa>
f01023de:	85 c0                	test   %eax,%eax
f01023e0:	74 19                	je     f01023fb <mem_init+0x11b1>
f01023e2:	68 10 6d 10 f0       	push   $0xf0106d10
f01023e7:	68 43 70 10 f0       	push   $0xf0107043
f01023ec:	68 69 04 00 00       	push   $0x469
f01023f1:	68 1d 70 10 f0       	push   $0xf010701d
f01023f6:	e8 45 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01023fb:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102401:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102404:	89 c2                	mov    %eax,%edx
f0102406:	89 f8                	mov    %edi,%eax
f0102408:	e8 c2 e6 ff ff       	call   f0100acf <check_va2pa>
f010240d:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102412:	74 19                	je     f010242d <mem_init+0x11e3>
f0102414:	68 34 6d 10 f0       	push   $0xf0106d34
f0102419:	68 43 70 10 f0       	push   $0xf0107043
f010241e:	68 6a 04 00 00       	push   $0x46a
f0102423:	68 1d 70 10 f0       	push   $0xf010701d
f0102428:	e8 13 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010242d:	89 f2                	mov    %esi,%edx
f010242f:	89 f8                	mov    %edi,%eax
f0102431:	e8 99 e6 ff ff       	call   f0100acf <check_va2pa>
f0102436:	85 c0                	test   %eax,%eax
f0102438:	74 19                	je     f0102453 <mem_init+0x1209>
f010243a:	68 64 6d 10 f0       	push   $0xf0106d64
f010243f:	68 43 70 10 f0       	push   $0xf0107043
f0102444:	68 6b 04 00 00       	push   $0x46b
f0102449:	68 1d 70 10 f0       	push   $0xf010701d
f010244e:	e8 ed db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102453:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102459:	89 f8                	mov    %edi,%eax
f010245b:	e8 6f e6 ff ff       	call   f0100acf <check_va2pa>
f0102460:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102463:	74 19                	je     f010247e <mem_init+0x1234>
f0102465:	68 88 6d 10 f0       	push   $0xf0106d88
f010246a:	68 43 70 10 f0       	push   $0xf0107043
f010246f:	68 6c 04 00 00       	push   $0x46c
f0102474:	68 1d 70 10 f0       	push   $0xf010701d
f0102479:	e8 c2 db ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010247e:	83 ec 04             	sub    $0x4,%esp
f0102481:	6a 00                	push   $0x0
f0102483:	53                   	push   %ebx
f0102484:	57                   	push   %edi
f0102485:	e8 29 eb ff ff       	call   f0100fb3 <pgdir_walk>
f010248a:	83 c4 10             	add    $0x10,%esp
f010248d:	f6 00 1a             	testb  $0x1a,(%eax)
f0102490:	75 19                	jne    f01024ab <mem_init+0x1261>
f0102492:	68 b4 6d 10 f0       	push   $0xf0106db4
f0102497:	68 43 70 10 f0       	push   $0xf0107043
f010249c:	68 6e 04 00 00       	push   $0x46e
f01024a1:	68 1d 70 10 f0       	push   $0xf010701d
f01024a6:	e8 95 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01024ab:	83 ec 04             	sub    $0x4,%esp
f01024ae:	6a 00                	push   $0x0
f01024b0:	53                   	push   %ebx
f01024b1:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f01024b7:	e8 f7 ea ff ff       	call   f0100fb3 <pgdir_walk>
f01024bc:	8b 00                	mov    (%eax),%eax
f01024be:	83 c4 10             	add    $0x10,%esp
f01024c1:	83 e0 04             	and    $0x4,%eax
f01024c4:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01024c7:	74 19                	je     f01024e2 <mem_init+0x1298>
f01024c9:	68 f8 6d 10 f0       	push   $0xf0106df8
f01024ce:	68 43 70 10 f0       	push   $0xf0107043
f01024d3:	68 6f 04 00 00       	push   $0x46f
f01024d8:	68 1d 70 10 f0       	push   $0xf010701d
f01024dd:	e8 5e db ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01024e2:	83 ec 04             	sub    $0x4,%esp
f01024e5:	6a 00                	push   $0x0
f01024e7:	53                   	push   %ebx
f01024e8:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f01024ee:	e8 c0 ea ff ff       	call   f0100fb3 <pgdir_walk>
f01024f3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01024f9:	83 c4 0c             	add    $0xc,%esp
f01024fc:	6a 00                	push   $0x0
f01024fe:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102501:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f0102507:	e8 a7 ea ff ff       	call   f0100fb3 <pgdir_walk>
f010250c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102512:	83 c4 0c             	add    $0xc,%esp
f0102515:	6a 00                	push   $0x0
f0102517:	56                   	push   %esi
f0102518:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f010251e:	e8 90 ea ff ff       	call   f0100fb3 <pgdir_walk>
f0102523:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102529:	c7 04 24 e6 72 10 f0 	movl   $0xf01072e6,(%esp)
f0102530:	e8 47 11 00 00       	call   f010367c <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102535:	a1 90 de 1d f0       	mov    0xf01dde90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010253a:	83 c4 10             	add    $0x10,%esp
f010253d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102542:	77 15                	ja     f0102559 <mem_init+0x130f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102544:	50                   	push   %eax
f0102545:	68 28 61 10 f0       	push   $0xf0106128
f010254a:	68 d5 00 00 00       	push   $0xd5
f010254f:	68 1d 70 10 f0       	push   $0xf010701d
f0102554:	e8 e7 da ff ff       	call   f0100040 <_panic>
f0102559:	83 ec 08             	sub    $0x8,%esp
f010255c:	6a 04                	push   $0x4
f010255e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102563:	50                   	push   %eax
f0102564:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102569:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010256e:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
f0102573:	e8 ce ea ff ff       	call   f0101046 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102578:	a1 48 d2 1d f0       	mov    0xf01dd248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010257d:	83 c4 10             	add    $0x10,%esp
f0102580:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102585:	77 15                	ja     f010259c <mem_init+0x1352>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102587:	50                   	push   %eax
f0102588:	68 28 61 10 f0       	push   $0xf0106128
f010258d:	68 df 00 00 00       	push   $0xdf
f0102592:	68 1d 70 10 f0       	push   $0xf010701d
f0102597:	e8 a4 da ff ff       	call   f0100040 <_panic>
f010259c:	83 ec 08             	sub    $0x8,%esp
f010259f:	6a 04                	push   $0x4
f01025a1:	05 00 00 00 10       	add    $0x10000000,%eax
f01025a6:	50                   	push   %eax
f01025a7:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01025ac:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01025b1:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
f01025b6:	e8 8b ea ff ff       	call   f0101046 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025bb:	83 c4 10             	add    $0x10,%esp
f01025be:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f01025c3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025c8:	77 15                	ja     f01025df <mem_init+0x1395>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025ca:	50                   	push   %eax
f01025cb:	68 28 61 10 f0       	push   $0xf0106128
f01025d0:	68 ec 00 00 00       	push   $0xec
f01025d5:	68 1d 70 10 f0       	push   $0xf010701d
f01025da:	e8 61 da ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f01025df:	83 ec 08             	sub    $0x8,%esp
f01025e2:	6a 03                	push   $0x3
f01025e4:	68 00 60 11 00       	push   $0x116000
f01025e9:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01025ee:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01025f3:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
f01025f8:	e8 49 ea ff ff       	call   f0101046 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0x0, PTE_W | PTE_P);
f01025fd:	83 c4 08             	add    $0x8,%esp
f0102600:	6a 03                	push   $0x3
f0102602:	6a 00                	push   $0x0
f0102604:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102609:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010260e:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
f0102613:	e8 2e ea ff ff       	call   f0101046 <boot_map_region>
f0102618:	c7 45 c4 00 f0 1d f0 	movl   $0xf01df000,-0x3c(%ebp)
f010261f:	83 c4 10             	add    $0x10,%esp
f0102622:	bb 00 f0 1d f0       	mov    $0xf01df000,%ebx
f0102627:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010262c:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102632:	77 15                	ja     f0102649 <mem_init+0x13ff>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102634:	53                   	push   %ebx
f0102635:	68 28 61 10 f0       	push   $0xf0106128
f010263a:	68 30 01 00 00       	push   $0x130
f010263f:	68 1d 70 10 f0       	push   $0xf010701d
f0102644:	e8 f7 d9 ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
	uint32_t kstacktop_i = KSTACKTOP;
	int i=0;
	for(i=0; i<NCPU; i++) 
	{
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W | PTE_P);
f0102649:	83 ec 08             	sub    $0x8,%esp
f010264c:	6a 03                	push   $0x3
f010264e:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102654:	50                   	push   %eax
f0102655:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010265a:	89 f2                	mov    %esi,%edx
f010265c:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
f0102661:	e8 e0 e9 ff ff       	call   f0101046 <boot_map_region>
f0102666:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010266c:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uint32_t kstacktop_i = KSTACKTOP;
	int i=0;
	for(i=0; i<NCPU; i++) 
f0102672:	83 c4 10             	add    $0x10,%esp
f0102675:	b8 00 f0 21 f0       	mov    $0xf021f000,%eax
f010267a:	39 d8                	cmp    %ebx,%eax
f010267c:	75 ae                	jne    f010262c <mem_init+0x13e2>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010267e:	8b 3d 8c de 1d f0    	mov    0xf01dde8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102684:	a1 88 de 1d f0       	mov    0xf01dde88,%eax
f0102689:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010268c:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102693:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102698:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010269b:	8b 35 90 de 1d f0    	mov    0xf01dde90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026a1:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01026a4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01026a9:	eb 55                	jmp    f0102700 <mem_init+0x14b6>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026ab:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01026b1:	89 f8                	mov    %edi,%eax
f01026b3:	e8 17 e4 ff ff       	call   f0100acf <check_va2pa>
f01026b8:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01026bf:	77 15                	ja     f01026d6 <mem_init+0x148c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026c1:	56                   	push   %esi
f01026c2:	68 28 61 10 f0       	push   $0xf0106128
f01026c7:	68 87 03 00 00       	push   $0x387
f01026cc:	68 1d 70 10 f0       	push   $0xf010701d
f01026d1:	e8 6a d9 ff ff       	call   f0100040 <_panic>
f01026d6:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01026dd:	39 c2                	cmp    %eax,%edx
f01026df:	74 19                	je     f01026fa <mem_init+0x14b0>
f01026e1:	68 2c 6e 10 f0       	push   $0xf0106e2c
f01026e6:	68 43 70 10 f0       	push   $0xf0107043
f01026eb:	68 87 03 00 00       	push   $0x387
f01026f0:	68 1d 70 10 f0       	push   $0xf010701d
f01026f5:	e8 46 d9 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01026fa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102700:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102703:	77 a6                	ja     f01026ab <mem_init+0x1461>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102705:	8b 35 48 d2 1d f0    	mov    0xf01dd248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010270b:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010270e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102713:	89 da                	mov    %ebx,%edx
f0102715:	89 f8                	mov    %edi,%eax
f0102717:	e8 b3 e3 ff ff       	call   f0100acf <check_va2pa>
f010271c:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102723:	77 15                	ja     f010273a <mem_init+0x14f0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102725:	56                   	push   %esi
f0102726:	68 28 61 10 f0       	push   $0xf0106128
f010272b:	68 8c 03 00 00       	push   $0x38c
f0102730:	68 1d 70 10 f0       	push   $0xf010701d
f0102735:	e8 06 d9 ff ff       	call   f0100040 <_panic>
f010273a:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102741:	39 d0                	cmp    %edx,%eax
f0102743:	74 19                	je     f010275e <mem_init+0x1514>
f0102745:	68 60 6e 10 f0       	push   $0xf0106e60
f010274a:	68 43 70 10 f0       	push   $0xf0107043
f010274f:	68 8c 03 00 00       	push   $0x38c
f0102754:	68 1d 70 10 f0       	push   $0xf010701d
f0102759:	e8 e2 d8 ff ff       	call   f0100040 <_panic>
f010275e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102764:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f010276a:	75 a7                	jne    f0102713 <mem_init+0x14c9>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010276c:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010276f:	c1 e6 0c             	shl    $0xc,%esi
f0102772:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102777:	eb 30                	jmp    f01027a9 <mem_init+0x155f>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102779:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010277f:	89 f8                	mov    %edi,%eax
f0102781:	e8 49 e3 ff ff       	call   f0100acf <check_va2pa>
f0102786:	39 c3                	cmp    %eax,%ebx
f0102788:	74 19                	je     f01027a3 <mem_init+0x1559>
f010278a:	68 94 6e 10 f0       	push   $0xf0106e94
f010278f:	68 43 70 10 f0       	push   $0xf0107043
f0102794:	68 90 03 00 00       	push   $0x390
f0102799:	68 1d 70 10 f0       	push   $0xf010701d
f010279e:	e8 9d d8 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027a3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01027a9:	39 f3                	cmp    %esi,%ebx
f01027ab:	72 cc                	jb     f0102779 <mem_init+0x152f>
f01027ad:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01027b2:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01027b5:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01027b8:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01027bb:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f01027c1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01027c4:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01027c6:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01027c9:	05 00 80 00 20       	add    $0x20008000,%eax
f01027ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01027d1:	89 da                	mov    %ebx,%edx
f01027d3:	89 f8                	mov    %edi,%eax
f01027d5:	e8 f5 e2 ff ff       	call   f0100acf <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027da:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01027e0:	77 15                	ja     f01027f7 <mem_init+0x15ad>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027e2:	56                   	push   %esi
f01027e3:	68 28 61 10 f0       	push   $0xf0106128
f01027e8:	68 98 03 00 00       	push   $0x398
f01027ed:	68 1d 70 10 f0       	push   $0xf010701d
f01027f2:	e8 49 d8 ff ff       	call   f0100040 <_panic>
f01027f7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01027fa:	8d 94 0b 00 f0 1d f0 	lea    -0xfe21000(%ebx,%ecx,1),%edx
f0102801:	39 d0                	cmp    %edx,%eax
f0102803:	74 19                	je     f010281e <mem_init+0x15d4>
f0102805:	68 bc 6e 10 f0       	push   $0xf0106ebc
f010280a:	68 43 70 10 f0       	push   $0xf0107043
f010280f:	68 98 03 00 00       	push   $0x398
f0102814:	68 1d 70 10 f0       	push   $0xf010701d
f0102819:	e8 22 d8 ff ff       	call   f0100040 <_panic>
f010281e:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102824:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102827:	75 a8                	jne    f01027d1 <mem_init+0x1587>
f0102829:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010282c:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102832:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102835:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102837:	89 da                	mov    %ebx,%edx
f0102839:	89 f8                	mov    %edi,%eax
f010283b:	e8 8f e2 ff ff       	call   f0100acf <check_va2pa>
f0102840:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102843:	74 19                	je     f010285e <mem_init+0x1614>
f0102845:	68 04 6f 10 f0       	push   $0xf0106f04
f010284a:	68 43 70 10 f0       	push   $0xf0107043
f010284f:	68 9a 03 00 00       	push   $0x39a
f0102854:	68 1d 70 10 f0       	push   $0xf010701d
f0102859:	e8 e2 d7 ff ff       	call   f0100040 <_panic>
f010285e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102864:	39 de                	cmp    %ebx,%esi
f0102866:	75 cf                	jne    f0102837 <mem_init+0x15ed>
f0102868:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010286b:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102872:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102879:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010287f:	b8 00 f0 21 f0       	mov    $0xf021f000,%eax
f0102884:	39 f0                	cmp    %esi,%eax
f0102886:	0f 85 2c ff ff ff    	jne    f01027b8 <mem_init+0x156e>
f010288c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102891:	eb 2a                	jmp    f01028bd <mem_init+0x1673>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}
	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102893:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102899:	83 fa 04             	cmp    $0x4,%edx
f010289c:	77 1f                	ja     f01028bd <mem_init+0x1673>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010289e:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f01028a2:	75 7e                	jne    f0102922 <mem_init+0x16d8>
f01028a4:	68 ff 72 10 f0       	push   $0xf01072ff
f01028a9:	68 43 70 10 f0       	push   $0xf0107043
f01028ae:	68 a4 03 00 00       	push   $0x3a4
f01028b3:	68 1d 70 10 f0       	push   $0xf010701d
f01028b8:	e8 83 d7 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01028bd:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01028c2:	76 3f                	jbe    f0102903 <mem_init+0x16b9>
				assert(pgdir[i] & PTE_P);
f01028c4:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01028c7:	f6 c2 01             	test   $0x1,%dl
f01028ca:	75 19                	jne    f01028e5 <mem_init+0x169b>
f01028cc:	68 ff 72 10 f0       	push   $0xf01072ff
f01028d1:	68 43 70 10 f0       	push   $0xf0107043
f01028d6:	68 a8 03 00 00       	push   $0x3a8
f01028db:	68 1d 70 10 f0       	push   $0xf010701d
f01028e0:	e8 5b d7 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01028e5:	f6 c2 02             	test   $0x2,%dl
f01028e8:	75 38                	jne    f0102922 <mem_init+0x16d8>
f01028ea:	68 10 73 10 f0       	push   $0xf0107310
f01028ef:	68 43 70 10 f0       	push   $0xf0107043
f01028f4:	68 a9 03 00 00       	push   $0x3a9
f01028f9:	68 1d 70 10 f0       	push   $0xf010701d
f01028fe:	e8 3d d7 ff ff       	call   f0100040 <_panic>
			} else {
				assert(pgdir[i] == 0);
f0102903:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102907:	74 19                	je     f0102922 <mem_init+0x16d8>
f0102909:	68 21 73 10 f0       	push   $0xf0107321
f010290e:	68 43 70 10 f0       	push   $0xf0107043
f0102913:	68 ab 03 00 00       	push   $0x3ab
f0102918:	68 1d 70 10 f0       	push   $0xf010701d
f010291d:	e8 1e d7 ff ff       	call   f0100040 <_panic>
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}
	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102922:	83 c0 01             	add    $0x1,%eax
f0102925:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010292a:	0f 86 63 ff ff ff    	jbe    f0102893 <mem_init+0x1649>
				assert(pgdir[i] == 0);
			}
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102930:	83 ec 0c             	sub    $0xc,%esp
f0102933:	68 28 6f 10 f0       	push   $0xf0106f28
f0102938:	e8 3f 0d 00 00       	call   f010367c <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010293d:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102942:	83 c4 10             	add    $0x10,%esp
f0102945:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010294a:	77 15                	ja     f0102961 <mem_init+0x1717>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010294c:	50                   	push   %eax
f010294d:	68 28 61 10 f0       	push   $0xf0106128
f0102952:	68 07 01 00 00       	push   $0x107
f0102957:	68 1d 70 10 f0       	push   $0xf010701d
f010295c:	e8 df d6 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102961:	05 00 00 00 10       	add    $0x10000000,%eax
f0102966:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102969:	b8 00 00 00 00       	mov    $0x0,%eax
f010296e:	e8 c0 e1 ff ff       	call   f0100b33 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102973:	0f 20 c0             	mov    %cr0,%eax
f0102976:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102979:	0d 23 00 05 80       	or     $0x80050023,%eax
f010297e:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102981:	83 ec 0c             	sub    $0xc,%esp
f0102984:	6a 00                	push   $0x0
f0102986:	e8 56 e5 ff ff       	call   f0100ee1 <page_alloc>
f010298b:	89 c3                	mov    %eax,%ebx
f010298d:	83 c4 10             	add    $0x10,%esp
f0102990:	85 c0                	test   %eax,%eax
f0102992:	75 19                	jne    f01029ad <mem_init+0x1763>
f0102994:	68 0b 71 10 f0       	push   $0xf010710b
f0102999:	68 43 70 10 f0       	push   $0xf0107043
f010299e:	68 84 04 00 00       	push   $0x484
f01029a3:	68 1d 70 10 f0       	push   $0xf010701d
f01029a8:	e8 93 d6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01029ad:	83 ec 0c             	sub    $0xc,%esp
f01029b0:	6a 00                	push   $0x0
f01029b2:	e8 2a e5 ff ff       	call   f0100ee1 <page_alloc>
f01029b7:	89 c7                	mov    %eax,%edi
f01029b9:	83 c4 10             	add    $0x10,%esp
f01029bc:	85 c0                	test   %eax,%eax
f01029be:	75 19                	jne    f01029d9 <mem_init+0x178f>
f01029c0:	68 21 71 10 f0       	push   $0xf0107121
f01029c5:	68 43 70 10 f0       	push   $0xf0107043
f01029ca:	68 85 04 00 00       	push   $0x485
f01029cf:	68 1d 70 10 f0       	push   $0xf010701d
f01029d4:	e8 67 d6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01029d9:	83 ec 0c             	sub    $0xc,%esp
f01029dc:	6a 00                	push   $0x0
f01029de:	e8 fe e4 ff ff       	call   f0100ee1 <page_alloc>
f01029e3:	89 c6                	mov    %eax,%esi
f01029e5:	83 c4 10             	add    $0x10,%esp
f01029e8:	85 c0                	test   %eax,%eax
f01029ea:	75 19                	jne    f0102a05 <mem_init+0x17bb>
f01029ec:	68 37 71 10 f0       	push   $0xf0107137
f01029f1:	68 43 70 10 f0       	push   $0xf0107043
f01029f6:	68 86 04 00 00       	push   $0x486
f01029fb:	68 1d 70 10 f0       	push   $0xf010701d
f0102a00:	e8 3b d6 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102a05:	83 ec 0c             	sub    $0xc,%esp
f0102a08:	53                   	push   %ebx
f0102a09:	e8 43 e5 ff ff       	call   f0100f51 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a0e:	89 f8                	mov    %edi,%eax
f0102a10:	2b 05 90 de 1d f0    	sub    0xf01dde90,%eax
f0102a16:	c1 f8 03             	sar    $0x3,%eax
f0102a19:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a1c:	89 c2                	mov    %eax,%edx
f0102a1e:	c1 ea 0c             	shr    $0xc,%edx
f0102a21:	83 c4 10             	add    $0x10,%esp
f0102a24:	3b 15 88 de 1d f0    	cmp    0xf01dde88,%edx
f0102a2a:	72 12                	jb     f0102a3e <mem_init+0x17f4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a2c:	50                   	push   %eax
f0102a2d:	68 04 61 10 f0       	push   $0xf0106104
f0102a32:	6a 58                	push   $0x58
f0102a34:	68 29 70 10 f0       	push   $0xf0107029
f0102a39:	e8 02 d6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a3e:	83 ec 04             	sub    $0x4,%esp
f0102a41:	68 00 10 00 00       	push   $0x1000
f0102a46:	6a 01                	push   $0x1
f0102a48:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a4d:	50                   	push   %eax
f0102a4e:	e8 df 29 00 00       	call   f0105432 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a53:	89 f0                	mov    %esi,%eax
f0102a55:	2b 05 90 de 1d f0    	sub    0xf01dde90,%eax
f0102a5b:	c1 f8 03             	sar    $0x3,%eax
f0102a5e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a61:	89 c2                	mov    %eax,%edx
f0102a63:	c1 ea 0c             	shr    $0xc,%edx
f0102a66:	83 c4 10             	add    $0x10,%esp
f0102a69:	3b 15 88 de 1d f0    	cmp    0xf01dde88,%edx
f0102a6f:	72 12                	jb     f0102a83 <mem_init+0x1839>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a71:	50                   	push   %eax
f0102a72:	68 04 61 10 f0       	push   $0xf0106104
f0102a77:	6a 58                	push   $0x58
f0102a79:	68 29 70 10 f0       	push   $0xf0107029
f0102a7e:	e8 bd d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102a83:	83 ec 04             	sub    $0x4,%esp
f0102a86:	68 00 10 00 00       	push   $0x1000
f0102a8b:	6a 02                	push   $0x2
f0102a8d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a92:	50                   	push   %eax
f0102a93:	e8 9a 29 00 00       	call   f0105432 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102a98:	6a 02                	push   $0x2
f0102a9a:	68 00 10 00 00       	push   $0x1000
f0102a9f:	57                   	push   %edi
f0102aa0:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f0102aa6:	e8 bf e6 ff ff       	call   f010116a <page_insert>
	assert(pp1->pp_ref == 1);
f0102aab:	83 c4 20             	add    $0x20,%esp
f0102aae:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ab3:	74 19                	je     f0102ace <mem_init+0x1884>
f0102ab5:	68 08 72 10 f0       	push   $0xf0107208
f0102aba:	68 43 70 10 f0       	push   $0xf0107043
f0102abf:	68 8b 04 00 00       	push   $0x48b
f0102ac4:	68 1d 70 10 f0       	push   $0xf010701d
f0102ac9:	e8 72 d5 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ace:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102ad5:	01 01 01 
f0102ad8:	74 19                	je     f0102af3 <mem_init+0x18a9>
f0102ada:	68 48 6f 10 f0       	push   $0xf0106f48
f0102adf:	68 43 70 10 f0       	push   $0xf0107043
f0102ae4:	68 8c 04 00 00       	push   $0x48c
f0102ae9:	68 1d 70 10 f0       	push   $0xf010701d
f0102aee:	e8 4d d5 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102af3:	6a 02                	push   $0x2
f0102af5:	68 00 10 00 00       	push   $0x1000
f0102afa:	56                   	push   %esi
f0102afb:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f0102b01:	e8 64 e6 ff ff       	call   f010116a <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b06:	83 c4 10             	add    $0x10,%esp
f0102b09:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b10:	02 02 02 
f0102b13:	74 19                	je     f0102b2e <mem_init+0x18e4>
f0102b15:	68 6c 6f 10 f0       	push   $0xf0106f6c
f0102b1a:	68 43 70 10 f0       	push   $0xf0107043
f0102b1f:	68 8e 04 00 00       	push   $0x48e
f0102b24:	68 1d 70 10 f0       	push   $0xf010701d
f0102b29:	e8 12 d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102b2e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102b33:	74 19                	je     f0102b4e <mem_init+0x1904>
f0102b35:	68 2a 72 10 f0       	push   $0xf010722a
f0102b3a:	68 43 70 10 f0       	push   $0xf0107043
f0102b3f:	68 8f 04 00 00       	push   $0x48f
f0102b44:	68 1d 70 10 f0       	push   $0xf010701d
f0102b49:	e8 f2 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102b4e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102b53:	74 19                	je     f0102b6e <mem_init+0x1924>
f0102b55:	68 94 72 10 f0       	push   $0xf0107294
f0102b5a:	68 43 70 10 f0       	push   $0xf0107043
f0102b5f:	68 90 04 00 00       	push   $0x490
f0102b64:	68 1d 70 10 f0       	push   $0xf010701d
f0102b69:	e8 d2 d4 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102b6e:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102b75:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b78:	89 f0                	mov    %esi,%eax
f0102b7a:	2b 05 90 de 1d f0    	sub    0xf01dde90,%eax
f0102b80:	c1 f8 03             	sar    $0x3,%eax
f0102b83:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b86:	89 c2                	mov    %eax,%edx
f0102b88:	c1 ea 0c             	shr    $0xc,%edx
f0102b8b:	3b 15 88 de 1d f0    	cmp    0xf01dde88,%edx
f0102b91:	72 12                	jb     f0102ba5 <mem_init+0x195b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b93:	50                   	push   %eax
f0102b94:	68 04 61 10 f0       	push   $0xf0106104
f0102b99:	6a 58                	push   $0x58
f0102b9b:	68 29 70 10 f0       	push   $0xf0107029
f0102ba0:	e8 9b d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ba5:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102bac:	03 03 03 
f0102baf:	74 19                	je     f0102bca <mem_init+0x1980>
f0102bb1:	68 90 6f 10 f0       	push   $0xf0106f90
f0102bb6:	68 43 70 10 f0       	push   $0xf0107043
f0102bbb:	68 92 04 00 00       	push   $0x492
f0102bc0:	68 1d 70 10 f0       	push   $0xf010701d
f0102bc5:	e8 76 d4 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102bca:	83 ec 08             	sub    $0x8,%esp
f0102bcd:	68 00 10 00 00       	push   $0x1000
f0102bd2:	ff 35 8c de 1d f0    	pushl  0xf01dde8c
f0102bd8:	e8 52 e5 ff ff       	call   f010112f <page_remove>
	assert(pp2->pp_ref == 0);
f0102bdd:	83 c4 10             	add    $0x10,%esp
f0102be0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102be5:	74 19                	je     f0102c00 <mem_init+0x19b6>
f0102be7:	68 62 72 10 f0       	push   $0xf0107262
f0102bec:	68 43 70 10 f0       	push   $0xf0107043
f0102bf1:	68 94 04 00 00       	push   $0x494
f0102bf6:	68 1d 70 10 f0       	push   $0xf010701d
f0102bfb:	e8 40 d4 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c00:	8b 0d 8c de 1d f0    	mov    0xf01dde8c,%ecx
f0102c06:	8b 11                	mov    (%ecx),%edx
f0102c08:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102c0e:	89 d8                	mov    %ebx,%eax
f0102c10:	2b 05 90 de 1d f0    	sub    0xf01dde90,%eax
f0102c16:	c1 f8 03             	sar    $0x3,%eax
f0102c19:	c1 e0 0c             	shl    $0xc,%eax
f0102c1c:	39 c2                	cmp    %eax,%edx
f0102c1e:	74 19                	je     f0102c39 <mem_init+0x19ef>
f0102c20:	68 18 69 10 f0       	push   $0xf0106918
f0102c25:	68 43 70 10 f0       	push   $0xf0107043
f0102c2a:	68 97 04 00 00       	push   $0x497
f0102c2f:	68 1d 70 10 f0       	push   $0xf010701d
f0102c34:	e8 07 d4 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102c39:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102c3f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102c44:	74 19                	je     f0102c5f <mem_init+0x1a15>
f0102c46:	68 19 72 10 f0       	push   $0xf0107219
f0102c4b:	68 43 70 10 f0       	push   $0xf0107043
f0102c50:	68 99 04 00 00       	push   $0x499
f0102c55:	68 1d 70 10 f0       	push   $0xf010701d
f0102c5a:	e8 e1 d3 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102c5f:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102c65:	83 ec 0c             	sub    $0xc,%esp
f0102c68:	53                   	push   %ebx
f0102c69:	e8 e3 e2 ff ff       	call   f0100f51 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102c6e:	c7 04 24 bc 6f 10 f0 	movl   $0xf0106fbc,(%esp)
f0102c75:	e8 02 0a 00 00       	call   f010367c <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102c7a:	83 c4 10             	add    $0x10,%esp
f0102c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c80:	5b                   	pop    %ebx
f0102c81:	5e                   	pop    %esi
f0102c82:	5f                   	pop    %edi
f0102c83:	5d                   	pop    %ebp
f0102c84:	c3                   	ret    

f0102c85 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102c85:	55                   	push   %ebp
f0102c86:	89 e5                	mov    %esp,%ebp
f0102c88:	57                   	push   %edi
f0102c89:	56                   	push   %esi
f0102c8a:	53                   	push   %ebx
f0102c8b:	83 ec 1c             	sub    $0x1c,%esp
f0102c8e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102c91:	8b 45 0c             	mov    0xc(%ebp),%eax
	// LAB 3: Your code here.
	uintptr_t mem_start = (uintptr_t) va;
f0102c94:	89 c3                	mov    %eax,%ebx
	
	uintptr_t mem_end = (uintptr_t) ROUNDUP(((uintptr_t) va + len), PGSIZE);
f0102c96:	8b 55 10             	mov    0x10(%ebp),%edx
f0102c99:	8d 84 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%eax
f0102ca0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102ca5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	
	perm = perm | PTE_P ;
f0102ca8:	8b 75 14             	mov    0x14(%ebp),%esi
f0102cab:	83 ce 01             	or     $0x1,%esi
	
	uintptr_t i;
				
	while(mem_start < mem_end){
f0102cae:	eb 4b                	jmp    f0102cfb <user_mem_check+0x76>
		
		if ((uint32_t)mem_start >= ULIM){
f0102cb0:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102cb6:	76 0d                	jbe    f0102cc5 <user_mem_check+0x40>
		
			user_mem_check_addr = (uintptr_t) mem_start;
f0102cb8:	89 1d 3c d2 1d f0    	mov    %ebx,0xf01dd23c
			return -E_FAULT;
f0102cbe:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102cc3:	eb 40                	jmp    f0102d05 <user_mem_check+0x80>
		}		
		
		pte_t * pte = pgdir_walk(env->env_pgdir, (void *) mem_start, 0);
f0102cc5:	83 ec 04             	sub    $0x4,%esp
f0102cc8:	6a 00                	push   $0x0
f0102cca:	53                   	push   %ebx
f0102ccb:	ff 77 60             	pushl  0x60(%edi)
f0102cce:	e8 e0 e2 ff ff       	call   f0100fb3 <pgdir_walk>
				
		if (pte == NULL || (((uint32_t) *pte & perm)!=perm)){
f0102cd3:	83 c4 10             	add    $0x10,%esp
f0102cd6:	85 c0                	test   %eax,%eax
f0102cd8:	74 08                	je     f0102ce2 <user_mem_check+0x5d>
f0102cda:	89 f1                	mov    %esi,%ecx
f0102cdc:	23 08                	and    (%eax),%ecx
f0102cde:	39 ce                	cmp    %ecx,%esi
f0102ce0:	74 0d                	je     f0102cef <user_mem_check+0x6a>
			
			user_mem_check_addr = (uintptr_t) mem_start;
f0102ce2:	89 1d 3c d2 1d f0    	mov    %ebx,0xf01dd23c
			return -E_FAULT;	
f0102ce8:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102ced:	eb 16                	jmp    f0102d05 <user_mem_check+0x80>
		
		}
		mem_start = (uintptr_t) ROUNDDOWN((uintptr_t) mem_start, PGSIZE);
f0102cef:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		mem_start += PGSIZE;	
f0102cf5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	
	perm = perm | PTE_P ;
	
	uintptr_t i;
				
	while(mem_start < mem_end){
f0102cfb:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102cfe:	72 b0                	jb     f0102cb0 <user_mem_check+0x2b>
		}
		mem_start = (uintptr_t) ROUNDDOWN((uintptr_t) mem_start, PGSIZE);
		mem_start += PGSIZE;	
	}

	return 0;
f0102d00:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d08:	5b                   	pop    %ebx
f0102d09:	5e                   	pop    %esi
f0102d0a:	5f                   	pop    %edi
f0102d0b:	5d                   	pop    %ebp
f0102d0c:	c3                   	ret    

f0102d0d <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102d0d:	55                   	push   %ebp
f0102d0e:	89 e5                	mov    %esp,%ebp
f0102d10:	53                   	push   %ebx
f0102d11:	83 ec 04             	sub    $0x4,%esp
f0102d14:	8b 5d 08             	mov    0x8(%ebp),%ebx
//	cprintf("SRHS: va passed to mem_assert is %08x \n",va);
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102d17:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d1a:	83 c8 04             	or     $0x4,%eax
f0102d1d:	50                   	push   %eax
f0102d1e:	ff 75 10             	pushl  0x10(%ebp)
f0102d21:	ff 75 0c             	pushl  0xc(%ebp)
f0102d24:	53                   	push   %ebx
f0102d25:	e8 5b ff ff ff       	call   f0102c85 <user_mem_check>
f0102d2a:	83 c4 10             	add    $0x10,%esp
f0102d2d:	85 c0                	test   %eax,%eax
f0102d2f:	79 21                	jns    f0102d52 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102d31:	83 ec 04             	sub    $0x4,%esp
f0102d34:	ff 35 3c d2 1d f0    	pushl  0xf01dd23c
f0102d3a:	ff 73 48             	pushl  0x48(%ebx)
f0102d3d:	68 e8 6f 10 f0       	push   $0xf0106fe8
f0102d42:	e8 35 09 00 00       	call   f010367c <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102d47:	89 1c 24             	mov    %ebx,(%esp)
f0102d4a:	e8 36 06 00 00       	call   f0103385 <env_destroy>
f0102d4f:	83 c4 10             	add    $0x10,%esp
	}
}
f0102d52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102d55:	c9                   	leave  
f0102d56:	c3                   	ret    

f0102d57 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102d57:	55                   	push   %ebp
f0102d58:	89 e5                	mov    %esp,%ebp
f0102d5a:	57                   	push   %edi
f0102d5b:	56                   	push   %esi
f0102d5c:	53                   	push   %ebx
f0102d5d:	83 ec 0c             	sub    $0xc,%esp
f0102d60:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)
	
	void *region_alloc_start = (void *) ROUNDDOWN((uint32_t) va, PGSIZE);
f0102d62:	89 d3                	mov    %edx,%ebx
f0102d64:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	void *region_alloc_end = (void *) ROUNDUP(((uint32_t) va + len), PGSIZE);
f0102d6a:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0102d71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d76:	89 c6                	mov    %eax,%esi
	
	if ((uint32_t)region_alloc_end > UTOP)
f0102d78:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f0102d7d:	76 6d                	jbe    f0102dec <region_alloc+0x95>
		panic("region_alloc failed: Cannot allocate memory above UTOP");
f0102d7f:	83 ec 04             	sub    $0x4,%esp
f0102d82:	68 30 73 10 f0       	push   $0xf0107330
f0102d87:	68 31 01 00 00       	push   $0x131
f0102d8c:	68 14 74 10 f0       	push   $0xf0107414
f0102d91:	e8 aa d2 ff ff       	call   f0100040 <_panic>
	//for(region_alloc_start; region_alloc_start < region_alloc_end; region_alloc_start += PGSIZE){
	struct PageInfo *page;
	
	while(region_alloc_start < region_alloc_end){
	
		page = page_alloc(0);
f0102d96:	83 ec 0c             	sub    $0xc,%esp
f0102d99:	6a 00                	push   $0x0
f0102d9b:	e8 41 e1 ff ff       	call   f0100ee1 <page_alloc>
		
		if (page == NULL) 
f0102da0:	83 c4 10             	add    $0x10,%esp
f0102da3:	85 c0                	test   %eax,%eax
f0102da5:	75 17                	jne    f0102dbe <region_alloc+0x67>
			panic("region_alloc failed: Allocation failed!");
f0102da7:	83 ec 04             	sub    $0x4,%esp
f0102daa:	68 68 73 10 f0       	push   $0xf0107368
f0102daf:	68 3b 01 00 00       	push   $0x13b
f0102db4:	68 14 74 10 f0       	push   $0xf0107414
f0102db9:	e8 82 d2 ff ff       	call   f0100040 <_panic>
	
		int r = page_insert(e->env_pgdir, page, region_alloc_start, (PTE_W | PTE_U));	
f0102dbe:	6a 06                	push   $0x6
f0102dc0:	53                   	push   %ebx
f0102dc1:	50                   	push   %eax
f0102dc2:	ff 77 60             	pushl  0x60(%edi)
f0102dc5:	e8 a0 e3 ff ff       	call   f010116a <page_insert>
		
		if(r != 0)
f0102dca:	83 c4 10             	add    $0x10,%esp
f0102dcd:	85 c0                	test   %eax,%eax
f0102dcf:	74 15                	je     f0102de6 <region_alloc+0x8f>
			panic("region_alloc: %e", r);
f0102dd1:	50                   	push   %eax
f0102dd2:	68 1f 74 10 f0       	push   $0xf010741f
f0102dd7:	68 40 01 00 00       	push   $0x140
f0102ddc:	68 14 74 10 f0       	push   $0xf0107414
f0102de1:	e8 5a d2 ff ff       	call   f0100040 <_panic>
	
		region_alloc_start += PGSIZE;
f0102de6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		panic("region_alloc failed: Cannot allocate memory above UTOP");
	
	//for(region_alloc_start; region_alloc_start < region_alloc_end; region_alloc_start += PGSIZE){
	struct PageInfo *page;
	
	while(region_alloc_start < region_alloc_end){
f0102dec:	39 f3                	cmp    %esi,%ebx
f0102dee:	72 a6                	jb     f0102d96 <region_alloc+0x3f>
	
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102df3:	5b                   	pop    %ebx
f0102df4:	5e                   	pop    %esi
f0102df5:	5f                   	pop    %edi
f0102df6:	5d                   	pop    %ebp
f0102df7:	c3                   	ret    

f0102df8 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102df8:	55                   	push   %ebp
f0102df9:	89 e5                	mov    %esp,%ebp
f0102dfb:	56                   	push   %esi
f0102dfc:	53                   	push   %ebx
f0102dfd:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e00:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e03:	85 c0                	test   %eax,%eax
f0102e05:	75 1a                	jne    f0102e21 <envid2env+0x29>
		*env_store = curenv;
f0102e07:	e8 46 2c 00 00       	call   f0105a52 <cpunum>
f0102e0c:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e0f:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f0102e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e18:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102e1a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e1f:	eb 70                	jmp    f0102e91 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102e21:	89 c3                	mov    %eax,%ebx
f0102e23:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102e29:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102e2c:	03 1d 48 d2 1d f0    	add    0xf01dd248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102e32:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102e36:	74 05                	je     f0102e3d <envid2env+0x45>
f0102e38:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102e3b:	74 10                	je     f0102e4d <envid2env+0x55>
		*env_store = 0;
f0102e3d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e40:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102e46:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e4b:	eb 44                	jmp    f0102e91 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102e4d:	84 d2                	test   %dl,%dl
f0102e4f:	74 36                	je     f0102e87 <envid2env+0x8f>
f0102e51:	e8 fc 2b 00 00       	call   f0105a52 <cpunum>
f0102e56:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e59:	3b 98 28 e0 1d f0    	cmp    -0xfe21fd8(%eax),%ebx
f0102e5f:	74 26                	je     f0102e87 <envid2env+0x8f>
f0102e61:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102e64:	e8 e9 2b 00 00       	call   f0105a52 <cpunum>
f0102e69:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e6c:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f0102e72:	3b 70 48             	cmp    0x48(%eax),%esi
f0102e75:	74 10                	je     f0102e87 <envid2env+0x8f>
		*env_store = 0;
f0102e77:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e7a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102e80:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e85:	eb 0a                	jmp    f0102e91 <envid2env+0x99>
	}

	*env_store = e;
f0102e87:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e8a:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102e8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102e91:	5b                   	pop    %ebx
f0102e92:	5e                   	pop    %esi
f0102e93:	5d                   	pop    %ebp
f0102e94:	c3                   	ret    

f0102e95 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102e95:	55                   	push   %ebp
f0102e96:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102e98:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f0102e9d:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102ea0:	b8 23 00 00 00       	mov    $0x23,%eax
f0102ea5:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102ea7:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102ea9:	b8 10 00 00 00       	mov    $0x10,%eax
f0102eae:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102eb0:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102eb2:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102eb4:	ea bb 2e 10 f0 08 00 	ljmp   $0x8,$0xf0102ebb
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102ebb:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ec0:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102ec3:	5d                   	pop    %ebp
f0102ec4:	c3                   	ret    

f0102ec5 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102ec5:	55                   	push   %ebp
f0102ec6:	89 e5                	mov    %esp,%ebp
f0102ec8:	56                   	push   %esi
f0102ec9:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = NULL;
f0102eca:	c7 05 4c d2 1d f0 00 	movl   $0x0,0xf01dd24c
f0102ed1:	00 00 00 
	int i;
	
	cprintf("PDX(UTOP) %u\n", PDX(UTOP) );
f0102ed4:	83 ec 08             	sub    $0x8,%esp
f0102ed7:	68 bb 03 00 00       	push   $0x3bb
f0102edc:	68 30 74 10 f0       	push   $0xf0107430
f0102ee1:	e8 96 07 00 00       	call   f010367c <cprintf>
	for (i = (NENV - 1); i >= 0; --i){
	
		envs[i].env_status = ENV_FREE;
f0102ee6:	8b 35 48 d2 1d f0    	mov    0xf01dd248,%esi
f0102eec:	8b 15 4c d2 1d f0    	mov    0xf01dd24c,%edx
f0102ef2:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102ef8:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102efb:	83 c4 10             	add    $0x10,%esp
f0102efe:	89 c1                	mov    %eax,%ecx
f0102f00:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0102f07:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102f0e:	89 50 44             	mov    %edx,0x44(%eax)
f0102f11:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0102f14:	89 ca                	mov    %ecx,%edx
	// LAB 3: Your code here.
	env_free_list = NULL;
	int i;
	
	cprintf("PDX(UTOP) %u\n", PDX(UTOP) );
	for (i = (NENV - 1); i >= 0; --i){
f0102f16:	39 d8                	cmp    %ebx,%eax
f0102f18:	75 e4                	jne    f0102efe <env_init+0x39>
f0102f1a:	89 35 4c d2 1d f0    	mov    %esi,0xf01dd24c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102f20:	e8 70 ff ff ff       	call   f0102e95 <env_init_percpu>
}
f0102f25:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102f28:	5b                   	pop    %ebx
f0102f29:	5e                   	pop    %esi
f0102f2a:	5d                   	pop    %ebp
f0102f2b:	c3                   	ret    

f0102f2c <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f2c:	55                   	push   %ebp
f0102f2d:	89 e5                	mov    %esp,%ebp
f0102f2f:	53                   	push   %ebx
f0102f30:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102f33:	8b 1d 4c d2 1d f0    	mov    0xf01dd24c,%ebx
f0102f39:	85 db                	test   %ebx,%ebx
f0102f3b:	0f 84 48 01 00 00    	je     f0103089 <env_alloc+0x15d>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102f41:	83 ec 0c             	sub    $0xc,%esp
f0102f44:	6a 01                	push   $0x1
f0102f46:	e8 96 df ff ff       	call   f0100ee1 <page_alloc>
f0102f4b:	83 c4 10             	add    $0x10,%esp
f0102f4e:	85 c0                	test   %eax,%eax
f0102f50:	0f 84 3a 01 00 00    	je     f0103090 <env_alloc+0x164>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0102f56:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f5b:	2b 05 90 de 1d f0    	sub    0xf01dde90,%eax
f0102f61:	c1 f8 03             	sar    $0x3,%eax
f0102f64:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f67:	89 c2                	mov    %eax,%edx
f0102f69:	c1 ea 0c             	shr    $0xc,%edx
f0102f6c:	3b 15 88 de 1d f0    	cmp    0xf01dde88,%edx
f0102f72:	72 12                	jb     f0102f86 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f74:	50                   	push   %eax
f0102f75:	68 04 61 10 f0       	push   $0xf0106104
f0102f7a:	6a 58                	push   $0x58
f0102f7c:	68 29 70 10 f0       	push   $0xf0107029
f0102f81:	e8 ba d0 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = (pde_t *) page2kva(p);
f0102f86:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f8b:	89 43 60             	mov    %eax,0x60(%ebx)
f0102f8e:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (i = 0; i < PDX(UTOP); i++)
	{
		e->env_pgdir[i]= 0;
f0102f93:	8b 53 60             	mov    0x60(%ebx),%edx
f0102f96:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f0102f9d:	83 c0 04             	add    $0x4,%eax

	// LAB 3: Your code here.
	p->pp_ref++;
	e->env_pgdir = (pde_t *) page2kva(p);
	
	for (i = 0; i < PDX(UTOP); i++)
f0102fa0:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0102fa5:	75 ec                	jne    f0102f93 <env_alloc+0x67>
	{
		e->env_pgdir[i]= 0;
	}
	for (i = PDX(UTOP) ;  i < NPDENTRIES; i++ )
	{
		e->env_pgdir[i] = kern_pgdir[i];
f0102fa7:	8b 15 8c de 1d f0    	mov    0xf01dde8c,%edx
f0102fad:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0102fb0:	8b 53 60             	mov    0x60(%ebx),%edx
f0102fb3:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0102fb6:	83 c0 04             	add    $0x4,%eax
	
	for (i = 0; i < PDX(UTOP); i++)
	{
		e->env_pgdir[i]= 0;
	}
	for (i = PDX(UTOP) ;  i < NPDENTRIES; i++ )
f0102fb9:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102fbe:	75 e7                	jne    f0102fa7 <env_alloc+0x7b>
		e->env_pgdir[i] = kern_pgdir[i];
	}
		
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102fc0:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fc3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102fc8:	77 15                	ja     f0102fdf <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fca:	50                   	push   %eax
f0102fcb:	68 28 61 10 f0       	push   $0xf0106128
f0102fd0:	68 d2 00 00 00       	push   $0xd2
f0102fd5:	68 14 74 10 f0       	push   $0xf0107414
f0102fda:	e8 61 d0 ff ff       	call   f0100040 <_panic>
f0102fdf:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102fe5:	83 ca 05             	or     $0x5,%edx
f0102fe8:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102fee:	8b 43 48             	mov    0x48(%ebx),%eax
f0102ff1:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102ff6:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102ffb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103000:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103003:	89 da                	mov    %ebx,%edx
f0103005:	2b 15 48 d2 1d f0    	sub    0xf01dd248,%edx
f010300b:	c1 fa 02             	sar    $0x2,%edx
f010300e:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103014:	09 d0                	or     %edx,%eax
f0103016:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103019:	8b 45 0c             	mov    0xc(%ebp),%eax
f010301c:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010301f:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103026:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010302d:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103034:	83 ec 04             	sub    $0x4,%esp
f0103037:	6a 44                	push   $0x44
f0103039:	6a 00                	push   $0x0
f010303b:	53                   	push   %ebx
f010303c:	e8 f1 23 00 00       	call   f0105432 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103041:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103047:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010304d:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103053:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010305a:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103060:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103067:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010306e:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103072:	8b 43 44             	mov    0x44(%ebx),%eax
f0103075:	a3 4c d2 1d f0       	mov    %eax,0xf01dd24c
	*newenv_store = e;
f010307a:	8b 45 08             	mov    0x8(%ebp),%eax
f010307d:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f010307f:	83 c4 10             	add    $0x10,%esp
f0103082:	b8 00 00 00 00       	mov    $0x0,%eax
f0103087:	eb 0c                	jmp    f0103095 <env_alloc+0x169>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103089:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010308e:	eb 05                	jmp    f0103095 <env_alloc+0x169>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103090:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103098:	c9                   	leave  
f0103099:	c3                   	ret    

f010309a <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010309a:	55                   	push   %ebp
f010309b:	89 e5                	mov    %esp,%ebp
f010309d:	57                   	push   %edi
f010309e:	56                   	push   %esi
f010309f:	53                   	push   %ebx
f01030a0:	83 ec 34             	sub    $0x34,%esp
f01030a3:	8b 7d 08             	mov    0x8(%ebp),%edi
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.

	struct Env *e;
	
	int r = env_alloc(&e, (envid_t) 0);
f01030a6:	6a 00                	push   $0x0
f01030a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01030ab:	50                   	push   %eax
f01030ac:	e8 7b fe ff ff       	call   f0102f2c <env_alloc>
	
	if(r != 0) {
f01030b1:	83 c4 10             	add    $0x10,%esp
f01030b4:	85 c0                	test   %eax,%eax
f01030b6:	74 15                	je     f01030cd <env_create+0x33>
		panic("env_alloc failed: env_create failed %e\n", r);
f01030b8:	50                   	push   %eax
f01030b9:	68 90 73 10 f0       	push   $0xf0107390
f01030be:	68 c6 01 00 00       	push   $0x1c6
f01030c3:	68 14 74 10 f0       	push   $0xf0107414
f01030c8:	e8 73 cf ff ff       	call   f0100040 <_panic>
	}
	
	load_icode(e,binary);
f01030cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01030d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Elf * elfHeader = (struct Elf *) binary;

	struct Proghdr *ph, *eph;

	// is this a valid ELF?
	if (elfHeader->e_magic != ELF_MAGIC)
f01030d3:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01030d9:	74 17                	je     f01030f2 <env_create+0x58>
		panic("load_icode failed: Not a valid ELF file!");
f01030db:	83 ec 04             	sub    $0x4,%esp
f01030de:	68 b8 73 10 f0       	push   $0xf01073b8
f01030e3:	68 88 01 00 00       	push   $0x188
f01030e8:	68 14 74 10 f0       	push   $0xf0107414
f01030ed:	e8 4e cf ff ff       	call   f0100040 <_panic>
	
	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) elfHeader + elfHeader->e_phoff);
f01030f2:	89 fb                	mov    %edi,%ebx
f01030f4:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elfHeader->e_phnum;
f01030f7:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01030fb:	c1 e6 05             	shl    $0x5,%esi
f01030fe:	01 de                	add    %ebx,%esi
	
	lcr3(PADDR(e->env_pgdir));
f0103100:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103103:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103106:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010310b:	77 15                	ja     f0103122 <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010310d:	50                   	push   %eax
f010310e:	68 28 61 10 f0       	push   $0xf0106128
f0103113:	68 8e 01 00 00       	push   $0x18e
f0103118:	68 14 74 10 f0       	push   $0xf0107414
f010311d:	e8 1e cf ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103122:	05 00 00 00 10       	add    $0x10000000,%eax
f0103127:	0f 22 d8             	mov    %eax,%cr3
f010312a:	eb 5b                	jmp    f0103187 <env_create+0xed>
	
	for (; ph < eph; ph++)
	{
		// p_pa is the load address of this segment (as well
		// as the physical address)
		if (ph->p_type == ELF_PROG_LOAD)
f010312c:	83 3b 01             	cmpl   $0x1,(%ebx)
f010312f:	75 53                	jne    f0103184 <env_create+0xea>
		{
			if(ph->p_filesz <= ph->p_memsz){
f0103131:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103134:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103137:	77 34                	ja     f010316d <env_create+0xd3>
			
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103139:	8b 53 08             	mov    0x8(%ebx),%edx
f010313c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010313f:	e8 13 fc ff ff       	call   f0102d57 <region_alloc>
			memset((void *) ph->p_va, 0, ph->p_memsz);
f0103144:	83 ec 04             	sub    $0x4,%esp
f0103147:	ff 73 14             	pushl  0x14(%ebx)
f010314a:	6a 00                	push   $0x0
f010314c:	ff 73 08             	pushl  0x8(%ebx)
f010314f:	e8 de 22 00 00       	call   f0105432 <memset>
			memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103154:	83 c4 0c             	add    $0xc,%esp
f0103157:	ff 73 10             	pushl  0x10(%ebx)
f010315a:	89 f8                	mov    %edi,%eax
f010315c:	03 43 04             	add    0x4(%ebx),%eax
f010315f:	50                   	push   %eax
f0103160:	ff 73 08             	pushl  0x8(%ebx)
f0103163:	e8 17 23 00 00       	call   f010547f <memmove>
f0103168:	83 c4 10             	add    $0x10,%esp
f010316b:	eb 17                	jmp    f0103184 <env_create+0xea>
			}
			
			else
				panic("load_icode failed: filesz is greater than memsz");
f010316d:	83 ec 04             	sub    $0x4,%esp
f0103170:	68 e4 73 10 f0       	push   $0xf01073e4
f0103175:	68 9e 01 00 00       	push   $0x19e
f010317a:	68 14 74 10 f0       	push   $0xf0107414
f010317f:	e8 bc ce ff ff       	call   f0100040 <_panic>
	ph = (struct Proghdr *) ((uint8_t *) elfHeader + elfHeader->e_phoff);
	eph = ph + elfHeader->e_phnum;
	
	lcr3(PADDR(e->env_pgdir));
	
	for (; ph < eph; ph++)
f0103184:	83 c3 20             	add    $0x20,%ebx
f0103187:	39 de                	cmp    %ebx,%esi
f0103189:	77 a1                	ja     f010312c <env_create+0x92>
				panic("load_icode failed: filesz is greater than memsz");
				
		}
	}
	
	e->env_tf.tf_eip = elfHeader->e_entry;
f010318b:	8b 47 18             	mov    0x18(%edi),%eax
f010318e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103191:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0103194:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103199:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010319e:	89 f8                	mov    %edi,%eax
f01031a0:	e8 b2 fb ff ff       	call   f0102d57 <region_alloc>
	
	lcr3(PADDR(kern_pgdir));
f01031a5:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031aa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031af:	77 15                	ja     f01031c6 <env_create+0x12c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031b1:	50                   	push   %eax
f01031b2:	68 28 61 10 f0       	push   $0xf0106128
f01031b7:	68 ae 01 00 00       	push   $0x1ae
f01031bc:	68 14 74 10 f0       	push   $0xf0107414
f01031c1:	e8 7a ce ff ff       	call   f0100040 <_panic>
f01031c6:	05 00 00 00 10       	add    $0x10000000,%eax
f01031cb:	0f 22 d8             	mov    %eax,%cr3
	if(r != 0) {
		panic("env_alloc failed: env_create failed %e\n", r);
	}
	
	load_icode(e,binary);
	e->env_type = type;
f01031ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031d1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01031d4:	89 50 50             	mov    %edx,0x50(%eax)
	

}
f01031d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031da:	5b                   	pop    %ebx
f01031db:	5e                   	pop    %esi
f01031dc:	5f                   	pop    %edi
f01031dd:	5d                   	pop    %ebp
f01031de:	c3                   	ret    

f01031df <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01031df:	55                   	push   %ebp
f01031e0:	89 e5                	mov    %esp,%ebp
f01031e2:	57                   	push   %edi
f01031e3:	56                   	push   %esi
f01031e4:	53                   	push   %ebx
f01031e5:	83 ec 1c             	sub    $0x1c,%esp
f01031e8:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01031eb:	e8 62 28 00 00       	call   f0105a52 <cpunum>
f01031f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01031f3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01031fa:	39 b8 28 e0 1d f0    	cmp    %edi,-0xfe21fd8(%eax)
f0103200:	75 30                	jne    f0103232 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f0103202:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103207:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010320c:	77 15                	ja     f0103223 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010320e:	50                   	push   %eax
f010320f:	68 28 61 10 f0       	push   $0xf0106128
f0103214:	68 de 01 00 00       	push   $0x1de
f0103219:	68 14 74 10 f0       	push   $0xf0107414
f010321e:	e8 1d ce ff ff       	call   f0100040 <_panic>
f0103223:	05 00 00 00 10       	add    $0x10000000,%eax
f0103228:	0f 22 d8             	mov    %eax,%cr3
f010322b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103232:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103235:	89 d0                	mov    %edx,%eax
f0103237:	c1 e0 02             	shl    $0x2,%eax
f010323a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010323d:	8b 47 60             	mov    0x60(%edi),%eax
f0103240:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103243:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103249:	0f 84 a8 00 00 00    	je     f01032f7 <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010324f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103255:	89 f0                	mov    %esi,%eax
f0103257:	c1 e8 0c             	shr    $0xc,%eax
f010325a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010325d:	39 05 88 de 1d f0    	cmp    %eax,0xf01dde88
f0103263:	77 15                	ja     f010327a <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103265:	56                   	push   %esi
f0103266:	68 04 61 10 f0       	push   $0xf0106104
f010326b:	68 ed 01 00 00       	push   $0x1ed
f0103270:	68 14 74 10 f0       	push   $0xf0107414
f0103275:	e8 c6 cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010327a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010327d:	c1 e0 16             	shl    $0x16,%eax
f0103280:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103283:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103288:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010328f:	01 
f0103290:	74 17                	je     f01032a9 <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103292:	83 ec 08             	sub    $0x8,%esp
f0103295:	89 d8                	mov    %ebx,%eax
f0103297:	c1 e0 0c             	shl    $0xc,%eax
f010329a:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010329d:	50                   	push   %eax
f010329e:	ff 77 60             	pushl  0x60(%edi)
f01032a1:	e8 89 de ff ff       	call   f010112f <page_remove>
f01032a6:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032a9:	83 c3 01             	add    $0x1,%ebx
f01032ac:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01032b2:	75 d4                	jne    f0103288 <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01032b4:	8b 47 60             	mov    0x60(%edi),%eax
f01032b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01032ba:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01032c4:	3b 05 88 de 1d f0    	cmp    0xf01dde88,%eax
f01032ca:	72 14                	jb     f01032e0 <env_free+0x101>
		panic("pa2page called with invalid pa");
f01032cc:	83 ec 04             	sub    $0x4,%esp
f01032cf:	68 c0 67 10 f0       	push   $0xf01067c0
f01032d4:	6a 51                	push   $0x51
f01032d6:	68 29 70 10 f0       	push   $0xf0107029
f01032db:	e8 60 cd ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01032e0:	83 ec 0c             	sub    $0xc,%esp
f01032e3:	a1 90 de 1d f0       	mov    0xf01dde90,%eax
f01032e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01032eb:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01032ee:	50                   	push   %eax
f01032ef:	e8 98 dc ff ff       	call   f0100f8c <page_decref>
f01032f4:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01032f7:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01032fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032fe:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103303:	0f 85 29 ff ff ff    	jne    f0103232 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103309:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010330c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103311:	77 15                	ja     f0103328 <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103313:	50                   	push   %eax
f0103314:	68 28 61 10 f0       	push   $0xf0106128
f0103319:	68 fb 01 00 00       	push   $0x1fb
f010331e:	68 14 74 10 f0       	push   $0xf0107414
f0103323:	e8 18 cd ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103328:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010332f:	05 00 00 00 10       	add    $0x10000000,%eax
f0103334:	c1 e8 0c             	shr    $0xc,%eax
f0103337:	3b 05 88 de 1d f0    	cmp    0xf01dde88,%eax
f010333d:	72 14                	jb     f0103353 <env_free+0x174>
		panic("pa2page called with invalid pa");
f010333f:	83 ec 04             	sub    $0x4,%esp
f0103342:	68 c0 67 10 f0       	push   $0xf01067c0
f0103347:	6a 51                	push   $0x51
f0103349:	68 29 70 10 f0       	push   $0xf0107029
f010334e:	e8 ed cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103353:	83 ec 0c             	sub    $0xc,%esp
f0103356:	8b 15 90 de 1d f0    	mov    0xf01dde90,%edx
f010335c:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010335f:	50                   	push   %eax
f0103360:	e8 27 dc ff ff       	call   f0100f8c <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103365:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010336c:	a1 4c d2 1d f0       	mov    0xf01dd24c,%eax
f0103371:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103374:	89 3d 4c d2 1d f0    	mov    %edi,0xf01dd24c
}
f010337a:	83 c4 10             	add    $0x10,%esp
f010337d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103380:	5b                   	pop    %ebx
f0103381:	5e                   	pop    %esi
f0103382:	5f                   	pop    %edi
f0103383:	5d                   	pop    %ebp
f0103384:	c3                   	ret    

f0103385 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103385:	55                   	push   %ebp
f0103386:	89 e5                	mov    %esp,%ebp
f0103388:	53                   	push   %ebx
f0103389:	83 ec 04             	sub    $0x4,%esp
f010338c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010338f:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103393:	75 19                	jne    f01033ae <env_destroy+0x29>
f0103395:	e8 b8 26 00 00       	call   f0105a52 <cpunum>
f010339a:	6b c0 74             	imul   $0x74,%eax,%eax
f010339d:	3b 98 28 e0 1d f0    	cmp    -0xfe21fd8(%eax),%ebx
f01033a3:	74 09                	je     f01033ae <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01033a5:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01033ac:	eb 33                	jmp    f01033e1 <env_destroy+0x5c>
	}

	env_free(e);
f01033ae:	83 ec 0c             	sub    $0xc,%esp
f01033b1:	53                   	push   %ebx
f01033b2:	e8 28 fe ff ff       	call   f01031df <env_free>

	if (curenv == e) {
f01033b7:	e8 96 26 00 00       	call   f0105a52 <cpunum>
f01033bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01033bf:	83 c4 10             	add    $0x10,%esp
f01033c2:	3b 98 28 e0 1d f0    	cmp    -0xfe21fd8(%eax),%ebx
f01033c8:	75 17                	jne    f01033e1 <env_destroy+0x5c>
		curenv = NULL;
f01033ca:	e8 83 26 00 00       	call   f0105a52 <cpunum>
f01033cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01033d2:	c7 80 28 e0 1d f0 00 	movl   $0x0,-0xfe21fd8(%eax)
f01033d9:	00 00 00 
		sched_yield();
f01033dc:	e8 9f 0e 00 00       	call   f0104280 <sched_yield>
	}
}
f01033e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033e4:	c9                   	leave  
f01033e5:	c3                   	ret    

f01033e6 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01033e6:	55                   	push   %ebp
f01033e7:	89 e5                	mov    %esp,%ebp
f01033e9:	53                   	push   %ebx
f01033ea:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01033ed:	e8 60 26 00 00       	call   f0105a52 <cpunum>
f01033f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01033f5:	8b 98 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%ebx
f01033fb:	e8 52 26 00 00       	call   f0105a52 <cpunum>
f0103400:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103403:	8b 65 08             	mov    0x8(%ebp),%esp
f0103406:	61                   	popa   
f0103407:	07                   	pop    %es
f0103408:	1f                   	pop    %ds
f0103409:	83 c4 08             	add    $0x8,%esp
f010340c:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010340d:	83 ec 04             	sub    $0x4,%esp
f0103410:	68 3e 74 10 f0       	push   $0xf010743e
f0103415:	68 31 02 00 00       	push   $0x231
f010341a:	68 14 74 10 f0       	push   $0xf0107414
f010341f:	e8 1c cc ff ff       	call   f0100040 <_panic>

f0103424 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103424:	55                   	push   %ebp
f0103425:	89 e5                	mov    %esp,%ebp
f0103427:	53                   	push   %ebx
f0103428:	83 ec 04             	sub    $0x4,%esp
f010342b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
//	cprintf("SRHS: inside env run \n");
	if(curenv != e){
f010342e:	e8 1f 26 00 00       	call   f0105a52 <cpunum>
f0103433:	6b c0 74             	imul   $0x74,%eax,%eax
f0103436:	39 98 28 e0 1d f0    	cmp    %ebx,-0xfe21fd8(%eax)
f010343c:	0f 84 a4 00 00 00    	je     f01034e6 <env_run+0xc2>
	
		if (curenv != NULL && curenv->env_status == ENV_RUNNING){
f0103442:	e8 0b 26 00 00       	call   f0105a52 <cpunum>
f0103447:	6b c0 74             	imul   $0x74,%eax,%eax
f010344a:	83 b8 28 e0 1d f0 00 	cmpl   $0x0,-0xfe21fd8(%eax)
f0103451:	74 29                	je     f010347c <env_run+0x58>
f0103453:	e8 fa 25 00 00       	call   f0105a52 <cpunum>
f0103458:	6b c0 74             	imul   $0x74,%eax,%eax
f010345b:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f0103461:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103465:	75 15                	jne    f010347c <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f0103467:	e8 e6 25 00 00       	call   f0105a52 <cpunum>
f010346c:	6b c0 74             	imul   $0x74,%eax,%eax
f010346f:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f0103475:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		}
		curenv = e;
f010347c:	e8 d1 25 00 00       	call   f0105a52 <cpunum>
f0103481:	6b c0 74             	imul   $0x74,%eax,%eax
f0103484:	89 98 28 e0 1d f0    	mov    %ebx,-0xfe21fd8(%eax)
		curenv->env_status = ENV_RUNNING;
f010348a:	e8 c3 25 00 00       	call   f0105a52 <cpunum>
f010348f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103492:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f0103498:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f010349f:	e8 ae 25 00 00       	call   f0105a52 <cpunum>
f01034a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01034a7:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f01034ad:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f01034b1:	e8 9c 25 00 00       	call   f0105a52 <cpunum>
f01034b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01034b9:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f01034bf:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034c2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034c7:	77 15                	ja     f01034de <env_run+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034c9:	50                   	push   %eax
f01034ca:	68 28 61 10 f0       	push   $0xf0106128
f01034cf:	68 58 02 00 00       	push   $0x258
f01034d4:	68 14 74 10 f0       	push   $0xf0107414
f01034d9:	e8 62 cb ff ff       	call   f0100040 <_panic>
f01034de:	05 00 00 00 10       	add    $0x10000000,%eax
f01034e3:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01034e6:	83 ec 0c             	sub    $0xc,%esp
f01034e9:	68 c0 03 12 f0       	push   $0xf01203c0
f01034ee:	e8 6a 28 00 00       	call   f0105d5d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01034f3:	f3 90                	pause  
	}
	unlock_kernel();	
	env_pop_tf(&e->env_tf);
f01034f5:	89 1c 24             	mov    %ebx,(%esp)
f01034f8:	e8 e9 fe ff ff       	call   f01033e6 <env_pop_tf>

f01034fd <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01034fd:	55                   	push   %ebp
f01034fe:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103500:	ba 70 00 00 00       	mov    $0x70,%edx
f0103505:	8b 45 08             	mov    0x8(%ebp),%eax
f0103508:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103509:	ba 71 00 00 00       	mov    $0x71,%edx
f010350e:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010350f:	0f b6 c0             	movzbl %al,%eax
}
f0103512:	5d                   	pop    %ebp
f0103513:	c3                   	ret    

f0103514 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103514:	55                   	push   %ebp
f0103515:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103517:	ba 70 00 00 00       	mov    $0x70,%edx
f010351c:	8b 45 08             	mov    0x8(%ebp),%eax
f010351f:	ee                   	out    %al,(%dx)
f0103520:	ba 71 00 00 00       	mov    $0x71,%edx
f0103525:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103528:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103529:	5d                   	pop    %ebp
f010352a:	c3                   	ret    

f010352b <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010352b:	55                   	push   %ebp
f010352c:	89 e5                	mov    %esp,%ebp
f010352e:	56                   	push   %esi
f010352f:	53                   	push   %ebx
f0103530:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103533:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f0103539:	80 3d 50 d2 1d f0 00 	cmpb   $0x0,0xf01dd250
f0103540:	74 5a                	je     f010359c <irq_setmask_8259A+0x71>
f0103542:	89 c6                	mov    %eax,%esi
f0103544:	ba 21 00 00 00       	mov    $0x21,%edx
f0103549:	ee                   	out    %al,(%dx)
f010354a:	66 c1 e8 08          	shr    $0x8,%ax
f010354e:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103553:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103554:	83 ec 0c             	sub    $0xc,%esp
f0103557:	68 4a 74 10 f0       	push   $0xf010744a
f010355c:	e8 1b 01 00 00       	call   f010367c <cprintf>
f0103561:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103564:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103569:	0f b7 f6             	movzwl %si,%esi
f010356c:	f7 d6                	not    %esi
f010356e:	0f a3 de             	bt     %ebx,%esi
f0103571:	73 11                	jae    f0103584 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103573:	83 ec 08             	sub    $0x8,%esp
f0103576:	53                   	push   %ebx
f0103577:	68 0f 79 10 f0       	push   $0xf010790f
f010357c:	e8 fb 00 00 00       	call   f010367c <cprintf>
f0103581:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103584:	83 c3 01             	add    $0x1,%ebx
f0103587:	83 fb 10             	cmp    $0x10,%ebx
f010358a:	75 e2                	jne    f010356e <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010358c:	83 ec 0c             	sub    $0xc,%esp
f010358f:	68 fd 72 10 f0       	push   $0xf01072fd
f0103594:	e8 e3 00 00 00       	call   f010367c <cprintf>
f0103599:	83 c4 10             	add    $0x10,%esp
}
f010359c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010359f:	5b                   	pop    %ebx
f01035a0:	5e                   	pop    %esi
f01035a1:	5d                   	pop    %ebp
f01035a2:	c3                   	ret    

f01035a3 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01035a3:	c6 05 50 d2 1d f0 01 	movb   $0x1,0xf01dd250
f01035aa:	ba 21 00 00 00       	mov    $0x21,%edx
f01035af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01035b4:	ee                   	out    %al,(%dx)
f01035b5:	ba a1 00 00 00       	mov    $0xa1,%edx
f01035ba:	ee                   	out    %al,(%dx)
f01035bb:	ba 20 00 00 00       	mov    $0x20,%edx
f01035c0:	b8 11 00 00 00       	mov    $0x11,%eax
f01035c5:	ee                   	out    %al,(%dx)
f01035c6:	ba 21 00 00 00       	mov    $0x21,%edx
f01035cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01035d0:	ee                   	out    %al,(%dx)
f01035d1:	b8 04 00 00 00       	mov    $0x4,%eax
f01035d6:	ee                   	out    %al,(%dx)
f01035d7:	b8 03 00 00 00       	mov    $0x3,%eax
f01035dc:	ee                   	out    %al,(%dx)
f01035dd:	ba a0 00 00 00       	mov    $0xa0,%edx
f01035e2:	b8 11 00 00 00       	mov    $0x11,%eax
f01035e7:	ee                   	out    %al,(%dx)
f01035e8:	ba a1 00 00 00       	mov    $0xa1,%edx
f01035ed:	b8 28 00 00 00       	mov    $0x28,%eax
f01035f2:	ee                   	out    %al,(%dx)
f01035f3:	b8 02 00 00 00       	mov    $0x2,%eax
f01035f8:	ee                   	out    %al,(%dx)
f01035f9:	b8 01 00 00 00       	mov    $0x1,%eax
f01035fe:	ee                   	out    %al,(%dx)
f01035ff:	ba 20 00 00 00       	mov    $0x20,%edx
f0103604:	b8 68 00 00 00       	mov    $0x68,%eax
f0103609:	ee                   	out    %al,(%dx)
f010360a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010360f:	ee                   	out    %al,(%dx)
f0103610:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103615:	b8 68 00 00 00       	mov    $0x68,%eax
f010361a:	ee                   	out    %al,(%dx)
f010361b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103620:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103621:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0103628:	66 83 f8 ff          	cmp    $0xffff,%ax
f010362c:	74 13                	je     f0103641 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010362e:	55                   	push   %ebp
f010362f:	89 e5                	mov    %esp,%ebp
f0103631:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103634:	0f b7 c0             	movzwl %ax,%eax
f0103637:	50                   	push   %eax
f0103638:	e8 ee fe ff ff       	call   f010352b <irq_setmask_8259A>
f010363d:	83 c4 10             	add    $0x10,%esp
}
f0103640:	c9                   	leave  
f0103641:	f3 c3                	repz ret 

f0103643 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103643:	55                   	push   %ebp
f0103644:	89 e5                	mov    %esp,%ebp
f0103646:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103649:	ff 75 08             	pushl  0x8(%ebp)
f010364c:	e8 2b d1 ff ff       	call   f010077c <cputchar>
	*cnt++;
}
f0103651:	83 c4 10             	add    $0x10,%esp
f0103654:	c9                   	leave  
f0103655:	c3                   	ret    

f0103656 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103656:	55                   	push   %ebp
f0103657:	89 e5                	mov    %esp,%ebp
f0103659:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010365c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103663:	ff 75 0c             	pushl  0xc(%ebp)
f0103666:	ff 75 08             	pushl  0x8(%ebp)
f0103669:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010366c:	50                   	push   %eax
f010366d:	68 43 36 10 f0       	push   $0xf0103643
f0103672:	e8 37 17 00 00       	call   f0104dae <vprintfmt>
	return cnt;
}
f0103677:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010367a:	c9                   	leave  
f010367b:	c3                   	ret    

f010367c <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010367c:	55                   	push   %ebp
f010367d:	89 e5                	mov    %esp,%ebp
f010367f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103682:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103685:	50                   	push   %eax
f0103686:	ff 75 08             	pushl  0x8(%ebp)
f0103689:	e8 c8 ff ff ff       	call   f0103656 <vcprintf>
	va_end(ap);

	return cnt;
}
f010368e:	c9                   	leave  
f010368f:	c3                   	ret    

f0103690 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103690:	55                   	push   %ebp
f0103691:	89 e5                	mov    %esp,%ebp
f0103693:	57                   	push   %edi
f0103694:	56                   	push   %esi
f0103695:	53                   	push   %ebx
f0103696:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	int i = thiscpu->cpu_id;
f0103699:	e8 b4 23 00 00       	call   f0105a52 <cpunum>
f010369e:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a1:	0f b6 98 20 e0 1d f0 	movzbl -0xfe21fe0(%eax),%ebx
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t) percpu_kstacks[thiscpu->cpu_id] + KSTKSIZE;
f01036a8:	e8 a5 23 00 00       	call   f0105a52 <cpunum>
f01036ad:	89 c6                	mov    %eax,%esi
f01036af:	e8 9e 23 00 00       	call   f0105a52 <cpunum>
f01036b4:	6b ce 74             	imul   $0x74,%esi,%ecx
f01036b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ba:	0f b6 90 20 e0 1d f0 	movzbl -0xfe21fe0(%eax),%edx
f01036c1:	c1 e2 0f             	shl    $0xf,%edx
f01036c4:	81 c2 00 70 1e f0    	add    $0xf01e7000,%edx
f01036ca:	89 91 30 e0 1d f0    	mov    %edx,-0xfe21fd0(%ecx)
        thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01036d0:	e8 7d 23 00 00       	call   f0105a52 <cpunum>
f01036d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01036d8:	66 c7 80 34 e0 1d f0 	movw   $0x10,-0xfe21fcc(%eax)
f01036df:	10 00 

        // Initialize the TSS slot of the gdt.
        gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01036e1:	0f b6 db             	movzbl %bl,%ebx
f01036e4:	83 c3 05             	add    $0x5,%ebx
f01036e7:	e8 66 23 00 00       	call   f0105a52 <cpunum>
f01036ec:	89 c7                	mov    %eax,%edi
f01036ee:	e8 5f 23 00 00       	call   f0105a52 <cpunum>
f01036f3:	89 c6                	mov    %eax,%esi
f01036f5:	e8 58 23 00 00       	call   f0105a52 <cpunum>
f01036fa:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f0103701:	f0 67 00 
f0103704:	6b ff 74             	imul   $0x74,%edi,%edi
f0103707:	81 c7 2c e0 1d f0    	add    $0xf01de02c,%edi
f010370d:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f0103714:	f0 
f0103715:	6b d6 74             	imul   $0x74,%esi,%edx
f0103718:	81 c2 2c e0 1d f0    	add    $0xf01de02c,%edx
f010371e:	c1 ea 10             	shr    $0x10,%edx
f0103721:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f0103728:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f010372f:	40 
f0103730:	6b c0 74             	imul   $0x74,%eax,%eax
f0103733:	05 2c e0 1d f0       	add    $0xf01de02c,%eax
f0103738:	c1 e8 18             	shr    $0x18,%eax
f010373b:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
                                        sizeof(struct Taskstate) - 1, 0);
        gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0103742:	c6 04 dd 45 03 12 f0 	movb   $0x89,-0xfedfcbb(,%ebx,8)
f0103749:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010374a:	c1 e3 03             	shl    $0x3,%ebx
f010374d:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103750:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f0103755:	0f 01 18             	lidtl  (%eax)
        ltr(GD_TSS0 + i * sizeof(struct Segdesc));

        // Load the IDT
        lidt(&idt_pd);

}
f0103758:	83 c4 0c             	add    $0xc,%esp
f010375b:	5b                   	pop    %ebx
f010375c:	5e                   	pop    %esi
f010375d:	5f                   	pop    %edi
f010375e:	5d                   	pop    %ebp
f010375f:	c3                   	ret    

f0103760 <trap_init>:
}


void
trap_init(void)
{
f0103760:	55                   	push   %ebp
f0103761:	89 e5                	mov    %esp,%ebp
f0103763:	83 ec 08             	sub    $0x8,%esp
	void fun_serial();
	void fun_spurious();
	void fun_ide();
	void fun_error();
	
	SETGATE(idt[T_DIVIDE],0,GD_KT,divide_error,0);
f0103766:	b8 0e 41 10 f0       	mov    $0xf010410e,%eax
f010376b:	66 a3 60 d2 1d f0    	mov    %ax,0xf01dd260
f0103771:	66 c7 05 62 d2 1d f0 	movw   $0x8,0xf01dd262
f0103778:	08 00 
f010377a:	c6 05 64 d2 1d f0 00 	movb   $0x0,0xf01dd264
f0103781:	c6 05 65 d2 1d f0 8e 	movb   $0x8e,0xf01dd265
f0103788:	c1 e8 10             	shr    $0x10,%eax
f010378b:	66 a3 66 d2 1d f0    	mov    %ax,0xf01dd266
	SETGATE(idt[T_DEBUG], 0, GD_KT, debug_exception, 0);
f0103791:	b8 18 41 10 f0       	mov    $0xf0104118,%eax
f0103796:	66 a3 68 d2 1d f0    	mov    %ax,0xf01dd268
f010379c:	66 c7 05 6a d2 1d f0 	movw   $0x8,0xf01dd26a
f01037a3:	08 00 
f01037a5:	c6 05 6c d2 1d f0 00 	movb   $0x0,0xf01dd26c
f01037ac:	c6 05 6d d2 1d f0 8e 	movb   $0x8e,0xf01dd26d
f01037b3:	c1 e8 10             	shr    $0x10,%eax
f01037b6:	66 a3 6e d2 1d f0    	mov    %ax,0xf01dd26e
	SETGATE(idt[T_NMI], 0, GD_KT, non_maskable_interrupt, 0);
f01037bc:	b8 1e 41 10 f0       	mov    $0xf010411e,%eax
f01037c1:	66 a3 70 d2 1d f0    	mov    %ax,0xf01dd270
f01037c7:	66 c7 05 72 d2 1d f0 	movw   $0x8,0xf01dd272
f01037ce:	08 00 
f01037d0:	c6 05 74 d2 1d f0 00 	movb   $0x0,0xf01dd274
f01037d7:	c6 05 75 d2 1d f0 8e 	movb   $0x8e,0xf01dd275
f01037de:	c1 e8 10             	shr    $0x10,%eax
f01037e1:	66 a3 76 d2 1d f0    	mov    %ax,0xf01dd276
	SETGATE(idt[T_BRKPT], 0, GD_KT, break_point, 3);
f01037e7:	b8 24 41 10 f0       	mov    $0xf0104124,%eax
f01037ec:	66 a3 78 d2 1d f0    	mov    %ax,0xf01dd278
f01037f2:	66 c7 05 7a d2 1d f0 	movw   $0x8,0xf01dd27a
f01037f9:	08 00 
f01037fb:	c6 05 7c d2 1d f0 00 	movb   $0x0,0xf01dd27c
f0103802:	c6 05 7d d2 1d f0 ee 	movb   $0xee,0xf01dd27d
f0103809:	c1 e8 10             	shr    $0x10,%eax
f010380c:	66 a3 7e d2 1d f0    	mov    %ax,0xf01dd27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, over_flow, 0);
f0103812:	b8 2a 41 10 f0       	mov    $0xf010412a,%eax
f0103817:	66 a3 80 d2 1d f0    	mov    %ax,0xf01dd280
f010381d:	66 c7 05 82 d2 1d f0 	movw   $0x8,0xf01dd282
f0103824:	08 00 
f0103826:	c6 05 84 d2 1d f0 00 	movb   $0x0,0xf01dd284
f010382d:	c6 05 85 d2 1d f0 8e 	movb   $0x8e,0xf01dd285
f0103834:	c1 e8 10             	shr    $0x10,%eax
f0103837:	66 a3 86 d2 1d f0    	mov    %ax,0xf01dd286
	SETGATE(idt[T_BOUND], 0, GD_KT, bounds_check, 0);
f010383d:	b8 30 41 10 f0       	mov    $0xf0104130,%eax
f0103842:	66 a3 88 d2 1d f0    	mov    %ax,0xf01dd288
f0103848:	66 c7 05 8a d2 1d f0 	movw   $0x8,0xf01dd28a
f010384f:	08 00 
f0103851:	c6 05 8c d2 1d f0 00 	movb   $0x0,0xf01dd28c
f0103858:	c6 05 8d d2 1d f0 8e 	movb   $0x8e,0xf01dd28d
f010385f:	c1 e8 10             	shr    $0x10,%eax
f0103862:	66 a3 8e d2 1d f0    	mov    %ax,0xf01dd28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, illegal_opcode, 0);
f0103868:	b8 36 41 10 f0       	mov    $0xf0104136,%eax
f010386d:	66 a3 90 d2 1d f0    	mov    %ax,0xf01dd290
f0103873:	66 c7 05 92 d2 1d f0 	movw   $0x8,0xf01dd292
f010387a:	08 00 
f010387c:	c6 05 94 d2 1d f0 00 	movb   $0x0,0xf01dd294
f0103883:	c6 05 95 d2 1d f0 8e 	movb   $0x8e,0xf01dd295
f010388a:	c1 e8 10             	shr    $0x10,%eax
f010388d:	66 a3 96 d2 1d f0    	mov    %ax,0xf01dd296
	SETGATE(idt[T_DEVICE], 0, GD_KT, device_not_available, 0);
f0103893:	b8 3c 41 10 f0       	mov    $0xf010413c,%eax
f0103898:	66 a3 98 d2 1d f0    	mov    %ax,0xf01dd298
f010389e:	66 c7 05 9a d2 1d f0 	movw   $0x8,0xf01dd29a
f01038a5:	08 00 
f01038a7:	c6 05 9c d2 1d f0 00 	movb   $0x0,0xf01dd29c
f01038ae:	c6 05 9d d2 1d f0 8e 	movb   $0x8e,0xf01dd29d
f01038b5:	c1 e8 10             	shr    $0x10,%eax
f01038b8:	66 a3 9e d2 1d f0    	mov    %ax,0xf01dd29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, double_fault, 0);
f01038be:	b8 42 41 10 f0       	mov    $0xf0104142,%eax
f01038c3:	66 a3 a0 d2 1d f0    	mov    %ax,0xf01dd2a0
f01038c9:	66 c7 05 a2 d2 1d f0 	movw   $0x8,0xf01dd2a2
f01038d0:	08 00 
f01038d2:	c6 05 a4 d2 1d f0 00 	movb   $0x0,0xf01dd2a4
f01038d9:	c6 05 a5 d2 1d f0 8e 	movb   $0x8e,0xf01dd2a5
f01038e0:	c1 e8 10             	shr    $0x10,%eax
f01038e3:	66 a3 a6 d2 1d f0    	mov    %ax,0xf01dd2a6
	SETGATE(idt[T_TSS], 0, GD_KT, task_segment_switch, 0);
f01038e9:	b8 46 41 10 f0       	mov    $0xf0104146,%eax
f01038ee:	66 a3 b0 d2 1d f0    	mov    %ax,0xf01dd2b0
f01038f4:	66 c7 05 b2 d2 1d f0 	movw   $0x8,0xf01dd2b2
f01038fb:	08 00 
f01038fd:	c6 05 b4 d2 1d f0 00 	movb   $0x0,0xf01dd2b4
f0103904:	c6 05 b5 d2 1d f0 8e 	movb   $0x8e,0xf01dd2b5
f010390b:	c1 e8 10             	shr    $0x10,%eax
f010390e:	66 a3 b6 d2 1d f0    	mov    %ax,0xf01dd2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, segment_not_present, 0);
f0103914:	b8 4a 41 10 f0       	mov    $0xf010414a,%eax
f0103919:	66 a3 b8 d2 1d f0    	mov    %ax,0xf01dd2b8
f010391f:	66 c7 05 ba d2 1d f0 	movw   $0x8,0xf01dd2ba
f0103926:	08 00 
f0103928:	c6 05 bc d2 1d f0 00 	movb   $0x0,0xf01dd2bc
f010392f:	c6 05 bd d2 1d f0 8e 	movb   $0x8e,0xf01dd2bd
f0103936:	c1 e8 10             	shr    $0x10,%eax
f0103939:	66 a3 be d2 1d f0    	mov    %ax,0xf01dd2be
	SETGATE(idt[T_STACK], 0, GD_KT, stack_exception, 0);
f010393f:	b8 4e 41 10 f0       	mov    $0xf010414e,%eax
f0103944:	66 a3 c0 d2 1d f0    	mov    %ax,0xf01dd2c0
f010394a:	66 c7 05 c2 d2 1d f0 	movw   $0x8,0xf01dd2c2
f0103951:	08 00 
f0103953:	c6 05 c4 d2 1d f0 00 	movb   $0x0,0xf01dd2c4
f010395a:	c6 05 c5 d2 1d f0 8e 	movb   $0x8e,0xf01dd2c5
f0103961:	c1 e8 10             	shr    $0x10,%eax
f0103964:	66 a3 c6 d2 1d f0    	mov    %ax,0xf01dd2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, general_protection_fault, 0);
f010396a:	b8 52 41 10 f0       	mov    $0xf0104152,%eax
f010396f:	66 a3 c8 d2 1d f0    	mov    %ax,0xf01dd2c8
f0103975:	66 c7 05 ca d2 1d f0 	movw   $0x8,0xf01dd2ca
f010397c:	08 00 
f010397e:	c6 05 cc d2 1d f0 00 	movb   $0x0,0xf01dd2cc
f0103985:	c6 05 cd d2 1d f0 8e 	movb   $0x8e,0xf01dd2cd
f010398c:	c1 e8 10             	shr    $0x10,%eax
f010398f:	66 a3 ce d2 1d f0    	mov    %ax,0xf01dd2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, page_fault, 0);
f0103995:	b8 56 41 10 f0       	mov    $0xf0104156,%eax
f010399a:	66 a3 d0 d2 1d f0    	mov    %ax,0xf01dd2d0
f01039a0:	66 c7 05 d2 d2 1d f0 	movw   $0x8,0xf01dd2d2
f01039a7:	08 00 
f01039a9:	c6 05 d4 d2 1d f0 00 	movb   $0x0,0xf01dd2d4
f01039b0:	c6 05 d5 d2 1d f0 8e 	movb   $0x8e,0xf01dd2d5
f01039b7:	c1 e8 10             	shr    $0x10,%eax
f01039ba:	66 a3 d6 d2 1d f0    	mov    %ax,0xf01dd2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, floating_point_error, 0);
f01039c0:	b8 5a 41 10 f0       	mov    $0xf010415a,%eax
f01039c5:	66 a3 e0 d2 1d f0    	mov    %ax,0xf01dd2e0
f01039cb:	66 c7 05 e2 d2 1d f0 	movw   $0x8,0xf01dd2e2
f01039d2:	08 00 
f01039d4:	c6 05 e4 d2 1d f0 00 	movb   $0x0,0xf01dd2e4
f01039db:	c6 05 e5 d2 1d f0 8e 	movb   $0x8e,0xf01dd2e5
f01039e2:	c1 e8 10             	shr    $0x10,%eax
f01039e5:	66 a3 e6 d2 1d f0    	mov    %ax,0xf01dd2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, alignment_check , 0);
f01039eb:	b8 60 41 10 f0       	mov    $0xf0104160,%eax
f01039f0:	66 a3 e8 d2 1d f0    	mov    %ax,0xf01dd2e8
f01039f6:	66 c7 05 ea d2 1d f0 	movw   $0x8,0xf01dd2ea
f01039fd:	08 00 
f01039ff:	c6 05 ec d2 1d f0 00 	movb   $0x0,0xf01dd2ec
f0103a06:	c6 05 ed d2 1d f0 8e 	movb   $0x8e,0xf01dd2ed
f0103a0d:	c1 e8 10             	shr    $0x10,%eax
f0103a10:	66 a3 ee d2 1d f0    	mov    %ax,0xf01dd2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, machine_check, 0);
f0103a16:	b8 64 41 10 f0       	mov    $0xf0104164,%eax
f0103a1b:	66 a3 f0 d2 1d f0    	mov    %ax,0xf01dd2f0
f0103a21:	66 c7 05 f2 d2 1d f0 	movw   $0x8,0xf01dd2f2
f0103a28:	08 00 
f0103a2a:	c6 05 f4 d2 1d f0 00 	movb   $0x0,0xf01dd2f4
f0103a31:	c6 05 f5 d2 1d f0 8e 	movb   $0x8e,0xf01dd2f5
f0103a38:	c1 e8 10             	shr    $0x10,%eax
f0103a3b:	66 a3 f6 d2 1d f0    	mov    %ax,0xf01dd2f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, simd_floating_point_error, 0);
f0103a41:	b8 6a 41 10 f0       	mov    $0xf010416a,%eax
f0103a46:	66 a3 f8 d2 1d f0    	mov    %ax,0xf01dd2f8
f0103a4c:	66 c7 05 fa d2 1d f0 	movw   $0x8,0xf01dd2fa
f0103a53:	08 00 
f0103a55:	c6 05 fc d2 1d f0 00 	movb   $0x0,0xf01dd2fc
f0103a5c:	c6 05 fd d2 1d f0 8e 	movb   $0x8e,0xf01dd2fd
f0103a63:	c1 e8 10             	shr    $0x10,%eax
f0103a66:	66 a3 fe d2 1d f0    	mov    %ax,0xf01dd2fe
	SETGATE(idt[T_SYSCALL], 0 , GD_KT, system_call, 3);
f0103a6c:	b8 70 41 10 f0       	mov    $0xf0104170,%eax
f0103a71:	66 a3 e0 d3 1d f0    	mov    %ax,0xf01dd3e0
f0103a77:	66 c7 05 e2 d3 1d f0 	movw   $0x8,0xf01dd3e2
f0103a7e:	08 00 
f0103a80:	c6 05 e4 d3 1d f0 00 	movb   $0x0,0xf01dd3e4
f0103a87:	c6 05 e5 d3 1d f0 ee 	movb   $0xee,0xf01dd3e5
f0103a8e:	c1 e8 10             	shr    $0x10,%eax
f0103a91:	66 a3 e6 d3 1d f0    	mov    %ax,0xf01dd3e6
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0 , GD_KT, fun_timer, 0);
f0103a97:	b8 76 41 10 f0       	mov    $0xf0104176,%eax
f0103a9c:	66 a3 60 d3 1d f0    	mov    %ax,0xf01dd360
f0103aa2:	66 c7 05 62 d3 1d f0 	movw   $0x8,0xf01dd362
f0103aa9:	08 00 
f0103aab:	c6 05 64 d3 1d f0 00 	movb   $0x0,0xf01dd364
f0103ab2:	c6 05 65 d3 1d f0 8e 	movb   $0x8e,0xf01dd365
f0103ab9:	c1 e8 10             	shr    $0x10,%eax
f0103abc:	66 a3 66 d3 1d f0    	mov    %ax,0xf01dd366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0 , GD_KT, fun_kbd, 0);
f0103ac2:	b8 7c 41 10 f0       	mov    $0xf010417c,%eax
f0103ac7:	66 a3 68 d3 1d f0    	mov    %ax,0xf01dd368
f0103acd:	66 c7 05 6a d3 1d f0 	movw   $0x8,0xf01dd36a
f0103ad4:	08 00 
f0103ad6:	c6 05 6c d3 1d f0 00 	movb   $0x0,0xf01dd36c
f0103add:	c6 05 6d d3 1d f0 8e 	movb   $0x8e,0xf01dd36d
f0103ae4:	c1 e8 10             	shr    $0x10,%eax
f0103ae7:	66 a3 6e d3 1d f0    	mov    %ax,0xf01dd36e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0 , GD_KT, fun_serial, 0);
f0103aed:	b8 94 41 10 f0       	mov    $0xf0104194,%eax
f0103af2:	66 a3 80 d3 1d f0    	mov    %ax,0xf01dd380
f0103af8:	66 c7 05 82 d3 1d f0 	movw   $0x8,0xf01dd382
f0103aff:	08 00 
f0103b01:	c6 05 84 d3 1d f0 00 	movb   $0x0,0xf01dd384
f0103b08:	c6 05 85 d3 1d f0 8e 	movb   $0x8e,0xf01dd385
f0103b0f:	c1 e8 10             	shr    $0x10,%eax
f0103b12:	66 a3 86 d3 1d f0    	mov    %ax,0xf01dd386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0 , GD_KT, fun_spurious, 0);
f0103b18:	b8 82 41 10 f0       	mov    $0xf0104182,%eax
f0103b1d:	66 a3 98 d3 1d f0    	mov    %ax,0xf01dd398
f0103b23:	66 c7 05 9a d3 1d f0 	movw   $0x8,0xf01dd39a
f0103b2a:	08 00 
f0103b2c:	c6 05 9c d3 1d f0 00 	movb   $0x0,0xf01dd39c
f0103b33:	c6 05 9d d3 1d f0 8e 	movb   $0x8e,0xf01dd39d
f0103b3a:	c1 e8 10             	shr    $0x10,%eax
f0103b3d:	66 a3 9e d3 1d f0    	mov    %ax,0xf01dd39e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0 , GD_KT, fun_ide, 0);
f0103b43:	b8 8e 41 10 f0       	mov    $0xf010418e,%eax
f0103b48:	66 a3 d0 d3 1d f0    	mov    %ax,0xf01dd3d0
f0103b4e:	66 c7 05 d2 d3 1d f0 	movw   $0x8,0xf01dd3d2
f0103b55:	08 00 
f0103b57:	c6 05 d4 d3 1d f0 00 	movb   $0x0,0xf01dd3d4
f0103b5e:	c6 05 d5 d3 1d f0 8e 	movb   $0x8e,0xf01dd3d5
f0103b65:	c1 e8 10             	shr    $0x10,%eax
f0103b68:	66 a3 d6 d3 1d f0    	mov    %ax,0xf01dd3d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0 , GD_KT, fun_error, 0);
f0103b6e:	b8 88 41 10 f0       	mov    $0xf0104188,%eax
f0103b73:	66 a3 f8 d3 1d f0    	mov    %ax,0xf01dd3f8
f0103b79:	66 c7 05 fa d3 1d f0 	movw   $0x8,0xf01dd3fa
f0103b80:	08 00 
f0103b82:	c6 05 fc d3 1d f0 00 	movb   $0x0,0xf01dd3fc
f0103b89:	c6 05 fd d3 1d f0 8e 	movb   $0x8e,0xf01dd3fd
f0103b90:	c1 e8 10             	shr    $0x10,%eax
f0103b93:	66 a3 fe d3 1d f0    	mov    %ax,0xf01dd3fe
	// Per-CPU setup 
	trap_init_percpu();
f0103b99:	e8 f2 fa ff ff       	call   f0103690 <trap_init_percpu>
}
f0103b9e:	c9                   	leave  
f0103b9f:	c3                   	ret    

f0103ba0 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103ba0:	55                   	push   %ebp
f0103ba1:	89 e5                	mov    %esp,%ebp
f0103ba3:	53                   	push   %ebx
f0103ba4:	83 ec 0c             	sub    $0xc,%esp
f0103ba7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103baa:	ff 33                	pushl  (%ebx)
f0103bac:	68 5e 74 10 f0       	push   $0xf010745e
f0103bb1:	e8 c6 fa ff ff       	call   f010367c <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103bb6:	83 c4 08             	add    $0x8,%esp
f0103bb9:	ff 73 04             	pushl  0x4(%ebx)
f0103bbc:	68 6d 74 10 f0       	push   $0xf010746d
f0103bc1:	e8 b6 fa ff ff       	call   f010367c <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103bc6:	83 c4 08             	add    $0x8,%esp
f0103bc9:	ff 73 08             	pushl  0x8(%ebx)
f0103bcc:	68 7c 74 10 f0       	push   $0xf010747c
f0103bd1:	e8 a6 fa ff ff       	call   f010367c <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103bd6:	83 c4 08             	add    $0x8,%esp
f0103bd9:	ff 73 0c             	pushl  0xc(%ebx)
f0103bdc:	68 8b 74 10 f0       	push   $0xf010748b
f0103be1:	e8 96 fa ff ff       	call   f010367c <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103be6:	83 c4 08             	add    $0x8,%esp
f0103be9:	ff 73 10             	pushl  0x10(%ebx)
f0103bec:	68 9a 74 10 f0       	push   $0xf010749a
f0103bf1:	e8 86 fa ff ff       	call   f010367c <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103bf6:	83 c4 08             	add    $0x8,%esp
f0103bf9:	ff 73 14             	pushl  0x14(%ebx)
f0103bfc:	68 a9 74 10 f0       	push   $0xf01074a9
f0103c01:	e8 76 fa ff ff       	call   f010367c <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103c06:	83 c4 08             	add    $0x8,%esp
f0103c09:	ff 73 18             	pushl  0x18(%ebx)
f0103c0c:	68 b8 74 10 f0       	push   $0xf01074b8
f0103c11:	e8 66 fa ff ff       	call   f010367c <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103c16:	83 c4 08             	add    $0x8,%esp
f0103c19:	ff 73 1c             	pushl  0x1c(%ebx)
f0103c1c:	68 c7 74 10 f0       	push   $0xf01074c7
f0103c21:	e8 56 fa ff ff       	call   f010367c <cprintf>
}
f0103c26:	83 c4 10             	add    $0x10,%esp
f0103c29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c2c:	c9                   	leave  
f0103c2d:	c3                   	ret    

f0103c2e <print_trapframe>:

}

void
print_trapframe(struct Trapframe *tf)
{
f0103c2e:	55                   	push   %ebp
f0103c2f:	89 e5                	mov    %esp,%ebp
f0103c31:	56                   	push   %esi
f0103c32:	53                   	push   %ebx
f0103c33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103c36:	e8 17 1e 00 00       	call   f0105a52 <cpunum>
f0103c3b:	83 ec 04             	sub    $0x4,%esp
f0103c3e:	50                   	push   %eax
f0103c3f:	53                   	push   %ebx
f0103c40:	68 2b 75 10 f0       	push   $0xf010752b
f0103c45:	e8 32 fa ff ff       	call   f010367c <cprintf>
	print_regs(&tf->tf_regs);
f0103c4a:	89 1c 24             	mov    %ebx,(%esp)
f0103c4d:	e8 4e ff ff ff       	call   f0103ba0 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103c52:	83 c4 08             	add    $0x8,%esp
f0103c55:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103c59:	50                   	push   %eax
f0103c5a:	68 49 75 10 f0       	push   $0xf0107549
f0103c5f:	e8 18 fa ff ff       	call   f010367c <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103c64:	83 c4 08             	add    $0x8,%esp
f0103c67:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103c6b:	50                   	push   %eax
f0103c6c:	68 5c 75 10 f0       	push   $0xf010755c
f0103c71:	e8 06 fa ff ff       	call   f010367c <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103c76:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103c79:	83 c4 10             	add    $0x10,%esp
f0103c7c:	83 f8 13             	cmp    $0x13,%eax
f0103c7f:	77 09                	ja     f0103c8a <print_trapframe+0x5c>
		return excnames[trapno];
f0103c81:	8b 14 85 20 78 10 f0 	mov    -0xfef87e0(,%eax,4),%edx
f0103c88:	eb 1f                	jmp    f0103ca9 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103c8a:	83 f8 30             	cmp    $0x30,%eax
f0103c8d:	74 15                	je     f0103ca4 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103c8f:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103c92:	83 fa 10             	cmp    $0x10,%edx
f0103c95:	b9 f5 74 10 f0       	mov    $0xf01074f5,%ecx
f0103c9a:	ba e2 74 10 f0       	mov    $0xf01074e2,%edx
f0103c9f:	0f 43 d1             	cmovae %ecx,%edx
f0103ca2:	eb 05                	jmp    f0103ca9 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103ca4:	ba d6 74 10 f0       	mov    $0xf01074d6,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ca9:	83 ec 04             	sub    $0x4,%esp
f0103cac:	52                   	push   %edx
f0103cad:	50                   	push   %eax
f0103cae:	68 6f 75 10 f0       	push   $0xf010756f
f0103cb3:	e8 c4 f9 ff ff       	call   f010367c <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103cb8:	83 c4 10             	add    $0x10,%esp
f0103cbb:	3b 1d 60 da 1d f0    	cmp    0xf01dda60,%ebx
f0103cc1:	75 1a                	jne    f0103cdd <print_trapframe+0xaf>
f0103cc3:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103cc7:	75 14                	jne    f0103cdd <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103cc9:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103ccc:	83 ec 08             	sub    $0x8,%esp
f0103ccf:	50                   	push   %eax
f0103cd0:	68 81 75 10 f0       	push   $0xf0107581
f0103cd5:	e8 a2 f9 ff ff       	call   f010367c <cprintf>
f0103cda:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103cdd:	83 ec 08             	sub    $0x8,%esp
f0103ce0:	ff 73 2c             	pushl  0x2c(%ebx)
f0103ce3:	68 90 75 10 f0       	push   $0xf0107590
f0103ce8:	e8 8f f9 ff ff       	call   f010367c <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103ced:	83 c4 10             	add    $0x10,%esp
f0103cf0:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103cf4:	75 49                	jne    f0103d3f <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103cf6:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103cf9:	89 c2                	mov    %eax,%edx
f0103cfb:	83 e2 01             	and    $0x1,%edx
f0103cfe:	ba 0f 75 10 f0       	mov    $0xf010750f,%edx
f0103d03:	b9 04 75 10 f0       	mov    $0xf0107504,%ecx
f0103d08:	0f 44 ca             	cmove  %edx,%ecx
f0103d0b:	89 c2                	mov    %eax,%edx
f0103d0d:	83 e2 02             	and    $0x2,%edx
f0103d10:	ba 21 75 10 f0       	mov    $0xf0107521,%edx
f0103d15:	be 1b 75 10 f0       	mov    $0xf010751b,%esi
f0103d1a:	0f 45 d6             	cmovne %esi,%edx
f0103d1d:	83 e0 04             	and    $0x4,%eax
f0103d20:	be 5b 76 10 f0       	mov    $0xf010765b,%esi
f0103d25:	b8 26 75 10 f0       	mov    $0xf0107526,%eax
f0103d2a:	0f 44 c6             	cmove  %esi,%eax
f0103d2d:	51                   	push   %ecx
f0103d2e:	52                   	push   %edx
f0103d2f:	50                   	push   %eax
f0103d30:	68 9e 75 10 f0       	push   $0xf010759e
f0103d35:	e8 42 f9 ff ff       	call   f010367c <cprintf>
f0103d3a:	83 c4 10             	add    $0x10,%esp
f0103d3d:	eb 10                	jmp    f0103d4f <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103d3f:	83 ec 0c             	sub    $0xc,%esp
f0103d42:	68 fd 72 10 f0       	push   $0xf01072fd
f0103d47:	e8 30 f9 ff ff       	call   f010367c <cprintf>
f0103d4c:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103d4f:	83 ec 08             	sub    $0x8,%esp
f0103d52:	ff 73 30             	pushl  0x30(%ebx)
f0103d55:	68 ad 75 10 f0       	push   $0xf01075ad
f0103d5a:	e8 1d f9 ff ff       	call   f010367c <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103d5f:	83 c4 08             	add    $0x8,%esp
f0103d62:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103d66:	50                   	push   %eax
f0103d67:	68 bc 75 10 f0       	push   $0xf01075bc
f0103d6c:	e8 0b f9 ff ff       	call   f010367c <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103d71:	83 c4 08             	add    $0x8,%esp
f0103d74:	ff 73 38             	pushl  0x38(%ebx)
f0103d77:	68 cf 75 10 f0       	push   $0xf01075cf
f0103d7c:	e8 fb f8 ff ff       	call   f010367c <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103d81:	83 c4 10             	add    $0x10,%esp
f0103d84:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103d88:	74 25                	je     f0103daf <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103d8a:	83 ec 08             	sub    $0x8,%esp
f0103d8d:	ff 73 3c             	pushl  0x3c(%ebx)
f0103d90:	68 de 75 10 f0       	push   $0xf01075de
f0103d95:	e8 e2 f8 ff ff       	call   f010367c <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103d9a:	83 c4 08             	add    $0x8,%esp
f0103d9d:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103da1:	50                   	push   %eax
f0103da2:	68 ed 75 10 f0       	push   $0xf01075ed
f0103da7:	e8 d0 f8 ff ff       	call   f010367c <cprintf>
f0103dac:	83 c4 10             	add    $0x10,%esp
	}
}
f0103daf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103db2:	5b                   	pop    %ebx
f0103db3:	5e                   	pop    %esi
f0103db4:	5d                   	pop    %ebp
f0103db5:	c3                   	ret    

f0103db6 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103db6:	55                   	push   %ebp
f0103db7:	89 e5                	mov    %esp,%ebp
f0103db9:	57                   	push   %edi
f0103dba:	56                   	push   %esi
f0103dbb:	53                   	push   %ebx
f0103dbc:	83 ec 0c             	sub    $0xc,%esp
f0103dbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103dc2:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs== GD_KT)
f0103dc5:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0103dca:	75 17                	jne    f0103de3 <page_fault_handler+0x2d>
		panic("page_fault_handler: Page Fault in Kernel");
f0103dcc:	83 ec 04             	sub    $0x4,%esp
f0103dcf:	68 a8 77 10 f0       	push   $0xf01077a8
f0103dd4:	68 65 01 00 00       	push   $0x165
f0103dd9:	68 00 76 10 f0       	push   $0xf0107600
f0103dde:	e8 5d c2 ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	uint32_t uxtop;
	struct UTrapframe *uxframe;
	if(curenv->env_pgfault_upcall == NULL)
f0103de3:	e8 6a 1c 00 00       	call   f0105a52 <cpunum>
f0103de8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103deb:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f0103df1:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103df5:	75 43                	jne    f0103e3a <page_fault_handler+0x84>
	{
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0103df7:	8b 7b 30             	mov    0x30(%ebx),%edi
                curenv->env_id, fault_va, tf->tf_eip);
f0103dfa:	e8 53 1c 00 00       	call   f0105a52 <cpunum>
	// LAB 4: Your code here.
	uint32_t uxtop;
	struct UTrapframe *uxframe;
	if(curenv->env_pgfault_upcall == NULL)
	{
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0103dff:	57                   	push   %edi
f0103e00:	56                   	push   %esi
                curenv->env_id, fault_va, tf->tf_eip);
f0103e01:	6b c0 74             	imul   $0x74,%eax,%eax
	// LAB 4: Your code here.
	uint32_t uxtop;
	struct UTrapframe *uxframe;
	if(curenv->env_pgfault_upcall == NULL)
	{
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0103e04:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f0103e0a:	ff 70 48             	pushl  0x48(%eax)
f0103e0d:	68 d4 77 10 f0       	push   $0xf01077d4
f0103e12:	e8 65 f8 ff ff       	call   f010367c <cprintf>
                curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f0103e17:	89 1c 24             	mov    %ebx,(%esp)
f0103e1a:	e8 0f fe ff ff       	call   f0103c2e <print_trapframe>
		env_destroy(curenv);
f0103e1f:	e8 2e 1c 00 00       	call   f0105a52 <cpunum>
f0103e24:	83 c4 04             	add    $0x4,%esp
f0103e27:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e2a:	ff b0 28 e0 1d f0    	pushl  -0xfe21fd8(%eax)
f0103e30:	e8 50 f5 ff ff       	call   f0103385 <env_destroy>
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;

		env_run(curenv);
	}

}
f0103e35:	e9 a5 00 00 00       	jmp    f0103edf <page_fault_handler+0x129>
		cprintf("[%08x] user fault va %08x ip %08x\n",
                curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
		env_destroy(curenv);
	} else {
		if(tf->tf_esp < USTACKTOP)
f0103e3a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103e3d:	3d ff df bf ee       	cmp    $0xeebfdfff,%eax
f0103e42:	77 26                	ja     f0103e6a <page_fault_handler+0xb4>
		{
			uxtop = UXSTACKTOP - sizeof(struct UTrapframe);
			user_mem_assert(curenv, (const void *) uxtop, sizeof(struct UTrapframe), PTE_W|PTE_P);
f0103e44:	e8 09 1c 00 00       	call   f0105a52 <cpunum>
f0103e49:	6a 03                	push   $0x3
f0103e4b:	6a 34                	push   $0x34
f0103e4d:	68 cc ff bf ee       	push   $0xeebfffcc
f0103e52:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e55:	ff b0 28 e0 1d f0    	pushl  -0xfe21fd8(%eax)
f0103e5b:	e8 ad ee ff ff       	call   f0102d0d <user_mem_assert>
f0103e60:	83 c4 10             	add    $0x10,%esp
		print_trapframe(tf);
		env_destroy(curenv);
	} else {
		if(tf->tf_esp < USTACKTOP)
		{
			uxtop = UXSTACKTOP - sizeof(struct UTrapframe);
f0103e63:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
f0103e68:	eb 20                	jmp    f0103e8a <page_fault_handler+0xd4>
			user_mem_assert(curenv, (const void *) uxtop, sizeof(struct UTrapframe), PTE_W|PTE_P);
		} else {
			uxtop = tf->tf_esp - sizeof(struct UTrapframe) - 4; 
f0103e6a:	83 e8 38             	sub    $0x38,%eax
f0103e6d:	89 c7                	mov    %eax,%edi
			user_mem_assert(curenv, (const void *) uxtop, sizeof(struct UTrapframe)+4, PTE_W|PTE_P);
f0103e6f:	e8 de 1b 00 00       	call   f0105a52 <cpunum>
f0103e74:	6a 03                	push   $0x3
f0103e76:	6a 38                	push   $0x38
f0103e78:	57                   	push   %edi
f0103e79:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e7c:	ff b0 28 e0 1d f0    	pushl  -0xfe21fd8(%eax)
f0103e82:	e8 86 ee ff ff       	call   f0102d0d <user_mem_assert>
f0103e87:	83 c4 10             	add    $0x10,%esp
		}
//		cprintf("SRHS: uxtop value is %08x \n",uxtop);
//		user_mem_assert(curenv, (const void *) uxtop, PGSIZE, PTE_W|PTE_P);
		
		uxframe = (struct UTrapframe *) uxtop;
		uxframe->utf_fault_va = fault_va;
f0103e8a:	89 fa                	mov    %edi,%edx
f0103e8c:	89 37                	mov    %esi,(%edi)
		uxframe->utf_err = tf->tf_err;
f0103e8e:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103e91:	89 47 04             	mov    %eax,0x4(%edi)
		uxframe->utf_regs = tf->tf_regs;
f0103e94:	8d 7f 08             	lea    0x8(%edi),%edi
f0103e97:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103e9c:	89 de                	mov    %ebx,%esi
f0103e9e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		uxframe->utf_eip = tf->tf_eip;
f0103ea0:	8b 43 30             	mov    0x30(%ebx),%eax
f0103ea3:	89 42 28             	mov    %eax,0x28(%edx)
		uxframe->utf_eflags = tf->tf_eflags;
f0103ea6:	8b 43 38             	mov    0x38(%ebx),%eax
f0103ea9:	89 42 2c             	mov    %eax,0x2c(%edx)
		uxframe->utf_esp = tf->tf_esp;
f0103eac:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103eaf:	89 42 30             	mov    %eax,0x30(%edx)

		tf->tf_esp = (uintptr_t)uxframe;
f0103eb2:	89 53 3c             	mov    %edx,0x3c(%ebx)
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f0103eb5:	e8 98 1b 00 00       	call   f0105a52 <cpunum>
f0103eba:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ebd:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f0103ec3:	8b 40 64             	mov    0x64(%eax),%eax
f0103ec6:	89 43 30             	mov    %eax,0x30(%ebx)

		env_run(curenv);
f0103ec9:	e8 84 1b 00 00       	call   f0105a52 <cpunum>
f0103ece:	83 ec 0c             	sub    $0xc,%esp
f0103ed1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ed4:	ff b0 28 e0 1d f0    	pushl  -0xfe21fd8(%eax)
f0103eda:	e8 45 f5 ff ff       	call   f0103424 <env_run>
	}

}
f0103edf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103ee2:	5b                   	pop    %ebx
f0103ee3:	5e                   	pop    %esi
f0103ee4:	5f                   	pop    %edi
f0103ee5:	5d                   	pop    %ebp
f0103ee6:	c3                   	ret    

f0103ee7 <trap>:
	
}

void
trap(struct Trapframe *tf)
{
f0103ee7:	55                   	push   %ebp
f0103ee8:	89 e5                	mov    %esp,%ebp
f0103eea:	57                   	push   %edi
f0103eeb:	56                   	push   %esi
f0103eec:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103eef:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103ef0:	83 3d 80 de 1d f0 00 	cmpl   $0x0,0xf01dde80
f0103ef7:	74 01                	je     f0103efa <trap+0x13>
		asm volatile("hlt");
f0103ef9:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103efa:	e8 53 1b 00 00       	call   f0105a52 <cpunum>
f0103eff:	6b d0 74             	imul   $0x74,%eax,%edx
f0103f02:	81 c2 20 e0 1d f0    	add    $0xf01de020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103f08:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f0d:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103f11:	83 f8 02             	cmp    $0x2,%eax
f0103f14:	75 10                	jne    f0103f26 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103f16:	83 ec 0c             	sub    $0xc,%esp
f0103f19:	68 c0 03 12 f0       	push   $0xf01203c0
f0103f1e:	e8 9d 1d 00 00       	call   f0105cc0 <spin_lock>
f0103f23:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103f26:	9c                   	pushf  
f0103f27:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103f28:	f6 c4 02             	test   $0x2,%ah
f0103f2b:	74 19                	je     f0103f46 <trap+0x5f>
f0103f2d:	68 0c 76 10 f0       	push   $0xf010760c
f0103f32:	68 43 70 10 f0       	push   $0xf0107043
f0103f37:	68 2f 01 00 00       	push   $0x12f
f0103f3c:	68 00 76 10 f0       	push   $0xf0107600
f0103f41:	e8 fa c0 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103f46:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103f4a:	83 e0 03             	and    $0x3,%eax
f0103f4d:	66 83 f8 03          	cmp    $0x3,%ax
f0103f51:	0f 85 a0 00 00 00    	jne    f0103ff7 <trap+0x110>
f0103f57:	83 ec 0c             	sub    $0xc,%esp
f0103f5a:	68 c0 03 12 f0       	push   $0xf01203c0
f0103f5f:	e8 5c 1d 00 00       	call   f0105cc0 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0103f64:	e8 e9 1a 00 00       	call   f0105a52 <cpunum>
f0103f69:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f6c:	83 c4 10             	add    $0x10,%esp
f0103f6f:	83 b8 28 e0 1d f0 00 	cmpl   $0x0,-0xfe21fd8(%eax)
f0103f76:	75 19                	jne    f0103f91 <trap+0xaa>
f0103f78:	68 25 76 10 f0       	push   $0xf0107625
f0103f7d:	68 43 70 10 f0       	push   $0xf0107043
f0103f82:	68 37 01 00 00       	push   $0x137
f0103f87:	68 00 76 10 f0       	push   $0xf0107600
f0103f8c:	e8 af c0 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103f91:	e8 bc 1a 00 00       	call   f0105a52 <cpunum>
f0103f96:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f99:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f0103f9f:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103fa3:	75 2d                	jne    f0103fd2 <trap+0xeb>
			env_free(curenv);
f0103fa5:	e8 a8 1a 00 00       	call   f0105a52 <cpunum>
f0103faa:	83 ec 0c             	sub    $0xc,%esp
f0103fad:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fb0:	ff b0 28 e0 1d f0    	pushl  -0xfe21fd8(%eax)
f0103fb6:	e8 24 f2 ff ff       	call   f01031df <env_free>
			curenv = NULL;
f0103fbb:	e8 92 1a 00 00       	call   f0105a52 <cpunum>
f0103fc0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fc3:	c7 80 28 e0 1d f0 00 	movl   $0x0,-0xfe21fd8(%eax)
f0103fca:	00 00 00 
			sched_yield();
f0103fcd:	e8 ae 02 00 00       	call   f0104280 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103fd2:	e8 7b 1a 00 00       	call   f0105a52 <cpunum>
f0103fd7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fda:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f0103fe0:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103fe5:	89 c7                	mov    %eax,%edi
f0103fe7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103fe9:	e8 64 1a 00 00       	call   f0105a52 <cpunum>
f0103fee:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff1:	8b b0 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103ff7:	89 35 60 da 1d f0    	mov    %esi,0xf01dda60


	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103ffd:	8b 46 28             	mov    0x28(%esi),%eax
f0104000:	83 f8 27             	cmp    $0x27,%eax
f0104003:	75 1d                	jne    f0104022 <trap+0x13b>
		cprintf("Spurious interrupt on irq 7\n");
f0104005:	83 ec 0c             	sub    $0xc,%esp
f0104008:	68 2c 76 10 f0       	push   $0xf010762c
f010400d:	e8 6a f6 ff ff       	call   f010367c <cprintf>
		print_trapframe(tf);
f0104012:	89 34 24             	mov    %esi,(%esp)
f0104015:	e8 14 fc ff ff       	call   f0103c2e <print_trapframe>
f010401a:	83 c4 10             	add    $0x10,%esp
f010401d:	e9 ab 00 00 00       	jmp    f01040cd <trap+0x1e6>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if(tf->tf_trapno == (IRQ_OFFSET + IRQ_TIMER)) {
f0104022:	83 f8 20             	cmp    $0x20,%eax
f0104025:	75 17                	jne    f010403e <trap+0x157>
cprintf("SRHS: timer interrupt is here\n");
f0104027:	83 ec 0c             	sub    $0xc,%esp
f010402a:	68 f8 77 10 f0       	push   $0xf01077f8
f010402f:	e8 48 f6 ff ff       	call   f010367c <cprintf>
		lapic_eoi();
f0104034:	e8 64 1b 00 00       	call   f0105b9d <lapic_eoi>
                sched_yield();
f0104039:	e8 42 02 00 00       	call   f0104280 <sched_yield>

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.


	if (tf->tf_trapno == T_PGFLT) {
f010403e:	83 f8 0e             	cmp    $0xe,%eax
f0104041:	75 0e                	jne    f0104051 <trap+0x16a>
		page_fault_handler(tf);
f0104043:	83 ec 0c             	sub    $0xc,%esp
f0104046:	56                   	push   %esi
f0104047:	e8 6a fd ff ff       	call   f0103db6 <page_fault_handler>
f010404c:	83 c4 10             	add    $0x10,%esp
f010404f:	eb 7c                	jmp    f01040cd <trap+0x1e6>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f0104051:	83 f8 03             	cmp    $0x3,%eax
f0104054:	75 0e                	jne    f0104064 <trap+0x17d>
		monitor(tf);
f0104056:	83 ec 0c             	sub    $0xc,%esp
f0104059:	56                   	push   %esi
f010405a:	e8 c1 c8 ff ff       	call   f0100920 <monitor>
f010405f:	83 c4 10             	add    $0x10,%esp
f0104062:	eb 69                	jmp    f01040cd <trap+0x1e6>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f0104064:	83 f8 30             	cmp    $0x30,%eax
f0104067:	75 21                	jne    f010408a <trap+0x1a3>
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104069:	83 ec 08             	sub    $0x8,%esp
f010406c:	ff 76 04             	pushl  0x4(%esi)
f010406f:	ff 36                	pushl  (%esi)
f0104071:	ff 76 10             	pushl  0x10(%esi)
f0104074:	ff 76 18             	pushl  0x18(%esi)
f0104077:	ff 76 14             	pushl  0x14(%esi)
f010407a:	ff 76 1c             	pushl  0x1c(%esi)
f010407d:	e8 a2 02 00 00       	call   f0104324 <syscall>
	if (tf->tf_trapno == T_BRKPT) {
		monitor(tf);
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
		tf->tf_regs.reg_eax = 
f0104082:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104085:	83 c4 20             	add    $0x20,%esp
f0104088:	eb 43                	jmp    f01040cd <trap+0x1e6>
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010408a:	83 ec 0c             	sub    $0xc,%esp
f010408d:	56                   	push   %esi
f010408e:	e8 9b fb ff ff       	call   f0103c2e <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104093:	83 c4 10             	add    $0x10,%esp
f0104096:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010409b:	75 17                	jne    f01040b4 <trap+0x1cd>
		panic("unhandled trap in kernel");
f010409d:	83 ec 04             	sub    $0x4,%esp
f01040a0:	68 49 76 10 f0       	push   $0xf0107649
f01040a5:	68 13 01 00 00       	push   $0x113
f01040aa:	68 00 76 10 f0       	push   $0xf0107600
f01040af:	e8 8c bf ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01040b4:	e8 99 19 00 00       	call   f0105a52 <cpunum>
f01040b9:	83 ec 0c             	sub    $0xc,%esp
f01040bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01040bf:	ff b0 28 e0 1d f0    	pushl  -0xfe21fd8(%eax)
f01040c5:	e8 bb f2 ff ff       	call   f0103385 <env_destroy>
f01040ca:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01040cd:	e8 80 19 00 00       	call   f0105a52 <cpunum>
f01040d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01040d5:	83 b8 28 e0 1d f0 00 	cmpl   $0x0,-0xfe21fd8(%eax)
f01040dc:	74 2a                	je     f0104108 <trap+0x221>
f01040de:	e8 6f 19 00 00       	call   f0105a52 <cpunum>
f01040e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01040e6:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f01040ec:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01040f0:	75 16                	jne    f0104108 <trap+0x221>
		env_run(curenv);
f01040f2:	e8 5b 19 00 00       	call   f0105a52 <cpunum>
f01040f7:	83 ec 0c             	sub    $0xc,%esp
f01040fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01040fd:	ff b0 28 e0 1d f0    	pushl  -0xfe21fd8(%eax)
f0104103:	e8 1c f3 ff ff       	call   f0103424 <env_run>
	else
		sched_yield();
f0104108:	e8 73 01 00 00       	call   f0104280 <sched_yield>
f010410d:	90                   	nop

f010410e <divide_error>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

	TRAPHANDLER_NOEC(divide_error, 0)
f010410e:	6a 00                	push   $0x0
f0104110:	6a 00                	push   $0x0
f0104112:	e9 83 00 00 00       	jmp    f010419a <_alltraps>
f0104117:	90                   	nop

f0104118 <debug_exception>:
        TRAPHANDLER_NOEC(debug_exception, 1)
f0104118:	6a 00                	push   $0x0
f010411a:	6a 01                	push   $0x1
f010411c:	eb 7c                	jmp    f010419a <_alltraps>

f010411e <non_maskable_interrupt>:
        TRAPHANDLER_NOEC(non_maskable_interrupt, 2)    
f010411e:	6a 00                	push   $0x0
f0104120:	6a 02                	push   $0x2
f0104122:	eb 76                	jmp    f010419a <_alltraps>

f0104124 <break_point>:
        TRAPHANDLER_NOEC(break_point, 3)
f0104124:	6a 00                	push   $0x0
f0104126:	6a 03                	push   $0x3
f0104128:	eb 70                	jmp    f010419a <_alltraps>

f010412a <over_flow>:
        TRAPHANDLER_NOEC(over_flow, 4)
f010412a:	6a 00                	push   $0x0
f010412c:	6a 04                	push   $0x4
f010412e:	eb 6a                	jmp    f010419a <_alltraps>

f0104130 <bounds_check>:
        TRAPHANDLER_NOEC(bounds_check, 5)
f0104130:	6a 00                	push   $0x0
f0104132:	6a 05                	push   $0x5
f0104134:	eb 64                	jmp    f010419a <_alltraps>

f0104136 <illegal_opcode>:
        TRAPHANDLER_NOEC(illegal_opcode, 6)
f0104136:	6a 00                	push   $0x0
f0104138:	6a 06                	push   $0x6
f010413a:	eb 5e                	jmp    f010419a <_alltraps>

f010413c <device_not_available>:
        TRAPHANDLER_NOEC(device_not_available, 7)
f010413c:	6a 00                	push   $0x0
f010413e:	6a 07                	push   $0x7
f0104140:	eb 58                	jmp    f010419a <_alltraps>

f0104142 <double_fault>:
        TRAPHANDLER(double_fault, 8)
f0104142:	6a 08                	push   $0x8
f0104144:	eb 54                	jmp    f010419a <_alltraps>

f0104146 <task_segment_switch>:
    
        TRAPHANDLER(task_segment_switch, 10)
f0104146:	6a 0a                	push   $0xa
f0104148:	eb 50                	jmp    f010419a <_alltraps>

f010414a <segment_not_present>:
        TRAPHANDLER(segment_not_present, 11)
f010414a:	6a 0b                	push   $0xb
f010414c:	eb 4c                	jmp    f010419a <_alltraps>

f010414e <stack_exception>:
        TRAPHANDLER(stack_exception, 12)
f010414e:	6a 0c                	push   $0xc
f0104150:	eb 48                	jmp    f010419a <_alltraps>

f0104152 <general_protection_fault>:
        TRAPHANDLER(general_protection_fault, 13)
f0104152:	6a 0d                	push   $0xd
f0104154:	eb 44                	jmp    f010419a <_alltraps>

f0104156 <page_fault>:
        TRAPHANDLER(page_fault, 14)
f0104156:	6a 0e                	push   $0xe
f0104158:	eb 40                	jmp    f010419a <_alltraps>

f010415a <floating_point_error>:
    
        TRAPHANDLER_NOEC(floating_point_error, 16)
f010415a:	6a 00                	push   $0x0
f010415c:	6a 10                	push   $0x10
f010415e:	eb 3a                	jmp    f010419a <_alltraps>

f0104160 <alignment_check>:
        TRAPHANDLER(alignment_check, 17)
f0104160:	6a 11                	push   $0x11
f0104162:	eb 36                	jmp    f010419a <_alltraps>

f0104164 <machine_check>:
        TRAPHANDLER_NOEC(machine_check, 18)
f0104164:	6a 00                	push   $0x0
f0104166:	6a 12                	push   $0x12
f0104168:	eb 30                	jmp    f010419a <_alltraps>

f010416a <simd_floating_point_error>:
        TRAPHANDLER_NOEC(simd_floating_point_error, 19)
f010416a:	6a 00                	push   $0x0
f010416c:	6a 13                	push   $0x13
f010416e:	eb 2a                	jmp    f010419a <_alltraps>

f0104170 <system_call>:
        TRAPHANDLER_NOEC(system_call, 48)
f0104170:	6a 00                	push   $0x0
f0104172:	6a 30                	push   $0x30
f0104174:	eb 24                	jmp    f010419a <_alltraps>

f0104176 <fun_timer>:
        TRAPHANDLER_NOEC(fun_timer, IRQ_OFFSET + IRQ_TIMER)
f0104176:	6a 00                	push   $0x0
f0104178:	6a 20                	push   $0x20
f010417a:	eb 1e                	jmp    f010419a <_alltraps>

f010417c <fun_kbd>:
        TRAPHANDLER_NOEC(fun_kbd, IRQ_OFFSET + IRQ_KBD)
f010417c:	6a 00                	push   $0x0
f010417e:	6a 21                	push   $0x21
f0104180:	eb 18                	jmp    f010419a <_alltraps>

f0104182 <fun_spurious>:
        TRAPHANDLER_NOEC(fun_spurious, IRQ_OFFSET + IRQ_SPURIOUS)
f0104182:	6a 00                	push   $0x0
f0104184:	6a 27                	push   $0x27
f0104186:	eb 12                	jmp    f010419a <_alltraps>

f0104188 <fun_error>:
        TRAPHANDLER_NOEC(fun_error, IRQ_OFFSET + IRQ_ERROR)
f0104188:	6a 00                	push   $0x0
f010418a:	6a 33                	push   $0x33
f010418c:	eb 0c                	jmp    f010419a <_alltraps>

f010418e <fun_ide>:
        TRAPHANDLER_NOEC(fun_ide, IRQ_OFFSET + IRQ_IDE)
f010418e:	6a 00                	push   $0x0
f0104190:	6a 2e                	push   $0x2e
f0104192:	eb 06                	jmp    f010419a <_alltraps>

f0104194 <fun_serial>:
        TRAPHANDLER_NOEC(fun_serial, IRQ_OFFSET + IRQ_SERIAL)
f0104194:	6a 00                	push   $0x0
f0104196:	6a 24                	push   $0x24
f0104198:	eb 00                	jmp    f010419a <_alltraps>

f010419a <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
   
    pushl %ds
f010419a:	1e                   	push   %ds
    
    pushl %es
f010419b:	06                   	push   %es
    
    pushal
f010419c:	60                   	pusha  
    
    movl $GD_KD,%eax
f010419d:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax,%ds
f01041a2:	8e d8                	mov    %eax,%ds
    movw %ax,%es   
f01041a4:	8e c0                	mov    %eax,%es
    
    pushl %esp
f01041a6:	54                   	push   %esp
    call trap
f01041a7:	e8 3b fd ff ff       	call   f0103ee7 <trap>

f01041ac <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01041ac:	55                   	push   %ebp
f01041ad:	89 e5                	mov    %esp,%ebp
f01041af:	83 ec 08             	sub    $0x8,%esp
f01041b2:	a1 48 d2 1d f0       	mov    0xf01dd248,%eax
f01041b7:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01041ba:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01041bf:	8b 02                	mov    (%edx),%eax
f01041c1:	83 e8 01             	sub    $0x1,%eax
f01041c4:	83 f8 02             	cmp    $0x2,%eax
f01041c7:	76 10                	jbe    f01041d9 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01041c9:	83 c1 01             	add    $0x1,%ecx
f01041cc:	83 c2 7c             	add    $0x7c,%edx
f01041cf:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01041d5:	75 e8                	jne    f01041bf <sched_halt+0x13>
f01041d7:	eb 08                	jmp    f01041e1 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01041d9:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01041df:	75 1f                	jne    f0104200 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f01041e1:	83 ec 0c             	sub    $0xc,%esp
f01041e4:	68 70 78 10 f0       	push   $0xf0107870
f01041e9:	e8 8e f4 ff ff       	call   f010367c <cprintf>
f01041ee:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01041f1:	83 ec 0c             	sub    $0xc,%esp
f01041f4:	6a 00                	push   $0x0
f01041f6:	e8 25 c7 ff ff       	call   f0100920 <monitor>
f01041fb:	83 c4 10             	add    $0x10,%esp
f01041fe:	eb f1                	jmp    f01041f1 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104200:	e8 4d 18 00 00       	call   f0105a52 <cpunum>
f0104205:	6b c0 74             	imul   $0x74,%eax,%eax
f0104208:	c7 80 28 e0 1d f0 00 	movl   $0x0,-0xfe21fd8(%eax)
f010420f:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104212:	a1 8c de 1d f0       	mov    0xf01dde8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104217:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010421c:	77 12                	ja     f0104230 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010421e:	50                   	push   %eax
f010421f:	68 28 61 10 f0       	push   $0xf0106128
f0104224:	6a 67                	push   $0x67
f0104226:	68 99 78 10 f0       	push   $0xf0107899
f010422b:	e8 10 be ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104230:	05 00 00 00 10       	add    $0x10000000,%eax
f0104235:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104238:	e8 15 18 00 00       	call   f0105a52 <cpunum>
f010423d:	6b d0 74             	imul   $0x74,%eax,%edx
f0104240:	81 c2 20 e0 1d f0    	add    $0xf01de020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104246:	b8 02 00 00 00       	mov    $0x2,%eax
f010424b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010424f:	83 ec 0c             	sub    $0xc,%esp
f0104252:	68 c0 03 12 f0       	push   $0xf01203c0
f0104257:	e8 01 1b 00 00       	call   f0105d5d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010425c:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010425e:	e8 ef 17 00 00       	call   f0105a52 <cpunum>
f0104263:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104266:	8b 80 30 e0 1d f0    	mov    -0xfe21fd0(%eax),%eax
f010426c:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104271:	89 c4                	mov    %eax,%esp
f0104273:	6a 00                	push   $0x0
f0104275:	6a 00                	push   $0x0
f0104277:	fb                   	sti    
f0104278:	f4                   	hlt    
f0104279:	eb fd                	jmp    f0104278 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010427b:	83 c4 10             	add    $0x10,%esp
f010427e:	c9                   	leave  
f010427f:	c3                   	ret    

f0104280 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104280:	55                   	push   %ebp
f0104281:	89 e5                	mov    %esp,%ebp
f0104283:	56                   	push   %esi
f0104284:	53                   	push   %ebx
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	if( curenv == NULL)
f0104285:	e8 c8 17 00 00       	call   f0105a52 <cpunum>
f010428a:	6b c0 74             	imul   $0x74,%eax,%eax
f010428d:	83 b8 28 e0 1d f0 00 	cmpl   $0x0,-0xfe21fd8(%eax)
f0104294:	75 07                	jne    f010429d <sched_yield+0x1d>
	{
		idle = envs;
f0104296:	a1 48 d2 1d f0       	mov    0xf01dd248,%eax
f010429b:	eb 11                	jmp    f01042ae <sched_yield+0x2e>
		//tmp = envs+(NENV*sizeof(struct Env));
	} else {
		idle = curenv+1;//sizeof(struct Env);
f010429d:	e8 b0 17 00 00       	call   f0105a52 <cpunum>
f01042a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01042a5:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f01042ab:	83 c0 7c             	add    $0x7c,%eax
		{
			env_run(idle);
			return;
		}
		//idle ++;//= sizeof(struct Env);
		if(idle >= (envs+NENV))
f01042ae:	8b 1d 48 d2 1d f0    	mov    0xf01dd248,%ebx
f01042b4:	8d b3 00 f0 01 00    	lea    0x1f000(%ebx),%esi
f01042ba:	ba 00 04 00 00       	mov    $0x400,%edx
		idle = curenv+1;//sizeof(struct Env);
		//tmp = curenv;
	}
	while(i<1024)
	{
		if(idle->env_status == ENV_RUNNABLE)
f01042bf:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01042c3:	75 09                	jne    f01042ce <sched_yield+0x4e>
		{
			env_run(idle);
f01042c5:	83 ec 0c             	sub    $0xc,%esp
f01042c8:	50                   	push   %eax
f01042c9:	e8 56 f1 ff ff       	call   f0103424 <env_run>
		if(idle >= (envs+NENV))
//		if(ENVX(idle->env_id) == (NENV-1))
                {
                        idle = envs;
                } else {
			idle++;
f01042ce:	8d 48 7c             	lea    0x7c(%eax),%ecx
f01042d1:	39 c6                	cmp    %eax,%esi
f01042d3:	89 c8                	mov    %ecx,%eax
f01042d5:	0f 46 c3             	cmovbe %ebx,%eax
		//tmp = envs+(NENV*sizeof(struct Env));
	} else {
		idle = curenv+1;//sizeof(struct Env);
		//tmp = curenv;
	}
	while(i<1024)
f01042d8:	83 ea 01             	sub    $0x1,%edx
f01042db:	75 e2                	jne    f01042bf <sched_yield+0x3f>
                } else {
			idle++;
		}
		i++;
	}
	if(curenv != NULL && curenv->env_status == ENV_RUNNING)
f01042dd:	e8 70 17 00 00       	call   f0105a52 <cpunum>
f01042e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01042e5:	83 b8 28 e0 1d f0 00 	cmpl   $0x0,-0xfe21fd8(%eax)
f01042ec:	74 2a                	je     f0104318 <sched_yield+0x98>
f01042ee:	e8 5f 17 00 00       	call   f0105a52 <cpunum>
f01042f3:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f6:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f01042fc:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104300:	75 16                	jne    f0104318 <sched_yield+0x98>
	{
		env_run(curenv);
f0104302:	e8 4b 17 00 00       	call   f0105a52 <cpunum>
f0104307:	83 ec 0c             	sub    $0xc,%esp
f010430a:	6b c0 74             	imul   $0x74,%eax,%eax
f010430d:	ff b0 28 e0 1d f0    	pushl  -0xfe21fd8(%eax)
f0104313:	e8 0c f1 ff ff       	call   f0103424 <env_run>
	
	if (curenv != NULL && curenv->env_status == ENV_RUNNING)
env_run(curenv);*/

	// sched_halt never returns
	sched_halt();
f0104318:	e8 8f fe ff ff       	call   f01041ac <sched_halt>
}
f010431d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104320:	5b                   	pop    %ebx
f0104321:	5e                   	pop    %esi
f0104322:	5d                   	pop    %ebp
f0104323:	c3                   	ret    

f0104324 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104324:	55                   	push   %ebp
f0104325:	89 e5                	mov    %esp,%ebp
f0104327:	57                   	push   %edi
f0104328:	56                   	push   %esi
f0104329:	53                   	push   %ebx
f010432a:	83 ec 1c             	sub    $0x1c,%esp
f010432d:	8b 45 08             	mov    0x8(%ebp),%eax
	// LAB 3: Your code here.
	
	//panic("syscall not implemented");
	int env_des;
	//cprintf("in syscall:%u",syscallno);
	switch (syscallno) 
f0104330:	83 f8 0e             	cmp    $0xe,%eax
f0104333:	0f 87 73 05 00 00    	ja     f01048ac <syscall+0x588>
f0104339:	ff 24 85 ac 78 10 f0 	jmp    *-0xfef8754(,%eax,4)
			break;
		default:
			return -E_INVAL;
	}
	
	return 0;
f0104340:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104345:	e9 6e 05 00 00       	jmp    f01048b8 <syscall+0x594>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (void *)s, len, PTE_U);
f010434a:	e8 03 17 00 00       	call   f0105a52 <cpunum>
f010434f:	6a 04                	push   $0x4
f0104351:	ff 75 10             	pushl  0x10(%ebp)
f0104354:	ff 75 0c             	pushl  0xc(%ebp)
f0104357:	6b c0 74             	imul   $0x74,%eax,%eax
f010435a:	ff b0 28 e0 1d f0    	pushl  -0xfe21fd8(%eax)
f0104360:	e8 a8 e9 ff ff       	call   f0102d0d <user_mem_assert>
	//cprintf("\nIn the syscall\nValue of s:%x\nLen VAL:%u",s,len);
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104365:	83 c4 0c             	add    $0xc,%esp
f0104368:	ff 75 0c             	pushl  0xc(%ebp)
f010436b:	ff 75 10             	pushl  0x10(%ebp)
f010436e:	68 a6 78 10 f0       	push   $0xf01078a6
f0104373:	e8 04 f3 ff ff       	call   f010367c <cprintf>
f0104378:	83 c4 10             	add    $0x10,%esp
	//cprintf("in syscall:%u",syscallno);
	switch (syscallno) 
	{
		case SYS_cputs:
			sys_cputs((const char *)a1, a2);
			return 0;		
f010437b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104380:	e9 33 05 00 00       	jmp    f01048b8 <syscall+0x594>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104385:	e8 62 c2 ff ff       	call   f01005ec <cons_getc>
		case SYS_cputs:
			sys_cputs((const char *)a1, a2);
			return 0;		
		case SYS_cgetc:
			sys_cgetc();
			return 0;
f010438a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010438f:	e9 24 05 00 00       	jmp    f01048b8 <syscall+0x594>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104394:	e8 b9 16 00 00       	call   f0105a52 <cpunum>
f0104399:	6b c0 74             	imul   $0x74,%eax,%eax
f010439c:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f01043a2:	8b 58 48             	mov    0x48(%eax),%ebx
			return 0;		
		case SYS_cgetc:
			sys_cgetc();
			return 0;
		case SYS_getenvid:
			return sys_getenvid();
f01043a5:	e9 0e 05 00 00       	jmp    f01048b8 <syscall+0x594>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;
	//cprintf("Env Destroy, envid:[%08x]",envid);
	if ((r = envid2env(envid, &e, 1)) < 0)
f01043aa:	83 ec 04             	sub    $0x4,%esp
f01043ad:	6a 01                	push   $0x1
f01043af:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01043b2:	50                   	push   %eax
f01043b3:	ff 75 0c             	pushl  0xc(%ebp)
f01043b6:	e8 3d ea ff ff       	call   f0102df8 <envid2env>
f01043bb:	83 c4 10             	add    $0x10,%esp
		return r;
f01043be:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;
	//cprintf("Env Destroy, envid:[%08x]",envid);
	if ((r = envid2env(envid, &e, 1)) < 0)
f01043c0:	85 c0                	test   %eax,%eax
f01043c2:	0f 88 f0 04 00 00    	js     f01048b8 <syscall+0x594>
		return r;
	env_destroy(e);
f01043c8:	83 ec 0c             	sub    $0xc,%esp
f01043cb:	ff 75 e4             	pushl  -0x1c(%ebp)
f01043ce:	e8 b2 ef ff ff       	call   f0103385 <env_destroy>
f01043d3:	83 c4 10             	add    $0x10,%esp
	return 0;
f01043d6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01043db:	e9 d8 04 00 00       	jmp    f01048b8 <syscall+0x594>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01043e0:	e8 9b fe ff ff       	call   f0104280 <sched_yield>
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	if((uintptr_t)va >= UTOP || (((uintptr_t)va % PGSIZE) != 0))
f01043e5:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01043ec:	77 76                	ja     f0104464 <syscall+0x140>
f01043ee:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01043f5:	75 77                	jne    f010446e <syscall+0x14a>
		return -E_INVAL;

	if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
f01043f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01043fa:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01043ff:	83 f8 05             	cmp    $0x5,%eax
f0104402:	75 74                	jne    f0104478 <syscall+0x154>
		return -E_INVAL;
	
	struct Env * e;
	if(!(envid2env(envid, &e, true)))
f0104404:	83 ec 04             	sub    $0x4,%esp
f0104407:	6a 01                	push   $0x1
f0104409:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010440c:	50                   	push   %eax
f010440d:	ff 75 0c             	pushl  0xc(%ebp)
f0104410:	e8 e3 e9 ff ff       	call   f0102df8 <envid2env>
f0104415:	83 c4 10             	add    $0x10,%esp
f0104418:	85 c0                	test   %eax,%eax
f010441a:	75 66                	jne    f0104482 <syscall+0x15e>
	{
		struct PageInfo * pp = page_alloc(ALLOC_ZERO);
f010441c:	83 ec 0c             	sub    $0xc,%esp
f010441f:	6a 01                	push   $0x1
f0104421:	e8 bb ca ff ff       	call   f0100ee1 <page_alloc>
f0104426:	89 c6                	mov    %eax,%esi
		if(pp)
f0104428:	83 c4 10             	add    $0x10,%esp
f010442b:	85 c0                	test   %eax,%eax
f010442d:	74 5d                	je     f010448c <syscall+0x168>
		{
		//	cprintf("\nIn sys_page_alloc\n");
			if((page_insert(e->env_pgdir, pp, va, perm)) == 0)
f010442f:	ff 75 14             	pushl  0x14(%ebp)
f0104432:	ff 75 10             	pushl  0x10(%ebp)
f0104435:	50                   	push   %eax
f0104436:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104439:	ff 70 60             	pushl  0x60(%eax)
f010443c:	e8 29 cd ff ff       	call   f010116a <page_insert>
f0104441:	89 c3                	mov    %eax,%ebx
f0104443:	83 c4 10             	add    $0x10,%esp
f0104446:	85 c0                	test   %eax,%eax
f0104448:	0f 84 6a 04 00 00    	je     f01048b8 <syscall+0x594>
				return 0;
			else
			{
				page_free(pp);
f010444e:	83 ec 0c             	sub    $0xc,%esp
f0104451:	56                   	push   %esi
f0104452:	e8 fa ca ff ff       	call   f0100f51 <page_free>
f0104457:	83 c4 10             	add    $0x10,%esp
				return -E_NO_MEM;		
f010445a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010445f:	e9 54 04 00 00       	jmp    f01048b8 <syscall+0x594>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	if((uintptr_t)va >= UTOP || (((uintptr_t)va % PGSIZE) != 0))
		return -E_INVAL;
f0104464:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104469:	e9 4a 04 00 00       	jmp    f01048b8 <syscall+0x594>
f010446e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104473:	e9 40 04 00 00       	jmp    f01048b8 <syscall+0x594>

	if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
		return -E_INVAL;
f0104478:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010447d:	e9 36 04 00 00       	jmp    f01048b8 <syscall+0x594>
		}
		else
			return -E_NO_MEM;
	}
	else
		return -E_BAD_ENV;
f0104482:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104487:	e9 2c 04 00 00       	jmp    f01048b8 <syscall+0x594>
				page_free(pp);
				return -E_NO_MEM;		
			}
		}
		else
			return -E_NO_MEM;
f010448c:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
			return sys_env_destroy(a1);			
		case SYS_yield:
			sys_yield();
			break;
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, a3);
f0104491:	e9 22 04 00 00       	jmp    f01048b8 <syscall+0x594>
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	if((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP || (((uintptr_t)srcva%PGSIZE) != 0) || (((uintptr_t)dstva%PGSIZE) != 0))
f0104496:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010449d:	0f 87 f0 00 00 00    	ja     f0104593 <syscall+0x26f>
f01044a3:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01044aa:	0f 87 e3 00 00 00    	ja     f0104593 <syscall+0x26f>
f01044b0:	8b 45 10             	mov    0x10(%ebp),%eax
f01044b3:	0b 45 18             	or     0x18(%ebp),%eax
f01044b6:	a9 ff 0f 00 00       	test   $0xfff,%eax
f01044bb:	0f 85 dc 00 00 00    	jne    f010459d <syscall+0x279>
		return -E_INVAL;


	if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
f01044c1:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01044c4:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01044c9:	83 f8 05             	cmp    $0x5,%eax
f01044cc:	0f 85 d5 00 00 00    	jne    f01045a7 <syscall+0x283>
		return -E_INVAL;

	struct Env * src;
	struct Env * dst;
	if( !envid2env(srcenvid, &src, true) && !envid2env(dstenvid, &dst,  true))
f01044d2:	83 ec 04             	sub    $0x4,%esp
f01044d5:	6a 01                	push   $0x1
f01044d7:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01044da:	50                   	push   %eax
f01044db:	ff 75 0c             	pushl  0xc(%ebp)
f01044de:	e8 15 e9 ff ff       	call   f0102df8 <envid2env>
f01044e3:	83 c4 10             	add    $0x10,%esp
f01044e6:	85 c0                	test   %eax,%eax
f01044e8:	0f 85 c3 00 00 00    	jne    f01045b1 <syscall+0x28d>
f01044ee:	83 ec 04             	sub    $0x4,%esp
f01044f1:	6a 01                	push   $0x1
f01044f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01044f6:	50                   	push   %eax
f01044f7:	ff 75 14             	pushl  0x14(%ebp)
f01044fa:	e8 f9 e8 ff ff       	call   f0102df8 <envid2env>
f01044ff:	89 c6                	mov    %eax,%esi
f0104501:	83 c4 10             	add    $0x10,%esp
f0104504:	85 c0                	test   %eax,%eax
f0104506:	0f 85 af 00 00 00    	jne    f01045bb <syscall+0x297>
	{
		//cprintf("In sys_page_map\n");
		pte_t * pte;
		struct PageInfo * pp = page_lookup(src->env_pgdir, srcva, &pte);
f010450c:	83 ec 04             	sub    $0x4,%esp
f010450f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104512:	50                   	push   %eax
f0104513:	ff 75 10             	pushl  0x10(%ebp)
f0104516:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104519:	ff 70 60             	pushl  0x60(%eax)
f010451c:	e8 a6 cb ff ff       	call   f01010c7 <page_lookup>
		if(pp)
f0104521:	83 c4 10             	add    $0x10,%esp
f0104524:	85 c0                	test   %eax,%eax
f0104526:	74 61                	je     f0104589 <syscall+0x265>
		{
			if(perm & PTE_W)
f0104528:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f010452b:	83 e3 02             	and    $0x2,%ebx
f010452e:	74 35                	je     f0104565 <syscall+0x241>
						return -E_NO_MEM;
					else
						return 0;
				}
				else
					return -E_INVAL;
f0104530:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		struct PageInfo * pp = page_lookup(src->env_pgdir, srcva, &pte);
		if(pp)
		{
			if(perm & PTE_W)
			{
				if(*pte & PTE_W)
f0104535:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104538:	f6 02 02             	testb  $0x2,(%edx)
f010453b:	0f 84 77 03 00 00    	je     f01048b8 <syscall+0x594>
				{
					if(page_insert(dst->env_pgdir, pp, dstva, perm) < 0)
f0104541:	ff 75 1c             	pushl  0x1c(%ebp)
f0104544:	ff 75 18             	pushl  0x18(%ebp)
f0104547:	50                   	push   %eax
f0104548:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010454b:	ff 70 60             	pushl  0x60(%eax)
f010454e:	e8 17 cc ff ff       	call   f010116a <page_insert>
f0104553:	83 c4 10             	add    $0x10,%esp
						return -E_NO_MEM;
					else
						return 0;
f0104556:	85 c0                	test   %eax,%eax
f0104558:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010455d:	0f 49 de             	cmovns %esi,%ebx
f0104560:	e9 53 03 00 00       	jmp    f01048b8 <syscall+0x594>
				else
					return -E_INVAL;
			}
			else
			{
				if(page_insert(dst->env_pgdir, pp, dstva, perm) < 0)
f0104565:	ff 75 1c             	pushl  0x1c(%ebp)
f0104568:	ff 75 18             	pushl  0x18(%ebp)
f010456b:	50                   	push   %eax
f010456c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010456f:	ff 70 60             	pushl  0x60(%eax)
f0104572:	e8 f3 cb ff ff       	call   f010116a <page_insert>
f0104577:	83 c4 10             	add    $0x10,%esp
					return -E_NO_MEM;  	
f010457a:	85 c0                	test   %eax,%eax
f010457c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104581:	0f 48 d8             	cmovs  %eax,%ebx
f0104584:	e9 2f 03 00 00       	jmp    f01048b8 <syscall+0x594>
				else
					return 0;
			}
		}
		else
			return -E_INVAL; 
f0104589:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010458e:	e9 25 03 00 00       	jmp    f01048b8 <syscall+0x594>
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	if((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP || (((uintptr_t)srcva%PGSIZE) != 0) || (((uintptr_t)dstva%PGSIZE) != 0))
		return -E_INVAL;
f0104593:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104598:	e9 1b 03 00 00       	jmp    f01048b8 <syscall+0x594>
f010459d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01045a2:	e9 11 03 00 00       	jmp    f01048b8 <syscall+0x594>


	if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
		return -E_INVAL;
f01045a7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01045ac:	e9 07 03 00 00       	jmp    f01048b8 <syscall+0x594>
		}
		else
			return -E_INVAL; 
	}
	else 
		return -E_BAD_ENV;
f01045b1:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01045b6:	e9 fd 02 00 00       	jmp    f01048b8 <syscall+0x594>
f01045bb:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
			break;
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, a3);
			break;
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
f01045c0:	e9 f3 02 00 00       	jmp    f01048b8 <syscall+0x594>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if((uintptr_t)va >= UTOP || (uintptr_t)va%PGSIZE != 0)
f01045c5:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01045cc:	77 3c                	ja     f010460a <syscall+0x2e6>
f01045ce:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01045d5:	75 3d                	jne    f0104614 <syscall+0x2f0>
		return -E_INVAL;
	struct Env * e;
	if(!envid2env(envid, &e, true))
f01045d7:	83 ec 04             	sub    $0x4,%esp
f01045da:	6a 01                	push   $0x1
f01045dc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045df:	50                   	push   %eax
f01045e0:	ff 75 0c             	pushl  0xc(%ebp)
f01045e3:	e8 10 e8 ff ff       	call   f0102df8 <envid2env>
f01045e8:	89 c3                	mov    %eax,%ebx
f01045ea:	83 c4 10             	add    $0x10,%esp
f01045ed:	85 c0                	test   %eax,%eax
f01045ef:	75 2d                	jne    f010461e <syscall+0x2fa>
	{
		page_remove(e->env_pgdir, va);
f01045f1:	83 ec 08             	sub    $0x8,%esp
f01045f4:	ff 75 10             	pushl  0x10(%ebp)
f01045f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045fa:	ff 70 60             	pushl  0x60(%eax)
f01045fd:	e8 2d cb ff ff       	call   f010112f <page_remove>
f0104602:	83 c4 10             	add    $0x10,%esp
f0104605:	e9 ae 02 00 00       	jmp    f01048b8 <syscall+0x594>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if((uintptr_t)va >= UTOP || (uintptr_t)va%PGSIZE != 0)
		return -E_INVAL;
f010460a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010460f:	e9 a4 02 00 00       	jmp    f01048b8 <syscall+0x594>
f0104614:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104619:	e9 9a 02 00 00       	jmp    f01048b8 <syscall+0x594>
	{
		page_remove(e->env_pgdir, va);
		return 0;
	}
	else
		return -E_BAD_ENV;
f010461e:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
			break;
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
			break;
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
f0104623:	e9 90 02 00 00       	jmp    f01048b8 <syscall+0x594>

	// LAB 4: Your code here.
	struct Env * e;
	//cprintf("\nIn Exo Fork. Should be called once.\n");
	int r;
	if((r = env_alloc(&e, curenv->env_id)) == 0)
f0104628:	e8 25 14 00 00       	call   f0105a52 <cpunum>
f010462d:	83 ec 08             	sub    $0x8,%esp
f0104630:	6b c0 74             	imul   $0x74,%eax,%eax
f0104633:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f0104639:	ff 70 48             	pushl  0x48(%eax)
f010463c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010463f:	50                   	push   %eax
f0104640:	e8 e7 e8 ff ff       	call   f0102f2c <env_alloc>
f0104645:	83 c4 10             	add    $0x10,%esp
		e->env_tf = curenv->env_tf;
		e->env_tf.tf_regs.reg_eax = 0;	
	}
	else
	{
		return r;
f0104648:	89 c3                	mov    %eax,%ebx

	// LAB 4: Your code here.
	struct Env * e;
	//cprintf("\nIn Exo Fork. Should be called once.\n");
	int r;
	if((r = env_alloc(&e, curenv->env_id)) == 0)
f010464a:	85 c0                	test   %eax,%eax
f010464c:	0f 85 66 02 00 00    	jne    f01048b8 <syscall+0x594>
	{
		e->env_status = ENV_NOT_RUNNABLE;
f0104652:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104655:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
		//memmove((void *) &e->env_tf, (void *) &curenv->env_tf, sizeof(struct Trapframe));
		//cprintf("\nValue of new env's ip:%x\n",e->env_tf.tf_eip);
		e->env_tf = curenv->env_tf;
f010465c:	e8 f1 13 00 00       	call   f0105a52 <cpunum>
f0104661:	6b c0 74             	imul   $0x74,%eax,%eax
f0104664:	8b b0 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%esi
f010466a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010466f:	89 df                	mov    %ebx,%edi
f0104671:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		e->env_tf.tf_regs.reg_eax = 0;	
f0104673:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104676:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	else
	{
		return r;
	}
	
	return e->env_id;
f010467d:	8b 58 48             	mov    0x48(%eax),%ebx
f0104680:	e9 33 02 00 00       	jmp    f01048b8 <syscall+0x594>
	// envid's status.

	// LAB 4: Your code here.
	struct Env * e;
	//cprintf("\nStatus:%d",status);
	if(!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
f0104685:	8b 45 10             	mov    0x10(%ebp),%eax
f0104688:	83 e8 02             	sub    $0x2,%eax
f010468b:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104690:	75 28                	jne    f01046ba <syscall+0x396>
		return -E_INVAL;
	if(!(envid2env(envid, &e, true)))
f0104692:	83 ec 04             	sub    $0x4,%esp
f0104695:	6a 01                	push   $0x1
f0104697:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010469a:	50                   	push   %eax
f010469b:	ff 75 0c             	pushl  0xc(%ebp)
f010469e:	e8 55 e7 ff ff       	call   f0102df8 <envid2env>
f01046a3:	89 c3                	mov    %eax,%ebx
f01046a5:	83 c4 10             	add    $0x10,%esp
f01046a8:	85 c0                	test   %eax,%eax
f01046aa:	75 18                	jne    f01046c4 <syscall+0x3a0>
	{		
		e->env_status = status;
f01046ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046af:	8b 7d 10             	mov    0x10(%ebp),%edi
f01046b2:	89 78 54             	mov    %edi,0x54(%eax)
f01046b5:	e9 fe 01 00 00       	jmp    f01048b8 <syscall+0x594>

	// LAB 4: Your code here.
	struct Env * e;
	//cprintf("\nStatus:%d",status);
	if(!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
		return -E_INVAL;
f01046ba:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01046bf:	e9 f4 01 00 00       	jmp    f01048b8 <syscall+0x594>
	{		
		e->env_status = status;
		return 0;
	}
	else
		return -E_BAD_ENV;
f01046c4:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
			break;
		case SYS_exofork:
			return sys_exofork();
			break;
		case SYS_env_set_status:
			return sys_env_set_status(a1,a2);
f01046c9:	e9 ea 01 00 00       	jmp    f01048b8 <syscall+0x594>
{
	// LAB 4: Your code here.
	//panic("sys_env_set_pgfault_upcall not implemented");
	struct Env *e;

	if (!(envid2env(envid, &e, 1)))
f01046ce:	83 ec 04             	sub    $0x4,%esp
f01046d1:	6a 01                	push   $0x1
f01046d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046d6:	50                   	push   %eax
f01046d7:	ff 75 0c             	pushl  0xc(%ebp)
f01046da:	e8 19 e7 ff ff       	call   f0102df8 <envid2env>
f01046df:	89 c3                	mov    %eax,%ebx
f01046e1:	83 c4 10             	add    $0x10,%esp
f01046e4:	85 c0                	test   %eax,%eax
f01046e6:	75 0e                	jne    f01046f6 <syscall+0x3d2>
		e->env_pgfault_upcall = func;
f01046e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01046ee:	89 48 64             	mov    %ecx,0x64(%eax)
f01046f1:	e9 c2 01 00 00       	jmp    f01048b8 <syscall+0x594>
	else
		return -E_BAD_ENV;
f01046f6:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
			return sys_exofork();
			break;
		case SYS_env_set_status:
			return sys_env_set_status(a1,a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void *)a2);
f01046fb:	e9 b8 01 00 00       	jmp    f01048b8 <syscall+0x594>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uint32_t) dstva < UTOP) 
f0104700:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104707:	77 23                	ja     f010472c <syscall+0x408>
	{
		if ((uint32_t) dstva % PGSIZE != 0)
f0104709:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104710:	0f 85 9d 01 00 00    	jne    f01048b3 <syscall+0x58f>
			return -E_INVAL;
		curenv->env_ipc_dstva = dstva;
f0104716:	e8 37 13 00 00       	call   f0105a52 <cpunum>
f010471b:	6b c0 74             	imul   $0x74,%eax,%eax
f010471e:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f0104724:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104727:	89 50 6c             	mov    %edx,0x6c(%eax)
f010472a:	eb 15                	jmp    f0104741 <syscall+0x41d>
	} 
	else
		curenv->env_ipc_dstva = (void *) 0xF0000000;
f010472c:	e8 21 13 00 00       	call   f0105a52 <cpunum>
f0104731:	6b c0 74             	imul   $0x74,%eax,%eax
f0104734:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f010473a:	c7 40 6c 00 00 00 f0 	movl   $0xf0000000,0x6c(%eax)
		
	curenv->env_ipc_dstva = dstva;
f0104741:	e8 0c 13 00 00       	call   f0105a52 <cpunum>
f0104746:	6b c0 74             	imul   $0x74,%eax,%eax
f0104749:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f010474f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104752:	89 50 6c             	mov    %edx,0x6c(%eax)
	curenv->env_ipc_recving = true;
f0104755:	e8 f8 12 00 00       	call   f0105a52 <cpunum>
f010475a:	6b c0 74             	imul   $0x74,%eax,%eax
f010475d:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f0104763:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104767:	e8 e6 12 00 00       	call   f0105a52 <cpunum>
f010476c:	6b c0 74             	imul   $0x74,%eax,%eax
f010476f:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f0104775:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	//curenv->env_tf.tf_regs.reg_eax = 0;
	sched_yield();
f010477c:	e8 ff fa ff ff       	call   f0104280 <sched_yield>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env * targetEnv;
	if (envid2env(envid, &targetEnv, 0))
f0104781:	83 ec 04             	sub    $0x4,%esp
f0104784:	6a 00                	push   $0x0
f0104786:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104789:	50                   	push   %eax
f010478a:	ff 75 0c             	pushl  0xc(%ebp)
f010478d:	e8 66 e6 ff ff       	call   f0102df8 <envid2env>
f0104792:	89 c3                	mov    %eax,%ebx
f0104794:	83 c4 10             	add    $0x10,%esp
f0104797:	85 c0                	test   %eax,%eax
f0104799:	0f 85 f8 00 00 00    	jne    f0104897 <syscall+0x573>
		return -E_BAD_ENV;

	if(targetEnv->env_ipc_recving  == 0)
f010479f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01047a2:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01047a6:	0f 84 f2 00 00 00    	je     f010489e <syscall+0x57a>
		return -E_IPC_NOT_RECV;

	if( (uint32_t)srcva < UTOP && ((uint32_t)srcva % PGSIZE != 0))
f01047ac:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01047b3:	0f 87 a3 00 00 00    	ja     f010485c <syscall+0x538>
f01047b9:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01047c0:	0f 85 df 00 00 00    	jne    f01048a5 <syscall+0x581>
	

	// All the sender side checks are done.
	//Check for page_insert errors now and mark the destination environment ENV_RUNNABLE.

	if((uint32_t)targetEnv->env_ipc_dstva < UTOP && (uint32_t)srcva < UTOP)
f01047c6:	81 78 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%eax)
f01047cd:	0f 87 89 00 00 00    	ja     f010485c <syscall+0x538>
	{
		//int r;

		if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
f01047d3:	8b 45 18             	mov    0x18(%ebp),%eax
f01047d6:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01047db:	83 f8 05             	cmp    $0x5,%eax
f01047de:	75 59                	jne    f0104839 <syscall+0x515>
		{
			//cprintf("Permission failure\n");
			return -E_INVAL;
		}	
		pte_t * pte;
		struct PageInfo * pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f01047e0:	e8 6d 12 00 00       	call   f0105a52 <cpunum>
f01047e5:	83 ec 04             	sub    $0x4,%esp
f01047e8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01047eb:	52                   	push   %edx
f01047ec:	ff 75 14             	pushl  0x14(%ebp)
f01047ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01047f2:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f01047f8:	ff 70 60             	pushl  0x60(%eax)
f01047fb:	e8 c7 c8 ff ff       	call   f01010c7 <page_lookup>
		if(!pp)
f0104800:	83 c4 10             	add    $0x10,%esp
f0104803:	85 c0                	test   %eax,%eax
f0104805:	74 39                	je     f0104840 <syscall+0x51c>
			return -E_INVAL;
		if(!(perm & PTE_W && *pte & PTE_W))
f0104807:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f010480b:	74 3a                	je     f0104847 <syscall+0x523>
f010480d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104810:	f6 02 02             	testb  $0x2,(%edx)
f0104813:	74 39                	je     f010484e <syscall+0x52a>
		{
			//cprintf("Permission failure in write\n");
			return -E_INVAL;
		}
		
		if((page_insert(targetEnv->env_pgdir, pp, targetEnv->env_ipc_dstva, perm)) < 0)
f0104815:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104818:	ff 75 18             	pushl  0x18(%ebp)
f010481b:	ff 72 6c             	pushl  0x6c(%edx)
f010481e:	50                   	push   %eax
f010481f:	ff 72 60             	pushl  0x60(%edx)
f0104822:	e8 43 c9 ff ff       	call   f010116a <page_insert>
f0104827:	83 c4 10             	add    $0x10,%esp
f010482a:	85 c0                	test   %eax,%eax
f010482c:	78 27                	js     f0104855 <syscall+0x531>
			return -E_NO_MEM;	
		targetEnv->env_ipc_perm = perm;
f010482e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104831:	8b 55 18             	mov    0x18(%ebp),%edx
f0104834:	89 50 78             	mov    %edx,0x78(%eax)
f0104837:	eb 2a                	jmp    f0104863 <syscall+0x53f>
		//int r;

		if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
		{
			//cprintf("Permission failure\n");
			return -E_INVAL;
f0104839:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010483e:	eb 78                	jmp    f01048b8 <syscall+0x594>
		}	
		pte_t * pte;
		struct PageInfo * pp = page_lookup(curenv->env_pgdir, srcva, &pte);
		if(!pp)
			return -E_INVAL;
f0104840:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104845:	eb 71                	jmp    f01048b8 <syscall+0x594>
		if(!(perm & PTE_W && *pte & PTE_W))
		{
			//cprintf("Permission failure in write\n");
			return -E_INVAL;
f0104847:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010484c:	eb 6a                	jmp    f01048b8 <syscall+0x594>
f010484e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104853:	eb 63                	jmp    f01048b8 <syscall+0x594>
		}
		
		if((page_insert(targetEnv->env_pgdir, pp, targetEnv->env_ipc_dstva, perm)) < 0)
			return -E_NO_MEM;	
f0104855:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010485a:	eb 5c                	jmp    f01048b8 <syscall+0x594>
		targetEnv->env_ipc_perm = perm;
	}
	else
		targetEnv->env_ipc_perm = 0;
f010485c:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	

	targetEnv->env_ipc_recving = false;
f0104863:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104866:	c6 46 68 00          	movb   $0x0,0x68(%esi)
	targetEnv->env_ipc_value = value;
f010486a:	8b 45 10             	mov    0x10(%ebp),%eax
f010486d:	89 46 70             	mov    %eax,0x70(%esi)
	targetEnv->env_ipc_from = curenv->env_id;
f0104870:	e8 dd 11 00 00       	call   f0105a52 <cpunum>
f0104875:	6b c0 74             	imul   $0x74,%eax,%eax
f0104878:	8b 80 28 e0 1d f0    	mov    -0xfe21fd8(%eax),%eax
f010487e:	8b 40 48             	mov    0x48(%eax),%eax
f0104881:	89 46 74             	mov    %eax,0x74(%esi)
	targetEnv->env_status = ENV_RUNNABLE;
f0104884:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104887:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	targetEnv->env_tf.tf_regs.reg_eax = 0;
f010488e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0104895:	eb 21                	jmp    f01048b8 <syscall+0x594>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env * targetEnv;
	if (envid2env(envid, &targetEnv, 0))
		return -E_BAD_ENV;
f0104897:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010489c:	eb 1a                	jmp    f01048b8 <syscall+0x594>

	if(targetEnv->env_ipc_recving  == 0)
		return -E_IPC_NOT_RECV;
f010489e:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f01048a3:	eb 13                	jmp    f01048b8 <syscall+0x594>

	if( (uint32_t)srcva < UTOP && ((uint32_t)srcva % PGSIZE != 0))
	{
		//cprintf("srcva:%x\n",srcva);
		return -E_INVAL;
f01048a5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return sys_env_set_pgfault_upcall(a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
			break;
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f01048aa:	eb 0c                	jmp    f01048b8 <syscall+0x594>
			break;
		case NSYSCALLS:
			break;
		default:
			return -E_INVAL;
f01048ac:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048b1:	eb 05                	jmp    f01048b8 <syscall+0x594>
		case SYS_env_set_status:
			return sys_env_set_status(a1,a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f01048b3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		default:
			return -E_INVAL;
	}
	
	return 0;
}
f01048b8:	89 d8                	mov    %ebx,%eax
f01048ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01048bd:	5b                   	pop    %ebx
f01048be:	5e                   	pop    %esi
f01048bf:	5f                   	pop    %edi
f01048c0:	5d                   	pop    %ebp
f01048c1:	c3                   	ret    

f01048c2 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01048c2:	55                   	push   %ebp
f01048c3:	89 e5                	mov    %esp,%ebp
f01048c5:	57                   	push   %edi
f01048c6:	56                   	push   %esi
f01048c7:	53                   	push   %ebx
f01048c8:	83 ec 14             	sub    $0x14,%esp
f01048cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01048ce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01048d1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01048d4:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01048d7:	8b 1a                	mov    (%edx),%ebx
f01048d9:	8b 01                	mov    (%ecx),%eax
f01048db:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01048de:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01048e5:	eb 7f                	jmp    f0104966 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01048e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01048ea:	01 d8                	add    %ebx,%eax
f01048ec:	89 c6                	mov    %eax,%esi
f01048ee:	c1 ee 1f             	shr    $0x1f,%esi
f01048f1:	01 c6                	add    %eax,%esi
f01048f3:	d1 fe                	sar    %esi
f01048f5:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01048f8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01048fb:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01048fe:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104900:	eb 03                	jmp    f0104905 <stab_binsearch+0x43>
			m--;
f0104902:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104905:	39 c3                	cmp    %eax,%ebx
f0104907:	7f 0d                	jg     f0104916 <stab_binsearch+0x54>
f0104909:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010490d:	83 ea 0c             	sub    $0xc,%edx
f0104910:	39 f9                	cmp    %edi,%ecx
f0104912:	75 ee                	jne    f0104902 <stab_binsearch+0x40>
f0104914:	eb 05                	jmp    f010491b <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104916:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104919:	eb 4b                	jmp    f0104966 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010491b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010491e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104921:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104925:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104928:	76 11                	jbe    f010493b <stab_binsearch+0x79>
			*region_left = m;
f010492a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010492d:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010492f:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104932:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104939:	eb 2b                	jmp    f0104966 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010493b:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010493e:	73 14                	jae    f0104954 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104940:	83 e8 01             	sub    $0x1,%eax
f0104943:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104946:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104949:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010494b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104952:	eb 12                	jmp    f0104966 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104954:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104957:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104959:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010495d:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010495f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104966:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104969:	0f 8e 78 ff ff ff    	jle    f01048e7 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010496f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104973:	75 0f                	jne    f0104984 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104975:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104978:	8b 00                	mov    (%eax),%eax
f010497a:	83 e8 01             	sub    $0x1,%eax
f010497d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104980:	89 06                	mov    %eax,(%esi)
f0104982:	eb 2c                	jmp    f01049b0 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104984:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104987:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104989:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010498c:	8b 0e                	mov    (%esi),%ecx
f010498e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104991:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104994:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104997:	eb 03                	jmp    f010499c <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104999:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010499c:	39 c8                	cmp    %ecx,%eax
f010499e:	7e 0b                	jle    f01049ab <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01049a0:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01049a4:	83 ea 0c             	sub    $0xc,%edx
f01049a7:	39 df                	cmp    %ebx,%edi
f01049a9:	75 ee                	jne    f0104999 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01049ab:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01049ae:	89 06                	mov    %eax,(%esi)
	}
}
f01049b0:	83 c4 14             	add    $0x14,%esp
f01049b3:	5b                   	pop    %ebx
f01049b4:	5e                   	pop    %esi
f01049b5:	5f                   	pop    %edi
f01049b6:	5d                   	pop    %ebp
f01049b7:	c3                   	ret    

f01049b8 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01049b8:	55                   	push   %ebp
f01049b9:	89 e5                	mov    %esp,%ebp
f01049bb:	57                   	push   %edi
f01049bc:	56                   	push   %esi
f01049bd:	53                   	push   %ebx
f01049be:	83 ec 3c             	sub    $0x3c,%esp
f01049c1:	8b 7d 08             	mov    0x8(%ebp),%edi
f01049c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01049c7:	c7 03 e8 78 10 f0    	movl   $0xf01078e8,(%ebx)
	info->eip_line = 0;
f01049cd:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01049d4:	c7 43 08 e8 78 10 f0 	movl   $0xf01078e8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01049db:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01049e2:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01049e5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01049ec:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01049f2:	0f 87 a3 00 00 00    	ja     f0104a9b <debuginfo_eip+0xe3>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;
		
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U | PTE_P))
f01049f8:	e8 55 10 00 00       	call   f0105a52 <cpunum>
f01049fd:	6a 05                	push   $0x5
f01049ff:	6a 10                	push   $0x10
f0104a01:	68 00 00 20 00       	push   $0x200000
f0104a06:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a09:	ff b0 28 e0 1d f0    	pushl  -0xfe21fd8(%eax)
f0104a0f:	e8 71 e2 ff ff       	call   f0102c85 <user_mem_check>
f0104a14:	83 c4 10             	add    $0x10,%esp
f0104a17:	85 c0                	test   %eax,%eax
f0104a19:	0f 85 35 02 00 00    	jne    f0104c54 <debuginfo_eip+0x29c>
			return -1;

		
		stabs = usd->stabs;
f0104a1f:	a1 00 00 20 00       	mov    0x200000,%eax
f0104a24:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104a27:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104a2d:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104a33:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104a36:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104a3b:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U | PTE_P) )
f0104a3e:	e8 0f 10 00 00       	call   f0105a52 <cpunum>
f0104a43:	6a 05                	push   $0x5
f0104a45:	89 f2                	mov    %esi,%edx
f0104a47:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104a4a:	29 ca                	sub    %ecx,%edx
f0104a4c:	c1 fa 02             	sar    $0x2,%edx
f0104a4f:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104a55:	52                   	push   %edx
f0104a56:	51                   	push   %ecx
f0104a57:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a5a:	ff b0 28 e0 1d f0    	pushl  -0xfe21fd8(%eax)
f0104a60:	e8 20 e2 ff ff       	call   f0102c85 <user_mem_check>
f0104a65:	83 c4 10             	add    $0x10,%esp
f0104a68:	85 c0                	test   %eax,%eax
f0104a6a:	0f 85 eb 01 00 00    	jne    f0104c5b <debuginfo_eip+0x2a3>
			return -1;
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U | PTE_P) )
f0104a70:	e8 dd 0f 00 00       	call   f0105a52 <cpunum>
f0104a75:	6a 05                	push   $0x5
f0104a77:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104a7a:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104a7d:	29 ca                	sub    %ecx,%edx
f0104a7f:	52                   	push   %edx
f0104a80:	51                   	push   %ecx
f0104a81:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a84:	ff b0 28 e0 1d f0    	pushl  -0xfe21fd8(%eax)
f0104a8a:	e8 f6 e1 ff ff       	call   f0102c85 <user_mem_check>
f0104a8f:	83 c4 10             	add    $0x10,%esp
f0104a92:	85 c0                	test   %eax,%eax
f0104a94:	74 1f                	je     f0104ab5 <debuginfo_eip+0xfd>
f0104a96:	e9 c7 01 00 00       	jmp    f0104c62 <debuginfo_eip+0x2aa>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104a9b:	c7 45 bc 6b 55 11 f0 	movl   $0xf011556b,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104aa2:	c7 45 b8 51 1e 11 f0 	movl   $0xf0111e51,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104aa9:	be 50 1e 11 f0       	mov    $0xf0111e50,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104aae:	c7 45 c0 90 7e 10 f0 	movl   $0xf0107e90,-0x40(%ebp)
			return -1;

	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104ab5:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104ab8:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104abb:	0f 83 a8 01 00 00    	jae    f0104c69 <debuginfo_eip+0x2b1>
f0104ac1:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104ac5:	0f 85 a5 01 00 00    	jne    f0104c70 <debuginfo_eip+0x2b8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104acb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104ad2:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104ad5:	c1 fe 02             	sar    $0x2,%esi
f0104ad8:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104ade:	83 e8 01             	sub    $0x1,%eax
f0104ae1:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104ae4:	83 ec 08             	sub    $0x8,%esp
f0104ae7:	57                   	push   %edi
f0104ae8:	6a 64                	push   $0x64
f0104aea:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104aed:	89 d1                	mov    %edx,%ecx
f0104aef:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104af2:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104af5:	89 f0                	mov    %esi,%eax
f0104af7:	e8 c6 fd ff ff       	call   f01048c2 <stab_binsearch>
	if (lfile == 0)
f0104afc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104aff:	83 c4 10             	add    $0x10,%esp
f0104b02:	85 c0                	test   %eax,%eax
f0104b04:	0f 84 6d 01 00 00    	je     f0104c77 <debuginfo_eip+0x2bf>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104b0a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104b0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b10:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104b13:	83 ec 08             	sub    $0x8,%esp
f0104b16:	57                   	push   %edi
f0104b17:	6a 24                	push   $0x24
f0104b19:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104b1c:	89 d1                	mov    %edx,%ecx
f0104b1e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104b21:	89 f0                	mov    %esi,%eax
f0104b23:	e8 9a fd ff ff       	call   f01048c2 <stab_binsearch>

	if (lfun <= rfun) {
f0104b28:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104b2b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104b2e:	83 c4 10             	add    $0x10,%esp
f0104b31:	39 d0                	cmp    %edx,%eax
f0104b33:	7f 2e                	jg     f0104b63 <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104b35:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104b38:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104b3b:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104b3e:	8b 36                	mov    (%esi),%esi
f0104b40:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104b43:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104b46:	39 ce                	cmp    %ecx,%esi
f0104b48:	73 06                	jae    f0104b50 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104b4a:	03 75 b8             	add    -0x48(%ebp),%esi
f0104b4d:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104b50:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104b53:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104b56:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104b59:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104b5b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104b5e:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104b61:	eb 0f                	jmp    f0104b72 <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104b63:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104b66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b69:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104b6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b6f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104b72:	83 ec 08             	sub    $0x8,%esp
f0104b75:	6a 3a                	push   $0x3a
f0104b77:	ff 73 08             	pushl  0x8(%ebx)
f0104b7a:	e8 97 08 00 00       	call   f0105416 <strfind>
f0104b7f:	2b 43 08             	sub    0x8(%ebx),%eax
f0104b82:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104b85:	83 c4 08             	add    $0x8,%esp
f0104b88:	57                   	push   %edi
f0104b89:	6a 44                	push   $0x44
f0104b8b:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104b8e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104b91:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104b94:	89 f8                	mov    %edi,%eax
f0104b96:	e8 27 fd ff ff       	call   f01048c2 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0104b9b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104b9e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104ba1:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104ba4:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f0104ba8:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104bab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104bae:	83 c4 10             	add    $0x10,%esp
f0104bb1:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104bb5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104bb8:	eb 0a                	jmp    f0104bc4 <debuginfo_eip+0x20c>
f0104bba:	83 e8 01             	sub    $0x1,%eax
f0104bbd:	83 ea 0c             	sub    $0xc,%edx
f0104bc0:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104bc4:	39 c7                	cmp    %eax,%edi
f0104bc6:	7e 05                	jle    f0104bcd <debuginfo_eip+0x215>
f0104bc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104bcb:	eb 47                	jmp    f0104c14 <debuginfo_eip+0x25c>
	       && stabs[lline].n_type != N_SOL
f0104bcd:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104bd1:	80 f9 84             	cmp    $0x84,%cl
f0104bd4:	75 0e                	jne    f0104be4 <debuginfo_eip+0x22c>
f0104bd6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104bd9:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104bdd:	74 1c                	je     f0104bfb <debuginfo_eip+0x243>
f0104bdf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104be2:	eb 17                	jmp    f0104bfb <debuginfo_eip+0x243>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104be4:	80 f9 64             	cmp    $0x64,%cl
f0104be7:	75 d1                	jne    f0104bba <debuginfo_eip+0x202>
f0104be9:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104bed:	74 cb                	je     f0104bba <debuginfo_eip+0x202>
f0104bef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104bf2:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104bf6:	74 03                	je     f0104bfb <debuginfo_eip+0x243>
f0104bf8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104bfb:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104bfe:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104c01:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104c04:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104c07:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104c0a:	29 f8                	sub    %edi,%eax
f0104c0c:	39 c2                	cmp    %eax,%edx
f0104c0e:	73 04                	jae    f0104c14 <debuginfo_eip+0x25c>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104c10:	01 fa                	add    %edi,%edx
f0104c12:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104c14:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104c17:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104c1a:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104c1f:	39 f2                	cmp    %esi,%edx
f0104c21:	7d 60                	jge    f0104c83 <debuginfo_eip+0x2cb>
		for (lline = lfun + 1;
f0104c23:	83 c2 01             	add    $0x1,%edx
f0104c26:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104c29:	89 d0                	mov    %edx,%eax
f0104c2b:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104c2e:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104c31:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104c34:	eb 04                	jmp    f0104c3a <debuginfo_eip+0x282>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104c36:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104c3a:	39 c6                	cmp    %eax,%esi
f0104c3c:	7e 40                	jle    f0104c7e <debuginfo_eip+0x2c6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104c3e:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104c42:	83 c0 01             	add    $0x1,%eax
f0104c45:	83 c2 0c             	add    $0xc,%edx
f0104c48:	80 f9 a0             	cmp    $0xa0,%cl
f0104c4b:	74 e9                	je     f0104c36 <debuginfo_eip+0x27e>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104c4d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c52:	eb 2f                	jmp    f0104c83 <debuginfo_eip+0x2cb>
		
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U | PTE_P))
			return -1;
f0104c54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104c59:	eb 28                	jmp    f0104c83 <debuginfo_eip+0x2cb>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U | PTE_P) )
			return -1;
f0104c5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104c60:	eb 21                	jmp    f0104c83 <debuginfo_eip+0x2cb>
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U | PTE_P) )
			return -1;
f0104c62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104c67:	eb 1a                	jmp    f0104c83 <debuginfo_eip+0x2cb>

	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104c69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104c6e:	eb 13                	jmp    f0104c83 <debuginfo_eip+0x2cb>
f0104c70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104c75:	eb 0c                	jmp    f0104c83 <debuginfo_eip+0x2cb>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104c77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104c7c:	eb 05                	jmp    f0104c83 <debuginfo_eip+0x2cb>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104c7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c86:	5b                   	pop    %ebx
f0104c87:	5e                   	pop    %esi
f0104c88:	5f                   	pop    %edi
f0104c89:	5d                   	pop    %ebp
f0104c8a:	c3                   	ret    

f0104c8b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104c8b:	55                   	push   %ebp
f0104c8c:	89 e5                	mov    %esp,%ebp
f0104c8e:	57                   	push   %edi
f0104c8f:	56                   	push   %esi
f0104c90:	53                   	push   %ebx
f0104c91:	83 ec 1c             	sub    $0x1c,%esp
f0104c94:	89 c7                	mov    %eax,%edi
f0104c96:	89 d6                	mov    %edx,%esi
f0104c98:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c9b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104c9e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ca1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104ca4:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104ca7:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104cac:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104caf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104cb2:	39 d3                	cmp    %edx,%ebx
f0104cb4:	72 05                	jb     f0104cbb <printnum+0x30>
f0104cb6:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104cb9:	77 45                	ja     f0104d00 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104cbb:	83 ec 0c             	sub    $0xc,%esp
f0104cbe:	ff 75 18             	pushl  0x18(%ebp)
f0104cc1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cc4:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104cc7:	53                   	push   %ebx
f0104cc8:	ff 75 10             	pushl  0x10(%ebp)
f0104ccb:	83 ec 08             	sub    $0x8,%esp
f0104cce:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104cd1:	ff 75 e0             	pushl  -0x20(%ebp)
f0104cd4:	ff 75 dc             	pushl  -0x24(%ebp)
f0104cd7:	ff 75 d8             	pushl  -0x28(%ebp)
f0104cda:	e8 71 11 00 00       	call   f0105e50 <__udivdi3>
f0104cdf:	83 c4 18             	add    $0x18,%esp
f0104ce2:	52                   	push   %edx
f0104ce3:	50                   	push   %eax
f0104ce4:	89 f2                	mov    %esi,%edx
f0104ce6:	89 f8                	mov    %edi,%eax
f0104ce8:	e8 9e ff ff ff       	call   f0104c8b <printnum>
f0104ced:	83 c4 20             	add    $0x20,%esp
f0104cf0:	eb 18                	jmp    f0104d0a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104cf2:	83 ec 08             	sub    $0x8,%esp
f0104cf5:	56                   	push   %esi
f0104cf6:	ff 75 18             	pushl  0x18(%ebp)
f0104cf9:	ff d7                	call   *%edi
f0104cfb:	83 c4 10             	add    $0x10,%esp
f0104cfe:	eb 03                	jmp    f0104d03 <printnum+0x78>
f0104d00:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104d03:	83 eb 01             	sub    $0x1,%ebx
f0104d06:	85 db                	test   %ebx,%ebx
f0104d08:	7f e8                	jg     f0104cf2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104d0a:	83 ec 08             	sub    $0x8,%esp
f0104d0d:	56                   	push   %esi
f0104d0e:	83 ec 04             	sub    $0x4,%esp
f0104d11:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104d14:	ff 75 e0             	pushl  -0x20(%ebp)
f0104d17:	ff 75 dc             	pushl  -0x24(%ebp)
f0104d1a:	ff 75 d8             	pushl  -0x28(%ebp)
f0104d1d:	e8 5e 12 00 00       	call   f0105f80 <__umoddi3>
f0104d22:	83 c4 14             	add    $0x14,%esp
f0104d25:	0f be 80 f2 78 10 f0 	movsbl -0xfef870e(%eax),%eax
f0104d2c:	50                   	push   %eax
f0104d2d:	ff d7                	call   *%edi
}
f0104d2f:	83 c4 10             	add    $0x10,%esp
f0104d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104d35:	5b                   	pop    %ebx
f0104d36:	5e                   	pop    %esi
f0104d37:	5f                   	pop    %edi
f0104d38:	5d                   	pop    %ebp
f0104d39:	c3                   	ret    

f0104d3a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104d3a:	55                   	push   %ebp
f0104d3b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104d3d:	83 fa 01             	cmp    $0x1,%edx
f0104d40:	7e 0e                	jle    f0104d50 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104d42:	8b 10                	mov    (%eax),%edx
f0104d44:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104d47:	89 08                	mov    %ecx,(%eax)
f0104d49:	8b 02                	mov    (%edx),%eax
f0104d4b:	8b 52 04             	mov    0x4(%edx),%edx
f0104d4e:	eb 22                	jmp    f0104d72 <getuint+0x38>
	else if (lflag)
f0104d50:	85 d2                	test   %edx,%edx
f0104d52:	74 10                	je     f0104d64 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104d54:	8b 10                	mov    (%eax),%edx
f0104d56:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104d59:	89 08                	mov    %ecx,(%eax)
f0104d5b:	8b 02                	mov    (%edx),%eax
f0104d5d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104d62:	eb 0e                	jmp    f0104d72 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104d64:	8b 10                	mov    (%eax),%edx
f0104d66:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104d69:	89 08                	mov    %ecx,(%eax)
f0104d6b:	8b 02                	mov    (%edx),%eax
f0104d6d:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104d72:	5d                   	pop    %ebp
f0104d73:	c3                   	ret    

f0104d74 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104d74:	55                   	push   %ebp
f0104d75:	89 e5                	mov    %esp,%ebp
f0104d77:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104d7a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104d7e:	8b 10                	mov    (%eax),%edx
f0104d80:	3b 50 04             	cmp    0x4(%eax),%edx
f0104d83:	73 0a                	jae    f0104d8f <sprintputch+0x1b>
		*b->buf++ = ch;
f0104d85:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104d88:	89 08                	mov    %ecx,(%eax)
f0104d8a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d8d:	88 02                	mov    %al,(%edx)
}
f0104d8f:	5d                   	pop    %ebp
f0104d90:	c3                   	ret    

f0104d91 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104d91:	55                   	push   %ebp
f0104d92:	89 e5                	mov    %esp,%ebp
f0104d94:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104d97:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104d9a:	50                   	push   %eax
f0104d9b:	ff 75 10             	pushl  0x10(%ebp)
f0104d9e:	ff 75 0c             	pushl  0xc(%ebp)
f0104da1:	ff 75 08             	pushl  0x8(%ebp)
f0104da4:	e8 05 00 00 00       	call   f0104dae <vprintfmt>
	va_end(ap);
}
f0104da9:	83 c4 10             	add    $0x10,%esp
f0104dac:	c9                   	leave  
f0104dad:	c3                   	ret    

f0104dae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104dae:	55                   	push   %ebp
f0104daf:	89 e5                	mov    %esp,%ebp
f0104db1:	57                   	push   %edi
f0104db2:	56                   	push   %esi
f0104db3:	53                   	push   %ebx
f0104db4:	83 ec 2c             	sub    $0x2c,%esp
f0104db7:	8b 75 08             	mov    0x8(%ebp),%esi
f0104dba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104dbd:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104dc0:	eb 12                	jmp    f0104dd4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104dc2:	85 c0                	test   %eax,%eax
f0104dc4:	0f 84 89 03 00 00    	je     f0105153 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0104dca:	83 ec 08             	sub    $0x8,%esp
f0104dcd:	53                   	push   %ebx
f0104dce:	50                   	push   %eax
f0104dcf:	ff d6                	call   *%esi
f0104dd1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104dd4:	83 c7 01             	add    $0x1,%edi
f0104dd7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104ddb:	83 f8 25             	cmp    $0x25,%eax
f0104dde:	75 e2                	jne    f0104dc2 <vprintfmt+0x14>
f0104de0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104de4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104deb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104df2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104df9:	ba 00 00 00 00       	mov    $0x0,%edx
f0104dfe:	eb 07                	jmp    f0104e07 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e00:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104e03:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e07:	8d 47 01             	lea    0x1(%edi),%eax
f0104e0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104e0d:	0f b6 07             	movzbl (%edi),%eax
f0104e10:	0f b6 c8             	movzbl %al,%ecx
f0104e13:	83 e8 23             	sub    $0x23,%eax
f0104e16:	3c 55                	cmp    $0x55,%al
f0104e18:	0f 87 1a 03 00 00    	ja     f0105138 <vprintfmt+0x38a>
f0104e1e:	0f b6 c0             	movzbl %al,%eax
f0104e21:	ff 24 85 40 7a 10 f0 	jmp    *-0xfef85c0(,%eax,4)
f0104e28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104e2b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104e2f:	eb d6                	jmp    f0104e07 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e31:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e34:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e39:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104e3c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104e3f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104e43:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104e46:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104e49:	83 fa 09             	cmp    $0x9,%edx
f0104e4c:	77 39                	ja     f0104e87 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104e4e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104e51:	eb e9                	jmp    f0104e3c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104e53:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e56:	8d 48 04             	lea    0x4(%eax),%ecx
f0104e59:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104e5c:	8b 00                	mov    (%eax),%eax
f0104e5e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e61:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104e64:	eb 27                	jmp    f0104e8d <vprintfmt+0xdf>
f0104e66:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e69:	85 c0                	test   %eax,%eax
f0104e6b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104e70:	0f 49 c8             	cmovns %eax,%ecx
f0104e73:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e79:	eb 8c                	jmp    f0104e07 <vprintfmt+0x59>
f0104e7b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104e7e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104e85:	eb 80                	jmp    f0104e07 <vprintfmt+0x59>
f0104e87:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e8a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104e8d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104e91:	0f 89 70 ff ff ff    	jns    f0104e07 <vprintfmt+0x59>
				width = precision, precision = -1;
f0104e97:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104e9a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104e9d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104ea4:	e9 5e ff ff ff       	jmp    f0104e07 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104ea9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104eac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104eaf:	e9 53 ff ff ff       	jmp    f0104e07 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104eb4:	8b 45 14             	mov    0x14(%ebp),%eax
f0104eb7:	8d 50 04             	lea    0x4(%eax),%edx
f0104eba:	89 55 14             	mov    %edx,0x14(%ebp)
f0104ebd:	83 ec 08             	sub    $0x8,%esp
f0104ec0:	53                   	push   %ebx
f0104ec1:	ff 30                	pushl  (%eax)
f0104ec3:	ff d6                	call   *%esi
			break;
f0104ec5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ec8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104ecb:	e9 04 ff ff ff       	jmp    f0104dd4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104ed0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ed3:	8d 50 04             	lea    0x4(%eax),%edx
f0104ed6:	89 55 14             	mov    %edx,0x14(%ebp)
f0104ed9:	8b 00                	mov    (%eax),%eax
f0104edb:	99                   	cltd   
f0104edc:	31 d0                	xor    %edx,%eax
f0104ede:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104ee0:	83 f8 0f             	cmp    $0xf,%eax
f0104ee3:	7f 0b                	jg     f0104ef0 <vprintfmt+0x142>
f0104ee5:	8b 14 85 a0 7b 10 f0 	mov    -0xfef8460(,%eax,4),%edx
f0104eec:	85 d2                	test   %edx,%edx
f0104eee:	75 18                	jne    f0104f08 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0104ef0:	50                   	push   %eax
f0104ef1:	68 0a 79 10 f0       	push   $0xf010790a
f0104ef6:	53                   	push   %ebx
f0104ef7:	56                   	push   %esi
f0104ef8:	e8 94 fe ff ff       	call   f0104d91 <printfmt>
f0104efd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f00:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104f03:	e9 cc fe ff ff       	jmp    f0104dd4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104f08:	52                   	push   %edx
f0104f09:	68 55 70 10 f0       	push   $0xf0107055
f0104f0e:	53                   	push   %ebx
f0104f0f:	56                   	push   %esi
f0104f10:	e8 7c fe ff ff       	call   f0104d91 <printfmt>
f0104f15:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f1b:	e9 b4 fe ff ff       	jmp    f0104dd4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104f20:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f23:	8d 50 04             	lea    0x4(%eax),%edx
f0104f26:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f29:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104f2b:	85 ff                	test   %edi,%edi
f0104f2d:	b8 03 79 10 f0       	mov    $0xf0107903,%eax
f0104f32:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104f35:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104f39:	0f 8e 94 00 00 00    	jle    f0104fd3 <vprintfmt+0x225>
f0104f3f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104f43:	0f 84 98 00 00 00    	je     f0104fe1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104f49:	83 ec 08             	sub    $0x8,%esp
f0104f4c:	ff 75 d0             	pushl  -0x30(%ebp)
f0104f4f:	57                   	push   %edi
f0104f50:	e8 77 03 00 00       	call   f01052cc <strnlen>
f0104f55:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104f58:	29 c1                	sub    %eax,%ecx
f0104f5a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104f5d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104f60:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104f64:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104f67:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104f6a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104f6c:	eb 0f                	jmp    f0104f7d <vprintfmt+0x1cf>
					putch(padc, putdat);
f0104f6e:	83 ec 08             	sub    $0x8,%esp
f0104f71:	53                   	push   %ebx
f0104f72:	ff 75 e0             	pushl  -0x20(%ebp)
f0104f75:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104f77:	83 ef 01             	sub    $0x1,%edi
f0104f7a:	83 c4 10             	add    $0x10,%esp
f0104f7d:	85 ff                	test   %edi,%edi
f0104f7f:	7f ed                	jg     f0104f6e <vprintfmt+0x1c0>
f0104f81:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104f84:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104f87:	85 c9                	test   %ecx,%ecx
f0104f89:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f8e:	0f 49 c1             	cmovns %ecx,%eax
f0104f91:	29 c1                	sub    %eax,%ecx
f0104f93:	89 75 08             	mov    %esi,0x8(%ebp)
f0104f96:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104f99:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104f9c:	89 cb                	mov    %ecx,%ebx
f0104f9e:	eb 4d                	jmp    f0104fed <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104fa0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104fa4:	74 1b                	je     f0104fc1 <vprintfmt+0x213>
f0104fa6:	0f be c0             	movsbl %al,%eax
f0104fa9:	83 e8 20             	sub    $0x20,%eax
f0104fac:	83 f8 5e             	cmp    $0x5e,%eax
f0104faf:	76 10                	jbe    f0104fc1 <vprintfmt+0x213>
					putch('?', putdat);
f0104fb1:	83 ec 08             	sub    $0x8,%esp
f0104fb4:	ff 75 0c             	pushl  0xc(%ebp)
f0104fb7:	6a 3f                	push   $0x3f
f0104fb9:	ff 55 08             	call   *0x8(%ebp)
f0104fbc:	83 c4 10             	add    $0x10,%esp
f0104fbf:	eb 0d                	jmp    f0104fce <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0104fc1:	83 ec 08             	sub    $0x8,%esp
f0104fc4:	ff 75 0c             	pushl  0xc(%ebp)
f0104fc7:	52                   	push   %edx
f0104fc8:	ff 55 08             	call   *0x8(%ebp)
f0104fcb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104fce:	83 eb 01             	sub    $0x1,%ebx
f0104fd1:	eb 1a                	jmp    f0104fed <vprintfmt+0x23f>
f0104fd3:	89 75 08             	mov    %esi,0x8(%ebp)
f0104fd6:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104fd9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104fdc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104fdf:	eb 0c                	jmp    f0104fed <vprintfmt+0x23f>
f0104fe1:	89 75 08             	mov    %esi,0x8(%ebp)
f0104fe4:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104fe7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104fea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104fed:	83 c7 01             	add    $0x1,%edi
f0104ff0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104ff4:	0f be d0             	movsbl %al,%edx
f0104ff7:	85 d2                	test   %edx,%edx
f0104ff9:	74 23                	je     f010501e <vprintfmt+0x270>
f0104ffb:	85 f6                	test   %esi,%esi
f0104ffd:	78 a1                	js     f0104fa0 <vprintfmt+0x1f2>
f0104fff:	83 ee 01             	sub    $0x1,%esi
f0105002:	79 9c                	jns    f0104fa0 <vprintfmt+0x1f2>
f0105004:	89 df                	mov    %ebx,%edi
f0105006:	8b 75 08             	mov    0x8(%ebp),%esi
f0105009:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010500c:	eb 18                	jmp    f0105026 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010500e:	83 ec 08             	sub    $0x8,%esp
f0105011:	53                   	push   %ebx
f0105012:	6a 20                	push   $0x20
f0105014:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105016:	83 ef 01             	sub    $0x1,%edi
f0105019:	83 c4 10             	add    $0x10,%esp
f010501c:	eb 08                	jmp    f0105026 <vprintfmt+0x278>
f010501e:	89 df                	mov    %ebx,%edi
f0105020:	8b 75 08             	mov    0x8(%ebp),%esi
f0105023:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105026:	85 ff                	test   %edi,%edi
f0105028:	7f e4                	jg     f010500e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010502a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010502d:	e9 a2 fd ff ff       	jmp    f0104dd4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105032:	83 fa 01             	cmp    $0x1,%edx
f0105035:	7e 16                	jle    f010504d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0105037:	8b 45 14             	mov    0x14(%ebp),%eax
f010503a:	8d 50 08             	lea    0x8(%eax),%edx
f010503d:	89 55 14             	mov    %edx,0x14(%ebp)
f0105040:	8b 50 04             	mov    0x4(%eax),%edx
f0105043:	8b 00                	mov    (%eax),%eax
f0105045:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105048:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010504b:	eb 32                	jmp    f010507f <vprintfmt+0x2d1>
	else if (lflag)
f010504d:	85 d2                	test   %edx,%edx
f010504f:	74 18                	je     f0105069 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0105051:	8b 45 14             	mov    0x14(%ebp),%eax
f0105054:	8d 50 04             	lea    0x4(%eax),%edx
f0105057:	89 55 14             	mov    %edx,0x14(%ebp)
f010505a:	8b 00                	mov    (%eax),%eax
f010505c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010505f:	89 c1                	mov    %eax,%ecx
f0105061:	c1 f9 1f             	sar    $0x1f,%ecx
f0105064:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105067:	eb 16                	jmp    f010507f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0105069:	8b 45 14             	mov    0x14(%ebp),%eax
f010506c:	8d 50 04             	lea    0x4(%eax),%edx
f010506f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105072:	8b 00                	mov    (%eax),%eax
f0105074:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105077:	89 c1                	mov    %eax,%ecx
f0105079:	c1 f9 1f             	sar    $0x1f,%ecx
f010507c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010507f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105082:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105085:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010508a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010508e:	79 74                	jns    f0105104 <vprintfmt+0x356>
				putch('-', putdat);
f0105090:	83 ec 08             	sub    $0x8,%esp
f0105093:	53                   	push   %ebx
f0105094:	6a 2d                	push   $0x2d
f0105096:	ff d6                	call   *%esi
				num = -(long long) num;
f0105098:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010509b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010509e:	f7 d8                	neg    %eax
f01050a0:	83 d2 00             	adc    $0x0,%edx
f01050a3:	f7 da                	neg    %edx
f01050a5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01050a8:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01050ad:	eb 55                	jmp    f0105104 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01050af:	8d 45 14             	lea    0x14(%ebp),%eax
f01050b2:	e8 83 fc ff ff       	call   f0104d3a <getuint>
			base = 10;
f01050b7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01050bc:	eb 46                	jmp    f0105104 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f01050be:	8d 45 14             	lea    0x14(%ebp),%eax
f01050c1:	e8 74 fc ff ff       	call   f0104d3a <getuint>
			base = 8;
f01050c6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f01050cb:	eb 37                	jmp    f0105104 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
f01050cd:	83 ec 08             	sub    $0x8,%esp
f01050d0:	53                   	push   %ebx
f01050d1:	6a 30                	push   $0x30
f01050d3:	ff d6                	call   *%esi
			putch('x', putdat);
f01050d5:	83 c4 08             	add    $0x8,%esp
f01050d8:	53                   	push   %ebx
f01050d9:	6a 78                	push   $0x78
f01050db:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01050dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01050e0:	8d 50 04             	lea    0x4(%eax),%edx
f01050e3:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01050e6:	8b 00                	mov    (%eax),%eax
f01050e8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01050ed:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01050f0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01050f5:	eb 0d                	jmp    f0105104 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01050f7:	8d 45 14             	lea    0x14(%ebp),%eax
f01050fa:	e8 3b fc ff ff       	call   f0104d3a <getuint>
			base = 16;
f01050ff:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105104:	83 ec 0c             	sub    $0xc,%esp
f0105107:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010510b:	57                   	push   %edi
f010510c:	ff 75 e0             	pushl  -0x20(%ebp)
f010510f:	51                   	push   %ecx
f0105110:	52                   	push   %edx
f0105111:	50                   	push   %eax
f0105112:	89 da                	mov    %ebx,%edx
f0105114:	89 f0                	mov    %esi,%eax
f0105116:	e8 70 fb ff ff       	call   f0104c8b <printnum>
			break;
f010511b:	83 c4 20             	add    $0x20,%esp
f010511e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105121:	e9 ae fc ff ff       	jmp    f0104dd4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105126:	83 ec 08             	sub    $0x8,%esp
f0105129:	53                   	push   %ebx
f010512a:	51                   	push   %ecx
f010512b:	ff d6                	call   *%esi
			break;
f010512d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105130:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105133:	e9 9c fc ff ff       	jmp    f0104dd4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105138:	83 ec 08             	sub    $0x8,%esp
f010513b:	53                   	push   %ebx
f010513c:	6a 25                	push   $0x25
f010513e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105140:	83 c4 10             	add    $0x10,%esp
f0105143:	eb 03                	jmp    f0105148 <vprintfmt+0x39a>
f0105145:	83 ef 01             	sub    $0x1,%edi
f0105148:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010514c:	75 f7                	jne    f0105145 <vprintfmt+0x397>
f010514e:	e9 81 fc ff ff       	jmp    f0104dd4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105153:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105156:	5b                   	pop    %ebx
f0105157:	5e                   	pop    %esi
f0105158:	5f                   	pop    %edi
f0105159:	5d                   	pop    %ebp
f010515a:	c3                   	ret    

f010515b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010515b:	55                   	push   %ebp
f010515c:	89 e5                	mov    %esp,%ebp
f010515e:	83 ec 18             	sub    $0x18,%esp
f0105161:	8b 45 08             	mov    0x8(%ebp),%eax
f0105164:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105167:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010516a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010516e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105171:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105178:	85 c0                	test   %eax,%eax
f010517a:	74 26                	je     f01051a2 <vsnprintf+0x47>
f010517c:	85 d2                	test   %edx,%edx
f010517e:	7e 22                	jle    f01051a2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105180:	ff 75 14             	pushl  0x14(%ebp)
f0105183:	ff 75 10             	pushl  0x10(%ebp)
f0105186:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105189:	50                   	push   %eax
f010518a:	68 74 4d 10 f0       	push   $0xf0104d74
f010518f:	e8 1a fc ff ff       	call   f0104dae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105194:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105197:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010519a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010519d:	83 c4 10             	add    $0x10,%esp
f01051a0:	eb 05                	jmp    f01051a7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01051a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01051a7:	c9                   	leave  
f01051a8:	c3                   	ret    

f01051a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01051a9:	55                   	push   %ebp
f01051aa:	89 e5                	mov    %esp,%ebp
f01051ac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01051af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01051b2:	50                   	push   %eax
f01051b3:	ff 75 10             	pushl  0x10(%ebp)
f01051b6:	ff 75 0c             	pushl  0xc(%ebp)
f01051b9:	ff 75 08             	pushl  0x8(%ebp)
f01051bc:	e8 9a ff ff ff       	call   f010515b <vsnprintf>
	va_end(ap);

	return rc;
}
f01051c1:	c9                   	leave  
f01051c2:	c3                   	ret    

f01051c3 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01051c3:	55                   	push   %ebp
f01051c4:	89 e5                	mov    %esp,%ebp
f01051c6:	57                   	push   %edi
f01051c7:	56                   	push   %esi
f01051c8:	53                   	push   %ebx
f01051c9:	83 ec 0c             	sub    $0xc,%esp
f01051cc:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f01051cf:	85 c0                	test   %eax,%eax
f01051d1:	74 11                	je     f01051e4 <readline+0x21>
		cprintf("%s", prompt);
f01051d3:	83 ec 08             	sub    $0x8,%esp
f01051d6:	50                   	push   %eax
f01051d7:	68 55 70 10 f0       	push   $0xf0107055
f01051dc:	e8 9b e4 ff ff       	call   f010367c <cprintf>
f01051e1:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f01051e4:	83 ec 0c             	sub    $0xc,%esp
f01051e7:	6a 00                	push   $0x0
f01051e9:	e8 af b5 ff ff       	call   f010079d <iscons>
f01051ee:	89 c7                	mov    %eax,%edi
f01051f0:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f01051f3:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01051f8:	e8 8f b5 ff ff       	call   f010078c <getchar>
f01051fd:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01051ff:	85 c0                	test   %eax,%eax
f0105201:	79 29                	jns    f010522c <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105203:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105208:	83 fb f8             	cmp    $0xfffffff8,%ebx
f010520b:	0f 84 9b 00 00 00    	je     f01052ac <readline+0xe9>
				cprintf("read error: %e\n", c);
f0105211:	83 ec 08             	sub    $0x8,%esp
f0105214:	53                   	push   %ebx
f0105215:	68 ff 7b 10 f0       	push   $0xf0107bff
f010521a:	e8 5d e4 ff ff       	call   f010367c <cprintf>
f010521f:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105222:	b8 00 00 00 00       	mov    $0x0,%eax
f0105227:	e9 80 00 00 00       	jmp    f01052ac <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010522c:	83 f8 08             	cmp    $0x8,%eax
f010522f:	0f 94 c2             	sete   %dl
f0105232:	83 f8 7f             	cmp    $0x7f,%eax
f0105235:	0f 94 c0             	sete   %al
f0105238:	08 c2                	or     %al,%dl
f010523a:	74 1a                	je     f0105256 <readline+0x93>
f010523c:	85 f6                	test   %esi,%esi
f010523e:	7e 16                	jle    f0105256 <readline+0x93>
			if (echoing)
f0105240:	85 ff                	test   %edi,%edi
f0105242:	74 0d                	je     f0105251 <readline+0x8e>
				cputchar('\b');
f0105244:	83 ec 0c             	sub    $0xc,%esp
f0105247:	6a 08                	push   $0x8
f0105249:	e8 2e b5 ff ff       	call   f010077c <cputchar>
f010524e:	83 c4 10             	add    $0x10,%esp
			i--;
f0105251:	83 ee 01             	sub    $0x1,%esi
f0105254:	eb a2                	jmp    f01051f8 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105256:	83 fb 1f             	cmp    $0x1f,%ebx
f0105259:	7e 26                	jle    f0105281 <readline+0xbe>
f010525b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105261:	7f 1e                	jg     f0105281 <readline+0xbe>
			if (echoing)
f0105263:	85 ff                	test   %edi,%edi
f0105265:	74 0c                	je     f0105273 <readline+0xb0>
				cputchar(c);
f0105267:	83 ec 0c             	sub    $0xc,%esp
f010526a:	53                   	push   %ebx
f010526b:	e8 0c b5 ff ff       	call   f010077c <cputchar>
f0105270:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105273:	88 9e 80 da 1d f0    	mov    %bl,-0xfe22580(%esi)
f0105279:	8d 76 01             	lea    0x1(%esi),%esi
f010527c:	e9 77 ff ff ff       	jmp    f01051f8 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105281:	83 fb 0a             	cmp    $0xa,%ebx
f0105284:	74 09                	je     f010528f <readline+0xcc>
f0105286:	83 fb 0d             	cmp    $0xd,%ebx
f0105289:	0f 85 69 ff ff ff    	jne    f01051f8 <readline+0x35>
			if (echoing)
f010528f:	85 ff                	test   %edi,%edi
f0105291:	74 0d                	je     f01052a0 <readline+0xdd>
				cputchar('\n');
f0105293:	83 ec 0c             	sub    $0xc,%esp
f0105296:	6a 0a                	push   $0xa
f0105298:	e8 df b4 ff ff       	call   f010077c <cputchar>
f010529d:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01052a0:	c6 86 80 da 1d f0 00 	movb   $0x0,-0xfe22580(%esi)
			return buf;
f01052a7:	b8 80 da 1d f0       	mov    $0xf01dda80,%eax
		}
	}
}
f01052ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01052af:	5b                   	pop    %ebx
f01052b0:	5e                   	pop    %esi
f01052b1:	5f                   	pop    %edi
f01052b2:	5d                   	pop    %ebp
f01052b3:	c3                   	ret    

f01052b4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01052b4:	55                   	push   %ebp
f01052b5:	89 e5                	mov    %esp,%ebp
f01052b7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01052ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01052bf:	eb 03                	jmp    f01052c4 <strlen+0x10>
		n++;
f01052c1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01052c4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01052c8:	75 f7                	jne    f01052c1 <strlen+0xd>
		n++;
	return n;
}
f01052ca:	5d                   	pop    %ebp
f01052cb:	c3                   	ret    

f01052cc <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01052cc:	55                   	push   %ebp
f01052cd:	89 e5                	mov    %esp,%ebp
f01052cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01052d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01052d5:	ba 00 00 00 00       	mov    $0x0,%edx
f01052da:	eb 03                	jmp    f01052df <strnlen+0x13>
		n++;
f01052dc:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01052df:	39 c2                	cmp    %eax,%edx
f01052e1:	74 08                	je     f01052eb <strnlen+0x1f>
f01052e3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01052e7:	75 f3                	jne    f01052dc <strnlen+0x10>
f01052e9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01052eb:	5d                   	pop    %ebp
f01052ec:	c3                   	ret    

f01052ed <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01052ed:	55                   	push   %ebp
f01052ee:	89 e5                	mov    %esp,%ebp
f01052f0:	53                   	push   %ebx
f01052f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01052f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01052f7:	89 c2                	mov    %eax,%edx
f01052f9:	83 c2 01             	add    $0x1,%edx
f01052fc:	83 c1 01             	add    $0x1,%ecx
f01052ff:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105303:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105306:	84 db                	test   %bl,%bl
f0105308:	75 ef                	jne    f01052f9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010530a:	5b                   	pop    %ebx
f010530b:	5d                   	pop    %ebp
f010530c:	c3                   	ret    

f010530d <strcat>:

char *
strcat(char *dst, const char *src)
{
f010530d:	55                   	push   %ebp
f010530e:	89 e5                	mov    %esp,%ebp
f0105310:	53                   	push   %ebx
f0105311:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105314:	53                   	push   %ebx
f0105315:	e8 9a ff ff ff       	call   f01052b4 <strlen>
f010531a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010531d:	ff 75 0c             	pushl  0xc(%ebp)
f0105320:	01 d8                	add    %ebx,%eax
f0105322:	50                   	push   %eax
f0105323:	e8 c5 ff ff ff       	call   f01052ed <strcpy>
	return dst;
}
f0105328:	89 d8                	mov    %ebx,%eax
f010532a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010532d:	c9                   	leave  
f010532e:	c3                   	ret    

f010532f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010532f:	55                   	push   %ebp
f0105330:	89 e5                	mov    %esp,%ebp
f0105332:	56                   	push   %esi
f0105333:	53                   	push   %ebx
f0105334:	8b 75 08             	mov    0x8(%ebp),%esi
f0105337:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010533a:	89 f3                	mov    %esi,%ebx
f010533c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010533f:	89 f2                	mov    %esi,%edx
f0105341:	eb 0f                	jmp    f0105352 <strncpy+0x23>
		*dst++ = *src;
f0105343:	83 c2 01             	add    $0x1,%edx
f0105346:	0f b6 01             	movzbl (%ecx),%eax
f0105349:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010534c:	80 39 01             	cmpb   $0x1,(%ecx)
f010534f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105352:	39 da                	cmp    %ebx,%edx
f0105354:	75 ed                	jne    f0105343 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105356:	89 f0                	mov    %esi,%eax
f0105358:	5b                   	pop    %ebx
f0105359:	5e                   	pop    %esi
f010535a:	5d                   	pop    %ebp
f010535b:	c3                   	ret    

f010535c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010535c:	55                   	push   %ebp
f010535d:	89 e5                	mov    %esp,%ebp
f010535f:	56                   	push   %esi
f0105360:	53                   	push   %ebx
f0105361:	8b 75 08             	mov    0x8(%ebp),%esi
f0105364:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105367:	8b 55 10             	mov    0x10(%ebp),%edx
f010536a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010536c:	85 d2                	test   %edx,%edx
f010536e:	74 21                	je     f0105391 <strlcpy+0x35>
f0105370:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105374:	89 f2                	mov    %esi,%edx
f0105376:	eb 09                	jmp    f0105381 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105378:	83 c2 01             	add    $0x1,%edx
f010537b:	83 c1 01             	add    $0x1,%ecx
f010537e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105381:	39 c2                	cmp    %eax,%edx
f0105383:	74 09                	je     f010538e <strlcpy+0x32>
f0105385:	0f b6 19             	movzbl (%ecx),%ebx
f0105388:	84 db                	test   %bl,%bl
f010538a:	75 ec                	jne    f0105378 <strlcpy+0x1c>
f010538c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010538e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105391:	29 f0                	sub    %esi,%eax
}
f0105393:	5b                   	pop    %ebx
f0105394:	5e                   	pop    %esi
f0105395:	5d                   	pop    %ebp
f0105396:	c3                   	ret    

f0105397 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105397:	55                   	push   %ebp
f0105398:	89 e5                	mov    %esp,%ebp
f010539a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010539d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01053a0:	eb 06                	jmp    f01053a8 <strcmp+0x11>
		p++, q++;
f01053a2:	83 c1 01             	add    $0x1,%ecx
f01053a5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01053a8:	0f b6 01             	movzbl (%ecx),%eax
f01053ab:	84 c0                	test   %al,%al
f01053ad:	74 04                	je     f01053b3 <strcmp+0x1c>
f01053af:	3a 02                	cmp    (%edx),%al
f01053b1:	74 ef                	je     f01053a2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01053b3:	0f b6 c0             	movzbl %al,%eax
f01053b6:	0f b6 12             	movzbl (%edx),%edx
f01053b9:	29 d0                	sub    %edx,%eax
}
f01053bb:	5d                   	pop    %ebp
f01053bc:	c3                   	ret    

f01053bd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01053bd:	55                   	push   %ebp
f01053be:	89 e5                	mov    %esp,%ebp
f01053c0:	53                   	push   %ebx
f01053c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01053c4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01053c7:	89 c3                	mov    %eax,%ebx
f01053c9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01053cc:	eb 06                	jmp    f01053d4 <strncmp+0x17>
		n--, p++, q++;
f01053ce:	83 c0 01             	add    $0x1,%eax
f01053d1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01053d4:	39 d8                	cmp    %ebx,%eax
f01053d6:	74 15                	je     f01053ed <strncmp+0x30>
f01053d8:	0f b6 08             	movzbl (%eax),%ecx
f01053db:	84 c9                	test   %cl,%cl
f01053dd:	74 04                	je     f01053e3 <strncmp+0x26>
f01053df:	3a 0a                	cmp    (%edx),%cl
f01053e1:	74 eb                	je     f01053ce <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01053e3:	0f b6 00             	movzbl (%eax),%eax
f01053e6:	0f b6 12             	movzbl (%edx),%edx
f01053e9:	29 d0                	sub    %edx,%eax
f01053eb:	eb 05                	jmp    f01053f2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01053ed:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01053f2:	5b                   	pop    %ebx
f01053f3:	5d                   	pop    %ebp
f01053f4:	c3                   	ret    

f01053f5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01053f5:	55                   	push   %ebp
f01053f6:	89 e5                	mov    %esp,%ebp
f01053f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01053fb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01053ff:	eb 07                	jmp    f0105408 <strchr+0x13>
		if (*s == c)
f0105401:	38 ca                	cmp    %cl,%dl
f0105403:	74 0f                	je     f0105414 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105405:	83 c0 01             	add    $0x1,%eax
f0105408:	0f b6 10             	movzbl (%eax),%edx
f010540b:	84 d2                	test   %dl,%dl
f010540d:	75 f2                	jne    f0105401 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010540f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105414:	5d                   	pop    %ebp
f0105415:	c3                   	ret    

f0105416 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105416:	55                   	push   %ebp
f0105417:	89 e5                	mov    %esp,%ebp
f0105419:	8b 45 08             	mov    0x8(%ebp),%eax
f010541c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105420:	eb 03                	jmp    f0105425 <strfind+0xf>
f0105422:	83 c0 01             	add    $0x1,%eax
f0105425:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105428:	38 ca                	cmp    %cl,%dl
f010542a:	74 04                	je     f0105430 <strfind+0x1a>
f010542c:	84 d2                	test   %dl,%dl
f010542e:	75 f2                	jne    f0105422 <strfind+0xc>
			break;
	return (char *) s;
}
f0105430:	5d                   	pop    %ebp
f0105431:	c3                   	ret    

f0105432 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105432:	55                   	push   %ebp
f0105433:	89 e5                	mov    %esp,%ebp
f0105435:	57                   	push   %edi
f0105436:	56                   	push   %esi
f0105437:	53                   	push   %ebx
f0105438:	8b 7d 08             	mov    0x8(%ebp),%edi
f010543b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010543e:	85 c9                	test   %ecx,%ecx
f0105440:	74 36                	je     f0105478 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105442:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105448:	75 28                	jne    f0105472 <memset+0x40>
f010544a:	f6 c1 03             	test   $0x3,%cl
f010544d:	75 23                	jne    f0105472 <memset+0x40>
		c &= 0xFF;
f010544f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105453:	89 d3                	mov    %edx,%ebx
f0105455:	c1 e3 08             	shl    $0x8,%ebx
f0105458:	89 d6                	mov    %edx,%esi
f010545a:	c1 e6 18             	shl    $0x18,%esi
f010545d:	89 d0                	mov    %edx,%eax
f010545f:	c1 e0 10             	shl    $0x10,%eax
f0105462:	09 f0                	or     %esi,%eax
f0105464:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105466:	89 d8                	mov    %ebx,%eax
f0105468:	09 d0                	or     %edx,%eax
f010546a:	c1 e9 02             	shr    $0x2,%ecx
f010546d:	fc                   	cld    
f010546e:	f3 ab                	rep stos %eax,%es:(%edi)
f0105470:	eb 06                	jmp    f0105478 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105472:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105475:	fc                   	cld    
f0105476:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105478:	89 f8                	mov    %edi,%eax
f010547a:	5b                   	pop    %ebx
f010547b:	5e                   	pop    %esi
f010547c:	5f                   	pop    %edi
f010547d:	5d                   	pop    %ebp
f010547e:	c3                   	ret    

f010547f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010547f:	55                   	push   %ebp
f0105480:	89 e5                	mov    %esp,%ebp
f0105482:	57                   	push   %edi
f0105483:	56                   	push   %esi
f0105484:	8b 45 08             	mov    0x8(%ebp),%eax
f0105487:	8b 75 0c             	mov    0xc(%ebp),%esi
f010548a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010548d:	39 c6                	cmp    %eax,%esi
f010548f:	73 35                	jae    f01054c6 <memmove+0x47>
f0105491:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105494:	39 d0                	cmp    %edx,%eax
f0105496:	73 2e                	jae    f01054c6 <memmove+0x47>
		s += n;
		d += n;
f0105498:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010549b:	89 d6                	mov    %edx,%esi
f010549d:	09 fe                	or     %edi,%esi
f010549f:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01054a5:	75 13                	jne    f01054ba <memmove+0x3b>
f01054a7:	f6 c1 03             	test   $0x3,%cl
f01054aa:	75 0e                	jne    f01054ba <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01054ac:	83 ef 04             	sub    $0x4,%edi
f01054af:	8d 72 fc             	lea    -0x4(%edx),%esi
f01054b2:	c1 e9 02             	shr    $0x2,%ecx
f01054b5:	fd                   	std    
f01054b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01054b8:	eb 09                	jmp    f01054c3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01054ba:	83 ef 01             	sub    $0x1,%edi
f01054bd:	8d 72 ff             	lea    -0x1(%edx),%esi
f01054c0:	fd                   	std    
f01054c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01054c3:	fc                   	cld    
f01054c4:	eb 1d                	jmp    f01054e3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01054c6:	89 f2                	mov    %esi,%edx
f01054c8:	09 c2                	or     %eax,%edx
f01054ca:	f6 c2 03             	test   $0x3,%dl
f01054cd:	75 0f                	jne    f01054de <memmove+0x5f>
f01054cf:	f6 c1 03             	test   $0x3,%cl
f01054d2:	75 0a                	jne    f01054de <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01054d4:	c1 e9 02             	shr    $0x2,%ecx
f01054d7:	89 c7                	mov    %eax,%edi
f01054d9:	fc                   	cld    
f01054da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01054dc:	eb 05                	jmp    f01054e3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01054de:	89 c7                	mov    %eax,%edi
f01054e0:	fc                   	cld    
f01054e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01054e3:	5e                   	pop    %esi
f01054e4:	5f                   	pop    %edi
f01054e5:	5d                   	pop    %ebp
f01054e6:	c3                   	ret    

f01054e7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01054e7:	55                   	push   %ebp
f01054e8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01054ea:	ff 75 10             	pushl  0x10(%ebp)
f01054ed:	ff 75 0c             	pushl  0xc(%ebp)
f01054f0:	ff 75 08             	pushl  0x8(%ebp)
f01054f3:	e8 87 ff ff ff       	call   f010547f <memmove>
}
f01054f8:	c9                   	leave  
f01054f9:	c3                   	ret    

f01054fa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01054fa:	55                   	push   %ebp
f01054fb:	89 e5                	mov    %esp,%ebp
f01054fd:	56                   	push   %esi
f01054fe:	53                   	push   %ebx
f01054ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0105502:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105505:	89 c6                	mov    %eax,%esi
f0105507:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010550a:	eb 1a                	jmp    f0105526 <memcmp+0x2c>
		if (*s1 != *s2)
f010550c:	0f b6 08             	movzbl (%eax),%ecx
f010550f:	0f b6 1a             	movzbl (%edx),%ebx
f0105512:	38 d9                	cmp    %bl,%cl
f0105514:	74 0a                	je     f0105520 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105516:	0f b6 c1             	movzbl %cl,%eax
f0105519:	0f b6 db             	movzbl %bl,%ebx
f010551c:	29 d8                	sub    %ebx,%eax
f010551e:	eb 0f                	jmp    f010552f <memcmp+0x35>
		s1++, s2++;
f0105520:	83 c0 01             	add    $0x1,%eax
f0105523:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105526:	39 f0                	cmp    %esi,%eax
f0105528:	75 e2                	jne    f010550c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010552a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010552f:	5b                   	pop    %ebx
f0105530:	5e                   	pop    %esi
f0105531:	5d                   	pop    %ebp
f0105532:	c3                   	ret    

f0105533 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105533:	55                   	push   %ebp
f0105534:	89 e5                	mov    %esp,%ebp
f0105536:	53                   	push   %ebx
f0105537:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010553a:	89 c1                	mov    %eax,%ecx
f010553c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010553f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105543:	eb 0a                	jmp    f010554f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105545:	0f b6 10             	movzbl (%eax),%edx
f0105548:	39 da                	cmp    %ebx,%edx
f010554a:	74 07                	je     f0105553 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010554c:	83 c0 01             	add    $0x1,%eax
f010554f:	39 c8                	cmp    %ecx,%eax
f0105551:	72 f2                	jb     f0105545 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105553:	5b                   	pop    %ebx
f0105554:	5d                   	pop    %ebp
f0105555:	c3                   	ret    

f0105556 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105556:	55                   	push   %ebp
f0105557:	89 e5                	mov    %esp,%ebp
f0105559:	57                   	push   %edi
f010555a:	56                   	push   %esi
f010555b:	53                   	push   %ebx
f010555c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010555f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105562:	eb 03                	jmp    f0105567 <strtol+0x11>
		s++;
f0105564:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105567:	0f b6 01             	movzbl (%ecx),%eax
f010556a:	3c 20                	cmp    $0x20,%al
f010556c:	74 f6                	je     f0105564 <strtol+0xe>
f010556e:	3c 09                	cmp    $0x9,%al
f0105570:	74 f2                	je     f0105564 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105572:	3c 2b                	cmp    $0x2b,%al
f0105574:	75 0a                	jne    f0105580 <strtol+0x2a>
		s++;
f0105576:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105579:	bf 00 00 00 00       	mov    $0x0,%edi
f010557e:	eb 11                	jmp    f0105591 <strtol+0x3b>
f0105580:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105585:	3c 2d                	cmp    $0x2d,%al
f0105587:	75 08                	jne    f0105591 <strtol+0x3b>
		s++, neg = 1;
f0105589:	83 c1 01             	add    $0x1,%ecx
f010558c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105591:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105597:	75 15                	jne    f01055ae <strtol+0x58>
f0105599:	80 39 30             	cmpb   $0x30,(%ecx)
f010559c:	75 10                	jne    f01055ae <strtol+0x58>
f010559e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01055a2:	75 7c                	jne    f0105620 <strtol+0xca>
		s += 2, base = 16;
f01055a4:	83 c1 02             	add    $0x2,%ecx
f01055a7:	bb 10 00 00 00       	mov    $0x10,%ebx
f01055ac:	eb 16                	jmp    f01055c4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01055ae:	85 db                	test   %ebx,%ebx
f01055b0:	75 12                	jne    f01055c4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01055b2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01055b7:	80 39 30             	cmpb   $0x30,(%ecx)
f01055ba:	75 08                	jne    f01055c4 <strtol+0x6e>
		s++, base = 8;
f01055bc:	83 c1 01             	add    $0x1,%ecx
f01055bf:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01055c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01055c9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01055cc:	0f b6 11             	movzbl (%ecx),%edx
f01055cf:	8d 72 d0             	lea    -0x30(%edx),%esi
f01055d2:	89 f3                	mov    %esi,%ebx
f01055d4:	80 fb 09             	cmp    $0x9,%bl
f01055d7:	77 08                	ja     f01055e1 <strtol+0x8b>
			dig = *s - '0';
f01055d9:	0f be d2             	movsbl %dl,%edx
f01055dc:	83 ea 30             	sub    $0x30,%edx
f01055df:	eb 22                	jmp    f0105603 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01055e1:	8d 72 9f             	lea    -0x61(%edx),%esi
f01055e4:	89 f3                	mov    %esi,%ebx
f01055e6:	80 fb 19             	cmp    $0x19,%bl
f01055e9:	77 08                	ja     f01055f3 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01055eb:	0f be d2             	movsbl %dl,%edx
f01055ee:	83 ea 57             	sub    $0x57,%edx
f01055f1:	eb 10                	jmp    f0105603 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01055f3:	8d 72 bf             	lea    -0x41(%edx),%esi
f01055f6:	89 f3                	mov    %esi,%ebx
f01055f8:	80 fb 19             	cmp    $0x19,%bl
f01055fb:	77 16                	ja     f0105613 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01055fd:	0f be d2             	movsbl %dl,%edx
f0105600:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105603:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105606:	7d 0b                	jge    f0105613 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105608:	83 c1 01             	add    $0x1,%ecx
f010560b:	0f af 45 10          	imul   0x10(%ebp),%eax
f010560f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105611:	eb b9                	jmp    f01055cc <strtol+0x76>

	if (endptr)
f0105613:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105617:	74 0d                	je     f0105626 <strtol+0xd0>
		*endptr = (char *) s;
f0105619:	8b 75 0c             	mov    0xc(%ebp),%esi
f010561c:	89 0e                	mov    %ecx,(%esi)
f010561e:	eb 06                	jmp    f0105626 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105620:	85 db                	test   %ebx,%ebx
f0105622:	74 98                	je     f01055bc <strtol+0x66>
f0105624:	eb 9e                	jmp    f01055c4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105626:	89 c2                	mov    %eax,%edx
f0105628:	f7 da                	neg    %edx
f010562a:	85 ff                	test   %edi,%edi
f010562c:	0f 45 c2             	cmovne %edx,%eax
}
f010562f:	5b                   	pop    %ebx
f0105630:	5e                   	pop    %esi
f0105631:	5f                   	pop    %edi
f0105632:	5d                   	pop    %ebp
f0105633:	c3                   	ret    

f0105634 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105634:	fa                   	cli    

	xorw    %ax, %ax
f0105635:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105637:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105639:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010563b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f010563d:	0f 01 16             	lgdtl  (%esi)
f0105640:	74 70                	je     f01056b2 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105642:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105645:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105649:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f010564c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105652:	08 00                	or     %al,(%eax)

f0105654 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105654:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105658:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010565a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010565c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010565e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105662:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105664:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105666:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f010566b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010566e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105671:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105676:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105679:	8b 25 84 de 1d f0    	mov    0xf01dde84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010567f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105684:	b8 b8 01 10 f0       	mov    $0xf01001b8,%eax
	call    *%eax
f0105689:	ff d0                	call   *%eax

f010568b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010568b:	eb fe                	jmp    f010568b <spin>
f010568d:	8d 76 00             	lea    0x0(%esi),%esi

f0105690 <gdt>:
	...
f0105698:	ff                   	(bad)  
f0105699:	ff 00                	incl   (%eax)
f010569b:	00 00                	add    %al,(%eax)
f010569d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01056a4:	00                   	.byte 0x0
f01056a5:	92                   	xchg   %eax,%edx
f01056a6:	cf                   	iret   
	...

f01056a8 <gdtdesc>:
f01056a8:	17                   	pop    %ss
f01056a9:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01056ae <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01056ae:	90                   	nop

f01056af <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01056af:	55                   	push   %ebp
f01056b0:	89 e5                	mov    %esp,%ebp
f01056b2:	57                   	push   %edi
f01056b3:	56                   	push   %esi
f01056b4:	53                   	push   %ebx
f01056b5:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01056b8:	8b 0d 88 de 1d f0    	mov    0xf01dde88,%ecx
f01056be:	89 c3                	mov    %eax,%ebx
f01056c0:	c1 eb 0c             	shr    $0xc,%ebx
f01056c3:	39 cb                	cmp    %ecx,%ebx
f01056c5:	72 12                	jb     f01056d9 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01056c7:	50                   	push   %eax
f01056c8:	68 04 61 10 f0       	push   $0xf0106104
f01056cd:	6a 57                	push   $0x57
f01056cf:	68 9d 7d 10 f0       	push   $0xf0107d9d
f01056d4:	e8 67 a9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01056d9:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01056df:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01056e1:	89 c2                	mov    %eax,%edx
f01056e3:	c1 ea 0c             	shr    $0xc,%edx
f01056e6:	39 ca                	cmp    %ecx,%edx
f01056e8:	72 12                	jb     f01056fc <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01056ea:	50                   	push   %eax
f01056eb:	68 04 61 10 f0       	push   $0xf0106104
f01056f0:	6a 57                	push   $0x57
f01056f2:	68 9d 7d 10 f0       	push   $0xf0107d9d
f01056f7:	e8 44 a9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01056fc:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105702:	eb 2f                	jmp    f0105733 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105704:	83 ec 04             	sub    $0x4,%esp
f0105707:	6a 04                	push   $0x4
f0105709:	68 ad 7d 10 f0       	push   $0xf0107dad
f010570e:	53                   	push   %ebx
f010570f:	e8 e6 fd ff ff       	call   f01054fa <memcmp>
f0105714:	83 c4 10             	add    $0x10,%esp
f0105717:	85 c0                	test   %eax,%eax
f0105719:	75 15                	jne    f0105730 <mpsearch1+0x81>
f010571b:	89 da                	mov    %ebx,%edx
f010571d:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105720:	0f b6 0a             	movzbl (%edx),%ecx
f0105723:	01 c8                	add    %ecx,%eax
f0105725:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105728:	39 d7                	cmp    %edx,%edi
f010572a:	75 f4                	jne    f0105720 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010572c:	84 c0                	test   %al,%al
f010572e:	74 0e                	je     f010573e <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105730:	83 c3 10             	add    $0x10,%ebx
f0105733:	39 f3                	cmp    %esi,%ebx
f0105735:	72 cd                	jb     f0105704 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105737:	b8 00 00 00 00       	mov    $0x0,%eax
f010573c:	eb 02                	jmp    f0105740 <mpsearch1+0x91>
f010573e:	89 d8                	mov    %ebx,%eax
}
f0105740:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105743:	5b                   	pop    %ebx
f0105744:	5e                   	pop    %esi
f0105745:	5f                   	pop    %edi
f0105746:	5d                   	pop    %ebp
f0105747:	c3                   	ret    

f0105748 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105748:	55                   	push   %ebp
f0105749:	89 e5                	mov    %esp,%ebp
f010574b:	57                   	push   %edi
f010574c:	56                   	push   %esi
f010574d:	53                   	push   %ebx
f010574e:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105751:	c7 05 c0 e3 1d f0 20 	movl   $0xf01de020,0xf01de3c0
f0105758:	e0 1d f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010575b:	83 3d 88 de 1d f0 00 	cmpl   $0x0,0xf01dde88
f0105762:	75 16                	jne    f010577a <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105764:	68 00 04 00 00       	push   $0x400
f0105769:	68 04 61 10 f0       	push   $0xf0106104
f010576e:	6a 6f                	push   $0x6f
f0105770:	68 9d 7d 10 f0       	push   $0xf0107d9d
f0105775:	e8 c6 a8 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010577a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105781:	85 c0                	test   %eax,%eax
f0105783:	74 16                	je     f010579b <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105785:	c1 e0 04             	shl    $0x4,%eax
f0105788:	ba 00 04 00 00       	mov    $0x400,%edx
f010578d:	e8 1d ff ff ff       	call   f01056af <mpsearch1>
f0105792:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105795:	85 c0                	test   %eax,%eax
f0105797:	75 3c                	jne    f01057d5 <mp_init+0x8d>
f0105799:	eb 20                	jmp    f01057bb <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010579b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01057a2:	c1 e0 0a             	shl    $0xa,%eax
f01057a5:	2d 00 04 00 00       	sub    $0x400,%eax
f01057aa:	ba 00 04 00 00       	mov    $0x400,%edx
f01057af:	e8 fb fe ff ff       	call   f01056af <mpsearch1>
f01057b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01057b7:	85 c0                	test   %eax,%eax
f01057b9:	75 1a                	jne    f01057d5 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01057bb:	ba 00 00 01 00       	mov    $0x10000,%edx
f01057c0:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01057c5:	e8 e5 fe ff ff       	call   f01056af <mpsearch1>
f01057ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01057cd:	85 c0                	test   %eax,%eax
f01057cf:	0f 84 5d 02 00 00    	je     f0105a32 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01057d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01057d8:	8b 70 04             	mov    0x4(%eax),%esi
f01057db:	85 f6                	test   %esi,%esi
f01057dd:	74 06                	je     f01057e5 <mp_init+0x9d>
f01057df:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01057e3:	74 15                	je     f01057fa <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f01057e5:	83 ec 0c             	sub    $0xc,%esp
f01057e8:	68 10 7c 10 f0       	push   $0xf0107c10
f01057ed:	e8 8a de ff ff       	call   f010367c <cprintf>
f01057f2:	83 c4 10             	add    $0x10,%esp
f01057f5:	e9 38 02 00 00       	jmp    f0105a32 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01057fa:	89 f0                	mov    %esi,%eax
f01057fc:	c1 e8 0c             	shr    $0xc,%eax
f01057ff:	3b 05 88 de 1d f0    	cmp    0xf01dde88,%eax
f0105805:	72 15                	jb     f010581c <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105807:	56                   	push   %esi
f0105808:	68 04 61 10 f0       	push   $0xf0106104
f010580d:	68 90 00 00 00       	push   $0x90
f0105812:	68 9d 7d 10 f0       	push   $0xf0107d9d
f0105817:	e8 24 a8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010581c:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105822:	83 ec 04             	sub    $0x4,%esp
f0105825:	6a 04                	push   $0x4
f0105827:	68 b2 7d 10 f0       	push   $0xf0107db2
f010582c:	53                   	push   %ebx
f010582d:	e8 c8 fc ff ff       	call   f01054fa <memcmp>
f0105832:	83 c4 10             	add    $0x10,%esp
f0105835:	85 c0                	test   %eax,%eax
f0105837:	74 15                	je     f010584e <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105839:	83 ec 0c             	sub    $0xc,%esp
f010583c:	68 40 7c 10 f0       	push   $0xf0107c40
f0105841:	e8 36 de ff ff       	call   f010367c <cprintf>
f0105846:	83 c4 10             	add    $0x10,%esp
f0105849:	e9 e4 01 00 00       	jmp    f0105a32 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010584e:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105852:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105856:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105859:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f010585e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105863:	eb 0d                	jmp    f0105872 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105865:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f010586c:	f0 
f010586d:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010586f:	83 c0 01             	add    $0x1,%eax
f0105872:	39 c7                	cmp    %eax,%edi
f0105874:	75 ef                	jne    f0105865 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105876:	84 d2                	test   %dl,%dl
f0105878:	74 15                	je     f010588f <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f010587a:	83 ec 0c             	sub    $0xc,%esp
f010587d:	68 74 7c 10 f0       	push   $0xf0107c74
f0105882:	e8 f5 dd ff ff       	call   f010367c <cprintf>
f0105887:	83 c4 10             	add    $0x10,%esp
f010588a:	e9 a3 01 00 00       	jmp    f0105a32 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010588f:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105893:	3c 01                	cmp    $0x1,%al
f0105895:	74 1d                	je     f01058b4 <mp_init+0x16c>
f0105897:	3c 04                	cmp    $0x4,%al
f0105899:	74 19                	je     f01058b4 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010589b:	83 ec 08             	sub    $0x8,%esp
f010589e:	0f b6 c0             	movzbl %al,%eax
f01058a1:	50                   	push   %eax
f01058a2:	68 98 7c 10 f0       	push   $0xf0107c98
f01058a7:	e8 d0 dd ff ff       	call   f010367c <cprintf>
f01058ac:	83 c4 10             	add    $0x10,%esp
f01058af:	e9 7e 01 00 00       	jmp    f0105a32 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01058b4:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f01058b8:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01058bc:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01058c1:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f01058c6:	01 ce                	add    %ecx,%esi
f01058c8:	eb 0d                	jmp    f01058d7 <mp_init+0x18f>
f01058ca:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f01058d1:	f0 
f01058d2:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01058d4:	83 c0 01             	add    $0x1,%eax
f01058d7:	39 c7                	cmp    %eax,%edi
f01058d9:	75 ef                	jne    f01058ca <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01058db:	89 d0                	mov    %edx,%eax
f01058dd:	02 43 2a             	add    0x2a(%ebx),%al
f01058e0:	74 15                	je     f01058f7 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01058e2:	83 ec 0c             	sub    $0xc,%esp
f01058e5:	68 b8 7c 10 f0       	push   $0xf0107cb8
f01058ea:	e8 8d dd ff ff       	call   f010367c <cprintf>
f01058ef:	83 c4 10             	add    $0x10,%esp
f01058f2:	e9 3b 01 00 00       	jmp    f0105a32 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01058f7:	85 db                	test   %ebx,%ebx
f01058f9:	0f 84 33 01 00 00    	je     f0105a32 <mp_init+0x2ea>
		return;
	ismp = 1;
f01058ff:	c7 05 00 e0 1d f0 01 	movl   $0x1,0xf01de000
f0105906:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105909:	8b 43 24             	mov    0x24(%ebx),%eax
f010590c:	a3 00 f0 21 f0       	mov    %eax,0xf021f000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105911:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105914:	be 00 00 00 00       	mov    $0x0,%esi
f0105919:	e9 85 00 00 00       	jmp    f01059a3 <mp_init+0x25b>
		switch (*p) {
f010591e:	0f b6 07             	movzbl (%edi),%eax
f0105921:	84 c0                	test   %al,%al
f0105923:	74 06                	je     f010592b <mp_init+0x1e3>
f0105925:	3c 04                	cmp    $0x4,%al
f0105927:	77 55                	ja     f010597e <mp_init+0x236>
f0105929:	eb 4e                	jmp    f0105979 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010592b:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010592f:	74 11                	je     f0105942 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105931:	6b 05 c4 e3 1d f0 74 	imul   $0x74,0xf01de3c4,%eax
f0105938:	05 20 e0 1d f0       	add    $0xf01de020,%eax
f010593d:	a3 c0 e3 1d f0       	mov    %eax,0xf01de3c0
			if (ncpu < NCPU) {
f0105942:	a1 c4 e3 1d f0       	mov    0xf01de3c4,%eax
f0105947:	83 f8 07             	cmp    $0x7,%eax
f010594a:	7f 13                	jg     f010595f <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f010594c:	6b d0 74             	imul   $0x74,%eax,%edx
f010594f:	88 82 20 e0 1d f0    	mov    %al,-0xfe21fe0(%edx)
				ncpu++;
f0105955:	83 c0 01             	add    $0x1,%eax
f0105958:	a3 c4 e3 1d f0       	mov    %eax,0xf01de3c4
f010595d:	eb 15                	jmp    f0105974 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010595f:	83 ec 08             	sub    $0x8,%esp
f0105962:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105966:	50                   	push   %eax
f0105967:	68 e8 7c 10 f0       	push   $0xf0107ce8
f010596c:	e8 0b dd ff ff       	call   f010367c <cprintf>
f0105971:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105974:	83 c7 14             	add    $0x14,%edi
			continue;
f0105977:	eb 27                	jmp    f01059a0 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105979:	83 c7 08             	add    $0x8,%edi
			continue;
f010597c:	eb 22                	jmp    f01059a0 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010597e:	83 ec 08             	sub    $0x8,%esp
f0105981:	0f b6 c0             	movzbl %al,%eax
f0105984:	50                   	push   %eax
f0105985:	68 10 7d 10 f0       	push   $0xf0107d10
f010598a:	e8 ed dc ff ff       	call   f010367c <cprintf>
			ismp = 0;
f010598f:	c7 05 00 e0 1d f0 00 	movl   $0x0,0xf01de000
f0105996:	00 00 00 
			i = conf->entry;
f0105999:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f010599d:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01059a0:	83 c6 01             	add    $0x1,%esi
f01059a3:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01059a7:	39 c6                	cmp    %eax,%esi
f01059a9:	0f 82 6f ff ff ff    	jb     f010591e <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01059af:	a1 c0 e3 1d f0       	mov    0xf01de3c0,%eax
f01059b4:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01059bb:	83 3d 00 e0 1d f0 00 	cmpl   $0x0,0xf01de000
f01059c2:	75 26                	jne    f01059ea <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01059c4:	c7 05 c4 e3 1d f0 01 	movl   $0x1,0xf01de3c4
f01059cb:	00 00 00 
		lapicaddr = 0;
f01059ce:	c7 05 00 f0 21 f0 00 	movl   $0x0,0xf021f000
f01059d5:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01059d8:	83 ec 0c             	sub    $0xc,%esp
f01059db:	68 30 7d 10 f0       	push   $0xf0107d30
f01059e0:	e8 97 dc ff ff       	call   f010367c <cprintf>
		return;
f01059e5:	83 c4 10             	add    $0x10,%esp
f01059e8:	eb 48                	jmp    f0105a32 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01059ea:	83 ec 04             	sub    $0x4,%esp
f01059ed:	ff 35 c4 e3 1d f0    	pushl  0xf01de3c4
f01059f3:	0f b6 00             	movzbl (%eax),%eax
f01059f6:	50                   	push   %eax
f01059f7:	68 b7 7d 10 f0       	push   $0xf0107db7
f01059fc:	e8 7b dc ff ff       	call   f010367c <cprintf>

	if (mp->imcrp) {
f0105a01:	83 c4 10             	add    $0x10,%esp
f0105a04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105a07:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105a0b:	74 25                	je     f0105a32 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105a0d:	83 ec 0c             	sub    $0xc,%esp
f0105a10:	68 5c 7d 10 f0       	push   $0xf0107d5c
f0105a15:	e8 62 dc ff ff       	call   f010367c <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105a1a:	ba 22 00 00 00       	mov    $0x22,%edx
f0105a1f:	b8 70 00 00 00       	mov    $0x70,%eax
f0105a24:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105a25:	ba 23 00 00 00       	mov    $0x23,%edx
f0105a2a:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105a2b:	83 c8 01             	or     $0x1,%eax
f0105a2e:	ee                   	out    %al,(%dx)
f0105a2f:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105a32:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a35:	5b                   	pop    %ebx
f0105a36:	5e                   	pop    %esi
f0105a37:	5f                   	pop    %edi
f0105a38:	5d                   	pop    %ebp
f0105a39:	c3                   	ret    

f0105a3a <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105a3a:	55                   	push   %ebp
f0105a3b:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105a3d:	8b 0d 04 f0 21 f0    	mov    0xf021f004,%ecx
f0105a43:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105a46:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105a48:	a1 04 f0 21 f0       	mov    0xf021f004,%eax
f0105a4d:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105a50:	5d                   	pop    %ebp
f0105a51:	c3                   	ret    

f0105a52 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105a52:	55                   	push   %ebp
f0105a53:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105a55:	a1 04 f0 21 f0       	mov    0xf021f004,%eax
f0105a5a:	85 c0                	test   %eax,%eax
f0105a5c:	74 08                	je     f0105a66 <cpunum+0x14>
		return lapic[ID] >> 24;
f0105a5e:	8b 40 20             	mov    0x20(%eax),%eax
f0105a61:	c1 e8 18             	shr    $0x18,%eax
f0105a64:	eb 05                	jmp    f0105a6b <cpunum+0x19>
	return 0;
f0105a66:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105a6b:	5d                   	pop    %ebp
f0105a6c:	c3                   	ret    

f0105a6d <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105a6d:	a1 00 f0 21 f0       	mov    0xf021f000,%eax
f0105a72:	85 c0                	test   %eax,%eax
f0105a74:	0f 84 21 01 00 00    	je     f0105b9b <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105a7a:	55                   	push   %ebp
f0105a7b:	89 e5                	mov    %esp,%ebp
f0105a7d:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105a80:	68 00 10 00 00       	push   $0x1000
f0105a85:	50                   	push   %eax
f0105a86:	e8 5c b7 ff ff       	call   f01011e7 <mmio_map_region>
f0105a8b:	a3 04 f0 21 f0       	mov    %eax,0xf021f004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105a90:	ba 27 01 00 00       	mov    $0x127,%edx
f0105a95:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105a9a:	e8 9b ff ff ff       	call   f0105a3a <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105a9f:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105aa4:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105aa9:	e8 8c ff ff ff       	call   f0105a3a <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105aae:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105ab3:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105ab8:	e8 7d ff ff ff       	call   f0105a3a <lapicw>
	lapicw(TICR, 10000000); 
f0105abd:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105ac2:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105ac7:	e8 6e ff ff ff       	call   f0105a3a <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105acc:	e8 81 ff ff ff       	call   f0105a52 <cpunum>
f0105ad1:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ad4:	05 20 e0 1d f0       	add    $0xf01de020,%eax
f0105ad9:	83 c4 10             	add    $0x10,%esp
f0105adc:	39 05 c0 e3 1d f0    	cmp    %eax,0xf01de3c0
f0105ae2:	74 0f                	je     f0105af3 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105ae4:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ae9:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105aee:	e8 47 ff ff ff       	call   f0105a3a <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105af3:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105af8:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105afd:	e8 38 ff ff ff       	call   f0105a3a <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105b02:	a1 04 f0 21 f0       	mov    0xf021f004,%eax
f0105b07:	8b 40 30             	mov    0x30(%eax),%eax
f0105b0a:	c1 e8 10             	shr    $0x10,%eax
f0105b0d:	3c 03                	cmp    $0x3,%al
f0105b0f:	76 0f                	jbe    f0105b20 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105b11:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105b16:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105b1b:	e8 1a ff ff ff       	call   f0105a3a <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105b20:	ba 33 00 00 00       	mov    $0x33,%edx
f0105b25:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105b2a:	e8 0b ff ff ff       	call   f0105a3a <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105b2f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b34:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105b39:	e8 fc fe ff ff       	call   f0105a3a <lapicw>
	lapicw(ESR, 0);
f0105b3e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b43:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105b48:	e8 ed fe ff ff       	call   f0105a3a <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105b4d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b52:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105b57:	e8 de fe ff ff       	call   f0105a3a <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105b5c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b61:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105b66:	e8 cf fe ff ff       	call   f0105a3a <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105b6b:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105b70:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b75:	e8 c0 fe ff ff       	call   f0105a3a <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105b7a:	8b 15 04 f0 21 f0    	mov    0xf021f004,%edx
f0105b80:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105b86:	f6 c4 10             	test   $0x10,%ah
f0105b89:	75 f5                	jne    f0105b80 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105b8b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b90:	b8 20 00 00 00       	mov    $0x20,%eax
f0105b95:	e8 a0 fe ff ff       	call   f0105a3a <lapicw>
}
f0105b9a:	c9                   	leave  
f0105b9b:	f3 c3                	repz ret 

f0105b9d <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105b9d:	83 3d 04 f0 21 f0 00 	cmpl   $0x0,0xf021f004
f0105ba4:	74 13                	je     f0105bb9 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105ba6:	55                   	push   %ebp
f0105ba7:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105ba9:	ba 00 00 00 00       	mov    $0x0,%edx
f0105bae:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105bb3:	e8 82 fe ff ff       	call   f0105a3a <lapicw>
}
f0105bb8:	5d                   	pop    %ebp
f0105bb9:	f3 c3                	repz ret 

f0105bbb <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105bbb:	55                   	push   %ebp
f0105bbc:	89 e5                	mov    %esp,%ebp
f0105bbe:	56                   	push   %esi
f0105bbf:	53                   	push   %ebx
f0105bc0:	8b 75 08             	mov    0x8(%ebp),%esi
f0105bc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105bc6:	ba 70 00 00 00       	mov    $0x70,%edx
f0105bcb:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105bd0:	ee                   	out    %al,(%dx)
f0105bd1:	ba 71 00 00 00       	mov    $0x71,%edx
f0105bd6:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105bdb:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105bdc:	83 3d 88 de 1d f0 00 	cmpl   $0x0,0xf01dde88
f0105be3:	75 19                	jne    f0105bfe <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105be5:	68 67 04 00 00       	push   $0x467
f0105bea:	68 04 61 10 f0       	push   $0xf0106104
f0105bef:	68 98 00 00 00       	push   $0x98
f0105bf4:	68 d4 7d 10 f0       	push   $0xf0107dd4
f0105bf9:	e8 42 a4 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105bfe:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105c05:	00 00 
	wrv[1] = addr >> 4;
f0105c07:	89 d8                	mov    %ebx,%eax
f0105c09:	c1 e8 04             	shr    $0x4,%eax
f0105c0c:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105c12:	c1 e6 18             	shl    $0x18,%esi
f0105c15:	89 f2                	mov    %esi,%edx
f0105c17:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105c1c:	e8 19 fe ff ff       	call   f0105a3a <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105c21:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105c26:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c2b:	e8 0a fe ff ff       	call   f0105a3a <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105c30:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105c35:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c3a:	e8 fb fd ff ff       	call   f0105a3a <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105c3f:	c1 eb 0c             	shr    $0xc,%ebx
f0105c42:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105c45:	89 f2                	mov    %esi,%edx
f0105c47:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105c4c:	e8 e9 fd ff ff       	call   f0105a3a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105c51:	89 da                	mov    %ebx,%edx
f0105c53:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c58:	e8 dd fd ff ff       	call   f0105a3a <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105c5d:	89 f2                	mov    %esi,%edx
f0105c5f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105c64:	e8 d1 fd ff ff       	call   f0105a3a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105c69:	89 da                	mov    %ebx,%edx
f0105c6b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c70:	e8 c5 fd ff ff       	call   f0105a3a <lapicw>
		microdelay(200);
	}
}
f0105c75:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105c78:	5b                   	pop    %ebx
f0105c79:	5e                   	pop    %esi
f0105c7a:	5d                   	pop    %ebp
f0105c7b:	c3                   	ret    

f0105c7c <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105c7c:	55                   	push   %ebp
f0105c7d:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105c7f:	8b 55 08             	mov    0x8(%ebp),%edx
f0105c82:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105c88:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c8d:	e8 a8 fd ff ff       	call   f0105a3a <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105c92:	8b 15 04 f0 21 f0    	mov    0xf021f004,%edx
f0105c98:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105c9e:	f6 c4 10             	test   $0x10,%ah
f0105ca1:	75 f5                	jne    f0105c98 <lapic_ipi+0x1c>
		;
}
f0105ca3:	5d                   	pop    %ebp
f0105ca4:	c3                   	ret    

f0105ca5 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105ca5:	55                   	push   %ebp
f0105ca6:	89 e5                	mov    %esp,%ebp
f0105ca8:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105cab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105cb1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105cb4:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105cb7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105cbe:	5d                   	pop    %ebp
f0105cbf:	c3                   	ret    

f0105cc0 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105cc0:	55                   	push   %ebp
f0105cc1:	89 e5                	mov    %esp,%ebp
f0105cc3:	56                   	push   %esi
f0105cc4:	53                   	push   %ebx
f0105cc5:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105cc8:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105ccb:	74 14                	je     f0105ce1 <spin_lock+0x21>
f0105ccd:	8b 73 08             	mov    0x8(%ebx),%esi
f0105cd0:	e8 7d fd ff ff       	call   f0105a52 <cpunum>
f0105cd5:	6b c0 74             	imul   $0x74,%eax,%eax
f0105cd8:	05 20 e0 1d f0       	add    $0xf01de020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105cdd:	39 c6                	cmp    %eax,%esi
f0105cdf:	74 07                	je     f0105ce8 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105ce1:	ba 01 00 00 00       	mov    $0x1,%edx
f0105ce6:	eb 20                	jmp    f0105d08 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105ce8:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105ceb:	e8 62 fd ff ff       	call   f0105a52 <cpunum>
f0105cf0:	83 ec 0c             	sub    $0xc,%esp
f0105cf3:	53                   	push   %ebx
f0105cf4:	50                   	push   %eax
f0105cf5:	68 e4 7d 10 f0       	push   $0xf0107de4
f0105cfa:	6a 41                	push   $0x41
f0105cfc:	68 48 7e 10 f0       	push   $0xf0107e48
f0105d01:	e8 3a a3 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105d06:	f3 90                	pause  
f0105d08:	89 d0                	mov    %edx,%eax
f0105d0a:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105d0d:	85 c0                	test   %eax,%eax
f0105d0f:	75 f5                	jne    f0105d06 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105d11:	e8 3c fd ff ff       	call   f0105a52 <cpunum>
f0105d16:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d19:	05 20 e0 1d f0       	add    $0xf01de020,%eax
f0105d1e:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105d21:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0105d24:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105d26:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d2b:	eb 0b                	jmp    f0105d38 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105d2d:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105d30:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105d33:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105d35:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105d38:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105d3e:	76 11                	jbe    f0105d51 <spin_lock+0x91>
f0105d40:	83 f8 09             	cmp    $0x9,%eax
f0105d43:	7e e8                	jle    f0105d2d <spin_lock+0x6d>
f0105d45:	eb 0a                	jmp    f0105d51 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105d47:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105d4e:	83 c0 01             	add    $0x1,%eax
f0105d51:	83 f8 09             	cmp    $0x9,%eax
f0105d54:	7e f1                	jle    f0105d47 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105d56:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105d59:	5b                   	pop    %ebx
f0105d5a:	5e                   	pop    %esi
f0105d5b:	5d                   	pop    %ebp
f0105d5c:	c3                   	ret    

f0105d5d <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105d5d:	55                   	push   %ebp
f0105d5e:	89 e5                	mov    %esp,%ebp
f0105d60:	57                   	push   %edi
f0105d61:	56                   	push   %esi
f0105d62:	53                   	push   %ebx
f0105d63:	83 ec 4c             	sub    $0x4c,%esp
f0105d66:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105d69:	83 3e 00             	cmpl   $0x0,(%esi)
f0105d6c:	74 18                	je     f0105d86 <spin_unlock+0x29>
f0105d6e:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105d71:	e8 dc fc ff ff       	call   f0105a52 <cpunum>
f0105d76:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d79:	05 20 e0 1d f0       	add    $0xf01de020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105d7e:	39 c3                	cmp    %eax,%ebx
f0105d80:	0f 84 a5 00 00 00    	je     f0105e2b <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105d86:	83 ec 04             	sub    $0x4,%esp
f0105d89:	6a 28                	push   $0x28
f0105d8b:	8d 46 0c             	lea    0xc(%esi),%eax
f0105d8e:	50                   	push   %eax
f0105d8f:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105d92:	53                   	push   %ebx
f0105d93:	e8 e7 f6 ff ff       	call   f010547f <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105d98:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105d9b:	0f b6 38             	movzbl (%eax),%edi
f0105d9e:	8b 76 04             	mov    0x4(%esi),%esi
f0105da1:	e8 ac fc ff ff       	call   f0105a52 <cpunum>
f0105da6:	57                   	push   %edi
f0105da7:	56                   	push   %esi
f0105da8:	50                   	push   %eax
f0105da9:	68 10 7e 10 f0       	push   $0xf0107e10
f0105dae:	e8 c9 d8 ff ff       	call   f010367c <cprintf>
f0105db3:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105db6:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105db9:	eb 54                	jmp    f0105e0f <spin_unlock+0xb2>
f0105dbb:	83 ec 08             	sub    $0x8,%esp
f0105dbe:	57                   	push   %edi
f0105dbf:	50                   	push   %eax
f0105dc0:	e8 f3 eb ff ff       	call   f01049b8 <debuginfo_eip>
f0105dc5:	83 c4 10             	add    $0x10,%esp
f0105dc8:	85 c0                	test   %eax,%eax
f0105dca:	78 27                	js     f0105df3 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105dcc:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105dce:	83 ec 04             	sub    $0x4,%esp
f0105dd1:	89 c2                	mov    %eax,%edx
f0105dd3:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105dd6:	52                   	push   %edx
f0105dd7:	ff 75 b0             	pushl  -0x50(%ebp)
f0105dda:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105ddd:	ff 75 ac             	pushl  -0x54(%ebp)
f0105de0:	ff 75 a8             	pushl  -0x58(%ebp)
f0105de3:	50                   	push   %eax
f0105de4:	68 58 7e 10 f0       	push   $0xf0107e58
f0105de9:	e8 8e d8 ff ff       	call   f010367c <cprintf>
f0105dee:	83 c4 20             	add    $0x20,%esp
f0105df1:	eb 12                	jmp    f0105e05 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105df3:	83 ec 08             	sub    $0x8,%esp
f0105df6:	ff 36                	pushl  (%esi)
f0105df8:	68 6f 7e 10 f0       	push   $0xf0107e6f
f0105dfd:	e8 7a d8 ff ff       	call   f010367c <cprintf>
f0105e02:	83 c4 10             	add    $0x10,%esp
f0105e05:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105e08:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105e0b:	39 c3                	cmp    %eax,%ebx
f0105e0d:	74 08                	je     f0105e17 <spin_unlock+0xba>
f0105e0f:	89 de                	mov    %ebx,%esi
f0105e11:	8b 03                	mov    (%ebx),%eax
f0105e13:	85 c0                	test   %eax,%eax
f0105e15:	75 a4                	jne    f0105dbb <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105e17:	83 ec 04             	sub    $0x4,%esp
f0105e1a:	68 77 7e 10 f0       	push   $0xf0107e77
f0105e1f:	6a 67                	push   $0x67
f0105e21:	68 48 7e 10 f0       	push   $0xf0107e48
f0105e26:	e8 15 a2 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105e2b:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105e32:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105e39:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e3e:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0105e41:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105e44:	5b                   	pop    %ebx
f0105e45:	5e                   	pop    %esi
f0105e46:	5f                   	pop    %edi
f0105e47:	5d                   	pop    %ebp
f0105e48:	c3                   	ret    
f0105e49:	66 90                	xchg   %ax,%ax
f0105e4b:	66 90                	xchg   %ax,%ax
f0105e4d:	66 90                	xchg   %ax,%ax
f0105e4f:	90                   	nop

f0105e50 <__udivdi3>:
f0105e50:	55                   	push   %ebp
f0105e51:	57                   	push   %edi
f0105e52:	56                   	push   %esi
f0105e53:	53                   	push   %ebx
f0105e54:	83 ec 1c             	sub    $0x1c,%esp
f0105e57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105e5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105e5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105e67:	85 f6                	test   %esi,%esi
f0105e69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105e6d:	89 ca                	mov    %ecx,%edx
f0105e6f:	89 f8                	mov    %edi,%eax
f0105e71:	75 3d                	jne    f0105eb0 <__udivdi3+0x60>
f0105e73:	39 cf                	cmp    %ecx,%edi
f0105e75:	0f 87 c5 00 00 00    	ja     f0105f40 <__udivdi3+0xf0>
f0105e7b:	85 ff                	test   %edi,%edi
f0105e7d:	89 fd                	mov    %edi,%ebp
f0105e7f:	75 0b                	jne    f0105e8c <__udivdi3+0x3c>
f0105e81:	b8 01 00 00 00       	mov    $0x1,%eax
f0105e86:	31 d2                	xor    %edx,%edx
f0105e88:	f7 f7                	div    %edi
f0105e8a:	89 c5                	mov    %eax,%ebp
f0105e8c:	89 c8                	mov    %ecx,%eax
f0105e8e:	31 d2                	xor    %edx,%edx
f0105e90:	f7 f5                	div    %ebp
f0105e92:	89 c1                	mov    %eax,%ecx
f0105e94:	89 d8                	mov    %ebx,%eax
f0105e96:	89 cf                	mov    %ecx,%edi
f0105e98:	f7 f5                	div    %ebp
f0105e9a:	89 c3                	mov    %eax,%ebx
f0105e9c:	89 d8                	mov    %ebx,%eax
f0105e9e:	89 fa                	mov    %edi,%edx
f0105ea0:	83 c4 1c             	add    $0x1c,%esp
f0105ea3:	5b                   	pop    %ebx
f0105ea4:	5e                   	pop    %esi
f0105ea5:	5f                   	pop    %edi
f0105ea6:	5d                   	pop    %ebp
f0105ea7:	c3                   	ret    
f0105ea8:	90                   	nop
f0105ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105eb0:	39 ce                	cmp    %ecx,%esi
f0105eb2:	77 74                	ja     f0105f28 <__udivdi3+0xd8>
f0105eb4:	0f bd fe             	bsr    %esi,%edi
f0105eb7:	83 f7 1f             	xor    $0x1f,%edi
f0105eba:	0f 84 98 00 00 00    	je     f0105f58 <__udivdi3+0x108>
f0105ec0:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105ec5:	89 f9                	mov    %edi,%ecx
f0105ec7:	89 c5                	mov    %eax,%ebp
f0105ec9:	29 fb                	sub    %edi,%ebx
f0105ecb:	d3 e6                	shl    %cl,%esi
f0105ecd:	89 d9                	mov    %ebx,%ecx
f0105ecf:	d3 ed                	shr    %cl,%ebp
f0105ed1:	89 f9                	mov    %edi,%ecx
f0105ed3:	d3 e0                	shl    %cl,%eax
f0105ed5:	09 ee                	or     %ebp,%esi
f0105ed7:	89 d9                	mov    %ebx,%ecx
f0105ed9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105edd:	89 d5                	mov    %edx,%ebp
f0105edf:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105ee3:	d3 ed                	shr    %cl,%ebp
f0105ee5:	89 f9                	mov    %edi,%ecx
f0105ee7:	d3 e2                	shl    %cl,%edx
f0105ee9:	89 d9                	mov    %ebx,%ecx
f0105eeb:	d3 e8                	shr    %cl,%eax
f0105eed:	09 c2                	or     %eax,%edx
f0105eef:	89 d0                	mov    %edx,%eax
f0105ef1:	89 ea                	mov    %ebp,%edx
f0105ef3:	f7 f6                	div    %esi
f0105ef5:	89 d5                	mov    %edx,%ebp
f0105ef7:	89 c3                	mov    %eax,%ebx
f0105ef9:	f7 64 24 0c          	mull   0xc(%esp)
f0105efd:	39 d5                	cmp    %edx,%ebp
f0105eff:	72 10                	jb     f0105f11 <__udivdi3+0xc1>
f0105f01:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105f05:	89 f9                	mov    %edi,%ecx
f0105f07:	d3 e6                	shl    %cl,%esi
f0105f09:	39 c6                	cmp    %eax,%esi
f0105f0b:	73 07                	jae    f0105f14 <__udivdi3+0xc4>
f0105f0d:	39 d5                	cmp    %edx,%ebp
f0105f0f:	75 03                	jne    f0105f14 <__udivdi3+0xc4>
f0105f11:	83 eb 01             	sub    $0x1,%ebx
f0105f14:	31 ff                	xor    %edi,%edi
f0105f16:	89 d8                	mov    %ebx,%eax
f0105f18:	89 fa                	mov    %edi,%edx
f0105f1a:	83 c4 1c             	add    $0x1c,%esp
f0105f1d:	5b                   	pop    %ebx
f0105f1e:	5e                   	pop    %esi
f0105f1f:	5f                   	pop    %edi
f0105f20:	5d                   	pop    %ebp
f0105f21:	c3                   	ret    
f0105f22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105f28:	31 ff                	xor    %edi,%edi
f0105f2a:	31 db                	xor    %ebx,%ebx
f0105f2c:	89 d8                	mov    %ebx,%eax
f0105f2e:	89 fa                	mov    %edi,%edx
f0105f30:	83 c4 1c             	add    $0x1c,%esp
f0105f33:	5b                   	pop    %ebx
f0105f34:	5e                   	pop    %esi
f0105f35:	5f                   	pop    %edi
f0105f36:	5d                   	pop    %ebp
f0105f37:	c3                   	ret    
f0105f38:	90                   	nop
f0105f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105f40:	89 d8                	mov    %ebx,%eax
f0105f42:	f7 f7                	div    %edi
f0105f44:	31 ff                	xor    %edi,%edi
f0105f46:	89 c3                	mov    %eax,%ebx
f0105f48:	89 d8                	mov    %ebx,%eax
f0105f4a:	89 fa                	mov    %edi,%edx
f0105f4c:	83 c4 1c             	add    $0x1c,%esp
f0105f4f:	5b                   	pop    %ebx
f0105f50:	5e                   	pop    %esi
f0105f51:	5f                   	pop    %edi
f0105f52:	5d                   	pop    %ebp
f0105f53:	c3                   	ret    
f0105f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105f58:	39 ce                	cmp    %ecx,%esi
f0105f5a:	72 0c                	jb     f0105f68 <__udivdi3+0x118>
f0105f5c:	31 db                	xor    %ebx,%ebx
f0105f5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0105f62:	0f 87 34 ff ff ff    	ja     f0105e9c <__udivdi3+0x4c>
f0105f68:	bb 01 00 00 00       	mov    $0x1,%ebx
f0105f6d:	e9 2a ff ff ff       	jmp    f0105e9c <__udivdi3+0x4c>
f0105f72:	66 90                	xchg   %ax,%ax
f0105f74:	66 90                	xchg   %ax,%ax
f0105f76:	66 90                	xchg   %ax,%ax
f0105f78:	66 90                	xchg   %ax,%ax
f0105f7a:	66 90                	xchg   %ax,%ax
f0105f7c:	66 90                	xchg   %ax,%ax
f0105f7e:	66 90                	xchg   %ax,%ax

f0105f80 <__umoddi3>:
f0105f80:	55                   	push   %ebp
f0105f81:	57                   	push   %edi
f0105f82:	56                   	push   %esi
f0105f83:	53                   	push   %ebx
f0105f84:	83 ec 1c             	sub    $0x1c,%esp
f0105f87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0105f8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0105f8f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105f97:	85 d2                	test   %edx,%edx
f0105f99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105f9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105fa1:	89 f3                	mov    %esi,%ebx
f0105fa3:	89 3c 24             	mov    %edi,(%esp)
f0105fa6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105faa:	75 1c                	jne    f0105fc8 <__umoddi3+0x48>
f0105fac:	39 f7                	cmp    %esi,%edi
f0105fae:	76 50                	jbe    f0106000 <__umoddi3+0x80>
f0105fb0:	89 c8                	mov    %ecx,%eax
f0105fb2:	89 f2                	mov    %esi,%edx
f0105fb4:	f7 f7                	div    %edi
f0105fb6:	89 d0                	mov    %edx,%eax
f0105fb8:	31 d2                	xor    %edx,%edx
f0105fba:	83 c4 1c             	add    $0x1c,%esp
f0105fbd:	5b                   	pop    %ebx
f0105fbe:	5e                   	pop    %esi
f0105fbf:	5f                   	pop    %edi
f0105fc0:	5d                   	pop    %ebp
f0105fc1:	c3                   	ret    
f0105fc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105fc8:	39 f2                	cmp    %esi,%edx
f0105fca:	89 d0                	mov    %edx,%eax
f0105fcc:	77 52                	ja     f0106020 <__umoddi3+0xa0>
f0105fce:	0f bd ea             	bsr    %edx,%ebp
f0105fd1:	83 f5 1f             	xor    $0x1f,%ebp
f0105fd4:	75 5a                	jne    f0106030 <__umoddi3+0xb0>
f0105fd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0105fda:	0f 82 e0 00 00 00    	jb     f01060c0 <__umoddi3+0x140>
f0105fe0:	39 0c 24             	cmp    %ecx,(%esp)
f0105fe3:	0f 86 d7 00 00 00    	jbe    f01060c0 <__umoddi3+0x140>
f0105fe9:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105fed:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105ff1:	83 c4 1c             	add    $0x1c,%esp
f0105ff4:	5b                   	pop    %ebx
f0105ff5:	5e                   	pop    %esi
f0105ff6:	5f                   	pop    %edi
f0105ff7:	5d                   	pop    %ebp
f0105ff8:	c3                   	ret    
f0105ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106000:	85 ff                	test   %edi,%edi
f0106002:	89 fd                	mov    %edi,%ebp
f0106004:	75 0b                	jne    f0106011 <__umoddi3+0x91>
f0106006:	b8 01 00 00 00       	mov    $0x1,%eax
f010600b:	31 d2                	xor    %edx,%edx
f010600d:	f7 f7                	div    %edi
f010600f:	89 c5                	mov    %eax,%ebp
f0106011:	89 f0                	mov    %esi,%eax
f0106013:	31 d2                	xor    %edx,%edx
f0106015:	f7 f5                	div    %ebp
f0106017:	89 c8                	mov    %ecx,%eax
f0106019:	f7 f5                	div    %ebp
f010601b:	89 d0                	mov    %edx,%eax
f010601d:	eb 99                	jmp    f0105fb8 <__umoddi3+0x38>
f010601f:	90                   	nop
f0106020:	89 c8                	mov    %ecx,%eax
f0106022:	89 f2                	mov    %esi,%edx
f0106024:	83 c4 1c             	add    $0x1c,%esp
f0106027:	5b                   	pop    %ebx
f0106028:	5e                   	pop    %esi
f0106029:	5f                   	pop    %edi
f010602a:	5d                   	pop    %ebp
f010602b:	c3                   	ret    
f010602c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106030:	8b 34 24             	mov    (%esp),%esi
f0106033:	bf 20 00 00 00       	mov    $0x20,%edi
f0106038:	89 e9                	mov    %ebp,%ecx
f010603a:	29 ef                	sub    %ebp,%edi
f010603c:	d3 e0                	shl    %cl,%eax
f010603e:	89 f9                	mov    %edi,%ecx
f0106040:	89 f2                	mov    %esi,%edx
f0106042:	d3 ea                	shr    %cl,%edx
f0106044:	89 e9                	mov    %ebp,%ecx
f0106046:	09 c2                	or     %eax,%edx
f0106048:	89 d8                	mov    %ebx,%eax
f010604a:	89 14 24             	mov    %edx,(%esp)
f010604d:	89 f2                	mov    %esi,%edx
f010604f:	d3 e2                	shl    %cl,%edx
f0106051:	89 f9                	mov    %edi,%ecx
f0106053:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106057:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010605b:	d3 e8                	shr    %cl,%eax
f010605d:	89 e9                	mov    %ebp,%ecx
f010605f:	89 c6                	mov    %eax,%esi
f0106061:	d3 e3                	shl    %cl,%ebx
f0106063:	89 f9                	mov    %edi,%ecx
f0106065:	89 d0                	mov    %edx,%eax
f0106067:	d3 e8                	shr    %cl,%eax
f0106069:	89 e9                	mov    %ebp,%ecx
f010606b:	09 d8                	or     %ebx,%eax
f010606d:	89 d3                	mov    %edx,%ebx
f010606f:	89 f2                	mov    %esi,%edx
f0106071:	f7 34 24             	divl   (%esp)
f0106074:	89 d6                	mov    %edx,%esi
f0106076:	d3 e3                	shl    %cl,%ebx
f0106078:	f7 64 24 04          	mull   0x4(%esp)
f010607c:	39 d6                	cmp    %edx,%esi
f010607e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106082:	89 d1                	mov    %edx,%ecx
f0106084:	89 c3                	mov    %eax,%ebx
f0106086:	72 08                	jb     f0106090 <__umoddi3+0x110>
f0106088:	75 11                	jne    f010609b <__umoddi3+0x11b>
f010608a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010608e:	73 0b                	jae    f010609b <__umoddi3+0x11b>
f0106090:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106094:	1b 14 24             	sbb    (%esp),%edx
f0106097:	89 d1                	mov    %edx,%ecx
f0106099:	89 c3                	mov    %eax,%ebx
f010609b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010609f:	29 da                	sub    %ebx,%edx
f01060a1:	19 ce                	sbb    %ecx,%esi
f01060a3:	89 f9                	mov    %edi,%ecx
f01060a5:	89 f0                	mov    %esi,%eax
f01060a7:	d3 e0                	shl    %cl,%eax
f01060a9:	89 e9                	mov    %ebp,%ecx
f01060ab:	d3 ea                	shr    %cl,%edx
f01060ad:	89 e9                	mov    %ebp,%ecx
f01060af:	d3 ee                	shr    %cl,%esi
f01060b1:	09 d0                	or     %edx,%eax
f01060b3:	89 f2                	mov    %esi,%edx
f01060b5:	83 c4 1c             	add    $0x1c,%esp
f01060b8:	5b                   	pop    %ebx
f01060b9:	5e                   	pop    %esi
f01060ba:	5f                   	pop    %edi
f01060bb:	5d                   	pop    %ebp
f01060bc:	c3                   	ret    
f01060bd:	8d 76 00             	lea    0x0(%esi),%esi
f01060c0:	29 f9                	sub    %edi,%ecx
f01060c2:	19 d6                	sbb    %edx,%esi
f01060c4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01060c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01060cc:	e9 18 ff ff ff       	jmp    f0105fe9 <__umoddi3+0x69>
