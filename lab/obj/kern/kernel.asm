
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
f0100015:	b8 00 d0 11 00       	mov    $0x11d000,%eax
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
f0100034:	bc 00 d0 11 f0       	mov    $0xf011d000,%esp

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
f0100048:	83 3d 00 af 22 f0 00 	cmpl   $0x0,0xf022af00
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 00 af 22 f0    	mov    %esi,0xf022af00

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 ed 51 00 00       	call   f010524e <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 e0 58 10 f0       	push   $0xf01058e0
f010006d:	e8 a2 35 00 00       	call   f0103614 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 72 35 00 00       	call   f01035ee <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 b7 6a 10 f0 	movl   $0xf0106ab7,(%esp)
f0100083:	e8 8c 35 00 00       	call   f0103614 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 4d 08 00 00       	call   f01008e2 <monitor>
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
f01000a1:	b8 08 c0 26 f0       	mov    $0xf026c008,%eax
f01000a6:	2d 78 95 22 f0       	sub    $0xf0229578,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 78 95 22 f0       	push   $0xf0229578
f01000b3:	e8 75 4b 00 00       	call   f0104c2d <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 5c 05 00 00       	call   f0100619 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 4c 59 10 f0       	push   $0xf010594c
f01000ca:	e8 45 35 00 00       	call   f0103614 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 24 11 00 00       	call   f01011f8 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 28 2d 00 00       	call   f0102e01 <env_init>
	trap_init();
f01000d9:	e8 a7 35 00 00       	call   f0103685 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 61 4e 00 00       	call   f0104f44 <mp_init>
	lapic_init();
f01000e3:	e8 81 51 00 00       	call   f0105269 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 4e 34 00 00       	call   f010353b <pic_init>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000ed:	83 c4 10             	add    $0x10,%esp
f01000f0:	83 3d 08 af 22 f0 07 	cmpl   $0x7,0xf022af08
f01000f7:	77 16                	ja     f010010f <i386_init+0x75>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000f9:	68 00 70 00 00       	push   $0x7000
f01000fe:	68 04 59 10 f0       	push   $0xf0105904
f0100103:	6a 53                	push   $0x53
f0100105:	68 67 59 10 f0       	push   $0xf0105967
f010010a:	e8 31 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010010f:	83 ec 04             	sub    $0x4,%esp
f0100112:	b8 aa 4e 10 f0       	mov    $0xf0104eaa,%eax
f0100117:	2d 30 4e 10 f0       	sub    $0xf0104e30,%eax
f010011c:	50                   	push   %eax
f010011d:	68 30 4e 10 f0       	push   $0xf0104e30
f0100122:	68 00 70 00 f0       	push   $0xf0007000
f0100127:	e8 4e 4b 00 00       	call   f0104c7a <memmove>
f010012c:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010012f:	bb 20 b0 22 f0       	mov    $0xf022b020,%ebx
f0100134:	eb 4d                	jmp    f0100183 <i386_init+0xe9>
		if (c == cpus + cpunum())  // We've started already.
f0100136:	e8 13 51 00 00       	call   f010524e <cpunum>
f010013b:	6b c0 74             	imul   $0x74,%eax,%eax
f010013e:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f0100143:	39 c3                	cmp    %eax,%ebx
f0100145:	74 39                	je     f0100180 <i386_init+0xe6>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100147:	89 d8                	mov    %ebx,%eax
f0100149:	2d 20 b0 22 f0       	sub    $0xf022b020,%eax
f010014e:	c1 f8 02             	sar    $0x2,%eax
f0100151:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100157:	c1 e0 0f             	shl    $0xf,%eax
f010015a:	05 00 40 23 f0       	add    $0xf0234000,%eax
f010015f:	a3 04 af 22 f0       	mov    %eax,0xf022af04
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100164:	83 ec 08             	sub    $0x8,%esp
f0100167:	68 00 70 00 00       	push   $0x7000
f010016c:	0f b6 03             	movzbl (%ebx),%eax
f010016f:	50                   	push   %eax
f0100170:	e8 42 52 00 00       	call   f01053b7 <lapic_startap>
f0100175:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100178:	8b 43 04             	mov    0x4(%ebx),%eax
f010017b:	83 f8 01             	cmp    $0x1,%eax
f010017e:	75 f8                	jne    f0100178 <i386_init+0xde>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100180:	83 c3 74             	add    $0x74,%ebx
f0100183:	6b 05 c4 b3 22 f0 74 	imul   $0x74,0xf022b3c4,%eax
f010018a:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f010018f:	39 c3                	cmp    %eax,%ebx
f0100191:	72 a3                	jb     f0100136 <i386_init+0x9c>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
f0100193:	83 ec 08             	sub    $0x8,%esp
f0100196:	6a 00                	push   $0x0
f0100198:	68 a8 0b 22 f0       	push   $0xf0220ba8
f010019d:	e8 69 2e 00 00       	call   f010300b <env_create>
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01001a2:	e8 11 3e 00 00       	call   f0103fb8 <sched_yield>

f01001a7 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001a7:	55                   	push   %ebp
f01001a8:	89 e5                	mov    %esp,%ebp
f01001aa:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001ad:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001b2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001b7:	77 12                	ja     f01001cb <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001b9:	50                   	push   %eax
f01001ba:	68 28 59 10 f0       	push   $0xf0105928
f01001bf:	6a 6a                	push   $0x6a
f01001c1:	68 67 59 10 f0       	push   $0xf0105967
f01001c6:	e8 75 fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01001cb:	05 00 00 00 10       	add    $0x10000000,%eax
f01001d0:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001d3:	e8 76 50 00 00       	call   f010524e <cpunum>
f01001d8:	83 ec 08             	sub    $0x8,%esp
f01001db:	50                   	push   %eax
f01001dc:	68 73 59 10 f0       	push   $0xf0105973
f01001e1:	e8 2e 34 00 00       	call   f0103614 <cprintf>

	lapic_init();
f01001e6:	e8 7e 50 00 00       	call   f0105269 <lapic_init>
	env_init_percpu();
f01001eb:	e8 e1 2b 00 00       	call   f0102dd1 <env_init_percpu>
	trap_init_percpu();
f01001f0:	e8 33 34 00 00       	call   f0103628 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001f5:	e8 54 50 00 00       	call   f010524e <cpunum>
f01001fa:	6b d0 74             	imul   $0x74,%eax,%edx
f01001fd:	81 c2 20 b0 22 f0    	add    $0xf022b020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100203:	b8 01 00 00 00       	mov    $0x1,%eax
f0100208:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010020c:	83 c4 10             	add    $0x10,%esp
f010020f:	eb fe                	jmp    f010020f <mp_main+0x68>

f0100211 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100211:	55                   	push   %ebp
f0100212:	89 e5                	mov    %esp,%ebp
f0100214:	53                   	push   %ebx
f0100215:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100218:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010021b:	ff 75 0c             	pushl  0xc(%ebp)
f010021e:	ff 75 08             	pushl  0x8(%ebp)
f0100221:	68 89 59 10 f0       	push   $0xf0105989
f0100226:	e8 e9 33 00 00       	call   f0103614 <cprintf>
	vcprintf(fmt, ap);
f010022b:	83 c4 08             	add    $0x8,%esp
f010022e:	53                   	push   %ebx
f010022f:	ff 75 10             	pushl  0x10(%ebp)
f0100232:	e8 b7 33 00 00       	call   f01035ee <vcprintf>
	cprintf("\n");
f0100237:	c7 04 24 b7 6a 10 f0 	movl   $0xf0106ab7,(%esp)
f010023e:	e8 d1 33 00 00       	call   f0103614 <cprintf>
	va_end(ap);
}
f0100243:	83 c4 10             	add    $0x10,%esp
f0100246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100249:	c9                   	leave  
f010024a:	c3                   	ret    

f010024b <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010024b:	55                   	push   %ebp
f010024c:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010024e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100253:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100254:	a8 01                	test   $0x1,%al
f0100256:	74 0b                	je     f0100263 <serial_proc_data+0x18>
f0100258:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010025d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010025e:	0f b6 c0             	movzbl %al,%eax
f0100261:	eb 05                	jmp    f0100268 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100263:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100268:	5d                   	pop    %ebp
f0100269:	c3                   	ret    

f010026a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010026a:	55                   	push   %ebp
f010026b:	89 e5                	mov    %esp,%ebp
f010026d:	53                   	push   %ebx
f010026e:	83 ec 04             	sub    $0x4,%esp
f0100271:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100273:	eb 2b                	jmp    f01002a0 <cons_intr+0x36>
		if (c == 0)
f0100275:	85 c0                	test   %eax,%eax
f0100277:	74 27                	je     f01002a0 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100279:	8b 0d 24 a2 22 f0    	mov    0xf022a224,%ecx
f010027f:	8d 51 01             	lea    0x1(%ecx),%edx
f0100282:	89 15 24 a2 22 f0    	mov    %edx,0xf022a224
f0100288:	88 81 20 a0 22 f0    	mov    %al,-0xfdd5fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010028e:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100294:	75 0a                	jne    f01002a0 <cons_intr+0x36>
			cons.wpos = 0;
f0100296:	c7 05 24 a2 22 f0 00 	movl   $0x0,0xf022a224
f010029d:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002a0:	ff d3                	call   *%ebx
f01002a2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002a5:	75 ce                	jne    f0100275 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002a7:	83 c4 04             	add    $0x4,%esp
f01002aa:	5b                   	pop    %ebx
f01002ab:	5d                   	pop    %ebp
f01002ac:	c3                   	ret    

f01002ad <kbd_proc_data>:
f01002ad:	ba 64 00 00 00       	mov    $0x64,%edx
f01002b2:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01002b3:	a8 01                	test   $0x1,%al
f01002b5:	0f 84 f0 00 00 00    	je     f01003ab <kbd_proc_data+0xfe>
f01002bb:	ba 60 00 00 00       	mov    $0x60,%edx
f01002c0:	ec                   	in     (%dx),%al
f01002c1:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002c3:	3c e0                	cmp    $0xe0,%al
f01002c5:	75 0d                	jne    f01002d4 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01002c7:	83 0d 00 a0 22 f0 40 	orl    $0x40,0xf022a000
		return 0;
f01002ce:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002d3:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002d4:	55                   	push   %ebp
f01002d5:	89 e5                	mov    %esp,%ebp
f01002d7:	53                   	push   %ebx
f01002d8:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002db:	84 c0                	test   %al,%al
f01002dd:	79 36                	jns    f0100315 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002df:	8b 0d 00 a0 22 f0    	mov    0xf022a000,%ecx
f01002e5:	89 cb                	mov    %ecx,%ebx
f01002e7:	83 e3 40             	and    $0x40,%ebx
f01002ea:	83 e0 7f             	and    $0x7f,%eax
f01002ed:	85 db                	test   %ebx,%ebx
f01002ef:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002f2:	0f b6 d2             	movzbl %dl,%edx
f01002f5:	0f b6 82 00 5b 10 f0 	movzbl -0xfefa500(%edx),%eax
f01002fc:	83 c8 40             	or     $0x40,%eax
f01002ff:	0f b6 c0             	movzbl %al,%eax
f0100302:	f7 d0                	not    %eax
f0100304:	21 c8                	and    %ecx,%eax
f0100306:	a3 00 a0 22 f0       	mov    %eax,0xf022a000
		return 0;
f010030b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100310:	e9 9e 00 00 00       	jmp    f01003b3 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100315:	8b 0d 00 a0 22 f0    	mov    0xf022a000,%ecx
f010031b:	f6 c1 40             	test   $0x40,%cl
f010031e:	74 0e                	je     f010032e <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100320:	83 c8 80             	or     $0xffffff80,%eax
f0100323:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100325:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100328:	89 0d 00 a0 22 f0    	mov    %ecx,0xf022a000
	}

	shift |= shiftcode[data];
f010032e:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100331:	0f b6 82 00 5b 10 f0 	movzbl -0xfefa500(%edx),%eax
f0100338:	0b 05 00 a0 22 f0    	or     0xf022a000,%eax
f010033e:	0f b6 8a 00 5a 10 f0 	movzbl -0xfefa600(%edx),%ecx
f0100345:	31 c8                	xor    %ecx,%eax
f0100347:	a3 00 a0 22 f0       	mov    %eax,0xf022a000

	c = charcode[shift & (CTL | SHIFT)][data];
f010034c:	89 c1                	mov    %eax,%ecx
f010034e:	83 e1 03             	and    $0x3,%ecx
f0100351:	8b 0c 8d e0 59 10 f0 	mov    -0xfefa620(,%ecx,4),%ecx
f0100358:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010035c:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010035f:	a8 08                	test   $0x8,%al
f0100361:	74 1b                	je     f010037e <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100363:	89 da                	mov    %ebx,%edx
f0100365:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100368:	83 f9 19             	cmp    $0x19,%ecx
f010036b:	77 05                	ja     f0100372 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f010036d:	83 eb 20             	sub    $0x20,%ebx
f0100370:	eb 0c                	jmp    f010037e <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100372:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100375:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100378:	83 fa 19             	cmp    $0x19,%edx
f010037b:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010037e:	f7 d0                	not    %eax
f0100380:	a8 06                	test   $0x6,%al
f0100382:	75 2d                	jne    f01003b1 <kbd_proc_data+0x104>
f0100384:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010038a:	75 25                	jne    f01003b1 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010038c:	83 ec 0c             	sub    $0xc,%esp
f010038f:	68 a3 59 10 f0       	push   $0xf01059a3
f0100394:	e8 7b 32 00 00       	call   f0103614 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100399:	ba 92 00 00 00       	mov    $0x92,%edx
f010039e:	b8 03 00 00 00       	mov    $0x3,%eax
f01003a3:	ee                   	out    %al,(%dx)
f01003a4:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003a7:	89 d8                	mov    %ebx,%eax
f01003a9:	eb 08                	jmp    f01003b3 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003b0:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003b1:	89 d8                	mov    %ebx,%eax
}
f01003b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003b6:	c9                   	leave  
f01003b7:	c3                   	ret    

f01003b8 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003b8:	55                   	push   %ebp
f01003b9:	89 e5                	mov    %esp,%ebp
f01003bb:	57                   	push   %edi
f01003bc:	56                   	push   %esi
f01003bd:	53                   	push   %ebx
f01003be:	83 ec 1c             	sub    $0x1c,%esp
f01003c1:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003c3:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003c8:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003cd:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003d2:	eb 09                	jmp    f01003dd <cons_putc+0x25>
f01003d4:	89 ca                	mov    %ecx,%edx
f01003d6:	ec                   	in     (%dx),%al
f01003d7:	ec                   	in     (%dx),%al
f01003d8:	ec                   	in     (%dx),%al
f01003d9:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003da:	83 c3 01             	add    $0x1,%ebx
f01003dd:	89 f2                	mov    %esi,%edx
f01003df:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003e0:	a8 20                	test   $0x20,%al
f01003e2:	75 08                	jne    f01003ec <cons_putc+0x34>
f01003e4:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003ea:	7e e8                	jle    f01003d4 <cons_putc+0x1c>
f01003ec:	89 f8                	mov    %edi,%eax
f01003ee:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003f1:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003f6:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003f7:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003fc:	be 79 03 00 00       	mov    $0x379,%esi
f0100401:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100406:	eb 09                	jmp    f0100411 <cons_putc+0x59>
f0100408:	89 ca                	mov    %ecx,%edx
f010040a:	ec                   	in     (%dx),%al
f010040b:	ec                   	in     (%dx),%al
f010040c:	ec                   	in     (%dx),%al
f010040d:	ec                   	in     (%dx),%al
f010040e:	83 c3 01             	add    $0x1,%ebx
f0100411:	89 f2                	mov    %esi,%edx
f0100413:	ec                   	in     (%dx),%al
f0100414:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010041a:	7f 04                	jg     f0100420 <cons_putc+0x68>
f010041c:	84 c0                	test   %al,%al
f010041e:	79 e8                	jns    f0100408 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100420:	ba 78 03 00 00       	mov    $0x378,%edx
f0100425:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100429:	ee                   	out    %al,(%dx)
f010042a:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010042f:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100434:	ee                   	out    %al,(%dx)
f0100435:	b8 08 00 00 00       	mov    $0x8,%eax
f010043a:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010043b:	89 fa                	mov    %edi,%edx
f010043d:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100443:	89 f8                	mov    %edi,%eax
f0100445:	80 cc 07             	or     $0x7,%ah
f0100448:	85 d2                	test   %edx,%edx
f010044a:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010044d:	89 f8                	mov    %edi,%eax
f010044f:	0f b6 c0             	movzbl %al,%eax
f0100452:	83 f8 09             	cmp    $0x9,%eax
f0100455:	74 74                	je     f01004cb <cons_putc+0x113>
f0100457:	83 f8 09             	cmp    $0x9,%eax
f010045a:	7f 0a                	jg     f0100466 <cons_putc+0xae>
f010045c:	83 f8 08             	cmp    $0x8,%eax
f010045f:	74 14                	je     f0100475 <cons_putc+0xbd>
f0100461:	e9 99 00 00 00       	jmp    f01004ff <cons_putc+0x147>
f0100466:	83 f8 0a             	cmp    $0xa,%eax
f0100469:	74 3a                	je     f01004a5 <cons_putc+0xed>
f010046b:	83 f8 0d             	cmp    $0xd,%eax
f010046e:	74 3d                	je     f01004ad <cons_putc+0xf5>
f0100470:	e9 8a 00 00 00       	jmp    f01004ff <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100475:	0f b7 05 28 a2 22 f0 	movzwl 0xf022a228,%eax
f010047c:	66 85 c0             	test   %ax,%ax
f010047f:	0f 84 e6 00 00 00    	je     f010056b <cons_putc+0x1b3>
			crt_pos--;
f0100485:	83 e8 01             	sub    $0x1,%eax
f0100488:	66 a3 28 a2 22 f0    	mov    %ax,0xf022a228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010048e:	0f b7 c0             	movzwl %ax,%eax
f0100491:	66 81 e7 00 ff       	and    $0xff00,%di
f0100496:	83 cf 20             	or     $0x20,%edi
f0100499:	8b 15 2c a2 22 f0    	mov    0xf022a22c,%edx
f010049f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004a3:	eb 78                	jmp    f010051d <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004a5:	66 83 05 28 a2 22 f0 	addw   $0x50,0xf022a228
f01004ac:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004ad:	0f b7 05 28 a2 22 f0 	movzwl 0xf022a228,%eax
f01004b4:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004ba:	c1 e8 16             	shr    $0x16,%eax
f01004bd:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004c0:	c1 e0 04             	shl    $0x4,%eax
f01004c3:	66 a3 28 a2 22 f0    	mov    %ax,0xf022a228
f01004c9:	eb 52                	jmp    f010051d <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d0:	e8 e3 fe ff ff       	call   f01003b8 <cons_putc>
		cons_putc(' ');
f01004d5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004da:	e8 d9 fe ff ff       	call   f01003b8 <cons_putc>
		cons_putc(' ');
f01004df:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e4:	e8 cf fe ff ff       	call   f01003b8 <cons_putc>
		cons_putc(' ');
f01004e9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ee:	e8 c5 fe ff ff       	call   f01003b8 <cons_putc>
		cons_putc(' ');
f01004f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f8:	e8 bb fe ff ff       	call   f01003b8 <cons_putc>
f01004fd:	eb 1e                	jmp    f010051d <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01004ff:	0f b7 05 28 a2 22 f0 	movzwl 0xf022a228,%eax
f0100506:	8d 50 01             	lea    0x1(%eax),%edx
f0100509:	66 89 15 28 a2 22 f0 	mov    %dx,0xf022a228
f0100510:	0f b7 c0             	movzwl %ax,%eax
f0100513:	8b 15 2c a2 22 f0    	mov    0xf022a22c,%edx
f0100519:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010051d:	66 81 3d 28 a2 22 f0 	cmpw   $0x7cf,0xf022a228
f0100524:	cf 07 
f0100526:	76 43                	jbe    f010056b <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100528:	a1 2c a2 22 f0       	mov    0xf022a22c,%eax
f010052d:	83 ec 04             	sub    $0x4,%esp
f0100530:	68 00 0f 00 00       	push   $0xf00
f0100535:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010053b:	52                   	push   %edx
f010053c:	50                   	push   %eax
f010053d:	e8 38 47 00 00       	call   f0104c7a <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100542:	8b 15 2c a2 22 f0    	mov    0xf022a22c,%edx
f0100548:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010054e:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100554:	83 c4 10             	add    $0x10,%esp
f0100557:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010055c:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010055f:	39 d0                	cmp    %edx,%eax
f0100561:	75 f4                	jne    f0100557 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100563:	66 83 2d 28 a2 22 f0 	subw   $0x50,0xf022a228
f010056a:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010056b:	8b 0d 30 a2 22 f0    	mov    0xf022a230,%ecx
f0100571:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100576:	89 ca                	mov    %ecx,%edx
f0100578:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100579:	0f b7 1d 28 a2 22 f0 	movzwl 0xf022a228,%ebx
f0100580:	8d 71 01             	lea    0x1(%ecx),%esi
f0100583:	89 d8                	mov    %ebx,%eax
f0100585:	66 c1 e8 08          	shr    $0x8,%ax
f0100589:	89 f2                	mov    %esi,%edx
f010058b:	ee                   	out    %al,(%dx)
f010058c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100591:	89 ca                	mov    %ecx,%edx
f0100593:	ee                   	out    %al,(%dx)
f0100594:	89 d8                	mov    %ebx,%eax
f0100596:	89 f2                	mov    %esi,%edx
f0100598:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100599:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010059c:	5b                   	pop    %ebx
f010059d:	5e                   	pop    %esi
f010059e:	5f                   	pop    %edi
f010059f:	5d                   	pop    %ebp
f01005a0:	c3                   	ret    

f01005a1 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005a1:	80 3d 34 a2 22 f0 00 	cmpb   $0x0,0xf022a234
f01005a8:	74 11                	je     f01005bb <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005aa:	55                   	push   %ebp
f01005ab:	89 e5                	mov    %esp,%ebp
f01005ad:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005b0:	b8 4b 02 10 f0       	mov    $0xf010024b,%eax
f01005b5:	e8 b0 fc ff ff       	call   f010026a <cons_intr>
}
f01005ba:	c9                   	leave  
f01005bb:	f3 c3                	repz ret 

f01005bd <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005bd:	55                   	push   %ebp
f01005be:	89 e5                	mov    %esp,%ebp
f01005c0:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005c3:	b8 ad 02 10 f0       	mov    $0xf01002ad,%eax
f01005c8:	e8 9d fc ff ff       	call   f010026a <cons_intr>
}
f01005cd:	c9                   	leave  
f01005ce:	c3                   	ret    

f01005cf <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005cf:	55                   	push   %ebp
f01005d0:	89 e5                	mov    %esp,%ebp
f01005d2:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005d5:	e8 c7 ff ff ff       	call   f01005a1 <serial_intr>
	kbd_intr();
f01005da:	e8 de ff ff ff       	call   f01005bd <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005df:	a1 20 a2 22 f0       	mov    0xf022a220,%eax
f01005e4:	3b 05 24 a2 22 f0    	cmp    0xf022a224,%eax
f01005ea:	74 26                	je     f0100612 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01005ec:	8d 50 01             	lea    0x1(%eax),%edx
f01005ef:	89 15 20 a2 22 f0    	mov    %edx,0xf022a220
f01005f5:	0f b6 88 20 a0 22 f0 	movzbl -0xfdd5fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01005fc:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01005fe:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100604:	75 11                	jne    f0100617 <cons_getc+0x48>
			cons.rpos = 0;
f0100606:	c7 05 20 a2 22 f0 00 	movl   $0x0,0xf022a220
f010060d:	00 00 00 
f0100610:	eb 05                	jmp    f0100617 <cons_getc+0x48>
		return c;
	}
	return 0;
f0100612:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100617:	c9                   	leave  
f0100618:	c3                   	ret    

f0100619 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100619:	55                   	push   %ebp
f010061a:	89 e5                	mov    %esp,%ebp
f010061c:	57                   	push   %edi
f010061d:	56                   	push   %esi
f010061e:	53                   	push   %ebx
f010061f:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100622:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100629:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100630:	5a a5 
	if (*cp != 0xA55A) {
f0100632:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100639:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010063d:	74 11                	je     f0100650 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010063f:	c7 05 30 a2 22 f0 b4 	movl   $0x3b4,0xf022a230
f0100646:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100649:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010064e:	eb 16                	jmp    f0100666 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100650:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100657:	c7 05 30 a2 22 f0 d4 	movl   $0x3d4,0xf022a230
f010065e:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100661:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100666:	8b 3d 30 a2 22 f0    	mov    0xf022a230,%edi
f010066c:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100671:	89 fa                	mov    %edi,%edx
f0100673:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100674:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100677:	89 da                	mov    %ebx,%edx
f0100679:	ec                   	in     (%dx),%al
f010067a:	0f b6 c8             	movzbl %al,%ecx
f010067d:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100680:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100685:	89 fa                	mov    %edi,%edx
f0100687:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100688:	89 da                	mov    %ebx,%edx
f010068a:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010068b:	89 35 2c a2 22 f0    	mov    %esi,0xf022a22c
	crt_pos = pos;
f0100691:	0f b6 c0             	movzbl %al,%eax
f0100694:	09 c8                	or     %ecx,%eax
f0100696:	66 a3 28 a2 22 f0    	mov    %ax,0xf022a228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f010069c:	e8 1c ff ff ff       	call   f01005bd <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006a1:	83 ec 0c             	sub    $0xc,%esp
f01006a4:	0f b7 05 88 f3 11 f0 	movzwl 0xf011f388,%eax
f01006ab:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006b0:	50                   	push   %eax
f01006b1:	e8 0d 2e 00 00       	call   f01034c3 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006b6:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c0:	89 f2                	mov    %esi,%edx
f01006c2:	ee                   	out    %al,(%dx)
f01006c3:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006c8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006cd:	ee                   	out    %al,(%dx)
f01006ce:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006d3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006d8:	89 da                	mov    %ebx,%edx
f01006da:	ee                   	out    %al,(%dx)
f01006db:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01006e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e5:	ee                   	out    %al,(%dx)
f01006e6:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006eb:	b8 03 00 00 00       	mov    $0x3,%eax
f01006f0:	ee                   	out    %al,(%dx)
f01006f1:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01006fb:	ee                   	out    %al,(%dx)
f01006fc:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100701:	b8 01 00 00 00       	mov    $0x1,%eax
f0100706:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100707:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010070c:	ec                   	in     (%dx),%al
f010070d:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010070f:	83 c4 10             	add    $0x10,%esp
f0100712:	3c ff                	cmp    $0xff,%al
f0100714:	0f 95 05 34 a2 22 f0 	setne  0xf022a234
f010071b:	89 f2                	mov    %esi,%edx
f010071d:	ec                   	in     (%dx),%al
f010071e:	89 da                	mov    %ebx,%edx
f0100720:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100721:	80 f9 ff             	cmp    $0xff,%cl
f0100724:	75 10                	jne    f0100736 <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f0100726:	83 ec 0c             	sub    $0xc,%esp
f0100729:	68 af 59 10 f0       	push   $0xf01059af
f010072e:	e8 e1 2e 00 00       	call   f0103614 <cprintf>
f0100733:	83 c4 10             	add    $0x10,%esp
}
f0100736:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100739:	5b                   	pop    %ebx
f010073a:	5e                   	pop    %esi
f010073b:	5f                   	pop    %edi
f010073c:	5d                   	pop    %ebp
f010073d:	c3                   	ret    

f010073e <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010073e:	55                   	push   %ebp
f010073f:	89 e5                	mov    %esp,%ebp
f0100741:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100744:	8b 45 08             	mov    0x8(%ebp),%eax
f0100747:	e8 6c fc ff ff       	call   f01003b8 <cons_putc>
}
f010074c:	c9                   	leave  
f010074d:	c3                   	ret    

f010074e <getchar>:

int
getchar(void)
{
f010074e:	55                   	push   %ebp
f010074f:	89 e5                	mov    %esp,%ebp
f0100751:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100754:	e8 76 fe ff ff       	call   f01005cf <cons_getc>
f0100759:	85 c0                	test   %eax,%eax
f010075b:	74 f7                	je     f0100754 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010075d:	c9                   	leave  
f010075e:	c3                   	ret    

f010075f <iscons>:

int
iscons(int fdnum)
{
f010075f:	55                   	push   %ebp
f0100760:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100762:	b8 01 00 00 00       	mov    $0x1,%eax
f0100767:	5d                   	pop    %ebp
f0100768:	c3                   	ret    

f0100769 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100769:	55                   	push   %ebp
f010076a:	89 e5                	mov    %esp,%ebp
f010076c:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010076f:	68 00 5c 10 f0       	push   $0xf0105c00
f0100774:	68 1e 5c 10 f0       	push   $0xf0105c1e
f0100779:	68 23 5c 10 f0       	push   $0xf0105c23
f010077e:	e8 91 2e 00 00       	call   f0103614 <cprintf>
f0100783:	83 c4 0c             	add    $0xc,%esp
f0100786:	68 d0 5c 10 f0       	push   $0xf0105cd0
f010078b:	68 2c 5c 10 f0       	push   $0xf0105c2c
f0100790:	68 23 5c 10 f0       	push   $0xf0105c23
f0100795:	e8 7a 2e 00 00       	call   f0103614 <cprintf>
f010079a:	83 c4 0c             	add    $0xc,%esp
f010079d:	68 35 5c 10 f0       	push   $0xf0105c35
f01007a2:	68 43 5c 10 f0       	push   $0xf0105c43
f01007a7:	68 23 5c 10 f0       	push   $0xf0105c23
f01007ac:	e8 63 2e 00 00       	call   f0103614 <cprintf>
	return 0;
}
f01007b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b6:	c9                   	leave  
f01007b7:	c3                   	ret    

f01007b8 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b8:	55                   	push   %ebp
f01007b9:	89 e5                	mov    %esp,%ebp
f01007bb:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007be:	68 4d 5c 10 f0       	push   $0xf0105c4d
f01007c3:	e8 4c 2e 00 00       	call   f0103614 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007c8:	83 c4 08             	add    $0x8,%esp
f01007cb:	68 0c 00 10 00       	push   $0x10000c
f01007d0:	68 f8 5c 10 f0       	push   $0xf0105cf8
f01007d5:	e8 3a 2e 00 00       	call   f0103614 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007da:	83 c4 0c             	add    $0xc,%esp
f01007dd:	68 0c 00 10 00       	push   $0x10000c
f01007e2:	68 0c 00 10 f0       	push   $0xf010000c
f01007e7:	68 20 5d 10 f0       	push   $0xf0105d20
f01007ec:	e8 23 2e 00 00       	call   f0103614 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007f1:	83 c4 0c             	add    $0xc,%esp
f01007f4:	68 d1 58 10 00       	push   $0x1058d1
f01007f9:	68 d1 58 10 f0       	push   $0xf01058d1
f01007fe:	68 44 5d 10 f0       	push   $0xf0105d44
f0100803:	e8 0c 2e 00 00       	call   f0103614 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100808:	83 c4 0c             	add    $0xc,%esp
f010080b:	68 78 95 22 00       	push   $0x229578
f0100810:	68 78 95 22 f0       	push   $0xf0229578
f0100815:	68 68 5d 10 f0       	push   $0xf0105d68
f010081a:	e8 f5 2d 00 00       	call   f0103614 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010081f:	83 c4 0c             	add    $0xc,%esp
f0100822:	68 08 c0 26 00       	push   $0x26c008
f0100827:	68 08 c0 26 f0       	push   $0xf026c008
f010082c:	68 8c 5d 10 f0       	push   $0xf0105d8c
f0100831:	e8 de 2d 00 00       	call   f0103614 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100836:	b8 07 c4 26 f0       	mov    $0xf026c407,%eax
f010083b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100840:	83 c4 08             	add    $0x8,%esp
f0100843:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100848:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010084e:	85 c0                	test   %eax,%eax
f0100850:	0f 48 c2             	cmovs  %edx,%eax
f0100853:	c1 f8 0a             	sar    $0xa,%eax
f0100856:	50                   	push   %eax
f0100857:	68 b0 5d 10 f0       	push   $0xf0105db0
f010085c:	e8 b3 2d 00 00       	call   f0103614 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100861:	b8 00 00 00 00       	mov    $0x0,%eax
f0100866:	c9                   	leave  
f0100867:	c3                   	ret    

f0100868 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100868:	55                   	push   %ebp
f0100869:	89 e5                	mov    %esp,%ebp
f010086b:	56                   	push   %esi
f010086c:	53                   	push   %ebx
f010086d:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100870:	89 eb                	mov    %ebp,%ebx
	
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
f0100872:	68 66 5c 10 f0       	push   $0xf0105c66
f0100877:	e8 98 2d 00 00       	call   f0103614 <cprintf>
	
	while (ebp) {
f010087c:	83 c4 10             	add    $0x10,%esp
                  *(ebp+3),
                  *(ebp+4),
                  *(ebp+5),
                  *(ebp+6));
                  
	     debuginfo_eip((*(ebp+1)),&info);
f010087f:	8d 75 e0             	lea    -0x20(%ebp),%esi
	
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
	
	while (ebp) {
f0100882:	eb 4e                	jmp    f01008d2 <mon_backtrace+0x6a>
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",ebp,*(ebp+1),
f0100884:	ff 73 18             	pushl  0x18(%ebx)
f0100887:	ff 73 14             	pushl  0x14(%ebx)
f010088a:	ff 73 10             	pushl  0x10(%ebx)
f010088d:	ff 73 0c             	pushl  0xc(%ebx)
f0100890:	ff 73 08             	pushl  0x8(%ebx)
f0100893:	ff 73 04             	pushl  0x4(%ebx)
f0100896:	53                   	push   %ebx
f0100897:	68 dc 5d 10 f0       	push   $0xf0105ddc
f010089c:	e8 73 2d 00 00       	call   f0103614 <cprintf>
                  *(ebp+3),
                  *(ebp+4),
                  *(ebp+5),
                  *(ebp+6));
                  
	     debuginfo_eip((*(ebp+1)),&info);
f01008a1:	83 c4 18             	add    $0x18,%esp
f01008a4:	56                   	push   %esi
f01008a5:	ff 73 04             	pushl  0x4(%ebx)
f01008a8:	e8 1e 39 00 00       	call   f01041cb <debuginfo_eip>
	     cprintf("         %s:%d: %.*s+%d\n", 
f01008ad:	83 c4 08             	add    $0x8,%esp
f01008b0:	8b 43 04             	mov    0x4(%ebx),%eax
f01008b3:	2b 45 f0             	sub    -0x10(%ebp),%eax
f01008b6:	50                   	push   %eax
f01008b7:	ff 75 e8             	pushl  -0x18(%ebp)
f01008ba:	ff 75 ec             	pushl  -0x14(%ebp)
f01008bd:	ff 75 e4             	pushl  -0x1c(%ebp)
f01008c0:	ff 75 e0             	pushl  -0x20(%ebp)
f01008c3:	68 78 5c 10 f0       	push   $0xf0105c78
f01008c8:	e8 47 2d 00 00       	call   f0103614 <cprintf>
	     info.eip_file, info.eip_line,
	     info.eip_fn_namelen, info.eip_fn_name, (*(ebp+1)) - info.eip_fn_addr);

	     ebp = (uint32_t *)*(ebp);
f01008cd:	8b 1b                	mov    (%ebx),%ebx
f01008cf:	83 c4 20             	add    $0x20,%esp
	
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
	
	while (ebp) {
f01008d2:	85 db                	test   %ebx,%ebx
f01008d4:	75 ae                	jne    f0100884 <mon_backtrace+0x1c>
	     ebp = (uint32_t *)*(ebp);
    }

	
	return 0;
}
f01008d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01008db:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01008de:	5b                   	pop    %ebx
f01008df:	5e                   	pop    %esi
f01008e0:	5d                   	pop    %ebp
f01008e1:	c3                   	ret    

f01008e2 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008e2:	55                   	push   %ebp
f01008e3:	89 e5                	mov    %esp,%ebp
f01008e5:	57                   	push   %edi
f01008e6:	56                   	push   %esi
f01008e7:	53                   	push   %ebx
f01008e8:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008eb:	68 10 5e 10 f0       	push   $0xf0105e10
f01008f0:	e8 1f 2d 00 00       	call   f0103614 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008f5:	c7 04 24 34 5e 10 f0 	movl   $0xf0105e34,(%esp)
f01008fc:	e8 13 2d 00 00       	call   f0103614 <cprintf>

	if (tf != NULL)
f0100901:	83 c4 10             	add    $0x10,%esp
f0100904:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100908:	74 0e                	je     f0100918 <monitor+0x36>
		print_trapframe(tf);
f010090a:	83 ec 0c             	sub    $0xc,%esp
f010090d:	ff 75 08             	pushl  0x8(%ebp)
f0100910:	e8 39 31 00 00       	call   f0103a4e <print_trapframe>
f0100915:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100918:	83 ec 0c             	sub    $0xc,%esp
f010091b:	68 91 5c 10 f0       	push   $0xf0105c91
f0100920:	e8 b1 40 00 00       	call   f01049d6 <readline>
f0100925:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100927:	83 c4 10             	add    $0x10,%esp
f010092a:	85 c0                	test   %eax,%eax
f010092c:	74 ea                	je     f0100918 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010092e:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100935:	be 00 00 00 00       	mov    $0x0,%esi
f010093a:	eb 0a                	jmp    f0100946 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010093c:	c6 03 00             	movb   $0x0,(%ebx)
f010093f:	89 f7                	mov    %esi,%edi
f0100941:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100944:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100946:	0f b6 03             	movzbl (%ebx),%eax
f0100949:	84 c0                	test   %al,%al
f010094b:	74 63                	je     f01009b0 <monitor+0xce>
f010094d:	83 ec 08             	sub    $0x8,%esp
f0100950:	0f be c0             	movsbl %al,%eax
f0100953:	50                   	push   %eax
f0100954:	68 95 5c 10 f0       	push   $0xf0105c95
f0100959:	e8 92 42 00 00       	call   f0104bf0 <strchr>
f010095e:	83 c4 10             	add    $0x10,%esp
f0100961:	85 c0                	test   %eax,%eax
f0100963:	75 d7                	jne    f010093c <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100965:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100968:	74 46                	je     f01009b0 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010096a:	83 fe 0f             	cmp    $0xf,%esi
f010096d:	75 14                	jne    f0100983 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010096f:	83 ec 08             	sub    $0x8,%esp
f0100972:	6a 10                	push   $0x10
f0100974:	68 9a 5c 10 f0       	push   $0xf0105c9a
f0100979:	e8 96 2c 00 00       	call   f0103614 <cprintf>
f010097e:	83 c4 10             	add    $0x10,%esp
f0100981:	eb 95                	jmp    f0100918 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100983:	8d 7e 01             	lea    0x1(%esi),%edi
f0100986:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010098a:	eb 03                	jmp    f010098f <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010098c:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010098f:	0f b6 03             	movzbl (%ebx),%eax
f0100992:	84 c0                	test   %al,%al
f0100994:	74 ae                	je     f0100944 <monitor+0x62>
f0100996:	83 ec 08             	sub    $0x8,%esp
f0100999:	0f be c0             	movsbl %al,%eax
f010099c:	50                   	push   %eax
f010099d:	68 95 5c 10 f0       	push   $0xf0105c95
f01009a2:	e8 49 42 00 00       	call   f0104bf0 <strchr>
f01009a7:	83 c4 10             	add    $0x10,%esp
f01009aa:	85 c0                	test   %eax,%eax
f01009ac:	74 de                	je     f010098c <monitor+0xaa>
f01009ae:	eb 94                	jmp    f0100944 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f01009b0:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009b7:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009b8:	85 f6                	test   %esi,%esi
f01009ba:	0f 84 58 ff ff ff    	je     f0100918 <monitor+0x36>
f01009c0:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009c5:	83 ec 08             	sub    $0x8,%esp
f01009c8:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009cb:	ff 34 85 60 5e 10 f0 	pushl  -0xfefa1a0(,%eax,4)
f01009d2:	ff 75 a8             	pushl  -0x58(%ebp)
f01009d5:	e8 b8 41 00 00       	call   f0104b92 <strcmp>
f01009da:	83 c4 10             	add    $0x10,%esp
f01009dd:	85 c0                	test   %eax,%eax
f01009df:	75 21                	jne    f0100a02 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f01009e1:	83 ec 04             	sub    $0x4,%esp
f01009e4:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009e7:	ff 75 08             	pushl  0x8(%ebp)
f01009ea:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01009ed:	52                   	push   %edx
f01009ee:	56                   	push   %esi
f01009ef:	ff 14 85 68 5e 10 f0 	call   *-0xfefa198(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009f6:	83 c4 10             	add    $0x10,%esp
f01009f9:	85 c0                	test   %eax,%eax
f01009fb:	78 25                	js     f0100a22 <monitor+0x140>
f01009fd:	e9 16 ff ff ff       	jmp    f0100918 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a02:	83 c3 01             	add    $0x1,%ebx
f0100a05:	83 fb 03             	cmp    $0x3,%ebx
f0100a08:	75 bb                	jne    f01009c5 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a0a:	83 ec 08             	sub    $0x8,%esp
f0100a0d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a10:	68 b7 5c 10 f0       	push   $0xf0105cb7
f0100a15:	e8 fa 2b 00 00       	call   f0103614 <cprintf>
f0100a1a:	83 c4 10             	add    $0x10,%esp
f0100a1d:	e9 f6 fe ff ff       	jmp    f0100918 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a22:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a25:	5b                   	pop    %ebx
f0100a26:	5e                   	pop    %esi
f0100a27:	5f                   	pop    %edi
f0100a28:	5d                   	pop    %ebp
f0100a29:	c3                   	ret    

f0100a2a <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a2a:	55                   	push   %ebp
f0100a2b:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a2d:	83 3d 38 a2 22 f0 00 	cmpl   $0x0,0xf022a238
f0100a34:	75 11                	jne    f0100a47 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a36:	ba 07 d0 26 f0       	mov    $0xf026d007,%edx
f0100a3b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a41:	89 15 38 a2 22 f0    	mov    %edx,0xf022a238
		nextfree = nextfree + n;
		nextfree = ROUNDUP((char *) nextfree, PGSIZE);
		return result;
	}
	else
		return nextfree;
f0100a47:	8b 15 38 a2 22 f0    	mov    0xf022a238,%edx
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	
	if(n != 0){
f0100a4d:	85 c0                	test   %eax,%eax
f0100a4f:	74 11                	je     f0100a62 <boot_alloc+0x38>
		result = nextfree;
		nextfree = nextfree + n;
		nextfree = ROUNDUP((char *) nextfree, PGSIZE);
f0100a51:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100a58:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a5d:	a3 38 a2 22 f0       	mov    %eax,0xf022a238
	}
	else
		return nextfree;

	return NULL;
}
f0100a62:	89 d0                	mov    %edx,%eax
f0100a64:	5d                   	pop    %ebp
f0100a65:	c3                   	ret    

f0100a66 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a66:	89 d1                	mov    %edx,%ecx
f0100a68:	c1 e9 16             	shr    $0x16,%ecx
f0100a6b:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a6e:	a8 01                	test   $0x1,%al
f0100a70:	74 52                	je     f0100ac4 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a77:	89 c1                	mov    %eax,%ecx
f0100a79:	c1 e9 0c             	shr    $0xc,%ecx
f0100a7c:	3b 0d 08 af 22 f0    	cmp    0xf022af08,%ecx
f0100a82:	72 1b                	jb     f0100a9f <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a84:	55                   	push   %ebp
f0100a85:	89 e5                	mov    %esp,%ebp
f0100a87:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a8a:	50                   	push   %eax
f0100a8b:	68 04 59 10 f0       	push   $0xf0105904
f0100a90:	68 a0 03 00 00       	push   $0x3a0
f0100a95:	68 b1 67 10 f0       	push   $0xf01067b1
f0100a9a:	e8 a1 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100a9f:	c1 ea 0c             	shr    $0xc,%edx
f0100aa2:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100aa8:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100aaf:	89 c2                	mov    %eax,%edx
f0100ab1:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ab4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ab9:	85 d2                	test   %edx,%edx
f0100abb:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ac0:	0f 44 c2             	cmove  %edx,%eax
f0100ac3:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100ac4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100ac9:	c3                   	ret    

f0100aca <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100aca:	55                   	push   %ebp
f0100acb:	89 e5                	mov    %esp,%ebp
f0100acd:	57                   	push   %edi
f0100ace:	56                   	push   %esi
f0100acf:	53                   	push   %ebx
f0100ad0:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ad3:	84 c0                	test   %al,%al
f0100ad5:	0f 85 91 02 00 00    	jne    f0100d6c <check_page_free_list+0x2a2>
f0100adb:	e9 9e 02 00 00       	jmp    f0100d7e <check_page_free_list+0x2b4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100ae0:	83 ec 04             	sub    $0x4,%esp
f0100ae3:	68 84 5e 10 f0       	push   $0xf0105e84
f0100ae8:	68 d5 02 00 00       	push   $0x2d5
f0100aed:	68 b1 67 10 f0       	push   $0xf01067b1
f0100af2:	e8 49 f5 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100af7:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100afa:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100afd:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b00:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b03:	89 c2                	mov    %eax,%edx
f0100b05:	2b 15 10 af 22 f0    	sub    0xf022af10,%edx
f0100b0b:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b11:	0f 95 c2             	setne  %dl
f0100b14:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b17:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b1b:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b1d:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b21:	8b 00                	mov    (%eax),%eax
f0100b23:	85 c0                	test   %eax,%eax
f0100b25:	75 dc                	jne    f0100b03 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b2a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b30:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b33:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b36:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b38:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b3b:	a3 40 a2 22 f0       	mov    %eax,0xf022a240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b40:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b45:	8b 1d 40 a2 22 f0    	mov    0xf022a240,%ebx
f0100b4b:	eb 53                	jmp    f0100ba0 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b4d:	89 d8                	mov    %ebx,%eax
f0100b4f:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0100b55:	c1 f8 03             	sar    $0x3,%eax
f0100b58:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b5b:	89 c2                	mov    %eax,%edx
f0100b5d:	c1 ea 16             	shr    $0x16,%edx
f0100b60:	39 f2                	cmp    %esi,%edx
f0100b62:	73 3a                	jae    f0100b9e <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b64:	89 c2                	mov    %eax,%edx
f0100b66:	c1 ea 0c             	shr    $0xc,%edx
f0100b69:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f0100b6f:	72 12                	jb     f0100b83 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b71:	50                   	push   %eax
f0100b72:	68 04 59 10 f0       	push   $0xf0105904
f0100b77:	6a 58                	push   $0x58
f0100b79:	68 bd 67 10 f0       	push   $0xf01067bd
f0100b7e:	e8 bd f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b83:	83 ec 04             	sub    $0x4,%esp
f0100b86:	68 80 00 00 00       	push   $0x80
f0100b8b:	68 97 00 00 00       	push   $0x97
f0100b90:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b95:	50                   	push   %eax
f0100b96:	e8 92 40 00 00       	call   f0104c2d <memset>
f0100b9b:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b9e:	8b 1b                	mov    (%ebx),%ebx
f0100ba0:	85 db                	test   %ebx,%ebx
f0100ba2:	75 a9                	jne    f0100b4d <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ba4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ba9:	e8 7c fe ff ff       	call   f0100a2a <boot_alloc>
f0100bae:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bb1:	8b 15 40 a2 22 f0    	mov    0xf022a240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bb7:	8b 0d 10 af 22 f0    	mov    0xf022af10,%ecx
		assert(pp < pages + npages);
f0100bbd:	a1 08 af 22 f0       	mov    0xf022af08,%eax
f0100bc2:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100bc5:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100bc8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bcb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100bce:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bd3:	e9 52 01 00 00       	jmp    f0100d2a <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bd8:	39 ca                	cmp    %ecx,%edx
f0100bda:	73 19                	jae    f0100bf5 <check_page_free_list+0x12b>
f0100bdc:	68 cb 67 10 f0       	push   $0xf01067cb
f0100be1:	68 d7 67 10 f0       	push   $0xf01067d7
f0100be6:	68 ef 02 00 00       	push   $0x2ef
f0100beb:	68 b1 67 10 f0       	push   $0xf01067b1
f0100bf0:	e8 4b f4 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100bf5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100bf8:	72 19                	jb     f0100c13 <check_page_free_list+0x149>
f0100bfa:	68 ec 67 10 f0       	push   $0xf01067ec
f0100bff:	68 d7 67 10 f0       	push   $0xf01067d7
f0100c04:	68 f0 02 00 00       	push   $0x2f0
f0100c09:	68 b1 67 10 f0       	push   $0xf01067b1
f0100c0e:	e8 2d f4 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c13:	89 d0                	mov    %edx,%eax
f0100c15:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c18:	a8 07                	test   $0x7,%al
f0100c1a:	74 19                	je     f0100c35 <check_page_free_list+0x16b>
f0100c1c:	68 a8 5e 10 f0       	push   $0xf0105ea8
f0100c21:	68 d7 67 10 f0       	push   $0xf01067d7
f0100c26:	68 f1 02 00 00       	push   $0x2f1
f0100c2b:	68 b1 67 10 f0       	push   $0xf01067b1
f0100c30:	e8 0b f4 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c35:	c1 f8 03             	sar    $0x3,%eax
f0100c38:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c3b:	85 c0                	test   %eax,%eax
f0100c3d:	75 19                	jne    f0100c58 <check_page_free_list+0x18e>
f0100c3f:	68 00 68 10 f0       	push   $0xf0106800
f0100c44:	68 d7 67 10 f0       	push   $0xf01067d7
f0100c49:	68 f4 02 00 00       	push   $0x2f4
f0100c4e:	68 b1 67 10 f0       	push   $0xf01067b1
f0100c53:	e8 e8 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c58:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c5d:	75 19                	jne    f0100c78 <check_page_free_list+0x1ae>
f0100c5f:	68 11 68 10 f0       	push   $0xf0106811
f0100c64:	68 d7 67 10 f0       	push   $0xf01067d7
f0100c69:	68 f5 02 00 00       	push   $0x2f5
f0100c6e:	68 b1 67 10 f0       	push   $0xf01067b1
f0100c73:	e8 c8 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c78:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c7d:	75 19                	jne    f0100c98 <check_page_free_list+0x1ce>
f0100c7f:	68 dc 5e 10 f0       	push   $0xf0105edc
f0100c84:	68 d7 67 10 f0       	push   $0xf01067d7
f0100c89:	68 f6 02 00 00       	push   $0x2f6
f0100c8e:	68 b1 67 10 f0       	push   $0xf01067b1
f0100c93:	e8 a8 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c98:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c9d:	75 19                	jne    f0100cb8 <check_page_free_list+0x1ee>
f0100c9f:	68 2a 68 10 f0       	push   $0xf010682a
f0100ca4:	68 d7 67 10 f0       	push   $0xf01067d7
f0100ca9:	68 f7 02 00 00       	push   $0x2f7
f0100cae:	68 b1 67 10 f0       	push   $0xf01067b1
f0100cb3:	e8 88 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cb8:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100cbd:	0f 86 de 00 00 00    	jbe    f0100da1 <check_page_free_list+0x2d7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cc3:	89 c7                	mov    %eax,%edi
f0100cc5:	c1 ef 0c             	shr    $0xc,%edi
f0100cc8:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100ccb:	77 12                	ja     f0100cdf <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ccd:	50                   	push   %eax
f0100cce:	68 04 59 10 f0       	push   $0xf0105904
f0100cd3:	6a 58                	push   $0x58
f0100cd5:	68 bd 67 10 f0       	push   $0xf01067bd
f0100cda:	e8 61 f3 ff ff       	call   f0100040 <_panic>
f0100cdf:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100ce5:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100ce8:	0f 86 a7 00 00 00    	jbe    f0100d95 <check_page_free_list+0x2cb>
f0100cee:	68 00 5f 10 f0       	push   $0xf0105f00
f0100cf3:	68 d7 67 10 f0       	push   $0xf01067d7
f0100cf8:	68 f8 02 00 00       	push   $0x2f8
f0100cfd:	68 b1 67 10 f0       	push   $0xf01067b1
f0100d02:	e8 39 f3 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d07:	68 44 68 10 f0       	push   $0xf0106844
f0100d0c:	68 d7 67 10 f0       	push   $0xf01067d7
f0100d11:	68 fa 02 00 00       	push   $0x2fa
f0100d16:	68 b1 67 10 f0       	push   $0xf01067b1
f0100d1b:	e8 20 f3 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d20:	83 c6 01             	add    $0x1,%esi
f0100d23:	eb 03                	jmp    f0100d28 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100d25:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d28:	8b 12                	mov    (%edx),%edx
f0100d2a:	85 d2                	test   %edx,%edx
f0100d2c:	0f 85 a6 fe ff ff    	jne    f0100bd8 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d32:	85 f6                	test   %esi,%esi
f0100d34:	7f 19                	jg     f0100d4f <check_page_free_list+0x285>
f0100d36:	68 61 68 10 f0       	push   $0xf0106861
f0100d3b:	68 d7 67 10 f0       	push   $0xf01067d7
f0100d40:	68 02 03 00 00       	push   $0x302
f0100d45:	68 b1 67 10 f0       	push   $0xf01067b1
f0100d4a:	e8 f1 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100d4f:	85 db                	test   %ebx,%ebx
f0100d51:	7f 5e                	jg     f0100db1 <check_page_free_list+0x2e7>
f0100d53:	68 73 68 10 f0       	push   $0xf0106873
f0100d58:	68 d7 67 10 f0       	push   $0xf01067d7
f0100d5d:	68 03 03 00 00       	push   $0x303
f0100d62:	68 b1 67 10 f0       	push   $0xf01067b1
f0100d67:	e8 d4 f2 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d6c:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f0100d71:	85 c0                	test   %eax,%eax
f0100d73:	0f 85 7e fd ff ff    	jne    f0100af7 <check_page_free_list+0x2d>
f0100d79:	e9 62 fd ff ff       	jmp    f0100ae0 <check_page_free_list+0x16>
f0100d7e:	83 3d 40 a2 22 f0 00 	cmpl   $0x0,0xf022a240
f0100d85:	0f 84 55 fd ff ff    	je     f0100ae0 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d8b:	be 00 04 00 00       	mov    $0x400,%esi
f0100d90:	e9 b0 fd ff ff       	jmp    f0100b45 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d95:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d9a:	75 89                	jne    f0100d25 <check_page_free_list+0x25b>
f0100d9c:	e9 66 ff ff ff       	jmp    f0100d07 <check_page_free_list+0x23d>
f0100da1:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100da6:	0f 85 74 ff ff ff    	jne    f0100d20 <check_page_free_list+0x256>
f0100dac:	e9 56 ff ff ff       	jmp    f0100d07 <check_page_free_list+0x23d>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100db1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100db4:	5b                   	pop    %ebx
f0100db5:	5e                   	pop    %esi
f0100db6:	5f                   	pop    %edi
f0100db7:	5d                   	pop    %ebp
f0100db8:	c3                   	ret    

f0100db9 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100db9:	55                   	push   %ebp
f0100dba:	89 e5                	mov    %esp,%ebp
f0100dbc:	56                   	push   %esi
f0100dbd:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0100dbe:	8b 35 44 a2 22 f0    	mov    0xf022a244,%esi
f0100dc4:	8b 1d 40 a2 22 f0    	mov    0xf022a240,%ebx
f0100dca:	ba 00 00 00 00       	mov    $0x0,%edx
f0100dcf:	b8 01 00 00 00       	mov    $0x1,%eax
f0100dd4:	eb 27                	jmp    f0100dfd <page_init+0x44>
		pages[i].pp_ref = 0;
f0100dd6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100ddd:	89 d1                	mov    %edx,%ecx
f0100ddf:	03 0d 10 af 22 f0    	add    0xf022af10,%ecx
f0100de5:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100deb:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0100ded:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100df0:	89 d3                	mov    %edx,%ebx
f0100df2:	03 1d 10 af 22 f0    	add    0xf022af10,%ebx
f0100df8:	ba 01 00 00 00       	mov    $0x1,%edx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0100dfd:	39 f0                	cmp    %esi,%eax
f0100dff:	72 d5                	jb     f0100dd6 <page_init+0x1d>
f0100e01:	84 d2                	test   %dl,%dl
f0100e03:	74 06                	je     f0100e0b <page_init+0x52>
f0100e05:	89 1d 40 a2 22 f0    	mov    %ebx,0xf022a240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	int free = (int)ROUNDUP((char *)envs + (sizeof(struct Env) * NENV) - KERNBASE,PGSIZE)/PGSIZE;
f0100e0b:	a1 48 a2 22 f0       	mov    0xf022a248,%eax
f0100e10:	05 ff ff 01 10       	add    $0x1001ffff,%eax
	//int free1 = (int)ROUNDUP((char *)envs + (sizeof(struct Env) * NENV),PGSIZE)/PGSIZE;
	//int free2 = (int)ROUNDUP((free + free1),PGSIZE);

	for (i = free; i < npages; i++) {
f0100e15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e1a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100e20:	85 c0                	test   %eax,%eax
f0100e22:	0f 48 c2             	cmovs  %edx,%eax
f0100e25:	c1 f8 0c             	sar    $0xc,%eax
f0100e28:	89 c2                	mov    %eax,%edx
f0100e2a:	8b 1d 40 a2 22 f0    	mov    0xf022a240,%ebx
f0100e30:	c1 e0 03             	shl    $0x3,%eax
f0100e33:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e38:	eb 23                	jmp    f0100e5d <page_init+0xa4>
		pages[i].pp_ref = 0;
f0100e3a:	89 c1                	mov    %eax,%ecx
f0100e3c:	03 0d 10 af 22 f0    	add    0xf022af10,%ecx
f0100e42:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100e48:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100e4a:	89 c3                	mov    %eax,%ebx
f0100e4c:	03 1d 10 af 22 f0    	add    0xf022af10,%ebx
	}
	int free = (int)ROUNDUP((char *)envs + (sizeof(struct Env) * NENV) - KERNBASE,PGSIZE)/PGSIZE;
	//int free1 = (int)ROUNDUP((char *)envs + (sizeof(struct Env) * NENV),PGSIZE)/PGSIZE;
	//int free2 = (int)ROUNDUP((free + free1),PGSIZE);

	for (i = free; i < npages; i++) {
f0100e52:	83 c2 01             	add    $0x1,%edx
f0100e55:	83 c0 08             	add    $0x8,%eax
f0100e58:	b9 01 00 00 00       	mov    $0x1,%ecx
f0100e5d:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f0100e63:	72 d5                	jb     f0100e3a <page_init+0x81>
f0100e65:	84 c9                	test   %cl,%cl
f0100e67:	74 06                	je     f0100e6f <page_init+0xb6>
f0100e69:	89 1d 40 a2 22 f0    	mov    %ebx,0xf022a240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100e6f:	5b                   	pop    %ebx
f0100e70:	5e                   	pop    %esi
f0100e71:	5d                   	pop    %ebp
f0100e72:	c3                   	ret    

f0100e73 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100e73:	55                   	push   %ebp
f0100e74:	89 e5                	mov    %esp,%ebp
f0100e76:	53                   	push   %ebx
f0100e77:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	if(page_free_list != 0){
f0100e7a:	8b 1d 40 a2 22 f0    	mov    0xf022a240,%ebx
f0100e80:	85 db                	test   %ebx,%ebx
f0100e82:	74 58                	je     f0100edc <page_alloc+0x69>
		struct PageInfo *result = page_free_list;
		page_free_list = page_free_list -> pp_link;
f0100e84:	8b 03                	mov    (%ebx),%eax
f0100e86:	a3 40 a2 22 f0       	mov    %eax,0xf022a240
		if(alloc_flags & ALLOC_ZERO)
f0100e8b:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e8f:	74 45                	je     f0100ed6 <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e91:	89 d8                	mov    %ebx,%eax
f0100e93:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0100e99:	c1 f8 03             	sar    $0x3,%eax
f0100e9c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e9f:	89 c2                	mov    %eax,%edx
f0100ea1:	c1 ea 0c             	shr    $0xc,%edx
f0100ea4:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f0100eaa:	72 12                	jb     f0100ebe <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eac:	50                   	push   %eax
f0100ead:	68 04 59 10 f0       	push   $0xf0105904
f0100eb2:	6a 58                	push   $0x58
f0100eb4:	68 bd 67 10 f0       	push   $0xf01067bd
f0100eb9:	e8 82 f1 ff ff       	call   f0100040 <_panic>
			memset(page2kva(result), 0 , PGSIZE);
f0100ebe:	83 ec 04             	sub    $0x4,%esp
f0100ec1:	68 00 10 00 00       	push   $0x1000
f0100ec6:	6a 00                	push   $0x0
f0100ec8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ecd:	50                   	push   %eax
f0100ece:	e8 5a 3d 00 00       	call   f0104c2d <memset>
f0100ed3:	83 c4 10             	add    $0x10,%esp
		result->pp_link = NULL;
f0100ed6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return result;
	}
	else
		return NULL;
}
f0100edc:	89 d8                	mov    %ebx,%eax
f0100ede:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ee1:	c9                   	leave  
f0100ee2:	c3                   	ret    

f0100ee3 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100ee3:	55                   	push   %ebp
f0100ee4:	89 e5                	mov    %esp,%ebp
f0100ee6:	83 ec 08             	sub    $0x8,%esp
f0100ee9:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_ref != 0) 
f0100eec:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ef1:	74 17                	je     f0100f0a <page_free+0x27>
		panic("pp_ref is nonzero");
f0100ef3:	83 ec 04             	sub    $0x4,%esp
f0100ef6:	68 84 68 10 f0       	push   $0xf0106884
f0100efb:	68 82 01 00 00       	push   $0x182
f0100f00:	68 b1 67 10 f0       	push   $0xf01067b1
f0100f05:	e8 36 f1 ff ff       	call   f0100040 <_panic>
	if(pp->pp_link != NULL)
f0100f0a:	83 38 00             	cmpl   $0x0,(%eax)
f0100f0d:	74 17                	je     f0100f26 <page_free+0x43>
		panic("pp_link is not NULL");
f0100f0f:	83 ec 04             	sub    $0x4,%esp
f0100f12:	68 96 68 10 f0       	push   $0xf0106896
f0100f17:	68 84 01 00 00       	push   $0x184
f0100f1c:	68 b1 67 10 f0       	push   $0xf01067b1
f0100f21:	e8 1a f1 ff ff       	call   f0100040 <_panic>

	pp->pp_link = page_free_list;
f0100f26:	8b 15 40 a2 22 f0    	mov    0xf022a240,%edx
f0100f2c:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f2e:	a3 40 a2 22 f0       	mov    %eax,0xf022a240
}
f0100f33:	c9                   	leave  
f0100f34:	c3                   	ret    

f0100f35 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f35:	55                   	push   %ebp
f0100f36:	89 e5                	mov    %esp,%ebp
f0100f38:	83 ec 08             	sub    $0x8,%esp
f0100f3b:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f3e:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100f42:	83 e8 01             	sub    $0x1,%eax
f0100f45:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100f49:	66 85 c0             	test   %ax,%ax
f0100f4c:	75 0c                	jne    f0100f5a <page_decref+0x25>
		page_free(pp);
f0100f4e:	83 ec 0c             	sub    $0xc,%esp
f0100f51:	52                   	push   %edx
f0100f52:	e8 8c ff ff ff       	call   f0100ee3 <page_free>
f0100f57:	83 c4 10             	add    $0x10,%esp
}
f0100f5a:	c9                   	leave  
f0100f5b:	c3                   	ret    

f0100f5c <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)				//this fn creates a page table entry for the given va
{
f0100f5c:	55                   	push   %ebp
f0100f5d:	89 e5                	mov    %esp,%ebp
f0100f5f:	56                   	push   %esi
f0100f60:	53                   	push   %ebx
f0100f61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int pdindex = PDX(va);
	int ptindex = PTX(va);
f0100f64:	89 de                	mov    %ebx,%esi
f0100f66:	c1 ee 0c             	shr    $0xc,%esi
f0100f69:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	pte_t *ptable;
	if(!(pgdir[pdindex] & PTE_P)){						// if relevant page doesn't exist, allocate a new one
f0100f6f:	c1 eb 16             	shr    $0x16,%ebx
f0100f72:	c1 e3 02             	shl    $0x2,%ebx
f0100f75:	03 5d 08             	add    0x8(%ebp),%ebx
f0100f78:	f6 03 01             	testb  $0x1,(%ebx)
f0100f7b:	75 2d                	jne    f0100faa <pgdir_walk+0x4e>
		if(create == true){
f0100f7d:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
f0100f81:	75 59                	jne    f0100fdc <pgdir_walk+0x80>
			struct PageInfo *newpage = page_alloc(ALLOC_ZERO);	//free page allocated and cleared
f0100f83:	83 ec 0c             	sub    $0xc,%esp
f0100f86:	6a 01                	push   $0x1
f0100f88:	e8 e6 fe ff ff       	call   f0100e73 <page_alloc>
			if(newpage == NULL)
f0100f8d:	83 c4 10             	add    $0x10,%esp
f0100f90:	85 c0                	test   %eax,%eax
f0100f92:	74 4f                	je     f0100fe3 <pgdir_walk+0x87>
				return NULL;

			newpage->pp_ref++;
f0100f94:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			pgdir[pdindex] = page2pa(newpage)|PTE_P|PTE_W|PTE_U;
f0100f99:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0100f9f:	c1 f8 03             	sar    $0x3,%eax
f0100fa2:	c1 e0 0c             	shl    $0xc,%eax
f0100fa5:	83 c8 07             	or     $0x7,%eax
f0100fa8:	89 03                	mov    %eax,(%ebx)
		}
		else
			return NULL;
	}
	
	ptable = (pte_t *) KADDR(PTE_ADDR(pgdir[pdindex]));
f0100faa:	8b 03                	mov    (%ebx),%eax
f0100fac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fb1:	89 c2                	mov    %eax,%edx
f0100fb3:	c1 ea 0c             	shr    $0xc,%edx
f0100fb6:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f0100fbc:	72 15                	jb     f0100fd3 <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fbe:	50                   	push   %eax
f0100fbf:	68 04 59 10 f0       	push   $0xf0105904
f0100fc4:	68 bf 01 00 00       	push   $0x1bf
f0100fc9:	68 b1 67 10 f0       	push   $0xf01067b1
f0100fce:	e8 6d f0 ff ff       	call   f0100040 <_panic>

	return &ptable[ptindex];//(ptable + ptindex);				//page table start + page table index = page table entry                    
f0100fd3:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0100fda:	eb 0c                	jmp    f0100fe8 <pgdir_walk+0x8c>
			newpage->pp_ref++;
			pgdir[pdindex] = page2pa(newpage)|PTE_P|PTE_W|PTE_U;
			
		}
		else
			return NULL;
f0100fdc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fe1:	eb 05                	jmp    f0100fe8 <pgdir_walk+0x8c>
	pte_t *ptable;
	if(!(pgdir[pdindex] & PTE_P)){						// if relevant page doesn't exist, allocate a new one
		if(create == true){
			struct PageInfo *newpage = page_alloc(ALLOC_ZERO);	//free page allocated and cleared
			if(newpage == NULL)
				return NULL;
f0100fe3:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	
	ptable = (pte_t *) KADDR(PTE_ADDR(pgdir[pdindex]));

	return &ptable[ptindex];//(ptable + ptindex);				//page table start + page table index = page table entry                    
}
f0100fe8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100feb:	5b                   	pop    %ebx
f0100fec:	5e                   	pop    %esi
f0100fed:	5d                   	pop    %ebp
f0100fee:	c3                   	ret    

f0100fef <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100fef:	55                   	push   %ebp
f0100ff0:	89 e5                	mov    %esp,%ebp
f0100ff2:	57                   	push   %edi
f0100ff3:	56                   	push   %esi
f0100ff4:	53                   	push   %ebx
f0100ff5:	83 ec 1c             	sub    $0x1c,%esp
f0100ff8:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100ffb:	c1 e9 0c             	shr    $0xc,%ecx
f0100ffe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(int i = 0; i < size/PGSIZE; i++,va = va + PGSIZE, pa = pa + PGSIZE){
f0101001:	89 d3                	mov    %edx,%ebx
f0101003:	bf 00 00 00 00       	mov    $0x0,%edi
f0101008:	8b 45 08             	mov    0x8(%ebp),%eax
f010100b:	29 d0                	sub    %edx,%eax
f010100d:	89 45 e0             	mov    %eax,-0x20(%ebp)
		pte_t * ptentry = pgdir_walk(pgdir, (void *) va, 1);
		*ptentry = pa|perm|PTE_P;
f0101010:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101013:	83 c8 01             	or     $0x1,%eax
f0101016:	89 45 d8             	mov    %eax,-0x28(%ebp)
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	for(int i = 0; i < size/PGSIZE; i++,va = va + PGSIZE, pa = pa + PGSIZE){
f0101019:	eb 24                	jmp    f010103f <boot_map_region+0x50>
		pte_t * ptentry = pgdir_walk(pgdir, (void *) va, 1);
f010101b:	83 ec 04             	sub    $0x4,%esp
f010101e:	6a 01                	push   $0x1
f0101020:	53                   	push   %ebx
f0101021:	ff 75 dc             	pushl  -0x24(%ebp)
f0101024:	e8 33 ff ff ff       	call   f0100f5c <pgdir_walk>
		*ptentry = pa|perm|PTE_P;
f0101029:	0b 75 d8             	or     -0x28(%ebp),%esi
f010102c:	89 30                	mov    %esi,(%eax)
		if(va == 4294967295LL)
f010102e:	83 c4 10             	add    $0x10,%esp
f0101031:	83 fb ff             	cmp    $0xffffffff,%ebx
f0101034:	74 14                	je     f010104a <boot_map_region+0x5b>
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	for(int i = 0; i < size/PGSIZE; i++,va = va + PGSIZE, pa = pa + PGSIZE){
f0101036:	83 c7 01             	add    $0x1,%edi
f0101039:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010103f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101042:	8d 34 18             	lea    (%eax,%ebx,1),%esi
f0101045:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0101048:	75 d1                	jne    f010101b <boot_map_region+0x2c>
		*ptentry = pa|perm|PTE_P;
		if(va == 4294967295LL)
			break;
	}
	
}
f010104a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010104d:	5b                   	pop    %ebx
f010104e:	5e                   	pop    %esi
f010104f:	5f                   	pop    %edi
f0101050:	5d                   	pop    %ebp
f0101051:	c3                   	ret    

f0101052 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101052:	55                   	push   %ebp
f0101053:	89 e5                	mov    %esp,%ebp
f0101055:	57                   	push   %edi
f0101056:	56                   	push   %esi
f0101057:	53                   	push   %ebx
f0101058:	83 ec 10             	sub    $0x10,%esp
f010105b:	8b 75 08             	mov    0x8(%ebp),%esi
f010105e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101061:	8b 7d 10             	mov    0x10(%ebp),%edi
	int pdindex = PDX(va);
	int ptindex = PTX(va);
	pte_t *ptentry = pgdir_walk(pgdir, va, 0);
f0101064:	6a 00                	push   $0x0
f0101066:	53                   	push   %ebx
f0101067:	56                   	push   %esi
f0101068:	e8 ef fe ff ff       	call   f0100f5c <pgdir_walk>
	
	if(!(pgdir[pdindex] & PTE_P)){
f010106d:	c1 eb 16             	shr    $0x16,%ebx
f0101070:	83 c4 10             	add    $0x10,%esp
f0101073:	f6 04 9e 01          	testb  $0x1,(%esi,%ebx,4)
f0101077:	74 32                	je     f01010ab <page_lookup+0x59>
		return NULL;
	}

	if(pte_store)
f0101079:	85 ff                	test   %edi,%edi
f010107b:	74 02                	je     f010107f <page_lookup+0x2d>
		*pte_store = ptentry;
f010107d:	89 07                	mov    %eax,(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010107f:	8b 00                	mov    (%eax),%eax
f0101081:	c1 e8 0c             	shr    $0xc,%eax
f0101084:	3b 05 08 af 22 f0    	cmp    0xf022af08,%eax
f010108a:	72 14                	jb     f01010a0 <page_lookup+0x4e>
		panic("pa2page called with invalid pa");
f010108c:	83 ec 04             	sub    $0x4,%esp
f010108f:	68 48 5f 10 f0       	push   $0xf0105f48
f0101094:	6a 51                	push   $0x51
f0101096:	68 bd 67 10 f0       	push   $0xf01067bd
f010109b:	e8 a0 ef ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01010a0:	8b 15 10 af 22 f0    	mov    0xf022af10,%edx
f01010a6:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	
	return pa2page(PTE_ADDR(*ptentry));
f01010a9:	eb 05                	jmp    f01010b0 <page_lookup+0x5e>
	int pdindex = PDX(va);
	int ptindex = PTX(va);
	pte_t *ptentry = pgdir_walk(pgdir, va, 0);
	
	if(!(pgdir[pdindex] & PTE_P)){
		return NULL;
f01010ab:	b8 00 00 00 00       	mov    $0x0,%eax
	if(pte_store)
		*pte_store = ptentry;
	
	return pa2page(PTE_ADDR(*ptentry));
		
}
f01010b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010b3:	5b                   	pop    %ebx
f01010b4:	5e                   	pop    %esi
f01010b5:	5f                   	pop    %edi
f01010b6:	5d                   	pop    %ebp
f01010b7:	c3                   	ret    

f01010b8 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01010b8:	55                   	push   %ebp
f01010b9:	89 e5                	mov    %esp,%ebp
f01010bb:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01010be:	e8 8b 41 00 00       	call   f010524e <cpunum>
f01010c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01010c6:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f01010cd:	74 16                	je     f01010e5 <tlb_invalidate+0x2d>
f01010cf:	e8 7a 41 00 00       	call   f010524e <cpunum>
f01010d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01010d7:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f01010dd:	8b 55 08             	mov    0x8(%ebp),%edx
f01010e0:	39 50 60             	cmp    %edx,0x60(%eax)
f01010e3:	75 06                	jne    f01010eb <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01010e5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010e8:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01010eb:	c9                   	leave  
f01010ec:	c3                   	ret    

f01010ed <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01010ed:	55                   	push   %ebp
f01010ee:	89 e5                	mov    %esp,%ebp
f01010f0:	56                   	push   %esi
f01010f1:	53                   	push   %ebx
f01010f2:	83 ec 14             	sub    $0x14,%esp
f01010f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01010f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *ptentry;

	struct PageInfo *oldpage = page_lookup(pgdir, va, &ptentry);
f01010fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01010fe:	50                   	push   %eax
f01010ff:	56                   	push   %esi
f0101100:	53                   	push   %ebx
f0101101:	e8 4c ff ff ff       	call   f0101052 <page_lookup>

	if(!oldpage || !(*ptentry & PTE_P))
f0101106:	83 c4 10             	add    $0x10,%esp
f0101109:	85 c0                	test   %eax,%eax
f010110b:	74 27                	je     f0101134 <page_remove+0x47>
f010110d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101110:	f6 02 01             	testb  $0x1,(%edx)
f0101113:	74 1f                	je     f0101134 <page_remove+0x47>
		return;
	page_decref(oldpage);
f0101115:	83 ec 0c             	sub    $0xc,%esp
f0101118:	50                   	push   %eax
f0101119:	e8 17 fe ff ff       	call   f0100f35 <page_decref>
	*ptentry = 0;
f010111e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101121:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f0101127:	83 c4 08             	add    $0x8,%esp
f010112a:	56                   	push   %esi
f010112b:	53                   	push   %ebx
f010112c:	e8 87 ff ff ff       	call   f01010b8 <tlb_invalidate>
f0101131:	83 c4 10             	add    $0x10,%esp
}
f0101134:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101137:	5b                   	pop    %ebx
f0101138:	5e                   	pop    %esi
f0101139:	5d                   	pop    %ebp
f010113a:	c3                   	ret    

f010113b <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010113b:	55                   	push   %ebp
f010113c:	89 e5                	mov    %esp,%ebp
f010113e:	57                   	push   %edi
f010113f:	56                   	push   %esi
f0101140:	53                   	push   %ebx
f0101141:	83 ec 10             	sub    $0x10,%esp
f0101144:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101147:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *ptentry = pgdir_walk(pgdir, va, 1);
f010114a:	6a 01                	push   $0x1
f010114c:	57                   	push   %edi
f010114d:	ff 75 08             	pushl  0x8(%ebp)
f0101150:	e8 07 fe ff ff       	call   f0100f5c <pgdir_walk>
	
	if(!ptentry)
f0101155:	83 c4 10             	add    $0x10,%esp
f0101158:	85 c0                	test   %eax,%eax
f010115a:	74 38                	je     f0101194 <page_insert+0x59>
f010115c:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;
		
	pp->pp_ref++;
f010115e:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
		
	if(*ptentry & PTE_P)
f0101163:	f6 00 01             	testb  $0x1,(%eax)
f0101166:	74 0f                	je     f0101177 <page_insert+0x3c>
		page_remove(pgdir, va);
f0101168:	83 ec 08             	sub    $0x8,%esp
f010116b:	57                   	push   %edi
f010116c:	ff 75 08             	pushl  0x8(%ebp)
f010116f:	e8 79 ff ff ff       	call   f01010ed <page_remove>
f0101174:	83 c4 10             	add    $0x10,%esp
	
	*ptentry = page2pa(pp) | perm | PTE_P;
f0101177:	2b 1d 10 af 22 f0    	sub    0xf022af10,%ebx
f010117d:	c1 fb 03             	sar    $0x3,%ebx
f0101180:	c1 e3 0c             	shl    $0xc,%ebx
f0101183:	8b 45 14             	mov    0x14(%ebp),%eax
f0101186:	83 c8 01             	or     $0x1,%eax
f0101189:	09 c3                	or     %eax,%ebx
f010118b:	89 1e                	mov    %ebx,(%esi)
	
	return 0;
f010118d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101192:	eb 05                	jmp    f0101199 <page_insert+0x5e>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *ptentry = pgdir_walk(pgdir, va, 1);
	
	if(!ptentry)
		return -E_NO_MEM;
f0101194:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);
	
	*ptentry = page2pa(pp) | perm | PTE_P;
	
	return 0;
}
f0101199:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010119c:	5b                   	pop    %ebx
f010119d:	5e                   	pop    %esi
f010119e:	5f                   	pop    %edi
f010119f:	5d                   	pop    %ebp
f01011a0:	c3                   	ret    

f01011a1 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01011a1:	55                   	push   %ebp
f01011a2:	89 e5                	mov    %esp,%ebp
f01011a4:	83 ec 08             	sub    $0x8,%esp
f01011a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// Your code here:
	
	uint32_t new_base = base + size;
	
	if (new_base > ULIM)
f01011aa:	8d 81 00 00 80 ef    	lea    -0x10800000(%ecx),%eax
f01011b0:	3d 00 00 80 ef       	cmp    $0xef800000,%eax
f01011b5:	76 17                	jbe    f01011ce <mmio_map_region+0x2d>
		panic("mmio_map_region failed: Cannot map above ULIM");
f01011b7:	83 ec 04             	sub    $0x4,%esp
f01011ba:	68 68 5f 10 f0       	push   $0xf0105f68
f01011bf:	68 70 02 00 00       	push   $0x270
f01011c4:	68 b1 67 10 f0       	push   $0xf01067b1
f01011c9:	e8 72 ee ff ff       	call   f0100040 <_panic>
	
	size = ROUNDUP(size, PGSIZE);
f01011ce:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
	
	boot_map_region(kern_pgdir, base, size, pa, PTE_W|PTE_PCD|PTE_PWT|PTE_P);
f01011d4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01011da:	83 ec 08             	sub    $0x8,%esp
f01011dd:	6a 1b                	push   $0x1b
f01011df:	ff 75 08             	pushl  0x8(%ebp)
f01011e2:	ba 00 00 80 ef       	mov    $0xef800000,%edx
f01011e7:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f01011ec:	e8 fe fd ff ff       	call   f0100fef <boot_map_region>
	
	return (void *)base;
	
	//panic("mmio_map_region not implemented");
}
f01011f1:	b8 00 00 80 ef       	mov    $0xef800000,%eax
f01011f6:	c9                   	leave  
f01011f7:	c3                   	ret    

f01011f8 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01011f8:	55                   	push   %ebp
f01011f9:	89 e5                	mov    %esp,%ebp
f01011fb:	57                   	push   %edi
f01011fc:	56                   	push   %esi
f01011fd:	53                   	push   %ebx
f01011fe:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101201:	6a 15                	push   $0x15
f0101203:	e8 8d 22 00 00       	call   f0103495 <mc146818_read>
f0101208:	89 c3                	mov    %eax,%ebx
f010120a:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101211:	e8 7f 22 00 00       	call   f0103495 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101216:	c1 e0 08             	shl    $0x8,%eax
f0101219:	09 d8                	or     %ebx,%eax
f010121b:	c1 e0 0a             	shl    $0xa,%eax
f010121e:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101224:	85 c0                	test   %eax,%eax
f0101226:	0f 48 c2             	cmovs  %edx,%eax
f0101229:	c1 f8 0c             	sar    $0xc,%eax
f010122c:	a3 44 a2 22 f0       	mov    %eax,0xf022a244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101231:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101238:	e8 58 22 00 00       	call   f0103495 <mc146818_read>
f010123d:	89 c3                	mov    %eax,%ebx
f010123f:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101246:	e8 4a 22 00 00       	call   f0103495 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010124b:	c1 e0 08             	shl    $0x8,%eax
f010124e:	09 d8                	or     %ebx,%eax
f0101250:	c1 e0 0a             	shl    $0xa,%eax
f0101253:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101259:	83 c4 10             	add    $0x10,%esp
f010125c:	85 c0                	test   %eax,%eax
f010125e:	0f 48 c2             	cmovs  %edx,%eax
f0101261:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101264:	85 c0                	test   %eax,%eax
f0101266:	74 0e                	je     f0101276 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101268:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010126e:	89 15 08 af 22 f0    	mov    %edx,0xf022af08
f0101274:	eb 0c                	jmp    f0101282 <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101276:	8b 15 44 a2 22 f0    	mov    0xf022a244,%edx
f010127c:	89 15 08 af 22 f0    	mov    %edx,0xf022af08

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101282:	c1 e0 0c             	shl    $0xc,%eax
f0101285:	c1 e8 0a             	shr    $0xa,%eax
f0101288:	50                   	push   %eax
f0101289:	a1 44 a2 22 f0       	mov    0xf022a244,%eax
f010128e:	c1 e0 0c             	shl    $0xc,%eax
f0101291:	c1 e8 0a             	shr    $0xa,%eax
f0101294:	50                   	push   %eax
f0101295:	a1 08 af 22 f0       	mov    0xf022af08,%eax
f010129a:	c1 e0 0c             	shl    $0xc,%eax
f010129d:	c1 e8 0a             	shr    $0xa,%eax
f01012a0:	50                   	push   %eax
f01012a1:	68 98 5f 10 f0       	push   $0xf0105f98
f01012a6:	e8 69 23 00 00       	call   f0103614 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01012ab:	b8 00 10 00 00       	mov    $0x1000,%eax
f01012b0:	e8 75 f7 ff ff       	call   f0100a2a <boot_alloc>
f01012b5:	a3 0c af 22 f0       	mov    %eax,0xf022af0c
	memset(kern_pgdir, 0, PGSIZE);
f01012ba:	83 c4 0c             	add    $0xc,%esp
f01012bd:	68 00 10 00 00       	push   $0x1000
f01012c2:	6a 00                	push   $0x0
f01012c4:	50                   	push   %eax
f01012c5:	e8 63 39 00 00       	call   f0104c2d <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01012ca:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01012cf:	83 c4 10             	add    $0x10,%esp
f01012d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01012d7:	77 15                	ja     f01012ee <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01012d9:	50                   	push   %eax
f01012da:	68 28 59 10 f0       	push   $0xf0105928
f01012df:	68 96 00 00 00       	push   $0x96
f01012e4:	68 b1 67 10 f0       	push   $0xf01067b1
f01012e9:	e8 52 ed ff ff       	call   f0100040 <_panic>
f01012ee:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01012f4:	83 ca 05             	or     $0x5,%edx
f01012f7:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo)*npages);
f01012fd:	a1 08 af 22 f0       	mov    0xf022af08,%eax
f0101302:	c1 e0 03             	shl    $0x3,%eax
f0101305:	e8 20 f7 ff ff       	call   f0100a2a <boot_alloc>
f010130a:	a3 10 af 22 f0       	mov    %eax,0xf022af10
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f010130f:	83 ec 04             	sub    $0x4,%esp
f0101312:	8b 0d 08 af 22 f0    	mov    0xf022af08,%ecx
f0101318:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010131f:	52                   	push   %edx
f0101320:	6a 00                	push   $0x0
f0101322:	50                   	push   %eax
f0101323:	e8 05 39 00 00       	call   f0104c2d <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(sizeof(struct Env)*NENV);
f0101328:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010132d:	e8 f8 f6 ff ff       	call   f0100a2a <boot_alloc>
f0101332:	a3 48 a2 22 f0       	mov    %eax,0xf022a248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101337:	e8 7d fa ff ff       	call   f0100db9 <page_init>

	check_page_free_list(1);
f010133c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101341:	e8 84 f7 ff ff       	call   f0100aca <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101346:	83 c4 10             	add    $0x10,%esp
f0101349:	83 3d 10 af 22 f0 00 	cmpl   $0x0,0xf022af10
f0101350:	75 17                	jne    f0101369 <mem_init+0x171>
		panic("'pages' is a null pointer!");
f0101352:	83 ec 04             	sub    $0x4,%esp
f0101355:	68 aa 68 10 f0       	push   $0xf01068aa
f010135a:	68 14 03 00 00       	push   $0x314
f010135f:	68 b1 67 10 f0       	push   $0xf01067b1
f0101364:	e8 d7 ec ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101369:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f010136e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101373:	eb 05                	jmp    f010137a <mem_init+0x182>
		++nfree;
f0101375:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101378:	8b 00                	mov    (%eax),%eax
f010137a:	85 c0                	test   %eax,%eax
f010137c:	75 f7                	jne    f0101375 <mem_init+0x17d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010137e:	83 ec 0c             	sub    $0xc,%esp
f0101381:	6a 00                	push   $0x0
f0101383:	e8 eb fa ff ff       	call   f0100e73 <page_alloc>
f0101388:	89 c7                	mov    %eax,%edi
f010138a:	83 c4 10             	add    $0x10,%esp
f010138d:	85 c0                	test   %eax,%eax
f010138f:	75 19                	jne    f01013aa <mem_init+0x1b2>
f0101391:	68 c5 68 10 f0       	push   $0xf01068c5
f0101396:	68 d7 67 10 f0       	push   $0xf01067d7
f010139b:	68 1c 03 00 00       	push   $0x31c
f01013a0:	68 b1 67 10 f0       	push   $0xf01067b1
f01013a5:	e8 96 ec ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01013aa:	83 ec 0c             	sub    $0xc,%esp
f01013ad:	6a 00                	push   $0x0
f01013af:	e8 bf fa ff ff       	call   f0100e73 <page_alloc>
f01013b4:	89 c6                	mov    %eax,%esi
f01013b6:	83 c4 10             	add    $0x10,%esp
f01013b9:	85 c0                	test   %eax,%eax
f01013bb:	75 19                	jne    f01013d6 <mem_init+0x1de>
f01013bd:	68 db 68 10 f0       	push   $0xf01068db
f01013c2:	68 d7 67 10 f0       	push   $0xf01067d7
f01013c7:	68 1d 03 00 00       	push   $0x31d
f01013cc:	68 b1 67 10 f0       	push   $0xf01067b1
f01013d1:	e8 6a ec ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01013d6:	83 ec 0c             	sub    $0xc,%esp
f01013d9:	6a 00                	push   $0x0
f01013db:	e8 93 fa ff ff       	call   f0100e73 <page_alloc>
f01013e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013e3:	83 c4 10             	add    $0x10,%esp
f01013e6:	85 c0                	test   %eax,%eax
f01013e8:	75 19                	jne    f0101403 <mem_init+0x20b>
f01013ea:	68 f1 68 10 f0       	push   $0xf01068f1
f01013ef:	68 d7 67 10 f0       	push   $0xf01067d7
f01013f4:	68 1e 03 00 00       	push   $0x31e
f01013f9:	68 b1 67 10 f0       	push   $0xf01067b1
f01013fe:	e8 3d ec ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101403:	39 f7                	cmp    %esi,%edi
f0101405:	75 19                	jne    f0101420 <mem_init+0x228>
f0101407:	68 07 69 10 f0       	push   $0xf0106907
f010140c:	68 d7 67 10 f0       	push   $0xf01067d7
f0101411:	68 21 03 00 00       	push   $0x321
f0101416:	68 b1 67 10 f0       	push   $0xf01067b1
f010141b:	e8 20 ec ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101420:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101423:	39 c6                	cmp    %eax,%esi
f0101425:	74 04                	je     f010142b <mem_init+0x233>
f0101427:	39 c7                	cmp    %eax,%edi
f0101429:	75 19                	jne    f0101444 <mem_init+0x24c>
f010142b:	68 d4 5f 10 f0       	push   $0xf0105fd4
f0101430:	68 d7 67 10 f0       	push   $0xf01067d7
f0101435:	68 22 03 00 00       	push   $0x322
f010143a:	68 b1 67 10 f0       	push   $0xf01067b1
f010143f:	e8 fc eb ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101444:	8b 0d 10 af 22 f0    	mov    0xf022af10,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010144a:	8b 15 08 af 22 f0    	mov    0xf022af08,%edx
f0101450:	c1 e2 0c             	shl    $0xc,%edx
f0101453:	89 f8                	mov    %edi,%eax
f0101455:	29 c8                	sub    %ecx,%eax
f0101457:	c1 f8 03             	sar    $0x3,%eax
f010145a:	c1 e0 0c             	shl    $0xc,%eax
f010145d:	39 d0                	cmp    %edx,%eax
f010145f:	72 19                	jb     f010147a <mem_init+0x282>
f0101461:	68 19 69 10 f0       	push   $0xf0106919
f0101466:	68 d7 67 10 f0       	push   $0xf01067d7
f010146b:	68 23 03 00 00       	push   $0x323
f0101470:	68 b1 67 10 f0       	push   $0xf01067b1
f0101475:	e8 c6 eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010147a:	89 f0                	mov    %esi,%eax
f010147c:	29 c8                	sub    %ecx,%eax
f010147e:	c1 f8 03             	sar    $0x3,%eax
f0101481:	c1 e0 0c             	shl    $0xc,%eax
f0101484:	39 c2                	cmp    %eax,%edx
f0101486:	77 19                	ja     f01014a1 <mem_init+0x2a9>
f0101488:	68 36 69 10 f0       	push   $0xf0106936
f010148d:	68 d7 67 10 f0       	push   $0xf01067d7
f0101492:	68 24 03 00 00       	push   $0x324
f0101497:	68 b1 67 10 f0       	push   $0xf01067b1
f010149c:	e8 9f eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01014a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014a4:	29 c8                	sub    %ecx,%eax
f01014a6:	c1 f8 03             	sar    $0x3,%eax
f01014a9:	c1 e0 0c             	shl    $0xc,%eax
f01014ac:	39 c2                	cmp    %eax,%edx
f01014ae:	77 19                	ja     f01014c9 <mem_init+0x2d1>
f01014b0:	68 53 69 10 f0       	push   $0xf0106953
f01014b5:	68 d7 67 10 f0       	push   $0xf01067d7
f01014ba:	68 25 03 00 00       	push   $0x325
f01014bf:	68 b1 67 10 f0       	push   $0xf01067b1
f01014c4:	e8 77 eb ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01014c9:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f01014ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01014d1:	c7 05 40 a2 22 f0 00 	movl   $0x0,0xf022a240
f01014d8:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01014db:	83 ec 0c             	sub    $0xc,%esp
f01014de:	6a 00                	push   $0x0
f01014e0:	e8 8e f9 ff ff       	call   f0100e73 <page_alloc>
f01014e5:	83 c4 10             	add    $0x10,%esp
f01014e8:	85 c0                	test   %eax,%eax
f01014ea:	74 19                	je     f0101505 <mem_init+0x30d>
f01014ec:	68 70 69 10 f0       	push   $0xf0106970
f01014f1:	68 d7 67 10 f0       	push   $0xf01067d7
f01014f6:	68 2c 03 00 00       	push   $0x32c
f01014fb:	68 b1 67 10 f0       	push   $0xf01067b1
f0101500:	e8 3b eb ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101505:	83 ec 0c             	sub    $0xc,%esp
f0101508:	57                   	push   %edi
f0101509:	e8 d5 f9 ff ff       	call   f0100ee3 <page_free>
	page_free(pp1);
f010150e:	89 34 24             	mov    %esi,(%esp)
f0101511:	e8 cd f9 ff ff       	call   f0100ee3 <page_free>
	page_free(pp2);
f0101516:	83 c4 04             	add    $0x4,%esp
f0101519:	ff 75 d4             	pushl  -0x2c(%ebp)
f010151c:	e8 c2 f9 ff ff       	call   f0100ee3 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101521:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101528:	e8 46 f9 ff ff       	call   f0100e73 <page_alloc>
f010152d:	89 c6                	mov    %eax,%esi
f010152f:	83 c4 10             	add    $0x10,%esp
f0101532:	85 c0                	test   %eax,%eax
f0101534:	75 19                	jne    f010154f <mem_init+0x357>
f0101536:	68 c5 68 10 f0       	push   $0xf01068c5
f010153b:	68 d7 67 10 f0       	push   $0xf01067d7
f0101540:	68 33 03 00 00       	push   $0x333
f0101545:	68 b1 67 10 f0       	push   $0xf01067b1
f010154a:	e8 f1 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010154f:	83 ec 0c             	sub    $0xc,%esp
f0101552:	6a 00                	push   $0x0
f0101554:	e8 1a f9 ff ff       	call   f0100e73 <page_alloc>
f0101559:	89 c7                	mov    %eax,%edi
f010155b:	83 c4 10             	add    $0x10,%esp
f010155e:	85 c0                	test   %eax,%eax
f0101560:	75 19                	jne    f010157b <mem_init+0x383>
f0101562:	68 db 68 10 f0       	push   $0xf01068db
f0101567:	68 d7 67 10 f0       	push   $0xf01067d7
f010156c:	68 34 03 00 00       	push   $0x334
f0101571:	68 b1 67 10 f0       	push   $0xf01067b1
f0101576:	e8 c5 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010157b:	83 ec 0c             	sub    $0xc,%esp
f010157e:	6a 00                	push   $0x0
f0101580:	e8 ee f8 ff ff       	call   f0100e73 <page_alloc>
f0101585:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101588:	83 c4 10             	add    $0x10,%esp
f010158b:	85 c0                	test   %eax,%eax
f010158d:	75 19                	jne    f01015a8 <mem_init+0x3b0>
f010158f:	68 f1 68 10 f0       	push   $0xf01068f1
f0101594:	68 d7 67 10 f0       	push   $0xf01067d7
f0101599:	68 35 03 00 00       	push   $0x335
f010159e:	68 b1 67 10 f0       	push   $0xf01067b1
f01015a3:	e8 98 ea ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015a8:	39 fe                	cmp    %edi,%esi
f01015aa:	75 19                	jne    f01015c5 <mem_init+0x3cd>
f01015ac:	68 07 69 10 f0       	push   $0xf0106907
f01015b1:	68 d7 67 10 f0       	push   $0xf01067d7
f01015b6:	68 37 03 00 00       	push   $0x337
f01015bb:	68 b1 67 10 f0       	push   $0xf01067b1
f01015c0:	e8 7b ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015c8:	39 c7                	cmp    %eax,%edi
f01015ca:	74 04                	je     f01015d0 <mem_init+0x3d8>
f01015cc:	39 c6                	cmp    %eax,%esi
f01015ce:	75 19                	jne    f01015e9 <mem_init+0x3f1>
f01015d0:	68 d4 5f 10 f0       	push   $0xf0105fd4
f01015d5:	68 d7 67 10 f0       	push   $0xf01067d7
f01015da:	68 38 03 00 00       	push   $0x338
f01015df:	68 b1 67 10 f0       	push   $0xf01067b1
f01015e4:	e8 57 ea ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01015e9:	83 ec 0c             	sub    $0xc,%esp
f01015ec:	6a 00                	push   $0x0
f01015ee:	e8 80 f8 ff ff       	call   f0100e73 <page_alloc>
f01015f3:	83 c4 10             	add    $0x10,%esp
f01015f6:	85 c0                	test   %eax,%eax
f01015f8:	74 19                	je     f0101613 <mem_init+0x41b>
f01015fa:	68 70 69 10 f0       	push   $0xf0106970
f01015ff:	68 d7 67 10 f0       	push   $0xf01067d7
f0101604:	68 39 03 00 00       	push   $0x339
f0101609:	68 b1 67 10 f0       	push   $0xf01067b1
f010160e:	e8 2d ea ff ff       	call   f0100040 <_panic>
f0101613:	89 f0                	mov    %esi,%eax
f0101615:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f010161b:	c1 f8 03             	sar    $0x3,%eax
f010161e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101621:	89 c2                	mov    %eax,%edx
f0101623:	c1 ea 0c             	shr    $0xc,%edx
f0101626:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f010162c:	72 12                	jb     f0101640 <mem_init+0x448>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010162e:	50                   	push   %eax
f010162f:	68 04 59 10 f0       	push   $0xf0105904
f0101634:	6a 58                	push   $0x58
f0101636:	68 bd 67 10 f0       	push   $0xf01067bd
f010163b:	e8 00 ea ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101640:	83 ec 04             	sub    $0x4,%esp
f0101643:	68 00 10 00 00       	push   $0x1000
f0101648:	6a 01                	push   $0x1
f010164a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010164f:	50                   	push   %eax
f0101650:	e8 d8 35 00 00       	call   f0104c2d <memset>
	page_free(pp0);
f0101655:	89 34 24             	mov    %esi,(%esp)
f0101658:	e8 86 f8 ff ff       	call   f0100ee3 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010165d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101664:	e8 0a f8 ff ff       	call   f0100e73 <page_alloc>
f0101669:	83 c4 10             	add    $0x10,%esp
f010166c:	85 c0                	test   %eax,%eax
f010166e:	75 19                	jne    f0101689 <mem_init+0x491>
f0101670:	68 7f 69 10 f0       	push   $0xf010697f
f0101675:	68 d7 67 10 f0       	push   $0xf01067d7
f010167a:	68 3e 03 00 00       	push   $0x33e
f010167f:	68 b1 67 10 f0       	push   $0xf01067b1
f0101684:	e8 b7 e9 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101689:	39 c6                	cmp    %eax,%esi
f010168b:	74 19                	je     f01016a6 <mem_init+0x4ae>
f010168d:	68 9d 69 10 f0       	push   $0xf010699d
f0101692:	68 d7 67 10 f0       	push   $0xf01067d7
f0101697:	68 3f 03 00 00       	push   $0x33f
f010169c:	68 b1 67 10 f0       	push   $0xf01067b1
f01016a1:	e8 9a e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016a6:	89 f0                	mov    %esi,%eax
f01016a8:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f01016ae:	c1 f8 03             	sar    $0x3,%eax
f01016b1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016b4:	89 c2                	mov    %eax,%edx
f01016b6:	c1 ea 0c             	shr    $0xc,%edx
f01016b9:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f01016bf:	72 12                	jb     f01016d3 <mem_init+0x4db>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016c1:	50                   	push   %eax
f01016c2:	68 04 59 10 f0       	push   $0xf0105904
f01016c7:	6a 58                	push   $0x58
f01016c9:	68 bd 67 10 f0       	push   $0xf01067bd
f01016ce:	e8 6d e9 ff ff       	call   f0100040 <_panic>
f01016d3:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01016d9:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01016df:	80 38 00             	cmpb   $0x0,(%eax)
f01016e2:	74 19                	je     f01016fd <mem_init+0x505>
f01016e4:	68 ad 69 10 f0       	push   $0xf01069ad
f01016e9:	68 d7 67 10 f0       	push   $0xf01067d7
f01016ee:	68 42 03 00 00       	push   $0x342
f01016f3:	68 b1 67 10 f0       	push   $0xf01067b1
f01016f8:	e8 43 e9 ff ff       	call   f0100040 <_panic>
f01016fd:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101700:	39 d0                	cmp    %edx,%eax
f0101702:	75 db                	jne    f01016df <mem_init+0x4e7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101704:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101707:	a3 40 a2 22 f0       	mov    %eax,0xf022a240

	// free the pages we took
	page_free(pp0);
f010170c:	83 ec 0c             	sub    $0xc,%esp
f010170f:	56                   	push   %esi
f0101710:	e8 ce f7 ff ff       	call   f0100ee3 <page_free>
	page_free(pp1);
f0101715:	89 3c 24             	mov    %edi,(%esp)
f0101718:	e8 c6 f7 ff ff       	call   f0100ee3 <page_free>
	page_free(pp2);
f010171d:	83 c4 04             	add    $0x4,%esp
f0101720:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101723:	e8 bb f7 ff ff       	call   f0100ee3 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101728:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f010172d:	83 c4 10             	add    $0x10,%esp
f0101730:	eb 05                	jmp    f0101737 <mem_init+0x53f>
		--nfree;
f0101732:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101735:	8b 00                	mov    (%eax),%eax
f0101737:	85 c0                	test   %eax,%eax
f0101739:	75 f7                	jne    f0101732 <mem_init+0x53a>
		--nfree;
	assert(nfree == 0);
f010173b:	85 db                	test   %ebx,%ebx
f010173d:	74 19                	je     f0101758 <mem_init+0x560>
f010173f:	68 b7 69 10 f0       	push   $0xf01069b7
f0101744:	68 d7 67 10 f0       	push   $0xf01067d7
f0101749:	68 4f 03 00 00       	push   $0x34f
f010174e:	68 b1 67 10 f0       	push   $0xf01067b1
f0101753:	e8 e8 e8 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101758:	83 ec 0c             	sub    $0xc,%esp
f010175b:	68 f4 5f 10 f0       	push   $0xf0105ff4
f0101760:	e8 af 1e 00 00       	call   f0103614 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101765:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010176c:	e8 02 f7 ff ff       	call   f0100e73 <page_alloc>
f0101771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101774:	83 c4 10             	add    $0x10,%esp
f0101777:	85 c0                	test   %eax,%eax
f0101779:	75 19                	jne    f0101794 <mem_init+0x59c>
f010177b:	68 c5 68 10 f0       	push   $0xf01068c5
f0101780:	68 d7 67 10 f0       	push   $0xf01067d7
f0101785:	68 b5 03 00 00       	push   $0x3b5
f010178a:	68 b1 67 10 f0       	push   $0xf01067b1
f010178f:	e8 ac e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101794:	83 ec 0c             	sub    $0xc,%esp
f0101797:	6a 00                	push   $0x0
f0101799:	e8 d5 f6 ff ff       	call   f0100e73 <page_alloc>
f010179e:	89 c3                	mov    %eax,%ebx
f01017a0:	83 c4 10             	add    $0x10,%esp
f01017a3:	85 c0                	test   %eax,%eax
f01017a5:	75 19                	jne    f01017c0 <mem_init+0x5c8>
f01017a7:	68 db 68 10 f0       	push   $0xf01068db
f01017ac:	68 d7 67 10 f0       	push   $0xf01067d7
f01017b1:	68 b6 03 00 00       	push   $0x3b6
f01017b6:	68 b1 67 10 f0       	push   $0xf01067b1
f01017bb:	e8 80 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017c0:	83 ec 0c             	sub    $0xc,%esp
f01017c3:	6a 00                	push   $0x0
f01017c5:	e8 a9 f6 ff ff       	call   f0100e73 <page_alloc>
f01017ca:	89 c6                	mov    %eax,%esi
f01017cc:	83 c4 10             	add    $0x10,%esp
f01017cf:	85 c0                	test   %eax,%eax
f01017d1:	75 19                	jne    f01017ec <mem_init+0x5f4>
f01017d3:	68 f1 68 10 f0       	push   $0xf01068f1
f01017d8:	68 d7 67 10 f0       	push   $0xf01067d7
f01017dd:	68 b7 03 00 00       	push   $0x3b7
f01017e2:	68 b1 67 10 f0       	push   $0xf01067b1
f01017e7:	e8 54 e8 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017ec:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01017ef:	75 19                	jne    f010180a <mem_init+0x612>
f01017f1:	68 07 69 10 f0       	push   $0xf0106907
f01017f6:	68 d7 67 10 f0       	push   $0xf01067d7
f01017fb:	68 ba 03 00 00       	push   $0x3ba
f0101800:	68 b1 67 10 f0       	push   $0xf01067b1
f0101805:	e8 36 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010180a:	39 c3                	cmp    %eax,%ebx
f010180c:	74 05                	je     f0101813 <mem_init+0x61b>
f010180e:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101811:	75 19                	jne    f010182c <mem_init+0x634>
f0101813:	68 d4 5f 10 f0       	push   $0xf0105fd4
f0101818:	68 d7 67 10 f0       	push   $0xf01067d7
f010181d:	68 bb 03 00 00       	push   $0x3bb
f0101822:	68 b1 67 10 f0       	push   $0xf01067b1
f0101827:	e8 14 e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010182c:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f0101831:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101834:	c7 05 40 a2 22 f0 00 	movl   $0x0,0xf022a240
f010183b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010183e:	83 ec 0c             	sub    $0xc,%esp
f0101841:	6a 00                	push   $0x0
f0101843:	e8 2b f6 ff ff       	call   f0100e73 <page_alloc>
f0101848:	83 c4 10             	add    $0x10,%esp
f010184b:	85 c0                	test   %eax,%eax
f010184d:	74 19                	je     f0101868 <mem_init+0x670>
f010184f:	68 70 69 10 f0       	push   $0xf0106970
f0101854:	68 d7 67 10 f0       	push   $0xf01067d7
f0101859:	68 c2 03 00 00       	push   $0x3c2
f010185e:	68 b1 67 10 f0       	push   $0xf01067b1
f0101863:	e8 d8 e7 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101868:	83 ec 04             	sub    $0x4,%esp
f010186b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010186e:	50                   	push   %eax
f010186f:	6a 00                	push   $0x0
f0101871:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101877:	e8 d6 f7 ff ff       	call   f0101052 <page_lookup>
f010187c:	83 c4 10             	add    $0x10,%esp
f010187f:	85 c0                	test   %eax,%eax
f0101881:	74 19                	je     f010189c <mem_init+0x6a4>
f0101883:	68 14 60 10 f0       	push   $0xf0106014
f0101888:	68 d7 67 10 f0       	push   $0xf01067d7
f010188d:	68 c5 03 00 00       	push   $0x3c5
f0101892:	68 b1 67 10 f0       	push   $0xf01067b1
f0101897:	e8 a4 e7 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010189c:	6a 02                	push   $0x2
f010189e:	6a 00                	push   $0x0
f01018a0:	53                   	push   %ebx
f01018a1:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f01018a7:	e8 8f f8 ff ff       	call   f010113b <page_insert>
f01018ac:	83 c4 10             	add    $0x10,%esp
f01018af:	85 c0                	test   %eax,%eax
f01018b1:	78 19                	js     f01018cc <mem_init+0x6d4>
f01018b3:	68 4c 60 10 f0       	push   $0xf010604c
f01018b8:	68 d7 67 10 f0       	push   $0xf01067d7
f01018bd:	68 c8 03 00 00       	push   $0x3c8
f01018c2:	68 b1 67 10 f0       	push   $0xf01067b1
f01018c7:	e8 74 e7 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01018cc:	83 ec 0c             	sub    $0xc,%esp
f01018cf:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018d2:	e8 0c f6 ff ff       	call   f0100ee3 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01018d7:	6a 02                	push   $0x2
f01018d9:	6a 00                	push   $0x0
f01018db:	53                   	push   %ebx
f01018dc:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f01018e2:	e8 54 f8 ff ff       	call   f010113b <page_insert>
f01018e7:	83 c4 20             	add    $0x20,%esp
f01018ea:	85 c0                	test   %eax,%eax
f01018ec:	74 19                	je     f0101907 <mem_init+0x70f>
f01018ee:	68 7c 60 10 f0       	push   $0xf010607c
f01018f3:	68 d7 67 10 f0       	push   $0xf01067d7
f01018f8:	68 cc 03 00 00       	push   $0x3cc
f01018fd:	68 b1 67 10 f0       	push   $0xf01067b1
f0101902:	e8 39 e7 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101907:	8b 3d 0c af 22 f0    	mov    0xf022af0c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010190d:	a1 10 af 22 f0       	mov    0xf022af10,%eax
f0101912:	89 c1                	mov    %eax,%ecx
f0101914:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101917:	8b 17                	mov    (%edi),%edx
f0101919:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010191f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101922:	29 c8                	sub    %ecx,%eax
f0101924:	c1 f8 03             	sar    $0x3,%eax
f0101927:	c1 e0 0c             	shl    $0xc,%eax
f010192a:	39 c2                	cmp    %eax,%edx
f010192c:	74 19                	je     f0101947 <mem_init+0x74f>
f010192e:	68 ac 60 10 f0       	push   $0xf01060ac
f0101933:	68 d7 67 10 f0       	push   $0xf01067d7
f0101938:	68 cd 03 00 00       	push   $0x3cd
f010193d:	68 b1 67 10 f0       	push   $0xf01067b1
f0101942:	e8 f9 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101947:	ba 00 00 00 00       	mov    $0x0,%edx
f010194c:	89 f8                	mov    %edi,%eax
f010194e:	e8 13 f1 ff ff       	call   f0100a66 <check_va2pa>
f0101953:	89 da                	mov    %ebx,%edx
f0101955:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101958:	c1 fa 03             	sar    $0x3,%edx
f010195b:	c1 e2 0c             	shl    $0xc,%edx
f010195e:	39 d0                	cmp    %edx,%eax
f0101960:	74 19                	je     f010197b <mem_init+0x783>
f0101962:	68 d4 60 10 f0       	push   $0xf01060d4
f0101967:	68 d7 67 10 f0       	push   $0xf01067d7
f010196c:	68 ce 03 00 00       	push   $0x3ce
f0101971:	68 b1 67 10 f0       	push   $0xf01067b1
f0101976:	e8 c5 e6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010197b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101980:	74 19                	je     f010199b <mem_init+0x7a3>
f0101982:	68 c2 69 10 f0       	push   $0xf01069c2
f0101987:	68 d7 67 10 f0       	push   $0xf01067d7
f010198c:	68 cf 03 00 00       	push   $0x3cf
f0101991:	68 b1 67 10 f0       	push   $0xf01067b1
f0101996:	e8 a5 e6 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f010199b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010199e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01019a3:	74 19                	je     f01019be <mem_init+0x7c6>
f01019a5:	68 d3 69 10 f0       	push   $0xf01069d3
f01019aa:	68 d7 67 10 f0       	push   $0xf01067d7
f01019af:	68 d0 03 00 00       	push   $0x3d0
f01019b4:	68 b1 67 10 f0       	push   $0xf01067b1
f01019b9:	e8 82 e6 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019be:	6a 02                	push   $0x2
f01019c0:	68 00 10 00 00       	push   $0x1000
f01019c5:	56                   	push   %esi
f01019c6:	57                   	push   %edi
f01019c7:	e8 6f f7 ff ff       	call   f010113b <page_insert>
f01019cc:	83 c4 10             	add    $0x10,%esp
f01019cf:	85 c0                	test   %eax,%eax
f01019d1:	74 19                	je     f01019ec <mem_init+0x7f4>
f01019d3:	68 04 61 10 f0       	push   $0xf0106104
f01019d8:	68 d7 67 10 f0       	push   $0xf01067d7
f01019dd:	68 d3 03 00 00       	push   $0x3d3
f01019e2:	68 b1 67 10 f0       	push   $0xf01067b1
f01019e7:	e8 54 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019ec:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019f1:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f01019f6:	e8 6b f0 ff ff       	call   f0100a66 <check_va2pa>
f01019fb:	89 f2                	mov    %esi,%edx
f01019fd:	2b 15 10 af 22 f0    	sub    0xf022af10,%edx
f0101a03:	c1 fa 03             	sar    $0x3,%edx
f0101a06:	c1 e2 0c             	shl    $0xc,%edx
f0101a09:	39 d0                	cmp    %edx,%eax
f0101a0b:	74 19                	je     f0101a26 <mem_init+0x82e>
f0101a0d:	68 40 61 10 f0       	push   $0xf0106140
f0101a12:	68 d7 67 10 f0       	push   $0xf01067d7
f0101a17:	68 d4 03 00 00       	push   $0x3d4
f0101a1c:	68 b1 67 10 f0       	push   $0xf01067b1
f0101a21:	e8 1a e6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101a26:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a2b:	74 19                	je     f0101a46 <mem_init+0x84e>
f0101a2d:	68 e4 69 10 f0       	push   $0xf01069e4
f0101a32:	68 d7 67 10 f0       	push   $0xf01067d7
f0101a37:	68 d5 03 00 00       	push   $0x3d5
f0101a3c:	68 b1 67 10 f0       	push   $0xf01067b1
f0101a41:	e8 fa e5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101a46:	83 ec 0c             	sub    $0xc,%esp
f0101a49:	6a 00                	push   $0x0
f0101a4b:	e8 23 f4 ff ff       	call   f0100e73 <page_alloc>
f0101a50:	83 c4 10             	add    $0x10,%esp
f0101a53:	85 c0                	test   %eax,%eax
f0101a55:	74 19                	je     f0101a70 <mem_init+0x878>
f0101a57:	68 70 69 10 f0       	push   $0xf0106970
f0101a5c:	68 d7 67 10 f0       	push   $0xf01067d7
f0101a61:	68 d8 03 00 00       	push   $0x3d8
f0101a66:	68 b1 67 10 f0       	push   $0xf01067b1
f0101a6b:	e8 d0 e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a70:	6a 02                	push   $0x2
f0101a72:	68 00 10 00 00       	push   $0x1000
f0101a77:	56                   	push   %esi
f0101a78:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101a7e:	e8 b8 f6 ff ff       	call   f010113b <page_insert>
f0101a83:	83 c4 10             	add    $0x10,%esp
f0101a86:	85 c0                	test   %eax,%eax
f0101a88:	74 19                	je     f0101aa3 <mem_init+0x8ab>
f0101a8a:	68 04 61 10 f0       	push   $0xf0106104
f0101a8f:	68 d7 67 10 f0       	push   $0xf01067d7
f0101a94:	68 db 03 00 00       	push   $0x3db
f0101a99:	68 b1 67 10 f0       	push   $0xf01067b1
f0101a9e:	e8 9d e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aa3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aa8:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f0101aad:	e8 b4 ef ff ff       	call   f0100a66 <check_va2pa>
f0101ab2:	89 f2                	mov    %esi,%edx
f0101ab4:	2b 15 10 af 22 f0    	sub    0xf022af10,%edx
f0101aba:	c1 fa 03             	sar    $0x3,%edx
f0101abd:	c1 e2 0c             	shl    $0xc,%edx
f0101ac0:	39 d0                	cmp    %edx,%eax
f0101ac2:	74 19                	je     f0101add <mem_init+0x8e5>
f0101ac4:	68 40 61 10 f0       	push   $0xf0106140
f0101ac9:	68 d7 67 10 f0       	push   $0xf01067d7
f0101ace:	68 dc 03 00 00       	push   $0x3dc
f0101ad3:	68 b1 67 10 f0       	push   $0xf01067b1
f0101ad8:	e8 63 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101add:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ae2:	74 19                	je     f0101afd <mem_init+0x905>
f0101ae4:	68 e4 69 10 f0       	push   $0xf01069e4
f0101ae9:	68 d7 67 10 f0       	push   $0xf01067d7
f0101aee:	68 dd 03 00 00       	push   $0x3dd
f0101af3:	68 b1 67 10 f0       	push   $0xf01067b1
f0101af8:	e8 43 e5 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101afd:	83 ec 0c             	sub    $0xc,%esp
f0101b00:	6a 00                	push   $0x0
f0101b02:	e8 6c f3 ff ff       	call   f0100e73 <page_alloc>
f0101b07:	83 c4 10             	add    $0x10,%esp
f0101b0a:	85 c0                	test   %eax,%eax
f0101b0c:	74 19                	je     f0101b27 <mem_init+0x92f>
f0101b0e:	68 70 69 10 f0       	push   $0xf0106970
f0101b13:	68 d7 67 10 f0       	push   $0xf01067d7
f0101b18:	68 e1 03 00 00       	push   $0x3e1
f0101b1d:	68 b1 67 10 f0       	push   $0xf01067b1
f0101b22:	e8 19 e5 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101b27:	8b 15 0c af 22 f0    	mov    0xf022af0c,%edx
f0101b2d:	8b 02                	mov    (%edx),%eax
f0101b2f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b34:	89 c1                	mov    %eax,%ecx
f0101b36:	c1 e9 0c             	shr    $0xc,%ecx
f0101b39:	3b 0d 08 af 22 f0    	cmp    0xf022af08,%ecx
f0101b3f:	72 15                	jb     f0101b56 <mem_init+0x95e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b41:	50                   	push   %eax
f0101b42:	68 04 59 10 f0       	push   $0xf0105904
f0101b47:	68 e4 03 00 00       	push   $0x3e4
f0101b4c:	68 b1 67 10 f0       	push   $0xf01067b1
f0101b51:	e8 ea e4 ff ff       	call   f0100040 <_panic>
f0101b56:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b5e:	83 ec 04             	sub    $0x4,%esp
f0101b61:	6a 00                	push   $0x0
f0101b63:	68 00 10 00 00       	push   $0x1000
f0101b68:	52                   	push   %edx
f0101b69:	e8 ee f3 ff ff       	call   f0100f5c <pgdir_walk>
f0101b6e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101b71:	8d 51 04             	lea    0x4(%ecx),%edx
f0101b74:	83 c4 10             	add    $0x10,%esp
f0101b77:	39 d0                	cmp    %edx,%eax
f0101b79:	74 19                	je     f0101b94 <mem_init+0x99c>
f0101b7b:	68 70 61 10 f0       	push   $0xf0106170
f0101b80:	68 d7 67 10 f0       	push   $0xf01067d7
f0101b85:	68 e5 03 00 00       	push   $0x3e5
f0101b8a:	68 b1 67 10 f0       	push   $0xf01067b1
f0101b8f:	e8 ac e4 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b94:	6a 06                	push   $0x6
f0101b96:	68 00 10 00 00       	push   $0x1000
f0101b9b:	56                   	push   %esi
f0101b9c:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101ba2:	e8 94 f5 ff ff       	call   f010113b <page_insert>
f0101ba7:	83 c4 10             	add    $0x10,%esp
f0101baa:	85 c0                	test   %eax,%eax
f0101bac:	74 19                	je     f0101bc7 <mem_init+0x9cf>
f0101bae:	68 b0 61 10 f0       	push   $0xf01061b0
f0101bb3:	68 d7 67 10 f0       	push   $0xf01067d7
f0101bb8:	68 e8 03 00 00       	push   $0x3e8
f0101bbd:	68 b1 67 10 f0       	push   $0xf01067b1
f0101bc2:	e8 79 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bc7:	8b 3d 0c af 22 f0    	mov    0xf022af0c,%edi
f0101bcd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bd2:	89 f8                	mov    %edi,%eax
f0101bd4:	e8 8d ee ff ff       	call   f0100a66 <check_va2pa>
f0101bd9:	89 f2                	mov    %esi,%edx
f0101bdb:	2b 15 10 af 22 f0    	sub    0xf022af10,%edx
f0101be1:	c1 fa 03             	sar    $0x3,%edx
f0101be4:	c1 e2 0c             	shl    $0xc,%edx
f0101be7:	39 d0                	cmp    %edx,%eax
f0101be9:	74 19                	je     f0101c04 <mem_init+0xa0c>
f0101beb:	68 40 61 10 f0       	push   $0xf0106140
f0101bf0:	68 d7 67 10 f0       	push   $0xf01067d7
f0101bf5:	68 e9 03 00 00       	push   $0x3e9
f0101bfa:	68 b1 67 10 f0       	push   $0xf01067b1
f0101bff:	e8 3c e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c04:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c09:	74 19                	je     f0101c24 <mem_init+0xa2c>
f0101c0b:	68 e4 69 10 f0       	push   $0xf01069e4
f0101c10:	68 d7 67 10 f0       	push   $0xf01067d7
f0101c15:	68 ea 03 00 00       	push   $0x3ea
f0101c1a:	68 b1 67 10 f0       	push   $0xf01067b1
f0101c1f:	e8 1c e4 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101c24:	83 ec 04             	sub    $0x4,%esp
f0101c27:	6a 00                	push   $0x0
f0101c29:	68 00 10 00 00       	push   $0x1000
f0101c2e:	57                   	push   %edi
f0101c2f:	e8 28 f3 ff ff       	call   f0100f5c <pgdir_walk>
f0101c34:	83 c4 10             	add    $0x10,%esp
f0101c37:	f6 00 04             	testb  $0x4,(%eax)
f0101c3a:	75 19                	jne    f0101c55 <mem_init+0xa5d>
f0101c3c:	68 f0 61 10 f0       	push   $0xf01061f0
f0101c41:	68 d7 67 10 f0       	push   $0xf01067d7
f0101c46:	68 eb 03 00 00       	push   $0x3eb
f0101c4b:	68 b1 67 10 f0       	push   $0xf01067b1
f0101c50:	e8 eb e3 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101c55:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f0101c5a:	f6 00 04             	testb  $0x4,(%eax)
f0101c5d:	75 19                	jne    f0101c78 <mem_init+0xa80>
f0101c5f:	68 f5 69 10 f0       	push   $0xf01069f5
f0101c64:	68 d7 67 10 f0       	push   $0xf01067d7
f0101c69:	68 ec 03 00 00       	push   $0x3ec
f0101c6e:	68 b1 67 10 f0       	push   $0xf01067b1
f0101c73:	e8 c8 e3 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c78:	6a 02                	push   $0x2
f0101c7a:	68 00 10 00 00       	push   $0x1000
f0101c7f:	56                   	push   %esi
f0101c80:	50                   	push   %eax
f0101c81:	e8 b5 f4 ff ff       	call   f010113b <page_insert>
f0101c86:	83 c4 10             	add    $0x10,%esp
f0101c89:	85 c0                	test   %eax,%eax
f0101c8b:	74 19                	je     f0101ca6 <mem_init+0xaae>
f0101c8d:	68 04 61 10 f0       	push   $0xf0106104
f0101c92:	68 d7 67 10 f0       	push   $0xf01067d7
f0101c97:	68 ef 03 00 00       	push   $0x3ef
f0101c9c:	68 b1 67 10 f0       	push   $0xf01067b1
f0101ca1:	e8 9a e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ca6:	83 ec 04             	sub    $0x4,%esp
f0101ca9:	6a 00                	push   $0x0
f0101cab:	68 00 10 00 00       	push   $0x1000
f0101cb0:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101cb6:	e8 a1 f2 ff ff       	call   f0100f5c <pgdir_walk>
f0101cbb:	83 c4 10             	add    $0x10,%esp
f0101cbe:	f6 00 02             	testb  $0x2,(%eax)
f0101cc1:	75 19                	jne    f0101cdc <mem_init+0xae4>
f0101cc3:	68 24 62 10 f0       	push   $0xf0106224
f0101cc8:	68 d7 67 10 f0       	push   $0xf01067d7
f0101ccd:	68 f0 03 00 00       	push   $0x3f0
f0101cd2:	68 b1 67 10 f0       	push   $0xf01067b1
f0101cd7:	e8 64 e3 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101cdc:	83 ec 04             	sub    $0x4,%esp
f0101cdf:	6a 00                	push   $0x0
f0101ce1:	68 00 10 00 00       	push   $0x1000
f0101ce6:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101cec:	e8 6b f2 ff ff       	call   f0100f5c <pgdir_walk>
f0101cf1:	83 c4 10             	add    $0x10,%esp
f0101cf4:	f6 00 04             	testb  $0x4,(%eax)
f0101cf7:	74 19                	je     f0101d12 <mem_init+0xb1a>
f0101cf9:	68 58 62 10 f0       	push   $0xf0106258
f0101cfe:	68 d7 67 10 f0       	push   $0xf01067d7
f0101d03:	68 f1 03 00 00       	push   $0x3f1
f0101d08:	68 b1 67 10 f0       	push   $0xf01067b1
f0101d0d:	e8 2e e3 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101d12:	6a 02                	push   $0x2
f0101d14:	68 00 00 40 00       	push   $0x400000
f0101d19:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d1c:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101d22:	e8 14 f4 ff ff       	call   f010113b <page_insert>
f0101d27:	83 c4 10             	add    $0x10,%esp
f0101d2a:	85 c0                	test   %eax,%eax
f0101d2c:	78 19                	js     f0101d47 <mem_init+0xb4f>
f0101d2e:	68 90 62 10 f0       	push   $0xf0106290
f0101d33:	68 d7 67 10 f0       	push   $0xf01067d7
f0101d38:	68 f4 03 00 00       	push   $0x3f4
f0101d3d:	68 b1 67 10 f0       	push   $0xf01067b1
f0101d42:	e8 f9 e2 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101d47:	6a 02                	push   $0x2
f0101d49:	68 00 10 00 00       	push   $0x1000
f0101d4e:	53                   	push   %ebx
f0101d4f:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101d55:	e8 e1 f3 ff ff       	call   f010113b <page_insert>
f0101d5a:	83 c4 10             	add    $0x10,%esp
f0101d5d:	85 c0                	test   %eax,%eax
f0101d5f:	74 19                	je     f0101d7a <mem_init+0xb82>
f0101d61:	68 c8 62 10 f0       	push   $0xf01062c8
f0101d66:	68 d7 67 10 f0       	push   $0xf01067d7
f0101d6b:	68 f7 03 00 00       	push   $0x3f7
f0101d70:	68 b1 67 10 f0       	push   $0xf01067b1
f0101d75:	e8 c6 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d7a:	83 ec 04             	sub    $0x4,%esp
f0101d7d:	6a 00                	push   $0x0
f0101d7f:	68 00 10 00 00       	push   $0x1000
f0101d84:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101d8a:	e8 cd f1 ff ff       	call   f0100f5c <pgdir_walk>
f0101d8f:	83 c4 10             	add    $0x10,%esp
f0101d92:	f6 00 04             	testb  $0x4,(%eax)
f0101d95:	74 19                	je     f0101db0 <mem_init+0xbb8>
f0101d97:	68 58 62 10 f0       	push   $0xf0106258
f0101d9c:	68 d7 67 10 f0       	push   $0xf01067d7
f0101da1:	68 f8 03 00 00       	push   $0x3f8
f0101da6:	68 b1 67 10 f0       	push   $0xf01067b1
f0101dab:	e8 90 e2 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101db0:	8b 3d 0c af 22 f0    	mov    0xf022af0c,%edi
f0101db6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dbb:	89 f8                	mov    %edi,%eax
f0101dbd:	e8 a4 ec ff ff       	call   f0100a66 <check_va2pa>
f0101dc2:	89 c1                	mov    %eax,%ecx
f0101dc4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101dc7:	89 d8                	mov    %ebx,%eax
f0101dc9:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0101dcf:	c1 f8 03             	sar    $0x3,%eax
f0101dd2:	c1 e0 0c             	shl    $0xc,%eax
f0101dd5:	39 c1                	cmp    %eax,%ecx
f0101dd7:	74 19                	je     f0101df2 <mem_init+0xbfa>
f0101dd9:	68 04 63 10 f0       	push   $0xf0106304
f0101dde:	68 d7 67 10 f0       	push   $0xf01067d7
f0101de3:	68 fb 03 00 00       	push   $0x3fb
f0101de8:	68 b1 67 10 f0       	push   $0xf01067b1
f0101ded:	e8 4e e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101df2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101df7:	89 f8                	mov    %edi,%eax
f0101df9:	e8 68 ec ff ff       	call   f0100a66 <check_va2pa>
f0101dfe:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101e01:	74 19                	je     f0101e1c <mem_init+0xc24>
f0101e03:	68 30 63 10 f0       	push   $0xf0106330
f0101e08:	68 d7 67 10 f0       	push   $0xf01067d7
f0101e0d:	68 fc 03 00 00       	push   $0x3fc
f0101e12:	68 b1 67 10 f0       	push   $0xf01067b1
f0101e17:	e8 24 e2 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e1c:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101e21:	74 19                	je     f0101e3c <mem_init+0xc44>
f0101e23:	68 0b 6a 10 f0       	push   $0xf0106a0b
f0101e28:	68 d7 67 10 f0       	push   $0xf01067d7
f0101e2d:	68 fe 03 00 00       	push   $0x3fe
f0101e32:	68 b1 67 10 f0       	push   $0xf01067b1
f0101e37:	e8 04 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101e3c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e41:	74 19                	je     f0101e5c <mem_init+0xc64>
f0101e43:	68 1c 6a 10 f0       	push   $0xf0106a1c
f0101e48:	68 d7 67 10 f0       	push   $0xf01067d7
f0101e4d:	68 ff 03 00 00       	push   $0x3ff
f0101e52:	68 b1 67 10 f0       	push   $0xf01067b1
f0101e57:	e8 e4 e1 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e5c:	83 ec 0c             	sub    $0xc,%esp
f0101e5f:	6a 00                	push   $0x0
f0101e61:	e8 0d f0 ff ff       	call   f0100e73 <page_alloc>
f0101e66:	83 c4 10             	add    $0x10,%esp
f0101e69:	85 c0                	test   %eax,%eax
f0101e6b:	74 04                	je     f0101e71 <mem_init+0xc79>
f0101e6d:	39 c6                	cmp    %eax,%esi
f0101e6f:	74 19                	je     f0101e8a <mem_init+0xc92>
f0101e71:	68 60 63 10 f0       	push   $0xf0106360
f0101e76:	68 d7 67 10 f0       	push   $0xf01067d7
f0101e7b:	68 02 04 00 00       	push   $0x402
f0101e80:	68 b1 67 10 f0       	push   $0xf01067b1
f0101e85:	e8 b6 e1 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e8a:	83 ec 08             	sub    $0x8,%esp
f0101e8d:	6a 00                	push   $0x0
f0101e8f:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101e95:	e8 53 f2 ff ff       	call   f01010ed <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e9a:	8b 3d 0c af 22 f0    	mov    0xf022af0c,%edi
f0101ea0:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ea5:	89 f8                	mov    %edi,%eax
f0101ea7:	e8 ba eb ff ff       	call   f0100a66 <check_va2pa>
f0101eac:	83 c4 10             	add    $0x10,%esp
f0101eaf:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101eb2:	74 19                	je     f0101ecd <mem_init+0xcd5>
f0101eb4:	68 84 63 10 f0       	push   $0xf0106384
f0101eb9:	68 d7 67 10 f0       	push   $0xf01067d7
f0101ebe:	68 06 04 00 00       	push   $0x406
f0101ec3:	68 b1 67 10 f0       	push   $0xf01067b1
f0101ec8:	e8 73 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ecd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ed2:	89 f8                	mov    %edi,%eax
f0101ed4:	e8 8d eb ff ff       	call   f0100a66 <check_va2pa>
f0101ed9:	89 da                	mov    %ebx,%edx
f0101edb:	2b 15 10 af 22 f0    	sub    0xf022af10,%edx
f0101ee1:	c1 fa 03             	sar    $0x3,%edx
f0101ee4:	c1 e2 0c             	shl    $0xc,%edx
f0101ee7:	39 d0                	cmp    %edx,%eax
f0101ee9:	74 19                	je     f0101f04 <mem_init+0xd0c>
f0101eeb:	68 30 63 10 f0       	push   $0xf0106330
f0101ef0:	68 d7 67 10 f0       	push   $0xf01067d7
f0101ef5:	68 07 04 00 00       	push   $0x407
f0101efa:	68 b1 67 10 f0       	push   $0xf01067b1
f0101eff:	e8 3c e1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101f04:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f09:	74 19                	je     f0101f24 <mem_init+0xd2c>
f0101f0b:	68 c2 69 10 f0       	push   $0xf01069c2
f0101f10:	68 d7 67 10 f0       	push   $0xf01067d7
f0101f15:	68 08 04 00 00       	push   $0x408
f0101f1a:	68 b1 67 10 f0       	push   $0xf01067b1
f0101f1f:	e8 1c e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101f24:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f29:	74 19                	je     f0101f44 <mem_init+0xd4c>
f0101f2b:	68 1c 6a 10 f0       	push   $0xf0106a1c
f0101f30:	68 d7 67 10 f0       	push   $0xf01067d7
f0101f35:	68 09 04 00 00       	push   $0x409
f0101f3a:	68 b1 67 10 f0       	push   $0xf01067b1
f0101f3f:	e8 fc e0 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f44:	6a 00                	push   $0x0
f0101f46:	68 00 10 00 00       	push   $0x1000
f0101f4b:	53                   	push   %ebx
f0101f4c:	57                   	push   %edi
f0101f4d:	e8 e9 f1 ff ff       	call   f010113b <page_insert>
f0101f52:	83 c4 10             	add    $0x10,%esp
f0101f55:	85 c0                	test   %eax,%eax
f0101f57:	74 19                	je     f0101f72 <mem_init+0xd7a>
f0101f59:	68 a8 63 10 f0       	push   $0xf01063a8
f0101f5e:	68 d7 67 10 f0       	push   $0xf01067d7
f0101f63:	68 0c 04 00 00       	push   $0x40c
f0101f68:	68 b1 67 10 f0       	push   $0xf01067b1
f0101f6d:	e8 ce e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0101f72:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f77:	75 19                	jne    f0101f92 <mem_init+0xd9a>
f0101f79:	68 2d 6a 10 f0       	push   $0xf0106a2d
f0101f7e:	68 d7 67 10 f0       	push   $0xf01067d7
f0101f83:	68 0d 04 00 00       	push   $0x40d
f0101f88:	68 b1 67 10 f0       	push   $0xf01067b1
f0101f8d:	e8 ae e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0101f92:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101f95:	74 19                	je     f0101fb0 <mem_init+0xdb8>
f0101f97:	68 39 6a 10 f0       	push   $0xf0106a39
f0101f9c:	68 d7 67 10 f0       	push   $0xf01067d7
f0101fa1:	68 0e 04 00 00       	push   $0x40e
f0101fa6:	68 b1 67 10 f0       	push   $0xf01067b1
f0101fab:	e8 90 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101fb0:	83 ec 08             	sub    $0x8,%esp
f0101fb3:	68 00 10 00 00       	push   $0x1000
f0101fb8:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101fbe:	e8 2a f1 ff ff       	call   f01010ed <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101fc3:	8b 3d 0c af 22 f0    	mov    0xf022af0c,%edi
f0101fc9:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fce:	89 f8                	mov    %edi,%eax
f0101fd0:	e8 91 ea ff ff       	call   f0100a66 <check_va2pa>
f0101fd5:	83 c4 10             	add    $0x10,%esp
f0101fd8:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fdb:	74 19                	je     f0101ff6 <mem_init+0xdfe>
f0101fdd:	68 84 63 10 f0       	push   $0xf0106384
f0101fe2:	68 d7 67 10 f0       	push   $0xf01067d7
f0101fe7:	68 12 04 00 00       	push   $0x412
f0101fec:	68 b1 67 10 f0       	push   $0xf01067b1
f0101ff1:	e8 4a e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101ff6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ffb:	89 f8                	mov    %edi,%eax
f0101ffd:	e8 64 ea ff ff       	call   f0100a66 <check_va2pa>
f0102002:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102005:	74 19                	je     f0102020 <mem_init+0xe28>
f0102007:	68 e0 63 10 f0       	push   $0xf01063e0
f010200c:	68 d7 67 10 f0       	push   $0xf01067d7
f0102011:	68 13 04 00 00       	push   $0x413
f0102016:	68 b1 67 10 f0       	push   $0xf01067b1
f010201b:	e8 20 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102020:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102025:	74 19                	je     f0102040 <mem_init+0xe48>
f0102027:	68 4e 6a 10 f0       	push   $0xf0106a4e
f010202c:	68 d7 67 10 f0       	push   $0xf01067d7
f0102031:	68 14 04 00 00       	push   $0x414
f0102036:	68 b1 67 10 f0       	push   $0xf01067b1
f010203b:	e8 00 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102040:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102045:	74 19                	je     f0102060 <mem_init+0xe68>
f0102047:	68 1c 6a 10 f0       	push   $0xf0106a1c
f010204c:	68 d7 67 10 f0       	push   $0xf01067d7
f0102051:	68 15 04 00 00       	push   $0x415
f0102056:	68 b1 67 10 f0       	push   $0xf01067b1
f010205b:	e8 e0 df ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102060:	83 ec 0c             	sub    $0xc,%esp
f0102063:	6a 00                	push   $0x0
f0102065:	e8 09 ee ff ff       	call   f0100e73 <page_alloc>
f010206a:	83 c4 10             	add    $0x10,%esp
f010206d:	39 c3                	cmp    %eax,%ebx
f010206f:	75 04                	jne    f0102075 <mem_init+0xe7d>
f0102071:	85 c0                	test   %eax,%eax
f0102073:	75 19                	jne    f010208e <mem_init+0xe96>
f0102075:	68 08 64 10 f0       	push   $0xf0106408
f010207a:	68 d7 67 10 f0       	push   $0xf01067d7
f010207f:	68 18 04 00 00       	push   $0x418
f0102084:	68 b1 67 10 f0       	push   $0xf01067b1
f0102089:	e8 b2 df ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010208e:	83 ec 0c             	sub    $0xc,%esp
f0102091:	6a 00                	push   $0x0
f0102093:	e8 db ed ff ff       	call   f0100e73 <page_alloc>
f0102098:	83 c4 10             	add    $0x10,%esp
f010209b:	85 c0                	test   %eax,%eax
f010209d:	74 19                	je     f01020b8 <mem_init+0xec0>
f010209f:	68 70 69 10 f0       	push   $0xf0106970
f01020a4:	68 d7 67 10 f0       	push   $0xf01067d7
f01020a9:	68 1b 04 00 00       	push   $0x41b
f01020ae:	68 b1 67 10 f0       	push   $0xf01067b1
f01020b3:	e8 88 df ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01020b8:	8b 0d 0c af 22 f0    	mov    0xf022af0c,%ecx
f01020be:	8b 11                	mov    (%ecx),%edx
f01020c0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01020c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020c9:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f01020cf:	c1 f8 03             	sar    $0x3,%eax
f01020d2:	c1 e0 0c             	shl    $0xc,%eax
f01020d5:	39 c2                	cmp    %eax,%edx
f01020d7:	74 19                	je     f01020f2 <mem_init+0xefa>
f01020d9:	68 ac 60 10 f0       	push   $0xf01060ac
f01020de:	68 d7 67 10 f0       	push   $0xf01067d7
f01020e3:	68 1e 04 00 00       	push   $0x41e
f01020e8:	68 b1 67 10 f0       	push   $0xf01067b1
f01020ed:	e8 4e df ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01020f2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01020f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020fb:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102100:	74 19                	je     f010211b <mem_init+0xf23>
f0102102:	68 d3 69 10 f0       	push   $0xf01069d3
f0102107:	68 d7 67 10 f0       	push   $0xf01067d7
f010210c:	68 20 04 00 00       	push   $0x420
f0102111:	68 b1 67 10 f0       	push   $0xf01067b1
f0102116:	e8 25 df ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010211b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010211e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102124:	83 ec 0c             	sub    $0xc,%esp
f0102127:	50                   	push   %eax
f0102128:	e8 b6 ed ff ff       	call   f0100ee3 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010212d:	83 c4 0c             	add    $0xc,%esp
f0102130:	6a 01                	push   $0x1
f0102132:	68 00 10 40 00       	push   $0x401000
f0102137:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f010213d:	e8 1a ee ff ff       	call   f0100f5c <pgdir_walk>
f0102142:	89 c7                	mov    %eax,%edi
f0102144:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102147:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f010214c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010214f:	8b 40 04             	mov    0x4(%eax),%eax
f0102152:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102157:	8b 0d 08 af 22 f0    	mov    0xf022af08,%ecx
f010215d:	89 c2                	mov    %eax,%edx
f010215f:	c1 ea 0c             	shr    $0xc,%edx
f0102162:	83 c4 10             	add    $0x10,%esp
f0102165:	39 ca                	cmp    %ecx,%edx
f0102167:	72 15                	jb     f010217e <mem_init+0xf86>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102169:	50                   	push   %eax
f010216a:	68 04 59 10 f0       	push   $0xf0105904
f010216f:	68 27 04 00 00       	push   $0x427
f0102174:	68 b1 67 10 f0       	push   $0xf01067b1
f0102179:	e8 c2 de ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010217e:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102183:	39 c7                	cmp    %eax,%edi
f0102185:	74 19                	je     f01021a0 <mem_init+0xfa8>
f0102187:	68 5f 6a 10 f0       	push   $0xf0106a5f
f010218c:	68 d7 67 10 f0       	push   $0xf01067d7
f0102191:	68 28 04 00 00       	push   $0x428
f0102196:	68 b1 67 10 f0       	push   $0xf01067b1
f010219b:	e8 a0 de ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01021a0:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01021a3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01021aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021ad:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01021b3:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f01021b9:	c1 f8 03             	sar    $0x3,%eax
f01021bc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021bf:	89 c2                	mov    %eax,%edx
f01021c1:	c1 ea 0c             	shr    $0xc,%edx
f01021c4:	39 d1                	cmp    %edx,%ecx
f01021c6:	77 12                	ja     f01021da <mem_init+0xfe2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021c8:	50                   	push   %eax
f01021c9:	68 04 59 10 f0       	push   $0xf0105904
f01021ce:	6a 58                	push   $0x58
f01021d0:	68 bd 67 10 f0       	push   $0xf01067bd
f01021d5:	e8 66 de ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01021da:	83 ec 04             	sub    $0x4,%esp
f01021dd:	68 00 10 00 00       	push   $0x1000
f01021e2:	68 ff 00 00 00       	push   $0xff
f01021e7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01021ec:	50                   	push   %eax
f01021ed:	e8 3b 2a 00 00       	call   f0104c2d <memset>
	page_free(pp0);
f01021f2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01021f5:	89 3c 24             	mov    %edi,(%esp)
f01021f8:	e8 e6 ec ff ff       	call   f0100ee3 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01021fd:	83 c4 0c             	add    $0xc,%esp
f0102200:	6a 01                	push   $0x1
f0102202:	6a 00                	push   $0x0
f0102204:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f010220a:	e8 4d ed ff ff       	call   f0100f5c <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010220f:	89 fa                	mov    %edi,%edx
f0102211:	2b 15 10 af 22 f0    	sub    0xf022af10,%edx
f0102217:	c1 fa 03             	sar    $0x3,%edx
f010221a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010221d:	89 d0                	mov    %edx,%eax
f010221f:	c1 e8 0c             	shr    $0xc,%eax
f0102222:	83 c4 10             	add    $0x10,%esp
f0102225:	3b 05 08 af 22 f0    	cmp    0xf022af08,%eax
f010222b:	72 12                	jb     f010223f <mem_init+0x1047>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010222d:	52                   	push   %edx
f010222e:	68 04 59 10 f0       	push   $0xf0105904
f0102233:	6a 58                	push   $0x58
f0102235:	68 bd 67 10 f0       	push   $0xf01067bd
f010223a:	e8 01 de ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010223f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102245:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102248:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010224e:	f6 00 01             	testb  $0x1,(%eax)
f0102251:	74 19                	je     f010226c <mem_init+0x1074>
f0102253:	68 77 6a 10 f0       	push   $0xf0106a77
f0102258:	68 d7 67 10 f0       	push   $0xf01067d7
f010225d:	68 32 04 00 00       	push   $0x432
f0102262:	68 b1 67 10 f0       	push   $0xf01067b1
f0102267:	e8 d4 dd ff ff       	call   f0100040 <_panic>
f010226c:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010226f:	39 d0                	cmp    %edx,%eax
f0102271:	75 db                	jne    f010224e <mem_init+0x1056>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102273:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f0102278:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010227e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102281:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102287:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010228a:	89 0d 40 a2 22 f0    	mov    %ecx,0xf022a240

	// free the pages we took
	page_free(pp0);
f0102290:	83 ec 0c             	sub    $0xc,%esp
f0102293:	50                   	push   %eax
f0102294:	e8 4a ec ff ff       	call   f0100ee3 <page_free>
	page_free(pp1);
f0102299:	89 1c 24             	mov    %ebx,(%esp)
f010229c:	e8 42 ec ff ff       	call   f0100ee3 <page_free>
	page_free(pp2);
f01022a1:	89 34 24             	mov    %esi,(%esp)
f01022a4:	e8 3a ec ff ff       	call   f0100ee3 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01022a9:	83 c4 08             	add    $0x8,%esp
f01022ac:	68 01 10 00 00       	push   $0x1001
f01022b1:	6a 00                	push   $0x0
f01022b3:	e8 e9 ee ff ff       	call   f01011a1 <mmio_map_region>
f01022b8:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01022ba:	83 c4 08             	add    $0x8,%esp
f01022bd:	68 00 10 00 00       	push   $0x1000
f01022c2:	6a 00                	push   $0x0
f01022c4:	e8 d8 ee ff ff       	call   f01011a1 <mmio_map_region>
f01022c9:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01022cb:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01022d1:	83 c4 10             	add    $0x10,%esp
f01022d4:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01022da:	76 07                	jbe    f01022e3 <mem_init+0x10eb>
f01022dc:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01022e1:	76 19                	jbe    f01022fc <mem_init+0x1104>
f01022e3:	68 2c 64 10 f0       	push   $0xf010642c
f01022e8:	68 d7 67 10 f0       	push   $0xf01067d7
f01022ed:	68 42 04 00 00       	push   $0x442
f01022f2:	68 b1 67 10 f0       	push   $0xf01067b1
f01022f7:	e8 44 dd ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01022fc:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102302:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102308:	77 08                	ja     f0102312 <mem_init+0x111a>
f010230a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102310:	77 19                	ja     f010232b <mem_init+0x1133>
f0102312:	68 54 64 10 f0       	push   $0xf0106454
f0102317:	68 d7 67 10 f0       	push   $0xf01067d7
f010231c:	68 43 04 00 00       	push   $0x443
f0102321:	68 b1 67 10 f0       	push   $0xf01067b1
f0102326:	e8 15 dd ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010232b:	89 da                	mov    %ebx,%edx
f010232d:	09 f2                	or     %esi,%edx
f010232f:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102335:	74 19                	je     f0102350 <mem_init+0x1158>
f0102337:	68 7c 64 10 f0       	push   $0xf010647c
f010233c:	68 d7 67 10 f0       	push   $0xf01067d7
f0102341:	68 45 04 00 00       	push   $0x445
f0102346:	68 b1 67 10 f0       	push   $0xf01067b1
f010234b:	e8 f0 dc ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102350:	39 c6                	cmp    %eax,%esi
f0102352:	73 19                	jae    f010236d <mem_init+0x1175>
f0102354:	68 8e 6a 10 f0       	push   $0xf0106a8e
f0102359:	68 d7 67 10 f0       	push   $0xf01067d7
f010235e:	68 47 04 00 00       	push   $0x447
f0102363:	68 b1 67 10 f0       	push   $0xf01067b1
f0102368:	e8 d3 dc ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010236d:	8b 3d 0c af 22 f0    	mov    0xf022af0c,%edi
f0102373:	89 da                	mov    %ebx,%edx
f0102375:	89 f8                	mov    %edi,%eax
f0102377:	e8 ea e6 ff ff       	call   f0100a66 <check_va2pa>
f010237c:	85 c0                	test   %eax,%eax
f010237e:	74 19                	je     f0102399 <mem_init+0x11a1>
f0102380:	68 a4 64 10 f0       	push   $0xf01064a4
f0102385:	68 d7 67 10 f0       	push   $0xf01067d7
f010238a:	68 49 04 00 00       	push   $0x449
f010238f:	68 b1 67 10 f0       	push   $0xf01067b1
f0102394:	e8 a7 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102399:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010239f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01023a2:	89 c2                	mov    %eax,%edx
f01023a4:	89 f8                	mov    %edi,%eax
f01023a6:	e8 bb e6 ff ff       	call   f0100a66 <check_va2pa>
f01023ab:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01023b0:	74 19                	je     f01023cb <mem_init+0x11d3>
f01023b2:	68 c8 64 10 f0       	push   $0xf01064c8
f01023b7:	68 d7 67 10 f0       	push   $0xf01067d7
f01023bc:	68 4a 04 00 00       	push   $0x44a
f01023c1:	68 b1 67 10 f0       	push   $0xf01067b1
f01023c6:	e8 75 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01023cb:	89 f2                	mov    %esi,%edx
f01023cd:	89 f8                	mov    %edi,%eax
f01023cf:	e8 92 e6 ff ff       	call   f0100a66 <check_va2pa>
f01023d4:	85 c0                	test   %eax,%eax
f01023d6:	74 19                	je     f01023f1 <mem_init+0x11f9>
f01023d8:	68 f8 64 10 f0       	push   $0xf01064f8
f01023dd:	68 d7 67 10 f0       	push   $0xf01067d7
f01023e2:	68 4b 04 00 00       	push   $0x44b
f01023e7:	68 b1 67 10 f0       	push   $0xf01067b1
f01023ec:	e8 4f dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01023f1:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01023f7:	89 f8                	mov    %edi,%eax
f01023f9:	e8 68 e6 ff ff       	call   f0100a66 <check_va2pa>
f01023fe:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102401:	74 19                	je     f010241c <mem_init+0x1224>
f0102403:	68 1c 65 10 f0       	push   $0xf010651c
f0102408:	68 d7 67 10 f0       	push   $0xf01067d7
f010240d:	68 4c 04 00 00       	push   $0x44c
f0102412:	68 b1 67 10 f0       	push   $0xf01067b1
f0102417:	e8 24 dc ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010241c:	83 ec 04             	sub    $0x4,%esp
f010241f:	6a 00                	push   $0x0
f0102421:	53                   	push   %ebx
f0102422:	57                   	push   %edi
f0102423:	e8 34 eb ff ff       	call   f0100f5c <pgdir_walk>
f0102428:	83 c4 10             	add    $0x10,%esp
f010242b:	f6 00 1a             	testb  $0x1a,(%eax)
f010242e:	75 19                	jne    f0102449 <mem_init+0x1251>
f0102430:	68 48 65 10 f0       	push   $0xf0106548
f0102435:	68 d7 67 10 f0       	push   $0xf01067d7
f010243a:	68 4e 04 00 00       	push   $0x44e
f010243f:	68 b1 67 10 f0       	push   $0xf01067b1
f0102444:	e8 f7 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102449:	83 ec 04             	sub    $0x4,%esp
f010244c:	6a 00                	push   $0x0
f010244e:	53                   	push   %ebx
f010244f:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0102455:	e8 02 eb ff ff       	call   f0100f5c <pgdir_walk>
f010245a:	8b 00                	mov    (%eax),%eax
f010245c:	83 c4 10             	add    $0x10,%esp
f010245f:	83 e0 04             	and    $0x4,%eax
f0102462:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102465:	74 19                	je     f0102480 <mem_init+0x1288>
f0102467:	68 8c 65 10 f0       	push   $0xf010658c
f010246c:	68 d7 67 10 f0       	push   $0xf01067d7
f0102471:	68 4f 04 00 00       	push   $0x44f
f0102476:	68 b1 67 10 f0       	push   $0xf01067b1
f010247b:	e8 c0 db ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102480:	83 ec 04             	sub    $0x4,%esp
f0102483:	6a 00                	push   $0x0
f0102485:	53                   	push   %ebx
f0102486:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f010248c:	e8 cb ea ff ff       	call   f0100f5c <pgdir_walk>
f0102491:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102497:	83 c4 0c             	add    $0xc,%esp
f010249a:	6a 00                	push   $0x0
f010249c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010249f:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f01024a5:	e8 b2 ea ff ff       	call   f0100f5c <pgdir_walk>
f01024aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01024b0:	83 c4 0c             	add    $0xc,%esp
f01024b3:	6a 00                	push   $0x0
f01024b5:	56                   	push   %esi
f01024b6:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f01024bc:	e8 9b ea ff ff       	call   f0100f5c <pgdir_walk>
f01024c1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01024c7:	c7 04 24 a0 6a 10 f0 	movl   $0xf0106aa0,(%esp)
f01024ce:	e8 41 11 00 00       	call   f0103614 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f01024d3:	a1 10 af 22 f0       	mov    0xf022af10,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01024d8:	83 c4 10             	add    $0x10,%esp
f01024db:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01024e0:	77 15                	ja     f01024f7 <mem_init+0x12ff>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01024e2:	50                   	push   %eax
f01024e3:	68 28 59 10 f0       	push   $0xf0105928
f01024e8:	68 c4 00 00 00       	push   $0xc4
f01024ed:	68 b1 67 10 f0       	push   $0xf01067b1
f01024f2:	e8 49 db ff ff       	call   f0100040 <_panic>
f01024f7:	83 ec 08             	sub    $0x8,%esp
f01024fa:	6a 04                	push   $0x4
f01024fc:	05 00 00 00 10       	add    $0x10000000,%eax
f0102501:	50                   	push   %eax
f0102502:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102507:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010250c:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f0102511:	e8 d9 ea ff ff       	call   f0100fef <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UTOP, PTSIZE, PADDR(envs), PTE_U);
f0102516:	a1 48 a2 22 f0       	mov    0xf022a248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010251b:	83 c4 10             	add    $0x10,%esp
f010251e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102523:	77 15                	ja     f010253a <mem_init+0x1342>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102525:	50                   	push   %eax
f0102526:	68 28 59 10 f0       	push   $0xf0105928
f010252b:	68 cd 00 00 00       	push   $0xcd
f0102530:	68 b1 67 10 f0       	push   $0xf01067b1
f0102535:	e8 06 db ff ff       	call   f0100040 <_panic>
f010253a:	83 ec 08             	sub    $0x8,%esp
f010253d:	6a 04                	push   $0x4
f010253f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102544:	50                   	push   %eax
f0102545:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010254a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010254f:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f0102554:	e8 96 ea ff ff       	call   f0100fef <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102559:	83 c4 10             	add    $0x10,%esp
f010255c:	b8 00 50 11 f0       	mov    $0xf0115000,%eax
f0102561:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102566:	77 15                	ja     f010257d <mem_init+0x1385>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102568:	50                   	push   %eax
f0102569:	68 28 59 10 f0       	push   $0xf0105928
f010256e:	68 e2 00 00 00       	push   $0xe2
f0102573:	68 b1 67 10 f0       	push   $0xf01067b1
f0102578:	e8 c3 da ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f010257d:	83 ec 08             	sub    $0x8,%esp
f0102580:	6a 02                	push   $0x2
f0102582:	68 00 50 11 00       	push   $0x115000
f0102587:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010258c:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102591:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f0102596:	e8 54 ea ff ff       	call   f0100fef <boot_map_region>


	// Initialize the SMP-related parts of the memory map
	mem_init_mp();

	boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f010259b:	83 c4 08             	add    $0x8,%esp
f010259e:	6a 02                	push   $0x2
f01025a0:	6a 00                	push   $0x0
f01025a2:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01025a7:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01025ac:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f01025b1:	e8 39 ea ff ff       	call   f0100fef <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01025b6:	8b 3d 0c af 22 f0    	mov    0xf022af0c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01025bc:	a1 08 af 22 f0       	mov    0xf022af08,%eax
f01025c1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01025c4:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01025cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01025d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01025d3:	8b 35 10 af 22 f0    	mov    0xf022af10,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025d9:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01025dc:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01025df:	bb 00 00 00 00       	mov    $0x0,%ebx
f01025e4:	eb 55                	jmp    f010263b <mem_init+0x1443>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01025e6:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01025ec:	89 f8                	mov    %edi,%eax
f01025ee:	e8 73 e4 ff ff       	call   f0100a66 <check_va2pa>
f01025f3:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01025fa:	77 15                	ja     f0102611 <mem_init+0x1419>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025fc:	56                   	push   %esi
f01025fd:	68 28 59 10 f0       	push   $0xf0105928
f0102602:	68 67 03 00 00       	push   $0x367
f0102607:	68 b1 67 10 f0       	push   $0xf01067b1
f010260c:	e8 2f da ff ff       	call   f0100040 <_panic>
f0102611:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102618:	39 d0                	cmp    %edx,%eax
f010261a:	74 19                	je     f0102635 <mem_init+0x143d>
f010261c:	68 c0 65 10 f0       	push   $0xf01065c0
f0102621:	68 d7 67 10 f0       	push   $0xf01067d7
f0102626:	68 67 03 00 00       	push   $0x367
f010262b:	68 b1 67 10 f0       	push   $0xf01067b1
f0102630:	e8 0b da ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102635:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010263b:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010263e:	77 a6                	ja     f01025e6 <mem_init+0x13ee>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102640:	8b 35 48 a2 22 f0    	mov    0xf022a248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102646:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102649:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f010264e:	89 da                	mov    %ebx,%edx
f0102650:	89 f8                	mov    %edi,%eax
f0102652:	e8 0f e4 ff ff       	call   f0100a66 <check_va2pa>
f0102657:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f010265e:	77 15                	ja     f0102675 <mem_init+0x147d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102660:	56                   	push   %esi
f0102661:	68 28 59 10 f0       	push   $0xf0105928
f0102666:	68 6c 03 00 00       	push   $0x36c
f010266b:	68 b1 67 10 f0       	push   $0xf01067b1
f0102670:	e8 cb d9 ff ff       	call   f0100040 <_panic>
f0102675:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f010267c:	39 d0                	cmp    %edx,%eax
f010267e:	74 19                	je     f0102699 <mem_init+0x14a1>
f0102680:	68 f4 65 10 f0       	push   $0xf01065f4
f0102685:	68 d7 67 10 f0       	push   $0xf01067d7
f010268a:	68 6c 03 00 00       	push   $0x36c
f010268f:	68 b1 67 10 f0       	push   $0xf01067b1
f0102694:	e8 a7 d9 ff ff       	call   f0100040 <_panic>
f0102699:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010269f:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01026a5:	75 a7                	jne    f010264e <mem_init+0x1456>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01026a7:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01026aa:	c1 e6 0c             	shl    $0xc,%esi
f01026ad:	bb 00 00 00 00       	mov    $0x0,%ebx
f01026b2:	eb 30                	jmp    f01026e4 <mem_init+0x14ec>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01026b4:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01026ba:	89 f8                	mov    %edi,%eax
f01026bc:	e8 a5 e3 ff ff       	call   f0100a66 <check_va2pa>
f01026c1:	39 c3                	cmp    %eax,%ebx
f01026c3:	74 19                	je     f01026de <mem_init+0x14e6>
f01026c5:	68 28 66 10 f0       	push   $0xf0106628
f01026ca:	68 d7 67 10 f0       	push   $0xf01067d7
f01026cf:	68 70 03 00 00       	push   $0x370
f01026d4:	68 b1 67 10 f0       	push   $0xf01067b1
f01026d9:	e8 62 d9 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01026de:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01026e4:	39 f3                	cmp    %esi,%ebx
f01026e6:	72 cc                	jb     f01026b4 <mem_init+0x14bc>
f01026e8:	be 00 c0 22 f0       	mov    $0xf022c000,%esi
f01026ed:	c7 45 cc 00 80 ff ef 	movl   $0xefff8000,-0x34(%ebp)
f01026f4:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01026f7:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f01026fd:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102700:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102702:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102705:	05 00 80 00 20       	add    $0x20008000,%eax
f010270a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010270d:	89 da                	mov    %ebx,%edx
f010270f:	89 f8                	mov    %edi,%eax
f0102711:	e8 50 e3 ff ff       	call   f0100a66 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102716:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010271c:	77 15                	ja     f0102733 <mem_init+0x153b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010271e:	56                   	push   %esi
f010271f:	68 28 59 10 f0       	push   $0xf0105928
f0102724:	68 78 03 00 00       	push   $0x378
f0102729:	68 b1 67 10 f0       	push   $0xf01067b1
f010272e:	e8 0d d9 ff ff       	call   f0100040 <_panic>
f0102733:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102736:	8d 94 0b 00 c0 22 f0 	lea    -0xfdd4000(%ebx,%ecx,1),%edx
f010273d:	39 d0                	cmp    %edx,%eax
f010273f:	74 19                	je     f010275a <mem_init+0x1562>
f0102741:	68 50 66 10 f0       	push   $0xf0106650
f0102746:	68 d7 67 10 f0       	push   $0xf01067d7
f010274b:	68 78 03 00 00       	push   $0x378
f0102750:	68 b1 67 10 f0       	push   $0xf01067b1
f0102755:	e8 e6 d8 ff ff       	call   f0100040 <_panic>
f010275a:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102760:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102763:	75 a8                	jne    f010270d <mem_init+0x1515>
f0102765:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102768:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f010276e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102771:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102773:	89 da                	mov    %ebx,%edx
f0102775:	89 f8                	mov    %edi,%eax
f0102777:	e8 ea e2 ff ff       	call   f0100a66 <check_va2pa>
f010277c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010277f:	74 19                	je     f010279a <mem_init+0x15a2>
f0102781:	68 98 66 10 f0       	push   $0xf0106698
f0102786:	68 d7 67 10 f0       	push   $0xf01067d7
f010278b:	68 7a 03 00 00       	push   $0x37a
f0102790:	68 b1 67 10 f0       	push   $0xf01067b1
f0102795:	e8 a6 d8 ff ff       	call   f0100040 <_panic>
f010279a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01027a0:	39 de                	cmp    %ebx,%esi
f01027a2:	75 cf                	jne    f0102773 <mem_init+0x157b>
f01027a4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01027a7:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01027ae:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01027b5:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01027bb:	b8 00 c0 26 f0       	mov    $0xf026c000,%eax
f01027c0:	39 f0                	cmp    %esi,%eax
f01027c2:	0f 85 2c ff ff ff    	jne    f01026f4 <mem_init+0x14fc>
f01027c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01027cd:	eb 2a                	jmp    f01027f9 <mem_init+0x1601>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01027cf:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01027d5:	83 fa 04             	cmp    $0x4,%edx
f01027d8:	77 1f                	ja     f01027f9 <mem_init+0x1601>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f01027da:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f01027de:	75 7e                	jne    f010285e <mem_init+0x1666>
f01027e0:	68 b9 6a 10 f0       	push   $0xf0106ab9
f01027e5:	68 d7 67 10 f0       	push   $0xf01067d7
f01027ea:	68 85 03 00 00       	push   $0x385
f01027ef:	68 b1 67 10 f0       	push   $0xf01067b1
f01027f4:	e8 47 d8 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01027f9:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01027fe:	76 3f                	jbe    f010283f <mem_init+0x1647>
				assert(pgdir[i] & PTE_P);
f0102800:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102803:	f6 c2 01             	test   $0x1,%dl
f0102806:	75 19                	jne    f0102821 <mem_init+0x1629>
f0102808:	68 b9 6a 10 f0       	push   $0xf0106ab9
f010280d:	68 d7 67 10 f0       	push   $0xf01067d7
f0102812:	68 89 03 00 00       	push   $0x389
f0102817:	68 b1 67 10 f0       	push   $0xf01067b1
f010281c:	e8 1f d8 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102821:	f6 c2 02             	test   $0x2,%dl
f0102824:	75 38                	jne    f010285e <mem_init+0x1666>
f0102826:	68 ca 6a 10 f0       	push   $0xf0106aca
f010282b:	68 d7 67 10 f0       	push   $0xf01067d7
f0102830:	68 8a 03 00 00       	push   $0x38a
f0102835:	68 b1 67 10 f0       	push   $0xf01067b1
f010283a:	e8 01 d8 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f010283f:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102843:	74 19                	je     f010285e <mem_init+0x1666>
f0102845:	68 db 6a 10 f0       	push   $0xf0106adb
f010284a:	68 d7 67 10 f0       	push   $0xf01067d7
f010284f:	68 8c 03 00 00       	push   $0x38c
f0102854:	68 b1 67 10 f0       	push   $0xf01067b1
f0102859:	e8 e2 d7 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010285e:	83 c0 01             	add    $0x1,%eax
f0102861:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102866:	0f 86 63 ff ff ff    	jbe    f01027cf <mem_init+0x15d7>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010286c:	83 ec 0c             	sub    $0xc,%esp
f010286f:	68 bc 66 10 f0       	push   $0xf01066bc
f0102874:	e8 9b 0d 00 00       	call   f0103614 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102879:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010287e:	83 c4 10             	add    $0x10,%esp
f0102881:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102886:	77 15                	ja     f010289d <mem_init+0x16a5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102888:	50                   	push   %eax
f0102889:	68 28 59 10 f0       	push   $0xf0105928
f010288e:	68 fe 00 00 00       	push   $0xfe
f0102893:	68 b1 67 10 f0       	push   $0xf01067b1
f0102898:	e8 a3 d7 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010289d:	05 00 00 00 10       	add    $0x10000000,%eax
f01028a2:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01028a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01028aa:	e8 1b e2 ff ff       	call   f0100aca <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01028af:	0f 20 c0             	mov    %cr0,%eax
f01028b2:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01028b5:	0d 23 00 05 80       	or     $0x80050023,%eax
f01028ba:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01028bd:	83 ec 0c             	sub    $0xc,%esp
f01028c0:	6a 00                	push   $0x0
f01028c2:	e8 ac e5 ff ff       	call   f0100e73 <page_alloc>
f01028c7:	89 c3                	mov    %eax,%ebx
f01028c9:	83 c4 10             	add    $0x10,%esp
f01028cc:	85 c0                	test   %eax,%eax
f01028ce:	75 19                	jne    f01028e9 <mem_init+0x16f1>
f01028d0:	68 c5 68 10 f0       	push   $0xf01068c5
f01028d5:	68 d7 67 10 f0       	push   $0xf01067d7
f01028da:	68 64 04 00 00       	push   $0x464
f01028df:	68 b1 67 10 f0       	push   $0xf01067b1
f01028e4:	e8 57 d7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01028e9:	83 ec 0c             	sub    $0xc,%esp
f01028ec:	6a 00                	push   $0x0
f01028ee:	e8 80 e5 ff ff       	call   f0100e73 <page_alloc>
f01028f3:	89 c7                	mov    %eax,%edi
f01028f5:	83 c4 10             	add    $0x10,%esp
f01028f8:	85 c0                	test   %eax,%eax
f01028fa:	75 19                	jne    f0102915 <mem_init+0x171d>
f01028fc:	68 db 68 10 f0       	push   $0xf01068db
f0102901:	68 d7 67 10 f0       	push   $0xf01067d7
f0102906:	68 65 04 00 00       	push   $0x465
f010290b:	68 b1 67 10 f0       	push   $0xf01067b1
f0102910:	e8 2b d7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102915:	83 ec 0c             	sub    $0xc,%esp
f0102918:	6a 00                	push   $0x0
f010291a:	e8 54 e5 ff ff       	call   f0100e73 <page_alloc>
f010291f:	89 c6                	mov    %eax,%esi
f0102921:	83 c4 10             	add    $0x10,%esp
f0102924:	85 c0                	test   %eax,%eax
f0102926:	75 19                	jne    f0102941 <mem_init+0x1749>
f0102928:	68 f1 68 10 f0       	push   $0xf01068f1
f010292d:	68 d7 67 10 f0       	push   $0xf01067d7
f0102932:	68 66 04 00 00       	push   $0x466
f0102937:	68 b1 67 10 f0       	push   $0xf01067b1
f010293c:	e8 ff d6 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102941:	83 ec 0c             	sub    $0xc,%esp
f0102944:	53                   	push   %ebx
f0102945:	e8 99 e5 ff ff       	call   f0100ee3 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010294a:	89 f8                	mov    %edi,%eax
f010294c:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0102952:	c1 f8 03             	sar    $0x3,%eax
f0102955:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102958:	89 c2                	mov    %eax,%edx
f010295a:	c1 ea 0c             	shr    $0xc,%edx
f010295d:	83 c4 10             	add    $0x10,%esp
f0102960:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f0102966:	72 12                	jb     f010297a <mem_init+0x1782>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102968:	50                   	push   %eax
f0102969:	68 04 59 10 f0       	push   $0xf0105904
f010296e:	6a 58                	push   $0x58
f0102970:	68 bd 67 10 f0       	push   $0xf01067bd
f0102975:	e8 c6 d6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010297a:	83 ec 04             	sub    $0x4,%esp
f010297d:	68 00 10 00 00       	push   $0x1000
f0102982:	6a 01                	push   $0x1
f0102984:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102989:	50                   	push   %eax
f010298a:	e8 9e 22 00 00       	call   f0104c2d <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010298f:	89 f0                	mov    %esi,%eax
f0102991:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0102997:	c1 f8 03             	sar    $0x3,%eax
f010299a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010299d:	89 c2                	mov    %eax,%edx
f010299f:	c1 ea 0c             	shr    $0xc,%edx
f01029a2:	83 c4 10             	add    $0x10,%esp
f01029a5:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f01029ab:	72 12                	jb     f01029bf <mem_init+0x17c7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029ad:	50                   	push   %eax
f01029ae:	68 04 59 10 f0       	push   $0xf0105904
f01029b3:	6a 58                	push   $0x58
f01029b5:	68 bd 67 10 f0       	push   $0xf01067bd
f01029ba:	e8 81 d6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01029bf:	83 ec 04             	sub    $0x4,%esp
f01029c2:	68 00 10 00 00       	push   $0x1000
f01029c7:	6a 02                	push   $0x2
f01029c9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01029ce:	50                   	push   %eax
f01029cf:	e8 59 22 00 00       	call   f0104c2d <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01029d4:	6a 02                	push   $0x2
f01029d6:	68 00 10 00 00       	push   $0x1000
f01029db:	57                   	push   %edi
f01029dc:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f01029e2:	e8 54 e7 ff ff       	call   f010113b <page_insert>
	assert(pp1->pp_ref == 1);
f01029e7:	83 c4 20             	add    $0x20,%esp
f01029ea:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01029ef:	74 19                	je     f0102a0a <mem_init+0x1812>
f01029f1:	68 c2 69 10 f0       	push   $0xf01069c2
f01029f6:	68 d7 67 10 f0       	push   $0xf01067d7
f01029fb:	68 6b 04 00 00       	push   $0x46b
f0102a00:	68 b1 67 10 f0       	push   $0xf01067b1
f0102a05:	e8 36 d6 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102a0a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102a11:	01 01 01 
f0102a14:	74 19                	je     f0102a2f <mem_init+0x1837>
f0102a16:	68 dc 66 10 f0       	push   $0xf01066dc
f0102a1b:	68 d7 67 10 f0       	push   $0xf01067d7
f0102a20:	68 6c 04 00 00       	push   $0x46c
f0102a25:	68 b1 67 10 f0       	push   $0xf01067b1
f0102a2a:	e8 11 d6 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102a2f:	6a 02                	push   $0x2
f0102a31:	68 00 10 00 00       	push   $0x1000
f0102a36:	56                   	push   %esi
f0102a37:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0102a3d:	e8 f9 e6 ff ff       	call   f010113b <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102a42:	83 c4 10             	add    $0x10,%esp
f0102a45:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102a4c:	02 02 02 
f0102a4f:	74 19                	je     f0102a6a <mem_init+0x1872>
f0102a51:	68 00 67 10 f0       	push   $0xf0106700
f0102a56:	68 d7 67 10 f0       	push   $0xf01067d7
f0102a5b:	68 6e 04 00 00       	push   $0x46e
f0102a60:	68 b1 67 10 f0       	push   $0xf01067b1
f0102a65:	e8 d6 d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102a6a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102a6f:	74 19                	je     f0102a8a <mem_init+0x1892>
f0102a71:	68 e4 69 10 f0       	push   $0xf01069e4
f0102a76:	68 d7 67 10 f0       	push   $0xf01067d7
f0102a7b:	68 6f 04 00 00       	push   $0x46f
f0102a80:	68 b1 67 10 f0       	push   $0xf01067b1
f0102a85:	e8 b6 d5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102a8a:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102a8f:	74 19                	je     f0102aaa <mem_init+0x18b2>
f0102a91:	68 4e 6a 10 f0       	push   $0xf0106a4e
f0102a96:	68 d7 67 10 f0       	push   $0xf01067d7
f0102a9b:	68 70 04 00 00       	push   $0x470
f0102aa0:	68 b1 67 10 f0       	push   $0xf01067b1
f0102aa5:	e8 96 d5 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102aaa:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102ab1:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ab4:	89 f0                	mov    %esi,%eax
f0102ab6:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0102abc:	c1 f8 03             	sar    $0x3,%eax
f0102abf:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ac2:	89 c2                	mov    %eax,%edx
f0102ac4:	c1 ea 0c             	shr    $0xc,%edx
f0102ac7:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f0102acd:	72 12                	jb     f0102ae1 <mem_init+0x18e9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102acf:	50                   	push   %eax
f0102ad0:	68 04 59 10 f0       	push   $0xf0105904
f0102ad5:	6a 58                	push   $0x58
f0102ad7:	68 bd 67 10 f0       	push   $0xf01067bd
f0102adc:	e8 5f d5 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ae1:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102ae8:	03 03 03 
f0102aeb:	74 19                	je     f0102b06 <mem_init+0x190e>
f0102aed:	68 24 67 10 f0       	push   $0xf0106724
f0102af2:	68 d7 67 10 f0       	push   $0xf01067d7
f0102af7:	68 72 04 00 00       	push   $0x472
f0102afc:	68 b1 67 10 f0       	push   $0xf01067b1
f0102b01:	e8 3a d5 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102b06:	83 ec 08             	sub    $0x8,%esp
f0102b09:	68 00 10 00 00       	push   $0x1000
f0102b0e:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0102b14:	e8 d4 e5 ff ff       	call   f01010ed <page_remove>
	assert(pp2->pp_ref == 0);
f0102b19:	83 c4 10             	add    $0x10,%esp
f0102b1c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102b21:	74 19                	je     f0102b3c <mem_init+0x1944>
f0102b23:	68 1c 6a 10 f0       	push   $0xf0106a1c
f0102b28:	68 d7 67 10 f0       	push   $0xf01067d7
f0102b2d:	68 74 04 00 00       	push   $0x474
f0102b32:	68 b1 67 10 f0       	push   $0xf01067b1
f0102b37:	e8 04 d5 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b3c:	8b 0d 0c af 22 f0    	mov    0xf022af0c,%ecx
f0102b42:	8b 11                	mov    (%ecx),%edx
f0102b44:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102b4a:	89 d8                	mov    %ebx,%eax
f0102b4c:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0102b52:	c1 f8 03             	sar    $0x3,%eax
f0102b55:	c1 e0 0c             	shl    $0xc,%eax
f0102b58:	39 c2                	cmp    %eax,%edx
f0102b5a:	74 19                	je     f0102b75 <mem_init+0x197d>
f0102b5c:	68 ac 60 10 f0       	push   $0xf01060ac
f0102b61:	68 d7 67 10 f0       	push   $0xf01067d7
f0102b66:	68 77 04 00 00       	push   $0x477
f0102b6b:	68 b1 67 10 f0       	push   $0xf01067b1
f0102b70:	e8 cb d4 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102b75:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102b7b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102b80:	74 19                	je     f0102b9b <mem_init+0x19a3>
f0102b82:	68 d3 69 10 f0       	push   $0xf01069d3
f0102b87:	68 d7 67 10 f0       	push   $0xf01067d7
f0102b8c:	68 79 04 00 00       	push   $0x479
f0102b91:	68 b1 67 10 f0       	push   $0xf01067b1
f0102b96:	e8 a5 d4 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102b9b:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102ba1:	83 ec 0c             	sub    $0xc,%esp
f0102ba4:	53                   	push   %ebx
f0102ba5:	e8 39 e3 ff ff       	call   f0100ee3 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102baa:	c7 04 24 50 67 10 f0 	movl   $0xf0106750,(%esp)
f0102bb1:	e8 5e 0a 00 00       	call   f0103614 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102bb6:	83 c4 10             	add    $0x10,%esp
f0102bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102bbc:	5b                   	pop    %ebx
f0102bbd:	5e                   	pop    %esi
f0102bbe:	5f                   	pop    %edi
f0102bbf:	5d                   	pop    %ebp
f0102bc0:	c3                   	ret    

f0102bc1 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102bc1:	55                   	push   %ebp
f0102bc2:	89 e5                	mov    %esp,%ebp
f0102bc4:	57                   	push   %edi
f0102bc5:	56                   	push   %esi
f0102bc6:	53                   	push   %ebx
f0102bc7:	83 ec 1c             	sub    $0x1c,%esp
f0102bca:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
	// LAB 3: Your code here.
	uintptr_t mem_start = (uintptr_t) va;
f0102bd0:	89 c3                	mov    %eax,%ebx
	
	uintptr_t mem_end = (uintptr_t) ROUNDUP(((uintptr_t) va + len), PGSIZE);
f0102bd2:	8b 55 10             	mov    0x10(%ebp),%edx
f0102bd5:	8d 84 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%eax
f0102bdc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102be1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	
	perm = perm | PTE_P ;
f0102be4:	8b 75 14             	mov    0x14(%ebp),%esi
f0102be7:	83 ce 01             	or     $0x1,%esi
	
	uintptr_t i;
				
	while(mem_start < mem_end){
f0102bea:	eb 4b                	jmp    f0102c37 <user_mem_check+0x76>
		
		if ((uint32_t)mem_start >= ULIM){
f0102bec:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102bf2:	76 0d                	jbe    f0102c01 <user_mem_check+0x40>
		
			user_mem_check_addr = (uintptr_t) mem_start;
f0102bf4:	89 1d 3c a2 22 f0    	mov    %ebx,0xf022a23c
			return -E_FAULT;
f0102bfa:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102bff:	eb 40                	jmp    f0102c41 <user_mem_check+0x80>
		}		
		
		pte_t * pte = pgdir_walk(env->env_pgdir, (void *) mem_start, 0);
f0102c01:	83 ec 04             	sub    $0x4,%esp
f0102c04:	6a 00                	push   $0x0
f0102c06:	53                   	push   %ebx
f0102c07:	ff 77 60             	pushl  0x60(%edi)
f0102c0a:	e8 4d e3 ff ff       	call   f0100f5c <pgdir_walk>
				
		if (pte == NULL || (((uint32_t) *pte & perm)!=perm)){
f0102c0f:	83 c4 10             	add    $0x10,%esp
f0102c12:	85 c0                	test   %eax,%eax
f0102c14:	74 08                	je     f0102c1e <user_mem_check+0x5d>
f0102c16:	89 f1                	mov    %esi,%ecx
f0102c18:	23 08                	and    (%eax),%ecx
f0102c1a:	39 ce                	cmp    %ecx,%esi
f0102c1c:	74 0d                	je     f0102c2b <user_mem_check+0x6a>
			
			user_mem_check_addr = (uintptr_t) mem_start;
f0102c1e:	89 1d 3c a2 22 f0    	mov    %ebx,0xf022a23c
			return -E_FAULT;	
f0102c24:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102c29:	eb 16                	jmp    f0102c41 <user_mem_check+0x80>
		
		}
		mem_start = (uintptr_t) ROUNDDOWN((uintptr_t) mem_start, PGSIZE);
f0102c2b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		mem_start += PGSIZE;	
f0102c31:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	
	perm = perm | PTE_P ;
	
	uintptr_t i;
				
	while(mem_start < mem_end){
f0102c37:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102c3a:	72 b0                	jb     f0102bec <user_mem_check+0x2b>
		}
		mem_start = (uintptr_t) ROUNDDOWN((uintptr_t) mem_start, PGSIZE);
		mem_start += PGSIZE;	
	}
	
	return 0;
f0102c3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c44:	5b                   	pop    %ebx
f0102c45:	5e                   	pop    %esi
f0102c46:	5f                   	pop    %edi
f0102c47:	5d                   	pop    %ebp
f0102c48:	c3                   	ret    

f0102c49 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102c49:	55                   	push   %ebp
f0102c4a:	89 e5                	mov    %esp,%ebp
f0102c4c:	53                   	push   %ebx
f0102c4d:	83 ec 04             	sub    $0x4,%esp
f0102c50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102c53:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c56:	83 c8 04             	or     $0x4,%eax
f0102c59:	50                   	push   %eax
f0102c5a:	ff 75 10             	pushl  0x10(%ebp)
f0102c5d:	ff 75 0c             	pushl  0xc(%ebp)
f0102c60:	53                   	push   %ebx
f0102c61:	e8 5b ff ff ff       	call   f0102bc1 <user_mem_check>
f0102c66:	83 c4 10             	add    $0x10,%esp
f0102c69:	85 c0                	test   %eax,%eax
f0102c6b:	79 21                	jns    f0102c8e <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102c6d:	83 ec 04             	sub    $0x4,%esp
f0102c70:	ff 35 3c a2 22 f0    	pushl  0xf022a23c
f0102c76:	ff 73 48             	pushl  0x48(%ebx)
f0102c79:	68 7c 67 10 f0       	push   $0xf010677c
f0102c7e:	e8 91 09 00 00       	call   f0103614 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102c83:	89 1c 24             	mov    %ebx,(%esp)
f0102c86:	e8 a0 06 00 00       	call   f010332b <env_destroy>
f0102c8b:	83 c4 10             	add    $0x10,%esp
	}
}
f0102c8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102c91:	c9                   	leave  
f0102c92:	c3                   	ret    

f0102c93 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102c93:	55                   	push   %ebp
f0102c94:	89 e5                	mov    %esp,%ebp
f0102c96:	57                   	push   %edi
f0102c97:	56                   	push   %esi
f0102c98:	53                   	push   %ebx
f0102c99:	83 ec 0c             	sub    $0xc,%esp
f0102c9c:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)
	
	void *region_alloc_start = (void *) ROUNDDOWN((uint32_t) va, PGSIZE);
f0102c9e:	89 d3                	mov    %edx,%ebx
f0102ca0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	void *region_alloc_end = (void *) ROUNDUP(((uint32_t) va + len), PGSIZE);
f0102ca6:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0102cad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102cb2:	89 c6                	mov    %eax,%esi
	
	if ((uint32_t)region_alloc_end > UTOP)
f0102cb4:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f0102cb9:	76 6d                	jbe    f0102d28 <region_alloc+0x95>
		panic("region_alloc failed: Cannot allocate memory above UTOP");
f0102cbb:	83 ec 04             	sub    $0x4,%esp
f0102cbe:	68 ec 6a 10 f0       	push   $0xf0106aec
f0102cc3:	68 31 01 00 00       	push   $0x131
f0102cc8:	68 d0 6b 10 f0       	push   $0xf0106bd0
f0102ccd:	e8 6e d3 ff ff       	call   f0100040 <_panic>
	//for(region_alloc_start; region_alloc_start < region_alloc_end; region_alloc_start += PGSIZE){
	struct PageInfo *page;
	
	while(region_alloc_start < region_alloc_end){
	
		page = page_alloc(0);
f0102cd2:	83 ec 0c             	sub    $0xc,%esp
f0102cd5:	6a 00                	push   $0x0
f0102cd7:	e8 97 e1 ff ff       	call   f0100e73 <page_alloc>
		
		if (page == NULL) 
f0102cdc:	83 c4 10             	add    $0x10,%esp
f0102cdf:	85 c0                	test   %eax,%eax
f0102ce1:	75 17                	jne    f0102cfa <region_alloc+0x67>
			panic("region_alloc failed: Allocation failed!");
f0102ce3:	83 ec 04             	sub    $0x4,%esp
f0102ce6:	68 24 6b 10 f0       	push   $0xf0106b24
f0102ceb:	68 3b 01 00 00       	push   $0x13b
f0102cf0:	68 d0 6b 10 f0       	push   $0xf0106bd0
f0102cf5:	e8 46 d3 ff ff       	call   f0100040 <_panic>
	
		int r = page_insert(e->env_pgdir, page, region_alloc_start, (PTE_W | PTE_U));	
f0102cfa:	6a 06                	push   $0x6
f0102cfc:	53                   	push   %ebx
f0102cfd:	50                   	push   %eax
f0102cfe:	ff 77 60             	pushl  0x60(%edi)
f0102d01:	e8 35 e4 ff ff       	call   f010113b <page_insert>
		
		if(r != 0)
f0102d06:	83 c4 10             	add    $0x10,%esp
f0102d09:	85 c0                	test   %eax,%eax
f0102d0b:	74 15                	je     f0102d22 <region_alloc+0x8f>
			panic("region_alloc: %e", r);
f0102d0d:	50                   	push   %eax
f0102d0e:	68 db 6b 10 f0       	push   $0xf0106bdb
f0102d13:	68 40 01 00 00       	push   $0x140
f0102d18:	68 d0 6b 10 f0       	push   $0xf0106bd0
f0102d1d:	e8 1e d3 ff ff       	call   f0100040 <_panic>
	
		region_alloc_start += PGSIZE;
f0102d22:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		panic("region_alloc failed: Cannot allocate memory above UTOP");
	
	//for(region_alloc_start; region_alloc_start < region_alloc_end; region_alloc_start += PGSIZE){
	struct PageInfo *page;
	
	while(region_alloc_start < region_alloc_end){
f0102d28:	39 f3                	cmp    %esi,%ebx
f0102d2a:	72 a6                	jb     f0102cd2 <region_alloc+0x3f>
	
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d2f:	5b                   	pop    %ebx
f0102d30:	5e                   	pop    %esi
f0102d31:	5f                   	pop    %edi
f0102d32:	5d                   	pop    %ebp
f0102d33:	c3                   	ret    

f0102d34 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102d34:	55                   	push   %ebp
f0102d35:	89 e5                	mov    %esp,%ebp
f0102d37:	56                   	push   %esi
f0102d38:	53                   	push   %ebx
f0102d39:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d3c:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102d3f:	85 c0                	test   %eax,%eax
f0102d41:	75 1a                	jne    f0102d5d <envid2env+0x29>
		*env_store = curenv;
f0102d43:	e8 06 25 00 00       	call   f010524e <cpunum>
f0102d48:	6b c0 74             	imul   $0x74,%eax,%eax
f0102d4b:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0102d51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102d54:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102d56:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d5b:	eb 70                	jmp    f0102dcd <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102d5d:	89 c3                	mov    %eax,%ebx
f0102d5f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102d65:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102d68:	03 1d 48 a2 22 f0    	add    0xf022a248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102d6e:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102d72:	74 05                	je     f0102d79 <envid2env+0x45>
f0102d74:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102d77:	74 10                	je     f0102d89 <envid2env+0x55>
		*env_store = 0;
f0102d79:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d7c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102d82:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102d87:	eb 44                	jmp    f0102dcd <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102d89:	84 d2                	test   %dl,%dl
f0102d8b:	74 36                	je     f0102dc3 <envid2env+0x8f>
f0102d8d:	e8 bc 24 00 00       	call   f010524e <cpunum>
f0102d92:	6b c0 74             	imul   $0x74,%eax,%eax
f0102d95:	3b 98 28 b0 22 f0    	cmp    -0xfdd4fd8(%eax),%ebx
f0102d9b:	74 26                	je     f0102dc3 <envid2env+0x8f>
f0102d9d:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102da0:	e8 a9 24 00 00       	call   f010524e <cpunum>
f0102da5:	6b c0 74             	imul   $0x74,%eax,%eax
f0102da8:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0102dae:	3b 70 48             	cmp    0x48(%eax),%esi
f0102db1:	74 10                	je     f0102dc3 <envid2env+0x8f>
		*env_store = 0;
f0102db3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102db6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102dbc:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102dc1:	eb 0a                	jmp    f0102dcd <envid2env+0x99>
	}

	*env_store = e;
f0102dc3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102dc6:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102dc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102dcd:	5b                   	pop    %ebx
f0102dce:	5e                   	pop    %esi
f0102dcf:	5d                   	pop    %ebp
f0102dd0:	c3                   	ret    

f0102dd1 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102dd1:	55                   	push   %ebp
f0102dd2:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102dd4:	b8 00 f3 11 f0       	mov    $0xf011f300,%eax
f0102dd9:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102ddc:	b8 23 00 00 00       	mov    $0x23,%eax
f0102de1:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102de3:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102de5:	b8 10 00 00 00       	mov    $0x10,%eax
f0102dea:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102dec:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102dee:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102df0:	ea f7 2d 10 f0 08 00 	ljmp   $0x8,$0xf0102df7
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102df7:	b8 00 00 00 00       	mov    $0x0,%eax
f0102dfc:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102dff:	5d                   	pop    %ebp
f0102e00:	c3                   	ret    

f0102e01 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102e01:	55                   	push   %ebp
f0102e02:	89 e5                	mov    %esp,%ebp
f0102e04:	56                   	push   %esi
f0102e05:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = NULL;
f0102e06:	c7 05 4c a2 22 f0 00 	movl   $0x0,0xf022a24c
f0102e0d:	00 00 00 
	int i;
	
	cprintf("PDX(UTOP) %u\n", PDX(UTOP) );
f0102e10:	83 ec 08             	sub    $0x8,%esp
f0102e13:	68 bb 03 00 00       	push   $0x3bb
f0102e18:	68 ec 6b 10 f0       	push   $0xf0106bec
f0102e1d:	e8 f2 07 00 00       	call   f0103614 <cprintf>
	for (i = (NENV - 1); i >= 0; --i){
	
		envs[i].env_status = ENV_FREE;
f0102e22:	8b 35 48 a2 22 f0    	mov    0xf022a248,%esi
f0102e28:	8b 15 4c a2 22 f0    	mov    0xf022a24c,%edx
f0102e2e:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102e34:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102e37:	83 c4 10             	add    $0x10,%esp
f0102e3a:	89 c1                	mov    %eax,%ecx
f0102e3c:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0102e43:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102e4a:	89 50 44             	mov    %edx,0x44(%eax)
f0102e4d:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0102e50:	89 ca                	mov    %ecx,%edx
	// LAB 3: Your code here.
	env_free_list = NULL;
	int i;
	
	cprintf("PDX(UTOP) %u\n", PDX(UTOP) );
	for (i = (NENV - 1); i >= 0; --i){
f0102e52:	39 d8                	cmp    %ebx,%eax
f0102e54:	75 e4                	jne    f0102e3a <env_init+0x39>
f0102e56:	89 35 4c a2 22 f0    	mov    %esi,0xf022a24c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102e5c:	e8 70 ff ff ff       	call   f0102dd1 <env_init_percpu>
}
f0102e61:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102e64:	5b                   	pop    %ebx
f0102e65:	5e                   	pop    %esi
f0102e66:	5d                   	pop    %ebp
f0102e67:	c3                   	ret    

f0102e68 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102e68:	55                   	push   %ebp
f0102e69:	89 e5                	mov    %esp,%ebp
f0102e6b:	53                   	push   %ebx
f0102e6c:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102e6f:	8b 1d 4c a2 22 f0    	mov    0xf022a24c,%ebx
f0102e75:	85 db                	test   %ebx,%ebx
f0102e77:	0f 84 7d 01 00 00    	je     f0102ffa <env_alloc+0x192>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102e7d:	83 ec 0c             	sub    $0xc,%esp
f0102e80:	6a 01                	push   $0x1
f0102e82:	e8 ec df ff ff       	call   f0100e73 <page_alloc>
f0102e87:	83 c4 10             	add    $0x10,%esp
f0102e8a:	85 c0                	test   %eax,%eax
f0102e8c:	0f 84 6f 01 00 00    	je     f0103001 <env_alloc+0x199>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0102e92:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e97:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0102e9d:	c1 f8 03             	sar    $0x3,%eax
f0102ea0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ea3:	89 c2                	mov    %eax,%edx
f0102ea5:	c1 ea 0c             	shr    $0xc,%edx
f0102ea8:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f0102eae:	72 12                	jb     f0102ec2 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102eb0:	50                   	push   %eax
f0102eb1:	68 04 59 10 f0       	push   $0xf0105904
f0102eb6:	6a 58                	push   $0x58
f0102eb8:	68 bd 67 10 f0       	push   $0xf01067bd
f0102ebd:	e8 7e d1 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = (pde_t *) page2kva(p);
f0102ec2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ec7:	89 43 60             	mov    %eax,0x60(%ebx)
f0102eca:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (i = 0; i < PDX(UTOP); i++)
	{
		e->env_pgdir[i]= 0;
f0102ecf:	8b 53 60             	mov    0x60(%ebx),%edx
f0102ed2:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f0102ed9:	83 c0 04             	add    $0x4,%eax

	// LAB 3: Your code here.
	p->pp_ref++;
	e->env_pgdir = (pde_t *) page2kva(p);
	
	for (i = 0; i < PDX(UTOP); i++)
f0102edc:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0102ee1:	75 ec                	jne    f0102ecf <env_alloc+0x67>
	{
		e->env_pgdir[i]= 0;
	}
	for (i = PDX(UTOP) ;  i < NPDENTRIES; i++ )
	{
		e->env_pgdir[i] = kern_pgdir[i];
f0102ee3:	8b 15 0c af 22 f0    	mov    0xf022af0c,%edx
f0102ee9:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0102eec:	8b 53 60             	mov    0x60(%ebx),%edx
f0102eef:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0102ef2:	83 c0 04             	add    $0x4,%eax
	
	for (i = 0; i < PDX(UTOP); i++)
	{
		e->env_pgdir[i]= 0;
	}
	for (i = PDX(UTOP) ;  i < NPDENTRIES; i++ )
f0102ef5:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102efa:	75 e7                	jne    f0102ee3 <env_alloc+0x7b>
		e->env_pgdir[i] = kern_pgdir[i];
	}
		
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102efc:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102eff:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f04:	77 15                	ja     f0102f1b <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f06:	50                   	push   %eax
f0102f07:	68 28 59 10 f0       	push   $0xf0105928
f0102f0c:	68 d2 00 00 00       	push   $0xd2
f0102f11:	68 d0 6b 10 f0       	push   $0xf0106bd0
f0102f16:	e8 25 d1 ff ff       	call   f0100040 <_panic>
f0102f1b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102f21:	83 ca 05             	or     $0x5,%edx
f0102f24:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102f2a:	8b 43 48             	mov    0x48(%ebx),%eax
f0102f2d:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102f32:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102f37:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102f3c:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102f3f:	89 da                	mov    %ebx,%edx
f0102f41:	2b 15 48 a2 22 f0    	sub    0xf022a248,%edx
f0102f47:	c1 fa 02             	sar    $0x2,%edx
f0102f4a:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0102f50:	09 d0                	or     %edx,%eax
f0102f52:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102f55:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f58:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102f5b:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102f62:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102f69:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102f70:	83 ec 04             	sub    $0x4,%esp
f0102f73:	6a 44                	push   $0x44
f0102f75:	6a 00                	push   $0x0
f0102f77:	53                   	push   %ebx
f0102f78:	e8 b0 1c 00 00       	call   f0104c2d <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102f7d:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102f83:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102f89:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102f8f:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102f96:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0102f9c:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0102fa3:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0102fa7:	8b 43 44             	mov    0x44(%ebx),%eax
f0102faa:	a3 4c a2 22 f0       	mov    %eax,0xf022a24c
	*newenv_store = e;
f0102faf:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fb2:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102fb4:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0102fb7:	e8 92 22 00 00       	call   f010524e <cpunum>
f0102fbc:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fbf:	83 c4 10             	add    $0x10,%esp
f0102fc2:	ba 00 00 00 00       	mov    $0x0,%edx
f0102fc7:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f0102fce:	74 11                	je     f0102fe1 <env_alloc+0x179>
f0102fd0:	e8 79 22 00 00       	call   f010524e <cpunum>
f0102fd5:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fd8:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0102fde:	8b 50 48             	mov    0x48(%eax),%edx
f0102fe1:	83 ec 04             	sub    $0x4,%esp
f0102fe4:	53                   	push   %ebx
f0102fe5:	52                   	push   %edx
f0102fe6:	68 fa 6b 10 f0       	push   $0xf0106bfa
f0102feb:	e8 24 06 00 00       	call   f0103614 <cprintf>
	return 0;
f0102ff0:	83 c4 10             	add    $0x10,%esp
f0102ff3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ff8:	eb 0c                	jmp    f0103006 <env_alloc+0x19e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102ffa:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102fff:	eb 05                	jmp    f0103006 <env_alloc+0x19e>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103001:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103006:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103009:	c9                   	leave  
f010300a:	c3                   	ret    

f010300b <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010300b:	55                   	push   %ebp
f010300c:	89 e5                	mov    %esp,%ebp
f010300e:	57                   	push   %edi
f010300f:	56                   	push   %esi
f0103010:	53                   	push   %ebx
f0103011:	83 ec 34             	sub    $0x34,%esp
f0103014:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	
	int r = env_alloc(&e, (envid_t) 0);
f0103017:	6a 00                	push   $0x0
f0103019:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010301c:	50                   	push   %eax
f010301d:	e8 46 fe ff ff       	call   f0102e68 <env_alloc>
	
	if(r != 0) {
f0103022:	83 c4 10             	add    $0x10,%esp
f0103025:	85 c0                	test   %eax,%eax
f0103027:	74 15                	je     f010303e <env_create+0x33>
		panic("env_alloc failed: env_create failed %e\n", r);
f0103029:	50                   	push   %eax
f010302a:	68 4c 6b 10 f0       	push   $0xf0106b4c
f010302f:	68 c1 01 00 00       	push   $0x1c1
f0103034:	68 d0 6b 10 f0       	push   $0xf0106bd0
f0103039:	e8 02 d0 ff ff       	call   f0100040 <_panic>
	}
	
	load_icode(e,binary);
f010303e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103041:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Elf * elfHeader = (struct Elf *) binary;

	struct Proghdr *ph, *eph;

	// is this a valid ELF?
	if (elfHeader->e_magic != ELF_MAGIC)
f0103044:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010304a:	74 17                	je     f0103063 <env_create+0x58>
		panic("load_icode failed: Not a valid ELF file!");
f010304c:	83 ec 04             	sub    $0x4,%esp
f010304f:	68 74 6b 10 f0       	push   $0xf0106b74
f0103054:	68 88 01 00 00       	push   $0x188
f0103059:	68 d0 6b 10 f0       	push   $0xf0106bd0
f010305e:	e8 dd cf ff ff       	call   f0100040 <_panic>
	
	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) elfHeader + elfHeader->e_phoff);
f0103063:	89 fb                	mov    %edi,%ebx
f0103065:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elfHeader->e_phnum;
f0103068:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f010306c:	c1 e6 05             	shl    $0x5,%esi
f010306f:	01 de                	add    %ebx,%esi
	
	lcr3(PADDR(e->env_pgdir));
f0103071:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103074:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103077:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010307c:	77 15                	ja     f0103093 <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010307e:	50                   	push   %eax
f010307f:	68 28 59 10 f0       	push   $0xf0105928
f0103084:	68 8e 01 00 00       	push   $0x18e
f0103089:	68 d0 6b 10 f0       	push   $0xf0106bd0
f010308e:	e8 ad cf ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103093:	05 00 00 00 10       	add    $0x10000000,%eax
f0103098:	0f 22 d8             	mov    %eax,%cr3
f010309b:	eb 5b                	jmp    f01030f8 <env_create+0xed>
	
	for (; ph < eph; ph++)
	{
		// p_pa is the load address of this segment (as well
		// as the physical address)
		if (ph->p_type == ELF_PROG_LOAD)
f010309d:	83 3b 01             	cmpl   $0x1,(%ebx)
f01030a0:	75 53                	jne    f01030f5 <env_create+0xea>
		{
			if(ph->p_filesz <= ph->p_memsz){
f01030a2:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01030a5:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01030a8:	77 34                	ja     f01030de <env_create+0xd3>
			
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01030aa:	8b 53 08             	mov    0x8(%ebx),%edx
f01030ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01030b0:	e8 de fb ff ff       	call   f0102c93 <region_alloc>
			memset((void *) ph->p_va, 0, ph->p_memsz);
f01030b5:	83 ec 04             	sub    $0x4,%esp
f01030b8:	ff 73 14             	pushl  0x14(%ebx)
f01030bb:	6a 00                	push   $0x0
f01030bd:	ff 73 08             	pushl  0x8(%ebx)
f01030c0:	e8 68 1b 00 00       	call   f0104c2d <memset>
			memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01030c5:	83 c4 0c             	add    $0xc,%esp
f01030c8:	ff 73 10             	pushl  0x10(%ebx)
f01030cb:	89 f8                	mov    %edi,%eax
f01030cd:	03 43 04             	add    0x4(%ebx),%eax
f01030d0:	50                   	push   %eax
f01030d1:	ff 73 08             	pushl  0x8(%ebx)
f01030d4:	e8 a1 1b 00 00       	call   f0104c7a <memmove>
f01030d9:	83 c4 10             	add    $0x10,%esp
f01030dc:	eb 17                	jmp    f01030f5 <env_create+0xea>
			}
			
			else
				panic("load_icode failed: filesz is greater than memsz");
f01030de:	83 ec 04             	sub    $0x4,%esp
f01030e1:	68 a0 6b 10 f0       	push   $0xf0106ba0
f01030e6:	68 9e 01 00 00       	push   $0x19e
f01030eb:	68 d0 6b 10 f0       	push   $0xf0106bd0
f01030f0:	e8 4b cf ff ff       	call   f0100040 <_panic>
	ph = (struct Proghdr *) ((uint8_t *) elfHeader + elfHeader->e_phoff);
	eph = ph + elfHeader->e_phnum;
	
	lcr3(PADDR(e->env_pgdir));
	
	for (; ph < eph; ph++)
f01030f5:	83 c3 20             	add    $0x20,%ebx
f01030f8:	39 de                	cmp    %ebx,%esi
f01030fa:	77 a1                	ja     f010309d <env_create+0x92>
				panic("load_icode failed: filesz is greater than memsz");
				
		}
	}
	
	e->env_tf.tf_eip = elfHeader->e_entry;
f01030fc:	8b 47 18             	mov    0x18(%edi),%eax
f01030ff:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103102:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0103105:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010310a:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010310f:	89 f8                	mov    %edi,%eax
f0103111:	e8 7d fb ff ff       	call   f0102c93 <region_alloc>
	
	lcr3(PADDR(kern_pgdir));
f0103116:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010311b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103120:	77 15                	ja     f0103137 <env_create+0x12c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103122:	50                   	push   %eax
f0103123:	68 28 59 10 f0       	push   $0xf0105928
f0103128:	68 ae 01 00 00       	push   $0x1ae
f010312d:	68 d0 6b 10 f0       	push   $0xf0106bd0
f0103132:	e8 09 cf ff ff       	call   f0100040 <_panic>
f0103137:	05 00 00 00 10       	add    $0x10000000,%eax
f010313c:	0f 22 d8             	mov    %eax,%cr3
	if(r != 0) {
		panic("env_alloc failed: env_create failed %e\n", r);
	}
	
	load_icode(e,binary);
	e->env_type = type;
f010313f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103142:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103145:	89 50 50             	mov    %edx,0x50(%eax)
	
}
f0103148:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010314b:	5b                   	pop    %ebx
f010314c:	5e                   	pop    %esi
f010314d:	5f                   	pop    %edi
f010314e:	5d                   	pop    %ebp
f010314f:	c3                   	ret    

f0103150 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103150:	55                   	push   %ebp
f0103151:	89 e5                	mov    %esp,%ebp
f0103153:	57                   	push   %edi
f0103154:	56                   	push   %esi
f0103155:	53                   	push   %ebx
f0103156:	83 ec 1c             	sub    $0x1c,%esp
f0103159:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010315c:	e8 ed 20 00 00       	call   f010524e <cpunum>
f0103161:	6b c0 74             	imul   $0x74,%eax,%eax
f0103164:	39 b8 28 b0 22 f0    	cmp    %edi,-0xfdd4fd8(%eax)
f010316a:	75 29                	jne    f0103195 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f010316c:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103171:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103176:	77 15                	ja     f010318d <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103178:	50                   	push   %eax
f0103179:	68 28 59 10 f0       	push   $0xf0105928
f010317e:	68 d8 01 00 00       	push   $0x1d8
f0103183:	68 d0 6b 10 f0       	push   $0xf0106bd0
f0103188:	e8 b3 ce ff ff       	call   f0100040 <_panic>
f010318d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103192:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103195:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103198:	e8 b1 20 00 00       	call   f010524e <cpunum>
f010319d:	6b c0 74             	imul   $0x74,%eax,%eax
f01031a0:	ba 00 00 00 00       	mov    $0x0,%edx
f01031a5:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f01031ac:	74 11                	je     f01031bf <env_free+0x6f>
f01031ae:	e8 9b 20 00 00       	call   f010524e <cpunum>
f01031b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01031b6:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f01031bc:	8b 50 48             	mov    0x48(%eax),%edx
f01031bf:	83 ec 04             	sub    $0x4,%esp
f01031c2:	53                   	push   %ebx
f01031c3:	52                   	push   %edx
f01031c4:	68 0f 6c 10 f0       	push   $0xf0106c0f
f01031c9:	e8 46 04 00 00       	call   f0103614 <cprintf>
f01031ce:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01031d1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01031d8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01031db:	89 d0                	mov    %edx,%eax
f01031dd:	c1 e0 02             	shl    $0x2,%eax
f01031e0:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01031e3:	8b 47 60             	mov    0x60(%edi),%eax
f01031e6:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01031e9:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01031ef:	0f 84 a8 00 00 00    	je     f010329d <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01031f5:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031fb:	89 f0                	mov    %esi,%eax
f01031fd:	c1 e8 0c             	shr    $0xc,%eax
f0103200:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103203:	39 05 08 af 22 f0    	cmp    %eax,0xf022af08
f0103209:	77 15                	ja     f0103220 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010320b:	56                   	push   %esi
f010320c:	68 04 59 10 f0       	push   $0xf0105904
f0103211:	68 e7 01 00 00       	push   $0x1e7
f0103216:	68 d0 6b 10 f0       	push   $0xf0106bd0
f010321b:	e8 20 ce ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103220:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103223:	c1 e0 16             	shl    $0x16,%eax
f0103226:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103229:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010322e:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103235:	01 
f0103236:	74 17                	je     f010324f <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103238:	83 ec 08             	sub    $0x8,%esp
f010323b:	89 d8                	mov    %ebx,%eax
f010323d:	c1 e0 0c             	shl    $0xc,%eax
f0103240:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103243:	50                   	push   %eax
f0103244:	ff 77 60             	pushl  0x60(%edi)
f0103247:	e8 a1 de ff ff       	call   f01010ed <page_remove>
f010324c:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010324f:	83 c3 01             	add    $0x1,%ebx
f0103252:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103258:	75 d4                	jne    f010322e <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010325a:	8b 47 60             	mov    0x60(%edi),%eax
f010325d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103260:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103267:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010326a:	3b 05 08 af 22 f0    	cmp    0xf022af08,%eax
f0103270:	72 14                	jb     f0103286 <env_free+0x136>
		panic("pa2page called with invalid pa");
f0103272:	83 ec 04             	sub    $0x4,%esp
f0103275:	68 48 5f 10 f0       	push   $0xf0105f48
f010327a:	6a 51                	push   $0x51
f010327c:	68 bd 67 10 f0       	push   $0xf01067bd
f0103281:	e8 ba cd ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0103286:	83 ec 0c             	sub    $0xc,%esp
f0103289:	a1 10 af 22 f0       	mov    0xf022af10,%eax
f010328e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103291:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103294:	50                   	push   %eax
f0103295:	e8 9b dc ff ff       	call   f0100f35 <page_decref>
f010329a:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010329d:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01032a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032a4:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01032a9:	0f 85 29 ff ff ff    	jne    f01031d8 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01032af:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032b2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032b7:	77 15                	ja     f01032ce <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032b9:	50                   	push   %eax
f01032ba:	68 28 59 10 f0       	push   $0xf0105928
f01032bf:	68 f5 01 00 00       	push   $0x1f5
f01032c4:	68 d0 6b 10 f0       	push   $0xf0106bd0
f01032c9:	e8 72 cd ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01032ce:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032d5:	05 00 00 00 10       	add    $0x10000000,%eax
f01032da:	c1 e8 0c             	shr    $0xc,%eax
f01032dd:	3b 05 08 af 22 f0    	cmp    0xf022af08,%eax
f01032e3:	72 14                	jb     f01032f9 <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f01032e5:	83 ec 04             	sub    $0x4,%esp
f01032e8:	68 48 5f 10 f0       	push   $0xf0105f48
f01032ed:	6a 51                	push   $0x51
f01032ef:	68 bd 67 10 f0       	push   $0xf01067bd
f01032f4:	e8 47 cd ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f01032f9:	83 ec 0c             	sub    $0xc,%esp
f01032fc:	8b 15 10 af 22 f0    	mov    0xf022af10,%edx
f0103302:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103305:	50                   	push   %eax
f0103306:	e8 2a dc ff ff       	call   f0100f35 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010330b:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103312:	a1 4c a2 22 f0       	mov    0xf022a24c,%eax
f0103317:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010331a:	89 3d 4c a2 22 f0    	mov    %edi,0xf022a24c
}
f0103320:	83 c4 10             	add    $0x10,%esp
f0103323:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103326:	5b                   	pop    %ebx
f0103327:	5e                   	pop    %esi
f0103328:	5f                   	pop    %edi
f0103329:	5d                   	pop    %ebp
f010332a:	c3                   	ret    

f010332b <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010332b:	55                   	push   %ebp
f010332c:	89 e5                	mov    %esp,%ebp
f010332e:	53                   	push   %ebx
f010332f:	83 ec 04             	sub    $0x4,%esp
f0103332:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103335:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103339:	75 19                	jne    f0103354 <env_destroy+0x29>
f010333b:	e8 0e 1f 00 00       	call   f010524e <cpunum>
f0103340:	6b c0 74             	imul   $0x74,%eax,%eax
f0103343:	3b 98 28 b0 22 f0    	cmp    -0xfdd4fd8(%eax),%ebx
f0103349:	74 09                	je     f0103354 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f010334b:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103352:	eb 33                	jmp    f0103387 <env_destroy+0x5c>
	}

	env_free(e);
f0103354:	83 ec 0c             	sub    $0xc,%esp
f0103357:	53                   	push   %ebx
f0103358:	e8 f3 fd ff ff       	call   f0103150 <env_free>

	if (curenv == e) {
f010335d:	e8 ec 1e 00 00       	call   f010524e <cpunum>
f0103362:	6b c0 74             	imul   $0x74,%eax,%eax
f0103365:	83 c4 10             	add    $0x10,%esp
f0103368:	3b 98 28 b0 22 f0    	cmp    -0xfdd4fd8(%eax),%ebx
f010336e:	75 17                	jne    f0103387 <env_destroy+0x5c>
		curenv = NULL;
f0103370:	e8 d9 1e 00 00       	call   f010524e <cpunum>
f0103375:	6b c0 74             	imul   $0x74,%eax,%eax
f0103378:	c7 80 28 b0 22 f0 00 	movl   $0x0,-0xfdd4fd8(%eax)
f010337f:	00 00 00 
		sched_yield();
f0103382:	e8 31 0c 00 00       	call   f0103fb8 <sched_yield>
	}
}
f0103387:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010338a:	c9                   	leave  
f010338b:	c3                   	ret    

f010338c <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010338c:	55                   	push   %ebp
f010338d:	89 e5                	mov    %esp,%ebp
f010338f:	53                   	push   %ebx
f0103390:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103393:	e8 b6 1e 00 00       	call   f010524e <cpunum>
f0103398:	6b c0 74             	imul   $0x74,%eax,%eax
f010339b:	8b 98 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%ebx
f01033a1:	e8 a8 1e 00 00       	call   f010524e <cpunum>
f01033a6:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f01033a9:	8b 65 08             	mov    0x8(%ebp),%esp
f01033ac:	61                   	popa   
f01033ad:	07                   	pop    %es
f01033ae:	1f                   	pop    %ds
f01033af:	83 c4 08             	add    $0x8,%esp
f01033b2:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01033b3:	83 ec 04             	sub    $0x4,%esp
f01033b6:	68 25 6c 10 f0       	push   $0xf0106c25
f01033bb:	68 2b 02 00 00       	push   $0x22b
f01033c0:	68 d0 6b 10 f0       	push   $0xf0106bd0
f01033c5:	e8 76 cc ff ff       	call   f0100040 <_panic>

f01033ca <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01033ca:	55                   	push   %ebp
f01033cb:	89 e5                	mov    %esp,%ebp
f01033cd:	53                   	push   %ebx
f01033ce:	83 ec 04             	sub    $0x4,%esp
f01033d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv != e){
f01033d4:	e8 75 1e 00 00       	call   f010524e <cpunum>
f01033d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01033dc:	39 98 28 b0 22 f0    	cmp    %ebx,-0xfdd4fd8(%eax)
f01033e2:	0f 84 a4 00 00 00    	je     f010348c <env_run+0xc2>
	
		if (curenv != NULL && curenv->env_status == ENV_RUNNING){
f01033e8:	e8 61 1e 00 00       	call   f010524e <cpunum>
f01033ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01033f0:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f01033f7:	74 29                	je     f0103422 <env_run+0x58>
f01033f9:	e8 50 1e 00 00       	call   f010524e <cpunum>
f01033fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0103401:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103407:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010340b:	75 15                	jne    f0103422 <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f010340d:	e8 3c 1e 00 00       	call   f010524e <cpunum>
f0103412:	6b c0 74             	imul   $0x74,%eax,%eax
f0103415:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f010341b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		}
		curenv = e;
f0103422:	e8 27 1e 00 00       	call   f010524e <cpunum>
f0103427:	6b c0 74             	imul   $0x74,%eax,%eax
f010342a:	89 98 28 b0 22 f0    	mov    %ebx,-0xfdd4fd8(%eax)
		curenv->env_status = ENV_RUNNING;
f0103430:	e8 19 1e 00 00       	call   f010524e <cpunum>
f0103435:	6b c0 74             	imul   $0x74,%eax,%eax
f0103438:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f010343e:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f0103445:	e8 04 1e 00 00       	call   f010524e <cpunum>
f010344a:	6b c0 74             	imul   $0x74,%eax,%eax
f010344d:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103453:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f0103457:	e8 f2 1d 00 00       	call   f010524e <cpunum>
f010345c:	6b c0 74             	imul   $0x74,%eax,%eax
f010345f:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103465:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103468:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010346d:	77 15                	ja     f0103484 <env_run+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010346f:	50                   	push   %eax
f0103470:	68 28 59 10 f0       	push   $0xf0105928
f0103475:	68 51 02 00 00       	push   $0x251
f010347a:	68 d0 6b 10 f0       	push   $0xf0106bd0
f010347f:	e8 bc cb ff ff       	call   f0100040 <_panic>
f0103484:	05 00 00 00 10       	add    $0x10000000,%eax
f0103489:	0f 22 d8             	mov    %eax,%cr3
	}
	
	env_pop_tf(&e->env_tf);
f010348c:	83 ec 0c             	sub    $0xc,%esp
f010348f:	53                   	push   %ebx
f0103490:	e8 f7 fe ff ff       	call   f010338c <env_pop_tf>

f0103495 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103495:	55                   	push   %ebp
f0103496:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103498:	ba 70 00 00 00       	mov    $0x70,%edx
f010349d:	8b 45 08             	mov    0x8(%ebp),%eax
f01034a0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01034a1:	ba 71 00 00 00       	mov    $0x71,%edx
f01034a6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01034a7:	0f b6 c0             	movzbl %al,%eax
}
f01034aa:	5d                   	pop    %ebp
f01034ab:	c3                   	ret    

f01034ac <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01034ac:	55                   	push   %ebp
f01034ad:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034af:	ba 70 00 00 00       	mov    $0x70,%edx
f01034b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01034b7:	ee                   	out    %al,(%dx)
f01034b8:	ba 71 00 00 00       	mov    $0x71,%edx
f01034bd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034c0:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01034c1:	5d                   	pop    %ebp
f01034c2:	c3                   	ret    

f01034c3 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01034c3:	55                   	push   %ebp
f01034c4:	89 e5                	mov    %esp,%ebp
f01034c6:	56                   	push   %esi
f01034c7:	53                   	push   %ebx
f01034c8:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01034cb:	66 a3 88 f3 11 f0    	mov    %ax,0xf011f388
	if (!didinit)
f01034d1:	80 3d 50 a2 22 f0 00 	cmpb   $0x0,0xf022a250
f01034d8:	74 5a                	je     f0103534 <irq_setmask_8259A+0x71>
f01034da:	89 c6                	mov    %eax,%esi
f01034dc:	ba 21 00 00 00       	mov    $0x21,%edx
f01034e1:	ee                   	out    %al,(%dx)
f01034e2:	66 c1 e8 08          	shr    $0x8,%ax
f01034e6:	ba a1 00 00 00       	mov    $0xa1,%edx
f01034eb:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01034ec:	83 ec 0c             	sub    $0xc,%esp
f01034ef:	68 31 6c 10 f0       	push   $0xf0106c31
f01034f4:	e8 1b 01 00 00       	call   f0103614 <cprintf>
f01034f9:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01034fc:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103501:	0f b7 f6             	movzwl %si,%esi
f0103504:	f7 d6                	not    %esi
f0103506:	0f a3 de             	bt     %ebx,%esi
f0103509:	73 11                	jae    f010351c <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f010350b:	83 ec 08             	sub    $0x8,%esp
f010350e:	53                   	push   %ebx
f010350f:	68 05 71 10 f0       	push   $0xf0107105
f0103514:	e8 fb 00 00 00       	call   f0103614 <cprintf>
f0103519:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010351c:	83 c3 01             	add    $0x1,%ebx
f010351f:	83 fb 10             	cmp    $0x10,%ebx
f0103522:	75 e2                	jne    f0103506 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103524:	83 ec 0c             	sub    $0xc,%esp
f0103527:	68 b7 6a 10 f0       	push   $0xf0106ab7
f010352c:	e8 e3 00 00 00       	call   f0103614 <cprintf>
f0103531:	83 c4 10             	add    $0x10,%esp
}
f0103534:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103537:	5b                   	pop    %ebx
f0103538:	5e                   	pop    %esi
f0103539:	5d                   	pop    %ebp
f010353a:	c3                   	ret    

f010353b <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f010353b:	c6 05 50 a2 22 f0 01 	movb   $0x1,0xf022a250
f0103542:	ba 21 00 00 00       	mov    $0x21,%edx
f0103547:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010354c:	ee                   	out    %al,(%dx)
f010354d:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103552:	ee                   	out    %al,(%dx)
f0103553:	ba 20 00 00 00       	mov    $0x20,%edx
f0103558:	b8 11 00 00 00       	mov    $0x11,%eax
f010355d:	ee                   	out    %al,(%dx)
f010355e:	ba 21 00 00 00       	mov    $0x21,%edx
f0103563:	b8 20 00 00 00       	mov    $0x20,%eax
f0103568:	ee                   	out    %al,(%dx)
f0103569:	b8 04 00 00 00       	mov    $0x4,%eax
f010356e:	ee                   	out    %al,(%dx)
f010356f:	b8 03 00 00 00       	mov    $0x3,%eax
f0103574:	ee                   	out    %al,(%dx)
f0103575:	ba a0 00 00 00       	mov    $0xa0,%edx
f010357a:	b8 11 00 00 00       	mov    $0x11,%eax
f010357f:	ee                   	out    %al,(%dx)
f0103580:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103585:	b8 28 00 00 00       	mov    $0x28,%eax
f010358a:	ee                   	out    %al,(%dx)
f010358b:	b8 02 00 00 00       	mov    $0x2,%eax
f0103590:	ee                   	out    %al,(%dx)
f0103591:	b8 01 00 00 00       	mov    $0x1,%eax
f0103596:	ee                   	out    %al,(%dx)
f0103597:	ba 20 00 00 00       	mov    $0x20,%edx
f010359c:	b8 68 00 00 00       	mov    $0x68,%eax
f01035a1:	ee                   	out    %al,(%dx)
f01035a2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01035a7:	ee                   	out    %al,(%dx)
f01035a8:	ba a0 00 00 00       	mov    $0xa0,%edx
f01035ad:	b8 68 00 00 00       	mov    $0x68,%eax
f01035b2:	ee                   	out    %al,(%dx)
f01035b3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01035b8:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01035b9:	0f b7 05 88 f3 11 f0 	movzwl 0xf011f388,%eax
f01035c0:	66 83 f8 ff          	cmp    $0xffff,%ax
f01035c4:	74 13                	je     f01035d9 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01035c6:	55                   	push   %ebp
f01035c7:	89 e5                	mov    %esp,%ebp
f01035c9:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f01035cc:	0f b7 c0             	movzwl %ax,%eax
f01035cf:	50                   	push   %eax
f01035d0:	e8 ee fe ff ff       	call   f01034c3 <irq_setmask_8259A>
f01035d5:	83 c4 10             	add    $0x10,%esp
}
f01035d8:	c9                   	leave  
f01035d9:	f3 c3                	repz ret 

f01035db <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01035db:	55                   	push   %ebp
f01035dc:	89 e5                	mov    %esp,%ebp
f01035de:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01035e1:	ff 75 08             	pushl  0x8(%ebp)
f01035e4:	e8 55 d1 ff ff       	call   f010073e <cputchar>
	*cnt++;
}
f01035e9:	83 c4 10             	add    $0x10,%esp
f01035ec:	c9                   	leave  
f01035ed:	c3                   	ret    

f01035ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01035ee:	55                   	push   %ebp
f01035ef:	89 e5                	mov    %esp,%ebp
f01035f1:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01035f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01035fb:	ff 75 0c             	pushl  0xc(%ebp)
f01035fe:	ff 75 08             	pushl  0x8(%ebp)
f0103601:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103604:	50                   	push   %eax
f0103605:	68 db 35 10 f0       	push   $0xf01035db
f010360a:	e8 b2 0f 00 00       	call   f01045c1 <vprintfmt>
	return cnt;
}
f010360f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103612:	c9                   	leave  
f0103613:	c3                   	ret    

f0103614 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103614:	55                   	push   %ebp
f0103615:	89 e5                	mov    %esp,%ebp
f0103617:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010361a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010361d:	50                   	push   %eax
f010361e:	ff 75 08             	pushl  0x8(%ebp)
f0103621:	e8 c8 ff ff ff       	call   f01035ee <vcprintf>
	va_end(ap);

	return cnt;
}
f0103626:	c9                   	leave  
f0103627:	c3                   	ret    

f0103628 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103628:	55                   	push   %ebp
f0103629:	89 e5                	mov    %esp,%ebp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f010362b:	b8 80 aa 22 f0       	mov    $0xf022aa80,%eax
f0103630:	c7 05 84 aa 22 f0 00 	movl   $0xf0000000,0xf022aa84
f0103637:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010363a:	66 c7 05 88 aa 22 f0 	movw   $0x10,0xf022aa88
f0103641:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103643:	66 c7 05 48 f3 11 f0 	movw   $0x67,0xf011f348
f010364a:	67 00 
f010364c:	66 a3 4a f3 11 f0    	mov    %ax,0xf011f34a
f0103652:	89 c2                	mov    %eax,%edx
f0103654:	c1 ea 10             	shr    $0x10,%edx
f0103657:	88 15 4c f3 11 f0    	mov    %dl,0xf011f34c
f010365d:	c6 05 4e f3 11 f0 40 	movb   $0x40,0xf011f34e
f0103664:	c1 e8 18             	shr    $0x18,%eax
f0103667:	a2 4f f3 11 f0       	mov    %al,0xf011f34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f010366c:	c6 05 4d f3 11 f0 89 	movb   $0x89,0xf011f34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103673:	b8 28 00 00 00       	mov    $0x28,%eax
f0103678:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f010367b:	b8 8c f3 11 f0       	mov    $0xf011f38c,%eax
f0103680:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103683:	5d                   	pop    %ebp
f0103684:	c3                   	ret    

f0103685 <trap_init>:
}


void
trap_init(void)
{
f0103685:	55                   	push   %ebp
f0103686:	89 e5                	mov    %esp,%ebp
	void machine_check();
	void simd_floating_point_error();
	void system_call();
	
	
	SETGATE(idt[T_DIVIDE],1,GD_KT,divide_error,0);
f0103688:	b8 6e 3e 10 f0       	mov    $0xf0103e6e,%eax
f010368d:	66 a3 60 a2 22 f0    	mov    %ax,0xf022a260
f0103693:	66 c7 05 62 a2 22 f0 	movw   $0x8,0xf022a262
f010369a:	08 00 
f010369c:	c6 05 64 a2 22 f0 00 	movb   $0x0,0xf022a264
f01036a3:	c6 05 65 a2 22 f0 8f 	movb   $0x8f,0xf022a265
f01036aa:	c1 e8 10             	shr    $0x10,%eax
f01036ad:	66 a3 66 a2 22 f0    	mov    %ax,0xf022a266
	SETGATE(idt[T_DEBUG], 1, GD_KT, debug_exception, 0);
f01036b3:	b8 74 3e 10 f0       	mov    $0xf0103e74,%eax
f01036b8:	66 a3 68 a2 22 f0    	mov    %ax,0xf022a268
f01036be:	66 c7 05 6a a2 22 f0 	movw   $0x8,0xf022a26a
f01036c5:	08 00 
f01036c7:	c6 05 6c a2 22 f0 00 	movb   $0x0,0xf022a26c
f01036ce:	c6 05 6d a2 22 f0 8f 	movb   $0x8f,0xf022a26d
f01036d5:	c1 e8 10             	shr    $0x10,%eax
f01036d8:	66 a3 6e a2 22 f0    	mov    %ax,0xf022a26e
	SETGATE(idt[T_NMI], 1, GD_KT, non_maskable_interrupt, 0);
f01036de:	b8 7a 3e 10 f0       	mov    $0xf0103e7a,%eax
f01036e3:	66 a3 70 a2 22 f0    	mov    %ax,0xf022a270
f01036e9:	66 c7 05 72 a2 22 f0 	movw   $0x8,0xf022a272
f01036f0:	08 00 
f01036f2:	c6 05 74 a2 22 f0 00 	movb   $0x0,0xf022a274
f01036f9:	c6 05 75 a2 22 f0 8f 	movb   $0x8f,0xf022a275
f0103700:	c1 e8 10             	shr    $0x10,%eax
f0103703:	66 a3 76 a2 22 f0    	mov    %ax,0xf022a276
	SETGATE(idt[T_BRKPT], 1, GD_KT, break_point, 3);
f0103709:	b8 80 3e 10 f0       	mov    $0xf0103e80,%eax
f010370e:	66 a3 78 a2 22 f0    	mov    %ax,0xf022a278
f0103714:	66 c7 05 7a a2 22 f0 	movw   $0x8,0xf022a27a
f010371b:	08 00 
f010371d:	c6 05 7c a2 22 f0 00 	movb   $0x0,0xf022a27c
f0103724:	c6 05 7d a2 22 f0 ef 	movb   $0xef,0xf022a27d
f010372b:	c1 e8 10             	shr    $0x10,%eax
f010372e:	66 a3 7e a2 22 f0    	mov    %ax,0xf022a27e
	SETGATE(idt[T_OFLOW], 1, GD_KT, over_flow, 0);
f0103734:	b8 86 3e 10 f0       	mov    $0xf0103e86,%eax
f0103739:	66 a3 80 a2 22 f0    	mov    %ax,0xf022a280
f010373f:	66 c7 05 82 a2 22 f0 	movw   $0x8,0xf022a282
f0103746:	08 00 
f0103748:	c6 05 84 a2 22 f0 00 	movb   $0x0,0xf022a284
f010374f:	c6 05 85 a2 22 f0 8f 	movb   $0x8f,0xf022a285
f0103756:	c1 e8 10             	shr    $0x10,%eax
f0103759:	66 a3 86 a2 22 f0    	mov    %ax,0xf022a286
	SETGATE(idt[T_BOUND], 1, GD_KT, bounds_check, 0);
f010375f:	b8 8c 3e 10 f0       	mov    $0xf0103e8c,%eax
f0103764:	66 a3 88 a2 22 f0    	mov    %ax,0xf022a288
f010376a:	66 c7 05 8a a2 22 f0 	movw   $0x8,0xf022a28a
f0103771:	08 00 
f0103773:	c6 05 8c a2 22 f0 00 	movb   $0x0,0xf022a28c
f010377a:	c6 05 8d a2 22 f0 8f 	movb   $0x8f,0xf022a28d
f0103781:	c1 e8 10             	shr    $0x10,%eax
f0103784:	66 a3 8e a2 22 f0    	mov    %ax,0xf022a28e
	SETGATE(idt[T_ILLOP], 1, GD_KT, illegal_opcode, 0);
f010378a:	b8 92 3e 10 f0       	mov    $0xf0103e92,%eax
f010378f:	66 a3 90 a2 22 f0    	mov    %ax,0xf022a290
f0103795:	66 c7 05 92 a2 22 f0 	movw   $0x8,0xf022a292
f010379c:	08 00 
f010379e:	c6 05 94 a2 22 f0 00 	movb   $0x0,0xf022a294
f01037a5:	c6 05 95 a2 22 f0 8f 	movb   $0x8f,0xf022a295
f01037ac:	c1 e8 10             	shr    $0x10,%eax
f01037af:	66 a3 96 a2 22 f0    	mov    %ax,0xf022a296
	SETGATE(idt[T_DEVICE], 1, GD_KT, device_not_available, 0);
f01037b5:	b8 98 3e 10 f0       	mov    $0xf0103e98,%eax
f01037ba:	66 a3 98 a2 22 f0    	mov    %ax,0xf022a298
f01037c0:	66 c7 05 9a a2 22 f0 	movw   $0x8,0xf022a29a
f01037c7:	08 00 
f01037c9:	c6 05 9c a2 22 f0 00 	movb   $0x0,0xf022a29c
f01037d0:	c6 05 9d a2 22 f0 8f 	movb   $0x8f,0xf022a29d
f01037d7:	c1 e8 10             	shr    $0x10,%eax
f01037da:	66 a3 9e a2 22 f0    	mov    %ax,0xf022a29e
	SETGATE(idt[T_DBLFLT], 1, GD_KT, double_fault, 0);
f01037e0:	b8 9e 3e 10 f0       	mov    $0xf0103e9e,%eax
f01037e5:	66 a3 a0 a2 22 f0    	mov    %ax,0xf022a2a0
f01037eb:	66 c7 05 a2 a2 22 f0 	movw   $0x8,0xf022a2a2
f01037f2:	08 00 
f01037f4:	c6 05 a4 a2 22 f0 00 	movb   $0x0,0xf022a2a4
f01037fb:	c6 05 a5 a2 22 f0 8f 	movb   $0x8f,0xf022a2a5
f0103802:	c1 e8 10             	shr    $0x10,%eax
f0103805:	66 a3 a6 a2 22 f0    	mov    %ax,0xf022a2a6
	SETGATE(idt[T_TSS], 1, GD_KT, task_segment_switch, 0);
f010380b:	b8 a2 3e 10 f0       	mov    $0xf0103ea2,%eax
f0103810:	66 a3 b0 a2 22 f0    	mov    %ax,0xf022a2b0
f0103816:	66 c7 05 b2 a2 22 f0 	movw   $0x8,0xf022a2b2
f010381d:	08 00 
f010381f:	c6 05 b4 a2 22 f0 00 	movb   $0x0,0xf022a2b4
f0103826:	c6 05 b5 a2 22 f0 8f 	movb   $0x8f,0xf022a2b5
f010382d:	c1 e8 10             	shr    $0x10,%eax
f0103830:	66 a3 b6 a2 22 f0    	mov    %ax,0xf022a2b6
	SETGATE(idt[T_SEGNP], 1, GD_KT, segment_not_present, 0);
f0103836:	b8 a6 3e 10 f0       	mov    $0xf0103ea6,%eax
f010383b:	66 a3 b8 a2 22 f0    	mov    %ax,0xf022a2b8
f0103841:	66 c7 05 ba a2 22 f0 	movw   $0x8,0xf022a2ba
f0103848:	08 00 
f010384a:	c6 05 bc a2 22 f0 00 	movb   $0x0,0xf022a2bc
f0103851:	c6 05 bd a2 22 f0 8f 	movb   $0x8f,0xf022a2bd
f0103858:	c1 e8 10             	shr    $0x10,%eax
f010385b:	66 a3 be a2 22 f0    	mov    %ax,0xf022a2be
	SETGATE(idt[T_STACK], 1, GD_KT, stack_exception, 0);
f0103861:	b8 aa 3e 10 f0       	mov    $0xf0103eaa,%eax
f0103866:	66 a3 c0 a2 22 f0    	mov    %ax,0xf022a2c0
f010386c:	66 c7 05 c2 a2 22 f0 	movw   $0x8,0xf022a2c2
f0103873:	08 00 
f0103875:	c6 05 c4 a2 22 f0 00 	movb   $0x0,0xf022a2c4
f010387c:	c6 05 c5 a2 22 f0 8f 	movb   $0x8f,0xf022a2c5
f0103883:	c1 e8 10             	shr    $0x10,%eax
f0103886:	66 a3 c6 a2 22 f0    	mov    %ax,0xf022a2c6
	SETGATE(idt[T_GPFLT], 1, GD_KT, general_protection_fault, 0);
f010388c:	b8 ae 3e 10 f0       	mov    $0xf0103eae,%eax
f0103891:	66 a3 c8 a2 22 f0    	mov    %ax,0xf022a2c8
f0103897:	66 c7 05 ca a2 22 f0 	movw   $0x8,0xf022a2ca
f010389e:	08 00 
f01038a0:	c6 05 cc a2 22 f0 00 	movb   $0x0,0xf022a2cc
f01038a7:	c6 05 cd a2 22 f0 8f 	movb   $0x8f,0xf022a2cd
f01038ae:	c1 e8 10             	shr    $0x10,%eax
f01038b1:	66 a3 ce a2 22 f0    	mov    %ax,0xf022a2ce
	SETGATE(idt[T_PGFLT], 1, GD_KT, page_fault, 0);
f01038b7:	b8 b2 3e 10 f0       	mov    $0xf0103eb2,%eax
f01038bc:	66 a3 d0 a2 22 f0    	mov    %ax,0xf022a2d0
f01038c2:	66 c7 05 d2 a2 22 f0 	movw   $0x8,0xf022a2d2
f01038c9:	08 00 
f01038cb:	c6 05 d4 a2 22 f0 00 	movb   $0x0,0xf022a2d4
f01038d2:	c6 05 d5 a2 22 f0 8f 	movb   $0x8f,0xf022a2d5
f01038d9:	c1 e8 10             	shr    $0x10,%eax
f01038dc:	66 a3 d6 a2 22 f0    	mov    %ax,0xf022a2d6
	SETGATE(idt[T_FPERR], 1, GD_KT, floating_point_error, 0);
f01038e2:	b8 b6 3e 10 f0       	mov    $0xf0103eb6,%eax
f01038e7:	66 a3 e0 a2 22 f0    	mov    %ax,0xf022a2e0
f01038ed:	66 c7 05 e2 a2 22 f0 	movw   $0x8,0xf022a2e2
f01038f4:	08 00 
f01038f6:	c6 05 e4 a2 22 f0 00 	movb   $0x0,0xf022a2e4
f01038fd:	c6 05 e5 a2 22 f0 8f 	movb   $0x8f,0xf022a2e5
f0103904:	c1 e8 10             	shr    $0x10,%eax
f0103907:	66 a3 e6 a2 22 f0    	mov    %ax,0xf022a2e6
	SETGATE(idt[T_ALIGN], 1, GD_KT, alignment_check , 0);
f010390d:	b8 bc 3e 10 f0       	mov    $0xf0103ebc,%eax
f0103912:	66 a3 e8 a2 22 f0    	mov    %ax,0xf022a2e8
f0103918:	66 c7 05 ea a2 22 f0 	movw   $0x8,0xf022a2ea
f010391f:	08 00 
f0103921:	c6 05 ec a2 22 f0 00 	movb   $0x0,0xf022a2ec
f0103928:	c6 05 ed a2 22 f0 8f 	movb   $0x8f,0xf022a2ed
f010392f:	c1 e8 10             	shr    $0x10,%eax
f0103932:	66 a3 ee a2 22 f0    	mov    %ax,0xf022a2ee
	SETGATE(idt[T_MCHK], 1, GD_KT, machine_check, 0);
f0103938:	b8 c0 3e 10 f0       	mov    $0xf0103ec0,%eax
f010393d:	66 a3 f0 a2 22 f0    	mov    %ax,0xf022a2f0
f0103943:	66 c7 05 f2 a2 22 f0 	movw   $0x8,0xf022a2f2
f010394a:	08 00 
f010394c:	c6 05 f4 a2 22 f0 00 	movb   $0x0,0xf022a2f4
f0103953:	c6 05 f5 a2 22 f0 8f 	movb   $0x8f,0xf022a2f5
f010395a:	c1 e8 10             	shr    $0x10,%eax
f010395d:	66 a3 f6 a2 22 f0    	mov    %ax,0xf022a2f6
	SETGATE(idt[T_SIMDERR], 1, GD_KT, simd_floating_point_error, 0);
f0103963:	b8 c6 3e 10 f0       	mov    $0xf0103ec6,%eax
f0103968:	66 a3 f8 a2 22 f0    	mov    %ax,0xf022a2f8
f010396e:	66 c7 05 fa a2 22 f0 	movw   $0x8,0xf022a2fa
f0103975:	08 00 
f0103977:	c6 05 fc a2 22 f0 00 	movb   $0x0,0xf022a2fc
f010397e:	c6 05 fd a2 22 f0 8f 	movb   $0x8f,0xf022a2fd
f0103985:	c1 e8 10             	shr    $0x10,%eax
f0103988:	66 a3 fe a2 22 f0    	mov    %ax,0xf022a2fe
	SETGATE(idt[T_SYSCALL], 1 , GD_KT, system_call, 3);
f010398e:	b8 cc 3e 10 f0       	mov    $0xf0103ecc,%eax
f0103993:	66 a3 e0 a3 22 f0    	mov    %ax,0xf022a3e0
f0103999:	66 c7 05 e2 a3 22 f0 	movw   $0x8,0xf022a3e2
f01039a0:	08 00 
f01039a2:	c6 05 e4 a3 22 f0 00 	movb   $0x0,0xf022a3e4
f01039a9:	c6 05 e5 a3 22 f0 ef 	movb   $0xef,0xf022a3e5
f01039b0:	c1 e8 10             	shr    $0x10,%eax
f01039b3:	66 a3 e6 a3 22 f0    	mov    %ax,0xf022a3e6
	
	// Per-CPU setup 
	trap_init_percpu();
f01039b9:	e8 6a fc ff ff       	call   f0103628 <trap_init_percpu>
}
f01039be:	5d                   	pop    %ebp
f01039bf:	c3                   	ret    

f01039c0 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01039c0:	55                   	push   %ebp
f01039c1:	89 e5                	mov    %esp,%ebp
f01039c3:	53                   	push   %ebx
f01039c4:	83 ec 0c             	sub    $0xc,%esp
f01039c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01039ca:	ff 33                	pushl  (%ebx)
f01039cc:	68 45 6c 10 f0       	push   $0xf0106c45
f01039d1:	e8 3e fc ff ff       	call   f0103614 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01039d6:	83 c4 08             	add    $0x8,%esp
f01039d9:	ff 73 04             	pushl  0x4(%ebx)
f01039dc:	68 54 6c 10 f0       	push   $0xf0106c54
f01039e1:	e8 2e fc ff ff       	call   f0103614 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01039e6:	83 c4 08             	add    $0x8,%esp
f01039e9:	ff 73 08             	pushl  0x8(%ebx)
f01039ec:	68 63 6c 10 f0       	push   $0xf0106c63
f01039f1:	e8 1e fc ff ff       	call   f0103614 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01039f6:	83 c4 08             	add    $0x8,%esp
f01039f9:	ff 73 0c             	pushl  0xc(%ebx)
f01039fc:	68 72 6c 10 f0       	push   $0xf0106c72
f0103a01:	e8 0e fc ff ff       	call   f0103614 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103a06:	83 c4 08             	add    $0x8,%esp
f0103a09:	ff 73 10             	pushl  0x10(%ebx)
f0103a0c:	68 81 6c 10 f0       	push   $0xf0106c81
f0103a11:	e8 fe fb ff ff       	call   f0103614 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103a16:	83 c4 08             	add    $0x8,%esp
f0103a19:	ff 73 14             	pushl  0x14(%ebx)
f0103a1c:	68 90 6c 10 f0       	push   $0xf0106c90
f0103a21:	e8 ee fb ff ff       	call   f0103614 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103a26:	83 c4 08             	add    $0x8,%esp
f0103a29:	ff 73 18             	pushl  0x18(%ebx)
f0103a2c:	68 9f 6c 10 f0       	push   $0xf0106c9f
f0103a31:	e8 de fb ff ff       	call   f0103614 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103a36:	83 c4 08             	add    $0x8,%esp
f0103a39:	ff 73 1c             	pushl  0x1c(%ebx)
f0103a3c:	68 ae 6c 10 f0       	push   $0xf0106cae
f0103a41:	e8 ce fb ff ff       	call   f0103614 <cprintf>
}
f0103a46:	83 c4 10             	add    $0x10,%esp
f0103a49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a4c:	c9                   	leave  
f0103a4d:	c3                   	ret    

f0103a4e <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103a4e:	55                   	push   %ebp
f0103a4f:	89 e5                	mov    %esp,%ebp
f0103a51:	56                   	push   %esi
f0103a52:	53                   	push   %ebx
f0103a53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103a56:	e8 f3 17 00 00       	call   f010524e <cpunum>
f0103a5b:	83 ec 04             	sub    $0x4,%esp
f0103a5e:	50                   	push   %eax
f0103a5f:	53                   	push   %ebx
f0103a60:	68 12 6d 10 f0       	push   $0xf0106d12
f0103a65:	e8 aa fb ff ff       	call   f0103614 <cprintf>
	print_regs(&tf->tf_regs);
f0103a6a:	89 1c 24             	mov    %ebx,(%esp)
f0103a6d:	e8 4e ff ff ff       	call   f01039c0 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103a72:	83 c4 08             	add    $0x8,%esp
f0103a75:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103a79:	50                   	push   %eax
f0103a7a:	68 30 6d 10 f0       	push   $0xf0106d30
f0103a7f:	e8 90 fb ff ff       	call   f0103614 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103a84:	83 c4 08             	add    $0x8,%esp
f0103a87:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103a8b:	50                   	push   %eax
f0103a8c:	68 43 6d 10 f0       	push   $0xf0106d43
f0103a91:	e8 7e fb ff ff       	call   f0103614 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103a96:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103a99:	83 c4 10             	add    $0x10,%esp
f0103a9c:	83 f8 13             	cmp    $0x13,%eax
f0103a9f:	77 09                	ja     f0103aaa <print_trapframe+0x5c>
		return excnames[trapno];
f0103aa1:	8b 14 85 20 70 10 f0 	mov    -0xfef8fe0(,%eax,4),%edx
f0103aa8:	eb 1f                	jmp    f0103ac9 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103aaa:	83 f8 30             	cmp    $0x30,%eax
f0103aad:	74 15                	je     f0103ac4 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103aaf:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103ab2:	83 fa 10             	cmp    $0x10,%edx
f0103ab5:	b9 dc 6c 10 f0       	mov    $0xf0106cdc,%ecx
f0103aba:	ba c9 6c 10 f0       	mov    $0xf0106cc9,%edx
f0103abf:	0f 43 d1             	cmovae %ecx,%edx
f0103ac2:	eb 05                	jmp    f0103ac9 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103ac4:	ba bd 6c 10 f0       	mov    $0xf0106cbd,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ac9:	83 ec 04             	sub    $0x4,%esp
f0103acc:	52                   	push   %edx
f0103acd:	50                   	push   %eax
f0103ace:	68 56 6d 10 f0       	push   $0xf0106d56
f0103ad3:	e8 3c fb ff ff       	call   f0103614 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103ad8:	83 c4 10             	add    $0x10,%esp
f0103adb:	3b 1d 60 aa 22 f0    	cmp    0xf022aa60,%ebx
f0103ae1:	75 1a                	jne    f0103afd <print_trapframe+0xaf>
f0103ae3:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ae7:	75 14                	jne    f0103afd <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103ae9:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103aec:	83 ec 08             	sub    $0x8,%esp
f0103aef:	50                   	push   %eax
f0103af0:	68 68 6d 10 f0       	push   $0xf0106d68
f0103af5:	e8 1a fb ff ff       	call   f0103614 <cprintf>
f0103afa:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103afd:	83 ec 08             	sub    $0x8,%esp
f0103b00:	ff 73 2c             	pushl  0x2c(%ebx)
f0103b03:	68 77 6d 10 f0       	push   $0xf0106d77
f0103b08:	e8 07 fb ff ff       	call   f0103614 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103b0d:	83 c4 10             	add    $0x10,%esp
f0103b10:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103b14:	75 49                	jne    f0103b5f <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103b16:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103b19:	89 c2                	mov    %eax,%edx
f0103b1b:	83 e2 01             	and    $0x1,%edx
f0103b1e:	ba f6 6c 10 f0       	mov    $0xf0106cf6,%edx
f0103b23:	b9 eb 6c 10 f0       	mov    $0xf0106ceb,%ecx
f0103b28:	0f 44 ca             	cmove  %edx,%ecx
f0103b2b:	89 c2                	mov    %eax,%edx
f0103b2d:	83 e2 02             	and    $0x2,%edx
f0103b30:	ba 08 6d 10 f0       	mov    $0xf0106d08,%edx
f0103b35:	be 02 6d 10 f0       	mov    $0xf0106d02,%esi
f0103b3a:	0f 45 d6             	cmovne %esi,%edx
f0103b3d:	83 e0 04             	and    $0x4,%eax
f0103b40:	be 68 6e 10 f0       	mov    $0xf0106e68,%esi
f0103b45:	b8 0d 6d 10 f0       	mov    $0xf0106d0d,%eax
f0103b4a:	0f 44 c6             	cmove  %esi,%eax
f0103b4d:	51                   	push   %ecx
f0103b4e:	52                   	push   %edx
f0103b4f:	50                   	push   %eax
f0103b50:	68 85 6d 10 f0       	push   $0xf0106d85
f0103b55:	e8 ba fa ff ff       	call   f0103614 <cprintf>
f0103b5a:	83 c4 10             	add    $0x10,%esp
f0103b5d:	eb 10                	jmp    f0103b6f <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103b5f:	83 ec 0c             	sub    $0xc,%esp
f0103b62:	68 b7 6a 10 f0       	push   $0xf0106ab7
f0103b67:	e8 a8 fa ff ff       	call   f0103614 <cprintf>
f0103b6c:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103b6f:	83 ec 08             	sub    $0x8,%esp
f0103b72:	ff 73 30             	pushl  0x30(%ebx)
f0103b75:	68 94 6d 10 f0       	push   $0xf0106d94
f0103b7a:	e8 95 fa ff ff       	call   f0103614 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103b7f:	83 c4 08             	add    $0x8,%esp
f0103b82:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103b86:	50                   	push   %eax
f0103b87:	68 a3 6d 10 f0       	push   $0xf0106da3
f0103b8c:	e8 83 fa ff ff       	call   f0103614 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103b91:	83 c4 08             	add    $0x8,%esp
f0103b94:	ff 73 38             	pushl  0x38(%ebx)
f0103b97:	68 b6 6d 10 f0       	push   $0xf0106db6
f0103b9c:	e8 73 fa ff ff       	call   f0103614 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103ba1:	83 c4 10             	add    $0x10,%esp
f0103ba4:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103ba8:	74 25                	je     f0103bcf <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103baa:	83 ec 08             	sub    $0x8,%esp
f0103bad:	ff 73 3c             	pushl  0x3c(%ebx)
f0103bb0:	68 c5 6d 10 f0       	push   $0xf0106dc5
f0103bb5:	e8 5a fa ff ff       	call   f0103614 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103bba:	83 c4 08             	add    $0x8,%esp
f0103bbd:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103bc1:	50                   	push   %eax
f0103bc2:	68 d4 6d 10 f0       	push   $0xf0106dd4
f0103bc7:	e8 48 fa ff ff       	call   f0103614 <cprintf>
f0103bcc:	83 c4 10             	add    $0x10,%esp
	}
}
f0103bcf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103bd2:	5b                   	pop    %ebx
f0103bd3:	5e                   	pop    %esi
f0103bd4:	5d                   	pop    %ebp
f0103bd5:	c3                   	ret    

f0103bd6 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103bd6:	55                   	push   %ebp
f0103bd7:	89 e5                	mov    %esp,%ebp
f0103bd9:	57                   	push   %edi
f0103bda:	56                   	push   %esi
f0103bdb:	53                   	push   %ebx
f0103bdc:	83 ec 0c             	sub    $0xc,%esp
f0103bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103be2:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs== GD_KT)
f0103be5:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0103bea:	75 17                	jne    f0103c03 <page_fault_handler+0x2d>
		panic("page_fault_handler: Page Fault in Kernel");
f0103bec:	83 ec 04             	sub    $0x4,%esp
f0103bef:	68 b4 6f 10 f0       	push   $0xf0106fb4
f0103bf4:	68 4e 01 00 00       	push   $0x14e
f0103bf9:	68 e7 6d 10 f0       	push   $0xf0106de7
f0103bfe:	e8 3d c4 ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103c03:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103c06:	e8 43 16 00 00       	call   f010524e <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103c0b:	57                   	push   %edi
f0103c0c:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103c0d:	6b c0 74             	imul   $0x74,%eax,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103c10:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103c16:	ff 70 48             	pushl  0x48(%eax)
f0103c19:	68 e0 6f 10 f0       	push   $0xf0106fe0
f0103c1e:	e8 f1 f9 ff ff       	call   f0103614 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103c23:	89 1c 24             	mov    %ebx,(%esp)
f0103c26:	e8 23 fe ff ff       	call   f0103a4e <print_trapframe>
	env_destroy(curenv);
f0103c2b:	e8 1e 16 00 00       	call   f010524e <cpunum>
f0103c30:	83 c4 04             	add    $0x4,%esp
f0103c33:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c36:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0103c3c:	e8 ea f6 ff ff       	call   f010332b <env_destroy>
}
f0103c41:	83 c4 10             	add    $0x10,%esp
f0103c44:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103c47:	5b                   	pop    %ebx
f0103c48:	5e                   	pop    %esi
f0103c49:	5f                   	pop    %edi
f0103c4a:	5d                   	pop    %ebp
f0103c4b:	c3                   	ret    

f0103c4c <trap>:
	
}

void
trap(struct Trapframe *tf)
{
f0103c4c:	55                   	push   %ebp
f0103c4d:	89 e5                	mov    %esp,%ebp
f0103c4f:	57                   	push   %edi
f0103c50:	56                   	push   %esi
f0103c51:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103c54:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103c55:	83 3d 00 af 22 f0 00 	cmpl   $0x0,0xf022af00
f0103c5c:	74 01                	je     f0103c5f <trap+0x13>
		asm volatile("hlt");
f0103c5e:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103c5f:	e8 ea 15 00 00       	call   f010524e <cpunum>
f0103c64:	6b d0 74             	imul   $0x74,%eax,%edx
f0103c67:	81 c2 20 b0 22 f0    	add    $0xf022b020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103c6d:	b8 01 00 00 00       	mov    $0x1,%eax
f0103c72:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103c76:	83 f8 02             	cmp    $0x2,%eax
f0103c79:	75 10                	jne    f0103c8b <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103c7b:	83 ec 0c             	sub    $0xc,%esp
f0103c7e:	68 a0 f3 11 f0       	push   $0xf011f3a0
f0103c83:	e8 34 18 00 00       	call   f01054bc <spin_lock>
f0103c88:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103c8b:	9c                   	pushf  
f0103c8c:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103c8d:	f6 c4 02             	test   $0x2,%ah
f0103c90:	74 19                	je     f0103cab <trap+0x5f>
f0103c92:	68 f3 6d 10 f0       	push   $0xf0106df3
f0103c97:	68 d7 67 10 f0       	push   $0xf01067d7
f0103c9c:	68 19 01 00 00       	push   $0x119
f0103ca1:	68 e7 6d 10 f0       	push   $0xf0106de7
f0103ca6:	e8 95 c3 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103cab:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103caf:	83 e0 03             	and    $0x3,%eax
f0103cb2:	66 83 f8 03          	cmp    $0x3,%ax
f0103cb6:	0f 85 90 00 00 00    	jne    f0103d4c <trap+0x100>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0103cbc:	e8 8d 15 00 00       	call   f010524e <cpunum>
f0103cc1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cc4:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f0103ccb:	75 19                	jne    f0103ce6 <trap+0x9a>
f0103ccd:	68 0c 6e 10 f0       	push   $0xf0106e0c
f0103cd2:	68 d7 67 10 f0       	push   $0xf01067d7
f0103cd7:	68 20 01 00 00       	push   $0x120
f0103cdc:	68 e7 6d 10 f0       	push   $0xf0106de7
f0103ce1:	e8 5a c3 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103ce6:	e8 63 15 00 00       	call   f010524e <cpunum>
f0103ceb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cee:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103cf4:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103cf8:	75 2d                	jne    f0103d27 <trap+0xdb>
			env_free(curenv);
f0103cfa:	e8 4f 15 00 00       	call   f010524e <cpunum>
f0103cff:	83 ec 0c             	sub    $0xc,%esp
f0103d02:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d05:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0103d0b:	e8 40 f4 ff ff       	call   f0103150 <env_free>
			curenv = NULL;
f0103d10:	e8 39 15 00 00       	call   f010524e <cpunum>
f0103d15:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d18:	c7 80 28 b0 22 f0 00 	movl   $0x0,-0xfdd4fd8(%eax)
f0103d1f:	00 00 00 
			sched_yield();
f0103d22:	e8 91 02 00 00       	call   f0103fb8 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103d27:	e8 22 15 00 00       	call   f010524e <cpunum>
f0103d2c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d2f:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103d35:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103d3a:	89 c7                	mov    %eax,%edi
f0103d3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103d3e:	e8 0b 15 00 00       	call   f010524e <cpunum>
f0103d43:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d46:	8b b0 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103d4c:	89 35 60 aa 22 f0    	mov    %esi,0xf022aa60


	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103d52:	8b 46 28             	mov    0x28(%esi),%eax
f0103d55:	83 f8 27             	cmp    $0x27,%eax
f0103d58:	75 1d                	jne    f0103d77 <trap+0x12b>
		cprintf("Spurious interrupt on irq 7\n");
f0103d5a:	83 ec 0c             	sub    $0xc,%esp
f0103d5d:	68 13 6e 10 f0       	push   $0xf0106e13
f0103d62:	e8 ad f8 ff ff       	call   f0103614 <cprintf>
		print_trapframe(tf);
f0103d67:	89 34 24             	mov    %esi,(%esp)
f0103d6a:	e8 df fc ff ff       	call   f0103a4e <print_trapframe>
f0103d6f:	83 c4 10             	add    $0x10,%esp
f0103d72:	e9 b7 00 00 00       	jmp    f0103e2e <trap+0x1e2>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	if (tf->tf_trapno == T_PGFLT) {
f0103d77:	83 f8 0e             	cmp    $0xe,%eax
f0103d7a:	75 1d                	jne    f0103d99 <trap+0x14d>
		cprintf("PAGE FAULT\n");
f0103d7c:	83 ec 0c             	sub    $0xc,%esp
f0103d7f:	68 30 6e 10 f0       	push   $0xf0106e30
f0103d84:	e8 8b f8 ff ff       	call   f0103614 <cprintf>
		page_fault_handler(tf);
f0103d89:	89 34 24             	mov    %esi,(%esp)
f0103d8c:	e8 45 fe ff ff       	call   f0103bd6 <page_fault_handler>
f0103d91:	83 c4 10             	add    $0x10,%esp
f0103d94:	e9 95 00 00 00       	jmp    f0103e2e <trap+0x1e2>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f0103d99:	83 f8 03             	cmp    $0x3,%eax
f0103d9c:	75 1a                	jne    f0103db8 <trap+0x16c>
		cprintf("BREAK POINT\n");
f0103d9e:	83 ec 0c             	sub    $0xc,%esp
f0103da1:	68 3c 6e 10 f0       	push   $0xf0106e3c
f0103da6:	e8 69 f8 ff ff       	call   f0103614 <cprintf>
		monitor(tf);
f0103dab:	89 34 24             	mov    %esi,(%esp)
f0103dae:	e8 2f cb ff ff       	call   f01008e2 <monitor>
f0103db3:	83 c4 10             	add    $0x10,%esp
f0103db6:	eb 76                	jmp    f0103e2e <trap+0x1e2>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f0103db8:	83 f8 30             	cmp    $0x30,%eax
f0103dbb:	75 2e                	jne    f0103deb <trap+0x19f>
		cprintf("SYSTEM CALL\n");
f0103dbd:	83 ec 0c             	sub    $0xc,%esp
f0103dc0:	68 49 6e 10 f0       	push   $0xf0106e49
f0103dc5:	e8 4a f8 ff ff       	call   f0103614 <cprintf>
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0103dca:	83 c4 08             	add    $0x8,%esp
f0103dcd:	ff 76 04             	pushl  0x4(%esi)
f0103dd0:	ff 36                	pushl  (%esi)
f0103dd2:	ff 76 10             	pushl  0x10(%esi)
f0103dd5:	ff 76 18             	pushl  0x18(%esi)
f0103dd8:	ff 76 14             	pushl  0x14(%esi)
f0103ddb:	ff 76 1c             	pushl  0x1c(%esi)
f0103dde:	e8 e2 01 00 00       	call   f0103fc5 <syscall>
		monitor(tf);
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
		cprintf("SYSTEM CALL\n");
		tf->tf_regs.reg_eax = 
f0103de3:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103de6:	83 c4 20             	add    $0x20,%esp
f0103de9:	eb 43                	jmp    f0103e2e <trap+0x1e2>
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}
	
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103deb:	83 ec 0c             	sub    $0xc,%esp
f0103dee:	56                   	push   %esi
f0103def:	e8 5a fc ff ff       	call   f0103a4e <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103df4:	83 c4 10             	add    $0x10,%esp
f0103df7:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103dfc:	75 17                	jne    f0103e15 <trap+0x1c9>
		panic("unhandled trap in kernel");
f0103dfe:	83 ec 04             	sub    $0x4,%esp
f0103e01:	68 56 6e 10 f0       	push   $0xf0106e56
f0103e06:	68 fd 00 00 00       	push   $0xfd
f0103e0b:	68 e7 6d 10 f0       	push   $0xf0106de7
f0103e10:	e8 2b c2 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0103e15:	e8 34 14 00 00       	call   f010524e <cpunum>
f0103e1a:	83 ec 0c             	sub    $0xc,%esp
f0103e1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e20:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0103e26:	e8 00 f5 ff ff       	call   f010332b <env_destroy>
f0103e2b:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103e2e:	e8 1b 14 00 00       	call   f010524e <cpunum>
f0103e33:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e36:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f0103e3d:	74 2a                	je     f0103e69 <trap+0x21d>
f0103e3f:	e8 0a 14 00 00       	call   f010524e <cpunum>
f0103e44:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e47:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103e4d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103e51:	75 16                	jne    f0103e69 <trap+0x21d>
		env_run(curenv);
f0103e53:	e8 f6 13 00 00       	call   f010524e <cpunum>
f0103e58:	83 ec 0c             	sub    $0xc,%esp
f0103e5b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e5e:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0103e64:	e8 61 f5 ff ff       	call   f01033ca <env_run>
	else
		sched_yield();
f0103e69:	e8 4a 01 00 00       	call   f0103fb8 <sched_yield>

f0103e6e <divide_error>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

	TRAPHANDLER_NOEC(divide_error, 0)
f0103e6e:	6a 00                	push   $0x0
f0103e70:	6a 00                	push   $0x0
f0103e72:	eb 5e                	jmp    f0103ed2 <_alltraps>

f0103e74 <debug_exception>:
        TRAPHANDLER_NOEC(debug_exception, 1)
f0103e74:	6a 00                	push   $0x0
f0103e76:	6a 01                	push   $0x1
f0103e78:	eb 58                	jmp    f0103ed2 <_alltraps>

f0103e7a <non_maskable_interrupt>:
        TRAPHANDLER_NOEC(non_maskable_interrupt, 2)    
f0103e7a:	6a 00                	push   $0x0
f0103e7c:	6a 02                	push   $0x2
f0103e7e:	eb 52                	jmp    f0103ed2 <_alltraps>

f0103e80 <break_point>:
        TRAPHANDLER_NOEC(break_point, 3)
f0103e80:	6a 00                	push   $0x0
f0103e82:	6a 03                	push   $0x3
f0103e84:	eb 4c                	jmp    f0103ed2 <_alltraps>

f0103e86 <over_flow>:
        TRAPHANDLER_NOEC(over_flow, 4)
f0103e86:	6a 00                	push   $0x0
f0103e88:	6a 04                	push   $0x4
f0103e8a:	eb 46                	jmp    f0103ed2 <_alltraps>

f0103e8c <bounds_check>:
        TRAPHANDLER_NOEC(bounds_check, 5)
f0103e8c:	6a 00                	push   $0x0
f0103e8e:	6a 05                	push   $0x5
f0103e90:	eb 40                	jmp    f0103ed2 <_alltraps>

f0103e92 <illegal_opcode>:
        TRAPHANDLER_NOEC(illegal_opcode, 6)
f0103e92:	6a 00                	push   $0x0
f0103e94:	6a 06                	push   $0x6
f0103e96:	eb 3a                	jmp    f0103ed2 <_alltraps>

f0103e98 <device_not_available>:
        TRAPHANDLER_NOEC(device_not_available, 7)
f0103e98:	6a 00                	push   $0x0
f0103e9a:	6a 07                	push   $0x7
f0103e9c:	eb 34                	jmp    f0103ed2 <_alltraps>

f0103e9e <double_fault>:
        TRAPHANDLER(double_fault, 8)
f0103e9e:	6a 08                	push   $0x8
f0103ea0:	eb 30                	jmp    f0103ed2 <_alltraps>

f0103ea2 <task_segment_switch>:
    
        TRAPHANDLER(task_segment_switch, 10)
f0103ea2:	6a 0a                	push   $0xa
f0103ea4:	eb 2c                	jmp    f0103ed2 <_alltraps>

f0103ea6 <segment_not_present>:
        TRAPHANDLER(segment_not_present, 11)
f0103ea6:	6a 0b                	push   $0xb
f0103ea8:	eb 28                	jmp    f0103ed2 <_alltraps>

f0103eaa <stack_exception>:
        TRAPHANDLER(stack_exception, 12)
f0103eaa:	6a 0c                	push   $0xc
f0103eac:	eb 24                	jmp    f0103ed2 <_alltraps>

f0103eae <general_protection_fault>:
        TRAPHANDLER(general_protection_fault, 13)
f0103eae:	6a 0d                	push   $0xd
f0103eb0:	eb 20                	jmp    f0103ed2 <_alltraps>

f0103eb2 <page_fault>:
        TRAPHANDLER(page_fault, 14)
f0103eb2:	6a 0e                	push   $0xe
f0103eb4:	eb 1c                	jmp    f0103ed2 <_alltraps>

f0103eb6 <floating_point_error>:
    
        TRAPHANDLER_NOEC(floating_point_error, 16)
f0103eb6:	6a 00                	push   $0x0
f0103eb8:	6a 10                	push   $0x10
f0103eba:	eb 16                	jmp    f0103ed2 <_alltraps>

f0103ebc <alignment_check>:
        TRAPHANDLER(alignment_check, 17)
f0103ebc:	6a 11                	push   $0x11
f0103ebe:	eb 12                	jmp    f0103ed2 <_alltraps>

f0103ec0 <machine_check>:
        TRAPHANDLER_NOEC(machine_check, 18)
f0103ec0:	6a 00                	push   $0x0
f0103ec2:	6a 12                	push   $0x12
f0103ec4:	eb 0c                	jmp    f0103ed2 <_alltraps>

f0103ec6 <simd_floating_point_error>:
        TRAPHANDLER_NOEC(simd_floating_point_error, 19)
f0103ec6:	6a 00                	push   $0x0
f0103ec8:	6a 13                	push   $0x13
f0103eca:	eb 06                	jmp    f0103ed2 <_alltraps>

f0103ecc <system_call>:
        TRAPHANDLER_NOEC(system_call, 48)
f0103ecc:	6a 00                	push   $0x0
f0103ece:	6a 30                	push   $0x30
f0103ed0:	eb 00                	jmp    f0103ed2 <_alltraps>

f0103ed2 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
   
    pushl %ds
f0103ed2:	1e                   	push   %ds
    
    pushl %es
f0103ed3:	06                   	push   %es
    
    pushal
f0103ed4:	60                   	pusha  
    
    movl $GD_KD,%eax
f0103ed5:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax,%ds
f0103eda:	8e d8                	mov    %eax,%ds
    movw %ax,%es   
f0103edc:	8e c0                	mov    %eax,%es
    
    pushl %esp
f0103ede:	54                   	push   %esp
    call trap
f0103edf:	e8 68 fd ff ff       	call   f0103c4c <trap>

f0103ee4 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0103ee4:	55                   	push   %ebp
f0103ee5:	89 e5                	mov    %esp,%ebp
f0103ee7:	83 ec 08             	sub    $0x8,%esp
f0103eea:	a1 48 a2 22 f0       	mov    0xf022a248,%eax
f0103eef:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103ef2:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0103ef7:	8b 02                	mov    (%edx),%eax
f0103ef9:	83 e8 01             	sub    $0x1,%eax
f0103efc:	83 f8 02             	cmp    $0x2,%eax
f0103eff:	76 10                	jbe    f0103f11 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103f01:	83 c1 01             	add    $0x1,%ecx
f0103f04:	83 c2 7c             	add    $0x7c,%edx
f0103f07:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103f0d:	75 e8                	jne    f0103ef7 <sched_halt+0x13>
f0103f0f:	eb 08                	jmp    f0103f19 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0103f11:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103f17:	75 1f                	jne    f0103f38 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0103f19:	83 ec 0c             	sub    $0xc,%esp
f0103f1c:	68 70 70 10 f0       	push   $0xf0107070
f0103f21:	e8 ee f6 ff ff       	call   f0103614 <cprintf>
f0103f26:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0103f29:	83 ec 0c             	sub    $0xc,%esp
f0103f2c:	6a 00                	push   $0x0
f0103f2e:	e8 af c9 ff ff       	call   f01008e2 <monitor>
f0103f33:	83 c4 10             	add    $0x10,%esp
f0103f36:	eb f1                	jmp    f0103f29 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0103f38:	e8 11 13 00 00       	call   f010524e <cpunum>
f0103f3d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f40:	c7 80 28 b0 22 f0 00 	movl   $0x0,-0xfdd4fd8(%eax)
f0103f47:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0103f4a:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f4f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f54:	77 12                	ja     f0103f68 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f56:	50                   	push   %eax
f0103f57:	68 28 59 10 f0       	push   $0xf0105928
f0103f5c:	6a 3d                	push   $0x3d
f0103f5e:	68 99 70 10 f0       	push   $0xf0107099
f0103f63:	e8 d8 c0 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103f68:	05 00 00 00 10       	add    $0x10000000,%eax
f0103f6d:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0103f70:	e8 d9 12 00 00       	call   f010524e <cpunum>
f0103f75:	6b d0 74             	imul   $0x74,%eax,%edx
f0103f78:	81 c2 20 b0 22 f0    	add    $0xf022b020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103f7e:	b8 02 00 00 00       	mov    $0x2,%eax
f0103f83:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103f87:	83 ec 0c             	sub    $0xc,%esp
f0103f8a:	68 a0 f3 11 f0       	push   $0xf011f3a0
f0103f8f:	e8 c5 15 00 00       	call   f0105559 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103f94:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0103f96:	e8 b3 12 00 00       	call   f010524e <cpunum>
f0103f9b:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0103f9e:	8b 80 30 b0 22 f0    	mov    -0xfdd4fd0(%eax),%eax
f0103fa4:	bd 00 00 00 00       	mov    $0x0,%ebp
f0103fa9:	89 c4                	mov    %eax,%esp
f0103fab:	6a 00                	push   $0x0
f0103fad:	6a 00                	push   $0x0
f0103faf:	fb                   	sti    
f0103fb0:	f4                   	hlt    
f0103fb1:	eb fd                	jmp    f0103fb0 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0103fb3:	83 c4 10             	add    $0x10,%esp
f0103fb6:	c9                   	leave  
f0103fb7:	c3                   	ret    

f0103fb8 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0103fb8:	55                   	push   %ebp
f0103fb9:	89 e5                	mov    %esp,%ebp
f0103fbb:	83 ec 08             	sub    $0x8,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.

	// sched_halt never returns
	sched_halt();
f0103fbe:	e8 21 ff ff ff       	call   f0103ee4 <sched_halt>
}
f0103fc3:	c9                   	leave  
f0103fc4:	c3                   	ret    

f0103fc5 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103fc5:	55                   	push   %ebp
f0103fc6:	89 e5                	mov    %esp,%ebp
f0103fc8:	53                   	push   %ebx
f0103fc9:	83 ec 14             	sub    $0x14,%esp
f0103fcc:	8b 45 08             	mov    0x8(%ebp),%eax
	// LAB 3: Your code here.

	//panic("syscall not implemented");
	int32_t ret = 0;
	
	switch (syscallno) {
f0103fcf:	83 f8 01             	cmp    $0x1,%eax
f0103fd2:	74 4f                	je     f0104023 <syscall+0x5e>
f0103fd4:	83 f8 01             	cmp    $0x1,%eax
f0103fd7:	72 0f                	jb     f0103fe8 <syscall+0x23>
f0103fd9:	83 f8 02             	cmp    $0x2,%eax
f0103fdc:	74 4f                	je     f010402d <syscall+0x68>
f0103fde:	83 f8 03             	cmp    $0x3,%eax
f0103fe1:	74 60                	je     f0104043 <syscall+0x7e>
f0103fe3:	e9 e3 00 00 00       	jmp    f01040cb <syscall+0x106>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (void *)s, len, PTE_U);
f0103fe8:	e8 61 12 00 00       	call   f010524e <cpunum>
f0103fed:	6a 04                	push   $0x4
f0103fef:	ff 75 10             	pushl  0x10(%ebp)
f0103ff2:	ff 75 0c             	pushl  0xc(%ebp)
f0103ff5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff8:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0103ffe:	e8 46 ec ff ff       	call   f0102c49 <user_mem_assert>
	
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104003:	83 c4 0c             	add    $0xc,%esp
f0104006:	ff 75 0c             	pushl  0xc(%ebp)
f0104009:	ff 75 10             	pushl  0x10(%ebp)
f010400c:	68 a6 70 10 f0       	push   $0xf01070a6
f0104011:	e8 fe f5 ff ff       	call   f0103614 <cprintf>
f0104016:	83 c4 10             	add    $0x10,%esp
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");
	int32_t ret = 0;
f0104019:	b8 00 00 00 00       	mov    $0x0,%eax
f010401e:	e9 ad 00 00 00       	jmp    f01040d0 <syscall+0x10b>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104023:	e8 a7 c5 ff ff       	call   f01005cf <cons_getc>
			sys_cputs((const char *)a1, a2);
			break;
			
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
f0104028:	e9 a3 00 00 00       	jmp    f01040d0 <syscall+0x10b>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010402d:	e8 1c 12 00 00       	call   f010524e <cpunum>
f0104032:	6b c0 74             	imul   $0x74,%eax,%eax
f0104035:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f010403b:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
f010403e:	e9 8d 00 00 00       	jmp    f01040d0 <syscall+0x10b>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104043:	83 ec 04             	sub    $0x4,%esp
f0104046:	6a 01                	push   $0x1
f0104048:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010404b:	50                   	push   %eax
f010404c:	ff 75 0c             	pushl  0xc(%ebp)
f010404f:	e8 e0 ec ff ff       	call   f0102d34 <envid2env>
f0104054:	83 c4 10             	add    $0x10,%esp
f0104057:	85 c0                	test   %eax,%eax
f0104059:	78 75                	js     f01040d0 <syscall+0x10b>
		return r;
	if (e == curenv)
f010405b:	e8 ee 11 00 00       	call   f010524e <cpunum>
f0104060:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104063:	6b c0 74             	imul   $0x74,%eax,%eax
f0104066:	39 90 28 b0 22 f0    	cmp    %edx,-0xfdd4fd8(%eax)
f010406c:	75 23                	jne    f0104091 <syscall+0xcc>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010406e:	e8 db 11 00 00       	call   f010524e <cpunum>
f0104073:	83 ec 08             	sub    $0x8,%esp
f0104076:	6b c0 74             	imul   $0x74,%eax,%eax
f0104079:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f010407f:	ff 70 48             	pushl  0x48(%eax)
f0104082:	68 ab 70 10 f0       	push   $0xf01070ab
f0104087:	e8 88 f5 ff ff       	call   f0103614 <cprintf>
f010408c:	83 c4 10             	add    $0x10,%esp
f010408f:	eb 25                	jmp    f01040b6 <syscall+0xf1>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104091:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104094:	e8 b5 11 00 00       	call   f010524e <cpunum>
f0104099:	83 ec 04             	sub    $0x4,%esp
f010409c:	53                   	push   %ebx
f010409d:	6b c0 74             	imul   $0x74,%eax,%eax
f01040a0:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f01040a6:	ff 70 48             	pushl  0x48(%eax)
f01040a9:	68 c6 70 10 f0       	push   $0xf01070c6
f01040ae:	e8 61 f5 ff ff       	call   f0103614 <cprintf>
f01040b3:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01040b6:	83 ec 0c             	sub    $0xc,%esp
f01040b9:	ff 75 f4             	pushl  -0xc(%ebp)
f01040bc:	e8 6a f2 ff ff       	call   f010332b <env_destroy>
f01040c1:	83 c4 10             	add    $0x10,%esp
	return 0;
f01040c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01040c9:	eb 05                	jmp    f01040d0 <syscall+0x10b>
		case SYS_env_destroy:
			ret = sys_env_destroy((envid_t)a1);
			break;
		case NSYSCALLS:		
		default:
			return -E_INVAL;
f01040cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	return ret;
}
f01040d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01040d3:	c9                   	leave  
f01040d4:	c3                   	ret    

f01040d5 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01040d5:	55                   	push   %ebp
f01040d6:	89 e5                	mov    %esp,%ebp
f01040d8:	57                   	push   %edi
f01040d9:	56                   	push   %esi
f01040da:	53                   	push   %ebx
f01040db:	83 ec 14             	sub    $0x14,%esp
f01040de:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01040e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01040e4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01040e7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01040ea:	8b 1a                	mov    (%edx),%ebx
f01040ec:	8b 01                	mov    (%ecx),%eax
f01040ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01040f1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01040f8:	eb 7f                	jmp    f0104179 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01040fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01040fd:	01 d8                	add    %ebx,%eax
f01040ff:	89 c6                	mov    %eax,%esi
f0104101:	c1 ee 1f             	shr    $0x1f,%esi
f0104104:	01 c6                	add    %eax,%esi
f0104106:	d1 fe                	sar    %esi
f0104108:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010410b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010410e:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104111:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104113:	eb 03                	jmp    f0104118 <stab_binsearch+0x43>
			m--;
f0104115:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104118:	39 c3                	cmp    %eax,%ebx
f010411a:	7f 0d                	jg     f0104129 <stab_binsearch+0x54>
f010411c:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104120:	83 ea 0c             	sub    $0xc,%edx
f0104123:	39 f9                	cmp    %edi,%ecx
f0104125:	75 ee                	jne    f0104115 <stab_binsearch+0x40>
f0104127:	eb 05                	jmp    f010412e <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104129:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f010412c:	eb 4b                	jmp    f0104179 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010412e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104131:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104134:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104138:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010413b:	76 11                	jbe    f010414e <stab_binsearch+0x79>
			*region_left = m;
f010413d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104140:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104142:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104145:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010414c:	eb 2b                	jmp    f0104179 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010414e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104151:	73 14                	jae    f0104167 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104153:	83 e8 01             	sub    $0x1,%eax
f0104156:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104159:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010415c:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010415e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104165:	eb 12                	jmp    f0104179 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104167:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010416a:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010416c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104170:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104172:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104179:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010417c:	0f 8e 78 ff ff ff    	jle    f01040fa <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104182:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104186:	75 0f                	jne    f0104197 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010418b:	8b 00                	mov    (%eax),%eax
f010418d:	83 e8 01             	sub    $0x1,%eax
f0104190:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104193:	89 06                	mov    %eax,(%esi)
f0104195:	eb 2c                	jmp    f01041c3 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104197:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010419a:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010419c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010419f:	8b 0e                	mov    (%esi),%ecx
f01041a1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01041a4:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01041a7:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01041aa:	eb 03                	jmp    f01041af <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01041ac:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01041af:	39 c8                	cmp    %ecx,%eax
f01041b1:	7e 0b                	jle    f01041be <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01041b3:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01041b7:	83 ea 0c             	sub    $0xc,%edx
f01041ba:	39 df                	cmp    %ebx,%edi
f01041bc:	75 ee                	jne    f01041ac <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01041be:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01041c1:	89 06                	mov    %eax,(%esi)
	}
}
f01041c3:	83 c4 14             	add    $0x14,%esp
f01041c6:	5b                   	pop    %ebx
f01041c7:	5e                   	pop    %esi
f01041c8:	5f                   	pop    %edi
f01041c9:	5d                   	pop    %ebp
f01041ca:	c3                   	ret    

f01041cb <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01041cb:	55                   	push   %ebp
f01041cc:	89 e5                	mov    %esp,%ebp
f01041ce:	57                   	push   %edi
f01041cf:	56                   	push   %esi
f01041d0:	53                   	push   %ebx
f01041d1:	83 ec 3c             	sub    $0x3c,%esp
f01041d4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01041d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01041da:	c7 03 de 70 10 f0    	movl   $0xf01070de,(%ebx)
	info->eip_line = 0;
f01041e0:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01041e7:	c7 43 08 de 70 10 f0 	movl   $0xf01070de,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01041ee:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01041f5:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01041f8:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01041ff:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104205:	0f 87 a3 00 00 00    	ja     f01042ae <debuginfo_eip+0xe3>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;
		
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U | PTE_P))
f010420b:	e8 3e 10 00 00       	call   f010524e <cpunum>
f0104210:	6a 05                	push   $0x5
f0104212:	6a 10                	push   $0x10
f0104214:	68 00 00 20 00       	push   $0x200000
f0104219:	6b c0 74             	imul   $0x74,%eax,%eax
f010421c:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0104222:	e8 9a e9 ff ff       	call   f0102bc1 <user_mem_check>
f0104227:	83 c4 10             	add    $0x10,%esp
f010422a:	85 c0                	test   %eax,%eax
f010422c:	0f 85 35 02 00 00    	jne    f0104467 <debuginfo_eip+0x29c>
			return -1;

		
		stabs = usd->stabs;
f0104232:	a1 00 00 20 00       	mov    0x200000,%eax
f0104237:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f010423a:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104240:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104246:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104249:	a1 0c 00 20 00       	mov    0x20000c,%eax
f010424e:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U | PTE_P) )
f0104251:	e8 f8 0f 00 00       	call   f010524e <cpunum>
f0104256:	6a 05                	push   $0x5
f0104258:	89 f2                	mov    %esi,%edx
f010425a:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010425d:	29 ca                	sub    %ecx,%edx
f010425f:	c1 fa 02             	sar    $0x2,%edx
f0104262:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104268:	52                   	push   %edx
f0104269:	51                   	push   %ecx
f010426a:	6b c0 74             	imul   $0x74,%eax,%eax
f010426d:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0104273:	e8 49 e9 ff ff       	call   f0102bc1 <user_mem_check>
f0104278:	83 c4 10             	add    $0x10,%esp
f010427b:	85 c0                	test   %eax,%eax
f010427d:	0f 85 eb 01 00 00    	jne    f010446e <debuginfo_eip+0x2a3>
			return -1;
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U | PTE_P) )
f0104283:	e8 c6 0f 00 00       	call   f010524e <cpunum>
f0104288:	6a 05                	push   $0x5
f010428a:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010428d:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104290:	29 ca                	sub    %ecx,%edx
f0104292:	52                   	push   %edx
f0104293:	51                   	push   %ecx
f0104294:	6b c0 74             	imul   $0x74,%eax,%eax
f0104297:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f010429d:	e8 1f e9 ff ff       	call   f0102bc1 <user_mem_check>
f01042a2:	83 c4 10             	add    $0x10,%esp
f01042a5:	85 c0                	test   %eax,%eax
f01042a7:	74 1f                	je     f01042c8 <debuginfo_eip+0xfd>
f01042a9:	e9 c7 01 00 00       	jmp    f0104475 <debuginfo_eip+0x2aa>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01042ae:	c7 45 bc c4 42 11 f0 	movl   $0xf01142c4,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01042b5:	c7 45 b8 91 0c 11 f0 	movl   $0xf0110c91,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01042bc:	be 90 0c 11 f0       	mov    $0xf0110c90,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01042c1:	c7 45 c0 b8 75 10 f0 	movl   $0xf01075b8,-0x40(%ebp)
			return -1;

	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01042c8:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01042cb:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f01042ce:	0f 83 a8 01 00 00    	jae    f010447c <debuginfo_eip+0x2b1>
f01042d4:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01042d8:	0f 85 a5 01 00 00    	jne    f0104483 <debuginfo_eip+0x2b8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01042de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01042e5:	2b 75 c0             	sub    -0x40(%ebp),%esi
f01042e8:	c1 fe 02             	sar    $0x2,%esi
f01042eb:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f01042f1:	83 e8 01             	sub    $0x1,%eax
f01042f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01042f7:	83 ec 08             	sub    $0x8,%esp
f01042fa:	57                   	push   %edi
f01042fb:	6a 64                	push   $0x64
f01042fd:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104300:	89 d1                	mov    %edx,%ecx
f0104302:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104305:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104308:	89 f0                	mov    %esi,%eax
f010430a:	e8 c6 fd ff ff       	call   f01040d5 <stab_binsearch>
	if (lfile == 0)
f010430f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104312:	83 c4 10             	add    $0x10,%esp
f0104315:	85 c0                	test   %eax,%eax
f0104317:	0f 84 6d 01 00 00    	je     f010448a <debuginfo_eip+0x2bf>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010431d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104320:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104323:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104326:	83 ec 08             	sub    $0x8,%esp
f0104329:	57                   	push   %edi
f010432a:	6a 24                	push   $0x24
f010432c:	8d 55 d8             	lea    -0x28(%ebp),%edx
f010432f:	89 d1                	mov    %edx,%ecx
f0104331:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104334:	89 f0                	mov    %esi,%eax
f0104336:	e8 9a fd ff ff       	call   f01040d5 <stab_binsearch>

	if (lfun <= rfun) {
f010433b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010433e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104341:	83 c4 10             	add    $0x10,%esp
f0104344:	39 d0                	cmp    %edx,%eax
f0104346:	7f 2e                	jg     f0104376 <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104348:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f010434b:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f010434e:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104351:	8b 36                	mov    (%esi),%esi
f0104353:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104356:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104359:	39 ce                	cmp    %ecx,%esi
f010435b:	73 06                	jae    f0104363 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010435d:	03 75 b8             	add    -0x48(%ebp),%esi
f0104360:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104363:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104366:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104369:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010436c:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f010436e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104371:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104374:	eb 0f                	jmp    f0104385 <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104376:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104379:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010437c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010437f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104382:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104385:	83 ec 08             	sub    $0x8,%esp
f0104388:	6a 3a                	push   $0x3a
f010438a:	ff 73 08             	pushl  0x8(%ebx)
f010438d:	e8 7f 08 00 00       	call   f0104c11 <strfind>
f0104392:	2b 43 08             	sub    0x8(%ebx),%eax
f0104395:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104398:	83 c4 08             	add    $0x8,%esp
f010439b:	57                   	push   %edi
f010439c:	6a 44                	push   $0x44
f010439e:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01043a1:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01043a4:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01043a7:	89 f8                	mov    %edi,%eax
f01043a9:	e8 27 fd ff ff       	call   f01040d5 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f01043ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01043b1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01043b4:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01043b7:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f01043bb:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01043be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01043c1:	83 c4 10             	add    $0x10,%esp
f01043c4:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01043c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01043cb:	eb 0a                	jmp    f01043d7 <debuginfo_eip+0x20c>
f01043cd:	83 e8 01             	sub    $0x1,%eax
f01043d0:	83 ea 0c             	sub    $0xc,%edx
f01043d3:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01043d7:	39 c7                	cmp    %eax,%edi
f01043d9:	7e 05                	jle    f01043e0 <debuginfo_eip+0x215>
f01043db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01043de:	eb 47                	jmp    f0104427 <debuginfo_eip+0x25c>
	       && stabs[lline].n_type != N_SOL
f01043e0:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01043e4:	80 f9 84             	cmp    $0x84,%cl
f01043e7:	75 0e                	jne    f01043f7 <debuginfo_eip+0x22c>
f01043e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01043ec:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01043f0:	74 1c                	je     f010440e <debuginfo_eip+0x243>
f01043f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01043f5:	eb 17                	jmp    f010440e <debuginfo_eip+0x243>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01043f7:	80 f9 64             	cmp    $0x64,%cl
f01043fa:	75 d1                	jne    f01043cd <debuginfo_eip+0x202>
f01043fc:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104400:	74 cb                	je     f01043cd <debuginfo_eip+0x202>
f0104402:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104405:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104409:	74 03                	je     f010440e <debuginfo_eip+0x243>
f010440b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010440e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104411:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104414:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104417:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010441a:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010441d:	29 f8                	sub    %edi,%eax
f010441f:	39 c2                	cmp    %eax,%edx
f0104421:	73 04                	jae    f0104427 <debuginfo_eip+0x25c>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104423:	01 fa                	add    %edi,%edx
f0104425:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104427:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010442a:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010442d:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104432:	39 f2                	cmp    %esi,%edx
f0104434:	7d 60                	jge    f0104496 <debuginfo_eip+0x2cb>
		for (lline = lfun + 1;
f0104436:	83 c2 01             	add    $0x1,%edx
f0104439:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010443c:	89 d0                	mov    %edx,%eax
f010443e:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104441:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104444:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104447:	eb 04                	jmp    f010444d <debuginfo_eip+0x282>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104449:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010444d:	39 c6                	cmp    %eax,%esi
f010444f:	7e 40                	jle    f0104491 <debuginfo_eip+0x2c6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104451:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104455:	83 c0 01             	add    $0x1,%eax
f0104458:	83 c2 0c             	add    $0xc,%edx
f010445b:	80 f9 a0             	cmp    $0xa0,%cl
f010445e:	74 e9                	je     f0104449 <debuginfo_eip+0x27e>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104460:	b8 00 00 00 00       	mov    $0x0,%eax
f0104465:	eb 2f                	jmp    f0104496 <debuginfo_eip+0x2cb>
		
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U | PTE_P))
			return -1;
f0104467:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010446c:	eb 28                	jmp    f0104496 <debuginfo_eip+0x2cb>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U | PTE_P) )
			return -1;
f010446e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104473:	eb 21                	jmp    f0104496 <debuginfo_eip+0x2cb>
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U | PTE_P) )
			return -1;
f0104475:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010447a:	eb 1a                	jmp    f0104496 <debuginfo_eip+0x2cb>

	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010447c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104481:	eb 13                	jmp    f0104496 <debuginfo_eip+0x2cb>
f0104483:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104488:	eb 0c                	jmp    f0104496 <debuginfo_eip+0x2cb>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010448a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010448f:	eb 05                	jmp    f0104496 <debuginfo_eip+0x2cb>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104491:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104496:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104499:	5b                   	pop    %ebx
f010449a:	5e                   	pop    %esi
f010449b:	5f                   	pop    %edi
f010449c:	5d                   	pop    %ebp
f010449d:	c3                   	ret    

f010449e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010449e:	55                   	push   %ebp
f010449f:	89 e5                	mov    %esp,%ebp
f01044a1:	57                   	push   %edi
f01044a2:	56                   	push   %esi
f01044a3:	53                   	push   %ebx
f01044a4:	83 ec 1c             	sub    $0x1c,%esp
f01044a7:	89 c7                	mov    %eax,%edi
f01044a9:	89 d6                	mov    %edx,%esi
f01044ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01044ae:	8b 55 0c             	mov    0xc(%ebp),%edx
f01044b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01044b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01044b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01044ba:	bb 00 00 00 00       	mov    $0x0,%ebx
f01044bf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01044c2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01044c5:	39 d3                	cmp    %edx,%ebx
f01044c7:	72 05                	jb     f01044ce <printnum+0x30>
f01044c9:	39 45 10             	cmp    %eax,0x10(%ebp)
f01044cc:	77 45                	ja     f0104513 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01044ce:	83 ec 0c             	sub    $0xc,%esp
f01044d1:	ff 75 18             	pushl  0x18(%ebp)
f01044d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01044d7:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01044da:	53                   	push   %ebx
f01044db:	ff 75 10             	pushl  0x10(%ebp)
f01044de:	83 ec 08             	sub    $0x8,%esp
f01044e1:	ff 75 e4             	pushl  -0x1c(%ebp)
f01044e4:	ff 75 e0             	pushl  -0x20(%ebp)
f01044e7:	ff 75 dc             	pushl  -0x24(%ebp)
f01044ea:	ff 75 d8             	pushl  -0x28(%ebp)
f01044ed:	e8 5e 11 00 00       	call   f0105650 <__udivdi3>
f01044f2:	83 c4 18             	add    $0x18,%esp
f01044f5:	52                   	push   %edx
f01044f6:	50                   	push   %eax
f01044f7:	89 f2                	mov    %esi,%edx
f01044f9:	89 f8                	mov    %edi,%eax
f01044fb:	e8 9e ff ff ff       	call   f010449e <printnum>
f0104500:	83 c4 20             	add    $0x20,%esp
f0104503:	eb 18                	jmp    f010451d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104505:	83 ec 08             	sub    $0x8,%esp
f0104508:	56                   	push   %esi
f0104509:	ff 75 18             	pushl  0x18(%ebp)
f010450c:	ff d7                	call   *%edi
f010450e:	83 c4 10             	add    $0x10,%esp
f0104511:	eb 03                	jmp    f0104516 <printnum+0x78>
f0104513:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104516:	83 eb 01             	sub    $0x1,%ebx
f0104519:	85 db                	test   %ebx,%ebx
f010451b:	7f e8                	jg     f0104505 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010451d:	83 ec 08             	sub    $0x8,%esp
f0104520:	56                   	push   %esi
f0104521:	83 ec 04             	sub    $0x4,%esp
f0104524:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104527:	ff 75 e0             	pushl  -0x20(%ebp)
f010452a:	ff 75 dc             	pushl  -0x24(%ebp)
f010452d:	ff 75 d8             	pushl  -0x28(%ebp)
f0104530:	e8 4b 12 00 00       	call   f0105780 <__umoddi3>
f0104535:	83 c4 14             	add    $0x14,%esp
f0104538:	0f be 80 e8 70 10 f0 	movsbl -0xfef8f18(%eax),%eax
f010453f:	50                   	push   %eax
f0104540:	ff d7                	call   *%edi
}
f0104542:	83 c4 10             	add    $0x10,%esp
f0104545:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104548:	5b                   	pop    %ebx
f0104549:	5e                   	pop    %esi
f010454a:	5f                   	pop    %edi
f010454b:	5d                   	pop    %ebp
f010454c:	c3                   	ret    

f010454d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010454d:	55                   	push   %ebp
f010454e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104550:	83 fa 01             	cmp    $0x1,%edx
f0104553:	7e 0e                	jle    f0104563 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104555:	8b 10                	mov    (%eax),%edx
f0104557:	8d 4a 08             	lea    0x8(%edx),%ecx
f010455a:	89 08                	mov    %ecx,(%eax)
f010455c:	8b 02                	mov    (%edx),%eax
f010455e:	8b 52 04             	mov    0x4(%edx),%edx
f0104561:	eb 22                	jmp    f0104585 <getuint+0x38>
	else if (lflag)
f0104563:	85 d2                	test   %edx,%edx
f0104565:	74 10                	je     f0104577 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104567:	8b 10                	mov    (%eax),%edx
f0104569:	8d 4a 04             	lea    0x4(%edx),%ecx
f010456c:	89 08                	mov    %ecx,(%eax)
f010456e:	8b 02                	mov    (%edx),%eax
f0104570:	ba 00 00 00 00       	mov    $0x0,%edx
f0104575:	eb 0e                	jmp    f0104585 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104577:	8b 10                	mov    (%eax),%edx
f0104579:	8d 4a 04             	lea    0x4(%edx),%ecx
f010457c:	89 08                	mov    %ecx,(%eax)
f010457e:	8b 02                	mov    (%edx),%eax
f0104580:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104585:	5d                   	pop    %ebp
f0104586:	c3                   	ret    

f0104587 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104587:	55                   	push   %ebp
f0104588:	89 e5                	mov    %esp,%ebp
f010458a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010458d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104591:	8b 10                	mov    (%eax),%edx
f0104593:	3b 50 04             	cmp    0x4(%eax),%edx
f0104596:	73 0a                	jae    f01045a2 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104598:	8d 4a 01             	lea    0x1(%edx),%ecx
f010459b:	89 08                	mov    %ecx,(%eax)
f010459d:	8b 45 08             	mov    0x8(%ebp),%eax
f01045a0:	88 02                	mov    %al,(%edx)
}
f01045a2:	5d                   	pop    %ebp
f01045a3:	c3                   	ret    

f01045a4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01045a4:	55                   	push   %ebp
f01045a5:	89 e5                	mov    %esp,%ebp
f01045a7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01045aa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01045ad:	50                   	push   %eax
f01045ae:	ff 75 10             	pushl  0x10(%ebp)
f01045b1:	ff 75 0c             	pushl  0xc(%ebp)
f01045b4:	ff 75 08             	pushl  0x8(%ebp)
f01045b7:	e8 05 00 00 00       	call   f01045c1 <vprintfmt>
	va_end(ap);
}
f01045bc:	83 c4 10             	add    $0x10,%esp
f01045bf:	c9                   	leave  
f01045c0:	c3                   	ret    

f01045c1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01045c1:	55                   	push   %ebp
f01045c2:	89 e5                	mov    %esp,%ebp
f01045c4:	57                   	push   %edi
f01045c5:	56                   	push   %esi
f01045c6:	53                   	push   %ebx
f01045c7:	83 ec 2c             	sub    $0x2c,%esp
f01045ca:	8b 75 08             	mov    0x8(%ebp),%esi
f01045cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01045d0:	8b 7d 10             	mov    0x10(%ebp),%edi
f01045d3:	eb 12                	jmp    f01045e7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01045d5:	85 c0                	test   %eax,%eax
f01045d7:	0f 84 89 03 00 00    	je     f0104966 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f01045dd:	83 ec 08             	sub    $0x8,%esp
f01045e0:	53                   	push   %ebx
f01045e1:	50                   	push   %eax
f01045e2:	ff d6                	call   *%esi
f01045e4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01045e7:	83 c7 01             	add    $0x1,%edi
f01045ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01045ee:	83 f8 25             	cmp    $0x25,%eax
f01045f1:	75 e2                	jne    f01045d5 <vprintfmt+0x14>
f01045f3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01045f7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01045fe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104605:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f010460c:	ba 00 00 00 00       	mov    $0x0,%edx
f0104611:	eb 07                	jmp    f010461a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104613:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104616:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010461a:	8d 47 01             	lea    0x1(%edi),%eax
f010461d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104620:	0f b6 07             	movzbl (%edi),%eax
f0104623:	0f b6 c8             	movzbl %al,%ecx
f0104626:	83 e8 23             	sub    $0x23,%eax
f0104629:	3c 55                	cmp    $0x55,%al
f010462b:	0f 87 1a 03 00 00    	ja     f010494b <vprintfmt+0x38a>
f0104631:	0f b6 c0             	movzbl %al,%eax
f0104634:	ff 24 85 a0 71 10 f0 	jmp    *-0xfef8e60(,%eax,4)
f010463b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010463e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104642:	eb d6                	jmp    f010461a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104647:	b8 00 00 00 00       	mov    $0x0,%eax
f010464c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010464f:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104652:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104656:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104659:	8d 51 d0             	lea    -0x30(%ecx),%edx
f010465c:	83 fa 09             	cmp    $0x9,%edx
f010465f:	77 39                	ja     f010469a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104661:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104664:	eb e9                	jmp    f010464f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104666:	8b 45 14             	mov    0x14(%ebp),%eax
f0104669:	8d 48 04             	lea    0x4(%eax),%ecx
f010466c:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010466f:	8b 00                	mov    (%eax),%eax
f0104671:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104674:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104677:	eb 27                	jmp    f01046a0 <vprintfmt+0xdf>
f0104679:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010467c:	85 c0                	test   %eax,%eax
f010467e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104683:	0f 49 c8             	cmovns %eax,%ecx
f0104686:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010468c:	eb 8c                	jmp    f010461a <vprintfmt+0x59>
f010468e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104691:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104698:	eb 80                	jmp    f010461a <vprintfmt+0x59>
f010469a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010469d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01046a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01046a4:	0f 89 70 ff ff ff    	jns    f010461a <vprintfmt+0x59>
				width = precision, precision = -1;
f01046aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01046ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01046b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01046b7:	e9 5e ff ff ff       	jmp    f010461a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01046bc:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01046bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01046c2:	e9 53 ff ff ff       	jmp    f010461a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01046c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01046ca:	8d 50 04             	lea    0x4(%eax),%edx
f01046cd:	89 55 14             	mov    %edx,0x14(%ebp)
f01046d0:	83 ec 08             	sub    $0x8,%esp
f01046d3:	53                   	push   %ebx
f01046d4:	ff 30                	pushl  (%eax)
f01046d6:	ff d6                	call   *%esi
			break;
f01046d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01046db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01046de:	e9 04 ff ff ff       	jmp    f01045e7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01046e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01046e6:	8d 50 04             	lea    0x4(%eax),%edx
f01046e9:	89 55 14             	mov    %edx,0x14(%ebp)
f01046ec:	8b 00                	mov    (%eax),%eax
f01046ee:	99                   	cltd   
f01046ef:	31 d0                	xor    %edx,%eax
f01046f1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01046f3:	83 f8 09             	cmp    $0x9,%eax
f01046f6:	7f 0b                	jg     f0104703 <vprintfmt+0x142>
f01046f8:	8b 14 85 00 73 10 f0 	mov    -0xfef8d00(,%eax,4),%edx
f01046ff:	85 d2                	test   %edx,%edx
f0104701:	75 18                	jne    f010471b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0104703:	50                   	push   %eax
f0104704:	68 00 71 10 f0       	push   $0xf0107100
f0104709:	53                   	push   %ebx
f010470a:	56                   	push   %esi
f010470b:	e8 94 fe ff ff       	call   f01045a4 <printfmt>
f0104710:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104713:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104716:	e9 cc fe ff ff       	jmp    f01045e7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f010471b:	52                   	push   %edx
f010471c:	68 e9 67 10 f0       	push   $0xf01067e9
f0104721:	53                   	push   %ebx
f0104722:	56                   	push   %esi
f0104723:	e8 7c fe ff ff       	call   f01045a4 <printfmt>
f0104728:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010472b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010472e:	e9 b4 fe ff ff       	jmp    f01045e7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104733:	8b 45 14             	mov    0x14(%ebp),%eax
f0104736:	8d 50 04             	lea    0x4(%eax),%edx
f0104739:	89 55 14             	mov    %edx,0x14(%ebp)
f010473c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f010473e:	85 ff                	test   %edi,%edi
f0104740:	b8 f9 70 10 f0       	mov    $0xf01070f9,%eax
f0104745:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104748:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010474c:	0f 8e 94 00 00 00    	jle    f01047e6 <vprintfmt+0x225>
f0104752:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104756:	0f 84 98 00 00 00    	je     f01047f4 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f010475c:	83 ec 08             	sub    $0x8,%esp
f010475f:	ff 75 d0             	pushl  -0x30(%ebp)
f0104762:	57                   	push   %edi
f0104763:	e8 5f 03 00 00       	call   f0104ac7 <strnlen>
f0104768:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010476b:	29 c1                	sub    %eax,%ecx
f010476d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104770:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104773:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104777:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010477a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010477d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010477f:	eb 0f                	jmp    f0104790 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0104781:	83 ec 08             	sub    $0x8,%esp
f0104784:	53                   	push   %ebx
f0104785:	ff 75 e0             	pushl  -0x20(%ebp)
f0104788:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010478a:	83 ef 01             	sub    $0x1,%edi
f010478d:	83 c4 10             	add    $0x10,%esp
f0104790:	85 ff                	test   %edi,%edi
f0104792:	7f ed                	jg     f0104781 <vprintfmt+0x1c0>
f0104794:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104797:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010479a:	85 c9                	test   %ecx,%ecx
f010479c:	b8 00 00 00 00       	mov    $0x0,%eax
f01047a1:	0f 49 c1             	cmovns %ecx,%eax
f01047a4:	29 c1                	sub    %eax,%ecx
f01047a6:	89 75 08             	mov    %esi,0x8(%ebp)
f01047a9:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01047ac:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01047af:	89 cb                	mov    %ecx,%ebx
f01047b1:	eb 4d                	jmp    f0104800 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01047b3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01047b7:	74 1b                	je     f01047d4 <vprintfmt+0x213>
f01047b9:	0f be c0             	movsbl %al,%eax
f01047bc:	83 e8 20             	sub    $0x20,%eax
f01047bf:	83 f8 5e             	cmp    $0x5e,%eax
f01047c2:	76 10                	jbe    f01047d4 <vprintfmt+0x213>
					putch('?', putdat);
f01047c4:	83 ec 08             	sub    $0x8,%esp
f01047c7:	ff 75 0c             	pushl  0xc(%ebp)
f01047ca:	6a 3f                	push   $0x3f
f01047cc:	ff 55 08             	call   *0x8(%ebp)
f01047cf:	83 c4 10             	add    $0x10,%esp
f01047d2:	eb 0d                	jmp    f01047e1 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f01047d4:	83 ec 08             	sub    $0x8,%esp
f01047d7:	ff 75 0c             	pushl  0xc(%ebp)
f01047da:	52                   	push   %edx
f01047db:	ff 55 08             	call   *0x8(%ebp)
f01047de:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01047e1:	83 eb 01             	sub    $0x1,%ebx
f01047e4:	eb 1a                	jmp    f0104800 <vprintfmt+0x23f>
f01047e6:	89 75 08             	mov    %esi,0x8(%ebp)
f01047e9:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01047ec:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01047ef:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01047f2:	eb 0c                	jmp    f0104800 <vprintfmt+0x23f>
f01047f4:	89 75 08             	mov    %esi,0x8(%ebp)
f01047f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01047fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01047fd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104800:	83 c7 01             	add    $0x1,%edi
f0104803:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104807:	0f be d0             	movsbl %al,%edx
f010480a:	85 d2                	test   %edx,%edx
f010480c:	74 23                	je     f0104831 <vprintfmt+0x270>
f010480e:	85 f6                	test   %esi,%esi
f0104810:	78 a1                	js     f01047b3 <vprintfmt+0x1f2>
f0104812:	83 ee 01             	sub    $0x1,%esi
f0104815:	79 9c                	jns    f01047b3 <vprintfmt+0x1f2>
f0104817:	89 df                	mov    %ebx,%edi
f0104819:	8b 75 08             	mov    0x8(%ebp),%esi
f010481c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010481f:	eb 18                	jmp    f0104839 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104821:	83 ec 08             	sub    $0x8,%esp
f0104824:	53                   	push   %ebx
f0104825:	6a 20                	push   $0x20
f0104827:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104829:	83 ef 01             	sub    $0x1,%edi
f010482c:	83 c4 10             	add    $0x10,%esp
f010482f:	eb 08                	jmp    f0104839 <vprintfmt+0x278>
f0104831:	89 df                	mov    %ebx,%edi
f0104833:	8b 75 08             	mov    0x8(%ebp),%esi
f0104836:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104839:	85 ff                	test   %edi,%edi
f010483b:	7f e4                	jg     f0104821 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010483d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104840:	e9 a2 fd ff ff       	jmp    f01045e7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104845:	83 fa 01             	cmp    $0x1,%edx
f0104848:	7e 16                	jle    f0104860 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f010484a:	8b 45 14             	mov    0x14(%ebp),%eax
f010484d:	8d 50 08             	lea    0x8(%eax),%edx
f0104850:	89 55 14             	mov    %edx,0x14(%ebp)
f0104853:	8b 50 04             	mov    0x4(%eax),%edx
f0104856:	8b 00                	mov    (%eax),%eax
f0104858:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010485b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010485e:	eb 32                	jmp    f0104892 <vprintfmt+0x2d1>
	else if (lflag)
f0104860:	85 d2                	test   %edx,%edx
f0104862:	74 18                	je     f010487c <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0104864:	8b 45 14             	mov    0x14(%ebp),%eax
f0104867:	8d 50 04             	lea    0x4(%eax),%edx
f010486a:	89 55 14             	mov    %edx,0x14(%ebp)
f010486d:	8b 00                	mov    (%eax),%eax
f010486f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104872:	89 c1                	mov    %eax,%ecx
f0104874:	c1 f9 1f             	sar    $0x1f,%ecx
f0104877:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010487a:	eb 16                	jmp    f0104892 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f010487c:	8b 45 14             	mov    0x14(%ebp),%eax
f010487f:	8d 50 04             	lea    0x4(%eax),%edx
f0104882:	89 55 14             	mov    %edx,0x14(%ebp)
f0104885:	8b 00                	mov    (%eax),%eax
f0104887:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010488a:	89 c1                	mov    %eax,%ecx
f010488c:	c1 f9 1f             	sar    $0x1f,%ecx
f010488f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104892:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104895:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104898:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010489d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01048a1:	79 74                	jns    f0104917 <vprintfmt+0x356>
				putch('-', putdat);
f01048a3:	83 ec 08             	sub    $0x8,%esp
f01048a6:	53                   	push   %ebx
f01048a7:	6a 2d                	push   $0x2d
f01048a9:	ff d6                	call   *%esi
				num = -(long long) num;
f01048ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01048ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01048b1:	f7 d8                	neg    %eax
f01048b3:	83 d2 00             	adc    $0x0,%edx
f01048b6:	f7 da                	neg    %edx
f01048b8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01048bb:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01048c0:	eb 55                	jmp    f0104917 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01048c2:	8d 45 14             	lea    0x14(%ebp),%eax
f01048c5:	e8 83 fc ff ff       	call   f010454d <getuint>
			base = 10;
f01048ca:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01048cf:	eb 46                	jmp    f0104917 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f01048d1:	8d 45 14             	lea    0x14(%ebp),%eax
f01048d4:	e8 74 fc ff ff       	call   f010454d <getuint>
			base = 8;
f01048d9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f01048de:	eb 37                	jmp    f0104917 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
f01048e0:	83 ec 08             	sub    $0x8,%esp
f01048e3:	53                   	push   %ebx
f01048e4:	6a 30                	push   $0x30
f01048e6:	ff d6                	call   *%esi
			putch('x', putdat);
f01048e8:	83 c4 08             	add    $0x8,%esp
f01048eb:	53                   	push   %ebx
f01048ec:	6a 78                	push   $0x78
f01048ee:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01048f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01048f3:	8d 50 04             	lea    0x4(%eax),%edx
f01048f6:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01048f9:	8b 00                	mov    (%eax),%eax
f01048fb:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104900:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104903:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0104908:	eb 0d                	jmp    f0104917 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010490a:	8d 45 14             	lea    0x14(%ebp),%eax
f010490d:	e8 3b fc ff ff       	call   f010454d <getuint>
			base = 16;
f0104912:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104917:	83 ec 0c             	sub    $0xc,%esp
f010491a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010491e:	57                   	push   %edi
f010491f:	ff 75 e0             	pushl  -0x20(%ebp)
f0104922:	51                   	push   %ecx
f0104923:	52                   	push   %edx
f0104924:	50                   	push   %eax
f0104925:	89 da                	mov    %ebx,%edx
f0104927:	89 f0                	mov    %esi,%eax
f0104929:	e8 70 fb ff ff       	call   f010449e <printnum>
			break;
f010492e:	83 c4 20             	add    $0x20,%esp
f0104931:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104934:	e9 ae fc ff ff       	jmp    f01045e7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104939:	83 ec 08             	sub    $0x8,%esp
f010493c:	53                   	push   %ebx
f010493d:	51                   	push   %ecx
f010493e:	ff d6                	call   *%esi
			break;
f0104940:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104943:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104946:	e9 9c fc ff ff       	jmp    f01045e7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010494b:	83 ec 08             	sub    $0x8,%esp
f010494e:	53                   	push   %ebx
f010494f:	6a 25                	push   $0x25
f0104951:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104953:	83 c4 10             	add    $0x10,%esp
f0104956:	eb 03                	jmp    f010495b <vprintfmt+0x39a>
f0104958:	83 ef 01             	sub    $0x1,%edi
f010495b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010495f:	75 f7                	jne    f0104958 <vprintfmt+0x397>
f0104961:	e9 81 fc ff ff       	jmp    f01045e7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0104966:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104969:	5b                   	pop    %ebx
f010496a:	5e                   	pop    %esi
f010496b:	5f                   	pop    %edi
f010496c:	5d                   	pop    %ebp
f010496d:	c3                   	ret    

f010496e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010496e:	55                   	push   %ebp
f010496f:	89 e5                	mov    %esp,%ebp
f0104971:	83 ec 18             	sub    $0x18,%esp
f0104974:	8b 45 08             	mov    0x8(%ebp),%eax
f0104977:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010497a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010497d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104981:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104984:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010498b:	85 c0                	test   %eax,%eax
f010498d:	74 26                	je     f01049b5 <vsnprintf+0x47>
f010498f:	85 d2                	test   %edx,%edx
f0104991:	7e 22                	jle    f01049b5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104993:	ff 75 14             	pushl  0x14(%ebp)
f0104996:	ff 75 10             	pushl  0x10(%ebp)
f0104999:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010499c:	50                   	push   %eax
f010499d:	68 87 45 10 f0       	push   $0xf0104587
f01049a2:	e8 1a fc ff ff       	call   f01045c1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01049a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01049aa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01049ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01049b0:	83 c4 10             	add    $0x10,%esp
f01049b3:	eb 05                	jmp    f01049ba <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01049b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01049ba:	c9                   	leave  
f01049bb:	c3                   	ret    

f01049bc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01049bc:	55                   	push   %ebp
f01049bd:	89 e5                	mov    %esp,%ebp
f01049bf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01049c2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01049c5:	50                   	push   %eax
f01049c6:	ff 75 10             	pushl  0x10(%ebp)
f01049c9:	ff 75 0c             	pushl  0xc(%ebp)
f01049cc:	ff 75 08             	pushl  0x8(%ebp)
f01049cf:	e8 9a ff ff ff       	call   f010496e <vsnprintf>
	va_end(ap);

	return rc;
}
f01049d4:	c9                   	leave  
f01049d5:	c3                   	ret    

f01049d6 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01049d6:	55                   	push   %ebp
f01049d7:	89 e5                	mov    %esp,%ebp
f01049d9:	57                   	push   %edi
f01049da:	56                   	push   %esi
f01049db:	53                   	push   %ebx
f01049dc:	83 ec 0c             	sub    $0xc,%esp
f01049df:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01049e2:	85 c0                	test   %eax,%eax
f01049e4:	74 11                	je     f01049f7 <readline+0x21>
		cprintf("%s", prompt);
f01049e6:	83 ec 08             	sub    $0x8,%esp
f01049e9:	50                   	push   %eax
f01049ea:	68 e9 67 10 f0       	push   $0xf01067e9
f01049ef:	e8 20 ec ff ff       	call   f0103614 <cprintf>
f01049f4:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01049f7:	83 ec 0c             	sub    $0xc,%esp
f01049fa:	6a 00                	push   $0x0
f01049fc:	e8 5e bd ff ff       	call   f010075f <iscons>
f0104a01:	89 c7                	mov    %eax,%edi
f0104a03:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104a06:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104a0b:	e8 3e bd ff ff       	call   f010074e <getchar>
f0104a10:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104a12:	85 c0                	test   %eax,%eax
f0104a14:	79 18                	jns    f0104a2e <readline+0x58>
			cprintf("read error: %e\n", c);
f0104a16:	83 ec 08             	sub    $0x8,%esp
f0104a19:	50                   	push   %eax
f0104a1a:	68 28 73 10 f0       	push   $0xf0107328
f0104a1f:	e8 f0 eb ff ff       	call   f0103614 <cprintf>
			return NULL;
f0104a24:	83 c4 10             	add    $0x10,%esp
f0104a27:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a2c:	eb 79                	jmp    f0104aa7 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104a2e:	83 f8 08             	cmp    $0x8,%eax
f0104a31:	0f 94 c2             	sete   %dl
f0104a34:	83 f8 7f             	cmp    $0x7f,%eax
f0104a37:	0f 94 c0             	sete   %al
f0104a3a:	08 c2                	or     %al,%dl
f0104a3c:	74 1a                	je     f0104a58 <readline+0x82>
f0104a3e:	85 f6                	test   %esi,%esi
f0104a40:	7e 16                	jle    f0104a58 <readline+0x82>
			if (echoing)
f0104a42:	85 ff                	test   %edi,%edi
f0104a44:	74 0d                	je     f0104a53 <readline+0x7d>
				cputchar('\b');
f0104a46:	83 ec 0c             	sub    $0xc,%esp
f0104a49:	6a 08                	push   $0x8
f0104a4b:	e8 ee bc ff ff       	call   f010073e <cputchar>
f0104a50:	83 c4 10             	add    $0x10,%esp
			i--;
f0104a53:	83 ee 01             	sub    $0x1,%esi
f0104a56:	eb b3                	jmp    f0104a0b <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104a58:	83 fb 1f             	cmp    $0x1f,%ebx
f0104a5b:	7e 23                	jle    f0104a80 <readline+0xaa>
f0104a5d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104a63:	7f 1b                	jg     f0104a80 <readline+0xaa>
			if (echoing)
f0104a65:	85 ff                	test   %edi,%edi
f0104a67:	74 0c                	je     f0104a75 <readline+0x9f>
				cputchar(c);
f0104a69:	83 ec 0c             	sub    $0xc,%esp
f0104a6c:	53                   	push   %ebx
f0104a6d:	e8 cc bc ff ff       	call   f010073e <cputchar>
f0104a72:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104a75:	88 9e 00 ab 22 f0    	mov    %bl,-0xfdd5500(%esi)
f0104a7b:	8d 76 01             	lea    0x1(%esi),%esi
f0104a7e:	eb 8b                	jmp    f0104a0b <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0104a80:	83 fb 0a             	cmp    $0xa,%ebx
f0104a83:	74 05                	je     f0104a8a <readline+0xb4>
f0104a85:	83 fb 0d             	cmp    $0xd,%ebx
f0104a88:	75 81                	jne    f0104a0b <readline+0x35>
			if (echoing)
f0104a8a:	85 ff                	test   %edi,%edi
f0104a8c:	74 0d                	je     f0104a9b <readline+0xc5>
				cputchar('\n');
f0104a8e:	83 ec 0c             	sub    $0xc,%esp
f0104a91:	6a 0a                	push   $0xa
f0104a93:	e8 a6 bc ff ff       	call   f010073e <cputchar>
f0104a98:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0104a9b:	c6 86 00 ab 22 f0 00 	movb   $0x0,-0xfdd5500(%esi)
			return buf;
f0104aa2:	b8 00 ab 22 f0       	mov    $0xf022ab00,%eax
		}
	}
}
f0104aa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104aaa:	5b                   	pop    %ebx
f0104aab:	5e                   	pop    %esi
f0104aac:	5f                   	pop    %edi
f0104aad:	5d                   	pop    %ebp
f0104aae:	c3                   	ret    

f0104aaf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104aaf:	55                   	push   %ebp
f0104ab0:	89 e5                	mov    %esp,%ebp
f0104ab2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104ab5:	b8 00 00 00 00       	mov    $0x0,%eax
f0104aba:	eb 03                	jmp    f0104abf <strlen+0x10>
		n++;
f0104abc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104abf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104ac3:	75 f7                	jne    f0104abc <strlen+0xd>
		n++;
	return n;
}
f0104ac5:	5d                   	pop    %ebp
f0104ac6:	c3                   	ret    

f0104ac7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104ac7:	55                   	push   %ebp
f0104ac8:	89 e5                	mov    %esp,%ebp
f0104aca:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104acd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104ad0:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ad5:	eb 03                	jmp    f0104ada <strnlen+0x13>
		n++;
f0104ad7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104ada:	39 c2                	cmp    %eax,%edx
f0104adc:	74 08                	je     f0104ae6 <strnlen+0x1f>
f0104ade:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0104ae2:	75 f3                	jne    f0104ad7 <strnlen+0x10>
f0104ae4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0104ae6:	5d                   	pop    %ebp
f0104ae7:	c3                   	ret    

f0104ae8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104ae8:	55                   	push   %ebp
f0104ae9:	89 e5                	mov    %esp,%ebp
f0104aeb:	53                   	push   %ebx
f0104aec:	8b 45 08             	mov    0x8(%ebp),%eax
f0104aef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104af2:	89 c2                	mov    %eax,%edx
f0104af4:	83 c2 01             	add    $0x1,%edx
f0104af7:	83 c1 01             	add    $0x1,%ecx
f0104afa:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104afe:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104b01:	84 db                	test   %bl,%bl
f0104b03:	75 ef                	jne    f0104af4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104b05:	5b                   	pop    %ebx
f0104b06:	5d                   	pop    %ebp
f0104b07:	c3                   	ret    

f0104b08 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104b08:	55                   	push   %ebp
f0104b09:	89 e5                	mov    %esp,%ebp
f0104b0b:	53                   	push   %ebx
f0104b0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104b0f:	53                   	push   %ebx
f0104b10:	e8 9a ff ff ff       	call   f0104aaf <strlen>
f0104b15:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104b18:	ff 75 0c             	pushl  0xc(%ebp)
f0104b1b:	01 d8                	add    %ebx,%eax
f0104b1d:	50                   	push   %eax
f0104b1e:	e8 c5 ff ff ff       	call   f0104ae8 <strcpy>
	return dst;
}
f0104b23:	89 d8                	mov    %ebx,%eax
f0104b25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104b28:	c9                   	leave  
f0104b29:	c3                   	ret    

f0104b2a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104b2a:	55                   	push   %ebp
f0104b2b:	89 e5                	mov    %esp,%ebp
f0104b2d:	56                   	push   %esi
f0104b2e:	53                   	push   %ebx
f0104b2f:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104b35:	89 f3                	mov    %esi,%ebx
f0104b37:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104b3a:	89 f2                	mov    %esi,%edx
f0104b3c:	eb 0f                	jmp    f0104b4d <strncpy+0x23>
		*dst++ = *src;
f0104b3e:	83 c2 01             	add    $0x1,%edx
f0104b41:	0f b6 01             	movzbl (%ecx),%eax
f0104b44:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104b47:	80 39 01             	cmpb   $0x1,(%ecx)
f0104b4a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104b4d:	39 da                	cmp    %ebx,%edx
f0104b4f:	75 ed                	jne    f0104b3e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104b51:	89 f0                	mov    %esi,%eax
f0104b53:	5b                   	pop    %ebx
f0104b54:	5e                   	pop    %esi
f0104b55:	5d                   	pop    %ebp
f0104b56:	c3                   	ret    

f0104b57 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104b57:	55                   	push   %ebp
f0104b58:	89 e5                	mov    %esp,%ebp
f0104b5a:	56                   	push   %esi
f0104b5b:	53                   	push   %ebx
f0104b5c:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104b62:	8b 55 10             	mov    0x10(%ebp),%edx
f0104b65:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104b67:	85 d2                	test   %edx,%edx
f0104b69:	74 21                	je     f0104b8c <strlcpy+0x35>
f0104b6b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104b6f:	89 f2                	mov    %esi,%edx
f0104b71:	eb 09                	jmp    f0104b7c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104b73:	83 c2 01             	add    $0x1,%edx
f0104b76:	83 c1 01             	add    $0x1,%ecx
f0104b79:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104b7c:	39 c2                	cmp    %eax,%edx
f0104b7e:	74 09                	je     f0104b89 <strlcpy+0x32>
f0104b80:	0f b6 19             	movzbl (%ecx),%ebx
f0104b83:	84 db                	test   %bl,%bl
f0104b85:	75 ec                	jne    f0104b73 <strlcpy+0x1c>
f0104b87:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104b89:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104b8c:	29 f0                	sub    %esi,%eax
}
f0104b8e:	5b                   	pop    %ebx
f0104b8f:	5e                   	pop    %esi
f0104b90:	5d                   	pop    %ebp
f0104b91:	c3                   	ret    

f0104b92 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104b92:	55                   	push   %ebp
f0104b93:	89 e5                	mov    %esp,%ebp
f0104b95:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104b98:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104b9b:	eb 06                	jmp    f0104ba3 <strcmp+0x11>
		p++, q++;
f0104b9d:	83 c1 01             	add    $0x1,%ecx
f0104ba0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104ba3:	0f b6 01             	movzbl (%ecx),%eax
f0104ba6:	84 c0                	test   %al,%al
f0104ba8:	74 04                	je     f0104bae <strcmp+0x1c>
f0104baa:	3a 02                	cmp    (%edx),%al
f0104bac:	74 ef                	je     f0104b9d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104bae:	0f b6 c0             	movzbl %al,%eax
f0104bb1:	0f b6 12             	movzbl (%edx),%edx
f0104bb4:	29 d0                	sub    %edx,%eax
}
f0104bb6:	5d                   	pop    %ebp
f0104bb7:	c3                   	ret    

f0104bb8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104bb8:	55                   	push   %ebp
f0104bb9:	89 e5                	mov    %esp,%ebp
f0104bbb:	53                   	push   %ebx
f0104bbc:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bbf:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104bc2:	89 c3                	mov    %eax,%ebx
f0104bc4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104bc7:	eb 06                	jmp    f0104bcf <strncmp+0x17>
		n--, p++, q++;
f0104bc9:	83 c0 01             	add    $0x1,%eax
f0104bcc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104bcf:	39 d8                	cmp    %ebx,%eax
f0104bd1:	74 15                	je     f0104be8 <strncmp+0x30>
f0104bd3:	0f b6 08             	movzbl (%eax),%ecx
f0104bd6:	84 c9                	test   %cl,%cl
f0104bd8:	74 04                	je     f0104bde <strncmp+0x26>
f0104bda:	3a 0a                	cmp    (%edx),%cl
f0104bdc:	74 eb                	je     f0104bc9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104bde:	0f b6 00             	movzbl (%eax),%eax
f0104be1:	0f b6 12             	movzbl (%edx),%edx
f0104be4:	29 d0                	sub    %edx,%eax
f0104be6:	eb 05                	jmp    f0104bed <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104be8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104bed:	5b                   	pop    %ebx
f0104bee:	5d                   	pop    %ebp
f0104bef:	c3                   	ret    

f0104bf0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104bf0:	55                   	push   %ebp
f0104bf1:	89 e5                	mov    %esp,%ebp
f0104bf3:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bf6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104bfa:	eb 07                	jmp    f0104c03 <strchr+0x13>
		if (*s == c)
f0104bfc:	38 ca                	cmp    %cl,%dl
f0104bfe:	74 0f                	je     f0104c0f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104c00:	83 c0 01             	add    $0x1,%eax
f0104c03:	0f b6 10             	movzbl (%eax),%edx
f0104c06:	84 d2                	test   %dl,%dl
f0104c08:	75 f2                	jne    f0104bfc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0104c0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104c0f:	5d                   	pop    %ebp
f0104c10:	c3                   	ret    

f0104c11 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104c11:	55                   	push   %ebp
f0104c12:	89 e5                	mov    %esp,%ebp
f0104c14:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c17:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104c1b:	eb 03                	jmp    f0104c20 <strfind+0xf>
f0104c1d:	83 c0 01             	add    $0x1,%eax
f0104c20:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104c23:	38 ca                	cmp    %cl,%dl
f0104c25:	74 04                	je     f0104c2b <strfind+0x1a>
f0104c27:	84 d2                	test   %dl,%dl
f0104c29:	75 f2                	jne    f0104c1d <strfind+0xc>
			break;
	return (char *) s;
}
f0104c2b:	5d                   	pop    %ebp
f0104c2c:	c3                   	ret    

f0104c2d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104c2d:	55                   	push   %ebp
f0104c2e:	89 e5                	mov    %esp,%ebp
f0104c30:	57                   	push   %edi
f0104c31:	56                   	push   %esi
f0104c32:	53                   	push   %ebx
f0104c33:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104c36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104c39:	85 c9                	test   %ecx,%ecx
f0104c3b:	74 36                	je     f0104c73 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104c3d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104c43:	75 28                	jne    f0104c6d <memset+0x40>
f0104c45:	f6 c1 03             	test   $0x3,%cl
f0104c48:	75 23                	jne    f0104c6d <memset+0x40>
		c &= 0xFF;
f0104c4a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104c4e:	89 d3                	mov    %edx,%ebx
f0104c50:	c1 e3 08             	shl    $0x8,%ebx
f0104c53:	89 d6                	mov    %edx,%esi
f0104c55:	c1 e6 18             	shl    $0x18,%esi
f0104c58:	89 d0                	mov    %edx,%eax
f0104c5a:	c1 e0 10             	shl    $0x10,%eax
f0104c5d:	09 f0                	or     %esi,%eax
f0104c5f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0104c61:	89 d8                	mov    %ebx,%eax
f0104c63:	09 d0                	or     %edx,%eax
f0104c65:	c1 e9 02             	shr    $0x2,%ecx
f0104c68:	fc                   	cld    
f0104c69:	f3 ab                	rep stos %eax,%es:(%edi)
f0104c6b:	eb 06                	jmp    f0104c73 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104c6d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c70:	fc                   	cld    
f0104c71:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104c73:	89 f8                	mov    %edi,%eax
f0104c75:	5b                   	pop    %ebx
f0104c76:	5e                   	pop    %esi
f0104c77:	5f                   	pop    %edi
f0104c78:	5d                   	pop    %ebp
f0104c79:	c3                   	ret    

f0104c7a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104c7a:	55                   	push   %ebp
f0104c7b:	89 e5                	mov    %esp,%ebp
f0104c7d:	57                   	push   %edi
f0104c7e:	56                   	push   %esi
f0104c7f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c82:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104c85:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104c88:	39 c6                	cmp    %eax,%esi
f0104c8a:	73 35                	jae    f0104cc1 <memmove+0x47>
f0104c8c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104c8f:	39 d0                	cmp    %edx,%eax
f0104c91:	73 2e                	jae    f0104cc1 <memmove+0x47>
		s += n;
		d += n;
f0104c93:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104c96:	89 d6                	mov    %edx,%esi
f0104c98:	09 fe                	or     %edi,%esi
f0104c9a:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104ca0:	75 13                	jne    f0104cb5 <memmove+0x3b>
f0104ca2:	f6 c1 03             	test   $0x3,%cl
f0104ca5:	75 0e                	jne    f0104cb5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0104ca7:	83 ef 04             	sub    $0x4,%edi
f0104caa:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104cad:	c1 e9 02             	shr    $0x2,%ecx
f0104cb0:	fd                   	std    
f0104cb1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104cb3:	eb 09                	jmp    f0104cbe <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104cb5:	83 ef 01             	sub    $0x1,%edi
f0104cb8:	8d 72 ff             	lea    -0x1(%edx),%esi
f0104cbb:	fd                   	std    
f0104cbc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104cbe:	fc                   	cld    
f0104cbf:	eb 1d                	jmp    f0104cde <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104cc1:	89 f2                	mov    %esi,%edx
f0104cc3:	09 c2                	or     %eax,%edx
f0104cc5:	f6 c2 03             	test   $0x3,%dl
f0104cc8:	75 0f                	jne    f0104cd9 <memmove+0x5f>
f0104cca:	f6 c1 03             	test   $0x3,%cl
f0104ccd:	75 0a                	jne    f0104cd9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0104ccf:	c1 e9 02             	shr    $0x2,%ecx
f0104cd2:	89 c7                	mov    %eax,%edi
f0104cd4:	fc                   	cld    
f0104cd5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104cd7:	eb 05                	jmp    f0104cde <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104cd9:	89 c7                	mov    %eax,%edi
f0104cdb:	fc                   	cld    
f0104cdc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104cde:	5e                   	pop    %esi
f0104cdf:	5f                   	pop    %edi
f0104ce0:	5d                   	pop    %ebp
f0104ce1:	c3                   	ret    

f0104ce2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104ce2:	55                   	push   %ebp
f0104ce3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104ce5:	ff 75 10             	pushl  0x10(%ebp)
f0104ce8:	ff 75 0c             	pushl  0xc(%ebp)
f0104ceb:	ff 75 08             	pushl  0x8(%ebp)
f0104cee:	e8 87 ff ff ff       	call   f0104c7a <memmove>
}
f0104cf3:	c9                   	leave  
f0104cf4:	c3                   	ret    

f0104cf5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104cf5:	55                   	push   %ebp
f0104cf6:	89 e5                	mov    %esp,%ebp
f0104cf8:	56                   	push   %esi
f0104cf9:	53                   	push   %ebx
f0104cfa:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cfd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d00:	89 c6                	mov    %eax,%esi
f0104d02:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104d05:	eb 1a                	jmp    f0104d21 <memcmp+0x2c>
		if (*s1 != *s2)
f0104d07:	0f b6 08             	movzbl (%eax),%ecx
f0104d0a:	0f b6 1a             	movzbl (%edx),%ebx
f0104d0d:	38 d9                	cmp    %bl,%cl
f0104d0f:	74 0a                	je     f0104d1b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0104d11:	0f b6 c1             	movzbl %cl,%eax
f0104d14:	0f b6 db             	movzbl %bl,%ebx
f0104d17:	29 d8                	sub    %ebx,%eax
f0104d19:	eb 0f                	jmp    f0104d2a <memcmp+0x35>
		s1++, s2++;
f0104d1b:	83 c0 01             	add    $0x1,%eax
f0104d1e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104d21:	39 f0                	cmp    %esi,%eax
f0104d23:	75 e2                	jne    f0104d07 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104d25:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104d2a:	5b                   	pop    %ebx
f0104d2b:	5e                   	pop    %esi
f0104d2c:	5d                   	pop    %ebp
f0104d2d:	c3                   	ret    

f0104d2e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104d2e:	55                   	push   %ebp
f0104d2f:	89 e5                	mov    %esp,%ebp
f0104d31:	53                   	push   %ebx
f0104d32:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104d35:	89 c1                	mov    %eax,%ecx
f0104d37:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0104d3a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104d3e:	eb 0a                	jmp    f0104d4a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104d40:	0f b6 10             	movzbl (%eax),%edx
f0104d43:	39 da                	cmp    %ebx,%edx
f0104d45:	74 07                	je     f0104d4e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104d47:	83 c0 01             	add    $0x1,%eax
f0104d4a:	39 c8                	cmp    %ecx,%eax
f0104d4c:	72 f2                	jb     f0104d40 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104d4e:	5b                   	pop    %ebx
f0104d4f:	5d                   	pop    %ebp
f0104d50:	c3                   	ret    

f0104d51 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104d51:	55                   	push   %ebp
f0104d52:	89 e5                	mov    %esp,%ebp
f0104d54:	57                   	push   %edi
f0104d55:	56                   	push   %esi
f0104d56:	53                   	push   %ebx
f0104d57:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104d5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104d5d:	eb 03                	jmp    f0104d62 <strtol+0x11>
		s++;
f0104d5f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104d62:	0f b6 01             	movzbl (%ecx),%eax
f0104d65:	3c 20                	cmp    $0x20,%al
f0104d67:	74 f6                	je     f0104d5f <strtol+0xe>
f0104d69:	3c 09                	cmp    $0x9,%al
f0104d6b:	74 f2                	je     f0104d5f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104d6d:	3c 2b                	cmp    $0x2b,%al
f0104d6f:	75 0a                	jne    f0104d7b <strtol+0x2a>
		s++;
f0104d71:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104d74:	bf 00 00 00 00       	mov    $0x0,%edi
f0104d79:	eb 11                	jmp    f0104d8c <strtol+0x3b>
f0104d7b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104d80:	3c 2d                	cmp    $0x2d,%al
f0104d82:	75 08                	jne    f0104d8c <strtol+0x3b>
		s++, neg = 1;
f0104d84:	83 c1 01             	add    $0x1,%ecx
f0104d87:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104d8c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104d92:	75 15                	jne    f0104da9 <strtol+0x58>
f0104d94:	80 39 30             	cmpb   $0x30,(%ecx)
f0104d97:	75 10                	jne    f0104da9 <strtol+0x58>
f0104d99:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104d9d:	75 7c                	jne    f0104e1b <strtol+0xca>
		s += 2, base = 16;
f0104d9f:	83 c1 02             	add    $0x2,%ecx
f0104da2:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104da7:	eb 16                	jmp    f0104dbf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0104da9:	85 db                	test   %ebx,%ebx
f0104dab:	75 12                	jne    f0104dbf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104dad:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104db2:	80 39 30             	cmpb   $0x30,(%ecx)
f0104db5:	75 08                	jne    f0104dbf <strtol+0x6e>
		s++, base = 8;
f0104db7:	83 c1 01             	add    $0x1,%ecx
f0104dba:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0104dbf:	b8 00 00 00 00       	mov    $0x0,%eax
f0104dc4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104dc7:	0f b6 11             	movzbl (%ecx),%edx
f0104dca:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104dcd:	89 f3                	mov    %esi,%ebx
f0104dcf:	80 fb 09             	cmp    $0x9,%bl
f0104dd2:	77 08                	ja     f0104ddc <strtol+0x8b>
			dig = *s - '0';
f0104dd4:	0f be d2             	movsbl %dl,%edx
f0104dd7:	83 ea 30             	sub    $0x30,%edx
f0104dda:	eb 22                	jmp    f0104dfe <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0104ddc:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104ddf:	89 f3                	mov    %esi,%ebx
f0104de1:	80 fb 19             	cmp    $0x19,%bl
f0104de4:	77 08                	ja     f0104dee <strtol+0x9d>
			dig = *s - 'a' + 10;
f0104de6:	0f be d2             	movsbl %dl,%edx
f0104de9:	83 ea 57             	sub    $0x57,%edx
f0104dec:	eb 10                	jmp    f0104dfe <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0104dee:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104df1:	89 f3                	mov    %esi,%ebx
f0104df3:	80 fb 19             	cmp    $0x19,%bl
f0104df6:	77 16                	ja     f0104e0e <strtol+0xbd>
			dig = *s - 'A' + 10;
f0104df8:	0f be d2             	movsbl %dl,%edx
f0104dfb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0104dfe:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104e01:	7d 0b                	jge    f0104e0e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0104e03:	83 c1 01             	add    $0x1,%ecx
f0104e06:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104e0a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0104e0c:	eb b9                	jmp    f0104dc7 <strtol+0x76>

	if (endptr)
f0104e0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104e12:	74 0d                	je     f0104e21 <strtol+0xd0>
		*endptr = (char *) s;
f0104e14:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104e17:	89 0e                	mov    %ecx,(%esi)
f0104e19:	eb 06                	jmp    f0104e21 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104e1b:	85 db                	test   %ebx,%ebx
f0104e1d:	74 98                	je     f0104db7 <strtol+0x66>
f0104e1f:	eb 9e                	jmp    f0104dbf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0104e21:	89 c2                	mov    %eax,%edx
f0104e23:	f7 da                	neg    %edx
f0104e25:	85 ff                	test   %edi,%edi
f0104e27:	0f 45 c2             	cmovne %edx,%eax
}
f0104e2a:	5b                   	pop    %ebx
f0104e2b:	5e                   	pop    %esi
f0104e2c:	5f                   	pop    %edi
f0104e2d:	5d                   	pop    %ebp
f0104e2e:	c3                   	ret    
f0104e2f:	90                   	nop

f0104e30 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0104e30:	fa                   	cli    

	xorw    %ax, %ax
f0104e31:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0104e33:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104e35:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104e37:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0104e39:	0f 01 16             	lgdtl  (%esi)
f0104e3c:	74 70                	je     f0104eae <mpsearch1+0x3>
	movl    %cr0, %eax
f0104e3e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0104e41:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0104e45:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0104e48:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0104e4e:	08 00                	or     %al,(%eax)

f0104e50 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0104e50:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0104e54:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104e56:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104e58:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0104e5a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0104e5e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0104e60:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0104e62:	b8 00 d0 11 00       	mov    $0x11d000,%eax
	movl    %eax, %cr3
f0104e67:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0104e6a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0104e6d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0104e72:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0104e75:	8b 25 04 af 22 f0    	mov    0xf022af04,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0104e7b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0104e80:	b8 a7 01 10 f0       	mov    $0xf01001a7,%eax
	call    *%eax
f0104e85:	ff d0                	call   *%eax

f0104e87 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0104e87:	eb fe                	jmp    f0104e87 <spin>
f0104e89:	8d 76 00             	lea    0x0(%esi),%esi

f0104e8c <gdt>:
	...
f0104e94:	ff                   	(bad)  
f0104e95:	ff 00                	incl   (%eax)
f0104e97:	00 00                	add    %al,(%eax)
f0104e99:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0104ea0:	00                   	.byte 0x0
f0104ea1:	92                   	xchg   %eax,%edx
f0104ea2:	cf                   	iret   
	...

f0104ea4 <gdtdesc>:
f0104ea4:	17                   	pop    %ss
f0104ea5:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0104eaa <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0104eaa:	90                   	nop

f0104eab <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0104eab:	55                   	push   %ebp
f0104eac:	89 e5                	mov    %esp,%ebp
f0104eae:	57                   	push   %edi
f0104eaf:	56                   	push   %esi
f0104eb0:	53                   	push   %ebx
f0104eb1:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104eb4:	8b 0d 08 af 22 f0    	mov    0xf022af08,%ecx
f0104eba:	89 c3                	mov    %eax,%ebx
f0104ebc:	c1 eb 0c             	shr    $0xc,%ebx
f0104ebf:	39 cb                	cmp    %ecx,%ebx
f0104ec1:	72 12                	jb     f0104ed5 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104ec3:	50                   	push   %eax
f0104ec4:	68 04 59 10 f0       	push   $0xf0105904
f0104ec9:	6a 57                	push   $0x57
f0104ecb:	68 c5 74 10 f0       	push   $0xf01074c5
f0104ed0:	e8 6b b1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0104ed5:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0104edb:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104edd:	89 c2                	mov    %eax,%edx
f0104edf:	c1 ea 0c             	shr    $0xc,%edx
f0104ee2:	39 ca                	cmp    %ecx,%edx
f0104ee4:	72 12                	jb     f0104ef8 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104ee6:	50                   	push   %eax
f0104ee7:	68 04 59 10 f0       	push   $0xf0105904
f0104eec:	6a 57                	push   $0x57
f0104eee:	68 c5 74 10 f0       	push   $0xf01074c5
f0104ef3:	e8 48 b1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0104ef8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0104efe:	eb 2f                	jmp    f0104f2f <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104f00:	83 ec 04             	sub    $0x4,%esp
f0104f03:	6a 04                	push   $0x4
f0104f05:	68 d5 74 10 f0       	push   $0xf01074d5
f0104f0a:	53                   	push   %ebx
f0104f0b:	e8 e5 fd ff ff       	call   f0104cf5 <memcmp>
f0104f10:	83 c4 10             	add    $0x10,%esp
f0104f13:	85 c0                	test   %eax,%eax
f0104f15:	75 15                	jne    f0104f2c <mpsearch1+0x81>
f0104f17:	89 da                	mov    %ebx,%edx
f0104f19:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0104f1c:	0f b6 0a             	movzbl (%edx),%ecx
f0104f1f:	01 c8                	add    %ecx,%eax
f0104f21:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0104f24:	39 d7                	cmp    %edx,%edi
f0104f26:	75 f4                	jne    f0104f1c <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104f28:	84 c0                	test   %al,%al
f0104f2a:	74 0e                	je     f0104f3a <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0104f2c:	83 c3 10             	add    $0x10,%ebx
f0104f2f:	39 f3                	cmp    %esi,%ebx
f0104f31:	72 cd                	jb     f0104f00 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0104f33:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f38:	eb 02                	jmp    f0104f3c <mpsearch1+0x91>
f0104f3a:	89 d8                	mov    %ebx,%eax
}
f0104f3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f3f:	5b                   	pop    %ebx
f0104f40:	5e                   	pop    %esi
f0104f41:	5f                   	pop    %edi
f0104f42:	5d                   	pop    %ebp
f0104f43:	c3                   	ret    

f0104f44 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0104f44:	55                   	push   %ebp
f0104f45:	89 e5                	mov    %esp,%ebp
f0104f47:	57                   	push   %edi
f0104f48:	56                   	push   %esi
f0104f49:	53                   	push   %ebx
f0104f4a:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0104f4d:	c7 05 c0 b3 22 f0 20 	movl   $0xf022b020,0xf022b3c0
f0104f54:	b0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104f57:	83 3d 08 af 22 f0 00 	cmpl   $0x0,0xf022af08
f0104f5e:	75 16                	jne    f0104f76 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104f60:	68 00 04 00 00       	push   $0x400
f0104f65:	68 04 59 10 f0       	push   $0xf0105904
f0104f6a:	6a 6f                	push   $0x6f
f0104f6c:	68 c5 74 10 f0       	push   $0xf01074c5
f0104f71:	e8 ca b0 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0104f76:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0104f7d:	85 c0                	test   %eax,%eax
f0104f7f:	74 16                	je     f0104f97 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0104f81:	c1 e0 04             	shl    $0x4,%eax
f0104f84:	ba 00 04 00 00       	mov    $0x400,%edx
f0104f89:	e8 1d ff ff ff       	call   f0104eab <mpsearch1>
f0104f8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104f91:	85 c0                	test   %eax,%eax
f0104f93:	75 3c                	jne    f0104fd1 <mp_init+0x8d>
f0104f95:	eb 20                	jmp    f0104fb7 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0104f97:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0104f9e:	c1 e0 0a             	shl    $0xa,%eax
f0104fa1:	2d 00 04 00 00       	sub    $0x400,%eax
f0104fa6:	ba 00 04 00 00       	mov    $0x400,%edx
f0104fab:	e8 fb fe ff ff       	call   f0104eab <mpsearch1>
f0104fb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104fb3:	85 c0                	test   %eax,%eax
f0104fb5:	75 1a                	jne    f0104fd1 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0104fb7:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104fbc:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0104fc1:	e8 e5 fe ff ff       	call   f0104eab <mpsearch1>
f0104fc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0104fc9:	85 c0                	test   %eax,%eax
f0104fcb:	0f 84 5d 02 00 00    	je     f010522e <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0104fd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104fd4:	8b 70 04             	mov    0x4(%eax),%esi
f0104fd7:	85 f6                	test   %esi,%esi
f0104fd9:	74 06                	je     f0104fe1 <mp_init+0x9d>
f0104fdb:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0104fdf:	74 15                	je     f0104ff6 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0104fe1:	83 ec 0c             	sub    $0xc,%esp
f0104fe4:	68 38 73 10 f0       	push   $0xf0107338
f0104fe9:	e8 26 e6 ff ff       	call   f0103614 <cprintf>
f0104fee:	83 c4 10             	add    $0x10,%esp
f0104ff1:	e9 38 02 00 00       	jmp    f010522e <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104ff6:	89 f0                	mov    %esi,%eax
f0104ff8:	c1 e8 0c             	shr    $0xc,%eax
f0104ffb:	3b 05 08 af 22 f0    	cmp    0xf022af08,%eax
f0105001:	72 15                	jb     f0105018 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105003:	56                   	push   %esi
f0105004:	68 04 59 10 f0       	push   $0xf0105904
f0105009:	68 90 00 00 00       	push   $0x90
f010500e:	68 c5 74 10 f0       	push   $0xf01074c5
f0105013:	e8 28 b0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105018:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010501e:	83 ec 04             	sub    $0x4,%esp
f0105021:	6a 04                	push   $0x4
f0105023:	68 da 74 10 f0       	push   $0xf01074da
f0105028:	53                   	push   %ebx
f0105029:	e8 c7 fc ff ff       	call   f0104cf5 <memcmp>
f010502e:	83 c4 10             	add    $0x10,%esp
f0105031:	85 c0                	test   %eax,%eax
f0105033:	74 15                	je     f010504a <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105035:	83 ec 0c             	sub    $0xc,%esp
f0105038:	68 68 73 10 f0       	push   $0xf0107368
f010503d:	e8 d2 e5 ff ff       	call   f0103614 <cprintf>
f0105042:	83 c4 10             	add    $0x10,%esp
f0105045:	e9 e4 01 00 00       	jmp    f010522e <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010504a:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f010504e:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105052:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105055:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f010505a:	b8 00 00 00 00       	mov    $0x0,%eax
f010505f:	eb 0d                	jmp    f010506e <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105061:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105068:	f0 
f0105069:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010506b:	83 c0 01             	add    $0x1,%eax
f010506e:	39 c7                	cmp    %eax,%edi
f0105070:	75 ef                	jne    f0105061 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105072:	84 d2                	test   %dl,%dl
f0105074:	74 15                	je     f010508b <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105076:	83 ec 0c             	sub    $0xc,%esp
f0105079:	68 9c 73 10 f0       	push   $0xf010739c
f010507e:	e8 91 e5 ff ff       	call   f0103614 <cprintf>
f0105083:	83 c4 10             	add    $0x10,%esp
f0105086:	e9 a3 01 00 00       	jmp    f010522e <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010508b:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f010508f:	3c 01                	cmp    $0x1,%al
f0105091:	74 1d                	je     f01050b0 <mp_init+0x16c>
f0105093:	3c 04                	cmp    $0x4,%al
f0105095:	74 19                	je     f01050b0 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105097:	83 ec 08             	sub    $0x8,%esp
f010509a:	0f b6 c0             	movzbl %al,%eax
f010509d:	50                   	push   %eax
f010509e:	68 c0 73 10 f0       	push   $0xf01073c0
f01050a3:	e8 6c e5 ff ff       	call   f0103614 <cprintf>
f01050a8:	83 c4 10             	add    $0x10,%esp
f01050ab:	e9 7e 01 00 00       	jmp    f010522e <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01050b0:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f01050b4:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01050b8:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01050bd:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f01050c2:	01 ce                	add    %ecx,%esi
f01050c4:	eb 0d                	jmp    f01050d3 <mp_init+0x18f>
f01050c6:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f01050cd:	f0 
f01050ce:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01050d0:	83 c0 01             	add    $0x1,%eax
f01050d3:	39 c7                	cmp    %eax,%edi
f01050d5:	75 ef                	jne    f01050c6 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01050d7:	89 d0                	mov    %edx,%eax
f01050d9:	02 43 2a             	add    0x2a(%ebx),%al
f01050dc:	74 15                	je     f01050f3 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01050de:	83 ec 0c             	sub    $0xc,%esp
f01050e1:	68 e0 73 10 f0       	push   $0xf01073e0
f01050e6:	e8 29 e5 ff ff       	call   f0103614 <cprintf>
f01050eb:	83 c4 10             	add    $0x10,%esp
f01050ee:	e9 3b 01 00 00       	jmp    f010522e <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01050f3:	85 db                	test   %ebx,%ebx
f01050f5:	0f 84 33 01 00 00    	je     f010522e <mp_init+0x2ea>
		return;
	ismp = 1;
f01050fb:	c7 05 00 b0 22 f0 01 	movl   $0x1,0xf022b000
f0105102:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105105:	8b 43 24             	mov    0x24(%ebx),%eax
f0105108:	a3 00 c0 26 f0       	mov    %eax,0xf026c000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010510d:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105110:	be 00 00 00 00       	mov    $0x0,%esi
f0105115:	e9 85 00 00 00       	jmp    f010519f <mp_init+0x25b>
		switch (*p) {
f010511a:	0f b6 07             	movzbl (%edi),%eax
f010511d:	84 c0                	test   %al,%al
f010511f:	74 06                	je     f0105127 <mp_init+0x1e3>
f0105121:	3c 04                	cmp    $0x4,%al
f0105123:	77 55                	ja     f010517a <mp_init+0x236>
f0105125:	eb 4e                	jmp    f0105175 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105127:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010512b:	74 11                	je     f010513e <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f010512d:	6b 05 c4 b3 22 f0 74 	imul   $0x74,0xf022b3c4,%eax
f0105134:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f0105139:	a3 c0 b3 22 f0       	mov    %eax,0xf022b3c0
			if (ncpu < NCPU) {
f010513e:	a1 c4 b3 22 f0       	mov    0xf022b3c4,%eax
f0105143:	83 f8 07             	cmp    $0x7,%eax
f0105146:	7f 13                	jg     f010515b <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105148:	6b d0 74             	imul   $0x74,%eax,%edx
f010514b:	88 82 20 b0 22 f0    	mov    %al,-0xfdd4fe0(%edx)
				ncpu++;
f0105151:	83 c0 01             	add    $0x1,%eax
f0105154:	a3 c4 b3 22 f0       	mov    %eax,0xf022b3c4
f0105159:	eb 15                	jmp    f0105170 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010515b:	83 ec 08             	sub    $0x8,%esp
f010515e:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105162:	50                   	push   %eax
f0105163:	68 10 74 10 f0       	push   $0xf0107410
f0105168:	e8 a7 e4 ff ff       	call   f0103614 <cprintf>
f010516d:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105170:	83 c7 14             	add    $0x14,%edi
			continue;
f0105173:	eb 27                	jmp    f010519c <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105175:	83 c7 08             	add    $0x8,%edi
			continue;
f0105178:	eb 22                	jmp    f010519c <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010517a:	83 ec 08             	sub    $0x8,%esp
f010517d:	0f b6 c0             	movzbl %al,%eax
f0105180:	50                   	push   %eax
f0105181:	68 38 74 10 f0       	push   $0xf0107438
f0105186:	e8 89 e4 ff ff       	call   f0103614 <cprintf>
			ismp = 0;
f010518b:	c7 05 00 b0 22 f0 00 	movl   $0x0,0xf022b000
f0105192:	00 00 00 
			i = conf->entry;
f0105195:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105199:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010519c:	83 c6 01             	add    $0x1,%esi
f010519f:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01051a3:	39 c6                	cmp    %eax,%esi
f01051a5:	0f 82 6f ff ff ff    	jb     f010511a <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01051ab:	a1 c0 b3 22 f0       	mov    0xf022b3c0,%eax
f01051b0:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01051b7:	83 3d 00 b0 22 f0 00 	cmpl   $0x0,0xf022b000
f01051be:	75 26                	jne    f01051e6 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01051c0:	c7 05 c4 b3 22 f0 01 	movl   $0x1,0xf022b3c4
f01051c7:	00 00 00 
		lapicaddr = 0;
f01051ca:	c7 05 00 c0 26 f0 00 	movl   $0x0,0xf026c000
f01051d1:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01051d4:	83 ec 0c             	sub    $0xc,%esp
f01051d7:	68 58 74 10 f0       	push   $0xf0107458
f01051dc:	e8 33 e4 ff ff       	call   f0103614 <cprintf>
		return;
f01051e1:	83 c4 10             	add    $0x10,%esp
f01051e4:	eb 48                	jmp    f010522e <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01051e6:	83 ec 04             	sub    $0x4,%esp
f01051e9:	ff 35 c4 b3 22 f0    	pushl  0xf022b3c4
f01051ef:	0f b6 00             	movzbl (%eax),%eax
f01051f2:	50                   	push   %eax
f01051f3:	68 df 74 10 f0       	push   $0xf01074df
f01051f8:	e8 17 e4 ff ff       	call   f0103614 <cprintf>

	if (mp->imcrp) {
f01051fd:	83 c4 10             	add    $0x10,%esp
f0105200:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105203:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105207:	74 25                	je     f010522e <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105209:	83 ec 0c             	sub    $0xc,%esp
f010520c:	68 84 74 10 f0       	push   $0xf0107484
f0105211:	e8 fe e3 ff ff       	call   f0103614 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105216:	ba 22 00 00 00       	mov    $0x22,%edx
f010521b:	b8 70 00 00 00       	mov    $0x70,%eax
f0105220:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105221:	ba 23 00 00 00       	mov    $0x23,%edx
f0105226:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105227:	83 c8 01             	or     $0x1,%eax
f010522a:	ee                   	out    %al,(%dx)
f010522b:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f010522e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105231:	5b                   	pop    %ebx
f0105232:	5e                   	pop    %esi
f0105233:	5f                   	pop    %edi
f0105234:	5d                   	pop    %ebp
f0105235:	c3                   	ret    

f0105236 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105236:	55                   	push   %ebp
f0105237:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105239:	8b 0d 04 c0 26 f0    	mov    0xf026c004,%ecx
f010523f:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105242:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105244:	a1 04 c0 26 f0       	mov    0xf026c004,%eax
f0105249:	8b 40 20             	mov    0x20(%eax),%eax
}
f010524c:	5d                   	pop    %ebp
f010524d:	c3                   	ret    

f010524e <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010524e:	55                   	push   %ebp
f010524f:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105251:	a1 04 c0 26 f0       	mov    0xf026c004,%eax
f0105256:	85 c0                	test   %eax,%eax
f0105258:	74 08                	je     f0105262 <cpunum+0x14>
		return lapic[ID] >> 24;
f010525a:	8b 40 20             	mov    0x20(%eax),%eax
f010525d:	c1 e8 18             	shr    $0x18,%eax
f0105260:	eb 05                	jmp    f0105267 <cpunum+0x19>
	return 0;
f0105262:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105267:	5d                   	pop    %ebp
f0105268:	c3                   	ret    

f0105269 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105269:	a1 00 c0 26 f0       	mov    0xf026c000,%eax
f010526e:	85 c0                	test   %eax,%eax
f0105270:	0f 84 21 01 00 00    	je     f0105397 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105276:	55                   	push   %ebp
f0105277:	89 e5                	mov    %esp,%ebp
f0105279:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f010527c:	68 00 10 00 00       	push   $0x1000
f0105281:	50                   	push   %eax
f0105282:	e8 1a bf ff ff       	call   f01011a1 <mmio_map_region>
f0105287:	a3 04 c0 26 f0       	mov    %eax,0xf026c004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010528c:	ba 27 01 00 00       	mov    $0x127,%edx
f0105291:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105296:	e8 9b ff ff ff       	call   f0105236 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010529b:	ba 0b 00 00 00       	mov    $0xb,%edx
f01052a0:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01052a5:	e8 8c ff ff ff       	call   f0105236 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01052aa:	ba 20 00 02 00       	mov    $0x20020,%edx
f01052af:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01052b4:	e8 7d ff ff ff       	call   f0105236 <lapicw>
	lapicw(TICR, 10000000); 
f01052b9:	ba 80 96 98 00       	mov    $0x989680,%edx
f01052be:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01052c3:	e8 6e ff ff ff       	call   f0105236 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01052c8:	e8 81 ff ff ff       	call   f010524e <cpunum>
f01052cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01052d0:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f01052d5:	83 c4 10             	add    $0x10,%esp
f01052d8:	39 05 c0 b3 22 f0    	cmp    %eax,0xf022b3c0
f01052de:	74 0f                	je     f01052ef <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f01052e0:	ba 00 00 01 00       	mov    $0x10000,%edx
f01052e5:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01052ea:	e8 47 ff ff ff       	call   f0105236 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01052ef:	ba 00 00 01 00       	mov    $0x10000,%edx
f01052f4:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01052f9:	e8 38 ff ff ff       	call   f0105236 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01052fe:	a1 04 c0 26 f0       	mov    0xf026c004,%eax
f0105303:	8b 40 30             	mov    0x30(%eax),%eax
f0105306:	c1 e8 10             	shr    $0x10,%eax
f0105309:	3c 03                	cmp    $0x3,%al
f010530b:	76 0f                	jbe    f010531c <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f010530d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105312:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105317:	e8 1a ff ff ff       	call   f0105236 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010531c:	ba 33 00 00 00       	mov    $0x33,%edx
f0105321:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105326:	e8 0b ff ff ff       	call   f0105236 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010532b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105330:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105335:	e8 fc fe ff ff       	call   f0105236 <lapicw>
	lapicw(ESR, 0);
f010533a:	ba 00 00 00 00       	mov    $0x0,%edx
f010533f:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105344:	e8 ed fe ff ff       	call   f0105236 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105349:	ba 00 00 00 00       	mov    $0x0,%edx
f010534e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105353:	e8 de fe ff ff       	call   f0105236 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105358:	ba 00 00 00 00       	mov    $0x0,%edx
f010535d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105362:	e8 cf fe ff ff       	call   f0105236 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105367:	ba 00 85 08 00       	mov    $0x88500,%edx
f010536c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105371:	e8 c0 fe ff ff       	call   f0105236 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105376:	8b 15 04 c0 26 f0    	mov    0xf026c004,%edx
f010537c:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105382:	f6 c4 10             	test   $0x10,%ah
f0105385:	75 f5                	jne    f010537c <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105387:	ba 00 00 00 00       	mov    $0x0,%edx
f010538c:	b8 20 00 00 00       	mov    $0x20,%eax
f0105391:	e8 a0 fe ff ff       	call   f0105236 <lapicw>
}
f0105396:	c9                   	leave  
f0105397:	f3 c3                	repz ret 

f0105399 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105399:	83 3d 04 c0 26 f0 00 	cmpl   $0x0,0xf026c004
f01053a0:	74 13                	je     f01053b5 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01053a2:	55                   	push   %ebp
f01053a3:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f01053a5:	ba 00 00 00 00       	mov    $0x0,%edx
f01053aa:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01053af:	e8 82 fe ff ff       	call   f0105236 <lapicw>
}
f01053b4:	5d                   	pop    %ebp
f01053b5:	f3 c3                	repz ret 

f01053b7 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01053b7:	55                   	push   %ebp
f01053b8:	89 e5                	mov    %esp,%ebp
f01053ba:	56                   	push   %esi
f01053bb:	53                   	push   %ebx
f01053bc:	8b 75 08             	mov    0x8(%ebp),%esi
f01053bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053c2:	ba 70 00 00 00       	mov    $0x70,%edx
f01053c7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01053cc:	ee                   	out    %al,(%dx)
f01053cd:	ba 71 00 00 00       	mov    $0x71,%edx
f01053d2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01053d7:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01053d8:	83 3d 08 af 22 f0 00 	cmpl   $0x0,0xf022af08
f01053df:	75 19                	jne    f01053fa <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01053e1:	68 67 04 00 00       	push   $0x467
f01053e6:	68 04 59 10 f0       	push   $0xf0105904
f01053eb:	68 98 00 00 00       	push   $0x98
f01053f0:	68 fc 74 10 f0       	push   $0xf01074fc
f01053f5:	e8 46 ac ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01053fa:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105401:	00 00 
	wrv[1] = addr >> 4;
f0105403:	89 d8                	mov    %ebx,%eax
f0105405:	c1 e8 04             	shr    $0x4,%eax
f0105408:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010540e:	c1 e6 18             	shl    $0x18,%esi
f0105411:	89 f2                	mov    %esi,%edx
f0105413:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105418:	e8 19 fe ff ff       	call   f0105236 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010541d:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105422:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105427:	e8 0a fe ff ff       	call   f0105236 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010542c:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105431:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105436:	e8 fb fd ff ff       	call   f0105236 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010543b:	c1 eb 0c             	shr    $0xc,%ebx
f010543e:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105441:	89 f2                	mov    %esi,%edx
f0105443:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105448:	e8 e9 fd ff ff       	call   f0105236 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010544d:	89 da                	mov    %ebx,%edx
f010544f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105454:	e8 dd fd ff ff       	call   f0105236 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105459:	89 f2                	mov    %esi,%edx
f010545b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105460:	e8 d1 fd ff ff       	call   f0105236 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105465:	89 da                	mov    %ebx,%edx
f0105467:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010546c:	e8 c5 fd ff ff       	call   f0105236 <lapicw>
		microdelay(200);
	}
}
f0105471:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105474:	5b                   	pop    %ebx
f0105475:	5e                   	pop    %esi
f0105476:	5d                   	pop    %ebp
f0105477:	c3                   	ret    

f0105478 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105478:	55                   	push   %ebp
f0105479:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010547b:	8b 55 08             	mov    0x8(%ebp),%edx
f010547e:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105484:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105489:	e8 a8 fd ff ff       	call   f0105236 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010548e:	8b 15 04 c0 26 f0    	mov    0xf026c004,%edx
f0105494:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010549a:	f6 c4 10             	test   $0x10,%ah
f010549d:	75 f5                	jne    f0105494 <lapic_ipi+0x1c>
		;
}
f010549f:	5d                   	pop    %ebp
f01054a0:	c3                   	ret    

f01054a1 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01054a1:	55                   	push   %ebp
f01054a2:	89 e5                	mov    %esp,%ebp
f01054a4:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01054a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01054ad:	8b 55 0c             	mov    0xc(%ebp),%edx
f01054b0:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01054b3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01054ba:	5d                   	pop    %ebp
f01054bb:	c3                   	ret    

f01054bc <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01054bc:	55                   	push   %ebp
f01054bd:	89 e5                	mov    %esp,%ebp
f01054bf:	56                   	push   %esi
f01054c0:	53                   	push   %ebx
f01054c1:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01054c4:	83 3b 00             	cmpl   $0x0,(%ebx)
f01054c7:	74 14                	je     f01054dd <spin_lock+0x21>
f01054c9:	8b 73 08             	mov    0x8(%ebx),%esi
f01054cc:	e8 7d fd ff ff       	call   f010524e <cpunum>
f01054d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01054d4:	05 20 b0 22 f0       	add    $0xf022b020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01054d9:	39 c6                	cmp    %eax,%esi
f01054db:	74 07                	je     f01054e4 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01054dd:	ba 01 00 00 00       	mov    $0x1,%edx
f01054e2:	eb 20                	jmp    f0105504 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01054e4:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01054e7:	e8 62 fd ff ff       	call   f010524e <cpunum>
f01054ec:	83 ec 0c             	sub    $0xc,%esp
f01054ef:	53                   	push   %ebx
f01054f0:	50                   	push   %eax
f01054f1:	68 0c 75 10 f0       	push   $0xf010750c
f01054f6:	6a 41                	push   $0x41
f01054f8:	68 70 75 10 f0       	push   $0xf0107570
f01054fd:	e8 3e ab ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105502:	f3 90                	pause  
f0105504:	89 d0                	mov    %edx,%eax
f0105506:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105509:	85 c0                	test   %eax,%eax
f010550b:	75 f5                	jne    f0105502 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010550d:	e8 3c fd ff ff       	call   f010524e <cpunum>
f0105512:	6b c0 74             	imul   $0x74,%eax,%eax
f0105515:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f010551a:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f010551d:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0105520:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105522:	b8 00 00 00 00       	mov    $0x0,%eax
f0105527:	eb 0b                	jmp    f0105534 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105529:	8b 4a 04             	mov    0x4(%edx),%ecx
f010552c:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010552f:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105531:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105534:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010553a:	76 11                	jbe    f010554d <spin_lock+0x91>
f010553c:	83 f8 09             	cmp    $0x9,%eax
f010553f:	7e e8                	jle    f0105529 <spin_lock+0x6d>
f0105541:	eb 0a                	jmp    f010554d <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105543:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010554a:	83 c0 01             	add    $0x1,%eax
f010554d:	83 f8 09             	cmp    $0x9,%eax
f0105550:	7e f1                	jle    f0105543 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105552:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105555:	5b                   	pop    %ebx
f0105556:	5e                   	pop    %esi
f0105557:	5d                   	pop    %ebp
f0105558:	c3                   	ret    

f0105559 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105559:	55                   	push   %ebp
f010555a:	89 e5                	mov    %esp,%ebp
f010555c:	57                   	push   %edi
f010555d:	56                   	push   %esi
f010555e:	53                   	push   %ebx
f010555f:	83 ec 4c             	sub    $0x4c,%esp
f0105562:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105565:	83 3e 00             	cmpl   $0x0,(%esi)
f0105568:	74 18                	je     f0105582 <spin_unlock+0x29>
f010556a:	8b 5e 08             	mov    0x8(%esi),%ebx
f010556d:	e8 dc fc ff ff       	call   f010524e <cpunum>
f0105572:	6b c0 74             	imul   $0x74,%eax,%eax
f0105575:	05 20 b0 22 f0       	add    $0xf022b020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010557a:	39 c3                	cmp    %eax,%ebx
f010557c:	0f 84 a5 00 00 00    	je     f0105627 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105582:	83 ec 04             	sub    $0x4,%esp
f0105585:	6a 28                	push   $0x28
f0105587:	8d 46 0c             	lea    0xc(%esi),%eax
f010558a:	50                   	push   %eax
f010558b:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010558e:	53                   	push   %ebx
f010558f:	e8 e6 f6 ff ff       	call   f0104c7a <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105594:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105597:	0f b6 38             	movzbl (%eax),%edi
f010559a:	8b 76 04             	mov    0x4(%esi),%esi
f010559d:	e8 ac fc ff ff       	call   f010524e <cpunum>
f01055a2:	57                   	push   %edi
f01055a3:	56                   	push   %esi
f01055a4:	50                   	push   %eax
f01055a5:	68 38 75 10 f0       	push   $0xf0107538
f01055aa:	e8 65 e0 ff ff       	call   f0103614 <cprintf>
f01055af:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01055b2:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01055b5:	eb 54                	jmp    f010560b <spin_unlock+0xb2>
f01055b7:	83 ec 08             	sub    $0x8,%esp
f01055ba:	57                   	push   %edi
f01055bb:	50                   	push   %eax
f01055bc:	e8 0a ec ff ff       	call   f01041cb <debuginfo_eip>
f01055c1:	83 c4 10             	add    $0x10,%esp
f01055c4:	85 c0                	test   %eax,%eax
f01055c6:	78 27                	js     f01055ef <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01055c8:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01055ca:	83 ec 04             	sub    $0x4,%esp
f01055cd:	89 c2                	mov    %eax,%edx
f01055cf:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01055d2:	52                   	push   %edx
f01055d3:	ff 75 b0             	pushl  -0x50(%ebp)
f01055d6:	ff 75 b4             	pushl  -0x4c(%ebp)
f01055d9:	ff 75 ac             	pushl  -0x54(%ebp)
f01055dc:	ff 75 a8             	pushl  -0x58(%ebp)
f01055df:	50                   	push   %eax
f01055e0:	68 80 75 10 f0       	push   $0xf0107580
f01055e5:	e8 2a e0 ff ff       	call   f0103614 <cprintf>
f01055ea:	83 c4 20             	add    $0x20,%esp
f01055ed:	eb 12                	jmp    f0105601 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01055ef:	83 ec 08             	sub    $0x8,%esp
f01055f2:	ff 36                	pushl  (%esi)
f01055f4:	68 97 75 10 f0       	push   $0xf0107597
f01055f9:	e8 16 e0 ff ff       	call   f0103614 <cprintf>
f01055fe:	83 c4 10             	add    $0x10,%esp
f0105601:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105604:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105607:	39 c3                	cmp    %eax,%ebx
f0105609:	74 08                	je     f0105613 <spin_unlock+0xba>
f010560b:	89 de                	mov    %ebx,%esi
f010560d:	8b 03                	mov    (%ebx),%eax
f010560f:	85 c0                	test   %eax,%eax
f0105611:	75 a4                	jne    f01055b7 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105613:	83 ec 04             	sub    $0x4,%esp
f0105616:	68 9f 75 10 f0       	push   $0xf010759f
f010561b:	6a 67                	push   $0x67
f010561d:	68 70 75 10 f0       	push   $0xf0107570
f0105622:	e8 19 aa ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105627:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f010562e:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105635:	b8 00 00 00 00       	mov    $0x0,%eax
f010563a:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f010563d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105640:	5b                   	pop    %ebx
f0105641:	5e                   	pop    %esi
f0105642:	5f                   	pop    %edi
f0105643:	5d                   	pop    %ebp
f0105644:	c3                   	ret    
f0105645:	66 90                	xchg   %ax,%ax
f0105647:	66 90                	xchg   %ax,%ax
f0105649:	66 90                	xchg   %ax,%ax
f010564b:	66 90                	xchg   %ax,%ax
f010564d:	66 90                	xchg   %ax,%ax
f010564f:	90                   	nop

f0105650 <__udivdi3>:
f0105650:	55                   	push   %ebp
f0105651:	57                   	push   %edi
f0105652:	56                   	push   %esi
f0105653:	53                   	push   %ebx
f0105654:	83 ec 1c             	sub    $0x1c,%esp
f0105657:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010565b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010565f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105663:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105667:	85 f6                	test   %esi,%esi
f0105669:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010566d:	89 ca                	mov    %ecx,%edx
f010566f:	89 f8                	mov    %edi,%eax
f0105671:	75 3d                	jne    f01056b0 <__udivdi3+0x60>
f0105673:	39 cf                	cmp    %ecx,%edi
f0105675:	0f 87 c5 00 00 00    	ja     f0105740 <__udivdi3+0xf0>
f010567b:	85 ff                	test   %edi,%edi
f010567d:	89 fd                	mov    %edi,%ebp
f010567f:	75 0b                	jne    f010568c <__udivdi3+0x3c>
f0105681:	b8 01 00 00 00       	mov    $0x1,%eax
f0105686:	31 d2                	xor    %edx,%edx
f0105688:	f7 f7                	div    %edi
f010568a:	89 c5                	mov    %eax,%ebp
f010568c:	89 c8                	mov    %ecx,%eax
f010568e:	31 d2                	xor    %edx,%edx
f0105690:	f7 f5                	div    %ebp
f0105692:	89 c1                	mov    %eax,%ecx
f0105694:	89 d8                	mov    %ebx,%eax
f0105696:	89 cf                	mov    %ecx,%edi
f0105698:	f7 f5                	div    %ebp
f010569a:	89 c3                	mov    %eax,%ebx
f010569c:	89 d8                	mov    %ebx,%eax
f010569e:	89 fa                	mov    %edi,%edx
f01056a0:	83 c4 1c             	add    $0x1c,%esp
f01056a3:	5b                   	pop    %ebx
f01056a4:	5e                   	pop    %esi
f01056a5:	5f                   	pop    %edi
f01056a6:	5d                   	pop    %ebp
f01056a7:	c3                   	ret    
f01056a8:	90                   	nop
f01056a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01056b0:	39 ce                	cmp    %ecx,%esi
f01056b2:	77 74                	ja     f0105728 <__udivdi3+0xd8>
f01056b4:	0f bd fe             	bsr    %esi,%edi
f01056b7:	83 f7 1f             	xor    $0x1f,%edi
f01056ba:	0f 84 98 00 00 00    	je     f0105758 <__udivdi3+0x108>
f01056c0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01056c5:	89 f9                	mov    %edi,%ecx
f01056c7:	89 c5                	mov    %eax,%ebp
f01056c9:	29 fb                	sub    %edi,%ebx
f01056cb:	d3 e6                	shl    %cl,%esi
f01056cd:	89 d9                	mov    %ebx,%ecx
f01056cf:	d3 ed                	shr    %cl,%ebp
f01056d1:	89 f9                	mov    %edi,%ecx
f01056d3:	d3 e0                	shl    %cl,%eax
f01056d5:	09 ee                	or     %ebp,%esi
f01056d7:	89 d9                	mov    %ebx,%ecx
f01056d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01056dd:	89 d5                	mov    %edx,%ebp
f01056df:	8b 44 24 08          	mov    0x8(%esp),%eax
f01056e3:	d3 ed                	shr    %cl,%ebp
f01056e5:	89 f9                	mov    %edi,%ecx
f01056e7:	d3 e2                	shl    %cl,%edx
f01056e9:	89 d9                	mov    %ebx,%ecx
f01056eb:	d3 e8                	shr    %cl,%eax
f01056ed:	09 c2                	or     %eax,%edx
f01056ef:	89 d0                	mov    %edx,%eax
f01056f1:	89 ea                	mov    %ebp,%edx
f01056f3:	f7 f6                	div    %esi
f01056f5:	89 d5                	mov    %edx,%ebp
f01056f7:	89 c3                	mov    %eax,%ebx
f01056f9:	f7 64 24 0c          	mull   0xc(%esp)
f01056fd:	39 d5                	cmp    %edx,%ebp
f01056ff:	72 10                	jb     f0105711 <__udivdi3+0xc1>
f0105701:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105705:	89 f9                	mov    %edi,%ecx
f0105707:	d3 e6                	shl    %cl,%esi
f0105709:	39 c6                	cmp    %eax,%esi
f010570b:	73 07                	jae    f0105714 <__udivdi3+0xc4>
f010570d:	39 d5                	cmp    %edx,%ebp
f010570f:	75 03                	jne    f0105714 <__udivdi3+0xc4>
f0105711:	83 eb 01             	sub    $0x1,%ebx
f0105714:	31 ff                	xor    %edi,%edi
f0105716:	89 d8                	mov    %ebx,%eax
f0105718:	89 fa                	mov    %edi,%edx
f010571a:	83 c4 1c             	add    $0x1c,%esp
f010571d:	5b                   	pop    %ebx
f010571e:	5e                   	pop    %esi
f010571f:	5f                   	pop    %edi
f0105720:	5d                   	pop    %ebp
f0105721:	c3                   	ret    
f0105722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105728:	31 ff                	xor    %edi,%edi
f010572a:	31 db                	xor    %ebx,%ebx
f010572c:	89 d8                	mov    %ebx,%eax
f010572e:	89 fa                	mov    %edi,%edx
f0105730:	83 c4 1c             	add    $0x1c,%esp
f0105733:	5b                   	pop    %ebx
f0105734:	5e                   	pop    %esi
f0105735:	5f                   	pop    %edi
f0105736:	5d                   	pop    %ebp
f0105737:	c3                   	ret    
f0105738:	90                   	nop
f0105739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105740:	89 d8                	mov    %ebx,%eax
f0105742:	f7 f7                	div    %edi
f0105744:	31 ff                	xor    %edi,%edi
f0105746:	89 c3                	mov    %eax,%ebx
f0105748:	89 d8                	mov    %ebx,%eax
f010574a:	89 fa                	mov    %edi,%edx
f010574c:	83 c4 1c             	add    $0x1c,%esp
f010574f:	5b                   	pop    %ebx
f0105750:	5e                   	pop    %esi
f0105751:	5f                   	pop    %edi
f0105752:	5d                   	pop    %ebp
f0105753:	c3                   	ret    
f0105754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105758:	39 ce                	cmp    %ecx,%esi
f010575a:	72 0c                	jb     f0105768 <__udivdi3+0x118>
f010575c:	31 db                	xor    %ebx,%ebx
f010575e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0105762:	0f 87 34 ff ff ff    	ja     f010569c <__udivdi3+0x4c>
f0105768:	bb 01 00 00 00       	mov    $0x1,%ebx
f010576d:	e9 2a ff ff ff       	jmp    f010569c <__udivdi3+0x4c>
f0105772:	66 90                	xchg   %ax,%ax
f0105774:	66 90                	xchg   %ax,%ax
f0105776:	66 90                	xchg   %ax,%ax
f0105778:	66 90                	xchg   %ax,%ax
f010577a:	66 90                	xchg   %ax,%ax
f010577c:	66 90                	xchg   %ax,%ax
f010577e:	66 90                	xchg   %ax,%ax

f0105780 <__umoddi3>:
f0105780:	55                   	push   %ebp
f0105781:	57                   	push   %edi
f0105782:	56                   	push   %esi
f0105783:	53                   	push   %ebx
f0105784:	83 ec 1c             	sub    $0x1c,%esp
f0105787:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010578b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010578f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105793:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105797:	85 d2                	test   %edx,%edx
f0105799:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010579d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01057a1:	89 f3                	mov    %esi,%ebx
f01057a3:	89 3c 24             	mov    %edi,(%esp)
f01057a6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01057aa:	75 1c                	jne    f01057c8 <__umoddi3+0x48>
f01057ac:	39 f7                	cmp    %esi,%edi
f01057ae:	76 50                	jbe    f0105800 <__umoddi3+0x80>
f01057b0:	89 c8                	mov    %ecx,%eax
f01057b2:	89 f2                	mov    %esi,%edx
f01057b4:	f7 f7                	div    %edi
f01057b6:	89 d0                	mov    %edx,%eax
f01057b8:	31 d2                	xor    %edx,%edx
f01057ba:	83 c4 1c             	add    $0x1c,%esp
f01057bd:	5b                   	pop    %ebx
f01057be:	5e                   	pop    %esi
f01057bf:	5f                   	pop    %edi
f01057c0:	5d                   	pop    %ebp
f01057c1:	c3                   	ret    
f01057c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01057c8:	39 f2                	cmp    %esi,%edx
f01057ca:	89 d0                	mov    %edx,%eax
f01057cc:	77 52                	ja     f0105820 <__umoddi3+0xa0>
f01057ce:	0f bd ea             	bsr    %edx,%ebp
f01057d1:	83 f5 1f             	xor    $0x1f,%ebp
f01057d4:	75 5a                	jne    f0105830 <__umoddi3+0xb0>
f01057d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01057da:	0f 82 e0 00 00 00    	jb     f01058c0 <__umoddi3+0x140>
f01057e0:	39 0c 24             	cmp    %ecx,(%esp)
f01057e3:	0f 86 d7 00 00 00    	jbe    f01058c0 <__umoddi3+0x140>
f01057e9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01057ed:	8b 54 24 04          	mov    0x4(%esp),%edx
f01057f1:	83 c4 1c             	add    $0x1c,%esp
f01057f4:	5b                   	pop    %ebx
f01057f5:	5e                   	pop    %esi
f01057f6:	5f                   	pop    %edi
f01057f7:	5d                   	pop    %ebp
f01057f8:	c3                   	ret    
f01057f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105800:	85 ff                	test   %edi,%edi
f0105802:	89 fd                	mov    %edi,%ebp
f0105804:	75 0b                	jne    f0105811 <__umoddi3+0x91>
f0105806:	b8 01 00 00 00       	mov    $0x1,%eax
f010580b:	31 d2                	xor    %edx,%edx
f010580d:	f7 f7                	div    %edi
f010580f:	89 c5                	mov    %eax,%ebp
f0105811:	89 f0                	mov    %esi,%eax
f0105813:	31 d2                	xor    %edx,%edx
f0105815:	f7 f5                	div    %ebp
f0105817:	89 c8                	mov    %ecx,%eax
f0105819:	f7 f5                	div    %ebp
f010581b:	89 d0                	mov    %edx,%eax
f010581d:	eb 99                	jmp    f01057b8 <__umoddi3+0x38>
f010581f:	90                   	nop
f0105820:	89 c8                	mov    %ecx,%eax
f0105822:	89 f2                	mov    %esi,%edx
f0105824:	83 c4 1c             	add    $0x1c,%esp
f0105827:	5b                   	pop    %ebx
f0105828:	5e                   	pop    %esi
f0105829:	5f                   	pop    %edi
f010582a:	5d                   	pop    %ebp
f010582b:	c3                   	ret    
f010582c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105830:	8b 34 24             	mov    (%esp),%esi
f0105833:	bf 20 00 00 00       	mov    $0x20,%edi
f0105838:	89 e9                	mov    %ebp,%ecx
f010583a:	29 ef                	sub    %ebp,%edi
f010583c:	d3 e0                	shl    %cl,%eax
f010583e:	89 f9                	mov    %edi,%ecx
f0105840:	89 f2                	mov    %esi,%edx
f0105842:	d3 ea                	shr    %cl,%edx
f0105844:	89 e9                	mov    %ebp,%ecx
f0105846:	09 c2                	or     %eax,%edx
f0105848:	89 d8                	mov    %ebx,%eax
f010584a:	89 14 24             	mov    %edx,(%esp)
f010584d:	89 f2                	mov    %esi,%edx
f010584f:	d3 e2                	shl    %cl,%edx
f0105851:	89 f9                	mov    %edi,%ecx
f0105853:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105857:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010585b:	d3 e8                	shr    %cl,%eax
f010585d:	89 e9                	mov    %ebp,%ecx
f010585f:	89 c6                	mov    %eax,%esi
f0105861:	d3 e3                	shl    %cl,%ebx
f0105863:	89 f9                	mov    %edi,%ecx
f0105865:	89 d0                	mov    %edx,%eax
f0105867:	d3 e8                	shr    %cl,%eax
f0105869:	89 e9                	mov    %ebp,%ecx
f010586b:	09 d8                	or     %ebx,%eax
f010586d:	89 d3                	mov    %edx,%ebx
f010586f:	89 f2                	mov    %esi,%edx
f0105871:	f7 34 24             	divl   (%esp)
f0105874:	89 d6                	mov    %edx,%esi
f0105876:	d3 e3                	shl    %cl,%ebx
f0105878:	f7 64 24 04          	mull   0x4(%esp)
f010587c:	39 d6                	cmp    %edx,%esi
f010587e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105882:	89 d1                	mov    %edx,%ecx
f0105884:	89 c3                	mov    %eax,%ebx
f0105886:	72 08                	jb     f0105890 <__umoddi3+0x110>
f0105888:	75 11                	jne    f010589b <__umoddi3+0x11b>
f010588a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010588e:	73 0b                	jae    f010589b <__umoddi3+0x11b>
f0105890:	2b 44 24 04          	sub    0x4(%esp),%eax
f0105894:	1b 14 24             	sbb    (%esp),%edx
f0105897:	89 d1                	mov    %edx,%ecx
f0105899:	89 c3                	mov    %eax,%ebx
f010589b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010589f:	29 da                	sub    %ebx,%edx
f01058a1:	19 ce                	sbb    %ecx,%esi
f01058a3:	89 f9                	mov    %edi,%ecx
f01058a5:	89 f0                	mov    %esi,%eax
f01058a7:	d3 e0                	shl    %cl,%eax
f01058a9:	89 e9                	mov    %ebp,%ecx
f01058ab:	d3 ea                	shr    %cl,%edx
f01058ad:	89 e9                	mov    %ebp,%ecx
f01058af:	d3 ee                	shr    %cl,%esi
f01058b1:	09 d0                	or     %edx,%eax
f01058b3:	89 f2                	mov    %esi,%edx
f01058b5:	83 c4 1c             	add    $0x1c,%esp
f01058b8:	5b                   	pop    %ebx
f01058b9:	5e                   	pop    %esi
f01058ba:	5f                   	pop    %edi
f01058bb:	5d                   	pop    %ebp
f01058bc:	c3                   	ret    
f01058bd:	8d 76 00             	lea    0x0(%esi),%esi
f01058c0:	29 f9                	sub    %edi,%ecx
f01058c2:	19 d6                	sbb    %edx,%esi
f01058c4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01058c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01058cc:	e9 18 ff ff ff       	jmp    f01057e9 <__umoddi3+0x69>
