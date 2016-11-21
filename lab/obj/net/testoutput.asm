
obj/net/testoutput:     file format elf32-i386


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
  80002c:	e8 9b 01 00 00       	call   8001cc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	envid_t ns_envid = sys_getenvid();
  800038:	e8 0a 0c 00 00       	call   800c47 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi
	int i, r;

	binaryname = "testoutput";
  80003f:	c7 05 00 20 80 00 40 	movl   $0x801640,0x802000
  800046:	16 80 00 

	output_envid = fork();
  800049:	e8 37 0f 00 00       	call   800f85 <fork>
  80004e:	a3 04 20 80 00       	mov    %eax,0x802004
	if (output_envid < 0)
  800053:	85 c0                	test   %eax,%eax
  800055:	79 14                	jns    80006b <umain+0x38>
		panic("error forking");
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	68 4b 16 80 00       	push   $0x80164b
  80005f:	6a 16                	push   $0x16
  800061:	68 59 16 80 00       	push   $0x801659
  800066:	e8 b9 01 00 00       	call   800224 <_panic>
  80006b:	bb 00 00 00 00       	mov    $0x0,%ebx
	else if (output_envid == 0) {
  800070:	85 c0                	test   %eax,%eax
  800072:	75 11                	jne    800085 <umain+0x52>
		output(ns_envid);
  800074:	83 ec 0c             	sub    $0xc,%esp
  800077:	56                   	push   %esi
  800078:	e8 40 01 00 00       	call   8001bd <output>
		return;
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	e9 8f 00 00 00       	jmp    800114 <umain+0xe1>
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 07                	push   $0x7
  80008a:	68 00 b0 fe 0f       	push   $0xffeb000
  80008f:	6a 00                	push   $0x0
  800091:	e8 ef 0b 00 00       	call   800c85 <sys_page_alloc>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x7c>
			panic("sys_page_alloc: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 6a 16 80 00       	push   $0x80166a
  8000a3:	6a 1e                	push   $0x1e
  8000a5:	68 59 16 80 00       	push   $0x801659
  8000aa:	e8 75 01 00 00       	call   800224 <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000af:	53                   	push   %ebx
  8000b0:	68 7d 16 80 00       	push   $0x80167d
  8000b5:	68 fc 0f 00 00       	push   $0xffc
  8000ba:	68 04 b0 fe 0f       	push   $0xffeb004
  8000bf:	e8 6b 07 00 00       	call   80082f <snprintf>
  8000c4:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000c9:	83 c4 08             	add    $0x8,%esp
  8000cc:	53                   	push   %ebx
  8000cd:	68 89 16 80 00       	push   $0x801689
  8000d2:	e8 26 02 00 00       	call   8002fd <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8000d7:	6a 07                	push   $0x7
  8000d9:	68 00 b0 fe 0f       	push   $0xffeb000
  8000de:	6a 0b                	push   $0xb
  8000e0:	ff 35 04 20 80 00    	pushl  0x802004
  8000e6:	e8 48 11 00 00       	call   801233 <ipc_send>
		sys_page_unmap(0, pkt);
  8000eb:	83 c4 18             	add    $0x18,%esp
  8000ee:	68 00 b0 fe 0f       	push   $0xffeb000
  8000f3:	6a 00                	push   $0x0
  8000f5:	e8 10 0c 00 00       	call   800d0a <sys_page_unmap>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  8000fa:	83 c3 01             	add    $0x1,%ebx
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	83 fb 0a             	cmp    $0xa,%ebx
  800103:	75 80                	jne    800085 <umain+0x52>
  800105:	bb 14 00 00 00       	mov    $0x14,%ebx
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  80010a:	e8 57 0b 00 00       	call   800c66 <sys_yield>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  80010f:	83 eb 01             	sub    $0x1,%ebx
  800112:	75 f6                	jne    80010a <umain+0xd7>
		sys_yield();
}
  800114:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	57                   	push   %edi
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	83 ec 1c             	sub    $0x1c,%esp
  800124:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  800127:	e8 4a 0d 00 00       	call   800e76 <sys_time_msec>
  80012c:	03 45 0c             	add    0xc(%ebp),%eax
  80012f:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  800131:	c7 05 00 20 80 00 a1 	movl   $0x8016a1,0x802000
  800138:	16 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  80013b:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80013e:	eb 05                	jmp    800145 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800140:	e8 21 0b 00 00       	call   800c66 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  800145:	e8 2c 0d 00 00       	call   800e76 <sys_time_msec>
  80014a:	89 c2                	mov    %eax,%edx
  80014c:	85 c0                	test   %eax,%eax
  80014e:	78 04                	js     800154 <timer+0x39>
  800150:	39 c3                	cmp    %eax,%ebx
  800152:	77 ec                	ja     800140 <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  800154:	85 c0                	test   %eax,%eax
  800156:	79 12                	jns    80016a <timer+0x4f>
			panic("sys_time_msec: %e", r);
  800158:	52                   	push   %edx
  800159:	68 aa 16 80 00       	push   $0x8016aa
  80015e:	6a 0f                	push   $0xf
  800160:	68 bc 16 80 00       	push   $0x8016bc
  800165:	e8 ba 00 00 00       	call   800224 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  80016a:	6a 00                	push   $0x0
  80016c:	6a 00                	push   $0x0
  80016e:	6a 0c                	push   $0xc
  800170:	56                   	push   %esi
  800171:	e8 bd 10 00 00       	call   801233 <ipc_send>
  800176:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800179:	83 ec 04             	sub    $0x4,%esp
  80017c:	6a 00                	push   $0x0
  80017e:	6a 00                	push   $0x0
  800180:	57                   	push   %edi
  800181:	e8 38 10 00 00       	call   8011be <ipc_recv>
  800186:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	39 f0                	cmp    %esi,%eax
  800190:	74 13                	je     8001a5 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	50                   	push   %eax
  800196:	68 c8 16 80 00       	push   $0x8016c8
  80019b:	e8 5d 01 00 00       	call   8002fd <cprintf>
				continue;
  8001a0:	83 c4 10             	add    $0x10,%esp
  8001a3:	eb d4                	jmp    800179 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  8001a5:	e8 cc 0c 00 00       	call   800e76 <sys_time_msec>
  8001aa:	01 c3                	add    %eax,%ebx
  8001ac:	eb 97                	jmp    800145 <timer+0x2a>

008001ae <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  8001b1:	c7 05 00 20 80 00 03 	movl   $0x801703,0x802000
  8001b8:	17 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
}
  8001bb:	5d                   	pop    %ebp
  8001bc:	c3                   	ret    

008001bd <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_output";
  8001c0:	c7 05 00 20 80 00 0c 	movl   $0x80170c,0x802000
  8001c7:	17 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
}
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  8001d7:	e8 6b 0a 00 00       	call   800c47 <sys_getenvid>
  8001dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e9:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ee:	85 db                	test   %ebx,%ebx
  8001f0:	7e 07                	jle    8001f9 <libmain+0x2d>
		binaryname = argv[0];
  8001f2:	8b 06                	mov    (%esi),%eax
  8001f4:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	56                   	push   %esi
  8001fd:	53                   	push   %ebx
  8001fe:	e8 30 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800203:	e8 0a 00 00 00       	call   800212 <exit>
}
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800218:	6a 00                	push   $0x0
  80021a:	e8 e7 09 00 00       	call   800c06 <sys_env_destroy>
}
  80021f:	83 c4 10             	add    $0x10,%esp
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800229:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80022c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800232:	e8 10 0a 00 00       	call   800c47 <sys_getenvid>
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	ff 75 0c             	pushl  0xc(%ebp)
  80023d:	ff 75 08             	pushl  0x8(%ebp)
  800240:	56                   	push   %esi
  800241:	50                   	push   %eax
  800242:	68 20 17 80 00       	push   $0x801720
  800247:	e8 b1 00 00 00       	call   8002fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80024c:	83 c4 18             	add    $0x18,%esp
  80024f:	53                   	push   %ebx
  800250:	ff 75 10             	pushl  0x10(%ebp)
  800253:	e8 54 00 00 00       	call   8002ac <vcprintf>
	cprintf("\n");
  800258:	c7 04 24 9f 16 80 00 	movl   $0x80169f,(%esp)
  80025f:	e8 99 00 00 00       	call   8002fd <cprintf>
  800264:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800267:	cc                   	int3   
  800268:	eb fd                	jmp    800267 <_panic+0x43>

0080026a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	53                   	push   %ebx
  80026e:	83 ec 04             	sub    $0x4,%esp
  800271:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800274:	8b 13                	mov    (%ebx),%edx
  800276:	8d 42 01             	lea    0x1(%edx),%eax
  800279:	89 03                	mov    %eax,(%ebx)
  80027b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800282:	3d ff 00 00 00       	cmp    $0xff,%eax
  800287:	75 1a                	jne    8002a3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	68 ff 00 00 00       	push   $0xff
  800291:	8d 43 08             	lea    0x8(%ebx),%eax
  800294:	50                   	push   %eax
  800295:	e8 2f 09 00 00       	call   800bc9 <sys_cputs>
		b->idx = 0;
  80029a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    

008002ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002bc:	00 00 00 
	b.cnt = 0;
  8002bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002c9:	ff 75 0c             	pushl  0xc(%ebp)
  8002cc:	ff 75 08             	pushl  0x8(%ebp)
  8002cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002d5:	50                   	push   %eax
  8002d6:	68 6a 02 80 00       	push   $0x80026a
  8002db:	e8 54 01 00 00       	call   800434 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002e0:	83 c4 08             	add    $0x8,%esp
  8002e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ef:	50                   	push   %eax
  8002f0:	e8 d4 08 00 00       	call   800bc9 <sys_cputs>

	return b.cnt;
}
  8002f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002fb:	c9                   	leave  
  8002fc:	c3                   	ret    

