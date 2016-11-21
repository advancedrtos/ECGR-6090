
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
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
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
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

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
f0100048:	83 3d 98 fe 25 f0 00 	cmpl   $0x0,0xf025fe98
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 98 fe 25 f0    	mov    %esi,0xf025fe98

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 e9 5a 00 00       	call   f0105b4a <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 40 67 10 f0       	push   $0xf0106740
f010006d:	e8 72 36 00 00       	call   f01036e4 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 42 36 00 00       	call   f01036be <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 46 7f 10 f0 	movl   $0xf0107f46,(%esp)
f0100083:	e8 5c 36 00 00       	call   f01036e4 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 d1 08 00 00       	call   f0100966 <monitor>
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
f01000a1:	b8 08 10 2a f0       	mov    $0xf02a1008,%eax
f01000a6:	2d 3c e7 25 f0       	sub    $0xf025e73c,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 3c e7 25 f0       	push   $0xf025e73c
f01000b3:	e8 72 54 00 00       	call   f010552a <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 bf 05 00 00       	call   f010067c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 ac 67 10 f0       	push   $0xf01067ac
f01000ca:	e8 15 36 00 00       	call   f01036e4 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 bc 11 00 00       	call   f0101290 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 32 2e 00 00       	call   f0102f0b <env_init>
	trap_init();
f01000d9:	e8 ea 36 00 00       	call   f01037c8 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 5d 57 00 00       	call   f0105840 <mp_init>
	lapic_init();
f01000e3:	e8 7d 5a 00 00       	call   f0105b65 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 08 35 00 00       	call   f01035f5 <pic_init>

	// Lab 6 hardware initialization functions
	time_init();
f01000ed:	e8 68 63 00 00       	call   f010645a <time_init>
	pci_init();
f01000f2:	e8 43 63 00 00       	call   f010643a <pci_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000f7:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01000fe:	e8 b5 5c 00 00       	call   f0105db8 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100103:	83 c4 10             	add    $0x10,%esp
f0100106:	83 3d a0 fe 25 f0 07 	cmpl   $0x7,0xf025fea0
f010010d:	77 16                	ja     f0100125 <i386_init+0x8b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010010f:	68 00 70 00 00       	push   $0x7000
f0100114:	68 64 67 10 f0       	push   $0xf0106764
f0100119:	6a 6d                	push   $0x6d
f010011b:	68 c7 67 10 f0       	push   $0xf01067c7
f0100120:	e8 1b ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100125:	83 ec 04             	sub    $0x4,%esp
f0100128:	b8 a6 57 10 f0       	mov    $0xf01057a6,%eax
f010012d:	2d 2c 57 10 f0       	sub    $0xf010572c,%eax
f0100132:	50                   	push   %eax
f0100133:	68 2c 57 10 f0       	push   $0xf010572c
f0100138:	68 00 70 00 f0       	push   $0xf0007000
f010013d:	e8 35 54 00 00       	call   f0105577 <memmove>
f0100142:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100145:	bb 20 00 26 f0       	mov    $0xf0260020,%ebx
f010014a:	eb 4d                	jmp    f0100199 <i386_init+0xff>
		if (c == cpus + cpunum())  // We've started already.
f010014c:	e8 f9 59 00 00       	call   f0105b4a <cpunum>
f0100151:	6b c0 74             	imul   $0x74,%eax,%eax
f0100154:	05 20 00 26 f0       	add    $0xf0260020,%eax
f0100159:	39 c3                	cmp    %eax,%ebx
f010015b:	74 39                	je     f0100196 <i386_init+0xfc>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010015d:	89 d8                	mov    %ebx,%eax
f010015f:	2d 20 00 26 f0       	sub    $0xf0260020,%eax
f0100164:	c1 f8 02             	sar    $0x2,%eax
f0100167:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010016d:	c1 e0 0f             	shl    $0xf,%eax
f0100170:	05 00 90 26 f0       	add    $0xf0269000,%eax
f0100175:	a3 9c fe 25 f0       	mov    %eax,0xf025fe9c
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010017a:	83 ec 08             	sub    $0x8,%esp
f010017d:	68 00 70 00 00       	push   $0x7000
f0100182:	0f b6 03             	movzbl (%ebx),%eax
f0100185:	50                   	push   %eax
f0100186:	e8 28 5b 00 00       	call   f0105cb3 <lapic_startap>
f010018b:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010018e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100191:	83 f8 01             	cmp    $0x1,%eax
f0100194:	75 f8                	jne    f010018e <i386_init+0xf4>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100196:	83 c3 74             	add    $0x74,%ebx
f0100199:	6b 05 c4 03 26 f0 74 	imul   $0x74,0xf02603c4,%eax
f01001a0:	05 20 00 26 f0       	add    $0xf0260020,%eax
f01001a5:	39 c3                	cmp    %eax,%ebx
f01001a7:	72 a3                	jb     f010014c <i386_init+0xb2>
	lock_kernel();
	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01001a9:	83 ec 08             	sub    $0x8,%esp
f01001ac:	6a 01                	push   $0x1
f01001ae:	68 dc 10 1a f0       	push   $0xf01a10dc
f01001b3:	e8 28 2f 00 00       	call   f01030e0 <env_create>

#if !defined(TEST_NO_NS)
	// Start ns.
	ENV_CREATE(net_ns, ENV_TYPE_NS);
f01001b8:	83 c4 08             	add    $0x8,%esp
f01001bb:	6a 02                	push   $0x2
f01001bd:	68 9c be 1e f0       	push   $0xf01ebe9c
f01001c2:	e8 19 2f 00 00       	call   f01030e0 <env_create>
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.

//	ENV_CREATE(user_icode, ENV_TYPE_USER);
	ENV_CREATE(user_icode, ENV_TYPE_FS);
f01001c7:	83 c4 08             	add    $0x8,%esp
f01001ca:	6a 01                	push   $0x1
f01001cc:	68 a4 bf 19 f0       	push   $0xf019bfa4
f01001d1:	e8 0a 2f 00 00       	call   f01030e0 <env_create>

	ENV_CREATE(user_forktree, ENV_TYPE_USER);
f01001d6:	83 c4 08             	add    $0x8,%esp
f01001d9:	6a 00                	push   $0x0
f01001db:	68 a0 79 17 f0       	push   $0xf01779a0
f01001e0:	e8 fb 2e 00 00       	call   f01030e0 <env_create>
//	ENV_CREATE(user_yield, ENV_TYPE_USER);
//	ENV_CREATE(user_yield, ENV_TYPE_USER);
//	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
	cprintf("SRHS: all 3 env created\n");
f01001e5:	c7 04 24 d3 67 10 f0 	movl   $0xf01067d3,(%esp)
f01001ec:	e8 f3 34 00 00       	call   f01036e4 <cprintf>

#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001f1:	e8 2a 04 00 00       	call   f0100620 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001f6:	e8 0b 41 00 00       	call   f0104306 <sched_yield>

f01001fb <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001fb:	55                   	push   %ebp
f01001fc:	89 e5                	mov    %esp,%ebp
f01001fe:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f0100201:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100206:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010020b:	77 15                	ja     f0100222 <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010020d:	50                   	push   %eax
f010020e:	68 88 67 10 f0       	push   $0xf0106788
f0100213:	68 84 00 00 00       	push   $0x84
f0100218:	68 c7 67 10 f0       	push   $0xf01067c7
f010021d:	e8 1e fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100222:	05 00 00 00 10       	add    $0x10000000,%eax
f0100227:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010022a:	e8 1b 59 00 00       	call   f0105b4a <cpunum>
f010022f:	83 ec 08             	sub    $0x8,%esp
f0100232:	50                   	push   %eax
f0100233:	68 ec 67 10 f0       	push   $0xf01067ec
f0100238:	e8 a7 34 00 00       	call   f01036e4 <cprintf>

	lapic_init();
f010023d:	e8 23 59 00 00       	call   f0105b65 <lapic_init>
	env_init_percpu();
f0100242:	e8 94 2c 00 00       	call   f0102edb <env_init_percpu>
	trap_init_percpu();
f0100247:	e8 ac 34 00 00       	call   f01036f8 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010024c:	e8 f9 58 00 00       	call   f0105b4a <cpunum>
f0100251:	6b d0 74             	imul   $0x74,%eax,%edx
f0100254:	81 c2 20 00 26 f0    	add    $0xf0260020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010025a:	b8 01 00 00 00       	mov    $0x1,%eax
f010025f:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100263:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f010026a:	e8 49 5b 00 00       	call   f0105db8 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f010026f:	e8 92 40 00 00       	call   f0104306 <sched_yield>

f0100274 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100274:	55                   	push   %ebp
f0100275:	89 e5                	mov    %esp,%ebp
f0100277:	53                   	push   %ebx
f0100278:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010027b:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010027e:	ff 75 0c             	pushl  0xc(%ebp)
f0100281:	ff 75 08             	pushl  0x8(%ebp)
f0100284:	68 02 68 10 f0       	push   $0xf0106802
f0100289:	e8 56 34 00 00       	call   f01036e4 <cprintf>
	vcprintf(fmt, ap);
f010028e:	83 c4 08             	add    $0x8,%esp
f0100291:	53                   	push   %ebx
f0100292:	ff 75 10             	pushl  0x10(%ebp)
f0100295:	e8 24 34 00 00       	call   f01036be <vcprintf>
	cprintf("\n");
f010029a:	c7 04 24 46 7f 10 f0 	movl   $0xf0107f46,(%esp)
f01002a1:	e8 3e 34 00 00       	call   f01036e4 <cprintf>
	va_end(ap);
}
f01002a6:	83 c4 10             	add    $0x10,%esp
f01002a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002ac:	c9                   	leave  
f01002ad:	c3                   	ret    

f01002ae <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002ae:	55                   	push   %ebp
f01002af:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002b1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002b6:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002b7:	a8 01                	test   $0x1,%al
f01002b9:	74 0b                	je     f01002c6 <serial_proc_data+0x18>
f01002bb:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002c0:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002c1:	0f b6 c0             	movzbl %al,%eax
f01002c4:	eb 05                	jmp    f01002cb <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002cb:	5d                   	pop    %ebp
f01002cc:	c3                   	ret    

f01002cd <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002cd:	55                   	push   %ebp
f01002ce:	89 e5                	mov    %esp,%ebp
f01002d0:	53                   	push   %ebx
f01002d1:	83 ec 04             	sub    $0x4,%esp
f01002d4:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002d6:	eb 2b                	jmp    f0100303 <cons_intr+0x36>
		if (c == 0)
f01002d8:	85 c0                	test   %eax,%eax
f01002da:	74 27                	je     f0100303 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002dc:	8b 0d 24 f2 25 f0    	mov    0xf025f224,%ecx
f01002e2:	8d 51 01             	lea    0x1(%ecx),%edx
f01002e5:	89 15 24 f2 25 f0    	mov    %edx,0xf025f224
f01002eb:	88 81 20 f0 25 f0    	mov    %al,-0xfda0fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002f1:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002f7:	75 0a                	jne    f0100303 <cons_intr+0x36>
			cons.wpos = 0;
f01002f9:	c7 05 24 f2 25 f0 00 	movl   $0x0,0xf025f224
f0100300:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100303:	ff d3                	call   *%ebx
f0100305:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100308:	75 ce                	jne    f01002d8 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010030a:	83 c4 04             	add    $0x4,%esp
f010030d:	5b                   	pop    %ebx
f010030e:	5d                   	pop    %ebp
f010030f:	c3                   	ret    

f0100310 <kbd_proc_data>:
f0100310:	ba 64 00 00 00       	mov    $0x64,%edx
f0100315:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100316:	a8 01                	test   $0x1,%al
f0100318:	0f 84 f0 00 00 00    	je     f010040e <kbd_proc_data+0xfe>
f010031e:	ba 60 00 00 00       	mov    $0x60,%edx
f0100323:	ec                   	in     (%dx),%al
f0100324:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100326:	3c e0                	cmp    $0xe0,%al
f0100328:	75 0d                	jne    f0100337 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f010032a:	83 0d 00 f0 25 f0 40 	orl    $0x40,0xf025f000
		return 0;
f0100331:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100336:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100337:	55                   	push   %ebp
f0100338:	89 e5                	mov    %esp,%ebp
f010033a:	53                   	push   %ebx
f010033b:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010033e:	84 c0                	test   %al,%al
f0100340:	79 36                	jns    f0100378 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100342:	8b 0d 00 f0 25 f0    	mov    0xf025f000,%ecx
f0100348:	89 cb                	mov    %ecx,%ebx
f010034a:	83 e3 40             	and    $0x40,%ebx
f010034d:	83 e0 7f             	and    $0x7f,%eax
f0100350:	85 db                	test   %ebx,%ebx
f0100352:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100355:	0f b6 d2             	movzbl %dl,%edx
f0100358:	0f b6 82 80 69 10 f0 	movzbl -0xfef9680(%edx),%eax
f010035f:	83 c8 40             	or     $0x40,%eax
f0100362:	0f b6 c0             	movzbl %al,%eax
f0100365:	f7 d0                	not    %eax
f0100367:	21 c8                	and    %ecx,%eax
f0100369:	a3 00 f0 25 f0       	mov    %eax,0xf025f000
		return 0;
f010036e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100373:	e9 9e 00 00 00       	jmp    f0100416 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100378:	8b 0d 00 f0 25 f0    	mov    0xf025f000,%ecx
f010037e:	f6 c1 40             	test   $0x40,%cl
f0100381:	74 0e                	je     f0100391 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100383:	83 c8 80             	or     $0xffffff80,%eax
f0100386:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100388:	83 e1 bf             	and    $0xffffffbf,%ecx
f010038b:	89 0d 00 f0 25 f0    	mov    %ecx,0xf025f000
	}

	shift |= shiftcode[data];
f0100391:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100394:	0f b6 82 80 69 10 f0 	movzbl -0xfef9680(%edx),%eax
f010039b:	0b 05 00 f0 25 f0    	or     0xf025f000,%eax
f01003a1:	0f b6 8a 80 68 10 f0 	movzbl -0xfef9780(%edx),%ecx
f01003a8:	31 c8                	xor    %ecx,%eax
f01003aa:	a3 00 f0 25 f0       	mov    %eax,0xf025f000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003af:	89 c1                	mov    %eax,%ecx
f01003b1:	83 e1 03             	and    $0x3,%ecx
f01003b4:	8b 0c 8d 60 68 10 f0 	mov    -0xfef97a0(,%ecx,4),%ecx
f01003bb:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003bf:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003c2:	a8 08                	test   $0x8,%al
f01003c4:	74 1b                	je     f01003e1 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f01003c6:	89 da                	mov    %ebx,%edx
f01003c8:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003cb:	83 f9 19             	cmp    $0x19,%ecx
f01003ce:	77 05                	ja     f01003d5 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f01003d0:	83 eb 20             	sub    $0x20,%ebx
f01003d3:	eb 0c                	jmp    f01003e1 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f01003d5:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003d8:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003db:	83 fa 19             	cmp    $0x19,%edx
f01003de:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003e1:	f7 d0                	not    %eax
f01003e3:	a8 06                	test   $0x6,%al
f01003e5:	75 2d                	jne    f0100414 <kbd_proc_data+0x104>
f01003e7:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003ed:	75 25                	jne    f0100414 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01003ef:	83 ec 0c             	sub    $0xc,%esp
f01003f2:	68 1c 68 10 f0       	push   $0xf010681c
f01003f7:	e8 e8 32 00 00       	call   f01036e4 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003fc:	ba 92 00 00 00       	mov    $0x92,%edx
f0100401:	b8 03 00 00 00       	mov    $0x3,%eax
f0100406:	ee                   	out    %al,(%dx)
f0100407:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010040a:	89 d8                	mov    %ebx,%eax
f010040c:	eb 08                	jmp    f0100416 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010040e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100413:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100414:	89 d8                	mov    %ebx,%eax
}
f0100416:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100419:	c9                   	leave  
f010041a:	c3                   	ret    

f010041b <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010041b:	55                   	push   %ebp
f010041c:	89 e5                	mov    %esp,%ebp
f010041e:	57                   	push   %edi
f010041f:	56                   	push   %esi
f0100420:	53                   	push   %ebx
f0100421:	83 ec 1c             	sub    $0x1c,%esp
f0100424:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100426:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010042b:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100430:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100435:	eb 09                	jmp    f0100440 <cons_putc+0x25>
f0100437:	89 ca                	mov    %ecx,%edx
f0100439:	ec                   	in     (%dx),%al
f010043a:	ec                   	in     (%dx),%al
f010043b:	ec                   	in     (%dx),%al
f010043c:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f010043d:	83 c3 01             	add    $0x1,%ebx
f0100440:	89 f2                	mov    %esi,%edx
f0100442:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100443:	a8 20                	test   $0x20,%al
f0100445:	75 08                	jne    f010044f <cons_putc+0x34>
f0100447:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010044d:	7e e8                	jle    f0100437 <cons_putc+0x1c>
f010044f:	89 f8                	mov    %edi,%eax
f0100451:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100454:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100459:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010045a:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010045f:	be 79 03 00 00       	mov    $0x379,%esi
f0100464:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100469:	eb 09                	jmp    f0100474 <cons_putc+0x59>
f010046b:	89 ca                	mov    %ecx,%edx
f010046d:	ec                   	in     (%dx),%al
f010046e:	ec                   	in     (%dx),%al
f010046f:	ec                   	in     (%dx),%al
f0100470:	ec                   	in     (%dx),%al
f0100471:	83 c3 01             	add    $0x1,%ebx
f0100474:	89 f2                	mov    %esi,%edx
f0100476:	ec                   	in     (%dx),%al
f0100477:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010047d:	7f 04                	jg     f0100483 <cons_putc+0x68>
f010047f:	84 c0                	test   %al,%al
f0100481:	79 e8                	jns    f010046b <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100483:	ba 78 03 00 00       	mov    $0x378,%edx
f0100488:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010048c:	ee                   	out    %al,(%dx)
f010048d:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100492:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100497:	ee                   	out    %al,(%dx)
f0100498:	b8 08 00 00 00       	mov    $0x8,%eax
f010049d:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010049e:	89 fa                	mov    %edi,%edx
f01004a0:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004a6:	89 f8                	mov    %edi,%eax
f01004a8:	80 cc 07             	or     $0x7,%ah
f01004ab:	85 d2                	test   %edx,%edx
f01004ad:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01004b0:	89 f8                	mov    %edi,%eax
f01004b2:	0f b6 c0             	movzbl %al,%eax
f01004b5:	83 f8 09             	cmp    $0x9,%eax
f01004b8:	74 74                	je     f010052e <cons_putc+0x113>
f01004ba:	83 f8 09             	cmp    $0x9,%eax
f01004bd:	7f 0a                	jg     f01004c9 <cons_putc+0xae>
f01004bf:	83 f8 08             	cmp    $0x8,%eax
f01004c2:	74 14                	je     f01004d8 <cons_putc+0xbd>
f01004c4:	e9 99 00 00 00       	jmp    f0100562 <cons_putc+0x147>
f01004c9:	83 f8 0a             	cmp    $0xa,%eax
f01004cc:	74 3a                	je     f0100508 <cons_putc+0xed>
f01004ce:	83 f8 0d             	cmp    $0xd,%eax
f01004d1:	74 3d                	je     f0100510 <cons_putc+0xf5>
f01004d3:	e9 8a 00 00 00       	jmp    f0100562 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01004d8:	0f b7 05 28 f2 25 f0 	movzwl 0xf025f228,%eax
f01004df:	66 85 c0             	test   %ax,%ax
f01004e2:	0f 84 e6 00 00 00    	je     f01005ce <cons_putc+0x1b3>
			crt_pos--;
f01004e8:	83 e8 01             	sub    $0x1,%eax
f01004eb:	66 a3 28 f2 25 f0    	mov    %ax,0xf025f228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004f1:	0f b7 c0             	movzwl %ax,%eax
f01004f4:	66 81 e7 00 ff       	and    $0xff00,%di
f01004f9:	83 cf 20             	or     $0x20,%edi
f01004fc:	8b 15 2c f2 25 f0    	mov    0xf025f22c,%edx
f0100502:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100506:	eb 78                	jmp    f0100580 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100508:	66 83 05 28 f2 25 f0 	addw   $0x50,0xf025f228
f010050f:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100510:	0f b7 05 28 f2 25 f0 	movzwl 0xf025f228,%eax
f0100517:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010051d:	c1 e8 16             	shr    $0x16,%eax
f0100520:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100523:	c1 e0 04             	shl    $0x4,%eax
f0100526:	66 a3 28 f2 25 f0    	mov    %ax,0xf025f228
f010052c:	eb 52                	jmp    f0100580 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f010052e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100533:	e8 e3 fe ff ff       	call   f010041b <cons_putc>
		cons_putc(' ');
f0100538:	b8 20 00 00 00       	mov    $0x20,%eax
f010053d:	e8 d9 fe ff ff       	call   f010041b <cons_putc>
		cons_putc(' ');
f0100542:	b8 20 00 00 00       	mov    $0x20,%eax
f0100547:	e8 cf fe ff ff       	call   f010041b <cons_putc>
		cons_putc(' ');
f010054c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100551:	e8 c5 fe ff ff       	call   f010041b <cons_putc>
		cons_putc(' ');
f0100556:	b8 20 00 00 00       	mov    $0x20,%eax
f010055b:	e8 bb fe ff ff       	call   f010041b <cons_putc>
f0100560:	eb 1e                	jmp    f0100580 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100562:	0f b7 05 28 f2 25 f0 	movzwl 0xf025f228,%eax
f0100569:	8d 50 01             	lea    0x1(%eax),%edx
f010056c:	66 89 15 28 f2 25 f0 	mov    %dx,0xf025f228
f0100573:	0f b7 c0             	movzwl %ax,%eax
f0100576:	8b 15 2c f2 25 f0    	mov    0xf025f22c,%edx
f010057c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100580:	66 81 3d 28 f2 25 f0 	cmpw   $0x7cf,0xf025f228
f0100587:	cf 07 
f0100589:	76 43                	jbe    f01005ce <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010058b:	a1 2c f2 25 f0       	mov    0xf025f22c,%eax
f0100590:	83 ec 04             	sub    $0x4,%esp
f0100593:	68 00 0f 00 00       	push   $0xf00
f0100598:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010059e:	52                   	push   %edx
f010059f:	50                   	push   %eax
f01005a0:	e8 d2 4f 00 00       	call   f0105577 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005a5:	8b 15 2c f2 25 f0    	mov    0xf025f22c,%edx
f01005ab:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005b1:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005b7:	83 c4 10             	add    $0x10,%esp
f01005ba:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005bf:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005c2:	39 d0                	cmp    %edx,%eax
f01005c4:	75 f4                	jne    f01005ba <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005c6:	66 83 2d 28 f2 25 f0 	subw   $0x50,0xf025f228
f01005cd:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005ce:	8b 0d 30 f2 25 f0    	mov    0xf025f230,%ecx
f01005d4:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005d9:	89 ca                	mov    %ecx,%edx
f01005db:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005dc:	0f b7 1d 28 f2 25 f0 	movzwl 0xf025f228,%ebx
f01005e3:	8d 71 01             	lea    0x1(%ecx),%esi
f01005e6:	89 d8                	mov    %ebx,%eax
f01005e8:	66 c1 e8 08          	shr    $0x8,%ax
f01005ec:	89 f2                	mov    %esi,%edx
f01005ee:	ee                   	out    %al,(%dx)
f01005ef:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005f4:	89 ca                	mov    %ecx,%edx
f01005f6:	ee                   	out    %al,(%dx)
f01005f7:	89 d8                	mov    %ebx,%eax
f01005f9:	89 f2                	mov    %esi,%edx
f01005fb:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005ff:	5b                   	pop    %ebx
f0100600:	5e                   	pop    %esi
f0100601:	5f                   	pop    %edi
f0100602:	5d                   	pop    %ebp
f0100603:	c3                   	ret    

f0100604 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100604:	80 3d 34 f2 25 f0 00 	cmpb   $0x0,0xf025f234
f010060b:	74 11                	je     f010061e <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010060d:	55                   	push   %ebp
f010060e:	89 e5                	mov    %esp,%ebp
f0100610:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100613:	b8 ae 02 10 f0       	mov    $0xf01002ae,%eax
f0100618:	e8 b0 fc ff ff       	call   f01002cd <cons_intr>
}
f010061d:	c9                   	leave  
f010061e:	f3 c3                	repz ret 

f0100620 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100626:	b8 10 03 10 f0       	mov    $0xf0100310,%eax
f010062b:	e8 9d fc ff ff       	call   f01002cd <cons_intr>
}
f0100630:	c9                   	leave  
f0100631:	c3                   	ret    

f0100632 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100632:	55                   	push   %ebp
f0100633:	89 e5                	mov    %esp,%ebp
f0100635:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100638:	e8 c7 ff ff ff       	call   f0100604 <serial_intr>
	kbd_intr();
f010063d:	e8 de ff ff ff       	call   f0100620 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100642:	a1 20 f2 25 f0       	mov    0xf025f220,%eax
f0100647:	3b 05 24 f2 25 f0    	cmp    0xf025f224,%eax
f010064d:	74 26                	je     f0100675 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010064f:	8d 50 01             	lea    0x1(%eax),%edx
f0100652:	89 15 20 f2 25 f0    	mov    %edx,0xf025f220
f0100658:	0f b6 88 20 f0 25 f0 	movzbl -0xfda0fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010065f:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100661:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100667:	75 11                	jne    f010067a <cons_getc+0x48>
			cons.rpos = 0;
f0100669:	c7 05 20 f2 25 f0 00 	movl   $0x0,0xf025f220
f0100670:	00 00 00 
f0100673:	eb 05                	jmp    f010067a <cons_getc+0x48>
		return c;
	}
	return 0;
f0100675:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010067a:	c9                   	leave  
f010067b:	c3                   	ret    

f010067c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010067c:	55                   	push   %ebp
f010067d:	89 e5                	mov    %esp,%ebp
f010067f:	57                   	push   %edi
f0100680:	56                   	push   %esi
f0100681:	53                   	push   %ebx
f0100682:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100685:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010068c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100693:	5a a5 
	if (*cp != 0xA55A) {
f0100695:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010069c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006a0:	74 11                	je     f01006b3 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006a2:	c7 05 30 f2 25 f0 b4 	movl   $0x3b4,0xf025f230
f01006a9:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006ac:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006b1:	eb 16                	jmp    f01006c9 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006b3:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006ba:	c7 05 30 f2 25 f0 d4 	movl   $0x3d4,0xf025f230
f01006c1:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006c4:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006c9:	8b 3d 30 f2 25 f0    	mov    0xf025f230,%edi
f01006cf:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006d4:	89 fa                	mov    %edi,%edx
f01006d6:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006d7:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006da:	89 da                	mov    %ebx,%edx
f01006dc:	ec                   	in     (%dx),%al
f01006dd:	0f b6 c8             	movzbl %al,%ecx
f01006e0:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006e8:	89 fa                	mov    %edi,%edx
f01006ea:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006eb:	89 da                	mov    %ebx,%edx
f01006ed:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006ee:	89 35 2c f2 25 f0    	mov    %esi,0xf025f22c
	crt_pos = pos;
f01006f4:	0f b6 c0             	movzbl %al,%eax
f01006f7:	09 c8                	or     %ecx,%eax
f01006f9:	66 a3 28 f2 25 f0    	mov    %ax,0xf025f228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006ff:	e8 1c ff ff ff       	call   f0100620 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100704:	83 ec 0c             	sub    $0xc,%esp
f0100707:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f010070e:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100713:	50                   	push   %eax
f0100714:	e8 64 2e 00 00       	call   f010357d <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100719:	be fa 03 00 00       	mov    $0x3fa,%esi
f010071e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100723:	89 f2                	mov    %esi,%edx
f0100725:	ee                   	out    %al,(%dx)
f0100726:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010072b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100730:	ee                   	out    %al,(%dx)
f0100731:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100736:	b8 0c 00 00 00       	mov    $0xc,%eax
f010073b:	89 da                	mov    %ebx,%edx
f010073d:	ee                   	out    %al,(%dx)
f010073e:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100743:	b8 00 00 00 00       	mov    $0x0,%eax
f0100748:	ee                   	out    %al,(%dx)
f0100749:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010074e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100753:	ee                   	out    %al,(%dx)
f0100754:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100759:	b8 00 00 00 00       	mov    $0x0,%eax
f010075e:	ee                   	out    %al,(%dx)
f010075f:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100764:	b8 01 00 00 00       	mov    $0x1,%eax
f0100769:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010076a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010076f:	ec                   	in     (%dx),%al
f0100770:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100772:	83 c4 10             	add    $0x10,%esp
f0100775:	3c ff                	cmp    $0xff,%al
f0100777:	0f 95 05 34 f2 25 f0 	setne  0xf025f234
f010077e:	89 f2                	mov    %esi,%edx
f0100780:	ec                   	in     (%dx),%al
f0100781:	89 da                	mov    %ebx,%edx
f0100783:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100784:	80 f9 ff             	cmp    $0xff,%cl
f0100787:	74 21                	je     f01007aa <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f0100789:	83 ec 0c             	sub    $0xc,%esp
f010078c:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0100793:	25 ef ff 00 00       	and    $0xffef,%eax
f0100798:	50                   	push   %eax
f0100799:	e8 df 2d 00 00       	call   f010357d <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010079e:	83 c4 10             	add    $0x10,%esp
f01007a1:	80 3d 34 f2 25 f0 00 	cmpb   $0x0,0xf025f234
f01007a8:	75 10                	jne    f01007ba <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f01007aa:	83 ec 0c             	sub    $0xc,%esp
f01007ad:	68 28 68 10 f0       	push   $0xf0106828
f01007b2:	e8 2d 2f 00 00       	call   f01036e4 <cprintf>
f01007b7:	83 c4 10             	add    $0x10,%esp
}
f01007ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007bd:	5b                   	pop    %ebx
f01007be:	5e                   	pop    %esi
f01007bf:	5f                   	pop    %edi
f01007c0:	5d                   	pop    %ebp
f01007c1:	c3                   	ret    

f01007c2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007c2:	55                   	push   %ebp
f01007c3:	89 e5                	mov    %esp,%ebp
f01007c5:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01007cb:	e8 4b fc ff ff       	call   f010041b <cons_putc>
}
f01007d0:	c9                   	leave  
f01007d1:	c3                   	ret    

f01007d2 <getchar>:

int
getchar(void)
{
f01007d2:	55                   	push   %ebp
f01007d3:	89 e5                	mov    %esp,%ebp
f01007d5:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007d8:	e8 55 fe ff ff       	call   f0100632 <cons_getc>
f01007dd:	85 c0                	test   %eax,%eax
f01007df:	74 f7                	je     f01007d8 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007e1:	c9                   	leave  
f01007e2:	c3                   	ret    

f01007e3 <iscons>:

int
iscons(int fdnum)
{
f01007e3:	55                   	push   %ebp
f01007e4:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007e6:	b8 01 00 00 00       	mov    $0x1,%eax
f01007eb:	5d                   	pop    %ebp
f01007ec:	c3                   	ret    

f01007ed <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007ed:	55                   	push   %ebp
f01007ee:	89 e5                	mov    %esp,%ebp
f01007f0:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007f3:	68 80 6a 10 f0       	push   $0xf0106a80
f01007f8:	68 9e 6a 10 f0       	push   $0xf0106a9e
f01007fd:	68 a3 6a 10 f0       	push   $0xf0106aa3
f0100802:	e8 dd 2e 00 00       	call   f01036e4 <cprintf>
f0100807:	83 c4 0c             	add    $0xc,%esp
f010080a:	68 50 6b 10 f0       	push   $0xf0106b50
f010080f:	68 ac 6a 10 f0       	push   $0xf0106aac
f0100814:	68 a3 6a 10 f0       	push   $0xf0106aa3
f0100819:	e8 c6 2e 00 00       	call   f01036e4 <cprintf>
f010081e:	83 c4 0c             	add    $0xc,%esp
f0100821:	68 b5 6a 10 f0       	push   $0xf0106ab5
f0100826:	68 c3 6a 10 f0       	push   $0xf0106ac3
f010082b:	68 a3 6a 10 f0       	push   $0xf0106aa3
f0100830:	e8 af 2e 00 00       	call   f01036e4 <cprintf>
	return 0;
}
f0100835:	b8 00 00 00 00       	mov    $0x0,%eax
f010083a:	c9                   	leave  
f010083b:	c3                   	ret    

f010083c <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010083c:	55                   	push   %ebp
f010083d:	89 e5                	mov    %esp,%ebp
f010083f:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100842:	68 cd 6a 10 f0       	push   $0xf0106acd
f0100847:	e8 98 2e 00 00       	call   f01036e4 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010084c:	83 c4 08             	add    $0x8,%esp
f010084f:	68 0c 00 10 00       	push   $0x10000c
f0100854:	68 78 6b 10 f0       	push   $0xf0106b78
f0100859:	e8 86 2e 00 00       	call   f01036e4 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010085e:	83 c4 0c             	add    $0xc,%esp
f0100861:	68 0c 00 10 00       	push   $0x10000c
f0100866:	68 0c 00 10 f0       	push   $0xf010000c
f010086b:	68 a0 6b 10 f0       	push   $0xf0106ba0
f0100870:	e8 6f 2e 00 00       	call   f01036e4 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100875:	83 c4 0c             	add    $0xc,%esp
f0100878:	68 31 67 10 00       	push   $0x106731
f010087d:	68 31 67 10 f0       	push   $0xf0106731
f0100882:	68 c4 6b 10 f0       	push   $0xf0106bc4
f0100887:	e8 58 2e 00 00       	call   f01036e4 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010088c:	83 c4 0c             	add    $0xc,%esp
f010088f:	68 3c e7 25 00       	push   $0x25e73c
f0100894:	68 3c e7 25 f0       	push   $0xf025e73c
f0100899:	68 e8 6b 10 f0       	push   $0xf0106be8
f010089e:	e8 41 2e 00 00       	call   f01036e4 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008a3:	83 c4 0c             	add    $0xc,%esp
f01008a6:	68 08 10 2a 00       	push   $0x2a1008
f01008ab:	68 08 10 2a f0       	push   $0xf02a1008
f01008b0:	68 0c 6c 10 f0       	push   $0xf0106c0c
f01008b5:	e8 2a 2e 00 00       	call   f01036e4 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01008ba:	b8 07 14 2a f0       	mov    $0xf02a1407,%eax
f01008bf:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008c4:	83 c4 08             	add    $0x8,%esp
f01008c7:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01008cc:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008d2:	85 c0                	test   %eax,%eax
f01008d4:	0f 48 c2             	cmovs  %edx,%eax
f01008d7:	c1 f8 0a             	sar    $0xa,%eax
f01008da:	50                   	push   %eax
f01008db:	68 30 6c 10 f0       	push   $0xf0106c30
f01008e0:	e8 ff 2d 00 00       	call   f01036e4 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ea:	c9                   	leave  
f01008eb:	c3                   	ret    

f01008ec <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008ec:	55                   	push   %ebp
f01008ed:	89 e5                	mov    %esp,%ebp
f01008ef:	56                   	push   %esi
f01008f0:	53                   	push   %ebx
f01008f1:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008f4:	89 eb                	mov    %ebp,%ebx
	
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
f01008f6:	68 e6 6a 10 f0       	push   $0xf0106ae6
f01008fb:	e8 e4 2d 00 00       	call   f01036e4 <cprintf>
	
	while (ebp) {
f0100900:	83 c4 10             	add    $0x10,%esp
                  *(ebp+3),
                  *(ebp+4),
                  *(ebp+5),
                  *(ebp+6));
                  
	     debuginfo_eip((*(ebp+1)),&info);
f0100903:	8d 75 e0             	lea    -0x20(%ebp),%esi
	
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
	
	while (ebp) {
f0100906:	eb 4e                	jmp    f0100956 <mon_backtrace+0x6a>
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",ebp,*(ebp+1),
f0100908:	ff 73 18             	pushl  0x18(%ebx)
f010090b:	ff 73 14             	pushl  0x14(%ebx)
f010090e:	ff 73 10             	pushl  0x10(%ebx)
f0100911:	ff 73 0c             	pushl  0xc(%ebx)
f0100914:	ff 73 08             	pushl  0x8(%ebx)
f0100917:	ff 73 04             	pushl  0x4(%ebx)
f010091a:	53                   	push   %ebx
f010091b:	68 5c 6c 10 f0       	push   $0xf0106c5c
f0100920:	e8 bf 2d 00 00       	call   f01036e4 <cprintf>
                  *(ebp+3),
                  *(ebp+4),
                  *(ebp+5),
                  *(ebp+6));
                  
	     debuginfo_eip((*(ebp+1)),&info);
f0100925:	83 c4 18             	add    $0x18,%esp
f0100928:	56                   	push   %esi
f0100929:	ff 73 04             	pushl  0x4(%ebx)
f010092c:	e8 7f 41 00 00       	call   f0104ab0 <debuginfo_eip>
	     cprintf("         %s:%d: %.*s+%d\n", 
f0100931:	83 c4 08             	add    $0x8,%esp
f0100934:	8b 43 04             	mov    0x4(%ebx),%eax
f0100937:	2b 45 f0             	sub    -0x10(%ebp),%eax
f010093a:	50                   	push   %eax
f010093b:	ff 75 e8             	pushl  -0x18(%ebp)
f010093e:	ff 75 ec             	pushl  -0x14(%ebp)
f0100941:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100944:	ff 75 e0             	pushl  -0x20(%ebp)
f0100947:	68 f8 6a 10 f0       	push   $0xf0106af8
f010094c:	e8 93 2d 00 00       	call   f01036e4 <cprintf>
	     info.eip_file, info.eip_line,
	     info.eip_fn_namelen, info.eip_fn_name, (*(ebp+1)) - info.eip_fn_addr);

	     ebp = (uint32_t *)*(ebp);
f0100951:	8b 1b                	mov    (%ebx),%ebx
f0100953:	83 c4 20             	add    $0x20,%esp
	
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
	
	while (ebp) {
f0100956:	85 db                	test   %ebx,%ebx
f0100958:	75 ae                	jne    f0100908 <mon_backtrace+0x1c>
	     ebp = (uint32_t *)*(ebp);
    }

	
	return 0;
}
f010095a:	b8 00 00 00 00       	mov    $0x0,%eax
f010095f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100962:	5b                   	pop    %ebx
f0100963:	5e                   	pop    %esi
f0100964:	5d                   	pop    %ebp
f0100965:	c3                   	ret    

f0100966 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100966:	55                   	push   %ebp
f0100967:	89 e5                	mov    %esp,%ebp
f0100969:	57                   	push   %edi
f010096a:	56                   	push   %esi
f010096b:	53                   	push   %ebx
f010096c:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010096f:	68 90 6c 10 f0       	push   $0xf0106c90
f0100974:	e8 6b 2d 00 00       	call   f01036e4 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100979:	c7 04 24 b4 6c 10 f0 	movl   $0xf0106cb4,(%esp)
f0100980:	e8 5f 2d 00 00       	call   f01036e4 <cprintf>

	if (tf != NULL)
f0100985:	83 c4 10             	add    $0x10,%esp
f0100988:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010098c:	74 0e                	je     f010099c <monitor+0x36>
		print_trapframe(tf);
f010098e:	83 ec 0c             	sub    $0xc,%esp
f0100991:	ff 75 08             	pushl  0x8(%ebp)
f0100994:	e8 fd 32 00 00       	call   f0103c96 <print_trapframe>
f0100999:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010099c:	83 ec 0c             	sub    $0xc,%esp
f010099f:	68 11 6b 10 f0       	push   $0xf0106b11
f01009a4:	e8 12 49 00 00       	call   f01052bb <readline>
f01009a9:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009ab:	83 c4 10             	add    $0x10,%esp
f01009ae:	85 c0                	test   %eax,%eax
f01009b0:	74 ea                	je     f010099c <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009b2:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009b9:	be 00 00 00 00       	mov    $0x0,%esi
f01009be:	eb 0a                	jmp    f01009ca <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009c0:	c6 03 00             	movb   $0x0,(%ebx)
f01009c3:	89 f7                	mov    %esi,%edi
f01009c5:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009c8:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009ca:	0f b6 03             	movzbl (%ebx),%eax
f01009cd:	84 c0                	test   %al,%al
f01009cf:	74 63                	je     f0100a34 <monitor+0xce>
f01009d1:	83 ec 08             	sub    $0x8,%esp
f01009d4:	0f be c0             	movsbl %al,%eax
f01009d7:	50                   	push   %eax
f01009d8:	68 15 6b 10 f0       	push   $0xf0106b15
f01009dd:	e8 0b 4b 00 00       	call   f01054ed <strchr>
f01009e2:	83 c4 10             	add    $0x10,%esp
f01009e5:	85 c0                	test   %eax,%eax
f01009e7:	75 d7                	jne    f01009c0 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009e9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009ec:	74 46                	je     f0100a34 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009ee:	83 fe 0f             	cmp    $0xf,%esi
f01009f1:	75 14                	jne    f0100a07 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009f3:	83 ec 08             	sub    $0x8,%esp
f01009f6:	6a 10                	push   $0x10
f01009f8:	68 1a 6b 10 f0       	push   $0xf0106b1a
f01009fd:	e8 e2 2c 00 00       	call   f01036e4 <cprintf>
f0100a02:	83 c4 10             	add    $0x10,%esp
f0100a05:	eb 95                	jmp    f010099c <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100a07:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a0a:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a0e:	eb 03                	jmp    f0100a13 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a10:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a13:	0f b6 03             	movzbl (%ebx),%eax
f0100a16:	84 c0                	test   %al,%al
f0100a18:	74 ae                	je     f01009c8 <monitor+0x62>
f0100a1a:	83 ec 08             	sub    $0x8,%esp
f0100a1d:	0f be c0             	movsbl %al,%eax
f0100a20:	50                   	push   %eax
f0100a21:	68 15 6b 10 f0       	push   $0xf0106b15
f0100a26:	e8 c2 4a 00 00       	call   f01054ed <strchr>
f0100a2b:	83 c4 10             	add    $0x10,%esp
f0100a2e:	85 c0                	test   %eax,%eax
f0100a30:	74 de                	je     f0100a10 <monitor+0xaa>
f0100a32:	eb 94                	jmp    f01009c8 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a34:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a3b:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a3c:	85 f6                	test   %esi,%esi
f0100a3e:	0f 84 58 ff ff ff    	je     f010099c <monitor+0x36>
f0100a44:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a49:	83 ec 08             	sub    $0x8,%esp
f0100a4c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a4f:	ff 34 85 e0 6c 10 f0 	pushl  -0xfef9320(,%eax,4)
f0100a56:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a59:	e8 31 4a 00 00       	call   f010548f <strcmp>
f0100a5e:	83 c4 10             	add    $0x10,%esp
f0100a61:	85 c0                	test   %eax,%eax
f0100a63:	75 21                	jne    f0100a86 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100a65:	83 ec 04             	sub    $0x4,%esp
f0100a68:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a6b:	ff 75 08             	pushl  0x8(%ebp)
f0100a6e:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a71:	52                   	push   %edx
f0100a72:	56                   	push   %esi
f0100a73:	ff 14 85 e8 6c 10 f0 	call   *-0xfef9318(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a7a:	83 c4 10             	add    $0x10,%esp
f0100a7d:	85 c0                	test   %eax,%eax
f0100a7f:	78 25                	js     f0100aa6 <monitor+0x140>
f0100a81:	e9 16 ff ff ff       	jmp    f010099c <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a86:	83 c3 01             	add    $0x1,%ebx
f0100a89:	83 fb 03             	cmp    $0x3,%ebx
f0100a8c:	75 bb                	jne    f0100a49 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a8e:	83 ec 08             	sub    $0x8,%esp
f0100a91:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a94:	68 37 6b 10 f0       	push   $0xf0106b37
f0100a99:	e8 46 2c 00 00       	call   f01036e4 <cprintf>
f0100a9e:	83 c4 10             	add    $0x10,%esp
f0100aa1:	e9 f6 fe ff ff       	jmp    f010099c <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100aa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aa9:	5b                   	pop    %ebx
f0100aaa:	5e                   	pop    %esi
f0100aab:	5f                   	pop    %edi
f0100aac:	5d                   	pop    %ebp
f0100aad:	c3                   	ret    

f0100aae <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100aae:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ab0:	83 3d 38 f2 25 f0 00 	cmpl   $0x0,0xf025f238
f0100ab7:	75 0f                	jne    f0100ac8 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ab9:	b8 07 20 2a f0       	mov    $0xf02a2007,%eax
f0100abe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ac3:	a3 38 f2 25 f0       	mov    %eax,0xf025f238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n > 0){
f0100ac8:	85 d2                	test   %edx,%edx
f0100aca:	74 42                	je     f0100b0e <boot_alloc+0x60>
		//cprintf("\nNextfree before allocation %x\n", nextfree);
		result = nextfree;
f0100acc:	a1 38 f2 25 f0       	mov    0xf025f238,%eax
		nextfree = nextfree + n;

		//cprintf("Nextfree after allocation %x\n", nextfree);
		//cprintf ("Bytes to be allocated %u\n", ((nextfree - result)/8));
		 
		nextfree = ROUNDUP((char *)nextfree , PGSIZE);
f0100ad1:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100ad8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ade:	89 15 38 f2 25 f0    	mov    %edx,0xf025f238
		
		
		//cprintf ("Nextfree after rounding up to page size %x\n", nextfree);
		//cprintf ("Bytes allocated %u\n", ((nextfree - result)/8));
		//cprintf ("Check%x\n ",((uint32_t)nextfree - KERNBASE));
		if (((uint32_t)nextfree - KERNBASE) > (npages * PGSIZE)){
f0100ae4:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100aea:	8b 0d a0 fe 25 f0    	mov    0xf025fea0,%ecx
f0100af0:	c1 e1 0c             	shl    $0xc,%ecx
f0100af3:	39 ca                	cmp    %ecx,%edx
f0100af5:	76 1c                	jbe    f0100b13 <boot_alloc+0x65>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100af7:	55                   	push   %ebp
f0100af8:	89 e5                	mov    %esp,%ebp
f0100afa:	83 ec 0c             	sub    $0xc,%esp
		
		//cprintf ("Nextfree after rounding up to page size %x\n", nextfree);
		//cprintf ("Bytes allocated %u\n", ((nextfree - result)/8));
		//cprintf ("Check%x\n ",((uint32_t)nextfree - KERNBASE));
		if (((uint32_t)nextfree - KERNBASE) > (npages * PGSIZE)){
			panic("boot_alloc panicked: Out of Memory\n");
f0100afd:	68 04 6d 10 f0       	push   $0xf0106d04
f0100b02:	6a 7b                	push   $0x7b
f0100b04:	68 9d 76 10 f0       	push   $0xf010769d
f0100b09:	e8 32 f5 ff ff       	call   f0100040 <_panic>
					
		}	
	}

	else{
		result = nextfree;
f0100b0e:	a1 38 f2 25 f0       	mov    0xf025f238,%eax
	} 

	return result;
}
f0100b13:	f3 c3                	repz ret 

f0100b15 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b15:	89 d1                	mov    %edx,%ecx
f0100b17:	c1 e9 16             	shr    $0x16,%ecx
f0100b1a:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b1d:	a8 01                	test   $0x1,%al
f0100b1f:	74 52                	je     f0100b73 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b21:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b26:	89 c1                	mov    %eax,%ecx
f0100b28:	c1 e9 0c             	shr    $0xc,%ecx
f0100b2b:	3b 0d a0 fe 25 f0    	cmp    0xf025fea0,%ecx
f0100b31:	72 1b                	jb     f0100b4e <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b33:	55                   	push   %ebp
f0100b34:	89 e5                	mov    %esp,%ebp
f0100b36:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b39:	50                   	push   %eax
f0100b3a:	68 64 67 10 f0       	push   $0xf0106764
f0100b3f:	68 c0 03 00 00       	push   $0x3c0
f0100b44:	68 9d 76 10 f0       	push   $0xf010769d
f0100b49:	e8 f2 f4 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b4e:	c1 ea 0c             	shr    $0xc,%edx
f0100b51:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b57:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b5e:	89 c2                	mov    %eax,%edx
f0100b60:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b63:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b68:	85 d2                	test   %edx,%edx
f0100b6a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b6f:	0f 44 c2             	cmove  %edx,%eax
f0100b72:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b78:	c3                   	ret    

f0100b79 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b79:	55                   	push   %ebp
f0100b7a:	89 e5                	mov    %esp,%ebp
f0100b7c:	57                   	push   %edi
f0100b7d:	56                   	push   %esi
f0100b7e:	53                   	push   %ebx
f0100b7f:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b82:	84 c0                	test   %al,%al
f0100b84:	0f 85 91 02 00 00    	jne    f0100e1b <check_page_free_list+0x2a2>
f0100b8a:	e9 9e 02 00 00       	jmp    f0100e2d <check_page_free_list+0x2b4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b8f:	83 ec 04             	sub    $0x4,%esp
f0100b92:	68 28 6d 10 f0       	push   $0xf0106d28
f0100b97:	68 f5 02 00 00       	push   $0x2f5
f0100b9c:	68 9d 76 10 f0       	push   $0xf010769d
f0100ba1:	e8 9a f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100ba6:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100ba9:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100bac:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100baf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bb2:	89 c2                	mov    %eax,%edx
f0100bb4:	2b 15 a8 fe 25 f0    	sub    0xf025fea8,%edx
f0100bba:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100bc0:	0f 95 c2             	setne  %dl
f0100bc3:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100bc6:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100bca:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100bcc:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bd0:	8b 00                	mov    (%eax),%eax
f0100bd2:	85 c0                	test   %eax,%eax
f0100bd4:	75 dc                	jne    f0100bb2 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100bd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bd9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100bdf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100be2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100be5:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100be7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bea:	a3 40 f2 25 f0       	mov    %eax,0xf025f240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bef:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bf4:	8b 1d 40 f2 25 f0    	mov    0xf025f240,%ebx
f0100bfa:	eb 53                	jmp    f0100c4f <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bfc:	89 d8                	mov    %ebx,%eax
f0100bfe:	2b 05 a8 fe 25 f0    	sub    0xf025fea8,%eax
f0100c04:	c1 f8 03             	sar    $0x3,%eax
f0100c07:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c0a:	89 c2                	mov    %eax,%edx
f0100c0c:	c1 ea 16             	shr    $0x16,%edx
f0100c0f:	39 f2                	cmp    %esi,%edx
f0100c11:	73 3a                	jae    f0100c4d <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c13:	89 c2                	mov    %eax,%edx
f0100c15:	c1 ea 0c             	shr    $0xc,%edx
f0100c18:	3b 15 a0 fe 25 f0    	cmp    0xf025fea0,%edx
f0100c1e:	72 12                	jb     f0100c32 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c20:	50                   	push   %eax
f0100c21:	68 64 67 10 f0       	push   $0xf0106764
f0100c26:	6a 58                	push   $0x58
f0100c28:	68 a9 76 10 f0       	push   $0xf01076a9
f0100c2d:	e8 0e f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c32:	83 ec 04             	sub    $0x4,%esp
f0100c35:	68 80 00 00 00       	push   $0x80
f0100c3a:	68 97 00 00 00       	push   $0x97
f0100c3f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c44:	50                   	push   %eax
f0100c45:	e8 e0 48 00 00       	call   f010552a <memset>
f0100c4a:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c4d:	8b 1b                	mov    (%ebx),%ebx
f0100c4f:	85 db                	test   %ebx,%ebx
f0100c51:	75 a9                	jne    f0100bfc <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c53:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c58:	e8 51 fe ff ff       	call   f0100aae <boot_alloc>
f0100c5d:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c60:	8b 15 40 f2 25 f0    	mov    0xf025f240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c66:	8b 0d a8 fe 25 f0    	mov    0xf025fea8,%ecx
		assert(pp < pages + npages);
f0100c6c:	a1 a0 fe 25 f0       	mov    0xf025fea0,%eax
f0100c71:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c74:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c77:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c7a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c7d:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c82:	e9 52 01 00 00       	jmp    f0100dd9 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c87:	39 ca                	cmp    %ecx,%edx
f0100c89:	73 19                	jae    f0100ca4 <check_page_free_list+0x12b>
f0100c8b:	68 b7 76 10 f0       	push   $0xf01076b7
f0100c90:	68 c3 76 10 f0       	push   $0xf01076c3
f0100c95:	68 0f 03 00 00       	push   $0x30f
f0100c9a:	68 9d 76 10 f0       	push   $0xf010769d
f0100c9f:	e8 9c f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100ca4:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100ca7:	72 19                	jb     f0100cc2 <check_page_free_list+0x149>
f0100ca9:	68 d8 76 10 f0       	push   $0xf01076d8
f0100cae:	68 c3 76 10 f0       	push   $0xf01076c3
f0100cb3:	68 10 03 00 00       	push   $0x310
f0100cb8:	68 9d 76 10 f0       	push   $0xf010769d
f0100cbd:	e8 7e f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cc2:	89 d0                	mov    %edx,%eax
f0100cc4:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100cc7:	a8 07                	test   $0x7,%al
f0100cc9:	74 19                	je     f0100ce4 <check_page_free_list+0x16b>
f0100ccb:	68 4c 6d 10 f0       	push   $0xf0106d4c
f0100cd0:	68 c3 76 10 f0       	push   $0xf01076c3
f0100cd5:	68 11 03 00 00       	push   $0x311
f0100cda:	68 9d 76 10 f0       	push   $0xf010769d
f0100cdf:	e8 5c f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ce4:	c1 f8 03             	sar    $0x3,%eax
f0100ce7:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cea:	85 c0                	test   %eax,%eax
f0100cec:	75 19                	jne    f0100d07 <check_page_free_list+0x18e>
f0100cee:	68 ec 76 10 f0       	push   $0xf01076ec
f0100cf3:	68 c3 76 10 f0       	push   $0xf01076c3
f0100cf8:	68 14 03 00 00       	push   $0x314
f0100cfd:	68 9d 76 10 f0       	push   $0xf010769d
f0100d02:	e8 39 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d07:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d0c:	75 19                	jne    f0100d27 <check_page_free_list+0x1ae>
f0100d0e:	68 fd 76 10 f0       	push   $0xf01076fd
f0100d13:	68 c3 76 10 f0       	push   $0xf01076c3
f0100d18:	68 15 03 00 00       	push   $0x315
f0100d1d:	68 9d 76 10 f0       	push   $0xf010769d
f0100d22:	e8 19 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d27:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d2c:	75 19                	jne    f0100d47 <check_page_free_list+0x1ce>
f0100d2e:	68 80 6d 10 f0       	push   $0xf0106d80
f0100d33:	68 c3 76 10 f0       	push   $0xf01076c3
f0100d38:	68 16 03 00 00       	push   $0x316
f0100d3d:	68 9d 76 10 f0       	push   $0xf010769d
f0100d42:	e8 f9 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d47:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d4c:	75 19                	jne    f0100d67 <check_page_free_list+0x1ee>
f0100d4e:	68 16 77 10 f0       	push   $0xf0107716
f0100d53:	68 c3 76 10 f0       	push   $0xf01076c3
f0100d58:	68 17 03 00 00       	push   $0x317
f0100d5d:	68 9d 76 10 f0       	push   $0xf010769d
f0100d62:	e8 d9 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d67:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d6c:	0f 86 de 00 00 00    	jbe    f0100e50 <check_page_free_list+0x2d7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d72:	89 c7                	mov    %eax,%edi
f0100d74:	c1 ef 0c             	shr    $0xc,%edi
f0100d77:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d7a:	77 12                	ja     f0100d8e <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d7c:	50                   	push   %eax
f0100d7d:	68 64 67 10 f0       	push   $0xf0106764
f0100d82:	6a 58                	push   $0x58
f0100d84:	68 a9 76 10 f0       	push   $0xf01076a9
f0100d89:	e8 b2 f2 ff ff       	call   f0100040 <_panic>
f0100d8e:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d94:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100d97:	0f 86 a7 00 00 00    	jbe    f0100e44 <check_page_free_list+0x2cb>
f0100d9d:	68 a4 6d 10 f0       	push   $0xf0106da4
f0100da2:	68 c3 76 10 f0       	push   $0xf01076c3
f0100da7:	68 18 03 00 00       	push   $0x318
f0100dac:	68 9d 76 10 f0       	push   $0xf010769d
f0100db1:	e8 8a f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100db6:	68 30 77 10 f0       	push   $0xf0107730
f0100dbb:	68 c3 76 10 f0       	push   $0xf01076c3
f0100dc0:	68 1a 03 00 00       	push   $0x31a
f0100dc5:	68 9d 76 10 f0       	push   $0xf010769d
f0100dca:	e8 71 f2 ff ff       	call   f0100040 <_panic>
		
		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100dcf:	83 c6 01             	add    $0x1,%esi
f0100dd2:	eb 03                	jmp    f0100dd7 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100dd4:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dd7:	8b 12                	mov    (%edx),%edx
f0100dd9:	85 d2                	test   %edx,%edx
f0100ddb:	0f 85 a6 fe ff ff    	jne    f0100c87 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100de1:	85 f6                	test   %esi,%esi
f0100de3:	7f 19                	jg     f0100dfe <check_page_free_list+0x285>
f0100de5:	68 4d 77 10 f0       	push   $0xf010774d
f0100dea:	68 c3 76 10 f0       	push   $0xf01076c3
f0100def:	68 22 03 00 00       	push   $0x322
f0100df4:	68 9d 76 10 f0       	push   $0xf010769d
f0100df9:	e8 42 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100dfe:	85 db                	test   %ebx,%ebx
f0100e00:	7f 5e                	jg     f0100e60 <check_page_free_list+0x2e7>
f0100e02:	68 5f 77 10 f0       	push   $0xf010775f
f0100e07:	68 c3 76 10 f0       	push   $0xf01076c3
f0100e0c:	68 23 03 00 00       	push   $0x323
f0100e11:	68 9d 76 10 f0       	push   $0xf010769d
f0100e16:	e8 25 f2 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e1b:	a1 40 f2 25 f0       	mov    0xf025f240,%eax
f0100e20:	85 c0                	test   %eax,%eax
f0100e22:	0f 85 7e fd ff ff    	jne    f0100ba6 <check_page_free_list+0x2d>
f0100e28:	e9 62 fd ff ff       	jmp    f0100b8f <check_page_free_list+0x16>
f0100e2d:	83 3d 40 f2 25 f0 00 	cmpl   $0x0,0xf025f240
f0100e34:	0f 84 55 fd ff ff    	je     f0100b8f <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e3a:	be 00 04 00 00       	mov    $0x400,%esi
f0100e3f:	e9 b0 fd ff ff       	jmp    f0100bf4 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e44:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e49:	75 89                	jne    f0100dd4 <check_page_free_list+0x25b>
f0100e4b:	e9 66 ff ff ff       	jmp    f0100db6 <check_page_free_list+0x23d>
f0100e50:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e55:	0f 85 74 ff ff ff    	jne    f0100dcf <check_page_free_list+0x256>
f0100e5b:	e9 56 ff ff ff       	jmp    f0100db6 <check_page_free_list+0x23d>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100e60:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e63:	5b                   	pop    %ebx
f0100e64:	5e                   	pop    %esi
f0100e65:	5f                   	pop    %edi
f0100e66:	5d                   	pop    %ebp
f0100e67:	c3                   	ret    

f0100e68 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e68:	55                   	push   %ebp
f0100e69:	89 e5                	mov    %esp,%ebp
f0100e6b:	56                   	push   %esi
f0100e6c:	53                   	push   %ebx
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	
	 for (i = 0; i < npages; i++) {
f0100e6d:	be 00 00 00 00       	mov    $0x0,%esi
f0100e72:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e77:	e9 9b 00 00 00       	jmp    f0100f17 <page_init+0xaf>
                if(i == 0 || (i >= (IOPHYSMEM/PGSIZE) && i < (EXTPHYSMEM/PGSIZE))) {
f0100e7c:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0100e82:	83 f8 5f             	cmp    $0x5f,%eax
f0100e85:	76 04                	jbe    f0100e8b <page_init+0x23>
f0100e87:	85 db                	test   %ebx,%ebx
f0100e89:	75 16                	jne    f0100ea1 <page_init+0x39>
                        pages[i].pp_ref = (uint16_t) 0;
f0100e8b:	89 f0                	mov    %esi,%eax
f0100e8d:	03 05 a8 fe 25 f0    	add    0xf025fea8,%eax
f0100e93:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
                        pages[i].pp_link = NULL;
f0100e99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100e9f:	eb 70                	jmp    f0100f11 <page_init+0xa9>
                }else if(i >= (EXTPHYSMEM/PGSIZE) && 
f0100ea1:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100ea7:	76 2c                	jbe    f0100ed5 <page_init+0x6d>
                         i < (((uint32_t)(boot_alloc(0)-KERNBASE))/PGSIZE)) {
f0100ea9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eae:	e8 fb fb ff ff       	call   f0100aae <boot_alloc>
	
	 for (i = 0; i < npages; i++) {
                if(i == 0 || (i >= (IOPHYSMEM/PGSIZE) && i < (EXTPHYSMEM/PGSIZE))) {
                        pages[i].pp_ref = (uint16_t) 0;
                        pages[i].pp_link = NULL;
                }else if(i >= (EXTPHYSMEM/PGSIZE) && 
f0100eb3:	05 00 00 00 10       	add    $0x10000000,%eax
f0100eb8:	c1 e8 0c             	shr    $0xc,%eax
f0100ebb:	39 c3                	cmp    %eax,%ebx
f0100ebd:	73 16                	jae    f0100ed5 <page_init+0x6d>
                         i < (((uint32_t)(boot_alloc(0)-KERNBASE))/PGSIZE)) {
                        pages[i].pp_ref = (uint16_t) 0;
f0100ebf:	89 f0                	mov    %esi,%eax
f0100ec1:	03 05 a8 fe 25 f0    	add    0xf025fea8,%eax
f0100ec7:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
                        pages[i].pp_link = NULL;
f0100ecd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100ed3:	eb 3c                	jmp    f0100f11 <page_init+0xa9>
                }else if(i == (MPENTRY_PADDR/PGSIZE)) {
f0100ed5:	83 fb 07             	cmp    $0x7,%ebx
f0100ed8:	75 14                	jne    f0100eee <page_init+0x86>
			pages[i].pp_ref = (uint16_t) 0;
f0100eda:	a1 a8 fe 25 f0       	mov    0xf025fea8,%eax
f0100edf:	66 c7 40 3c 00 00    	movw   $0x0,0x3c(%eax)
                        pages[i].pp_link = NULL;
f0100ee5:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0100eec:	eb 23                	jmp    f0100f11 <page_init+0xa9>
		}else{
                        pages[i].pp_ref = 0;
f0100eee:	89 f0                	mov    %esi,%eax
f0100ef0:	03 05 a8 fe 25 f0    	add    0xf025fea8,%eax
f0100ef6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
                        pages[i].pp_link = page_free_list;
f0100efc:	8b 15 40 f2 25 f0    	mov    0xf025f240,%edx
f0100f02:	89 10                	mov    %edx,(%eax)
                        page_free_list = &pages[i];
f0100f04:	89 f0                	mov    %esi,%eax
f0100f06:	03 05 a8 fe 25 f0    	add    0xf025fea8,%eax
f0100f0c:	a3 40 f2 25 f0       	mov    %eax,0xf025f240
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	
	 for (i = 0; i < npages; i++) {
f0100f11:	83 c3 01             	add    $0x1,%ebx
f0100f14:	83 c6 08             	add    $0x8,%esi
f0100f17:	3b 1d a0 fe 25 f0    	cmp    0xf025fea0,%ebx
f0100f1d:	0f 82 59 ff ff ff    	jb     f0100e7c <page_init+0x14>
                        pages[i].pp_ref = 0;
                        pages[i].pp_link = page_free_list;
                        page_free_list = &pages[i];
                }
        }
} 
f0100f23:	5b                   	pop    %ebx
f0100f24:	5e                   	pop    %esi
f0100f25:	5d                   	pop    %ebp
f0100f26:	c3                   	ret    

f0100f27 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f27:	55                   	push   %ebp
f0100f28:	89 e5                	mov    %esp,%ebp
f0100f2a:	53                   	push   %ebx
f0100f2b:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct PageInfo* allocated_page=NULL;
        
        if(page_free_list != NULL) {
f0100f2e:	8b 1d 40 f2 25 f0    	mov    0xf025f240,%ebx
f0100f34:	85 db                	test   %ebx,%ebx
f0100f36:	74 58                	je     f0100f90 <page_alloc+0x69>
                allocated_page = page_free_list;
                page_free_list = allocated_page->pp_link;
f0100f38:	8b 03                	mov    (%ebx),%eax
f0100f3a:	a3 40 f2 25 f0       	mov    %eax,0xf025f240
                allocated_page->pp_link = NULL;
f0100f3f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
                
                if(alloc_flags & ALLOC_ZERO) {
f0100f45:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f49:	74 45                	je     f0100f90 <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f4b:	89 d8                	mov    %ebx,%eax
f0100f4d:	2b 05 a8 fe 25 f0    	sub    0xf025fea8,%eax
f0100f53:	c1 f8 03             	sar    $0x3,%eax
f0100f56:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f59:	89 c2                	mov    %eax,%edx
f0100f5b:	c1 ea 0c             	shr    $0xc,%edx
f0100f5e:	3b 15 a0 fe 25 f0    	cmp    0xf025fea0,%edx
f0100f64:	72 12                	jb     f0100f78 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f66:	50                   	push   %eax
f0100f67:	68 64 67 10 f0       	push   $0xf0106764
f0100f6c:	6a 58                	push   $0x58
f0100f6e:	68 a9 76 10 f0       	push   $0xf01076a9
f0100f73:	e8 c8 f0 ff ff       	call   f0100040 <_panic>
                        memset(page2kva(allocated_page), 0,PGSIZE);
f0100f78:	83 ec 04             	sub    $0x4,%esp
f0100f7b:	68 00 10 00 00       	push   $0x1000
f0100f80:	6a 00                	push   $0x0
f0100f82:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f87:	50                   	push   %eax
f0100f88:	e8 9d 45 00 00       	call   f010552a <memset>
f0100f8d:	83 c4 10             	add    $0x10,%esp
                }
        }
        return allocated_page;
        
}
f0100f90:	89 d8                	mov    %ebx,%eax
f0100f92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f95:	c9                   	leave  
f0100f96:	c3                   	ret    

f0100f97 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f97:	55                   	push   %ebp
f0100f98:	89 e5                	mov    %esp,%ebp
f0100f9a:	83 ec 08             	sub    $0x8,%esp
f0100f9d:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if((pp->pp_link != NULL) || (pp->pp_ref !=0)) {
f0100fa0:	83 38 00             	cmpl   $0x0,(%eax)
f0100fa3:	75 07                	jne    f0100fac <page_free+0x15>
f0100fa5:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100faa:	74 17                	je     f0100fc3 <page_free+0x2c>
                panic("ref count is not zero or pp_link is not NULL");
f0100fac:	83 ec 04             	sub    $0x4,%esp
f0100faf:	68 ec 6d 10 f0       	push   $0xf0106dec
f0100fb4:	68 99 01 00 00       	push   $0x199
f0100fb9:	68 9d 76 10 f0       	push   $0xf010769d
f0100fbe:	e8 7d f0 ff ff       	call   f0100040 <_panic>
        }
        
        else{


                pp->pp_link = page_free_list;
f0100fc3:	8b 15 40 f2 25 f0    	mov    0xf025f240,%edx
f0100fc9:	89 10                	mov    %edx,(%eax)
                page_free_list = pp;
f0100fcb:	a3 40 f2 25 f0       	mov    %eax,0xf025f240
        }
	
				
}
f0100fd0:	c9                   	leave  
f0100fd1:	c3                   	ret    

f0100fd2 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100fd2:	55                   	push   %ebp
f0100fd3:	89 e5                	mov    %esp,%ebp
f0100fd5:	83 ec 08             	sub    $0x8,%esp
f0100fd8:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fdb:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fdf:	83 e8 01             	sub    $0x1,%eax
f0100fe2:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100fe6:	66 85 c0             	test   %ax,%ax
f0100fe9:	75 0c                	jne    f0100ff7 <page_decref+0x25>
		page_free(pp);
f0100feb:	83 ec 0c             	sub    $0xc,%esp
f0100fee:	52                   	push   %edx
f0100fef:	e8 a3 ff ff ff       	call   f0100f97 <page_free>
f0100ff4:	83 c4 10             	add    $0x10,%esp
}
f0100ff7:	c9                   	leave  
f0100ff8:	c3                   	ret    

f0100ff9 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100ff9:	55                   	push   %ebp
f0100ffa:	89 e5                	mov    %esp,%ebp
f0100ffc:	56                   	push   %esi
f0100ffd:	53                   	push   %ebx
f0100ffe:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo* new_pg_table;
	pde_t *pdep;
	pte_t *ptep;
	// Fill this function in
	if((pgdir[PDX(va)] & PTE_P) != PTE_P) {
f0101001:	89 f3                	mov    %esi,%ebx
f0101003:	c1 eb 16             	shr    $0x16,%ebx
f0101006:	c1 e3 02             	shl    $0x2,%ebx
f0101009:	03 5d 08             	add    0x8(%ebp),%ebx
f010100c:	f6 03 01             	testb  $0x1,(%ebx)
f010100f:	75 2d                	jne    f010103e <pgdir_walk+0x45>
		if(create == false) {
f0101011:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101015:	74 62                	je     f0101079 <pgdir_walk+0x80>
			return NULL;
		}else{
			new_pg_table = page_alloc(ALLOC_ZERO);
f0101017:	83 ec 0c             	sub    $0xc,%esp
f010101a:	6a 01                	push   $0x1
f010101c:	e8 06 ff ff ff       	call   f0100f27 <page_alloc>
			if(new_pg_table == NULL) {
f0101021:	83 c4 10             	add    $0x10,%esp
f0101024:	85 c0                	test   %eax,%eax
f0101026:	74 58                	je     f0101080 <pgdir_walk+0x87>
				return NULL;
			}else{
				new_pg_table->pp_ref += 1;
f0101028:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
				pgdir[PDX(va)] = (page2pa(new_pg_table) | PTE_P);
f010102d:	2b 05 a8 fe 25 f0    	sub    0xf025fea8,%eax
f0101033:	c1 f8 03             	sar    $0x3,%eax
f0101036:	c1 e0 0c             	shl    $0xc,%eax
f0101039:	83 c8 01             	or     $0x1,%eax
f010103c:	89 03                	mov    %eax,(%ebx)
			}
		}
	}
	pdep = (pde_t *)&pgdir[PDX(va)];
	ptep = (pte_t *)KADDR(PTE_ADDR(*pdep));
f010103e:	8b 03                	mov    (%ebx),%eax
f0101040:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101045:	89 c2                	mov    %eax,%edx
f0101047:	c1 ea 0c             	shr    $0xc,%edx
f010104a:	3b 15 a0 fe 25 f0    	cmp    0xf025fea0,%edx
f0101050:	72 15                	jb     f0101067 <pgdir_walk+0x6e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101052:	50                   	push   %eax
f0101053:	68 64 67 10 f0       	push   $0xf0106764
f0101058:	68 dc 01 00 00       	push   $0x1dc
f010105d:	68 9d 76 10 f0       	push   $0xf010769d
f0101062:	e8 d9 ef ff ff       	call   f0100040 <_panic>
	return &ptep[PTX(va)];
f0101067:	c1 ee 0a             	shr    $0xa,%esi
f010106a:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101070:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101077:	eb 0c                	jmp    f0101085 <pgdir_walk+0x8c>
	pde_t *pdep;
	pte_t *ptep;
	// Fill this function in
	if((pgdir[PDX(va)] & PTE_P) != PTE_P) {
		if(create == false) {
			return NULL;
f0101079:	b8 00 00 00 00       	mov    $0x0,%eax
f010107e:	eb 05                	jmp    f0101085 <pgdir_walk+0x8c>
		}else{
			new_pg_table = page_alloc(ALLOC_ZERO);
			if(new_pg_table == NULL) {
				return NULL;
f0101080:	b8 00 00 00 00       	mov    $0x0,%eax
		}
	}
	pdep = (pde_t *)&pgdir[PDX(va)];
	ptep = (pte_t *)KADDR(PTE_ADDR(*pdep));
	return &ptep[PTX(va)];
}
f0101085:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101088:	5b                   	pop    %ebx
f0101089:	5e                   	pop    %esi
f010108a:	5d                   	pop    %ebp
f010108b:	c3                   	ret    

f010108c <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010108c:	55                   	push   %ebp
f010108d:	89 e5                	mov    %esp,%ebp
f010108f:	57                   	push   %edi
f0101090:	56                   	push   %esi
f0101091:	53                   	push   %ebx
f0101092:	83 ec 1c             	sub    $0x1c,%esp
f0101095:	89 c3                	mov    %eax,%ebx
f0101097:	89 c8                	mov    %ecx,%eax
f0101099:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	// Fill this function in
	pte_t *ptep;
	if(va+size < va)
f010109c:	01 d0                	add    %edx,%eax
f010109e:	73 4d                	jae    f01010ed <boot_map_region+0x61>
		panic("boot_map_region: Kernel panicked ");
f01010a0:	83 ec 04             	sub    $0x4,%esp
f01010a3:	68 1c 6e 10 f0       	push   $0xf0106e1c
f01010a8:	68 f1 01 00 00       	push   $0x1f1
f01010ad:	68 9d 76 10 f0       	push   $0xf010769d
f01010b2:	e8 89 ef ff ff       	call   f0100040 <_panic>
	for(int i=0; i<size; i+=PGSIZE) {
		ptep = pgdir_walk(pgdir,(void*)(va+i),1);
f01010b7:	83 ec 04             	sub    $0x4,%esp
f01010ba:	6a 01                	push   $0x1
f01010bc:	56                   	push   %esi
f01010bd:	53                   	push   %ebx
f01010be:	e8 36 ff ff ff       	call   f0100ff9 <pgdir_walk>
		if(ptep != NULL){
f01010c3:	83 c4 10             	add    $0x10,%esp
f01010c6:	85 c0                	test   %eax,%eax
f01010c8:	74 15                	je     f01010df <boot_map_region+0x53>
			*ptep = ((pa+i) | perm | PTE_P);
f01010ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01010cd:	03 55 08             	add    0x8(%ebp),%edx
f01010d0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01010d3:	09 ca                	or     %ecx,%edx
f01010d5:	89 10                	mov    %edx,(%eax)
			pgdir[PDX(va+i)] |= perm | PTE_P;
f01010d7:	89 f0                	mov    %esi,%eax
f01010d9:	c1 e8 16             	shr    $0x16,%eax
f01010dc:	09 0c 83             	or     %ecx,(%ebx,%eax,4)
{
	// Fill this function in
	pte_t *ptep;
	if(va+size < va)
		panic("boot_map_region: Kernel panicked ");
	for(int i=0; i<size; i+=PGSIZE) {
f01010df:	81 c7 00 10 00 00    	add    $0x1000,%edi
f01010e5:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01010eb:	eb 10                	jmp    f01010fd <boot_map_region+0x71>
f01010ed:	89 d6                	mov    %edx,%esi
f01010ef:	bf 00 00 00 00       	mov    $0x0,%edi
f01010f4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010f7:	83 c8 01             	or     $0x1,%eax
f01010fa:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01010fd:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0101100:	39 7d e0             	cmp    %edi,-0x20(%ebp)
f0101103:	77 b2                	ja     f01010b7 <boot_map_region+0x2b>
		if(ptep != NULL){
			*ptep = ((pa+i) | perm | PTE_P);
			pgdir[PDX(va+i)] |= perm | PTE_P;
		}
	}
}
f0101105:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101108:	5b                   	pop    %ebx
f0101109:	5e                   	pop    %esi
f010110a:	5f                   	pop    %edi
f010110b:	5d                   	pop    %ebp
f010110c:	c3                   	ret    

f010110d <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010110d:	55                   	push   %ebp
f010110e:	89 e5                	mov    %esp,%ebp
f0101110:	53                   	push   %ebx
f0101111:	83 ec 08             	sub    $0x8,%esp
f0101114:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *ptep;
	struct PageInfo *pp=NULL;
	ptep = pgdir_walk(pgdir,va,0);
f0101117:	6a 00                	push   $0x0
f0101119:	ff 75 0c             	pushl  0xc(%ebp)
f010111c:	ff 75 08             	pushl  0x8(%ebp)
f010111f:	e8 d5 fe ff ff       	call   f0100ff9 <pgdir_walk>
	if(ptep == NULL) {
f0101124:	83 c4 10             	add    $0x10,%esp
f0101127:	85 c0                	test   %eax,%eax
f0101129:	74 39                	je     f0101164 <page_lookup+0x57>
f010112b:	89 c1                	mov    %eax,%ecx
		return NULL;
	}else if((*ptep & PTE_P) != PTE_P) {
f010112d:	8b 10                	mov    (%eax),%edx
f010112f:	f6 c2 01             	test   $0x1,%dl
f0101132:	74 37                	je     f010116b <page_lookup+0x5e>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101134:	c1 ea 0c             	shr    $0xc,%edx
f0101137:	3b 15 a0 fe 25 f0    	cmp    0xf025fea0,%edx
f010113d:	72 14                	jb     f0101153 <page_lookup+0x46>
		panic("pa2page called with invalid pa");
f010113f:	83 ec 04             	sub    $0x4,%esp
f0101142:	68 40 6e 10 f0       	push   $0xf0106e40
f0101147:	6a 51                	push   $0x51
f0101149:	68 a9 76 10 f0       	push   $0xf01076a9
f010114e:	e8 ed ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101153:	a1 a8 fe 25 f0       	mov    0xf025fea8,%eax
f0101158:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		return NULL;
	}else{
		pp = pa2page(PTE_ADDR(*ptep));
		if(*pte_store != 0) {
f010115b:	83 3b 00             	cmpl   $0x0,(%ebx)
f010115e:	74 10                	je     f0101170 <page_lookup+0x63>
			*pte_store = ptep; 
f0101160:	89 0b                	mov    %ecx,(%ebx)
f0101162:	eb 0c                	jmp    f0101170 <page_lookup+0x63>
	// Fill this function in
	pte_t *ptep;
	struct PageInfo *pp=NULL;
	ptep = pgdir_walk(pgdir,va,0);
	if(ptep == NULL) {
		return NULL;
f0101164:	b8 00 00 00 00       	mov    $0x0,%eax
f0101169:	eb 05                	jmp    f0101170 <page_lookup+0x63>
	}else if((*ptep & PTE_P) != PTE_P) {
		return NULL;
f010116b:	b8 00 00 00 00       	mov    $0x0,%eax
		if(*pte_store != 0) {
			*pte_store = ptep; 
		}
	}
	return pp;
}
f0101170:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101173:	c9                   	leave  
f0101174:	c3                   	ret    

f0101175 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101175:	55                   	push   %ebp
f0101176:	89 e5                	mov    %esp,%ebp
f0101178:	53                   	push   %ebx
f0101179:	83 ec 18             	sub    $0x18,%esp
f010117c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	//pte_t **ptep_store;
	pte_t *ptep;
	struct PageInfo *pp=NULL;
	pp = page_lookup(pgdir, va, &ptep);
f010117f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101182:	50                   	push   %eax
f0101183:	53                   	push   %ebx
f0101184:	ff 75 08             	pushl  0x8(%ebp)
f0101187:	e8 81 ff ff ff       	call   f010110d <page_lookup>
	if(pp != NULL) {
f010118c:	83 c4 10             	add    $0x10,%esp
f010118f:	85 c0                	test   %eax,%eax
f0101191:	74 18                	je     f01011ab <page_remove+0x36>
		page_decref(pp);
f0101193:	83 ec 0c             	sub    $0xc,%esp
f0101196:	50                   	push   %eax
f0101197:	e8 36 fe ff ff       	call   f0100fd2 <page_decref>
		*ptep = 0x0;
f010119c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010119f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011a5:	0f 01 3b             	invlpg (%ebx)
f01011a8:	83 c4 10             	add    $0x10,%esp
		tlb_invalidate(pgdir,va);	
	}
}
f01011ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011ae:	c9                   	leave  
f01011af:	c3                   	ret    

f01011b0 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01011b0:	55                   	push   %ebp
f01011b1:	89 e5                	mov    %esp,%ebp
f01011b3:	57                   	push   %edi
f01011b4:	56                   	push   %esi
f01011b5:	53                   	push   %ebx
f01011b6:	83 ec 10             	sub    $0x10,%esp
f01011b9:	8b 75 08             	mov    0x8(%ebp),%esi
f01011bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *ptep;

	ptep = pgdir_walk(pgdir, va, 1);
f01011bf:	6a 01                	push   $0x1
f01011c1:	ff 75 10             	pushl  0x10(%ebp)
f01011c4:	56                   	push   %esi
f01011c5:	e8 2f fe ff ff       	call   f0100ff9 <pgdir_walk>
	if(ptep == NULL) {
f01011ca:	83 c4 10             	add    $0x10,%esp
f01011cd:	85 c0                	test   %eax,%eax
f01011cf:	74 44                	je     f0101215 <page_insert+0x65>
f01011d1:	89 c7                	mov    %eax,%edi
		
		return (-E_NO_MEM);
	}
	pp->pp_ref++;
f01011d3:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if((*ptep & PTE_P) == PTE_P) {
f01011d8:	f6 00 01             	testb  $0x1,(%eax)
f01011db:	74 0f                	je     f01011ec <page_insert+0x3c>
		page_remove(pgdir,va);
f01011dd:	83 ec 08             	sub    $0x8,%esp
f01011e0:	ff 75 10             	pushl  0x10(%ebp)
f01011e3:	56                   	push   %esi
f01011e4:	e8 8c ff ff ff       	call   f0101175 <page_remove>
f01011e9:	83 c4 10             	add    $0x10,%esp
	}
	*ptep = (page2pa(pp) | perm | PTE_P);
f01011ec:	2b 1d a8 fe 25 f0    	sub    0xf025fea8,%ebx
f01011f2:	c1 fb 03             	sar    $0x3,%ebx
f01011f5:	c1 e3 0c             	shl    $0xc,%ebx
f01011f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01011fb:	83 c8 01             	or     $0x1,%eax
f01011fe:	09 c3                	or     %eax,%ebx
f0101200:	89 1f                	mov    %ebx,(%edi)
	pgdir[PDX(va)] |= perm;
f0101202:	8b 45 10             	mov    0x10(%ebp),%eax
f0101205:	c1 e8 16             	shr    $0x16,%eax
f0101208:	8b 55 14             	mov    0x14(%ebp),%edx
f010120b:	09 14 86             	or     %edx,(%esi,%eax,4)
	return 0;
f010120e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101213:	eb 05                	jmp    f010121a <page_insert+0x6a>
	pte_t *ptep;

	ptep = pgdir_walk(pgdir, va, 1);
	if(ptep == NULL) {
		
		return (-E_NO_MEM);
f0101215:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir,va);
	}
	*ptep = (page2pa(pp) | perm | PTE_P);
	pgdir[PDX(va)] |= perm;
	return 0;
}
f010121a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010121d:	5b                   	pop    %ebx
f010121e:	5e                   	pop    %esi
f010121f:	5f                   	pop    %edi
f0101220:	5d                   	pop    %ebp
f0101221:	c3                   	ret    

f0101222 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101222:	55                   	push   %ebp
f0101223:	89 e5                	mov    %esp,%ebp
f0101225:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101228:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010122b:	5d                   	pop    %ebp
f010122c:	c3                   	ret    

f010122d <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f010122d:	55                   	push   %ebp
f010122e:	89 e5                	mov    %esp,%ebp
f0101230:	53                   	push   %ebx
f0101231:	83 ec 04             	sub    $0x4,%esp
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
		
	size = ROUNDUP(size,PGSIZE);
f0101234:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101237:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f010123d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(base+size > MMIOLIM)
f0101243:	8b 15 00 23 12 f0    	mov    0xf0122300,%edx
f0101249:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f010124c:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101251:	76 17                	jbe    f010126a <mmio_map_region+0x3d>
	{
		panic("Requested memory cannot be mapped");
f0101253:	83 ec 04             	sub    $0x4,%esp
f0101256:	68 60 6e 10 f0       	push   $0xf0106e60
f010125b:	68 93 02 00 00       	push   $0x293
f0101260:	68 9d 76 10 f0       	push   $0xf010769d
f0101265:	e8 d6 ed ff ff       	call   f0100040 <_panic>
	}
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD | PTE_PWT | PTE_W);
f010126a:	83 ec 08             	sub    $0x8,%esp
f010126d:	6a 1a                	push   $0x1a
f010126f:	ff 75 08             	pushl  0x8(%ebp)
f0101272:	89 d9                	mov    %ebx,%ecx
f0101274:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
f0101279:	e8 0e fe ff ff       	call   f010108c <boot_map_region>
	uintptr_t mapped_base = base;
f010127e:	a1 00 23 12 f0       	mov    0xf0122300,%eax
	base += size;
f0101283:	01 c3                	add    %eax,%ebx
f0101285:	89 1d 00 23 12 f0    	mov    %ebx,0xf0122300
	return((void *)mapped_base);
}
f010128b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010128e:	c9                   	leave  
f010128f:	c3                   	ret    

f0101290 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101290:	55                   	push   %ebp
f0101291:	89 e5                	mov    %esp,%ebp
f0101293:	57                   	push   %edi
f0101294:	56                   	push   %esi
f0101295:	53                   	push   %ebx
f0101296:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101299:	6a 15                	push   $0x15
f010129b:	e8 af 22 00 00       	call   f010354f <mc146818_read>
f01012a0:	89 c3                	mov    %eax,%ebx
f01012a2:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01012a9:	e8 a1 22 00 00       	call   f010354f <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01012ae:	c1 e0 08             	shl    $0x8,%eax
f01012b1:	09 d8                	or     %ebx,%eax
f01012b3:	c1 e0 0a             	shl    $0xa,%eax
f01012b6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012bc:	85 c0                	test   %eax,%eax
f01012be:	0f 48 c2             	cmovs  %edx,%eax
f01012c1:	c1 f8 0c             	sar    $0xc,%eax
f01012c4:	a3 44 f2 25 f0       	mov    %eax,0xf025f244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01012c9:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01012d0:	e8 7a 22 00 00       	call   f010354f <mc146818_read>
f01012d5:	89 c3                	mov    %eax,%ebx
f01012d7:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01012de:	e8 6c 22 00 00       	call   f010354f <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01012e3:	c1 e0 08             	shl    $0x8,%eax
f01012e6:	09 d8                	or     %ebx,%eax
f01012e8:	c1 e0 0a             	shl    $0xa,%eax
f01012eb:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012f1:	83 c4 10             	add    $0x10,%esp
f01012f4:	85 c0                	test   %eax,%eax
f01012f6:	0f 48 c2             	cmovs  %edx,%eax
f01012f9:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01012fc:	85 c0                	test   %eax,%eax
f01012fe:	74 0e                	je     f010130e <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101300:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101306:	89 15 a0 fe 25 f0    	mov    %edx,0xf025fea0
f010130c:	eb 0c                	jmp    f010131a <mem_init+0x8a>
	else
		npages = npages_basemem;
f010130e:	8b 15 44 f2 25 f0    	mov    0xf025f244,%edx
f0101314:	89 15 a0 fe 25 f0    	mov    %edx,0xf025fea0
	//cprintf("Amount of physical memory (in pages) %u\n",npages);
	//cprintf("Page Size is %u\n", PGSIZE);
	//cprintf("Amount of base memory (in pages) is %u\n\n", npages_basemem);
	
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010131a:	c1 e0 0c             	shl    $0xc,%eax
f010131d:	c1 e8 0a             	shr    $0xa,%eax
f0101320:	50                   	push   %eax
f0101321:	a1 44 f2 25 f0       	mov    0xf025f244,%eax
f0101326:	c1 e0 0c             	shl    $0xc,%eax
f0101329:	c1 e8 0a             	shr    $0xa,%eax
f010132c:	50                   	push   %eax
f010132d:	a1 a0 fe 25 f0       	mov    0xf025fea0,%eax
f0101332:	c1 e0 0c             	shl    $0xc,%eax
f0101335:	c1 e8 0a             	shr    $0xa,%eax
f0101338:	50                   	push   %eax
f0101339:	68 84 6e 10 f0       	push   $0xf0106e84
f010133e:	e8 a1 23 00 00       	call   f01036e4 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101343:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101348:	e8 61 f7 ff ff       	call   f0100aae <boot_alloc>
f010134d:	a3 a4 fe 25 f0       	mov    %eax,0xf025fea4
	memset(kern_pgdir, 0, PGSIZE);
f0101352:	83 c4 0c             	add    $0xc,%esp
f0101355:	68 00 10 00 00       	push   $0x1000
f010135a:	6a 00                	push   $0x0
f010135c:	50                   	push   %eax
f010135d:	e8 c8 41 00 00       	call   f010552a <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101362:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101367:	83 c4 10             	add    $0x10,%esp
f010136a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010136f:	77 15                	ja     f0101386 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101371:	50                   	push   %eax
f0101372:	68 88 67 10 f0       	push   $0xf0106788
f0101377:	68 a8 00 00 00       	push   $0xa8
f010137c:	68 9d 76 10 f0       	push   $0xf010769d
f0101381:	e8 ba ec ff ff       	call   f0100040 <_panic>
f0101386:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010138c:	83 ca 05             	or     $0x5,%edx
f010138f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	
	pages = boot_alloc (npages * sizeof (struct PageInfo));
f0101395:	a1 a0 fe 25 f0       	mov    0xf025fea0,%eax
f010139a:	c1 e0 03             	shl    $0x3,%eax
f010139d:	e8 0c f7 ff ff       	call   f0100aae <boot_alloc>
f01013a2:	a3 a8 fe 25 f0       	mov    %eax,0xf025fea8
	
	memset(pages, 0 , npages * sizeof (struct PageInfo));
f01013a7:	83 ec 04             	sub    $0x4,%esp
f01013aa:	8b 0d a0 fe 25 f0    	mov    0xf025fea0,%ecx
f01013b0:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013b7:	52                   	push   %edx
f01013b8:	6a 00                	push   $0x0
f01013ba:	50                   	push   %eax
f01013bb:	e8 6a 41 00 00       	call   f010552a <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	
	envs = (struct Env *) boot_alloc(NENV*sizeof(struct Env));
f01013c0:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013c5:	e8 e4 f6 ff ff       	call   f0100aae <boot_alloc>
f01013ca:	a3 48 f2 25 f0       	mov    %eax,0xf025f248
	
	memset(envs, 0, NENV*sizeof(struct Env));
f01013cf:	83 c4 0c             	add    $0xc,%esp
f01013d2:	68 00 f0 01 00       	push   $0x1f000
f01013d7:	6a 00                	push   $0x0
f01013d9:	50                   	push   %eax
f01013da:	e8 4b 41 00 00       	call   f010552a <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01013df:	e8 84 fa ff ff       	call   f0100e68 <page_init>

	check_page_free_list(1);
f01013e4:	b8 01 00 00 00       	mov    $0x1,%eax
f01013e9:	e8 8b f7 ff ff       	call   f0100b79 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01013ee:	83 c4 10             	add    $0x10,%esp
f01013f1:	83 3d a8 fe 25 f0 00 	cmpl   $0x0,0xf025fea8
f01013f8:	75 17                	jne    f0101411 <mem_init+0x181>
		panic("'pages' is a null pointer!");
f01013fa:	83 ec 04             	sub    $0x4,%esp
f01013fd:	68 70 77 10 f0       	push   $0xf0107770
f0101402:	68 34 03 00 00       	push   $0x334
f0101407:	68 9d 76 10 f0       	push   $0xf010769d
f010140c:	e8 2f ec ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101411:	a1 40 f2 25 f0       	mov    0xf025f240,%eax
f0101416:	bb 00 00 00 00       	mov    $0x0,%ebx
f010141b:	eb 05                	jmp    f0101422 <mem_init+0x192>
		++nfree;
f010141d:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101420:	8b 00                	mov    (%eax),%eax
f0101422:	85 c0                	test   %eax,%eax
f0101424:	75 f7                	jne    f010141d <mem_init+0x18d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101426:	83 ec 0c             	sub    $0xc,%esp
f0101429:	6a 00                	push   $0x0
f010142b:	e8 f7 fa ff ff       	call   f0100f27 <page_alloc>
f0101430:	89 c7                	mov    %eax,%edi
f0101432:	83 c4 10             	add    $0x10,%esp
f0101435:	85 c0                	test   %eax,%eax
f0101437:	75 19                	jne    f0101452 <mem_init+0x1c2>
f0101439:	68 8b 77 10 f0       	push   $0xf010778b
f010143e:	68 c3 76 10 f0       	push   $0xf01076c3
f0101443:	68 3c 03 00 00       	push   $0x33c
f0101448:	68 9d 76 10 f0       	push   $0xf010769d
f010144d:	e8 ee eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101452:	83 ec 0c             	sub    $0xc,%esp
f0101455:	6a 00                	push   $0x0
f0101457:	e8 cb fa ff ff       	call   f0100f27 <page_alloc>
f010145c:	89 c6                	mov    %eax,%esi
f010145e:	83 c4 10             	add    $0x10,%esp
f0101461:	85 c0                	test   %eax,%eax
f0101463:	75 19                	jne    f010147e <mem_init+0x1ee>
f0101465:	68 a1 77 10 f0       	push   $0xf01077a1
f010146a:	68 c3 76 10 f0       	push   $0xf01076c3
f010146f:	68 3d 03 00 00       	push   $0x33d
f0101474:	68 9d 76 10 f0       	push   $0xf010769d
f0101479:	e8 c2 eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010147e:	83 ec 0c             	sub    $0xc,%esp
f0101481:	6a 00                	push   $0x0
f0101483:	e8 9f fa ff ff       	call   f0100f27 <page_alloc>
f0101488:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010148b:	83 c4 10             	add    $0x10,%esp
f010148e:	85 c0                	test   %eax,%eax
f0101490:	75 19                	jne    f01014ab <mem_init+0x21b>
f0101492:	68 b7 77 10 f0       	push   $0xf01077b7
f0101497:	68 c3 76 10 f0       	push   $0xf01076c3
f010149c:	68 3e 03 00 00       	push   $0x33e
f01014a1:	68 9d 76 10 f0       	push   $0xf010769d
f01014a6:	e8 95 eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014ab:	39 f7                	cmp    %esi,%edi
f01014ad:	75 19                	jne    f01014c8 <mem_init+0x238>
f01014af:	68 cd 77 10 f0       	push   $0xf01077cd
f01014b4:	68 c3 76 10 f0       	push   $0xf01076c3
f01014b9:	68 41 03 00 00       	push   $0x341
f01014be:	68 9d 76 10 f0       	push   $0xf010769d
f01014c3:	e8 78 eb ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014cb:	39 c6                	cmp    %eax,%esi
f01014cd:	74 04                	je     f01014d3 <mem_init+0x243>
f01014cf:	39 c7                	cmp    %eax,%edi
f01014d1:	75 19                	jne    f01014ec <mem_init+0x25c>
f01014d3:	68 c0 6e 10 f0       	push   $0xf0106ec0
f01014d8:	68 c3 76 10 f0       	push   $0xf01076c3
f01014dd:	68 42 03 00 00       	push   $0x342
f01014e2:	68 9d 76 10 f0       	push   $0xf010769d
f01014e7:	e8 54 eb ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014ec:	8b 0d a8 fe 25 f0    	mov    0xf025fea8,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014f2:	8b 15 a0 fe 25 f0    	mov    0xf025fea0,%edx
f01014f8:	c1 e2 0c             	shl    $0xc,%edx
f01014fb:	89 f8                	mov    %edi,%eax
f01014fd:	29 c8                	sub    %ecx,%eax
f01014ff:	c1 f8 03             	sar    $0x3,%eax
f0101502:	c1 e0 0c             	shl    $0xc,%eax
f0101505:	39 d0                	cmp    %edx,%eax
f0101507:	72 19                	jb     f0101522 <mem_init+0x292>
f0101509:	68 df 77 10 f0       	push   $0xf01077df
f010150e:	68 c3 76 10 f0       	push   $0xf01076c3
f0101513:	68 43 03 00 00       	push   $0x343
f0101518:	68 9d 76 10 f0       	push   $0xf010769d
f010151d:	e8 1e eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101522:	89 f0                	mov    %esi,%eax
f0101524:	29 c8                	sub    %ecx,%eax
f0101526:	c1 f8 03             	sar    $0x3,%eax
f0101529:	c1 e0 0c             	shl    $0xc,%eax
f010152c:	39 c2                	cmp    %eax,%edx
f010152e:	77 19                	ja     f0101549 <mem_init+0x2b9>
f0101530:	68 fc 77 10 f0       	push   $0xf01077fc
f0101535:	68 c3 76 10 f0       	push   $0xf01076c3
f010153a:	68 44 03 00 00       	push   $0x344
f010153f:	68 9d 76 10 f0       	push   $0xf010769d
f0101544:	e8 f7 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101549:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010154c:	29 c8                	sub    %ecx,%eax
f010154e:	c1 f8 03             	sar    $0x3,%eax
f0101551:	c1 e0 0c             	shl    $0xc,%eax
f0101554:	39 c2                	cmp    %eax,%edx
f0101556:	77 19                	ja     f0101571 <mem_init+0x2e1>
f0101558:	68 19 78 10 f0       	push   $0xf0107819
f010155d:	68 c3 76 10 f0       	push   $0xf01076c3
f0101562:	68 45 03 00 00       	push   $0x345
f0101567:	68 9d 76 10 f0       	push   $0xf010769d
f010156c:	e8 cf ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101571:	a1 40 f2 25 f0       	mov    0xf025f240,%eax
f0101576:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101579:	c7 05 40 f2 25 f0 00 	movl   $0x0,0xf025f240
f0101580:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101583:	83 ec 0c             	sub    $0xc,%esp
f0101586:	6a 00                	push   $0x0
f0101588:	e8 9a f9 ff ff       	call   f0100f27 <page_alloc>
f010158d:	83 c4 10             	add    $0x10,%esp
f0101590:	85 c0                	test   %eax,%eax
f0101592:	74 19                	je     f01015ad <mem_init+0x31d>
f0101594:	68 36 78 10 f0       	push   $0xf0107836
f0101599:	68 c3 76 10 f0       	push   $0xf01076c3
f010159e:	68 4c 03 00 00       	push   $0x34c
f01015a3:	68 9d 76 10 f0       	push   $0xf010769d
f01015a8:	e8 93 ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01015ad:	83 ec 0c             	sub    $0xc,%esp
f01015b0:	57                   	push   %edi
f01015b1:	e8 e1 f9 ff ff       	call   f0100f97 <page_free>
	page_free(pp1);
f01015b6:	89 34 24             	mov    %esi,(%esp)
f01015b9:	e8 d9 f9 ff ff       	call   f0100f97 <page_free>
	page_free(pp2);
f01015be:	83 c4 04             	add    $0x4,%esp
f01015c1:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015c4:	e8 ce f9 ff ff       	call   f0100f97 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015d0:	e8 52 f9 ff ff       	call   f0100f27 <page_alloc>
f01015d5:	89 c6                	mov    %eax,%esi
f01015d7:	83 c4 10             	add    $0x10,%esp
f01015da:	85 c0                	test   %eax,%eax
f01015dc:	75 19                	jne    f01015f7 <mem_init+0x367>
f01015de:	68 8b 77 10 f0       	push   $0xf010778b
f01015e3:	68 c3 76 10 f0       	push   $0xf01076c3
f01015e8:	68 53 03 00 00       	push   $0x353
f01015ed:	68 9d 76 10 f0       	push   $0xf010769d
f01015f2:	e8 49 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015f7:	83 ec 0c             	sub    $0xc,%esp
f01015fa:	6a 00                	push   $0x0
f01015fc:	e8 26 f9 ff ff       	call   f0100f27 <page_alloc>
f0101601:	89 c7                	mov    %eax,%edi
f0101603:	83 c4 10             	add    $0x10,%esp
f0101606:	85 c0                	test   %eax,%eax
f0101608:	75 19                	jne    f0101623 <mem_init+0x393>
f010160a:	68 a1 77 10 f0       	push   $0xf01077a1
f010160f:	68 c3 76 10 f0       	push   $0xf01076c3
f0101614:	68 54 03 00 00       	push   $0x354
f0101619:	68 9d 76 10 f0       	push   $0xf010769d
f010161e:	e8 1d ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101623:	83 ec 0c             	sub    $0xc,%esp
f0101626:	6a 00                	push   $0x0
f0101628:	e8 fa f8 ff ff       	call   f0100f27 <page_alloc>
f010162d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101630:	83 c4 10             	add    $0x10,%esp
f0101633:	85 c0                	test   %eax,%eax
f0101635:	75 19                	jne    f0101650 <mem_init+0x3c0>
f0101637:	68 b7 77 10 f0       	push   $0xf01077b7
f010163c:	68 c3 76 10 f0       	push   $0xf01076c3
f0101641:	68 55 03 00 00       	push   $0x355
f0101646:	68 9d 76 10 f0       	push   $0xf010769d
f010164b:	e8 f0 e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101650:	39 fe                	cmp    %edi,%esi
f0101652:	75 19                	jne    f010166d <mem_init+0x3dd>
f0101654:	68 cd 77 10 f0       	push   $0xf01077cd
f0101659:	68 c3 76 10 f0       	push   $0xf01076c3
f010165e:	68 57 03 00 00       	push   $0x357
f0101663:	68 9d 76 10 f0       	push   $0xf010769d
f0101668:	e8 d3 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010166d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101670:	39 c7                	cmp    %eax,%edi
f0101672:	74 04                	je     f0101678 <mem_init+0x3e8>
f0101674:	39 c6                	cmp    %eax,%esi
f0101676:	75 19                	jne    f0101691 <mem_init+0x401>
f0101678:	68 c0 6e 10 f0       	push   $0xf0106ec0
f010167d:	68 c3 76 10 f0       	push   $0xf01076c3
f0101682:	68 58 03 00 00       	push   $0x358
f0101687:	68 9d 76 10 f0       	push   $0xf010769d
f010168c:	e8 af e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101691:	83 ec 0c             	sub    $0xc,%esp
f0101694:	6a 00                	push   $0x0
f0101696:	e8 8c f8 ff ff       	call   f0100f27 <page_alloc>
f010169b:	83 c4 10             	add    $0x10,%esp
f010169e:	85 c0                	test   %eax,%eax
f01016a0:	74 19                	je     f01016bb <mem_init+0x42b>
f01016a2:	68 36 78 10 f0       	push   $0xf0107836
f01016a7:	68 c3 76 10 f0       	push   $0xf01076c3
f01016ac:	68 59 03 00 00       	push   $0x359
f01016b1:	68 9d 76 10 f0       	push   $0xf010769d
f01016b6:	e8 85 e9 ff ff       	call   f0100040 <_panic>
f01016bb:	89 f0                	mov    %esi,%eax
f01016bd:	2b 05 a8 fe 25 f0    	sub    0xf025fea8,%eax
f01016c3:	c1 f8 03             	sar    $0x3,%eax
f01016c6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016c9:	89 c2                	mov    %eax,%edx
f01016cb:	c1 ea 0c             	shr    $0xc,%edx
f01016ce:	3b 15 a0 fe 25 f0    	cmp    0xf025fea0,%edx
f01016d4:	72 12                	jb     f01016e8 <mem_init+0x458>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016d6:	50                   	push   %eax
f01016d7:	68 64 67 10 f0       	push   $0xf0106764
f01016dc:	6a 58                	push   $0x58
f01016de:	68 a9 76 10 f0       	push   $0xf01076a9
f01016e3:	e8 58 e9 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01016e8:	83 ec 04             	sub    $0x4,%esp
f01016eb:	68 00 10 00 00       	push   $0x1000
f01016f0:	6a 01                	push   $0x1
f01016f2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016f7:	50                   	push   %eax
f01016f8:	e8 2d 3e 00 00       	call   f010552a <memset>
	page_free(pp0);
f01016fd:	89 34 24             	mov    %esi,(%esp)
f0101700:	e8 92 f8 ff ff       	call   f0100f97 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101705:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010170c:	e8 16 f8 ff ff       	call   f0100f27 <page_alloc>
f0101711:	83 c4 10             	add    $0x10,%esp
f0101714:	85 c0                	test   %eax,%eax
f0101716:	75 19                	jne    f0101731 <mem_init+0x4a1>
f0101718:	68 45 78 10 f0       	push   $0xf0107845
f010171d:	68 c3 76 10 f0       	push   $0xf01076c3
f0101722:	68 5e 03 00 00       	push   $0x35e
f0101727:	68 9d 76 10 f0       	push   $0xf010769d
f010172c:	e8 0f e9 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101731:	39 c6                	cmp    %eax,%esi
f0101733:	74 19                	je     f010174e <mem_init+0x4be>
f0101735:	68 63 78 10 f0       	push   $0xf0107863
f010173a:	68 c3 76 10 f0       	push   $0xf01076c3
f010173f:	68 5f 03 00 00       	push   $0x35f
f0101744:	68 9d 76 10 f0       	push   $0xf010769d
f0101749:	e8 f2 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010174e:	89 f0                	mov    %esi,%eax
f0101750:	2b 05 a8 fe 25 f0    	sub    0xf025fea8,%eax
f0101756:	c1 f8 03             	sar    $0x3,%eax
f0101759:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010175c:	89 c2                	mov    %eax,%edx
f010175e:	c1 ea 0c             	shr    $0xc,%edx
f0101761:	3b 15 a0 fe 25 f0    	cmp    0xf025fea0,%edx
f0101767:	72 12                	jb     f010177b <mem_init+0x4eb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101769:	50                   	push   %eax
f010176a:	68 64 67 10 f0       	push   $0xf0106764
f010176f:	6a 58                	push   $0x58
f0101771:	68 a9 76 10 f0       	push   $0xf01076a9
f0101776:	e8 c5 e8 ff ff       	call   f0100040 <_panic>
f010177b:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101781:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101787:	80 38 00             	cmpb   $0x0,(%eax)
f010178a:	74 19                	je     f01017a5 <mem_init+0x515>
f010178c:	68 73 78 10 f0       	push   $0xf0107873
f0101791:	68 c3 76 10 f0       	push   $0xf01076c3
f0101796:	68 62 03 00 00       	push   $0x362
f010179b:	68 9d 76 10 f0       	push   $0xf010769d
f01017a0:	e8 9b e8 ff ff       	call   f0100040 <_panic>
f01017a5:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01017a8:	39 d0                	cmp    %edx,%eax
f01017aa:	75 db                	jne    f0101787 <mem_init+0x4f7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01017ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01017af:	a3 40 f2 25 f0       	mov    %eax,0xf025f240

	// free the pages we took
	page_free(pp0);
f01017b4:	83 ec 0c             	sub    $0xc,%esp
f01017b7:	56                   	push   %esi
f01017b8:	e8 da f7 ff ff       	call   f0100f97 <page_free>
	page_free(pp1);
f01017bd:	89 3c 24             	mov    %edi,(%esp)
f01017c0:	e8 d2 f7 ff ff       	call   f0100f97 <page_free>
	page_free(pp2);
f01017c5:	83 c4 04             	add    $0x4,%esp
f01017c8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017cb:	e8 c7 f7 ff ff       	call   f0100f97 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017d0:	a1 40 f2 25 f0       	mov    0xf025f240,%eax
f01017d5:	83 c4 10             	add    $0x10,%esp
f01017d8:	eb 05                	jmp    f01017df <mem_init+0x54f>
		--nfree;
f01017da:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017dd:	8b 00                	mov    (%eax),%eax
f01017df:	85 c0                	test   %eax,%eax
f01017e1:	75 f7                	jne    f01017da <mem_init+0x54a>
		--nfree;
	assert(nfree == 0);
f01017e3:	85 db                	test   %ebx,%ebx
f01017e5:	74 19                	je     f0101800 <mem_init+0x570>
f01017e7:	68 7d 78 10 f0       	push   $0xf010787d
f01017ec:	68 c3 76 10 f0       	push   $0xf01076c3
f01017f1:	68 6f 03 00 00       	push   $0x36f
f01017f6:	68 9d 76 10 f0       	push   $0xf010769d
f01017fb:	e8 40 e8 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101800:	83 ec 0c             	sub    $0xc,%esp
f0101803:	68 e0 6e 10 f0       	push   $0xf0106ee0
f0101808:	e8 d7 1e 00 00       	call   f01036e4 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010180d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101814:	e8 0e f7 ff ff       	call   f0100f27 <page_alloc>
f0101819:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010181c:	83 c4 10             	add    $0x10,%esp
f010181f:	85 c0                	test   %eax,%eax
f0101821:	75 19                	jne    f010183c <mem_init+0x5ac>
f0101823:	68 8b 77 10 f0       	push   $0xf010778b
f0101828:	68 c3 76 10 f0       	push   $0xf01076c3
f010182d:	68 d5 03 00 00       	push   $0x3d5
f0101832:	68 9d 76 10 f0       	push   $0xf010769d
f0101837:	e8 04 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010183c:	83 ec 0c             	sub    $0xc,%esp
f010183f:	6a 00                	push   $0x0
f0101841:	e8 e1 f6 ff ff       	call   f0100f27 <page_alloc>
f0101846:	89 c3                	mov    %eax,%ebx
f0101848:	83 c4 10             	add    $0x10,%esp
f010184b:	85 c0                	test   %eax,%eax
f010184d:	75 19                	jne    f0101868 <mem_init+0x5d8>
f010184f:	68 a1 77 10 f0       	push   $0xf01077a1
f0101854:	68 c3 76 10 f0       	push   $0xf01076c3
f0101859:	68 d6 03 00 00       	push   $0x3d6
f010185e:	68 9d 76 10 f0       	push   $0xf010769d
f0101863:	e8 d8 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101868:	83 ec 0c             	sub    $0xc,%esp
f010186b:	6a 00                	push   $0x0
f010186d:	e8 b5 f6 ff ff       	call   f0100f27 <page_alloc>
f0101872:	89 c6                	mov    %eax,%esi
f0101874:	83 c4 10             	add    $0x10,%esp
f0101877:	85 c0                	test   %eax,%eax
f0101879:	75 19                	jne    f0101894 <mem_init+0x604>
f010187b:	68 b7 77 10 f0       	push   $0xf01077b7
f0101880:	68 c3 76 10 f0       	push   $0xf01076c3
f0101885:	68 d7 03 00 00       	push   $0x3d7
f010188a:	68 9d 76 10 f0       	push   $0xf010769d
f010188f:	e8 ac e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101894:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101897:	75 19                	jne    f01018b2 <mem_init+0x622>
f0101899:	68 cd 77 10 f0       	push   $0xf01077cd
f010189e:	68 c3 76 10 f0       	push   $0xf01076c3
f01018a3:	68 da 03 00 00       	push   $0x3da
f01018a8:	68 9d 76 10 f0       	push   $0xf010769d
f01018ad:	e8 8e e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018b2:	39 c3                	cmp    %eax,%ebx
f01018b4:	74 05                	je     f01018bb <mem_init+0x62b>
f01018b6:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018b9:	75 19                	jne    f01018d4 <mem_init+0x644>
f01018bb:	68 c0 6e 10 f0       	push   $0xf0106ec0
f01018c0:	68 c3 76 10 f0       	push   $0xf01076c3
f01018c5:	68 db 03 00 00       	push   $0x3db
f01018ca:	68 9d 76 10 f0       	push   $0xf010769d
f01018cf:	e8 6c e7 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018d4:	a1 40 f2 25 f0       	mov    0xf025f240,%eax
f01018d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018dc:	c7 05 40 f2 25 f0 00 	movl   $0x0,0xf025f240
f01018e3:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018e6:	83 ec 0c             	sub    $0xc,%esp
f01018e9:	6a 00                	push   $0x0
f01018eb:	e8 37 f6 ff ff       	call   f0100f27 <page_alloc>
f01018f0:	83 c4 10             	add    $0x10,%esp
f01018f3:	85 c0                	test   %eax,%eax
f01018f5:	74 19                	je     f0101910 <mem_init+0x680>
f01018f7:	68 36 78 10 f0       	push   $0xf0107836
f01018fc:	68 c3 76 10 f0       	push   $0xf01076c3
f0101901:	68 e2 03 00 00       	push   $0x3e2
f0101906:	68 9d 76 10 f0       	push   $0xf010769d
f010190b:	e8 30 e7 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101910:	83 ec 04             	sub    $0x4,%esp
f0101913:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101916:	50                   	push   %eax
f0101917:	6a 00                	push   $0x0
f0101919:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f010191f:	e8 e9 f7 ff ff       	call   f010110d <page_lookup>
f0101924:	83 c4 10             	add    $0x10,%esp
f0101927:	85 c0                	test   %eax,%eax
f0101929:	74 19                	je     f0101944 <mem_init+0x6b4>
f010192b:	68 00 6f 10 f0       	push   $0xf0106f00
f0101930:	68 c3 76 10 f0       	push   $0xf01076c3
f0101935:	68 e5 03 00 00       	push   $0x3e5
f010193a:	68 9d 76 10 f0       	push   $0xf010769d
f010193f:	e8 fc e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101944:	6a 02                	push   $0x2
f0101946:	6a 00                	push   $0x0
f0101948:	53                   	push   %ebx
f0101949:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f010194f:	e8 5c f8 ff ff       	call   f01011b0 <page_insert>
f0101954:	83 c4 10             	add    $0x10,%esp
f0101957:	85 c0                	test   %eax,%eax
f0101959:	78 19                	js     f0101974 <mem_init+0x6e4>
f010195b:	68 38 6f 10 f0       	push   $0xf0106f38
f0101960:	68 c3 76 10 f0       	push   $0xf01076c3
f0101965:	68 e8 03 00 00       	push   $0x3e8
f010196a:	68 9d 76 10 f0       	push   $0xf010769d
f010196f:	e8 cc e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101974:	83 ec 0c             	sub    $0xc,%esp
f0101977:	ff 75 d4             	pushl  -0x2c(%ebp)
f010197a:	e8 18 f6 ff ff       	call   f0100f97 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010197f:	6a 02                	push   $0x2
f0101981:	6a 00                	push   $0x0
f0101983:	53                   	push   %ebx
f0101984:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f010198a:	e8 21 f8 ff ff       	call   f01011b0 <page_insert>
f010198f:	83 c4 20             	add    $0x20,%esp
f0101992:	85 c0                	test   %eax,%eax
f0101994:	74 19                	je     f01019af <mem_init+0x71f>
f0101996:	68 68 6f 10 f0       	push   $0xf0106f68
f010199b:	68 c3 76 10 f0       	push   $0xf01076c3
f01019a0:	68 ec 03 00 00       	push   $0x3ec
f01019a5:	68 9d 76 10 f0       	push   $0xf010769d
f01019aa:	e8 91 e6 ff ff       	call   f0100040 <_panic>

	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019af:	8b 3d a4 fe 25 f0    	mov    0xf025fea4,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019b5:	a1 a8 fe 25 f0       	mov    0xf025fea8,%eax
f01019ba:	89 c1                	mov    %eax,%ecx
f01019bc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01019bf:	8b 17                	mov    (%edi),%edx
f01019c1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019ca:	29 c8                	sub    %ecx,%eax
f01019cc:	c1 f8 03             	sar    $0x3,%eax
f01019cf:	c1 e0 0c             	shl    $0xc,%eax
f01019d2:	39 c2                	cmp    %eax,%edx
f01019d4:	74 19                	je     f01019ef <mem_init+0x75f>
f01019d6:	68 98 6f 10 f0       	push   $0xf0106f98
f01019db:	68 c3 76 10 f0       	push   $0xf01076c3
f01019e0:	68 ee 03 00 00       	push   $0x3ee
f01019e5:	68 9d 76 10 f0       	push   $0xf010769d
f01019ea:	e8 51 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019ef:	ba 00 00 00 00       	mov    $0x0,%edx
f01019f4:	89 f8                	mov    %edi,%eax
f01019f6:	e8 1a f1 ff ff       	call   f0100b15 <check_va2pa>
f01019fb:	89 da                	mov    %ebx,%edx
f01019fd:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101a00:	c1 fa 03             	sar    $0x3,%edx
f0101a03:	c1 e2 0c             	shl    $0xc,%edx
f0101a06:	39 d0                	cmp    %edx,%eax
f0101a08:	74 19                	je     f0101a23 <mem_init+0x793>
f0101a0a:	68 c0 6f 10 f0       	push   $0xf0106fc0
f0101a0f:	68 c3 76 10 f0       	push   $0xf01076c3
f0101a14:	68 ef 03 00 00       	push   $0x3ef
f0101a19:	68 9d 76 10 f0       	push   $0xf010769d
f0101a1e:	e8 1d e6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101a23:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a28:	74 19                	je     f0101a43 <mem_init+0x7b3>
f0101a2a:	68 88 78 10 f0       	push   $0xf0107888
f0101a2f:	68 c3 76 10 f0       	push   $0xf01076c3
f0101a34:	68 f0 03 00 00       	push   $0x3f0
f0101a39:	68 9d 76 10 f0       	push   $0xf010769d
f0101a3e:	e8 fd e5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101a43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a46:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a4b:	74 19                	je     f0101a66 <mem_init+0x7d6>
f0101a4d:	68 99 78 10 f0       	push   $0xf0107899
f0101a52:	68 c3 76 10 f0       	push   $0xf01076c3
f0101a57:	68 f1 03 00 00       	push   $0x3f1
f0101a5c:	68 9d 76 10 f0       	push   $0xf010769d
f0101a61:	e8 da e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a66:	6a 02                	push   $0x2
f0101a68:	68 00 10 00 00       	push   $0x1000
f0101a6d:	56                   	push   %esi
f0101a6e:	57                   	push   %edi
f0101a6f:	e8 3c f7 ff ff       	call   f01011b0 <page_insert>
f0101a74:	83 c4 10             	add    $0x10,%esp
f0101a77:	85 c0                	test   %eax,%eax
f0101a79:	74 19                	je     f0101a94 <mem_init+0x804>
f0101a7b:	68 f0 6f 10 f0       	push   $0xf0106ff0
f0101a80:	68 c3 76 10 f0       	push   $0xf01076c3
f0101a85:	68 f4 03 00 00       	push   $0x3f4
f0101a8a:	68 9d 76 10 f0       	push   $0xf010769d
f0101a8f:	e8 ac e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a94:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a99:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
f0101a9e:	e8 72 f0 ff ff       	call   f0100b15 <check_va2pa>
f0101aa3:	89 f2                	mov    %esi,%edx
f0101aa5:	2b 15 a8 fe 25 f0    	sub    0xf025fea8,%edx
f0101aab:	c1 fa 03             	sar    $0x3,%edx
f0101aae:	c1 e2 0c             	shl    $0xc,%edx
f0101ab1:	39 d0                	cmp    %edx,%eax
f0101ab3:	74 19                	je     f0101ace <mem_init+0x83e>
f0101ab5:	68 2c 70 10 f0       	push   $0xf010702c
f0101aba:	68 c3 76 10 f0       	push   $0xf01076c3
f0101abf:	68 f5 03 00 00       	push   $0x3f5
f0101ac4:	68 9d 76 10 f0       	push   $0xf010769d
f0101ac9:	e8 72 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ace:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ad3:	74 19                	je     f0101aee <mem_init+0x85e>
f0101ad5:	68 aa 78 10 f0       	push   $0xf01078aa
f0101ada:	68 c3 76 10 f0       	push   $0xf01076c3
f0101adf:	68 f6 03 00 00       	push   $0x3f6
f0101ae4:	68 9d 76 10 f0       	push   $0xf010769d
f0101ae9:	e8 52 e5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101aee:	83 ec 0c             	sub    $0xc,%esp
f0101af1:	6a 00                	push   $0x0
f0101af3:	e8 2f f4 ff ff       	call   f0100f27 <page_alloc>
f0101af8:	83 c4 10             	add    $0x10,%esp
f0101afb:	85 c0                	test   %eax,%eax
f0101afd:	74 19                	je     f0101b18 <mem_init+0x888>
f0101aff:	68 36 78 10 f0       	push   $0xf0107836
f0101b04:	68 c3 76 10 f0       	push   $0xf01076c3
f0101b09:	68 f9 03 00 00       	push   $0x3f9
f0101b0e:	68 9d 76 10 f0       	push   $0xf010769d
f0101b13:	e8 28 e5 ff ff       	call   f0100040 <_panic>
	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b18:	6a 02                	push   $0x2
f0101b1a:	68 00 10 00 00       	push   $0x1000
f0101b1f:	56                   	push   %esi
f0101b20:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f0101b26:	e8 85 f6 ff ff       	call   f01011b0 <page_insert>
f0101b2b:	83 c4 10             	add    $0x10,%esp
f0101b2e:	85 c0                	test   %eax,%eax
f0101b30:	74 19                	je     f0101b4b <mem_init+0x8bb>
f0101b32:	68 f0 6f 10 f0       	push   $0xf0106ff0
f0101b37:	68 c3 76 10 f0       	push   $0xf01076c3
f0101b3c:	68 fb 03 00 00       	push   $0x3fb
f0101b41:	68 9d 76 10 f0       	push   $0xf010769d
f0101b46:	e8 f5 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b4b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b50:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
f0101b55:	e8 bb ef ff ff       	call   f0100b15 <check_va2pa>
f0101b5a:	89 f2                	mov    %esi,%edx
f0101b5c:	2b 15 a8 fe 25 f0    	sub    0xf025fea8,%edx
f0101b62:	c1 fa 03             	sar    $0x3,%edx
f0101b65:	c1 e2 0c             	shl    $0xc,%edx
f0101b68:	39 d0                	cmp    %edx,%eax
f0101b6a:	74 19                	je     f0101b85 <mem_init+0x8f5>
f0101b6c:	68 2c 70 10 f0       	push   $0xf010702c
f0101b71:	68 c3 76 10 f0       	push   $0xf01076c3
f0101b76:	68 fc 03 00 00       	push   $0x3fc
f0101b7b:	68 9d 76 10 f0       	push   $0xf010769d
f0101b80:	e8 bb e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b85:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b8a:	74 19                	je     f0101ba5 <mem_init+0x915>
f0101b8c:	68 aa 78 10 f0       	push   $0xf01078aa
f0101b91:	68 c3 76 10 f0       	push   $0xf01076c3
f0101b96:	68 fd 03 00 00       	push   $0x3fd
f0101b9b:	68 9d 76 10 f0       	push   $0xf010769d
f0101ba0:	e8 9b e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ba5:	83 ec 0c             	sub    $0xc,%esp
f0101ba8:	6a 00                	push   $0x0
f0101baa:	e8 78 f3 ff ff       	call   f0100f27 <page_alloc>
f0101baf:	83 c4 10             	add    $0x10,%esp
f0101bb2:	85 c0                	test   %eax,%eax
f0101bb4:	74 19                	je     f0101bcf <mem_init+0x93f>
f0101bb6:	68 36 78 10 f0       	push   $0xf0107836
f0101bbb:	68 c3 76 10 f0       	push   $0xf01076c3
f0101bc0:	68 01 04 00 00       	push   $0x401
f0101bc5:	68 9d 76 10 f0       	push   $0xf010769d
f0101bca:	e8 71 e4 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101bcf:	8b 15 a4 fe 25 f0    	mov    0xf025fea4,%edx
f0101bd5:	8b 02                	mov    (%edx),%eax
f0101bd7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101bdc:	89 c1                	mov    %eax,%ecx
f0101bde:	c1 e9 0c             	shr    $0xc,%ecx
f0101be1:	3b 0d a0 fe 25 f0    	cmp    0xf025fea0,%ecx
f0101be7:	72 15                	jb     f0101bfe <mem_init+0x96e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101be9:	50                   	push   %eax
f0101bea:	68 64 67 10 f0       	push   $0xf0106764
f0101bef:	68 04 04 00 00       	push   $0x404
f0101bf4:	68 9d 76 10 f0       	push   $0xf010769d
f0101bf9:	e8 42 e4 ff ff       	call   f0100040 <_panic>
f0101bfe:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c03:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c06:	83 ec 04             	sub    $0x4,%esp
f0101c09:	6a 00                	push   $0x0
f0101c0b:	68 00 10 00 00       	push   $0x1000
f0101c10:	52                   	push   %edx
f0101c11:	e8 e3 f3 ff ff       	call   f0100ff9 <pgdir_walk>
f0101c16:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c19:	8d 51 04             	lea    0x4(%ecx),%edx
f0101c1c:	83 c4 10             	add    $0x10,%esp
f0101c1f:	39 d0                	cmp    %edx,%eax
f0101c21:	74 19                	je     f0101c3c <mem_init+0x9ac>
f0101c23:	68 5c 70 10 f0       	push   $0xf010705c
f0101c28:	68 c3 76 10 f0       	push   $0xf01076c3
f0101c2d:	68 05 04 00 00       	push   $0x405
f0101c32:	68 9d 76 10 f0       	push   $0xf010769d
f0101c37:	e8 04 e4 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c3c:	6a 06                	push   $0x6
f0101c3e:	68 00 10 00 00       	push   $0x1000
f0101c43:	56                   	push   %esi
f0101c44:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f0101c4a:	e8 61 f5 ff ff       	call   f01011b0 <page_insert>
f0101c4f:	83 c4 10             	add    $0x10,%esp
f0101c52:	85 c0                	test   %eax,%eax
f0101c54:	74 19                	je     f0101c6f <mem_init+0x9df>
f0101c56:	68 9c 70 10 f0       	push   $0xf010709c
f0101c5b:	68 c3 76 10 f0       	push   $0xf01076c3
f0101c60:	68 08 04 00 00       	push   $0x408
f0101c65:	68 9d 76 10 f0       	push   $0xf010769d
f0101c6a:	e8 d1 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c6f:	8b 3d a4 fe 25 f0    	mov    0xf025fea4,%edi
f0101c75:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c7a:	89 f8                	mov    %edi,%eax
f0101c7c:	e8 94 ee ff ff       	call   f0100b15 <check_va2pa>
f0101c81:	89 f2                	mov    %esi,%edx
f0101c83:	2b 15 a8 fe 25 f0    	sub    0xf025fea8,%edx
f0101c89:	c1 fa 03             	sar    $0x3,%edx
f0101c8c:	c1 e2 0c             	shl    $0xc,%edx
f0101c8f:	39 d0                	cmp    %edx,%eax
f0101c91:	74 19                	je     f0101cac <mem_init+0xa1c>
f0101c93:	68 2c 70 10 f0       	push   $0xf010702c
f0101c98:	68 c3 76 10 f0       	push   $0xf01076c3
f0101c9d:	68 09 04 00 00       	push   $0x409
f0101ca2:	68 9d 76 10 f0       	push   $0xf010769d
f0101ca7:	e8 94 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101cac:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101cb1:	74 19                	je     f0101ccc <mem_init+0xa3c>
f0101cb3:	68 aa 78 10 f0       	push   $0xf01078aa
f0101cb8:	68 c3 76 10 f0       	push   $0xf01076c3
f0101cbd:	68 0a 04 00 00       	push   $0x40a
f0101cc2:	68 9d 76 10 f0       	push   $0xf010769d
f0101cc7:	e8 74 e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101ccc:	83 ec 04             	sub    $0x4,%esp
f0101ccf:	6a 00                	push   $0x0
f0101cd1:	68 00 10 00 00       	push   $0x1000
f0101cd6:	57                   	push   %edi
f0101cd7:	e8 1d f3 ff ff       	call   f0100ff9 <pgdir_walk>
f0101cdc:	83 c4 10             	add    $0x10,%esp
f0101cdf:	f6 00 04             	testb  $0x4,(%eax)
f0101ce2:	75 19                	jne    f0101cfd <mem_init+0xa6d>
f0101ce4:	68 dc 70 10 f0       	push   $0xf01070dc
f0101ce9:	68 c3 76 10 f0       	push   $0xf01076c3
f0101cee:	68 0b 04 00 00       	push   $0x40b
f0101cf3:	68 9d 76 10 f0       	push   $0xf010769d
f0101cf8:	e8 43 e3 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101cfd:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
f0101d02:	f6 00 04             	testb  $0x4,(%eax)
f0101d05:	75 19                	jne    f0101d20 <mem_init+0xa90>
f0101d07:	68 bb 78 10 f0       	push   $0xf01078bb
f0101d0c:	68 c3 76 10 f0       	push   $0xf01076c3
f0101d11:	68 0c 04 00 00       	push   $0x40c
f0101d16:	68 9d 76 10 f0       	push   $0xf010769d
f0101d1b:	e8 20 e3 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d20:	6a 02                	push   $0x2
f0101d22:	68 00 10 00 00       	push   $0x1000
f0101d27:	56                   	push   %esi
f0101d28:	50                   	push   %eax
f0101d29:	e8 82 f4 ff ff       	call   f01011b0 <page_insert>
f0101d2e:	83 c4 10             	add    $0x10,%esp
f0101d31:	85 c0                	test   %eax,%eax
f0101d33:	74 19                	je     f0101d4e <mem_init+0xabe>
f0101d35:	68 f0 6f 10 f0       	push   $0xf0106ff0
f0101d3a:	68 c3 76 10 f0       	push   $0xf01076c3
f0101d3f:	68 0f 04 00 00       	push   $0x40f
f0101d44:	68 9d 76 10 f0       	push   $0xf010769d
f0101d49:	e8 f2 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d4e:	83 ec 04             	sub    $0x4,%esp
f0101d51:	6a 00                	push   $0x0
f0101d53:	68 00 10 00 00       	push   $0x1000
f0101d58:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f0101d5e:	e8 96 f2 ff ff       	call   f0100ff9 <pgdir_walk>
f0101d63:	83 c4 10             	add    $0x10,%esp
f0101d66:	f6 00 02             	testb  $0x2,(%eax)
f0101d69:	75 19                	jne    f0101d84 <mem_init+0xaf4>
f0101d6b:	68 10 71 10 f0       	push   $0xf0107110
f0101d70:	68 c3 76 10 f0       	push   $0xf01076c3
f0101d75:	68 10 04 00 00       	push   $0x410
f0101d7a:	68 9d 76 10 f0       	push   $0xf010769d
f0101d7f:	e8 bc e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d84:	83 ec 04             	sub    $0x4,%esp
f0101d87:	6a 00                	push   $0x0
f0101d89:	68 00 10 00 00       	push   $0x1000
f0101d8e:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f0101d94:	e8 60 f2 ff ff       	call   f0100ff9 <pgdir_walk>
f0101d99:	83 c4 10             	add    $0x10,%esp
f0101d9c:	f6 00 04             	testb  $0x4,(%eax)
f0101d9f:	74 19                	je     f0101dba <mem_init+0xb2a>
f0101da1:	68 44 71 10 f0       	push   $0xf0107144
f0101da6:	68 c3 76 10 f0       	push   $0xf01076c3
f0101dab:	68 11 04 00 00       	push   $0x411
f0101db0:	68 9d 76 10 f0       	push   $0xf010769d
f0101db5:	e8 86 e2 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101dba:	6a 02                	push   $0x2
f0101dbc:	68 00 00 40 00       	push   $0x400000
f0101dc1:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101dc4:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f0101dca:	e8 e1 f3 ff ff       	call   f01011b0 <page_insert>
f0101dcf:	83 c4 10             	add    $0x10,%esp
f0101dd2:	85 c0                	test   %eax,%eax
f0101dd4:	78 19                	js     f0101def <mem_init+0xb5f>
f0101dd6:	68 7c 71 10 f0       	push   $0xf010717c
f0101ddb:	68 c3 76 10 f0       	push   $0xf01076c3
f0101de0:	68 14 04 00 00       	push   $0x414
f0101de5:	68 9d 76 10 f0       	push   $0xf010769d
f0101dea:	e8 51 e2 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101def:	6a 02                	push   $0x2
f0101df1:	68 00 10 00 00       	push   $0x1000
f0101df6:	53                   	push   %ebx
f0101df7:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f0101dfd:	e8 ae f3 ff ff       	call   f01011b0 <page_insert>
f0101e02:	83 c4 10             	add    $0x10,%esp
f0101e05:	85 c0                	test   %eax,%eax
f0101e07:	74 19                	je     f0101e22 <mem_init+0xb92>
f0101e09:	68 b4 71 10 f0       	push   $0xf01071b4
f0101e0e:	68 c3 76 10 f0       	push   $0xf01076c3
f0101e13:	68 17 04 00 00       	push   $0x417
f0101e18:	68 9d 76 10 f0       	push   $0xf010769d
f0101e1d:	e8 1e e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e22:	83 ec 04             	sub    $0x4,%esp
f0101e25:	6a 00                	push   $0x0
f0101e27:	68 00 10 00 00       	push   $0x1000
f0101e2c:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f0101e32:	e8 c2 f1 ff ff       	call   f0100ff9 <pgdir_walk>
f0101e37:	83 c4 10             	add    $0x10,%esp
f0101e3a:	f6 00 04             	testb  $0x4,(%eax)
f0101e3d:	74 19                	je     f0101e58 <mem_init+0xbc8>
f0101e3f:	68 44 71 10 f0       	push   $0xf0107144
f0101e44:	68 c3 76 10 f0       	push   $0xf01076c3
f0101e49:	68 18 04 00 00       	push   $0x418
f0101e4e:	68 9d 76 10 f0       	push   $0xf010769d
f0101e53:	e8 e8 e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e58:	8b 3d a4 fe 25 f0    	mov    0xf025fea4,%edi
f0101e5e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e63:	89 f8                	mov    %edi,%eax
f0101e65:	e8 ab ec ff ff       	call   f0100b15 <check_va2pa>
f0101e6a:	89 c1                	mov    %eax,%ecx
f0101e6c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e6f:	89 d8                	mov    %ebx,%eax
f0101e71:	2b 05 a8 fe 25 f0    	sub    0xf025fea8,%eax
f0101e77:	c1 f8 03             	sar    $0x3,%eax
f0101e7a:	c1 e0 0c             	shl    $0xc,%eax
f0101e7d:	39 c1                	cmp    %eax,%ecx
f0101e7f:	74 19                	je     f0101e9a <mem_init+0xc0a>
f0101e81:	68 f0 71 10 f0       	push   $0xf01071f0
f0101e86:	68 c3 76 10 f0       	push   $0xf01076c3
f0101e8b:	68 1b 04 00 00       	push   $0x41b
f0101e90:	68 9d 76 10 f0       	push   $0xf010769d
f0101e95:	e8 a6 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e9a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e9f:	89 f8                	mov    %edi,%eax
f0101ea1:	e8 6f ec ff ff       	call   f0100b15 <check_va2pa>
f0101ea6:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101ea9:	74 19                	je     f0101ec4 <mem_init+0xc34>
f0101eab:	68 1c 72 10 f0       	push   $0xf010721c
f0101eb0:	68 c3 76 10 f0       	push   $0xf01076c3
f0101eb5:	68 1c 04 00 00       	push   $0x41c
f0101eba:	68 9d 76 10 f0       	push   $0xf010769d
f0101ebf:	e8 7c e1 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101ec4:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101ec9:	74 19                	je     f0101ee4 <mem_init+0xc54>
f0101ecb:	68 d1 78 10 f0       	push   $0xf01078d1
f0101ed0:	68 c3 76 10 f0       	push   $0xf01076c3
f0101ed5:	68 1e 04 00 00       	push   $0x41e
f0101eda:	68 9d 76 10 f0       	push   $0xf010769d
f0101edf:	e8 5c e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101ee4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ee9:	74 19                	je     f0101f04 <mem_init+0xc74>
f0101eeb:	68 e2 78 10 f0       	push   $0xf01078e2
f0101ef0:	68 c3 76 10 f0       	push   $0xf01076c3
f0101ef5:	68 1f 04 00 00       	push   $0x41f
f0101efa:	68 9d 76 10 f0       	push   $0xf010769d
f0101eff:	e8 3c e1 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101f04:	83 ec 0c             	sub    $0xc,%esp
f0101f07:	6a 00                	push   $0x0
f0101f09:	e8 19 f0 ff ff       	call   f0100f27 <page_alloc>
f0101f0e:	83 c4 10             	add    $0x10,%esp
f0101f11:	85 c0                	test   %eax,%eax
f0101f13:	74 04                	je     f0101f19 <mem_init+0xc89>
f0101f15:	39 c6                	cmp    %eax,%esi
f0101f17:	74 19                	je     f0101f32 <mem_init+0xca2>
f0101f19:	68 4c 72 10 f0       	push   $0xf010724c
f0101f1e:	68 c3 76 10 f0       	push   $0xf01076c3
f0101f23:	68 22 04 00 00       	push   $0x422
f0101f28:	68 9d 76 10 f0       	push   $0xf010769d
f0101f2d:	e8 0e e1 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101f32:	83 ec 08             	sub    $0x8,%esp
f0101f35:	6a 00                	push   $0x0
f0101f37:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f0101f3d:	e8 33 f2 ff ff       	call   f0101175 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f42:	8b 3d a4 fe 25 f0    	mov    0xf025fea4,%edi
f0101f48:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f4d:	89 f8                	mov    %edi,%eax
f0101f4f:	e8 c1 eb ff ff       	call   f0100b15 <check_va2pa>
f0101f54:	83 c4 10             	add    $0x10,%esp
f0101f57:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f5a:	74 19                	je     f0101f75 <mem_init+0xce5>
f0101f5c:	68 70 72 10 f0       	push   $0xf0107270
f0101f61:	68 c3 76 10 f0       	push   $0xf01076c3
f0101f66:	68 26 04 00 00       	push   $0x426
f0101f6b:	68 9d 76 10 f0       	push   $0xf010769d
f0101f70:	e8 cb e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f75:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f7a:	89 f8                	mov    %edi,%eax
f0101f7c:	e8 94 eb ff ff       	call   f0100b15 <check_va2pa>
f0101f81:	89 da                	mov    %ebx,%edx
f0101f83:	2b 15 a8 fe 25 f0    	sub    0xf025fea8,%edx
f0101f89:	c1 fa 03             	sar    $0x3,%edx
f0101f8c:	c1 e2 0c             	shl    $0xc,%edx
f0101f8f:	39 d0                	cmp    %edx,%eax
f0101f91:	74 19                	je     f0101fac <mem_init+0xd1c>
f0101f93:	68 1c 72 10 f0       	push   $0xf010721c
f0101f98:	68 c3 76 10 f0       	push   $0xf01076c3
f0101f9d:	68 27 04 00 00       	push   $0x427
f0101fa2:	68 9d 76 10 f0       	push   $0xf010769d
f0101fa7:	e8 94 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101fac:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fb1:	74 19                	je     f0101fcc <mem_init+0xd3c>
f0101fb3:	68 88 78 10 f0       	push   $0xf0107888
f0101fb8:	68 c3 76 10 f0       	push   $0xf01076c3
f0101fbd:	68 28 04 00 00       	push   $0x428
f0101fc2:	68 9d 76 10 f0       	push   $0xf010769d
f0101fc7:	e8 74 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101fcc:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fd1:	74 19                	je     f0101fec <mem_init+0xd5c>
f0101fd3:	68 e2 78 10 f0       	push   $0xf01078e2
f0101fd8:	68 c3 76 10 f0       	push   $0xf01076c3
f0101fdd:	68 29 04 00 00       	push   $0x429
f0101fe2:	68 9d 76 10 f0       	push   $0xf010769d
f0101fe7:	e8 54 e0 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101fec:	6a 00                	push   $0x0
f0101fee:	68 00 10 00 00       	push   $0x1000
f0101ff3:	53                   	push   %ebx
f0101ff4:	57                   	push   %edi
f0101ff5:	e8 b6 f1 ff ff       	call   f01011b0 <page_insert>
f0101ffa:	83 c4 10             	add    $0x10,%esp
f0101ffd:	85 c0                	test   %eax,%eax
f0101fff:	74 19                	je     f010201a <mem_init+0xd8a>
f0102001:	68 94 72 10 f0       	push   $0xf0107294
f0102006:	68 c3 76 10 f0       	push   $0xf01076c3
f010200b:	68 2c 04 00 00       	push   $0x42c
f0102010:	68 9d 76 10 f0       	push   $0xf010769d
f0102015:	e8 26 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f010201a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010201f:	75 19                	jne    f010203a <mem_init+0xdaa>
f0102021:	68 f3 78 10 f0       	push   $0xf01078f3
f0102026:	68 c3 76 10 f0       	push   $0xf01076c3
f010202b:	68 2d 04 00 00       	push   $0x42d
f0102030:	68 9d 76 10 f0       	push   $0xf010769d
f0102035:	e8 06 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010203a:	83 3b 00             	cmpl   $0x0,(%ebx)
f010203d:	74 19                	je     f0102058 <mem_init+0xdc8>
f010203f:	68 ff 78 10 f0       	push   $0xf01078ff
f0102044:	68 c3 76 10 f0       	push   $0xf01076c3
f0102049:	68 2e 04 00 00       	push   $0x42e
f010204e:	68 9d 76 10 f0       	push   $0xf010769d
f0102053:	e8 e8 df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102058:	83 ec 08             	sub    $0x8,%esp
f010205b:	68 00 10 00 00       	push   $0x1000
f0102060:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f0102066:	e8 0a f1 ff ff       	call   f0101175 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010206b:	8b 3d a4 fe 25 f0    	mov    0xf025fea4,%edi
f0102071:	ba 00 00 00 00       	mov    $0x0,%edx
f0102076:	89 f8                	mov    %edi,%eax
f0102078:	e8 98 ea ff ff       	call   f0100b15 <check_va2pa>
f010207d:	83 c4 10             	add    $0x10,%esp
f0102080:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102083:	74 19                	je     f010209e <mem_init+0xe0e>
f0102085:	68 70 72 10 f0       	push   $0xf0107270
f010208a:	68 c3 76 10 f0       	push   $0xf01076c3
f010208f:	68 32 04 00 00       	push   $0x432
f0102094:	68 9d 76 10 f0       	push   $0xf010769d
f0102099:	e8 a2 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010209e:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020a3:	89 f8                	mov    %edi,%eax
f01020a5:	e8 6b ea ff ff       	call   f0100b15 <check_va2pa>
f01020aa:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020ad:	74 19                	je     f01020c8 <mem_init+0xe38>
f01020af:	68 cc 72 10 f0       	push   $0xf01072cc
f01020b4:	68 c3 76 10 f0       	push   $0xf01076c3
f01020b9:	68 33 04 00 00       	push   $0x433
f01020be:	68 9d 76 10 f0       	push   $0xf010769d
f01020c3:	e8 78 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01020c8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020cd:	74 19                	je     f01020e8 <mem_init+0xe58>
f01020cf:	68 14 79 10 f0       	push   $0xf0107914
f01020d4:	68 c3 76 10 f0       	push   $0xf01076c3
f01020d9:	68 34 04 00 00       	push   $0x434
f01020de:	68 9d 76 10 f0       	push   $0xf010769d
f01020e3:	e8 58 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020e8:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020ed:	74 19                	je     f0102108 <mem_init+0xe78>
f01020ef:	68 e2 78 10 f0       	push   $0xf01078e2
f01020f4:	68 c3 76 10 f0       	push   $0xf01076c3
f01020f9:	68 35 04 00 00       	push   $0x435
f01020fe:	68 9d 76 10 f0       	push   $0xf010769d
f0102103:	e8 38 df ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102108:	83 ec 0c             	sub    $0xc,%esp
f010210b:	6a 00                	push   $0x0
f010210d:	e8 15 ee ff ff       	call   f0100f27 <page_alloc>
f0102112:	83 c4 10             	add    $0x10,%esp
f0102115:	39 c3                	cmp    %eax,%ebx
f0102117:	75 04                	jne    f010211d <mem_init+0xe8d>
f0102119:	85 c0                	test   %eax,%eax
f010211b:	75 19                	jne    f0102136 <mem_init+0xea6>
f010211d:	68 f4 72 10 f0       	push   $0xf01072f4
f0102122:	68 c3 76 10 f0       	push   $0xf01076c3
f0102127:	68 38 04 00 00       	push   $0x438
f010212c:	68 9d 76 10 f0       	push   $0xf010769d
f0102131:	e8 0a df ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102136:	83 ec 0c             	sub    $0xc,%esp
f0102139:	6a 00                	push   $0x0
f010213b:	e8 e7 ed ff ff       	call   f0100f27 <page_alloc>
f0102140:	83 c4 10             	add    $0x10,%esp
f0102143:	85 c0                	test   %eax,%eax
f0102145:	74 19                	je     f0102160 <mem_init+0xed0>
f0102147:	68 36 78 10 f0       	push   $0xf0107836
f010214c:	68 c3 76 10 f0       	push   $0xf01076c3
f0102151:	68 3b 04 00 00       	push   $0x43b
f0102156:	68 9d 76 10 f0       	push   $0xf010769d
f010215b:	e8 e0 de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102160:	8b 0d a4 fe 25 f0    	mov    0xf025fea4,%ecx
f0102166:	8b 11                	mov    (%ecx),%edx
f0102168:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010216e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102171:	2b 05 a8 fe 25 f0    	sub    0xf025fea8,%eax
f0102177:	c1 f8 03             	sar    $0x3,%eax
f010217a:	c1 e0 0c             	shl    $0xc,%eax
f010217d:	39 c2                	cmp    %eax,%edx
f010217f:	74 19                	je     f010219a <mem_init+0xf0a>
f0102181:	68 98 6f 10 f0       	push   $0xf0106f98
f0102186:	68 c3 76 10 f0       	push   $0xf01076c3
f010218b:	68 3e 04 00 00       	push   $0x43e
f0102190:	68 9d 76 10 f0       	push   $0xf010769d
f0102195:	e8 a6 de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010219a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01021a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021a3:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021a8:	74 19                	je     f01021c3 <mem_init+0xf33>
f01021aa:	68 99 78 10 f0       	push   $0xf0107899
f01021af:	68 c3 76 10 f0       	push   $0xf01076c3
f01021b4:	68 40 04 00 00       	push   $0x440
f01021b9:	68 9d 76 10 f0       	push   $0xf010769d
f01021be:	e8 7d de ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01021c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021c6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01021cc:	83 ec 0c             	sub    $0xc,%esp
f01021cf:	50                   	push   %eax
f01021d0:	e8 c2 ed ff ff       	call   f0100f97 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01021d5:	83 c4 0c             	add    $0xc,%esp
f01021d8:	6a 01                	push   $0x1
f01021da:	68 00 10 40 00       	push   $0x401000
f01021df:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f01021e5:	e8 0f ee ff ff       	call   f0100ff9 <pgdir_walk>
f01021ea:	89 c7                	mov    %eax,%edi
f01021ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01021ef:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
f01021f4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01021f7:	8b 40 04             	mov    0x4(%eax),%eax
f01021fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021ff:	8b 0d a0 fe 25 f0    	mov    0xf025fea0,%ecx
f0102205:	89 c2                	mov    %eax,%edx
f0102207:	c1 ea 0c             	shr    $0xc,%edx
f010220a:	83 c4 10             	add    $0x10,%esp
f010220d:	39 ca                	cmp    %ecx,%edx
f010220f:	72 15                	jb     f0102226 <mem_init+0xf96>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102211:	50                   	push   %eax
f0102212:	68 64 67 10 f0       	push   $0xf0106764
f0102217:	68 47 04 00 00       	push   $0x447
f010221c:	68 9d 76 10 f0       	push   $0xf010769d
f0102221:	e8 1a de ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102226:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010222b:	39 c7                	cmp    %eax,%edi
f010222d:	74 19                	je     f0102248 <mem_init+0xfb8>
f010222f:	68 25 79 10 f0       	push   $0xf0107925
f0102234:	68 c3 76 10 f0       	push   $0xf01076c3
f0102239:	68 48 04 00 00       	push   $0x448
f010223e:	68 9d 76 10 f0       	push   $0xf010769d
f0102243:	e8 f8 dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102248:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010224b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102252:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102255:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010225b:	2b 05 a8 fe 25 f0    	sub    0xf025fea8,%eax
f0102261:	c1 f8 03             	sar    $0x3,%eax
f0102264:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102267:	89 c2                	mov    %eax,%edx
f0102269:	c1 ea 0c             	shr    $0xc,%edx
f010226c:	39 d1                	cmp    %edx,%ecx
f010226e:	77 12                	ja     f0102282 <mem_init+0xff2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102270:	50                   	push   %eax
f0102271:	68 64 67 10 f0       	push   $0xf0106764
f0102276:	6a 58                	push   $0x58
f0102278:	68 a9 76 10 f0       	push   $0xf01076a9
f010227d:	e8 be dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102282:	83 ec 04             	sub    $0x4,%esp
f0102285:	68 00 10 00 00       	push   $0x1000
f010228a:	68 ff 00 00 00       	push   $0xff
f010228f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102294:	50                   	push   %eax
f0102295:	e8 90 32 00 00       	call   f010552a <memset>
	page_free(pp0);
f010229a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010229d:	89 3c 24             	mov    %edi,(%esp)
f01022a0:	e8 f2 ec ff ff       	call   f0100f97 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01022a5:	83 c4 0c             	add    $0xc,%esp
f01022a8:	6a 01                	push   $0x1
f01022aa:	6a 00                	push   $0x0
f01022ac:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f01022b2:	e8 42 ed ff ff       	call   f0100ff9 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022b7:	89 fa                	mov    %edi,%edx
f01022b9:	2b 15 a8 fe 25 f0    	sub    0xf025fea8,%edx
f01022bf:	c1 fa 03             	sar    $0x3,%edx
f01022c2:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022c5:	89 d0                	mov    %edx,%eax
f01022c7:	c1 e8 0c             	shr    $0xc,%eax
f01022ca:	83 c4 10             	add    $0x10,%esp
f01022cd:	3b 05 a0 fe 25 f0    	cmp    0xf025fea0,%eax
f01022d3:	72 12                	jb     f01022e7 <mem_init+0x1057>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022d5:	52                   	push   %edx
f01022d6:	68 64 67 10 f0       	push   $0xf0106764
f01022db:	6a 58                	push   $0x58
f01022dd:	68 a9 76 10 f0       	push   $0xf01076a9
f01022e2:	e8 59 dd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01022e7:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01022ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01022f0:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01022f6:	f6 00 01             	testb  $0x1,(%eax)
f01022f9:	74 19                	je     f0102314 <mem_init+0x1084>
f01022fb:	68 3d 79 10 f0       	push   $0xf010793d
f0102300:	68 c3 76 10 f0       	push   $0xf01076c3
f0102305:	68 52 04 00 00       	push   $0x452
f010230a:	68 9d 76 10 f0       	push   $0xf010769d
f010230f:	e8 2c dd ff ff       	call   f0100040 <_panic>
f0102314:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102317:	39 c2                	cmp    %eax,%edx
f0102319:	75 db                	jne    f01022f6 <mem_init+0x1066>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010231b:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
f0102320:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102326:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102329:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010232f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102332:	89 0d 40 f2 25 f0    	mov    %ecx,0xf025f240

	// free the pages we took
	page_free(pp0);
f0102338:	83 ec 0c             	sub    $0xc,%esp
f010233b:	50                   	push   %eax
f010233c:	e8 56 ec ff ff       	call   f0100f97 <page_free>
	page_free(pp1);
f0102341:	89 1c 24             	mov    %ebx,(%esp)
f0102344:	e8 4e ec ff ff       	call   f0100f97 <page_free>
	page_free(pp2);
f0102349:	89 34 24             	mov    %esi,(%esp)
f010234c:	e8 46 ec ff ff       	call   f0100f97 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102351:	83 c4 08             	add    $0x8,%esp
f0102354:	68 01 10 00 00       	push   $0x1001
f0102359:	6a 00                	push   $0x0
f010235b:	e8 cd ee ff ff       	call   f010122d <mmio_map_region>
f0102360:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102362:	83 c4 08             	add    $0x8,%esp
f0102365:	68 00 10 00 00       	push   $0x1000
f010236a:	6a 00                	push   $0x0
f010236c:	e8 bc ee ff ff       	call   f010122d <mmio_map_region>
f0102371:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102373:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102379:	83 c4 10             	add    $0x10,%esp
f010237c:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102382:	76 07                	jbe    f010238b <mem_init+0x10fb>
f0102384:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102389:	76 19                	jbe    f01023a4 <mem_init+0x1114>
f010238b:	68 18 73 10 f0       	push   $0xf0107318
f0102390:	68 c3 76 10 f0       	push   $0xf01076c3
f0102395:	68 62 04 00 00       	push   $0x462
f010239a:	68 9d 76 10 f0       	push   $0xf010769d
f010239f:	e8 9c dc ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01023a4:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01023aa:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01023b0:	77 08                	ja     f01023ba <mem_init+0x112a>
f01023b2:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01023b8:	77 19                	ja     f01023d3 <mem_init+0x1143>
f01023ba:	68 40 73 10 f0       	push   $0xf0107340
f01023bf:	68 c3 76 10 f0       	push   $0xf01076c3
f01023c4:	68 63 04 00 00       	push   $0x463
f01023c9:	68 9d 76 10 f0       	push   $0xf010769d
f01023ce:	e8 6d dc ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01023d3:	89 da                	mov    %ebx,%edx
f01023d5:	09 f2                	or     %esi,%edx
f01023d7:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01023dd:	74 19                	je     f01023f8 <mem_init+0x1168>
f01023df:	68 68 73 10 f0       	push   $0xf0107368
f01023e4:	68 c3 76 10 f0       	push   $0xf01076c3
f01023e9:	68 65 04 00 00       	push   $0x465
f01023ee:	68 9d 76 10 f0       	push   $0xf010769d
f01023f3:	e8 48 dc ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01023f8:	39 c6                	cmp    %eax,%esi
f01023fa:	73 19                	jae    f0102415 <mem_init+0x1185>
f01023fc:	68 54 79 10 f0       	push   $0xf0107954
f0102401:	68 c3 76 10 f0       	push   $0xf01076c3
f0102406:	68 67 04 00 00       	push   $0x467
f010240b:	68 9d 76 10 f0       	push   $0xf010769d
f0102410:	e8 2b dc ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102415:	8b 3d a4 fe 25 f0    	mov    0xf025fea4,%edi
f010241b:	89 da                	mov    %ebx,%edx
f010241d:	89 f8                	mov    %edi,%eax
f010241f:	e8 f1 e6 ff ff       	call   f0100b15 <check_va2pa>
f0102424:	85 c0                	test   %eax,%eax
f0102426:	74 19                	je     f0102441 <mem_init+0x11b1>
f0102428:	68 90 73 10 f0       	push   $0xf0107390
f010242d:	68 c3 76 10 f0       	push   $0xf01076c3
f0102432:	68 69 04 00 00       	push   $0x469
f0102437:	68 9d 76 10 f0       	push   $0xf010769d
f010243c:	e8 ff db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102441:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102447:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010244a:	89 c2                	mov    %eax,%edx
f010244c:	89 f8                	mov    %edi,%eax
f010244e:	e8 c2 e6 ff ff       	call   f0100b15 <check_va2pa>
f0102453:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102458:	74 19                	je     f0102473 <mem_init+0x11e3>
f010245a:	68 b4 73 10 f0       	push   $0xf01073b4
f010245f:	68 c3 76 10 f0       	push   $0xf01076c3
f0102464:	68 6a 04 00 00       	push   $0x46a
f0102469:	68 9d 76 10 f0       	push   $0xf010769d
f010246e:	e8 cd db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102473:	89 f2                	mov    %esi,%edx
f0102475:	89 f8                	mov    %edi,%eax
f0102477:	e8 99 e6 ff ff       	call   f0100b15 <check_va2pa>
f010247c:	85 c0                	test   %eax,%eax
f010247e:	74 19                	je     f0102499 <mem_init+0x1209>
f0102480:	68 e4 73 10 f0       	push   $0xf01073e4
f0102485:	68 c3 76 10 f0       	push   $0xf01076c3
f010248a:	68 6b 04 00 00       	push   $0x46b
f010248f:	68 9d 76 10 f0       	push   $0xf010769d
f0102494:	e8 a7 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102499:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010249f:	89 f8                	mov    %edi,%eax
f01024a1:	e8 6f e6 ff ff       	call   f0100b15 <check_va2pa>
f01024a6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024a9:	74 19                	je     f01024c4 <mem_init+0x1234>
f01024ab:	68 08 74 10 f0       	push   $0xf0107408
f01024b0:	68 c3 76 10 f0       	push   $0xf01076c3
f01024b5:	68 6c 04 00 00       	push   $0x46c
f01024ba:	68 9d 76 10 f0       	push   $0xf010769d
f01024bf:	e8 7c db ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01024c4:	83 ec 04             	sub    $0x4,%esp
f01024c7:	6a 00                	push   $0x0
f01024c9:	53                   	push   %ebx
f01024ca:	57                   	push   %edi
f01024cb:	e8 29 eb ff ff       	call   f0100ff9 <pgdir_walk>
f01024d0:	83 c4 10             	add    $0x10,%esp
f01024d3:	f6 00 1a             	testb  $0x1a,(%eax)
f01024d6:	75 19                	jne    f01024f1 <mem_init+0x1261>
f01024d8:	68 34 74 10 f0       	push   $0xf0107434
f01024dd:	68 c3 76 10 f0       	push   $0xf01076c3
f01024e2:	68 6e 04 00 00       	push   $0x46e
f01024e7:	68 9d 76 10 f0       	push   $0xf010769d
f01024ec:	e8 4f db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01024f1:	83 ec 04             	sub    $0x4,%esp
f01024f4:	6a 00                	push   $0x0
f01024f6:	53                   	push   %ebx
f01024f7:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f01024fd:	e8 f7 ea ff ff       	call   f0100ff9 <pgdir_walk>
f0102502:	8b 00                	mov    (%eax),%eax
f0102504:	83 c4 10             	add    $0x10,%esp
f0102507:	83 e0 04             	and    $0x4,%eax
f010250a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010250d:	74 19                	je     f0102528 <mem_init+0x1298>
f010250f:	68 78 74 10 f0       	push   $0xf0107478
f0102514:	68 c3 76 10 f0       	push   $0xf01076c3
f0102519:	68 6f 04 00 00       	push   $0x46f
f010251e:	68 9d 76 10 f0       	push   $0xf010769d
f0102523:	e8 18 db ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102528:	83 ec 04             	sub    $0x4,%esp
f010252b:	6a 00                	push   $0x0
f010252d:	53                   	push   %ebx
f010252e:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f0102534:	e8 c0 ea ff ff       	call   f0100ff9 <pgdir_walk>
f0102539:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010253f:	83 c4 0c             	add    $0xc,%esp
f0102542:	6a 00                	push   $0x0
f0102544:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102547:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f010254d:	e8 a7 ea ff ff       	call   f0100ff9 <pgdir_walk>
f0102552:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102558:	83 c4 0c             	add    $0xc,%esp
f010255b:	6a 00                	push   $0x0
f010255d:	56                   	push   %esi
f010255e:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f0102564:	e8 90 ea ff ff       	call   f0100ff9 <pgdir_walk>
f0102569:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010256f:	c7 04 24 66 79 10 f0 	movl   $0xf0107966,(%esp)
f0102576:	e8 69 11 00 00       	call   f01036e4 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f010257b:	a1 a8 fe 25 f0       	mov    0xf025fea8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102580:	83 c4 10             	add    $0x10,%esp
f0102583:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102588:	77 15                	ja     f010259f <mem_init+0x130f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010258a:	50                   	push   %eax
f010258b:	68 88 67 10 f0       	push   $0xf0106788
f0102590:	68 d5 00 00 00       	push   $0xd5
f0102595:	68 9d 76 10 f0       	push   $0xf010769d
f010259a:	e8 a1 da ff ff       	call   f0100040 <_panic>
f010259f:	83 ec 08             	sub    $0x8,%esp
f01025a2:	6a 04                	push   $0x4
f01025a4:	05 00 00 00 10       	add    $0x10000000,%eax
f01025a9:	50                   	push   %eax
f01025aa:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01025af:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01025b4:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
f01025b9:	e8 ce ea ff ff       	call   f010108c <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f01025be:	a1 48 f2 25 f0       	mov    0xf025f248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025c3:	83 c4 10             	add    $0x10,%esp
f01025c6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025cb:	77 15                	ja     f01025e2 <mem_init+0x1352>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025cd:	50                   	push   %eax
f01025ce:	68 88 67 10 f0       	push   $0xf0106788
f01025d3:	68 df 00 00 00       	push   $0xdf
f01025d8:	68 9d 76 10 f0       	push   $0xf010769d
f01025dd:	e8 5e da ff ff       	call   f0100040 <_panic>
f01025e2:	83 ec 08             	sub    $0x8,%esp
f01025e5:	6a 04                	push   $0x4
f01025e7:	05 00 00 00 10       	add    $0x10000000,%eax
f01025ec:	50                   	push   %eax
f01025ed:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01025f2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01025f7:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
f01025fc:	e8 8b ea ff ff       	call   f010108c <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102601:	83 c4 10             	add    $0x10,%esp
f0102604:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0102609:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010260e:	77 15                	ja     f0102625 <mem_init+0x1395>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102610:	50                   	push   %eax
f0102611:	68 88 67 10 f0       	push   $0xf0106788
f0102616:	68 ec 00 00 00       	push   $0xec
f010261b:	68 9d 76 10 f0       	push   $0xf010769d
f0102620:	e8 1b da ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f0102625:	83 ec 08             	sub    $0x8,%esp
f0102628:	6a 03                	push   $0x3
f010262a:	68 00 80 11 00       	push   $0x118000
f010262f:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102634:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102639:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
f010263e:	e8 49 ea ff ff       	call   f010108c <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0x0, PTE_W | PTE_P);
f0102643:	83 c4 08             	add    $0x8,%esp
f0102646:	6a 03                	push   $0x3
f0102648:	6a 00                	push   $0x0
f010264a:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f010264f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102654:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
f0102659:	e8 2e ea ff ff       	call   f010108c <boot_map_region>
f010265e:	c7 45 c4 00 10 26 f0 	movl   $0xf0261000,-0x3c(%ebp)
f0102665:	83 c4 10             	add    $0x10,%esp
f0102668:	bb 00 10 26 f0       	mov    $0xf0261000,%ebx
f010266d:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102672:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102678:	77 15                	ja     f010268f <mem_init+0x13ff>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010267a:	53                   	push   %ebx
f010267b:	68 88 67 10 f0       	push   $0xf0106788
f0102680:	68 30 01 00 00       	push   $0x130
f0102685:	68 9d 76 10 f0       	push   $0xf010769d
f010268a:	e8 b1 d9 ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
	uint32_t kstacktop_i = KSTACKTOP;
	int i=0;
	for(i=0; i<NCPU; i++) 
	{
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W | PTE_P);
f010268f:	83 ec 08             	sub    $0x8,%esp
f0102692:	6a 03                	push   $0x3
f0102694:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010269a:	50                   	push   %eax
f010269b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026a0:	89 f2                	mov    %esi,%edx
f01026a2:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
f01026a7:	e8 e0 e9 ff ff       	call   f010108c <boot_map_region>
f01026ac:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01026b2:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uint32_t kstacktop_i = KSTACKTOP;
	int i=0;
	for(i=0; i<NCPU; i++) 
f01026b8:	83 c4 10             	add    $0x10,%esp
f01026bb:	b8 00 10 2a f0       	mov    $0xf02a1000,%eax
f01026c0:	39 d8                	cmp    %ebx,%eax
f01026c2:	75 ae                	jne    f0102672 <mem_init+0x13e2>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026c4:	8b 3d a4 fe 25 f0    	mov    0xf025fea4,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026ca:	a1 a0 fe 25 f0       	mov    0xf025fea0,%eax
f01026cf:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01026d2:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01026d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01026de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026e1:	8b 35 a8 fe 25 f0    	mov    0xf025fea8,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026e7:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01026ea:	bb 00 00 00 00       	mov    $0x0,%ebx
f01026ef:	eb 55                	jmp    f0102746 <mem_init+0x14b6>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026f1:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01026f7:	89 f8                	mov    %edi,%eax
f01026f9:	e8 17 e4 ff ff       	call   f0100b15 <check_va2pa>
f01026fe:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102705:	77 15                	ja     f010271c <mem_init+0x148c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102707:	56                   	push   %esi
f0102708:	68 88 67 10 f0       	push   $0xf0106788
f010270d:	68 87 03 00 00       	push   $0x387
f0102712:	68 9d 76 10 f0       	push   $0xf010769d
f0102717:	e8 24 d9 ff ff       	call   f0100040 <_panic>
f010271c:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102723:	39 c2                	cmp    %eax,%edx
f0102725:	74 19                	je     f0102740 <mem_init+0x14b0>
f0102727:	68 ac 74 10 f0       	push   $0xf01074ac
f010272c:	68 c3 76 10 f0       	push   $0xf01076c3
f0102731:	68 87 03 00 00       	push   $0x387
f0102736:	68 9d 76 10 f0       	push   $0xf010769d
f010273b:	e8 00 d9 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102740:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102746:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102749:	77 a6                	ja     f01026f1 <mem_init+0x1461>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010274b:	8b 35 48 f2 25 f0    	mov    0xf025f248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102751:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102754:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102759:	89 da                	mov    %ebx,%edx
f010275b:	89 f8                	mov    %edi,%eax
f010275d:	e8 b3 e3 ff ff       	call   f0100b15 <check_va2pa>
f0102762:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102769:	77 15                	ja     f0102780 <mem_init+0x14f0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010276b:	56                   	push   %esi
f010276c:	68 88 67 10 f0       	push   $0xf0106788
f0102771:	68 8c 03 00 00       	push   $0x38c
f0102776:	68 9d 76 10 f0       	push   $0xf010769d
f010277b:	e8 c0 d8 ff ff       	call   f0100040 <_panic>
f0102780:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102787:	39 d0                	cmp    %edx,%eax
f0102789:	74 19                	je     f01027a4 <mem_init+0x1514>
f010278b:	68 e0 74 10 f0       	push   $0xf01074e0
f0102790:	68 c3 76 10 f0       	push   $0xf01076c3
f0102795:	68 8c 03 00 00       	push   $0x38c
f010279a:	68 9d 76 10 f0       	push   $0xf010769d
f010279f:	e8 9c d8 ff ff       	call   f0100040 <_panic>
f01027a4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027aa:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01027b0:	75 a7                	jne    f0102759 <mem_init+0x14c9>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027b2:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01027b5:	c1 e6 0c             	shl    $0xc,%esi
f01027b8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01027bd:	eb 30                	jmp    f01027ef <mem_init+0x155f>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01027bf:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01027c5:	89 f8                	mov    %edi,%eax
f01027c7:	e8 49 e3 ff ff       	call   f0100b15 <check_va2pa>
f01027cc:	39 c3                	cmp    %eax,%ebx
f01027ce:	74 19                	je     f01027e9 <mem_init+0x1559>
f01027d0:	68 14 75 10 f0       	push   $0xf0107514
f01027d5:	68 c3 76 10 f0       	push   $0xf01076c3
f01027da:	68 90 03 00 00       	push   $0x390
f01027df:	68 9d 76 10 f0       	push   $0xf010769d
f01027e4:	e8 57 d8 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027e9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01027ef:	39 f3                	cmp    %esi,%ebx
f01027f1:	72 cc                	jb     f01027bf <mem_init+0x152f>
f01027f3:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01027f8:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01027fb:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01027fe:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102801:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102807:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010280a:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010280c:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010280f:	05 00 80 00 20       	add    $0x20008000,%eax
f0102814:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102817:	89 da                	mov    %ebx,%edx
f0102819:	89 f8                	mov    %edi,%eax
f010281b:	e8 f5 e2 ff ff       	call   f0100b15 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102820:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102826:	77 15                	ja     f010283d <mem_init+0x15ad>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102828:	56                   	push   %esi
f0102829:	68 88 67 10 f0       	push   $0xf0106788
f010282e:	68 98 03 00 00       	push   $0x398
f0102833:	68 9d 76 10 f0       	push   $0xf010769d
f0102838:	e8 03 d8 ff ff       	call   f0100040 <_panic>
f010283d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102840:	8d 94 0b 00 10 26 f0 	lea    -0xfd9f000(%ebx,%ecx,1),%edx
f0102847:	39 d0                	cmp    %edx,%eax
f0102849:	74 19                	je     f0102864 <mem_init+0x15d4>
f010284b:	68 3c 75 10 f0       	push   $0xf010753c
f0102850:	68 c3 76 10 f0       	push   $0xf01076c3
f0102855:	68 98 03 00 00       	push   $0x398
f010285a:	68 9d 76 10 f0       	push   $0xf010769d
f010285f:	e8 dc d7 ff ff       	call   f0100040 <_panic>
f0102864:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010286a:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f010286d:	75 a8                	jne    f0102817 <mem_init+0x1587>
f010286f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102872:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102878:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010287b:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010287d:	89 da                	mov    %ebx,%edx
f010287f:	89 f8                	mov    %edi,%eax
f0102881:	e8 8f e2 ff ff       	call   f0100b15 <check_va2pa>
f0102886:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102889:	74 19                	je     f01028a4 <mem_init+0x1614>
f010288b:	68 84 75 10 f0       	push   $0xf0107584
f0102890:	68 c3 76 10 f0       	push   $0xf01076c3
f0102895:	68 9a 03 00 00       	push   $0x39a
f010289a:	68 9d 76 10 f0       	push   $0xf010769d
f010289f:	e8 9c d7 ff ff       	call   f0100040 <_panic>
f01028a4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01028aa:	39 de                	cmp    %ebx,%esi
f01028ac:	75 cf                	jne    f010287d <mem_init+0x15ed>
f01028ae:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01028b1:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01028b8:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01028bf:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01028c5:	b8 00 10 2a f0       	mov    $0xf02a1000,%eax
f01028ca:	39 f0                	cmp    %esi,%eax
f01028cc:	0f 85 2c ff ff ff    	jne    f01027fe <mem_init+0x156e>
f01028d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01028d7:	eb 2a                	jmp    f0102903 <mem_init+0x1673>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}
	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01028d9:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01028df:	83 fa 04             	cmp    $0x4,%edx
f01028e2:	77 1f                	ja     f0102903 <mem_init+0x1673>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f01028e4:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f01028e8:	75 7e                	jne    f0102968 <mem_init+0x16d8>
f01028ea:	68 7f 79 10 f0       	push   $0xf010797f
f01028ef:	68 c3 76 10 f0       	push   $0xf01076c3
f01028f4:	68 a4 03 00 00       	push   $0x3a4
f01028f9:	68 9d 76 10 f0       	push   $0xf010769d
f01028fe:	e8 3d d7 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102903:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102908:	76 3f                	jbe    f0102949 <mem_init+0x16b9>
				assert(pgdir[i] & PTE_P);
f010290a:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010290d:	f6 c2 01             	test   $0x1,%dl
f0102910:	75 19                	jne    f010292b <mem_init+0x169b>
f0102912:	68 7f 79 10 f0       	push   $0xf010797f
f0102917:	68 c3 76 10 f0       	push   $0xf01076c3
f010291c:	68 a8 03 00 00       	push   $0x3a8
f0102921:	68 9d 76 10 f0       	push   $0xf010769d
f0102926:	e8 15 d7 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f010292b:	f6 c2 02             	test   $0x2,%dl
f010292e:	75 38                	jne    f0102968 <mem_init+0x16d8>
f0102930:	68 90 79 10 f0       	push   $0xf0107990
f0102935:	68 c3 76 10 f0       	push   $0xf01076c3
f010293a:	68 a9 03 00 00       	push   $0x3a9
f010293f:	68 9d 76 10 f0       	push   $0xf010769d
f0102944:	e8 f7 d6 ff ff       	call   f0100040 <_panic>
			} else {
				assert(pgdir[i] == 0);
f0102949:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f010294d:	74 19                	je     f0102968 <mem_init+0x16d8>
f010294f:	68 a1 79 10 f0       	push   $0xf01079a1
f0102954:	68 c3 76 10 f0       	push   $0xf01076c3
f0102959:	68 ab 03 00 00       	push   $0x3ab
f010295e:	68 9d 76 10 f0       	push   $0xf010769d
f0102963:	e8 d8 d6 ff ff       	call   f0100040 <_panic>
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}
	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102968:	83 c0 01             	add    $0x1,%eax
f010296b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102970:	0f 86 63 ff ff ff    	jbe    f01028d9 <mem_init+0x1649>
				assert(pgdir[i] == 0);
			}
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102976:	83 ec 0c             	sub    $0xc,%esp
f0102979:	68 a8 75 10 f0       	push   $0xf01075a8
f010297e:	e8 61 0d 00 00       	call   f01036e4 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102983:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102988:	83 c4 10             	add    $0x10,%esp
f010298b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102990:	77 15                	ja     f01029a7 <mem_init+0x1717>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102992:	50                   	push   %eax
f0102993:	68 88 67 10 f0       	push   $0xf0106788
f0102998:	68 07 01 00 00       	push   $0x107
f010299d:	68 9d 76 10 f0       	push   $0xf010769d
f01029a2:	e8 99 d6 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01029a7:	05 00 00 00 10       	add    $0x10000000,%eax
f01029ac:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01029af:	b8 00 00 00 00       	mov    $0x0,%eax
f01029b4:	e8 c0 e1 ff ff       	call   f0100b79 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01029b9:	0f 20 c0             	mov    %cr0,%eax
f01029bc:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01029bf:	0d 23 00 05 80       	or     $0x80050023,%eax
f01029c4:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01029c7:	83 ec 0c             	sub    $0xc,%esp
f01029ca:	6a 00                	push   $0x0
f01029cc:	e8 56 e5 ff ff       	call   f0100f27 <page_alloc>
f01029d1:	89 c3                	mov    %eax,%ebx
f01029d3:	83 c4 10             	add    $0x10,%esp
f01029d6:	85 c0                	test   %eax,%eax
f01029d8:	75 19                	jne    f01029f3 <mem_init+0x1763>
f01029da:	68 8b 77 10 f0       	push   $0xf010778b
f01029df:	68 c3 76 10 f0       	push   $0xf01076c3
f01029e4:	68 84 04 00 00       	push   $0x484
f01029e9:	68 9d 76 10 f0       	push   $0xf010769d
f01029ee:	e8 4d d6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01029f3:	83 ec 0c             	sub    $0xc,%esp
f01029f6:	6a 00                	push   $0x0
f01029f8:	e8 2a e5 ff ff       	call   f0100f27 <page_alloc>
f01029fd:	89 c7                	mov    %eax,%edi
f01029ff:	83 c4 10             	add    $0x10,%esp
f0102a02:	85 c0                	test   %eax,%eax
f0102a04:	75 19                	jne    f0102a1f <mem_init+0x178f>
f0102a06:	68 a1 77 10 f0       	push   $0xf01077a1
f0102a0b:	68 c3 76 10 f0       	push   $0xf01076c3
f0102a10:	68 85 04 00 00       	push   $0x485
f0102a15:	68 9d 76 10 f0       	push   $0xf010769d
f0102a1a:	e8 21 d6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102a1f:	83 ec 0c             	sub    $0xc,%esp
f0102a22:	6a 00                	push   $0x0
f0102a24:	e8 fe e4 ff ff       	call   f0100f27 <page_alloc>
f0102a29:	89 c6                	mov    %eax,%esi
f0102a2b:	83 c4 10             	add    $0x10,%esp
f0102a2e:	85 c0                	test   %eax,%eax
f0102a30:	75 19                	jne    f0102a4b <mem_init+0x17bb>
f0102a32:	68 b7 77 10 f0       	push   $0xf01077b7
f0102a37:	68 c3 76 10 f0       	push   $0xf01076c3
f0102a3c:	68 86 04 00 00       	push   $0x486
f0102a41:	68 9d 76 10 f0       	push   $0xf010769d
f0102a46:	e8 f5 d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102a4b:	83 ec 0c             	sub    $0xc,%esp
f0102a4e:	53                   	push   %ebx
f0102a4f:	e8 43 e5 ff ff       	call   f0100f97 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a54:	89 f8                	mov    %edi,%eax
f0102a56:	2b 05 a8 fe 25 f0    	sub    0xf025fea8,%eax
f0102a5c:	c1 f8 03             	sar    $0x3,%eax
f0102a5f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a62:	89 c2                	mov    %eax,%edx
f0102a64:	c1 ea 0c             	shr    $0xc,%edx
f0102a67:	83 c4 10             	add    $0x10,%esp
f0102a6a:	3b 15 a0 fe 25 f0    	cmp    0xf025fea0,%edx
f0102a70:	72 12                	jb     f0102a84 <mem_init+0x17f4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a72:	50                   	push   %eax
f0102a73:	68 64 67 10 f0       	push   $0xf0106764
f0102a78:	6a 58                	push   $0x58
f0102a7a:	68 a9 76 10 f0       	push   $0xf01076a9
f0102a7f:	e8 bc d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a84:	83 ec 04             	sub    $0x4,%esp
f0102a87:	68 00 10 00 00       	push   $0x1000
f0102a8c:	6a 01                	push   $0x1
f0102a8e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a93:	50                   	push   %eax
f0102a94:	e8 91 2a 00 00       	call   f010552a <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a99:	89 f0                	mov    %esi,%eax
f0102a9b:	2b 05 a8 fe 25 f0    	sub    0xf025fea8,%eax
f0102aa1:	c1 f8 03             	sar    $0x3,%eax
f0102aa4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102aa7:	89 c2                	mov    %eax,%edx
f0102aa9:	c1 ea 0c             	shr    $0xc,%edx
f0102aac:	83 c4 10             	add    $0x10,%esp
f0102aaf:	3b 15 a0 fe 25 f0    	cmp    0xf025fea0,%edx
f0102ab5:	72 12                	jb     f0102ac9 <mem_init+0x1839>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ab7:	50                   	push   %eax
f0102ab8:	68 64 67 10 f0       	push   $0xf0106764
f0102abd:	6a 58                	push   $0x58
f0102abf:	68 a9 76 10 f0       	push   $0xf01076a9
f0102ac4:	e8 77 d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102ac9:	83 ec 04             	sub    $0x4,%esp
f0102acc:	68 00 10 00 00       	push   $0x1000
f0102ad1:	6a 02                	push   $0x2
f0102ad3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ad8:	50                   	push   %eax
f0102ad9:	e8 4c 2a 00 00       	call   f010552a <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102ade:	6a 02                	push   $0x2
f0102ae0:	68 00 10 00 00       	push   $0x1000
f0102ae5:	57                   	push   %edi
f0102ae6:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f0102aec:	e8 bf e6 ff ff       	call   f01011b0 <page_insert>
	assert(pp1->pp_ref == 1);
f0102af1:	83 c4 20             	add    $0x20,%esp
f0102af4:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102af9:	74 19                	je     f0102b14 <mem_init+0x1884>
f0102afb:	68 88 78 10 f0       	push   $0xf0107888
f0102b00:	68 c3 76 10 f0       	push   $0xf01076c3
f0102b05:	68 8b 04 00 00       	push   $0x48b
f0102b0a:	68 9d 76 10 f0       	push   $0xf010769d
f0102b0f:	e8 2c d5 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b14:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b1b:	01 01 01 
f0102b1e:	74 19                	je     f0102b39 <mem_init+0x18a9>
f0102b20:	68 c8 75 10 f0       	push   $0xf01075c8
f0102b25:	68 c3 76 10 f0       	push   $0xf01076c3
f0102b2a:	68 8c 04 00 00       	push   $0x48c
f0102b2f:	68 9d 76 10 f0       	push   $0xf010769d
f0102b34:	e8 07 d5 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b39:	6a 02                	push   $0x2
f0102b3b:	68 00 10 00 00       	push   $0x1000
f0102b40:	56                   	push   %esi
f0102b41:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f0102b47:	e8 64 e6 ff ff       	call   f01011b0 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b4c:	83 c4 10             	add    $0x10,%esp
f0102b4f:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b56:	02 02 02 
f0102b59:	74 19                	je     f0102b74 <mem_init+0x18e4>
f0102b5b:	68 ec 75 10 f0       	push   $0xf01075ec
f0102b60:	68 c3 76 10 f0       	push   $0xf01076c3
f0102b65:	68 8e 04 00 00       	push   $0x48e
f0102b6a:	68 9d 76 10 f0       	push   $0xf010769d
f0102b6f:	e8 cc d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102b74:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102b79:	74 19                	je     f0102b94 <mem_init+0x1904>
f0102b7b:	68 aa 78 10 f0       	push   $0xf01078aa
f0102b80:	68 c3 76 10 f0       	push   $0xf01076c3
f0102b85:	68 8f 04 00 00       	push   $0x48f
f0102b8a:	68 9d 76 10 f0       	push   $0xf010769d
f0102b8f:	e8 ac d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102b94:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102b99:	74 19                	je     f0102bb4 <mem_init+0x1924>
f0102b9b:	68 14 79 10 f0       	push   $0xf0107914
f0102ba0:	68 c3 76 10 f0       	push   $0xf01076c3
f0102ba5:	68 90 04 00 00       	push   $0x490
f0102baa:	68 9d 76 10 f0       	push   $0xf010769d
f0102baf:	e8 8c d4 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102bb4:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102bbb:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bbe:	89 f0                	mov    %esi,%eax
f0102bc0:	2b 05 a8 fe 25 f0    	sub    0xf025fea8,%eax
f0102bc6:	c1 f8 03             	sar    $0x3,%eax
f0102bc9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bcc:	89 c2                	mov    %eax,%edx
f0102bce:	c1 ea 0c             	shr    $0xc,%edx
f0102bd1:	3b 15 a0 fe 25 f0    	cmp    0xf025fea0,%edx
f0102bd7:	72 12                	jb     f0102beb <mem_init+0x195b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bd9:	50                   	push   %eax
f0102bda:	68 64 67 10 f0       	push   $0xf0106764
f0102bdf:	6a 58                	push   $0x58
f0102be1:	68 a9 76 10 f0       	push   $0xf01076a9
f0102be6:	e8 55 d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102beb:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102bf2:	03 03 03 
f0102bf5:	74 19                	je     f0102c10 <mem_init+0x1980>
f0102bf7:	68 10 76 10 f0       	push   $0xf0107610
f0102bfc:	68 c3 76 10 f0       	push   $0xf01076c3
f0102c01:	68 92 04 00 00       	push   $0x492
f0102c06:	68 9d 76 10 f0       	push   $0xf010769d
f0102c0b:	e8 30 d4 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c10:	83 ec 08             	sub    $0x8,%esp
f0102c13:	68 00 10 00 00       	push   $0x1000
f0102c18:	ff 35 a4 fe 25 f0    	pushl  0xf025fea4
f0102c1e:	e8 52 e5 ff ff       	call   f0101175 <page_remove>
	assert(pp2->pp_ref == 0);
f0102c23:	83 c4 10             	add    $0x10,%esp
f0102c26:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c2b:	74 19                	je     f0102c46 <mem_init+0x19b6>
f0102c2d:	68 e2 78 10 f0       	push   $0xf01078e2
f0102c32:	68 c3 76 10 f0       	push   $0xf01076c3
f0102c37:	68 94 04 00 00       	push   $0x494
f0102c3c:	68 9d 76 10 f0       	push   $0xf010769d
f0102c41:	e8 fa d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c46:	8b 0d a4 fe 25 f0    	mov    0xf025fea4,%ecx
f0102c4c:	8b 11                	mov    (%ecx),%edx
f0102c4e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102c54:	89 d8                	mov    %ebx,%eax
f0102c56:	2b 05 a8 fe 25 f0    	sub    0xf025fea8,%eax
f0102c5c:	c1 f8 03             	sar    $0x3,%eax
f0102c5f:	c1 e0 0c             	shl    $0xc,%eax
f0102c62:	39 c2                	cmp    %eax,%edx
f0102c64:	74 19                	je     f0102c7f <mem_init+0x19ef>
f0102c66:	68 98 6f 10 f0       	push   $0xf0106f98
f0102c6b:	68 c3 76 10 f0       	push   $0xf01076c3
f0102c70:	68 97 04 00 00       	push   $0x497
f0102c75:	68 9d 76 10 f0       	push   $0xf010769d
f0102c7a:	e8 c1 d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102c7f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102c85:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102c8a:	74 19                	je     f0102ca5 <mem_init+0x1a15>
f0102c8c:	68 99 78 10 f0       	push   $0xf0107899
f0102c91:	68 c3 76 10 f0       	push   $0xf01076c3
f0102c96:	68 99 04 00 00       	push   $0x499
f0102c9b:	68 9d 76 10 f0       	push   $0xf010769d
f0102ca0:	e8 9b d3 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102ca5:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102cab:	83 ec 0c             	sub    $0xc,%esp
f0102cae:	53                   	push   %ebx
f0102caf:	e8 e3 e2 ff ff       	call   f0100f97 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102cb4:	c7 04 24 3c 76 10 f0 	movl   $0xf010763c,(%esp)
f0102cbb:	e8 24 0a 00 00       	call   f01036e4 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102cc0:	83 c4 10             	add    $0x10,%esp
f0102cc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cc6:	5b                   	pop    %ebx
f0102cc7:	5e                   	pop    %esi
f0102cc8:	5f                   	pop    %edi
f0102cc9:	5d                   	pop    %ebp
f0102cca:	c3                   	ret    

f0102ccb <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102ccb:	55                   	push   %ebp
f0102ccc:	89 e5                	mov    %esp,%ebp
f0102cce:	57                   	push   %edi
f0102ccf:	56                   	push   %esi
f0102cd0:	53                   	push   %ebx
f0102cd1:	83 ec 1c             	sub    $0x1c,%esp
f0102cd4:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102cd7:	8b 45 0c             	mov    0xc(%ebp),%eax
	// LAB 3: Your code here.
	uintptr_t mem_start = (uintptr_t) va;
f0102cda:	89 c3                	mov    %eax,%ebx
	
	uintptr_t mem_end = (uintptr_t) ROUNDUP(((uintptr_t) va + len), PGSIZE);
f0102cdc:	8b 55 10             	mov    0x10(%ebp),%edx
f0102cdf:	8d 84 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%eax
f0102ce6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102ceb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	
	perm = perm | PTE_P ;
f0102cee:	8b 75 14             	mov    0x14(%ebp),%esi
f0102cf1:	83 ce 01             	or     $0x1,%esi
	
	uintptr_t i;
				
	while(mem_start < mem_end){
f0102cf4:	eb 4b                	jmp    f0102d41 <user_mem_check+0x76>
		
		if ((uint32_t)mem_start >= ULIM){
f0102cf6:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102cfc:	76 0d                	jbe    f0102d0b <user_mem_check+0x40>
		
			user_mem_check_addr = (uintptr_t) mem_start;
f0102cfe:	89 1d 3c f2 25 f0    	mov    %ebx,0xf025f23c
			return -E_FAULT;
f0102d04:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d09:	eb 40                	jmp    f0102d4b <user_mem_check+0x80>
		}		
		
		pte_t * pte = pgdir_walk(env->env_pgdir, (void *) mem_start, 0);
f0102d0b:	83 ec 04             	sub    $0x4,%esp
f0102d0e:	6a 00                	push   $0x0
f0102d10:	53                   	push   %ebx
f0102d11:	ff 77 60             	pushl  0x60(%edi)
f0102d14:	e8 e0 e2 ff ff       	call   f0100ff9 <pgdir_walk>
				
		if (pte == NULL || (((uint32_t) *pte & perm)!=perm)){
f0102d19:	83 c4 10             	add    $0x10,%esp
f0102d1c:	85 c0                	test   %eax,%eax
f0102d1e:	74 08                	je     f0102d28 <user_mem_check+0x5d>
f0102d20:	89 f1                	mov    %esi,%ecx
f0102d22:	23 08                	and    (%eax),%ecx
f0102d24:	39 ce                	cmp    %ecx,%esi
f0102d26:	74 0d                	je     f0102d35 <user_mem_check+0x6a>
			
			user_mem_check_addr = (uintptr_t) mem_start;
f0102d28:	89 1d 3c f2 25 f0    	mov    %ebx,0xf025f23c
			return -E_FAULT;	
f0102d2e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d33:	eb 16                	jmp    f0102d4b <user_mem_check+0x80>
		
		}
		mem_start = (uintptr_t) ROUNDDOWN((uintptr_t) mem_start, PGSIZE);
f0102d35:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		mem_start += PGSIZE;	
f0102d3b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	
	perm = perm | PTE_P ;
	
	uintptr_t i;
				
	while(mem_start < mem_end){
f0102d41:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102d44:	72 b0                	jb     f0102cf6 <user_mem_check+0x2b>
		}
		mem_start = (uintptr_t) ROUNDDOWN((uintptr_t) mem_start, PGSIZE);
		mem_start += PGSIZE;	
	}

	return 0;
f0102d46:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d4e:	5b                   	pop    %ebx
f0102d4f:	5e                   	pop    %esi
f0102d50:	5f                   	pop    %edi
f0102d51:	5d                   	pop    %ebp
f0102d52:	c3                   	ret    

f0102d53 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102d53:	55                   	push   %ebp
f0102d54:	89 e5                	mov    %esp,%ebp
f0102d56:	53                   	push   %ebx
f0102d57:	83 ec 04             	sub    $0x4,%esp
f0102d5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
//	cprintf("SRHS: va passed to mem_assert is %08x \n",va);
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102d5d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d60:	83 c8 04             	or     $0x4,%eax
f0102d63:	50                   	push   %eax
f0102d64:	ff 75 10             	pushl  0x10(%ebp)
f0102d67:	ff 75 0c             	pushl  0xc(%ebp)
f0102d6a:	53                   	push   %ebx
f0102d6b:	e8 5b ff ff ff       	call   f0102ccb <user_mem_check>
f0102d70:	83 c4 10             	add    $0x10,%esp
f0102d73:	85 c0                	test   %eax,%eax
f0102d75:	79 21                	jns    f0102d98 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102d77:	83 ec 04             	sub    $0x4,%esp
f0102d7a:	ff 35 3c f2 25 f0    	pushl  0xf025f23c
f0102d80:	ff 73 48             	pushl  0x48(%ebx)
f0102d83:	68 68 76 10 f0       	push   $0xf0107668
f0102d88:	e8 57 09 00 00       	call   f01036e4 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102d8d:	89 1c 24             	mov    %ebx,(%esp)
f0102d90:	e8 42 06 00 00       	call   f01033d7 <env_destroy>
f0102d95:	83 c4 10             	add    $0x10,%esp
	}
}
f0102d98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102d9b:	c9                   	leave  
f0102d9c:	c3                   	ret    

f0102d9d <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102d9d:	55                   	push   %ebp
f0102d9e:	89 e5                	mov    %esp,%ebp
f0102da0:	57                   	push   %edi
f0102da1:	56                   	push   %esi
f0102da2:	53                   	push   %ebx
f0102da3:	83 ec 0c             	sub    $0xc,%esp
f0102da6:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)
	
	void *region_alloc_start = (void *) ROUNDDOWN((uint32_t) va, PGSIZE);
f0102da8:	89 d3                	mov    %edx,%ebx
f0102daa:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	void *region_alloc_end = (void *) ROUNDUP(((uint32_t) va + len), PGSIZE);
f0102db0:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0102db7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102dbc:	89 c6                	mov    %eax,%esi
	
	if ((uint32_t)region_alloc_end > UTOP)
f0102dbe:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f0102dc3:	76 6d                	jbe    f0102e32 <region_alloc+0x95>
		panic("region_alloc failed: Cannot allocate memory above UTOP");
f0102dc5:	83 ec 04             	sub    $0x4,%esp
f0102dc8:	68 b0 79 10 f0       	push   $0xf01079b0
f0102dcd:	68 31 01 00 00       	push   $0x131
f0102dd2:	68 94 7a 10 f0       	push   $0xf0107a94
f0102dd7:	e8 64 d2 ff ff       	call   f0100040 <_panic>
	//for(region_alloc_start; region_alloc_start < region_alloc_end; region_alloc_start += PGSIZE){
	struct PageInfo *page;
	
	while(region_alloc_start < region_alloc_end){
	
		page = page_alloc(0);
f0102ddc:	83 ec 0c             	sub    $0xc,%esp
f0102ddf:	6a 00                	push   $0x0
f0102de1:	e8 41 e1 ff ff       	call   f0100f27 <page_alloc>
		
		if (page == NULL) 
f0102de6:	83 c4 10             	add    $0x10,%esp
f0102de9:	85 c0                	test   %eax,%eax
f0102deb:	75 17                	jne    f0102e04 <region_alloc+0x67>
			panic("region_alloc failed: Allocation failed!");
f0102ded:	83 ec 04             	sub    $0x4,%esp
f0102df0:	68 e8 79 10 f0       	push   $0xf01079e8
f0102df5:	68 3b 01 00 00       	push   $0x13b
f0102dfa:	68 94 7a 10 f0       	push   $0xf0107a94
f0102dff:	e8 3c d2 ff ff       	call   f0100040 <_panic>
	
		int r = page_insert(e->env_pgdir, page, region_alloc_start, (PTE_W | PTE_U));	
f0102e04:	6a 06                	push   $0x6
f0102e06:	53                   	push   %ebx
f0102e07:	50                   	push   %eax
f0102e08:	ff 77 60             	pushl  0x60(%edi)
f0102e0b:	e8 a0 e3 ff ff       	call   f01011b0 <page_insert>
		
		if(r != 0)
f0102e10:	83 c4 10             	add    $0x10,%esp
f0102e13:	85 c0                	test   %eax,%eax
f0102e15:	74 15                	je     f0102e2c <region_alloc+0x8f>
			panic("region_alloc: %e", r);
f0102e17:	50                   	push   %eax
f0102e18:	68 9f 7a 10 f0       	push   $0xf0107a9f
f0102e1d:	68 40 01 00 00       	push   $0x140
f0102e22:	68 94 7a 10 f0       	push   $0xf0107a94
f0102e27:	e8 14 d2 ff ff       	call   f0100040 <_panic>
	
		region_alloc_start += PGSIZE;
f0102e2c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		panic("region_alloc failed: Cannot allocate memory above UTOP");
	
	//for(region_alloc_start; region_alloc_start < region_alloc_end; region_alloc_start += PGSIZE){
	struct PageInfo *page;
	
	while(region_alloc_start < region_alloc_end){
f0102e32:	39 f3                	cmp    %esi,%ebx
f0102e34:	72 a6                	jb     f0102ddc <region_alloc+0x3f>
	
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102e36:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e39:	5b                   	pop    %ebx
f0102e3a:	5e                   	pop    %esi
f0102e3b:	5f                   	pop    %edi
f0102e3c:	5d                   	pop    %ebp
f0102e3d:	c3                   	ret    

f0102e3e <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e3e:	55                   	push   %ebp
f0102e3f:	89 e5                	mov    %esp,%ebp
f0102e41:	56                   	push   %esi
f0102e42:	53                   	push   %ebx
f0102e43:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e46:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e49:	85 c0                	test   %eax,%eax
f0102e4b:	75 1a                	jne    f0102e67 <envid2env+0x29>
		*env_store = curenv;
f0102e4d:	e8 f8 2c 00 00       	call   f0105b4a <cpunum>
f0102e52:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e55:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f0102e5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e5e:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102e60:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e65:	eb 70                	jmp    f0102ed7 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102e67:	89 c3                	mov    %eax,%ebx
f0102e69:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102e6f:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102e72:	03 1d 48 f2 25 f0    	add    0xf025f248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102e78:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102e7c:	74 05                	je     f0102e83 <envid2env+0x45>
f0102e7e:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102e81:	74 10                	je     f0102e93 <envid2env+0x55>
		*env_store = 0;
f0102e83:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e86:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102e8c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e91:	eb 44                	jmp    f0102ed7 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102e93:	84 d2                	test   %dl,%dl
f0102e95:	74 36                	je     f0102ecd <envid2env+0x8f>
f0102e97:	e8 ae 2c 00 00       	call   f0105b4a <cpunum>
f0102e9c:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e9f:	3b 98 28 00 26 f0    	cmp    -0xfd9ffd8(%eax),%ebx
f0102ea5:	74 26                	je     f0102ecd <envid2env+0x8f>
f0102ea7:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102eaa:	e8 9b 2c 00 00       	call   f0105b4a <cpunum>
f0102eaf:	6b c0 74             	imul   $0x74,%eax,%eax
f0102eb2:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f0102eb8:	3b 70 48             	cmp    0x48(%eax),%esi
f0102ebb:	74 10                	je     f0102ecd <envid2env+0x8f>
		*env_store = 0;
f0102ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ec0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ec6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ecb:	eb 0a                	jmp    f0102ed7 <envid2env+0x99>
	}

	*env_store = e;
f0102ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ed0:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102ed2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ed7:	5b                   	pop    %ebx
f0102ed8:	5e                   	pop    %esi
f0102ed9:	5d                   	pop    %ebp
f0102eda:	c3                   	ret    

f0102edb <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102edb:	55                   	push   %ebp
f0102edc:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102ede:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f0102ee3:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102ee6:	b8 23 00 00 00       	mov    $0x23,%eax
f0102eeb:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102eed:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102eef:	b8 10 00 00 00       	mov    $0x10,%eax
f0102ef4:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102ef6:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102ef8:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102efa:	ea 01 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f01
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102f01:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f06:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f09:	5d                   	pop    %ebp
f0102f0a:	c3                   	ret    

f0102f0b <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102f0b:	55                   	push   %ebp
f0102f0c:	89 e5                	mov    %esp,%ebp
f0102f0e:	56                   	push   %esi
f0102f0f:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = NULL;
f0102f10:	c7 05 4c f2 25 f0 00 	movl   $0x0,0xf025f24c
f0102f17:	00 00 00 
	int i;
	
	cprintf("PDX(UTOP) %u\n", PDX(UTOP) );
f0102f1a:	83 ec 08             	sub    $0x8,%esp
f0102f1d:	68 bb 03 00 00       	push   $0x3bb
f0102f22:	68 b0 7a 10 f0       	push   $0xf0107ab0
f0102f27:	e8 b8 07 00 00       	call   f01036e4 <cprintf>
	for (i = (NENV - 1); i >= 0; --i){
	
		envs[i].env_status = ENV_FREE;
f0102f2c:	8b 35 48 f2 25 f0    	mov    0xf025f248,%esi
f0102f32:	8b 15 4c f2 25 f0    	mov    0xf025f24c,%edx
f0102f38:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102f3e:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102f41:	83 c4 10             	add    $0x10,%esp
f0102f44:	89 c1                	mov    %eax,%ecx
f0102f46:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0102f4d:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102f54:	89 50 44             	mov    %edx,0x44(%eax)
f0102f57:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0102f5a:	89 ca                	mov    %ecx,%edx
	// LAB 3: Your code here.
	env_free_list = NULL;
	int i;
	
	cprintf("PDX(UTOP) %u\n", PDX(UTOP) );
	for (i = (NENV - 1); i >= 0; --i){
f0102f5c:	39 d8                	cmp    %ebx,%eax
f0102f5e:	75 e4                	jne    f0102f44 <env_init+0x39>
f0102f60:	89 35 4c f2 25 f0    	mov    %esi,0xf025f24c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102f66:	e8 70 ff ff ff       	call   f0102edb <env_init_percpu>
}
f0102f6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102f6e:	5b                   	pop    %ebx
f0102f6f:	5e                   	pop    %esi
f0102f70:	5d                   	pop    %ebp
f0102f71:	c3                   	ret    

f0102f72 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f72:	55                   	push   %ebp
f0102f73:	89 e5                	mov    %esp,%ebp
f0102f75:	53                   	push   %ebx
f0102f76:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102f79:	8b 1d 4c f2 25 f0    	mov    0xf025f24c,%ebx
f0102f7f:	85 db                	test   %ebx,%ebx
f0102f81:	0f 84 48 01 00 00    	je     f01030cf <env_alloc+0x15d>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102f87:	83 ec 0c             	sub    $0xc,%esp
f0102f8a:	6a 01                	push   $0x1
f0102f8c:	e8 96 df ff ff       	call   f0100f27 <page_alloc>
f0102f91:	83 c4 10             	add    $0x10,%esp
f0102f94:	85 c0                	test   %eax,%eax
f0102f96:	0f 84 3a 01 00 00    	je     f01030d6 <env_alloc+0x164>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0102f9c:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102fa1:	2b 05 a8 fe 25 f0    	sub    0xf025fea8,%eax
f0102fa7:	c1 f8 03             	sar    $0x3,%eax
f0102faa:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102fad:	89 c2                	mov    %eax,%edx
f0102faf:	c1 ea 0c             	shr    $0xc,%edx
f0102fb2:	3b 15 a0 fe 25 f0    	cmp    0xf025fea0,%edx
f0102fb8:	72 12                	jb     f0102fcc <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102fba:	50                   	push   %eax
f0102fbb:	68 64 67 10 f0       	push   $0xf0106764
f0102fc0:	6a 58                	push   $0x58
f0102fc2:	68 a9 76 10 f0       	push   $0xf01076a9
f0102fc7:	e8 74 d0 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = (pde_t *) page2kva(p);
f0102fcc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102fd1:	89 43 60             	mov    %eax,0x60(%ebx)
f0102fd4:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (i = 0; i < PDX(UTOP); i++)
	{
		e->env_pgdir[i]= 0;
f0102fd9:	8b 53 60             	mov    0x60(%ebx),%edx
f0102fdc:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f0102fe3:	83 c0 04             	add    $0x4,%eax

	// LAB 3: Your code here.
	p->pp_ref++;
	e->env_pgdir = (pde_t *) page2kva(p);
	
	for (i = 0; i < PDX(UTOP); i++)
f0102fe6:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0102feb:	75 ec                	jne    f0102fd9 <env_alloc+0x67>
	{
		e->env_pgdir[i]= 0;
	}
	for (i = PDX(UTOP) ;  i < NPDENTRIES; i++ )
	{
		e->env_pgdir[i] = kern_pgdir[i];
f0102fed:	8b 15 a4 fe 25 f0    	mov    0xf025fea4,%edx
f0102ff3:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0102ff6:	8b 53 60             	mov    0x60(%ebx),%edx
f0102ff9:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0102ffc:	83 c0 04             	add    $0x4,%eax
	
	for (i = 0; i < PDX(UTOP); i++)
	{
		e->env_pgdir[i]= 0;
	}
	for (i = PDX(UTOP) ;  i < NPDENTRIES; i++ )
f0102fff:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103004:	75 e7                	jne    f0102fed <env_alloc+0x7b>
		e->env_pgdir[i] = kern_pgdir[i];
	}
		
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103006:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103009:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010300e:	77 15                	ja     f0103025 <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103010:	50                   	push   %eax
f0103011:	68 88 67 10 f0       	push   $0xf0106788
f0103016:	68 d2 00 00 00       	push   $0xd2
f010301b:	68 94 7a 10 f0       	push   $0xf0107a94
f0103020:	e8 1b d0 ff ff       	call   f0100040 <_panic>
f0103025:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010302b:	83 ca 05             	or     $0x5,%edx
f010302e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103034:	8b 43 48             	mov    0x48(%ebx),%eax
f0103037:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010303c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103041:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103046:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103049:	89 da                	mov    %ebx,%edx
f010304b:	2b 15 48 f2 25 f0    	sub    0xf025f248,%edx
f0103051:	c1 fa 02             	sar    $0x2,%edx
f0103054:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010305a:	09 d0                	or     %edx,%eax
f010305c:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010305f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103062:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103065:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010306c:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103073:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010307a:	83 ec 04             	sub    $0x4,%esp
f010307d:	6a 44                	push   $0x44
f010307f:	6a 00                	push   $0x0
f0103081:	53                   	push   %ebx
f0103082:	e8 a3 24 00 00       	call   f010552a <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103087:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010308d:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103093:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103099:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01030a0:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f01030a6:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01030ad:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01030b4:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01030b8:	8b 43 44             	mov    0x44(%ebx),%eax
f01030bb:	a3 4c f2 25 f0       	mov    %eax,0xf025f24c
	*newenv_store = e;
f01030c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01030c3:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f01030c5:	83 c4 10             	add    $0x10,%esp
f01030c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01030cd:	eb 0c                	jmp    f01030db <env_alloc+0x169>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01030cf:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01030d4:	eb 05                	jmp    f01030db <env_alloc+0x169>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01030d6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01030db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01030de:	c9                   	leave  
f01030df:	c3                   	ret    

f01030e0 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01030e0:	55                   	push   %ebp
f01030e1:	89 e5                	mov    %esp,%ebp
f01030e3:	57                   	push   %edi
f01030e4:	56                   	push   %esi
f01030e5:	53                   	push   %ebx
f01030e6:	83 ec 34             	sub    $0x34,%esp
f01030e9:	8b 7d 08             	mov    0x8(%ebp),%edi
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.

	struct Env *e;
	
	int r = env_alloc(&e, (envid_t) 0);
f01030ec:	6a 00                	push   $0x0
f01030ee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01030f1:	50                   	push   %eax
f01030f2:	e8 7b fe ff ff       	call   f0102f72 <env_alloc>
	
	if(r != 0) {
f01030f7:	83 c4 10             	add    $0x10,%esp
f01030fa:	85 c0                	test   %eax,%eax
f01030fc:	74 15                	je     f0103113 <env_create+0x33>
		panic("env_alloc failed: env_create failed %e\n", r);
f01030fe:	50                   	push   %eax
f01030ff:	68 10 7a 10 f0       	push   $0xf0107a10
f0103104:	68 c6 01 00 00       	push   $0x1c6
f0103109:	68 94 7a 10 f0       	push   $0xf0107a94
f010310e:	e8 2d cf ff ff       	call   f0100040 <_panic>
	}
	
	load_icode(e,binary);
f0103113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103116:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Elf * elfHeader = (struct Elf *) binary;

	struct Proghdr *ph, *eph;

	// is this a valid ELF?
	if (elfHeader->e_magic != ELF_MAGIC)
f0103119:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010311f:	74 17                	je     f0103138 <env_create+0x58>
		panic("load_icode failed: Not a valid ELF file!");
f0103121:	83 ec 04             	sub    $0x4,%esp
f0103124:	68 38 7a 10 f0       	push   $0xf0107a38
f0103129:	68 88 01 00 00       	push   $0x188
f010312e:	68 94 7a 10 f0       	push   $0xf0107a94
f0103133:	e8 08 cf ff ff       	call   f0100040 <_panic>
	
	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) elfHeader + elfHeader->e_phoff);
f0103138:	89 fb                	mov    %edi,%ebx
f010313a:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elfHeader->e_phnum;
f010313d:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103141:	c1 e6 05             	shl    $0x5,%esi
f0103144:	01 de                	add    %ebx,%esi
	
	lcr3(PADDR(e->env_pgdir));
f0103146:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103149:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010314c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103151:	77 15                	ja     f0103168 <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103153:	50                   	push   %eax
f0103154:	68 88 67 10 f0       	push   $0xf0106788
f0103159:	68 8e 01 00 00       	push   $0x18e
f010315e:	68 94 7a 10 f0       	push   $0xf0107a94
f0103163:	e8 d8 ce ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103168:	05 00 00 00 10       	add    $0x10000000,%eax
f010316d:	0f 22 d8             	mov    %eax,%cr3
f0103170:	eb 5b                	jmp    f01031cd <env_create+0xed>
	
	for (; ph < eph; ph++)
	{
		// p_pa is the load address of this segment (as well
		// as the physical address)
		if (ph->p_type == ELF_PROG_LOAD)
f0103172:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103175:	75 53                	jne    f01031ca <env_create+0xea>
		{
			if(ph->p_filesz <= ph->p_memsz){
f0103177:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010317a:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f010317d:	77 34                	ja     f01031b3 <env_create+0xd3>
			
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010317f:	8b 53 08             	mov    0x8(%ebx),%edx
f0103182:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103185:	e8 13 fc ff ff       	call   f0102d9d <region_alloc>
			memset((void *) ph->p_va, 0, ph->p_memsz);
f010318a:	83 ec 04             	sub    $0x4,%esp
f010318d:	ff 73 14             	pushl  0x14(%ebx)
f0103190:	6a 00                	push   $0x0
f0103192:	ff 73 08             	pushl  0x8(%ebx)
f0103195:	e8 90 23 00 00       	call   f010552a <memset>
			memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010319a:	83 c4 0c             	add    $0xc,%esp
f010319d:	ff 73 10             	pushl  0x10(%ebx)
f01031a0:	89 f8                	mov    %edi,%eax
f01031a2:	03 43 04             	add    0x4(%ebx),%eax
f01031a5:	50                   	push   %eax
f01031a6:	ff 73 08             	pushl  0x8(%ebx)
f01031a9:	e8 c9 23 00 00       	call   f0105577 <memmove>
f01031ae:	83 c4 10             	add    $0x10,%esp
f01031b1:	eb 17                	jmp    f01031ca <env_create+0xea>
			}
			
			else
				panic("load_icode failed: filesz is greater than memsz");
f01031b3:	83 ec 04             	sub    $0x4,%esp
f01031b6:	68 64 7a 10 f0       	push   $0xf0107a64
f01031bb:	68 9e 01 00 00       	push   $0x19e
f01031c0:	68 94 7a 10 f0       	push   $0xf0107a94
f01031c5:	e8 76 ce ff ff       	call   f0100040 <_panic>
	ph = (struct Proghdr *) ((uint8_t *) elfHeader + elfHeader->e_phoff);
	eph = ph + elfHeader->e_phnum;
	
	lcr3(PADDR(e->env_pgdir));
	
	for (; ph < eph; ph++)
f01031ca:	83 c3 20             	add    $0x20,%ebx
f01031cd:	39 de                	cmp    %ebx,%esi
f01031cf:	77 a1                	ja     f0103172 <env_create+0x92>
				panic("load_icode failed: filesz is greater than memsz");
				
		}
	}
	
	e->env_tf.tf_eip = elfHeader->e_entry;
f01031d1:	8b 47 18             	mov    0x18(%edi),%eax
f01031d4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01031d7:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f01031da:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01031df:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01031e4:	89 f8                	mov    %edi,%eax
f01031e6:	e8 b2 fb ff ff       	call   f0102d9d <region_alloc>
	
	lcr3(PADDR(kern_pgdir));
f01031eb:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031f0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031f5:	77 15                	ja     f010320c <env_create+0x12c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031f7:	50                   	push   %eax
f01031f8:	68 88 67 10 f0       	push   $0xf0106788
f01031fd:	68 ae 01 00 00       	push   $0x1ae
f0103202:	68 94 7a 10 f0       	push   $0xf0107a94
f0103207:	e8 34 ce ff ff       	call   f0100040 <_panic>
f010320c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103211:	0f 22 d8             	mov    %eax,%cr3
	if(r != 0) {
		panic("env_alloc failed: env_create failed %e\n", r);
	}
	
	load_icode(e,binary);
	e->env_type = type;
f0103214:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103217:	8b 55 0c             	mov    0xc(%ebp),%edx
f010321a:	89 50 50             	mov    %edx,0x50(%eax)
	
	if (type == ENV_TYPE_FS) {
f010321d:	83 fa 01             	cmp    $0x1,%edx
f0103220:	75 07                	jne    f0103229 <env_create+0x149>
        	e->env_tf.tf_eflags |= FL_IOPL_3;
f0103222:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
        }

}
f0103229:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010322c:	5b                   	pop    %ebx
f010322d:	5e                   	pop    %esi
f010322e:	5f                   	pop    %edi
f010322f:	5d                   	pop    %ebp
f0103230:	c3                   	ret    

f0103231 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103231:	55                   	push   %ebp
f0103232:	89 e5                	mov    %esp,%ebp
f0103234:	57                   	push   %edi
f0103235:	56                   	push   %esi
f0103236:	53                   	push   %ebx
f0103237:	83 ec 1c             	sub    $0x1c,%esp
f010323a:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010323d:	e8 08 29 00 00       	call   f0105b4a <cpunum>
f0103242:	6b c0 74             	imul   $0x74,%eax,%eax
f0103245:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010324c:	39 b8 28 00 26 f0    	cmp    %edi,-0xfd9ffd8(%eax)
f0103252:	75 30                	jne    f0103284 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f0103254:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103259:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010325e:	77 15                	ja     f0103275 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103260:	50                   	push   %eax
f0103261:	68 88 67 10 f0       	push   $0xf0106788
f0103266:	68 e1 01 00 00       	push   $0x1e1
f010326b:	68 94 7a 10 f0       	push   $0xf0107a94
f0103270:	e8 cb cd ff ff       	call   f0100040 <_panic>
f0103275:	05 00 00 00 10       	add    $0x10000000,%eax
f010327a:	0f 22 d8             	mov    %eax,%cr3
f010327d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103284:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103287:	89 d0                	mov    %edx,%eax
f0103289:	c1 e0 02             	shl    $0x2,%eax
f010328c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010328f:	8b 47 60             	mov    0x60(%edi),%eax
f0103292:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103295:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010329b:	0f 84 a8 00 00 00    	je     f0103349 <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01032a1:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032a7:	89 f0                	mov    %esi,%eax
f01032a9:	c1 e8 0c             	shr    $0xc,%eax
f01032ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01032af:	39 05 a0 fe 25 f0    	cmp    %eax,0xf025fea0
f01032b5:	77 15                	ja     f01032cc <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032b7:	56                   	push   %esi
f01032b8:	68 64 67 10 f0       	push   $0xf0106764
f01032bd:	68 f0 01 00 00       	push   $0x1f0
f01032c2:	68 94 7a 10 f0       	push   $0xf0107a94
f01032c7:	e8 74 cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032cf:	c1 e0 16             	shl    $0x16,%eax
f01032d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032d5:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01032da:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01032e1:	01 
f01032e2:	74 17                	je     f01032fb <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032e4:	83 ec 08             	sub    $0x8,%esp
f01032e7:	89 d8                	mov    %ebx,%eax
f01032e9:	c1 e0 0c             	shl    $0xc,%eax
f01032ec:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01032ef:	50                   	push   %eax
f01032f0:	ff 77 60             	pushl  0x60(%edi)
f01032f3:	e8 7d de ff ff       	call   f0101175 <page_remove>
f01032f8:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032fb:	83 c3 01             	add    $0x1,%ebx
f01032fe:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103304:	75 d4                	jne    f01032da <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103306:	8b 47 60             	mov    0x60(%edi),%eax
f0103309:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010330c:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103313:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103316:	3b 05 a0 fe 25 f0    	cmp    0xf025fea0,%eax
f010331c:	72 14                	jb     f0103332 <env_free+0x101>
		panic("pa2page called with invalid pa");
f010331e:	83 ec 04             	sub    $0x4,%esp
f0103321:	68 40 6e 10 f0       	push   $0xf0106e40
f0103326:	6a 51                	push   $0x51
f0103328:	68 a9 76 10 f0       	push   $0xf01076a9
f010332d:	e8 0e cd ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0103332:	83 ec 0c             	sub    $0xc,%esp
f0103335:	a1 a8 fe 25 f0       	mov    0xf025fea8,%eax
f010333a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010333d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103340:	50                   	push   %eax
f0103341:	e8 8c dc ff ff       	call   f0100fd2 <page_decref>
f0103346:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103349:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010334d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103350:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103355:	0f 85 29 ff ff ff    	jne    f0103284 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010335b:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010335e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103363:	77 15                	ja     f010337a <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103365:	50                   	push   %eax
f0103366:	68 88 67 10 f0       	push   $0xf0106788
f010336b:	68 fe 01 00 00       	push   $0x1fe
f0103370:	68 94 7a 10 f0       	push   $0xf0107a94
f0103375:	e8 c6 cc ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f010337a:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103381:	05 00 00 00 10       	add    $0x10000000,%eax
f0103386:	c1 e8 0c             	shr    $0xc,%eax
f0103389:	3b 05 a0 fe 25 f0    	cmp    0xf025fea0,%eax
f010338f:	72 14                	jb     f01033a5 <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103391:	83 ec 04             	sub    $0x4,%esp
f0103394:	68 40 6e 10 f0       	push   $0xf0106e40
f0103399:	6a 51                	push   $0x51
f010339b:	68 a9 76 10 f0       	push   $0xf01076a9
f01033a0:	e8 9b cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f01033a5:	83 ec 0c             	sub    $0xc,%esp
f01033a8:	8b 15 a8 fe 25 f0    	mov    0xf025fea8,%edx
f01033ae:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01033b1:	50                   	push   %eax
f01033b2:	e8 1b dc ff ff       	call   f0100fd2 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01033b7:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01033be:	a1 4c f2 25 f0       	mov    0xf025f24c,%eax
f01033c3:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01033c6:	89 3d 4c f2 25 f0    	mov    %edi,0xf025f24c
}
f01033cc:	83 c4 10             	add    $0x10,%esp
f01033cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033d2:	5b                   	pop    %ebx
f01033d3:	5e                   	pop    %esi
f01033d4:	5f                   	pop    %edi
f01033d5:	5d                   	pop    %ebp
f01033d6:	c3                   	ret    

f01033d7 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01033d7:	55                   	push   %ebp
f01033d8:	89 e5                	mov    %esp,%ebp
f01033da:	53                   	push   %ebx
f01033db:	83 ec 04             	sub    $0x4,%esp
f01033de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01033e1:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01033e5:	75 19                	jne    f0103400 <env_destroy+0x29>
f01033e7:	e8 5e 27 00 00       	call   f0105b4a <cpunum>
f01033ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01033ef:	3b 98 28 00 26 f0    	cmp    -0xfd9ffd8(%eax),%ebx
f01033f5:	74 09                	je     f0103400 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01033f7:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01033fe:	eb 33                	jmp    f0103433 <env_destroy+0x5c>
	}

	env_free(e);
f0103400:	83 ec 0c             	sub    $0xc,%esp
f0103403:	53                   	push   %ebx
f0103404:	e8 28 fe ff ff       	call   f0103231 <env_free>

	if (curenv == e) {
f0103409:	e8 3c 27 00 00       	call   f0105b4a <cpunum>
f010340e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103411:	83 c4 10             	add    $0x10,%esp
f0103414:	3b 98 28 00 26 f0    	cmp    -0xfd9ffd8(%eax),%ebx
f010341a:	75 17                	jne    f0103433 <env_destroy+0x5c>
		curenv = NULL;
f010341c:	e8 29 27 00 00       	call   f0105b4a <cpunum>
f0103421:	6b c0 74             	imul   $0x74,%eax,%eax
f0103424:	c7 80 28 00 26 f0 00 	movl   $0x0,-0xfd9ffd8(%eax)
f010342b:	00 00 00 
		sched_yield();
f010342e:	e8 d3 0e 00 00       	call   f0104306 <sched_yield>
	}
}
f0103433:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103436:	c9                   	leave  
f0103437:	c3                   	ret    

f0103438 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103438:	55                   	push   %ebp
f0103439:	89 e5                	mov    %esp,%ebp
f010343b:	53                   	push   %ebx
f010343c:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010343f:	e8 06 27 00 00       	call   f0105b4a <cpunum>
f0103444:	6b c0 74             	imul   $0x74,%eax,%eax
f0103447:	8b 98 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%ebx
f010344d:	e8 f8 26 00 00       	call   f0105b4a <cpunum>
f0103452:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103455:	8b 65 08             	mov    0x8(%ebp),%esp
f0103458:	61                   	popa   
f0103459:	07                   	pop    %es
f010345a:	1f                   	pop    %ds
f010345b:	83 c4 08             	add    $0x8,%esp
f010345e:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010345f:	83 ec 04             	sub    $0x4,%esp
f0103462:	68 be 7a 10 f0       	push   $0xf0107abe
f0103467:	68 34 02 00 00       	push   $0x234
f010346c:	68 94 7a 10 f0       	push   $0xf0107a94
f0103471:	e8 ca cb ff ff       	call   f0100040 <_panic>

f0103476 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103476:	55                   	push   %ebp
f0103477:	89 e5                	mov    %esp,%ebp
f0103479:	53                   	push   %ebx
f010347a:	83 ec 04             	sub    $0x4,%esp
f010347d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
//	cprintf("SRHS: inside env run \n");
	if(curenv != e){
f0103480:	e8 c5 26 00 00       	call   f0105b4a <cpunum>
f0103485:	6b c0 74             	imul   $0x74,%eax,%eax
f0103488:	39 98 28 00 26 f0    	cmp    %ebx,-0xfd9ffd8(%eax)
f010348e:	0f 84 a4 00 00 00    	je     f0103538 <env_run+0xc2>
	
		if (curenv != NULL && curenv->env_status == ENV_RUNNING){
f0103494:	e8 b1 26 00 00       	call   f0105b4a <cpunum>
f0103499:	6b c0 74             	imul   $0x74,%eax,%eax
f010349c:	83 b8 28 00 26 f0 00 	cmpl   $0x0,-0xfd9ffd8(%eax)
f01034a3:	74 29                	je     f01034ce <env_run+0x58>
f01034a5:	e8 a0 26 00 00       	call   f0105b4a <cpunum>
f01034aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01034ad:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f01034b3:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01034b7:	75 15                	jne    f01034ce <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f01034b9:	e8 8c 26 00 00       	call   f0105b4a <cpunum>
f01034be:	6b c0 74             	imul   $0x74,%eax,%eax
f01034c1:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f01034c7:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		}
		curenv = e;
f01034ce:	e8 77 26 00 00       	call   f0105b4a <cpunum>
f01034d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01034d6:	89 98 28 00 26 f0    	mov    %ebx,-0xfd9ffd8(%eax)
		curenv->env_status = ENV_RUNNING;
f01034dc:	e8 69 26 00 00       	call   f0105b4a <cpunum>
f01034e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01034e4:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f01034ea:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f01034f1:	e8 54 26 00 00       	call   f0105b4a <cpunum>
f01034f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01034f9:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f01034ff:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f0103503:	e8 42 26 00 00       	call   f0105b4a <cpunum>
f0103508:	6b c0 74             	imul   $0x74,%eax,%eax
f010350b:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f0103511:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103514:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103519:	77 15                	ja     f0103530 <env_run+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010351b:	50                   	push   %eax
f010351c:	68 88 67 10 f0       	push   $0xf0106788
f0103521:	68 5b 02 00 00       	push   $0x25b
f0103526:	68 94 7a 10 f0       	push   $0xf0107a94
f010352b:	e8 10 cb ff ff       	call   f0100040 <_panic>
f0103530:	05 00 00 00 10       	add    $0x10000000,%eax
f0103535:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103538:	83 ec 0c             	sub    $0xc,%esp
f010353b:	68 c0 23 12 f0       	push   $0xf01223c0
f0103540:	e8 10 29 00 00       	call   f0105e55 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103545:	f3 90                	pause  
	}
	unlock_kernel();	
	env_pop_tf(&e->env_tf);
f0103547:	89 1c 24             	mov    %ebx,(%esp)
f010354a:	e8 e9 fe ff ff       	call   f0103438 <env_pop_tf>

f010354f <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010354f:	55                   	push   %ebp
f0103550:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103552:	ba 70 00 00 00       	mov    $0x70,%edx
f0103557:	8b 45 08             	mov    0x8(%ebp),%eax
f010355a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010355b:	ba 71 00 00 00       	mov    $0x71,%edx
f0103560:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103561:	0f b6 c0             	movzbl %al,%eax
}
f0103564:	5d                   	pop    %ebp
f0103565:	c3                   	ret    

f0103566 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103566:	55                   	push   %ebp
f0103567:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103569:	ba 70 00 00 00       	mov    $0x70,%edx
f010356e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103571:	ee                   	out    %al,(%dx)
f0103572:	ba 71 00 00 00       	mov    $0x71,%edx
f0103577:	8b 45 0c             	mov    0xc(%ebp),%eax
f010357a:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010357b:	5d                   	pop    %ebp
f010357c:	c3                   	ret    

f010357d <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010357d:	55                   	push   %ebp
f010357e:	89 e5                	mov    %esp,%ebp
f0103580:	56                   	push   %esi
f0103581:	53                   	push   %ebx
f0103582:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103585:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f010358b:	80 3d 50 f2 25 f0 00 	cmpb   $0x0,0xf025f250
f0103592:	74 5a                	je     f01035ee <irq_setmask_8259A+0x71>
f0103594:	89 c6                	mov    %eax,%esi
f0103596:	ba 21 00 00 00       	mov    $0x21,%edx
f010359b:	ee                   	out    %al,(%dx)
f010359c:	66 c1 e8 08          	shr    $0x8,%ax
f01035a0:	ba a1 00 00 00       	mov    $0xa1,%edx
f01035a5:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01035a6:	83 ec 0c             	sub    $0xc,%esp
f01035a9:	68 ca 7a 10 f0       	push   $0xf0107aca
f01035ae:	e8 31 01 00 00       	call   f01036e4 <cprintf>
f01035b3:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01035b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01035bb:	0f b7 f6             	movzwl %si,%esi
f01035be:	f7 d6                	not    %esi
f01035c0:	0f a3 de             	bt     %ebx,%esi
f01035c3:	73 11                	jae    f01035d6 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f01035c5:	83 ec 08             	sub    $0x8,%esp
f01035c8:	53                   	push   %ebx
f01035c9:	68 e3 7f 10 f0       	push   $0xf0107fe3
f01035ce:	e8 11 01 00 00       	call   f01036e4 <cprintf>
f01035d3:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01035d6:	83 c3 01             	add    $0x1,%ebx
f01035d9:	83 fb 10             	cmp    $0x10,%ebx
f01035dc:	75 e2                	jne    f01035c0 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01035de:	83 ec 0c             	sub    $0xc,%esp
f01035e1:	68 46 7f 10 f0       	push   $0xf0107f46
f01035e6:	e8 f9 00 00 00       	call   f01036e4 <cprintf>
f01035eb:	83 c4 10             	add    $0x10,%esp
}
f01035ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01035f1:	5b                   	pop    %ebx
f01035f2:	5e                   	pop    %esi
f01035f3:	5d                   	pop    %ebp
f01035f4:	c3                   	ret    

f01035f5 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01035f5:	c6 05 50 f2 25 f0 01 	movb   $0x1,0xf025f250
f01035fc:	ba 21 00 00 00       	mov    $0x21,%edx
f0103601:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103606:	ee                   	out    %al,(%dx)
f0103607:	ba a1 00 00 00       	mov    $0xa1,%edx
f010360c:	ee                   	out    %al,(%dx)
f010360d:	ba 20 00 00 00       	mov    $0x20,%edx
f0103612:	b8 11 00 00 00       	mov    $0x11,%eax
f0103617:	ee                   	out    %al,(%dx)
f0103618:	ba 21 00 00 00       	mov    $0x21,%edx
f010361d:	b8 20 00 00 00       	mov    $0x20,%eax
f0103622:	ee                   	out    %al,(%dx)
f0103623:	b8 04 00 00 00       	mov    $0x4,%eax
f0103628:	ee                   	out    %al,(%dx)
f0103629:	b8 03 00 00 00       	mov    $0x3,%eax
f010362e:	ee                   	out    %al,(%dx)
f010362f:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103634:	b8 11 00 00 00       	mov    $0x11,%eax
f0103639:	ee                   	out    %al,(%dx)
f010363a:	ba a1 00 00 00       	mov    $0xa1,%edx
f010363f:	b8 28 00 00 00       	mov    $0x28,%eax
f0103644:	ee                   	out    %al,(%dx)
f0103645:	b8 02 00 00 00       	mov    $0x2,%eax
f010364a:	ee                   	out    %al,(%dx)
f010364b:	b8 01 00 00 00       	mov    $0x1,%eax
f0103650:	ee                   	out    %al,(%dx)
f0103651:	ba 20 00 00 00       	mov    $0x20,%edx
f0103656:	b8 68 00 00 00       	mov    $0x68,%eax
f010365b:	ee                   	out    %al,(%dx)
f010365c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103661:	ee                   	out    %al,(%dx)
f0103662:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103667:	b8 68 00 00 00       	mov    $0x68,%eax
f010366c:	ee                   	out    %al,(%dx)
f010366d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103672:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103673:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f010367a:	66 83 f8 ff          	cmp    $0xffff,%ax
f010367e:	74 13                	je     f0103693 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103680:	55                   	push   %ebp
f0103681:	89 e5                	mov    %esp,%ebp
f0103683:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103686:	0f b7 c0             	movzwl %ax,%eax
f0103689:	50                   	push   %eax
f010368a:	e8 ee fe ff ff       	call   f010357d <irq_setmask_8259A>
f010368f:	83 c4 10             	add    $0x10,%esp
}
f0103692:	c9                   	leave  
f0103693:	f3 c3                	repz ret 

f0103695 <irq_eoi>:
	cprintf("\n");
}

void
irq_eoi(void)
{
f0103695:	55                   	push   %ebp
f0103696:	89 e5                	mov    %esp,%ebp
f0103698:	ba 20 00 00 00       	mov    $0x20,%edx
f010369d:	b8 20 00 00 00       	mov    $0x20,%eax
f01036a2:	ee                   	out    %al,(%dx)
f01036a3:	ba a0 00 00 00       	mov    $0xa0,%edx
f01036a8:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f01036a9:	5d                   	pop    %ebp
f01036aa:	c3                   	ret    

f01036ab <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01036ab:	55                   	push   %ebp
f01036ac:	89 e5                	mov    %esp,%ebp
f01036ae:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01036b1:	ff 75 08             	pushl  0x8(%ebp)
f01036b4:	e8 09 d1 ff ff       	call   f01007c2 <cputchar>
	*cnt++;
}
f01036b9:	83 c4 10             	add    $0x10,%esp
f01036bc:	c9                   	leave  
f01036bd:	c3                   	ret    

f01036be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01036be:	55                   	push   %ebp
f01036bf:	89 e5                	mov    %esp,%ebp
f01036c1:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01036c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01036cb:	ff 75 0c             	pushl  0xc(%ebp)
f01036ce:	ff 75 08             	pushl  0x8(%ebp)
f01036d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01036d4:	50                   	push   %eax
f01036d5:	68 ab 36 10 f0       	push   $0xf01036ab
f01036da:	e8 c7 17 00 00       	call   f0104ea6 <vprintfmt>
	return cnt;
}
f01036df:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01036e2:	c9                   	leave  
f01036e3:	c3                   	ret    

f01036e4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01036e4:	55                   	push   %ebp
f01036e5:	89 e5                	mov    %esp,%ebp
f01036e7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01036ea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01036ed:	50                   	push   %eax
f01036ee:	ff 75 08             	pushl  0x8(%ebp)
f01036f1:	e8 c8 ff ff ff       	call   f01036be <vcprintf>
	va_end(ap);

	return cnt;
}
f01036f6:	c9                   	leave  
f01036f7:	c3                   	ret    

f01036f8 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01036f8:	55                   	push   %ebp
f01036f9:	89 e5                	mov    %esp,%ebp
f01036fb:	57                   	push   %edi
f01036fc:	56                   	push   %esi
f01036fd:	53                   	push   %ebx
f01036fe:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	int i = thiscpu->cpu_id;
f0103701:	e8 44 24 00 00       	call   f0105b4a <cpunum>
f0103706:	6b c0 74             	imul   $0x74,%eax,%eax
f0103709:	0f b6 98 20 00 26 f0 	movzbl -0xfd9ffe0(%eax),%ebx
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t) percpu_kstacks[thiscpu->cpu_id] + KSTKSIZE;
f0103710:	e8 35 24 00 00       	call   f0105b4a <cpunum>
f0103715:	89 c6                	mov    %eax,%esi
f0103717:	e8 2e 24 00 00       	call   f0105b4a <cpunum>
f010371c:	6b ce 74             	imul   $0x74,%esi,%ecx
f010371f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103722:	0f b6 90 20 00 26 f0 	movzbl -0xfd9ffe0(%eax),%edx
f0103729:	c1 e2 0f             	shl    $0xf,%edx
f010372c:	81 c2 00 90 26 f0    	add    $0xf0269000,%edx
f0103732:	89 91 30 00 26 f0    	mov    %edx,-0xfd9ffd0(%ecx)
        thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103738:	e8 0d 24 00 00       	call   f0105b4a <cpunum>
f010373d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103740:	66 c7 80 34 00 26 f0 	movw   $0x10,-0xfd9ffcc(%eax)
f0103747:	10 00 

        // Initialize the TSS slot of the gdt.
        gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103749:	0f b6 db             	movzbl %bl,%ebx
f010374c:	83 c3 05             	add    $0x5,%ebx
f010374f:	e8 f6 23 00 00       	call   f0105b4a <cpunum>
f0103754:	89 c7                	mov    %eax,%edi
f0103756:	e8 ef 23 00 00       	call   f0105b4a <cpunum>
f010375b:	89 c6                	mov    %eax,%esi
f010375d:	e8 e8 23 00 00       	call   f0105b4a <cpunum>
f0103762:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f0103769:	f0 67 00 
f010376c:	6b ff 74             	imul   $0x74,%edi,%edi
f010376f:	81 c7 2c 00 26 f0    	add    $0xf026002c,%edi
f0103775:	66 89 3c dd 42 23 12 	mov    %di,-0xfeddcbe(,%ebx,8)
f010377c:	f0 
f010377d:	6b d6 74             	imul   $0x74,%esi,%edx
f0103780:	81 c2 2c 00 26 f0    	add    $0xf026002c,%edx
f0103786:	c1 ea 10             	shr    $0x10,%edx
f0103789:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f0103790:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f0103797:	40 
f0103798:	6b c0 74             	imul   $0x74,%eax,%eax
f010379b:	05 2c 00 26 f0       	add    $0xf026002c,%eax
f01037a0:	c1 e8 18             	shr    $0x18,%eax
f01037a3:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
                                        sizeof(struct Taskstate) - 1, 0);
        gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f01037aa:	c6 04 dd 45 23 12 f0 	movb   $0x89,-0xfeddcbb(,%ebx,8)
f01037b1:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01037b2:	c1 e3 03             	shl    $0x3,%ebx
f01037b5:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01037b8:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f01037bd:	0f 01 18             	lidtl  (%eax)
        ltr(GD_TSS0 + i * sizeof(struct Segdesc));

        // Load the IDT
        lidt(&idt_pd);

}
f01037c0:	83 c4 0c             	add    $0xc,%esp
f01037c3:	5b                   	pop    %ebx
f01037c4:	5e                   	pop    %esi
f01037c5:	5f                   	pop    %edi
f01037c6:	5d                   	pop    %ebp
f01037c7:	c3                   	ret    

f01037c8 <trap_init>:
}


void
trap_init(void)
{
f01037c8:	55                   	push   %ebp
f01037c9:	89 e5                	mov    %esp,%ebp
f01037cb:	83 ec 08             	sub    $0x8,%esp
	void fun_serial();
	void fun_spurious();
	void fun_ide();
	void fun_error();
	
	SETGATE(idt[T_DIVIDE],0,GD_KT,divide_error,0);
f01037ce:	b8 94 41 10 f0       	mov    $0xf0104194,%eax
f01037d3:	66 a3 60 f2 25 f0    	mov    %ax,0xf025f260
f01037d9:	66 c7 05 62 f2 25 f0 	movw   $0x8,0xf025f262
f01037e0:	08 00 
f01037e2:	c6 05 64 f2 25 f0 00 	movb   $0x0,0xf025f264
f01037e9:	c6 05 65 f2 25 f0 8e 	movb   $0x8e,0xf025f265
f01037f0:	c1 e8 10             	shr    $0x10,%eax
f01037f3:	66 a3 66 f2 25 f0    	mov    %ax,0xf025f266
	SETGATE(idt[T_DEBUG], 0, GD_KT, debug_exception, 0);
f01037f9:	b8 9e 41 10 f0       	mov    $0xf010419e,%eax
f01037fe:	66 a3 68 f2 25 f0    	mov    %ax,0xf025f268
f0103804:	66 c7 05 6a f2 25 f0 	movw   $0x8,0xf025f26a
f010380b:	08 00 
f010380d:	c6 05 6c f2 25 f0 00 	movb   $0x0,0xf025f26c
f0103814:	c6 05 6d f2 25 f0 8e 	movb   $0x8e,0xf025f26d
f010381b:	c1 e8 10             	shr    $0x10,%eax
f010381e:	66 a3 6e f2 25 f0    	mov    %ax,0xf025f26e
	SETGATE(idt[T_NMI], 0, GD_KT, non_maskable_interrupt, 0);
f0103824:	b8 a4 41 10 f0       	mov    $0xf01041a4,%eax
f0103829:	66 a3 70 f2 25 f0    	mov    %ax,0xf025f270
f010382f:	66 c7 05 72 f2 25 f0 	movw   $0x8,0xf025f272
f0103836:	08 00 
f0103838:	c6 05 74 f2 25 f0 00 	movb   $0x0,0xf025f274
f010383f:	c6 05 75 f2 25 f0 8e 	movb   $0x8e,0xf025f275
f0103846:	c1 e8 10             	shr    $0x10,%eax
f0103849:	66 a3 76 f2 25 f0    	mov    %ax,0xf025f276
	SETGATE(idt[T_BRKPT], 0, GD_KT, break_point, 3);
f010384f:	b8 aa 41 10 f0       	mov    $0xf01041aa,%eax
f0103854:	66 a3 78 f2 25 f0    	mov    %ax,0xf025f278
f010385a:	66 c7 05 7a f2 25 f0 	movw   $0x8,0xf025f27a
f0103861:	08 00 
f0103863:	c6 05 7c f2 25 f0 00 	movb   $0x0,0xf025f27c
f010386a:	c6 05 7d f2 25 f0 ee 	movb   $0xee,0xf025f27d
f0103871:	c1 e8 10             	shr    $0x10,%eax
f0103874:	66 a3 7e f2 25 f0    	mov    %ax,0xf025f27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, over_flow, 0);
f010387a:	b8 b0 41 10 f0       	mov    $0xf01041b0,%eax
f010387f:	66 a3 80 f2 25 f0    	mov    %ax,0xf025f280
f0103885:	66 c7 05 82 f2 25 f0 	movw   $0x8,0xf025f282
f010388c:	08 00 
f010388e:	c6 05 84 f2 25 f0 00 	movb   $0x0,0xf025f284
f0103895:	c6 05 85 f2 25 f0 8e 	movb   $0x8e,0xf025f285
f010389c:	c1 e8 10             	shr    $0x10,%eax
f010389f:	66 a3 86 f2 25 f0    	mov    %ax,0xf025f286
	SETGATE(idt[T_BOUND], 0, GD_KT, bounds_check, 0);
f01038a5:	b8 b6 41 10 f0       	mov    $0xf01041b6,%eax
f01038aa:	66 a3 88 f2 25 f0    	mov    %ax,0xf025f288
f01038b0:	66 c7 05 8a f2 25 f0 	movw   $0x8,0xf025f28a
f01038b7:	08 00 
f01038b9:	c6 05 8c f2 25 f0 00 	movb   $0x0,0xf025f28c
f01038c0:	c6 05 8d f2 25 f0 8e 	movb   $0x8e,0xf025f28d
f01038c7:	c1 e8 10             	shr    $0x10,%eax
f01038ca:	66 a3 8e f2 25 f0    	mov    %ax,0xf025f28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, illegal_opcode, 0);
f01038d0:	b8 bc 41 10 f0       	mov    $0xf01041bc,%eax
f01038d5:	66 a3 90 f2 25 f0    	mov    %ax,0xf025f290
f01038db:	66 c7 05 92 f2 25 f0 	movw   $0x8,0xf025f292
f01038e2:	08 00 
f01038e4:	c6 05 94 f2 25 f0 00 	movb   $0x0,0xf025f294
f01038eb:	c6 05 95 f2 25 f0 8e 	movb   $0x8e,0xf025f295
f01038f2:	c1 e8 10             	shr    $0x10,%eax
f01038f5:	66 a3 96 f2 25 f0    	mov    %ax,0xf025f296
	SETGATE(idt[T_DEVICE], 0, GD_KT, device_not_available, 0);
f01038fb:	b8 c2 41 10 f0       	mov    $0xf01041c2,%eax
f0103900:	66 a3 98 f2 25 f0    	mov    %ax,0xf025f298
f0103906:	66 c7 05 9a f2 25 f0 	movw   $0x8,0xf025f29a
f010390d:	08 00 
f010390f:	c6 05 9c f2 25 f0 00 	movb   $0x0,0xf025f29c
f0103916:	c6 05 9d f2 25 f0 8e 	movb   $0x8e,0xf025f29d
f010391d:	c1 e8 10             	shr    $0x10,%eax
f0103920:	66 a3 9e f2 25 f0    	mov    %ax,0xf025f29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, double_fault, 0);
f0103926:	b8 c8 41 10 f0       	mov    $0xf01041c8,%eax
f010392b:	66 a3 a0 f2 25 f0    	mov    %ax,0xf025f2a0
f0103931:	66 c7 05 a2 f2 25 f0 	movw   $0x8,0xf025f2a2
f0103938:	08 00 
f010393a:	c6 05 a4 f2 25 f0 00 	movb   $0x0,0xf025f2a4
f0103941:	c6 05 a5 f2 25 f0 8e 	movb   $0x8e,0xf025f2a5
f0103948:	c1 e8 10             	shr    $0x10,%eax
f010394b:	66 a3 a6 f2 25 f0    	mov    %ax,0xf025f2a6
	SETGATE(idt[T_TSS], 0, GD_KT, task_segment_switch, 0);
f0103951:	b8 cc 41 10 f0       	mov    $0xf01041cc,%eax
f0103956:	66 a3 b0 f2 25 f0    	mov    %ax,0xf025f2b0
f010395c:	66 c7 05 b2 f2 25 f0 	movw   $0x8,0xf025f2b2
f0103963:	08 00 
f0103965:	c6 05 b4 f2 25 f0 00 	movb   $0x0,0xf025f2b4
f010396c:	c6 05 b5 f2 25 f0 8e 	movb   $0x8e,0xf025f2b5
f0103973:	c1 e8 10             	shr    $0x10,%eax
f0103976:	66 a3 b6 f2 25 f0    	mov    %ax,0xf025f2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, segment_not_present, 0);
f010397c:	b8 d0 41 10 f0       	mov    $0xf01041d0,%eax
f0103981:	66 a3 b8 f2 25 f0    	mov    %ax,0xf025f2b8
f0103987:	66 c7 05 ba f2 25 f0 	movw   $0x8,0xf025f2ba
f010398e:	08 00 
f0103990:	c6 05 bc f2 25 f0 00 	movb   $0x0,0xf025f2bc
f0103997:	c6 05 bd f2 25 f0 8e 	movb   $0x8e,0xf025f2bd
f010399e:	c1 e8 10             	shr    $0x10,%eax
f01039a1:	66 a3 be f2 25 f0    	mov    %ax,0xf025f2be
	SETGATE(idt[T_STACK], 0, GD_KT, stack_exception, 0);
f01039a7:	b8 d4 41 10 f0       	mov    $0xf01041d4,%eax
f01039ac:	66 a3 c0 f2 25 f0    	mov    %ax,0xf025f2c0
f01039b2:	66 c7 05 c2 f2 25 f0 	movw   $0x8,0xf025f2c2
f01039b9:	08 00 
f01039bb:	c6 05 c4 f2 25 f0 00 	movb   $0x0,0xf025f2c4
f01039c2:	c6 05 c5 f2 25 f0 8e 	movb   $0x8e,0xf025f2c5
f01039c9:	c1 e8 10             	shr    $0x10,%eax
f01039cc:	66 a3 c6 f2 25 f0    	mov    %ax,0xf025f2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, general_protection_fault, 0);
f01039d2:	b8 d8 41 10 f0       	mov    $0xf01041d8,%eax
f01039d7:	66 a3 c8 f2 25 f0    	mov    %ax,0xf025f2c8
f01039dd:	66 c7 05 ca f2 25 f0 	movw   $0x8,0xf025f2ca
f01039e4:	08 00 
f01039e6:	c6 05 cc f2 25 f0 00 	movb   $0x0,0xf025f2cc
f01039ed:	c6 05 cd f2 25 f0 8e 	movb   $0x8e,0xf025f2cd
f01039f4:	c1 e8 10             	shr    $0x10,%eax
f01039f7:	66 a3 ce f2 25 f0    	mov    %ax,0xf025f2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, page_fault, 0);
f01039fd:	b8 dc 41 10 f0       	mov    $0xf01041dc,%eax
f0103a02:	66 a3 d0 f2 25 f0    	mov    %ax,0xf025f2d0
f0103a08:	66 c7 05 d2 f2 25 f0 	movw   $0x8,0xf025f2d2
f0103a0f:	08 00 
f0103a11:	c6 05 d4 f2 25 f0 00 	movb   $0x0,0xf025f2d4
f0103a18:	c6 05 d5 f2 25 f0 8e 	movb   $0x8e,0xf025f2d5
f0103a1f:	c1 e8 10             	shr    $0x10,%eax
f0103a22:	66 a3 d6 f2 25 f0    	mov    %ax,0xf025f2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, floating_point_error, 0);
f0103a28:	b8 e0 41 10 f0       	mov    $0xf01041e0,%eax
f0103a2d:	66 a3 e0 f2 25 f0    	mov    %ax,0xf025f2e0
f0103a33:	66 c7 05 e2 f2 25 f0 	movw   $0x8,0xf025f2e2
f0103a3a:	08 00 
f0103a3c:	c6 05 e4 f2 25 f0 00 	movb   $0x0,0xf025f2e4
f0103a43:	c6 05 e5 f2 25 f0 8e 	movb   $0x8e,0xf025f2e5
f0103a4a:	c1 e8 10             	shr    $0x10,%eax
f0103a4d:	66 a3 e6 f2 25 f0    	mov    %ax,0xf025f2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, alignment_check , 0);
f0103a53:	b8 e6 41 10 f0       	mov    $0xf01041e6,%eax
f0103a58:	66 a3 e8 f2 25 f0    	mov    %ax,0xf025f2e8
f0103a5e:	66 c7 05 ea f2 25 f0 	movw   $0x8,0xf025f2ea
f0103a65:	08 00 
f0103a67:	c6 05 ec f2 25 f0 00 	movb   $0x0,0xf025f2ec
f0103a6e:	c6 05 ed f2 25 f0 8e 	movb   $0x8e,0xf025f2ed
f0103a75:	c1 e8 10             	shr    $0x10,%eax
f0103a78:	66 a3 ee f2 25 f0    	mov    %ax,0xf025f2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, machine_check, 0);
f0103a7e:	b8 ea 41 10 f0       	mov    $0xf01041ea,%eax
f0103a83:	66 a3 f0 f2 25 f0    	mov    %ax,0xf025f2f0
f0103a89:	66 c7 05 f2 f2 25 f0 	movw   $0x8,0xf025f2f2
f0103a90:	08 00 
f0103a92:	c6 05 f4 f2 25 f0 00 	movb   $0x0,0xf025f2f4
f0103a99:	c6 05 f5 f2 25 f0 8e 	movb   $0x8e,0xf025f2f5
f0103aa0:	c1 e8 10             	shr    $0x10,%eax
f0103aa3:	66 a3 f6 f2 25 f0    	mov    %ax,0xf025f2f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, simd_floating_point_error, 0);
f0103aa9:	b8 f0 41 10 f0       	mov    $0xf01041f0,%eax
f0103aae:	66 a3 f8 f2 25 f0    	mov    %ax,0xf025f2f8
f0103ab4:	66 c7 05 fa f2 25 f0 	movw   $0x8,0xf025f2fa
f0103abb:	08 00 
f0103abd:	c6 05 fc f2 25 f0 00 	movb   $0x0,0xf025f2fc
f0103ac4:	c6 05 fd f2 25 f0 8e 	movb   $0x8e,0xf025f2fd
f0103acb:	c1 e8 10             	shr    $0x10,%eax
f0103ace:	66 a3 fe f2 25 f0    	mov    %ax,0xf025f2fe
	SETGATE(idt[T_SYSCALL], 0 , GD_KT, system_call, 3);
f0103ad4:	b8 f6 41 10 f0       	mov    $0xf01041f6,%eax
f0103ad9:	66 a3 e0 f3 25 f0    	mov    %ax,0xf025f3e0
f0103adf:	66 c7 05 e2 f3 25 f0 	movw   $0x8,0xf025f3e2
f0103ae6:	08 00 
f0103ae8:	c6 05 e4 f3 25 f0 00 	movb   $0x0,0xf025f3e4
f0103aef:	c6 05 e5 f3 25 f0 ee 	movb   $0xee,0xf025f3e5
f0103af6:	c1 e8 10             	shr    $0x10,%eax
f0103af9:	66 a3 e6 f3 25 f0    	mov    %ax,0xf025f3e6
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0 , GD_KT, fun_timer, 0);
f0103aff:	b8 fc 41 10 f0       	mov    $0xf01041fc,%eax
f0103b04:	66 a3 60 f3 25 f0    	mov    %ax,0xf025f360
f0103b0a:	66 c7 05 62 f3 25 f0 	movw   $0x8,0xf025f362
f0103b11:	08 00 
f0103b13:	c6 05 64 f3 25 f0 00 	movb   $0x0,0xf025f364
f0103b1a:	c6 05 65 f3 25 f0 8e 	movb   $0x8e,0xf025f365
f0103b21:	c1 e8 10             	shr    $0x10,%eax
f0103b24:	66 a3 66 f3 25 f0    	mov    %ax,0xf025f366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0 , GD_KT, fun_kbd, 0);
f0103b2a:	b8 02 42 10 f0       	mov    $0xf0104202,%eax
f0103b2f:	66 a3 68 f3 25 f0    	mov    %ax,0xf025f368
f0103b35:	66 c7 05 6a f3 25 f0 	movw   $0x8,0xf025f36a
f0103b3c:	08 00 
f0103b3e:	c6 05 6c f3 25 f0 00 	movb   $0x0,0xf025f36c
f0103b45:	c6 05 6d f3 25 f0 8e 	movb   $0x8e,0xf025f36d
f0103b4c:	c1 e8 10             	shr    $0x10,%eax
f0103b4f:	66 a3 6e f3 25 f0    	mov    %ax,0xf025f36e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0 , GD_KT, fun_serial, 0);
f0103b55:	b8 1a 42 10 f0       	mov    $0xf010421a,%eax
f0103b5a:	66 a3 80 f3 25 f0    	mov    %ax,0xf025f380
f0103b60:	66 c7 05 82 f3 25 f0 	movw   $0x8,0xf025f382
f0103b67:	08 00 
f0103b69:	c6 05 84 f3 25 f0 00 	movb   $0x0,0xf025f384
f0103b70:	c6 05 85 f3 25 f0 8e 	movb   $0x8e,0xf025f385
f0103b77:	c1 e8 10             	shr    $0x10,%eax
f0103b7a:	66 a3 86 f3 25 f0    	mov    %ax,0xf025f386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0 , GD_KT, fun_spurious, 0);
f0103b80:	b8 08 42 10 f0       	mov    $0xf0104208,%eax
f0103b85:	66 a3 98 f3 25 f0    	mov    %ax,0xf025f398
f0103b8b:	66 c7 05 9a f3 25 f0 	movw   $0x8,0xf025f39a
f0103b92:	08 00 
f0103b94:	c6 05 9c f3 25 f0 00 	movb   $0x0,0xf025f39c
f0103b9b:	c6 05 9d f3 25 f0 8e 	movb   $0x8e,0xf025f39d
f0103ba2:	c1 e8 10             	shr    $0x10,%eax
f0103ba5:	66 a3 9e f3 25 f0    	mov    %ax,0xf025f39e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0 , GD_KT, fun_ide, 0);
f0103bab:	b8 14 42 10 f0       	mov    $0xf0104214,%eax
f0103bb0:	66 a3 d0 f3 25 f0    	mov    %ax,0xf025f3d0
f0103bb6:	66 c7 05 d2 f3 25 f0 	movw   $0x8,0xf025f3d2
f0103bbd:	08 00 
f0103bbf:	c6 05 d4 f3 25 f0 00 	movb   $0x0,0xf025f3d4
f0103bc6:	c6 05 d5 f3 25 f0 8e 	movb   $0x8e,0xf025f3d5
f0103bcd:	c1 e8 10             	shr    $0x10,%eax
f0103bd0:	66 a3 d6 f3 25 f0    	mov    %ax,0xf025f3d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0 , GD_KT, fun_error, 0);
f0103bd6:	b8 0e 42 10 f0       	mov    $0xf010420e,%eax
f0103bdb:	66 a3 f8 f3 25 f0    	mov    %ax,0xf025f3f8
f0103be1:	66 c7 05 fa f3 25 f0 	movw   $0x8,0xf025f3fa
f0103be8:	08 00 
f0103bea:	c6 05 fc f3 25 f0 00 	movb   $0x0,0xf025f3fc
f0103bf1:	c6 05 fd f3 25 f0 8e 	movb   $0x8e,0xf025f3fd
f0103bf8:	c1 e8 10             	shr    $0x10,%eax
f0103bfb:	66 a3 fe f3 25 f0    	mov    %ax,0xf025f3fe
	// Per-CPU setup 
	trap_init_percpu();
f0103c01:	e8 f2 fa ff ff       	call   f01036f8 <trap_init_percpu>
}
f0103c06:	c9                   	leave  
f0103c07:	c3                   	ret    

f0103c08 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103c08:	55                   	push   %ebp
f0103c09:	89 e5                	mov    %esp,%ebp
f0103c0b:	53                   	push   %ebx
f0103c0c:	83 ec 0c             	sub    $0xc,%esp
f0103c0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103c12:	ff 33                	pushl  (%ebx)
f0103c14:	68 de 7a 10 f0       	push   $0xf0107ade
f0103c19:	e8 c6 fa ff ff       	call   f01036e4 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103c1e:	83 c4 08             	add    $0x8,%esp
f0103c21:	ff 73 04             	pushl  0x4(%ebx)
f0103c24:	68 ed 7a 10 f0       	push   $0xf0107aed
f0103c29:	e8 b6 fa ff ff       	call   f01036e4 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103c2e:	83 c4 08             	add    $0x8,%esp
f0103c31:	ff 73 08             	pushl  0x8(%ebx)
f0103c34:	68 fc 7a 10 f0       	push   $0xf0107afc
f0103c39:	e8 a6 fa ff ff       	call   f01036e4 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103c3e:	83 c4 08             	add    $0x8,%esp
f0103c41:	ff 73 0c             	pushl  0xc(%ebx)
f0103c44:	68 0b 7b 10 f0       	push   $0xf0107b0b
f0103c49:	e8 96 fa ff ff       	call   f01036e4 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103c4e:	83 c4 08             	add    $0x8,%esp
f0103c51:	ff 73 10             	pushl  0x10(%ebx)
f0103c54:	68 1a 7b 10 f0       	push   $0xf0107b1a
f0103c59:	e8 86 fa ff ff       	call   f01036e4 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103c5e:	83 c4 08             	add    $0x8,%esp
f0103c61:	ff 73 14             	pushl  0x14(%ebx)
f0103c64:	68 29 7b 10 f0       	push   $0xf0107b29
f0103c69:	e8 76 fa ff ff       	call   f01036e4 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103c6e:	83 c4 08             	add    $0x8,%esp
f0103c71:	ff 73 18             	pushl  0x18(%ebx)
f0103c74:	68 38 7b 10 f0       	push   $0xf0107b38
f0103c79:	e8 66 fa ff ff       	call   f01036e4 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103c7e:	83 c4 08             	add    $0x8,%esp
f0103c81:	ff 73 1c             	pushl  0x1c(%ebx)
f0103c84:	68 47 7b 10 f0       	push   $0xf0107b47
f0103c89:	e8 56 fa ff ff       	call   f01036e4 <cprintf>
}
f0103c8e:	83 c4 10             	add    $0x10,%esp
f0103c91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c94:	c9                   	leave  
f0103c95:	c3                   	ret    

f0103c96 <print_trapframe>:

}

void
print_trapframe(struct Trapframe *tf)
{
f0103c96:	55                   	push   %ebp
f0103c97:	89 e5                	mov    %esp,%ebp
f0103c99:	56                   	push   %esi
f0103c9a:	53                   	push   %ebx
f0103c9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103c9e:	e8 a7 1e 00 00       	call   f0105b4a <cpunum>
f0103ca3:	83 ec 04             	sub    $0x4,%esp
f0103ca6:	50                   	push   %eax
f0103ca7:	53                   	push   %ebx
f0103ca8:	68 ab 7b 10 f0       	push   $0xf0107bab
f0103cad:	e8 32 fa ff ff       	call   f01036e4 <cprintf>
	print_regs(&tf->tf_regs);
f0103cb2:	89 1c 24             	mov    %ebx,(%esp)
f0103cb5:	e8 4e ff ff ff       	call   f0103c08 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103cba:	83 c4 08             	add    $0x8,%esp
f0103cbd:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103cc1:	50                   	push   %eax
f0103cc2:	68 c9 7b 10 f0       	push   $0xf0107bc9
f0103cc7:	e8 18 fa ff ff       	call   f01036e4 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ccc:	83 c4 08             	add    $0x8,%esp
f0103ccf:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103cd3:	50                   	push   %eax
f0103cd4:	68 dc 7b 10 f0       	push   $0xf0107bdc
f0103cd9:	e8 06 fa ff ff       	call   f01036e4 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103cde:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103ce1:	83 c4 10             	add    $0x10,%esp
f0103ce4:	83 f8 13             	cmp    $0x13,%eax
f0103ce7:	77 09                	ja     f0103cf2 <print_trapframe+0x5c>
		return excnames[trapno];
f0103ce9:	8b 14 85 a0 7e 10 f0 	mov    -0xfef8160(,%eax,4),%edx
f0103cf0:	eb 1f                	jmp    f0103d11 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103cf2:	83 f8 30             	cmp    $0x30,%eax
f0103cf5:	74 15                	je     f0103d0c <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103cf7:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103cfa:	83 fa 10             	cmp    $0x10,%edx
f0103cfd:	b9 75 7b 10 f0       	mov    $0xf0107b75,%ecx
f0103d02:	ba 62 7b 10 f0       	mov    $0xf0107b62,%edx
f0103d07:	0f 43 d1             	cmovae %ecx,%edx
f0103d0a:	eb 05                	jmp    f0103d11 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103d0c:	ba 56 7b 10 f0       	mov    $0xf0107b56,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d11:	83 ec 04             	sub    $0x4,%esp
f0103d14:	52                   	push   %edx
f0103d15:	50                   	push   %eax
f0103d16:	68 ef 7b 10 f0       	push   $0xf0107bef
f0103d1b:	e8 c4 f9 ff ff       	call   f01036e4 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103d20:	83 c4 10             	add    $0x10,%esp
f0103d23:	3b 1d 60 fa 25 f0    	cmp    0xf025fa60,%ebx
f0103d29:	75 1a                	jne    f0103d45 <print_trapframe+0xaf>
f0103d2b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103d2f:	75 14                	jne    f0103d45 <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103d31:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103d34:	83 ec 08             	sub    $0x8,%esp
f0103d37:	50                   	push   %eax
f0103d38:	68 01 7c 10 f0       	push   $0xf0107c01
f0103d3d:	e8 a2 f9 ff ff       	call   f01036e4 <cprintf>
f0103d42:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103d45:	83 ec 08             	sub    $0x8,%esp
f0103d48:	ff 73 2c             	pushl  0x2c(%ebx)
f0103d4b:	68 10 7c 10 f0       	push   $0xf0107c10
f0103d50:	e8 8f f9 ff ff       	call   f01036e4 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103d55:	83 c4 10             	add    $0x10,%esp
f0103d58:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103d5c:	75 49                	jne    f0103da7 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103d5e:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103d61:	89 c2                	mov    %eax,%edx
f0103d63:	83 e2 01             	and    $0x1,%edx
f0103d66:	ba 8f 7b 10 f0       	mov    $0xf0107b8f,%edx
f0103d6b:	b9 84 7b 10 f0       	mov    $0xf0107b84,%ecx
f0103d70:	0f 44 ca             	cmove  %edx,%ecx
f0103d73:	89 c2                	mov    %eax,%edx
f0103d75:	83 e2 02             	and    $0x2,%edx
f0103d78:	ba a1 7b 10 f0       	mov    $0xf0107ba1,%edx
f0103d7d:	be 9b 7b 10 f0       	mov    $0xf0107b9b,%esi
f0103d82:	0f 45 d6             	cmovne %esi,%edx
f0103d85:	83 e0 04             	and    $0x4,%eax
f0103d88:	be db 7c 10 f0       	mov    $0xf0107cdb,%esi
f0103d8d:	b8 a6 7b 10 f0       	mov    $0xf0107ba6,%eax
f0103d92:	0f 44 c6             	cmove  %esi,%eax
f0103d95:	51                   	push   %ecx
f0103d96:	52                   	push   %edx
f0103d97:	50                   	push   %eax
f0103d98:	68 1e 7c 10 f0       	push   $0xf0107c1e
f0103d9d:	e8 42 f9 ff ff       	call   f01036e4 <cprintf>
f0103da2:	83 c4 10             	add    $0x10,%esp
f0103da5:	eb 10                	jmp    f0103db7 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103da7:	83 ec 0c             	sub    $0xc,%esp
f0103daa:	68 46 7f 10 f0       	push   $0xf0107f46
f0103daf:	e8 30 f9 ff ff       	call   f01036e4 <cprintf>
f0103db4:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103db7:	83 ec 08             	sub    $0x8,%esp
f0103dba:	ff 73 30             	pushl  0x30(%ebx)
f0103dbd:	68 2d 7c 10 f0       	push   $0xf0107c2d
f0103dc2:	e8 1d f9 ff ff       	call   f01036e4 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103dc7:	83 c4 08             	add    $0x8,%esp
f0103dca:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103dce:	50                   	push   %eax
f0103dcf:	68 3c 7c 10 f0       	push   $0xf0107c3c
f0103dd4:	e8 0b f9 ff ff       	call   f01036e4 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103dd9:	83 c4 08             	add    $0x8,%esp
f0103ddc:	ff 73 38             	pushl  0x38(%ebx)
f0103ddf:	68 4f 7c 10 f0       	push   $0xf0107c4f
f0103de4:	e8 fb f8 ff ff       	call   f01036e4 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103de9:	83 c4 10             	add    $0x10,%esp
f0103dec:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103df0:	74 25                	je     f0103e17 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103df2:	83 ec 08             	sub    $0x8,%esp
f0103df5:	ff 73 3c             	pushl  0x3c(%ebx)
f0103df8:	68 5e 7c 10 f0       	push   $0xf0107c5e
f0103dfd:	e8 e2 f8 ff ff       	call   f01036e4 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103e02:	83 c4 08             	add    $0x8,%esp
f0103e05:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103e09:	50                   	push   %eax
f0103e0a:	68 6d 7c 10 f0       	push   $0xf0107c6d
f0103e0f:	e8 d0 f8 ff ff       	call   f01036e4 <cprintf>
f0103e14:	83 c4 10             	add    $0x10,%esp
	}
}
f0103e17:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103e1a:	5b                   	pop    %ebx
f0103e1b:	5e                   	pop    %esi
f0103e1c:	5d                   	pop    %ebp
f0103e1d:	c3                   	ret    

f0103e1e <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103e1e:	55                   	push   %ebp
f0103e1f:	89 e5                	mov    %esp,%ebp
f0103e21:	57                   	push   %edi
f0103e22:	56                   	push   %esi
f0103e23:	53                   	push   %ebx
f0103e24:	83 ec 0c             	sub    $0xc,%esp
f0103e27:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103e2a:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs== GD_KT)
f0103e2d:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0103e32:	75 17                	jne    f0103e4b <page_fault_handler+0x2d>
		panic("page_fault_handler: Page Fault in Kernel");
f0103e34:	83 ec 04             	sub    $0x4,%esp
f0103e37:	68 28 7e 10 f0       	push   $0xf0107e28
f0103e3c:	68 76 01 00 00       	push   $0x176
f0103e41:	68 80 7c 10 f0       	push   $0xf0107c80
f0103e46:	e8 f5 c1 ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	uint32_t uxtop;
	struct UTrapframe *uxframe;
	if(curenv->env_pgfault_upcall == NULL)
f0103e4b:	e8 fa 1c 00 00       	call   f0105b4a <cpunum>
f0103e50:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e53:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f0103e59:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103e5d:	75 43                	jne    f0103ea2 <page_fault_handler+0x84>
	{
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0103e5f:	8b 7b 30             	mov    0x30(%ebx),%edi
                curenv->env_id, fault_va, tf->tf_eip);
f0103e62:	e8 e3 1c 00 00       	call   f0105b4a <cpunum>
	// LAB 4: Your code here.
	uint32_t uxtop;
	struct UTrapframe *uxframe;
	if(curenv->env_pgfault_upcall == NULL)
	{
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0103e67:	57                   	push   %edi
f0103e68:	56                   	push   %esi
                curenv->env_id, fault_va, tf->tf_eip);
f0103e69:	6b c0 74             	imul   $0x74,%eax,%eax
	// LAB 4: Your code here.
	uint32_t uxtop;
	struct UTrapframe *uxframe;
	if(curenv->env_pgfault_upcall == NULL)
	{
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0103e6c:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f0103e72:	ff 70 48             	pushl  0x48(%eax)
f0103e75:	68 54 7e 10 f0       	push   $0xf0107e54
f0103e7a:	e8 65 f8 ff ff       	call   f01036e4 <cprintf>
                curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f0103e7f:	89 1c 24             	mov    %ebx,(%esp)
f0103e82:	e8 0f fe ff ff       	call   f0103c96 <print_trapframe>
		env_destroy(curenv);
f0103e87:	e8 be 1c 00 00       	call   f0105b4a <cpunum>
f0103e8c:	83 c4 04             	add    $0x4,%esp
f0103e8f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e92:	ff b0 28 00 26 f0    	pushl  -0xfd9ffd8(%eax)
f0103e98:	e8 3a f5 ff ff       	call   f01033d7 <env_destroy>
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;

		env_run(curenv);
	}

}
f0103e9d:	e9 a5 00 00 00       	jmp    f0103f47 <page_fault_handler+0x129>
		cprintf("[%08x] user fault va %08x ip %08x\n",
                curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
		env_destroy(curenv);
	} else {
		if(tf->tf_esp < USTACKTOP)
f0103ea2:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103ea5:	3d ff df bf ee       	cmp    $0xeebfdfff,%eax
f0103eaa:	77 26                	ja     f0103ed2 <page_fault_handler+0xb4>
		{
			uxtop = UXSTACKTOP - sizeof(struct UTrapframe);
			user_mem_assert(curenv, (const void *) uxtop, sizeof(struct UTrapframe), PTE_W|PTE_P);
f0103eac:	e8 99 1c 00 00       	call   f0105b4a <cpunum>
f0103eb1:	6a 03                	push   $0x3
f0103eb3:	6a 34                	push   $0x34
f0103eb5:	68 cc ff bf ee       	push   $0xeebfffcc
f0103eba:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ebd:	ff b0 28 00 26 f0    	pushl  -0xfd9ffd8(%eax)
f0103ec3:	e8 8b ee ff ff       	call   f0102d53 <user_mem_assert>
f0103ec8:	83 c4 10             	add    $0x10,%esp
		print_trapframe(tf);
		env_destroy(curenv);
	} else {
		if(tf->tf_esp < USTACKTOP)
		{
			uxtop = UXSTACKTOP - sizeof(struct UTrapframe);
f0103ecb:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
f0103ed0:	eb 20                	jmp    f0103ef2 <page_fault_handler+0xd4>
			user_mem_assert(curenv, (const void *) uxtop, sizeof(struct UTrapframe), PTE_W|PTE_P);
		} else {
			uxtop = tf->tf_esp - sizeof(struct UTrapframe) - 4; 
f0103ed2:	83 e8 38             	sub    $0x38,%eax
f0103ed5:	89 c7                	mov    %eax,%edi
			user_mem_assert(curenv, (const void *) uxtop, sizeof(struct UTrapframe)+4, PTE_W|PTE_P);
f0103ed7:	e8 6e 1c 00 00       	call   f0105b4a <cpunum>
f0103edc:	6a 03                	push   $0x3
f0103ede:	6a 38                	push   $0x38
f0103ee0:	57                   	push   %edi
f0103ee1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ee4:	ff b0 28 00 26 f0    	pushl  -0xfd9ffd8(%eax)
f0103eea:	e8 64 ee ff ff       	call   f0102d53 <user_mem_assert>
f0103eef:	83 c4 10             	add    $0x10,%esp
		}
//		cprintf("SRHS: uxtop value is %08x \n",uxtop);
//		user_mem_assert(curenv, (const void *) uxtop, PGSIZE, PTE_W|PTE_P);
		
		uxframe = (struct UTrapframe *) uxtop;
		uxframe->utf_fault_va = fault_va;
f0103ef2:	89 fa                	mov    %edi,%edx
f0103ef4:	89 37                	mov    %esi,(%edi)
		uxframe->utf_err = tf->tf_err;
f0103ef6:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103ef9:	89 47 04             	mov    %eax,0x4(%edi)
		uxframe->utf_regs = tf->tf_regs;
f0103efc:	8d 7f 08             	lea    0x8(%edi),%edi
f0103eff:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103f04:	89 de                	mov    %ebx,%esi
f0103f06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		uxframe->utf_eip = tf->tf_eip;
f0103f08:	8b 43 30             	mov    0x30(%ebx),%eax
f0103f0b:	89 42 28             	mov    %eax,0x28(%edx)
		uxframe->utf_eflags = tf->tf_eflags;
f0103f0e:	8b 43 38             	mov    0x38(%ebx),%eax
f0103f11:	89 42 2c             	mov    %eax,0x2c(%edx)
		uxframe->utf_esp = tf->tf_esp;
f0103f14:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f17:	89 42 30             	mov    %eax,0x30(%edx)

		tf->tf_esp = (uintptr_t)uxframe;
f0103f1a:	89 53 3c             	mov    %edx,0x3c(%ebx)
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f0103f1d:	e8 28 1c 00 00       	call   f0105b4a <cpunum>
f0103f22:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f25:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f0103f2b:	8b 40 64             	mov    0x64(%eax),%eax
f0103f2e:	89 43 30             	mov    %eax,0x30(%ebx)

		env_run(curenv);
f0103f31:	e8 14 1c 00 00       	call   f0105b4a <cpunum>
f0103f36:	83 ec 0c             	sub    $0xc,%esp
f0103f39:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f3c:	ff b0 28 00 26 f0    	pushl  -0xfd9ffd8(%eax)
f0103f42:	e8 2f f5 ff ff       	call   f0103476 <env_run>
	}

}
f0103f47:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f4a:	5b                   	pop    %ebx
f0103f4b:	5e                   	pop    %esi
f0103f4c:	5f                   	pop    %edi
f0103f4d:	5d                   	pop    %ebp
f0103f4e:	c3                   	ret    

f0103f4f <trap>:
	
}

void
trap(struct Trapframe *tf)
{
f0103f4f:	55                   	push   %ebp
f0103f50:	89 e5                	mov    %esp,%ebp
f0103f52:	57                   	push   %edi
f0103f53:	56                   	push   %esi
f0103f54:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103f57:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103f58:	83 3d 98 fe 25 f0 00 	cmpl   $0x0,0xf025fe98
f0103f5f:	74 01                	je     f0103f62 <trap+0x13>
		asm volatile("hlt");
f0103f61:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103f62:	e8 e3 1b 00 00       	call   f0105b4a <cpunum>
f0103f67:	6b d0 74             	imul   $0x74,%eax,%edx
f0103f6a:	81 c2 20 00 26 f0    	add    $0xf0260020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103f70:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f75:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103f79:	83 f8 02             	cmp    $0x2,%eax
f0103f7c:	75 10                	jne    f0103f8e <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103f7e:	83 ec 0c             	sub    $0xc,%esp
f0103f81:	68 c0 23 12 f0       	push   $0xf01223c0
f0103f86:	e8 2d 1e 00 00       	call   f0105db8 <spin_lock>
f0103f8b:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103f8e:	9c                   	pushf  
f0103f8f:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103f90:	f6 c4 02             	test   $0x2,%ah
f0103f93:	74 19                	je     f0103fae <trap+0x5f>
f0103f95:	68 8c 7c 10 f0       	push   $0xf0107c8c
f0103f9a:	68 c3 76 10 f0       	push   $0xf01076c3
f0103f9f:	68 40 01 00 00       	push   $0x140
f0103fa4:	68 80 7c 10 f0       	push   $0xf0107c80
f0103fa9:	e8 92 c0 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103fae:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103fb2:	83 e0 03             	and    $0x3,%eax
f0103fb5:	66 83 f8 03          	cmp    $0x3,%ax
f0103fb9:	0f 85 a0 00 00 00    	jne    f010405f <trap+0x110>
f0103fbf:	83 ec 0c             	sub    $0xc,%esp
f0103fc2:	68 c0 23 12 f0       	push   $0xf01223c0
f0103fc7:	e8 ec 1d 00 00       	call   f0105db8 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0103fcc:	e8 79 1b 00 00       	call   f0105b4a <cpunum>
f0103fd1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fd4:	83 c4 10             	add    $0x10,%esp
f0103fd7:	83 b8 28 00 26 f0 00 	cmpl   $0x0,-0xfd9ffd8(%eax)
f0103fde:	75 19                	jne    f0103ff9 <trap+0xaa>
f0103fe0:	68 a5 7c 10 f0       	push   $0xf0107ca5
f0103fe5:	68 c3 76 10 f0       	push   $0xf01076c3
f0103fea:	68 48 01 00 00       	push   $0x148
f0103fef:	68 80 7c 10 f0       	push   $0xf0107c80
f0103ff4:	e8 47 c0 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103ff9:	e8 4c 1b 00 00       	call   f0105b4a <cpunum>
f0103ffe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104001:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f0104007:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010400b:	75 2d                	jne    f010403a <trap+0xeb>
			env_free(curenv);
f010400d:	e8 38 1b 00 00       	call   f0105b4a <cpunum>
f0104012:	83 ec 0c             	sub    $0xc,%esp
f0104015:	6b c0 74             	imul   $0x74,%eax,%eax
f0104018:	ff b0 28 00 26 f0    	pushl  -0xfd9ffd8(%eax)
f010401e:	e8 0e f2 ff ff       	call   f0103231 <env_free>
			curenv = NULL;
f0104023:	e8 22 1b 00 00       	call   f0105b4a <cpunum>
f0104028:	6b c0 74             	imul   $0x74,%eax,%eax
f010402b:	c7 80 28 00 26 f0 00 	movl   $0x0,-0xfd9ffd8(%eax)
f0104032:	00 00 00 
			sched_yield();
f0104035:	e8 cc 02 00 00       	call   f0104306 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010403a:	e8 0b 1b 00 00       	call   f0105b4a <cpunum>
f010403f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104042:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f0104048:	b9 11 00 00 00       	mov    $0x11,%ecx
f010404d:	89 c7                	mov    %eax,%edi
f010404f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104051:	e8 f4 1a 00 00       	call   f0105b4a <cpunum>
f0104056:	6b c0 74             	imul   $0x74,%eax,%eax
f0104059:	8b b0 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010405f:	89 35 60 fa 25 f0    	mov    %esi,0xf025fa60


	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104065:	8b 46 28             	mov    0x28(%esi),%eax
f0104068:	83 f8 27             	cmp    $0x27,%eax
f010406b:	75 1d                	jne    f010408a <trap+0x13b>
		cprintf("Spurious interrupt on irq 7\n");
f010406d:	83 ec 0c             	sub    $0xc,%esp
f0104070:	68 ac 7c 10 f0       	push   $0xf0107cac
f0104075:	e8 6a f6 ff ff       	call   f01036e4 <cprintf>
		print_trapframe(tf);
f010407a:	89 34 24             	mov    %esi,(%esp)
f010407d:	e8 14 fc ff ff       	call   f0103c96 <print_trapframe>
f0104082:	83 c4 10             	add    $0x10,%esp
f0104085:	e9 c9 00 00 00       	jmp    f0104153 <trap+0x204>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if(tf->tf_trapno == (IRQ_OFFSET + IRQ_TIMER)) {
f010408a:	83 f8 20             	cmp    $0x20,%eax
f010408d:	75 17                	jne    f01040a6 <trap+0x157>
cprintf("SRHS: timer interrupt is here\n");
f010408f:	83 ec 0c             	sub    $0xc,%esp
f0104092:	68 78 7e 10 f0       	push   $0xf0107e78
f0104097:	e8 48 f6 ff ff       	call   f01036e4 <cprintf>
		lapic_eoi();
f010409c:	e8 f4 1b 00 00       	call   f0105c95 <lapic_eoi>
                sched_yield();
f01040a1:	e8 60 02 00 00       	call   f0104306 <sched_yield>


	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
	
	if(tf->tf_trapno == (IRQ_OFFSET + IRQ_KBD)) {
f01040a6:	83 f8 21             	cmp    $0x21,%eax
f01040a9:	75 0a                	jne    f01040b5 <trap+0x166>
		kbd_intr();
f01040ab:	e8 70 c5 ff ff       	call   f0100620 <kbd_intr>
f01040b0:	e9 9e 00 00 00       	jmp    f0104153 <trap+0x204>
                return;
        }

	if(tf->tf_trapno == (IRQ_OFFSET + IRQ_SERIAL)) {
f01040b5:	83 f8 24             	cmp    $0x24,%eax
f01040b8:	75 0a                	jne    f01040c4 <trap+0x175>
		serial_intr();
f01040ba:	e8 45 c5 ff ff       	call   f0100604 <serial_intr>
f01040bf:	e9 8f 00 00 00       	jmp    f0104153 <trap+0x204>
                return;
        }


	if (tf->tf_trapno == T_PGFLT) {
f01040c4:	83 f8 0e             	cmp    $0xe,%eax
f01040c7:	75 0e                	jne    f01040d7 <trap+0x188>
		page_fault_handler(tf);
f01040c9:	83 ec 0c             	sub    $0xc,%esp
f01040cc:	56                   	push   %esi
f01040cd:	e8 4c fd ff ff       	call   f0103e1e <page_fault_handler>
f01040d2:	83 c4 10             	add    $0x10,%esp
f01040d5:	eb 7c                	jmp    f0104153 <trap+0x204>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f01040d7:	83 f8 03             	cmp    $0x3,%eax
f01040da:	75 0e                	jne    f01040ea <trap+0x19b>
		monitor(tf);
f01040dc:	83 ec 0c             	sub    $0xc,%esp
f01040df:	56                   	push   %esi
f01040e0:	e8 81 c8 ff ff       	call   f0100966 <monitor>
f01040e5:	83 c4 10             	add    $0x10,%esp
f01040e8:	eb 69                	jmp    f0104153 <trap+0x204>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f01040ea:	83 f8 30             	cmp    $0x30,%eax
f01040ed:	75 21                	jne    f0104110 <trap+0x1c1>
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f01040ef:	83 ec 08             	sub    $0x8,%esp
f01040f2:	ff 76 04             	pushl  0x4(%esi)
f01040f5:	ff 36                	pushl  (%esi)
f01040f7:	ff 76 10             	pushl  0x10(%esi)
f01040fa:	ff 76 18             	pushl  0x18(%esi)
f01040fd:	ff 76 14             	pushl  0x14(%esi)
f0104100:	ff 76 1c             	pushl  0x1c(%esi)
f0104103:	e8 a2 02 00 00       	call   f01043aa <syscall>
	if (tf->tf_trapno == T_BRKPT) {
		monitor(tf);
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
		tf->tf_regs.reg_eax = 
f0104108:	89 46 1c             	mov    %eax,0x1c(%esi)
f010410b:	83 c4 20             	add    $0x20,%esp
f010410e:	eb 43                	jmp    f0104153 <trap+0x204>
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104110:	83 ec 0c             	sub    $0xc,%esp
f0104113:	56                   	push   %esi
f0104114:	e8 7d fb ff ff       	call   f0103c96 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104119:	83 c4 10             	add    $0x10,%esp
f010411c:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104121:	75 17                	jne    f010413a <trap+0x1eb>
		panic("unhandled trap in kernel");
f0104123:	83 ec 04             	sub    $0x4,%esp
f0104126:	68 c9 7c 10 f0       	push   $0xf0107cc9
f010412b:	68 24 01 00 00       	push   $0x124
f0104130:	68 80 7c 10 f0       	push   $0xf0107c80
f0104135:	e8 06 bf ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f010413a:	e8 0b 1a 00 00       	call   f0105b4a <cpunum>
f010413f:	83 ec 0c             	sub    $0xc,%esp
f0104142:	6b c0 74             	imul   $0x74,%eax,%eax
f0104145:	ff b0 28 00 26 f0    	pushl  -0xfd9ffd8(%eax)
f010414b:	e8 87 f2 ff ff       	call   f01033d7 <env_destroy>
f0104150:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104153:	e8 f2 19 00 00       	call   f0105b4a <cpunum>
f0104158:	6b c0 74             	imul   $0x74,%eax,%eax
f010415b:	83 b8 28 00 26 f0 00 	cmpl   $0x0,-0xfd9ffd8(%eax)
f0104162:	74 2a                	je     f010418e <trap+0x23f>
f0104164:	e8 e1 19 00 00       	call   f0105b4a <cpunum>
f0104169:	6b c0 74             	imul   $0x74,%eax,%eax
f010416c:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f0104172:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104176:	75 16                	jne    f010418e <trap+0x23f>
		env_run(curenv);
f0104178:	e8 cd 19 00 00       	call   f0105b4a <cpunum>
f010417d:	83 ec 0c             	sub    $0xc,%esp
f0104180:	6b c0 74             	imul   $0x74,%eax,%eax
f0104183:	ff b0 28 00 26 f0    	pushl  -0xfd9ffd8(%eax)
f0104189:	e8 e8 f2 ff ff       	call   f0103476 <env_run>
	else
		sched_yield();
f010418e:	e8 73 01 00 00       	call   f0104306 <sched_yield>
f0104193:	90                   	nop

f0104194 <divide_error>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

	TRAPHANDLER_NOEC(divide_error, 0)
f0104194:	6a 00                	push   $0x0
f0104196:	6a 00                	push   $0x0
f0104198:	e9 83 00 00 00       	jmp    f0104220 <_alltraps>
f010419d:	90                   	nop

f010419e <debug_exception>:
        TRAPHANDLER_NOEC(debug_exception, 1)
f010419e:	6a 00                	push   $0x0
f01041a0:	6a 01                	push   $0x1
f01041a2:	eb 7c                	jmp    f0104220 <_alltraps>

f01041a4 <non_maskable_interrupt>:
        TRAPHANDLER_NOEC(non_maskable_interrupt, 2)    
f01041a4:	6a 00                	push   $0x0
f01041a6:	6a 02                	push   $0x2
f01041a8:	eb 76                	jmp    f0104220 <_alltraps>

f01041aa <break_point>:
        TRAPHANDLER_NOEC(break_point, 3)
f01041aa:	6a 00                	push   $0x0
f01041ac:	6a 03                	push   $0x3
f01041ae:	eb 70                	jmp    f0104220 <_alltraps>

f01041b0 <over_flow>:
        TRAPHANDLER_NOEC(over_flow, 4)
f01041b0:	6a 00                	push   $0x0
f01041b2:	6a 04                	push   $0x4
f01041b4:	eb 6a                	jmp    f0104220 <_alltraps>

f01041b6 <bounds_check>:
        TRAPHANDLER_NOEC(bounds_check, 5)
f01041b6:	6a 00                	push   $0x0
f01041b8:	6a 05                	push   $0x5
f01041ba:	eb 64                	jmp    f0104220 <_alltraps>

f01041bc <illegal_opcode>:
        TRAPHANDLER_NOEC(illegal_opcode, 6)
f01041bc:	6a 00                	push   $0x0
f01041be:	6a 06                	push   $0x6
f01041c0:	eb 5e                	jmp    f0104220 <_alltraps>

f01041c2 <device_not_available>:
        TRAPHANDLER_NOEC(device_not_available, 7)
f01041c2:	6a 00                	push   $0x0
f01041c4:	6a 07                	push   $0x7
f01041c6:	eb 58                	jmp    f0104220 <_alltraps>

f01041c8 <double_fault>:
        TRAPHANDLER(double_fault, 8)
f01041c8:	6a 08                	push   $0x8
f01041ca:	eb 54                	jmp    f0104220 <_alltraps>

f01041cc <task_segment_switch>:
    
        TRAPHANDLER(task_segment_switch, 10)
f01041cc:	6a 0a                	push   $0xa
f01041ce:	eb 50                	jmp    f0104220 <_alltraps>

f01041d0 <segment_not_present>:
        TRAPHANDLER(segment_not_present, 11)
f01041d0:	6a 0b                	push   $0xb
f01041d2:	eb 4c                	jmp    f0104220 <_alltraps>

f01041d4 <stack_exception>:
        TRAPHANDLER(stack_exception, 12)
f01041d4:	6a 0c                	push   $0xc
f01041d6:	eb 48                	jmp    f0104220 <_alltraps>

f01041d8 <general_protection_fault>:
        TRAPHANDLER(general_protection_fault, 13)
f01041d8:	6a 0d                	push   $0xd
f01041da:	eb 44                	jmp    f0104220 <_alltraps>

f01041dc <page_fault>:
        TRAPHANDLER(page_fault, 14)
f01041dc:	6a 0e                	push   $0xe
f01041de:	eb 40                	jmp    f0104220 <_alltraps>

f01041e0 <floating_point_error>:
    
        TRAPHANDLER_NOEC(floating_point_error, 16)
f01041e0:	6a 00                	push   $0x0
f01041e2:	6a 10                	push   $0x10
f01041e4:	eb 3a                	jmp    f0104220 <_alltraps>

f01041e6 <alignment_check>:
        TRAPHANDLER(alignment_check, 17)
f01041e6:	6a 11                	push   $0x11
f01041e8:	eb 36                	jmp    f0104220 <_alltraps>

f01041ea <machine_check>:
        TRAPHANDLER_NOEC(machine_check, 18)
f01041ea:	6a 00                	push   $0x0
f01041ec:	6a 12                	push   $0x12
f01041ee:	eb 30                	jmp    f0104220 <_alltraps>

f01041f0 <simd_floating_point_error>:
        TRAPHANDLER_NOEC(simd_floating_point_error, 19)
f01041f0:	6a 00                	push   $0x0
f01041f2:	6a 13                	push   $0x13
f01041f4:	eb 2a                	jmp    f0104220 <_alltraps>

f01041f6 <system_call>:
        TRAPHANDLER_NOEC(system_call, 48)
f01041f6:	6a 00                	push   $0x0
f01041f8:	6a 30                	push   $0x30
f01041fa:	eb 24                	jmp    f0104220 <_alltraps>

f01041fc <fun_timer>:
        TRAPHANDLER_NOEC(fun_timer, IRQ_OFFSET + IRQ_TIMER)
f01041fc:	6a 00                	push   $0x0
f01041fe:	6a 20                	push   $0x20
f0104200:	eb 1e                	jmp    f0104220 <_alltraps>

f0104202 <fun_kbd>:
        TRAPHANDLER_NOEC(fun_kbd, IRQ_OFFSET + IRQ_KBD)
f0104202:	6a 00                	push   $0x0
f0104204:	6a 21                	push   $0x21
f0104206:	eb 18                	jmp    f0104220 <_alltraps>

f0104208 <fun_spurious>:
        TRAPHANDLER_NOEC(fun_spurious, IRQ_OFFSET + IRQ_SPURIOUS)
f0104208:	6a 00                	push   $0x0
f010420a:	6a 27                	push   $0x27
f010420c:	eb 12                	jmp    f0104220 <_alltraps>

f010420e <fun_error>:
        TRAPHANDLER_NOEC(fun_error, IRQ_OFFSET + IRQ_ERROR)
f010420e:	6a 00                	push   $0x0
f0104210:	6a 33                	push   $0x33
f0104212:	eb 0c                	jmp    f0104220 <_alltraps>

f0104214 <fun_ide>:
        TRAPHANDLER_NOEC(fun_ide, IRQ_OFFSET + IRQ_IDE)
f0104214:	6a 00                	push   $0x0
f0104216:	6a 2e                	push   $0x2e
f0104218:	eb 06                	jmp    f0104220 <_alltraps>

f010421a <fun_serial>:
        TRAPHANDLER_NOEC(fun_serial, IRQ_OFFSET + IRQ_SERIAL)
f010421a:	6a 00                	push   $0x0
f010421c:	6a 24                	push   $0x24
f010421e:	eb 00                	jmp    f0104220 <_alltraps>

f0104220 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
   
    pushl %ds
f0104220:	1e                   	push   %ds
    
    pushl %es
f0104221:	06                   	push   %es
    
    pushal
f0104222:	60                   	pusha  
    
    movl $GD_KD,%eax
f0104223:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax,%ds
f0104228:	8e d8                	mov    %eax,%ds
    movw %ax,%es   
f010422a:	8e c0                	mov    %eax,%es
    
    pushl %esp
f010422c:	54                   	push   %esp
    call trap
f010422d:	e8 1d fd ff ff       	call   f0103f4f <trap>

f0104232 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104232:	55                   	push   %ebp
f0104233:	89 e5                	mov    %esp,%ebp
f0104235:	83 ec 08             	sub    $0x8,%esp
f0104238:	a1 48 f2 25 f0       	mov    0xf025f248,%eax
f010423d:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104240:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104245:	8b 02                	mov    (%edx),%eax
f0104247:	83 e8 01             	sub    $0x1,%eax
f010424a:	83 f8 02             	cmp    $0x2,%eax
f010424d:	76 10                	jbe    f010425f <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010424f:	83 c1 01             	add    $0x1,%ecx
f0104252:	83 c2 7c             	add    $0x7c,%edx
f0104255:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010425b:	75 e8                	jne    f0104245 <sched_halt+0x13>
f010425d:	eb 08                	jmp    f0104267 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f010425f:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104265:	75 1f                	jne    f0104286 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0104267:	83 ec 0c             	sub    $0xc,%esp
f010426a:	68 f0 7e 10 f0       	push   $0xf0107ef0
f010426f:	e8 70 f4 ff ff       	call   f01036e4 <cprintf>
f0104274:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104277:	83 ec 0c             	sub    $0xc,%esp
f010427a:	6a 00                	push   $0x0
f010427c:	e8 e5 c6 ff ff       	call   f0100966 <monitor>
f0104281:	83 c4 10             	add    $0x10,%esp
f0104284:	eb f1                	jmp    f0104277 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104286:	e8 bf 18 00 00       	call   f0105b4a <cpunum>
f010428b:	6b c0 74             	imul   $0x74,%eax,%eax
f010428e:	c7 80 28 00 26 f0 00 	movl   $0x0,-0xfd9ffd8(%eax)
f0104295:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104298:	a1 a4 fe 25 f0       	mov    0xf025fea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010429d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01042a2:	77 12                	ja     f01042b6 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01042a4:	50                   	push   %eax
f01042a5:	68 88 67 10 f0       	push   $0xf0106788
f01042aa:	6a 67                	push   $0x67
f01042ac:	68 19 7f 10 f0       	push   $0xf0107f19
f01042b1:	e8 8a bd ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01042b6:	05 00 00 00 10       	add    $0x10000000,%eax
f01042bb:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01042be:	e8 87 18 00 00       	call   f0105b4a <cpunum>
f01042c3:	6b d0 74             	imul   $0x74,%eax,%edx
f01042c6:	81 c2 20 00 26 f0    	add    $0xf0260020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01042cc:	b8 02 00 00 00       	mov    $0x2,%eax
f01042d1:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01042d5:	83 ec 0c             	sub    $0xc,%esp
f01042d8:	68 c0 23 12 f0       	push   $0xf01223c0
f01042dd:	e8 73 1b 00 00       	call   f0105e55 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01042e2:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01042e4:	e8 61 18 00 00       	call   f0105b4a <cpunum>
f01042e9:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01042ec:	8b 80 30 00 26 f0    	mov    -0xfd9ffd0(%eax),%eax
f01042f2:	bd 00 00 00 00       	mov    $0x0,%ebp
f01042f7:	89 c4                	mov    %eax,%esp
f01042f9:	6a 00                	push   $0x0
f01042fb:	6a 00                	push   $0x0
f01042fd:	fb                   	sti    
f01042fe:	f4                   	hlt    
f01042ff:	eb fd                	jmp    f01042fe <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104301:	83 c4 10             	add    $0x10,%esp
f0104304:	c9                   	leave  
f0104305:	c3                   	ret    

f0104306 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104306:	55                   	push   %ebp
f0104307:	89 e5                	mov    %esp,%ebp
f0104309:	56                   	push   %esi
f010430a:	53                   	push   %ebx
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	if( curenv == NULL)
f010430b:	e8 3a 18 00 00       	call   f0105b4a <cpunum>
f0104310:	6b c0 74             	imul   $0x74,%eax,%eax
f0104313:	83 b8 28 00 26 f0 00 	cmpl   $0x0,-0xfd9ffd8(%eax)
f010431a:	75 07                	jne    f0104323 <sched_yield+0x1d>
	{
		idle = envs;
f010431c:	a1 48 f2 25 f0       	mov    0xf025f248,%eax
f0104321:	eb 11                	jmp    f0104334 <sched_yield+0x2e>
		//tmp = envs+(NENV*sizeof(struct Env));
	} else {
		idle = curenv+1;//sizeof(struct Env);
f0104323:	e8 22 18 00 00       	call   f0105b4a <cpunum>
f0104328:	6b c0 74             	imul   $0x74,%eax,%eax
f010432b:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f0104331:	83 c0 7c             	add    $0x7c,%eax
		{
			env_run(idle);
			return;
		}
		//idle ++;//= sizeof(struct Env);
		if(idle >= (envs+NENV))
f0104334:	8b 1d 48 f2 25 f0    	mov    0xf025f248,%ebx
f010433a:	8d b3 00 f0 01 00    	lea    0x1f000(%ebx),%esi
f0104340:	ba 00 04 00 00       	mov    $0x400,%edx
		idle = curenv+1;//sizeof(struct Env);
		//tmp = curenv;
	}
	while(i<1024)
	{
		if(idle->env_status == ENV_RUNNABLE)
f0104345:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104349:	75 09                	jne    f0104354 <sched_yield+0x4e>
		{
			env_run(idle);
f010434b:	83 ec 0c             	sub    $0xc,%esp
f010434e:	50                   	push   %eax
f010434f:	e8 22 f1 ff ff       	call   f0103476 <env_run>
		if(idle >= (envs+NENV))
//		if(ENVX(idle->env_id) == (NENV-1))
                {
                        idle = envs;
                } else {
			idle++;
f0104354:	8d 48 7c             	lea    0x7c(%eax),%ecx
f0104357:	39 c6                	cmp    %eax,%esi
f0104359:	89 c8                	mov    %ecx,%eax
f010435b:	0f 46 c3             	cmovbe %ebx,%eax
		//tmp = envs+(NENV*sizeof(struct Env));
	} else {
		idle = curenv+1;//sizeof(struct Env);
		//tmp = curenv;
	}
	while(i<1024)
f010435e:	83 ea 01             	sub    $0x1,%edx
f0104361:	75 e2                	jne    f0104345 <sched_yield+0x3f>
                } else {
			idle++;
		}
		i++;
	}
	if(curenv != NULL && curenv->env_status == ENV_RUNNING)
f0104363:	e8 e2 17 00 00       	call   f0105b4a <cpunum>
f0104368:	6b c0 74             	imul   $0x74,%eax,%eax
f010436b:	83 b8 28 00 26 f0 00 	cmpl   $0x0,-0xfd9ffd8(%eax)
f0104372:	74 2a                	je     f010439e <sched_yield+0x98>
f0104374:	e8 d1 17 00 00       	call   f0105b4a <cpunum>
f0104379:	6b c0 74             	imul   $0x74,%eax,%eax
f010437c:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f0104382:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104386:	75 16                	jne    f010439e <sched_yield+0x98>
	{
		env_run(curenv);
f0104388:	e8 bd 17 00 00       	call   f0105b4a <cpunum>
f010438d:	83 ec 0c             	sub    $0xc,%esp
f0104390:	6b c0 74             	imul   $0x74,%eax,%eax
f0104393:	ff b0 28 00 26 f0    	pushl  -0xfd9ffd8(%eax)
f0104399:	e8 d8 f0 ff ff       	call   f0103476 <env_run>
	
	if (curenv != NULL && curenv->env_status == ENV_RUNNING)
env_run(curenv);*/

	// sched_halt never returns
	sched_halt();
f010439e:	e8 8f fe ff ff       	call   f0104232 <sched_halt>
}
f01043a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01043a6:	5b                   	pop    %ebx
f01043a7:	5e                   	pop    %esi
f01043a8:	5d                   	pop    %ebp
f01043a9:	c3                   	ret    

f01043aa <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01043aa:	55                   	push   %ebp
f01043ab:	89 e5                	mov    %esp,%ebp
f01043ad:	57                   	push   %edi
f01043ae:	56                   	push   %esi
f01043af:	53                   	push   %ebx
f01043b0:	83 ec 1c             	sub    $0x1c,%esp
f01043b3:	8b 45 08             	mov    0x8(%ebp),%eax
	// LAB 3: Your code here.
	
	//panic("syscall not implemented");
	int env_des;
	//cprintf("in syscall:%u",syscallno);
	switch (syscallno) 
f01043b6:	83 f8 0f             	cmp    $0xf,%eax
f01043b9:	0f 87 e5 05 00 00    	ja     f01049a4 <syscall+0x5fa>
f01043bf:	ff 24 85 7c 7f 10 f0 	jmp    *-0xfef8084(,%eax,4)
			break;
		default:
			return -E_INVAL;
	}
	
	return 0;
f01043c6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01043cb:	e9 e0 05 00 00       	jmp    f01049b0 <syscall+0x606>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (void *)s, len, PTE_U);
f01043d0:	e8 75 17 00 00       	call   f0105b4a <cpunum>
f01043d5:	6a 04                	push   $0x4
f01043d7:	ff 75 10             	pushl  0x10(%ebp)
f01043da:	ff 75 0c             	pushl  0xc(%ebp)
f01043dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01043e0:	ff b0 28 00 26 f0    	pushl  -0xfd9ffd8(%eax)
f01043e6:	e8 68 e9 ff ff       	call   f0102d53 <user_mem_assert>
	//cprintf("\nIn the syscall\nValue of s:%x\nLen VAL:%u",s,len);
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01043eb:	83 c4 0c             	add    $0xc,%esp
f01043ee:	ff 75 0c             	pushl  0xc(%ebp)
f01043f1:	ff 75 10             	pushl  0x10(%ebp)
f01043f4:	68 26 7f 10 f0       	push   $0xf0107f26
f01043f9:	e8 e6 f2 ff ff       	call   f01036e4 <cprintf>
f01043fe:	83 c4 10             	add    $0x10,%esp
	//cprintf("in syscall:%u",syscallno);
	switch (syscallno) 
	{
		case SYS_cputs:
			sys_cputs((const char *)a1, a2);
			return 0;		
f0104401:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104406:	e9 a5 05 00 00       	jmp    f01049b0 <syscall+0x606>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010440b:	e8 22 c2 ff ff       	call   f0100632 <cons_getc>
		case SYS_cputs:
			sys_cputs((const char *)a1, a2);
			return 0;		
		case SYS_cgetc:
			sys_cgetc();
			return 0;
f0104410:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104415:	e9 96 05 00 00       	jmp    f01049b0 <syscall+0x606>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010441a:	e8 2b 17 00 00       	call   f0105b4a <cpunum>
f010441f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104422:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f0104428:	8b 58 48             	mov    0x48(%eax),%ebx
			return 0;		
		case SYS_cgetc:
			sys_cgetc();
			return 0;
		case SYS_getenvid:
			return sys_getenvid();
f010442b:	e9 80 05 00 00       	jmp    f01049b0 <syscall+0x606>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;
	//cprintf("Env Destroy, envid:[%08x]",envid);
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104430:	83 ec 04             	sub    $0x4,%esp
f0104433:	6a 01                	push   $0x1
f0104435:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104438:	50                   	push   %eax
f0104439:	ff 75 0c             	pushl  0xc(%ebp)
f010443c:	e8 fd e9 ff ff       	call   f0102e3e <envid2env>
f0104441:	83 c4 10             	add    $0x10,%esp
		return r;
f0104444:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;
	//cprintf("Env Destroy, envid:[%08x]",envid);
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104446:	85 c0                	test   %eax,%eax
f0104448:	0f 88 62 05 00 00    	js     f01049b0 <syscall+0x606>
		return r;
	env_destroy(e);
f010444e:	83 ec 0c             	sub    $0xc,%esp
f0104451:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104454:	e8 7e ef ff ff       	call   f01033d7 <env_destroy>
f0104459:	83 c4 10             	add    $0x10,%esp
	return 0;
f010445c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104461:	e9 4a 05 00 00       	jmp    f01049b0 <syscall+0x606>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104466:	e8 9b fe ff ff       	call   f0104306 <sched_yield>
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	if((uintptr_t)va >= UTOP || (((uintptr_t)va % PGSIZE) != 0))
f010446b:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104472:	77 76                	ja     f01044ea <syscall+0x140>
f0104474:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010447b:	75 77                	jne    f01044f4 <syscall+0x14a>
		return -E_INVAL;

	if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
f010447d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104480:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104485:	83 f8 05             	cmp    $0x5,%eax
f0104488:	75 74                	jne    f01044fe <syscall+0x154>
		return -E_INVAL;
	
	struct Env * e;
	if(!(envid2env(envid, &e, true)))
f010448a:	83 ec 04             	sub    $0x4,%esp
f010448d:	6a 01                	push   $0x1
f010448f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104492:	50                   	push   %eax
f0104493:	ff 75 0c             	pushl  0xc(%ebp)
f0104496:	e8 a3 e9 ff ff       	call   f0102e3e <envid2env>
f010449b:	83 c4 10             	add    $0x10,%esp
f010449e:	85 c0                	test   %eax,%eax
f01044a0:	75 66                	jne    f0104508 <syscall+0x15e>
	{
		struct PageInfo * pp = page_alloc(ALLOC_ZERO);
f01044a2:	83 ec 0c             	sub    $0xc,%esp
f01044a5:	6a 01                	push   $0x1
f01044a7:	e8 7b ca ff ff       	call   f0100f27 <page_alloc>
f01044ac:	89 c6                	mov    %eax,%esi
		if(pp)
f01044ae:	83 c4 10             	add    $0x10,%esp
f01044b1:	85 c0                	test   %eax,%eax
f01044b3:	74 5d                	je     f0104512 <syscall+0x168>
		{
		//	cprintf("\nIn sys_page_alloc\n");
			if((page_insert(e->env_pgdir, pp, va, perm)) == 0)
f01044b5:	ff 75 14             	pushl  0x14(%ebp)
f01044b8:	ff 75 10             	pushl  0x10(%ebp)
f01044bb:	50                   	push   %eax
f01044bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01044bf:	ff 70 60             	pushl  0x60(%eax)
f01044c2:	e8 e9 cc ff ff       	call   f01011b0 <page_insert>
f01044c7:	89 c3                	mov    %eax,%ebx
f01044c9:	83 c4 10             	add    $0x10,%esp
f01044cc:	85 c0                	test   %eax,%eax
f01044ce:	0f 84 dc 04 00 00    	je     f01049b0 <syscall+0x606>
				return 0;
			else
			{
				page_free(pp);
f01044d4:	83 ec 0c             	sub    $0xc,%esp
f01044d7:	56                   	push   %esi
f01044d8:	e8 ba ca ff ff       	call   f0100f97 <page_free>
f01044dd:	83 c4 10             	add    $0x10,%esp
				return -E_NO_MEM;		
f01044e0:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01044e5:	e9 c6 04 00 00       	jmp    f01049b0 <syscall+0x606>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	if((uintptr_t)va >= UTOP || (((uintptr_t)va % PGSIZE) != 0))
		return -E_INVAL;
f01044ea:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01044ef:	e9 bc 04 00 00       	jmp    f01049b0 <syscall+0x606>
f01044f4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01044f9:	e9 b2 04 00 00       	jmp    f01049b0 <syscall+0x606>

	if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
		return -E_INVAL;
f01044fe:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104503:	e9 a8 04 00 00       	jmp    f01049b0 <syscall+0x606>
		}
		else
			return -E_NO_MEM;
	}
	else
		return -E_BAD_ENV;
f0104508:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010450d:	e9 9e 04 00 00       	jmp    f01049b0 <syscall+0x606>
				page_free(pp);
				return -E_NO_MEM;		
			}
		}
		else
			return -E_NO_MEM;
f0104512:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
			return sys_env_destroy(a1);			
		case SYS_yield:
			sys_yield();
			break;
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, a3);
f0104517:	e9 94 04 00 00       	jmp    f01049b0 <syscall+0x606>
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	if((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP || (((uintptr_t)srcva%PGSIZE) != 0) || (((uintptr_t)dstva%PGSIZE) != 0))
f010451c:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104523:	0f 87 f0 00 00 00    	ja     f0104619 <syscall+0x26f>
f0104529:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104530:	0f 87 e3 00 00 00    	ja     f0104619 <syscall+0x26f>
f0104536:	8b 45 10             	mov    0x10(%ebp),%eax
f0104539:	0b 45 18             	or     0x18(%ebp),%eax
f010453c:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0104541:	0f 85 dc 00 00 00    	jne    f0104623 <syscall+0x279>
		return -E_INVAL;


	if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
f0104547:	8b 45 1c             	mov    0x1c(%ebp),%eax
f010454a:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f010454f:	83 f8 05             	cmp    $0x5,%eax
f0104552:	0f 85 d5 00 00 00    	jne    f010462d <syscall+0x283>
		return -E_INVAL;

	struct Env * src;
	struct Env * dst;
	if( !envid2env(srcenvid, &src, true) && !envid2env(dstenvid, &dst,  true))
f0104558:	83 ec 04             	sub    $0x4,%esp
f010455b:	6a 01                	push   $0x1
f010455d:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104560:	50                   	push   %eax
f0104561:	ff 75 0c             	pushl  0xc(%ebp)
f0104564:	e8 d5 e8 ff ff       	call   f0102e3e <envid2env>
f0104569:	83 c4 10             	add    $0x10,%esp
f010456c:	85 c0                	test   %eax,%eax
f010456e:	0f 85 c3 00 00 00    	jne    f0104637 <syscall+0x28d>
f0104574:	83 ec 04             	sub    $0x4,%esp
f0104577:	6a 01                	push   $0x1
f0104579:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010457c:	50                   	push   %eax
f010457d:	ff 75 14             	pushl  0x14(%ebp)
f0104580:	e8 b9 e8 ff ff       	call   f0102e3e <envid2env>
f0104585:	89 c6                	mov    %eax,%esi
f0104587:	83 c4 10             	add    $0x10,%esp
f010458a:	85 c0                	test   %eax,%eax
f010458c:	0f 85 af 00 00 00    	jne    f0104641 <syscall+0x297>
	{
		//cprintf("In sys_page_map\n");
		pte_t * pte;
		struct PageInfo * pp = page_lookup(src->env_pgdir, srcva, &pte);
f0104592:	83 ec 04             	sub    $0x4,%esp
f0104595:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104598:	50                   	push   %eax
f0104599:	ff 75 10             	pushl  0x10(%ebp)
f010459c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010459f:	ff 70 60             	pushl  0x60(%eax)
f01045a2:	e8 66 cb ff ff       	call   f010110d <page_lookup>
		if(pp)
f01045a7:	83 c4 10             	add    $0x10,%esp
f01045aa:	85 c0                	test   %eax,%eax
f01045ac:	74 61                	je     f010460f <syscall+0x265>
		{
			if(perm & PTE_W)
f01045ae:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f01045b1:	83 e3 02             	and    $0x2,%ebx
f01045b4:	74 35                	je     f01045eb <syscall+0x241>
						return -E_NO_MEM;
					else
						return 0;
				}
				else
					return -E_INVAL;
f01045b6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		struct PageInfo * pp = page_lookup(src->env_pgdir, srcva, &pte);
		if(pp)
		{
			if(perm & PTE_W)
			{
				if(*pte & PTE_W)
f01045bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01045be:	f6 02 02             	testb  $0x2,(%edx)
f01045c1:	0f 84 e9 03 00 00    	je     f01049b0 <syscall+0x606>
				{
					if(page_insert(dst->env_pgdir, pp, dstva, perm) < 0)
f01045c7:	ff 75 1c             	pushl  0x1c(%ebp)
f01045ca:	ff 75 18             	pushl  0x18(%ebp)
f01045cd:	50                   	push   %eax
f01045ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01045d1:	ff 70 60             	pushl  0x60(%eax)
f01045d4:	e8 d7 cb ff ff       	call   f01011b0 <page_insert>
f01045d9:	83 c4 10             	add    $0x10,%esp
						return -E_NO_MEM;
					else
						return 0;
f01045dc:	85 c0                	test   %eax,%eax
f01045de:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01045e3:	0f 49 de             	cmovns %esi,%ebx
f01045e6:	e9 c5 03 00 00       	jmp    f01049b0 <syscall+0x606>
				else
					return -E_INVAL;
			}
			else
			{
				if(page_insert(dst->env_pgdir, pp, dstva, perm) < 0)
f01045eb:	ff 75 1c             	pushl  0x1c(%ebp)
f01045ee:	ff 75 18             	pushl  0x18(%ebp)
f01045f1:	50                   	push   %eax
f01045f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01045f5:	ff 70 60             	pushl  0x60(%eax)
f01045f8:	e8 b3 cb ff ff       	call   f01011b0 <page_insert>
f01045fd:	83 c4 10             	add    $0x10,%esp
					return -E_NO_MEM;  	
f0104600:	85 c0                	test   %eax,%eax
f0104602:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104607:	0f 48 d8             	cmovs  %eax,%ebx
f010460a:	e9 a1 03 00 00       	jmp    f01049b0 <syscall+0x606>
				else
					return 0;
			}
		}
		else
			return -E_INVAL; 
f010460f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104614:	e9 97 03 00 00       	jmp    f01049b0 <syscall+0x606>
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	if((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP || (((uintptr_t)srcva%PGSIZE) != 0) || (((uintptr_t)dstva%PGSIZE) != 0))
		return -E_INVAL;
f0104619:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010461e:	e9 8d 03 00 00       	jmp    f01049b0 <syscall+0x606>
f0104623:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104628:	e9 83 03 00 00       	jmp    f01049b0 <syscall+0x606>


	if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
		return -E_INVAL;
f010462d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104632:	e9 79 03 00 00       	jmp    f01049b0 <syscall+0x606>
		}
		else
			return -E_INVAL; 
	}
	else 
		return -E_BAD_ENV;
f0104637:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010463c:	e9 6f 03 00 00       	jmp    f01049b0 <syscall+0x606>
f0104641:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
			break;
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, a3);
			break;
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
f0104646:	e9 65 03 00 00       	jmp    f01049b0 <syscall+0x606>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if((uintptr_t)va >= UTOP || (uintptr_t)va%PGSIZE != 0)
f010464b:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104652:	77 3c                	ja     f0104690 <syscall+0x2e6>
f0104654:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010465b:	75 3d                	jne    f010469a <syscall+0x2f0>
		return -E_INVAL;
	struct Env * e;
	if(!envid2env(envid, &e, true))
f010465d:	83 ec 04             	sub    $0x4,%esp
f0104660:	6a 01                	push   $0x1
f0104662:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104665:	50                   	push   %eax
f0104666:	ff 75 0c             	pushl  0xc(%ebp)
f0104669:	e8 d0 e7 ff ff       	call   f0102e3e <envid2env>
f010466e:	89 c3                	mov    %eax,%ebx
f0104670:	83 c4 10             	add    $0x10,%esp
f0104673:	85 c0                	test   %eax,%eax
f0104675:	75 2d                	jne    f01046a4 <syscall+0x2fa>
	{
		page_remove(e->env_pgdir, va);
f0104677:	83 ec 08             	sub    $0x8,%esp
f010467a:	ff 75 10             	pushl  0x10(%ebp)
f010467d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104680:	ff 70 60             	pushl  0x60(%eax)
f0104683:	e8 ed ca ff ff       	call   f0101175 <page_remove>
f0104688:	83 c4 10             	add    $0x10,%esp
f010468b:	e9 20 03 00 00       	jmp    f01049b0 <syscall+0x606>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if((uintptr_t)va >= UTOP || (uintptr_t)va%PGSIZE != 0)
		return -E_INVAL;
f0104690:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104695:	e9 16 03 00 00       	jmp    f01049b0 <syscall+0x606>
f010469a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010469f:	e9 0c 03 00 00       	jmp    f01049b0 <syscall+0x606>
	{
		page_remove(e->env_pgdir, va);
		return 0;
	}
	else
		return -E_BAD_ENV;
f01046a4:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
			break;
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
			break;
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
f01046a9:	e9 02 03 00 00       	jmp    f01049b0 <syscall+0x606>

	// LAB 4: Your code here.
	struct Env * e;
	//cprintf("\nIn Exo Fork. Should be called once.\n");
	int r;
	if((r = env_alloc(&e, curenv->env_id)) == 0)
f01046ae:	e8 97 14 00 00       	call   f0105b4a <cpunum>
f01046b3:	83 ec 08             	sub    $0x8,%esp
f01046b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01046b9:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f01046bf:	ff 70 48             	pushl  0x48(%eax)
f01046c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046c5:	50                   	push   %eax
f01046c6:	e8 a7 e8 ff ff       	call   f0102f72 <env_alloc>
f01046cb:	83 c4 10             	add    $0x10,%esp
		e->env_tf = curenv->env_tf;
		e->env_tf.tf_regs.reg_eax = 0;	
	}
	else
	{
		return r;
f01046ce:	89 c3                	mov    %eax,%ebx

	// LAB 4: Your code here.
	struct Env * e;
	//cprintf("\nIn Exo Fork. Should be called once.\n");
	int r;
	if((r = env_alloc(&e, curenv->env_id)) == 0)
f01046d0:	85 c0                	test   %eax,%eax
f01046d2:	0f 85 d8 02 00 00    	jne    f01049b0 <syscall+0x606>
	{
		e->env_status = ENV_NOT_RUNNABLE;
f01046d8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01046db:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
		//memmove((void *) &e->env_tf, (void *) &curenv->env_tf, sizeof(struct Trapframe));
		//cprintf("\nValue of new env's ip:%x\n",e->env_tf.tf_eip);
		e->env_tf = curenv->env_tf;
f01046e2:	e8 63 14 00 00       	call   f0105b4a <cpunum>
f01046e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01046ea:	8b b0 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%esi
f01046f0:	b9 11 00 00 00       	mov    $0x11,%ecx
f01046f5:	89 df                	mov    %ebx,%edi
f01046f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		e->env_tf.tf_regs.reg_eax = 0;	
f01046f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046fc:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	else
	{
		return r;
	}
	
	return e->env_id;
f0104703:	8b 58 48             	mov    0x48(%eax),%ebx
f0104706:	e9 a5 02 00 00       	jmp    f01049b0 <syscall+0x606>
	// envid's status.

	// LAB 4: Your code here.
	struct Env * e;
	//cprintf("\nStatus:%d",status);
	if(!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
f010470b:	8b 45 10             	mov    0x10(%ebp),%eax
f010470e:	83 e8 02             	sub    $0x2,%eax
f0104711:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104716:	75 28                	jne    f0104740 <syscall+0x396>
		return -E_INVAL;
	if(!(envid2env(envid, &e, true)))
f0104718:	83 ec 04             	sub    $0x4,%esp
f010471b:	6a 01                	push   $0x1
f010471d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104720:	50                   	push   %eax
f0104721:	ff 75 0c             	pushl  0xc(%ebp)
f0104724:	e8 15 e7 ff ff       	call   f0102e3e <envid2env>
f0104729:	89 c3                	mov    %eax,%ebx
f010472b:	83 c4 10             	add    $0x10,%esp
f010472e:	85 c0                	test   %eax,%eax
f0104730:	75 18                	jne    f010474a <syscall+0x3a0>
	{		
		e->env_status = status;
f0104732:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104735:	8b 55 10             	mov    0x10(%ebp),%edx
f0104738:	89 50 54             	mov    %edx,0x54(%eax)
f010473b:	e9 70 02 00 00       	jmp    f01049b0 <syscall+0x606>

	// LAB 4: Your code here.
	struct Env * e;
	//cprintf("\nStatus:%d",status);
	if(!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
		return -E_INVAL;
f0104740:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104745:	e9 66 02 00 00       	jmp    f01049b0 <syscall+0x606>
	{		
		e->env_status = status;
		return 0;
	}
	else
		return -E_BAD_ENV;
f010474a:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
			break;
		case SYS_exofork:
			return sys_exofork();
			break;
		case SYS_env_set_status:
			return sys_env_set_status(a1,a2);
f010474f:	e9 5c 02 00 00       	jmp    f01049b0 <syscall+0x606>
{
	// LAB 4: Your code here.
	//panic("sys_env_set_pgfault_upcall not implemented");
	struct Env *e;

	if (!(envid2env(envid, &e, 1)))
f0104754:	83 ec 04             	sub    $0x4,%esp
f0104757:	6a 01                	push   $0x1
f0104759:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010475c:	50                   	push   %eax
f010475d:	ff 75 0c             	pushl  0xc(%ebp)
f0104760:	e8 d9 e6 ff ff       	call   f0102e3e <envid2env>
f0104765:	89 c3                	mov    %eax,%ebx
f0104767:	83 c4 10             	add    $0x10,%esp
f010476a:	85 c0                	test   %eax,%eax
f010476c:	75 0e                	jne    f010477c <syscall+0x3d2>
		e->env_pgfault_upcall = func;
f010476e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104771:	8b 55 10             	mov    0x10(%ebp),%edx
f0104774:	89 50 64             	mov    %edx,0x64(%eax)
f0104777:	e9 34 02 00 00       	jmp    f01049b0 <syscall+0x606>
	else
		return -E_BAD_ENV;
f010477c:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
			return sys_exofork();
			break;
		case SYS_env_set_status:
			return sys_env_set_status(a1,a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void *)a2);
f0104781:	e9 2a 02 00 00       	jmp    f01049b0 <syscall+0x606>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uint32_t) dstva < UTOP) 
f0104786:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f010478d:	77 23                	ja     f01047b2 <syscall+0x408>
	{
		if ((uint32_t) dstva % PGSIZE != 0)
f010478f:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104796:	0f 85 0f 02 00 00    	jne    f01049ab <syscall+0x601>
			return -E_INVAL;
		curenv->env_ipc_dstva = dstva;
f010479c:	e8 a9 13 00 00       	call   f0105b4a <cpunum>
f01047a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01047a4:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f01047aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01047ad:	89 48 6c             	mov    %ecx,0x6c(%eax)
f01047b0:	eb 15                	jmp    f01047c7 <syscall+0x41d>
	} 
	else
		curenv->env_ipc_dstva = (void *) 0xF0000000;
f01047b2:	e8 93 13 00 00       	call   f0105b4a <cpunum>
f01047b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01047ba:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f01047c0:	c7 40 6c 00 00 00 f0 	movl   $0xf0000000,0x6c(%eax)
		
	curenv->env_ipc_dstva = dstva;
f01047c7:	e8 7e 13 00 00       	call   f0105b4a <cpunum>
f01047cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01047cf:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f01047d5:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01047d8:	89 78 6c             	mov    %edi,0x6c(%eax)
	curenv->env_ipc_recving = true;
f01047db:	e8 6a 13 00 00       	call   f0105b4a <cpunum>
f01047e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01047e3:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f01047e9:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f01047ed:	e8 58 13 00 00       	call   f0105b4a <cpunum>
f01047f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01047f5:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f01047fb:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	//curenv->env_tf.tf_regs.reg_eax = 0;
	sched_yield();
f0104802:	e8 ff fa ff ff       	call   f0104306 <sched_yield>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env * targetEnv;
	if (envid2env(envid, &targetEnv, 0))
f0104807:	83 ec 04             	sub    $0x4,%esp
f010480a:	6a 00                	push   $0x0
f010480c:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010480f:	50                   	push   %eax
f0104810:	ff 75 0c             	pushl  0xc(%ebp)
f0104813:	e8 26 e6 ff ff       	call   f0102e3e <envid2env>
f0104818:	89 c3                	mov    %eax,%ebx
f010481a:	83 c4 10             	add    $0x10,%esp
f010481d:	85 c0                	test   %eax,%eax
f010481f:	0f 85 0a 01 00 00    	jne    f010492f <syscall+0x585>
		return -E_BAD_ENV;

	if(targetEnv->env_ipc_recving  == 0)
f0104825:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104828:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f010482c:	0f 84 04 01 00 00    	je     f0104936 <syscall+0x58c>
		return -E_IPC_NOT_RECV;

	if( (uint32_t)srcva < UTOP && ((uint32_t)srcva % PGSIZE != 0))
f0104832:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104839:	0f 87 b2 00 00 00    	ja     f01048f1 <syscall+0x547>
f010483f:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104846:	0f 85 f1 00 00 00    	jne    f010493d <syscall+0x593>
	

	// All the sender side checks are done.
	//Check for page_insert errors now and mark the destination environment ENV_RUNNABLE.

	if((uint32_t)targetEnv->env_ipc_dstva < UTOP && (uint32_t)srcva < UTOP)
f010484c:	81 78 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%eax)
f0104853:	0f 87 98 00 00 00    	ja     f01048f1 <syscall+0x547>
	{
		//int r;

		if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
f0104859:	8b 45 18             	mov    0x18(%ebp),%eax
f010485c:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104861:	83 f8 05             	cmp    $0x5,%eax
f0104864:	75 59                	jne    f01048bf <syscall+0x515>
		{
			//cprintf("Permission failure\n");
			return -E_INVAL;
		}	
		pte_t * pte;
		struct PageInfo * pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104866:	e8 df 12 00 00       	call   f0105b4a <cpunum>
f010486b:	83 ec 04             	sub    $0x4,%esp
f010486e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104871:	52                   	push   %edx
f0104872:	ff 75 14             	pushl  0x14(%ebp)
f0104875:	6b c0 74             	imul   $0x74,%eax,%eax
f0104878:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f010487e:	ff 70 60             	pushl  0x60(%eax)
f0104881:	e8 87 c8 ff ff       	call   f010110d <page_lookup>
		if(!pp)
f0104886:	83 c4 10             	add    $0x10,%esp
f0104889:	85 c0                	test   %eax,%eax
f010488b:	74 3c                	je     f01048c9 <syscall+0x51f>
			return -E_INVAL;
		if(!(perm & PTE_W && *pte & PTE_W))
f010488d:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104891:	74 40                	je     f01048d3 <syscall+0x529>
f0104893:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104896:	f6 02 02             	testb  $0x2,(%edx)
f0104899:	74 42                	je     f01048dd <syscall+0x533>
		{
			//cprintf("Permission failure in write\n");
			return -E_INVAL;
		}
		
		if((page_insert(targetEnv->env_pgdir, pp, targetEnv->env_ipc_dstva, perm)) < 0)
f010489b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010489e:	ff 75 18             	pushl  0x18(%ebp)
f01048a1:	ff 72 6c             	pushl  0x6c(%edx)
f01048a4:	50                   	push   %eax
f01048a5:	ff 72 60             	pushl  0x60(%edx)
f01048a8:	e8 03 c9 ff ff       	call   f01011b0 <page_insert>
f01048ad:	83 c4 10             	add    $0x10,%esp
f01048b0:	85 c0                	test   %eax,%eax
f01048b2:	78 33                	js     f01048e7 <syscall+0x53d>
			return -E_NO_MEM;	
		targetEnv->env_ipc_perm = perm;
f01048b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048b7:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01048ba:	89 48 78             	mov    %ecx,0x78(%eax)
f01048bd:	eb 39                	jmp    f01048f8 <syscall+0x54e>
		//int r;

		if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
		{
			//cprintf("Permission failure\n");
			return -E_INVAL;
f01048bf:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048c4:	e9 e7 00 00 00       	jmp    f01049b0 <syscall+0x606>
		}	
		pte_t * pte;
		struct PageInfo * pp = page_lookup(curenv->env_pgdir, srcva, &pte);
		if(!pp)
			return -E_INVAL;
f01048c9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048ce:	e9 dd 00 00 00       	jmp    f01049b0 <syscall+0x606>
		if(!(perm & PTE_W && *pte & PTE_W))
		{
			//cprintf("Permission failure in write\n");
			return -E_INVAL;
f01048d3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048d8:	e9 d3 00 00 00       	jmp    f01049b0 <syscall+0x606>
f01048dd:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048e2:	e9 c9 00 00 00       	jmp    f01049b0 <syscall+0x606>
		}
		
		if((page_insert(targetEnv->env_pgdir, pp, targetEnv->env_ipc_dstva, perm)) < 0)
			return -E_NO_MEM;	
f01048e7:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01048ec:	e9 bf 00 00 00       	jmp    f01049b0 <syscall+0x606>
		targetEnv->env_ipc_perm = perm;
	}
	else
		targetEnv->env_ipc_perm = 0;
f01048f1:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	

	targetEnv->env_ipc_recving = false;
f01048f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01048fb:	c6 46 68 00          	movb   $0x0,0x68(%esi)
	targetEnv->env_ipc_value = value;
f01048ff:	8b 45 10             	mov    0x10(%ebp),%eax
f0104902:	89 46 70             	mov    %eax,0x70(%esi)
	targetEnv->env_ipc_from = curenv->env_id;
f0104905:	e8 40 12 00 00       	call   f0105b4a <cpunum>
f010490a:	6b c0 74             	imul   $0x74,%eax,%eax
f010490d:	8b 80 28 00 26 f0    	mov    -0xfd9ffd8(%eax),%eax
f0104913:	8b 40 48             	mov    0x48(%eax),%eax
f0104916:	89 46 74             	mov    %eax,0x74(%esi)
	targetEnv->env_status = ENV_RUNNABLE;
f0104919:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010491c:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	targetEnv->env_tf.tf_regs.reg_eax = 0;
f0104923:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f010492a:	e9 81 00 00 00       	jmp    f01049b0 <syscall+0x606>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env * targetEnv;
	if (envid2env(envid, &targetEnv, 0))
		return -E_BAD_ENV;
f010492f:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104934:	eb 7a                	jmp    f01049b0 <syscall+0x606>

	if(targetEnv->env_ipc_recving  == 0)
		return -E_IPC_NOT_RECV;
f0104936:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f010493b:	eb 73                	jmp    f01049b0 <syscall+0x606>

	if( (uint32_t)srcva < UTOP && ((uint32_t)srcva % PGSIZE != 0))
	{
		//cprintf("srcva:%x\n",srcva);
		return -E_INVAL;
f010493d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return sys_env_set_pgfault_upcall(a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
			break;
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0104942:	eb 6c                	jmp    f01049b0 <syscall+0x606>
			case SYS_env_set_trapframe: 
			return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
f0104944:	8b 75 10             	mov    0x10(%ebp),%esi
	// address!
	//panic("sys_env_set_trapframe not implemented");
	int ret;
	struct Env *env;

	ret = envid2env(envid, &env, 1);
f0104947:	83 ec 04             	sub    $0x4,%esp
f010494a:	6a 01                	push   $0x1
f010494c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010494f:	50                   	push   %eax
f0104950:	ff 75 0c             	pushl  0xc(%ebp)
f0104953:	e8 e6 e4 ff ff       	call   f0102e3e <envid2env>
	if(ret < 0)
f0104958:	83 c4 10             	add    $0x10,%esp
f010495b:	85 c0                	test   %eax,%eax
f010495d:	79 17                	jns    f0104976 <syscall+0x5cc>
	{
panic("SRHS: envid2env is failing \n");
f010495f:	83 ec 04             	sub    $0x4,%esp
f0104962:	68 2b 7f 10 f0       	push   $0xf0107f2b
f0104967:	68 9a 00 00 00       	push   $0x9a
f010496c:	68 48 7f 10 f0       	push   $0xf0107f48
f0104971:	e8 ca b6 ff ff       	call   f0100040 <_panic>
		return ret;
	}
	if(tf == NULL)
f0104976:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010497a:	75 17                	jne    f0104993 <syscall+0x5e9>
	{
	panic("SRHS: return since tf is not null \n");
f010497c:	83 ec 04             	sub    $0x4,%esp
f010497f:	68 58 7f 10 f0       	push   $0xf0107f58
f0104984:	68 9f 00 00 00       	push   $0x9f
f0104989:	68 48 7f 10 f0       	push   $0xf0107f48
f010498e:	e8 ad b6 ff ff       	call   f0100040 <_panic>
		return -E_INVAL;
	}
	env->env_tf = *tf;
f0104993:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104998:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010499b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			return sys_ipc_recv((void *)a1);
			break;
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
			case SYS_env_set_trapframe: 
			return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
f010499d:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049a2:	eb 0c                	jmp    f01049b0 <syscall+0x606>
			break;
		case NSYSCALLS:
			break;
		default:
			return -E_INVAL;
f01049a4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049a9:	eb 05                	jmp    f01049b0 <syscall+0x606>
		case SYS_env_set_status:
			return sys_env_set_status(a1,a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f01049ab:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		default:
			return -E_INVAL;
	}
	
	return 0;
}
f01049b0:	89 d8                	mov    %ebx,%eax
f01049b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049b5:	5b                   	pop    %ebx
f01049b6:	5e                   	pop    %esi
f01049b7:	5f                   	pop    %edi
f01049b8:	5d                   	pop    %ebp
f01049b9:	c3                   	ret    

f01049ba <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01049ba:	55                   	push   %ebp
f01049bb:	89 e5                	mov    %esp,%ebp
f01049bd:	57                   	push   %edi
f01049be:	56                   	push   %esi
f01049bf:	53                   	push   %ebx
f01049c0:	83 ec 14             	sub    $0x14,%esp
f01049c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01049c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01049c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01049cc:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01049cf:	8b 1a                	mov    (%edx),%ebx
f01049d1:	8b 01                	mov    (%ecx),%eax
f01049d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01049d6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01049dd:	eb 7f                	jmp    f0104a5e <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01049df:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01049e2:	01 d8                	add    %ebx,%eax
f01049e4:	89 c6                	mov    %eax,%esi
f01049e6:	c1 ee 1f             	shr    $0x1f,%esi
f01049e9:	01 c6                	add    %eax,%esi
f01049eb:	d1 fe                	sar    %esi
f01049ed:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01049f0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01049f3:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01049f6:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01049f8:	eb 03                	jmp    f01049fd <stab_binsearch+0x43>
			m--;
f01049fa:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01049fd:	39 c3                	cmp    %eax,%ebx
f01049ff:	7f 0d                	jg     f0104a0e <stab_binsearch+0x54>
f0104a01:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104a05:	83 ea 0c             	sub    $0xc,%edx
f0104a08:	39 f9                	cmp    %edi,%ecx
f0104a0a:	75 ee                	jne    f01049fa <stab_binsearch+0x40>
f0104a0c:	eb 05                	jmp    f0104a13 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104a0e:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104a11:	eb 4b                	jmp    f0104a5e <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104a13:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104a16:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104a19:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104a1d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104a20:	76 11                	jbe    f0104a33 <stab_binsearch+0x79>
			*region_left = m;
f0104a22:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104a25:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104a27:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104a2a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104a31:	eb 2b                	jmp    f0104a5e <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104a33:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104a36:	73 14                	jae    f0104a4c <stab_binsearch+0x92>
			*region_right = m - 1;
f0104a38:	83 e8 01             	sub    $0x1,%eax
f0104a3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104a3e:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104a41:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104a43:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104a4a:	eb 12                	jmp    f0104a5e <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104a4c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104a4f:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104a51:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104a55:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104a57:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104a5e:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104a61:	0f 8e 78 ff ff ff    	jle    f01049df <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104a67:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104a6b:	75 0f                	jne    f0104a7c <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104a6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a70:	8b 00                	mov    (%eax),%eax
f0104a72:	83 e8 01             	sub    $0x1,%eax
f0104a75:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104a78:	89 06                	mov    %eax,(%esi)
f0104a7a:	eb 2c                	jmp    f0104aa8 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104a7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a7f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104a81:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104a84:	8b 0e                	mov    (%esi),%ecx
f0104a86:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104a89:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104a8c:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104a8f:	eb 03                	jmp    f0104a94 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104a91:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104a94:	39 c8                	cmp    %ecx,%eax
f0104a96:	7e 0b                	jle    f0104aa3 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104a98:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104a9c:	83 ea 0c             	sub    $0xc,%edx
f0104a9f:	39 df                	cmp    %ebx,%edi
f0104aa1:	75 ee                	jne    f0104a91 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104aa3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104aa6:	89 06                	mov    %eax,(%esi)
	}
}
f0104aa8:	83 c4 14             	add    $0x14,%esp
f0104aab:	5b                   	pop    %ebx
f0104aac:	5e                   	pop    %esi
f0104aad:	5f                   	pop    %edi
f0104aae:	5d                   	pop    %ebp
f0104aaf:	c3                   	ret    

f0104ab0 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104ab0:	55                   	push   %ebp
f0104ab1:	89 e5                	mov    %esp,%ebp
f0104ab3:	57                   	push   %edi
f0104ab4:	56                   	push   %esi
f0104ab5:	53                   	push   %ebx
f0104ab6:	83 ec 3c             	sub    $0x3c,%esp
f0104ab9:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104abc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104abf:	c7 03 bc 7f 10 f0    	movl   $0xf0107fbc,(%ebx)
	info->eip_line = 0;
f0104ac5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104acc:	c7 43 08 bc 7f 10 f0 	movl   $0xf0107fbc,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104ad3:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104ada:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104add:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104ae4:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104aea:	0f 87 a3 00 00 00    	ja     f0104b93 <debuginfo_eip+0xe3>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;
		
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U | PTE_P))
f0104af0:	e8 55 10 00 00       	call   f0105b4a <cpunum>
f0104af5:	6a 05                	push   $0x5
f0104af7:	6a 10                	push   $0x10
f0104af9:	68 00 00 20 00       	push   $0x200000
f0104afe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b01:	ff b0 28 00 26 f0    	pushl  -0xfd9ffd8(%eax)
f0104b07:	e8 bf e1 ff ff       	call   f0102ccb <user_mem_check>
f0104b0c:	83 c4 10             	add    $0x10,%esp
f0104b0f:	85 c0                	test   %eax,%eax
f0104b11:	0f 85 35 02 00 00    	jne    f0104d4c <debuginfo_eip+0x29c>
			return -1;

		
		stabs = usd->stabs;
f0104b17:	a1 00 00 20 00       	mov    0x200000,%eax
f0104b1c:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104b1f:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104b25:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104b2b:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104b2e:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104b33:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U | PTE_P) )
f0104b36:	e8 0f 10 00 00       	call   f0105b4a <cpunum>
f0104b3b:	6a 05                	push   $0x5
f0104b3d:	89 f2                	mov    %esi,%edx
f0104b3f:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104b42:	29 ca                	sub    %ecx,%edx
f0104b44:	c1 fa 02             	sar    $0x2,%edx
f0104b47:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104b4d:	52                   	push   %edx
f0104b4e:	51                   	push   %ecx
f0104b4f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b52:	ff b0 28 00 26 f0    	pushl  -0xfd9ffd8(%eax)
f0104b58:	e8 6e e1 ff ff       	call   f0102ccb <user_mem_check>
f0104b5d:	83 c4 10             	add    $0x10,%esp
f0104b60:	85 c0                	test   %eax,%eax
f0104b62:	0f 85 eb 01 00 00    	jne    f0104d53 <debuginfo_eip+0x2a3>
			return -1;
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U | PTE_P) )
f0104b68:	e8 dd 0f 00 00       	call   f0105b4a <cpunum>
f0104b6d:	6a 05                	push   $0x5
f0104b6f:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104b72:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104b75:	29 ca                	sub    %ecx,%edx
f0104b77:	52                   	push   %edx
f0104b78:	51                   	push   %ecx
f0104b79:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b7c:	ff b0 28 00 26 f0    	pushl  -0xfd9ffd8(%eax)
f0104b82:	e8 44 e1 ff ff       	call   f0102ccb <user_mem_check>
f0104b87:	83 c4 10             	add    $0x10,%esp
f0104b8a:	85 c0                	test   %eax,%eax
f0104b8c:	74 1f                	je     f0104bad <debuginfo_eip+0xfd>
f0104b8e:	e9 c7 01 00 00       	jmp    f0104d5a <debuginfo_eip+0x2aa>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104b93:	c7 45 bc 1c 77 11 f0 	movl   $0xf011771c,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104b9a:	c7 45 b8 05 37 11 f0 	movl   $0xf0113705,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104ba1:	be 04 37 11 f0       	mov    $0xf0113704,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104ba6:	c7 45 c0 a8 87 10 f0 	movl   $0xf01087a8,-0x40(%ebp)
			return -1;

	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104bad:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104bb0:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104bb3:	0f 83 a8 01 00 00    	jae    f0104d61 <debuginfo_eip+0x2b1>
f0104bb9:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104bbd:	0f 85 a5 01 00 00    	jne    f0104d68 <debuginfo_eip+0x2b8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104bc3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104bca:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104bcd:	c1 fe 02             	sar    $0x2,%esi
f0104bd0:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104bd6:	83 e8 01             	sub    $0x1,%eax
f0104bd9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104bdc:	83 ec 08             	sub    $0x8,%esp
f0104bdf:	57                   	push   %edi
f0104be0:	6a 64                	push   $0x64
f0104be2:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104be5:	89 d1                	mov    %edx,%ecx
f0104be7:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104bea:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104bed:	89 f0                	mov    %esi,%eax
f0104bef:	e8 c6 fd ff ff       	call   f01049ba <stab_binsearch>
	if (lfile == 0)
f0104bf4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bf7:	83 c4 10             	add    $0x10,%esp
f0104bfa:	85 c0                	test   %eax,%eax
f0104bfc:	0f 84 6d 01 00 00    	je     f0104d6f <debuginfo_eip+0x2bf>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104c02:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104c05:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c08:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104c0b:	83 ec 08             	sub    $0x8,%esp
f0104c0e:	57                   	push   %edi
f0104c0f:	6a 24                	push   $0x24
f0104c11:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104c14:	89 d1                	mov    %edx,%ecx
f0104c16:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104c19:	89 f0                	mov    %esi,%eax
f0104c1b:	e8 9a fd ff ff       	call   f01049ba <stab_binsearch>

	if (lfun <= rfun) {
f0104c20:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104c23:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104c26:	83 c4 10             	add    $0x10,%esp
f0104c29:	39 d0                	cmp    %edx,%eax
f0104c2b:	7f 2e                	jg     f0104c5b <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104c2d:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104c30:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104c33:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104c36:	8b 36                	mov    (%esi),%esi
f0104c38:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104c3b:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104c3e:	39 ce                	cmp    %ecx,%esi
f0104c40:	73 06                	jae    f0104c48 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104c42:	03 75 b8             	add    -0x48(%ebp),%esi
f0104c45:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104c48:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104c4b:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104c4e:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104c51:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104c53:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104c56:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104c59:	eb 0f                	jmp    f0104c6a <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104c5b:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104c5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c61:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104c64:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c67:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104c6a:	83 ec 08             	sub    $0x8,%esp
f0104c6d:	6a 3a                	push   $0x3a
f0104c6f:	ff 73 08             	pushl  0x8(%ebx)
f0104c72:	e8 97 08 00 00       	call   f010550e <strfind>
f0104c77:	2b 43 08             	sub    0x8(%ebx),%eax
f0104c7a:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104c7d:	83 c4 08             	add    $0x8,%esp
f0104c80:	57                   	push   %edi
f0104c81:	6a 44                	push   $0x44
f0104c83:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104c86:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104c89:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104c8c:	89 f8                	mov    %edi,%eax
f0104c8e:	e8 27 fd ff ff       	call   f01049ba <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0104c93:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104c96:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c99:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104c9c:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f0104ca0:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104ca3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ca6:	83 c4 10             	add    $0x10,%esp
f0104ca9:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104cad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104cb0:	eb 0a                	jmp    f0104cbc <debuginfo_eip+0x20c>
f0104cb2:	83 e8 01             	sub    $0x1,%eax
f0104cb5:	83 ea 0c             	sub    $0xc,%edx
f0104cb8:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104cbc:	39 c7                	cmp    %eax,%edi
f0104cbe:	7e 05                	jle    f0104cc5 <debuginfo_eip+0x215>
f0104cc0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cc3:	eb 47                	jmp    f0104d0c <debuginfo_eip+0x25c>
	       && stabs[lline].n_type != N_SOL
f0104cc5:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104cc9:	80 f9 84             	cmp    $0x84,%cl
f0104ccc:	75 0e                	jne    f0104cdc <debuginfo_eip+0x22c>
f0104cce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cd1:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104cd5:	74 1c                	je     f0104cf3 <debuginfo_eip+0x243>
f0104cd7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104cda:	eb 17                	jmp    f0104cf3 <debuginfo_eip+0x243>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104cdc:	80 f9 64             	cmp    $0x64,%cl
f0104cdf:	75 d1                	jne    f0104cb2 <debuginfo_eip+0x202>
f0104ce1:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104ce5:	74 cb                	je     f0104cb2 <debuginfo_eip+0x202>
f0104ce7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cea:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104cee:	74 03                	je     f0104cf3 <debuginfo_eip+0x243>
f0104cf0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104cf3:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104cf6:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104cf9:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104cfc:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104cff:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104d02:	29 f8                	sub    %edi,%eax
f0104d04:	39 c2                	cmp    %eax,%edx
f0104d06:	73 04                	jae    f0104d0c <debuginfo_eip+0x25c>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104d08:	01 fa                	add    %edi,%edx
f0104d0a:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104d0c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104d0f:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d12:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104d17:	39 f2                	cmp    %esi,%edx
f0104d19:	7d 60                	jge    f0104d7b <debuginfo_eip+0x2cb>
		for (lline = lfun + 1;
f0104d1b:	83 c2 01             	add    $0x1,%edx
f0104d1e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104d21:	89 d0                	mov    %edx,%eax
f0104d23:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104d26:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104d29:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104d2c:	eb 04                	jmp    f0104d32 <debuginfo_eip+0x282>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104d2e:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104d32:	39 c6                	cmp    %eax,%esi
f0104d34:	7e 40                	jle    f0104d76 <debuginfo_eip+0x2c6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104d36:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104d3a:	83 c0 01             	add    $0x1,%eax
f0104d3d:	83 c2 0c             	add    $0xc,%edx
f0104d40:	80 f9 a0             	cmp    $0xa0,%cl
f0104d43:	74 e9                	je     f0104d2e <debuginfo_eip+0x27e>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d45:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d4a:	eb 2f                	jmp    f0104d7b <debuginfo_eip+0x2cb>
		
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U | PTE_P))
			return -1;
f0104d4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d51:	eb 28                	jmp    f0104d7b <debuginfo_eip+0x2cb>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U | PTE_P) )
			return -1;
f0104d53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d58:	eb 21                	jmp    f0104d7b <debuginfo_eip+0x2cb>
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U | PTE_P) )
			return -1;
f0104d5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d5f:	eb 1a                	jmp    f0104d7b <debuginfo_eip+0x2cb>

	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104d61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d66:	eb 13                	jmp    f0104d7b <debuginfo_eip+0x2cb>
f0104d68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d6d:	eb 0c                	jmp    f0104d7b <debuginfo_eip+0x2cb>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104d6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d74:	eb 05                	jmp    f0104d7b <debuginfo_eip+0x2cb>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d76:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104d7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104d7e:	5b                   	pop    %ebx
f0104d7f:	5e                   	pop    %esi
f0104d80:	5f                   	pop    %edi
f0104d81:	5d                   	pop    %ebp
f0104d82:	c3                   	ret    

f0104d83 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104d83:	55                   	push   %ebp
f0104d84:	89 e5                	mov    %esp,%ebp
f0104d86:	57                   	push   %edi
f0104d87:	56                   	push   %esi
f0104d88:	53                   	push   %ebx
f0104d89:	83 ec 1c             	sub    $0x1c,%esp
f0104d8c:	89 c7                	mov    %eax,%edi
f0104d8e:	89 d6                	mov    %edx,%esi
f0104d90:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d93:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d96:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d99:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104d9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104d9f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104da4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104da7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104daa:	39 d3                	cmp    %edx,%ebx
f0104dac:	72 05                	jb     f0104db3 <printnum+0x30>
f0104dae:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104db1:	77 45                	ja     f0104df8 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104db3:	83 ec 0c             	sub    $0xc,%esp
f0104db6:	ff 75 18             	pushl  0x18(%ebp)
f0104db9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104dbc:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104dbf:	53                   	push   %ebx
f0104dc0:	ff 75 10             	pushl  0x10(%ebp)
f0104dc3:	83 ec 08             	sub    $0x8,%esp
f0104dc6:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104dc9:	ff 75 e0             	pushl  -0x20(%ebp)
f0104dcc:	ff 75 dc             	pushl  -0x24(%ebp)
f0104dcf:	ff 75 d8             	pushl  -0x28(%ebp)
f0104dd2:	e8 d9 16 00 00       	call   f01064b0 <__udivdi3>
f0104dd7:	83 c4 18             	add    $0x18,%esp
f0104dda:	52                   	push   %edx
f0104ddb:	50                   	push   %eax
f0104ddc:	89 f2                	mov    %esi,%edx
f0104dde:	89 f8                	mov    %edi,%eax
f0104de0:	e8 9e ff ff ff       	call   f0104d83 <printnum>
f0104de5:	83 c4 20             	add    $0x20,%esp
f0104de8:	eb 18                	jmp    f0104e02 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104dea:	83 ec 08             	sub    $0x8,%esp
f0104ded:	56                   	push   %esi
f0104dee:	ff 75 18             	pushl  0x18(%ebp)
f0104df1:	ff d7                	call   *%edi
f0104df3:	83 c4 10             	add    $0x10,%esp
f0104df6:	eb 03                	jmp    f0104dfb <printnum+0x78>
f0104df8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104dfb:	83 eb 01             	sub    $0x1,%ebx
f0104dfe:	85 db                	test   %ebx,%ebx
f0104e00:	7f e8                	jg     f0104dea <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104e02:	83 ec 08             	sub    $0x8,%esp
f0104e05:	56                   	push   %esi
f0104e06:	83 ec 04             	sub    $0x4,%esp
f0104e09:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e0c:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e0f:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e12:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e15:	e8 c6 17 00 00       	call   f01065e0 <__umoddi3>
f0104e1a:	83 c4 14             	add    $0x14,%esp
f0104e1d:	0f be 80 c6 7f 10 f0 	movsbl -0xfef803a(%eax),%eax
f0104e24:	50                   	push   %eax
f0104e25:	ff d7                	call   *%edi
}
f0104e27:	83 c4 10             	add    $0x10,%esp
f0104e2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e2d:	5b                   	pop    %ebx
f0104e2e:	5e                   	pop    %esi
f0104e2f:	5f                   	pop    %edi
f0104e30:	5d                   	pop    %ebp
f0104e31:	c3                   	ret    

f0104e32 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104e32:	55                   	push   %ebp
f0104e33:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104e35:	83 fa 01             	cmp    $0x1,%edx
f0104e38:	7e 0e                	jle    f0104e48 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104e3a:	8b 10                	mov    (%eax),%edx
f0104e3c:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104e3f:	89 08                	mov    %ecx,(%eax)
f0104e41:	8b 02                	mov    (%edx),%eax
f0104e43:	8b 52 04             	mov    0x4(%edx),%edx
f0104e46:	eb 22                	jmp    f0104e6a <getuint+0x38>
	else if (lflag)
f0104e48:	85 d2                	test   %edx,%edx
f0104e4a:	74 10                	je     f0104e5c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104e4c:	8b 10                	mov    (%eax),%edx
f0104e4e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104e51:	89 08                	mov    %ecx,(%eax)
f0104e53:	8b 02                	mov    (%edx),%eax
f0104e55:	ba 00 00 00 00       	mov    $0x0,%edx
f0104e5a:	eb 0e                	jmp    f0104e6a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104e5c:	8b 10                	mov    (%eax),%edx
f0104e5e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104e61:	89 08                	mov    %ecx,(%eax)
f0104e63:	8b 02                	mov    (%edx),%eax
f0104e65:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104e6a:	5d                   	pop    %ebp
f0104e6b:	c3                   	ret    

f0104e6c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104e6c:	55                   	push   %ebp
f0104e6d:	89 e5                	mov    %esp,%ebp
f0104e6f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104e72:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104e76:	8b 10                	mov    (%eax),%edx
f0104e78:	3b 50 04             	cmp    0x4(%eax),%edx
f0104e7b:	73 0a                	jae    f0104e87 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104e7d:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104e80:	89 08                	mov    %ecx,(%eax)
f0104e82:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e85:	88 02                	mov    %al,(%edx)
}
f0104e87:	5d                   	pop    %ebp
f0104e88:	c3                   	ret    

f0104e89 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104e89:	55                   	push   %ebp
f0104e8a:	89 e5                	mov    %esp,%ebp
f0104e8c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104e8f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104e92:	50                   	push   %eax
f0104e93:	ff 75 10             	pushl  0x10(%ebp)
f0104e96:	ff 75 0c             	pushl  0xc(%ebp)
f0104e99:	ff 75 08             	pushl  0x8(%ebp)
f0104e9c:	e8 05 00 00 00       	call   f0104ea6 <vprintfmt>
	va_end(ap);
}
f0104ea1:	83 c4 10             	add    $0x10,%esp
f0104ea4:	c9                   	leave  
f0104ea5:	c3                   	ret    

f0104ea6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104ea6:	55                   	push   %ebp
f0104ea7:	89 e5                	mov    %esp,%ebp
f0104ea9:	57                   	push   %edi
f0104eaa:	56                   	push   %esi
f0104eab:	53                   	push   %ebx
f0104eac:	83 ec 2c             	sub    $0x2c,%esp
f0104eaf:	8b 75 08             	mov    0x8(%ebp),%esi
f0104eb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104eb5:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104eb8:	eb 12                	jmp    f0104ecc <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104eba:	85 c0                	test   %eax,%eax
f0104ebc:	0f 84 89 03 00 00    	je     f010524b <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0104ec2:	83 ec 08             	sub    $0x8,%esp
f0104ec5:	53                   	push   %ebx
f0104ec6:	50                   	push   %eax
f0104ec7:	ff d6                	call   *%esi
f0104ec9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104ecc:	83 c7 01             	add    $0x1,%edi
f0104ecf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104ed3:	83 f8 25             	cmp    $0x25,%eax
f0104ed6:	75 e2                	jne    f0104eba <vprintfmt+0x14>
f0104ed8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104edc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104ee3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104eea:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104ef1:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ef6:	eb 07                	jmp    f0104eff <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ef8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104efb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104eff:	8d 47 01             	lea    0x1(%edi),%eax
f0104f02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104f05:	0f b6 07             	movzbl (%edi),%eax
f0104f08:	0f b6 c8             	movzbl %al,%ecx
f0104f0b:	83 e8 23             	sub    $0x23,%eax
f0104f0e:	3c 55                	cmp    $0x55,%al
f0104f10:	0f 87 1a 03 00 00    	ja     f0105230 <vprintfmt+0x38a>
f0104f16:	0f b6 c0             	movzbl %al,%eax
f0104f19:	ff 24 85 00 81 10 f0 	jmp    *-0xfef7f00(,%eax,4)
f0104f20:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104f23:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104f27:	eb d6                	jmp    f0104eff <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f29:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f2c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f31:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104f34:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104f37:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104f3b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104f3e:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104f41:	83 fa 09             	cmp    $0x9,%edx
f0104f44:	77 39                	ja     f0104f7f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104f46:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104f49:	eb e9                	jmp    f0104f34 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104f4b:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f4e:	8d 48 04             	lea    0x4(%eax),%ecx
f0104f51:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104f54:	8b 00                	mov    (%eax),%eax
f0104f56:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f59:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104f5c:	eb 27                	jmp    f0104f85 <vprintfmt+0xdf>
f0104f5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f61:	85 c0                	test   %eax,%eax
f0104f63:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104f68:	0f 49 c8             	cmovns %eax,%ecx
f0104f6b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f71:	eb 8c                	jmp    f0104eff <vprintfmt+0x59>
f0104f73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104f76:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104f7d:	eb 80                	jmp    f0104eff <vprintfmt+0x59>
f0104f7f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104f82:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104f85:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104f89:	0f 89 70 ff ff ff    	jns    f0104eff <vprintfmt+0x59>
				width = precision, precision = -1;
f0104f8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104f92:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104f95:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104f9c:	e9 5e ff ff ff       	jmp    f0104eff <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104fa1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fa4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104fa7:	e9 53 ff ff ff       	jmp    f0104eff <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104fac:	8b 45 14             	mov    0x14(%ebp),%eax
f0104faf:	8d 50 04             	lea    0x4(%eax),%edx
f0104fb2:	89 55 14             	mov    %edx,0x14(%ebp)
f0104fb5:	83 ec 08             	sub    $0x8,%esp
f0104fb8:	53                   	push   %ebx
f0104fb9:	ff 30                	pushl  (%eax)
f0104fbb:	ff d6                	call   *%esi
			break;
f0104fbd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fc0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104fc3:	e9 04 ff ff ff       	jmp    f0104ecc <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104fc8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fcb:	8d 50 04             	lea    0x4(%eax),%edx
f0104fce:	89 55 14             	mov    %edx,0x14(%ebp)
f0104fd1:	8b 00                	mov    (%eax),%eax
f0104fd3:	99                   	cltd   
f0104fd4:	31 d0                	xor    %edx,%eax
f0104fd6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104fd8:	83 f8 0f             	cmp    $0xf,%eax
f0104fdb:	7f 0b                	jg     f0104fe8 <vprintfmt+0x142>
f0104fdd:	8b 14 85 60 82 10 f0 	mov    -0xfef7da0(,%eax,4),%edx
f0104fe4:	85 d2                	test   %edx,%edx
f0104fe6:	75 18                	jne    f0105000 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0104fe8:	50                   	push   %eax
f0104fe9:	68 de 7f 10 f0       	push   $0xf0107fde
f0104fee:	53                   	push   %ebx
f0104fef:	56                   	push   %esi
f0104ff0:	e8 94 fe ff ff       	call   f0104e89 <printfmt>
f0104ff5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ff8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104ffb:	e9 cc fe ff ff       	jmp    f0104ecc <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0105000:	52                   	push   %edx
f0105001:	68 d5 76 10 f0       	push   $0xf01076d5
f0105006:	53                   	push   %ebx
f0105007:	56                   	push   %esi
f0105008:	e8 7c fe ff ff       	call   f0104e89 <printfmt>
f010500d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105010:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105013:	e9 b4 fe ff ff       	jmp    f0104ecc <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105018:	8b 45 14             	mov    0x14(%ebp),%eax
f010501b:	8d 50 04             	lea    0x4(%eax),%edx
f010501e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105021:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105023:	85 ff                	test   %edi,%edi
f0105025:	b8 d7 7f 10 f0       	mov    $0xf0107fd7,%eax
f010502a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010502d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105031:	0f 8e 94 00 00 00    	jle    f01050cb <vprintfmt+0x225>
f0105037:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010503b:	0f 84 98 00 00 00    	je     f01050d9 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105041:	83 ec 08             	sub    $0x8,%esp
f0105044:	ff 75 d0             	pushl  -0x30(%ebp)
f0105047:	57                   	push   %edi
f0105048:	e8 77 03 00 00       	call   f01053c4 <strnlen>
f010504d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105050:	29 c1                	sub    %eax,%ecx
f0105052:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105055:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105058:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010505c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010505f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105062:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105064:	eb 0f                	jmp    f0105075 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0105066:	83 ec 08             	sub    $0x8,%esp
f0105069:	53                   	push   %ebx
f010506a:	ff 75 e0             	pushl  -0x20(%ebp)
f010506d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010506f:	83 ef 01             	sub    $0x1,%edi
f0105072:	83 c4 10             	add    $0x10,%esp
f0105075:	85 ff                	test   %edi,%edi
f0105077:	7f ed                	jg     f0105066 <vprintfmt+0x1c0>
f0105079:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010507c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010507f:	85 c9                	test   %ecx,%ecx
f0105081:	b8 00 00 00 00       	mov    $0x0,%eax
f0105086:	0f 49 c1             	cmovns %ecx,%eax
f0105089:	29 c1                	sub    %eax,%ecx
f010508b:	89 75 08             	mov    %esi,0x8(%ebp)
f010508e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105091:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105094:	89 cb                	mov    %ecx,%ebx
f0105096:	eb 4d                	jmp    f01050e5 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105098:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010509c:	74 1b                	je     f01050b9 <vprintfmt+0x213>
f010509e:	0f be c0             	movsbl %al,%eax
f01050a1:	83 e8 20             	sub    $0x20,%eax
f01050a4:	83 f8 5e             	cmp    $0x5e,%eax
f01050a7:	76 10                	jbe    f01050b9 <vprintfmt+0x213>
					putch('?', putdat);
f01050a9:	83 ec 08             	sub    $0x8,%esp
f01050ac:	ff 75 0c             	pushl  0xc(%ebp)
f01050af:	6a 3f                	push   $0x3f
f01050b1:	ff 55 08             	call   *0x8(%ebp)
f01050b4:	83 c4 10             	add    $0x10,%esp
f01050b7:	eb 0d                	jmp    f01050c6 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f01050b9:	83 ec 08             	sub    $0x8,%esp
f01050bc:	ff 75 0c             	pushl  0xc(%ebp)
f01050bf:	52                   	push   %edx
f01050c0:	ff 55 08             	call   *0x8(%ebp)
f01050c3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01050c6:	83 eb 01             	sub    $0x1,%ebx
f01050c9:	eb 1a                	jmp    f01050e5 <vprintfmt+0x23f>
f01050cb:	89 75 08             	mov    %esi,0x8(%ebp)
f01050ce:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01050d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01050d4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01050d7:	eb 0c                	jmp    f01050e5 <vprintfmt+0x23f>
f01050d9:	89 75 08             	mov    %esi,0x8(%ebp)
f01050dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01050df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01050e2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01050e5:	83 c7 01             	add    $0x1,%edi
f01050e8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01050ec:	0f be d0             	movsbl %al,%edx
f01050ef:	85 d2                	test   %edx,%edx
f01050f1:	74 23                	je     f0105116 <vprintfmt+0x270>
f01050f3:	85 f6                	test   %esi,%esi
f01050f5:	78 a1                	js     f0105098 <vprintfmt+0x1f2>
f01050f7:	83 ee 01             	sub    $0x1,%esi
f01050fa:	79 9c                	jns    f0105098 <vprintfmt+0x1f2>
f01050fc:	89 df                	mov    %ebx,%edi
f01050fe:	8b 75 08             	mov    0x8(%ebp),%esi
f0105101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105104:	eb 18                	jmp    f010511e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105106:	83 ec 08             	sub    $0x8,%esp
f0105109:	53                   	push   %ebx
f010510a:	6a 20                	push   $0x20
f010510c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010510e:	83 ef 01             	sub    $0x1,%edi
f0105111:	83 c4 10             	add    $0x10,%esp
f0105114:	eb 08                	jmp    f010511e <vprintfmt+0x278>
f0105116:	89 df                	mov    %ebx,%edi
f0105118:	8b 75 08             	mov    0x8(%ebp),%esi
f010511b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010511e:	85 ff                	test   %edi,%edi
f0105120:	7f e4                	jg     f0105106 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105122:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105125:	e9 a2 fd ff ff       	jmp    f0104ecc <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010512a:	83 fa 01             	cmp    $0x1,%edx
f010512d:	7e 16                	jle    f0105145 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f010512f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105132:	8d 50 08             	lea    0x8(%eax),%edx
f0105135:	89 55 14             	mov    %edx,0x14(%ebp)
f0105138:	8b 50 04             	mov    0x4(%eax),%edx
f010513b:	8b 00                	mov    (%eax),%eax
f010513d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105140:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105143:	eb 32                	jmp    f0105177 <vprintfmt+0x2d1>
	else if (lflag)
f0105145:	85 d2                	test   %edx,%edx
f0105147:	74 18                	je     f0105161 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0105149:	8b 45 14             	mov    0x14(%ebp),%eax
f010514c:	8d 50 04             	lea    0x4(%eax),%edx
f010514f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105152:	8b 00                	mov    (%eax),%eax
f0105154:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105157:	89 c1                	mov    %eax,%ecx
f0105159:	c1 f9 1f             	sar    $0x1f,%ecx
f010515c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010515f:	eb 16                	jmp    f0105177 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0105161:	8b 45 14             	mov    0x14(%ebp),%eax
f0105164:	8d 50 04             	lea    0x4(%eax),%edx
f0105167:	89 55 14             	mov    %edx,0x14(%ebp)
f010516a:	8b 00                	mov    (%eax),%eax
f010516c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010516f:	89 c1                	mov    %eax,%ecx
f0105171:	c1 f9 1f             	sar    $0x1f,%ecx
f0105174:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105177:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010517a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010517d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105182:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105186:	79 74                	jns    f01051fc <vprintfmt+0x356>
				putch('-', putdat);
f0105188:	83 ec 08             	sub    $0x8,%esp
f010518b:	53                   	push   %ebx
f010518c:	6a 2d                	push   $0x2d
f010518e:	ff d6                	call   *%esi
				num = -(long long) num;
f0105190:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105193:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105196:	f7 d8                	neg    %eax
f0105198:	83 d2 00             	adc    $0x0,%edx
f010519b:	f7 da                	neg    %edx
f010519d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01051a0:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01051a5:	eb 55                	jmp    f01051fc <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01051a7:	8d 45 14             	lea    0x14(%ebp),%eax
f01051aa:	e8 83 fc ff ff       	call   f0104e32 <getuint>
			base = 10;
f01051af:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01051b4:	eb 46                	jmp    f01051fc <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f01051b6:	8d 45 14             	lea    0x14(%ebp),%eax
f01051b9:	e8 74 fc ff ff       	call   f0104e32 <getuint>
			base = 8;
f01051be:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f01051c3:	eb 37                	jmp    f01051fc <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
f01051c5:	83 ec 08             	sub    $0x8,%esp
f01051c8:	53                   	push   %ebx
f01051c9:	6a 30                	push   $0x30
f01051cb:	ff d6                	call   *%esi
			putch('x', putdat);
f01051cd:	83 c4 08             	add    $0x8,%esp
f01051d0:	53                   	push   %ebx
f01051d1:	6a 78                	push   $0x78
f01051d3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01051d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01051d8:	8d 50 04             	lea    0x4(%eax),%edx
f01051db:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01051de:	8b 00                	mov    (%eax),%eax
f01051e0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01051e5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01051e8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01051ed:	eb 0d                	jmp    f01051fc <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01051ef:	8d 45 14             	lea    0x14(%ebp),%eax
f01051f2:	e8 3b fc ff ff       	call   f0104e32 <getuint>
			base = 16;
f01051f7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01051fc:	83 ec 0c             	sub    $0xc,%esp
f01051ff:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105203:	57                   	push   %edi
f0105204:	ff 75 e0             	pushl  -0x20(%ebp)
f0105207:	51                   	push   %ecx
f0105208:	52                   	push   %edx
f0105209:	50                   	push   %eax
f010520a:	89 da                	mov    %ebx,%edx
f010520c:	89 f0                	mov    %esi,%eax
f010520e:	e8 70 fb ff ff       	call   f0104d83 <printnum>
			break;
f0105213:	83 c4 20             	add    $0x20,%esp
f0105216:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105219:	e9 ae fc ff ff       	jmp    f0104ecc <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010521e:	83 ec 08             	sub    $0x8,%esp
f0105221:	53                   	push   %ebx
f0105222:	51                   	push   %ecx
f0105223:	ff d6                	call   *%esi
			break;
f0105225:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105228:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010522b:	e9 9c fc ff ff       	jmp    f0104ecc <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105230:	83 ec 08             	sub    $0x8,%esp
f0105233:	53                   	push   %ebx
f0105234:	6a 25                	push   $0x25
f0105236:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105238:	83 c4 10             	add    $0x10,%esp
f010523b:	eb 03                	jmp    f0105240 <vprintfmt+0x39a>
f010523d:	83 ef 01             	sub    $0x1,%edi
f0105240:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105244:	75 f7                	jne    f010523d <vprintfmt+0x397>
f0105246:	e9 81 fc ff ff       	jmp    f0104ecc <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010524b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010524e:	5b                   	pop    %ebx
f010524f:	5e                   	pop    %esi
f0105250:	5f                   	pop    %edi
f0105251:	5d                   	pop    %ebp
f0105252:	c3                   	ret    

f0105253 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105253:	55                   	push   %ebp
f0105254:	89 e5                	mov    %esp,%ebp
f0105256:	83 ec 18             	sub    $0x18,%esp
f0105259:	8b 45 08             	mov    0x8(%ebp),%eax
f010525c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010525f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105262:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105266:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105269:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105270:	85 c0                	test   %eax,%eax
f0105272:	74 26                	je     f010529a <vsnprintf+0x47>
f0105274:	85 d2                	test   %edx,%edx
f0105276:	7e 22                	jle    f010529a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105278:	ff 75 14             	pushl  0x14(%ebp)
f010527b:	ff 75 10             	pushl  0x10(%ebp)
f010527e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105281:	50                   	push   %eax
f0105282:	68 6c 4e 10 f0       	push   $0xf0104e6c
f0105287:	e8 1a fc ff ff       	call   f0104ea6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010528c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010528f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105292:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105295:	83 c4 10             	add    $0x10,%esp
f0105298:	eb 05                	jmp    f010529f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010529a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010529f:	c9                   	leave  
f01052a0:	c3                   	ret    

f01052a1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01052a1:	55                   	push   %ebp
f01052a2:	89 e5                	mov    %esp,%ebp
f01052a4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01052a7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01052aa:	50                   	push   %eax
f01052ab:	ff 75 10             	pushl  0x10(%ebp)
f01052ae:	ff 75 0c             	pushl  0xc(%ebp)
f01052b1:	ff 75 08             	pushl  0x8(%ebp)
f01052b4:	e8 9a ff ff ff       	call   f0105253 <vsnprintf>
	va_end(ap);

	return rc;
}
f01052b9:	c9                   	leave  
f01052ba:	c3                   	ret    

f01052bb <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01052bb:	55                   	push   %ebp
f01052bc:	89 e5                	mov    %esp,%ebp
f01052be:	57                   	push   %edi
f01052bf:	56                   	push   %esi
f01052c0:	53                   	push   %ebx
f01052c1:	83 ec 0c             	sub    $0xc,%esp
f01052c4:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f01052c7:	85 c0                	test   %eax,%eax
f01052c9:	74 11                	je     f01052dc <readline+0x21>
		cprintf("%s", prompt);
f01052cb:	83 ec 08             	sub    $0x8,%esp
f01052ce:	50                   	push   %eax
f01052cf:	68 d5 76 10 f0       	push   $0xf01076d5
f01052d4:	e8 0b e4 ff ff       	call   f01036e4 <cprintf>
f01052d9:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f01052dc:	83 ec 0c             	sub    $0xc,%esp
f01052df:	6a 00                	push   $0x0
f01052e1:	e8 fd b4 ff ff       	call   f01007e3 <iscons>
f01052e6:	89 c7                	mov    %eax,%edi
f01052e8:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f01052eb:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01052f0:	e8 dd b4 ff ff       	call   f01007d2 <getchar>
f01052f5:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01052f7:	85 c0                	test   %eax,%eax
f01052f9:	79 29                	jns    f0105324 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01052fb:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105300:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105303:	0f 84 9b 00 00 00    	je     f01053a4 <readline+0xe9>
				cprintf("read error: %e\n", c);
f0105309:	83 ec 08             	sub    $0x8,%esp
f010530c:	53                   	push   %ebx
f010530d:	68 bf 82 10 f0       	push   $0xf01082bf
f0105312:	e8 cd e3 ff ff       	call   f01036e4 <cprintf>
f0105317:	83 c4 10             	add    $0x10,%esp
			return NULL;
f010531a:	b8 00 00 00 00       	mov    $0x0,%eax
f010531f:	e9 80 00 00 00       	jmp    f01053a4 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105324:	83 f8 08             	cmp    $0x8,%eax
f0105327:	0f 94 c2             	sete   %dl
f010532a:	83 f8 7f             	cmp    $0x7f,%eax
f010532d:	0f 94 c0             	sete   %al
f0105330:	08 c2                	or     %al,%dl
f0105332:	74 1a                	je     f010534e <readline+0x93>
f0105334:	85 f6                	test   %esi,%esi
f0105336:	7e 16                	jle    f010534e <readline+0x93>
			if (echoing)
f0105338:	85 ff                	test   %edi,%edi
f010533a:	74 0d                	je     f0105349 <readline+0x8e>
				cputchar('\b');
f010533c:	83 ec 0c             	sub    $0xc,%esp
f010533f:	6a 08                	push   $0x8
f0105341:	e8 7c b4 ff ff       	call   f01007c2 <cputchar>
f0105346:	83 c4 10             	add    $0x10,%esp
			i--;
f0105349:	83 ee 01             	sub    $0x1,%esi
f010534c:	eb a2                	jmp    f01052f0 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010534e:	83 fb 1f             	cmp    $0x1f,%ebx
f0105351:	7e 26                	jle    f0105379 <readline+0xbe>
f0105353:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105359:	7f 1e                	jg     f0105379 <readline+0xbe>
			if (echoing)
f010535b:	85 ff                	test   %edi,%edi
f010535d:	74 0c                	je     f010536b <readline+0xb0>
				cputchar(c);
f010535f:	83 ec 0c             	sub    $0xc,%esp
f0105362:	53                   	push   %ebx
f0105363:	e8 5a b4 ff ff       	call   f01007c2 <cputchar>
f0105368:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010536b:	88 9e 80 fa 25 f0    	mov    %bl,-0xfda0580(%esi)
f0105371:	8d 76 01             	lea    0x1(%esi),%esi
f0105374:	e9 77 ff ff ff       	jmp    f01052f0 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105379:	83 fb 0a             	cmp    $0xa,%ebx
f010537c:	74 09                	je     f0105387 <readline+0xcc>
f010537e:	83 fb 0d             	cmp    $0xd,%ebx
f0105381:	0f 85 69 ff ff ff    	jne    f01052f0 <readline+0x35>
			if (echoing)
f0105387:	85 ff                	test   %edi,%edi
f0105389:	74 0d                	je     f0105398 <readline+0xdd>
				cputchar('\n');
f010538b:	83 ec 0c             	sub    $0xc,%esp
f010538e:	6a 0a                	push   $0xa
f0105390:	e8 2d b4 ff ff       	call   f01007c2 <cputchar>
f0105395:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105398:	c6 86 80 fa 25 f0 00 	movb   $0x0,-0xfda0580(%esi)
			return buf;
f010539f:	b8 80 fa 25 f0       	mov    $0xf025fa80,%eax
		}
	}
}
f01053a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01053a7:	5b                   	pop    %ebx
f01053a8:	5e                   	pop    %esi
f01053a9:	5f                   	pop    %edi
f01053aa:	5d                   	pop    %ebp
f01053ab:	c3                   	ret    

f01053ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01053ac:	55                   	push   %ebp
f01053ad:	89 e5                	mov    %esp,%ebp
f01053af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01053b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01053b7:	eb 03                	jmp    f01053bc <strlen+0x10>
		n++;
f01053b9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01053bc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01053c0:	75 f7                	jne    f01053b9 <strlen+0xd>
		n++;
	return n;
}
f01053c2:	5d                   	pop    %ebp
f01053c3:	c3                   	ret    

f01053c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01053c4:	55                   	push   %ebp
f01053c5:	89 e5                	mov    %esp,%ebp
f01053c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01053ca:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01053cd:	ba 00 00 00 00       	mov    $0x0,%edx
f01053d2:	eb 03                	jmp    f01053d7 <strnlen+0x13>
		n++;
f01053d4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01053d7:	39 c2                	cmp    %eax,%edx
f01053d9:	74 08                	je     f01053e3 <strnlen+0x1f>
f01053db:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01053df:	75 f3                	jne    f01053d4 <strnlen+0x10>
f01053e1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01053e3:	5d                   	pop    %ebp
f01053e4:	c3                   	ret    

f01053e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01053e5:	55                   	push   %ebp
f01053e6:	89 e5                	mov    %esp,%ebp
f01053e8:	53                   	push   %ebx
f01053e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01053ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01053ef:	89 c2                	mov    %eax,%edx
f01053f1:	83 c2 01             	add    $0x1,%edx
f01053f4:	83 c1 01             	add    $0x1,%ecx
f01053f7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01053fb:	88 5a ff             	mov    %bl,-0x1(%edx)
f01053fe:	84 db                	test   %bl,%bl
f0105400:	75 ef                	jne    f01053f1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105402:	5b                   	pop    %ebx
f0105403:	5d                   	pop    %ebp
f0105404:	c3                   	ret    

f0105405 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105405:	55                   	push   %ebp
f0105406:	89 e5                	mov    %esp,%ebp
f0105408:	53                   	push   %ebx
f0105409:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010540c:	53                   	push   %ebx
f010540d:	e8 9a ff ff ff       	call   f01053ac <strlen>
f0105412:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105415:	ff 75 0c             	pushl  0xc(%ebp)
f0105418:	01 d8                	add    %ebx,%eax
f010541a:	50                   	push   %eax
f010541b:	e8 c5 ff ff ff       	call   f01053e5 <strcpy>
	return dst;
}
f0105420:	89 d8                	mov    %ebx,%eax
f0105422:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105425:	c9                   	leave  
f0105426:	c3                   	ret    

f0105427 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105427:	55                   	push   %ebp
f0105428:	89 e5                	mov    %esp,%ebp
f010542a:	56                   	push   %esi
f010542b:	53                   	push   %ebx
f010542c:	8b 75 08             	mov    0x8(%ebp),%esi
f010542f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105432:	89 f3                	mov    %esi,%ebx
f0105434:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105437:	89 f2                	mov    %esi,%edx
f0105439:	eb 0f                	jmp    f010544a <strncpy+0x23>
		*dst++ = *src;
f010543b:	83 c2 01             	add    $0x1,%edx
f010543e:	0f b6 01             	movzbl (%ecx),%eax
f0105441:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105444:	80 39 01             	cmpb   $0x1,(%ecx)
f0105447:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010544a:	39 da                	cmp    %ebx,%edx
f010544c:	75 ed                	jne    f010543b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010544e:	89 f0                	mov    %esi,%eax
f0105450:	5b                   	pop    %ebx
f0105451:	5e                   	pop    %esi
f0105452:	5d                   	pop    %ebp
f0105453:	c3                   	ret    

f0105454 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105454:	55                   	push   %ebp
f0105455:	89 e5                	mov    %esp,%ebp
f0105457:	56                   	push   %esi
f0105458:	53                   	push   %ebx
f0105459:	8b 75 08             	mov    0x8(%ebp),%esi
f010545c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010545f:	8b 55 10             	mov    0x10(%ebp),%edx
f0105462:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105464:	85 d2                	test   %edx,%edx
f0105466:	74 21                	je     f0105489 <strlcpy+0x35>
f0105468:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010546c:	89 f2                	mov    %esi,%edx
f010546e:	eb 09                	jmp    f0105479 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105470:	83 c2 01             	add    $0x1,%edx
f0105473:	83 c1 01             	add    $0x1,%ecx
f0105476:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105479:	39 c2                	cmp    %eax,%edx
f010547b:	74 09                	je     f0105486 <strlcpy+0x32>
f010547d:	0f b6 19             	movzbl (%ecx),%ebx
f0105480:	84 db                	test   %bl,%bl
f0105482:	75 ec                	jne    f0105470 <strlcpy+0x1c>
f0105484:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105486:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105489:	29 f0                	sub    %esi,%eax
}
f010548b:	5b                   	pop    %ebx
f010548c:	5e                   	pop    %esi
f010548d:	5d                   	pop    %ebp
f010548e:	c3                   	ret    

f010548f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010548f:	55                   	push   %ebp
f0105490:	89 e5                	mov    %esp,%ebp
f0105492:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105495:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105498:	eb 06                	jmp    f01054a0 <strcmp+0x11>
		p++, q++;
f010549a:	83 c1 01             	add    $0x1,%ecx
f010549d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01054a0:	0f b6 01             	movzbl (%ecx),%eax
f01054a3:	84 c0                	test   %al,%al
f01054a5:	74 04                	je     f01054ab <strcmp+0x1c>
f01054a7:	3a 02                	cmp    (%edx),%al
f01054a9:	74 ef                	je     f010549a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01054ab:	0f b6 c0             	movzbl %al,%eax
f01054ae:	0f b6 12             	movzbl (%edx),%edx
f01054b1:	29 d0                	sub    %edx,%eax
}
f01054b3:	5d                   	pop    %ebp
f01054b4:	c3                   	ret    

f01054b5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01054b5:	55                   	push   %ebp
f01054b6:	89 e5                	mov    %esp,%ebp
f01054b8:	53                   	push   %ebx
f01054b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01054bc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01054bf:	89 c3                	mov    %eax,%ebx
f01054c1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01054c4:	eb 06                	jmp    f01054cc <strncmp+0x17>
		n--, p++, q++;
f01054c6:	83 c0 01             	add    $0x1,%eax
f01054c9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01054cc:	39 d8                	cmp    %ebx,%eax
f01054ce:	74 15                	je     f01054e5 <strncmp+0x30>
f01054d0:	0f b6 08             	movzbl (%eax),%ecx
f01054d3:	84 c9                	test   %cl,%cl
f01054d5:	74 04                	je     f01054db <strncmp+0x26>
f01054d7:	3a 0a                	cmp    (%edx),%cl
f01054d9:	74 eb                	je     f01054c6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01054db:	0f b6 00             	movzbl (%eax),%eax
f01054de:	0f b6 12             	movzbl (%edx),%edx
f01054e1:	29 d0                	sub    %edx,%eax
f01054e3:	eb 05                	jmp    f01054ea <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01054e5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01054ea:	5b                   	pop    %ebx
f01054eb:	5d                   	pop    %ebp
f01054ec:	c3                   	ret    

f01054ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01054ed:	55                   	push   %ebp
f01054ee:	89 e5                	mov    %esp,%ebp
f01054f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01054f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01054f7:	eb 07                	jmp    f0105500 <strchr+0x13>
		if (*s == c)
f01054f9:	38 ca                	cmp    %cl,%dl
f01054fb:	74 0f                	je     f010550c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01054fd:	83 c0 01             	add    $0x1,%eax
f0105500:	0f b6 10             	movzbl (%eax),%edx
f0105503:	84 d2                	test   %dl,%dl
f0105505:	75 f2                	jne    f01054f9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105507:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010550c:	5d                   	pop    %ebp
f010550d:	c3                   	ret    

f010550e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010550e:	55                   	push   %ebp
f010550f:	89 e5                	mov    %esp,%ebp
f0105511:	8b 45 08             	mov    0x8(%ebp),%eax
f0105514:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105518:	eb 03                	jmp    f010551d <strfind+0xf>
f010551a:	83 c0 01             	add    $0x1,%eax
f010551d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105520:	38 ca                	cmp    %cl,%dl
f0105522:	74 04                	je     f0105528 <strfind+0x1a>
f0105524:	84 d2                	test   %dl,%dl
f0105526:	75 f2                	jne    f010551a <strfind+0xc>
			break;
	return (char *) s;
}
f0105528:	5d                   	pop    %ebp
f0105529:	c3                   	ret    

f010552a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010552a:	55                   	push   %ebp
f010552b:	89 e5                	mov    %esp,%ebp
f010552d:	57                   	push   %edi
f010552e:	56                   	push   %esi
f010552f:	53                   	push   %ebx
f0105530:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105533:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105536:	85 c9                	test   %ecx,%ecx
f0105538:	74 36                	je     f0105570 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010553a:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105540:	75 28                	jne    f010556a <memset+0x40>
f0105542:	f6 c1 03             	test   $0x3,%cl
f0105545:	75 23                	jne    f010556a <memset+0x40>
		c &= 0xFF;
f0105547:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010554b:	89 d3                	mov    %edx,%ebx
f010554d:	c1 e3 08             	shl    $0x8,%ebx
f0105550:	89 d6                	mov    %edx,%esi
f0105552:	c1 e6 18             	shl    $0x18,%esi
f0105555:	89 d0                	mov    %edx,%eax
f0105557:	c1 e0 10             	shl    $0x10,%eax
f010555a:	09 f0                	or     %esi,%eax
f010555c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010555e:	89 d8                	mov    %ebx,%eax
f0105560:	09 d0                	or     %edx,%eax
f0105562:	c1 e9 02             	shr    $0x2,%ecx
f0105565:	fc                   	cld    
f0105566:	f3 ab                	rep stos %eax,%es:(%edi)
f0105568:	eb 06                	jmp    f0105570 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010556a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010556d:	fc                   	cld    
f010556e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105570:	89 f8                	mov    %edi,%eax
f0105572:	5b                   	pop    %ebx
f0105573:	5e                   	pop    %esi
f0105574:	5f                   	pop    %edi
f0105575:	5d                   	pop    %ebp
f0105576:	c3                   	ret    

f0105577 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105577:	55                   	push   %ebp
f0105578:	89 e5                	mov    %esp,%ebp
f010557a:	57                   	push   %edi
f010557b:	56                   	push   %esi
f010557c:	8b 45 08             	mov    0x8(%ebp),%eax
f010557f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105582:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105585:	39 c6                	cmp    %eax,%esi
f0105587:	73 35                	jae    f01055be <memmove+0x47>
f0105589:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010558c:	39 d0                	cmp    %edx,%eax
f010558e:	73 2e                	jae    f01055be <memmove+0x47>
		s += n;
		d += n;
f0105590:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105593:	89 d6                	mov    %edx,%esi
f0105595:	09 fe                	or     %edi,%esi
f0105597:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010559d:	75 13                	jne    f01055b2 <memmove+0x3b>
f010559f:	f6 c1 03             	test   $0x3,%cl
f01055a2:	75 0e                	jne    f01055b2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01055a4:	83 ef 04             	sub    $0x4,%edi
f01055a7:	8d 72 fc             	lea    -0x4(%edx),%esi
f01055aa:	c1 e9 02             	shr    $0x2,%ecx
f01055ad:	fd                   	std    
f01055ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01055b0:	eb 09                	jmp    f01055bb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01055b2:	83 ef 01             	sub    $0x1,%edi
f01055b5:	8d 72 ff             	lea    -0x1(%edx),%esi
f01055b8:	fd                   	std    
f01055b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01055bb:	fc                   	cld    
f01055bc:	eb 1d                	jmp    f01055db <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01055be:	89 f2                	mov    %esi,%edx
f01055c0:	09 c2                	or     %eax,%edx
f01055c2:	f6 c2 03             	test   $0x3,%dl
f01055c5:	75 0f                	jne    f01055d6 <memmove+0x5f>
f01055c7:	f6 c1 03             	test   $0x3,%cl
f01055ca:	75 0a                	jne    f01055d6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01055cc:	c1 e9 02             	shr    $0x2,%ecx
f01055cf:	89 c7                	mov    %eax,%edi
f01055d1:	fc                   	cld    
f01055d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01055d4:	eb 05                	jmp    f01055db <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01055d6:	89 c7                	mov    %eax,%edi
f01055d8:	fc                   	cld    
f01055d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01055db:	5e                   	pop    %esi
f01055dc:	5f                   	pop    %edi
f01055dd:	5d                   	pop    %ebp
f01055de:	c3                   	ret    

f01055df <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01055df:	55                   	push   %ebp
f01055e0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01055e2:	ff 75 10             	pushl  0x10(%ebp)
f01055e5:	ff 75 0c             	pushl  0xc(%ebp)
f01055e8:	ff 75 08             	pushl  0x8(%ebp)
f01055eb:	e8 87 ff ff ff       	call   f0105577 <memmove>
}
f01055f0:	c9                   	leave  
f01055f1:	c3                   	ret    

f01055f2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01055f2:	55                   	push   %ebp
f01055f3:	89 e5                	mov    %esp,%ebp
f01055f5:	56                   	push   %esi
f01055f6:	53                   	push   %ebx
f01055f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01055fa:	8b 55 0c             	mov    0xc(%ebp),%edx
f01055fd:	89 c6                	mov    %eax,%esi
f01055ff:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105602:	eb 1a                	jmp    f010561e <memcmp+0x2c>
		if (*s1 != *s2)
f0105604:	0f b6 08             	movzbl (%eax),%ecx
f0105607:	0f b6 1a             	movzbl (%edx),%ebx
f010560a:	38 d9                	cmp    %bl,%cl
f010560c:	74 0a                	je     f0105618 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010560e:	0f b6 c1             	movzbl %cl,%eax
f0105611:	0f b6 db             	movzbl %bl,%ebx
f0105614:	29 d8                	sub    %ebx,%eax
f0105616:	eb 0f                	jmp    f0105627 <memcmp+0x35>
		s1++, s2++;
f0105618:	83 c0 01             	add    $0x1,%eax
f010561b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010561e:	39 f0                	cmp    %esi,%eax
f0105620:	75 e2                	jne    f0105604 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105622:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105627:	5b                   	pop    %ebx
f0105628:	5e                   	pop    %esi
f0105629:	5d                   	pop    %ebp
f010562a:	c3                   	ret    

f010562b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010562b:	55                   	push   %ebp
f010562c:	89 e5                	mov    %esp,%ebp
f010562e:	53                   	push   %ebx
f010562f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105632:	89 c1                	mov    %eax,%ecx
f0105634:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105637:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010563b:	eb 0a                	jmp    f0105647 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010563d:	0f b6 10             	movzbl (%eax),%edx
f0105640:	39 da                	cmp    %ebx,%edx
f0105642:	74 07                	je     f010564b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105644:	83 c0 01             	add    $0x1,%eax
f0105647:	39 c8                	cmp    %ecx,%eax
f0105649:	72 f2                	jb     f010563d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010564b:	5b                   	pop    %ebx
f010564c:	5d                   	pop    %ebp
f010564d:	c3                   	ret    

f010564e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010564e:	55                   	push   %ebp
f010564f:	89 e5                	mov    %esp,%ebp
f0105651:	57                   	push   %edi
f0105652:	56                   	push   %esi
f0105653:	53                   	push   %ebx
f0105654:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105657:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010565a:	eb 03                	jmp    f010565f <strtol+0x11>
		s++;
f010565c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010565f:	0f b6 01             	movzbl (%ecx),%eax
f0105662:	3c 20                	cmp    $0x20,%al
f0105664:	74 f6                	je     f010565c <strtol+0xe>
f0105666:	3c 09                	cmp    $0x9,%al
f0105668:	74 f2                	je     f010565c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010566a:	3c 2b                	cmp    $0x2b,%al
f010566c:	75 0a                	jne    f0105678 <strtol+0x2a>
		s++;
f010566e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105671:	bf 00 00 00 00       	mov    $0x0,%edi
f0105676:	eb 11                	jmp    f0105689 <strtol+0x3b>
f0105678:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010567d:	3c 2d                	cmp    $0x2d,%al
f010567f:	75 08                	jne    f0105689 <strtol+0x3b>
		s++, neg = 1;
f0105681:	83 c1 01             	add    $0x1,%ecx
f0105684:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105689:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010568f:	75 15                	jne    f01056a6 <strtol+0x58>
f0105691:	80 39 30             	cmpb   $0x30,(%ecx)
f0105694:	75 10                	jne    f01056a6 <strtol+0x58>
f0105696:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010569a:	75 7c                	jne    f0105718 <strtol+0xca>
		s += 2, base = 16;
f010569c:	83 c1 02             	add    $0x2,%ecx
f010569f:	bb 10 00 00 00       	mov    $0x10,%ebx
f01056a4:	eb 16                	jmp    f01056bc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01056a6:	85 db                	test   %ebx,%ebx
f01056a8:	75 12                	jne    f01056bc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01056aa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01056af:	80 39 30             	cmpb   $0x30,(%ecx)
f01056b2:	75 08                	jne    f01056bc <strtol+0x6e>
		s++, base = 8;
f01056b4:	83 c1 01             	add    $0x1,%ecx
f01056b7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01056bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01056c1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01056c4:	0f b6 11             	movzbl (%ecx),%edx
f01056c7:	8d 72 d0             	lea    -0x30(%edx),%esi
f01056ca:	89 f3                	mov    %esi,%ebx
f01056cc:	80 fb 09             	cmp    $0x9,%bl
f01056cf:	77 08                	ja     f01056d9 <strtol+0x8b>
			dig = *s - '0';
f01056d1:	0f be d2             	movsbl %dl,%edx
f01056d4:	83 ea 30             	sub    $0x30,%edx
f01056d7:	eb 22                	jmp    f01056fb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01056d9:	8d 72 9f             	lea    -0x61(%edx),%esi
f01056dc:	89 f3                	mov    %esi,%ebx
f01056de:	80 fb 19             	cmp    $0x19,%bl
f01056e1:	77 08                	ja     f01056eb <strtol+0x9d>
			dig = *s - 'a' + 10;
f01056e3:	0f be d2             	movsbl %dl,%edx
f01056e6:	83 ea 57             	sub    $0x57,%edx
f01056e9:	eb 10                	jmp    f01056fb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01056eb:	8d 72 bf             	lea    -0x41(%edx),%esi
f01056ee:	89 f3                	mov    %esi,%ebx
f01056f0:	80 fb 19             	cmp    $0x19,%bl
f01056f3:	77 16                	ja     f010570b <strtol+0xbd>
			dig = *s - 'A' + 10;
f01056f5:	0f be d2             	movsbl %dl,%edx
f01056f8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01056fb:	3b 55 10             	cmp    0x10(%ebp),%edx
f01056fe:	7d 0b                	jge    f010570b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105700:	83 c1 01             	add    $0x1,%ecx
f0105703:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105707:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105709:	eb b9                	jmp    f01056c4 <strtol+0x76>

	if (endptr)
f010570b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010570f:	74 0d                	je     f010571e <strtol+0xd0>
		*endptr = (char *) s;
f0105711:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105714:	89 0e                	mov    %ecx,(%esi)
f0105716:	eb 06                	jmp    f010571e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105718:	85 db                	test   %ebx,%ebx
f010571a:	74 98                	je     f01056b4 <strtol+0x66>
f010571c:	eb 9e                	jmp    f01056bc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010571e:	89 c2                	mov    %eax,%edx
f0105720:	f7 da                	neg    %edx
f0105722:	85 ff                	test   %edi,%edi
f0105724:	0f 45 c2             	cmovne %edx,%eax
}
f0105727:	5b                   	pop    %ebx
f0105728:	5e                   	pop    %esi
f0105729:	5f                   	pop    %edi
f010572a:	5d                   	pop    %ebp
f010572b:	c3                   	ret    

f010572c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010572c:	fa                   	cli    

	xorw    %ax, %ax
f010572d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010572f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105731:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105733:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105735:	0f 01 16             	lgdtl  (%esi)
f0105738:	74 70                	je     f01057aa <mpsearch1+0x3>
	movl    %cr0, %eax
f010573a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010573d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105741:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105744:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010574a:	08 00                	or     %al,(%eax)

f010574c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010574c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105750:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105752:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105754:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105756:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010575a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010575c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010575e:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0105763:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105766:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105769:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010576e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105771:	8b 25 9c fe 25 f0    	mov    0xf025fe9c,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105777:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010577c:	b8 fb 01 10 f0       	mov    $0xf01001fb,%eax
	call    *%eax
f0105781:	ff d0                	call   *%eax

f0105783 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105783:	eb fe                	jmp    f0105783 <spin>
f0105785:	8d 76 00             	lea    0x0(%esi),%esi

f0105788 <gdt>:
	...
f0105790:	ff                   	(bad)  
f0105791:	ff 00                	incl   (%eax)
f0105793:	00 00                	add    %al,(%eax)
f0105795:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010579c:	00                   	.byte 0x0
f010579d:	92                   	xchg   %eax,%edx
f010579e:	cf                   	iret   
	...

f01057a0 <gdtdesc>:
f01057a0:	17                   	pop    %ss
f01057a1:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01057a6 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01057a6:	90                   	nop

f01057a7 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01057a7:	55                   	push   %ebp
f01057a8:	89 e5                	mov    %esp,%ebp
f01057aa:	57                   	push   %edi
f01057ab:	56                   	push   %esi
f01057ac:	53                   	push   %ebx
f01057ad:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01057b0:	8b 0d a0 fe 25 f0    	mov    0xf025fea0,%ecx
f01057b6:	89 c3                	mov    %eax,%ebx
f01057b8:	c1 eb 0c             	shr    $0xc,%ebx
f01057bb:	39 cb                	cmp    %ecx,%ebx
f01057bd:	72 12                	jb     f01057d1 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01057bf:	50                   	push   %eax
f01057c0:	68 64 67 10 f0       	push   $0xf0106764
f01057c5:	6a 57                	push   $0x57
f01057c7:	68 5d 84 10 f0       	push   $0xf010845d
f01057cc:	e8 6f a8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01057d1:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01057d7:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01057d9:	89 c2                	mov    %eax,%edx
f01057db:	c1 ea 0c             	shr    $0xc,%edx
f01057de:	39 ca                	cmp    %ecx,%edx
f01057e0:	72 12                	jb     f01057f4 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01057e2:	50                   	push   %eax
f01057e3:	68 64 67 10 f0       	push   $0xf0106764
f01057e8:	6a 57                	push   $0x57
f01057ea:	68 5d 84 10 f0       	push   $0xf010845d
f01057ef:	e8 4c a8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01057f4:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01057fa:	eb 2f                	jmp    f010582b <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01057fc:	83 ec 04             	sub    $0x4,%esp
f01057ff:	6a 04                	push   $0x4
f0105801:	68 6d 84 10 f0       	push   $0xf010846d
f0105806:	53                   	push   %ebx
f0105807:	e8 e6 fd ff ff       	call   f01055f2 <memcmp>
f010580c:	83 c4 10             	add    $0x10,%esp
f010580f:	85 c0                	test   %eax,%eax
f0105811:	75 15                	jne    f0105828 <mpsearch1+0x81>
f0105813:	89 da                	mov    %ebx,%edx
f0105815:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105818:	0f b6 0a             	movzbl (%edx),%ecx
f010581b:	01 c8                	add    %ecx,%eax
f010581d:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105820:	39 d7                	cmp    %edx,%edi
f0105822:	75 f4                	jne    f0105818 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105824:	84 c0                	test   %al,%al
f0105826:	74 0e                	je     f0105836 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105828:	83 c3 10             	add    $0x10,%ebx
f010582b:	39 f3                	cmp    %esi,%ebx
f010582d:	72 cd                	jb     f01057fc <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010582f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105834:	eb 02                	jmp    f0105838 <mpsearch1+0x91>
f0105836:	89 d8                	mov    %ebx,%eax
}
f0105838:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010583b:	5b                   	pop    %ebx
f010583c:	5e                   	pop    %esi
f010583d:	5f                   	pop    %edi
f010583e:	5d                   	pop    %ebp
f010583f:	c3                   	ret    

f0105840 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105840:	55                   	push   %ebp
f0105841:	89 e5                	mov    %esp,%ebp
f0105843:	57                   	push   %edi
f0105844:	56                   	push   %esi
f0105845:	53                   	push   %ebx
f0105846:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105849:	c7 05 c0 03 26 f0 20 	movl   $0xf0260020,0xf02603c0
f0105850:	00 26 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105853:	83 3d a0 fe 25 f0 00 	cmpl   $0x0,0xf025fea0
f010585a:	75 16                	jne    f0105872 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010585c:	68 00 04 00 00       	push   $0x400
f0105861:	68 64 67 10 f0       	push   $0xf0106764
f0105866:	6a 6f                	push   $0x6f
f0105868:	68 5d 84 10 f0       	push   $0xf010845d
f010586d:	e8 ce a7 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105872:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105879:	85 c0                	test   %eax,%eax
f010587b:	74 16                	je     f0105893 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f010587d:	c1 e0 04             	shl    $0x4,%eax
f0105880:	ba 00 04 00 00       	mov    $0x400,%edx
f0105885:	e8 1d ff ff ff       	call   f01057a7 <mpsearch1>
f010588a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010588d:	85 c0                	test   %eax,%eax
f010588f:	75 3c                	jne    f01058cd <mp_init+0x8d>
f0105891:	eb 20                	jmp    f01058b3 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105893:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010589a:	c1 e0 0a             	shl    $0xa,%eax
f010589d:	2d 00 04 00 00       	sub    $0x400,%eax
f01058a2:	ba 00 04 00 00       	mov    $0x400,%edx
f01058a7:	e8 fb fe ff ff       	call   f01057a7 <mpsearch1>
f01058ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01058af:	85 c0                	test   %eax,%eax
f01058b1:	75 1a                	jne    f01058cd <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01058b3:	ba 00 00 01 00       	mov    $0x10000,%edx
f01058b8:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01058bd:	e8 e5 fe ff ff       	call   f01057a7 <mpsearch1>
f01058c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01058c5:	85 c0                	test   %eax,%eax
f01058c7:	0f 84 5d 02 00 00    	je     f0105b2a <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01058cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058d0:	8b 70 04             	mov    0x4(%eax),%esi
f01058d3:	85 f6                	test   %esi,%esi
f01058d5:	74 06                	je     f01058dd <mp_init+0x9d>
f01058d7:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01058db:	74 15                	je     f01058f2 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f01058dd:	83 ec 0c             	sub    $0xc,%esp
f01058e0:	68 d0 82 10 f0       	push   $0xf01082d0
f01058e5:	e8 fa dd ff ff       	call   f01036e4 <cprintf>
f01058ea:	83 c4 10             	add    $0x10,%esp
f01058ed:	e9 38 02 00 00       	jmp    f0105b2a <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01058f2:	89 f0                	mov    %esi,%eax
f01058f4:	c1 e8 0c             	shr    $0xc,%eax
f01058f7:	3b 05 a0 fe 25 f0    	cmp    0xf025fea0,%eax
f01058fd:	72 15                	jb     f0105914 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01058ff:	56                   	push   %esi
f0105900:	68 64 67 10 f0       	push   $0xf0106764
f0105905:	68 90 00 00 00       	push   $0x90
f010590a:	68 5d 84 10 f0       	push   $0xf010845d
f010590f:	e8 2c a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105914:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010591a:	83 ec 04             	sub    $0x4,%esp
f010591d:	6a 04                	push   $0x4
f010591f:	68 72 84 10 f0       	push   $0xf0108472
f0105924:	53                   	push   %ebx
f0105925:	e8 c8 fc ff ff       	call   f01055f2 <memcmp>
f010592a:	83 c4 10             	add    $0x10,%esp
f010592d:	85 c0                	test   %eax,%eax
f010592f:	74 15                	je     f0105946 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105931:	83 ec 0c             	sub    $0xc,%esp
f0105934:	68 00 83 10 f0       	push   $0xf0108300
f0105939:	e8 a6 dd ff ff       	call   f01036e4 <cprintf>
f010593e:	83 c4 10             	add    $0x10,%esp
f0105941:	e9 e4 01 00 00       	jmp    f0105b2a <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105946:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f010594a:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f010594e:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105951:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105956:	b8 00 00 00 00       	mov    $0x0,%eax
f010595b:	eb 0d                	jmp    f010596a <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f010595d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105964:	f0 
f0105965:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105967:	83 c0 01             	add    $0x1,%eax
f010596a:	39 c7                	cmp    %eax,%edi
f010596c:	75 ef                	jne    f010595d <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010596e:	84 d2                	test   %dl,%dl
f0105970:	74 15                	je     f0105987 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105972:	83 ec 0c             	sub    $0xc,%esp
f0105975:	68 34 83 10 f0       	push   $0xf0108334
f010597a:	e8 65 dd ff ff       	call   f01036e4 <cprintf>
f010597f:	83 c4 10             	add    $0x10,%esp
f0105982:	e9 a3 01 00 00       	jmp    f0105b2a <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105987:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f010598b:	3c 01                	cmp    $0x1,%al
f010598d:	74 1d                	je     f01059ac <mp_init+0x16c>
f010598f:	3c 04                	cmp    $0x4,%al
f0105991:	74 19                	je     f01059ac <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105993:	83 ec 08             	sub    $0x8,%esp
f0105996:	0f b6 c0             	movzbl %al,%eax
f0105999:	50                   	push   %eax
f010599a:	68 58 83 10 f0       	push   $0xf0108358
f010599f:	e8 40 dd ff ff       	call   f01036e4 <cprintf>
f01059a4:	83 c4 10             	add    $0x10,%esp
f01059a7:	e9 7e 01 00 00       	jmp    f0105b2a <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01059ac:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f01059b0:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01059b4:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01059b9:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f01059be:	01 ce                	add    %ecx,%esi
f01059c0:	eb 0d                	jmp    f01059cf <mp_init+0x18f>
f01059c2:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f01059c9:	f0 
f01059ca:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01059cc:	83 c0 01             	add    $0x1,%eax
f01059cf:	39 c7                	cmp    %eax,%edi
f01059d1:	75 ef                	jne    f01059c2 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01059d3:	89 d0                	mov    %edx,%eax
f01059d5:	02 43 2a             	add    0x2a(%ebx),%al
f01059d8:	74 15                	je     f01059ef <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01059da:	83 ec 0c             	sub    $0xc,%esp
f01059dd:	68 78 83 10 f0       	push   $0xf0108378
f01059e2:	e8 fd dc ff ff       	call   f01036e4 <cprintf>
f01059e7:	83 c4 10             	add    $0x10,%esp
f01059ea:	e9 3b 01 00 00       	jmp    f0105b2a <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01059ef:	85 db                	test   %ebx,%ebx
f01059f1:	0f 84 33 01 00 00    	je     f0105b2a <mp_init+0x2ea>
		return;
	ismp = 1;
f01059f7:	c7 05 00 00 26 f0 01 	movl   $0x1,0xf0260000
f01059fe:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105a01:	8b 43 24             	mov    0x24(%ebx),%eax
f0105a04:	a3 00 10 2a f0       	mov    %eax,0xf02a1000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105a09:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105a0c:	be 00 00 00 00       	mov    $0x0,%esi
f0105a11:	e9 85 00 00 00       	jmp    f0105a9b <mp_init+0x25b>
		switch (*p) {
f0105a16:	0f b6 07             	movzbl (%edi),%eax
f0105a19:	84 c0                	test   %al,%al
f0105a1b:	74 06                	je     f0105a23 <mp_init+0x1e3>
f0105a1d:	3c 04                	cmp    $0x4,%al
f0105a1f:	77 55                	ja     f0105a76 <mp_init+0x236>
f0105a21:	eb 4e                	jmp    f0105a71 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105a23:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105a27:	74 11                	je     f0105a3a <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105a29:	6b 05 c4 03 26 f0 74 	imul   $0x74,0xf02603c4,%eax
f0105a30:	05 20 00 26 f0       	add    $0xf0260020,%eax
f0105a35:	a3 c0 03 26 f0       	mov    %eax,0xf02603c0
			if (ncpu < NCPU) {
f0105a3a:	a1 c4 03 26 f0       	mov    0xf02603c4,%eax
f0105a3f:	83 f8 07             	cmp    $0x7,%eax
f0105a42:	7f 13                	jg     f0105a57 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105a44:	6b d0 74             	imul   $0x74,%eax,%edx
f0105a47:	88 82 20 00 26 f0    	mov    %al,-0xfd9ffe0(%edx)
				ncpu++;
f0105a4d:	83 c0 01             	add    $0x1,%eax
f0105a50:	a3 c4 03 26 f0       	mov    %eax,0xf02603c4
f0105a55:	eb 15                	jmp    f0105a6c <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105a57:	83 ec 08             	sub    $0x8,%esp
f0105a5a:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105a5e:	50                   	push   %eax
f0105a5f:	68 a8 83 10 f0       	push   $0xf01083a8
f0105a64:	e8 7b dc ff ff       	call   f01036e4 <cprintf>
f0105a69:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105a6c:	83 c7 14             	add    $0x14,%edi
			continue;
f0105a6f:	eb 27                	jmp    f0105a98 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105a71:	83 c7 08             	add    $0x8,%edi
			continue;
f0105a74:	eb 22                	jmp    f0105a98 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105a76:	83 ec 08             	sub    $0x8,%esp
f0105a79:	0f b6 c0             	movzbl %al,%eax
f0105a7c:	50                   	push   %eax
f0105a7d:	68 d0 83 10 f0       	push   $0xf01083d0
f0105a82:	e8 5d dc ff ff       	call   f01036e4 <cprintf>
			ismp = 0;
f0105a87:	c7 05 00 00 26 f0 00 	movl   $0x0,0xf0260000
f0105a8e:	00 00 00 
			i = conf->entry;
f0105a91:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105a95:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105a98:	83 c6 01             	add    $0x1,%esi
f0105a9b:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105a9f:	39 c6                	cmp    %eax,%esi
f0105aa1:	0f 82 6f ff ff ff    	jb     f0105a16 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105aa7:	a1 c0 03 26 f0       	mov    0xf02603c0,%eax
f0105aac:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105ab3:	83 3d 00 00 26 f0 00 	cmpl   $0x0,0xf0260000
f0105aba:	75 26                	jne    f0105ae2 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105abc:	c7 05 c4 03 26 f0 01 	movl   $0x1,0xf02603c4
f0105ac3:	00 00 00 
		lapicaddr = 0;
f0105ac6:	c7 05 00 10 2a f0 00 	movl   $0x0,0xf02a1000
f0105acd:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105ad0:	83 ec 0c             	sub    $0xc,%esp
f0105ad3:	68 f0 83 10 f0       	push   $0xf01083f0
f0105ad8:	e8 07 dc ff ff       	call   f01036e4 <cprintf>
		return;
f0105add:	83 c4 10             	add    $0x10,%esp
f0105ae0:	eb 48                	jmp    f0105b2a <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105ae2:	83 ec 04             	sub    $0x4,%esp
f0105ae5:	ff 35 c4 03 26 f0    	pushl  0xf02603c4
f0105aeb:	0f b6 00             	movzbl (%eax),%eax
f0105aee:	50                   	push   %eax
f0105aef:	68 77 84 10 f0       	push   $0xf0108477
f0105af4:	e8 eb db ff ff       	call   f01036e4 <cprintf>

	if (mp->imcrp) {
f0105af9:	83 c4 10             	add    $0x10,%esp
f0105afc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105aff:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105b03:	74 25                	je     f0105b2a <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105b05:	83 ec 0c             	sub    $0xc,%esp
f0105b08:	68 1c 84 10 f0       	push   $0xf010841c
f0105b0d:	e8 d2 db ff ff       	call   f01036e4 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105b12:	ba 22 00 00 00       	mov    $0x22,%edx
f0105b17:	b8 70 00 00 00       	mov    $0x70,%eax
f0105b1c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105b1d:	ba 23 00 00 00       	mov    $0x23,%edx
f0105b22:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105b23:	83 c8 01             	or     $0x1,%eax
f0105b26:	ee                   	out    %al,(%dx)
f0105b27:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105b2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b2d:	5b                   	pop    %ebx
f0105b2e:	5e                   	pop    %esi
f0105b2f:	5f                   	pop    %edi
f0105b30:	5d                   	pop    %ebp
f0105b31:	c3                   	ret    

f0105b32 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105b32:	55                   	push   %ebp
f0105b33:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105b35:	8b 0d 04 10 2a f0    	mov    0xf02a1004,%ecx
f0105b3b:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105b3e:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105b40:	a1 04 10 2a f0       	mov    0xf02a1004,%eax
f0105b45:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105b48:	5d                   	pop    %ebp
f0105b49:	c3                   	ret    

f0105b4a <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105b4a:	55                   	push   %ebp
f0105b4b:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105b4d:	a1 04 10 2a f0       	mov    0xf02a1004,%eax
f0105b52:	85 c0                	test   %eax,%eax
f0105b54:	74 08                	je     f0105b5e <cpunum+0x14>
		return lapic[ID] >> 24;
f0105b56:	8b 40 20             	mov    0x20(%eax),%eax
f0105b59:	c1 e8 18             	shr    $0x18,%eax
f0105b5c:	eb 05                	jmp    f0105b63 <cpunum+0x19>
	return 0;
f0105b5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105b63:	5d                   	pop    %ebp
f0105b64:	c3                   	ret    

f0105b65 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105b65:	a1 00 10 2a f0       	mov    0xf02a1000,%eax
f0105b6a:	85 c0                	test   %eax,%eax
f0105b6c:	0f 84 21 01 00 00    	je     f0105c93 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105b72:	55                   	push   %ebp
f0105b73:	89 e5                	mov    %esp,%ebp
f0105b75:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105b78:	68 00 10 00 00       	push   $0x1000
f0105b7d:	50                   	push   %eax
f0105b7e:	e8 aa b6 ff ff       	call   f010122d <mmio_map_region>
f0105b83:	a3 04 10 2a f0       	mov    %eax,0xf02a1004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105b88:	ba 27 01 00 00       	mov    $0x127,%edx
f0105b8d:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105b92:	e8 9b ff ff ff       	call   f0105b32 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105b97:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105b9c:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105ba1:	e8 8c ff ff ff       	call   f0105b32 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105ba6:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105bab:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105bb0:	e8 7d ff ff ff       	call   f0105b32 <lapicw>
	lapicw(TICR, 10000000); 
f0105bb5:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105bba:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105bbf:	e8 6e ff ff ff       	call   f0105b32 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105bc4:	e8 81 ff ff ff       	call   f0105b4a <cpunum>
f0105bc9:	6b c0 74             	imul   $0x74,%eax,%eax
f0105bcc:	05 20 00 26 f0       	add    $0xf0260020,%eax
f0105bd1:	83 c4 10             	add    $0x10,%esp
f0105bd4:	39 05 c0 03 26 f0    	cmp    %eax,0xf02603c0
f0105bda:	74 0f                	je     f0105beb <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105bdc:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105be1:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105be6:	e8 47 ff ff ff       	call   f0105b32 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105beb:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105bf0:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105bf5:	e8 38 ff ff ff       	call   f0105b32 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105bfa:	a1 04 10 2a f0       	mov    0xf02a1004,%eax
f0105bff:	8b 40 30             	mov    0x30(%eax),%eax
f0105c02:	c1 e8 10             	shr    $0x10,%eax
f0105c05:	3c 03                	cmp    $0x3,%al
f0105c07:	76 0f                	jbe    f0105c18 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105c09:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c0e:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105c13:	e8 1a ff ff ff       	call   f0105b32 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105c18:	ba 33 00 00 00       	mov    $0x33,%edx
f0105c1d:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105c22:	e8 0b ff ff ff       	call   f0105b32 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105c27:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c2c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105c31:	e8 fc fe ff ff       	call   f0105b32 <lapicw>
	lapicw(ESR, 0);
f0105c36:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c3b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105c40:	e8 ed fe ff ff       	call   f0105b32 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105c45:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c4a:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105c4f:	e8 de fe ff ff       	call   f0105b32 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105c54:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c59:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105c5e:	e8 cf fe ff ff       	call   f0105b32 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105c63:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105c68:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c6d:	e8 c0 fe ff ff       	call   f0105b32 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105c72:	8b 15 04 10 2a f0    	mov    0xf02a1004,%edx
f0105c78:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105c7e:	f6 c4 10             	test   $0x10,%ah
f0105c81:	75 f5                	jne    f0105c78 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105c83:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c88:	b8 20 00 00 00       	mov    $0x20,%eax
f0105c8d:	e8 a0 fe ff ff       	call   f0105b32 <lapicw>
}
f0105c92:	c9                   	leave  
f0105c93:	f3 c3                	repz ret 

f0105c95 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105c95:	83 3d 04 10 2a f0 00 	cmpl   $0x0,0xf02a1004
f0105c9c:	74 13                	je     f0105cb1 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105c9e:	55                   	push   %ebp
f0105c9f:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105ca1:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ca6:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105cab:	e8 82 fe ff ff       	call   f0105b32 <lapicw>
}
f0105cb0:	5d                   	pop    %ebp
f0105cb1:	f3 c3                	repz ret 

f0105cb3 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105cb3:	55                   	push   %ebp
f0105cb4:	89 e5                	mov    %esp,%ebp
f0105cb6:	56                   	push   %esi
f0105cb7:	53                   	push   %ebx
f0105cb8:	8b 75 08             	mov    0x8(%ebp),%esi
f0105cbb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105cbe:	ba 70 00 00 00       	mov    $0x70,%edx
f0105cc3:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105cc8:	ee                   	out    %al,(%dx)
f0105cc9:	ba 71 00 00 00       	mov    $0x71,%edx
f0105cce:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105cd3:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105cd4:	83 3d a0 fe 25 f0 00 	cmpl   $0x0,0xf025fea0
f0105cdb:	75 19                	jne    f0105cf6 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105cdd:	68 67 04 00 00       	push   $0x467
f0105ce2:	68 64 67 10 f0       	push   $0xf0106764
f0105ce7:	68 98 00 00 00       	push   $0x98
f0105cec:	68 94 84 10 f0       	push   $0xf0108494
f0105cf1:	e8 4a a3 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105cf6:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105cfd:	00 00 
	wrv[1] = addr >> 4;
f0105cff:	89 d8                	mov    %ebx,%eax
f0105d01:	c1 e8 04             	shr    $0x4,%eax
f0105d04:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105d0a:	c1 e6 18             	shl    $0x18,%esi
f0105d0d:	89 f2                	mov    %esi,%edx
f0105d0f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d14:	e8 19 fe ff ff       	call   f0105b32 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105d19:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105d1e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d23:	e8 0a fe ff ff       	call   f0105b32 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105d28:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105d2d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d32:	e8 fb fd ff ff       	call   f0105b32 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d37:	c1 eb 0c             	shr    $0xc,%ebx
f0105d3a:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105d3d:	89 f2                	mov    %esi,%edx
f0105d3f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d44:	e8 e9 fd ff ff       	call   f0105b32 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d49:	89 da                	mov    %ebx,%edx
f0105d4b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d50:	e8 dd fd ff ff       	call   f0105b32 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105d55:	89 f2                	mov    %esi,%edx
f0105d57:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d5c:	e8 d1 fd ff ff       	call   f0105b32 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d61:	89 da                	mov    %ebx,%edx
f0105d63:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d68:	e8 c5 fd ff ff       	call   f0105b32 <lapicw>
		microdelay(200);
	}
}
f0105d6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105d70:	5b                   	pop    %ebx
f0105d71:	5e                   	pop    %esi
f0105d72:	5d                   	pop    %ebp
f0105d73:	c3                   	ret    

f0105d74 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105d74:	55                   	push   %ebp
f0105d75:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105d77:	8b 55 08             	mov    0x8(%ebp),%edx
f0105d7a:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105d80:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d85:	e8 a8 fd ff ff       	call   f0105b32 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105d8a:	8b 15 04 10 2a f0    	mov    0xf02a1004,%edx
f0105d90:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105d96:	f6 c4 10             	test   $0x10,%ah
f0105d99:	75 f5                	jne    f0105d90 <lapic_ipi+0x1c>
		;
}
f0105d9b:	5d                   	pop    %ebp
f0105d9c:	c3                   	ret    

f0105d9d <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105d9d:	55                   	push   %ebp
f0105d9e:	89 e5                	mov    %esp,%ebp
f0105da0:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105da3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105da9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105dac:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105daf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105db6:	5d                   	pop    %ebp
f0105db7:	c3                   	ret    

f0105db8 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105db8:	55                   	push   %ebp
f0105db9:	89 e5                	mov    %esp,%ebp
f0105dbb:	56                   	push   %esi
f0105dbc:	53                   	push   %ebx
f0105dbd:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105dc0:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105dc3:	74 14                	je     f0105dd9 <spin_lock+0x21>
f0105dc5:	8b 73 08             	mov    0x8(%ebx),%esi
f0105dc8:	e8 7d fd ff ff       	call   f0105b4a <cpunum>
f0105dcd:	6b c0 74             	imul   $0x74,%eax,%eax
f0105dd0:	05 20 00 26 f0       	add    $0xf0260020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105dd5:	39 c6                	cmp    %eax,%esi
f0105dd7:	74 07                	je     f0105de0 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105dd9:	ba 01 00 00 00       	mov    $0x1,%edx
f0105dde:	eb 20                	jmp    f0105e00 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105de0:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105de3:	e8 62 fd ff ff       	call   f0105b4a <cpunum>
f0105de8:	83 ec 0c             	sub    $0xc,%esp
f0105deb:	53                   	push   %ebx
f0105dec:	50                   	push   %eax
f0105ded:	68 a4 84 10 f0       	push   $0xf01084a4
f0105df2:	6a 41                	push   $0x41
f0105df4:	68 06 85 10 f0       	push   $0xf0108506
f0105df9:	e8 42 a2 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105dfe:	f3 90                	pause  
f0105e00:	89 d0                	mov    %edx,%eax
f0105e02:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105e05:	85 c0                	test   %eax,%eax
f0105e07:	75 f5                	jne    f0105dfe <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105e09:	e8 3c fd ff ff       	call   f0105b4a <cpunum>
f0105e0e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e11:	05 20 00 26 f0       	add    $0xf0260020,%eax
f0105e16:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105e19:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0105e1c:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105e1e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e23:	eb 0b                	jmp    f0105e30 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105e25:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105e28:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105e2b:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105e2d:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105e30:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105e36:	76 11                	jbe    f0105e49 <spin_lock+0x91>
f0105e38:	83 f8 09             	cmp    $0x9,%eax
f0105e3b:	7e e8                	jle    f0105e25 <spin_lock+0x6d>
f0105e3d:	eb 0a                	jmp    f0105e49 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105e3f:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105e46:	83 c0 01             	add    $0x1,%eax
f0105e49:	83 f8 09             	cmp    $0x9,%eax
f0105e4c:	7e f1                	jle    f0105e3f <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105e4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105e51:	5b                   	pop    %ebx
f0105e52:	5e                   	pop    %esi
f0105e53:	5d                   	pop    %ebp
f0105e54:	c3                   	ret    

f0105e55 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105e55:	55                   	push   %ebp
f0105e56:	89 e5                	mov    %esp,%ebp
f0105e58:	57                   	push   %edi
f0105e59:	56                   	push   %esi
f0105e5a:	53                   	push   %ebx
f0105e5b:	83 ec 4c             	sub    $0x4c,%esp
f0105e5e:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105e61:	83 3e 00             	cmpl   $0x0,(%esi)
f0105e64:	74 18                	je     f0105e7e <spin_unlock+0x29>
f0105e66:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105e69:	e8 dc fc ff ff       	call   f0105b4a <cpunum>
f0105e6e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e71:	05 20 00 26 f0       	add    $0xf0260020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105e76:	39 c3                	cmp    %eax,%ebx
f0105e78:	0f 84 a5 00 00 00    	je     f0105f23 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105e7e:	83 ec 04             	sub    $0x4,%esp
f0105e81:	6a 28                	push   $0x28
f0105e83:	8d 46 0c             	lea    0xc(%esi),%eax
f0105e86:	50                   	push   %eax
f0105e87:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105e8a:	53                   	push   %ebx
f0105e8b:	e8 e7 f6 ff ff       	call   f0105577 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105e90:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105e93:	0f b6 38             	movzbl (%eax),%edi
f0105e96:	8b 76 04             	mov    0x4(%esi),%esi
f0105e99:	e8 ac fc ff ff       	call   f0105b4a <cpunum>
f0105e9e:	57                   	push   %edi
f0105e9f:	56                   	push   %esi
f0105ea0:	50                   	push   %eax
f0105ea1:	68 d0 84 10 f0       	push   $0xf01084d0
f0105ea6:	e8 39 d8 ff ff       	call   f01036e4 <cprintf>
f0105eab:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105eae:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105eb1:	eb 54                	jmp    f0105f07 <spin_unlock+0xb2>
f0105eb3:	83 ec 08             	sub    $0x8,%esp
f0105eb6:	57                   	push   %edi
f0105eb7:	50                   	push   %eax
f0105eb8:	e8 f3 eb ff ff       	call   f0104ab0 <debuginfo_eip>
f0105ebd:	83 c4 10             	add    $0x10,%esp
f0105ec0:	85 c0                	test   %eax,%eax
f0105ec2:	78 27                	js     f0105eeb <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105ec4:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105ec6:	83 ec 04             	sub    $0x4,%esp
f0105ec9:	89 c2                	mov    %eax,%edx
f0105ecb:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105ece:	52                   	push   %edx
f0105ecf:	ff 75 b0             	pushl  -0x50(%ebp)
f0105ed2:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105ed5:	ff 75 ac             	pushl  -0x54(%ebp)
f0105ed8:	ff 75 a8             	pushl  -0x58(%ebp)
f0105edb:	50                   	push   %eax
f0105edc:	68 16 85 10 f0       	push   $0xf0108516
f0105ee1:	e8 fe d7 ff ff       	call   f01036e4 <cprintf>
f0105ee6:	83 c4 20             	add    $0x20,%esp
f0105ee9:	eb 12                	jmp    f0105efd <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105eeb:	83 ec 08             	sub    $0x8,%esp
f0105eee:	ff 36                	pushl  (%esi)
f0105ef0:	68 2d 85 10 f0       	push   $0xf010852d
f0105ef5:	e8 ea d7 ff ff       	call   f01036e4 <cprintf>
f0105efa:	83 c4 10             	add    $0x10,%esp
f0105efd:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105f00:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105f03:	39 c3                	cmp    %eax,%ebx
f0105f05:	74 08                	je     f0105f0f <spin_unlock+0xba>
f0105f07:	89 de                	mov    %ebx,%esi
f0105f09:	8b 03                	mov    (%ebx),%eax
f0105f0b:	85 c0                	test   %eax,%eax
f0105f0d:	75 a4                	jne    f0105eb3 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105f0f:	83 ec 04             	sub    $0x4,%esp
f0105f12:	68 35 85 10 f0       	push   $0xf0108535
f0105f17:	6a 67                	push   $0x67
f0105f19:	68 06 85 10 f0       	push   $0xf0108506
f0105f1e:	e8 1d a1 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105f23:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105f2a:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105f31:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f36:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0105f39:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105f3c:	5b                   	pop    %ebx
f0105f3d:	5e                   	pop    %esi
f0105f3e:	5f                   	pop    %edi
f0105f3f:	5d                   	pop    %ebp
f0105f40:	c3                   	ret    

f0105f41 <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f0105f41:	55                   	push   %ebp
f0105f42:	89 e5                	mov    %esp,%ebp
f0105f44:	57                   	push   %edi
f0105f45:	56                   	push   %esi
f0105f46:	53                   	push   %ebx
f0105f47:	83 ec 0c             	sub    $0xc,%esp
f0105f4a:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105f4d:	8b 45 10             	mov    0x10(%ebp),%eax
f0105f50:	8d 58 08             	lea    0x8(%eax),%ebx
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f0105f53:	eb 3a                	jmp    f0105f8f <pci_attach_match+0x4e>
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f0105f55:	39 7b f8             	cmp    %edi,-0x8(%ebx)
f0105f58:	75 32                	jne    f0105f8c <pci_attach_match+0x4b>
f0105f5a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f5d:	39 56 fc             	cmp    %edx,-0x4(%esi)
f0105f60:	75 2a                	jne    f0105f8c <pci_attach_match+0x4b>
			int r = list[i].attachfn(pcif);
f0105f62:	83 ec 0c             	sub    $0xc,%esp
f0105f65:	ff 75 14             	pushl  0x14(%ebp)
f0105f68:	ff d0                	call   *%eax
			if (r > 0)
f0105f6a:	83 c4 10             	add    $0x10,%esp
f0105f6d:	85 c0                	test   %eax,%eax
f0105f6f:	7f 26                	jg     f0105f97 <pci_attach_match+0x56>
				return r;
			if (r < 0)
f0105f71:	85 c0                	test   %eax,%eax
f0105f73:	79 17                	jns    f0105f8c <pci_attach_match+0x4b>
				cprintf("pci_attach_match: attaching "
f0105f75:	83 ec 0c             	sub    $0xc,%esp
f0105f78:	50                   	push   %eax
f0105f79:	ff 36                	pushl  (%esi)
f0105f7b:	ff 75 0c             	pushl  0xc(%ebp)
f0105f7e:	57                   	push   %edi
f0105f7f:	68 50 85 10 f0       	push   $0xf0108550
f0105f84:	e8 5b d7 ff ff       	call   f01036e4 <cprintf>
f0105f89:	83 c4 20             	add    $0x20,%esp
f0105f8c:	83 c3 0c             	add    $0xc,%ebx
f0105f8f:	89 de                	mov    %ebx,%esi
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f0105f91:	8b 03                	mov    (%ebx),%eax
f0105f93:	85 c0                	test   %eax,%eax
f0105f95:	75 be                	jne    f0105f55 <pci_attach_match+0x14>
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f0105f97:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105f9a:	5b                   	pop    %ebx
f0105f9b:	5e                   	pop    %esi
f0105f9c:	5f                   	pop    %edi
f0105f9d:	5d                   	pop    %ebp
f0105f9e:	c3                   	ret    

f0105f9f <pci_conf1_set_addr>:
static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
f0105f9f:	55                   	push   %ebp
f0105fa0:	89 e5                	mov    %esp,%ebp
f0105fa2:	53                   	push   %ebx
f0105fa3:	83 ec 04             	sub    $0x4,%esp
f0105fa6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	assert(bus < 256);
f0105fa9:	3d ff 00 00 00       	cmp    $0xff,%eax
f0105fae:	76 16                	jbe    f0105fc6 <pci_conf1_set_addr+0x27>
f0105fb0:	68 a8 86 10 f0       	push   $0xf01086a8
f0105fb5:	68 c3 76 10 f0       	push   $0xf01076c3
f0105fba:	6a 2b                	push   $0x2b
f0105fbc:	68 b2 86 10 f0       	push   $0xf01086b2
f0105fc1:	e8 7a a0 ff ff       	call   f0100040 <_panic>
	assert(dev < 32);
f0105fc6:	83 fa 1f             	cmp    $0x1f,%edx
f0105fc9:	76 16                	jbe    f0105fe1 <pci_conf1_set_addr+0x42>
f0105fcb:	68 bd 86 10 f0       	push   $0xf01086bd
f0105fd0:	68 c3 76 10 f0       	push   $0xf01076c3
f0105fd5:	6a 2c                	push   $0x2c
f0105fd7:	68 b2 86 10 f0       	push   $0xf01086b2
f0105fdc:	e8 5f a0 ff ff       	call   f0100040 <_panic>
	assert(func < 8);
f0105fe1:	83 f9 07             	cmp    $0x7,%ecx
f0105fe4:	76 16                	jbe    f0105ffc <pci_conf1_set_addr+0x5d>
f0105fe6:	68 c6 86 10 f0       	push   $0xf01086c6
f0105feb:	68 c3 76 10 f0       	push   $0xf01076c3
f0105ff0:	6a 2d                	push   $0x2d
f0105ff2:	68 b2 86 10 f0       	push   $0xf01086b2
f0105ff7:	e8 44 a0 ff ff       	call   f0100040 <_panic>
	assert(offset < 256);
f0105ffc:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0106002:	76 16                	jbe    f010601a <pci_conf1_set_addr+0x7b>
f0106004:	68 cf 86 10 f0       	push   $0xf01086cf
f0106009:	68 c3 76 10 f0       	push   $0xf01076c3
f010600e:	6a 2e                	push   $0x2e
f0106010:	68 b2 86 10 f0       	push   $0xf01086b2
f0106015:	e8 26 a0 ff ff       	call   f0100040 <_panic>
	assert((offset & 0x3) == 0);
f010601a:	f6 c3 03             	test   $0x3,%bl
f010601d:	74 16                	je     f0106035 <pci_conf1_set_addr+0x96>
f010601f:	68 dc 86 10 f0       	push   $0xf01086dc
f0106024:	68 c3 76 10 f0       	push   $0xf01076c3
f0106029:	6a 2f                	push   $0x2f
f010602b:	68 b2 86 10 f0       	push   $0xf01086b2
f0106030:	e8 0b a0 ff ff       	call   f0100040 <_panic>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0106035:	c1 e1 08             	shl    $0x8,%ecx
f0106038:	81 cb 00 00 00 80    	or     $0x80000000,%ebx
f010603e:	09 cb                	or     %ecx,%ebx
f0106040:	c1 e2 0b             	shl    $0xb,%edx
f0106043:	09 d3                	or     %edx,%ebx
f0106045:	c1 e0 10             	shl    $0x10,%eax
f0106048:	09 d8                	or     %ebx,%eax
f010604a:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f010604f:	ef                   	out    %eax,(%dx)

	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}
f0106050:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106053:	c9                   	leave  
f0106054:	c3                   	ret    

f0106055 <pci_conf_read>:

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
f0106055:	55                   	push   %ebp
f0106056:	89 e5                	mov    %esp,%ebp
f0106058:	53                   	push   %ebx
f0106059:	83 ec 10             	sub    $0x10,%esp
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f010605c:	8b 48 08             	mov    0x8(%eax),%ecx
f010605f:	8b 58 04             	mov    0x4(%eax),%ebx
f0106062:	8b 00                	mov    (%eax),%eax
f0106064:	8b 40 04             	mov    0x4(%eax),%eax
f0106067:	52                   	push   %edx
f0106068:	89 da                	mov    %ebx,%edx
f010606a:	e8 30 ff ff ff       	call   f0105f9f <pci_conf1_set_addr>

static __inline uint32_t
inl(int port)
{
	uint32_t data;
	__asm __volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f010606f:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0106074:	ed                   	in     (%dx),%eax
	return inl(pci_conf1_data_ioport);
}
f0106075:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106078:	c9                   	leave  
f0106079:	c3                   	ret    

f010607a <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f010607a:	55                   	push   %ebp
f010607b:	89 e5                	mov    %esp,%ebp
f010607d:	57                   	push   %edi
f010607e:	56                   	push   %esi
f010607f:	53                   	push   %ebx
f0106080:	81 ec 00 01 00 00    	sub    $0x100,%esp
f0106086:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f0106088:	6a 48                	push   $0x48
f010608a:	6a 00                	push   $0x0
f010608c:	8d 45 a0             	lea    -0x60(%ebp),%eax
f010608f:	50                   	push   %eax
f0106090:	e8 95 f4 ff ff       	call   f010552a <memset>
	df.bus = bus;
f0106095:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f0106098:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f010609f:	83 c4 10             	add    $0x10,%esp
}

static int
pci_scan_bus(struct pci_bus *bus)
{
	int totaldev = 0;
f01060a2:	c7 85 00 ff ff ff 00 	movl   $0x0,-0x100(%ebp)
f01060a9:	00 00 00 
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f01060ac:	ba 0c 00 00 00       	mov    $0xc,%edx
f01060b1:	8d 45 a0             	lea    -0x60(%ebp),%eax
f01060b4:	e8 9c ff ff ff       	call   f0106055 <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f01060b9:	89 c2                	mov    %eax,%edx
f01060bb:	c1 ea 10             	shr    $0x10,%edx
f01060be:	83 e2 7f             	and    $0x7f,%edx
f01060c1:	83 fa 01             	cmp    $0x1,%edx
f01060c4:	0f 87 4b 01 00 00    	ja     f0106215 <pci_scan_bus+0x19b>
			continue;

		totaldev++;
f01060ca:	83 85 00 ff ff ff 01 	addl   $0x1,-0x100(%ebp)

		struct pci_func f = df;
f01060d1:	8d bd 10 ff ff ff    	lea    -0xf0(%ebp),%edi
f01060d7:	8d 75 a0             	lea    -0x60(%ebp),%esi
f01060da:	b9 12 00 00 00       	mov    $0x12,%ecx
f01060df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f01060e1:	c7 85 18 ff ff ff 00 	movl   $0x0,-0xe8(%ebp)
f01060e8:	00 00 00 
f01060eb:	25 00 00 80 00       	and    $0x800000,%eax
f01060f0:	83 f8 01             	cmp    $0x1,%eax
f01060f3:	19 c0                	sbb    %eax,%eax
f01060f5:	83 e0 f9             	and    $0xfffffff9,%eax
f01060f8:	83 c0 08             	add    $0x8,%eax
f01060fb:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
			if (PCI_VENDOR(af.dev_id) == 0xffff)
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f0106101:	8d 9d 58 ff ff ff    	lea    -0xa8(%ebp),%ebx
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106107:	e9 f7 00 00 00       	jmp    f0106203 <pci_scan_bus+0x189>
		     f.func++) {
			struct pci_func af = f;
f010610c:	8d bd 58 ff ff ff    	lea    -0xa8(%ebp),%edi
f0106112:	8d b5 10 ff ff ff    	lea    -0xf0(%ebp),%esi
f0106118:	b9 12 00 00 00       	mov    $0x12,%ecx
f010611d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f010611f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106124:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f010612a:	e8 26 ff ff ff       	call   f0106055 <pci_conf_read>
f010612f:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f0106135:	66 83 f8 ff          	cmp    $0xffff,%ax
f0106139:	0f 84 bd 00 00 00    	je     f01061fc <pci_scan_bus+0x182>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f010613f:	ba 3c 00 00 00       	mov    $0x3c,%edx
f0106144:	89 d8                	mov    %ebx,%eax
f0106146:	e8 0a ff ff ff       	call   f0106055 <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f010614b:	88 45 9c             	mov    %al,-0x64(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f010614e:	ba 08 00 00 00       	mov    $0x8,%edx
f0106153:	89 d8                	mov    %ebx,%eax
f0106155:	e8 fb fe ff ff       	call   f0106055 <pci_conf_read>
f010615a:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f0106160:	89 c1                	mov    %eax,%ecx
f0106162:	c1 e9 18             	shr    $0x18,%ecx
};

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
f0106165:	be f0 86 10 f0       	mov    $0xf01086f0,%esi
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f010616a:	83 f9 06             	cmp    $0x6,%ecx
f010616d:	77 07                	ja     f0106176 <pci_scan_bus+0xfc>
		class = pci_class[PCI_CLASS(f->dev_class)];
f010616f:	8b 34 8d 64 87 10 f0 	mov    -0xfef789c(,%ecx,4),%esi

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0106176:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f010617c:	83 ec 08             	sub    $0x8,%esp
f010617f:	0f b6 7d 9c          	movzbl -0x64(%ebp),%edi
f0106183:	57                   	push   %edi
f0106184:	56                   	push   %esi
f0106185:	c1 e8 10             	shr    $0x10,%eax
f0106188:	0f b6 c0             	movzbl %al,%eax
f010618b:	50                   	push   %eax
f010618c:	51                   	push   %ecx
f010618d:	89 d0                	mov    %edx,%eax
f010618f:	c1 e8 10             	shr    $0x10,%eax
f0106192:	50                   	push   %eax
f0106193:	0f b7 d2             	movzwl %dx,%edx
f0106196:	52                   	push   %edx
f0106197:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f010619d:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
f01061a3:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f01061a9:	ff 70 04             	pushl  0x4(%eax)
f01061ac:	68 7c 85 10 f0       	push   $0xf010857c
f01061b1:	e8 2e d5 ff ff       	call   f01036e4 <cprintf>
static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
f01061b6:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f01061bc:	83 c4 30             	add    $0x30,%esp
f01061bf:	53                   	push   %ebx
f01061c0:	68 f4 23 12 f0       	push   $0xf01223f4
f01061c5:	89 c2                	mov    %eax,%edx
f01061c7:	c1 ea 10             	shr    $0x10,%edx
f01061ca:	0f b6 d2             	movzbl %dl,%edx
f01061cd:	52                   	push   %edx
f01061ce:	c1 e8 18             	shr    $0x18,%eax
f01061d1:	50                   	push   %eax
f01061d2:	e8 6a fd ff ff       	call   f0105f41 <pci_attach_match>
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
f01061d7:	83 c4 10             	add    $0x10,%esp
f01061da:	85 c0                	test   %eax,%eax
f01061dc:	75 1e                	jne    f01061fc <pci_scan_bus+0x182>
		pci_attach_match(PCI_VENDOR(f->dev_id),
				 PCI_PRODUCT(f->dev_id),
f01061de:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
f01061e4:	53                   	push   %ebx
f01061e5:	68 80 fe 25 f0       	push   $0xf025fe80
f01061ea:	89 c2                	mov    %eax,%edx
f01061ec:	c1 ea 10             	shr    $0x10,%edx
f01061ef:	52                   	push   %edx
f01061f0:	0f b7 c0             	movzwl %ax,%eax
f01061f3:	50                   	push   %eax
f01061f4:	e8 48 fd ff ff       	call   f0105f41 <pci_attach_match>
f01061f9:	83 c4 10             	add    $0x10,%esp

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f01061fc:	83 85 18 ff ff ff 01 	addl   $0x1,-0xe8(%ebp)
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106203:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
f0106209:	3b 85 18 ff ff ff    	cmp    -0xe8(%ebp),%eax
f010620f:	0f 87 f7 fe ff ff    	ja     f010610c <pci_scan_bus+0x92>
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
f0106215:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0106218:	83 c0 01             	add    $0x1,%eax
f010621b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f010621e:	83 f8 1f             	cmp    $0x1f,%eax
f0106221:	0f 86 85 fe ff ff    	jbe    f01060ac <pci_scan_bus+0x32>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f0106227:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
f010622d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106230:	5b                   	pop    %ebx
f0106231:	5e                   	pop    %esi
f0106232:	5f                   	pop    %edi
f0106233:	5d                   	pop    %ebp
f0106234:	c3                   	ret    

f0106235 <pci_bridge_attach>:

static int
pci_bridge_attach(struct pci_func *pcif)
{
f0106235:	55                   	push   %ebp
f0106236:	89 e5                	mov    %esp,%ebp
f0106238:	57                   	push   %edi
f0106239:	56                   	push   %esi
f010623a:	53                   	push   %ebx
f010623b:	83 ec 1c             	sub    $0x1c,%esp
f010623e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f0106241:	ba 1c 00 00 00       	mov    $0x1c,%edx
f0106246:	89 d8                	mov    %ebx,%eax
f0106248:	e8 08 fe ff ff       	call   f0106055 <pci_conf_read>
f010624d:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f010624f:	ba 18 00 00 00       	mov    $0x18,%edx
f0106254:	89 d8                	mov    %ebx,%eax
f0106256:	e8 fa fd ff ff       	call   f0106055 <pci_conf_read>

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f010625b:	83 e7 0f             	and    $0xf,%edi
f010625e:	83 ff 01             	cmp    $0x1,%edi
f0106261:	75 1f                	jne    f0106282 <pci_bridge_attach+0x4d>
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f0106263:	ff 73 08             	pushl  0x8(%ebx)
f0106266:	ff 73 04             	pushl  0x4(%ebx)
f0106269:	8b 03                	mov    (%ebx),%eax
f010626b:	ff 70 04             	pushl  0x4(%eax)
f010626e:	68 b8 85 10 f0       	push   $0xf01085b8
f0106273:	e8 6c d4 ff ff       	call   f01036e4 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
f0106278:	83 c4 10             	add    $0x10,%esp
f010627b:	b8 00 00 00 00       	mov    $0x0,%eax
f0106280:	eb 4e                	jmp    f01062d0 <pci_bridge_attach+0x9b>
f0106282:	89 c6                	mov    %eax,%esi
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f0106284:	83 ec 04             	sub    $0x4,%esp
f0106287:	6a 08                	push   $0x8
f0106289:	6a 00                	push   $0x0
f010628b:	8d 7d e0             	lea    -0x20(%ebp),%edi
f010628e:	57                   	push   %edi
f010628f:	e8 96 f2 ff ff       	call   f010552a <memset>
	nbus.parent_bridge = pcif;
f0106294:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f0106297:	89 f0                	mov    %esi,%eax
f0106299:	0f b6 c4             	movzbl %ah,%eax
f010629c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f010629f:	83 c4 08             	add    $0x8,%esp
f01062a2:	89 f2                	mov    %esi,%edx
f01062a4:	c1 ea 10             	shr    $0x10,%edx
f01062a7:	0f b6 f2             	movzbl %dl,%esi
f01062aa:	56                   	push   %esi
f01062ab:	50                   	push   %eax
f01062ac:	ff 73 08             	pushl  0x8(%ebx)
f01062af:	ff 73 04             	pushl  0x4(%ebx)
f01062b2:	8b 03                	mov    (%ebx),%eax
f01062b4:	ff 70 04             	pushl  0x4(%eax)
f01062b7:	68 ec 85 10 f0       	push   $0xf01085ec
f01062bc:	e8 23 d4 ff ff       	call   f01036e4 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);

	pci_scan_bus(&nbus);
f01062c1:	83 c4 20             	add    $0x20,%esp
f01062c4:	89 f8                	mov    %edi,%eax
f01062c6:	e8 af fd ff ff       	call   f010607a <pci_scan_bus>
	return 1;
f01062cb:	b8 01 00 00 00       	mov    $0x1,%eax
}
f01062d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01062d3:	5b                   	pop    %ebx
f01062d4:	5e                   	pop    %esi
f01062d5:	5f                   	pop    %edi
f01062d6:	5d                   	pop    %ebp
f01062d7:	c3                   	ret    

f01062d8 <pci_conf_write>:
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
f01062d8:	55                   	push   %ebp
f01062d9:	89 e5                	mov    %esp,%ebp
f01062db:	56                   	push   %esi
f01062dc:	53                   	push   %ebx
f01062dd:	89 cb                	mov    %ecx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f01062df:	8b 48 08             	mov    0x8(%eax),%ecx
f01062e2:	8b 70 04             	mov    0x4(%eax),%esi
f01062e5:	8b 00                	mov    (%eax),%eax
f01062e7:	8b 40 04             	mov    0x4(%eax),%eax
f01062ea:	83 ec 0c             	sub    $0xc,%esp
f01062ed:	52                   	push   %edx
f01062ee:	89 f2                	mov    %esi,%edx
f01062f0:	e8 aa fc ff ff       	call   f0105f9f <pci_conf1_set_addr>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f01062f5:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f01062fa:	89 d8                	mov    %ebx,%eax
f01062fc:	ef                   	out    %eax,(%dx)
	outl(pci_conf1_data_ioport, v);
}
f01062fd:	83 c4 10             	add    $0x10,%esp
f0106300:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106303:	5b                   	pop    %ebx
f0106304:	5e                   	pop    %esi
f0106305:	5d                   	pop    %ebp
f0106306:	c3                   	ret    

f0106307 <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f0106307:	55                   	push   %ebp
f0106308:	89 e5                	mov    %esp,%ebp
f010630a:	57                   	push   %edi
f010630b:	56                   	push   %esi
f010630c:	53                   	push   %ebx
f010630d:	83 ec 1c             	sub    $0x1c,%esp
f0106310:	8b 7d 08             	mov    0x8(%ebp),%edi
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f0106313:	b9 07 00 00 00       	mov    $0x7,%ecx
f0106318:	ba 04 00 00 00       	mov    $0x4,%edx
f010631d:	89 f8                	mov    %edi,%eax
f010631f:	e8 b4 ff ff ff       	call   f01062d8 <pci_conf_write>
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0106324:	be 10 00 00 00       	mov    $0x10,%esi
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
f0106329:	89 f2                	mov    %esi,%edx
f010632b:	89 f8                	mov    %edi,%eax
f010632d:	e8 23 fd ff ff       	call   f0106055 <pci_conf_read>
f0106332:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
f0106335:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f010633a:	89 f2                	mov    %esi,%edx
f010633c:	89 f8                	mov    %edi,%eax
f010633e:	e8 95 ff ff ff       	call   f01062d8 <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f0106343:	89 f2                	mov    %esi,%edx
f0106345:	89 f8                	mov    %edi,%eax
f0106347:	e8 09 fd ff ff       	call   f0106055 <pci_conf_read>
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f010634c:	bb 04 00 00 00       	mov    $0x4,%ebx
		pci_conf_write(f, bar, 0xffffffff);
		uint32_t rv = pci_conf_read(f, bar);

		if (rv == 0)
f0106351:	85 c0                	test   %eax,%eax
f0106353:	0f 84 a6 00 00 00    	je     f01063ff <pci_func_enable+0xf8>
			continue;

		int regnum = PCI_MAPREG_NUM(bar);
f0106359:	8d 56 f0             	lea    -0x10(%esi),%edx
f010635c:	c1 ea 02             	shr    $0x2,%edx
f010635f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f0106362:	a8 01                	test   $0x1,%al
f0106364:	75 2c                	jne    f0106392 <pci_func_enable+0x8b>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f0106366:	89 c2                	mov    %eax,%edx
f0106368:	83 e2 06             	and    $0x6,%edx
				bar_width = 8;
f010636b:	83 fa 04             	cmp    $0x4,%edx
f010636e:	0f 94 c3             	sete   %bl
f0106371:	0f b6 db             	movzbl %bl,%ebx
f0106374:	8d 1c 9d 04 00 00 00 	lea    0x4(,%ebx,4),%ebx

			size = PCI_MAPREG_MEM_SIZE(rv);
f010637b:	83 e0 f0             	and    $0xfffffff0,%eax
f010637e:	89 c2                	mov    %eax,%edx
f0106380:	f7 da                	neg    %edx
f0106382:	21 c2                	and    %eax,%edx
f0106384:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_MEM_ADDR(oldv);
f0106387:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010638a:	83 e0 f0             	and    $0xfffffff0,%eax
f010638d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0106390:	eb 1a                	jmp    f01063ac <pci_func_enable+0xa5>
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f0106392:	83 e0 fc             	and    $0xfffffffc,%eax
f0106395:	89 c2                	mov    %eax,%edx
f0106397:	f7 da                	neg    %edx
f0106399:	21 c2                	and    %eax,%edx
f010639b:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_IO_ADDR(oldv);
f010639e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01063a1:	83 e0 fc             	and    $0xfffffffc,%eax
f01063a4:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f01063a7:	bb 04 00 00 00       	mov    $0x4,%ebx
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f01063ac:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01063af:	89 f2                	mov    %esi,%edx
f01063b1:	89 f8                	mov    %edi,%eax
f01063b3:	e8 20 ff ff ff       	call   f01062d8 <pci_conf_write>
f01063b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01063bb:	8d 04 87             	lea    (%edi,%eax,4),%eax
		f->reg_base[regnum] = base;
f01063be:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01063c1:	89 50 14             	mov    %edx,0x14(%eax)
		f->reg_size[regnum] = size;
f01063c4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01063c7:	89 48 2c             	mov    %ecx,0x2c(%eax)

		if (size && !base)
f01063ca:	85 c9                	test   %ecx,%ecx
f01063cc:	74 31                	je     f01063ff <pci_func_enable+0xf8>
f01063ce:	85 d2                	test   %edx,%edx
f01063d0:	75 2d                	jne    f01063ff <pci_func_enable+0xf8>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f01063d2:	8b 47 0c             	mov    0xc(%edi),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f01063d5:	83 ec 0c             	sub    $0xc,%esp
f01063d8:	51                   	push   %ecx
f01063d9:	52                   	push   %edx
f01063da:	ff 75 e0             	pushl  -0x20(%ebp)
f01063dd:	89 c2                	mov    %eax,%edx
f01063df:	c1 ea 10             	shr    $0x10,%edx
f01063e2:	52                   	push   %edx
f01063e3:	0f b7 c0             	movzwl %ax,%eax
f01063e6:	50                   	push   %eax
f01063e7:	ff 77 08             	pushl  0x8(%edi)
f01063ea:	ff 77 04             	pushl  0x4(%edi)
f01063ed:	8b 07                	mov    (%edi),%eax
f01063ef:	ff 70 04             	pushl  0x4(%eax)
f01063f2:	68 1c 86 10 f0       	push   $0xf010861c
f01063f7:	e8 e8 d2 ff ff       	call   f01036e4 <cprintf>
f01063fc:	83 c4 30             	add    $0x30,%esp
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
f01063ff:	01 de                	add    %ebx,%esi
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0106401:	83 fe 27             	cmp    $0x27,%esi
f0106404:	0f 86 1f ff ff ff    	jbe    f0106329 <pci_func_enable+0x22>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f010640a:	8b 47 0c             	mov    0xc(%edi),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f010640d:	83 ec 08             	sub    $0x8,%esp
f0106410:	89 c2                	mov    %eax,%edx
f0106412:	c1 ea 10             	shr    $0x10,%edx
f0106415:	52                   	push   %edx
f0106416:	0f b7 c0             	movzwl %ax,%eax
f0106419:	50                   	push   %eax
f010641a:	ff 77 08             	pushl  0x8(%edi)
f010641d:	ff 77 04             	pushl  0x4(%edi)
f0106420:	8b 07                	mov    (%edi),%eax
f0106422:	ff 70 04             	pushl  0x4(%eax)
f0106425:	68 78 86 10 f0       	push   $0xf0108678
f010642a:	e8 b5 d2 ff ff       	call   f01036e4 <cprintf>
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f010642f:	83 c4 20             	add    $0x20,%esp
f0106432:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106435:	5b                   	pop    %ebx
f0106436:	5e                   	pop    %esi
f0106437:	5f                   	pop    %edi
f0106438:	5d                   	pop    %ebp
f0106439:	c3                   	ret    

f010643a <pci_init>:

int
pci_init(void)
{
f010643a:	55                   	push   %ebp
f010643b:	89 e5                	mov    %esp,%ebp
f010643d:	83 ec 0c             	sub    $0xc,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f0106440:	6a 08                	push   $0x8
f0106442:	6a 00                	push   $0x0
f0106444:	68 8c fe 25 f0       	push   $0xf025fe8c
f0106449:	e8 dc f0 ff ff       	call   f010552a <memset>

	return pci_scan_bus(&root_bus);
f010644e:	b8 8c fe 25 f0       	mov    $0xf025fe8c,%eax
f0106453:	e8 22 fc ff ff       	call   f010607a <pci_scan_bus>
}
f0106458:	c9                   	leave  
f0106459:	c3                   	ret    

f010645a <time_init>:

static unsigned int ticks;

void
time_init(void)
{
f010645a:	55                   	push   %ebp
f010645b:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f010645d:	c7 05 94 fe 25 f0 00 	movl   $0x0,0xf025fe94
f0106464:	00 00 00 
}
f0106467:	5d                   	pop    %ebp
f0106468:	c3                   	ret    

f0106469 <time_tick>:
// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
	ticks++;
f0106469:	a1 94 fe 25 f0       	mov    0xf025fe94,%eax
f010646e:	83 c0 01             	add    $0x1,%eax
f0106471:	a3 94 fe 25 f0       	mov    %eax,0xf025fe94
	if (ticks * 10 < ticks)
f0106476:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0106479:	01 d2                	add    %edx,%edx
f010647b:	39 d0                	cmp    %edx,%eax
f010647d:	76 17                	jbe    f0106496 <time_tick+0x2d>

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
f010647f:	55                   	push   %ebp
f0106480:	89 e5                	mov    %esp,%ebp
f0106482:	83 ec 0c             	sub    $0xc,%esp
	ticks++;
	if (ticks * 10 < ticks)
		panic("time_tick: time overflowed");
f0106485:	68 80 87 10 f0       	push   $0xf0108780
f010648a:	6a 13                	push   $0x13
f010648c:	68 9b 87 10 f0       	push   $0xf010879b
f0106491:	e8 aa 9b ff ff       	call   f0100040 <_panic>
f0106496:	f3 c3                	repz ret 

f0106498 <time_msec>:
}

unsigned int
time_msec(void)
{
f0106498:	55                   	push   %ebp
f0106499:	89 e5                	mov    %esp,%ebp
	return ticks * 10;
f010649b:	a1 94 fe 25 f0       	mov    0xf025fe94,%eax
f01064a0:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01064a3:	01 c0                	add    %eax,%eax
}
f01064a5:	5d                   	pop    %ebp
f01064a6:	c3                   	ret    
f01064a7:	66 90                	xchg   %ax,%ax
f01064a9:	66 90                	xchg   %ax,%ax
f01064ab:	66 90                	xchg   %ax,%ax
f01064ad:	66 90                	xchg   %ax,%ax
f01064af:	90                   	nop

f01064b0 <__udivdi3>:
f01064b0:	55                   	push   %ebp
f01064b1:	57                   	push   %edi
f01064b2:	56                   	push   %esi
f01064b3:	53                   	push   %ebx
f01064b4:	83 ec 1c             	sub    $0x1c,%esp
f01064b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01064bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01064bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01064c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01064c7:	85 f6                	test   %esi,%esi
f01064c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01064cd:	89 ca                	mov    %ecx,%edx
f01064cf:	89 f8                	mov    %edi,%eax
f01064d1:	75 3d                	jne    f0106510 <__udivdi3+0x60>
f01064d3:	39 cf                	cmp    %ecx,%edi
f01064d5:	0f 87 c5 00 00 00    	ja     f01065a0 <__udivdi3+0xf0>
f01064db:	85 ff                	test   %edi,%edi
f01064dd:	89 fd                	mov    %edi,%ebp
f01064df:	75 0b                	jne    f01064ec <__udivdi3+0x3c>
f01064e1:	b8 01 00 00 00       	mov    $0x1,%eax
f01064e6:	31 d2                	xor    %edx,%edx
f01064e8:	f7 f7                	div    %edi
f01064ea:	89 c5                	mov    %eax,%ebp
f01064ec:	89 c8                	mov    %ecx,%eax
f01064ee:	31 d2                	xor    %edx,%edx
f01064f0:	f7 f5                	div    %ebp
f01064f2:	89 c1                	mov    %eax,%ecx
f01064f4:	89 d8                	mov    %ebx,%eax
f01064f6:	89 cf                	mov    %ecx,%edi
f01064f8:	f7 f5                	div    %ebp
f01064fa:	89 c3                	mov    %eax,%ebx
f01064fc:	89 d8                	mov    %ebx,%eax
f01064fe:	89 fa                	mov    %edi,%edx
f0106500:	83 c4 1c             	add    $0x1c,%esp
f0106503:	5b                   	pop    %ebx
f0106504:	5e                   	pop    %esi
f0106505:	5f                   	pop    %edi
f0106506:	5d                   	pop    %ebp
f0106507:	c3                   	ret    
f0106508:	90                   	nop
f0106509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106510:	39 ce                	cmp    %ecx,%esi
f0106512:	77 74                	ja     f0106588 <__udivdi3+0xd8>
f0106514:	0f bd fe             	bsr    %esi,%edi
f0106517:	83 f7 1f             	xor    $0x1f,%edi
f010651a:	0f 84 98 00 00 00    	je     f01065b8 <__udivdi3+0x108>
f0106520:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106525:	89 f9                	mov    %edi,%ecx
f0106527:	89 c5                	mov    %eax,%ebp
f0106529:	29 fb                	sub    %edi,%ebx
f010652b:	d3 e6                	shl    %cl,%esi
f010652d:	89 d9                	mov    %ebx,%ecx
f010652f:	d3 ed                	shr    %cl,%ebp
f0106531:	89 f9                	mov    %edi,%ecx
f0106533:	d3 e0                	shl    %cl,%eax
f0106535:	09 ee                	or     %ebp,%esi
f0106537:	89 d9                	mov    %ebx,%ecx
f0106539:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010653d:	89 d5                	mov    %edx,%ebp
f010653f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106543:	d3 ed                	shr    %cl,%ebp
f0106545:	89 f9                	mov    %edi,%ecx
f0106547:	d3 e2                	shl    %cl,%edx
f0106549:	89 d9                	mov    %ebx,%ecx
f010654b:	d3 e8                	shr    %cl,%eax
f010654d:	09 c2                	or     %eax,%edx
f010654f:	89 d0                	mov    %edx,%eax
f0106551:	89 ea                	mov    %ebp,%edx
f0106553:	f7 f6                	div    %esi
f0106555:	89 d5                	mov    %edx,%ebp
f0106557:	89 c3                	mov    %eax,%ebx
f0106559:	f7 64 24 0c          	mull   0xc(%esp)
f010655d:	39 d5                	cmp    %edx,%ebp
f010655f:	72 10                	jb     f0106571 <__udivdi3+0xc1>
f0106561:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106565:	89 f9                	mov    %edi,%ecx
f0106567:	d3 e6                	shl    %cl,%esi
f0106569:	39 c6                	cmp    %eax,%esi
f010656b:	73 07                	jae    f0106574 <__udivdi3+0xc4>
f010656d:	39 d5                	cmp    %edx,%ebp
f010656f:	75 03                	jne    f0106574 <__udivdi3+0xc4>
f0106571:	83 eb 01             	sub    $0x1,%ebx
f0106574:	31 ff                	xor    %edi,%edi
f0106576:	89 d8                	mov    %ebx,%eax
f0106578:	89 fa                	mov    %edi,%edx
f010657a:	83 c4 1c             	add    $0x1c,%esp
f010657d:	5b                   	pop    %ebx
f010657e:	5e                   	pop    %esi
f010657f:	5f                   	pop    %edi
f0106580:	5d                   	pop    %ebp
f0106581:	c3                   	ret    
f0106582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106588:	31 ff                	xor    %edi,%edi
f010658a:	31 db                	xor    %ebx,%ebx
f010658c:	89 d8                	mov    %ebx,%eax
f010658e:	89 fa                	mov    %edi,%edx
f0106590:	83 c4 1c             	add    $0x1c,%esp
f0106593:	5b                   	pop    %ebx
f0106594:	5e                   	pop    %esi
f0106595:	5f                   	pop    %edi
f0106596:	5d                   	pop    %ebp
f0106597:	c3                   	ret    
f0106598:	90                   	nop
f0106599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01065a0:	89 d8                	mov    %ebx,%eax
f01065a2:	f7 f7                	div    %edi
f01065a4:	31 ff                	xor    %edi,%edi
f01065a6:	89 c3                	mov    %eax,%ebx
f01065a8:	89 d8                	mov    %ebx,%eax
f01065aa:	89 fa                	mov    %edi,%edx
f01065ac:	83 c4 1c             	add    $0x1c,%esp
f01065af:	5b                   	pop    %ebx
f01065b0:	5e                   	pop    %esi
f01065b1:	5f                   	pop    %edi
f01065b2:	5d                   	pop    %ebp
f01065b3:	c3                   	ret    
f01065b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01065b8:	39 ce                	cmp    %ecx,%esi
f01065ba:	72 0c                	jb     f01065c8 <__udivdi3+0x118>
f01065bc:	31 db                	xor    %ebx,%ebx
f01065be:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01065c2:	0f 87 34 ff ff ff    	ja     f01064fc <__udivdi3+0x4c>
f01065c8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01065cd:	e9 2a ff ff ff       	jmp    f01064fc <__udivdi3+0x4c>
f01065d2:	66 90                	xchg   %ax,%ax
f01065d4:	66 90                	xchg   %ax,%ax
f01065d6:	66 90                	xchg   %ax,%ax
f01065d8:	66 90                	xchg   %ax,%ax
f01065da:	66 90                	xchg   %ax,%ax
f01065dc:	66 90                	xchg   %ax,%ax
f01065de:	66 90                	xchg   %ax,%ax

f01065e0 <__umoddi3>:
f01065e0:	55                   	push   %ebp
f01065e1:	57                   	push   %edi
f01065e2:	56                   	push   %esi
f01065e3:	53                   	push   %ebx
f01065e4:	83 ec 1c             	sub    $0x1c,%esp
f01065e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01065eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01065ef:	8b 74 24 34          	mov    0x34(%esp),%esi
f01065f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01065f7:	85 d2                	test   %edx,%edx
f01065f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01065fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106601:	89 f3                	mov    %esi,%ebx
f0106603:	89 3c 24             	mov    %edi,(%esp)
f0106606:	89 74 24 04          	mov    %esi,0x4(%esp)
f010660a:	75 1c                	jne    f0106628 <__umoddi3+0x48>
f010660c:	39 f7                	cmp    %esi,%edi
f010660e:	76 50                	jbe    f0106660 <__umoddi3+0x80>
f0106610:	89 c8                	mov    %ecx,%eax
f0106612:	89 f2                	mov    %esi,%edx
f0106614:	f7 f7                	div    %edi
f0106616:	89 d0                	mov    %edx,%eax
f0106618:	31 d2                	xor    %edx,%edx
f010661a:	83 c4 1c             	add    $0x1c,%esp
f010661d:	5b                   	pop    %ebx
f010661e:	5e                   	pop    %esi
f010661f:	5f                   	pop    %edi
f0106620:	5d                   	pop    %ebp
f0106621:	c3                   	ret    
f0106622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106628:	39 f2                	cmp    %esi,%edx
f010662a:	89 d0                	mov    %edx,%eax
f010662c:	77 52                	ja     f0106680 <__umoddi3+0xa0>
f010662e:	0f bd ea             	bsr    %edx,%ebp
f0106631:	83 f5 1f             	xor    $0x1f,%ebp
f0106634:	75 5a                	jne    f0106690 <__umoddi3+0xb0>
f0106636:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010663a:	0f 82 e0 00 00 00    	jb     f0106720 <__umoddi3+0x140>
f0106640:	39 0c 24             	cmp    %ecx,(%esp)
f0106643:	0f 86 d7 00 00 00    	jbe    f0106720 <__umoddi3+0x140>
f0106649:	8b 44 24 08          	mov    0x8(%esp),%eax
f010664d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106651:	83 c4 1c             	add    $0x1c,%esp
f0106654:	5b                   	pop    %ebx
f0106655:	5e                   	pop    %esi
f0106656:	5f                   	pop    %edi
f0106657:	5d                   	pop    %ebp
f0106658:	c3                   	ret    
f0106659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106660:	85 ff                	test   %edi,%edi
f0106662:	89 fd                	mov    %edi,%ebp
f0106664:	75 0b                	jne    f0106671 <__umoddi3+0x91>
f0106666:	b8 01 00 00 00       	mov    $0x1,%eax
f010666b:	31 d2                	xor    %edx,%edx
f010666d:	f7 f7                	div    %edi
f010666f:	89 c5                	mov    %eax,%ebp
f0106671:	89 f0                	mov    %esi,%eax
f0106673:	31 d2                	xor    %edx,%edx
f0106675:	f7 f5                	div    %ebp
f0106677:	89 c8                	mov    %ecx,%eax
f0106679:	f7 f5                	div    %ebp
f010667b:	89 d0                	mov    %edx,%eax
f010667d:	eb 99                	jmp    f0106618 <__umoddi3+0x38>
f010667f:	90                   	nop
f0106680:	89 c8                	mov    %ecx,%eax
f0106682:	89 f2                	mov    %esi,%edx
f0106684:	83 c4 1c             	add    $0x1c,%esp
f0106687:	5b                   	pop    %ebx
f0106688:	5e                   	pop    %esi
f0106689:	5f                   	pop    %edi
f010668a:	5d                   	pop    %ebp
f010668b:	c3                   	ret    
f010668c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106690:	8b 34 24             	mov    (%esp),%esi
f0106693:	bf 20 00 00 00       	mov    $0x20,%edi
f0106698:	89 e9                	mov    %ebp,%ecx
f010669a:	29 ef                	sub    %ebp,%edi
f010669c:	d3 e0                	shl    %cl,%eax
f010669e:	89 f9                	mov    %edi,%ecx
f01066a0:	89 f2                	mov    %esi,%edx
f01066a2:	d3 ea                	shr    %cl,%edx
f01066a4:	89 e9                	mov    %ebp,%ecx
f01066a6:	09 c2                	or     %eax,%edx
f01066a8:	89 d8                	mov    %ebx,%eax
f01066aa:	89 14 24             	mov    %edx,(%esp)
f01066ad:	89 f2                	mov    %esi,%edx
f01066af:	d3 e2                	shl    %cl,%edx
f01066b1:	89 f9                	mov    %edi,%ecx
f01066b3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01066b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01066bb:	d3 e8                	shr    %cl,%eax
f01066bd:	89 e9                	mov    %ebp,%ecx
f01066bf:	89 c6                	mov    %eax,%esi
f01066c1:	d3 e3                	shl    %cl,%ebx
f01066c3:	89 f9                	mov    %edi,%ecx
f01066c5:	89 d0                	mov    %edx,%eax
f01066c7:	d3 e8                	shr    %cl,%eax
f01066c9:	89 e9                	mov    %ebp,%ecx
f01066cb:	09 d8                	or     %ebx,%eax
f01066cd:	89 d3                	mov    %edx,%ebx
f01066cf:	89 f2                	mov    %esi,%edx
f01066d1:	f7 34 24             	divl   (%esp)
f01066d4:	89 d6                	mov    %edx,%esi
f01066d6:	d3 e3                	shl    %cl,%ebx
f01066d8:	f7 64 24 04          	mull   0x4(%esp)
f01066dc:	39 d6                	cmp    %edx,%esi
f01066de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01066e2:	89 d1                	mov    %edx,%ecx
f01066e4:	89 c3                	mov    %eax,%ebx
f01066e6:	72 08                	jb     f01066f0 <__umoddi3+0x110>
f01066e8:	75 11                	jne    f01066fb <__umoddi3+0x11b>
f01066ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01066ee:	73 0b                	jae    f01066fb <__umoddi3+0x11b>
f01066f0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01066f4:	1b 14 24             	sbb    (%esp),%edx
f01066f7:	89 d1                	mov    %edx,%ecx
f01066f9:	89 c3                	mov    %eax,%ebx
f01066fb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01066ff:	29 da                	sub    %ebx,%edx
f0106701:	19 ce                	sbb    %ecx,%esi
f0106703:	89 f9                	mov    %edi,%ecx
f0106705:	89 f0                	mov    %esi,%eax
f0106707:	d3 e0                	shl    %cl,%eax
f0106709:	89 e9                	mov    %ebp,%ecx
f010670b:	d3 ea                	shr    %cl,%edx
f010670d:	89 e9                	mov    %ebp,%ecx
f010670f:	d3 ee                	shr    %cl,%esi
f0106711:	09 d0                	or     %edx,%eax
f0106713:	89 f2                	mov    %esi,%edx
f0106715:	83 c4 1c             	add    $0x1c,%esp
f0106718:	5b                   	pop    %ebx
f0106719:	5e                   	pop    %esi
f010671a:	5f                   	pop    %edi
f010671b:	5d                   	pop    %ebp
f010671c:	c3                   	ret    
f010671d:	8d 76 00             	lea    0x0(%esi),%esi
f0106720:	29 f9                	sub    %edi,%ecx
f0106722:	19 d6                	sbb    %edx,%esi
f0106724:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106728:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010672c:	e9 18 ff ff ff       	jmp    f0106649 <__umoddi3+0x69>