008002fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800303:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800306:	50                   	push   %eax
  800307:	ff 75 08             	pushl  0x8(%ebp)
  80030a:	e8 9d ff ff ff       	call   8002ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	57                   	push   %edi
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
  800317:	83 ec 1c             	sub    $0x1c,%esp
  80031a:	89 c7                	mov    %eax,%edi
  80031c:	89 d6                	mov    %edx,%esi
  80031e:	8b 45 08             	mov    0x8(%ebp),%eax
  800321:	8b 55 0c             	mov    0xc(%ebp),%edx
  800324:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800327:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80032a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80032d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800332:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800335:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800338:	39 d3                	cmp    %edx,%ebx
  80033a:	72 05                	jb     800341 <printnum+0x30>
  80033c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80033f:	77 45                	ja     800386 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800341:	83 ec 0c             	sub    $0xc,%esp
  800344:	ff 75 18             	pushl  0x18(%ebp)
  800347:	8b 45 14             	mov    0x14(%ebp),%eax
  80034a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80034d:	53                   	push   %ebx
  80034e:	ff 75 10             	pushl  0x10(%ebp)
  800351:	83 ec 08             	sub    $0x8,%esp
  800354:	ff 75 e4             	pushl  -0x1c(%ebp)
  800357:	ff 75 e0             	pushl  -0x20(%ebp)
  80035a:	ff 75 dc             	pushl  -0x24(%ebp)
  80035d:	ff 75 d8             	pushl  -0x28(%ebp)
  800360:	e8 3b 10 00 00       	call   8013a0 <__udivdi3>
  800365:	83 c4 18             	add    $0x18,%esp
  800368:	52                   	push   %edx
  800369:	50                   	push   %eax
  80036a:	89 f2                	mov    %esi,%edx
  80036c:	89 f8                	mov    %edi,%eax
  80036e:	e8 9e ff ff ff       	call   800311 <printnum>
  800373:	83 c4 20             	add    $0x20,%esp
  800376:	eb 18                	jmp    800390 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800378:	83 ec 08             	sub    $0x8,%esp
  80037b:	56                   	push   %esi
  80037c:	ff 75 18             	pushl  0x18(%ebp)
  80037f:	ff d7                	call   *%edi
  800381:	83 c4 10             	add    $0x10,%esp
  800384:	eb 03                	jmp    800389 <printnum+0x78>
  800386:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800389:	83 eb 01             	sub    $0x1,%ebx
  80038c:	85 db                	test   %ebx,%ebx
  80038e:	7f e8                	jg     800378 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800390:	83 ec 08             	sub    $0x8,%esp
  800393:	56                   	push   %esi
  800394:	83 ec 04             	sub    $0x4,%esp
  800397:	ff 75 e4             	pushl  -0x1c(%ebp)
  80039a:	ff 75 e0             	pushl  -0x20(%ebp)
  80039d:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003a3:	e8 28 11 00 00       	call   8014d0 <__umoddi3>
  8003a8:	83 c4 14             	add    $0x14,%esp
  8003ab:	0f be 80 43 17 80 00 	movsbl 0x801743(%eax),%eax
  8003b2:	50                   	push   %eax
  8003b3:	ff d7                	call   *%edi
}
  8003b5:	83 c4 10             	add    $0x10,%esp
  8003b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003bb:	5b                   	pop    %ebx
  8003bc:	5e                   	pop    %esi
  8003bd:	5f                   	pop    %edi
  8003be:	5d                   	pop    %ebp
  8003bf:	c3                   	ret    

008003c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c3:	83 fa 01             	cmp    $0x1,%edx
  8003c6:	7e 0e                	jle    8003d6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003c8:	8b 10                	mov    (%eax),%edx
  8003ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003cd:	89 08                	mov    %ecx,(%eax)
  8003cf:	8b 02                	mov    (%edx),%eax
  8003d1:	8b 52 04             	mov    0x4(%edx),%edx
  8003d4:	eb 22                	jmp    8003f8 <getuint+0x38>
	else if (lflag)
  8003d6:	85 d2                	test   %edx,%edx
  8003d8:	74 10                	je     8003ea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003df:	89 08                	mov    %ecx,(%eax)
  8003e1:	8b 02                	mov    (%edx),%eax
  8003e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e8:	eb 0e                	jmp    8003f8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ea:	8b 10                	mov    (%eax),%edx
  8003ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ef:	89 08                	mov    %ecx,(%eax)
  8003f1:	8b 02                	mov    (%edx),%eax
  8003f3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f8:	5d                   	pop    %ebp
  8003f9:	c3                   	ret    

008003fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800400:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800404:	8b 10                	mov    (%eax),%edx
  800406:	3b 50 04             	cmp    0x4(%eax),%edx
  800409:	73 0a                	jae    800415 <sprintputch+0x1b>
		*b->buf++ = ch;
  80040b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80040e:	89 08                	mov    %ecx,(%eax)
  800410:	8b 45 08             	mov    0x8(%ebp),%eax
  800413:	88 02                	mov    %al,(%edx)
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80041d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800420:	50                   	push   %eax
  800421:	ff 75 10             	pushl  0x10(%ebp)
  800424:	ff 75 0c             	pushl  0xc(%ebp)
  800427:	ff 75 08             	pushl  0x8(%ebp)
  80042a:	e8 05 00 00 00       	call   800434 <vprintfmt>
	va_end(ap);
}
  80042f:	83 c4 10             	add    $0x10,%esp
  800432:	c9                   	leave  
  800433:	c3                   	ret    

00800434 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	57                   	push   %edi
  800438:	56                   	push   %esi
  800439:	53                   	push   %ebx
  80043a:	83 ec 2c             	sub    $0x2c,%esp
  80043d:	8b 75 08             	mov    0x8(%ebp),%esi
  800440:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800443:	8b 7d 10             	mov    0x10(%ebp),%edi
  800446:	eb 12                	jmp    80045a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800448:	85 c0                	test   %eax,%eax
  80044a:	0f 84 89 03 00 00    	je     8007d9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	53                   	push   %ebx
  800454:	50                   	push   %eax
  800455:	ff d6                	call   *%esi
  800457:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80045a:	83 c7 01             	add    $0x1,%edi
  80045d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800461:	83 f8 25             	cmp    $0x25,%eax
  800464:	75 e2                	jne    800448 <vprintfmt+0x14>
  800466:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80046a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800471:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800478:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80047f:	ba 00 00 00 00       	mov    $0x0,%edx
  800484:	eb 07                	jmp    80048d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800489:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8d 47 01             	lea    0x1(%edi),%eax
  800490:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800493:	0f b6 07             	movzbl (%edi),%eax
  800496:	0f b6 c8             	movzbl %al,%ecx
  800499:	83 e8 23             	sub    $0x23,%eax
  80049c:	3c 55                	cmp    $0x55,%al
  80049e:	0f 87 1a 03 00 00    	ja     8007be <vprintfmt+0x38a>
  8004a4:	0f b6 c0             	movzbl %al,%eax
  8004a7:	ff 24 85 80 18 80 00 	jmp    *0x801880(,%eax,4)
  8004ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004b1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004b5:	eb d6                	jmp    80048d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004c5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004c9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004cc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004cf:	83 fa 09             	cmp    $0x9,%edx
  8004d2:	77 39                	ja     80050d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004d7:	eb e9                	jmp    8004c2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8004df:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004e2:	8b 00                	mov    (%eax),%eax
  8004e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ea:	eb 27                	jmp    800513 <vprintfmt+0xdf>
  8004ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f6:	0f 49 c8             	cmovns %eax,%ecx
  8004f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ff:	eb 8c                	jmp    80048d <vprintfmt+0x59>
  800501:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800504:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80050b:	eb 80                	jmp    80048d <vprintfmt+0x59>
  80050d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800510:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800513:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800517:	0f 89 70 ff ff ff    	jns    80048d <vprintfmt+0x59>
				width = precision, precision = -1;
  80051d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800520:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800523:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80052a:	e9 5e ff ff ff       	jmp    80048d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80052f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800535:	e9 53 ff ff ff       	jmp    80048d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 50 04             	lea    0x4(%eax),%edx
  800540:	89 55 14             	mov    %edx,0x14(%ebp)
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	53                   	push   %ebx
  800547:	ff 30                	pushl  (%eax)
  800549:	ff d6                	call   *%esi
			break;
  80054b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800551:	e9 04 ff ff ff       	jmp    80045a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 50 04             	lea    0x4(%eax),%edx
  80055c:	89 55 14             	mov    %edx,0x14(%ebp)
  80055f:	8b 00                	mov    (%eax),%eax
  800561:	99                   	cltd   
  800562:	31 d0                	xor    %edx,%eax
  800564:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800566:	83 f8 0f             	cmp    $0xf,%eax
  800569:	7f 0b                	jg     800576 <vprintfmt+0x142>
  80056b:	8b 14 85 e0 19 80 00 	mov    0x8019e0(,%eax,4),%edx
  800572:	85 d2                	test   %edx,%edx
  800574:	75 18                	jne    80058e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800576:	50                   	push   %eax
  800577:	68 5b 17 80 00       	push   $0x80175b
  80057c:	53                   	push   %ebx
  80057d:	56                   	push   %esi
  80057e:	e8 94 fe ff ff       	call   800417 <printfmt>
  800583:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800589:	e9 cc fe ff ff       	jmp    80045a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80058e:	52                   	push   %edx
  80058f:	68 64 17 80 00       	push   $0x801764
  800594:	53                   	push   %ebx
  800595:	56                   	push   %esi
  800596:	e8 7c fe ff ff       	call   800417 <printfmt>
  80059b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a1:	e9 b4 fe ff ff       	jmp    80045a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005b1:	85 ff                	test   %edi,%edi
  8005b3:	b8 54 17 80 00       	mov    $0x801754,%eax
  8005b8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bf:	0f 8e 94 00 00 00    	jle    800659 <vprintfmt+0x225>
  8005c5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005c9:	0f 84 98 00 00 00    	je     800667 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	ff 75 d0             	pushl  -0x30(%ebp)
  8005d5:	57                   	push   %edi
  8005d6:	e8 86 02 00 00       	call   800861 <strnlen>
  8005db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005de:	29 c1                	sub    %eax,%ecx
  8005e0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005e3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005e6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ed:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005f0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f2:	eb 0f                	jmp    800603 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005f4:	83 ec 08             	sub    $0x8,%esp
  8005f7:	53                   	push   %ebx
  8005f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8005fb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fd:	83 ef 01             	sub    $0x1,%edi
  800600:	83 c4 10             	add    $0x10,%esp
  800603:	85 ff                	test   %edi,%edi
  800605:	7f ed                	jg     8005f4 <vprintfmt+0x1c0>
  800607:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80060a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80060d:	85 c9                	test   %ecx,%ecx
  80060f:	b8 00 00 00 00       	mov    $0x0,%eax
  800614:	0f 49 c1             	cmovns %ecx,%eax
  800617:	29 c1                	sub    %eax,%ecx
  800619:	89 75 08             	mov    %esi,0x8(%ebp)
  80061c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80061f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800622:	89 cb                	mov    %ecx,%ebx
  800624:	eb 4d                	jmp    800673 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800626:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80062a:	74 1b                	je     800647 <vprintfmt+0x213>
  80062c:	0f be c0             	movsbl %al,%eax
  80062f:	83 e8 20             	sub    $0x20,%eax
  800632:	83 f8 5e             	cmp    $0x5e,%eax
  800635:	76 10                	jbe    800647 <vprintfmt+0x213>
					putch('?', putdat);
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	ff 75 0c             	pushl  0xc(%ebp)
  80063d:	6a 3f                	push   $0x3f
  80063f:	ff 55 08             	call   *0x8(%ebp)
  800642:	83 c4 10             	add    $0x10,%esp
  800645:	eb 0d                	jmp    800654 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	ff 75 0c             	pushl  0xc(%ebp)
  80064d:	52                   	push   %edx
  80064e:	ff 55 08             	call   *0x8(%ebp)
  800651:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800654:	83 eb 01             	sub    $0x1,%ebx
  800657:	eb 1a                	jmp    800673 <vprintfmt+0x23f>
  800659:	89 75 08             	mov    %esi,0x8(%ebp)
  80065c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80065f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800662:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800665:	eb 0c                	jmp    800673 <vprintfmt+0x23f>
  800667:	89 75 08             	mov    %esi,0x8(%ebp)
  80066a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80066d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800670:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800673:	83 c7 01             	add    $0x1,%edi
  800676:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80067a:	0f be d0             	movsbl %al,%edx
  80067d:	85 d2                	test   %edx,%edx
  80067f:	74 23                	je     8006a4 <vprintfmt+0x270>
  800681:	85 f6                	test   %esi,%esi
  800683:	78 a1                	js     800626 <vprintfmt+0x1f2>
  800685:	83 ee 01             	sub    $0x1,%esi
  800688:	79 9c                	jns    800626 <vprintfmt+0x1f2>
  80068a:	89 df                	mov    %ebx,%edi
  80068c:	8b 75 08             	mov    0x8(%ebp),%esi
  80068f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800692:	eb 18                	jmp    8006ac <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	53                   	push   %ebx
  800698:	6a 20                	push   $0x20
  80069a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069c:	83 ef 01             	sub    $0x1,%edi
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	eb 08                	jmp    8006ac <vprintfmt+0x278>
  8006a4:	89 df                	mov    %ebx,%edi
  8006a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ac:	85 ff                	test   %edi,%edi
  8006ae:	7f e4                	jg     800694 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b3:	e9 a2 fd ff ff       	jmp    80045a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b8:	83 fa 01             	cmp    $0x1,%edx
  8006bb:	7e 16                	jle    8006d3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8d 50 08             	lea    0x8(%eax),%edx
  8006c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c6:	8b 50 04             	mov    0x4(%eax),%edx
  8006c9:	8b 00                	mov    (%eax),%eax
  8006cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006d1:	eb 32                	jmp    800705 <vprintfmt+0x2d1>
	else if (lflag)
  8006d3:	85 d2                	test   %edx,%edx
  8006d5:	74 18                	je     8006ef <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8d 50 04             	lea    0x4(%eax),%edx
  8006dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e0:	8b 00                	mov    (%eax),%eax
  8006e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e5:	89 c1                	mov    %eax,%ecx
  8006e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ed:	eb 16                	jmp    800705 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8d 50 04             	lea    0x4(%eax),%edx
  8006f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f8:	8b 00                	mov    (%eax),%eax
  8006fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fd:	89 c1                	mov    %eax,%ecx
  8006ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800702:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800705:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800708:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80070b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800710:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800714:	79 74                	jns    80078a <vprintfmt+0x356>
				putch('-', putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	53                   	push   %ebx
  80071a:	6a 2d                	push   $0x2d
  80071c:	ff d6                	call   *%esi
				num = -(long long) num;
  80071e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800721:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800724:	f7 d8                	neg    %eax
  800726:	83 d2 00             	adc    $0x0,%edx
  800729:	f7 da                	neg    %edx
  80072b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80072e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800733:	eb 55                	jmp    80078a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800735:	8d 45 14             	lea    0x14(%ebp),%eax
  800738:	e8 83 fc ff ff       	call   8003c0 <getuint>
			base = 10;
  80073d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800742:	eb 46                	jmp    80078a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800744:	8d 45 14             	lea    0x14(%ebp),%eax
  800747:	e8 74 fc ff ff       	call   8003c0 <getuint>
			base = 8;
  80074c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800751:	eb 37                	jmp    80078a <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  800753:	83 ec 08             	sub    $0x8,%esp
  800756:	53                   	push   %ebx
  800757:	6a 30                	push   $0x30
  800759:	ff d6                	call   *%esi
			putch('x', putdat);
  80075b:	83 c4 08             	add    $0x8,%esp
  80075e:	53                   	push   %ebx
  80075f:	6a 78                	push   $0x78
  800761:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80076c:	8b 00                	mov    (%eax),%eax
  80076e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800773:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800776:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80077b:	eb 0d                	jmp    80078a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80077d:	8d 45 14             	lea    0x14(%ebp),%eax
  800780:	e8 3b fc ff ff       	call   8003c0 <getuint>
			base = 16;
  800785:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80078a:	83 ec 0c             	sub    $0xc,%esp
  80078d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800791:	57                   	push   %edi
  800792:	ff 75 e0             	pushl  -0x20(%ebp)
  800795:	51                   	push   %ecx
  800796:	52                   	push   %edx
  800797:	50                   	push   %eax
  800798:	89 da                	mov    %ebx,%edx
  80079a:	89 f0                	mov    %esi,%eax
  80079c:	e8 70 fb ff ff       	call   800311 <printnum>
			break;
  8007a1:	83 c4 20             	add    $0x20,%esp
  8007a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a7:	e9 ae fc ff ff       	jmp    80045a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ac:	83 ec 08             	sub    $0x8,%esp
  8007af:	53                   	push   %ebx
  8007b0:	51                   	push   %ecx
  8007b1:	ff d6                	call   *%esi
			break;
  8007b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007b9:	e9 9c fc ff ff       	jmp    80045a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	6a 25                	push   $0x25
  8007c4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	eb 03                	jmp    8007ce <vprintfmt+0x39a>
  8007cb:	83 ef 01             	sub    $0x1,%edi
  8007ce:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007d2:	75 f7                	jne    8007cb <vprintfmt+0x397>
  8007d4:	e9 81 fc ff ff       	jmp    80045a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007dc:	5b                   	pop    %ebx
  8007dd:	5e                   	pop    %esi
  8007de:	5f                   	pop    %edi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	83 ec 18             	sub    $0x18,%esp
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fe:	85 c0                	test   %eax,%eax
  800800:	74 26                	je     800828 <vsnprintf+0x47>
  800802:	85 d2                	test   %edx,%edx
  800804:	7e 22                	jle    800828 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800806:	ff 75 14             	pushl  0x14(%ebp)
  800809:	ff 75 10             	pushl  0x10(%ebp)
  80080c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80080f:	50                   	push   %eax
  800810:	68 fa 03 80 00       	push   $0x8003fa
  800815:	e8 1a fc ff ff       	call   800434 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80081a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800820:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	eb 05                	jmp    80082d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800828:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80082d:	c9                   	leave  
  80082e:	c3                   	ret    

0080082f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800835:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800838:	50                   	push   %eax
  800839:	ff 75 10             	pushl  0x10(%ebp)
  80083c:	ff 75 0c             	pushl  0xc(%ebp)
  80083f:	ff 75 08             	pushl  0x8(%ebp)
  800842:	e8 9a ff ff ff       	call   8007e1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800847:	c9                   	leave  
  800848:	c3                   	ret    

00800849 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	eb 03                	jmp    800859 <strlen+0x10>
		n++;
  800856:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800859:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80085d:	75 f7                	jne    800856 <strlen+0xd>
		n++;
	return n;
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800867:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086a:	ba 00 00 00 00       	mov    $0x0,%edx
  80086f:	eb 03                	jmp    800874 <strnlen+0x13>
		n++;
  800871:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800874:	39 c2                	cmp    %eax,%edx
  800876:	74 08                	je     800880 <strnlen+0x1f>
  800878:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80087c:	75 f3                	jne    800871 <strnlen+0x10>
  80087e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	53                   	push   %ebx
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80088c:	89 c2                	mov    %eax,%edx
  80088e:	83 c2 01             	add    $0x1,%edx
  800891:	83 c1 01             	add    $0x1,%ecx
  800894:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800898:	88 5a ff             	mov    %bl,-0x1(%edx)
  80089b:	84 db                	test   %bl,%bl
  80089d:	75 ef                	jne    80088e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80089f:	5b                   	pop    %ebx
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a9:	53                   	push   %ebx
  8008aa:	e8 9a ff ff ff       	call   800849 <strlen>
  8008af:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008b2:	ff 75 0c             	pushl  0xc(%ebp)
  8008b5:	01 d8                	add    %ebx,%eax
  8008b7:	50                   	push   %eax
  8008b8:	e8 c5 ff ff ff       	call   800882 <strcpy>
	return dst;
}
  8008bd:	89 d8                	mov    %ebx,%eax
  8008bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c2:	c9                   	leave  
  8008c3:	c3                   	ret    

008008c4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cf:	89 f3                	mov    %esi,%ebx
  8008d1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d4:	89 f2                	mov    %esi,%edx
  8008d6:	eb 0f                	jmp    8008e7 <strncpy+0x23>
		*dst++ = *src;
  8008d8:	83 c2 01             	add    $0x1,%edx
  8008db:	0f b6 01             	movzbl (%ecx),%eax
  8008de:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e1:	80 39 01             	cmpb   $0x1,(%ecx)
  8008e4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e7:	39 da                	cmp    %ebx,%edx
  8008e9:	75 ed                	jne    8008d8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008eb:	89 f0                	mov    %esi,%eax
  8008ed:	5b                   	pop    %ebx
  8008ee:	5e                   	pop    %esi
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	56                   	push   %esi
  8008f5:	53                   	push   %ebx
  8008f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fc:	8b 55 10             	mov    0x10(%ebp),%edx
  8008ff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800901:	85 d2                	test   %edx,%edx
  800903:	74 21                	je     800926 <strlcpy+0x35>
  800905:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800909:	89 f2                	mov    %esi,%edx
  80090b:	eb 09                	jmp    800916 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80090d:	83 c2 01             	add    $0x1,%edx
  800910:	83 c1 01             	add    $0x1,%ecx
  800913:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800916:	39 c2                	cmp    %eax,%edx
  800918:	74 09                	je     800923 <strlcpy+0x32>
  80091a:	0f b6 19             	movzbl (%ecx),%ebx
  80091d:	84 db                	test   %bl,%bl
  80091f:	75 ec                	jne    80090d <strlcpy+0x1c>
  800921:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800923:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800926:	29 f0                	sub    %esi,%eax
}
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800935:	eb 06                	jmp    80093d <strcmp+0x11>
		p++, q++;
  800937:	83 c1 01             	add    $0x1,%ecx
  80093a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80093d:	0f b6 01             	movzbl (%ecx),%eax
  800940:	84 c0                	test   %al,%al
  800942:	74 04                	je     800948 <strcmp+0x1c>
  800944:	3a 02                	cmp    (%edx),%al
  800946:	74 ef                	je     800937 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800948:	0f b6 c0             	movzbl %al,%eax
  80094b:	0f b6 12             	movzbl (%edx),%edx
  80094e:	29 d0                	sub    %edx,%eax
}
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	53                   	push   %ebx
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095c:	89 c3                	mov    %eax,%ebx
  80095e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800961:	eb 06                	jmp    800969 <strncmp+0x17>
		n--, p++, q++;
  800963:	83 c0 01             	add    $0x1,%eax
  800966:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800969:	39 d8                	cmp    %ebx,%eax
  80096b:	74 15                	je     800982 <strncmp+0x30>
  80096d:	0f b6 08             	movzbl (%eax),%ecx
  800970:	84 c9                	test   %cl,%cl
  800972:	74 04                	je     800978 <strncmp+0x26>
  800974:	3a 0a                	cmp    (%edx),%cl
  800976:	74 eb                	je     800963 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800978:	0f b6 00             	movzbl (%eax),%eax
  80097b:	0f b6 12             	movzbl (%edx),%edx
  80097e:	29 d0                	sub    %edx,%eax
  800980:	eb 05                	jmp    800987 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800982:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800987:	5b                   	pop    %ebx
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800994:	eb 07                	jmp    80099d <strchr+0x13>
		if (*s == c)
  800996:	38 ca                	cmp    %cl,%dl
  800998:	74 0f                	je     8009a9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80099a:	83 c0 01             	add    $0x1,%eax
  80099d:	0f b6 10             	movzbl (%eax),%edx
  8009a0:	84 d2                	test   %dl,%dl
  8009a2:	75 f2                	jne    800996 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	eb 03                	jmp    8009ba <strfind+0xf>
  8009b7:	83 c0 01             	add    $0x1,%eax
  8009ba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009bd:	38 ca                	cmp    %cl,%dl
  8009bf:	74 04                	je     8009c5 <strfind+0x1a>
  8009c1:	84 d2                	test   %dl,%dl
  8009c3:	75 f2                	jne    8009b7 <strfind+0xc>
			break;
	return (char *) s;
}
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	57                   	push   %edi
  8009cb:	56                   	push   %esi
  8009cc:	53                   	push   %ebx
  8009cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d3:	85 c9                	test   %ecx,%ecx
  8009d5:	74 36                	je     800a0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009dd:	75 28                	jne    800a07 <memset+0x40>
  8009df:	f6 c1 03             	test   $0x3,%cl
  8009e2:	75 23                	jne    800a07 <memset+0x40>
		c &= 0xFF;
  8009e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e8:	89 d3                	mov    %edx,%ebx
  8009ea:	c1 e3 08             	shl    $0x8,%ebx
  8009ed:	89 d6                	mov    %edx,%esi
  8009ef:	c1 e6 18             	shl    $0x18,%esi
  8009f2:	89 d0                	mov    %edx,%eax
  8009f4:	c1 e0 10             	shl    $0x10,%eax
  8009f7:	09 f0                	or     %esi,%eax
  8009f9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009fb:	89 d8                	mov    %ebx,%eax
  8009fd:	09 d0                	or     %edx,%eax
  8009ff:	c1 e9 02             	shr    $0x2,%ecx
  800a02:	fc                   	cld    
  800a03:	f3 ab                	rep stos %eax,%es:(%edi)
  800a05:	eb 06                	jmp    800a0d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	fc                   	cld    
  800a0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0d:	89 f8                	mov    %edi,%eax
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5f                   	pop    %edi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a22:	39 c6                	cmp    %eax,%esi
  800a24:	73 35                	jae    800a5b <memmove+0x47>
  800a26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a29:	39 d0                	cmp    %edx,%eax
  800a2b:	73 2e                	jae    800a5b <memmove+0x47>
		s += n;
		d += n;
  800a2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a30:	89 d6                	mov    %edx,%esi
  800a32:	09 fe                	or     %edi,%esi
  800a34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3a:	75 13                	jne    800a4f <memmove+0x3b>
  800a3c:	f6 c1 03             	test   $0x3,%cl
  800a3f:	75 0e                	jne    800a4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a41:	83 ef 04             	sub    $0x4,%edi
  800a44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a47:	c1 e9 02             	shr    $0x2,%ecx
  800a4a:	fd                   	std    
  800a4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4d:	eb 09                	jmp    800a58 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a4f:	83 ef 01             	sub    $0x1,%edi
  800a52:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a55:	fd                   	std    
  800a56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a58:	fc                   	cld    
  800a59:	eb 1d                	jmp    800a78 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5b:	89 f2                	mov    %esi,%edx
  800a5d:	09 c2                	or     %eax,%edx
  800a5f:	f6 c2 03             	test   $0x3,%dl
  800a62:	75 0f                	jne    800a73 <memmove+0x5f>
  800a64:	f6 c1 03             	test   $0x3,%cl
  800a67:	75 0a                	jne    800a73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a69:	c1 e9 02             	shr    $0x2,%ecx
  800a6c:	89 c7                	mov    %eax,%edi
  800a6e:	fc                   	cld    
  800a6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a71:	eb 05                	jmp    800a78 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	fc                   	cld    
  800a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a7f:	ff 75 10             	pushl  0x10(%ebp)
  800a82:	ff 75 0c             	pushl  0xc(%ebp)
  800a85:	ff 75 08             	pushl  0x8(%ebp)
  800a88:	e8 87 ff ff ff       	call   800a14 <memmove>
}
  800a8d:	c9                   	leave  
  800a8e:	c3                   	ret    

00800a8f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	56                   	push   %esi
  800a93:	53                   	push   %ebx
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9a:	89 c6                	mov    %eax,%esi
  800a9c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9f:	eb 1a                	jmp    800abb <memcmp+0x2c>
		if (*s1 != *s2)
  800aa1:	0f b6 08             	movzbl (%eax),%ecx
  800aa4:	0f b6 1a             	movzbl (%edx),%ebx
  800aa7:	38 d9                	cmp    %bl,%cl
  800aa9:	74 0a                	je     800ab5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aab:	0f b6 c1             	movzbl %cl,%eax
  800aae:	0f b6 db             	movzbl %bl,%ebx
  800ab1:	29 d8                	sub    %ebx,%eax
  800ab3:	eb 0f                	jmp    800ac4 <memcmp+0x35>
		s1++, s2++;
  800ab5:	83 c0 01             	add    $0x1,%eax
  800ab8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abb:	39 f0                	cmp    %esi,%eax
  800abd:	75 e2                	jne    800aa1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800abf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	53                   	push   %ebx
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800acf:	89 c1                	mov    %eax,%ecx
  800ad1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad8:	eb 0a                	jmp    800ae4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ada:	0f b6 10             	movzbl (%eax),%edx
  800add:	39 da                	cmp    %ebx,%edx
  800adf:	74 07                	je     800ae8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae1:	83 c0 01             	add    $0x1,%eax
  800ae4:	39 c8                	cmp    %ecx,%eax
  800ae6:	72 f2                	jb     800ada <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	57                   	push   %edi
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
  800af1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af7:	eb 03                	jmp    800afc <strtol+0x11>
		s++;
  800af9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afc:	0f b6 01             	movzbl (%ecx),%eax
  800aff:	3c 20                	cmp    $0x20,%al
  800b01:	74 f6                	je     800af9 <strtol+0xe>
  800b03:	3c 09                	cmp    $0x9,%al
  800b05:	74 f2                	je     800af9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b07:	3c 2b                	cmp    $0x2b,%al
  800b09:	75 0a                	jne    800b15 <strtol+0x2a>
		s++;
  800b0b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b13:	eb 11                	jmp    800b26 <strtol+0x3b>
  800b15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b1a:	3c 2d                	cmp    $0x2d,%al
  800b1c:	75 08                	jne    800b26 <strtol+0x3b>
		s++, neg = 1;
  800b1e:	83 c1 01             	add    $0x1,%ecx
  800b21:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b26:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b2c:	75 15                	jne    800b43 <strtol+0x58>
  800b2e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b31:	75 10                	jne    800b43 <strtol+0x58>
  800b33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b37:	75 7c                	jne    800bb5 <strtol+0xca>
		s += 2, base = 16;
  800b39:	83 c1 02             	add    $0x2,%ecx
  800b3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b41:	eb 16                	jmp    800b59 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b43:	85 db                	test   %ebx,%ebx
  800b45:	75 12                	jne    800b59 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b47:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b4f:	75 08                	jne    800b59 <strtol+0x6e>
		s++, base = 8;
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b59:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b61:	0f b6 11             	movzbl (%ecx),%edx
  800b64:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b67:	89 f3                	mov    %esi,%ebx
  800b69:	80 fb 09             	cmp    $0x9,%bl
  800b6c:	77 08                	ja     800b76 <strtol+0x8b>
			dig = *s - '0';
  800b6e:	0f be d2             	movsbl %dl,%edx
  800b71:	83 ea 30             	sub    $0x30,%edx
  800b74:	eb 22                	jmp    800b98 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b76:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b79:	89 f3                	mov    %esi,%ebx
  800b7b:	80 fb 19             	cmp    $0x19,%bl
  800b7e:	77 08                	ja     800b88 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b80:	0f be d2             	movsbl %dl,%edx
  800b83:	83 ea 57             	sub    $0x57,%edx
  800b86:	eb 10                	jmp    800b98 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b88:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b8b:	89 f3                	mov    %esi,%ebx
  800b8d:	80 fb 19             	cmp    $0x19,%bl
  800b90:	77 16                	ja     800ba8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b92:	0f be d2             	movsbl %dl,%edx
  800b95:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b98:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b9b:	7d 0b                	jge    800ba8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b9d:	83 c1 01             	add    $0x1,%ecx
  800ba0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ba4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ba6:	eb b9                	jmp    800b61 <strtol+0x76>

	if (endptr)
  800ba8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bac:	74 0d                	je     800bbb <strtol+0xd0>
		*endptr = (char *) s;
  800bae:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb1:	89 0e                	mov    %ecx,(%esi)
  800bb3:	eb 06                	jmp    800bbb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb5:	85 db                	test   %ebx,%ebx
  800bb7:	74 98                	je     800b51 <strtol+0x66>
  800bb9:	eb 9e                	jmp    800b59 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bbb:	89 c2                	mov    %eax,%edx
  800bbd:	f7 da                	neg    %edx
  800bbf:	85 ff                	test   %edi,%edi
  800bc1:	0f 45 c2             	cmovne %edx,%eax
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	89 c3                	mov    %eax,%ebx
  800bdc:	89 c7                	mov    %eax,%edi
  800bde:	89 c6                	mov    %eax,%esi
  800be0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bed:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf2:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf7:	89 d1                	mov    %edx,%ecx
  800bf9:	89 d3                	mov    %edx,%ebx
  800bfb:	89 d7                	mov    %edx,%edi
  800bfd:	89 d6                	mov    %edx,%esi
  800bff:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c14:	b8 03 00 00 00       	mov    $0x3,%eax
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	89 cb                	mov    %ecx,%ebx
  800c1e:	89 cf                	mov    %ecx,%edi
  800c20:	89 ce                	mov    %ecx,%esi
  800c22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c24:	85 c0                	test   %eax,%eax
  800c26:	7e 17                	jle    800c3f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	50                   	push   %eax
  800c2c:	6a 03                	push   $0x3
  800c2e:	68 3f 1a 80 00       	push   $0x801a3f
  800c33:	6a 23                	push   $0x23
  800c35:	68 5c 1a 80 00       	push   $0x801a5c
  800c3a:	e8 e5 f5 ff ff       	call   800224 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c52:	b8 02 00 00 00       	mov    $0x2,%eax
  800c57:	89 d1                	mov    %edx,%ecx
  800c59:	89 d3                	mov    %edx,%ebx
  800c5b:	89 d7                	mov    %edx,%edi
  800c5d:	89 d6                	mov    %edx,%esi
  800c5f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_yield>:

void
sys_yield(void)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c71:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c76:	89 d1                	mov    %edx,%ecx
  800c78:	89 d3                	mov    %edx,%ebx
  800c7a:	89 d7                	mov    %edx,%edi
  800c7c:	89 d6                	mov    %edx,%esi
  800c7e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	be 00 00 00 00       	mov    $0x0,%esi
  800c93:	b8 04 00 00 00       	mov    $0x4,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca1:	89 f7                	mov    %esi,%edi
  800ca3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7e 17                	jle    800cc0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 04                	push   $0x4
  800caf:	68 3f 1a 80 00       	push   $0x801a3f
  800cb4:	6a 23                	push   $0x23
  800cb6:	68 5c 1a 80 00       	push   $0x801a5c
  800cbb:	e8 64 f5 ff ff       	call   800224 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd1:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce2:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7e 17                	jle    800d02 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	50                   	push   %eax
  800cef:	6a 05                	push   $0x5
  800cf1:	68 3f 1a 80 00       	push   $0x801a3f
  800cf6:	6a 23                	push   $0x23
  800cf8:	68 5c 1a 80 00       	push   $0x801a5c
  800cfd:	e8 22 f5 ff ff       	call   800224 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d18:	b8 06 00 00 00       	mov    $0x6,%eax
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	89 df                	mov    %ebx,%edi
  800d25:	89 de                	mov    %ebx,%esi
  800d27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 17                	jle    800d44 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	50                   	push   %eax
  800d31:	6a 06                	push   $0x6
  800d33:	68 3f 1a 80 00       	push   $0x801a3f
  800d38:	6a 23                	push   $0x23
  800d3a:	68 5c 1a 80 00       	push   $0x801a5c
  800d3f:	e8 e0 f4 ff ff       	call   800224 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 df                	mov    %ebx,%edi
  800d67:	89 de                	mov    %ebx,%esi
  800d69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 17                	jle    800d86 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 08                	push   $0x8
  800d75:	68 3f 1a 80 00       	push   $0x801a3f
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 5c 1a 80 00       	push   $0x801a5c
  800d81:	e8 9e f4 ff ff       	call   800224 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9c:	b8 09 00 00 00       	mov    $0x9,%eax
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	89 df                	mov    %ebx,%edi
  800da9:	89 de                	mov    %ebx,%esi
  800dab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dad:	85 c0                	test   %eax,%eax
  800daf:	7e 17                	jle    800dc8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	6a 09                	push   $0x9
  800db7:	68 3f 1a 80 00       	push   $0x801a3f
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 5c 1a 80 00       	push   $0x801a5c
  800dc3:	e8 5c f4 ff ff       	call   800224 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dde:	b8 0a 00 00 00       	mov    $0xa,%eax
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	89 df                	mov    %ebx,%edi
  800deb:	89 de                	mov    %ebx,%esi
  800ded:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800def:	85 c0                	test   %eax,%eax
  800df1:	7e 17                	jle    800e0a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	50                   	push   %eax
  800df7:	6a 0a                	push   $0xa
  800df9:	68 3f 1a 80 00       	push   $0x801a3f
  800dfe:	6a 23                	push   $0x23
  800e00:	68 5c 1a 80 00       	push   $0x801a5c
  800e05:	e8 1a f4 ff ff       	call   800224 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e18:	be 00 00 00 00       	mov    $0x0,%esi
  800e1d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e25:	8b 55 08             	mov    0x8(%ebp),%edx
  800e28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	57                   	push   %edi
  800e39:	56                   	push   %esi
  800e3a:	53                   	push   %ebx
  800e3b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e43:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e48:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4b:	89 cb                	mov    %ecx,%ebx
  800e4d:	89 cf                	mov    %ecx,%edi
  800e4f:	89 ce                	mov    %ecx,%esi
  800e51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e53:	85 c0                	test   %eax,%eax
  800e55:	7e 17                	jle    800e6e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e57:	83 ec 0c             	sub    $0xc,%esp
  800e5a:	50                   	push   %eax
  800e5b:	6a 0d                	push   $0xd
  800e5d:	68 3f 1a 80 00       	push   $0x801a3f
  800e62:	6a 23                	push   $0x23
  800e64:	68 5c 1a 80 00       	push   $0x801a5c
  800e69:	e8 b6 f3 ff ff       	call   800224 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e81:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e86:	89 d1                	mov    %edx,%ecx
  800e88:	89 d3                	mov    %edx,%ebx
  800e8a:	89 d7                	mov    %edx,%edi
  800e8c:	89 d6                	mov    %edx,%esi
  800e8e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5f                   	pop    %edi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	53                   	push   %ebx
  800e99:	83 ec 04             	sub    $0x4,%esp
  800e9c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e9f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  800ea1:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ea5:	75 14                	jne    800ebb <pgfault+0x26>
		panic("\nPage fault error : Faulting access was not a write access\n");
  800ea7:	83 ec 04             	sub    $0x4,%esp
  800eaa:	68 6c 1a 80 00       	push   $0x801a6c
  800eaf:	6a 22                	push   $0x22
  800eb1:	68 4f 1b 80 00       	push   $0x801b4f
  800eb6:	e8 69 f3 ff ff       	call   800224 <_panic>
	
	//*pte = uvpt[temp];

	if(!(uvpt[PGNUM(addr)] & PTE_COW))
  800ebb:	89 d8                	mov    %ebx,%eax
  800ebd:	c1 e8 0c             	shr    $0xc,%eax
  800ec0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec7:	f6 c4 08             	test   $0x8,%ah
  800eca:	75 14                	jne    800ee0 <pgfault+0x4b>
		panic("\nPage fault error : Not a Copy on write page\n");
  800ecc:	83 ec 04             	sub    $0x4,%esp
  800ecf:	68 a8 1a 80 00       	push   $0x801aa8
  800ed4:	6a 27                	push   $0x27
  800ed6:	68 4f 1b 80 00       	push   $0x801b4f
  800edb:	e8 44 f3 ff ff       	call   800224 <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	if((r = sys_page_alloc(0, PFTEMP, (PTE_P | PTE_U | PTE_W))) < 0)
  800ee0:	83 ec 04             	sub    $0x4,%esp
  800ee3:	6a 07                	push   $0x7
  800ee5:	68 00 f0 7f 00       	push   $0x7ff000
  800eea:	6a 00                	push   $0x0
  800eec:	e8 94 fd ff ff       	call   800c85 <sys_page_alloc>
  800ef1:	83 c4 10             	add    $0x10,%esp
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	79 14                	jns    800f0c <pgfault+0x77>
		panic("\nPage fault error: Sys_page_alloc failed\n");
  800ef8:	83 ec 04             	sub    $0x4,%esp
  800efb:	68 d8 1a 80 00       	push   $0x801ad8
  800f00:	6a 2f                	push   $0x2f
  800f02:	68 4f 1b 80 00       	push   $0x801b4f
  800f07:	e8 18 f3 ff ff       	call   800224 <_panic>

	memmove((void *)PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800f0c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f12:	83 ec 04             	sub    $0x4,%esp
  800f15:	68 00 10 00 00       	push   $0x1000
  800f1a:	53                   	push   %ebx
  800f1b:	68 00 f0 7f 00       	push   $0x7ff000
  800f20:	e8 ef fa ff ff       	call   800a14 <memmove>

	if((r = sys_page_map(0, PFTEMP, 0, (void *)ROUNDDOWN(addr, PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800f25:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f2c:	53                   	push   %ebx
  800f2d:	6a 00                	push   $0x0
  800f2f:	68 00 f0 7f 00       	push   $0x7ff000
  800f34:	6a 00                	push   $0x0
  800f36:	e8 8d fd ff ff       	call   800cc8 <sys_page_map>
  800f3b:	83 c4 20             	add    $0x20,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	79 14                	jns    800f56 <pgfault+0xc1>
		panic("\nPage fault error: Sys_page_map failed\n");
  800f42:	83 ec 04             	sub    $0x4,%esp
  800f45:	68 04 1b 80 00       	push   $0x801b04
  800f4a:	6a 34                	push   $0x34
  800f4c:	68 4f 1b 80 00       	push   $0x801b4f
  800f51:	e8 ce f2 ff ff       	call   800224 <_panic>

	if((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f56:	83 ec 08             	sub    $0x8,%esp
  800f59:	68 00 f0 7f 00       	push   $0x7ff000
  800f5e:	6a 00                	push   $0x0
  800f60:	e8 a5 fd ff ff       	call   800d0a <sys_page_unmap>
  800f65:	83 c4 10             	add    $0x10,%esp
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	79 14                	jns    800f80 <pgfault+0xeb>
		panic("\nPage fault error: Sys_page_unmap\n");
  800f6c:	83 ec 04             	sub    $0x4,%esp
  800f6f:	68 2c 1b 80 00       	push   $0x801b2c
  800f74:	6a 37                	push   $0x37
  800f76:	68 4f 1b 80 00       	push   $0x801b4f
  800f7b:	e8 a4 f2 ff ff       	call   800224 <_panic>
		panic("\nPage fault error: Sys_page_unmap failed\n");
	*/
	// LAB 4: Your code here.

	//panic("pgfault not implemented");
}
  800f80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f83:	c9                   	leave  
  800f84:	c3                   	ret    

00800f85 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	57                   	push   %edi
  800f89:	56                   	push   %esi
  800f8a:	53                   	push   %ebx
  800f8b:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800f8e:	68 95 0e 80 00       	push   $0x800e95
  800f93:	e8 60 03 00 00       	call   8012f8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f98:	b8 07 00 00 00       	mov    $0x7,%eax
  800f9d:	cd 30                	int    $0x30
  800f9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fa2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t pn = 0;
	int r;

	envid = sys_exofork();

	if (envid < 0)
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	79 15                	jns    800fc1 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  800fac:	50                   	push   %eax
  800fad:	68 5a 1b 80 00       	push   $0x801b5a
  800fb2:	68 8d 00 00 00       	push   $0x8d
  800fb7:	68 4f 1b 80 00       	push   $0x801b4f
  800fbc:	e8 63 f2 ff ff       	call   800224 <_panic>
  800fc1:	be 00 00 00 00       	mov    $0x0,%esi
  800fc6:	bb 00 00 00 00       	mov    $0x0,%ebx

	if (envid == 0) {
  800fcb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fcf:	75 21                	jne    800ff2 <fork+0x6d>
		// We're the child.
		thisenv = &envs[ENVX(sys_getenvid())];
  800fd1:	e8 71 fc ff ff       	call   800c47 <sys_getenvid>
  800fd6:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fdb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fde:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fe3:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800fe8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fed:	e9 aa 01 00 00       	jmp    80119c <fork+0x217>
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
		if((uvpd[PDX(pn*PGSIZE)] & PTE_P) && (uvpt[pn] & (PTE_P|PTE_U)))
  800ff2:	89 f0                	mov    %esi,%eax
  800ff4:	c1 e8 16             	shr    $0x16,%eax
  800ff7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ffe:	a8 01                	test   $0x1,%al
  801000:	0f 84 f9 00 00 00    	je     8010ff <fork+0x17a>
  801006:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80100d:	a8 05                	test   $0x5,%al
  80100f:	0f 84 ea 00 00 00    	je     8010ff <fork+0x17a>
	int r;

	int perm = (PTE_P|PTE_U);   //PTE_AVAIL ???


	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)) || (uvpt[pn] & PTE_SHARE))
  801015:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80101c:	a8 02                	test   $0x2,%al
  80101e:	75 1c                	jne    80103c <fork+0xb7>
  801020:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801027:	f6 c4 08             	test   $0x8,%ah
  80102a:	75 10                	jne    80103c <fork+0xb7>
  80102c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801033:	f6 c4 04             	test   $0x4,%ah
  801036:	0f 84 99 00 00 00    	je     8010d5 <fork+0x150>
	{
		if(uvpt[pn] & PTE_SHARE)
  80103c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801043:	f6 c4 04             	test   $0x4,%ah
  801046:	74 0f                	je     801057 <fork+0xd2>
		{
			perm = (uvpt[pn] & PTE_SYSCALL); 
  801048:	8b 3c 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edi
  80104f:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801055:	eb 2d                	jmp    801084 <fork+0xff>
		} else if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW))) {
  801057:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
			perm = PTE_P|PTE_U|PTE_COW;
  80105e:	bf 05 08 00 00       	mov    $0x805,%edi
	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)) || (uvpt[pn] & PTE_SHARE))
	{
		if(uvpt[pn] & PTE_SHARE)
		{
			perm = (uvpt[pn] & PTE_SYSCALL); 
		} else if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW))) {
  801063:	a8 02                	test   $0x2,%al
  801065:	75 1d                	jne    801084 <fork+0xff>
  801067:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80106e:	25 00 08 00 00       	and    $0x800,%eax
			perm = PTE_P|PTE_U|PTE_COW;
  801073:	83 f8 01             	cmp    $0x1,%eax
  801076:	19 ff                	sbb    %edi,%edi
  801078:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  80107e:	81 c7 05 08 00 00    	add    $0x805,%edi
		}

		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), (perm))) < 0)
  801084:	83 ec 0c             	sub    $0xc,%esp
  801087:	57                   	push   %edi
  801088:	56                   	push   %esi
  801089:	ff 75 e4             	pushl  -0x1c(%ebp)
  80108c:	56                   	push   %esi
  80108d:	6a 00                	push   $0x0
  80108f:	e8 34 fc ff ff       	call   800cc8 <sys_page_map>
  801094:	83 c4 20             	add    $0x20,%esp
  801097:	85 c0                	test   %eax,%eax
  801099:	79 12                	jns    8010ad <fork+0x128>
			panic("fork: sys_page_map: %e", r);
  80109b:	50                   	push   %eax
  80109c:	68 6a 1b 80 00       	push   $0x801b6a
  8010a1:	6a 62                	push   $0x62
  8010a3:	68 4f 1b 80 00       	push   $0x801b4f
  8010a8:	e8 77 f1 ff ff       	call   800224 <_panic>
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), (perm))) < 0)
  8010ad:	83 ec 0c             	sub    $0xc,%esp
  8010b0:	57                   	push   %edi
  8010b1:	56                   	push   %esi
  8010b2:	6a 00                	push   $0x0
  8010b4:	56                   	push   %esi
  8010b5:	6a 00                	push   $0x0
  8010b7:	e8 0c fc ff ff       	call   800cc8 <sys_page_map>
  8010bc:	83 c4 20             	add    $0x20,%esp
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	79 3c                	jns    8010ff <fork+0x17a>
			panic("fork: sys_page_map: %e", r);
  8010c3:	50                   	push   %eax
  8010c4:	68 6a 1b 80 00       	push   $0x801b6a
  8010c9:	6a 65                	push   $0x65
  8010cb:	68 4f 1b 80 00       	push   $0x801b4f
  8010d0:	e8 4f f1 ff ff       	call   800224 <_panic>
	}
	else{
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0)
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	6a 05                	push   $0x5
  8010da:	56                   	push   %esi
  8010db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010de:	56                   	push   %esi
  8010df:	6a 00                	push   $0x0
  8010e1:	e8 e2 fb ff ff       	call   800cc8 <sys_page_map>
  8010e6:	83 c4 20             	add    $0x20,%esp
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	79 12                	jns    8010ff <fork+0x17a>
			panic("fork: sys_page_map: %e", r);
  8010ed:	50                   	push   %eax
  8010ee:	68 6a 1b 80 00       	push   $0x801b6a
  8010f3:	6a 6a                	push   $0x6a
  8010f5:	68 4f 1b 80 00       	push   $0x801b4f
  8010fa:	e8 25 f1 ff ff       	call   800224 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
  8010ff:	83 c3 01             	add    $0x1,%ebx
  801102:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801108:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  80110e:	0f 85 de fe ff ff    	jne    800ff2 <fork+0x6d>
			duppage(envid, pn);
	}

	//Copying stack
	
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  801114:	83 ec 04             	sub    $0x4,%esp
  801117:	6a 07                	push   $0x7
  801119:	68 00 f0 bf ee       	push   $0xeebff000
  80111e:	ff 75 e0             	pushl  -0x20(%ebp)
  801121:	e8 5f fb ff ff       	call   800c85 <sys_page_alloc>
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	85 c0                	test   %eax,%eax
  80112b:	79 15                	jns    801142 <fork+0x1bd>
		panic("sys_page_alloc: %e", r);
  80112d:	50                   	push   %eax
  80112e:	68 6a 16 80 00       	push   $0x80166a
  801133:	68 9e 00 00 00       	push   $0x9e
  801138:	68 4f 1b 80 00       	push   $0x801b4f
  80113d:	e8 e2 f0 ff ff       	call   800224 <_panic>

	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801142:	83 ec 08             	sub    $0x8,%esp
  801145:	68 75 13 80 00       	push   $0x801375
  80114a:	ff 75 e0             	pushl  -0x20(%ebp)
  80114d:	e8 7e fc ff ff       	call   800dd0 <sys_env_set_pgfault_upcall>
  801152:	83 c4 10             	add    $0x10,%esp
  801155:	85 c0                	test   %eax,%eax
  801157:	79 17                	jns    801170 <fork+0x1eb>
		panic("sys_pgfault_upcall error");
  801159:	83 ec 04             	sub    $0x4,%esp
  80115c:	68 81 1b 80 00       	push   $0x801b81
  801161:	68 a1 00 00 00       	push   $0xa1
  801166:	68 4f 1b 80 00       	push   $0x801b4f
  80116b:	e8 b4 f0 ff ff       	call   800224 <_panic>
	
	

	//setting child runnable			
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801170:	83 ec 08             	sub    $0x8,%esp
  801173:	6a 02                	push   $0x2
  801175:	ff 75 e0             	pushl  -0x20(%ebp)
  801178:	e8 cf fb ff ff       	call   800d4c <sys_env_set_status>
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	85 c0                	test   %eax,%eax
  801182:	79 15                	jns    801199 <fork+0x214>
		panic("sys_env_set_status: %e", r);
  801184:	50                   	push   %eax
  801185:	68 9a 1b 80 00       	push   $0x801b9a
  80118a:	68 a7 00 00 00       	push   $0xa7
  80118f:	68 4f 1b 80 00       	push   $0x801b4f
  801194:	e8 8b f0 ff ff       	call   800224 <_panic>

	return envid;
  801199:	8b 45 e0             	mov    -0x20(%ebp),%eax
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  80119c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119f:	5b                   	pop    %ebx
  8011a0:	5e                   	pop    %esi
  8011a1:	5f                   	pop    %edi
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <sfork>:

// Challenge!
int
sfork(void)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011aa:	68 b1 1b 80 00       	push   $0x801bb1
  8011af:	68 b2 00 00 00       	push   $0xb2
  8011b4:	68 4f 1b 80 00       	push   $0x801b4f
  8011b9:	e8 66 f0 ff ff       	call   800224 <_panic>

008011be <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	56                   	push   %esi
  8011c2:	53                   	push   %ebx
  8011c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c9:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	74 0e                	je     8011de <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  8011d0:	83 ec 0c             	sub    $0xc,%esp
  8011d3:	50                   	push   %eax
  8011d4:	e8 5c fc ff ff       	call   800e35 <sys_ipc_recv>
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	eb 10                	jmp    8011ee <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  8011de:	83 ec 0c             	sub    $0xc,%esp
  8011e1:	68 00 00 00 f0       	push   $0xf0000000
  8011e6:	e8 4a fc ff ff       	call   800e35 <sys_ipc_recv>
  8011eb:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	74 16                	je     801208 <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  8011f2:	85 db                	test   %ebx,%ebx
  8011f4:	74 36                	je     80122c <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  8011f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  8011fc:	85 f6                	test   %esi,%esi
  8011fe:	74 2c                	je     80122c <ipc_recv+0x6e>
				*perm_store = 0;
  801200:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801206:	eb 24                	jmp    80122c <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  801208:	85 db                	test   %ebx,%ebx
  80120a:	74 18                	je     801224 <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  80120c:	a1 08 20 80 00       	mov    0x802008,%eax
  801211:	8b 40 74             	mov    0x74(%eax),%eax
  801214:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  801216:	85 f6                	test   %esi,%esi
  801218:	74 0a                	je     801224 <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  80121a:	a1 08 20 80 00       	mov    0x802008,%eax
  80121f:	8b 40 78             	mov    0x78(%eax),%eax
  801222:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  801224:	a1 08 20 80 00       	mov    0x802008,%eax
  801229:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  80122c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80122f:	5b                   	pop    %ebx
  801230:	5e                   	pop    %esi
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    

00801233 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	57                   	push   %edi
  801237:	56                   	push   %esi
  801238:	53                   	push   %ebx
  801239:	83 ec 0c             	sub    $0xc,%esp
  80123c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80123f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  801242:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801246:	75 39                	jne    801281 <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  801248:	6a 00                	push   $0x0
  80124a:	68 00 00 00 f0       	push   $0xf0000000
  80124f:	56                   	push   %esi
  801250:	57                   	push   %edi
  801251:	e8 bc fb ff ff       	call   800e12 <sys_ipc_try_send>
  801256:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80125e:	74 16                	je     801276 <ipc_send+0x43>
  801260:	85 c0                	test   %eax,%eax
  801262:	74 12                	je     801276 <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  801264:	50                   	push   %eax
  801265:	68 c8 1b 80 00       	push   $0x801bc8
  80126a:	6a 4f                	push   $0x4f
  80126c:	68 00 1c 80 00       	push   $0x801c00
  801271:	e8 ae ef ff ff       	call   800224 <_panic>
			sys_yield();
  801276:	e8 eb f9 ff ff       	call   800c66 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  80127b:	85 db                	test   %ebx,%ebx
  80127d:	75 c9                	jne    801248 <ipc_send+0x15>
  80127f:	eb 36                	jmp    8012b7 <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  801281:	ff 75 14             	pushl  0x14(%ebp)
  801284:	ff 75 10             	pushl  0x10(%ebp)
  801287:	56                   	push   %esi
  801288:	57                   	push   %edi
  801289:	e8 84 fb ff ff       	call   800e12 <sys_ipc_try_send>
  80128e:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801296:	74 16                	je     8012ae <ipc_send+0x7b>
  801298:	85 c0                	test   %eax,%eax
  80129a:	74 12                	je     8012ae <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  80129c:	50                   	push   %eax
  80129d:	68 c8 1b 80 00       	push   $0x801bc8
  8012a2:	6a 5a                	push   $0x5a
  8012a4:	68 00 1c 80 00       	push   $0x801c00
  8012a9:	e8 76 ef ff ff       	call   800224 <_panic>
			sys_yield();
  8012ae:	e8 b3 f9 ff ff       	call   800c66 <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  8012b3:	85 db                	test   %ebx,%ebx
  8012b5:	75 ca                	jne    801281 <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  8012b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ba:	5b                   	pop    %ebx
  8012bb:	5e                   	pop    %esi
  8012bc:	5f                   	pop    %edi
  8012bd:	5d                   	pop    %ebp
  8012be:	c3                   	ret    

008012bf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012c5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012ca:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012cd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012d3:	8b 52 50             	mov    0x50(%edx),%edx
  8012d6:	39 ca                	cmp    %ecx,%edx
  8012d8:	75 0d                	jne    8012e7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8012da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012e2:	8b 40 48             	mov    0x48(%eax),%eax
  8012e5:	eb 0f                	jmp    8012f6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012e7:	83 c0 01             	add    $0x1,%eax
  8012ea:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012ef:	75 d9                	jne    8012ca <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012fe:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801305:	75 64                	jne    80136b <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		int r;
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801307:	a1 08 20 80 00       	mov    0x802008,%eax
  80130c:	8b 40 48             	mov    0x48(%eax),%eax
  80130f:	83 ec 04             	sub    $0x4,%esp
  801312:	6a 07                	push   $0x7
  801314:	68 00 f0 bf ee       	push   $0xeebff000
  801319:	50                   	push   %eax
  80131a:	e8 66 f9 ff ff       	call   800c85 <sys_page_alloc>
		if ( r != 0)
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	85 c0                	test   %eax,%eax
  801324:	74 14                	je     80133a <set_pgfault_handler+0x42>
			panic("set_pgfault_handler: sys_page_alloc failed.");
  801326:	83 ec 04             	sub    $0x4,%esp
  801329:	68 0c 1c 80 00       	push   $0x801c0c
  80132e:	6a 24                	push   $0x24
  801330:	68 5c 1c 80 00       	push   $0x801c5c
  801335:	e8 ea ee ff ff       	call   800224 <_panic>
			
		if (sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall) < 0)
  80133a:	a1 08 20 80 00       	mov    0x802008,%eax
  80133f:	8b 40 48             	mov    0x48(%eax),%eax
  801342:	83 ec 08             	sub    $0x8,%esp
  801345:	68 75 13 80 00       	push   $0x801375
  80134a:	50                   	push   %eax
  80134b:	e8 80 fa ff ff       	call   800dd0 <sys_env_set_pgfault_upcall>
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	85 c0                	test   %eax,%eax
  801355:	79 14                	jns    80136b <set_pgfault_handler+0x73>
		 	panic("sys_env_set_pgfault_upcall failed");
  801357:	83 ec 04             	sub    $0x4,%esp
  80135a:	68 38 1c 80 00       	push   $0x801c38
  80135f:	6a 27                	push   $0x27
  801361:	68 5c 1c 80 00       	push   $0x801c5c
  801366:	e8 b9 ee ff ff       	call   800224 <_panic>
			
	}

	
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80136b:	8b 45 08             	mov    0x8(%ebp),%eax
  80136e:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801373:	c9                   	leave  
  801374:	c3                   	ret    

00801375 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801375:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801376:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80137b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80137d:	83 c4 04             	add    $0x4,%esp
	addl $0x4,%esp
	popfl
	popl %esp
	ret
*/
movl 0x28(%esp), %eax
  801380:	8b 44 24 28          	mov    0x28(%esp),%eax
movl %esp, %ebx
  801384:	89 e3                	mov    %esp,%ebx
movl 0x30(%esp), %esp
  801386:	8b 64 24 30          	mov    0x30(%esp),%esp
pushl %eax
  80138a:	50                   	push   %eax
movl %esp, 0x30(%ebx)
  80138b:	89 63 30             	mov    %esp,0x30(%ebx)
movl %ebx, %esp
  80138e:	89 dc                	mov    %ebx,%esp
addl $0x8, %esp
  801390:	83 c4 08             	add    $0x8,%esp
popal
  801393:	61                   	popa   
addl $0x4, %esp
  801394:	83 c4 04             	add    $0x4,%esp
popfl
  801397:	9d                   	popf   
popl %esp
  801398:	5c                   	pop    %esp
ret
  801399:	c3                   	ret    
  80139a:	66 90                	xchg   %ax,%ax
  80139c:	66 90                	xchg   %ax,%ax
  80139e:	66 90                	xchg   %ax,%ax

008013a0 <__udivdi3>:
  8013a0:	55                   	push   %ebp
  8013a1:	57                   	push   %edi
  8013a2:	56                   	push   %esi
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 1c             	sub    $0x1c,%esp
  8013a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8013ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8013af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8013b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013b7:	85 f6                	test   %esi,%esi
  8013b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013bd:	89 ca                	mov    %ecx,%edx
  8013bf:	89 f8                	mov    %edi,%eax
  8013c1:	75 3d                	jne    801400 <__udivdi3+0x60>
  8013c3:	39 cf                	cmp    %ecx,%edi
  8013c5:	0f 87 c5 00 00 00    	ja     801490 <__udivdi3+0xf0>
  8013cb:	85 ff                	test   %edi,%edi
  8013cd:	89 fd                	mov    %edi,%ebp
  8013cf:	75 0b                	jne    8013dc <__udivdi3+0x3c>
  8013d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8013d6:	31 d2                	xor    %edx,%edx
  8013d8:	f7 f7                	div    %edi
  8013da:	89 c5                	mov    %eax,%ebp
  8013dc:	89 c8                	mov    %ecx,%eax
  8013de:	31 d2                	xor    %edx,%edx
  8013e0:	f7 f5                	div    %ebp
  8013e2:	89 c1                	mov    %eax,%ecx
  8013e4:	89 d8                	mov    %ebx,%eax
  8013e6:	89 cf                	mov    %ecx,%edi
  8013e8:	f7 f5                	div    %ebp
  8013ea:	89 c3                	mov    %eax,%ebx
  8013ec:	89 d8                	mov    %ebx,%eax
  8013ee:	89 fa                	mov    %edi,%edx
  8013f0:	83 c4 1c             	add    $0x1c,%esp
  8013f3:	5b                   	pop    %ebx
  8013f4:	5e                   	pop    %esi
  8013f5:	5f                   	pop    %edi
  8013f6:	5d                   	pop    %ebp
  8013f7:	c3                   	ret    
  8013f8:	90                   	nop
  8013f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801400:	39 ce                	cmp    %ecx,%esi
  801402:	77 74                	ja     801478 <__udivdi3+0xd8>
  801404:	0f bd fe             	bsr    %esi,%edi
  801407:	83 f7 1f             	xor    $0x1f,%edi
  80140a:	0f 84 98 00 00 00    	je     8014a8 <__udivdi3+0x108>
  801410:	bb 20 00 00 00       	mov    $0x20,%ebx
  801415:	89 f9                	mov    %edi,%ecx
  801417:	89 c5                	mov    %eax,%ebp
  801419:	29 fb                	sub    %edi,%ebx
  80141b:	d3 e6                	shl    %cl,%esi
  80141d:	89 d9                	mov    %ebx,%ecx
  80141f:	d3 ed                	shr    %cl,%ebp
  801421:	89 f9                	mov    %edi,%ecx
  801423:	d3 e0                	shl    %cl,%eax
  801425:	09 ee                	or     %ebp,%esi
  801427:	89 d9                	mov    %ebx,%ecx
  801429:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80142d:	89 d5                	mov    %edx,%ebp
  80142f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801433:	d3 ed                	shr    %cl,%ebp
  801435:	89 f9                	mov    %edi,%ecx
  801437:	d3 e2                	shl    %cl,%edx
  801439:	89 d9                	mov    %ebx,%ecx
  80143b:	d3 e8                	shr    %cl,%eax
  80143d:	09 c2                	or     %eax,%edx
  80143f:	89 d0                	mov    %edx,%eax
  801441:	89 ea                	mov    %ebp,%edx
  801443:	f7 f6                	div    %esi
  801445:	89 d5                	mov    %edx,%ebp
  801447:	89 c3                	mov    %eax,%ebx
  801449:	f7 64 24 0c          	mull   0xc(%esp)
  80144d:	39 d5                	cmp    %edx,%ebp
  80144f:	72 10                	jb     801461 <__udivdi3+0xc1>
  801451:	8b 74 24 08          	mov    0x8(%esp),%esi
  801455:	89 f9                	mov    %edi,%ecx
  801457:	d3 e6                	shl    %cl,%esi
  801459:	39 c6                	cmp    %eax,%esi
  80145b:	73 07                	jae    801464 <__udivdi3+0xc4>
  80145d:	39 d5                	cmp    %edx,%ebp
  80145f:	75 03                	jne    801464 <__udivdi3+0xc4>
  801461:	83 eb 01             	sub    $0x1,%ebx
  801464:	31 ff                	xor    %edi,%edi
  801466:	89 d8                	mov    %ebx,%eax
  801468:	89 fa                	mov    %edi,%edx
  80146a:	83 c4 1c             	add    $0x1c,%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5e                   	pop    %esi
  80146f:	5f                   	pop    %edi
  801470:	5d                   	pop    %ebp
  801471:	c3                   	ret    
  801472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801478:	31 ff                	xor    %edi,%edi
  80147a:	31 db                	xor    %ebx,%ebx
  80147c:	89 d8                	mov    %ebx,%eax
  80147e:	89 fa                	mov    %edi,%edx
  801480:	83 c4 1c             	add    $0x1c,%esp
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5f                   	pop    %edi
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    
  801488:	90                   	nop
  801489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801490:	89 d8                	mov    %ebx,%eax
  801492:	f7 f7                	div    %edi
  801494:	31 ff                	xor    %edi,%edi
  801496:	89 c3                	mov    %eax,%ebx
  801498:	89 d8                	mov    %ebx,%eax
  80149a:	89 fa                	mov    %edi,%edx
  80149c:	83 c4 1c             	add    $0x1c,%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5e                   	pop    %esi
  8014a1:	5f                   	pop    %edi
  8014a2:	5d                   	pop    %ebp
  8014a3:	c3                   	ret    
  8014a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014a8:	39 ce                	cmp    %ecx,%esi
  8014aa:	72 0c                	jb     8014b8 <__udivdi3+0x118>
  8014ac:	31 db                	xor    %ebx,%ebx
  8014ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8014b2:	0f 87 34 ff ff ff    	ja     8013ec <__udivdi3+0x4c>
  8014b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8014bd:	e9 2a ff ff ff       	jmp    8013ec <__udivdi3+0x4c>
  8014c2:	66 90                	xchg   %ax,%ax
  8014c4:	66 90                	xchg   %ax,%ax
  8014c6:	66 90                	xchg   %ax,%ax
  8014c8:	66 90                	xchg   %ax,%ax
  8014ca:	66 90                	xchg   %ax,%ax
  8014cc:	66 90                	xchg   %ax,%ax
  8014ce:	66 90                	xchg   %ax,%ax

008014d0 <__umoddi3>:
  8014d0:	55                   	push   %ebp
  8014d1:	57                   	push   %edi
  8014d2:	56                   	push   %esi
  8014d3:	53                   	push   %ebx
  8014d4:	83 ec 1c             	sub    $0x1c,%esp
  8014d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8014db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8014df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8014e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8014e7:	85 d2                	test   %edx,%edx
  8014e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8014ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014f1:	89 f3                	mov    %esi,%ebx
  8014f3:	89 3c 24             	mov    %edi,(%esp)
  8014f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014fa:	75 1c                	jne    801518 <__umoddi3+0x48>
  8014fc:	39 f7                	cmp    %esi,%edi
  8014fe:	76 50                	jbe    801550 <__umoddi3+0x80>
  801500:	89 c8                	mov    %ecx,%eax
  801502:	89 f2                	mov    %esi,%edx
  801504:	f7 f7                	div    %edi
  801506:	89 d0                	mov    %edx,%eax
  801508:	31 d2                	xor    %edx,%edx
  80150a:	83 c4 1c             	add    $0x1c,%esp
  80150d:	5b                   	pop    %ebx
  80150e:	5e                   	pop    %esi
  80150f:	5f                   	pop    %edi
  801510:	5d                   	pop    %ebp
  801511:	c3                   	ret    
  801512:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801518:	39 f2                	cmp    %esi,%edx
  80151a:	89 d0                	mov    %edx,%eax
  80151c:	77 52                	ja     801570 <__umoddi3+0xa0>
  80151e:	0f bd ea             	bsr    %edx,%ebp
  801521:	83 f5 1f             	xor    $0x1f,%ebp
  801524:	75 5a                	jne    801580 <__umoddi3+0xb0>
  801526:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80152a:	0f 82 e0 00 00 00    	jb     801610 <__umoddi3+0x140>
  801530:	39 0c 24             	cmp    %ecx,(%esp)
  801533:	0f 86 d7 00 00 00    	jbe    801610 <__umoddi3+0x140>
  801539:	8b 44 24 08          	mov    0x8(%esp),%eax
  80153d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801541:	83 c4 1c             	add    $0x1c,%esp
  801544:	5b                   	pop    %ebx
  801545:	5e                   	pop    %esi
  801546:	5f                   	pop    %edi
  801547:	5d                   	pop    %ebp
  801548:	c3                   	ret    
  801549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801550:	85 ff                	test   %edi,%edi
  801552:	89 fd                	mov    %edi,%ebp
  801554:	75 0b                	jne    801561 <__umoddi3+0x91>
  801556:	b8 01 00 00 00       	mov    $0x1,%eax
  80155b:	31 d2                	xor    %edx,%edx
  80155d:	f7 f7                	div    %edi
  80155f:	89 c5                	mov    %eax,%ebp
  801561:	89 f0                	mov    %esi,%eax
  801563:	31 d2                	xor    %edx,%edx
  801565:	f7 f5                	div    %ebp
  801567:	89 c8                	mov    %ecx,%eax
  801569:	f7 f5                	div    %ebp
  80156b:	89 d0                	mov    %edx,%eax
  80156d:	eb 99                	jmp    801508 <__umoddi3+0x38>
  80156f:	90                   	nop
  801570:	89 c8                	mov    %ecx,%eax
  801572:	89 f2                	mov    %esi,%edx
  801574:	83 c4 1c             	add    $0x1c,%esp
  801577:	5b                   	pop    %ebx
  801578:	5e                   	pop    %esi
  801579:	5f                   	pop    %edi
  80157a:	5d                   	pop    %ebp
  80157b:	c3                   	ret    
  80157c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801580:	8b 34 24             	mov    (%esp),%esi
  801583:	bf 20 00 00 00       	mov    $0x20,%edi
  801588:	89 e9                	mov    %ebp,%ecx
  80158a:	29 ef                	sub    %ebp,%edi
  80158c:	d3 e0                	shl    %cl,%eax
  80158e:	89 f9                	mov    %edi,%ecx
  801590:	89 f2                	mov    %esi,%edx
  801592:	d3 ea                	shr    %cl,%edx
  801594:	89 e9                	mov    %ebp,%ecx
  801596:	09 c2                	or     %eax,%edx
  801598:	89 d8                	mov    %ebx,%eax
  80159a:	89 14 24             	mov    %edx,(%esp)
  80159d:	89 f2                	mov    %esi,%edx
  80159f:	d3 e2                	shl    %cl,%edx
  8015a1:	89 f9                	mov    %edi,%ecx
  8015a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8015ab:	d3 e8                	shr    %cl,%eax
  8015ad:	89 e9                	mov    %ebp,%ecx
  8015af:	89 c6                	mov    %eax,%esi
  8015b1:	d3 e3                	shl    %cl,%ebx
  8015b3:	89 f9                	mov    %edi,%ecx
  8015b5:	89 d0                	mov    %edx,%eax
  8015b7:	d3 e8                	shr    %cl,%eax
  8015b9:	89 e9                	mov    %ebp,%ecx
  8015bb:	09 d8                	or     %ebx,%eax
  8015bd:	89 d3                	mov    %edx,%ebx
  8015bf:	89 f2                	mov    %esi,%edx
  8015c1:	f7 34 24             	divl   (%esp)
  8015c4:	89 d6                	mov    %edx,%esi
  8015c6:	d3 e3                	shl    %cl,%ebx
  8015c8:	f7 64 24 04          	mull   0x4(%esp)
  8015cc:	39 d6                	cmp    %edx,%esi
  8015ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015d2:	89 d1                	mov    %edx,%ecx
  8015d4:	89 c3                	mov    %eax,%ebx
  8015d6:	72 08                	jb     8015e0 <__umoddi3+0x110>
  8015d8:	75 11                	jne    8015eb <__umoddi3+0x11b>
  8015da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8015de:	73 0b                	jae    8015eb <__umoddi3+0x11b>
  8015e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8015e4:	1b 14 24             	sbb    (%esp),%edx
  8015e7:	89 d1                	mov    %edx,%ecx
  8015e9:	89 c3                	mov    %eax,%ebx
  8015eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8015ef:	29 da                	sub    %ebx,%edx
  8015f1:	19 ce                	sbb    %ecx,%esi
  8015f3:	89 f9                	mov    %edi,%ecx
  8015f5:	89 f0                	mov    %esi,%eax
  8015f7:	d3 e0                	shl    %cl,%eax
  8015f9:	89 e9                	mov    %ebp,%ecx
  8015fb:	d3 ea                	shr    %cl,%edx
  8015fd:	89 e9                	mov    %ebp,%ecx
  8015ff:	d3 ee                	shr    %cl,%esi
  801601:	09 d0                	or     %edx,%eax
  801603:	89 f2                	mov    %esi,%edx
  801605:	83 c4 1c             	add    $0x1c,%esp
  801608:	5b                   	pop    %ebx
  801609:	5e                   	pop    %esi
  80160a:	5f                   	pop    %edi
  80160b:	5d                   	pop    %ebp
  80160c:	c3                   	ret    
  80160d:	8d 76 00             	lea    0x0(%esi),%esi
  801610:	29 f9                	sub    %edi,%ecx
  801612:	19 d6                	sbb    %edx,%esi
  801614:	89 74 24 04          	mov    %esi,0x4(%esp)
  801618:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80161c:	e9 18 ff ff ff       	jmp    801539 <__umoddi3+0x69>
